#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Configure ~/.bashrc
#
if(! grep --quiet 'function dockin()' ~/.bashrc)
then
    echo '' | tee -a ~/.bashrc
    echo '# Function to make nsenter easier' | tee -a ~/.bashrc
    echo '#' | tee -a ~/.bashrc
    echo 'function dockin()' | tee -a ~/.bashrc
    echo '{' | tee -a ~/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a ~/.bashrc
    echo '  then' | tee -a ~/.bashrc
    echo '		echo "Please pass a docker container to enter"' | tee -a ~/.bashrc
    echo '		echo "Usage: dockin [containerToEnter]"' | tee -a ~/.bashrc
    echo '	else' | tee -a ~/.bashrc
    echo '		docker exec -it $1 /bin/bash' | tee -a ~/.bashrc

    echo '	fi' | tee -a ~/.bashrc
    echo '}' | tee -a ~/.bashrc
fi

if(! grep --quiet 'function reload()' ~/.bashrc)
then
    echo '' | tee -a ~/.bashrc
    echo '# Function to make container rebuilds easier' | tee -a ~/.bashrc
    echo '#' | tee -a ~/.bashrc
    echo 'function reload()' | tee -a ~/.bashrc
    echo '{' | tee -a ~/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a ~/.bashrc
    echo '  then' | tee -a ~/.bashrc
    echo '    echo "Please pass a docker container to destroy and recreate"' | tee -a ~/.bashrc
    echo '    echo "Usage: reload [containerToReload]"' | tee -a ~/.bashrc
    echo '  else' | tee -a ~/.bashrc
    echo '    CONTAINER=${1%/}' | tee -a ~/.bashrc
    echo '    docker rm -fv $CONTAINER' | tee -a ~/.bashrc
    echo '    make build-$CONTAINER' | tee -a ~/.bashrc
    echo '    make run-$CONTAINER' | tee -a ~/.bashrc
    echo '  fi' | tee -a ~/.bashrc
    echo '}' | tee -a ~/.bashrc
fi

if(! grep --quiet "alias c='dockin'" ~/.bashrc)
then
    echo '' | tee -a ~/.bashrc
    echo '# Aliases to frequently used functions and applications' | tee -a ~/.bashrc
    echo '#' | tee -a ~/.bashrc
    echo "alias c='dockin'" | tee -a ~/.bashrc
    echo "alias d='docker'" | tee -a ~/.bashrc
    echo "alias r='reload'" | tee -a ~/.bashrc
    echo "alias l='docker logs'" | tee -a ~/.bashrc
    echo "alias dc='docker-compose'" | tee -a ~/.bashrc
fi

# Start in /vagrant/, instead of ~/
if(! grep --quiet 'cd /vagrant/' ~/.bashrc)
then
    echo '' | tee -a ~/.bashrc
    echo '# Start in /vagrant/, instead of ~/' | tee -a ~/.bashrc
    echo 'cd /vagrant/docker/' | tee -a ~/.bashrc
fi


# Set up ~/.vimrc
#
if(! grep --quiet 'function dockin()' /home/vagrant/.vimrc) then
    echo 'set number' | tee -a /home/vagrant/.vimrc
    echo 'colorscheme delek' | tee -a /home/vagrant/.vimrc
fi
