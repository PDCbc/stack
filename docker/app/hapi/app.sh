#!/bin/bash
#
# Start script for the PDC's HubAPI service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${HAPI_REPO}
export BRANCH=${HAPI_BRANCH}
export PORT=${HAPI_PORT}
export MONGO_URI=mongodb://hubdb:27017/query_composer_development
export AUTH_CONTROL=https://auth:${AUTH_CONTROLPORT}
export ROLES=${AUTH_ROLEFILE}


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
npm install
exec npm start
