#!/bin/bash
#
set -e -o nounset


# Set varaibles
#
COMMAND=${1:-"exit"}
PROVIDERS_FILE=${2:-"/pdc/data/private/providers/providers.csv"}
#
GROUPS_FILE=${GROUPS_FILE:-"/pdc/data/config/groups/groups.json"}
JURI=${JURI:-"TEST"}
PROVIDERS_TEMP=PROVIDERS_TEMP.csv


# Check input
#
if([ "${COMMAND}" != "add" ]&&[ "${COMMAND}" != "update" ])
then
	echo
	echo "Usage:"
	echo
	echo "./providers.sh [COMMAND]"
	echo
	echo "Commands:"
	echo " add    - adds a single provider, prompts for details"
	echo " update - updates providers from a CSV"
	echo "          defaults to "${PROVIDERS_FILE}
	exit
fi


# Obrain providers file
#
sudo cp ${PROVIDERS_FILE} ${PROVIDERS_TEMP}
sudo chown $(whoami):$(whoami) ${PROVIDERS_TEMP}


# Add user fir COMMAND=add
#
if [ "${COMMAND}" == "add" ]
then
	# Prep variables
	#
	PASSWORD="this"
	PASSWORD_2="that"
	RESP="n"


	# Loop until user confirms out
	#
	while [ "${RESP}" != "y" ]
	do
		# Ger user details, making sure password match
		#
		echo ""
		echo "User (auto-pads numbers)"
		read -p "              Login: " USERNAME
		read -p "             CPSID#: " CPSID
		read -p "           Gateway#: " GATEWAY_NO
		while [ ${PASSWORD} != ${PASSWORD_2} ]
		do
			read -s -p "           Password: " PASSWORD
			echo
			read -s -p "           (repeat): " PASSWORD_2
			echo
		done


		# Verify CPSID is five digits and set endpoint name from gateway_id
		#
		CPSID=$(printf "%05d" ${CPSID})
		EP=pdc-$(printf "%04d" ${GATEWAY_NO})


		# Getgroup details
		#
		echo "Groups (blank for default)"
		read -p "         Attachment: " ATTACHMENT_GROUP
		read -p "       Polypharmacy: " PPHRR_GROUP
		read -p "Practice Reflection: " PR_GROUP
		read -p "  Population Health: " PH_GROUP


		# Set group defaults
		#
		ATTACHMENT_GROUP=${ATTACHMENT_GROUP:-"attch-default"}
		PPHRR_GROUP=${PPHRR_GROUP:-"pphrr-default"}
		PR_GROUP=${PR_GROUP:-"pr-default"}
		PH_GROUP=${PH_GROUP:-"ph-default"}


		# CheConfirm details with user
		#
		echo
		echo "Confirm User"
		echo "              Login: ${USERNAME}"
		echo "              CPSID: ${CPSID}"
		echo "           Endpoint: ${EP}"
		echo
		echo "Confirm Groups"
		echo "         Attachment: ${ATTACHMENT_GROUP}"
		echo "       Polypharmacy: ${PPHRR_GROUP}"
		echo "Practice Reflection: ${PR_GROUP}"
		echo "  Population Health: ${PH_GROUP}"
		echo
		read -p "Correct? [y|n]: " RESP
	done


	# Comment out if username/cpsid in providers.csv (copied as ${PROVIDERS_TEMP})
	#
	if( grep --quiet "^${USERNAME},${CPSID}," ./${PROVIDERS_TEMP} )
	then
		sudo sed -i.bk_$(date +%F_%H:%M) "s/^${USERNAME},${CPSID},/#${USERNAME},${CPSID},/" ${PROVIDERS_FILE}
	fi

	# Prep ${PROVIDERS_TEMP} with new entry and append to original providers.csv
	#
	echo "$USERNAME,$CPSID,$EP,$ATTACHMENT_GROUP,$PPHRR_GROUP,$PH_GROUP,$PR_GROUP,$PASSWORD,10" | tee ./${PROVIDERS_TEMP}
	cat ${PROVIDERS_TEMP} | sudo tee -a ${PROVIDERS_FILE}
fi


# Iterate through providers.csv (IFS = Input File Separator)
#
OLDIFS=$IFS
IFS=","
#
while read USERNAME CPSID GROUP ATTACHMENT PPHRR POPULATIONHEALTH PRACTICEREFLECTION PASSWORD COUNTER
do
	# Skip commented lines
	#
	[[ ${USERNAME} != \#* ]]|| continue


	# get the provider hash and clean up password
	#
	PROVIDER_HASH=`echo -n "$CPSID" | openssl dgst -binary -sha224 | openssl base64`
	PASSWORD=`echo ${PASSWORD} | xargs`

	#update the user in DACS
	#
	sudo docker exec auth /app/manage_users.sh "${USERNAME}" "${PROVIDER_HASH}" "${GROUP}" "${JURI}" $(echo ${PASSWORD})

	#  Add user to filger_providers and GROUPs
	#
	if [ ${ATTACHMENT} != 0 ]; then
		sudo docker exec hapi node /app/util/update_filter_providers.js ${PROVIDER_HASH} Attachment
		sudo ./providers/add_user_to_group.py ${PROVIDER_HASH} "\""${ATTACHMENT}"\"" "Attachment" ${GROUPS_FILE}
	fi
	if [ ${PPHRR} != 0 ]; then
		sudo docker exec hapi node /app/util/update_filter_providers.js ${PROVIDER_HASH} PPhRR
		sudo ./providers/add_user_to_group.py ${PROVIDER_HASH} "\""${PPHRR}"\"" "PPhRR" ${GROUPS_FILE}
	fi
	if [ ${PRACTICEREFLECTION} != 0 ]; then
		sudo docker exec hapi node /app/util/update_filter_providers.js ${PROVIDER_HASH} PopulationHealth
		sudo ./providers/add_user_to_group.py ${PROVIDER_HASH} "\""${POPULATIONHEALTH}"\"" "PopulationHealth" ${GROUPS_FILE}
	fi
	if [ ${PRACTICEREFLECTION} != 0 ]; then
		sudo docker exec hapi node /app/util/update_filter_providers.js ${PROVIDER_HASH} PracticeReflection
		sudo ./providers/add_user_to_group.py ${PROVIDER_HASH} "\""${PRACTICEREFLECTION}"\"" "PracticeReflection" ${GROUPS_FILE}
	fi

done < ${PROVIDERS_TEMP}


# Cleanup
#
sudo rm ${PROVIDERS_TEMP}
IFS=$OLDIFS # make sure we set the file seperator back.
