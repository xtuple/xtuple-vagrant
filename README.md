## xTuple and Vagrant

xTuple uses Vagrant to build disposable Linux virtual machines
(VMs).  The files in the
[xtuple-vagrant repository](https://github.com/xtuple/xtuple-vagrant)
simplify spinning up new VMs for several different use cases,
including hosting demonstration databases and developing for the
mobile web and desktop clients.

The setup files and instructions below are designed to let you edit
files on either the host computer or from the VM. There are other
ways to use Vagrant. This system works for us.

## Creating a Vagrant Virtual Development Environment

[Vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html) is open-source software used to create lightweight and portable virtual development environments. Vagrant works like a "wrapper" for VirtualBox that can create, configure, and destroy virtual machines with the use of its own terminal commands. Vagrant facilitates the setup of environments without any direct interaction with VirtualBox and allows developers to use preferred editors and browsers in their native operating system. [This blog](http://mitchellh.com/the-tao-of-vagrant) describes a typical workflow using Vagrant in a development environment.

New to Github? Learn more about basic Github activities [here](https://help.github.com/categories/54/articles).

**Note:** If you are using a Windows host, please use [these instructions](../../wiki/Creating-a-Vagrant-Virtual-Environment-on-a-Windows-Host).

###  Install Vagrant

- Download and install
  [VirtualBox 4.3.12](https://www.virtualbox.org/wiki/Download_Old_Builds_4_3).
  Do not open VirtualBox or create a virtual machine. This will be done by Vagrant later.
- Download and install
  [Vagrant 1.6.4](http://www.vagrantup.com/download-archive/v1.6.4.html).
  Package managers like apt-get and gem install will install different
  versions of Vagrant so you must use the download page.

### Install git

Make sure you have git installed on your host computer. You can do this in any of several
different ways:

- `$ sudo apt-get install git` on some Linux distributions
- installing Xcode from Apple's App Store
- downloading GitHub's [desktop client](https://desktop.github.com)
- downloading an installer from [git-scm.com](http://git-scm.com/downloads)

### Get the Source Files

Fork the following repositories on GitHub:

- [xtuple](http://github.com/xtuple/xtuple/fork)
- [xtuple-extensions](http://github.com/xtuple/xtuple-extensions/fork)
- [qt-client](http://github.com/xtuple/qt-client/fork) only if you are going to make
  changes to xTuple's desktop client
- [openrpt](http://github.com/xtuple/openrpt/fork) only if you are going to make
  changes to the OpenRPT report writer
- [csvimp](http://github.com/xtuple/csvimp/fork) only if you are going to make
  changes to the CSVImp utility

**Important**: If you have previously forked these repositories, you should
[update your fork](../../../xtuple/wiki/Basic-Git-Usage#wiki-merging) and
[update your dependencies](../../../xtuple/wiki/Upgrading#wiki-update-stack-dependencies).

Clone your forks of the `xtuple` and `xtuple-extensions` repositories to a directory on your host machine:

    host $ mkdir dev
    host $ cd dev
    host $ git clone --recursive https://github.com/<your-github-username>/xtuple.git
    host $ git clone --recursive https://github.com/<your-github-username>/xtuple-extensions.git
    host $ #and the following only if you plan to change them
    host $ git clone --recursive https://github.com/<your-github-username>/qt-client.git
    host $ git clone --recursive https://github.com/<your-github-username>/openrpt.git
    host $ git clone --recursive https://github.com/<your-github-username>/csvimp.git

Clone xtuple's `xtuple-vagrant` repository in a separate directory adjacent to your development folder:

    host $ cd ..
    host $ ls dev       # this should show xtuple, xtuple-extensions, ...
    host $ mkdir vagrant
    host $ cd vagrant
    host $ git clone https://github.com/xtuple/xtuple-vagrant.git   # no need to fork
    host $ cd xtuple-vagrant

### Configure Your VM

You probably need to configure your VM before you start it for the first time.
We've made it easy to change some basic settings that control how the VM
interacts with the host computer and what software gets installed in the VM.
You can change the amount of memory the VM uses, its hostname and IP address,
what version of PostgreSQL is installed, etc.

There is a list of variables at the top of the `Vagrantfile`. You can override these settings by creating a file called `xtlocal.rb` and placing new variable assignments in this file. For example, if you need to change the amount of memory the VM can use, override the `xtVboxMemory` setting:

    host $ cat 'xtVboxMemory = "2048"' > xtlocal.rb

One common case is configuring a second or third VM running on a single host. This is easy to do. You must overrride the network address of the VM and the network ports that the host forwards to the VM. To assign these ports manually, change the `xtlocal.rb` file to look like this:

    xtHostAddr      = "192.168.33.11"
    xtHostAppPort   = 8444
    xtHostRestPort  = 3001
    xtHostWebPort   = 8889

You can also use the `xtHostOffset` variable. First get the variables to change:

    host $ egrep ^xtHost Vagrantfile > xtlocal.rb

Then edit the resulting file to look something like this:

    xtHostOffset    = 2
    xtHostAddr      = "192.168.33.12"
    xtHostAppPort   = xtGuestAppPort  + xtHostOffset
    xtHostRestPort  = xtGuestRestPort + xtHostOffset
    xtHostWebPort   = xtGuestWebPort  + xtHostOffset

Now make sure the VM will play nicely with your host machine:

    host $ vagrant plugin install vagrant-vbguest

**Important**: Make sure the `xtSourceDir` variable matches the
location of the cloned xTuple source code on the host machine. It
should be a relative path

**Important**: The default configuration runs a script to set up the VM
for mobile-web client development. You can override this by changing the
`xtHostSetupFile`:

- `mvdev_setup.sh` sets up the VM for developing the mobile web client.
- `qtsrc_setup.sh` downloads the source code for Qt 4, then compiles
  and installs it.  This takes a long time but is similar to the
  configuration we use to build the desktop client for releases.
  The resulting VM may be used for both desktop and mobile web
  client development.
- Create your own script to set up a VM for a different purpose.

### Connect to the Virtual Machine

Start the virtual machine:

    host $ vagrant up

Vagrant will automatically run the shell script named by the
`xtHostSetupFile` variable in either the `Vagrantfile` or `xtlocal.rb`
to install the right tools. This may take anywhere from a few minutes
to a few hours to run, depending on which script you choose to run.

Connect to the virtual machine via ssh:

    host $ vagrant ssh

Note that the xTuple source code is synced to the folder `~/dev`:

    vagrant $ ls dev    # you should see xtuple and xtuple-extensions

Start the datasource:

    vagrant $ cd dev/xtuple/node-datasource
    vagrant $ node main.js

### xTuple Mobile Web

Launch your local browser and navigate to application using localhost
`http://localhost:8888` or the static IP address of the the virtual
machine `http://192.168.33.10:8888`. You will need to use a different
IP address or port if you changed `xtHostAddr` or `xtHostOffset` in your `xtlocal.rb`.

The default username and password to your local application are `admin`

### xTuple Desktop Client

The xTuple ERP desktop client application can use the database
server running in the vagrant VM. Just make sure the application
matches the xTuple database version - that is, run a 4.9.1 client
to talk to a 4.9.1 database, 4.10.0 development client to talk to
a 4.10.0 development database, etc. Just make sure to log in to
the database using the `admin` user, `admin` password (unless you changed it!-),
and proper IP address and database server port.


#### Simplifying Desktop Development
If you set up the VM for desktop client development, you can
[tweak the VM configuration](#configure-your-vm) to make it easier
to work in. Set the `xtGui` variable to `true` in `xtlocal.rb` and
restart the VM:

    host $ vagrant reload

This will reboot the VM and show the Linux display in a VirtualBox
window so you can work in it directly.  You can still connect to
the VM on the command line with `vagrant ssh`. Remember that you should
use vagrant commands to shutdown or reboot the VM whenever possible.

#### Using Qt Creator

**Note**: This section is optional and only relevant if you are changing
the xTuple ERP desktop client application.

Qt Creator is a good IDE for working with Qt projects but we at
xTuple have had trouble getting it to work properly.  The
`qtkpt_setup.sh` and `qt4src_setup.sh` scripts install Qt Creator
for you but you do not have to use it. There are a few things you
need to know:

- Open the qt-client project by navigating to the `qt-client` directory and opening `xtuple.pro`
- The xTuple widgets plugin must be installed properly before you can edit `.ui` files. You can tell whether it's installed by opening a `.ui` within Creator and making sure there is a section called _xTuple Custom Widgets_ in the widgets palette.
- If it isn't there, check **Tools** > **Form Editor** > **About Qt Designer Plugins...** and look under **Failed Plugins**.
  - If the xTuple plugin is listed but there was an error loading it, try clicking the **Refresh** button.
  - If the xTuple plugin is not listed:
    1. close the `.ui` file
    1. open any `.cpp` file in the `widgets` directory and make a simple change, like adding then removing a space
    1. save the modified `.cpp`
    1. click the **Build Project** button (looks like a hammer)
    1. open **Refresh** the plugins again as described above
    1. open a `.ui` file and double-check the widgets palette
  - If you continue to have problems:
    - make sure you have write-permissions on `/usr/lib/x86_64-linux-gnu/qt4/plugins/designer` and that it contains `libxtuplewidgets.so`
    - check that `/etc/ld.so.conf.d/xtuple.conf` exists and that it lists both the `/home/vagrant/dev/qt-client/lib` and `/home/vagrant/dev/qt-client/openrpt/lib` dirs. If not, create this file, add each of these directories on separate lines, and run `ldconfig`.

### Additional Information

Shutting down, restarting, and destroying your VM:

[Basic commands](https://github.com/xtuple/xtuple-vagrant/wiki/Vagrant-Tips-and-Tricks)

See [Configure Your VM](#configure-your-vm) if you have special
needs, such as more than one xTuple vagrant VM. If running on a Mac
with 8GB of RAM or less, [set](#configure-your-vm)
your VM to use 2GB. Set `xtVboxMemory = "2048"` in your `xtlocal.rb`,
then either `vagrant up` or `vagrant reload`.
