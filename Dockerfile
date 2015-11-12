FROM 	mcneilco/racas:ACASDEV-409-build-tools-restructuring
USER 	root
RUN 	npm install -g grunt grunt-cli forever node-inspector nodemon
COPY 	package.json /home/runner/package.json
WORKDIR /home/runner
RUN 	npm install && cp -r node_modules build && mkdir build/privateUploads
COPY 	. /home/runner
RUN 	mkdir /home/runner/logs
RUN 	chown -R runner:runner /home/runner
USER    runner
RUN     npm install
WORKDIR /home/runner/build
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
ENV     ACAS_HOME=/home/runner/build
ENV     R_LIBS=/home/runner/build/r_libs
CMD ["/bin/sh","bin/acas-docker.sh", "run"]
