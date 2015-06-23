#########################
# Environment Variables #
#########################

# Source configuration file
#
include config.env


# Set branch defaults
#
ifeq ($(BUILD_MODE), dev)
	BRANCH_DEFAULT = dev
else ifeq ($(BUILD_MODE), master)
	BRANCH_DEFAULT = master
else
	BRANCH_DEFAULT = $(RELEASE_VERSION)
endif


# Append Docker run commands for non-production modes
#
ifneq ($(BUILD_MODE), prod)
	DOCKER_AUTH_PRODUCTION += $(DOCKER_AUTH_DEV_APPEND)
	DOCKER_DCLAPI_PRODUCTION += $(DOCKER_DCLAPI_DEV_APPEND)
	DOCKER_ENDPOINT_PRODUCTION += $(DOCKER_ENDPOINT_DEV_APPEND)
	DOCKER_HAPI_PRODUCTION += $(DOCKER_HAPI_DEV_APPEND)
	DOCKER_HUB_PRODUCTION += $(DOCKER_HUB_DEV_APPEND)
	DOCKER_HUBDB_PRODUCTION += $(DOCKER_HUBDB_DEV_APPEND)
	DOCKER_QI_PRODUCTION += $(DOCKER_QI_DEV_APPEND)
	DOCKER_VIZ_PRODUCTION += $(DOCKER_VIZ_DEV_APPEND)
endif


# Use branch defaults where overrides are not provided
#
BRANCH_AUTH ?= $(BRANCH_DEFAULT)
BRANCH_DCLAPI ?= $(BRANCH_DEFAULT)
BRANCH_ENDPOINT ?= $(BRANCH_DEFAULT)
BRANCH_HAPI ?= $(BRANCH_DEFAULT)
BRANCH_HUB ?= $(BRANCH_DEFAULT)
BRANCH_HUBDB ?= $(BRANCH_DEFAULT)
BRANCH_QI ?= $(BRANCH_DEFAULT)
BRANCH_VIZ ?= $(BRANCH_DEFAULT)


################
# General Jobs #
################

default: configure clone containers

configure: config-packages config-mongodb config-bash config-img-pull

clone: clone-auth clone-dclapi clone-hubdb clone-hub clone-hapi clone-viz clone-queries clone-endpoint

containers: clone hubdb hub auth ep-sample dclapi hapi viz mode-inform

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
	@ $(call mode_change,dev)
#
master:
	@ $(call mode_change,master)
#
prod:
	@ $(call mode_change,prod)


#########################
# Default Container Set #
#########################

hubdb:
	@	sudo mkdir -p $(PATH_HOST)/mongo/
	@	$(call dockerize,hubdb,$(DOCKER_HUBDB_PRODUCTION))
	@	sudo docker exec hubdb /app/init_db.sh > /dev/null


hub:
	@	sudo mkdir -p $(PATH_HOST)/keys/hub_authorized/
	@	sudo mkdir -p $(PATH_HOST)/keys/hub_ssh/
	@	$(call dockerize,hub,$(DOCKER_HUB_PRODUCTION))
	@	if [ $(BUILD_MODE) != prod ]; \
		then \
			$(MAKE) ep-sample; \
			$(MAKE) queries; \
		fi

auth:
	@	sudo mkdir -p $(PATH_HOST)/dacs/
	@	$(call dockerize,auth,$(DOCKER_AUTH_PRODUCTION))


dclapi:
	@	sudo mkdir -p $(PATH_HOST)/drugref/
	@	sudo test -s $(PATH_HOST)/drugref/dcl.sqlite || \
		sudo cp build/dclapi/drugref/dcl.sqlite $(PATH_HOST)/drugref/
	@	$(call dockerize,dclapi,$(DOCKER_DCLAPI_PRODUCTION))


hapi:
	@	$(call dockerize,hapi,$(DOCKER_HAPI_PRODUCTION))


viz:
	@	sudo mkdir -p $(PATH_HOST)/cert/
	@	[ -f ./cert/server.crt -a ! -f $(PATH_HOST)/cert/server.crt ]&& \
			sudo cp ./cert/server.crt $(PATH_HOST)/cert/ || \
			true
	@	[ -f ./cert/server.key -a ! -f $(PATH_HOST)/cert/server.crt ]|| \
			sudo cp ./cert/server.key $(PATH_HOST)/cert/ || \
			true
	@	$(call dockerize,viz,$(DOCKER_VIZ_PRODUCTION))


