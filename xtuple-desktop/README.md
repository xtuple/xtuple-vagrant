## Creating a Vagrant Virtual Development Environment For Qt AND Mobile Development##

[Vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html) is open-source software used to create lightweight and portable virtual development environments. Vagrant works like a "wrapper" for VirtualBox that can create, configure, and destroy virtual machines with the use of its own terminal commands. Vagrant facilitates the setup of environments without any direct interaction with VirtualBox and allows developers to use preferred editors and browsers in their native operating system. [This blog](http://mitchellh.com/the-tao-of-vagrant) describes a typical workflow using Vagrant in a development environment.

New to Github? Learn more about basic Github activities [here](https://help.github.com/categories/54/articles).

Note: This document is for setting up a virtual environment on a Unix host. If you are using a Windows host,
please use [these instructions](https://github.com/xtuple/xtuple-vagrant/wiki/Creating-a-Vagrant-Virtual-Development-Environment-For-Qt-AND-Mobile-Development-on-a-Windows-Host).

### Install Vagrant ###

- Download and install [VirtualBox 4.3.12](https://www.virtualbox.org/wiki/Downloads)
  - Do not open VirtualBox or create a virtual machine. This will be handled by Vagrant.
- Download and install [Vagrant 1.6.3](http://www.vagrantup.com/download-archive/v1.6.3.html)
  - Package managers like apt-get and gem install will install an older version of Vagrant so it is required to use the download page.

[Fork](http://github.com/xtuple/xtuple/fork) the `xtuple`, [fork](http://github.com/xtuple/xtuple-extensions/fork)  `xtuple-extensions`, [fork](http://github.com/xtuple/qt-client/fork) `qt-client`, and [fork](http://github.com/xtuple/xtuple-vagrant/fork) `xtuple-vagrant` repositories on Github.

Clone your forks of the `xtuple` and `xtuple-extensions` repositories to a directory on your host machine:

    host $ mkdir dev
    host $ cd dev
    host $ git clone --recursive https://github.com/<your-github-username-here>/xtuple.git
    host $ git clone --recursive https://github.com/<your-github-username-here>/xtuple-extensions.git
    host $ git clone --recursive https://github.com/<your-github-username-here>/qt-client.git

Clone your fork of the `xtuple-vagrant` repository in a separate directory adjacent to your development folder:

    host $ cd ..
    host $ mkdir vagrant
    host $ cd vagrant
    host $ git clone https://github.com/<your-github-username-here>/xtuple-vagrant.git
    host $ cd xtuple-vagrant

**Important**: If you have previously forked these repositories, please ensure that you [update your fork](../../../../xtuple/wiki/Basic-Git-Usage#wiki-merging) and [update your dependencies](../../../../xtuple/wiki/Upgrading#wiki-update-stack-dependencies).

### Setup Vagrant ###

- In the `Vagrantfile`, ensure that the `sourceDir` variable to matches the location of the cloned xTuple source code: `sourceDir = "../../dev"`
  - This path should be relative to the location of the Vagrantfile

### Connect to the Virtual Machine ###

Start the virtual machine:

    host $ cd /path/to/xtuple-vagrant/xtuple-desktop/
    host $ vagrant up

- Vagrant will automatically run a shell script to install git and the xTuple development environment(with added Qt dev environment expect this step to take a WHILE) Est ~1-2 Hours depending on internet speed.

Connect to the virtual machine via ssh:

    host $ vagrant ssh

- The xTuple source code is synced to the folder `~/dev`

Start the datasource:

    vagrant $ cd dev/xtuple/node-datasource
    vagrant $ node main.js

### xTuple Mobile Web

Launch your local browser and navigate to application using localhost `http://localhost:8888` or the static IP Address of the virtual machine `http://192.168.33.10:8888`

Default username and password to your local application are `admin`

### xTuple Desktop Development###

-From within vagrant edit your ~/.bashrc file:

    vagrant $ cd ~
    vagrant $ edit ./.bashrc
    vagrant $ add "export PATH=/usr/local/Trolltech/Qt-4.8.6/bin:$PATH" to the end of the file
    vagrant $ exit

-Enable GUI for debugging/running xTuple desktop application:

    host $ cd /path/to/xtuple-vagrant/xtuple-desktop
    host $ edit Vagrantfile
    host $ change "#v.gui = true" to "v.gui = true"

-Reload your virtual machine:

    host $ cd /xtuple-vagrant/xtuple-desktop
    host $ vagrant reload

-You should now see a GUI pop-up, dont worry if you don't want to edit inside of that GUI you can still use 'vagrant ssh' or edit the files on the host. To begin working with the Qt environment compile the application:

    host $ cd /xtuple-vagrant/xtuple-desktop
    host $ vagrant ssh
    vagrant $ cd ~/dev/qt-client
    vagrant $ qmake
    vagrant $ make

-Compiling the application will take around an hour depending on the resources allotted in your VagrantFile, after it is finished you can launch it in two ways.

    vagrant $ cd ~/dev/qt-client/bin
    vagrant $ ./xtuple

-If you prefer to use the GUI navigate to the ~/dev/qt-client/bin directory and double-click to launch the compiled xTuple application.

-When you make changes and would like to test, repeat the make step above and launch the client, editing the files from wherever you choose when connecting from your compiled application you will need to connect using these credentials:
  * Username: `admin`
  * Password: `admin`
  * Server : `localhost`
  * Port: `5432`
  * Database: `demo`

### xTuple Desktop Client###

- Obtain the [xTuple Desktop Client Installer](https://sourceforge.net/projects/postbooks/files/latest/download?source=dlp) for your platform. To be sure the PostBooks Desktop Client version matches the PostBooks database version you are installing, look at the "About" information in the Mobile client.

- Run the installer. On the screen where you select an xTuple database, select "I do not need a Free Trial database."
-  Complete the installation and launch the Desktop Client. On the login screen, enter these credentials to connect to your local xTuple server:
  * Username: `admin`
  * Password: `admin`
  * Server : `192.168.33.10`
  * Port: `5432`
  * Database: `demo`

### Additional Information ###

Shutting down, restarting, and destroying your VM:

[Basic commands](https://github.com/xtuple/xtuple-vagrant/wiki/Vagrant-Tips-and-Tricks)
