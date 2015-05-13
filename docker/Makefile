#################
# Source Config #
#################

include config.env


################
# General Jobs #
################
default: environment build up queries

all: default

up: up-data up-network up-app

build: build-data build-network build-app

remove: rm-app rm-network rm-data

environment: config-environment

queries: config-queries


############
# Shotcuts #
############

u: up
b: build
r: remove
d: rm-data build-data up-data
n: rm-network build-network up-network
a: rm-app build-app up-app
q: queries
e: eb eu
eu: up-endpoint
eb: build-endpoint
er: rm-endpoint


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

up-endpoint:
	( sudo docker exec network_hub_1 grep -q pdcadmin /etc/passwd )||( \
		echo ""; \
		echo "Please enter a password for pdcadmin on network_hub_1:"; \
		/bin/bash -c "sudo docker exec -dt network_hub_1 useradd pdcadmin -m -G sudo"; \
		/bin/bash -c "sudo docker exec -it network_hub_1 passwd pdcadmin" \
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

build-endpoint:
	sudo docker build -t endpoint extras/endpoint


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


#################
# Configuration #
#################
config-environment:
	extras/config-env.sh

config-queries:
	sudo docker build -t importer extras/queryImporter/
	sudo docker run -dt --name importer -h importer --link data_hubdb_1:hubdb importer
	sudo docker exec -it importer /app/setup.sh
	sudo docker rm -fv importer


############################
# Non-Interactive, Vagrant #
############################

noninteractive: environment build up config-queries-noninteractive

config-queries-noninteractive:
	sudo docker build -t importer extras/queryImporter/
	sudo docker run -dt --name importer -h importer --link data_hubdb_1:hubdb importer
	sudo docker exec -i importer /app/setup.sh
	sudo docker rm -fv importer
