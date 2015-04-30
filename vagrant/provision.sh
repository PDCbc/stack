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


# Makefile installs packages, configures .bashrc and handles containers
#
cd /vagrant/docker
make environment
make
