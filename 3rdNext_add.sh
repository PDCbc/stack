#!/bin/bash
#
#
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Endpoint #
# $2 Doctor ID


# Check parameters
#
if([ $# -lt 2 ] || [ $# -gt 3 ])
then
        echo ""
        echo "Unexpected number of parameters."
        echo ""
        echo "Usage: dacs_add.sh [endpointNumber] [doctorID] [more soon!]"
        echo ""
        exit
fi


# Set variables from parameters
#
export EP_NUM=$(printf "%04d" ${1})
export EP_NAME=pdc-${EP_NUM} 
export DOCTOR=${2}
export ADMIN_PORT=`expr 44000 + ${EP_NUM}`


# Pass command for appending to Endpoint's providers.txt
#
sudo docker exec -ti hub ssh -t -p ${ADMIN_PORT} pdcadmin@localhost /app/provider_add.sh ${DOCTOR}


# Add Endpoint to the HubDB
#
sudo docker exec hubdb /app/endpoint_add.sh $1 | grep WriteResult


# Get ClinicID (Endpoint's MongoDB ObjectID) and provide it to Auth
#
sudo docker exec -ti auth /sbin/setuser app /app/dacs_add.sh \
        ${DOCTOR} $(sudo docker exec hubdb /app/endpoint_getClinicID.sh ${EP_NUM}) \
        ${EP_NAME} admin TEST sample


# 3. HAPI
# +cpsid to each group for participating, lib/groups, populate object around line 14
#
# ...


# 4. Add cpsid to library function filterProviders on Hub
#
# ...
