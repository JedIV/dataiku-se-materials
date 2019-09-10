#!/bin/bash
# Automatically runs upgrade of design/automation/api nodes
## DEFINITELY NOT SAFE OR FOR CUSTOMERS ##

URL="https://cdn.downloads.dataiku.com/public/studio"

DESIGN="dss_beta"
AUTOMATION="dss_beta_automation"
API="dss_beta_api"
ROOT_DIRECTORY_PATH="/Users/jediv/dataiku"

while getopts "bv:" OPTION
do
	case $OPTION in
		b)
			echo "You're using a beta version"
			read -s -p "Password: " PW
			URL="http://dataiku:$PW@downloads.dataiku.com/studio/preview"
			;;
		v)
			echo "The value of -v is $OPTARG"
			VERSION=$OPTARG
			echo "Version: "
			echo VERSION
			;;
	esac
done
echo "Trying to dowload $ROOT_DIRECTORY_PATH/dataiku-dss-$VERSION-osx.tar.gz"

if [ -f $ROOT_DIRECTORY_PATH/dataiku-dss-$VERSION-osx.tar.gz ]
then
    echo "file already downloaded"
else
    echo "downloading now..."
    wget $URL/$VERSION/dataiku-dss-$VERSION-osx.tar.gz
fi
if [ -f $ROOT_DIRECTORY_PATH/dataiku-dss-$VERSION-osx ]
then
    echo "already unzipped"
else
    echo "unzipping now"
    tar -xzf dataiku-dss-$VERSION-osx.tar.gz
fi
# directories 
# Stop everything
$ROOT_DIRECTORY_PATH/$DESIGN/bin/dss stop
$ROOT_DIRECTORY_PATH/$AUTOMATION/bin/dss stop
$ROOT_DIRECTORY_PATH/$API/bin/dss stop

# Perform Upgrades
$ROOT_DIRECTORY_PATH/dataiku-dss-$VERSION-osx/installer.sh -u -d $ROOT_DIRECTORY_PATH/$DESIGN/
$ROOT_DIRECTORY_PATH/dataiku-dss-$VERSION-osx/installer.sh -u -t automation -d $ROOT_DIRECTORY_PATH/$AUTOMATION/
$ROOT_DIRECTORY_PATH/dataiku-dss-$VERSION-osx/installer.sh -u -t api -d $ROOT_DIRECTORY_PATH/$API/

# Rerun integration
$ROOT_DIRECTORY_PATH/$DESIGN/bin/dssadmin install-R-integration


# Start back up
$ROOT_DIRECTORY_PATH/$DESIGN/bin/dss start
$ROOT_DIRECTORY_PATH/$AUTOMATION/bin/dss start
$ROOT_DIRECTORY_PATH/$API/bin/dss start
