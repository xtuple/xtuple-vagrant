#!/bin/sh
set -x

# Set up exports for the arguments sent by config.vm.provision.  Will be
# used by vagran_provison.sh
export XREPO=$1
export XTUPLE_TAG=$2
export XTUPLE_EXTENSIONS_TAG=$3
export BI_OPEN_TAG=$4
export BI_TAG=$5
export PRIVATE_EXTENSIONS_TAG=$6
export XT_QTDEV_TOOLS_TAG=$7

# Copy ssh keys for private repos 
sudo cp /home/vagrant/scripts/.ssh/* /home/vagrant/.ssh

# Run provision as vagrant
su -c "source /home/vagrant/scripts/vagrant_provision.sh" vagrant

echo "The xTuple Server install script is done!"
