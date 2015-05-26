FROM mcneilco/racas:1.6.0-release

USER	root

RUN		npm install -g grunt grunt-cli forever

# COPY SOURCE CODE
COPY	. /home/runner

RUN	chown -R runner:runner /home/runner

USER	runner

WORKDIR /home/runner

RUN npm install && \
    mkdir log && \
    mv conf/config-docker.properties conf/config.properties

# Expose ports
EXPOSE	1080
EXPOSE	3000
EXPOSE	3001

# Define default command
CMD grunt execute:prepare_config_files && cd conf && node PrepareModuleConfJSON.js && sh /home/runner/bin/acas.sh start && tail -f /home/runner/log/*.log

