################
# General Jobs #
################
default: up

all: environment up

pull: pull-phusion pull-mongo pull-node

up: up-network up-support up-app up-monitor config-data

build: build-network build-support build-app

environment: config-packages config-bash

destroy: destroy-app destroy-support destroy-network


###########
# Up Jobs #
###########
up-network:
	docker-compose -f network/network.yml up -d

up-support:
	docker-compose -f support/support.yml up -d

up-app:
	docker-compose -f app/app.yml up -d

up-monitor:
	sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest

up-endpoint:
	@echo ""; \
	echo "Gateway ID: "; \
	read gID; \
	echo "Clinician ID: "; \
	read cID; \
	scripts/up-endpoint.sh $${gID} $${cID}


#################
# Configuration #
#################
config-data:
	scripts/config-data.sh

config-bash:
	scripts/config-bash.sh

config-packages:
	scripts/config-package.sh


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
	@echo ""; \
	echo "Gateway ID: "; \
	read gID; \
	scripts/remove-endpoint.sh $${gID}
