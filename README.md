## Creating a Vagrant Virtual Development Environment ##

[Vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html) is open-source software used to create lightweight and portable virtual development environments. Vagrant works like a "wrapper" for VirtualBox that can create, configure, and destroy virtual machines with the use of its own terminal commands. Vagrant facilitates the setup of environments without any direct interaction with VirtualBox and allows developers to use preferred editors and browsers in their native operating system. [This blog](http://mitchellh.com/the-tao-of-vagrant) describes a typical workflow using Vagrant in a development environment.

New to Github? Learn more about basic Github activities [here](https://help.github.com/categories/54/articles).

Note: This document is for setting up a virtual environment on a Unix host. If you are using a Windows host,
please use [these instructions](../../wiki/Creating-a-Vagrant-Virtual-Environment-on-a-Windows-Host).

###  Install Vagrant ###

- Download and install [VirtualBox 4.3.12](https://www.virtualbox.org/wiki/Downloads)
  - Do not open VirtualBox or create a virtual machine. This will be handled by Vagrant.
- Download and install [Vagrant 1.6.4](http://www.vagrantup.com/download-archive/v1.6.4.html)
  - Package managers like apt-get and gem install will install an older version of Vagrant so it is required to use the download page.

[Fork](http://github.com/xtuple/xtuple/fork) the `xtuple`, [fork](http://github.com/xtuple/xtuple-extensions/fork)  `xtuple-extensions`, and [fork](http://github.com/xtuple/xtuple-vagrant/fork) `xtuple-vagrant` repositories on Github.

Clone your forks of the `xtuple` and `xtuple-extensions` repositories to a directory on your host machine:

    host $ mkdir dev
    host $ cd dev
    host $ git clone --recursive https://github.com/<your-github-username>/xtuple.git
    host $ git clone --recursive https://github.com/<your-github-username>/xtuple-extensions.git

Clone your fork of the `xtuple-vagrant` repository in a separate directory adjacent to your development folder:

    host $ cd ..
    host $ mkdir vagrant
    host $ cd vagrant
    host $ git clone https://github.com/<your-github-username-here>/xtuple-vagrant.git
    host $ cd xtuple-vagrant

**Important**: If you have previously forked these repositories, please ensure that you [update your fork](../../../xtuple/wiki/Basic-Git-Usage#wiki-merging) and [update your dependencies](../../../xtuple/wiki/Upgrading#wiki-update-stack-dependencies).

### Set up Vagrant ###

- In the `Vagrantfile`, ensure that the `sourceDir` variable matches the location of the cloned xTuple source code: `sourceDir = "../../dev"`
  - This path should be relative to the location of the Vagrantfile

### Install VirtualBox Guest Additions Plugin

    vagrant plugin install vagrant-vbguest

### Connect to the Virtual Machine ###

Start the virtual machine[*](#configure-your-vm):

    host $ vagrant up

Vagrant will automatically run a shell script to install git and the xTuple development environment.

Connect to the virtual machine via ssh:

    host $ vagrant ssh

The xTuple source code is synced to the folder `~/dev`

Start the datasource:

    vagrant $ cd dev/xtuple/node-datasource
    vagrant $ node main.js

### xTuple Mobile Web

Launch your local browser and navigate to application using localhost `http://localhost:8888` or the static IP Address of the virtual machine `http://192.168.33.10:8888`

Default username and password to your local application are `admin`

### xTuple Desktop Client ###

- Obtain the [xTuple Desktop Client Installer](https://sourceforge.net/projects/postbooks/files/latest/download?source=dlp) for your platform. To be sure the PostBooks Desktop Client version matches the PostBooks database version you are installing, look at the "About" information in the Mobile client.

- Run the installer. On the screen where you select an xTuple database, select "I do not need a Free Trial database."
-  Complete the installation and launch the Desktop Client. On the login screen, enter these credentials to connect to your local xTuple server:
  * Username: `admin`
  * Password: `admin`
  * Server : `192.168.33.10`
  * Port: `5432`
  * Database: `demo`

### Configure Your VM ###

Sometimes you need to change the default configuration of your virtual machine. For this reason we've made it easy to change some basic settings of the vagrant VMs.

There is a list of variables at the top of the `Vagrantfile`. You can override these settings by creating a file called `xtlocal.rb` and placing new variable assignments in this file. For example, if you need to change the amount of memory the VM can use, override the `xtVboxMemory` setting:

    host $ cat 'xtVboxMemory = "2048"' > xtlocal.rb

One common case is configuring a second or third VM running on a single host. This is easy to do. You must overrride the network address of the VM and the network ports that the host forwards to the VM. To assign these ports manually, change the `xtlocal.rb` file to look like this:

    xtHostAddr      = "192.168.33.11"
    xtHostAppPort   = 8444
    xtHostRestPort  = 3001
    xtHostWebPort   = 8889

You can also use the `xtHostOffset` variable:

First get the variables to change:

    host $ egrep ^xtHost Vagrantfile > xtlocal.rb

Then edit the resulting file to look something like this:

    xtHostOffset    = 2
    xtHostAddr      = "192.168.33.12"
    xtHostAppPort   = xtGuestAppPort + xtHostOffset
    xtHostRestPort  = xtGuestRestPort + xtHostOffset
    xtHostWebPort   = xtGuestWebPort  + xtHostOffset

### Additional Information ###

Shutting down, restarting, and destroying your VM:

[Basic commands](https://github.com/xtuple/xtuple-vagrant/wiki/Vagrant-Tips-and-Tricks)
