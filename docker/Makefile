#########################
# Environment Variables #
#########################
include config.env

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
	BRANCH_DEFAULT = master
endif

ifeq ($(BRANCH_AUTH), )
	BRANCH_AUTH = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_DCLAPI), )
	BRANCH_DCLAPI = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_ENDPOINT), )
	BRANCH_ENDPOINT = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_HAPI), )
	BRANCH_HAPI = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_HUB), )
	BRANCH_HUB = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_HUBDB), )
	BRANCH_HUBDB = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_QI), )
	BRANCH_QI = $(BRANCH_DEFAULT)
endif

ifeq ($(BRANCH_VIZ), )
	BRANCH_VIZ = $(BRANCH_DEFAULT)
endif


################
# General Jobs #
################
default:
	$(MAKE) -s all

all:
	$(MAKE) -s configure
	$(MAKE) -s containers

configure:
	$(MAKE) -s config-packages
	$(MAKE) -s config-mongodb
	$(MAKE) -s config-vim
	$(MAKE) -s config-bash
	$(MAKE) -s config-img-pull

clone:
	$(MAKE) -s clone-auth
	$(MAKE) -s clone-dclapi
	$(MAKE) -s clone-hub
	$(MAKE) -s clone-hapi
	$(MAKE) -s clone-viz
	$(MAKE) -s clone-queries
	$(MAKE) -s clone-endpoint

clone-update:
	$(MAKE) -s say-goodbye
	$(MAKE) -s clone-remove
	$(MAKE) -s clone

containers:
	$(MAKE) -s clone
	$(MAKE) -s auth
	$(MAKE) -s hubdb
	$(MAKE) -s dclapi
	$(MAKE) -s hub
	$(MAKE) -s hapi
	$(MAKE) -s viz
	#$(MAKE) -s ep-sample
	$(MAKE) -s mode-inform

containers-update:
	$(MAKE) -s say-goodbye
	$(MAKE) -s containers-remove
	$(MAKE) -s containers

remove-all:
	$(MAKE) -s say-goodbye
	$(MAKE) -s clone-remove
	$(MAKE) -s containers-remove

reset:
	$(MAKE) -s remove-all
	$(MAKE) -s containers


#############
# Run Modes #
#############
mode:
	@echo
	@cat config.env | grep DEV_MODE=
	@echo
	@echo "Set: make [ dev | prod ]"
	@echo

dev:
	@if $(DEV_MODE); \
	then \
		echo; \
		echo "Mode unchanged"; \
		echo; \
	else \
		sed -i -e "s/DEV_MODE=.*/DEV_MODE=true/" config.env; \
		cat config.env | grep DEV_MODE=; \
		$(MAKE) clone-update; \
	fi

prod:
	@if ! $(DEV_MODE); \
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
auth:
	@sudo mkdir -p $(PATH_HOST)/dacs/
	$(call dockerize,auth,$(DOCKER_AUTH_PRODUCTION))

hubdb: config-mongodb
	@sudo mkdir -p $(PATH_HOST)/mongo/
	$(call dockerize,hubdb,$(DOCKER_HUBDB_PRODUCTION))
	@sudo docker exec hubdb /app/init_db.sh

dclapi:
	@sudo mkdir -p $(PATH_HOST)/drugref/
	@( sudo test -s $(PATH_HOST)/drugref/dcl.sqlite ) || \
		sudo cp build/dclapi/drugref/dcl.sqlite $(PATH_HOST)/drugref/
	$(call dockerize,dclapi,$(DOCKER_DCLAPI_PRODUCTION))

hub: hubdb
	@sudo mkdir -p $(PATH_HOST)/keys/hub/
	@sudo mkdir -p $(PATH_HOST)/keys/endpoints/
	$(call dockerize,hub,$(DOCKER_HUB_PRODUCTION))
	@( $(DEV_MODE) && $(MAKE) queries && $(MAKE) ep-sample )|| true

