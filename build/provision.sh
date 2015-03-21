#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Configure yum and add GPG key
#
#yum update -y
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*


# Install Packages
#
yum remove -y vim-minimal
yum install -y sudo vim nano docker-io cmake mongodb


# Configure and start docker daemon
#
groupadd docker || true
gpasswd -a vagrant docker
systemctl enable docker
systemctl start docker


# Pass commands as vagrant user, not root
#
#su vagrant << EOF
  # Add dockin() function to .bashrc
  #
  if(! grep --quiet 'function dockin()' /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Function to make nsenter easier' | tee -a /home/vagrant/.bashrc
    echo '#' | tee -a /home/vagrant/.bashrc
    echo 'function dockin()' | tee -a /home/vagrant/.bashrc
    echo '{' | tee -a /home/vagrant/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a /home/vagrant/.bashrc
    echo '  then' | tee -a /home/vagrant/.bashrc
    echo '		echo "Please pass a docker container to enter"' | tee -a /home/vagrant/.bashrc
    echo '		echo "Usage: dockin [containerToEnter]"' | tee -a /home/vagrant/.bashrc
    echo '	else' | tee -a /home/vagrant/.bashrc
    echo '		sudo nsenter --target $(docker inspect --format {{.State.Pid}} $1) --mount --uts --ipc --net --pid /bin/bash' | tee -a /home/vagrant/.bashrc
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
#EOF


# Make containers
#
cd /vagrant/build/docker

make
