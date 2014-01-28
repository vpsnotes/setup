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
  mkdir /var/www
}

function help {
  echo -en "\ec"
  echo "-------------------------------------------------------------------------------------------------------"
  echo "bash setup.sh init                                                                                     "
  echo "	Initialize the  System - Update the system, remove unwanted programs and install useful ones   "
  echo "bash setup.sh install nginx                                                                            "
  echo "	Install NGINX webserver                                                                        "
  echo "bash setup.sh add_static_website domain.tld                                                            "
  echo "	Setup a static website given a domain name.                                                    "
  echo "	E.g. bash setup.sh add_static_website abc.com                                                  "
  echo "-------------------------------------------------------------------------------------------------------"
}

function add_static_website {
  domain_name=$1
  mkdir /var/www
  mkdir /var/www/$domain_name
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
	add_static_website)
		add_static_website $2
	;;
	*)
		help
	;;
esac
