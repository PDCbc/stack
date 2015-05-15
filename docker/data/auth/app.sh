#!/bin/bash
#
# Start script for the PDC's Auth service


# Exit on errors or unitialized variables
#
set -e -o nounset -x


# Environment variables
#
REPO=${REPO_AUTH}
BRANCH=${BRANCH_AUTH}


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
ls -la /tmp/app/
mv --backup=numbered /tmp/app/* /app/
ls -la /app/
mv --backup=numbered /app/federations/* /etc/dacs/federations/
rm -rf /tmp/app/ /app/federations/
#chown app:app /app/ /etc/dacs/federations/
#RUN mkdir -p /etc/dacs/federations/pdc.dev/
#RUN touch /etc/dacs/federations/pdc.dev/federation_keyfile

# DACS - create roles file load keyfile
#
touch /etc/dacs/federations/pdc.dev/roles
dacskey -uj TEST -v /etc/dacs/federations/pdc.dev/federation_keyfile


# Start service
#
cd /app/
npm install
npm start
