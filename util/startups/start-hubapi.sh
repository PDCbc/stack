#/bin/bash
#
cd ~/hubapi/
npm install
MONGO_URI=mongodb://localhost:27019/query_composer_development npm start > ~/.hubapi.out