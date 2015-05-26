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

all: dependencies pull set queries ep-sample

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
dependencies:
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
	@[ "$${CONFIRM}" != "goodbye" ] || ( \
			( sudo docker stop `sudo docker ps -q`) && \
			( sudo docker rm `sudo docker ps -a -q` )|| \
			echo "No containers to delete" \
		)


#########################
# Default container set #
#########################
auth:
	$(call dockerize,auth,$(DOCKER_AUTH_PRODUCTION))
	sudo mkdir -p $(PATH_HOST)/dacs/

hubdb:
	$(call dockerize,hubdb,$(DOCKER_HUBDB_PRODUCTION))
	sudo mkdir -p $(PATH_HOST)/mongo/
	( sleep 2; sudo docker exec hubdb /app/config.sh )|| \
		( sleep 10; sudo docker exec hubdb /app/config.sh )

dclapi:
	$(call dockerize,dclapi,$(DOCKER_DCLAPI_PRODUCTION))

hub: hubdb
	$(call dockerize,hub,$(DOCKER_HUB_PRODUCTION))
	sudo mkdir -p $(PATH_HOST)/ssh/hub/
	sudo mkdir -p $(PATH_HOST)/ssh/endpoints/
	sudo touch $(PATH_HOST)/keys/authorized_keys
	$(DEV_MODE) && $(MAKE) queries && $(MAKE) ep-sample

hapi: auth hubdb dclapi
	$(call dockerize,hapi,$(DOCKER_HAPI_PRODUCTION))

viz: auth hapi
	$(call dockerize,viz,$(DOCKER_VIZ_PRODUCTION))

set: auth hubdb dclapi hub hapi viz


##############################
# Dev and testing containers #
##############################
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
	$(call docker_remove, ep$${gID}db); \
	$(call docker_remove, ep$${gID}); \
	EVAL="db.endpoints.remove({ \"base_url\" : \"http://localhost:$$((40000 + $$gID))\" })"; \
	/bin/bash -c "sudo docker exec hubdb mongo query_composer_development --eval '$${EVAL}'"


#############
# Functions #
#############
define docker_build
	sudo docker build -t pdc.io/$1 ./build/$1/
endef

define docker_remove
	sudo docker stop $1 || true
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
