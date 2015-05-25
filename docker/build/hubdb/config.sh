#!/bin/bash
#
# Admin config stript for the PDC's HubDB (MongoDB) service


# Exit on errors or unitialized variables
#
set -e -o nounset


# Set key (for duplicates) and import pdcadmin account
#
EVAL1="printjson( db.users.ensureIndex({ username : 1 }, { unique : true }))"
EVAL2='db.users.insert({ "first_name" : "PDC", "last_name" : "Admin", "username" : "pdcadmin", "email" : "pdcadmin@pdc.io", "encrypted_password" : "$2a$10$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true })'
/bin/bash -c "mongo query_composer_development --eval '${EVAL1}'"
/bin/bash -c "mongo query_composer_development --eval '${EVAL2}'"
