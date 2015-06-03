FROM mcneilco/racas:1.6.0-release

USER	root

RUN		npm install -g grunt grunt-cli forever

# COPY SOURCE CODE
COPY	. /home/runner

RUN	chown -R runner:runner /home/runner

USER	runner

WORKDIR /home/runner

RUN npm install && \
    mkdir log

# Expose ports
EXPOSE	1080
EXPOSE	3000
EXPOSE	3001

# Define default command
CMD ["/bin/sh", "bin/acas-docker.sh"]k