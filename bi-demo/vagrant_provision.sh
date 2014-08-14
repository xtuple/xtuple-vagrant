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
  
# Install xtuple with latest npm
sudo npm update -g npm
cd xtuple
npm install --quiet
cd ..

# Use the server to do an install and build xtuple (must be in the xtuple folder?)
cd xtuple
sudo xtuple-server install-dev --xt-demo --xt-adminpw admin
cd ..

# Install BI and perform ETL
sudo chmod -R 777 /usr/local/lib
sudo n 0.8
cd bi-open/scripts
sudo -H bash build_bi.sh -ebm -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin
cd ../../bi/scripts
sudo bash install.sh
cd ../../bi-open/scripts
sudo bash build_bi.sh -l -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin
sudo bash start_bi.sh
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

# Start the app.
cd xtuple
npm start > console.log &
sleep 10
cd ..

# Run a test to make sure that BI is accessible and the ETL worked
cd private-extensions
#- cat test/lib/sample_login_data.js | sed 's#org:.*#org: \"demo_dev\",#' > test/lib/login_data.js
cp ../xtuple/test/lib/login_data.js* test/lib/login_data.js
sudo npm run-script test-bi

#move to after-failure
cat test/lib/login_data.js
cat ../ErpBI/data-integration/properties/psg-linux/.kettle/kettle.properties
cat ../ErpBI/biserver-ce/tomcat/logs/catalina.out
cat ../xtuple/console.log

echo "The xTuple Server install script is done!"
