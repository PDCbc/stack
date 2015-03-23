#!/bin/bash

docker rm -fv dclapi
make build-dclapi
make run-dclapi
sleep 5
docker ps
