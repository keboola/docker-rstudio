FROM quay.io/keboola/docker-base-r-packages:3.2.5-e
# Copied from https://hub.docker.com/r/rocker/rstudio/~/dockerfile/

# Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin/:$PATH

# Install prerequisites
RUN yum -y update \
	&& yum -y install \
    ca-certificates \
    file \
    git \
    libapparmor1 \
    libedit2 \
    libcurl4-openssl-dev \
    libssl1.0.0 \
    libssl-dev \
    psmisc \
    python-setuptools \
    sudo \
    wget \
	&& yum clean all

# Download and install RStudio server & dependencies
# Attempts to get detect latest version, otherwise falls back to version given in $VER
# Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && wget -q https://download2.rstudio.org/rstudio-server-rhel-${VER}-x86_64.rpm \
  && yum -y install --nogpgcheck rstudio-server-rhel-${VER}-x86_64.rpm \
  && yum clean all \
  && rm rstudio-server-rhel-${VER}-x86_64.rpm \
  && rm rstudio-server-*-amd64.deb \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz \
  && mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates 

## Ensure that if both httr and httpuv are installed downstream, oauth 2.0 flows still work correctly.
RUN echo '\n\
\n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
\n# is not set since a redirect to localhost may not work depending upon \
\n# where this Docker container is running. \
\nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
\n  options(httr_oob_default = TRUE) \
\n}' >> /etc/R/Rprofile.site

RUN echo "PATH=$PATH" >> /etc/R/Renviron.site

## Use s6
RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

COPY userconf.sh /etc/cont-init.d/conf
COPY run.sh /etc/services.d/rstudio/run

EXPOSE 8787

RUN alternatives --install /usr/bin/R R /usr/local/src/R/R-3.2.5/bin/R 1
RUN alternatives --install /usr/bin/Rscript Rscript /usr/local/src/R/R-3.2.5/bin/Rscript 1

CMD ["/init"]
