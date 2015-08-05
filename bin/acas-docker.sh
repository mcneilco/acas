#!/bin/sh
cd conf
#cp config-docker.properties config.properties
node PrepareConfigFiles.js docker
until $(curl --output /dev/null --silent --head --fail "http://$ROO_PORT_8080_TCP_ADDR:$ROO_PORT_8080_TCP_PORT"); do
    printf '.'
    sleep 1
done
node PrepareModuleConfJSON.js
cd ..
sh bin/acas.sh start
tail -f /home/runner/log/*.log