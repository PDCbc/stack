################
# General Jobs #
################

default: configure containers

configure: config-packages config-mongodb config-bash config-img-pull

containers: hubdb hub auth dclapi hapi viz queries mode-inform

reset: destroy clone containers


#############
# Run Modes #
#############

# Show mode - development, master or production
#
mode:
	@	echo
	@	cat config.env | grep BUILD_MODE=
	@	echo
	@	echo "Set: make [ dev | master | prod ]"
	@	echo


# Switch to mode and replace clones
#
dev:
	@	$(call mode_change,dev)
#
master:
	@	$(call mode_change,master)
#
prod:
	@	$(call mode_change,prod)


#########################
# Default Container Set #
#########################

hubdb:
	sudo docker pull pdcbc/hubdb:latest
	sudo docker run -d -v /pdc/data/private/mongo_live/:/data/db/:rw -v /pdc/data/private/mongo_dump/:/data/dump/:rw --name=hubdb -h hubdb pdcbc/hubdb
	@	sudo docker exec hubdb /app/mongodb_init.sh > /dev/null


hub:
	sudo docker pull pdcbc/composer:latest
	sudo docker run -d -p 2774:22 -p 3002:3002 --link hubdb:hubdb -v /pdc/data/config/ssh/authorized_keys/:/home/autossh/.ssh/:rw -v /pdc/data/config/ssh/known_hosts/:/root/.ssh/:rw -v /pdc/data/config/ssh/ssh_keys_hub/:/etc/ssh/:rw -v /pdc/data/config/scheduled_jobs/:/app/util/scheduled_job_params:rw --name=hub -h hub --restart=always pdcbc/composer:latest


auth:
	sudo docker pull pdcbc/auth:latest
	sudo docker run -d -v /pdc/data/config/dacs/:/etc/dacs/:rw --name=auth -h auth --restart=always pdcbc/auth:latest


dclapi:
	sudo docker pull pdcbc/dclapi:latest
	sudo docker run -d --name=dclapi -h dclapi --restart=always pdcbc/dclapi:latest


hapi:
	sudo docker pull pdcbc/hapi:latest
	sudo docker run -d --link auth:auth --link hubdb:hubdb --link dclapi:dclapi --name=hapi -h hapi --restart=always pdcbc/hapi:latest


viz:
	sudo docker pull pdcbc/viz:latest
	sudo docker run -d --link auth:auth --link hapi:hapi -p 443:3004 -p 80:3008 --name=viz -h viz --restart=always pdcbc/viz:latest


queries:
	sudo docker pull pdcbc/query_importer:latest
	sudo docker run --rm --link hubdb:hubdb --name=query_importer -h query_importer pdcbc/query_importer:latest


################################
# Tools and Testing Containers #
################################

mode-inform:
	@	sudo docker ps
	@	echo
	@	echo "..."
	@	echo
	@	echo "Environment complete"
	@	echo " - mode: $(BUILD_MODE)"
	@	echo
	@	echo "Enjoy!"
	@	echo
	@	echo "..."
	@	echo


#################
# Configuration #
#################

