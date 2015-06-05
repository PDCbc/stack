#########################
# Environment Variables #
#########################

# Source configuration file
#
include config.env


# Set branch defaults and adjust Docker run commands
#
ifeq ($(DEV_MODE), true)
	DOCKER_AUTH_PRODUCTION += $(DOCKER_AUTH_DEV_APPEND)
	DOCKER_DCLAPI_PRODUCTION += $(DOCKER_DCLAPI_DEV_APPEND)
	DOCKER_ENDPOINT_PRODUCTION += $(DOCKER_ENDPOINT_DEV_APPEND)
	DOCKER_HAPI_PRODUCTION += $(DOCKER_HAPI_DEV_APPEND)
	DOCKER_HUB_PRODUCTION += $(DOCKER_HUB_DEV_APPEND)
	DOCKER_HUBDB_PRODUCTION += $(DOCKER_HUBDB_DEV_APPEND)
	DOCKER_QI_PRODUCTION += $(DOCKER_QI_DEV_APPEND)
	DOCKER_VIZ_PRODUCTION += $(DOCKER_VIZ_DEV_APPEND)
	BRANCH_DEFAULT = dev
else
	BRANCH_DEFAULT = $(RELEASE_VERSION)
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

configure: config-packages config-mongodb config-vim config-bash config-img-pull

clone: clone-auth clone-dclapi clone-hubdb clone-hub clone-hapi clone-viz clone-queries clone-endpoint

containers: hubdb hub auth ep-sample dclapi hapi viz mode-inform

clone-update: say-goodbye clone-remove clone

remove-all: say-goodbye clone-remove containers-remove

reset: remove-all clone containers


#############
# Run Modes #
#############

# Show mode - development or production
#
mode:
	@	echo
	@	cat config.env | grep DEV_MODE=
	@	echo
	@	echo "Set: make [ dev | prod ]"
	@	echo


# Switch to development mode (dev branches)
#
dev:
	@	if $(DEV_MODE); \
		then \
			echo; \
			echo "Mode unchanged"; \
			echo; \
		else \
			sed -i -e "s/DEV_MODE=.*/DEV_MODE=true/" config.env; \
			cat config.env | grep DEV_MODE=; \
			$(MAKE) clone-update; \
		fi


# Switch to production mode (master branches)
#
prod:
	@	if ! $(DEV_MODE); \
		then \
			echo; \
			echo "Mode unchanged"; \
			echo; \
		else \
			sed -i -e "s/DEV_MODE=.*/DEV_MODE=false/" config.env; \
			cat config.env | grep DEV_MODE=; \
			$(MAKE) clone-update; \
		fi


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
	@	( $(DEV_MODE) && $(MAKE) queries )|| true


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
	@	$(call dockerize,viz,$(DOCKER_VIZ_PRODUCTION))


ep-sample:
	@	$(call dockerize_ep,endpoint,$(DOCKER_ENDPOINT_PRODUCTION),0,cpsid,sample)
	@	sudo docker exec ep0 mongoimport --db query_gateway_development --collection records /app/sample.json > /dev/null


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
	@	echo ""
	@	echo "Gateway ID (#): "
	@	read gID; \
		echo "Clinician ID (#####): "; \
		read DOCTOR; \
		$(call dockerize_ep,endpoint,$(DOCKER_ENDPOINT_PRODUCTION),$(gID),$${DOCTOR},sample); \


ep-rm:
	@	echo ""
	@	echo "Gateway ID (#): "
	@	read gID; \
		echo "Clinician ID (#####): "; \
		read DOCTOR; \
		sudo docker exec hubdb /app/endpoint_remove.sh $${gID}; \
		sudo docker exec auth /sbin/setuser app /app/dacs_remove.sh $${DOCTOR} TEST; \
		sudo docker rm -fv ep$${gID} || true 2> /dev/null


cadvisor:
	@	sudo docker rm -f cadvisor || true
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
	@	if( $${DEV_MODE} ); \
		then \
			echo "Development environment complete"; \
			else \
			echo "Production environment complete"; \
		fi
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
		rm -rf auth/ dclapi/ hapi/ hub/ hubdb/ viz/ queries/ endpoint/ || true


#################
# Configuration #
#################

config-packages:
	@ sudo apt-get update
	@	sudo apt-get install -y linux-image-extra-$$(uname -r) 2> /dev/null
	@	sudo modprobe aufs
	@	if( $${DEV_MODE} ) \
		then \
			for a in \
				curl \
				lynx \
				mongodb \
				nodejs \
				nodejs-legacy \
				npm; \
			do \
				( dpkg -l | grep -w $${a} )|| sudo apt-get install -y $${a}; \
			done; \
		fi
	@	( which docker )||( wget -qO- https://get.docker.com/ | sh )


config-mongodb:
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled )> /dev/null
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag )> /dev/null


config-vim:
	@	if([ ! -e $${HOME}/.vimrc ]||(! grep --quiet 'colorscheme delek' $${HOME}/.vimrc )); \
		then \
		  ( \
		    echo 'set number'; \
		    echo 'colorscheme delek'; \
		  ) | tee -a $${HOME}/.vimrc; \
		fi


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
				echo ""; \
				echo ""; \
				echo "# Fix for Vagrant clock skew"; \
				echo "#"; \
				echo "sudo ntpdate us.pool.ntp.org"; \

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
	if test ! -d build/$1; \
	then \
		git clone -b $3 $2 build/$1; \
	else \
		echo "Repo already exists - $1"; \
	fi
endef


define docker_remove
	( sudo docker stop $1 2> /dev/null )|| true
	( sudo docker rm -v $1 2> /dev/null )|| true
	echo
endef


define docker_build
	echo
	echo "*** Building $1 *** sudo docker build -t pdc.io/$1 ./build/$1/ ***"
	echo
	sudo docker build -t pdc.io/$1 ./build/$1/
	echo
endef


define docker_run
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
	$(call docker_remove,$1)
	$(call docker_build,$1)
	$(call docker_run,$1,$2)
	echo
	echo "*** End Dockerize $1 ***"
	echo
endef


define dockerize_ep
	$(call docker_remove,ep$3)
	$(call docker_build,$1)
	$(call docker_run,$1,$2,$3)

	sudo docker exec     ep$3  ssh -p $(PORT_AUTOSSH) -o StrictHostKeyChecking=no autossh@$(URL_HUB) 2> /dev/null || true
	sudo docker exec -ti ep$3  /app/key_exchange.sh | sudo tee -a $(PATH_KEYS_HUB_AUTH)/authorized_keys > /dev/null

	sudo docker exec     hubdb /app/endpoint_add.sh $3 | grep WriteResult
	sudo docker exec -it auth /sbin/setuser app /app/dacs_add.sh \
		$4 $5 $4 \
		$$(sudo docker exec hubdb /app/endpoint_getClinicID.sh $3) \
		TEST sample

	echo
	echo
	echo "*** End Dockerize $1 ***"
	echo
endef
