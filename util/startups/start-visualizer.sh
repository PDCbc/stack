#/bin/bash
#
cd ~/visualizer/
npm install
MONGO_URI=mongodb://localhost:27018/visualizer npm start  > ~/.visualizer.out
