#!/bin/sh
#As root, run these first
#npm install -g forever
#npm install -g grunt-cli
usage ()
{
  echo 'Usage : Script -d <install_directory> -u <bitbucket_user> -p <bitbucket_password>'
  echo '                -a <acas_branch> -c <custom_repo> -b <custom_branch> -m <deploy_mode> -dev <dev>'
  echo ''
  echo '	-p <bitbucket_password>		optional - password, otherwise it will prompt you'
  echo '	-m <deploy_mode>		optional - acas will run with config-<deploy_mode>.properties and config_advanced-<deploy_mode>.properties files'
  echo '	-dev <dev>			optionally clone "base" or "custom" instead of export'
  echo ''
  exit
}

while [ "$1" != "" ]; do
case $1 in
        -d )           shift
                       INSTALL_DIRECTORY=$1
                       ;;
        -u )           shift
                       BITBUCKET_USER=$1
                       ;;
        -p )           shift
                       BITBUCKET_PASSWORD=$1
                       ;;
        -a )           shift
                       ACAS_BRANCH=$1
                       ;;
        -c )           shift
                       CUSTOM_REPO=$1
                       ;;
        -b )           shift
                       CUSTOM_BRANCH=$1
                       ;;
        -m )           shift
                       DEPLOYMODE=$1
                       ;;
        -dev )         shift
                       DEV=$1
                       ;;
        * )            QUERY=$1
    esac
    shift
done

if [ "$ACAS_BRANCH" = "" ]
then
    usage
fi
if [ "$INSTALL_DIRECTORY" = "" ]
then
    INSTALL_DIRECTORY="."
fi
if [ "$BITBUCKET_USER" = "" ]
then
	printf "Enter bitbucket user: "
	read BITBUCKET_USER
fi
if [ "$BITBUCKET_PASSWORD" = "" ]
then
	printf "Enter bitbucket password for $BITBUCKET_USER: "
	stty -echo
	read BITBUCKET_PASSWORD
	stty echo
	printf '\n'
fi
if [ "$CUSTOM_REPO" != "" ]
then
    if [ "$CUSTOM_BRANCH" = "" ]
	then
    	CUSTOM_BRANCH="master"
	fi
fi
if [ "$DEV" != "base" ] && [ "$DEV" != "custom" ] && [ "$DEV" != "" ]
then
	echo "DEV: $DEV"
    usage
    
fi
#Main

echo "Installing acas_branch $ACAS_BRANCH to $INSTALL_DIRECTORY"
if [ "$CUSTOM_REPO" = "" ]; then
	echo "Not using acas_custom"
else 
	echo "Using custom_repo $CUSTOM_REPO on custom_branch $CUSTOM_BRANCH"
fi
if [ "$DEPLOYMODE" = "" ]; then
	echo "deploy_mode not set so using standard configuration settings"
else
	echo "deploy_mode set to $DEPLOYMODE"
fi
cd $INSTALL_DIRECTORY
if [ -h "acas" ]; then
	rm acas
fi
if [ -h "blueimp" ]; then
	rm blueimp
fi
if [ ! -d "log" ]; then
	mkdir log
fi
date=$(date +%Y-%m-%d-%H-%M-%S)
mkdir acas-$date
ln -s acas-$date acas
cd acas-$date

if [ "$DEV" == "base" ] 
then
	git clone https://$BITBUCKET_USER:$BITBUCKET_PASSWORD@bitbucket.org/mcneilco/acas.git .
	git checkout $ACAS_BRANCH
else
	curl --digest --user $BITBUCKET_USER:$BITBUCKET_PASSWORD https://bitbucket.org/mcneilco/acas/get/$ACAS_BRANCH.tar.gz | tar xvz --strip-components=1 
fi
ln -s acas/serverOnlyModules/blueimp-file-upload-node/ ../blueimp
if [ "$CUSTOM_REPO" != "" ]
then
	echo "Installing acas_custom $CUSTOM_REPO on branch $CUSTOM_BRANCH"
    mkdir acas_custom
	cd acas_custom
	if [ "$DEV" == "custom" ] 
	then
		git clone https://$BITBUCKET_USER:$BITBUCKET_PASSWORD@bitbucket.org/mcneilco/$CUSTOM_REPO.git .
		git checkout $CUSTOM_BRANCH
	else
		curl --digest --user $BITBUCKET_USER:$BITBUCKET_PASSWORD https://bitbucket.org/mcneilco/$CUSTOM_REPO/get/$CUSTOM_BRANCH.tar.gz | tar xvz --strip-components=1 
	fi
	cd ..
else 
	echo "Not installing acas_custom"
fi
echo "Installing node modules"
npm install
echo "Copy acas_custom into place"
grunt copy
echo "Preparing configuration files"
cd conf
node PrepareConfigFiles.js $DEPLOYMODE
echo "Preparing module includes"
node PrepareModuleIncludes.js
echo "Installing racas"
Rscript install.R $ACAS_BRANCH $BITBUCKET_USER $BITBUCKET_PASSWORD
if [ -z "config.R" ]; then
    echo "Running custom config.R file"
	Rscript config.R
else
    echo "Custom config.R file not found in conf, not running"
fi

#export ACAS_HOME=$(pwd)/..
#export R_LIBS=$ACAS_HOME/r_libs
#R -e "library(racas);query('select * from api_protocol')"

