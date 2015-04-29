#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# If running vagrant use a partiular home directory for .bashrc
#
if [ -d /vagrant/ ]&&[ -d /home/vagrant ];
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
  (
    echo ''
    echo '# Function to make nsenter easier'
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


# Start in /vagrant/, instead of $HOME/
#
if(! grep --quiet 'cd /vagrant/' $HOME/.bashrc)
then
  (
    echo ''
    echo '# Start in /vagrant/, instead of $HOME/'
    echo 'cd /vagrant/docker/'
  ) | tee -a $HOME/.bashrc
fi


# Set up $HOME/.vimrc
#
if([ ! -e $HOME/.vimrc ]||(! grep --quiet 'function dockin()' $HOME/.vimrc))
then
  (
    echo 'set number'
    echo 'colorscheme delek'
  ) | tee -a $HOME/.vimrc

fi


# Reminder to source .bashrc
#
  echo ""
  tput setaf 1
    echo "Remember to source .bashrc!"
  tput sgr0
  echo ""
  echo "Do: source "$HOME"/.bashrc"
  echo "Or: ~ "$HOME"/.bashrc"
  echo ""
