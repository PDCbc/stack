#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Tell Ubuntu not to use tty
#
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile


# Update and install
apt-get update
apt-get install -y sudo vim nano node cmake mongodb wget


# Install the most recent version of docker
#
curl https://get.docker.com/ > docker_install.sh
sudo sh docker_install.sh


# Install docker-compose
#
curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# Configure and start docker daemon
#
groupadd docker || true
gpasswd -a vagrant docker


# Configure ~/.bashrc
#
../docker/scripts/docker-bash.sh


# Make containers
#
cd /vagrant/docker
make
