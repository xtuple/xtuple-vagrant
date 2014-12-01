#!/bin/sh
set -x

SERVICE=xtupleBi

#
#  Set the repo tag below.
#
LASTTAG='v4.7.0-beta.2'
XTUPLE_TAG=$LASTTAG
XTUPLE_EXTENSIONS_TAG=$LASTTAG
BI_OPEN_TAG=$LASTTAG
BI_TAG=$LASTTAG
PRIVATE_EXTENSIONS_TAG=$LASTTAG

# Set up the init.d script.  It's too late for it to run in this boot so we'll call it in the provisioner
cat <<xtupleBiEOF | sudo tee /etc/init.d/$SERVICE
#!/bin/bash
### BEGIN INIT INFO
# Provides:          xTuple-BI-Open
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Controls the open source version of xTuple BI
# Description:       Start/Stop xTuple BI service
### END INIT INFO

# Author: Jeff Gunderson <jgunderson@xtuple.com>

# TODO: start with a fresh copy of /etc/init.d/skeleton and use
#       fewer custom scripts and more pentaho scripts

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="xTuple Open BI"
PIDFILE=/var/run/${SERVICE}.pid
SCRIPTNAME=/etc/init.d/$SERVICE

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

do_start()
{
  if [ -d /home/vagrant/bi-open/scripts -a \
       -d /home/vagrant/xtuple/node-datasource ] ; then
    cd /home/vagrant/xtuple/node-datasource
    sudo -u vagrant bash -c "node main.js | sudo tee -a /var/log/$SERVICE &"
    ps auwwx | awk '/node main.js/ { print \$2}' | sudo tee \$PIDFILE
  else
    return 2
  fi
  cd /home/vagrant/bi-open/scripts
  bash start_bi.sh >> /var/log/$SERVICE 2>&1
  if [ \$? -ne 0 ] ; then
    return 2
  fi
  return 0
}

do_stop()
{
  local RETVAL=1
  if [ -e \$PIDFILE ] ; then
    kill -9 \`cat \$PIDFILE\` >> /var/log/$SERVICE 2>&1
    rm -f \$PIDFILE
    cd /home/vagrant/bi-open/scripts
    bash stop_bi.sh >> /var/log/$SERVICE 2>&1
    if [ \$? -ne 0 ] ; then
      RETVAL=2
    else
      RETVAL=0
    fi
  fi
  return $RETVAL
}

do_reload() {
  do_stop
  do_start
}

case "\$1" in
  start)
        [ "\$VERBOSE" != no ] && log_daemon_msg "Starting \$DESC" "\$NAME"
        do_start
        case "\$?" in
          0|1) [ "\$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "\$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  stop)
        [ "\$VERBOSE" != no ] && log_daemon_msg "Stopping \$DESC" "\$NAME"
        do_stop
        case "\$?" in
                0|1) [ "\$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "\$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  restart|force-reload)
        log_daemon_msg "Restarting \$DESC" "\$NAME"
        do_stop
        case "\$?" in
          0|1)
                do_start
                case "\$?" in
                        0) log_end_msg 0 ;;
                        1) log_end_msg 1 ;; # Old process is still running
                        *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
          *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
  *)
        echo "Usage: \$SCRIPTNAME {start|stop|restart|force-reload}" >&2
        exit 3
        ;;
esac

exit 0
xtupleBiEOF

sudo update-rc.d $SERVICE defaults 98
sudo chmod +x /etc/init.d/$SERVICE

# Bootstrap
wget xtuple.com/bootstrap -qO- | sudo bash

# Clone repos first.  Have trouble with git ssh authorization after xtuple-server install-dev is run (why?)
git clone https://github.com/xtuple/xtuple-server.git
git clone https://github.com/xtuple/xtuple.git --recursive
git clone https://github.com/xtuple/xtuple-extensions.git
git clone https://github.com/xtuple/bi-open.git 
git clone git@github.com:xtuple/bi.git
git clone git@github.com:xtuple/private-extensions.git

# Install xtuple-server-commercial
cd xtuple-server
npm install
cd ..

# Install xtuple-extensions
sudo chmod -R 777 /usr/local/lib
sudo n 0.10
cd xtuple-extensions
git checkout $XTUPLE_EXTENSIONS_TAG
git submodule update --init --recursive --quiet
npm install --quiet
cd ..
  
# Install xtuple
cd xtuple
git checkout $XTUPLE_TAG
npm install --quiet
cd ..

# Use the server to do an install and build xtuple (must be in the xtuple folder?)
cd xtuple
sudo xtuple-server install-dev --xt-demo --xt-adminpw admin --pg-worldlogin true --nginx-sslcnames 192.168.33.10
cd ..

# Figure out port # for cluster to use.  Look at all lines with ".", and skip main cluster.
CLUSTERPORT=$(pg_lsclusters -h | awk '/^./ { if ($2 != "main") { print $3; } }')

# Install BI and perform ETL
sudo chmod -R 777 /usr/local/lib
sudo n 0.10
cd bi-open/scripts
git checkout $BI_OPEN_TAG
sudo -H bash build_bi.sh -ebm -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin -n 192.168.33.10 -p $CLUSTERPORT -o $CLUSTERPORT
cd ../../bi/scripts
git checkout $BI_TAG
sudo bash install.sh
cd ../../bi-open/scripts
sudo bash build_bi.sh -l -c ../../xtuple/node-datasource/config.js -d demo_dev -P admin -p $CLUSTERPORT -o $CLUSTERPORT
cd ../..

# Install bi-open.
cd xtuple
sudo ./scripts/build_app.js -d demo_dev -e ../xtuple-extensions/source/bi_open
cd ..
  
# Install the bi commercial extension. 
cd private-extensions
git checkout $PRIVATE_EXTENSIONS_TAG
git submodule update --init --recursive --quiet
npm install --quiet
cd ../xtuple
sudo ./scripts/build_app.js -d demo_dev -e ../private-extensions/source/bi
cd ..


for NGINXCONFIG in /etc/nginx/sites-available/* ; do
  if ! grep -q /pentaho $NGINXCONFIG ; then
    sudo cp $NGINXCONFIG $NGINXCONFIG.`date +%Y%m%d_%H%M`
    awk 'BEGIN { print "upstream bi {";
                 print "  server 127.0.0.1:8080;"
                 print "}"
               }
         /nice picture of a bunny/ {
                 print;
                 print "  }";
                 print "  location /pentaho {"
                 print "    proxy_pass http://bi;"
                 next;
               }
          /.*/ { print }' $NGINXCONFIG | sudo tee $NGINXCONFIG
  fi
done

sudo service nginx restart

sudo service $SERVICE start

echo "The xTuple Server install script is done!"
