#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# If running vagrant use a partiular home directory for .bashrc
#
if [ -d /vagrant/ ] && [ -d /home/vagrant ];
then
  echo "Vagrant!"
  HOME=/home/vagrant
else
  echo "Not vagrant!"
  HOME=~
fi


# Configure $HOME/.bashrc
#
if(! grep --quiet 'function dockin()' $HOME/.bashrc)
then
    echo '' | tee -a $HOME/.bashrc
    echo '# Function to make nsenter easier' | tee -a $HOME/.bashrc
    echo '#' | tee -a $HOME/.bashrc
    echo 'function dockin()' | tee -a $HOME/.bashrc
    echo '{' | tee -a $HOME/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a $HOME/.bashrc
    echo '  then' | tee -a $HOME/.bashrc
    echo '		echo "Please pass a docker container to enter"' | tee -a $HOME/.bashrc
    echo '		echo "Usage: dockin [containerToEnter]"' | tee -a $HOME/.bashrc
    echo '	else' | tee -a $HOME/.bashrc
    echo '		docker exec -it $1 /bin/bash' | tee -a $HOME/.bashrc

    echo '	fi' | tee -a $HOME/.bashrc
    echo '}' | tee -a $HOME/.bashrc
fi

if(! grep --quiet 'function reload()' $HOME/.bashrc)
then
    echo '' | tee -a $HOME/.bashrc
    echo '# Function to make container rebuilds easier' | tee -a $HOME/.bashrc
    echo '#' | tee -a $HOME/.bashrc
    echo 'function reload()' | tee -a $HOME/.bashrc
    echo '{' | tee -a $HOME/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a $HOME/.bashrc
    echo '  then' | tee -a $HOME/.bashrc
    echo '    echo "Please pass a docker container to destroy and recreate"' | tee -a $HOME/.bashrc
    echo '    echo "Usage: reload [containerToReload]"' | tee -a $HOME/.bashrc
    echo '  else' | tee -a $HOME/.bashrc
    echo '    CONTAINER=${1%/}' | tee -a $HOME/.bashrc
    echo '    docker rm -fv $CONTAINER' | tee -a $HOME/.bashrc
    echo '    make build-$CONTAINER' | tee -a $HOME/.bashrc
    echo '    make run-$CONTAINER' | tee -a $HOME/.bashrc
    echo '  fi' | tee -a $HOME/.bashrc
    echo '}' | tee -a $HOME/.bashrc
fi

if(! grep --quiet "alias c='dockin'" $HOME/.bashrc)
then
    echo '' | tee -a $HOME/.bashrc
    echo '# Aliases to frequently used functions and applications' | tee -a $HOME/.bashrc
    echo '#' | tee -a $HOME/.bashrc
    echo "alias c='dockin'" | tee -a $HOME/.bashrc
    echo "alias d='docker'" | tee -a $HOME/.bashrc
    echo "alias r='reload'" | tee -a $HOME/.bashrc
    echo "alias l='docker logs'" | tee -a $HOME/.bashrc
    echo "alias dc='docker-compose'" | tee -a $HOME/.bashrc
fi


# Start in /vagrant/, instead of $HOME/
#
if(! grep --quiet 'cd /vagrant/' $HOME/.bashrc)
then
    echo '' | tee -a $HOME/.bashrc
    echo '# Start in /vagrant/, instead of $HOME/' | tee -a $HOME/.bashrc
    echo 'cd /vagrant/docker/' | tee -a $HOME/.bashrc
fi


# Set up $HOME/.vimrc
#
if([ ! -e $HOME/.vimrc ]||(! grep --quiet 'function dockin()' $HOME/.vimrc))
then
    echo 'set number' | tee -a $HOME/.vimrc
    echo 'colorscheme delek' | tee -a $HOME/.vimrc
fi
