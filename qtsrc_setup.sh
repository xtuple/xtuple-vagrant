#!/bin/sh
set -x

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
  mesg n
fi

PROG=`basename $0`
XTUPLE_DIR=/home/vagrant/dev/xtuple/
PGVER=9.3
QTVER=4

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

sudo apt-get install -q -y --no-install-recommends \
              ubuntu-desktop unity-lens-applications unity-lens-files \
              gnome-panel firefox                                       || die

# non-fatal
sudo apt-get install -q -y --no-install-recommends firefox-gnome-support

sudo apt-get install -q -y libfontconfig1-dev libkrb5-dev libfreetype6-dev    \
               libx11-dev libxcursor-dev libxext-dev libxfixes-dev libxft-dev \
               libxi-dev libxrandr-dev libxrender-dev libcups2-dev libsm-dev  \
               libxinerama-dev                                                \
               gcc make                                                 || die

cdir /home/vagrant/dev

if [ "$QTVER" -eq 4 ] ; then
  M=4 N=8 P=6
  QTDOWNLOADURL=http://download.qt.io/official_releases/qt/$M.$N/$M.$N.$P/
elif [ "$QTVER" -eq 5 ] ; then
  M=5 N=5 P=0
  QTDOWNLOADURL=http://download.qt.io/official_releases/qt/$M.$N/$M.$N.$P/single/$TARFILE
fi

TARFILE=qt-everywhere-opensource-src-$M.$N.$P.tar.gz
wget $QTDOWNLOADURL/$TARFILE

QTDIR=/usr/local/Trolltech/Qt-$M.$N.$P
tar xvf $TARFILE
cdir $(basename $TARFILE .tar.gz)

echo "Configuring Qt"
if [ "$QTVER" -eq 4 ] ; then
  ./configure -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg \
              -plugin-sql-psql -plugin-sql-odbc -plugin-sql-sqlite   \
              -lkrb5 -webkit -nomake examples -nomake demos          \
              -confirm-license -fontconfig -opensource -continue        || die 1 "Qt didn't configure"
else
  ./configure -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg \
              -plugin-sql-psql -plugin-sql-odbc -plugin-sql-sqlite   \
              -lkrb5 -webkit -nomake examples -nomake demos          \
              -confirm-license -fontconfig -opensource -continue       || die 1 "Qt didn't configure"
fi

echo "Building Qt -- GO GET SOME COFFEE IT'S GOING TO BE A WHILE"
make -j4                                || die 1 "Qt didn't build"

echo "Installing Qt -- Get another cup"
sudo make -j1 install                   || die 1 "Qt didn't install"
# this shouldn't be necessary:
sudo chmod -R go+rX /usr/local/Trolltech/Qt-4.8.6

PATH=$QTDIR/bin:$PATH
for STARTUPFILE in .profile .bashrc ; do
  echo "PATH=$QTDIR/bin:\$PATH" >> $STARTUPFILE
done

echo "Compiling OPENRPT dependency"
cdir /home/vagrant/dev/qt-client/openrpt
qmake                                   || die 1 "openrpt didn't qmake"
make -j4                                || die 1 "openrpt didn't build"
echo "Compiling CSVIMP dependency"
cdir ../csvimp
qmake                                   || die 1 "csvimp didn't qmake"
make -j4                                || die 1 "csvimp didn't build"
echo "Compiling qt-client itself"
cdir ..
qmake                                   || die 1 "qt-client didn't qmake"
make -j4                                || die 1 "qt-client didn't build"

echo "$HOME/dev/qt-client/openrpt/lib
$HOME/dev/qt-client/lib" | sudo tee -a /etc/ld.so.conf.d/xtuple.conf
sudo ldconfig

echo "The xTuple vagrant setup script is done!"
