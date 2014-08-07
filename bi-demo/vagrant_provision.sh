#!/bin/sh

# Boostrap. This sets node to 0.11.13 which causes npm problems with bcrpyt and ursa.  
wget git.io/hikK5g -qO- | sudo bash
# So we reset to 0.8
sudo n 0.8
sudo npm update npm
# But that gives ownership to root, which causes later trouble with npm install
sudo chown -R vagrant .npm

# diagnostics
set -x

# The FOSS xtuple-server requires an existing xtuple 
git clone https://github.com/xtuple/xtuple.git  
cd xtuple
git checkout 4_6_x
git submodule update --init --recursive --quiet
npm install --quiet
cd ..

# And we need extensions for bi-open
git clone https://github.com/xtuple/xtuple-extensions.git  
cd xtuple-extensions
git checkout 4_6_x
git submodule update --init --recursive --quiet
npm install --quiet
cd ..

# Install xtuple-server
npm install -g xtuple-server

# Use the server to do an install and build xtuple
sudo xtuple-server install-dev --xt-version 4.5.1 --xt-demo --local-workspace ./xtuple --xt-adminpw admin

# One of the above sets node to 0.11.13 so back again.
sudo n 0.8

# Install the bi-open extension. TODO: build this into the xtuple-server install as a flag
cd xtuple
sudo ./scripts/build_app.js -d demo_dev -e ../xtuple-extensions/source/bi_open
cd ..

# Install BI load data and start BI server
git clone https://github.com/xtuple/bi-open.git  
cd bi-open/scripts
git checkout 4_6_x
sudo bash build_bi.sh -eblm -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin
sudo bash start_bi.sh
cd ../..

# Start the app.
cd xtuple
npm start > console.log &
sleep 10
cd ..

# Run a test to make sure that BI is accessible and the ETL worked
cd xtuple-extensions
cp ../xtuple/test/lib/login_data.js test/lib/login_data.js
sudo npm run-script test-bi_open

# diagostics (move to after failure)
cat test/lib/login_data.js
cat ../ErpBI/data-integration/properties/psg-linux/.kettle/kettle.properties
cat ../ErpBI/biserver-ce/tomcat/logs/catalina.out
cat ../xtuple/console.log

echo "The xTuple Server install script is done!"
