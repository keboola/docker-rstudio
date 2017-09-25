#!/bin/bash
set -e

# Environment variables must be provided
if [ -z ${USER} ] || [ -z ${PASSWORD} ] ; then
	echo "USER and PASSWORD must be provided"
	exit 2
fi

useradd $USER
usermod -a -G root $USER
# set home directory
usermod -d /data/ $USER
echo "$USER:$PASSWORD" | chpasswd

# directory for fake r session data
mkdir -p /data/.rstudio/sdb/per/t/
chmod a+rwx -R /data/
Rscript /code/rsession_init.R
chmod a+rw /data/main.R
chown -R $USER /data/.rstudio
chown $USER /data/main.R

/code/wait-for-it.sh -t 0 data-loader:80 -- echo "Data loader is up"

exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
