#!/bin/bash
#


# Add endpoints to mongo
#
mongo query_composer_development --port 27019 --eval 'db.endpoints.insert({"name":"ep-0", "base_url":"http://10.0.2.2:40000"})'
mongo query_composer_development --port 27019 --eval 'db.endpoints.insert({"name":"ep-1", "base_url":"http://10.0.2.2:40001"})'
mongo query_composer_development --port 27019 --eval 'db.endpoints.insert({"name":"ep-2", "base_url":"http://10.0.2.2:40002"})'


# Add admin account
#
mongo query_composer_development --port 27019 --eval 'db.users.insert({
	"first_name" : "PDC",
	"last_name" : "Admin",
	"username" : "pdcadmin",
	"email" : "pdcadmin@pdc.io",
	"encrypted_password" : "$2a$10$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.",
	"agree_license" : true,
	"approved" : true,
	"admin" : true
})'
