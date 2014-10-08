#!/bin/sh
set -x

# Bootstrap
wget git.io/hikK5g -qO- | sudo bash

# Clone repos first.  Have trouble with git ssh authorization after xtuple-server install-dev is run (why?)
cd /home/vagrant/dev
git clone https://github.com/xtuple/xtuple.git --recursive
git clone https://github.com/jgunderson/xtuple-extensions.git
git clone https://github.com/xtuple/bi-open.git

# Install xtuple-server
npm install -g xtuple-server

# Install xtuple-extensions
sudo chmod -R 777 /usr/local/lib
sudo n 0.10
cd xtuple-extensions
git checkout radar
git submodule update --init --recursive --quiet
npm install --quiet
cd ..
  
# Install xtuple
cd xtuple
npm install --quiet
cd ..

# Use the server to do an install and build xtuple (must be in the xtuple folder?)
sudo n 0.11
cd /home/vagrant
sudo xtuple-server install-dev --xt-demo --xt-adminpw admin --nginx-sslcnames 192.168.33.10 --local-workspace /home/vagrant/dev/xtuple  --verbose

# Install BI and perform ETL
cd /home/vagrant/dev
sudo chmod -R 777 /usr/local/lib
#sudo n 0.10
cd bi-open/scripts
sudo -H bash build_bi.sh -eblm -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin -n 192.168.33.10
cd ../..

# Install bi-open.
cd xtuple
sudo ./scripts/build_app.js -d demo_dev -e ../xtuple-extensions/source/bi_open
cd ..

# Start the servers.  This will run as an init.d on reboots
sudo service vagrant_init

echo "The xTuple Server install script is done!"
