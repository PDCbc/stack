#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Endpoint number
# $2 Clinician number
# $3 Visualizer login name [optional]
# $4 Jurisdiction [optional]


# Check parameters
#
if([ $# -eq 0 ] || [ $# -gt 4 ])
then
	echo ""
	echo "Unexpected number of parameters."
	echo ""
	echo "Usage: up-endpoint.sh [endpointNumber] [clinicianNumber] [optional:visualizerName] [optional:jurisdiction]"
	echo ""
	exit
fi


# Script directory, useful for running scripts from scripts
#
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Set variables from parameters
#
EPNAME=ep${1}
DBNAME=ep${1}db
EPPORT=`expr 40000 + ${1}`
CLINICIAN=$2
USERNAME=${3:-$CLINICIAN}
JURISDICTION=${4:-TEST}


# If a username has not been specified, output default (Endpoint name)
#
if [ $# -eq 1 ]
then
	echo "No username provided.  Defaulting to "${USERNAME}"."
	echo ""
fi


# Prompt for password
#
echo "Please provide a password for user "${USERNAME}":"
read -s PASSWORD
echo ""


# Start containers
#
(
	sudo docker build -t endpoint ${SCRIPT_DIR}
  sudo docker run -dt --name ${DBNAME} -h ${DBNAME} --restart='always' mongo --smallfiles
  sudo docker run -dt --name ${EPNAME} -h ${EPNAME} --restart='always' -p ${EPPORT}:3001 -e "gID=${1}" --link ${DBNAME}:epdb endpoint
) || echo "ERROR: Does "${EPNAME}" already exist?"


# Check (by URL) if Endpoint is already in the Hub
#
CHECK='{ "base_url" : "http://10.0.2.2:'${EPPORT}'"}'
CHECK="mongo --port 27019 query_composer_development --eval 'db.endpoints.count( ${CHECK} )'"
CHECK=`/bin/bash -c "${CHECK} | grep -v Mongo | grep -v connecting"`


# Add to Hub, if not there
#
if [ $CHECK = "0" ]
then
	INSERT='{ "name" : "'${EPNAME}'", "base_url" : "http://10.0.2.2:'${EPPORT}'" }'
	INSERT="--eval 'db.endpoints.insert( ${INSERT} )'"
	(
	  /bin/bash -c "sudo docker exec data_hubdb_1 mongo query_composer_development ${INSERT}"
	) || echo "ERROR: "${EPNAME}" will not be pre-populated in the Hub."
else
	echo "Endpoint already added to Hub."
fi


# Auth - Add user to DACS,
#
(
  /bin/bash -c "sudo docker exec data_auth_1 dacspasswd -uj ${JURISDICTION} -p ${PASSWORD} -a ${USERNAME}"
) || echo "ERROR: Failed on Auth add."


# Add user to ROLEFILE, unless already there
#
CHECK=$( sudo docker exec -it data_auth_1 /bin/bash -c "cat /etc/dacs/federations/pdc.dev/roles" )
if (( `echo ${CHECK} | grep -c ${USERNAME}` > 0 ))
then
	echo "User already added."
else
	ROLEFILE=/etc/dacs/federations/pdc.dev/roles
	INROLE="${USERNAME}:admin >> ${ROLEFILE}"
	(
	  /bin/bash -c "sudo docker exec -it data_auth_1 /bin/bash -c \"echo ${INROLE}\""
	) || echo "ERROR: Failed appending to ROLEFILE."
fi


# Set private data
#
CLINIC='{ "base_url" : "http://10.0.2.2:'${EPPORT}'" }, { "_id": 1 }'
CLINIC="printjson( db.endpoints.findOne( ${CLINIC} ))"
CLINIC="sudo docker exec data_hubdb_1 mongo query_composer_development --eval '${CLINIC}'"
CLINIC=`/bin/bash -c "${CLINIC}" | grep -o "(.*)" | grep -io "\w\+"`
INJSON=`echo \'{ \"clinician\":\""${CLINICIAN}"\", \"clinic\":\""${CLINIC}"\" }\'`
(
	/bin/bash -c "sudo docker exec data_auth_1 /usr/bin/dacspasswd -uj TEST -pds ${INJSON} ${USERNAME}"
) || echo "ERROR: Failed to add private data."


# If using sample doctor (cpsid), add sample data
#
if [ $CLINICIAN="cpsid" ]
then
	MNT=$( sudo docker inspect -f '{{.Id}}' ${DBNAME} )
	sudo ls /var/lib/docker/aufs/mnt/${MNT}/
	sudo cp -r ${SCRIPT_DIR}/oscar.json /var/lib/docker/aufs/mnt/${MNT}/tmp/
	sudo ls /var/lib/docker/aufs/mnt/${MNT}/
	sudo docker exec ${DBNAME} mongoimport --db query_gateway_development --collection records /tmp/oscar.json
fi


# Wrap up
#
echo ""
echo "Please visit the visualizer and get started!"
echo ""
