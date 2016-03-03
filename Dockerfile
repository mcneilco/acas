FROM centos:centos6
# Update
RUN \
  useradd -ms /bin/bash builder && \
  yum update -y && \
  yum upgrade -y && \
  yum install -y git initscripts tar gcc-c++ make krb5-devel && \
  yum clean all

# node
# verify gpg and sha256: http://nodejs.org/dist/v0.10.30/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
# gpg: aka "Julien Gilli <jgilli@fastmail.fm>"
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

ENV NODE_VERSION 0.12.4
ENV NPM_VERSION 2.10.1

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --verify SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm -f "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
	&& npm install -g npm@"$NPM_VERSION" \
	&& npm cache clear

# ACAS
USER    root
RUN	    useradd -u 1000 -ms /bin/bash runner
ENV     APP_NAME ACAS
ENV     BUILD_PATH /home/runner/build
ENV     ACAS_BASE /home/runner/acas
ENV     ACAS_CUSTOM /home/runner/acas_custom
ENV     APACHE Redhat
RUN     npm install -g grunt grunt-cli forever nodemon mocha node-gyp coffee-script
COPY    . $ACAS_BASE
RUN     chown -R runner:runner $ACAS_BASE
USER    runner
WORKDIR $ACAS_BASE
# npm install needs 'LINK=g++ make install' because of the kerbos install of the mongodb-core dependency of winston-mongodb in acas
RUN     export LINK=g++ make install && npm install && cp -r node_modules $BUILD_PATH && mkdir $BUILD_PATH/privateUploads
RUN     mkdir /home/runner/logs
RUN     npm --loglevel info install && mkdir -p $BUILD_PATH/conf/compiled
WORKDIR $BUILD_PATH
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
ENV     ACAS_HOME=$BUILD_PATH

CMD     ["/bin/sh","bin/acas-docker.sh", "run"]
