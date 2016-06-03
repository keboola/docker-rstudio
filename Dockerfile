FROM quay.io/keboola/docker-base-r-packages:3.2.1-f
# Copied from https://hub.docker.com/r/rocker/rstudio/~/dockerfile/

# Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin/:$PATH

# Install prerequisites
RUN yum -y update \
	&& yum -y install \
    ca-certificates \
    file \
    libapparmor1 \
    libedit2 \
    libcurl4-openssl-dev \
    libssl1.0.0 \
    libssl-dev \
    psmisc \
    python-setuptools \
    supervisor \
    sudo \
    wget \
    initscripts \
	&& yum clean all

# Download and install RStudio server & dependencies
# Attempts to get detect latest version, otherwise falls back to version given in $VER
# Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && wget -q https://download2.rstudio.org/rstudio-server-rhel-${VER}-x86_64.rpm \
  && yum -y install --nogpgcheck rstudio-server-rhel-${VER}-x86_64.rpm \
  && yum clean all \
  && rm rstudio-server-rhel-${VER}-x86_64.rpm \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz \
  && mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates 

# Ensure that if both httr and httpuv are installed downstream, oauth 2.0 flows still work correctly.
RUN echo -e '\n\
 \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
 \n# is not set since a redirect to localhost may not work depending upon \
 \n# where this Docker container is running. \
 \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
 \n  options(httr_oob_default = TRUE) \
 \n}' >> $R_HOME/etc/Rprofile.site

# Create a group for the RStudioServer and grant access to $R_HOME/etc/
RUN groupadd rserver \
  && chgrp rserver -R $R_HOME/etc/

RUN useradd rstudio
RUN usermod -a -G root rstudio
RUN echo "rstudio:rstudio" | chpasswd

RUN echo '"\e[5~": history-search-backward' >> /etc/inputrc \
  && echo '"\e[6~": history-search-backward' >> /etc/inputrc 

# User config and supervisord for persistant RStudio session
COPY userconf.sh /usr/bin/userconf.sh
COPY add-students.sh /usr/local/bin/add-students
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor \
  && chgrp rserver /var/log/supervisor \
  && chmod g+w /var/log/supervisor \
  && chgrp rserver /etc/supervisor/conf.d/supervisord.conf

# RUN mkdir /run/lock \
#   && mkdir /var/lock/subsys \
#   && mkdir /var/lock/subsys/rstudio-server

RUN alternatives --install /usr/bin/R R /usr/local/src/R/R-3.2.1/bin/R 1
RUN alternatives --install /usr/bin/Rscript Rscript /usr/local/src/R/R-3.2.1/bin/Rscript 1

RUN chmod ug+x /usr/bin/userconf.sh

EXPOSE 8787

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]