hapi: auth hubdb dclapi
	$(call dockerize,hapi,$(DOCKER_HAPI_PRODUCTION))

viz: auth hapi
	$(call dockerize,viz,$(DOCKER_VIZ_PRODUCTION))

containers-remove: rm-all


################################
# Tools and Testing Containers #
################################
queries:
	$(call dockerize,queries,$(DOCKER_QI_PRODUCTION))
	sudo docker logs -f queries
	$(call docker_remove,queries)

ep-sample:
	$(call dockerize_ep,endpoint,$(DOCKER_ENDPOINT_PRODUCTION),0)
	sudo docker exec hubdb /app/endpoint_add.sh 0
	sudo docker exec ep0 ssh -p $(PORT_AUTOSSH) -o StrictHostKeyChecking=no autossh@$(URL_HUB) || true
	SSH_KEY=$$(sudo docker exec -ti ep0 /app/key_exchange.sh); \
	echo $${SSH_KEY} | sudo tee -a $(PATH_KEYS_HUB_AUTH)/authorized_keys; \
	sudo cat $(PATH_KEYS_HUB_AUTH)/authorized_keys; \
	echo authorized_keys file is $(PATH_KEYS_HUB_AUTH)/authorized_keys
	sudo docker exec ep0 mongoimport --db query_gateway_development --collection records /app/sample.json

ep:
	@echo ""
	@echo "Gateway ID (#): "
	@read gID; \
	@echo "Clinician ID (#####): "; \
	read cID; \
	$(call dockerize_ep,endpoint,$(DOCKER_ENDPOINT_PRODUCTION),$(gID))
	sudo docker exec hubdb /app/endpoint_add.sh $(gID)
	sudo docker exec ep$(gID) ssh -p $(PORT_AUTOSSH) -o StrictHostKeyChecking=no autossh@$(URL_HUB) || true
	SSH_KEY=$$(sudo docker exec -ti ep$(gID) /app/key_exchange.sh); \
	echo $${SSH_KEY} | sudo tee -a $(PATH_KEYS_HUB_AUTH)/authorized_keys; \
	sudo cat $(PATH_KEYS_HUB_AUTH)/authorized_keys; \
	echo authorized_keys file is $(PATH_KEYS_HUB_AUTH)/authorized_keys
	#
	# To Do --- Auth Adds

rm-all:
	( sudo docker rm -f cadvisor )|| true; \
	( sudo docker stop `sudo docker ps -q`) && \
	( sudo docker rm `sudo docker ps -a -q` )|| \
	echo "No containers to delete"

#rm-ep:
#	@echo "";
#	@echo "Please enter a gatewayID (#) to rm: "
#	@read gID; \
#	$(call docker_remove,ep$${gID}db); \
#	$(call docker_remove,ep$${gID}); \
	#EVAL="db.endpoints.remove({ \"base_url\" : \"http://localhost:$$((40000 + $$gID))\" })"; \
	#/bin/bash -c "sudo docker exec hubdb mongo query_composer_development --eval '$${EVAL}'"; \
#	/bin/bash -c "sudo docker exec auth /sbin/setuser app /usr/bin/dacspasswd -uj $(DACS_JURISDICTION) -d ep$${gID}"; \
#	/bin/bash -c "sudo docker exec auth /sbin/setuser app sed -i\".bak\" '/ep$${gID}/d' /etc/dacs/federations/pdc.dev/roles"

cadvisor:
	sudo docker rm -f cadvisor || true
	sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest


################
# Repo Cloning #
################
clone-auth:
	$(call clone,auth,$(GITHUB_AUTH),$(BRANCH_AUTH))

clone-dclapi:
	$(call clone,dclapi,$(GITHUB_DCLAPI),$(BRANCH_DCLAPI))

clone-hub:
	$(call clone,hub,$(GITHUB_HUB),$(BRANCH_HUB))

clone-hapi:
	$(call clone,hapi,$(GITHUB_HAPI),$(BRANCH_HAPI))

