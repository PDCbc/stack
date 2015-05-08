#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Vagrant 4.3.?? Bug
# https://github.com/mitchellh/vagrant/issues/3341
#
if [ ! -L /usr/lib/VBoxGuestAdditions ]
then
  ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
else
  echo "Symbolic link already exists."
fi


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


# Makefile installs packages, configures .bashrc and handles containers
#
cd /vagrant/docker
make
