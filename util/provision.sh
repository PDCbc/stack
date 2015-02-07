#!/bin/bash

# Partitioning
parted /dev/sdb mklabel msdos
parted /dev/sdb mkpart primary xfs 512 100%
parted /dev/sdb set 1 lvm on
vgextend vg_vagrant /dev/sdb1
lvextend /dev/mapper/vg_vagrant-lv_root -L 100G
resize2fs /dev/mapper/vg_vagrant-lv_root

# Install Packages
yum remove -y vim-minimal # Removed sudo :(
yum install -y sudo zsh vim-enhanced docker-io tmux cmake java-1.8.0-openjdk mongodb git unzip npm nano screen

# Daemons
systemctl enable docker
systemctl start docker

# Add user to docker group.
gpasswd -a vagrant docker

su vagrant << EOF
  # get the environtment repo
  git clone https://github.com/PhyDac/scoop-env scoop-env
  git clone https://github.com/PhyDaC/visualizer visualizer
  git clone https://github.com/PhyDaC/hubapi hubapi
  git clone https://github.com/scoophealth/query-gateway endpoint
  git clone https://github.com/scoophealth/query-composer hub

  # Copy scripts
  cp /vagrant/util/startups/start-hubapi.sh /home/vagrant/hubapi/
  cp /vagrant/util/startups/start-visualizer.sh /home/vagrant/visualizer/
  cp /vagrant/util/startups/background-startups.sh /home/vagrant/

  # Add to hosts file
  echo '127.0.0.1         hubapi.scoop.local' | sudo tee -a /etc/hosts
  echo '127.0.0.1         visualizer.scoop.local' | sudo tee -a /etc/hosts
  echo '127.0.0.1         hub.scoop.local' | sudo tee -a /etc/hosts
  echo '127.0.0.1         endpoint.scoop.local' | sudo tee -a /etc/hosts
EOF

echo ''
echo '`cd dotfiles && make` if you would like nicer configs.'
echo ''