config-packages:
	@	( which docker )|| \
			( \
				sudo apt-get update; \
				sudo apt-get install -y linux-image-extra-$$(uname -r); \
				sudo modprobe aufs; \
				wget -qO- https://get.docker.com/ | sh; \
			)


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
	@	if(! grep --quiet 'function dockin()' $${HOME}/.bashrc ); \
		then \
			( \
				echo ''; \
				echo ''; \
				echo '# Function to quickly enter containers'; \
				echo '#'; \
				echo 'function dockin()'; \
				echo '{'; \
				echo '  if [ $$# -eq 0 ]'; \
				echo '  then'; \
				echo '		echo "Please pass a docker container to enter"'; \
				echo '		echo "Usage: dockin [containerToEnter]"'; \
				echo '	else'; \
				echo '		sudo docker exec -it $$1 /bin/bash'; \
				echo '	fi'; \
				echo '}'; \
				echo ''; \
				echo '# Function to remove stopped containers and untagged images'; \
				echo '#'; \
				echo 'function dclean()'; \
				echo '{'; \
				echo '  sudo docker rm $$(sudo docker ps -a -q)'; \
				echo "  sudo docker rmi \$$(sudo docker images | grep '^<none>' | awk '{print \$$3}')"; \
				echo '}'; \
				echo ''; \
				echo '# Aliases to frequently used functions and applications'; \
				echo '#'; \
				echo "alias c='dockin'"; \
				echo "alias d='sudo docker'"; \
				echo "alias e='sudo docker exec'"; \
				echo "alias i='sudo docker inspect'"; \
				echo "alias l='sudo docker logs -f'"; \
				echo "alias p='sudo docker ps -a'"; \
				echo "alias s='sudo docker ps -a | less -S'"; \
				echo "alias dstats='sudo docker stats \$$(sudo docker ps -a -q)'"; \
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


######################
# Docker Image Pulls #
######################

config-img-pull:
	@	sudo docker pull pdcbc/hubdb:latest
	@	sudo docker pull pdcbc/composer:latest
	@	sudo docker pull pdcbc/auth:latest
	@	sudo docker pull pdcbc/dclapi:latest
	@	sudo docker pull pdcbc/hapi:latest
	@	sudo docker pull pdcbc/viz:latest
	@	sudo docker pull pdcbc/query_importer:latest


#############
# Functions #
#############

define docker_remove
	# 1=folder
	#
	( sudo docker stop $1 && sudo docker rm -v $1 ) 2> /dev/null || true
	echo
endef


define docker_build
	# 1=folder
	#
	echo
	echo "*** Building $1 *** sudo docker build -t pdc.io/$1 ./build/$1/ ***"
	echo
	sudo docker build -t pdc.io/$1 ./build/$1/
	echo
endef


define docker_run
	# 1=folder, 2=docker cmd
	#
	echo "*** Running $1 *** sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1 ***"
	echo
	sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1
	echo
endef


define dockerize
	# 1=folder, 2=docker cmd
	#
	$(call docker_remove,$1)
	$(call docker_build,$1)
	$(call docker_run,$1,$2)
	echo
	echo "*** End Dockerize $1 ***"
	echo
endef


define mode_change
	# 1=mode
	#
	if [ $(BUILD_MODE) = $1 ]; \
	then \
		echo; \
		echo "Mode unchanged"; \
		echo; \
	else \
		sudo sed -i -e "s/BUILD_MODE=.*/BUILD_MODE=$1/" config.env; \
		cat config.env | grep BUILD_MODE=; \
		$(MAKE) clone-update; \
	fi
endef


#########################
# Environment Variables #
#########################

# Source configuration file
#
include config.env


# Override branch defaults for non-production modes
#
ifneq ($(BUILD_MODE), prod)
	BRANCH_AUTH ?= $(BUILD_MODE)
	BRANCH_DCLAPI ?= $(BUILD_MODE)
	BRANCH_HAPI ?= $(BUILD_MODE)
	BRANCH_HUB ?= $(BUILD_MODE)
	BRANCH_HUBDB ?= $(BUILD_MODE)
	BRANCH_QI ?= $(BUILD_MODE)
	BRANCH_VIZ ?= $(BUILD_MODE)
endif


# Append Docker run commands for non-production modes
#
ifneq ($(BUILD_MODE), prod)
	DOCKER_AUTH_PROD += $(DOCKER_AUTH_JOIN)
	DOCKER_DCLAPI_PROD += $(DOCKER_DCLAPI_JOIN)
	DOCKER_HAPI_PROD += $(DOCKER_HAPI_JOIN)
	DOCKER_HUB_PROD += $(DOCKER_HUB_JOIN)
	DOCKER_HUBDB_PROD += $(DOCKER_HUBDB_JOIN)
	DOCKER_QI_PROD += $(DOCKER_QI_JOIN)
	DOCKER_VIZ_PROD += $(DOCKER_VIZ_JOIN)
endif
