FROM 	mcneilco/racas:1.6.1.0-release
USER 	root
RUN 	npm install -g grunt grunt-cli forever node-inspector
COPY 	package.json /home/runner/acas/package.json
WORKDIR /home/runner/acas
RUN 	npm install && mkdir build && cp -r node_modules build && mv /home/runner/r_libs build && mkdir build/privateUploads && mkdir build/acas_custom
COPY 	. /home/runner/acas
RUN 	mkdir /home/runner/logs
RUN 	chown -R runner:runner /home/runner
USER    runner
RUN     npm install
WORKDIR /home/runner/acas/build
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
ENV     ACAS_HOME=/home/runner/acas/build
ENV     R_LIBS=/home/runner/acas/build/r_libs
EXPOSE	1080
EXPOSE	3000
EXPOSE	3001
CMD ["/bin/sh","bin/acas-docker.sh", "run"]
