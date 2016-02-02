#!/bin/bash
#
# Run this script after the queries in steps 1-4 (masters1_run.sh) have completed.
#
set -e -o nounset


# Find and chanbge to script directory
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}


# Make sure providers are up to date
#
./providers.sh update


# 5., 6. Run importers
#
sudo docker exec -it composer /bin/bash -c 'cd /app/util/demographicsImporter/; QUERY_TITLE=PDC-001 RETRO_QUERY_TITLE=Retro-PDC-001 node demographicsImporter.js'
sudo docker exec -it composer /bin/bash -c 'cd /app/util/demographicsImporter/; QUERY_TITLE=PDC-1740 RETRO_QUERY_TITLE=Retro-PDC-1740 node demographicsImporter.js'
sudo docker exec -it composer /bin/bash -c 'cd /app/util/retroImporter/; QUERY_TITLE=PDC-1738 RETRO_QUERY_TITLE=Retro-PDC-1738 node retroImporter.js'
