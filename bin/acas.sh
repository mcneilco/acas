#!/bin/bash
### BEGIN INIT INFO
# Provides:		acas
# Required-Start:	$local_fs
# Required-Stop:	$local_fs
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description: start and stop the acas app.js, server.js and apache instance
# Description: start and stop the acas app.js, server.js and apache instance
### END INIT INFO
# chkconfig: 2345 64 02
# description: start and stop the acas app.js, server.js and apache instance
# processname: acas

################################################################################
################################################################################
##                                                                            ##
#                       PATHs section                                          #
##                                                                            ##
################################################################################
################################################################################

ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

if [ -f /etc/redhat-release ]; then
    OS=`cat /etc/redhat-release | awk {'print $1}'`
    VER=`cut -d ' ' -f 3 /etc/redhat-release`
    . /etc/init.d/functions
    apacheCMD='/usr/sbin/httpd'
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
    . /lib/lsb/init-functions
    action() {
      local STRING rc

      STRING=$1
      echo -n "$STRING "
      shift
      "$@" && success $"$STRING" || failure $"$STRING"
      rc=$?
      echo
      return $rc
    }
    success() {
      [ "$BOOTUP" != "verbose" -a -z "$LSB" ] && echo_success
      return 0
    }
    failure() {
      rc=$?
      [ "$BOOTUP" != "verbose" -a -z "$LSB" ] && echo_failure
      return $rc
    }
    echo_success() {
      [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
      echo -n "[  "
      [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
      echo -n $"OK"
      [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
      echo -n "  ]"
      echo -ne "\r"
      return 0
    }

    echo_failure() {
      [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
      echo -n "["
      [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
      echo -n $"FAILED"
      [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
      echo -n "]"
      echo -ne "\r"
      return 1
    }
    apacheCMD='/usr/sbin/apache2'
elif [ -f /etc/debian_version ]; then
    OS=Debian  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
    . /lib/lsb/init-functions
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

export PATH=/usr/local/bin:${PATH:=}
export MANPATH=/usr/local/man:${MANPATH:=}
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH:=}

# Get default locale
# Ubuntu
[ -f /etc/default/locale ] && . /etc/default/locale

# Centos
[ -f /etc/sysconfig/i18n ] && . /etc/sysconfig/i18n
export LANG

################################################################################
################################################################################
##                                                                            ##
#                       FOREVER section                                        #
##                                                                            ##
################################################################################
################################################################################


running() {
    runningCommand="export FOREVER_ROOT=$ACAS_HOME/bin && forever list 2>/dev/null | grep $ACAS_HOME/app.js 2>&1 >/dev/null"
    if [ $(whoami) != "$ACAS_USER" ]; then
        runningCommand="su -p - $ACAS_USER $suAdd -c \"($runningCommand)\""
    fi
    eval $runningCommand
    return $?
}

start_server() {
    startCommand="export FOREVER_ROOT=$ACAS_HOME/bin && forever start --killSignal=SIGTERM --workingDir --append -l $logname -o $logout -e $logerr $ACAS_HOME/app.js 2>&1 >/dev/null"
    if [ $(whoami) != "$ACAS_USER" ]; then
        startCommand="su -p - $ACAS_USER $suAdd -c \"(cd `dirname $ACAS_HOME/app.js` && $startCommand)\""
    fi
    eval $startCommand
    return $?
}

run_server() {
    if [ -z "$@" ]; then
      runCommand="npm run start"
    else
      runCommand="npm run $@"
    fi
    echo "runCommand: $runCommand"
    if [ $(whoami) != "$ACAS_USER" ]; then
        startCommand="su -p - $ACAS_USER $suAdd -c \"(cd `dirname $ACAS_HOME/app.js` && $startCommand)\""
    fi
    eval "($runCommand)" &
    return $?
}

stop_server() {
    stopCommand="export FOREVER_ROOT=$ACAS_HOME/bin && forever stop $ACAS_HOME/app.js 2>&1 >/dev/null"
    if [ $(whoami) != "$ACAS_USER" ]; then
        stopCommand="su -p - $ACAS_USER $suAdd -c \"($stopCommand)\""
    fi
    eval $stopCommand

    return $?
}

apache_running() {
    pidofproc -p $ACAS_HOME/bin/apache.pid "DAEMON" 2>&1 >/dev/null
    return $?
    #[ `pgrep $pid` ] && echo 'running' || echo 'running'
}

start_apache() {
    remove_apache_pid
    startCommand=" $apacheCMD -f $ACAS_HOME/conf/compiled/apache.conf -k start 2>&1 >/dev/null"
    if [ $(whoami) != "$RAPACHE_START_ACAS_USER" ]; then
        startCommand="su -p - $RAPACHE_START_ACAS_USER $suAdd -c \"($startCommand)\""
    fi
    eval $startCommand
    return $?
}

run_apache() {
    cp $ACAS_HOME/conf/compiled/apache.conf /tmp/apache.conf
    startCommand=" $apacheCMD -f /tmp/apache.conf -k start -DFOREGROUND"
    if [ $(whoami) != "$RAPACHE_START_ACAS_USER" ]; then
        startCommand="su -p - $RAPACHE_START_ACAS_USER $suAdd -c \"($startCommand)\""
    fi
    eval "($startCommand) $1"
    return $?
}

stop_apache() {
    stopCommand="$apacheCMD -f $ACAS_HOME/conf/compiled/apache.conf -k stop 2>&1 >/dev/null"
    if [ $(whoami) != "$RAPACHE_START_ACAS_USER" ]; then
        stopCommand="su -p - $RAPACHE_START_ACAS_USER $suAdd -c \"($stopCommand)\""
    fi
    eval $stopCommand
    return $?
}

apache_reload() {
    reloadCommand="$apacheCMD -f $ACAS_HOME/conf/compiled/apache.conf -k graceful 2>&1 >/dev/null"
    if [ $(whoami) != "$RAPACHE_START_ACAS_USER" ]; then
        reloadCommand="su -p - $RAPACHE_START_ACAS_USER $suAdd -c \"($reloadCommand)\""
    fi
    eval $reloadCommand
    return $?
}

################################################################################
################################################################################
##                                                                            ##
#                       GENERIC section                                        #
##                                                                            ##
################################################################################
################################################################################

DIETIME=1              # Time to wait for the server to die, in seconds
# If this value is set too low you might not
# let some servers to die gracefully and
# 'restart' will not work

STARTTIME=0.1             # Time to wait for the server to start, in seconds
# If this value is set each time the server is
# started (on start or restart) the script will
# stall to try to determine if it is running
# If it is not set and the server takes time
# to setup a pid file the log message might
# be a false positive (says it did not start
# when it actually did)

# Console logging.
log() {
    local STRING mode

    STRING=$1
    arg2=$2
    mode="${arg2:=success}"

    echo -n "$STRING "
    if [ "${RHGB_STARTED:-}" != "" -a -w /etc/rhgb/temp/rhgb-console ]; then
        echo -n "$STRING " > /etc/rhgb/temp/rhgb-console
    fi
    if [ "$mode" = "success" ]; then
        success $"$STRING"
    else
        failure $"$STRING"
    fi
    echo
    if [ "${RHGB_STARTED:-}" != "" -a -w /etc/rhgb/temp/rhgb-console ]; then
        if [ "$mode" = "success" ]; then
            echo_success > /etc/rhgb/temp/rhgb-console
        else
            echo_failure > /etc/rhgb/temp/rhgb-console
            [ -x /usr/bin/rhgb-client ] && /usr/bin/rhgb-client --details=yes
        fi
        echo > /etc/rhgb/temp/rhgb-console
    fi
}

# Starts the server.
do_start() {
    dirname=`basename $ACAS_HOME`
    LOCKFILE=$ACAS_HOME/bin/app.js.LOCKFILE
    logname=$server_log_path/acas_app${server_log_suffix}.log
    logout=$server_log_path/acas_app${server_log_suffix}_stdout.log
    logerr=$server_log_path/acas_app${server_log_suffix}_stderr.log
    # Check if it's running first
    if running ;  then
        log "app.js already running"
    else
        action "Starting app.js" start_server
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            # NOTE: Some servers might die some time after they start,
            # this code will detect this issue if STARTTIME is set
            # to a reasonable value
            [ -n "$STARTTIME" ] && sleep $STARTTIME # Wait some time
            if  running ;  then
                # It's ok, the server started and is running
                log "app.js started"
                touch $LOCKFILE
                RETVAL=0
            else
                # It is not running after we did start
                log "app.js died on startup" "failure"
                RETVAL=1
            fi
        fi

    fi
    if [ $doApache = true ]; then
        if apache_running ;  then
            log "apache already running"
        else
            action "Starting apache" start_apache
            RETVAL=$?
            if [ $RETVAL -eq 0 ]; then
                log "apache started"
            else
                log "apache startup failure" "failure"
                RETVAL=1
            fi
        fi
    fi
    return $RETVAL
}

remove_apache_pid() {
  if [ -f "$ACAS_HOME/bin/apache.pid" ]; then
      rm "$ACAS_HOME/bin/apache.pid"
  fi
}
# Runs the server.
do_run() {
    if [ $name == "rservices" ] || [ $name == "all" ]; then
        remove_apache_pid
        counter=0
        wait=5
        until [ -f $ACAS_HOME/conf/compiled/apache.conf  ] || [ $counter == $wait ]; do
            printf "."
            sleep 1
            counter=$((counter+1))
        done
        if [ $name == "all" ]; then
            action "Running apache in background" run_apache &
        else
            action "Running apache" run_apache &
        fi
    fi

    if [ $name == "acas" ] || [ $name == "all" ]; then
        dirname=`basename $ACAS_HOME`
        LOCKFILE=$ACAS_HOME/bin/app.js.LOCKFILE
        action "Running app.js" run_server "${@:2}"
        acaspid=$?
    fi
    trap 'kill -TERM jobs -p' TERM
    wait
    return $RETVAL
}

# Stops the server.
do_stop() {
    dirname=`basename $ACAS_HOME`
    LOCKFILE=$ACAS_HOME/bin/app.js.LOCKFILE
    if running ; then
        # Only stop the server if we see it running
        action "Stopping app.js" stop_server
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
    else
        # If it's not running don't do anything
        log "app.js not running"
        RETVAL=0
    fi
    if [ $doApache = true ]; then
        if apache_running ;  then
            action "Stopping apache" stop_apache
            RETVAL=$?
        else
            # If it's not running don't do anything
            log "apache not running"
            RETVAL=0
        fi
    fi
    return $RETVAL
}

get_status() {
    dirname=`basename $ACAS_HOME`
    if running ;  then
        log "app.js running"
    else
        log "app.js not running"
    fi
    if apache_running ;  then
        log "apache running"
    else
        log "apache not running"
    fi
}

usage() {
    echo "Usage: ${0} {start|stop|status|restart|reload|run (options-rservices,acas,all:default-all)}"
}

################################################################################
################################################################################
##                                                                            ##
#                           APPLICATION section                                #
##             Edit the variables below for your installation                 ##
#####################################################r###########################
################################################################################
# SETUP ACAS_HOME path
scriptPath=$(readlink -f ${BASH_SOURCE[0]})
ACAS_HOME=$(cd "$(dirname "$scriptPath")"/..; pwd)
echo "ACAS_HOME=$ACAS_HOME"
cd $ACAS_HOME

# get customer specific environment
[ -f $ACAS_HOME/bin/setenv.sh ] && . $ACAS_HOME/bin/setenv.sh  || echo "$ACAS_HOME/bin/setenv.sh not found"

# Run Prepare config files as the compiled directory should be empty
if [ "$PREPARE_CONFIG_FILES" = "true" ]; then
    gulp execute:prepare_config_files
fi

#Get ACAS config variables
counter=0
wait=5
until [ -f $ACAS_HOME/conf/compiled/conf.properties  ] || [ $counter == $wait ]; do
    printf "."
    sleep 1
    counter=$((counter+1))
done
source /dev/stdin <<< "$(cat $ACAS_HOME/conf/compiled/conf.properties | awk -f $ACAS_HOME/bin/readproperties.awk)"

#Once tomcat is available then try and run prepare module conf json if in environment
if [ "$PREPARE_MODULE_CONF_JSON" = "true" ]; then
    (ping -c 1 ${client_service_persistence_host} > /dev/null
    cd src/javascripts/BuildUtilities
    if [ $? -eq 0 ];then
        counter=0
        wait=100
        until $(curl --output /dev/null --silent --head --fail http://${client_service_persistence_host}:${client_service_persistence_port}) || [ $counter == $wait ]; do
            sleep 1
            counter=$((counter+1))
        done
        if [ $counter == $wait ]; then
            echo "waited $wait seconds for acas to start, giving up on prepare module conf json"
        else
            node PrepareModuleConfJSON.js
        fi
    else
        echo "${client_service_persistence_host} not available, not waiting for roo to start and not running prepare module conf json"
    fi
    cd ../../..
    ) &
fi

# Export these variables so that the apache config can pick them up
export ACAS_USER=${server_run_user}
if [ "$ACAS_USER" == "" ] || [ "$ACAS_USER" == "null" ]; then
    #echo "Setting ACAS_USER to $(whoami)"
    export ACAS_USER=$(whoami)
fi
echo "ACAS_USER=$ACAS_USER"
echo "CLIENT_PORT=${client_port}"

echo "RAPACHE_PORT=${client_service_rapache_port}"
if [ ${client_service_rapache_port} -lt 1024 ] && [ $(whoami) != "root" ]; then
    echo "skipping rapache as client.service.rapache.port is set to run on privilaged port '${client_service_rapache_port}' you must be root to stop, start or reload apache on this port"
    doApache=false
else
    doApache=true
    if [ ${client_service_rapache_port} -lt 1024 ]; then
        RAPACHE_START_ACAS_USER="root"
    else
        RAPACHE_START_ACAS_USER=$ACAS_USER
    fi
fi

case "$1" in
    run)
        name=$2
        name=${name:-all}
        if [[ "$name" =~ ^(acas|rservices|all)$ ]]; then
            do_run $name "${@:3}"
        else
            usage
        fi
    ;;
    start)
        do_start
        RETVAL=$?
    ;;
    stop)
        do_stop
        RETVAL=$?
    ;;
    restart)
        do_stop
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            # Wait some sensible amount, some server need this
            [ -n "$DIETIME" ] && sleep $DIETIME
            do_start
            RETVAL=$?
        fi
    ;;
    status)
        get_status
        RETVAL=0
    ;;
    reload)
        if [ $doApache = true ];  then
            if apache_running; then
                action "reloading apache" apache_reload
                RETVAL=$?
                if [ $RETVAL -eq 0 ]; then
                    log "apache reloaded"
                else
                    log "apache reload failure" "failure"
                    RETVAL=1
                fi
            else
                log "apache is not running" "failure"
                REVAL=0
            fi
            RETVAL=$RETVAL
        fi
    ;;
    *)
        usage
        RETVAL=1
    ;;
esac
exit $RETVAL
