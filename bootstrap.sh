#!/bin/bash

website='hajr.io'

#Update and install LEMP stack packages and dependencies for Wordpress
yum update -y
yum module install php nginx mariadb -y
yum install php-mysqlnd php-fpm php-json unzip -y

#installing AWS CLI version 2 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
bash ./aws/install
rm -rf ./aws awscliv2.zip

#Installing and configuring Wordpress
mkdir /var/www/$website
cd /var/www/$website
curl https://wordpress.org/latest.tar.gz -o ./latest.tar.gz
tar -xzvf ./latest.tar.gz
cp -r wordpress/* .
rm -rf latest.tar.gz wordpress 
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chown -R nginx:nginx wp-content

#adding Nginx configuration
curl https://raw.githubusercontent.com/MohamedHajr/AWS-Wordrpess-Portflio-Automation/master/hajr.io.conf -o /etc/nginx/conf.d/hajr.io.conf
curl https://raw.githubusercontent.com/MohamedHajr/AWS-Wordrpess-Portflio-Automation/master/nginx.conf > /etc/nginx/nginx.conf

region="eu-west-3"
path="/hajr.io/dev/db-server"

#Get database credentials
password=$(aws ssm get-parameter --name "$path/password" --with-decryption --query "Parameter.Value" --output text --region $region)
username=$(aws ssm get-parameter --name "$path/username" --query "Parameter.Value" --output text --region $region)
name=$(aws ssm get-parameter --name "$path/name" --query "Parameter.Value" --output text --region $region)

#Securing MariaDB by automaing what mysql_secure_installtion does behind the sceanes
# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password=PASSWORD('$password') WHERE User='root';"
# Kill the anonymous users
mysql -e "DELETE FROM mysql.user WHERE User='';"
#Disallow remote login
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
# Kill off the demo database
mysql -e "DROP DATABASE IF EXISTS test;"
#Removing privileges on test database...
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param


#Creating the wp-config.php file with the database credentials
SALTS=`curl https://api.wordpress.org/secret-key/1.1/salt/`

cat <<EOF > /var/www/hajr.io/wp-config.php
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

#Spining everything
systemctl enable --now nginx php-fpm mariadb
