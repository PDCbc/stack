###############
# General Jobs #
################

default: pull build run

all: pull build run

pull: pull-mongo pull-phusion

build: build-visualizer build-hubapi build-hub build-endpoint

run: run-hub run-endpoint run-hubapi run-visualizer

remove: remove-endpoint remove-hub remove-visualizer remove-hubapi

clean: docker rmi pdc/hub pdc/endpoint pdc/visualizer pdc/hubapi


############
# Run Jobs #
############

run-hubapi:
	docker run -d -t -i --name hubapi -p 8081:8080 --link hub-db:hub-db hubapi

run-visualizer:
	docker run -d -t -i --name visualizer -p 8082:8081 --link hubapi:hubapi visualizer

run-hub:
	docker run -d -t -i --name hub-db -p 27019:27017 mongo
	docker run -d -t -i --name hub -p 8083:3002 --link hub-db:database pdc/hub
	sleep 20
	mongorestore -v --port 27019 hub/db #restore the first user - requires that mongo is installed on the host

run-endpoint:
	docker run -d -t -i --name endpoint-db -p 27020:27017 mongo
	docker run -d -t -i --name endpoint -p 8084:3001 --link hub:hub --link endpoint-db:database pdc/endpoint


###############
# Remove Jobs #
###############

remove-endpoint:
	docker stop endpoint-db || true
	docker stop endpoint || true
	docker rm -v endpoint-db || true
	docker rm -v endpoint || true

remove-hub:
	docker stop hub-db || true
	docker stop hub || true
	docker rm -v hub-db || true
	docker rm -v hub || true

remove-visualizer:
	docker stop visualizer-db || true
	docker stop visualizer || true
	docker rm -v visualizer-db || true
	docker rm -v visualizer || true

remove-hubapi:
	docker stop hubapi || true
	docker rm -v hubapi || true


##############
# Build Jobs #
##############

build-hubapi:
	docker build -t hubapi hubapi/

build-visualizer:
	docker build -t visualizer visualizer/

build-hub:
	docker build -t pdc/hub hub/

build-endpoint:
	docker build -t pdc/endpoint endpoint/


#############
# Pull Jobs #
#############

pull-mongo:
	docker pull mongo

pull-wildfly:
	docker pull jboss/keycloak-adapter-wildfly

pull-keycloak:
	docker pull jboss/keycloak

pull-phusion:
		docker pull phusion/passenger-ruby19
