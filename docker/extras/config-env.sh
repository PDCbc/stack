#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Vagrant VM case: provision uses root, but we access it as vagrant
#
if [ -d /vagrant/ ]&&[ -d /home/vagrant ]
then
  echo "Vagrant!"
  export DEBIAN_FRONTEND=noninteractive
  USER=vagrant
  HOME=/home/vagrant
fi


## Vagrant VM starts in docker folder
#
if ([ "$HOME" == "/home/vagrant" ]&&(! grep --quiet 'cd /vagrant/docker/' $HOME/.bashrc ))
then
  (
    echo ''
    echo '# Start in docker directory'
    echo 'cd /vagrant/docker/'
  ) | tee -a $HOME/.bashrc
fi


# Configure $HOME/.bashrc
#
if(! grep --quiet 'function dockin()' $HOME/.bashrc )
then
  (
    echo ''
    echo '# Function to quickly enter containers'
    echo '#'
    echo 'function dockin()'
    echo '{'
    echo '  if [ $# -eq 0 ]'
    echo '  then'
    echo '		echo "Please pass a docker container to enter"'
    echo '		echo "Usage: dockin [containerToEnter]"'
    echo '	else'
    echo '		sudo docker exec -it $1 /bin/bash'
    echo '	fi'
    echo '}'
  ) | tee -a $HOME/.bashrc
fi

if(! grep --quiet "alias c='dockin'" $HOME/.bashrc )
then
  (
    echo ''
    echo '# Aliases to frequently used functions and applications'
    echo '#'
    echo "alias c='dockin'"
    echo "alias d='sudo docker'"
    echo "alias l='sudo docker logs -f'"
    echo "alias drm='sudo docker rm -fv'"
    echo "alias dless='sudo docker ps | less -S'"
    echo "alias dc='sudo docker-compose'"
    echo "alias m='make'"
  ) | tee -a $HOME/.bashrc
fi


# Configure $HOME/.vimrc
#
if([ ! -e $HOME/.vimrc ]||(! grep --quiet 'colorscheme delek' $HOME/.vimrc ))
then
  (
    echo 'set number'
    echo 'colorscheme delek'
  ) | tee -a $HOME/.vimrc
fi


# Install Docker PPA and key
#
if([ ! -f /etc/apt/sources.list.d/docker.list ]||(! grep --quiet 'https://get.docker.io/ubuntu' /etc/apt/sources.list.d/docker.list ))
then
  (
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  ) 2>&1 >/dev/null
  sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
fi


# Update and upgrade, non-interactive
#
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y


# Create list of packages and then install
#
declare -a APPS=(
  linux-image-extra-`uname -r` \
  curl \
  lxc-docker \
  lynx \
  mongodb \
  nodejs \
  nodejs-legacy \
  npm
)
for a in ${APPS[@]}
do
  # suppress stdout, show errors
  (
    ( dpkg -l | grep -w $a )|| sudo apt-get install -y $a
  ) 2>&1 >/dev/null

  if(! dpkg -l | grep -w $a )
  then
    # send output to stderr (red)
    echo "ERROR:" $a "install failed!" >&2
  fi
done


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


## Create container backup folder
#
mkdir -p $HOME/env-data/
mkdir -p $HOME/env-data/dacs/
mkdir -p $HOME/env-data/hub/
mkdir -p $HOME/env-data/mdr/


# Reminder
#
echo ""
echo "Please log in/out for changes to take effect!"
echo ""
