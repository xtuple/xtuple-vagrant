#!/bin/bash
su - vagrant -c "cd ~/dev/bi-open/scripts ; sudo sh start_bi.sh"
su - vagrant -c "cd ~/dev/xtuple ; npm start &"
echo "Started BI Server and xTuple app"
