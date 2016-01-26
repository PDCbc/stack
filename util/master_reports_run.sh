#!/bin/bash
#
set -e -o nounset


# Clear executions
#
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "PDC-001" },{ $set :{ executions : [] }}, {} );'
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "PDC-1740" },{ $set :{ executions : [] }}, {} );'
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "PDC-1738" },{ $set :{ executions : [] }}, {} );'


# Run demographics importer
#
sudo docker exec -it composer /bin/bash -c 'cd /app/util/demographicsImporter/; QUERY_TITLE=PDC-001 RETRO_QUERY_TITLE=Retro-PDC-001 node demographicsImporter.js'
sudo docker exec -it composer /bin/bash -c 'cd /app/util/demographicsImporter/; QUERY_TITLE=PDC-1740 RETRO_QUERY_TITLE=Retro-PDC-1740 node demographicsImporter.js'
sudo docker exec -it composer /bin/bash -c 'cd /app/util/retroImporter/; QUERY_TITLE=PDC-1738 RETRO_QUERY_TITLE=Retro-PDC-1738 node retroImporter.js'


# Run master report
#
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-001 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1740 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1738 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'
