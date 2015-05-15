#!/bin/bash
#
# Start script for the PDC's Visualizer service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${REPO_VIZ}
export BRANCH=${BRANCH_VIZ}
export PORT=${VIZ_PORT}
export AUTH_MAIN_URL=https://auth:${MAINPORT}
export AUTH_CONTROL_URL=https://auth:${CONTROLPORT}
export CALLBACK_URL=https://auth:${CONTROLPORT}/auth/callback


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
mv --backup=numbered /tmp/app/* /app/
rm -rf /tmp/app/
cd /app/


# Start service
#
npm config set python /usr/bin/python
( npm install )|| true
exec npm start
