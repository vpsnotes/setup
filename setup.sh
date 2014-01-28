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

  # install some nice utilities
  apt-get -y install locate nano htop less zip gzip unzip less git-core
}

function help {
  echo -en "\ec"
  echo "-------------------------------------------------------------------------------------------------------"
  echo "bash setup.sh init"
  echo "	Initialize the  System - Update the system, remove unwanted programs and install useful ones"
  echo "-------------------------------------------------------------------------------------------------------"
}

case $1 in
	help)
		help
	;;
	init)
		init
	;;
	*)
		help
	;;
esac
