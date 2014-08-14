#!/bin/sh
set -x

# Copy ssh keys for private repos 
sudo cp /home/vagrant/scripts/.ssh/* /home/vagrant/.ssh
#sudo chown -R vagrant /home/vagrant/.ssh
#sudo chgrp -R vagrant /home/vagrant/.ssh
#sudo chmod -R 600 /home/vagrant/.ssh

# Run provision as vagrant
su -c "source /home/vagrant/scripts/vagrant_provision.sh" vagrant

echo "The xTuple Server install script is done!"
