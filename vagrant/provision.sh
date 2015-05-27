#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Vagrant VM starts in docker folder
#
if (! grep --quiet 'cd /vagrant/docker/' /home/vagrant/.bashrc )
then
  (
    echo ''
    echo '# Start in docker directory'
    echo '#'
    echo 'cd /vagrant/docker/'
  ) | tee -a /home/vagrant/.bashrc
else
  echo "~/.bashrc already configured"
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
(
  apt-get upgrade -y
  apt-get dist-upgrade -y
  apt-get install -f
  apt-get autoremove
) 2>&1 >/dev/null


# Provision uses root, but we want to configure Vagrant's settings
#
export HOME=/home/vagrant
cd /vagrant/docker
make all
