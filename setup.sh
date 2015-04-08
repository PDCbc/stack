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
echo "Press [Enter] to open the Visualizer, the Hub and our queries on GitHub."
read -s enterToContinue
echo ""


# Open queries repo
#
sleep 2
OS=$(uname)
if [ $OS == 'Linux' ]
then
	xdg-open https://github.com/PhysiciansDataCollaborative/queries
	xdg-open https://localhost:3002
	xdg-open https://localhost:3004
elif [ $OS == 'Darwin' ]
then
	open https://github.com/PhysiciansDataCollaborative/queries
	open https://localhost:3002
	open https://localhost:3004
else
	echo ""
	echo "Open error.  Visit:"
	echo " - https://github.com/PhysiciansDataCollaborative/queries"
	echo " - https://localhost:3002"
	echo " - https://localhost:3004"
fi
