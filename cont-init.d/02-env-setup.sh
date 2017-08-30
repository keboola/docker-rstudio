#!/usr/bin/with-contenv bash
set -e

## add these to the global environment so they are avialable to the RStudio user 
echo "HTTR_LOCALHOST=$HTTR_LOCALHOST" >> $R_HOME/etc/Renviron.site
echo "HTTR_PORT=$HTTR_PORT" >> $R_HOME/etc/Renviron.site

# directory for fake r session data
mkdir -p /data/.rstudio/sdb/per/t/
Rscript /code/rsession_init.R

chmod a+rwx -R /data/
