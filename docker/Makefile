################
# General Jobs #
################
default: up

all: up

pull: pull-phusion pull-mongo pull-node

up: up-network up-support up-app configure

build: build-network build-support build-app

run: run-network run-endpoint-support run-app configure

stop: stop-app stop-support stop-network

remove: remove-app remove-support remove-network

destroy: stop remove


###########
# Up Jobs #
###########
up-network:
	docker-compose -f network/docker-compose.yml up -d

up-support:
	docker-compose -f support/docker-compose.yml up -d

up-app:
	docker-compose -f app/docker-compose.yml up -d

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
configure:
	scripts/config.sh


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
	docker-compose -f network/docker-compose.yml build

build-support:
	docker-compose -f support/docker-compose.yml build

build-app:
	docker-compose -f app/docker-compose.yml build


############
# Run Jobs #
############
run-network:
	docker-compose -f network/docker-compose.yml run -d

run-support:
	docker-compose -f support/docker-compose.yml run -d

run-app:
	docker-compose -f app/docker-compose.yml run -d


#############
# Stop Jobs #
#############
stop-network:
	docker-compose -f network/docker-compose.yml stop

stop-support:
	docker-compose -f support/docker-compose.yml stop

stop-app:
	docker-compose -f app/docker-compose.yml stop


###############
# Remove Jobs #
###############
remove-network:
	docker-compose -f network/docker-compose.yml rm -f

remove-support:
	docker-compose -f support/docker-compose.yml rm -f

remove-app:
	docker-compose -f app/docker-compose.yml rm -f

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
