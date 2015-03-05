#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Clone or pull (update) HubAPI and Visualier
#
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
