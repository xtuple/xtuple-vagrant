# -*- mode: ruby -*-
# vi: set ft=ruby :

# this is the directory where the xtuple and xtuple-extensions
# cloned code repositories are located

sourceDir = "../../dev"

Vagrant.require_version ">= 1.6.3"

Vagrant.configure("2") do |config|
  config.vm.hostname = "xtuple-server"

  config.vm.post_up_message = "Welcome to the xTuple Server virtual environment.
  Use the command 'vagrant ssh' to access your server."

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Version 1.6.0 "post up" message
  #config.vm.post_up_message = "Welcome to the xTuple Server development environment.
  #Use the command 'vagrant ssh' to access your server."

  # config.vm.provider 'vmware_fusion' do |v, override|
  #   override.vm.box     = 'precise64_fusion'
  #   override.vm.box_url = 'http://files.vagrantup.com/precise64_vmware.box'
  # end

  # Vbguest Plugin
  # We will try to autodetect this path.
  # However, if we cannot or you have a special one you may pass it like:
  # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or
  # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"

  # set auto_update to false, if you do NOT want to check the correct
  # additions version when booting this machine
  #config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  #config.vbguest.no_remote = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 8888, host: 8888
  config.vm.network :forwarded_port, guest: 8443, host: 8443
  # Support REST Clients running on Express
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder sourceDir, "/home/vagrant/dev"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |v|
    # Use VBoxManage to customize the VM
    # This line disable hw virtualization and increases memory
    v.customize ["modifyvm", :id, "--memory", "4096"]

    # Via http://blog.liip.ch/archive/2012/07/25/vagrant-and-node-js-quick-tip.html
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]

    # Debug VM by booting in Gui mode
    #v.gui = true

    # If the host CPU does not have hardware virtualization support,
    # this will disable that setting in VirtualBox - only works on 32-bit OS
    #v.customize ["modifyvm", :id, "--hwvirtex", "off"]
    #v.customize ["modifyvm", :id, "--cpus", "1"]
  end

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["memsize"] = "4096"
  end

  # This ensures that the locale is correctly set for Postgres
  config.vm.provision "shell", inline: 'update-locale LC_ALL="en_US.utf8"'

  # Run install script virtual machine is created
  # This forces the script to *not* be run as sudo
  config.vm.provision "shell", path: "vagrant_setup.sh", privileged: "false", binary: "false"

end
