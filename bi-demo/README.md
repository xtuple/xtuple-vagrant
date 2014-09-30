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
	
Start the virtual machine:

    host $ vagrant up

In your host file add the followign mapping:
  192.168.33.10 administrator-460-dev.localhost
	
Launch your local browser and navigate to application using https://vagrant-460-dev.localhost:443

BI won't work unless you manually change the nginx sites-available to define the BI gateway