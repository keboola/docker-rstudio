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

# fix permission issue with shared volumes
usermod -a -G root rstudio-server

## add these to the global environment so they are avialable to the RStudio user 
echo "HTTR_LOCALHOST=$HTTR_LOCALHOST" >> $R_HOME/etc/Renviron.site
echo "HTTR_PORT=$HTTR_PORT" >> $R_HOME/etc/Renviron.site

# directory for fake r session data
mkdir -p /data/.rstudio/sdb/per/t/
Rscript /tmp/rsession_init.R
