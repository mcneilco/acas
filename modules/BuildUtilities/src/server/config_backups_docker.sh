#!/bin/sh

usage ()
{
  echo 'Usage : Script -d <backup_directory> -u <backup_user> -p <docker_project>'
  echo ''
  exit
}

while [ "$1" != "" ]; do
case $1 in
        -d )           shift
                       BACKUP_DIRECTORY=$1
                       ;;
        -u )           shift
                       BACKUP_USER=$1
                       ;;
        -p )           shift
                       PROJECT=$1
                       ;;
        * )            QUERY=$1
    esac
    shift
done

if [ "$BACKUP_DIRECTORY" = "" ]
then
	echo "backup_directory cannot be empty"	
    usage
fi
if [ "$PROJECT" = "" ]
then
	echo "project cannot be empty"	
    usage
fi
if [ "$BACKUP_USER" = "" ]
then
	echo "backup_user cannot be empty"
    usage
else 
	userCount=$(grep -c '^'$BACKUP_USER':' /etc/passwd)
	if [ $userCount -lt 1 ]
	then
		echo "backup_user '$BACKUP_USER' does not exist"
		usage
	fi
fi

#Get ACAS config variables
source /dev/stdin <<< "$(docker exec colas_acas_1 bash -c 'cat $ACAS_HOME/conf/compiled/conf.properties | awk -f $ACAS_HOME/bin/readproperties.awk')"

server_database_name=${server_database_name}
server_database_username=${server_database_username}
server_database_password=${server_database_password}
server_database_port=${server_database_port}
server_datafiles_relative_path=${server_datafiles_relative_path}


##########Setup folder heirarchy 
###if $BACKUP_DIRECTORY does not exist then create it
echo "configuring backup base directories"
if [ -d "$BACKUP_DIRECTORY" ]; then
	echo "	exists $BACKUP_DIRECTORY"
else
	echo "	creating $BACKUP_DIRECTORY"
	mkdir "$BACKUP_DIRECTORY/$PROJECT"
fi

###Now setup the base backup location for seurat instance
backupsLocation=$BACKUP_DIRECTORY/$PROJECT
echo "	creating $backupsLocation/backups/backup_hourly"
mkdir -p $backupsLocation/backups/backup_hourly
echo "	creating $backupsLocation/backups/backup_daily"
mkdir -p $backupsLocation/backups/backup_daily
echo "	creating $backupsLocation/backups/backup_weekly"
mkdir -p $backupsLocation/backups/backup_weekly
echo "	creating $backupsLocation/backups/scripts"
mkdir -p $backupsLocation/scripts

#############Begin Creating Scripts
echo "configuring backup scripts"
###backup_hourly
###Create tmp file
echo "	creating $backupsLocation/scripts/backup_hourly.sh"
touch $backupsLocation/scripts/backup_hourly.sh
cat /dev/null > $backupsLocation/scripts/backup_hourly.sh
###Setup Script specific variables
backupDirLine="BaseBackupDir=$backupsLocation/backups"
logDateLine="date >> \$BaseBackupDir/backup_hourly/backuplog.txt"
logStartLineDaily="echo \"$PROJECT Hourly Backup\" >> \$BaseBackupDir/backup_hourly/backuplog.txt"
ACASNameDaily="acasArchNameGz=filestore_\`date +%H\`.tar.gz"
DBNameDaily="dbNameGz=dbstore_${server_database_name}_\`date +%H\`.gz"
acasImageLine="ACAS_IMAGE=\$(docker ps --filter \"name=``$PROJECT``_acas_1\"  --format \"{{.Image}}\")"
dbImageLine="DB_IMAGE=\$(docker ps --filter \"name=``$PROJECT``_db_1\"  --format \"{{.Image}}\")"
acasTarLine="docker run --rm -e acasArchNameGz=\$acasArchNameGz -v \$BaseBackupDir/backup_hourly:/backup -v ``$PROJECT``_filestore:/home/runner/build/privateUploads \$ACAS_IMAGE tar -pPzcf /backup/\$acasArchNameGz $server_datafiles_relative_path >> \$BaseBackupDir/backup_hourly/backuplog.txt 2>&1"
dbDumpLine="docker run --rm  --network ``$PROJECT``_default -e dbNameGz=\$dbNameGz -e PGPASSWORD=${server_database_password} -e server_database_host=$server_database_host -e server_database_port=$server_database_port -e server_database_username=server_database_username -e server_database_password=server_database_password -v \$BaseBackupDir/backup_hourly:/backup -v ``$PROJECT``_dbstore:/var/lib/postgresql/data \$DB_IMAGE bash -c \"pg_dump --host=${server_database_host} --port=${server_database_port} --username=${server_database_username} --clean ${server_database_name} | gzip -c > /backup/\$dbNameGz\" >> \$BaseBackupDir/backup_hourly/backuplog.txt 2>&1"

##Add Lines to Temp File
echo $backupDirLine >> $backupsLocation/scripts/backup_hourly.sh
echo $logStartLineDaily >> $backupsLocation/scripts/backup_hourly.sh
echo $logDateLine >> $backupsLocation/scripts/backup_hourly.sh
echo $ACASNameDaily >> $backupsLocation/scripts/backup_hourly.sh
echo $DBNameDaily >> $backupsLocation/scripts/backup_hourly.sh
echo $acasImageLine >> $backupsLocation/scripts/backup_hourly.sh
echo $dbImageLine >> $backupsLocation/scripts/backup_hourly.sh
echo $acasTarLine >> $backupsLocation/scripts/backup_hourly.sh
echo $dbDumpLine >> $backupsLocation/scripts/backup_hourly.sh

