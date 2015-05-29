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
endif


################
# General Jobs #
################
default: all

all: configure containers

configure: config-packages config-mongo config-vim config-bash config-img-pull

clone: clone-auth clone-dclapi clone-hub clone-hapi clone-viz clone-queries

clone-update: say-goodbye clone-remove clone

containers: clone auth hubdb dclapi hub hapi viz ep-sample mode-inform

containers-update: say-goodbye containers-remove containers

remove-all: say-goodbye clone-remove containers-remove

reset: remove-all clone containers


#############
# Run Modes #
#############

dev:
	@sed -i -e "s/DEV_MODE=.*/DEV_MODE=true/" config.env
	@cat config.env | grep DEV_MODE

prod:
	@sed -i -e "s/DEV_MODE=.*/DEV_MODE=false/" config.env
	@cat config.env | grep DEV_MODE


#########################
# Default Container Set #
#########################
auth:
	$(call dockerize,auth,$(DOCKER_AUTH_PRODUCTION))
	sudo mkdir -p $(PATH_HOST)/dacs/

hubdb: config-mongo
	$(call dockerize_img,hubdb,$(DOCKER_HUBDB_PRODUCTION),mongo)
	sudo mkdir -p $(PATH_HOST)/mongo/
	sleep 2
	sudo docker exec hubdb mongo query_composer_development --eval \
		'printjson( db.users.ensureIndex({ username : 1 }, { unique : true }))'
	sudo docker exec hubdb mongo query_composer_development --eval \
		'db.users.insert({ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "\$2a\$10\$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true })'

dclapi:
	$(call dockerize,dclapi,$(DOCKER_DCLAPI_PRODUCTION))

hub: hubdb
	sudo mkdir -p $(PATH_HOST)/ssh/hub/
	sudo mkdir -p $(PATH_HOST)/ssh/endpoints/
	$(call dockerize,hub,$(DOCKER_HUB_PRODUCTION))
	sudo cp $(PATH_HOST)/keys/hub/known_hosts ./build/endpoint
	( $(DEV_MODE) && $(MAKE) queries && $(MAKE) ep-sample )|| true

hapi: auth hubdb dclapi
	$(call dockerize,hapi,$(DOCKER_HAPI_PRODUCTION))

viz: auth hapi
	$(call dockerize,viz,$(DOCKER_VIZ_PRODUCTION))

containers-remove: rm-all


################################
# Tools and Testing Containers #
################################
rm-all:
	( sudo docker rm -f cadvisor > /dev/null )|| true; \
	( sudo docker stop `sudo docker ps -q`) && \
	( sudo docker rm `sudo docker ps -a -q` )|| \
	echo "No containers to delete"

queries:
	$(call dockerize,queries,$(DOCKER_QI_PRODUCTION))
	sudo docker logs -f queries
	$(call docker_remove,queries)

ep-sample:
	$(call docker_remove, ep0db); \
	$(call docker_remove, ep0); \
	export PATH_KEYS_ENDPOINTS=$(PATH_KEYS_ENDPOINTS); \
	export URL_HUB=$(URL_HUB); \
	./build/add-endpoint.sh 0 cpsid ep0 TEST sample

ep:
	@echo ""
	@echo "Gateway ID (#): "
	@read gID; \
	echo "Clinician ID (#####): "; \
	read cID; \
	export PATH_KEYS_ENDPOINTS=$(PATH_KEYS_ENDPOINTS); \
	export URL_HUB=$(URL_HUB); \
	./build/add-endpoint.sh $${gID} $${cID} ep$${gID}

rm-ep:
	@echo "";
	@echo "Please enter a gatewayID (#) to rm: "
	@read gID; \
	$(call docker_remove,ep$${gID}db); \
	$(call docker_remove,ep$${gID}); \
	EVAL="db.endpoints.remove({ \"base_url\" : \"http://localhost:$$((40000 + $$gID))\" })"; \
	/bin/bash -c "sudo docker exec hubdb mongo query_composer_development --eval '$${EVAL}'"; \
	/bin/bash -c "sudo docker exec auth /sbin/setuser app /usr/bin/dacspasswd -uj $(DACS_JURISDICTION) -d ep$${gID}"; \
	/bin/bash -c "sudo docker exec auth /sbin/setuser app sed -i\".bak\" '/ep$${gID}/d' /etc/dacs/federations/pdc.dev/roles"

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


#################
# Configuration #
#################
config-packages:
	@if([ ! -f /etc/apt/sources.list.d/docker.list ]||(! grep --quiet 'https://get.docker.io/ubuntu' /etc/apt/sources.list.d/docker.list )) \
	then \
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9; \
		sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"; \
		sudo apt-get update; \
	fi
	@( which docker )||( sudo apt-get install -y lxc-docker )
	#
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
			( dpkg -l | grep -w $$a )|| sudo apt-get install -y $$a; \
		done; \
	fi

config-mongo:
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
	sudo docker pull phusion/baseimage


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
	sudo docker rm -f cadvisor|| true
	sudo docker stop $1 || true
	sudo docker rm -v $1 || true
endef

define dockerize
	$(call docker_remove,$1)
	sudo docker build -t pdc.io/$1 ./build/$1/
	sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1
endef

define dockerize_img
	$(call docker_remove,$1)
	sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 $3
endef

say-goodbye:
	@echo ""
	@echo "DESTROY WARNING: Backup any work before continuing!"
	@echo ""
	@echo "Please type 'goodbye' to confirm"
	@read CONFIRM; \
	[ "$${CONFIRM}" = "goodbye" ] || ( echo "Not confirmed"; false )

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
