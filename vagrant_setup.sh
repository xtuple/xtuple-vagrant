#!/bin/sh

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
   mesg n
fi

# set xtuple source directory
XTUPLE_DIR=/home/vagrant/dev/xtuple/

# handy little function from install_script
cdir() {
	echo "Changing directory to $1"
	cd $1
}

# install git
echo "Installing Git"
sudo apt-get install git -y

# this is temporary fix for the problem where Windows
# cannot translate the symlinks in the repository
echo "Creating symlink to lib folder"
cd /home/vagrant/dev/xtuple/lib/
rm module
ln -s ../node_modules/ module
git update-index --assume-unchanged module

echo "Creating symlink to application folder"
cd /home/vagrant/dev/xtuple/enyo-client/application/
rm lib
ln -s ../../lib/ lib
git update-index --assume-unchanged lib

cdir $XTUPLE_DIR
echo "Beginning install script"
bash scripts/install_xtuple.sh

echo "Adding Vagrant PostgreSQL Access Rule"
echo "host all all  0.0.0.0/0 trust" | sudo tee -a /etc/postgresql/9.1/main/pg_hba.conf

echo "Restarting Postgres Database"
sudo service postgresql restart

echo "The xTuple Server install script is done!"
