#!/bin/sh
# chkconfig: 2345 64 02
# description: start and stop the acas app.js, server.js and apache instance
# processname: node

scriptPath=$(readlink ${BASH_SOURCE[0]})
ACAS_HOME=$(cd "$(dirname "$scriptPath")"/..; pwd)

#Get ACAS config variables
source /dev/stdin <<< "$(cat $ACAS_HOME/conf/compiled/conf.properties | awk -f $ACAS_HOME/conf/readproperties.awk)"

#Export these variables so that the apache config can pick them up
export ACAS_USER=${server_run_user}
if [ "$ACAS_USER" == "" ] || [ "$ACAS_USER" == "null" ]; then
    echo "Setting ACAS_USER to $(whoami)"
    export ACAS_USER=$(whoami)
fi
suAdd="-i"

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
		logname=$server_log_path/${dirname}${server_log_suffix}.log
		logout=$server_log_path/${dirname}${server_log_suffix}_stdout.log
		logerr=$server_log_path/${dirname}${server_log_suffix}_stderr.log

        echo "starting $dirname/$app"
		startCommand="cd $dir && forever start --append -l $logname -o $logout -e $logerr $app"
		if [ $(whoami) == $ACAS_USER ]; then
			eval $startCommand
		else
			command="su - $ACAS_USER $suAdd -c \"($startCommand)\""
			eval $command
		fi

        echo "$dirname/$app started"
        done
        
		echo "starting apache instance $ACAS_HOME/conf/compiled/apache.conf"
		/usr/sbin/httpd -f $ACAS_HOME/conf/compiled/apache.conf -k start
		echo "apache instance $ACAS_HOME/conf/compiled/apache.conf started"
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

        stopCommand="cd $dir && forever stop $app"
		if [ $(whoami) == $ACAS_USER ]; then
			eval $stopCommand
		else
			command="su - $ACAS_USER $suAdd -c \"($stopCommand)\""
			eval $command
		fi

        echo "$dirname/$app stopped"
        done
        
		echo "stoppping apache instance $ACAS_HOME/conf/compiled/apache.conf"
		/usr/sbin/httpd -f $ACAS_HOME/conf/compiled/apache.conf -k stop
		echo "apache instance $ACAS_HOME/conf/compiled/apache.conf stopped"
	;;
reload)
		echo "reloading apache config $ACAS_HOME/conf/compiled/apache.conf"
		/usr/sbin/httpd -f $ACAS_HOME/conf/compiled/apache.conf -k graceful
		echo "apache config $ACAS_HOME/conf/compiled/apache.conf reloaded"
	;;
esac
