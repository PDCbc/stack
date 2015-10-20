#!/bin/bash
#
# Exit on errors or uninitialized variables
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Doctor IDs (separated by commas)


# Check parameters
#
if [ $# -ne 1 ]
then
        echo ""
        echo "Unexpected number of parameters."
        echo ""
        echo "Usage: provider_add.sh [docID #1],[docID #2],...,[docID #n]"
        echo ""
        exit
fi


# Stub - just repeat back the parameters
#
echo
echo
echo $1
echo
echo

