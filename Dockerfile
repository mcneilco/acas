FROM centos:centos6
# Update
RUN \
  yum update -y && \
  yum upgrade -y && \
# tar for pulling down node
# git required for some npm packages
  yum install -y tar git && \
  yum install -y fontconfig urw-fonts && \
  yum clean all

# node
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 "$key" || \
    gpg --keyserver pgp.mit.edu "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_VERSION 6.9.3

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --verify SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm -f "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
	&& npm cache clear

# ACAS
RUN	    useradd -u 1000 -ms /bin/bash runner
ENV     APP_NAME ACAS
ENV     BUILD_PATH /home/runner/build
ENV     ACAS_BASE /home/runner/acas
ENV     ACAS_CUSTOM /home/runner/acas_custom
ENV     ACAS_SHARED /home/runner/acas_shared
ENV     APACHE Redhat
RUN     npm install -g gulp@4.0.0 forever nodemon mocha coffeescript
COPY    package.json $ACAS_BASE/package.json
RUN     chown -R runner:runner $ACAS_BASE
USER    runner
WORKDIR $ACAS_BASE
# This installs the modules but not acas, doing this makes subsequent builds much faster so that the container isn't invalidated on a small code change
RUN     npm install --ignore-scripts --loglevel warn
COPY    . $ACAS_BASE
USER    root
RUN     chown -R runner:runner $ACAS_BASE
USER    runner
RUN     mkdir -p $BUILD_PATH/node_modules && \
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

#Install python dependencies
USER	root
RUN		curl -SLO dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && rpm -ivh epel-release-6-8.noarch.rpm && rm epel-release-6-8.noarch.rpm
RUN		yum install -y centos-release-SCL
RUN		yum install -y python-pip python-psycopg2 python27
RUN		source /opt/rh/python27/enable && pip install argparse requests psycopg2-binary
USER	runner

EXPOSE 3000

CMD     ["/bin/sh","bin/acas.sh", "run"]
