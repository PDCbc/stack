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
        echo "Usage: cloud_add.sh [endpointNumber] [docID #1],[docID #2],...,[docID #n]"
        echo ""
        exit
fi


# Set variables from parameters, pad EP_NUM to four digits
#
export EP_NUM=${1}
export EP_NAME=pdc-$(printf "%04d" ${EP_NUM})
export ADMIN_PORT=`expr 44000 + ${EP_NUM}`
export DOCTORS=${2}


# Process IDs
#
if [ ${EP_NUM} -eq 0 ]
then
	# Local test EP
	echo "Local Cloud Add - not created yet!"
	echo "cd /pdc/stack/; make ep-sample"
if [ ${EP_NUM} -lt 500 ]
then
	# EPs should already be built
	sudo docker exec -ti hub ssh -t -p ${ADMIN_PORT} pdcadmin@localhost /app/provider_add.sh ${DOCTORS}
elif [ $${EP_NUM} -lt 1000 ]
then
	# EPs to be created
	echo "Cloud Add - not created yet!"
	echo "ssh -p PORT_TBD someone@somewhere /pdc/stack/cloud_add.sh ${EP_NUM}"
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
        ${DOC_SET} $(sudo docker exec hubdb /app/endpoint_getClinicID.sh ${EP_NUM}) \
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
