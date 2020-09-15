#!/bin/bash

website='hajr.io'
region="eu-west-3"
path="/$website/dev/db-server"
#database credentials
password=''
username=''
name=''


#Update and install LEMP stack packages and dependencies for WordPress
function installPackages {
    yum update -y
    yum module install php nginx mariadb -y
    yum install php-mysqlnd php-fpm php-json unzip -y
}

#installing AWS CLI version 2 
function installAwsCli {
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    bash ./aws/install
    rm -rf ./aws awscliv2.zip
}

#Installing and configuring WordPress
function installWordPress {
    mkdir /var/www/$website
    cd /var/www/$website
    curl https://wordpress.org/latest.tar.gz -o ./latest.tar.gz
    tar -xzvf ./latest.tar.gz
    cp -r wordpress/* .
    rm -rf latest.tar.gz wordpress 
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chown -R nginx:nginx wp-content
}

#downloanding and overwriting the  Nginx configuration files 
function configuringNginx {
    github_raw_url='https://raw.githubusercontent.com/MohamedHajr/AWS-Wordrpess-Portflio-Automation/master'
    curl "$github_raw_url/hajr.io.conf" -o /etc/nginx/conf.d/hajr.io.conf
    curl "$github_raw_url/nginx.conf" > /etc/nginx/nginx.conf
}
#Get Database credentials
function getAndSetCredentials {
    password=$(aws ssm get-parameter --name "$path/password" --with-decryption --query "Parameter.Value" --output text --region $region)
    username=$(aws ssm get-parameter --name "$path/username" --query "Parameter.Value" --output text --region $region)
    name=$(aws ssm get-parameter --name "$path/name" --query "Parameter.Value" --output text --region $region)
}

#Securing MariaDB by automaing what mysql_secure_installtion does behind the sceanes
#And Creating a new database and user for WordPress
function configuringMariaDB {
mysql --user=root <<-EOF
    UPDATE mysql.user SET Password=PASSWORD('$password') WHERE User='root';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    CREATE DATABASE $name;
    CREATE USER '$username'@'localhost' identified by '$password';
    GRANT ALL ON $name.* TO '$username'@'localhost' identified by '$password';
    FLUSH PRIVILEGES;
EOF
}

#Creating the wp-config.php file with the database credentials
function creatingPhpConfig {
SALTS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
cat <<-EOF > /var/www/hajr.io/wp-config.php
    <?php
    define( 'DB_NAME', '$name' );
    define( 'DB_USER', '$username' );
    define( 'DB_PASSWORD', '$password' );
    define( 'DB_HOST', 'localhost' );
    define( 'DB_CHARSET', 'utf8' );
    define( 'DB_COLLATE', '' );

    $SALTS

    \$table_prefix = 'wp_';
    define( 'WP_DEBUG', false );
    if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
    }
    require_once ABSPATH . 'wp-settings.php';
EOF
}



#Running Everything
installPackages
installAwsCli
installWordPress
configuringNginx
#Spining everything
systemctl enable --now nginx php-fpm mariadb
getAndSetCredentials
configuringMariaDB
creatingPhpConfig
