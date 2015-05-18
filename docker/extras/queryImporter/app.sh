#!/bin/bash
#
# Start script for the PDC's Query Importer service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${QI_REPO}
export BRANCH=${QI_BRANCH}


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
mv --backup=numbered /tmp/app/* /app/
rm -rf /tmp/app/


# Start service
#
cd /app/
( rm -rf /app/node_modules/ )|| true
npm config set python /usr/bin/python2.7
( npm install )|| true
node index.js import --mongo-host=hubdb --mongo-db=query_composer_development --mongo-port=27017
