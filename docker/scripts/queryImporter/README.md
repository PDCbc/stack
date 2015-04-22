## QueryImporter Utility

This a tool to assist installing and updating queries into the Mongo database on the Hub. This script is meant to be run on the hub and will talk directly to the Mongo database. 

The general order of operations for this script are: 

1. Clone down the queries repository (https://github.com/PhysiciansDataCollaborative/queries) into a `tmp/` directory
2. Check the queries repo for integrity, i.e. expected folder structure:
    - `queries_repo/queries/` 
    - `queries_repo/functions/`
    - If these directories are not intact the importer cannot proceed. 
3. Open files in the `queries/` and `functions/` directories and format the data into objects that can be pushed into the appropriate collections in the MongoDB.
4. Pushes the queries or functions into the MongoDB.
    - Currently the behaviour is the update ALL entries if they exist, or to create a new one. 
    - Matches on the `title` field in the `queries` collection
    - Matches on the `title` field in the `library_functions` collection for function names.


### Usage

Execute this script from the scripts directory, `/vagrant/docker/scripts/` 

This will run the importer on the local MongoDB: 

`nodejs queryImporter import --mongo-host=127.0.0.1 --mongo-db=query_composer_development --mongo-port=27019`

Specifiy a username to push the scripts into the database with: `--pdc-user=USERNAME`, not the username must exist in the `users` collection in the existing MongoDB. 

### Future Work

The following are a list of things that could be updated/changed about the current implementation of the tool: 

* Linting of the queries and functions 
    - Also checking to make sure map() functions are present in the queries before they are pushed into the DB.
    - We currently assume the user knows what they are doing......
    - Suggest implementing these fixes in `index.js:getTextBlobs()` function. 
* Change the update/overwrite behaviour to support a more robust understanding of a query lifecycle. 
    - This will likely require some significant changes
* Code refactor to make it prettier. 

### Dependencies

####Environment

This tool requires a MongoDB service to be running at the desired location. The tool has been tested on Ubuntu 14.04 LTS, we have not tested it in any other environments.

NodeJS version 0.12.2 or greater is required. The default NodeJS installed via `sudo apt-get install node` is version 0.10.xx, this will not work. If you can't get a newer version installed/built, try: 

* `npm install -g n`  - n is a tool for managing different versions of nodejs. 
* `sudo n stable` - gets the last stable version of NodeJS and installs
* You may be required to run the newer version with: `n use 0.xx.xx`

If you can find a better fix for this problem of Ubuntu's NodeJS version please update this file. 

#### Node Modules
The following dependencies are required to run the importer: 

* fs - NodeJS File System library
* assert - NodeJS Assert Library
* async - NodeJS Asynchronous behavior management library. 
* mongoose - Tool for managing data models in MongoDB
* mongodb - Native JS library for interacting with MongoDB
* minimist - Library for parsing arguments to the script

Use the following to install all dependencies: `npm install assert async fs minimist mongodb mongoose` 

Or just run: `npm install` to use the dependencies in package.json

