# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM mongo


# Prepare config script/folder
#
WORKDIR /app/
RUN ( \
      echo "#!/bin/bash"; \
      echo "#"; \
      echo "#Admin config script for the PDC's HubDB (MongoDB) service"; \
      echo ""; \
      echo ""; \
      echo "# Halt on errors or unset variables"; \
      echo "#"; \
      echo "set -e -o nounset -x"; \
      echo ""; \
      echo ""; \
      echo "# Set key (for duplicates) and import pdcadmin account"; \
      echo "#"; \
      echo "EVAL1='printjson( db.users.ensureIndex({ username : 1 }, { unique : true }))'"; \
      echo "EVAL2='db.users.insert({ \"first_name\" : \"PDC\", \"last_name\" : \"Admin\", \"username\" : \"pdcadmin\", \"email\" : \"pdcadmin@pdc.io\", \"encrypted_password\" : \"\$2a\$10\$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.\", \"agree_license\" : true, \"approved\" : true, \"admin\" : true })'"; \
      echo "/bin/bash -c mongo query_composer_development --eval '\${EVAL1}'"; \
      echo "/bin/bash -c mongo query_composer_development --eval '\${EVAL2}'"; \
    )  \
      >> /app/config.sh
RUN chmod +x /app/config.sh
