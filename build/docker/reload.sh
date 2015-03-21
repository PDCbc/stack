#!/bin/bash

docker stop auth
docker rm -v auth
make build-auth
make run-auth
