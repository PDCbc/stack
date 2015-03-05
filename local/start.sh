#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Reminder to edit the visualizer before startin
#
clear
echo ""
echo "Please remember to edit the following visualizer file:"
echo ""
echo " - visualizer/lib/middleware.js"
echo " -- 135: req.session.user.clinic    = <ENDPOINT_ID>"
echo " -- 136: req.session.user.clinician = <PHYSICIAN_ID>"
echo ""
echo ""
echo "Endpoint ID:"
echo ""
echo " - Add endpoint to the Hub's Dashboard:"
echo " -- URL: http://10.0.2.2:40000 + endpoint # {0, 1, 2}"
echo ""
echo " - From Vagrant connect with Mongo and...:"
echo " -- $ mongo --port 27019"
echo " -- > use query_composer_development"
echo " -- > db.endpoints.find().pretty()"
echo " -- "
echo "   -- Copy it from {( \"_id\": ObjectID( \"54f79d63526153bf01000005\" )}"
echo ""
echo "Physician ID:"
echo ""
echo " - Available from any impratble *.xml"
echo ""
echo "   -- Provided sample uses \"cpsid\""
echo ""
echo ""
echo "Once complete, press [Enter] to open the HubAPI and Visualizer"
read -s enterToContinue


# Start HubAPI
#
cd hubapi/
./start.sh &
cd ..


# Start Visualizer
#
cd visualizer/
./start.sh &
cd ..


# Open HubAPI and Visualizer or provide instructions on error
#

sleep 2
OS=$(uname)
if [ $OS == 'Linux' ]
then
	xdg-open https://localhost:3003
	xdg-open https://localhost:3004
else if [ $OS == 'Darwin' ]
	open https://localhost:3003
	open https://localhost:3004
else
	echo ""	
	echo "Open error.  Visit https://localhost:3003 and :3004"
	echo ""
	echo "Press [Enter] when ready"
	read -s enterToContinue
	echo ""
fi
