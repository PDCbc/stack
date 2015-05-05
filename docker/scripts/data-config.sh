#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Import Mongo databases for endpoints and an admin account (users)
#
mongoimport --port 27019 --db query_composer_development --collection endpoints $DIR/data/endpoints.json
mongoimport --port 27019 --db query_composer_development --collection users     $DIR/data/users.json


# Npm deoendencies for importer, import to Mongo
#
cd $DIR
sudo npm install n -g
sudo n stable
npm install assert async fs minimist mongodb mongoose --save
n use 0.12.2 queryImporter import --mongo-host=127.0.0.1 --mongo-db=query_composer_development --mongo-port=27019


# Import Mongo databases for Oscar sample 10 records into endpoints
#
mongoimport --port 27020 --db query_gateway_development --collection records $DIR/data/oscar.json


# Add endpoints to auth
#
EP0=`mongo --port 27019 query_composer_development --eval 'printjson( db.endpoints.findOne({base_url:"http://10.0.2.2:40000" }, { "_id":1 }))'  | grep -o "(.*)" | grep -io "\w\+"`
JS0="{\"clinician\":\"cpsid\",\"clinic\":\""$EP0"\"}"
docker exec app_auth_1 /usr/bin/dacspasswd -uj TEST -pds $JS0 oscar
