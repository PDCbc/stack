#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -x -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Import Mongo databases for queries and an admin account (users)
#
mongoimport --port 27019 --db query_composer_development --collection queries $DIR/data/queries.json
mongoimport --port 27019 --db query_composer_development --collection users   $DIR/data/users.json
