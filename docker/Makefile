################
# General Jobs #
################
default: up

all: up

pull: pull-phusion pull-mongo pull-node

up: up-network up-support up-app

build: build-network build-support build-app

run: run-network run-endpoint-support run-app

stop: stop-app stop-support stop-network

remove: remove-app remove-support remove-network

destroy: stop remove


###########
# Up Jobs #
###########
up-network:
	docker-compose -f network/docker-compose.yml up -d

up-support:
	docker-compose -f network/docker-support.yml up -d

up-app:
	docker-compose -f network/docker-app.yml up -d


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
