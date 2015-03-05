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
open https://localhost:3002/users/sign_up
sleep 2


# Grand hub admin access and import *.xml files into pdc-0, pdc-1 and pdc-2
#
cd build/scripts
./grant-admin.sh
./import-xml.sh
cd ../..


# Open the hub and endpoints
#
sleep 2
open http://localhost:40000
open http://localhost:40001
open http://localhost:40002
sleep 1
open https://localhost:3002


# OS X: Start HubAPI and Visualizer in the background
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
