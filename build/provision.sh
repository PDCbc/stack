#!/bin/bash
#
#


# Configure yum and add GPG key
#
yum update
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*


# Install Packages
#
yum install -y sudo docker-io cmake mongodb # tmux zsh java-1.8.0-openjdk npm lynx


# Configure and start docker daemon
#
groupadd docker
gpasswd -a vagrant docker
systemctl enable docker
systemctl start docker


# Make containers
#
cd /vagrant/build/docker
make


# Import *.xml files
#
clear
sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-0) --mount --uts --ipc --net --pid /bin/bash <<EOF
  /home/app/endpoint/util/relay-service.rb &
	sleep 1
  lynx -accept_all_cookies http://localhost:3000/records/relay
EOF

clear
sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-1) --mount --uts --ipc --net --pid /bin/bash <<EOF
  /home/app/endpoint/util/relay-service.rb &
	sleep 1
  lynx -accept_all_cookies http://localhost:3000/records/relay
EOF

clear
sudo nsenter --target $(docker inspect --format {{.State.Pid}} pdc-2) --mount --uts --ipc --net --pid /bin/bash <<EOF
  /home/app/endpoint/util/relay-service.rb &
	sleep 1
  lynx -accept_all_cookies http://localhost:3000/records/relay
EOF



# Pass commands as vagrant user, not root
#
su vagrant << EOF
  # Add dockin() function to .bashrc
  #
  if(! grep --quiet 'function dockin()' /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Function to make nsenter easier' | tee -a /home/vagrant/.bashrc
    echo '#' | tee -a /home/vagrant/.bashrc
    echo 'function dockin()' | tee -a /home/vagrant/.bashrc
    echo '{' | tee -a /home/vagrant/.bashrc
    echo '  if [ \$# -eq 0 ]' | tee -a /home/vagrant/.bashrc
    echo '  then' | tee -a /home/vagrant/.bashrc
    echo '		echo "Please pass a docker container to enter"' | tee -a /home/vagrant/.bashrc
    echo '		echo "Usage: dockin [containerToEnter]"' | tee -a /home/vagrant/.bashrc
    echo '	else' | tee -a /home/vagrant/.bashrc
    echo '		sudo nsenter --target \$(docker inspect --format {{.State.Pid}} \$1) --mount --uts --ipc --net --pid /bin/bash' | tee -a /home/vagrant/.bashrc
    echo '	fi' | tee -a /home/vagrant/.bashrc
    echo '}' | tee -a /home/vagrant/.bashrc
    echo '' | tee -a /home/vagrant/.bashrc
    echo "alias d='docker'" | tee -a /home/vagrant/.bashrc
    echo "alias c='dockin'" | tee -a /home/vagrant/.bashrc
  fi

  # Start in /vagrant/, instead of /home/vagrant/
  if(! grep --quiet 'cd /vagrant/' /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Start in /vagrant/, instead of /home/vagrant/' | tee -a /home/vagrant/.bashrc
    echo 'cd /vagrant/' | tee -a /home/vagrant/.bashrc
  fi
EOF
