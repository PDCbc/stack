#!/bin/bash

# Exit on errors and trace (print) exections
#
set -e -x

cd ./hubapi
npm install
PORT=9080 MONGO_URI=mongodb://localhost:27019/query_composer_development npm start
