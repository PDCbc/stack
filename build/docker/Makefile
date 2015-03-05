################
# General Jobs #
################
default: pull build run

all: pull build run

pull: pull-mongo pull-phusion

build: build-hub build-endpoint

run: run-hub run-endpoint-set

clean: docker rmi phydac/endpoint

############
# Run Jobs #
############
run-hub:
	docker run -d -t -i --name hub-db -h hub-db --restart='always' -p 27019:27017 mongo
	docker run -d -t -i --name hub -h hub --restart='always' -p 3002:3002 --link hub-db:database phydac/hub

run-endpoint:
	echo ""
	echo "Please enter a gatewayID (#) to run: "; \
	read gID; \
	epName=pdc-$$gID; \
	dbName=$$epName-db; \
	epPort=`expr 40000 + $$gID`; \
	docker run -dti --name $$dbName -h $$dbName --restart='always' mongo --smallfiles; \
	docker run -dti --name $$epName -h $$epName --restart='always' -p $$epPort:3001 --link hub:hub --link $$dbName:database phydac/endpoint

run-endpoint-set:
	docker run -dti --name pdc-0-db -h pdc-0-db --restart='always' -p 27020:27017 mongo --smallfiles
	docker run -dti --name pdc-1-db -h pdc-1-db --restart='always' -p 27021:27017 mongo --smallfiles
	docker run -dti --name pdc-2-db -h pdc-2-db --restart='always' -p 27022:27017 mongo --smallfiles
	docker run -dti --name pdc-0 -h pdc-0 --restart='always' -p 40000:3001 --link pdc-0-db:database --link hub:hub phydac/endpoint
	docker run -dti --name pdc-1 -h pdc-1 --restart='always' -p 40001:3001 --link pdc-1-db:database --link hub:hub phydac/endpoint
	docker run -dti --name pdc-2 -h pdc-2 --restart='always' -p 40002:3001 --link pdc-2-db:database --link hub:hub phydac/endpoint

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
	docker rm $$dbName || true; \
	docker rm $$epName || true

remove-set:
	docker stop pdc-2-db pdc-1-db pdc-0-db hub-db pdc-2 pdc-1 pdc-0 hub || true; \
	docker rm -v pdc-2-db pdc-1-db pdc-0-db hub-db pdc-2 pdc-1 pdc-0 hub || true

##############
# Build Jobs #
##############
build-hub:
	docker build -t phydac/hub hub/

build-endpoint:
	docker build -t phydac/endpoint endpoint/


#############
# Pull Jobs #
#############
pull-mongo:
	docker pull mongo

pull-phusion:
	docker pull phusion/passenger-ruby19
