#!/bin/bash
#
# Start script for the PDC's DCLAPI service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${DCLAPI_BRANCH}


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
npm start
