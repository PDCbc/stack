#!/bin/bash
#
# Run this script after the queries in steps 1-4 (masters1_run.sh) have completed.
#
set -e -o nounset


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
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1738 GROUP=\"FNW-attachment\" EXECUTION_DATE=27 node generateReports.js'


# 9. Move reports to Docker volumes
#
sudo docker exec -t hapi /bin/bash -c 'mv /app/lib/util/*.csv /volumes/reports/'
