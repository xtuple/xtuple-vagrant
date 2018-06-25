#!/bin/bash

PROG=${PROG:-$(basename $0)}
VAGRANTPREFIX=/vagrant
if [ ! -e $VAGRANTPREFIX/common.sh ] ; then
  VAGRANTPREFIX=.
fi
source $VAGRANTPREFIX/common.sh *@

#let install_xtuple.sh build openrpt without requiring a fix to the script
sudo chmod go+rwX /usr/local/src                        || die

cdir $XTUPLE_DIR                                        || die

echo "Beginning install script"
bash scripts/install_xtuple.sh -d $PGVER -q $QTVER      || die

echo "Adding Vagrant PostgreSQL Access Rule"
echo "host all all  0.0.0.0/0 trust" | sudo tee -a /etc/postgresql/${PGVER}/main/pg_hba.conf

# Install plv8 v2.0+ required for xTupleCommerce extension
sudo apt-get -q -y install libc++1 && \
cd ${HOME} && \
wget http://updates.xtuple.com/updates/plv8/linux64/xtuple_plv8.tgz && \
tar xf xtuple_plv8.tgz && \
cd xtuple_plv8 && \
printf "\n" | sudo ./install_plv8.sh /usr && \
cd ${HOME} && \
rm -rf xtuple_plv8 && \
rm xtuple_plv8.tgz

echo "Restarting Postgres Database"
sudo service postgresql restart
