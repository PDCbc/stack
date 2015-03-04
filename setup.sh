#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e


# Build the Vagrant box
#
vagrant up


# Clone or pull (update) HubAPI and Visualier
#
cd local/

if [ -d hubapi/ ]
then
	git -C hubapi pull
else
	git clone https://github.com/phydac/hubapi
fi

if [ -d visualizer/ ]
then
	git -C visualizer pull
else
	git clone https://github.com/phydac/hubapi
fi

cd ..


# Prompt for creation of Hub admin account
#
# Signup message and SSL note here
#
sleep 2
echo ""
echo "Sign up with hQuery, taking note of the user name,"
echo "then return to this script/window"
echo ""
echo "Please accept/bypass SSL errors for localhost"
echo ""
echo "Press [Enter] when ready"
read -s enterToContinue
echo ""


# Open the sign up page
#
sleep 2
open https://localhost:3002/users/sign_up


# Grand hub admin access and import *.xml files into pdc-0, pdc-1 and pdc-2
#
cd build
./initialize.sh
cd ..


# Open the hub and endpoints
#
open https://localhost:3002
sleep 2
open http://localhost:40000
sleep 2
open http://localhost:40001
sleep 2
open http://localhost:40002


# OS X: Start HubAPI and Visualizer in the background
#
cd local
start.sh
cd ..


# Done!
#
clear
echo ""
echo "Done!"
echo ""