ep-sample:
	@ $(call dockerize,endpoint,$(DOCKER_ENDPOINT_PRODUCTION),ep0)
	@	$(call config_ep,0,cpsid,cpsid,admin,TEST,sample)


queries:
	@	$(call dockerize,queries,$(DOCKER_QI_PRODUCTION))
	@	sudo docker logs -f queries
	@	$(call docker_remove,queries)


containers-remove:
	@	( sudo docker stop `sudo docker ps -q` )&&( sudo docker rm `sudo docker ps -a -q` )|| \
			echo "No containers to delete"


################################
# Tools and Testing Containers #
################################

ep:
	@	if [ -z "$(gID)" ] || [ -z "$(DOCTOR)" ]; \
		then \
			echo; \
			echo "Create an Endpoint and Auth ID"; \
			echo "Usage: make ep [gID=#] [DOCTOR=#####] [op:JURISDUCTION] [op:ROLE] [op:PASSWORD]"; \
			echo; \
		else \
			$(call dockerize_ep,endpoint,$(DOCKER_ENDPOINT_PRODUCTION),$(gID)); \
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
	@	sudo mkdir -p $(PATH_KEYS_EP_CLOUD)
	@	if [ ! -e $(PATH_KEYS_EP_CLOUD) ]; \
		then \
			sudo cp id_rsa.pub id_rsa known_hosts $(PATH_KEYS_EP_CLOUD); \
			sudo chown root $(PATH_KEYS_EP_CLOUD)/*; \
			fi
	@	echo
	@	echo "Please enter a gatewayID (####) to run: "; \
		read gID; \
		NAME=pdc-$${gID}; \
		PORT=`expr 40000 + $${gID}`; \
		sudo docker run -dt --name $${NAME} -h $${NAME} -e gID=$${gID} --env-file=config.env --restart='always' -p $${PORT}:3001 -v $(PATH_KEYS_EP_CLOUD):/root/.ssh/:ro pdc.io/endpoint; \
		sudo docker exec $${NAME} /app/key_exchange.sh


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
	@	echo
	@	echo "Please type 'goodbye' to confirm"
	@	read CONFIRM; \
		[ "$${CONFIRM}" = "goodbye" ] || ( echo "Not confirmed"; exit )


mode-inform:
	@	sudo docker ps
	@	echo
	@	echo "..."
	@	echo
	@	echo "Environment complete"
	@ echo " - mode: $(BUILD_MODE)"
	@ echo
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
	@ sudo apt-get update
	@	( which docker )||( \
			sudo apt-get install -y linux-image-extra-$$(uname -r); \
			sudo modprobe aufs; \
			wget -qO- https://get.docker.com/ | sh; \
		 )
	@	for a in \
			curl \
			lynx; \
		do \
			( dpkg -l | grep -w $${a} )|| sudo apt-get install -y $${a}; \
		done; \


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
		  ) | tee -a $${HOME}/.bashrc; \
			echo ""; \
			echo ""; \
			echo "Please log in/out for changes to take effect!"; \
			echo ""; \
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
	# 1=folder, 2=op:container
	#
	if [ -z $2 ]; \
	then \
		( sudo docker stop $1 && sudo docker rm -v $1 ) 2> /dev/null || true; \
	else \
		( sudo docker stop $2 && sudo docker rm -v $2 ) 2> /dev/null || true; \
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
	# 1=folder, 2=docker cmd, 3=op:container
	#
	if [ -z $3 ]; \
	then \
		RUN="--name $1 -h $1"; \
	else \
		RUN="--name $3 -h $3 -e gID=$3"; \
	fi; \
	echo; \
	echo "*** Running $1 *** sudo docker run -d $${RUN} --env-file=config.env --restart='always' $2 pdc.io/$1 ***"; \
	echo; \
	sudo docker run -d $${RUN} --env-file=config.env --restart='always' $2 pdc.io/$1
	echo
endef


define dockerize
	# 1=folder, 2=docker cmd, 3=op:container
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
	sudo docker exec ep$1 ssh -p $(PORT_AUTOSSH) -o StrictHostKeyChecking=no autossh@$(URL_HUB) 2> /dev/null || true
	sudo docker exec ep$1 /app/key_exchange.sh | sudo tee -a $(PATH_KEYS_HUB_AUTH)/authorized_keys > /dev/null

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
