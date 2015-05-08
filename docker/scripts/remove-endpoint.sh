#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Endpoint number


# Check parameters
#
if [ ! $# -eq 1 ]
then
	echo ""
	echo "Unexpected number of parameters."
	echo ""
	echo "Usage: remove-endpoint.sh [endpointNumber]"
	echo ""
	exit
fi
echo ""


# Remove containers
#
EPNAME=ep${1}
DBNAME=ep${1}db
EPPORT=`expr 40000 + ${1}`
(
	docker stop ${EPNAME} ${DBNAME}
	docker rm -v ${EPNAME} ${DBNAME}
) || echo "ERROR: Does "$EPNAME" exist?"


# Set variables from parameters
#
REMOVE="'db.endpoints.remove( { \"base_url\" : \"http://10.0.2.2:${EPPORT}\" } )'"; \
/bin/bash -c "docker exec data_hubdb_1 mongo query_composer_development --eval ${REMOVE}"
