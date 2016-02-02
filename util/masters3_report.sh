#!/bin/bash
#
# Run this script after the queries in steps 1-4 (masters1_run.sh) have completed.
#
set -e -o nounset


# 7., 8. Run reports
#
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-001 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-001 GROUP=\"YVR-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1740 GROUP=\"FNW-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1740 GROUP=\"YVR-attachment\" EXECUTION_DATE=24 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1738 GROUP=\"FNW-attachment\" EXECUTION_DATE=27 node generateReports.js'
sudo docker exec -t hapi /bin/bash -c 'cd /app/lib/util/; QUERY=PDC-1738 GROUP=\"YVR-attachment\" EXECUTION_DATE=27 node generateReports.js'



# 9. Move reports to Docker volumes and remove quotes from names
#
sudo docker exec -t hapi /bin/bash -c 'mv /app/lib/util/*.csv /volumes/reports/'
sudo rename -v 's/\"//' /pdc/data/private/reports/*.csv
sudo rename -v 's/\"/_/' /pdc/data/private/reports/*.csv
