#!/bin/bash

PROG=${PROG:-$(basename $0)}
VAGRANTPREFIX=/vagrant
if [ ! -e $VAGRANTPREFIX/common.sh ] ; then
  VAGRANTPREFIX=.
fi
source $VAGRANTPREFIX/common.sh

#let install_xtuple.sh build openrpt without requiring a fix to the script
sudo chmod go+rwX /usr/local/src                        || die

cdir $XTUPLE_DIR                                        || die

echo "Beginning install script"
bash scripts/install_xtuple.sh -d $PGVER -q $QTVER      || die

echo "Adding Vagrant PostgreSQL Access Rule"
echo "host all all  0.0.0.0/0 trust" | sudo tee -a /etc/postgresql/${PGVER}/main/pg_hba.conf

echo "Restarting Postgres Database"
sudo service postgresql restart
