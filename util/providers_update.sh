#!/bin/bash
#
set -e -o nounset


# Call update_providers.sh and point to providers.csv
#
cd ./providers/
sudo ./update_providers.sh /pdc/data/private/providers/providers.csv
