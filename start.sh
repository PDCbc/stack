#/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Create ~/vagrant/ folder and copy files in
# This prevents using sensitive data in a folder that could be pushed to GitHub
# 
mkdir -p ~/vagrant/
cp README.md ~/vagrant/
cp -r dirs/* ~/vagrant/
cp builds/* ~/vagrant/


# Echo log and monit status, coloured red
#
echo ""
echo "Your Vagrant build environment is ready in ~/vagrant/"
echo "Enjoy!"
echo ""
