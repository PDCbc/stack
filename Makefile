################
# General Jobs #
################

default: configure prod

configure: config-packages config-mongodb config-bash


###################
# Individual jobs #
###################

prod:
	@ $(call deploy,prod)

master:
	@ $(call deploy,latest)

dev:
	@ $(call deploy,dev)

local:
	@ [ -s ./dev/build.yml ]|| \
		sudo cp ./dev/build.yml-sample ./dev/build.yml
	@ $(call deploy,prod,-f docker-compose.yml -f ./dev/build.yml)

clean:
	@ sudo docker rm $$( sudo docker ps -a -q ) || true
	@ sudo docker rmi $$( sudo docker images | grep '^<none>' | awk '{print $$3}' )

queries:
	@ sudo docker-compose start query_importer


#################
# Configuration #
#################

# Deploy prod, master, dev or local
#
define deploy
		# 1=TAG (required)
		# 2=2ndary .YML file (optional)
		#
		echo sudo TAG=$1 docker-compose $2 pull
		sudo TAG=$1 docker-compose $2 pull
		sudo TAG=$1 docker-compose $2 build
		sudo TAG=$1 docker-compose $2 stop
		sudo TAG=$1 docker-compose $2 rm -f
		sudo TAG=$1 docker-compose $2 up -d
endef


#################
# Configuration #
#################

