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
default: set

all: dep pull set queries ep-sample

import: queries

endpoint: ep

remove-all: say-goodbye


############
# Modes #
############
dev:
	@sed -i -e "s/DEV_MODE=.*/DEV_MODE=true/" config.env
	@cat config.env | grep DEV_MODE

prod:
	@sed -i -e "s/DEV_MODE=.*/DEV_MODE=false/" config.env
	@cat config.env | grep DEV_MODE


#################
# Configuration #
#################
dep:
		./dependencies/dependencies.sh

pull:
	sudo docker pull mongo
	sudo docker pull phusion/baseimage

say-goodbye:
	@echo ""
	@echo "Are you sure you want to delete all your hard work?"
	@echo ""
	@echo "Please type 'goodbye' to confirm"
	@read CONFIRM; \
	[ "$${CONFIRM}" != "goodbye" ] || ( \
			sudo docker rm -f cadvisor || true; \
			( sudo docker stop `sudo docker ps -q`) && \
			( sudo docker rm `sudo docker ps -a -q` )|| \
			echo "No containers to delete" \
		)



##################
# GitHub cloning #
##################
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

clone-set: clone-auth clone-dclapi clone-hub clone-hapi clone-viz


#########################
# Default container set #
#########################
auth:
	sudo mkdir -p $(PATH_HOST)/dacs/
	$(call dockerize,auth,$(DOCKER_AUTH_PRODUCTION))

hubdb:
	sudo mkdir -p $(PATH_HOST)/mongo/
	$(call dockerize,hubdb,$(DOCKER_HUBDB_PRODUCTION))
	( sleep 2; sudo docker exec hubdb /app/config.sh )|| \
		( sleep 10; sudo docker exec hubdb /app/config.sh )

dclapi:
	$(call dockerize,dclapi,$(DOCKER_DCLAPI_PRODUCTION))

hub: hubdb
	sudo mkdir -p $(PATH_HOST)/ssh/hub/
	sudo mkdir -p $(PATH_HOST)/ssh/endpoints/
	$(call dockerize,hub,$(DOCKER_HUB_PRODUCTION))
	sudo cp $(PATH_HOST)/keys/hub/known_hosts ./build/endpoint
	$(DEV_MODE) && $(MAKE) queries && $(MAKE) ep-sample

hapi: auth hubdb dclapi
	$(call dockerize,hapi,$(DOCKER_HAPI_PRODUCTION))

viz: auth hapi
	$(call dockerize,viz,$(DOCKER_VIZ_PRODUCTION))

set: auth hubdb dclapi hub hapi viz


################################
# Tools and testing containers #
################################
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

queries:
	$(call dockerize,queries,$(DOCKER_QI_PRODUCTION))
	sudo docker exec queries /app/app.sh pdcadmin
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
	echo EVAL="db.endpoints.remove({ \"base_url\" : \"http://localhost:$$((40000 + $$gID))\" })"; \
	EVAL="db.endpoints.remove({ \"base_url\" : \"http://localhost:$$((40000 + $$gID))\" })"; \
	/bin/bash -c "sudo docker exec hubdb mongo query_composer_development --eval '$${EVAL}'"; \
	/bin/bash -c "sudo docker exec auth /sbin/setuser app /usr/bin/dacspasswd -uj $(DACS_JURISDICTION) -d ep$${gID}"; \
	/bin/bash -c "sudo docker exec auth /sbin/setuser app sed -i\".bak\" '/ep$${gID}/d' /etc/dacs/federations/pdc.dev/roles"


#############
# Functions #
#############
define clone
	if test ! -d build/$1; then git clone -b $3 $2 build/$1; else echo "Exists!"; fi
endef

define docker_build
	sudo docker build -t pdc.io/$1 ./build/$1/
endef

define docker_remove
	sudo docker rm -f cadvisor || true; \
	sudo docker stop $1 || true; \
	sudo docker rm -v $1 || true
endef

define docker_run
	sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1
endef

define dockerize
	$(call docker_build,$1)
	$(call docker_remove,$1)
	$(call docker_run,$1,$2)
endef
