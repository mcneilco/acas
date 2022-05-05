FROM quay.io/centos/centos:stream8

ARG BUILDTIME=1970-01-01T00:00:00Z
ENV CLIENT_ABOUT_ACAS_BUILDTIME=${BUILDTIME}

ARG VERSION=0.0.0
ENV CLIENT_ABOUT_ACAS_VERSION=${VERSION}

ARG REVISION=UNKNOWN
ENV CLIENT_ABOUT_ACAS_REVISION=${REVISION}

# Update
RUN \
  dnf update -y && \
  dnf upgrade -y && \
# tar for pulling down node
# git required for some npm packages
# postgresql for utility scripts
  dnf install -y tar git && \
  dnf install -y fontconfig urw-fonts iputils postgresql && \
  dnf clean all

#Install python dependencies
RUN   dnf install -y python36 python3-pip
RUN   alternatives --set python /usr/bin/python3
RUN   alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
RUN		pip install argparse requests
RUN   dnf install -y initscripts python3-psycopg2

# node
ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_VERSION 14.x
RUN curl -fsSL https://rpm.nodesource.com/setup_$NODE_VERSION | bash - && \
  dnf install -y nodejs

# ACAS
RUN	    useradd -u 1000 -ms /bin/bash runner
ENV     APP_NAME ACAS
ENV     BUILD_PATH /home/runner/build
ENV     ACAS_BASE /home/runner/acas
ENV     ACAS_CUSTOM /home/runner/acas_custom
ENV     ACAS_SHARED /home/runner/acas_shared
ENV     APACHE Redhat
RUN     npm install -g gulp@4.0.2 forever@3.0.4 coffeescript@2.5.1
COPY    --chown=runner:runner package.json $ACAS_BASE/package.json
USER    runner
WORKDIR $ACAS_BASE

# This installs the modules but not acas, doing this makes subsequent builds much faster so that the container isn't invalidated on a small code change
RUN     npm install --ignore-scripts --loglevel warn
COPY --chown=runner:runner . $ACAS_BASE
RUN     mkdir -p $BUILD_PATH/node_modules && \
        mkdir -p $BUILD_PATH/public && \
        cp -r node_modules $BUILD_PATH && \
        npm install --no-configs && \
        mkdir $BUILD_PATH/privateUploads && \
        mkdir /home/runner/logs && \
        mkdir -p $BUILD_PATH/conf/compiled && \
        rm -rf $ACAS_BASE
WORKDIR $BUILD_PATH
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
ENV     RUN_SYSTEM_TEST=false
ENV     ACAS_HOME=$BUILD_PATH
RUN     gulp execute:prepare_config_files

USER	runner

EXPOSE 3000
CMD     ["/bin/sh","bin/acas.sh", "run"]
