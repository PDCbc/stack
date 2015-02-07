#!/bin/bash

PUBKEY=$(sudo nsenter --target $(docker inspect --format {{.State.Pid}} endpoint) --mount --uts --ipc --net --pid cat /root/.ssh/id_rsa.pub)
sudo nsenter --target $(docker inspect --format {{.State.Pid}} endpoint) --mount --uts --ipc --net --pid /bin/bash <<EOF
	sed -i -e "s/REMOTE_ACCESS_PORT=13001/REMOTE_ACCESS_PORT=13001/" /etc/service/endpoint_tunnel/run
EOF
sudo nsenter --target $(docker inspect --format {{.State.Pid}} hub) --mount --uts --ipc --net --pid /bin/bash <<EOF
	mkdir -p /home/autossh/.ssh
	echo -e $PUBKEY >> /home/autossh/.ssh/authorized_keys
EOF
# TODO: More professional.
PUBKEY=" "
