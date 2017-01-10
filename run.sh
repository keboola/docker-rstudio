#!/bin/bash
set -e
/tmp/wait-for-it.sh -t 0 data-loader:80 -- echo "Data loader is up"
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
