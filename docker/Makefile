################
# General Jobs #
################
default: environment up

all: environment up

pull: pull-mongo pull-phusion pull-phusionBaseImage pull-node

up: up-network up-support up-app config-data

build: build-network build-support build-app

environment: config-env

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

config-env:
	scripts/config-env.sh


#############
# Pull Jobs #
#############
pull-mongo:
	docker pull mongo

pull-phusion:
	docker pull phusion/passenger-ruby19

pull-phusionBaseImage:
	docker pull phusion/baseimage

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
