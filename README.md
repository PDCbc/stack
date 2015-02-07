This repo includes a `Vagrantfile` that will boot up a Fedora 20 based host box. The disk has been extended and it will automatically pull down various repos related to the SCOOP project.


## You'll need:

* [Vagrant](http://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)
* >50GB disk space
* Time

Currently, there is no publicly available data for the `data/` folder, we're working on this. For now, please place a hub dump into the `data/hub-dump` folder.


## Git Clone and Start Vagrant

Clone the repository and run start.sh
```bash
git clone https://github.com/PhyDaC/scoop-env
cd scoop-env
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


## Configuring the Hosts File

Vagrant's hosts file is configured by provision.sh, but your host (non-VM) machine will need these entries to communicate with our docker containers.
```bash
127.0.0.1         hubapi.scoop.local
127.0.0.1         visualizer.scoop.local
127.0.0.1         hub.scoop.local
127.0.0.1         endpoint.scoop.local
```

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


Visit one of the components in your web browser:

* Auth: [https://auth.scoop.local:8080]()
* Provider: [https://provider.scoop.local:8081/api]()
* Visualizer: [https://visualizer.scoop.local:8082]()
* Hub: [https://hub.scoop.local:8083]()
* Endpoint: [https://endpoint.scoop.local:8084]()


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
