FROM 	mcneilco/racas:ACASDEV-424-reintegration
USER 	root
RUN 	npm install -g grunt grunt-cli forever
COPY 	package.json /home/runner/package.json
WORKDIR /home/runner
RUN 	npm install
COPY 	. /home/runner
RUN 	mkdir log
RUN 	chown -R runner:runner /home/runner
USER    runner
EXPOSE	1080
EXPOSE	3000
EXPOSE	3001
CMD 	["/bin/sh", "bin/acas-docker.sh"]

