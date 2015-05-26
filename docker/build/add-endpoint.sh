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
# $5 Password [optional]


# Check parameters
#
if([ $# -eq 0 ] || [ $# -gt 5 ])
then
	echo ""
	echo "Unexpected number of parameters."
	echo ""
	echo "Usage: up-endpoint.sh [endpointNumber] [clinicianNumber] [optional:visualizerName] [optional:jurisdiction] [optional:password]"
	echo ""
	exit
fi


# Script directory, useful for running scripts from scripts
#
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Set variables from parameters
#
export EPNAME=ep${1}
export DBNAME=ep${1}db
export EPPORT=`expr 40000 + ${1}`
export CLINICIAN=${2}
export USERNAME=${3:-$CLINICIAN}
export JURISDICTION=${4:-TEST}
export KEY="No key created"


# Script directory, useful for running scripts from scripts
#
export SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Prompt for password, if necessary
#
if [ $# -eq  5 ]
then
	PASSWORD=${5}
else
	echo "Please provide a password for user "${USERNAME}":"
	read -s PASSWORD
	echo ""
fi


# Start containers and fetch ssh key
#
(
	sudo docker build -t pdc.io/endpoint ${SCRIPT_DIR}/endpoint/
  sudo docker run -d --name ${DBNAME} -h ${DBNAME} --restart='always' -e "LC_ALL=C" mongo --smallfiles
	sudo docker run -d -e "gID=${1}" --name ${EPNAME} -h ${EPNAME} --env-file=${SCRIPT_DIR}/../config.env --link ${DBNAME}:epdb -p ${EPPORT}:3001 pdc.io/endpoint
) || echo "ERROR: Does "${EPNAME}" already exist?"


# Add SSH public key to authorized keys
#
PUB_KEY=`sudo docker exec ${EPNAME} /app/key_exchange.sh | grep -v /app/wait`
(
	echo ${PUB_KEY} | sudo tee -a ${PATH_KEYS_ENDPOINTS}/authorized_keys
	sudo chown vagrant:vagrant ${PATH_KEYS_ENDPOINTS}/authorized_keys
	echo "SSH public key recorded"
) || echo "ERROR: SSH public key not recorded"


# Check (by URL) if Endpoint is already in the Hub
#
SH_CMD='db.endpoints.count({ "base_url" : "http://localhost:'${EPPORT}'" })'
D_EXEC="sudo docker exec hubdb mongo query_composer_development --eval '${SH_CMD}'"
RESULT=`/bin/bash -c "${D_EXEC}" | grep -v Mongo | grep -v connecting`


# Add to Hub, if not there
#
if [ ${RESULT} = "0" ]
then
	JSON='{ "name" : "'${EPNAME}'", "base_url" : "http://localhost:'${EPPORT}'" }'
	EVAL="--eval 'db.endpoints.insert( ${JSON} )'"
	(
	  /bin/bash -c "sudo docker exec hubdb mongo query_composer_development ${EVAL}"
	) || echo "ERROR: "${EPNAME}" will not be pre-populated in the Hub."
else
	echo "Endpoint already added to Hub."
fi


# Auth - Add user to DACS,
#
(
  /bin/bash -c "sudo docker exec auth /sbin/setuser app /usr/bin/dacspasswd -uj ${JURISDICTION} -p ${PASSWORD} -a ${USERNAME}"
) || echo "ERROR: Failed on Auth add."


# Add user to ROLEFILE, unless already there
#
CHECK=$( sudo docker exec auth /bin/bash -c "cat /etc/dacs/federations/pdc.dev/roles" )
if (( `echo ${CHECK} | grep -c ${USERNAME}` > 0 ))
then
	echo "User already added."
else
	ROLEFILE=/etc/dacs/federations/pdc.dev/roles
	INROLE="${USERNAME}:admin >> ${ROLEFILE}"
	(
	  /bin/bash -c "sudo docker exec auth /bin/bash -c \"echo ${INROLE}\""
	) || echo "ERROR: Failed appending to ROLEFILE."
fi


# Obtain clinic number
#
TO_QRY='{ "base_url" : "http://localhost:'${EPPORT}'" }, { "_id": 1 }'
SH_CMD="printjson( db.endpoints.findOne( ${TO_QRY} ))"
D_EXEC="sudo docker exec hubdb mongo query_composer_development --eval '${SH_CMD}'"
CLINIC=`/bin/bash -c "${D_EXEC}" | grep -o "(.*)" | grep -io "\w\+"`


# Set private data
#
INJSON=`echo \'{ \"clinician\":\""${CLINICIAN}"\", \"clinic\":\""${CLINIC}"\" }\'`
(
	/bin/bash -c "sudo docker exec auth /sbin/setuser app /usr/bin/dacspasswd -uj TEST -pds ${INJSON} ${USERNAME}"
) || echo "ERROR: Failed to add private data."


# If using sample doctor (cpsid), add sample data
#
if [ ${CLINICIAN}="cpsid" ]
then
	MNT=$( sudo docker inspect -f '{{.Id}}' ${DBNAME} )
	sudo cp -r ${SCRIPT_DIR}/endpoint/oscar.json /var/lib/docker/aufs/mnt/${MNT}/tmp/
	sudo docker exec ${DBNAME} mongoimport --db query_gateway_development --collection records /tmp/oscar.json
fi
