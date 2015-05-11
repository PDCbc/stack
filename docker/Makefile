###############
# General Jobs #
################
default: environment build up

all: environment build up

up: up-data up-network up-app import

build: build-data build-network build-app

remove: remove-app remove-network remove-data

environment: config-env

import: up-importer


###########
# Up Jobs #
###########
up-data:
	sudo docker-compose -f data/data.yml up -d

up-network:
	sudo docker-compose -f network/network.yml up -d
	INSERT='{ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "$$2a$$10$$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true }'; \
	INSERT="--eval 'db.users.insert( $${INSERT} )'"; \
	/bin/bash -c "sudo docker exec data_hubdb_1 mongo query_composer_development $${INSERT}"

up-app:
	sudo docker-compose -f app/app.yml up -d

up-importer:
	sudo docker build -t importer extras/queryImporter/
	sudo docker run -dt --name importer -h importer --link data_hubdb_1:hubdb importer
	sudo docker exec -dt importer /app/setup.sh
	sudo docker rm -fv importer

up-endpoint:
	@echo ""
	@echo "Gateway ID (#): "
	@read gID; \
	echo "Clinician ID (#####): "; \
	read cID; \
	./extras/endpoint/up-endpoint.sh $${gID} $${cID} ep$${gID}


#################
# Configuration #
#################
config-env:
	extras/config-env.sh


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
remove-data:
	sudo docker-compose -f data/data.yml stop
	sudo docker-compose -f data/data.yml rm -f

remove-network:
	sudo docker-compose -f network/network.yml stop
	sudo docker-compose -f network/network.yml rm -f

remove-app:
	sudo docker-compose -f app/app.yml stop
	sudo docker-compose -f app/app.yml rm -f

remove-endpoint:
	@echo ""
	@echo "Please enter a gatewayID (#) to remove: "
	@read gID; \
	./extras/endpoint/remove-endpoint.sh $${gID}
