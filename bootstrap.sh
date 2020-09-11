#!/bin/bash

WEBSITE='hajr.io'

yum update -y
yum module install php nginx mariadb -y
yum install php-mysqlnd php-fpm php-json -y

#Installing Wordpress
mkdir /var/www/$WEBSITE
cd /var/www/$WEBSITE
curl https://wordpress.org/latest.tar.gz -o ./latest.tar.gz
tar -xzvf ./latest.tar.gz
cp -r wordpress/* .
rm -rf latest.tar.gz wordpress 
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chown -R nginx:nginx wp-content

#Creating the wp-config.php file
SALTS=`curl https://api.wordpress.org/secret-key/1.1/salt/`

cat <<EOF > ./wp-config.php
<?php
define( 'DB_NAME', '$DB_NAME' );
define( 'DB_USER', '$DB_USER' );
define( 'DB_PASSWORD', '$DB_PASS' );
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

#adding Nginx configuration
curl https://raw.githubusercontent.com/MohamedHajr/AWS-Wordrpess-Portflio-Automation/master/hajr.io.conf -o /etc/nginx/conf.d/hajr.io.conf
curl https://raw.githubusercontent.com/MohamedHajr/AWS-Wordrpess-Portflio-Automation/master/nginx.conf > /etc/nginx/nginx.conf

#Spining everything
systemctl enable --now nginx php-fpm mariadb
