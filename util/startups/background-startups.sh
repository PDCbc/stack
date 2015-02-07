#/bin/bash
#
screen -A -m -d -S screen-hubapi "./hubapi/start-hubapi.sh" &
screen -A -m -d -S screen-visualizer "./visualizer/start-visualizer.sh" &
ps -aux | grep screen | grep -v grep