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
OS=uname


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
