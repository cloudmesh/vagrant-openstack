#!/bin/bash

######################################################################
# Author        : Aravindh Varadharaju
# Date          : 6th April 2014
# Purpose       : Controller Script
# Description : This script is modified from 
#        http://stackoverflow.com/questions/16768777/can-i-switch-user-in-vagrant-bootstrap-shell-script
######################################################################

case $(id -u) in
    0) 
        #echo "first: running as root"
        #echo "doing the root tasks..."

        #groupadd stack
        #useradd -g stack -s /bin/bash -d /opt/stack -m stack
        #echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

        sudo ufw disable
        sudo apt-get -q -y update
        sudo apt-get install -y git
        sudo apt-get install -y python-pip
        
        git clone https://github.com/openstack-dev/devstack.git
        chown -R vagrant:vagrant devstack
   
        # When creating the stack deployment for the first time,
        # you are going to see prompts for multiple passwords.
        # Your results will be stored in the localrc file.
        # If you wish to bypass this, and provide the passwords up front,
        # add in the following lines with your own password to the localrc file

        echo '[[local|localrc]]' > local.conf
        #echo HOST_IP=192.168.236.11 >> local.conf
        #echo FLAT_INTERFACE=eth0 >> local.conf
        #echo FIXED_RANGE=10.4.128.0/20 >> local.conf
        #echo FIXED_NETWORK_SIZE=4096 >> local.conf
        echo MULTI_HOST=1 >> local.conf
        echo LOGFILE=/home/vagrant/stack.sh.log >> local.conf
        echo ADMIN_PASSWORD=labstack >> local.conf
        echo MYSQL_PASSWORD=supersecret >> local.conf
        echo RABBIT_PASSWORD=supersecrete >> local.conf
        echo SERVICE_PASSWORD=supersecrete >> local.conf
        echo SERVICE_TOKEN=1qaz2wsx >> local.conf
        #echo FLAT_INTERFACE=eth1 >> local.conf
        mv local.conf /home/vagrant/devstack
        chown vagrant:vagrant /home/vagrant/devstack/local.conf
        
        #for i in `seq 2 10`; do /opt/stack/nova/bin/nova-manage fixed reserve 10.4.128.$i; done
        sudo -u vagrant -i $0  # script calling itself as the vagrant user
        ;;
    *) 
        #echo "then: running as vagrant user"
        #echo "doing the vagrant user's tasks"
        #echo "########################################"
        #echo "I going to run ./stack.sh as `whoami`"
        #echo "########################################"
        cd /home/vagrant/devstack
        ./stack.sh
        ;;
esac
