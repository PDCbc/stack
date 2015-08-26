#!/bin/bash
#
#
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Endpoint #
# $2 Doctor IDs (separated by commas)


# Check parameters
#
if [ $# -ne 2 ]
then
        echo ""
        echo "Unexpected number of parameters."
        echo ""
        echo "Usage: setup_gateway.sh [endpointNumber] [docID #1],[docID #2],...,[docID #n]"
        echo ""
        exit
fi


# Set variables from parameters, pad EP_NUM to four digits
#
export EP_NUM=${1}
export EP_NAME=pdc-$(printf "%04d" ${EP_NUM})
export ADMIN_PORT=`expr 44000 + ${EP_NUM}`
export DOCTORS=${2}


# Provider specific variables
#
export P1_PORT=${ADMIN_PORT}
export P1_CRED=pdcadmin@localhost
export P2_PORT=<portHere>
export P2_CRED=pdcadmin@localhost


# Process IDs
#
if [ ${EP_NUM} -lt 500 ]
then
	# Group #1 Prod range - EPs should already be built
	echo "Provider #1 Prod - should have been built already!"
	sudo docker exec -ti hub echo TO HUB: ssh -t -p ${P1_PORT} ${P1_CRED} /app/provider_add.sh ${DOCTORS}
elif [ ${EP_NUM} -lt 1000 ]
then
	# Group #2 Prod range - EPs created offsite, use real data
	echo "Provider #2 Prod - created remotely, but not scripted yet!"
	sudo docker exec -ti hub echo TO HUB: ssh -t -p ${P2_PORT} ${P2_CRED} /pdc/stack/gateway_add.sh ${EP_NUM} ${DOCTORS}
else
	echo "Out of range!"
	exit
fi


# Add Endpoint to the HubDB
#
sudo docker exec hubdb /app/endpoint_add.sh $1 | grep WriteResult


# Get ClinicID (Endpoint's MongoDB ObjectID) and provide it to Auth
#
sudo docker exec -ti auth /sbin/setuser app /app/dacs_add.sh \
        ${DOCTORS} $(sudo docker exec hubdb /app/endpoint_getClinicID.sh ${EP_NUM}) \
        ${EP_NAME} admin TEST sample


# 3. HAPI
# +cpsid to each group for participating, lib/groups, populate object around line 14
#
echo "HAPI - not created yet!"
echo "sudo docker exec -ti hapi /sbin/setuser app /app/provider_add.sh ${EP_NUM} ${DOCTORS}"


# 4. Add cpsid to library function filterProviders on Hub
#
echo "Hub filterProviders - not created yet!"
echo "sudo docker exec -ti hub /sbin/setuser app /app/provider_add.sh"
