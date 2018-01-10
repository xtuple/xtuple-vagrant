#!/bin/bash

PROG=${PROG:-$(basename $0)}
VAGRANTPREFIX=/vagrant
if [ ! -e $VAGRANTPREFIX/webdev_setup.sh ] ; then
  VAGRANTPREFIX=.
fi
source $VAGRANTPREFIX/webdev_setup.sh

sudo apt-get install -q -y --no-install-recommends \
              ubuntu-desktop unity-lens-applications unity-lens-files \
              gnome-panel firefox                                       || die

# non-fatal
sudo apt-get install -q -y --no-install-recommends firefox-gnome-support

sudo apt-get install -q -y libfontconfig1-dev libkrb5-dev libfreetype6-dev    \
               libx11-dev libxcursor-dev libxext-dev libxfixes-dev libxft-dev \
               libxi-dev libxrandr-dev libxrender-dev gcc make          || sicken installing dev dependencies

sudo apt-get install -q -y xorg libxdamage-dev \
               libxinerama-dev libx11-xcb-dev "^libxcb.*" libxcomposite-dev     \
               libasound2-dev libegl1-mesa-dev libgl1-mesa-dev libglu1-mesa-dev \
               libgstreamer0.10-dev libgstreamer1.0-dev libcups2-dev libsm-dev  \
               libgstreamer-plugins-base0.10-dev libgstreamer-plugins-base1.0-dev \
               libicu-dev libldap2-dev libmysqlclient-dev libossp-uuid-dev      \
               libpam0g-dev libpam-dev libperl-dev libreadline6-dev             \
               libsqlite0-dev libssl-dev libwebp-dev libxml2-dev libxslt1-dev   \
               libxslt-dev mesa-common-dev                                      \
               bison build-essential flex g++ gperf icu-devtools       \
               perl python readline-common ruby unixodbc-dev xorg zlib1g-dev    || sicken installing qt prereqs

cdir $HOME/dev

if [ "$QTVER" -eq 5 ] ; then
  M=5 N=5 P=1
  QTDOWNLOADURL=http://download.qt.io/archive/qt/$M.$N/$M.$N.$P/single/$TARFILE
fi

TARFILE=qt-everywhere-opensource-src-$M.$N.$P.tar.gz
wget $QTDOWNLOADURL/$TARFILE

QTDIR=$HOME/dev/Qt-$M.$N.$P
tar xvf $TARFILE
cdir $(basename $TARFILE .tar.gz)

echo "Configuring Qt"
if [ "$QTVER" -eq 5 ] ; then
  ./configure -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg \
              -plugin-sql-psql -plugin-sql-odbc -plugin-sql-sqlite   \
              -lkrb5 -webkit -nomake examples                        \
              -confirm-license -fontconfig -opensource -continue       || die 1 "Qt didn't configure"
fi

MAKEFLAGS=-j$(nproc)

echo "Building Qt -- GO GET SOME COFFEE IT'S GOING TO BE A WHILE"
make                                 || die 1 "Qt didn't build"

echo "Installing Qt -- Get another cup"
sudo make -j1 install                || die 1 "Qt didn't install"

sudo chmod -R go+rX $QTDIR

PATH=$QTDIR/bin:$PATH
for STARTUPFILE in .profile .bashrc ; do
  echo "PATH=$QTDIR/bin:\$PATH" >> $STARTUPFILE
done

echo "Compiling OPENRPT dependency"
cdir $HOME/dev/qt-client/openrpt
qmake                                   || sicken "openrpt didn't qmake"
make -j$MAKEJOBS                        || sicken "openrpt didn't build"
echo "Compiling CSVIMP dependency"
cdir ../csvimp
qmake                                   || sicken "csvimp didn't qmake"
make -j$MAKEJOBS                        || sicken "csvimp didn't build"
echo "Compiling qt-client itself"
cdir ..
qmake                                   || sicken "qt-client didn't qmake"
make -j$MAKEJOBS                        || sicken "qt-client didn't build"

echo "$HOME/dev/qt-client/openrpt/lib
$HOME/dev/qt-client/lib" | sudo tee -a /etc/ld.so.conf.d/xtuple.conf
sudo ldconfig

echo "The xTuple vagrant setup script is done!"
echo Warnings:
echo $WARNINGS | tr ";" "\\n"
