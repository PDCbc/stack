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


# Update and upgrade, non-interactive
#
sudo apt-get update
sudo apt-get upgrade -y


# Create list of packages and then install
#
declare -a APPS=( linux-image-extra-`uname -r` \
                  curl \
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


# Install the most recent version of docker (requires aufs loaded)
#
if( type -p docker )
then
  echo "Docker is already installed"
else
  # suppress stdout, show errors
  (
    modprobe aufs
    curl https://get.docker.com/ > docker_install.sh
    sudo sh docker_install.sh
    rm docker_install.sh
    gpasswd -a $USER docker
  ) 2>&1 >/dev/null

  if( type -p docker )
  then
    echo "Docker successfully installed"
  else
    # send output to stderr (red)
    echo "ERROR: Docker install failed!" >&2
  fi
fi


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
