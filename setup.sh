#/bin/bash
#
# Exit on errors or unitialized variables
#
set -e


# Build the Vagrant box
#
vagrant up


# Prompt for creation of Hub admin account
#
# Signup message and SSL note here
#
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


# Grant admin access
#
vagrant ssh -c '
	clear
	echo "Welcome back!"
	echo ""
  echo "User name:"
  read userName
  echo "Vagrant received $userName"
	sudo nsenter --target $(docker inspect --format {{.State.Pid}} hub) --mount --uts --ipc --net --pid /bin/bash <<EOF
	echo "Container received $userName"
	cd /home/app/hub
	/usr/local/bin/bundle exec rake hquery:users:grant_admin USER_ID=$userName
EOF
'


# Open the hub and endpoints
#
open https://localhost:3002
sleep 2
open http://localhost:40000
sleep 2
open http://localhost:40001
sleep 2
open http://localhost:40002
sleep 2


# Clone HubAPI and Visualier (or pull them)
#
# NOT WRITTEN YET!


# VAGRANT: Start HubAPI and Visualizer in the background
#
#vagrant ssh -c '
#	cd /vagrant/local/
#	./background-startups.sh
#'


# OS X: Start HubAPI and Visualizer in the background
#
cd local
./background-startups.sh


# Done!
#
clear
echo ""
echo "Done!"
echo ""


# Post install
# Endpoints load *.xml files with ./relay-thing.sh & lynx -accept_all_cookies http://localhost:3000/records/relay
