#!/bin/bash
set -e

echo "Running"
/etc/cont-init.d/01-user-conf.sh
echo "Running 2"
/etc/cont-init.d/02-env-setup.sh
echo "Running 3"
/etc/cont-init.d/03-data-loader-wait.sh
echo "Running 4"
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
