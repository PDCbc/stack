################
# General Jobs #
################

default: configure clone containers

configure: config-packages config-mongodb config-bash config-img-pull

clone: clone-auth clone-dclapi clone-hubdb clone-hub clone-hapi clone-viz clone-queries clone-endpoint

containers: clone hubdb hub auth dclapi hapi viz queries ep-sample mode-inform

clone-update: say-goodbye clone-remove clone

destroy: say-goodbye clone-remove containers-remove

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
	@	sudo mkdir -p $(PATH_MONGO_DB) $(PATH_MONGO_DUMP)
	@	$(call dockerize,hubdb,$(DOCKER_HUBDB_PROD))
	@	sudo docker exec hubdb /app/mongodb_init.sh > /dev/null


hub:
	@	sudo mkdir -p $(PATH_HUB_AUTHKEYS) $(PATH_HUB_AUTOSSH)
	@	$(call dockerize,hub,$(DOCKER_HUB_PROD))


auth:
	@	sudo mkdir -p $(PATH_DACS)
	@	$(call dockerize,auth,$(DOCKER_AUTH_PROD))


dclapi:
	@	sudo mkdir -p $(PATH_DRUGREF)
	@	$(call dockerize,dclapi,$(DOCKER_DCLAPI_PROD))


hapi:
	@	$(call dockerize,hapi,$(DOCKER_HAPI_PROD))


viz:
	@	sudo mkdir -p $(PATH_CERT)
	@	$(call dockerize,viz,$(DOCKER_VIZ_PROD))


ep-sample:
	@	sudo mkdir -p $(PATH_EPX_AUTOSSH)
	@	$(call dockerize,endpoint,$(DOCKER_ENDPOINT_PROD),0)
	@	$(call config_ep,0,cpsid,cpsid,admin,TEST,sample)


queries:
	@	$(call dockerize,queries,$(DOCKER_QI_PROD))
	@	sudo docker logs -f queries
	@	$(call docker_remove,queries)


containers-remove:
	@	( sudo docker stop `sudo docker ps -q` )&&( sudo docker rm `sudo docker ps -a -q` )|| \
			echo "No containers to delete"


################################
# Tools and Testing Containers #
################################

ep:
	@	sudo mkdir -p $(PATH_EPX_AUTOSSH)
	@	if [ -z "$(gID)" ] || [ -z "$(DOCTOR)" ]; \
		then \
			echo; \
			echo "Create an Endpoint and Auth ID"; \
			echo "Usage: make ep [gID=#] [DOCTOR=#####] [op:JURISDUCTION] [op:ROLE] [op:PASSWORD]"; \
			echo; \
		else \
			$(call dockerize_ep,endpoint,$(DOCKER_ENDPOINT_PROD),$(gID)); \
			$(call config_ep,$(gID),$(DOCTOR),$(ROLE),$(JURISDICTION),$(PASSWORD)); \
		fi


ep-rm:
	@	if [ -z "$(gID)" ] || [ -z "$(DOCTOR)" ]; \
		then \
			echo; \
			echo "Remove an Endpoint and Auth ID"; \
			echo "Usage: make ep [gID=#] [DOCTOR=#####] [op:JURISDUCTION]"; \
			echo; \
		else \
			sudo docker exec hubdb /app/endpoint_remove.sh $(gID); \
			sudo docker exec auth /sbin/setuser app /app/dacs_remove.sh $(DOCTOR) $(JURISDICTION); \
			sudo docker rm -fv ep$(gID); \
		fi


ep-cloud:
	@	echo
	@	echo "Please enter a gatewayID (####) to run: "
	@	read gID; \
		NAME=pdc-$${gID}; \
		PORT=`expr 40000 + $${gID}`; \
		sudo docker run -dt --name $${NAME} -h $${NAME} -e gID=$${gID} --env-file=config.env --restart='always' -p $${PORT}:3001 -v $(PATH_EPX_AUTOSSH):/root/.ssh/:ro pdc.io/endpoint; \


ep-cloud-rm:
	@	echo
	@	echo "Please enter a gatewayID (####) to remove: "; \
		read gID; \
		NAME=pdc-$${gID}; \
		$(call docker_remove,$${NAME})


cadvisor:
	@	$(call docker_remove,cadvisor)
	@	sudo docker run -ti \
		--volume=/:/rootfs:ro \
		--volume=/var/run:/var/run:rw \
		--volume=/sys:/sys:ro \
		--volume=/var/lib/docker/:/var/lib/docker:ro \
		--publish=8080:8080 \
		--detach=true \
		--name=cadvisor \
		google/cadvisor:latest
	@	$(call docker_remove,cadvisor)


