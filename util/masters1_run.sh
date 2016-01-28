#!/bin/bash
#
# After the queries in steps 1-4 have completed, they can be compiled into
# reports using steps 5-9 (masters2_generate.sh).  Wait two hours.
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
