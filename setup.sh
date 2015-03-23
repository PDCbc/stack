#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Build the Vagrant box
#
vagrant up


# Create PDC Admin account
#
mongo query_composer_development --port 27019 --eval 'db.users.insert({
	"first_name" : "PDC",
	"last_name" : "Admin",
	"username" : "pdcadmin",
	"email" : "pdcadmin@pdc.io",
	"encrypted_password" : "$2a$10$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.",
	"agree_license" : true,
	"approved" : true,
	"admin" : true,
})'


# Grand hub admin access and import *.xml files into pdc-0, pdc-1 and pdc-2
#
cd build/scripts
./configure-hub.sh
./import-xml.sh
cd ../..


# Open the hub or provide instruction on error
#
sleep 2
if [ $OS == 'Linux' ]
then
	xdg-open https://localhost:3002
elif [ $OS == 'Darwin' ]
then
	open https://localhost:3002
else
	echo ""
	echo "Open error.  Visit https://localhost:3002"
	echo ""
	echo "Press [Enter] when ready"
	read -s enterToContinue
	echo ""
fi


# Start HubAPI and Visualizer in the background
#
cd local
./start.sh
cd ..


# Done!
#
clear
echo ""
echo "Done!"
echo ""
echo "Why not try out one of our queries from https://github.com/PhyDaC/queries?"
echo ""
echo "Press [Enter] when ready"
read -s enterToContinue
echo ""


# Open queries repo
#
sleep 2
OS=$(uname)
if [ $OS == 'Linux' ]
then
	xdg-open https://github.com/PhyDaC/queries
elif [ $OS == 'Darwin' ]
then
else
	echo ""
	echo "Open error.  Visit https://github.com/PhyDaC/queries"
	echo ""
	echo "Press [Enter] when ready"
	read -s enterToContinue
	echo ""
fi
