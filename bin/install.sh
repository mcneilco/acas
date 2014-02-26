#As root, run these first
#npm install -g forever
#npm install -g grunt-cli
usage ()
{
  echo 'Usage : Script -u <bitbucket_user> -p <bitbucket_password> -a <acas_branch>'
  echo '                   -c <custom_repo> -b <custom_branch> -d <deploymode>'
  exit
}

while [ "$1" != "" ]; do
case $1 in
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
        -d )           shift
                       DEPLOYMODE=$1
                       ;;
        * )            QUERY=$1
    esac
    shift
done

if [ "$ACAS_BRANCH" = "" ]
then
    usage
fi
if [ "$BITBUCKET_USER" = "" ]
then
    read -p "Enter bitbucket user: " BITBUCKET_USER
fi
if [ "$BITBUCKET_PASSWORD" = "" ]
then
    read -s -p "Enter bitbucket password for $BITBUCKET_USER: " BITBUCKET_PASSWORD
fi
if [ "$CUSTOM_REPO" = "" ]
then
    if [ "$CUSTOM_BRANCH" = "" ]
	then
    	CUSTOM_BRANCH="master"
	fi
fi

#Main
cd $INSTALL_DIR
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
curl --digest --user $BITBUCKET_USER:$BITBUCKET_PASSWORD https://bitbucket.org/mcneilco/acas/get/$ACAS_BRANCH.tar.gz | tar xvz --strip-components=1 
ln -s acas/serverOnlyModules/blueimp-file-upload-node/ ../blueimp
if [ "$CUSTOM_REPO" != "" ]
then
    mkdir acas_custom
	cd acas_custom
	curl --digest --user $BITBUCKET_USER:$BITBUCKET_PASSWORD https://bitbucket.org/mcneilco/$CUSTOM_REPO/get/$CUSTOM_BRANCH.tar.gz | tar xvz --strip-components=1 
	cd ..
fi
npm install
grunt copy
cd conf
node PrepareConfigFiles.js $DEPLOYMODE
node PrepareModuleIncludes.js
Rscript install.R $ACAS_BRANCH $BITBUCKET_USER $BITBUCKET_PASSWORD
if [ -z "config.R" ]; then
	Rscript config.R
fi
export ACAS_HOME=$(pwd)/..
export R_LIBS=$ACAS_HOME/r_libs
R -e "library(racas);query('select * from api_protocol')"