say-goodbye:
	@	echo
	@	echo "DESTROY WARNING: Backup any changes before continuing!"
	@	sudo -k echo
	@	echo "Please type 'goodbye' to confirm"
	@	read CONFIRM; \
		[ "$${CONFIRM}" = "goodbye" ] || ( echo "Not confirmed"; exit )


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


################
# Repo Cloning #
################

clone-auth:
	@	$(call clone,auth,$(GITHUB_AUTH),$(BRANCH_AUTH))


clone-dclapi:
	@	$(call clone,dclapi,$(GITHUB_DCLAPI),$(BRANCH_DCLAPI))


clone-endpoint:
	@	$(call clone,endpoint,$(GITHUB_ENDPOINT),$(BRANCH_ENDPOINT))


clone-hubdb:
	@	$(call clone,hubdb,$(GITHUB_HUBDB),$(BRANCH_HUBDB))


clone-hub:
	@	$(call clone,hub,$(GITHUB_HUB),$(BRANCH_HUB))


clone-hapi:
	@	$(call clone,hapi,$(GITHUB_HAPI),$(BRANCH_HAPI))


clone-viz:
	@	$(call clone,viz,$(GITHUB_VIZ),$(BRANCH_VIZ))


clone-queries:
	@	$(call clone,queries,$(GITHUB_QI),$(BRANCH_QI))


clone-remove:
	@	cd build; \
		sudo rm -rf auth/ dclapi/ hapi/ hub/ hubdb/ viz/ queries/ endpoint/ || true


#################
# Configuration #
#################

config-packages:
	@	sudo apt-get update
	@	( which docker )|| \
			( \
				sudo apt-get install -y linux-image-extra-$$(uname -r); \
				sudo modprobe aufs; \
				wget -qO- https://get.docker.com/ | sh; \
			)


config-mongodb:
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled )> /dev/null
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag )> /dev/null


config-bash:
	@	if(! grep --quiet 'function dockin()' $${HOME}/.bashrc ); \
		then \
			( \
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
				echo '# Aliases to frequently used functions and applications'; \
				echo '#'; \
				echo "alias c='dockin'"; \
				echo "alias d='sudo docker'"; \
				echo "alias e='sudo docker exec'"; \
				echo "alias i='sudo docker inspect'"; \
				echo "alias l='sudo docker logs -f'"; \
				echo "alias p='sudo docker ps -a'"; \
				echo "alias r='sudo docker rm -fv'"; \
				echo "alias s='sudo docker ps -a | less -S'"; \
				echo "alias m='make'"; \
				echo "alias gitsubdiffs='find . -maxdepth 1 -mindepth 1 -type d -exec git -C {} status \;'"; \
				echo "alias ggraph='git log --oneline --graph --decorate --color'"; \
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
	@	if [ ! -e ${PATH_HOST}/oc_backup.sh ]; \
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
				echo '# Create a MongoDB dump'; \
				echo '#'; \
				echo 'sudo docker exec hubdb /app/mongodb_dump.sh';\
				echo ''; \
				echo ''; \
				echo '# Copy non-sensitive MongoDB dumps to ./mongo_partial/'; \
				echo '#'; \
				echo 'sudo mkdir -p mongo_partial/'; \
				echo 'FROM=$\${PATH_HOST}'; \
				echo 'sudo cp mongo/dump/query_composer_development/delayed*   mongo_partial/'; \
				echo 'sudo cp mongo/dump/query_composer_development/endpoints* mongo_partial/'; \
				echo 'sudo cp mongo/dump/query_composer_development/system*    mongo_partial/'; \
				echo 'sudo cp mongo/dump/query_composer_development/users*     mongo_partial/'; \
				echo ''; \
				echo ''; \
				echo '# Backup cert, dacs, drugref, keys and mongo_partial folders to ownCloud'; \
				echo '#'; \
				echo 'USERNAME='$${OWNCLOUD_ID}; \
				echo 'PASSWORD='$${OWNCLOUD_PW}; \
				echo 'OWNCLOUD='$${OWNCLOUD_URL}; \
				echo '#'; \
				echo 'OC_PATH=$${OWNCLOUD}/owncloud/remote.php/webdav/stack'; \
				echo '#'; \
				echo 'for DIR in \\'; \
				echo '	cert \\'; \
				echo '	dacs \\'; \
				echo '	drugref \\'; \
				echo '	epx \\'; \
				echo '	hub \\'; \
				echo '	mongo_partial \\'; \
				echo '	recovery;'; \
				echo 'do'; \
				echo '	sudo owncloudcmd -u $${USERNAME} -p $${PASSWORD} $${DIR} $${OC_PATH}/$${DIR};'; \
				echo 'done'; \
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
		    echo ''; \
		  ) | sudo tee -a /var/spool/cron/crontabs/root; \
		fi


