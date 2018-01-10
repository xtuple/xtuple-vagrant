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
               libxi-dev libxrandr-dev libxrender-dev gcc make xsltproc || sicken installing dev dependencies

sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial main universe"
sudo apt-get update
sudo apt-get install -q -y qt5-qmake libqt5core5a libqt5designer5             \
                           libqt5designercomponents5 libqt5gui5               \
                           libqt5help5 libqt5network5 libqt5printsupport5     \
                           libqt5script5 qtscript5-dev libqt5scripttools5     \
                           libqt5sql5 libqt5sql5-odbc libqt5serialport5-dev   \
                           libqt5sql5-psql libqt5webkit5 libqt5widgets5       \
                           libqt5xml5 libqt5xmlpatterns5                      \
                           libqt5webkit5-dev libqt5xmlpatterns5-dev           \
                           qttools5-dev qttools5-dev-tools                    \
                           || sicken installing qt dependencies
# split for now - this part doesn't work consistently
sudo apt-get install -q -y libqt5websockets5-dev || sicken installing qt5 websockets
sudo apt-get install -q -y webchannel            || sicken installing webchannel
sudo mkdir -p        /usr/lib/x86_64-linux-gnu/qt5/plugins/designer
sudo chown $(whoami) /usr/lib/x86_64-linux-gnu/qt5/plugins/designer

MAKEJOBS=$(nproc)
export QT_SELECT=5

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