clone-viz:
	$(call clone,viz,$(GITHUB_VIZ),$(BRANCH_VIZ))

clone-queries:
	$(call clone,queries,$(GITHUB_QI),$(BRANCH_QI))

clone-endpoint:
	$(call clone,endpoint,$(GITHUB_ENDPOINT),$(BRANCH_ENDPOINT))

clone-remove:
	@cd build; \
	rm -rf auth/ dclapi/ hapi/ hub/ viz/ queries/ endpoint/


#################
# Configuration #
#################
config-packages:
	@if( $${DEV_MODE} ) \
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
	@( which docker )||( wget -qO- https://get.docker.com/ | sh )

config-mongodb:
	@( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled )> /dev/null
	@( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag )> /dev/null

config-vim:
	@if([ ! -e $${HOME}/.vimrc ]||(! grep --quiet 'colorscheme delek' $${HOME}/.vimrc )); \
	then \
	  ( \
	    echo 'set number'; \
	    echo 'colorscheme delek'; \
	  ) | tee -a $${HOME}/.vimrc; \
	fi

config-bash:
	@if(! grep --quiet 'function dockin()' $${HOME}/.bashrc ); \
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
		echo "Please log in/out for changes to take effect!"; \
		echo ""; \
	fi


######################
# Docker Image Pulls #
######################
config-img-pull:
	sudo docker pull mongo
	sudo docker pull phusion/passenger-nodejs
	sudo docker pull phusion/passenger-ruby19


#############
# Functions #
#############
define clone
	@if test ! -d build/$1; \
	then \
		git clone -b $3 $2 build/$1; \
	else \
		echo "Repo already exists - $1"; \
	fi
endef

define docker_remove
	sudo docker rm -f cadvisor || true
	sudo docker stop $1 || true
	sudo docker rm -v $1 || true
endef

define dockerize
	@echo; echo
	@echo "*** Start Dockerize $1 ***"
	@echo; echo
	$(call docker_remove,$1)
	@echo; echo
	@echo "*** Building $1 *** sudo docker build -t pdc.io/$1 ./build/$1/ ***"
	@echo; echo
	sudo docker build -t pdc.io/$1 ./build/$1/
	@echo; echo
	@echo "*** Running $1 *** sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1 ***"
	@echo; echo
	sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1
	@echo; echo
	@echo "*** End Dockerize $1 ***"
	@echo; echo
endef

define dockerize_ep
	@echo; echo
	@echo "*** Start Dockerize $1 ***"
	@echo; echo
	$(call docker_remove,ep$3)
	@echo; echo;
	@echo "*** Building ep$3 *** sudo docker build -t pdc.io/$1 ./build/$1/ ***";
	@echo; echo
	sudo docker build -t pdc.io/$1 ./build/$1/
	@echo; echo;
	@echo "*** Running ep$3 *** sudo docker run -d --name ep$3 -h ep$3 --env-file=config.env --restart='always' $2 pdc.io/$1 ***";
	@echo; echo
	echo gID=$3; sudo docker run -d --name ep$3 -h ep$3 --env-file=config.env -e 'gID=$3' --restart='always' $2 pdc.io/$1
	@echo; echo
	@echo "*** End Dockerize $1 ***"
	@echo; echo
endef

say-goodbye:
	@echo ""
	@echo "DESTROY WARNING: Backup any changes before continuing!"
	@echo ""
	@echo "Please type 'goodbye' to confirm"
	@read CONFIRM; \
	[ "$${CONFIRM}" = "goodbye" ] || ( echo "Not confirmed"; exit )

mode-inform:
	@sudo docker ps
	@echo ""
	@echo "..."
	@echo ""
	@if( $${DEV_MODE} ); \
	then \
		echo "Development environment complete"; \
	else \
		echo "Production environment complete"; \
	fi
	@echo ""
	@echo "Enjoy!"
	@echo ""
	@echo "..."
	@echo ""
