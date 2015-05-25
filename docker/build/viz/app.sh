#!/bin/bash
#
# Start script for the PDC's Visualizer service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${VIZ_BRANCH}
export PORT=${VIZ_PORT}
export AUTH_MAIN_URL=https://auth:${AUTH_MAINPORT}
export AUTH_CONTROL_URL=https://auth:${AUTH_CONTROLPORT}
export CALLBACK_URL=https://auth:${AUTH_CONTROLPORT}/auth/callback
export HUBAPI_URL=${HAPI_URL}


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