######################
# Docker Image Pulls #
######################

config-img-pull:
	@	sudo docker pull mongo
	@	sudo docker pull phusion/passenger-nodejs
	@	sudo docker pull phusion/passenger-ruby19


#############
# Functions #
#############

define clone
	sudo mkdir -p build/; \
	if test ! -d build/$1; \
	then \
		sudo git clone -b $3 $2 build/$1; \
	else \
		echo "Repo already exists - $1"; \
	fi
endef


define docker_remove
	# 1=folder, 2=op:gID
	#
	if [ -z $2 ]; \
	then \
		( sudo docker stop $1 && sudo docker rm -v $1 ) 2> /dev/null || true; \
	else \
		( sudo docker stop ep$2 && sudo docker rm -v ep$2 ) 2> /dev/null || true; \
	fi
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
	# 1=folder, 2=docker cmd, 3=op:gID
	#
	if [ -z $3 ]; \
	then \
		RUN="--name $1 -h $1"; \
	else \
		RUN="--name ep$3 -h ep$3 -e gID=$3"; \
	fi; \
	echo; \
	echo "*** Running $1 *** sudo docker run -d $${RUN} --env-file=config.env --restart='always' $2 pdc.io/$1 ***"; \
	echo; \
	sudo docker run -d $${RUN} --env-file=config.env --restart='always' $2 pdc.io/$1
	echo
endef


define dockerize
	# 1=folder, 2=docker cmd, 3=op:gID
	#
	$(call docker_remove,$1,$3)
	$(call docker_build,$1)
	$(call docker_run,$1,$2,$3)
	echo
	echo "*** End Dockerize $1 ***"
	echo
endef


define config_ep
	# 1=gID, 2=doctorID, 3=op:userID, 4=op:role, 5=op:jurisdiction, 6=op:password
	#
	# Add Hub to known_hosts and receive Endpoint's public key
	#
	sudo docker exec ep$1 ssh -p $(PORT_AUTOSSH) -o StrictHostKeyChecking=no autossh@$(IP_HUB) 2> /dev/null || true
	sudo docker exec ep$1 /app/key_exchange.sh | sudo tee -a $(PATH_HUB_AUTOSSH)/authorized_keys > /dev/null

	# Add Endpoint to the HubDB
	#
	sudo docker exec hubdb /app/endpoint_add.sh $1 | grep WriteResult

	# Get ClinicID (Endpoint's MongoDB ObjectID) and provide it to Auth
	#
	sudo docker exec -t auth /sbin/setuser app /app/dacs_add.sh \
		$2 $$(sudo docker exec hubdb /app/endpoint_getClinicID.sh $1) \
		$3 $4 $5 $6

	# If doctorID is cpsid, then import sample 10 (cpsid) data
	#
	[ "$2" != "cpsid" ] || sudo docker exec ep$1 /app/sample10/import.sh

	# Enable SSH and regenerate host keys
	#
	sudo docker exec -t ep$1 rm -f /etc/service/sshd/down
	sudo docker exec -t ep$1 update-rc.d ssh defaults
	sudo docker exec -t ep$1 /etc/my_init.d/00_regen_ssh_host_keys.sh
	sudo docker exec -t ep$1 service ssh start

	# Set pdcadmin's password and rights to .ssh/
	#
	sudo docker exec -t ep$1 chown -R pdcadmin:pdcadmin /home/pdcadmin/.ssh/
	sudo docker exec -ti ep$1 passwd pdcadmin
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
	BRANCH_ENDPOINT ?= $(BUILD_MODE)
	BRANCH_EPXCLOUD ?= $(BUILD_MODE)
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
	DOCKER_ENDPOINT_PROD += $(DOCKER_ENDPOINT_JOIN)
	DOCKER_EPXCLOUD_PROD += $(DOCKER_ENDPOINT_JOIN)
	DOCKER_HAPI_PROD += $(DOCKER_HAPI_JOIN)
	DOCKER_HUB_PROD += $(DOCKER_HUB_JOIN)
	DOCKER_HUBDB_PROD += $(DOCKER_HUBDB_JOIN)
	DOCKER_QI_PROD += $(DOCKER_QI_JOIN)
	DOCKER_VIZ_PROD += $(DOCKER_VIZ_JOIN)
endif
