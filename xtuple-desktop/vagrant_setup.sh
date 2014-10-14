#!/bin/sh

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
 mesg n
fi

# set xtuple source directory
XTUPLE_DIR=/home/vagrant/dev/xtuple/

# handy little function from install_script
cdir() {
  echo "Changing directory to $1"
  cd $1
}

exitEarly() {
  local RESULT=63
  if [ $* -gt 0 ] ; then
    RESULT=$1
    shift
  fi
  echo $*
  exit $RESULT
}

# install git
echo "Installing Git"
sudo apt-get install git -y

# this is temporary fix for the problem where Windows
# cannot translate the symlinks in the repository
echo "Creating symlink to lib folder"
cdir /home/vagrant/dev/xtuple/lib/
rm module
ln -s ../node_modules/ module
git update-index --assume-unchanged module

echo "Creating symlink to application folder"
cdir /home/vagrant/dev/xtuple/enyo-client/application/
rm lib
ln -s ../../lib/ lib
git update-index --assume-unchanged lib

cdir $XTUPLE_DIR
echo "Beginning install script"
bash scripts/install_xtuple.sh

echo "Adding Vagrant PostgreSQL Access Rule"
echo "host all all  0.0.0.0/0 trust" | sudo tee -a /etc/postgresql/9.1/main/pg_hba.conf

echo "Restarting Postgres Database"
sudo service postgresql restart

##begin qtdev wizardry
cdir /home/vagrant/dev
sudo apt-get install -q -y libfontconfig1-dev libkrb5-dev libfreetype6-dev    \
               libx11-dev libxcursor-dev libxext-dev libxfixes-dev libxft-dev \
               libxi-dev libxrandr-dev libxrender-dev gcc make
sudo apt-get install -q -y --no-install-recommends ubuntu-desktop \
               firefox firefox-gnome-support
wget http://download.qt-project.org/official_releases/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz
tar xvf qt-everywhere-opensource-src-4.8.6.tar.gz
cdir qt-everywhere-opensource-src-4.8.6
echo "Configuring Qt"
./configure -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg \
            -plugin-sql-psql -plugin-sql-odbc -plugin-sql-sqlite   \
            -I /usr/local/pgsql/include -L /usr/local/pgsql/lib    \
            -lkrb5 -webkit -nomake examples -nomake demos          \
            -confirm-license -fontconfig -opensource -continue
echo "Building Qt 4.8.6--GO GET SOME COFFEE IT'S GOING TO BE A WHILE"
make -j4                                || exitEarly 1 "Qt didn't build"

echo "Installing Qt 4.8.6--Get another cup"
sudo make -j1 install                   || exitEarly 1 "Qt didn't install"

echo "Compiling OPENRPT dependency"
cdir /home/vagrant/dev/qt-client/openrpt
/usr/local/Trolltech/Qt-4.8.6/bin/qmake || exitEarly 1 "openrpt didn't qmake"
make -j4                                || exitEarly 1 "openrpt didn't build"
echo "Compiling CSVIMP dependency"
cdir ../csvimp
/usr/local/Trolltech/Qt-4.8.6/bin/qmake || exitEarly 1 "csvmip didn't qmake"
make -j4                                || exitEarly 1 "csvmip didn't build"

cdir /home/vagrant
for STARTUPFILE in .profile .bashrc ; do
  echo '[[ "$PATH" =~ Qt-4.8.6 ]] || export PATH=/usr/local/Trolltech/Qt-4.8.6/bin:$PATH' >> $STARTUPFILE
done

echo "Qt development environment finished!"
echo "To get started cd /home/vagrant/dev/qt-client qmake then make to build xTuple desktop!"
##end qtdev wizardry

echo "The xTuple Server install script is done!"
