#!/bin/bash

wordpress_dir=/usr/share/nginx/wordpress

function installPackages {
    yum update -y
    amazon-linux-extras install php7.2 nginx1 lamp-mariadb10.2-php7.2 -y
    yum install amazon-efs-utils -y
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
}

function installWordpress {
    echo "Installing WordPress...."

    cd $wordpress_dir
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

    #create wp-config.php
    wp config create --dbname=${db_name} --dbuser=${db_username} --dbpass=${db_password} --dbhost=${db_host}

    # Run wordpress install ...
    wp core install --url=${site_url} --title="${wp_title}" --admin_user=${wp_username} --admin_password=${wp_password} --admin_email=${wp_email}
}

#Installing Everything
installPackages
mountEFS
configuringNginx

#Spining everything
systemctl enable --now nginx php-fpm 

if (( $(shopt -s nullglob dotglob; echo $wordpress_dir/*) )); then
    echo "Wordpress Already installed on the EFS file system"
else
    installWordpress 
fi
