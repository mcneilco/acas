#!/bin/sh
# chkconfig: 2345 64 02
# description: start and stop the acas app.js, server.js and apache instance
# processname: node

scriptPath=$(readlink -f ${BASH_SOURCE[0]})
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
        dirname=`basename $ACAS_HOME`
        logname=$server_log_path/${dirname}${server_log_suffix}.log
        logout=$server_log_path/${dirname}${server_log_suffix}_stdout.log
        logerr=$server_log_path/${dirname}${server_log_suffix}_stderr.log

        echo "starting $ACAS_HOME/app.js"
        startCommand="export FOREVER_ROOT=$ACAS_HOME/bin && forever start --killSignal=SIGTERM --workingDir --append -l $logname -o $logout -e $logerr $ACAS_HOME/app.js 2>&1 >/dev/null"
        if [ $(whoami) == $ACAS_USER ]; then
          eval $startCommand
        else
          command="su - $ACAS_USER $suAdd -c \"($startCommand)\""
          eval $command
        fi
        echo "$ACAS_HOME/app.js started"

        echo "starting apache instance $ACAS_HOME/conf/compiled/apache.conf"
        /usr/sbin/httpd -f $ACAS_HOME/conf/compiled/apache.conf -k start
        echo "apache instance $ACAS_HOME/conf/compiled/apache.conf started"
    ;;
    stop)
        dirname=`basename $ACAS_HOME`

        echo "stopping $ACAS_HOME/app.js"

        stopCommand="export FOREVER_ROOT=$ACAS_HOME/bin && forever stop $ACAS_HOME/app.js 2>&1 >/dev/null"
        if [ $(whoami) == $ACAS_USER ]; then
          eval $stopCommand
        else
          command="su - $ACAS_USER $suAdd -c \"($stopCommand)\""
          eval $command
        fi
        echo "$ACAS_HOME/app.js stopped"

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
