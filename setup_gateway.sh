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


# Process IDs
#
if [ ${EP_NUM} -eq 0 ]
then
	# Non-Group Demo - non-persistent Docker testing
	echo "Local/Demo Add"
	cd /pdc/stack/
	make ep-sample
elif [ ${EP_NUM} -lt 490 ]
then
	# Group #1 Prod range - EPs should already be built
	echo "Group #1 Prod - should have been built already!"
	sudo docker exec -ti hub echo ssh -t -p ${ADMIN_PORT} pdcadmin@localhost /app/provider_add.sh ${EP_NUM} ${DOCTORS}
elif [ ${EP_NUM} -lt 500 ]
then
	# Group #1 Demo range - EPs created locally, use test data
	echo "Group #1 Demo - should have been built already!"
	echo "sudo docker exec -ti hub ssh -t -p ${ADMIN_PORT} pdcadmin@localhost /app/provider_add.sh ${DOCTORS}"
elif [ ${EP_NUM} -lt 990 ]
then
	# Group #2 Prod range - EPs created offsite, use real data
	echo "Group #2 Prod - created remotely, but not scripted yet!"
	echo "sudo docker exec -ti hub ssh -p PORT_TBD pdcadmin@somewhere /pdc/stack/cloud_add.sh ${EP_NUM} ${DOCTORS}"
elif [ ${EP_NUM} - lt 1000 ]
then
	# Group #2 Demo range - EPs created locally, use test data
	echo "Group #2 Demo - created locally, but not scripted  yet!"
	echo "./cloud_add.sh ${EP_NUM} ${DOCTORS}"
else
	echo "Out of range!"
	exit
fi


# Add Endpoint to the HubDB
#
sudo docker exec hubdb /app/endpoint_add.sh $1 | grep WriteResult


# Get ClinicID (Endpoint's MongoDB ObjectID) and provide it to Auth
#
#sudo docker exec -ti auth /sbin/setuser app /app/dacs_add.sh \
#        ${DOCTORS} $(sudo docker exec hubdb /app/endpoint_getClinicID.sh ${EP_NUM}) \
#        ${EP_NAME} admin TEST sample


# 3. HAPI
# +cpsid to each group for participating, lib/groups, populate object around line 14
#
echo "HAPI - not created yet!"
echo "sudo docker exec -ti hapi /sbin/setuser app /app/provider_add.sh ${EP_NUM} ${DOCTORS}"


# 4. Add cpsid to library function filterProviders on Hub
#
echo "Hub filterProviders - not created yet!"
echo "sudo docker exec -ti hub /sbin/setuser app /app/provider_add.sh"
