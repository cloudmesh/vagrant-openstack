**********************************************************************
Multiworker Devstack for Vagrant
**********************************************************************

.. sidebar::  
  .
  
  .. contents::
     :depth: 5

..

The procedure below deploys Devstack with multiple workers from devstack source code. The vagrant script below sets up a cluster with the following nodes:

* Controller
* Compute1
* Compute2


Requirements
===============================

Setup a virtual environment using VirtualEnv and activate the environment::

  $ virtualenv  --no-site-packages ~/ENV
  $ source ~/ENV/bin/activate

Get reservation code, VirtualBox, Vagrant, Virtualenv and setup the requirements::

  $ mkdir ~/github
  $ cd ~/github
  $ git clone https://github.com/cloudmesh/reservation.git
  $ cd reservation
  $ ./install-prereq.sh
  $ pip install -r requirements.txt

Setup
======================================================================

The setup is easily achieved via cookiecutter, which will
create a new directory with the appropriate scripts and configuration
parameters. It will ask you for a number of parameters such as

* a label, that will be appended to the directory name where the
  scripts are located
* a password for the admin
* a password for the services
* a token for the services

Please do not use the defaults for the passwords and the tokens, but define your own strong versions.

To create the directory with the scripts::

  $ cd ~/github
  $ cookiecutter https://github.com/cloudmesh/cookiecutter-multinode-devstack.git

Than you will find a directory called multinode-<label> 

You can than cd in this directory and inspect the scripts::

  $ cd multidevstack-<TAB>

Run the command:: 

  $ vagrant up

The command will bring up all the nodes: controller, compute1 and compute2.

After the successful installation, the Horizon dashboard will be available at::

  http://192.168.236.11 

You can use the username "**admin**" and password that you have defined with the help of cookiecutter. 

Testing the setup
======================================================================

Log into the controller node::
  
  $ vagrant ssh controller

Source the openrc file for user admin (openrc configures login credentials suitable for use with the OpenStack command-line tools)::

  $ cd devstack
  $ source openrc admin admin

To list the images available in the setup::

  $ nova image-list

To list the flavors available in the setup::

  $ nova flavor-list

To boot an instance in the setup::

  $ nova boot --flavor 1 --image "cirros-0.3.1-x86_64-uec" testvm
  
The above command will boot a VM according to the specification given in the above command. 

To view the status of the "nova boot" command::

  $ nova list

When the VM is provisioned successfully, the status of the VM will be set to "ACTIVE".

To log into the provisioned VM, use the login name "cirros" and password "cubswin:)"::

  $ ssh <private-ip> -i cirros

To shutdown the provisioned VM::

  $ nova stop testvm
  
To start the provisioned VM::

  $ nova start testvm

To delete the provisioned VM::

  $ nova delete testvm
  
.. note ::

  To boot an instance on a particular node::

  $ nova boot --image cirros-0.3.1-x86_64-uec --flavor 1 --availability-zone nova:compute1 testvm

Logout of the controller VM::

  $ exit

To shutdown the VMs started by Vagrant::

  $ vagrant halt

To destroy the VMs provisioned by <vagrant up> command::

  $ vagrant destroy

.. note ::

  When the VMs are restarted, we will need to run the following on all the nodes to rejoin the screens started by stack.sh::
  
  $ vagrant ssh <node name>
  $ cd devstack
  $ ./rejoin-stack.sh

Shell Scripts
======================================================================

The section below shows the contents of the three scripts that would be created when you do "cookiecutter https://github.com/cloudmesh/cookiecutter-multinode-devstack.git".

Controller: install-controller.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`install-controller.sh <https://github.com/cloudmesh/reservation/blob/master/scripts/multinode/install-controller.sh>`_



.. include:: ../../scripts/multinode/install-controller.sh
   :literal:


Compute: install-compute.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`install-compute.sh <https://github.com/cloudmesh/reservation/blob/master/scripts/multinode/install-compute.sh>`_



.. include:: ../../scripts/multinode/install-compute.sh
   :literal:

Vagrantfile
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`Vagrantfile <https://github.com/cloudmesh/reservation/blob/master/scripts/multinode/Vagrantfile>`_



.. include:: ../../scripts/multinode/Vagrantfile
   :literal:





