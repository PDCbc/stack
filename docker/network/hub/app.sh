#!/bin/bash
#
# Start script for the PDC's Hub service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export REPO=${HUB_REPO}
export BRANCH=${HUB_BRANCH}


# Clone and checkout branch or tag
#
( rm -rf /tmp/app/ )|| true
git clone -b ${BRANCH} --single-branch https://github.com/${REPO} /tmp/app/
mv --backup=numbered /tmp/app/* /app/
rm -rf /tmp/app/


# Configure Hub (run bundler as non-root)
#
cd /app/
bundle install --path vendor/bundle
sed -i -e "s/localhost:27017/hubdb:27017/" config/mongoid.yml


# Start service
#
( rm -rf /app/node_modules/ )|| true
bundle install
bundle exec script/delayed_job start
exec bundle exec rails server -p 3002
bundle exec script/delayed_job stop
