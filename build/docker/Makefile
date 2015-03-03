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
# Config=> # Change hubInf for your hub! <DOMAIN_NAME>:<IP_ADDRESS> # <= Config #
############
run-hub:
	docker run -d -t -i --name hub-db -h hub-db --restart='always' mongo
	docker run -d -t -i --name hub -h hub-db --restart='always' -p 3002:3002 --link hub-db:database phydac/hub

run-endpoint:
	echo ""; \
	echo "Please enter a gatewayID (####) to run: "; \
	read gID; \
	epName=pdc-$$gID; \
	dbName=$$epName-db; \
	epPort=`expr 40000 + $$gID`; \
	docker run -dti --name $$dbName -h $$dbName --restart='always' mongo --smallfiles; \
	docker run -dti --name $$epName -h $$epName --restart='always' -p $$epPort:3001 --link hub:hub --link $$dbName:database phydac/endpoint

run-endpoint-set:
	docker run -dti --name pdc-0000-db -h pdc-0000-db --restart='always' mongo --smallfiles
	docker run -dti --name pdc-0001-db -h pdc-0001-db --restart='always' mongo --smallfiles
	docker run -dti --name pdc-0002-db -h pdc-0002-db --restart='always' mongo --smallfiles
	docker run -dti --name pdc-0000 -h pdc-0000 --restart='always' -p 40000:3001 --link hub:hub --link pdc-0000-db:database phydac/endpoint
	docker run -dti --name pdc-0001 -h pdc-0001 --restart='always' -p 40001:3001 --link hub:hub --link pdc-0001-db:database phydac/endpoint
	docker run -dti --name pdc-0002 -h pdc-0002 --restart='always' -p 40002:3001 --link hub:hub --link pdc-0002-db:database phydac/endpoint

###############
# Remove Jobs #
###############
remove-endpoint:
	echo "Please enter a gatewayID (####) to remove: "; \
	read gID; \
	epName=pdc-$$gID; \
	dbName=$$epName-db; \
	docker stop $$dbName || true; \
	docker stop $$epName || true; \
	docker rm $$dbName || true; \
	docker rm $$epName || true


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
