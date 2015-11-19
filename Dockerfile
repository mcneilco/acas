FROM    mcneilco/racas:ACASDEV-409-build-tools-restructuring
USER    root
ENV     APP_NAME ACAS
ENV     BUILD_PATH /home/runner/build
ENV     ACAS_BASE /home/runner/acas
ENV     ACAS_CUSTOM /home/runner/acas_custom
RUN     npm install -g grunt grunt-cli forever node-inspector nodemon
COPY    package.json $ACAS_BASE/package.json
WORKDIR $ACAS_BASE
RUN     npm install && cp -r node_modules $BUILD_PATH && mkdir $BUILD_PATH/privateUploads
COPY    . $ACAS_BASE
RUN     mkdir /home/runner/logs
RUN     chown -R runner:runner /home/runner
USER    runner
RUN     npm install && mkdir -p $BUILD_PATH/conf/compiled
WORKDIR $BUILD_PATH
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
ENV     ACAS_HOME=$BUILD_PATH
ENV     R_LIBS=$BUILD_PATH/r_libs
CMD     ["/bin/sh","bin/acas-docker.sh", "run"]
