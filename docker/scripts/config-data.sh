#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Add admin account
#
INSERT='{ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "$2a$10$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true }'
INSERT="--eval 'db.users.insert( ${INSERT} )'"
/bin/bash -c "docker exec network_hubdb_1 mongo query_composer_development ${INSERT}"


# If Ep0 is not in the Hub, then add it
#
CHECK='{ "base_url" : "http://10.0.2.2:40000"}'
CHECK="--eval 'db.endpoints.count( ${CHECK} )'"
CHECK="docker exec network_hubdb_1 mongo query_composer_development ${CHECK}"
CHECK=$( /bin/bash -c "${CHECK} | grep -v Mongo | grep -v connecting" )
#
if [ $CHECK = "0" ]
then
INSERT='{ "name" : "ep0-oscar", "base_url" : "http://10.0.2.2:40000" }'
INSERT="--eval 'db.endpoints.insert( ${INSERT} )'"
	(
    /bin/bash -c "docker exec network_hubdb_1 mongo query_composer_development ${INSERT}"
	) || echo "ERROR: "${EPNAME}" will not be pre-populated in the Hub."
else
	echo "Endpoint already added to Hub."
fi


# Import Mongo databases for queries and Oscar sample 10 records
#
mongoimport --port 27019 --db query_composer_development --collection queries $DIR/data/queries.json
mongoimport --port 27020 --db query_gateway_development --collection records $DIR/data/oscar.json


# Add Ep0 private data to Auth
#
EP0_id='{ base_url : "http://10.0.2.2:40000" }, { _id : 1 }'
EP0_id="--eval 'printjson( db.endpoints.findOne( ${EP0_id} ))'"
EP0_id=$( /bin/bash -c "docker exec network_hubdb_1 mongo query_composer_development ${EP0_id}" )
EP0_id=$( echo ${EP0_id} | grep -o "(.*)" | grep -io "\w\+" )
JS0="'{\"clinician\":\"cpsid\",\"clinic\":\"'${EP0_id}'\"}'"
(
  /bin/bash -c "docker exec app_auth_1 /usr/bin/dacspasswd -uj TEST -pds ${JS0} oscar"
) || echo "ERROR: "${EPNAME}" will not be pre-configured in Auth."
