#!/bin/sh
# Check if mounted environments exists, if not then use default environments to export variables before prepare config files runs
if [ -d "/mnt/environments" ];then
    envPath="/mnt/environments"
else
    export APP_NAME=${APP_NAME:=acas}
    envPath="bin/environments"
fi
for f in $envPath/*/*.env; do echo Using $f;source $f;export $(cut -d= -f1 $f); done

# Run Prepare config files as the compiled directory should be empty
if [ $PREPARE_CONFIG_FILES == "true" ]; then
    cd conf
    node PrepareConfigFiles.js docker
    cd ..
fi

#Once tomcat is availble then try and run prepare module conf json if in demo mode
if [ $PREPARE_MODULE_CONF_JSON == "true" ]; then
    cd conf
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
    cd ..
fi

sh bin/acas.sh "$@"
if [ $1 == "start" ]; then
    tail -F /home/runner/log/*.log
fi
