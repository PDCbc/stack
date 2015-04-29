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
else
  echo 'Mirrors already updated'
fi


# Update and upgrade, non-interactive
#
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y


# Create list of packages and then install
#
declare -a APPS=( linux-image-extra-$(uname -r) \
                  mongodb \
                  nodejs
                )
for a in ${APPS[@]}
do
  # suppress stdout, show errors
  (
    ( dpkg -l | grep $a )|| apt-get install -y $a
  ) 2>&1 >/dev/null

  if(! dpkg -l | grep $a )
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
    gpasswd -a vagrant docker
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
    curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  ) 2>&1 >/dev/null
  if( type -p docker-compose )
  then
    echo "Docker Compose successfully installed"
  else
    # send output to stderr (red)
    echo "ERROR: Docker Compose install failed!" >&2
  fi
fi


# Configure ~/.bashrc
#
/vagrant/docker/scripts/bash-config.sh


# Make containers
#
cd /vagrant/docker
make
