#########################
# Environment Variables #
#########################
include config.env

ifeq ($(DEV_MODE), true)
	AUTH_DOC += $(AUTH_DEV)
	DCLAPI_DOC += $(DCLAPI_DEV)
	EP_DOC += $(EP_DEV)
	HAPI_DOC += $(HAPI_DEV)
	HUB_DOC += $(HUB_DEV)
	HUBDB_DOC += $(HUBDB_DEV)
	QI_DOC += $(QI_DEV)
	VIZ_DOC += $(VIZ_DEV)
endif


#############
# Functions #
#############
define dockerize
	sudo docker rm -fv $1 || true
	sudo docker build -t pdc.io/$1 ./build/$1/
	sudo docker run -d --name $1 -h $1 --env-file=config.env --restart='always' $2 pdc.io/$1
endef


################
# General Jobs #
################
default: all

all: dependencies pull build up

dependencies: dep

up: auth hubdb dclapi hub hapi viz queries ep-sample

import: queries

endpoint: ep

remove: rm-all


############
# Modes #
############
dev:
	@sed -i -e "s/DEV_MODE=.*/DEV_MODE=true/" config.env
	@cat config.env | grep DEV_MODE

prod:
	@sed -i -e "s/DEV_MODE=.*/DEV_MODE=false/" config.env
	@cat config.env | grep DEV_MODE


############
# Shotcuts #
############
q: queries
e: ep
f: rm-ep
r: remove


#################
# Configuration #
#################
dep:
		./dependencies/dependencies.sh


#############
# Pull Jobs #
#############
pull:
	sudo docker pull mongo
	sudo docker pull phusion/baseimage


##############
# Containers #
##############
auth:
	$(call dockerize,auth,$(AUTH_DOC))
	sudo mkdir -p $(PATH_HOST)/dacs/

hubdb:
	$(call dockerize,hubdb,$(HUBDB_DOC))
	sudo mkdir -p $(PATH_HOST)/mongo/
	sudo docker exec hubdb /app/config.sh

dclapi:
	$(call dockerize,dclapi,$(DCLAPI_DOC))

hub:
	$(call dockerize,hub,$(HUB_DOC))
	sudo mkdir -p $(PATH_HOST)/keys/
	sudo touch $(PATH_HOST)/keys/authorized_keys

hapi:
	$(call dockerize,hapi,$(HAPI_DOC))

viz:
	$(call dockerize,viz,$(VIZ_DOC))

queries:
	$(call dockerize,queries,$(QI_DOC))
	sudo docker exec queries /app/app.sh pdcadmin
	sudo docker rm -fv queries

ep-sample:
	sudo docker rm -fv ep0db ep0 || true
	export PATH_KEYS=$(PATH_KEYS); \
	export HUB_URL=$(HUB_URL); \
	./build/add-endpoint.sh 0 cpsid ep0 TEST sample

ep:
	@echo ""
	@echo "Gateway ID (#): "
	@read gID; \
	echo "Clinician ID (#####): "; \
	read cID; \
	export PATH_KEYS=$(PATH_KEYS); \
	export HUB_URL=$(HUB_URL); \
	./build/add-endpoint.sh $${gID} $${cID} ep$${gID}


###############
# Remove Jobs #
###############
rm-ep:
	@echo "";
	@echo "Please enter a gatewayID (#) to rm: "
	@read gID; \
	echo sudo docker rm -fv ep$${gID} ep$${gID}db; \
	EVAL="db.endpoints.remove({ \"base_url\" : \"http://localhost:$$((40000 + $$gID))\" })"; \
	/bin/bash -c "sudo docker exec hubdb mongo query_composer_development --eval '$${EVAL}'"

rm-all:
	@( sudo docker rm -fv `sudo docker ps -a -q` )|| echo "No containers to delete"
