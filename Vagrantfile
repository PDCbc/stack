# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"


# Create disk (.vdi) in the default VirtualBox VM folder
#
SECOND_DISK = "#{Dir.home}/VirtualBox VMs/scoop-env-extension.vdi"


# Vagrant VM configuration settings
#
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a pre-exiting base VM
  config.vm.box = "chef/fedora-20"

  # config.vm.network "public_network"

  # Port forwarding rules; here 8080-8084 are passed straight through
  [8080, 8081, 8082, 8083, 8084].each do |x|
    config.vm.network "forwarded_port", guest: x, host: x
  end

  # Virtualbox config
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.cpus = 4
    vb.memory = 4096
    unless File.exists?(SECOND_DISK)
    	# Make a new hard disk to fit the necessary data.
    	vb.customize ["createhd", "--filename", SECOND_DISK, "--size", 64*1024]
    end
    # Attach it.
    vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", SECOND_DISK]
  end
  config.vm.provision "shell", path: "util/provision.sh"
end
