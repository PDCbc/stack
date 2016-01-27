#!/bin/bash
#
set -e -o nounset


# 1. Clear retro excutions
#
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "Retro-PDC-001" },{ $set :{ executions : [] }}, {} );'
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "Retro-PDC-1740" },{ $set :{ executions : [] }}, {} );'
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "Retro-PDC-1738" },{ $set :{ executions : [] }}, {} );'


# 2. Clear non-retro executions (was #3)
#
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "PDC-001" },{ $set :{ executions : [] }}, {} );'
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "PDC-1740" },{ $set :{ executions : [] }}, {} );'
sudo docker exec hubdb mongo query_composer_development --eval 'db.queries.update({ title : "PDC-1738" },{ $set :{ executions : [] }}, {} );'


# 3. Run retro queries (was #2), then
# 4. ...run non-retro queries (in .JSON config file)
#
sudo docker exec -it composer /bin/bash -c 'cd /app/util/; ./scheduled_job_post.py ./job_params/master_job_params.json'


# 5. Run retroImporter.js
#
sudo docker exec -it composer /bin/bash -c 'cd /app/util/retroImporter/; QUERY_TITLE=PDC-1738 RETRO_QUERY_TITLE=Retro-PDC-1738 node retroImporter.js'


# 6. Run the demographicsImporter.js
#
sudo docker exec -it composer /bin/bash -c 'cd /app/util/demographicsImporter/; QUERY_TITLE=PDC-001 RETRO_QUERY_TITLE=Retro-PDC-001 node demographicsImporter.js'
sudo docker exec -it composer /bin/bash -c 'cd /app/util/demographicsImporter/; QUERY_TITLE=PDC-1740 RETRO_QUERY_TITLE=Retro-PDC-1740 node demographicsImporter.js'


# 7. Run generateReports.js, which calls masterReport.js and AttachedActivePatientReport.js
#
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-001 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1740 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'


# 8. Run generateReports.js, which calls masterReport.js and AttachedActivePatientReport.js
#
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1738 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'


# Move reports to Docker volumes
#
sudo docker exec -t hapi /bin/bash -c 'mv /app/lib/util/*.csv /volumes/reports/'
