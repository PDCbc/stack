#!/bin/bash
#
# Backup script for ownCloud - run from the data dir!
#
# Exit on errors or unitialized variables
set -e -o nounset


# Change to script directory
#
SCRIPT_DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
cd ${SCRIPT_DIR}


# Copy non-sensitive MongoDB dumps to ./mongo_partial/
#
SOURCE_DUMP=${SCRIPT_DIR}/private/mongo_dump/query_composer_development
DESTINATION_DUMP=${SCRIPT_DIR}/config/mongo_partial
sudo mkdir -p ${DESTINATION_DUMP}
#
for FILES in \
	delayed* \
	endpoints* \
	system* \
	users*;
do
	sudo cp ${SOURCE_DUMP}/${FILES} ${DESTINATION_DUMP}
done


# Backup config folder to ownCloud
#
USERNAME=hub.pdc.io
PASSWORD=cOccBgjYqDNRGhZd73A10MTVEeUPFlzI
OWNCLOUD=cloud.pdc.io
#
WEBDAV=https://${OWNCLOUD}/owncloud/remote.php/webdav
#
SOURCE_BACKUP=config
DESTINATION_BACKUP=${WEBDAV}/stack/${SOURCE_BACKUP}
#
sudo owncloudcmd -u ${USERNAME} -p ${PASSWORD} ${SOURCE_BACKUP} ${DESTINATION_BACKUP}
