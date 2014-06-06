#!/bin/sh
# chkconfig: 2345 64 02
# description: start and stop the acas app.js, server.js and apache instance
# processname: node

scriptPath=$(readlink ${BASH_SOURCE[0]})
ACAS_HOME=$(cd "$(dirname $0)"/..; /bin/pwd)

#Get ACAS config variables
source /dev/stdin <<< "$(cat $ACAS_HOME/conf/compiled/conf.properties | awk -f $ACAS_HOME/conf/readproperties.awk)"

#Export these variables so that the apache config can pick them up
export ACAS_USER=${server_run_user}
if [ "$ACAS_USER" == "" ] || [ "$ACAS_USER" == "null" ]; then
    echo "Setting ACAS_USER to $(whoami)"
    export ACAS_USER=$(whoami)
fi

export ACAS_GROUP=$(id -g -n $ACAS_USER)
export ACAS_HOME=$ACAS_HOME
export client_service_rapache_port=$client_service_rapache_port
export client_service_rapache_path=$client_service_rapache_path
export client_host=$client_host
export client_port=$client_port
export server_log_path=$server_log_path
export server_log_suffix=$server_log_suffix
export server_log_level=$(echo $server_log_level | awk '{print tolower($0)}')

unamestr=$(uname)
apacheConfFile=apache.conf
if [ "$unamestr" == 'Darwin' ]; then
	suAdd="-i"
	apacheConfFile=apache-darwin.conf
fi
if [ ! -d "$server_log_path" ]; then
    if [ $(whoami) == $ACAS_USER ]; then
        mkdir $server_log_path
    else
        eval "su - $ACAS_USER mkdir $server_log_path"
    fi
fi

case $1 in
start)
		logname=$server_log_path/acas${server_log_suffix}.log
		logout=$server_log_path/acas${server_log_suffix}_stdout.log
		logerr=$server_log_path/acas${server_log_suffix}_stderr.log

        echo "starting acas/app.js"
		startCommand="cd $ACAS_HOME && forever start --append -l $logname -o $logout -e $logerr app.js"
		if [ $(whoami) == $ACAS_USER ]; then
			eval $startCommand
		else
			command="su - $ACAS_USER $suAdd -c \"($startCommand)\""
			eval $command
		fi

        echo "acas/app.js started"

		echo "starting apache instance $ACAS_HOME/conf/$apacheConfFile"
		/usr/sbin/httpd -f $ACAS_HOME/conf/$apacheConfFile -k start
		echo "apache instance $ACAS_HOME/conf/$apacheConfFile started"
	;;
stop)
        echo "stopping acas/app.js"

        stopCommand="cd $ACAS_HOME && forever stop app.js"
		if [ $(whoami) == $ACAS_USER ]; then
			eval $stopCommand
		else
			command="su - $ACAS_USER $suAdd -c \"($stopCommand)\""
			eval $command
		fi

        echo "acas/app.js stopped"

		echo "stoppping apache instance $ACAS_HOME/conf/$apacheConfFile"
		/usr/sbin/httpd -f $ACAS_HOME/conf/$apacheConfFile -k stop
		echo "apache instance $ACAS_HOME/conf/$apacheConfFile stopped"
	;;
reload)
		echo "reloading apache config $ACAS_HOME/conf/$apacheConfFile"
		/usr/sbin/httpd -f $ACAS_HOME/conf/$apacheConfFile -k graceful
		echo "apache config $ACAS_HOME/conf/$apacheConfFile reloaded"
	;;
esac
