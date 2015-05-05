#!/bin/bash
#
set -e -o nounset


# Script directory, useful for running scripts from scripts
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# Npm deoendencies for importer, import to Mongo
#
cd $DIR
npm install assert async fs minimist mongodb mongoose --save
nodejs queryImporter import --mongo-host=127.0.0.1 --mongo-db=query_composer_development --mongo-port=27019
