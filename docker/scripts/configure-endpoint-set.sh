#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Add endpoints to mongo
#
mongoimport --port 27020 --db query_gateway_development --collection records $DIR/data/oscar10.json
mongoimport --port 27021 --db query_gateway_development --collection records $DIR/data/oscar10.json
mongoimport --port 27022 --db query_gateway_development --collection records $DIR/data/oscar10.json
