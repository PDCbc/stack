#!/bin/bash
#
set -e -o nounset

sudo docker exec hapi /app/queryImporter/import_queries.sh
