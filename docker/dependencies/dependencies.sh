#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


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
    echo ''
    echo '# Aliases to frequently used functions and applications'
    echo '#'
    echo "alias c='dockin'"
    echo "alias d='sudo docker'"
    echo "alias e='sudo docker exec'"
    echo "alias i='sudo docker inspect'"
    echo "alias l='sudo docker logs -f'"
    echo "alias p='sudo docker ps -a'"
    echo "alias r='sudo docker rm -fv'"
    echo "alias s='sudo docker ps -a | less -S'"
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
  lxc-docker
)                                  # curl lynx mongodb nodejs nodejs-legacy npm?
for a in ${APPS[@]}
do
  # Suppress stdout, show errors
  (
    ( dpkg -l | grep -w $a )|| sudo apt-get install -y $a
  ) 2>&1 >/dev/null

  if(! dpkg -l | grep -w $a )
  then
    # Send output to stderr (red)
    echo "ERROR:" $a "install failed!" >&2
  fi
done


# Reminder
#
echo ""
echo "Please log in/out for changes to take effect!"
echo ""
