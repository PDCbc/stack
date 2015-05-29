#!/bin/bash -i
#
set -e -o nounset


# Make sure Node is installed and updated
#
# curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
# apt-get update
# apt-get install -y nodejs

node index.js import --mongo-host=hubdb --mongo-db=query_composer_development --mongo-port=27017
