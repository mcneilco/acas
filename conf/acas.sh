#!/bin/sh
# chkconfig: 2345 64 02
# description: start and stop the acas app.js, server.js and apache instance
# processname: node

ACAS_HOME=$(cd "$(dirname "$0")"/..; pwd)

#Get ACAS config variables
source /dev/stdin <<< "$(cat $ACAS_HOME/conf/compiled/conf.properties | awk -f $ACAS_HOME/conf/readproperties.awk)"

#Export these variables so that the apache config can pick them up
export ACAS_USER=${server_run_user}
export ACAS_GROUP=$(id -g -n $ACAS_USER)
export ACAS_HOME=$ACAS_HOME
export client_service_rapache_port=$client_service_rapache_port
export client_host=$client_host
export client_port=$client_port
export server_log_path=$server_log_path
export server_log_level=$(echo $server_log_level | awk '{print tolower($0)}')

unamestr=$(uname)
apacheConfFile=apache.conf
if [ "$unamestr" == 'Darwin' ]; then
	suAdd="-i"
	apacheConfFile=apache-darwin.conf
fi
case $1 in
start)
        for dir in `find $ACAS_HOME/.. -maxdepth 1 -type l`
        do
		if [ -e $dir/app.js ]; then
			app=app.js
		fi
		if [ -e $dir/server.js ]; then
			app=server.js
		fi

		dirname=`basename $dir`
		logname=$server_log_path/${dirname}.log
		logout=$server_log_path/${dirname}_stdout.log
		logerr=$server_log_path/${dirname}_stderr.log

        	echo "starting $dirname/$app"

        	su - $ACAS_USER $suAdd -c "(cd $dir && forever start --append -l $logname -o $logout -e $logerr $app)"

        	echo "$dirname/$app started"
        done
        
		echo "starting apache instance $ACAS_HOME/conf/$apacheConfFile"
		/usr/sbin/httpd -f $ACAS_HOME/conf/$apacheConfFile -k start
		echo "apache instance $ACAS_HOME/conf/$apacheConfFile started"
	;;
stop)
        for dir in `find $ACAS_HOME/.. -maxdepth 1 -type l`
        do
		if [ -e $dir/app.js ]; then
			app=app.js
		fi
		if [ -e $dir/server.js ]; then
			app=server.js
		fi

		dirname=`basename $dir`

        	echo "stopping $dirname/$app"

        	#su - svc_node -c "(cd $dir && forever stop $app)"
        	su - $ACAS_USER -c "killall node"

        	echo "$dirname/$app stopped"
        done
        
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