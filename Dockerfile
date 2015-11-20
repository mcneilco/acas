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

# #RSTUDIO INSTALL
# USER root
# RUN echo "runner" | passwd --stdin runner && \
#      wget https://download2.rstudio.org/rstudio-server-rhel-0.99.489-x86_64.rpm --no-verbose && \
#      yum install -y --nogpgcheck rstudio-server-rhel-0.99.489-x86_64.rpm && \
#      yum install -y git
# USER runner
# RUN printf "R_LIBS_USER=$BUILD_PATH/r_libs\nR_DEFAULT_PACKAGES=\"utils,racas\"" > /home/runner/.Renviron

CMD     ["/bin/sh","bin/acas-docker.sh", "run"]
