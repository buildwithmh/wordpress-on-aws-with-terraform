#!/bin/bash

wordpress_dir=/usr/share/nginx/wordpress

function installPackages {
    yum update -y
    amazon-linux-extras install php7.2 nginx1 lamp-mariadb10.2-php7.2 -y
    yum install amazon-efs-utils -y
}

function installMemcachedClient {
    wget https://elasticache-downloads.s3.amazonaws.com/ClusterClient/PHP-7.0/latest-64bit
    tar -zxvf latest-64bit
    mv artifact/amazon-elasticache-cluster-client.so /usr/lib64/php/modules/
    echo "extension=amazon-elasticache-cluster-client.so" | sudo tee --append /etc/php.d/50-memcached.ini
    rm -rfv latest-64bit artifact
}


#Mount the EFS file system to the wordpress dir
function mountEFS {
     mkdir $wordpress_dir
     mount -t efs ${file_system_id}:/ $wordpress_dir
}


#downloanding and overwriting the  Nginx configuration files 
function configuringNginx {
    echo "Configuring Nginx ........"

    github_raw_url='https://raw.githubusercontent.com/MohamedHajr/wordpress-on-aws-with-terraform/master/configurations'
    curl "$github_raw_url/wordpress.conf" -o /etc/nginx/conf.d/wordpress.conf
    curl "$github_raw_url/nginx.conf" > /etc/nginx/nginx.conf
    sed -i '/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0' /etc/php.ini
    #sed -i '/user = apache/c\user = apache, nginx' /etc/php-fpm.d/www.conf
}

function installWordpress {
    cd $wordpress_dir

    echo "Downloading WP-CLI...."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    echo "Downloading Wordpress...."
    wp core download 

    #create wp-config.php
    echo "Generating wp-config.php...."
    wp config create --dbname=${db_name} --dbuser=${db_username} --dbpass=${db_password} --dbhost=${db_host}

    echo "Installing Wordpress...."
    wp core install --url=${site_url} --title="${wp_title}" --admin_user=${wp_username} --admin_password=${wp_password} --admin_email=${wp_email}

    #Install w3-total cache plugin 
    wp plugin install w3-total-cache --activate
}


#Installing Everything
installPackages
mountEFS
configuringNginx

#Spining everything
systemctl enable --now nginx php-fpm 

if [ -n "$(ls -A $wordpress_dir 2>/dev/null)" ]
then
    echo "Wordpress Already installed on the EFS file system"
else
    installWordpress 
fi
