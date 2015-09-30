#!/usr/bin/python

#######
# Takes 2 parameters: hashed_id, group_name, path_to_groups_json_file
######

import json
import sys

provider = None
group = None
path = None

if len(sys.argv) != 4:
	print "3 arguments expected, got "+str(len(sys.argv)-1)
	sys.exit(1)
else:
	provider = str(sys.argv[1])	
	group = str(sys.argv[2])	
	path = str(sys.argv[3])	

groups_file = open(path, "r+")

try:
	groups = json.loads(groups_file.read())

except Exception as e:
	print "Invalid json provided in "+str(path)+", failed to import."
	sys.exit(1)

flag = False

for g in groups:
	if g["name"] == group:
		if provider not in g['members']:
			g["members"].append(provider)
		flag=True


if not flag: #i.e. they did not get added to group, likely b/c group name did not exist.
	tmp = dict()
	tmp['name'] = group
	tmp['members'] = [provider]
	groups.append(tmp)

groups_file.seek(0)
groups_file.write(json.dumps(groups))
groups_file.truncate()

groups_file.close()
