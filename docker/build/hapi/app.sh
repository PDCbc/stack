#!/bin/bash
#
# Start script for the PDC's HubAPI service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${BRANCH_HAPI}
export PORT=${PORT_HAPI}
export MONGO_URI=mongodb://hubdb:27017/query_composer_development
export AUTH_CONTROL=https://auth:${PORT_AUTH_C}
export ROLES=${DACS_ROLEFILE}
export SECRET=${NODE_SECRET}


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
