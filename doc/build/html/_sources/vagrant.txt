Vagrant
===========================

Vagrant is a tool that allows you to create, configure reproducible development environments. In other words it allows you to setup a Virtual Machine and provision the necessary software on the fly.  Once the environment has been created, it can be saved and then distributed to any one interested in using the environment.

So when a VM has been downloaded from Vagrant's repository, a hypervisor is required to run the Virtual Machines. The hypervisors are called as "Providers" in Vagrant world. Vagrant come with support for Virtual Box by default. But there are plugins to support other providers such as VMWare, AWS etc. So before we install Vagrant, we need to install Virtual Box.

The steps to install Vagrant and provision a VM is given below:

Installation
------------------------

* Install Virtual Box

  * Download and install Virtual Box installer from the link: https://www.virtualbox.org/wiki/Downloads

* Download and install Vagrant

  * Vagrant can be downloaded from the following link: http://www.vagrantup.com/downloads

* Once Vagrant is installed, path to Vagrant binary is added automatically to the system path and will be available to run from the command line. Vagrant will be installed under */Applications/Vagrant* in Mac OS and under */opt/vagrant* in Linux.

Commands
---------

Once vagrant is installed, run the command::

   vagrant --version

Vagrant maintains different projects under directories. To setup up a
new project, create a new directory in your preferred location. within
the project run the following command::

    vagrant init precise32 http://files.vagrantup.com/precise32.box

The above step will download the box file (which are nothing but base
images) for a 32 bit Ubuntu VM from Vagrant's repository and will
create a file called Vagrantfile which contains certain configuration
details.  We will look into the details later.  To download a 64 bit
virtual machine, run the following::
  
    vagrant init precise64 http://files.vagrantup.com/precise32.box
  
Now start the new VM by running the following command::
  
    vagrant up
  
The above step will start the VM within Virtual Box. To log into the Virtual Machine, run the following command::
  
    vagrant ssh
  
VM can be suspended using the following command::
  
    vagrant suspend
  
To check the status of the VMs, run the following command::
  
    vagrant status
  
When you are done with your VM, stop the Virtual Machine by running the following command::
  
    vagrant halt
  
To completely remove the Virtual Machine run the following command::
  
    vagrant destroy
  
The VM created above was a very basic one without much software on
it. The process of installing the necessary software on the fly while
the system is booting is termed as **provisioning**. Vagrant does
automated provisioning and runs some provisioners whenever we issue
the::

  vagrant up

command. The details about provisioning a software
will be explained in details later.

