#!/bin/sh
set -x

# Copy ssh keys for private repos 
sudo cp /home/vagrant/scripts/.ssh/* /home/vagrant/.ssh

# Set up the init.d script.  It's too late for it to run in this boot so we'll call it in the provisioner
sudo cp /home/vagrant/scripts/vagrant_init.sh /etc/init.d/vagrant_init
sudo update-rc.d vagrant_init defaults 98

# Run provision as vagrant
su -c "source /home/vagrant/scripts/vagrant_provision.sh" vagrant

echo "The xTuple Server install script is done!"
