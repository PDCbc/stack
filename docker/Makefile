################
# General Jobs #
################
default: environment up

all: environment up

up: up-data up-network up-app up-cadvisor

build: build-data build-network build-app

remove: remove-cadvisor remove-app remove-network remove-data

environment: config-env

import: import-ep

###########
# Up Jobs #
###########
up-data:
	docker-compose -f data/data.yml up -d

up-network:
	docker-compose -f network/network.yml up -d
	INSERT='{ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "$$2a$$10$$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true }'; \
	INSERT="--eval 'db.users.insert( $${INSERT} )'"; \
	/bin/bash -c "docker exec data_hubdb_1 mongo query_composer_development $${INSERT}"

up-app:
	docker-compose -f app/app.yml up -d

up-importer:
	docker build -t importer extras/queryImporter/
	docker run -dt --name importer -h importer --link data_hubdb_1:hubdb importer
	docker exec -it importer /app/setup.sh
	docker rm -fv importer

up-cadvisor:
	( docker rm -fv cadvisor )|| true
	docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest

up-endpoint:
	@echo ""
	@echo "Gateway ID (#): "
	@read gID; \
	echo "Clinician ID (#####): "; \
	read cID; \
	./extras/endpoint/up-endpoint.sh $${gID} $${cID}


#################
# Configuration #
#################
config-env:
	scripts/config-env.sh


##############
# Build Jobs #
##############
build-data:
	docker-compose -f data/data.yml build

build-network:
	docker-compose -f network/network.yml build

build-app:
	docker-compose -f app/app.yml build


###############
# Remove Jobs #
###############
remove-cadvisor:
	docker rm -fv cadvisor

remove-data:
	docker-compose -f data/data.yml stop
	docker-compose -f data/data.yml rm -f

remove-network:
	docker-compose -f network/network.yml stop
	docker-compose -f network/network.yml rm -f

remove-app:
	docker-compose -f app/app.yml stop
	docker-compose -f app/app.yml rm -f

remove-endpoint:
	@echo ""
	@echo "Please enter a gatewayID (#) to remove: "
	@read gID; \
	./extras/endpoint/remove-endpoint.sh $${gID}
