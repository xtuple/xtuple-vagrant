# xTuple and Vagrant

[Vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html) is open-source software used to create lightweight and portable virtual development environments. Vagrant works like a "wrapper" for VirtualBox that can create, configure, and destroy virtual machines with the use of its own terminal commands. Vagrant facilitates the setup of environments without any direct interaction with VirtualBox and allows developers to use preferred editors and browsers in their native operating system. [This blog](http://mitchellh.com/the-tao-of-vagrant) describes a typical workflow using Vagrant in a development environment.

xTuple uses [vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html)
to create virtual machines for several distinct purposes:

- demonstrate the core xTuple software
- demonstrate the xTuple ERP Business Intelligence integration
- develop and test bug fixes for the xTuple Server
- develop and test bug fixes and new features for OpenRPT, CSVImp, and the xTuple ERP desktop client
- develop and test bug fixes and new features for the xTuple mobile web client
- develop and test bug fixes and new features of the xTuple ERP Business Intelligence integration

Note that all of these virtual machines run Ubuntu Linux. In all cases you can connect to the xTuple Server and database from your host environment or from the virtual machine. The development setups allow you to edit source files in either environment, too, but you will have to build the application in the VM.

xTuple recommends that you use these virtual machines, particularly for development purposes.[*](#caveat)

See the [xtuple-vagrant wiki](https://github.com/xtuple/xtuple-vagrant/wiki/Home) for instructions on getting started.

**Windows users:** Make sure that you always open the Windows Command Prompt as **Administrator** to run git and vagrant commands.

New to Github? Learn more about basic Github activities [here](https://help.github.com/categories/54/articles).

#### Caveat

* The desktop development VM cannot currently be used to build and package the desktop clients _for release_. This VM is fine for day-to-day bug fixing and feature development.
