#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Import Mongo database for set of three endpoints
#
mongoimport --port 27019 --db query_composer_development --collection endpoints $DIR/data/endpoints.json


# Import Mongo databases for Oscar sample 10 records into endpoints
#
mongoimport --port 27020 --db query_gateway_development --collection records $DIR/data/oscar10.json
mongoimport --port 27021 --db query_gateway_development --collection records $DIR/data/oscar10.json
