#!/bin/sh

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
   mesg n
fi

PROG=`basename $0`
XTUPLE_DIR=/home/vagrant/dev/xtuple/
PGVER=9.3

cdir() {
  echo "Changing directory to $1"
  cd $1
}

die() {
  local RESULT=63
  if [ $# -gt 0 -a $(( $1 + 0 )) -ne 0 ] ; then
    RESULT=$1
    shift
  fi
  [ $# -gt 0 ] && echo $*
  exit $RESULT
}

usage() {
  echo $PROG -h
  echo $PROG [ -p postgresversion ]
}

while getopts "hp:" OPT ; do
  case $OPT in
    h) usage
       exit 0
       ;;
    p) PGVER=$OPTARG
       ;;
  esac
done

# install git
echo "Installing Git"
sudo apt-get install git -y

# this is temporary fix for the problem where Windows
# cannot translate the symlinks in the repository
echo "Creating symlink to lib folder"
cdir /home/vagrant/dev/xtuple/lib                       || die
rm module                                               || die
ln -s ../node_modules module                            || die
git update-index --assume-unchanged module              || die

echo "Creating symlink to application folder"
cd /home/vagrant/dev/xtuple/enyo-client/application     || die
rm lib                                                  || die
ln -s ../../lib lib                                     || die
git update-index --assume-unchanged lib                 || die

cdir $XTUPLE_DIR                                        || die
echo "Beginning install script"
bash scripts/install_xtuple.sh -d $PGVER                || die

#stolen from xtuple-server-core repository
echo "Installing openRPT"
cd /home/vagrant/dev
git clone -q https://github.com/xtuple/openrpt.git |& \
                                tee -a $logfile || die "Can't clone openrpt"
apt-get install -qq --force-yes qt4-qmake libqt4-dev libqt4-sql-psql |& \
                                tee -a $logfile || die "Can't install Qt"
cd openrpt                                      || die "Can't cd openrpt"
OPENRPT_VER=master #TODO: OPENRPT_VER=`latest stable release`
git checkout -q $OPENRPT_VER |& tee -a $logfile || die "Can't checkout openrpt"
log "Starting OpenRPT build (this will take a few minutes)..."
qmake                        |& tee -a $logfile || die "Can't qmake openrpt"
make > /dev/null             |& tee -a $logfile || die "Can't make openrpt"
sudo mkdir -p /usr/local/bin                         || die "Can't make /usr/local/bin"
sudo mkdir -p /usr/local/lib                         || die "Can't make /usr/local/lib"
sudo tar cf - bin lib | sudo tar xf - -C /usr/local       || die "Can't install OpenRPT"
ldconfig                     |& tee -a $logfile || die "ldconfig failed"

echo "Adding Vagrant PostgreSQL Access Rule"
echo "host all all  0.0.0.0/0 trust" | sudo tee -a /etc/postgresql/${PGVER}/main/pg_hba.conf

echo "Restarting Postgres Database"
sudo service postgresql restart

echo "The xTuple Server install script is done!"
