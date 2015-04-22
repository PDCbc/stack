################
# General Jobs #
################
default: pull build run

all: pull build run

pull: pull-mongo pull-phusion

up: up-network up-support up-app

build: build-network build-support build-app

run: run-network run-endpoint-support run-app


###########
# Up Jobs #
###########
up-network:
	cd network
	docker-compose up &
	cd ..

up-support:
	cd support
	docker-compose up &
	cd ..

up-app:
	cd app
	docker-compose up &
	cd ..


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
	cd network
	docker-compose build
	cd ..

build-support:
	cd support
	docker-compose build
	cd ..

build-app:
	cd app
	docker-compose build
	cd ..


############
# Run Jobs #
############
run-network:
	cd network
	docker-compose run &
	cd ..

run-support:
	cd support
	docker-compose run &
	cd ..

run-app:
	cd app
	docker-compose run &
	cd ..
