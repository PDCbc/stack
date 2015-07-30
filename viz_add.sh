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
        echo "Usage: viz_add.sh [endpointNumber] [doctorID] [more soon!]"
        echo ""
        exit
fi


# Set variables from parameters
#
export EP_NUM=$(printf "%04d" ${1})
export EP_NAME=pdc-${EP_NUM} 
export DOCTOR=${2}


# Add Endpoint to the HubDB
#
#sudo docker exec hubdb /app/endpoint_add.sh $1 | grep WriteResult


# Get ClinicID (Endpoint's MongoDB ObjectID) and provide it to Auth
#
sudo docker exec -ti auth /sbin/setuser app /app/dacs_add.sh \
        ${DOCTOR} $(sudo docker exec hubdb /app/endpoint_getClinicID.sh ${EP_NUM}) \
        ${EP_NAME} admin TEST sample
