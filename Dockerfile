FROM 	mcneilco/racas:1.8.0-release
USER 	root
RUN 	npm install -g grunt grunt-cli forever
COPY 	package.json /home/runner/package.json
WORKDIR /home/runner
RUN 	npm install
COPY 	. /home/runner
RUN 	mkdir log
RUN 	chown -R runner:runner /home/runner
USER    runner
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
EXPOSE	1080
EXPOSE	3000
EXPOSE	3001
CMD ["bin/acas-docker.sh", "run"]
