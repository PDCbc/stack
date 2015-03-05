#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Build the Vagrant box
#
vagrant up || vagrant provision


# Clone or pull (update) HubAPI and Visualier
#
cd local
./initialize.sh
cd ..


# Prompt for and create Hub admin account
#
clear
echo ""
echo "Sign up with hQuery, taking note of the user name,"
echo "then return to this script/window"
echo ""
echo "Please accept/bypass SSL errors for localhost"
echo ""
echo "Press [Enter] when ready"
read -s enterToContinue
echo ""


# Open the sign up page or provide instruction on error
#
sleep 2
OS=$(uname)
if [ $OS == 'Linux' ]
then
	xdg-open https://localhost:3002/users/sign_up
else if [ $OS == 'Darwin' ]
	open https://localhost:3002/users/sign_up
else
	echo ""	
	echo "Open error.  Visit https://localhost:3002/users/sign_up"
	echo ""
	echo "Press [Enter] when ready"
	read -s enterToContinue
	echo ""
fi


# Grand hub admin access and import *.xml files into pdc-0, pdc-1 and pdc-2
#
cd build/scripts
./grant-admin.sh
./import-xml.sh
cd ../..


# Open the hub or provide instruction on error
#
sleep 2
if [ $OS == 'Linux' ]
then
	xdg-open https://localhost:3002
else if [ $OS == 'Darwin' ]
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
./initialize.sh
./start.sh
cd ..


# Done!
#
clear
echo ""
echo "Done!"
echo ""
