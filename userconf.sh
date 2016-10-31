#!/usr/bin/with-contenv bash

# Environment variables must be provided
if [ -z ${USER+x} ] || [ -z ${PASSWORD+x} ] ; then
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

## add these to the global environment so they are avialable to the RStudio user 
echo "HTTR_LOCALHOST=$HTTR_LOCALHOST" >> $R_HOME/etc/Renviron.site
echo "HTTR_PORT=$HTTR_PORT" >> $R_HOME/etc/Renviron.site

# fake data folder
mkdir -p /data/out/tables/
mkdir -p /data/out/files/
mkdir -p /data/in/tables/
mkdir -p /data/in/files/

# directory for fake r session data
mkdir -p /data/.rstudio/sdb/per/t/
Rscript /tmp/rsession_init.R
cp /tmp/pcs /data/.rstudio/pcs/

chmod a+rwx -R /data/
