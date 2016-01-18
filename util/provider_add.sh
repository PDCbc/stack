#!/bin/bash

USERNAME=""
PASS=""
ATTACHMENT_GROUP=""
PPHRR_GROUP=""
PR_GROUP=""
PH_GROUP=""
CPSID=""
EP=""

echo ""
echo "This script will add or modify an existing provider to match the inputs."

echo ""

read -p "Enter the username for the provider: " USERNAME

read -s -p "Enter user's *new* password: " PASSWORD

echo ""

read -s -p "Enter user's *new* password again: " PASSWORD_2

echo ""

if [ $PASSWORD != $PASSWORD_2 ]; then
	echo ""
	echo "Passwords do not match!"
	echo "Exiting...."
	exit
fi

read -p "Enter the CPSID of the user: " CPSID

read -p "Enter the endpoint id for this user: " EP

read -p "Enter the group name for attachment (blank for default): " ATTACHMENT_GROUP

if [ -z $ATTACHMENT_GROUP ]; then
	ATTACHMENT_GROUP="attachment-default"
fi

read -p "Enter the group name for polypharmacy (blank for default): " PPHRR_GROUP

if [ -z $PPHRR_GROUP ]; then
	PPHRR_GROUP="polypharmacy-default"
fi

read -p "Enter the group name for practice reflection (blank for default): " PR_GROUP

if [ -z $PR_GROUP ]; then
	PR_GROUP="practicereflection-default"
fi

read -p "Enter the group name for population health (blank for default): " PH_GROUP

if [ -z $PH_GROUP ]; then
	PH_GROUP="populationhealth-default"
fi


echo "Are the following correct? "

echo -e "Username\t\t\t: ${USERNAME}"
echo -e  "CPSID\t\t\t\t: ${CPSID}"
echo -e  "ENDPOINT\t\t\t: ${EP}"
echo -e "Attachment Group\t\t: ${ATTACHMENT_GROUP}"
echo -e "Polypharmacy Group\t\t: ${PPHRR_GROUP}"
echo -e "Practice Reflection Group\t: ${PR_GROUP}"
echo -e "Population Health Group\t\t: ${PH_GROUP}"

read -p "Correct? [y|n]: " RESP

if [ $RESP == "y" ]; then
	echo ""
	echo "OK! Committing changes to the system...."

	echo ""
	echo "-------------"

	mkdir -p /tmp/provider_tmp

	echo "foo,foo,foo,foo,foo,foo,foo,foo,foo,foo" > /tmp/provider_tmp/tmp.csv
	echo "$USERNAME,$CPSID,$EP,$ATTACHMENT_GROUP,$PPHRR_GROUP,$PH_GROUP,$PR_GROUP,$PASSWORD,10" >> /tmp/provider_tmp/tmp.csv

	./providers/update_providers.sh /tmp/provider_tmp/tmp.csv

	rm -rf /tmp/provider_tmp

	echo ""
	echo "-------------"



else
	echo ""
 	echo "Exiting without any changes."
	exit
fi

echo ""
echo "All done, goodbye!"
echo ""
