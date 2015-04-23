#!/bin/bash

TARGET=$1
docker rm -fv $TARGET 
make build-$TARGET
make run-$TARGET
#sleep 5
#docker ps
sleep 10
docker logs $TARGET
