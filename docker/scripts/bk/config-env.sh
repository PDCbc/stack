#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Vagrant VM case: non-interactive apt-get, set $USER and $HOME
#
if [ -d /vagrant/ ]&&[ -d /home/vagrant ];
then
  echo "Vagrant!"
  export DEBIAN_FRONTEND=noninteractive
  USER=vagrant
  HOME=/home/vagrant
else
  echo "Not vagrant!"
fi


## Vagrant VM starts in docker folder
#
if ([ "$HOME" == "/home/vagrant" ]&&(! grep --quiet 'cd /vagrant/docker/' $HOME/.bashrc ))
then
  echo "Added!"
  (
    echo ''
    echo '# Start in docker directory'
    echo 'cd /vagrant/docker/'
  ) | tee -a $HOME/.bashrc
else
  echo "Not added!"
fi


# Configure $HOME/.bashrc
#
if(! grep --quiet 'function dockin()' $HOME/.bashrc)
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
    echo '		docker exec -it $1 /bin/bash'
    echo '	fi'
    echo '}'
  ) | tee -a $HOME/.bashrc
fi
#
if(! grep --quiet 'function reload()' $HOME/.bashrc)
then
  (
    echo ''
    echo '# Function to make container rebuilds easier'
    echo '#'
    echo 'function reload()'
    echo '{'
    echo '  if [ $# -eq 0 ]'
    echo '  then'
    echo '    echo "Please pass a docker container to destroy and recreate"'
    echo '    echo "Usage: reload [containerToReload]"'
    echo '  else'
    echo '    CONTAINER=${1%/}'
    echo '    docker rm -fv $CONTAINER'
    echo '    make build-$CONTAINER'
    echo '    make run-$CONTAINER'
    echo '  fi'
    echo '}'
  ) | tee -a $HOME/.bashrc
fi
#
if(! grep --quiet "alias c='dockin'" $HOME/.bashrc)
then
  (
    echo ''
    echo '# Aliases to frequently used functions and applications'
    echo '#'
    echo "alias c='dockin'"
    echo "alias d='docker'"
    echo "alias r='reload'"
    echo "alias l='docker logs'"
    echo "alias dc='docker-compose'"
  ) | tee -a $HOME/.bashrc
fi


# Configure $HOME/.vimrc
#
if([ ! -e $HOME/.vimrc ]||(! grep --quiet 'colorscheme delek' $HOME/.vimrc))
then
  (
    echo 'set number'
    echo 'colorscheme delek'
  ) | tee -a $HOME/.vimrc
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
                  nodejs
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


# Reminder
#
echo ""
echo "Please log in/out for changes to take effect!"
echo ""
