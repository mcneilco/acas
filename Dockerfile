FROM mcneilco/racas:docker

USER	root

RUN	npm install -g grunt grunt-cli forever

COPY	. /home/runner
USER	root
RUN	chown -R runner:runner /home/runner
USER	runner

RUN cd ~ && \
	npm install && \
    mkdir log

#Expose ports
EXPOSE	1080
EXPOSE	3000
EXPOSE	3001

# Define default command.
CMD cd ~ && grunt execute:prepare_config_files && cd conf && node PrepareModuleConfJSON.js && sh /home/runner/bin/acas.sh start && tail -f /home/runner/log/*.log
