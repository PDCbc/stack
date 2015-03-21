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
echo " -- 144: req.session.user.clinic    = <ENDPOINT_ID>"
echo ""
echo ""
echo "ENDPOINT_ID:"
echo ""
echo " 1. Add endpoint to the Hub's Dashboard:"
echo "    - URL: http://10.0.2.2:40000 + endpoint # {0, 1, 2}"
echo ""
echo " 2. From the command line:"
echo "    - $ mongo --port 27019"
echo "    - > use query_composer_development"
echo "    - > db.endpoints.find().pretty()"
echo ""
echo " 3. Copy the 25-digit ID:"
echo "    - in {( \"_id\": ObjectID( \"GET_ENDPOINT_ID_RIGHT_HERE\" )}"
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
	sleep 3
	xdg-open https://localhost:3004
elif [ $OS == 'Darwin' ]
then
	open https://localhost:3003
	sleep 3
	open https://localhost:3004
else
	echo ""
	echo "Open error.  Visit https://localhost:3003 and :3004"
	echo ""
	echo "Press [Enter] when ready"
	read -s enterToContinue
	echo ""
fi
