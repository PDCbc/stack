#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Add endpoints to mongo
#
mongo query_composer_development --port 27019 --eval 'db.endpoints.insert({"name":"ep-0", "base_url":"http://10.0.2.2:40000"})'
mongo query_composer_development --port 27019 --eval 'db.endpoints.insert({"name":"ep-1", "base_url":"http://10.0.2.2:40001"})'
mongo query_composer_development --port 27019 --eval 'db.endpoints.insert({"name":"ep-2", "base_url":"http://10.0.2.2:40002"})'


# Import *.xml files
#
cd ../..

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-0) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
	sleep 2
  lynx -accept_all_cookies http://localhost:3000/records/relay
EOF

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-1) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
  sleep 2
  lynx -accept_all_cookies http://localhost:3000/records/relay
EOF

sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-2) --mount --uts --ipc --net --pid /bin/bash <<EOF
  cd /home/app/endpoint/util/
  ./relay-service.rb &
	sleep 2
  lynx -accept_all_cookies http://localhost:3000/records/relay
EOF
