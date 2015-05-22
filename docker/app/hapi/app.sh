#!/bin/bash
#
# Start script for the PDC's HubAPI service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${HAPI_BRANCH}
export PORT=${HAPI_PORT}
export MONGO_URI=mongodb://hubdb:27017/query_composer_development
export AUTH_CONTROL=https://auth:${AUTH_CONTROLPORT}
export ROLES=${AUTH_ROLEFILE}


# Clone and checkout branch or tag
#
cd /app/
git pull
git checkout ${BRANCH}


# Start service
#
cd /app/
npm config set python /usr/bin/python2.7
npm install
exec npm start
