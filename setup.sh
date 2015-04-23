#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Build the Vagrant box
#
vagrant up



# OS Name
#
OS=$(uname)


# Done!
#
clear
echo ""
echo "Done!"
echo ""
echo "Press [Enter] to open the Visualizer and Hub."
read -s enterToContinue
echo ""


# Open queries repo
#
sleep 2
OS=$(uname)
if [ $OS == 'Linux' ]
then
	xdg-open https://localhost:3002
	sleep 5
	xdg-open https://localhost:3004
elif [ $OS == 'Darwin' ]
then
	open https://localhost:3002
	sleep 5
	open https://localhost:3004
else
	echo ""
	echo "Open error.  Visit:"
	echo " - https://localhost:3002"
	echo " - https://localhost:3004"
fi
