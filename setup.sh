#/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


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


# Open the sign up page
#
open https://localhost:3002/users/sign_up


# Grant admin access
#
vagrant ssh -c '
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


# Clear the contents of ./endpoint/import! (Might change to delete)
#
mkdir -p ~/Desktop/pdc-env-import
mv ./build/docker/endpoint/import/*.xml ~/Desktop/pdc-env-import || true
mv ./build/docker/endpoint/import/*.zip ~/Desktop/pdc-env-import || true
#
echo "Done!"
echo ""
echo "Please be aware that any endpoint import files (*.zip, *.xml)"
echo "have been moved to your desktop"
