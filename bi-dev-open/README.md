## Vagrant Setup for xTuple Open BI Dev Machine ##

Download and install [VirtualBox 4.3.12](https://www.virtualbox.org/wiki/Downloads)
  - Do not open VirtualBox or create a virtual machine. This will be handled by Vagrant.
  
Download and install [Vagrant 1.6.3](http://www.vagrantup.com/download-archive/v1.6.3.html)
  - Package managers like apt-get and gem install will install an older version of Vagrant so it is required to use the download page.

Clone this xtuple-vagrant repository:

    host $ git clone https://github.com/jgunderson/xtuple-vagrant.git
	host cd xtuple-vagrant
	host git checkout bidevopen

Install VirtualBox Guest Additions Plugin

    host $ cd bi-dev-open
    host $ vagrant plugin install vagrant-vbguest
	
Start the virtual machine:

    host $ vagrant up
	
Launch your local browser, navigate to the application using https://192.168.33.10:443 and 
logon with user admin, password admin.  Select Dashboard and then + New to add charts to the dashboard.  

There isn't much CRM data in the demo database so charts will be empty for the current year unless 
you add opportunities and quotes.  There is some data for year 2007.  Select the Opportunities chart, 
select the Opportunities Amount measure and select the filter button (top right corner) and set the year to 2007.
