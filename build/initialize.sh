#!/bin/bash
#


# Grant admin access on hub
#
cd ..
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

# Import *.xml files
#
vagrant ssh -c '
sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-0) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
	sleep 1
  lynx -accept_all_cookies http://localhost:3000
EOF

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-1) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
  sleep 1
  lynx -accept_all_cookies http://localhost:3000
EOF

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-2) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
	sleep 1
  lynx -accept_all_cookies http://localhost:3000
EOF
'
