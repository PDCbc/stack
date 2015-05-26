#!/bin/bash
#
# Start script for the PDC's Visualizer service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${BRANCH_VIZ}
export PORT=${PORT_VIZ}
export AUTH_MAIN_URL=https://auth:${PORT_AUTH_M}
export AUTH_CONTROL_URL=https://auth:${PORT_AUTH_C}
export CALLBACK_URL=https://auth:${PORT_AUTH_C}/auth/callback
export HUBAPI_URL=${URL_HAPI}
export SECRET=${NODE_SECRET}
export DACS=${DACS_STOREDIR}


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