###backup_daily
###Create File
echo "	creating $backupsLocation/scripts/backup_daily.sh"
touch $backupsLocation/scripts/backup_daily.sh
cat /dev/null > $backupsLocation/scripts/backup_daily.sh
###Variables
backupDirLine="BaseBackupDir=$backupsLocation/backups"
logDateLine="date >> \$BaseBackupDir/backup_daily/backuplog.txt"
logStartLineDaily="echo \"$BackupName Daily Backup\" >> \$BaseBackupDir/backup_daily/backuplog.txt"
ACASNameDaily="acasArchNameGz=filestore_\`date +%a\`.tar.gz"
DBNameDaily="dbNameGz=dbstore_${server_database_name}_\`date +%a\`.gz"
cpLine1Daily="cp \$BaseBackupDir/backup_hourly/filestore_23.tar.gz \$BaseBackupDir/backup_daily/\$acasArchNameGz >> \$BaseBackupDir/backup_daily/backuplog.txt 2>&1"
cpLine2Daily="cp \$BaseBackupDir/backup_hourly/dbstore_${server_database_name}_23.gz \$BaseBackupDir/backup_daily/\$dbNameGz >> \$BaseBackupDir/backup_daily/backuplog.txt 2>&1"
##Add to File
echo $backupDirLine >> $backupsLocation/scripts/backup_daily.sh
echo $logStartLineDaily >> $backupsLocation/scripts/backup_daily.sh
echo $logDateLine >> $backupsLocation/scripts/backup_daily.sh
echo $ACASNameDaily >> $backupsLocation/scripts/backup_daily.sh
echo $DBNameDaily >> $backupsLocation/scripts/backup_daily.sh
echo $cpLine1Daily >> $backupsLocation/scripts/backup_daily.sh
echo $cpLine2Daily >> $backupsLocation/scripts/backup_daily.sh

###backup_weekly
###Create File
echo "	creating $backupsLocation/scripts/backup_weekly.sh"
touch $backupsLocation/scripts/backup_weekly.sh
cat /dev/null > $backupsLocation/scripts/backup_weekly.sh
###Variables
backupDirLine="BaseBackupDir=$backupsLocation/backups"
logDateLine="date >> \$BaseBackupDir/backup_weekly/backuplog.txt"
logStartLineWeekly="echo \"$BackupName Weekly Backup\" >> \$BaseBackupDir/backup_weekly/backuplog.txt"
ACASNameWeekly="acasArchNameGz=filestore_\`date +%m_%d_%y\`.tar.gz"
DBNameWeekly="dbNameGz=dbstore_${server_database_name}_\`date +%m_%d_%y\`.gz"
cpLine1Weekly="cp \$BaseBackupDir/backup_daily/filestore_Fri.tar.gz \$BaseBackupDir/backup_weekly/\$acasArchNameGz >> \$BaseBackupDir/backup_weekly/backuplog.txt 2>&1"
cpLine2Weekly="cp \$BaseBackupDir/backup_daily/dbstore_${server_database_name}_Fri.gz \$BaseBackupDir/backup_weekly/\$dbNameGz >> \$BaseBackupDir/backup_weekly/backuplog.txt 2>&1"
##Add to File
echo $backupDirLine >> $backupsLocation/scripts/backup_weekly.sh
echo $logStartLineWeekly >> $backupsLocation/scripts/backup_weekly.sh
echo $logDateLine >> $backupsLocation/scripts/backup_weekly.sh
echo $ACASNameWeekly >> $backupsLocation/scripts/backup_weekly.sh
echo $DBNameWeekly >> $backupsLocation/scripts/backup_weekly.sh
echo $cpLine1Weekly >> $backupsLocation/scripts/backup_weekly.sh
echo $cpLine2Weekly >> $backupsLocation/scripts/backup_weekly.sh

###Now Setup crontab
su - $BACKUP_USER -c "touch /tmp/crontabFile.txt"
su - $BACKUP_USER -c "crontab -l > /tmp/crontabFile.txt"

echo "removing any old cron for backup_user $BACKUP_USER, instance ${PROJECT}"
su - $BACKUP_USER -c "sed -i '/#START ${PROJECT} backup scripts section/,/#END ${PROJECT} backup scripts section/d' /tmp/crontabFile.txt"

echo "installing cron for backup_user $BACKUP_USER"
su - $BACKUP_USER -c "echo \"#START ${PROJECT} backup scripts section\" >> /tmp/crontabFile.txt"
su - $BACKUP_USER -c "echo \"01 23	 * * * $backupsLocation/scripts/backup_hourly.sh 2>&1\"  >> /tmp/crontabFile.txt"
su - $BACKUP_USER -c "echo \"30 23 * * * $backupsLocation/scripts/backup_daily.sh 2>&1\"  >> /tmp/crontabFile.txt"
su - $BACKUP_USER -c "echo \"40 23 * * 5 $backupsLocation/scripts/backup_weekly.sh 2>&1\"  >> /tmp/crontabFile.txt"
su - $BACKUP_USER -c "echo \"#END ${PROJECT} backup scripts section\" >> /tmp/crontabFile.txt"
su - $BACKUP_USER -c "crontab /tmp/crontabFile.txt"
su - $BACKUP_USER -c "rm -f /tmp/crontabFile.txt"

##Set permissions for these new files to the backup user
chown -R $BACKUP_USER $backupsLocation
chmod -R 700 $backupsLocation
