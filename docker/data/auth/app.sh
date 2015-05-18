#!/bin/bash
#
# Start script for the PDC's Auth service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${AUTH_REPO}
export BRANCH=${AUTH_BRANCH}
export CONTROLPORT=${AUTH_CONTROLPORT}
export MAINPORT=${AUTH_MAINPORT}
export FEDERATION=${AUTH_FEDERATION}
export JURISDICTION=${AUTH_JURISDICTION}
export ROLEFILE=${AUTH_ROLEFILE}


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
ls -la /tmp/app/
mv --backup=numbered /tmp/app/* /app/
ls -la /app/
mv --backup=numbered /app/federations/* /etc/dacs/federations/
rm -rf /tmp/app/ /app/federations/


# DACS - create roles file load keyfile
#
touch /etc/dacs/federations/pdc.dev/roles
dacskey -uj TEST -v /etc/dacs/federations/pdc.dev/federation_keyfile


# Start service
#
cd /app/
( rm -rf /app/node_modules/ )|| true
npm install
exec npm start
