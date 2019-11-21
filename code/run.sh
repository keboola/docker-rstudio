#!/bin/bash
set -e

# Environment variables must be provided
if [ -z ${USER} ] || [ -z ${PASSWORD} ] ; then
	echo "USER and PASSWORD must be provided"
	exit 2
fi

echo "waiting for data-loader"
/tmp-rstudio/wait-for-it.sh -t 0 data-loader:80 -- echo "Data loader is up"

useradd $USER
# add user to the users group (GID 100)
usermod -a -G users $USER
# set home directory
usermod -d /data/ $USER
echo "$USER:$PASSWORD" | chpasswd

echo "user added"
# directory for fake r session data
mkdir -p /data/.rstudio/sdb/per/t/
chmod a+rwx -R /tmp/
chmod a+rwx -R /data/
Rscript /tmp-rstudio/rsession_init.R
echo "rsession initted"
chmod a+rwx -R /data
chown -R $USER /data
chown -R $USER /data/.rstudio
chgrp -R users /data

echo "starting rserver"
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
