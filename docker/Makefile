################
# General Jobs #
################
default: up

all: environment up

pull: pull-phusion pull-mongo pull-node

up: up-network up-support up-app config-data

build: build-network build-support build-app

stop: stop-app stop-support stop-network

remove: remove-app remove-support remove-network

environment: config-packages config-bash

bash: config-bash

packages: config-packages

destroy: stop remove


###########
# Up Jobs #
###########
up-network:
	docker-compose -f network/network.yml up -d

up-support:
	docker-compose -f support/support.yml up -d

up-app:
	docker-compose -f app/app.yml up -d

up-endpoint:
	@echo ""
	@echo "Please enter a gatewayID (#) to run: "
	@read gID; \
	EPNAME=ep$${gID}; \
	DBNAME=ep$${gID}db; \
	EPPORT=`expr 40000 + $${gID}`; \
	docker run -dt --name $${DBNAME} -h $${DBNAME} --restart='always' mongo --smallfiles; \
	docker run -dt --name $${EPNAME} -h $${EPNAME} --restart='always' -p $${EPPORT}:3001 --link network_hub_1:hub --link $${DBNAME}:epdb network_ep0; \
	INSERT='{ "name" : "'$${EPNAME}'", "base_url" : "http://10.0.2.2:'$${EPPORT}'" }'; \
	INSERT="--eval 'db.endpoints.insert($${INSERT})'"; \
	INSERT=`echo docker exec network_hubdb_1 mongo query_composer_development $${INSERT}`; \
	/bin/bash -c "$${INSERT}"


#################
# Configuration #
#################
config-data:
	scripts/data-config.sh

config-bash:
	scripts/bash-config.sh

config-packages:
	scripts/package-config.sh


#############
# Pull Jobs #
#############
pull-mongo:
	docker pull mongo

pull-phusion:
	docker pull phusion/passenger-ruby19

pull-node:
	docker pull node


##############
# Build Jobs #
##############
build-network:
	docker-compose -f network/network.yml build

build-support:
	docker-compose -f support/support.yml build

build-app:
	docker-compose -f app/app.yml build


#############
# Stop Jobs #
#############
stop-network:
	docker-compose -f network/network.yml stop

stop-support:
	docker-compose -f support/support.yml stop

stop-app:
	docker-compose -f app/app.yml stop


################
# Destroy Jobs #
################
destroy-network:
	docker-compose -f network/network.yml stop
	docker-compose -f network/network.yml rm -f

destroy-support:
	docker-compose -f support/support.yml stop
	docker-compose -f support/support.yml rm -f

destroy-app:
	docker-compose -f app/app.yml stop
	docker-compose -f app/app.yml rm -f


###############
# Remove Jobs #
###############
remove-network:
	docker-compose -f network/network.yml rm -f

remove-support:
	docker-compose -f support/support.yml rm -f

remove-app:
	docker-compose -f app/app.yml rm -f

remove-endpoint:
	@echo ""
	@echo "Please enter a gatewayID (#) to remove: "
	@read gID; \
	EPNAME=ep$${gID}; \
	DBNAME=ep$${gID}db; \
	docker stop  $${EPNAME} $${DBNAME}; \
	docker rm -v $${EPNAME} $${DBNAME}; \
	REMOVE='{ "name" : "'$${EPNAME}'" }'; \
	REMOVE="'db.endpoints.remove( $${REMOVE} )'"; \
	REMOVE=`echo docker exec network_hubdb_1 mongo query_composer_development --eval $${REMOVE}`; \
	/bin/bash -c "$${REMOVE}"
