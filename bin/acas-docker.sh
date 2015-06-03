#!/bin/sh
cd conf
#cp config-docker.properties config.properties
node PrepareConfigFiles.js docker
node PrepareModuleConfJSON.js
cd ..
sh bin/acas.sh start
tail -f /home/runner/log/*.log
