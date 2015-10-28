#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Script requires a providers.csv file be provided as an argument!"
	echo "No changes made, exiting..."
	exit
fi

OLDIFS=$IFS #store old file seperator just in case.
IFS=","  #set our file seperator to comma

GROUPS_FILE="/pdc/data/config/groups/groups.json"
JURI="TEST"

count=0
provider_hash=0

while read username cpsid group attachment pphrr populationhealth practicereflection pass extra
do
	# do not count the first line.

	if [ $count == 0 ]; then
		count=$((count+1))
		continue
	fi

	# get the hash for the provider.

	provider_hash=`echo -n "$cpsid" | openssl dgst -binary -sha224 | openssl base64`

	echo $count":"$username","$cpsid","$group","$provider_hash",$pass, $extra"

	#update the user in dacs
	sudo docker exec auth /app/manage_users.sh $username $provider_hash $group $JURI $pass

	#update the user to filter providers function in queries via the HAPI container.
	if [ $attachment != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash Attachment 
		sudo ./add_user_to_group.py $provider_hash "\""$attachment"\"" "Attachment" $GROUPS_FILE
	fi
	if [ $pphrr != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash PPhRR 
		sudo ./add_user_to_group.py $provider_hash "\""$pphrr"\"" "PPhRR" $GROUPS_FILE
	fi
	if [ $populationhealth != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash PopulationHealth 
		sudo ./add_user_to_group.py $provider_hash "\""$populationhealth"\"" "PopulationHealth" $GROUPS_FILE
	fi
	if [ $practicereflection != 0 ]; then 
		sudo docker exec hapi node /app/util/update_filter_providers.js $provider_hash PracticeReflection
		sudo ./add_user_to_group.py $provider_hash "\""$practicereflection"\"" "PracticeReflection" $GROUPS_FILE
	fi

	count=$((count+1))

done < $1

IFS=$OLDIFS # make sure we set the file seperator back.
