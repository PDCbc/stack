## Requirements:

* [Vagrant](http://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)
* >50GB disk space
* Time


Currently, there is no publicly available data for the `data/` folder, we're working on this. For now, please place a hub dump into the `data/hub-dump` folder.


## Git Clone and Start Vagrant

Clone the repository and run start.sh
```bash
git clone https://github.com/PhysiciansDataCollaborative/pdc-env
cd pdc-env
vagrant up
```
Note: 64-bit guests in VirtualBox require VT-x support.  Ensure that VT-x support is enabled in the BIOS before installing 64-bit guests.

A Fedora image is downloaded on the first run.  Please expect it to take time.

Read `util/provision.sh` to see how it:

* Creates a second drive and join both as a volume group
* Expands the logical volume and resize the filesystem
* Installs tools
* Setsvup some sane dotfiles
* Clones repositories


## Access Vagrant

Login with SSH
```bash
vagrant ssh
```

To pass vagrant commands, use `vagrant ssh -c COMMAND`


## Build the visualizer, hubapi, hub and endpoint

Login to Vagrant, navigate to its share (/vagrant/) then make those containers
```bash
cd /vagrant/
make
```

That runs the commands below, as seen in the Makefile.  Knowing this structure will aid greatly in troubleshooting.

make:
* make pull
 * make pull-mongo
 * make pull-wildfly
 * make pull-keycloak
 * make pull-phusion
* make build
 * make build-hubapi
 * make build-visualizer
 * make build-hub
 * make build-endpoint
* make run
 * make run-hubapi
 * make run-visualizer
 * make run-hub
 * make run-endpoint

Due to some *unreliabilities* with Docker and Virtualbox interactions (We haven't quite figured it out yet), `docker pull` commands will often fail with cryptic errors. Please see troubleshooting at the bottom of this document.

Note: `make run` fails if the containers are already running.  Please see the troubleshooting section.


## Accessing Docker Containers

List Containers (ssh'd into vagrant)
```bash
docker ps -a
```

Verify that hubapi, visualizer-db, hub-db, hub, endpoint-db and endpoint are running

Access the endpoint by entering its namespace
```bash
sudo nsenter --target $(docker inspect --format {{.State.Pid}} endpoint) --mount --uts --ipc --net --pid /bin/bash
```

Explanation: Finding the endpoint's PID with `docker inspect --format {{.State.Pid}} endpoint`

Explanation: Enter via namespace `sudo nsenter --target PID_NUMBER --mount --uts --ipc --net --pid /bin/bash `

## Create a Bash Function

Optionally, create a bash function for calling that lengthy nsenter command (above).

Here the command is `dockin [containerToEnter]`.

Edit ~/.bashrc with `nano ~/.bashrc`, adding the code below.  Then log in/out or type `source ~/.bashrc`.
```bash
function dockin(){
  if [ $# -eq 0 ]
  then
    echo "Please pass a docker container to enter"
    echo "Usage: dockin [containerToEnter]"
  else
    sudo nsenter --target $(docker inspect --format {{.State.Pid}} $1) --mount --uts --ipc --net --pid /bin/bash
  fi
}
```


## Importing Data

Login to Vagrant and then the endpoint (as above)

Navigate to the endpoint's util directory
```bash
cd /home/app/endpoint/util/
```

Import Multiple XML Files:
Use SCP to copy the E2E files (multiple XML) into ./files/
```bash
mkdir -p files/
scp LOGIN_NAME@IP_OR_HOSTNAME:/PATH_TO_FILES/*.xml ./files/
```

Or Import and Extract a Zip File:
Use SCP to copying a zip file over, then unzip it and then move the XML files
```bash
scp LOGIN_NAME@IP_OR_HOSTNAME:/PATH_TO_ZIP/*.zip ./files/
unzip ZIPFILE.zip
mv UNZIPPED_SUBDIRECTORY/* ./files/
```

Note, OS X: Enable SCP from System Preferences > Sharing > Remote Login [checkbox]
Note, Linux: Pre-installed, but if not use `yum install scp` (Red Hat, Fedora, CentOS) or `apt-get install openssh-server` (Ubuntu, Mint, Debian)
Note, Windows: You're on your own!  Install Linux?

Start the relay service and push it to the background with `&`
```bash
./relay-service.rb &
[press Enter]
```

Note: Forgetting the `&` will leave you staring indefinitely at web server logs!

Use lynx to access the page on localhost:3000 and run the import
```bash
lynx http://localhost:3000
```
Select "Create test patient records."  White means highlighted.  The process will complete in around 20 minutes, then press q, y to quit.

Leave the docker container
```bash
exit
```

## Playing

Start the HubAPI and Visualizer (ssh'd into Vagrant)
```bash
cd /vagrant/
./background-startups.sh
exit
```

This launches two scripts and sends them to the background with screen.  Please see hubapi/start-hubapi.sh and visualizer/start-visualizer.sh for details.  They output logs to ~/.hubapi.out and ~/.visualizer.out.


Check if HubAPI and Visualizer are running with screen (ssh'd into Vagrant)
```bash
ps -aux | grep screen | grep -v grep
```

Explanation: `ps -aux` shows a = all processes, u = users (e.g vagrant) and x = no tty restriction (don't ask)
Explanation: `| grep screen` shows only processes with the word `screen`
Explanation: `| grep -v grep` hides processes with the word `grep` in them, since greps is also a process!


## Troubleshooting

### "make run" Returns "already assigned" ... "Error 1"

The container in question is probably already running.  Try one of the these:

1. Start the containers manually
```bash
docker start hub-db
docker start hub
docker start endpoint-db
docker start endpoint
```

2. Type `docker ps -a` to see a list of containers.  Stop them manually and run `make run` again.  
```bash
docker stop hub-db
docker stop hub
docker stop endpoint-db
docker stop endpoint
make run
```

### Pulling the Images

#### Unexpected EOF

Output:

```
b5094295c793: Pulling metadata
2014/09/17 18:55:41 unexpected EOF
make: *** [pull-mongo] Error 1
```

`make pull` is a composite of the following tasks, try the one that failed:

```bash
make pull-mongo
make pull-wildfly
make pull-keycloak
make pull-phusion
```

Eventually, you'll successfully get a copy.

#### Failed to create rootfs

```bash
eea2821a4553: Download complete
05aea00a321b: Error downloading dependent layers
13e42d0c2a51: Download complete
01e217439a55: Download complete
2014/09/18 16:29:34 Error pulling image (0.9.6) from phusion/passenger-ruby19, Driver devicemapper failed to create image rootfs 05aea00a321b91d34b2c81a2c4b524fd2ed9912ba061ec9416fb919970edf56b: device 05aea00a321b91d34b2c81a2c4b524fd2ed9912ba061ec9416fb919970edf56b already exists
make: *** [pull-phusion] Error 1
```

This commonly happens after the EOF error. In this case, the solution is:

```bash
sudo rm -rf /var/lib/docker/devicemapper/mnt/05aea00a321b91d34b2c81a2c4b524fd2ed9912ba061ec9416fb919970edf56b
```

If you have errors removing this folder, particularly an input/output error, try restarting the virtual machine.



































# API

The hubapi component acts as a data access and processing layer around the mongodb. It has the following routes of interest:


- `GET /retro/:title`
    + This route will return a JSON object that contains data for the query identified by `:title`.
    + This route is used for *ratio* type queries.
    + It will return data that is almost identical to the `/api/processed_result` route, the only difference being that it look for many executions over time instead of just the most recent.
    + This route requires that cookie be passed via the query string of the URL
        *  it must be accessible via: `request.query.cookie`
    + During normal execution, the route will return a JSON string/object of the following structure:

    ```JavaScript
    {
        "processed_result" : {
            "clinician" : [
                { "aggregate_result" : { "numerator" : INT , "denominator" : INT }, "time": TIMESTAMP, "display_name" : STRING },
                ...
            ],
            "group" : [
                { "aggregate_result" : { "numerator" : INT , "denominator" : INT }, "time": TIMESTAMP, "display_name" : STRING },
                ...
            ],
            "network" : [
                { "aggregate_result" : { "numerator" : INT , "denominator" : INT }, "time": TIMESTAMP, "display_name" : STRING },
                ...
            ],
        },
        "provider_id" : STRING,
        "network_id" : STRING,
        "title" : STRING,
        "description" : STRING
    }
    ```
    + The status codes are as follows, in the event of an error code (status > 399) or no content (status == 204) the data object will be `null` or an empty object `{}` :
        * `200` - Processing completed successfully, the resulting data will be in the returned object.
        * `204` - The request was correctly processed, but no executions for this query exist!
        * `400` - Request for data was not well formed, i.e. there was not `request.body.bakedCookie` field
        * `404` - The query requested does not exist
        * `401` - Request failed due to invalid credential
        * `500` - Request failed due to unknown server error.

- `GET /api/processed_result/:title`
    + Returns data for the query identified by the `:title` input
    + This route is used for *ratio* type queries.
    + This route requires that cookie be passed via the query string of the URL
        *  it must be accessible via: `request.query.cookie`
    + During normal execution, the route will return a JSON string/object of the following structure:

    ```JavaScript
    {
        "processed_result" : {
            "clinician" : [
                { "aggregate_result" : { "numerator" : INT , "denominator" : INT }, "time": TIMESTAMP, "display_name" : STRING },
                ...
            ],
            "group" : [
                { "aggregate_result" : { "numerator" : INT , "denominator" : INT }, "time": TIMESTAMP, "display_name" : STRING },
                ...
            ],
            "network" : [
                { "aggregate_result" : { "numerator" : INT , "denominator" : INT }, "time": TIMESTAMP, "display_name" : STRING },
                ...
            ],
        },
        "provider_id" : STRING,
        "network_id" : STRING,
        "title" : STRING,
        "description" : STRING
    }
    ```
    + The status codes are as follows, in the event of an error code (status > 399) or no content (status == 204) the data object will be `null` or an empty object `{}` :
        * `200` - Processing completed successfully, the resulting data will be in the returned object.
        * `204` - The request was correctly processed, but no executions for this query exist!
        * `400` - Request for data was not well formed, i.e. there was not `request.body.bakedCookie` field
        * `404` - The query requested does not exist
        * `401` - Request failed due to invalid credential
        * `500` - Request failed due to unknown server error.

- `GET /demographics`
    + Returns data for the demographics query.
    + This route requires that cookie be passed via the query string of the URL
        *  it must be accessible via: `request.query.cookie`
    + During normal execution, the route will return a JSON string/object of the following structure:
    + Returns data for **single** (most recent) execution. For all executions see `/retro/demographics` route.

    ```JavaScript
    {
        "clinician" : [ { "gender" : { "age-range" : NUMBER, ... }, ... } ],
        "group" : [ { "gender" : { "age-range" : NUMBER, ... }, ... } ],
        "network" : [ { "gender" : { "age-range" : NUMBER, ... }, ... } ],
        "provider_id" : STRING
    }
    ```
    + The status codes are as follows, in the event of an error code (status > 399) or no content (status == 204) the data object will be `null` or an empty object `{}` :
        * `200` - Processing completed successfully, the resulting data will be in the returned object.
        * `204` - The request was correctly processed, but no executions for this query exist!
        * `400` - Request for data was not well formed, i.e. there was not `request.body.bakedCookie` field
        * `404` - The query requested does not exist
        * `401` - Request failed due to invalid credential
        * `500` - Request failed due to unknown server error.

- `GET /api/queries`
    + Returns a list of all of the queries and their executions
    + This route requires that cookie be provided that is accessible via the Node Express: `request.query.cookie` object.
    + During normal operation, the route will return a JSON string of the following format:

    ```JavaScript
    {
        "queries" : [
            { "_id" : STRING, "title" : STRING, "user_id" : STRING, "description" : STRING, "executions" : [ ... ] },
            ...
        ]
    }
    ```
    + This route should be used to determine which queries exist within the hub.
    + The status codes are as follows, in the event of an error code (status > 399) or no content (status == 204) the data object will be null or an empty object {} :
        * `200` - Completed successfully, the resulting data will be in the returned object.
        * `204` - The request was executed correctly, but no queries were found.
        * `400` - Request for data was not well formed, i.e. there was not `request.body.bakedCookie` field
        * `404` - The query requested does not exist
        * `401` - Request failed due to invalid credential
        * `500` - Request failed due to unknown server error.

- `GET /reports/`
    + This route will return a list of reports that can requested. It is analogous to the `/api/queries` route but for reports instead of queries.  
    + This report requires that a cookie be passed via the request GET query string, it must be accessible via Express' `request.query.cookie` object. The cookie must contain user information and will be used to authenticate the user.
    + During normal (non-error) operation, the following object structure will be returned:

    ```JavaScript
    [
        { "shortTitle" : STRING, "title" : STRING},
        ...
    ]
    ```
        * Where the `shortTitle` field is a name used to reference the report by HAPI. All subsequent requests to `/reports/title` should use the `shortTitle`. The `title` field of the returned object is a human readable string that can be presented in the user interface.  
    + The status codes are as follows, in the event of an error code (status > 399) or no content (status == 204) the data object will be an empty array `[]`.
        * `200` - Completed successfully, data will be as described above.
        * `204` - Completed successfully, but no reports were found, data will be an empty array.
        * `400` - Request for data was not well formed, i.e. there was not `request.body.bakedCookie` field
        * `401` - Request failed due to invalid credentials
        * `500` - Failed due to a server failure.

- `GET /reports/:title`
    + This route requires that the cookie be sent in the request query string.
    + This route will return a CSV data in a buffer that can be consumed by a client.
    + During normal operation (non-error), a `STRING` will be returned that is the report CSV string.
    + Under normal operation (non-error), the route will return HTTP status code `200`, in other cases the following will be returned and the `STRING` will be `null`:  
        * `204` - The request was successful, but no content was found.
        * `400` - The request was poorly formatted, perhaps the cookie was not there.
        * `401` - The request failed to authenticate via the auth component, i.e. the cookie was invalid
        * `404` - Report does not exist.
        * `500` - Server error occurred

- `GET /medclass`
    + This route will return a JSON object that shows the 10 most commonly prescribed medication classes for the user of interest.
    + The route requires that user information be in a cookie sent via the GET query string.
    + Under normal operation (non-error, status code 200) the route will return the following JSON string as a response:

    ```JavaScript
    {
        provider_id : STRING
        processed_result : {

            display_names : {

                clinician : STRING,
                group : STRING,
                network: STRING

            },

            drugs : [
                {
                    drug_name : STRING,
                    agg_data : [
                        { set: "clinician", numerator : NUMBER, denominator: NUMBER, time: TIMESTAMP },
                        { set: "group", numerator : NUMBER, denominator: NUMBER, time: TIMESTAMP },
                        { set: "network", numerator : NUMBER, denominator: NUMBER, time: TIMESTAMP }
                    ]
                },
                ...
            ]
        }
    }
    ```

    + If an error occurs the data returned by this route will be `null` and the status code will be one of:
        * `204` - The request was successful, but no data or executions of this query were found.
        * `400` - The request was poorly formatted, perhaps the cookie was not sent?
        * `401` - The request failed to authenticate via the auth component, i.e. the cookie was invalid
        * `404` - The requested query does not exist.
        * `500` - Server error occurred.


# Tests

## Unit Tests

Unit tests reside in the `test/` directory. They are using the [MochaJs](http://mochajs.org/) unit test framework. Code coverage is provided by [Blanket](https://github.com/alex-seville/blanket) The directory is structured to mirror the `lib/` directory, please keep it organized! To run tests use the following:

`npm test` - this runs a suite of mocha tests and a code coverage by running `sh runtests.sh`.

Alternatively, code coverage can be run independently of the regular mocha reporter: `npm run test-coverage` and tests can be run without coverage: `npm run test-no-coverage`.  

Note: the coverage and normal coverage unit tests are coupled together in `npm test` because the mocha does not currently support multiple reporter types (html-cov AND command line) at the same time.  

# Setup

## Dependencies

Before starting, you should ensure you have the following available on your machine:

* An active MongoDB instance.
* Node.js

On Mac OS X or a RHEL/Fedora derivative you can install it like so:

```bash
cd $PROJECT_DIRECTORY
./setup.sh
```

If you're on Windows, or feel like having a VM to work on, install [Vagrant](https://www.vagrantup.com/) try using our `Vagrantfile`:

```bash
cd $PROJECT_DIRECTORY
vagrant up  # Start the VM.
vagrant ssh # Shell into the VM.
```

## Starting

```bash
cd $PROJECT_DIRECTORY
npm install # Install Dependencies into `.node_modules/`.
npm start   # Start the application.
```

### Starting for Development

During development it can desirable to set URLs of other components (MongoDB, Visualizer, Auth, DCLAPI etc...)
to something other than default. Do this by setting environment variables for the process, for example:

```bash
MONGO_URI=mongodb://localhost:27019/query_composer_development AUTH_CONTROL=https://localhost:3006 DCLAPI_URI=http://localhost:3007 npm start
```

Note that the components at the URLs given must be running, if you are having issues consider the following:
    - Are all the right ports open on the various machines?
    - Are you on the right network?
    - Is the host you are trying to connect to reachable?

# Deploy

There is a `Dockerfile` for use in deployment, however your mileage may vary.

# Troubleshooting

## Making certificates

In order to not have to accept a new cert every time, bake your own. [Source](https://library.linode.com/security/ssl-certificates/self-signed).

```bash
mkdir ./cert
openssl req -new -x509 -days 365 -nodes -out ./cert/server.crt -keyout ./cert/server.key
chmod 600 ./cert/*
```
