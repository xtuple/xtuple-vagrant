#!/bin/sh

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
  mesg n
fi

PROG=`basename $0`
XTUPLE_DIR=/home/vagrant/dev/xtuple/
PGVER=9.3
QTVER=5

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
  echo $PROG [ -p postgresversion ] [ -q qtversion ]
}

while getopts "hp:q:" OPT ; do
  case $OPT in
    h) usage
       exit 0
       ;;
    p) PGVER=$OPTARG
       ;;
    q) QTVER=$OPTARG
       ;;
  esac
done

# install git
echo "Installing Git"
sudo apt-get install git -y

# this is a temporary fix for the problem where Windows
# cannot translate the symlinks in the repository
cat <<SKIP
echo "Creating symlink to lib folder"
cdir /home/vagrant/dev/xtuple/lib                       || die
rm module                                               || die
ln -s ../node_modules module                            || die
git update-index --assume-unchanged module              || die

echo "Creating symlink to application folder"
cdir /home/vagrant/dev/xtuple/enyo-client/application   || die
rm lib                                                  || die
ln -s ../../lib lib                                     || die
git update-index --assume-unchanged lib                 || die
SKIP

#let install_xtuple.sh build openrpt without requiring a fix to the script
sudo chmod go+rwX /usr/local/src                        || die

cdir $XTUPLE_DIR                                        || die
echo "Beginning install script"
bash scripts/install_xtuple.sh -d $PGVER -q $QTVER      || die

echo "Adding Vagrant PostgreSQL Access Rule"
echo "host all all  0.0.0.0/0 trust" | sudo tee -a /etc/postgresql/${PGVER}/main/pg_hba.conf

echo "Restarting Postgres Database"
sudo service postgresql restart

echo "The xTuple vagrant setup script is done!"