config-packages:
	@	sudo apt-get update
	@	sudo apt-get install -y \
			linux-image-extra-$$(uname -r) \
			curl
	@	sudo modprobe aufs
	@	wget -qO- https://get.docker.com/ | sh
	@ sudo curl -o /usr/local/bin/docker-compose -L \
			https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m`
	@ sudo chmod +x /usr/local/bin/docker-compose


config-mongodb:
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled )> /dev/null
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag )> /dev/null
	@	if(! grep --quiet 'never > /sys/kernel/mm/transparent_hugepage/enabled' /etc/rc.local ); \
		then \
			sudo sed -i '/exit 0/d' /etc/rc.local; \
			( \
				echo ''; \
				echo '# Disable Transparent Hugepage, for Mongo'; \
				echo '#'; \
				echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'; \
				echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'; \
				echo ''; \
				echo 'exit 0'; \
			) | sudo tee -a /etc/rc.local; \
		fi; \
		sudo chmod 755 /etc/rc.local


config-bash:
	@	if(! grep --quiet 'function dclean()' $${HOME}/.bashrc ); \
		then \
			( \
				echo ""; \
				echo "# Function to quickly enter containers"; \
				echo "#"; \
				echo "function c()"; \
				echo "{"; \
				echo "	sudo docker exec -it \$$1 /bin/bash"; \
				echo "}"; \
				echo ""; \
				echo "# Function to remove stopped containers and untagged images"; \
				echo "#"; \
				echo "function dclean()"; \
				echo "{"; \
				echo "  sudo docker rm \$$( sudo docker ps -a -q )"; \
				echo "  sudo docker rmi \$$( sudo docker images | grep '^<none>' | awk '{print \$$3}' )"; \
				echo "}"; \
				echo ""; \
				echo "# Function to enter a PDC managed Endpoint"; \
				echo "#"; \
				echo "function ep-in()"; \
				echo "{"; \
				echo "	sudo docker exec -it composer ssh -p \$$( expr 44000 + \$$1 ) pdcadmin@localhost"; \
				echo "}"; \
				echo ""; \
				echo "# Aliases to frequently used functions and applications"; \
				echo "#"; \
				echo "alias d='sudo docker'"; \
				echo "alias dc='sudo docker-compose'"; \
				echo "alias i='sudo docker inspect'"; \
				echo "alias l='sudo docker logs -f'"; \
				echo "alias p='sudo docker ps -a'"; \
				echo "alias s='sudo docker ps -a | less -S'"; \
				echo "alias dstats='sudo docker stats \$$( sudo docker ps -a -q )'"; \
			) | tee -a $${HOME}/.bashrc; \
			echo ""; \
			echo ""; \
			echo "Please log in/out for changes to take effect!"; \
			echo ""; \
		fi


config-backups:
	# Add repository, install owncloud cmd client and run cronjobs for infrastructure and MongoDB data
	#
	@	echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/xUbuntu_14.04/ /' \
			| sudo tee /etc/apt/sources.list.d/owncloud-client.list
	@	wget -qO- http://download.opensuse.org/repositories/isv:ownCloud:desktop/xUbuntu_14.04/Release.key \
			| sudo apt-key add -
	@	sudo apt-get update
	@	sudo apt-get install -y owncloud-client

	@	# Create backup script, if necessary
	@	#
		if [ ! -e ${PATH_HOST}/oc_backup.sh ]; \
		then \
			echo; \
			echo "Please configure ownCloud"; \
			echo; \
			echo "Server:"; \
			read OWNCLOUD_URL; \
			echo "User name:"; \
			read OWNCLOUD_ID; \
			echo "Password:"; \
			read OWNCLOUD_PW; \
			echo; \
			( \
				echo '#!/bin/bash'; \
				echo '#'; \
				echo '# Backup script for ownCloud - run from the data dir!'; \
				echo '#'; \
				echo '# Exit on errors or unitialized variables'; \
				echo 'set -e -o nounset'; \
				echo ''; \
				echo ''; \
				echo '# Change to script directory'; \
				echo '#'; \
				echo 'SCRIPT_DIR=$$( cd $$( dirname $${BASH_SOURCE[0]} ) && pwd )'; \
				echo 'cd $${SCRIPT_DIR}'; \
				echo ''; \
				echo ''; \
				echo '# Copy non-sensitive MongoDB dumps to ./mongo_partial/'; \
				echo '#'; \
				echo 'SOURCE_DUMP=$${SCRIPT_DIR}/private/mongo_dump/query_composer_development'; \
				echo 'DESTINATION_DUMP=$${SCRIPT_DIR}/config/mongo_partial'; \
				echo 'sudo mkdir -p $${DESTINATION_DUMP}'; \
				echo '#'; \
				echo 'for FILES in \'; \
				echo '	delayed* \'; \
				echo '	endpoints* \'; \
				echo '	system* \'; \
				echo '	users*;'; \
				echo 'do'; \
				echo '	sudo cp $${SOURCE_DUMP}/$${FILES} $${DESTINATION_DUMP}'; \
				echo 'done'; \
				echo ''; \
				echo ''; \
				echo '# Backup config folder to ownCloud'; \
				echo '#'; \
				echo 'USERNAME='$${OWNCLOUD_ID}; \
				echo 'PASSWORD='$${OWNCLOUD_PW}; \
				echo 'OWNCLOUD='$${OWNCLOUD_URL}; \
				echo '#'; \
				echo 'WEBDAV=https://$${OWNCLOUD}/owncloud/remote.php/webdav'; \
				echo '#'; \
				echo 'SOURCE_BACKUP=config'; \
				echo 'DESTINATION_BACKUP=$${WEBDAV}/stack/$${SOURCE_BACKUP}'; \
				echo '#'; \
				echo 'sudo owncloudcmd -u $${USERNAME} -p $${PASSWORD} $${SOURCE_BACKUP} $${DESTINATION_BACKUP}'; \
			) | sudo tee -a \${PATH_HOST}/oc_backup.sh; \
			sudo chmod 700 \${PATH_HOST}/oc_backup.sh; \
		fi


	@	# Add script to cron
	@	#
	@	if((! sudo test -e /var/spool/cron/crontabs/root )||(! sudo grep --quiet 'oc_backup.sh' /var/spool/cron/crontabs/root )); \
		then \
		  ( \
		    echo ''; \
		    echo ''; \
		    echo '# Backup to ownCloud every 30 minutes'; \
		    echo '#'; \
		    echo '0,30 * * * * $\${PATH_HOST}/oc_backup.sh'; \
		    echo ''; \
		    echo ''; \
		    echo '# Dump MongoDB nightly for UVic backup'; \
		    echo '#'; \
		    echo '15 1 * * * sudo docker exec hubdb /app/mongodb_dump.sh'; \
		  ) | sudo tee -a /var/spool/cron/crontabs/root; \
		fi
