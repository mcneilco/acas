FROM centos:centos8
# Update
RUN \
  dnf update -y && \
  dnf upgrade -y && \
# tar for pulling down node
# git required for some npm packages
  dnf install -y tar git && \
  dnf install -y fontconfig urw-fonts && \
  dnf clean all

# node

ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_VERSION 14.15.1

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm -f "node-v$NODE_VERSION-linux-x64.tar.gz"

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
ENV     RUN_SYSTEM_TEST=true
ENV     ACAS_HOME=$BUILD_PATH
RUN     gulp execute:prepare_config_files

#Install python dependencies
USER	root
RUN   dnf install -y python36 python3-pip
RUN   alternatives --set python /usr/bin/python3
RUN   alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
RUN		pip install argparse requests psycopg2-binary
RUN   dnf install -y initscripts

USER	runner

EXPOSE 3000
CMD     ["/bin/sh","bin/acas.sh", "run"]
