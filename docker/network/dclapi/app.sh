#!/bin/bash
#
# Start script for the PDC's DCLAPI service


# Exit on errors or unitialized variables
#
set -e


# Service name
#
REPO=${REPO_DCLAPI}
BRANCH=${BRANCH_DLAPI}


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
mv /tmp/app/* /app/
rm -rf /tmp/app/
cd /app/


# Start service
#
npm install
npm start
