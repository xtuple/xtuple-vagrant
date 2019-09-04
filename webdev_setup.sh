#!/bin/bash

# TODO: replace most of this with xTAU
# its presence here lets us remove install_xtuple.sh
PROG=${PROG:-$(basename $0)}
DEBDIST=$(lsb_release -c -s)
BASEDIR=/usr/local/src
DATABASE=dev
USERNAME=$(whoami)

VAGRANTPREFIX=/vagrant
if [ ! -e $VAGRANTPREFIX/common.sh ] ; then
  VAGRANTPREFIX=.
fi
source $VAGRANTPREFIX/common.sh *@

if [ "${DEBDIST}" = "wheezy" ] ; then
  sudo add-apt-repository -y "deb http://ftp.debian.org/debian wheezy-backports main"
fi

case "${DEBDIST}" in
  "bionic") ;&
  "trusty") ;&
  "utopic") ;&
  "wheezy") ;&
  "jessie") ;&
  "xenial")
    if [ ! -f /etc/apt/sources.list.d/pgdg.list ] || ! grep -q "apt.postgresql.org" /etc/apt/sources.list.d/pgdg.list; then
      sudo bash -c "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"
      sudo bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    fi
    ;;
esac

sudo apt-get --quiet --quiet update

sudo apt-get --quiet --quiet --assume-yes install \
  build-essential curl libssl-dev xvfb xsltproc   \
  software-properties-common

sudo apt-get --quiet --assume-yes install \
  libxss1 libasound2 libfontconfig1 libharfbuzz0b libnspr4 libnss3 \
  libxrender1 libxkbcommon0 libxkbcommon-x11-0

sudo apt-get --quiet --quiet --assume-yes                            \
             --allow-downgrades --allow-change-held-packages install \
  postgresql-${PGVER} postgresql-server-dev-${PGVER}                 \
  postgresql-${PGVER}-asn1oid postgresql-contrib-${PGVER}

sudo chmod go+w $BASEDIR
mkdir -p $BASEDIR/postgres
sudo chmod go-w $BASEDIR

PGDIR=/etc/postgresql/${PGVER}/main

sudo sed --in-place=".default"                                                  \
         -e "s/#listen_addresses = \S*/listen_addresses = \'*\'/"               \
         -e "s/#custom_variable_classes = ''/custom_variable_classes = 'plv8'/" \
         $PGDIR/postgresql.conf
echo "plv8.start_proc = 'xt.js_init'" | sudo tee -a $PGDIR/postgresql.conf

sudo sed --in-place=".default"                                          \
         -e "s/local\s*all\s*postgres.*/local\tall\tpostgres\ttrust/"   \
         -e "s/local\s*all\s*all.*/local\tall\tall\ttrust/"             \
         -e "s#host\s*all\s*all\s*127\.0\.0\.1.*#host\tall\tall\t127.0.0.1/32\ttrust#" \
         $PGDIR/pg_hba.conf
echo "host all all  0.0.0.0/0 trust" | sudo tee -a ${PGDIR}/pg_hba.conf
sudo chown postgres $PGDIR/pg_hba.conf

# test the plv8 we built since that's what we recommend to customers
PREVDIR="$(pwd)"
mkdir -p ${HOME}/tmp
cd ${HOME}/tmp
  sudo apt-get --quiet --assume-yes install libc++1 || sicken Could not install libc++1
  wget --no-verbose http://updates.xtuple.com/updates/plv8/linux64/xtuple_plv8.tgz   || sicken Could not download xtuple_plv8
  tar xf xtuple_plv8.tgz
  cd xtuple_plv8
    printf "\n" | sudo ./install_plv8.sh /usr
  cd ..
  rm -rf ${HOME}/xtuple_plv8 ${HOME}/xtuple_plv8.tgz
cd "$PREVDIR"

sudo service postgresql restart

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
INITNVM="$(tail -n 3 $HOME/.bashrc | tr "\n" ";")"
eval "$INITNVM"

if [ ! -d $XTUPLEDIR ] ; then
  git clone git://github.com/$USERNAME/xtuple.git $XTUPLEDIR
  cdir $XTUPLEDIR
  git remote add XTUPLE git://github.com/xtuple/xtuple.git
else
  cdir $XTUPLE_DIR
fi

sed -e "s/testDatabase: \"\"/testDatabase: '$DATABASE'/" \
  $XTUPLEDIR/node-datasource/sample_config.js > $XTUPLEDIR/node-datasource/config.js

mkdir -p $XTUPLEDIR/node-datasource/lib/private
cdir $XTUPLEDIR/node-datasource/lib/private
[ -e salt.txt           ] || cat /dev/urandom | tr -dc '0-9a-zA-Z!@#$%^&*_+-'| head -c 64 > salt.txt
[ -e encryption_key.txt ] || cat /dev/urandom | tr -dc '0-9a-zA-Z!@#$%^&*_+-'| head -c 64 > encryption_key.txt
[ -e server.key         ] || openssl genrsa -des3 -out server.key -passout pass:xtuple 1024
openssl rsa -in server.key -passin pass:xtuple -out key.pem -passout pass:xtuple
[ -e $HOME/.rnd ] || touch $HOME/.rnd
openssl req -batch -new -key key.pem -out server.csr -subj '/CN='$(hostname)
openssl x509 -req -days 365 -in server.csr -signkey key.pem -out server.crt

cdir $XTUPLEDIR/test/lib
sed -e "s/org: \'dev\'/org: \'$DATABASE\'/" sample_login_data.js > login_data.js

cdir $XTUPLEDIR
if [ -n "$NODEVER" ] ; then
  nvm install $NODEVER
  nvm use     $NODEVER
elif [ -e .nvmrc ] ; then
  nvm install
  nvm use
elif egrep --quiet 'async.*0\.2\.x' package.json ; then
  nvm install v0.10.40
else
  nvm install v8.11.4
fi

# this fixes a problem where Windows cannot translate symlinks in the repository
if $WINDOWSHOST ; then
  cdir $HOME/dev/xtuple/lib                     || die
  rm module                                     || die
  ln -s ../node_modules module                  || die
  git update-index --assume-unchanged module    || die

  cdir $HOME/dev/xtuple/enyo-client/application || die
  rm lib                                        || die
  ln -s ../../lib lib                           || die
  git update-index --assume-unchanged lib       || die

  cd $XTUPLEDIR
fi

psql -U postgres -q -f foundation-database/init.sql
npm install
npm run-script test-build

cat <<EOF
You can login to the database and web client with
  username: admin
  password: admin
Run the following commands to start the datasource:
  cd node-datasource
  node main.js
EOF
