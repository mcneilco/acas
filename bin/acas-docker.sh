#!/bin/sh
for f in /mnt/environments/*/*.env; do source $f;export $(cut -d= -f1 $f); done
cd conf
node PrepareConfigFiles.js docker
until $(curl --output /dev/null --silent --head --fail "http://tomcat:8080"); do
    printf '.'
    sleep 1
done
node PrepareModuleConfJSON.js
cd ..
sh bin/acas.sh start
tail -f /home/runner/log/*.log