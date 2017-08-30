#!/usr/bin/with-contenv bash
set -e

# Environment variables must be provided
if [ -z ${USER} ] || [ -z ${PASSWORD} ] ; then
	echo "USER and PASSWORD must be provided"
	exit 2
fi

# Create a group for the RStudioServer and grant access to $R_HOME/etc/
groupadd rserver
chgrp rserver -R $R_HOME/etc/
  		  
useradd $USER
usermod -a -G root $USER
# set home directory
usermod -d /data/ $USER
echo "$USER:$PASSWORD" | chpasswd
