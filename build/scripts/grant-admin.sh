#!/bin/bash
#


# Grant admin access on hub
#
cd ..
vagrant ssh -c '
	echo ""
  echo "Admin user name:"
  read userName
  echo "Vagrant received $userName"
	sudo nsenter --target $(docker inspect --format {{.State.Pid}} hub) --mount --uts --ipc --net --pid /bin/bash <<EOF
	echo "Container received $userName"
	cd /home/app/hub
	/usr/local/bin/bundle exec rake hquery:users:grant_admin USER_ID=$userName
EOF
'
