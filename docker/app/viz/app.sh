#!/bin/bash
#
# Start script for the PDC's Visualizer service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${VIZ_REPO}
export BRANCH=${VIZ_BRANCH}
export PORT=${VIZ_PORT}
export AUTH_MAIN_URL=https://auth:${AUTH_MAINPORT}
export AUTH_CONTROL_URL=https://auth:${AUTH_CONTROLPORT}
export CALLBACK_URL=https://auth:${AUTH_CONTROLPORT}/auth/callback
export HUBAPI_URL=${HAPI_URL}


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
exec npm start
