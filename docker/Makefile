################
# General Jobs #
################
default: pull build run

all: pull build run

pull: pull-mongo pull-phusion

build: build-hub build-endpoint build-auth build-dclapi build-hubapi build-visualizer

run: run-hub run-endpoint-set run-auth run-dclapi run-hubapi run-visualizer

destroy: destroy-all

############
# Run Jobs #
############
run-hub:
	docker run -dt --name hub-db -h hub-db --restart='always' -p 27019:27017 mongo
	docker run -dt --name hub    -h hub    --restart='always' -p 3002:3002 --link hub-db:database phydac/hub
	sleep 15
	scripts/configure-hub.sh
	docker restart hub

run-endpoint:
	echo ""
	echo "Please enter a gatewayID (#) to run: "
	read gID; \
	epName=pdc-$$gID; \
	dbName=$$epName-db; \
	epPort=`expr 40000 + $$gID`; \
	docker run -dt --name $$dbName   -h $$dbName   --restart='always' mongo --smallfiles; \
	docker run -dt --name $$epName   -h $$epName   --restart='always' -p $$epPort:3001 --link hub:hub --link $$dbName:database phydac/endpoint

run-endpoint-set:
	docker run -dt --name pdc-0-db   -h pdc-0-db   --restart='always' -p 27020:27017 mongo --smallfiles
	docker run -dt --name pdc-1-db   -h pdc-1-db   --restart='always' -p 27021:27017 mongo --smallfiles
	docker run -dt --name pdc-2-db   -h pdc-2-db   --restart='always' -p 27022:27017 mongo --smallfiles
	docker run -dt --name pdc-0      -h pdc-0      --restart='always' -p 40000:3001 --link pdc-0-db:database --link hub:hub phydac/endpoint
	docker run -dt --name pdc-1      -h pdc-1      --restart='always' -p 40001:3001 --link pdc-1-db:database --link hub:hub phydac/endpoint
	docker run -dt --name pdc-2      -h pdc-2      --restart='always' -p 40002:3001 --link pdc-2-db:database --link hub:hub phydac/endpoint
	sleep 5
	scripts/configure-endpoint-set.sh

run-auth:
	docker run -dt --name auth       -h auth       --restart='always' -p 3006:3006 phydac/auth

run-dclapi:
	docker run -dt --name dclapi     -h dclapi     --restart='always' phydac/dclapi

run-hubapi:
	docker run -dt --name hubapi     -h hubapi     --restart='always' --link hub-db:hub-db --link auth:auth --link dclapi:dclapi phydac/hubapi

run-visualizer:
	docker run -dt --name visualizer -h visualizer --restart='always' -p 3004:3004 --link auth:auth --link hubapi:hubapi phydac/visualizer


################
# Destroy Jobs #
################
destroy-all:
	docker rm -fv hub-db hub pdc-2-db pdc-1-db pdc-0-db pdc-2 pdc-1 pdc-0 visualizer hubapi dclapi auth


###############
# Remove Jobs #
###############
remove-endpoint:
	echo "Please enter a gatewayID (#) to remove: "; \
	read gID; \
	epName=pdc-$$gID; \
	dbName=$$epName-db; \
	docker stop $$dbName || true; \
	docker stop $$epName || true; \
	docker rm   $$dbName || true; \
	docker rm   $$epName || true

remove-endpoint-set:
	docker stop  pdc-2-db pdc-1-db pdc-0-db hub-db pdc-2 pdc-1 pdc-0 hub || true; \
	docker rm -v pdc-2-db pdc-1-db pdc-0-db hub-db pdc-2 pdc-1 pdc-0 hub || true


##############
# Build Jobs #
##############
build-hub:
	docker build -t phydac/hub        hub/

build-endpoint:
	docker build -t phydac/endpoint   endpoint/

build-auth:
	docker build -t phydac/auth       auth/

build-dclapi:
	docker build -t phydac/dclapi     dclapi/

build-hubapi:
	docker build -t phydac/hubapi     hubapi/

build-visualizer:
	docker build -t phydac/visualizer visualizer/


#############
# Pull Jobs #
#############
pull-mongo:
	docker pull mongo

pull-phusion:
	docker pull phusion/passenger-ruby19

pull-node:
	docker pull node
