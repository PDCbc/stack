#/bin/bash
#

# Start HubAPI
#
cd hubapi/
./start.sh &
cd ..


# Start Visualizer
#
cd visualizer/
./start.sh &
cd ..


# Open Apps
sleep 6
open https://localhost:3003
sleep 4
open https://localhost:3004
