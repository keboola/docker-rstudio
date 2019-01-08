FROM quay.io/keboola/docker-custom-r:1.8.1
# Copied from https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.3.2/Dockerfile

ARG RSTUDIO_VERSION
ARG PANDOC_TEMPLATES_VERSION
ENV PANDOC_TEMPLATES_VERSION ${PANDOC_TEMPLATES_VERSION:-1.18}
ARG GITHUB_PAT

WORKDIR /tmp-rstudio/

## Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin:$PATH

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \ 
    psmisc \
    python-setuptools \
    sudo \
    wget \
  && wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
  && dpkg -i libssl1.0.0.deb \	
  && rm libssl1.0.0.deb \    
  && RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  && wget -q http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && dpkg -i rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb \
  ## Symlink pandoc & standard pandoc templates for use system-wide
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && git clone https://github.com/jgm/pandoc-templates \
  && mkdir -p /opt/pandoc/templates \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  ## RStudio wants an /etc/R, will populate from $R_HOME/etc
  && mkdir -p /etc/R \
  ## Write config files in $R_HOME/etc
  && echo '\n\
    \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
    \n# is not set since a redirect to localhost may not work depending upon \
    \n# where this Docker container is running. \
    \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
    \n  options(httr_oob_default = TRUE) \
    \n}' >> /usr/local/lib/R/etc/Rprofile.site \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  ## Need to configure non-root user for RStudio
  && useradd rstudio \
  && echo "rstudio:rstudio" | chpasswd \
  && mkdir /home/rstudio \
  && chown rstudio:rstudio /home/rstudio \
  && addgroup rstudio staff \
  ## Prevent rstudio from deciding to use /usr/bin/R if a user apt-get installs a package
  &&  echo 'rsession-which-r=/usr/local/bin/R' >> /etc/rstudio/rserver.conf \ 
  ## use more robust file locking to avoid errors when using shared volumes:
  && echo 'lock-type=advisory' >> /etc/rstudio/file-locks \
  ## configure git not to request password each time 
  && git config --system credential.helper 'cache --timeout=3600' \
  && git config --system push.default simple \
  ## Create a group for the RStudioServer and grant access to $R_HOME/etc/
  && groupadd rserver \
  && chgrp rserver -R $R_HOME/etc/

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Set proper paths and install r-transformation library (generate the install file on fly to avoid dependence on COPY)
RUN update-alternatives --install /usr/bin/R R $R_HOME/bin/R 1 \
  && update-alternatives --install /usr/bin/Rscript Rscript $R_HOME/bin/Rscript 1 \
  && printf "devtools::install_github('keboola/r-transformation', ref = '1.2.8')\n" >> /tmp-rstudio/init.R \
  && printf "install.packages('readr')\n" >> /tmp-rstudio/init.R \
  && R CMD javareconf \ 
  && printf "GITHUB_PAT=$GITHUB_PAT\n" > .Renviron \
  && /usr/local/lib/R/bin/Rscript /tmp-rstudio/init.R \
  && rm /tmp-rstudio/init.R \
  && chmod -R a+wx /usr/local/lib/R/site-library \
  && rm -f .Renviron

COPY rstudio/ /etc/rstudio
COPY code/ /tmp-rstudio/

EXPOSE 8787

ENTRYPOINT ["/tini", "--"]
CMD ["/tmp-rstudio/run.sh"]
