#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -x -o nounset


# Import *.xml files
#
cd ../..

vagrant ssh -c '
sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-0) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
	sleep 2
  lynx -accept_all_cookies http://localhost:3000/records/relay
	hostname; pwd
EOF

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-1) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
  sleep 2
  lynx -accept_all_cookies http://localhost:3000/records/relay
	hostname; pwd
EOF

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-2) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
	sleep 2
  lynx -accept_all_cookies http://localhost:3000/records/relay
	hostname; pwd
EOF
'
