#!/bin/bash
#
# Start script for the PDC's DCLAPI service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${DCLAPI_REPO}
export BRANCH=${DCLAPI_BRANCH}


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
npm install
exec npm start
