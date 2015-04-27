#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Import Mongo databases for endpoints, queries and an admin account (users)
#
mongoimport --port 27019 --db query_composer_development --collection endpoints $DIR/data/endpoints.json
mongoimport --port 27019 --db query_composer_development --collection queries   $DIR/data/queries.json
mongoimport --port 27019 --db query_composer_development --collection users     $DIR/data/users.json


# Import Mongo databases for Oscar sample 10 records into endpoints
#
mongoimport --port 27020 --db query_gateway_development --collection records $DIR/data/oscar.json

( mongoimport --port 27021 --db query_gateway_development --collection records $DIR/data/osler.json )|| \
  ( echo -e "*\n*\nERROR: Osler data not imported. Please ensure osler.json exists.\n*\n*" >&2 )


# Add endpoints to auth
#
EP0=`mongo --port 27019 query_composer_development --eval 'printjson( db.endpoints.findOne({base_url:"http://10.0.2.2:40000" }, { "_id":1 }))'  | grep -o "(.*)" | grep -io "\w\+"`
JS0="{\"clinician\":\"cpsid\",\"clinic\":\""$EP0"\"}"
docker exec app_auth_1 /usr/bin/dacspasswd -uj TEST -pds $JS0 oscar
EP1=`mongo --port 27019 query_composer_development --eval 'printjson( db.endpoints.findOne({base_url:"http://10.0.2.2:40001" }, { "_id":1 }))'  | grep -o "(.*)" | grep -io "\w\+"`
JS1="{\"clinician\":\"27542\",\"clinic\":\""$EP1"\"}"
docker exec app_auth_1 /usr/bin/dacspasswd -uj TEST -pds $JS1 osler
