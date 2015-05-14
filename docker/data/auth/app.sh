#!/bin/bash
#
# Start script for the PDC's Auth service


# Exit on errors or unitialized variables
#
set -e


# Service name
#
REPO=${REPO_AUTH}
BRANCH=${BRANCH_AUTH}


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
mv /tmp/app/* /app/
rm -rf /tmp/app/ /etc/dacs/federations/
mv /app/federations/ /etc/dacs/federations/
chown app:app /app/


# Load DACS keyfile
#
dacskey -uj TEST -v /etc/dacs/federations/pdc.dev/federation_keyfile


# Start service
#
cd /app/
npm install
npm start
