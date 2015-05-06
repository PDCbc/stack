#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Vagrant VM case: non-interactive apt-get, set user=vagrant
#
if [ -d /vagrant/ ]&&[ -d /home/vagrant ];
then
  echo "Vagrant!"
  export DEBIAN_FRONTEND=noninteractive
  USER=vagrant
else
  echo "Not vagrant!"
fi


# Install Docker PPA and key
#
if(! grep --quiet 'https://get.docker.io/ubuntu' /etc/apt/sources.list.d/docker.list )
then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
fi


# Update and upgrade, non-interactive
#
sudo apt-get update
sudo apt-get upgrade -y


# Create list of packages and then install
#
declare -a APPS=( linux-image-extra-`uname -r` \
                  curl \
                  lxc-docker \
                  mongodb \
                  nodejs \
                  npm
                )
for a in ${APPS[@]}
do
  # suppress stdout, show errors
  (
#    ( dpkg -l | grep $a )|| sudo apt-get install -y $a
    ( dpkg -l | grep -w $a )|| sudo apt-get install -y $a
  ) 2>&1 >/dev/null

  if(! dpkg -l | grep -w $a )
  then
    # send output to stderr (red)
    echo "ERROR:" $a "install failed!" >&2
  fi
done


# Docker post-install configuration
#
gpasswd -a $USER docker
#sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker


# Install docker-compose
#
if( type -p docker-compose )
then
  echo "Docker Compose is already installed"
else
  # suppress stdout, show errors
  (
    sudo curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  ) 2>&1 >/dev/null
  if( type -p docker-compose )
  then
    echo "Docker Compose successfully installed"
  else
    # send output to stderr (red)
    echo "ERROR: Docker Compose install failed!" >&2
  fi
fi
