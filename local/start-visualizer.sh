#!/bin/bash

# Exit on errors and trace (print) exections
#
set -e -x

cd ./visualizer
npm install
HUBAPI_URL=https://localhost:9080 PORT=9081 NODE_TLS_REJECT_UNAUTHORIZED=0 npm start
