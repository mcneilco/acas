#!/bin/sh

# Run Prepare config files as the compiled directory should be empty
if [ $PREPARE_CONFIG_FILES == "true" ]; then
    grunt execute:prepare_config_files
fi

#Once tomcat is availble then try and run prepare module conf json if in demo mode
if [ $PREPARE_MODULE_CONF_JSON == "true" ]; then
    cd src/javascripts/BuildUtilities
    echo 'ping -c 1 tomcat > /dev/null
    if [ $? -eq 0 ];then
        counter=0
        wait=100
        until $(curl --output /dev/null --silent --head --fail http://tomcat:8080) || [ $counter == $wait ]; do
            printf "."
            sleep 1
            counter=$((counter+1))
        done
        if [ $counter == $wait ]; then
            echo "waited $wait seconds for acas to start, giving up on prepare module conf json"
        else
            node PrepareModuleConfJSON.js
        fi
    else
        echo "tomcat not available, not waiting for roo to start and not running prepare module conf json"
    fi' | sh 2>&1 &
    cd ../../..
fi

sh bin/acas.sh "$@"
if [ $1 == "start" ]; then
    tail -F /home/runner/log/*.log
fi
