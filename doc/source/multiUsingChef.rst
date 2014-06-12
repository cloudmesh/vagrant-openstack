Multi worker DevStack using Vagrant and Chef Cookbooks
================================================================================

OpenStack Distributions
----------------------------------------------------------------------

OpenStack is a opensource and a very complex code set. Due to the complexity involved in setting up an OpenStack Cloud, companies such as RackSpace, Redhat, Mirantis etc., took the OpenStack code and packaged it for easy deployment by clients. In addition to the core OpenStack code, the vendors would add addtional componenets to ease the deployment along with value add features such as monitoring etc. For example, Rackspace has taken the OpenStack code and packaged it along with value add features such as High Availability componenets, Chef Server etc. 

An explanation about difference between OpenStack Distribution and Rackspace Private Cloud can be found in the links below:

* http://www.rackspace.com/blog/openstack-the-project-the-rackspace-product-and-the-rackspace-service/
* http://www.rackspace.com/blog/rackspace-private-cloud-is-open/
* http://www.rackspace.com/information/legal/rpcswpackages

There are various cookbooks made available by vendors which can be used to setup a cluster. 

.. note:: 

  We are trying to plugin a new scheduler which works based on Calendar events. When the cluster is being setup using Cookbooks as shown in the steps below, we will not be able to plugin a new scheduler as there is no provision to do one. This has been clarified with people from Rackspace. Aravindh had raised a query with Rackspace and they confirmed that they is no provision at the moment and they had asked Aravindh to see if he could look into the Cookbooks and start from there.


Multi-Node OpenStack Install
----------------------------------------------------------------------

The vagrant script below uses the cookbooks from Rackspace to setup a cluster with the following nodes:

* Chef
* Controller
* Compute1
* Compute2
* Cinder

The steps to be followed to create a cluster for the above nodes are 
given below:

* mkdir havana
* cd havana
* vagrant init

Replace the contents of the Vagrantfile generated in the previous step with the contents below::

  # -*- mode: ruby -*-
  # vi: set ft=ruby :
 
  VAGRANTFILE_API_VERSION = "2"
  $script = <<SCRIPT
  echo root:vagrant | chpasswd
  cat << EOF >> /etc/hosts
   192.168.236.10 chef
   192.168.236.11 controller
   192.168.236.12 compute1
   192.168.236.13 compute2
   192.168.236.14 cinder
  EOF
  SCRIPT
  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.box = "precise64"
 
  # Turn off shared folders
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
 
  # Begin chef
  config.vm.define "chef" do |chef_config|
   chef_config.vm.hostname = "chef"
   chef_config.vm.provision "shell", inline: $script
   # eth1 configured in the 192.168.236.0/24 network
   chef_config.vm.network "private_network", ip: "192.168.236.10"
 
   chef_config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "512"]
    v.customize ["modifyvm", :id, "--cpus", "1"]
   end
  end
  # End chef
 
 # Begin controller
  config.vm.define "controller" do |controller_config|
   controller_config.vm.hostname = "controller"
   controller_config.vm.boot_timeout = 600
   controller_config.vm.provision "shell", inline: $script
   # eth1 configured in the 192.168.236.0/24 network
   controller_config.vm.network "private_network", ip: "192.168.236.11"

   controller_config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048"]
    v.customize ["modifyvm", :id, "--cpus", "1"]
   end
  end
  # End controller
 
  # Begin compute1
  config.vm.define "compute1" do |compute1_config|
   compute1_config.vm.hostname = "compute1"
   compute1_config.vm.provision "shell", inline: $script
   # eth1 configured in the 192.168.236.0/24 network
   compute1_config.vm.network "private_network", ip: "192.168.236.12"
 
   compute1_config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
    v.customize ["modifyvm", :id, "--cpus", "2"]
    # eth2 left unconfigured so the Chef Cookbooks can configure it
    v.customize ["modifyvm", :id, "--nic3", "intnet"]
   end
  end
  # End compute1
  
  # Begin compute2
  config.vm.define "compute2" do |compute2_config|
   compute2_config.vm.hostname = "compute2"
   compute2_config.vm.provision "shell", inline: $script
   # eth1 configured in the 192.168.236.0/24 network
   compute2_config.vm.network "private_network", ip: "192.168.236.13"
 
   compute2_config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
    v.customize ["modifyvm", :id, "--cpus", "2"]
    # eth2 left unconfigured so the Chef Cookbooks can configure it
    v.customize ["modifyvm", :id, "--nic3", "intnet"]
   end
  end
  # End compute2
  # Begin cinder
  config.vm.define "cinder" do |cinder_config|
   cinder_config.vm.hostname = "cinder"
   cinder_config.vm.provision "shell", inline: $script
   # eth1 configured in the 192.168.236.0/24 network
   cinder_config.vm.network "private_network", ip: "192.168.236.14"

   cinder_config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "512"]
    v.customize ["modifyvm", :id, "--cpus", "1"]
   end
  end
  # End cinder
 end

* Save the Vagranfile
* Run the command: **vagrant up**
* The command will bring up all the nodes: chef, controller, compute1, compute2 and cinder.
* Horizon Dashboard should now be available at https://192.168.236.11/auth/login/. The user name is "**admin**" and password is "**secrete**" 
* When we bring up the cluster for the second time, we can shutdown the chef node: **vagrant halt chef**

