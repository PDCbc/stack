#!/bin/bash
#
# Start script for the PDC's Hub service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Environment variables
#
export BRANCH=${HUB_BRANCH}


# Clone and checkout branch or tag
#
cd /app/
git pull
git checkout ${BRANCH}


# Configure Hub (run bundler as non-root)
#
cd /app/
bundle install --path vendor/bundle
sed -i -e "s/localhost:27017/hubdb:27017/" config/mongoid.yml


# Configure Hub (run bundler as non-root)
#
cd /app/
bundle install
bundle exec script/delayed_job start
exec bundle exec rails server -p 3002
bundle exec script/delayed_job stop
