#!/bin/bash
# Copyright (c) John McNeil & Company Inc.

#########################################################################
#
# This script is for rotating the application log files
# through the Linux logrotate system.
#
#########################################################################

APP_CONFIG_FILE=$ACAS_HOME/conf/compiled/conf.properties
LOG_PATH_VARIABLE=server.log.path
LOGROTATE_CONFIG_FILE=$ACAS_HOME/conf/logrotate.conf

get_prop(){
propfile=$1
key=$2
grep  "^${2}=" ${1}| sed "s%${2}=\(.*\)%\1%"
}


#MAIN
logDirectory=$(get_prop $APP_CONFIG_FILE $LOG_PATH_VARIABLE)

if [ -d "$logDirectory" ]; then
  echo "Rotating log files in $logDirectory"
  cd $logDirectory
  exec /usr/sbin/logrotate  -s logrotate_state_file $LOGROTATE_CONFIG_FILE
  #To Force Rotate
  #exec /usr/sbin/logrotate -f -s logrotate_state_file $LOGROTATE_CONFIG_FILE
fi

echo "Log directory \"$logDirectory\" does not exist"
