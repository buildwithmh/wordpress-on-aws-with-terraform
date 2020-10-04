#!/bin/bash

function installPackages {
    yum update -y
    amazon-linux-extras install php7.2 nginx1 lamp-mariadb10.2-php7.2 -y
    yum install mariadb-server -y
}

#Installing and configuring WordPress
function installWordPress {
    echo "Installing WordPress...."

    mkdir /usr/share/nginx/wordpress
    cd /usr/share/nginx/wordpress
    curl https://wordpress.org/latest.tar.gz -o ./latest.tar.gz
    tar -xzvf ./latest.tar.gz
    cp -r wordpress/* .
    rm -rf latest.tar.gz wordpress 
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chown -R nginx:nginx wp-content

    #installing wp-cli
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
}

#downloanding and overwriting the  Nginx configuration files 
function configuringNginx {
    echo "Configuring Nginx ........"

    github_raw_url='https://raw.githubusercontent.com/MohamedHajr/AWS-Wordrpess-Portflio-Automation/master/configurations'
    curl "$github_raw_url/wordpress.conf" -o /etc/nginx/conf.d/wordpress.conf
    curl "$github_raw_url/nginx.conf" > /etc/nginx/nginx.conf
}

#Securing MariaDB by automaing what mysql_secure_installtion does behind the sceanes
#And Creating a new database and user for WordPress
function configuringMariaDB {
    echo "Configuring MariaDB......."

mysql --user=root <<-EOF
    UPDATE mysql.user SET Password=PASSWORD('${db_password}') WHERE User='root';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    CREATE DATABASE ${db_name};
    CREATE USER '${db_username}'@'localhost' identified by '${db_password}';
    GRANT ALL ON ${db_name}.* TO '${db_username}'@'localhost' identified by '${db_password}';
    FLUSH PRIVILEGES;
EOF
}

#Creating the wp-config.php file with the database credentials
function creatingPhpConfig {
echo "Creating wp-config.ph...."

#Grab auto generated Salt Keys
SALTS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
cat <<-EOF > /usr/share/nginx/wordpress/wp-config.php
    <?php
    define( 'DB_NAME', '${db_name}' );
    define( 'DB_USER', '${db_username}' );
    define( 'DB_PASSWORD', '${db_password}' );
    define( 'DB_HOST', '${db_host}' );
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


#Installing Everything
installPackages
installWordPress
configuringNginx
#Spining everything
systemctl enable --now nginx php-fpm mariadb
configuringMariaDB
creatingPhpConfig

# Run wordpress install ...
cd /usr/share/nginx/wordpress
wp core install --url=${site_url} --title="${wp_title}" --admin_user=${wp_username} --admin_password=${wp_password} --admin_email=${wp_email}

#curl -d "weblog_title=${wp_title}&user_name=${wp_username}&admin_password=${wp_password}&admin_password2=${wp_password}&admin_email=${wp_email}" http://$site_url/wp-admin/install.php?step=2

