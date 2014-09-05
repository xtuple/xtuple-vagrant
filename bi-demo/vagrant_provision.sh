#!/bin/sh
set -x

# Bootstrap
wget git.io/hikK5g -qO- | sudo bash

# Clone repos first.  Have trouble with git ssh authorization after xtuple-server install-dev is run (why?)
git clone git@github.com:xtuple/xtuple-server-commercial.git
git clone https://github.com/xtuple/xtuple.git --recursive
git clone https://github.com/xtuple/xtuple-extensions.git
git clone https://github.com/xtuple/bi-open.git
git clone git@github.com:xtuple/bi.git
git clone git@github.com:xtuple/private-extensions.git

# Install xtuple-server-commercial
cd xtuple-server-commercial
npm install
cd ..

# Install xtuple-extensions
sudo chmod -R 777 /usr/local/lib
sudo n 0.8
cd xtuple-extensions
git submodule update --init --recursive --quiet
npm install --quiet
cd ..
  
# Install xtuple
cd xtuple
npm install --quiet
cd ..

# Use the server to do an install and build xtuple (must be in the xtuple folder?)
cd xtuple
sudo xtuple-server install-dev --xt-demo --xt-adminpw admin --nginx-sslcnames 192.168.33.10
cd ..

# Install BI and perform ETL
sudo chmod -R 777 /usr/local/lib
sudo n 0.8
cd bi-open/scripts
sudo -H bash build_bi.sh -ebm -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin -n 192.168.33.10
cd ../../bi/scripts
sudo bash install.sh
cd ../../bi-open/scripts
sudo bash build_bi.sh -l -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin
cd ../..

# Install bi-open.
cd xtuple
sudo ./scripts/build_app.js -d demo_dev -e ../xtuple-extensions/source/bi_open
cd ..
  
# Install the bi commercial extension. 
cd private-extensions
git submodule update --init --recursive --quiet
npm install --quiet
cd ../xtuple
sudo ./scripts/build_app.js -d demo_dev -e ../private-extensions/source/bi
cd ..

# Start the servers.  This will run as an init.d on reboots
sudo service vagrant_init

echo "The xTuple Server install script is done!"
