#!/bin/bash

#############################
# A Simple Setup Script
# For Ubuntu Linux
#############################


function init {
  # update/upgrade
  apt-get -y update
  apt-get -q -y upgrade

  # remove programs we dont need
  apt-get -q -y remove --purge portmap apache2* bind9 samba* nscd sendmail* whoopsie*
  apt-get -q -y autoremove

  # install some nice utilities
  apt-get -y install locate nano htop less zip gzip unzip less git-core
}

function install_nginx {
  apt-get -y install nginx
  sed -i "/worker_processes/cworker_processes `nproc`;"  /etc/nginx/nginx.conf
  rm /etc/nginx/sites-available/default
}

function install_php {
  apt-get install -q -y --force-yes php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd php5-cgi php5-curl
  sed -i "/listen *=/clisten = 127.0.0.1:9000"  /etc/php5/fpm/pool.d/www.conf
}

function install_mysql {
  apt-get -y install mysql-server mysql-client
}

function add_static_website {
  domain_name=$1
  mkdir -p /var/www/$domain_name
  echo "<html><title>My Website</title><body><h1>My Website $domain_name </h1>Welcome it works</body></html>" > /var/www/$domain_name/index.html
  cat > /etc/nginx/sites-enabled/$domain_name.conf <<END
server {
    listen 80;
    server_name $domain_name www.$domain_name;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    root /var/www/$domain_name;
}
END
}

function add_php_website {
  domain_name=$1
  mkdir -p /var/www/$domain_name
  echo "<?php phpinfo(); ?>" > /var/www/$domain_name/index.php
  cat > /etc/nginx/sites-enabled/$domain_name.conf <<END
server {
    listen 80;
    server_name $domain_name www.$domain_name;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    root /var/www/$domain_name;

    index index.php index.htm index.html;
    location ~ \.php\$ {
	try_files \$uri =404;
	fastcgi_split_path_info ^(.+\.php)(/.+)\$;
	include fastcgi_params;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	fastcgi_pass 127.0.0.1:9000;
    }
}
END
}

function add_wp_website {
  domain_name=$1
  db_name=$2

  # get wp template config
  cd /etc/nginx
  wget -nc https://raw.github.com/vpsnotes/setup/master/nginx/wordpress.conf

  #db 
  echo "create schema $db_name;" | mysql -u root -ppassword

  # prepare web files
  mkdir -p /var/www
  cd /var/www
  wget http://wordpress.org/latest.zip
  unzip latest.zip
  rm latest.zip
  mv wordpress $domain_name

  #ownership
  cd /var/www
  chown -R www-data: $domain_name

  # nginx conf
  cat > /etc/nginx/sites-enabled/$domain_name.conf <<END
server {
    listen 80;
    server_name $domain_name www.$domain_name;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    root /var/www/$domain_name;

    index index.php index.htm index.html;
    include wordpress.conf;
}
END

}

function help {
  echo -en "\ec"
  echo "-------------------------------------------------------------------------------------------------------"
  echo "bash setup.sh init                                                                                     "
  echo "	Initialize the  System - Update the system, remove unwanted programs and install useful ones   "
  echo "bash setup.sh install_nginx                                                                            "
  echo "	Install NGINX webserver                                                                        "
  echo "bash setup.sh install_php                                                                              "
  echo "	Install PHP Support                                                                            "
  echo "bash setup.sh install_mysql                                                                            "
  echo "	Install MySQL Database                                                                         "
  echo "bash setup.sh add_static_website domain.tld                                                            "
  echo "	Setup a static website given a domain name.                                                    "
  echo "	E.g. bash setup.sh add_static_website abc.com                                                  "
  echo "bash setup.sh add_php_website domain.tld                                                               "
  echo "	Setup a PHP website given a domain name.                                                       "
  echo "	E.g. bash setup.sh add_php_website abc.com                                                     "
  echo "-------------------------------------------------------------------------------------------------------"
}


case $1 in
	help)
		help
	;;
	init)
		init
	;;
	install_nginx)
		install_nginx
	;;
	install_php)
		install_php
	;;
	install_mysql)
		install_mysql
	;;
	add_static_website)
		add_static_website $2
	;;
	add_php_website)
		add_php_website $2
	;;
	add_wp_website)
		add_wp_website $2 $3
	;;
	*)
		help
	;;
esac
