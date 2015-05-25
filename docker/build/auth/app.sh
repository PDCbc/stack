#!/bin/bash
#
# Start script for the PDC's Auth service
#
# Note: unlike the PDC's other Docker startup scripts
#       this one is intended to be run as root


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${AUTH_BRANCH}
export CONTROLPORT=${AUTH_CONTROLPORT}
export MAINPORT=${AUTH_MAINPORT}
export FEDERATION=${AUTH_FEDERATION}
export JURISDICTION=${AUTH_JURISDICTION}
export ROLEFILE=${AUTH_ROLEFILE}


# Clone and checkout branch or tag (default is master)
#
cd /app/
git pull
git checkout ${BRANCH:-master}


# If jurisdiction folder doesn't exist, then initialize DACS
#
if [ ! -d /etc/dacs/federations/pdc.dev/TEST/ ]
then
  (
    mkdir -p /etc/dacs/federations/pdc.dev/TEST/
    cp /app/federations/dacs.conf /etc/dacs/federations/
    cp /app/federations/site.conf /etc/dacs/federations/
    touch /etc/dacs/federations/pdc.dev/roles
    touch /etc/dacs/federations/pdc.dev/federation_keyfile
    dacskey -uj TEST -v /etc/dacs/federations/pdc.dev/federation_keyfile
  )||(
    echo "ERROR: DACS initialization unsuccessful" >&2
  )
fi


# Start service
#
cd /app/
npm install
npm start
