#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Pick fastest mirrors
#
if(! grep --quiet 'mirror://mirrors' /etc/apt/sources.list )
then
  (
    echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse'; \
    echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse'; \
    echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse'; \
    echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse'
  ) | tee /etc/apt/sources.list
  # ; \
  # cat /etc/apt/sources.list
else
  echo 'Mirrors already updated'
fi


# Update and upgrade
#
apt-get update
apt-get upgrade -y


# Install packages


# Install updated kernel extra modules (incl. aufs)
#
dpkg -l | grep linux-image-extra-$(uname -r) || apt-get install -y linux-image-extra-$(uname -r)


# Install apps
#
(type -p mongo  )|| apt-get install -y mongodb
(type -p nodejs )|| apt-get install -y nodejs


# Install the most recent version of docker (requires aufs loaded)
#
if( type -p docker )
then
 echo "Docker is already installed"
else
 modprobe aufs
 curl https://get.docker.com/ > docker_install.sh
 sudo sh docker_install.sh
 gpasswd -a vagrant docker
fi


# Install docker-compose
#
if( type -p docker-compose )
then
 echo "Docker Compose is already installed"
else
 curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
 chmod +x /usr/local/bin/docker-compose
fi


# Configure ~/.bashrc
#
/vagrant/docker/scripts/docker-bash.sh


# Make containers
#
cd /vagrant/docker
make
