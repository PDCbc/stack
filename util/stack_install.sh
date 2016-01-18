#!/bin/bash
#
set -e -o nounset


# Set variables
#
TAG=${TAG:-""}
MODE=${MODE:-""}


# Prompt for build type
#
echo
echo
echo "This will stop and rebuild the Stack."
echo
echo "prod  = production deployment."
echo "dev   = development deployment."
echo "build = hybrid deployment, adds local folders specified in dev.yml."
echo
echo "Please enter a build type, as above, or anything else to cancel."
read PROMPT
echo


# Set build details
#
if [ "${PROMPT}" = "prod" ]
then
  TAG=latest
  MODE=prod
elif [ "${PROMPT}" = "dev" ]
then
  TAG=dev
  MODE=prod
elif [ "${PROMPT}" = "build" ]
then
  TAG=dev
  MODE=dev
else
  echo "No build mode specified.  Exiting."
  exit
fi


# Deploy
#
cd ..
TAG=${TAG} MODE=${MODE} make deploy
