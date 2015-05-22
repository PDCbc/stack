################
# General Jobs #
################
default: build up queries

all: environment pull build up queries

up: up-data up-network up-app

pull: pull-phusion pull-mongo

build: build-data build-network build-app

remove: rm-everything

environment: config-environment

queries: config-queries

endpoint: up-endpoint

reset: remove build up queries up-endpoint

noninteractive: environment pull build up config-queries-noninteractive


############
# Shotcuts #
############
u: up
r: remove
t: reset
q: queries
e: up-endpoint
f: rm-endpoint
d: rm-data build-data up-data
n: rm-network build-network up-network
a: rm-app build-app up-app


###########
# Up Jobs #
###########
up-data:
	sudo docker-compose -f data/data.yml up -d
	SH_CMD="sudo docker exec data_hubdb_1 mongo query_composer_development"; \
	JSON_1="printjson( db.users.ensureIndex({ username : 1 }, { unique : true }))"; \
	JSON_2='db.users.insert({ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "$$2a$$10$$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true })'; \
	/bin/bash -c "$${SH_CMD} --eval '$${JSON_1}'"; \
	/bin/bash -c "$${SH_CMD} --eval '$${JSON_2}'"

up-network:
	sudo docker-compose -f network/network.yml up -d

up-app:
	sudo docker-compose -f app/app.yml up -d

up-endpoint:
	( sudo docker exec network_hub_1 grep -q pdcadmin /etc/passwd )||( \
		echo ""; \
		echo "Please enter a password for pdcadmin on network_hub_1:"; \
		/bin/bash -c "sudo docker exec -dt network_hub_1 useradd pdcadmin -m -G sudo"; \
		/bin/bash -c "sudo docker exec -it network_hub_1 passwd pdcadmin"; \
	)
	@echo ""
	@echo "Gateway ID (#): "
	@read gID; \
	echo "Clinician ID (#####): "; \
	read cID; \
	./extras/endpoint/up-endpoint.sh $${gID} $${cID} ep$${gID}


##############
# Build Jobs #
##############
build-data:
	sudo docker-compose -f data/data.yml build

build-network:
	sudo docker-compose -f network/network.yml build

build-app:
	sudo docker-compose -f app/app.yml build


###############
# Remove Jobs #
###############
rm-data:
	sudo docker-compose -f data/data.yml stop
	sudo docker-compose -f data/data.yml rm -f

rm-network:
	sudo docker-compose -f network/network.yml stop
	sudo docker-compose -f network/network.yml rm -f

rm-app:
	sudo docker-compose -f app/app.yml stop
	sudo docker-compose -f app/app.yml rm -f

rm-endpoint:
	@echo ""
	@echo "Please enter a gatewayID (#) to rm: "
	@read gID; \
	./extras/endpoint/rm-endpoint.sh $${gID}

rm-everything:
	@( sudo docker rm -fv `sudo docker ps -a -q` )|| echo "No containers to delete"


#################
# Configuration #
#################
config-environment:
	extras/config-env.sh

config-queries:
	sudo docker build -t importer extras/queryImporter/
	sudo docker run -dt --name importer -h importer --env-file=config.env --link data_hubdb_1:hubdb importer
	sudo docker exec -it importer /app/app.sh pdcadmin
	sudo docker rm -fv importer


#############
# Pull Jobs #
#############
pull-mongo:
	sudo docker pull mongo

pull-phusion:
	sudo docker pull phusion/baseimage


############################
# Non-Interactive, Vagrant #
############################

config-queries-noninteractive:
	sudo docker build -t importer extras/queryImporter/
	sudo docker run -dt --name importer -h importer --env-file=config.env --link data_hubdb_1:hubdb importer
	sudo docker exec -i importer /app/app.sh pdcadmin
	sudo docker rm -fv importer


###############
# Development #
###############
auth:
	sudo docker rm -fv auth || true
	sudo docker build -t pdc.io/auth data/auth/
	. ./config.env; \
	CMD="$${AUTH_NAME} $${AUTH_OPEN} $${AUTH_RESTART} $${AUTH_VOLUMES}"; \
	sudo docker run -d --env-file=config.env $${CMD} pdc.io/auth

hubdb:
	sudo docker rm -fv hubdb || true
	. ./config.env; \
	CMD="$${HUBDB_NAME} $${HUBDB_OPEN} $${HUBDB_RESTART} $${HUBDB_VOLUMES}"; \
	sudo docker run -d -e "LC_ALL=C" $${CMD} mongo
	SH_CMD="sudo docker exec hub mongo query_composer_development"; \
	JSON_1="printjson( db.users.ensureIndex({ username : 1 }, { unique : true }))"; \
	JSON_2='db.users.insert({ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "$$2a$$10$$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true })'; \
	/bin/bash -c "$${SH_CMD} --eval '$${JSON_1}'"; \
	/bin/bash -c "$${SH_CMD} --eval '$${JSON_2}'"

dclapi:
	sudo docker rm -fv dclapi || true
	sudo docker build -t pdc.io/dclapi network/dclapi/
	. ./config.env; \
	CMD="$${DCLAPI_NAME} $${DCLAPI_OPEN} $${DCLAPI_RESTART} $${DCLAPI_VOLUMES}"; \
	sudo docker run -d $${CMD} pdc.io/dclapi

hub:
	sudo docker rm -fv hub || true
	sudo docker build -t pdc.io/hub network/hub/
	. ./config.env; \
	CMD="$${HUB_NAME} $${HUB_OPEN} $${HUB_RESTART} $${HUB_VOLUMES} $${HUB_LINK}"; \
	sudo docker run -d --env-file=config.env $${CMD} pdc.io/hub

hapi:
	sudo docker rm -fv hapi || true; \
	sudo docker build -t pdc.io/hapi app/hapi/; \
	. ./config.env; \
	CMD="$${HAPI_LINK} $${HAPI_NAME} $${HAPI_OPEN} $${HAPI_RESTART}"; \
	sudo docker run -d --env-file=config.env $${CMD} pdc.io/hapi

viz:
	sudo docker rm -fv viz || true; \
	sudo docker build -t pdc.io/viz app/viz/; \
	. ./config.env; \
	CMD="$${VIZ_LINK} $${VIZ_NAME} $${VIZ_OPEN} $${VIZ_RESTART}"; \
	sudo docker run -d --env-file=config.env $${CMD} pdc.io/viz

importer:
	sudo docker rm -fv importer || true; \
	sudo docker build -t pdc.io/importer extras/queryImporter/; \
	. ./config.env; \
	CMD="$${QI_LINK} $${QI_NAME} $${QI_OPEN} $${QI_RESTART}"; \
	sudo docker run -d --env-file=config.env $${CMD} pdc.io/importer
	sudo docker exec -it importer /app/app.sh pdcadmin
	sudo docker rm -fv importer
