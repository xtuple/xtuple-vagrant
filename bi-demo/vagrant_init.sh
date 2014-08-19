#!/bin/bash
su - vagrant -c "cd ~/bi-open/scripts ; sudo sh start_bi.sh"
su - vagrant -c "cd ~/xtuple ; npm start &"
echo "Started BI Server and xTuple app"
