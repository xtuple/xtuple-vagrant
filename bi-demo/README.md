## Vagrant Setup for Commercial BI Demo ##

Download and install [VirtualBox 4.3.12](https://www.virtualbox.org/wiki/Downloads)
  - Do not open VirtualBox or create a virtual machine. This will be handled by Vagrant.
Download and install [Vagrant 1.6.3](http://www.vagrantup.com/download-archive/v1.6.3.html)
  - Package managers like apt-get and gem install will install an older version of Vagrant so it is required to use the download page.

[Fork](http://github.com/xtuple/xtuple-vagrant/fork) `xtuple-vagrant` repository on Github.

Clone your fork of the `xtuple-vagrant` repository:

    host $ git clone https://github.com/<your-github-username-here>/xtuple-vagrant.git
	
Copy your git hub keys to
    xtuple-vagrant/bi-demo/.ssh
	
Modify the config file at xtuple-vagrant/bi-demo/.ssh/config to specify your key name.

Install VirtualBox Guest Additions Plugin

    host $ cd xtuple-vagrant/bi-demo
    host $ vagrant plugin install vagrant-vbguest
	
You can update the vagrant configuration by supplying parameters in an xtlocal.rb file.  Refer
to Vagrantfile for a list of parameters.
	
Start the virtual machine:

    host $ vagrant up
	
Launch your local browser and navigate to the application using https://192.168.33.10:443