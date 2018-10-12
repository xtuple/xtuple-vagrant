#!/bin/bash

PROG=${PROG:-$(basename $0)}
VAGRANTPREFIX=/vagrant
if [ ! -e $VAGRANTPREFIX/webdev_setup.sh ] ; then
  VAGRANTPREFIX=.
fi
source $VAGRANTPREFIX/webdev_setup.sh *@

sudo apt-get install -q -y --no-install-recommends \
              ubuntu-desktop unity-lens-applications unity-lens-files \
              gnome-panel firefox                                       || die

sudo apt-get install -q -y --no-install-recommends firefox-gnome-support

sudo apt-get install -q -y \
      bison             build-essential flex            g++                \
      gcc               gperf           icu-devtools    make               \
      mesa-common-dev   perl            python          readline-common    \
      ruby              unixodbc-dev    xorg            xsltproc           \
      zlib1g-dev        || sicken installing development tools

sudo apt-get install -q -y \
      libasound2-dev     libcap-dev             libcups2-dev                  \
      libdbus-1-dev      libegl1-mesa-dev       libfontconfig1-dev            \
      libfreetype6-dev   libgl1-mesa-dev        libglu1-mesa-dev              \
      libicu-dev         libkrb5-dev            libldap2-dev                  \
      libmysqlclient-dev libossp-uuid-dev       libpci-dev                    \
      libperl-dev        libreadline6-dev       libsm-dev                     \
      libsqlite0-dev     libssl-dev             libudev-dev                   \
      libwebp-dev        libx11-dev             libx11-xcb-dev                \
      libxcomposite-dev  libxcursor-dev         libxdamage-dev                \
      libxext-dev        libxfixes-dev          libxft-dev                    \
      libxi-dev          libxinerama-dev        libxml2-dev                   \
      libxrandr-dev      libxrender-dev         libxslt-dev                   \
      libxslt1-dev       libxtst-dev            libxtst0dev                   \
      "^libgstreamer-plugins-base.*-dev"        "^libgstreamer.*-dev"         \
      "^libnss.*-dev"    "^libpam.*-dev"        "^libxcb.*"                   \
  || sicken installing qt prereqs

cdir $HOME/dev

if [ "$QTVER" -eq 5 ] ; then
  M=5 N=5 P=1
  QTDOWNLOADURL=http://download.qt.io/archive/qt/$M.$N/$M.$N.$P/single
fi

QTDIR=$HOME/dev/Linux_Qt/Qt$M.$N.$P
TARFILE=qt-everywhere-opensource-src-$M.$N.$P.tar.xz
QTSRC=$HOME/dev/$(basename $TARFILE .tar.xz)

[ -e $TARFILE ] || wget $QTDOWNLOADURL/$TARFILE
[ -d $QTSRC ]   || tar xvfJ $TARFILE

if [ -x $QTDIR/bin/qmake ] ; then
  echo "Qt appears to be built already"
else
  cdir $QTSRC
  echo "Configuring Qt"
  if [ "$QTVER" -eq 5 ] ; then
    ./configure -release -prefix $QTDIR -openssl -fontconfig -nomake examples \
                -qt-zlib -qt-libpng -qt-libjpeg                               \
                -qt-sql-psql -qt-sql-odbc -qt-sql-sqlite                      \
                -confirm-license -opensource -continue || die 1 "Qt didn't configure"

    MAKEFLAGS=-j$(nproc)
    echo "Building Qt -- Get a cup of coffee"
    make                                 || die 1 "Qt didn't build"
    echo "Installing Qt -- Get another cup"
    sudo make -j1 install                || die 1 "Qt didn't install"
    sudo chmod -R go+rX $QTDIR

  fi
  cd $HOME/dev
fi

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
