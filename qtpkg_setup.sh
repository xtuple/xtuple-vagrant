#!/bin/sh

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

if ! grep -q QTVER scripts/install_xtuple.sh && [ "$QTVER" = 5 ] ; then
  echo USING Qt 4 UNTIL install_xtuple.sh ACCEPTS -q
  QTVER=4
fi
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
               libxi-dev libxrandr-dev libxrender-dev gcc make          || die

if [ "$QTVER" -eq 5 ] ; then
  sudo apt-get install -q -y qt5-qmake libqt5core5a libqt5designer5             \
                             libqt5designercomponents5 libqt5gui5               \
                             libqt5help5 libqt5network5 libqt5printsupport5     \
                             libqt5script5 qtscript5-dev libqt5scripttools5     \
                             libqt5sql5 libqt5sql5-odbc                         \
                             libqt5sql5-psql libqt5webkit5 libqt5widgets5       \
                             libqt5xml5 libqt5xmlpatterns5                      \
                             libqt5webkit5-dev libqt5xmlpatterns5-dev           \
                             qttools5-dev qttools5-dev-tools              || die
  sudo mkdir           /usr/lib/x86_64-linux-gnu/qt5/plugins/designer
  sudo chown $(whoami) /usr/lib/x86_64-linux-gnu/qt5/plugins/designer
elif [ "$QTVER" -eq 4 ] ; then
  sudo apt-get install -q -y qt4-qmake libqt4-dev-bin libqt4-dev libqtcore4     \
                             libqtgui4 libqt4-designer libqt4-help libqt4-sql   \
                             libqt4-network libqt4-script libqt4-scripttools    \
                             libqt4-xml libqt4-xmlpatterns libqtwebkit4         \
                                                                          || die
fi

MAKEJOBS=$(nproc)

echo "Compiling OPENRPT dependency"
cdir /home/vagrant/dev/qt-client/openrpt
qmake                                   || die 1 "openrpt didn't qmake"
make -j$MAKEJOBS                        || die 1 "openrpt didn't build"
echo "Compiling CSVIMP dependency"
cdir ../csvimp
qmake                                   || die 1 "csvimp didn't qmake"
make -j$MAKEJOBS                        || die 1 "csvimp didn't build"
echo "Compiling qt-client itself"
cdir ..
qmake                                   || die 1 "qt-client didn't qmake"
make -j$MAKEJOBS                        || die 1 "qt-client didn't build"

echo "$HOME/dev/qt-client/openrpt/lib
$HOME/dev/qt-client/lib" | sudo tee -a /etc/ld.so.conf.d/xtuple.conf
sudo ldconfig

echo "The xTuple vagrant setup script is done!"
