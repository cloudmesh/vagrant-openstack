DevStack
---------------------------------------------------------------------

We asume you have virtualbox and vagrant installed. This procedure will guide you to install OpenStack using DevStack. The procedure will be carried out using Shell Script Provisioner available with Vagrant. There are other standard Provisioning tools such as Chef and Puppet available. For now we will use the Shell Script Provisioner for ease of use. The steps to be followed in a nutshell is given below:

* Have Virtual Box and Vagrant installed
* Create Vagrantfile using **vagrant init** command
* Create a shell script named **install.sh** (or a different name) with the steps to install OpenStack
* Amend the Vagrantfile to call the script

The install.sh script is shown below::

 #!/bin/bash
 #################################################################################################################
 # Author        : Aravindh Varadharaju
 # Date          : 6th March 2014
 # Description   : I was strugging with running the stack.sh file as a vagrant user. Though I run the file using
 #                 "sudo su vagrant" the installation of devstack setup was failing with an error "/root/.my.cnf" 
 #                 permission denied. I was looking for a solution and the below mentioned site had a solution to 
 #                 run certain parts as root and certain parts as vagrant. This was really a blessing.
 # Script source : http://stackoverflow.com/questions/16768777/can-i-switch-user-in-vagrant-bootstrap-shell-script
 #################################################################################################################
 case $(id -u) in
  0) 
   sudo ufw disable
   sudo apt-get -q -y update
   sudo apt-get install -y git
   sudo apt-get install -y python-pip
   # sudo pip install -q netaddr
   git clone https://github.com/openstack-dev/devstack.git
   chown -R vagrant:vagrant devstack
   cd devstack
   echo ADMIN_PASSWORD=1qaz2wsx > localrc
   echo MYSQL_PASSWORD=1qaz2wsx >> localrc
   echo RABBIT_PASSWORD=1qaz2wsx >> localrc
   echo SERVICE_PASSWORD=1qaz2wsx >> localrc
   echo SERVICE_TOKEN=1qaz2wsx >> localrc
   source localrc
   sudo -u vagrant -i $0  # script calling itself as the vagrant user
  *) 
   cd /home/vagrant/devstack
   ./stack.sh
 esac

The above script needs to be placed in the project directory where the Vagrantfile is present. The next task is to modify the Vagrant file to call the shell script just created.

Add the following line to the Vagrantfile::

  config.vm.provision "shell", path: "install.sh"

Once the file is saved, run the following commands to rebuilt the VM through Vagrant::

 vagrant destroy
 vagrant up

This would take some time to run as OpenStack installation takes around 10 - 15 minutes.
