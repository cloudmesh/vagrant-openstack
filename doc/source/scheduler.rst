Changing the scheduler in openstack
======================================================================

This section expects a devstack deployment. 

Thus, if you have not deployed devstack you should first take a look
at the section on devstack deployment.

The a scheduler in openstack makes scheduling decisions in one
of the following ways:

#. **Creating a new Scheduler from scratch:** Here we create new a brand
   new scheduler. The advantage of this approach is that we have
   complete freedom to create the scheduler in whatever way need. The
   disadvantage is that the openstack schedulers have a lot already
   built into them. We can not benefit from them.

#. **Using the filtered scheduler provided by openstack and creating
   custom filters:** Openstack has an inbuilt filtered scheduler. This
   filtered scheduler uses filters which tell if a host is available
   for booting the instance or not. Openstack already provides a
   number of filters and also a provision to create new filters. The
   advantage of this method is that any new filter can be combined
   with the existing filters. THis also implies that multiple filters
   can be specified to the filter scheduler. The disadvantage is that
   we are restricted to the filter based framework.

Important directories/files
----------------------------------------------------------------------

When your openstack is setup is setup (at least using dev-stack) you
will find the deployment of openstack nova in the **/opt/stack/nova**

This is the base folder for the nova project. All your code has to be
somewhere within this path. For creating schedulers we are
specifically interested in nova.scheduler module and sub modules
**(/opt/stack/nova/nova/scheduler** or **/opt/stack/nova/nova/scheduler/filters)**. Though the custom made schedulers/ filters can be placed
anywhere within the nova project folder it would be easier if we kept
it within the above mentioned folder. Thus any of the schedulers/filters can be accessed from the
**nova.scheduler** module or **nova.scheduler.filter** module

The nova **configuration** file can be found at **/etc/nova/nova.conf**

Most of the configuration is kept in this configuration file.

We would need to modify this configuration file if we wanted change the scheduler/filter.

Creating a brand new scheduler.
---------------------------------------------------------------------------------

For creating a new scheduler the nova.scheduler.driver.Scheduler has
to be implemented. This class has the following methods

#. update_service_capabilities
#. hosts_up
#. group_hosts
#. schedule_run_instance (required to be implemented) - This is the method which schedules an
   instance. It contains a remote procedure call.
#. select_destinations (required to be impleneted)- This gives a list of destination hosts(workers/compute nodes) that
   can be used.

Some methods need to implemented as indicated above. The others have a default implementation.

The code can be found in **scripts/scheduler/ip_scheduler.py** in the
**reservation project** (`github link <https://github.com/cloudmesh/reservation/blob/master/scripts/scheduler/ip_scheduler.py>`_).

Here the scheduler is implemented
as a random node selector based on IP and hostname. This scheduler code must be placed in
placed **/opt/stack/nova/nova/scheduler** 

Also `host_name` prefixes may have to be changed as per the names of
your host nodes(aka compute node or worker nodes). My host node is named ‘sridhar’ so I changed the
hostname_prefix value to ‘sridhar’

** WHAT IS A HOSTNODE??? IS THIS THE HOSTNAME??? **

Changes to the configuration file: 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Modify the scheduler information in **/etc/nova/nova.conf** file. Lookup for the old scheduler information (it is the variable called scheduler_driver) and change it to::
    
    scheduler_driver=nova.scheduler.ip_scheduler.IPScheduler

Testing the scheduler
-------------------------

In dev stack the output is shown on different screens. Out of the
various screens. There are various screens for different purposes like showing the status of scheduler, disk drives, etc. We are interested in the **n-sch screen (screen 10)** which is the screen which shows how the scheduling has been done. 
If you have your devstack running then the following command brings up all of the screens. This would not work if you already have screens open somewhere.::

	screen -r stack

Now you need to go to screen 10. You could go to screen 9 **( Ctrl + A + 9)**
and then do a next **(Ctrl + A + N)**. All the output related to the
booting of vms would be in on this screen.

Also after every change to either the filter/scheduler class or config
file, you need to exit(Ctrl + C) on this screen and re-run the last
command. This will update to the latest version of the scheduler/
conf. **Do not forget to do this**.

To test the scheduler you will have to boot a new instance. But before
that you need to provide the user information. The easy way to
do this is to go to where you have the devstack source directory(This is the directory you have cloned devstack into). Once you have done that for admin mode do::
 
	$ source openrc ‘admin’

There is also a non-admin mode called **demo** configured in the openrc. if you do not want the admin mode, you can use the demo mode.::

    $ source openrc demo

You can boot an instance. For booting the instance do the following::

	$ nova boot <instance_name> --image=<image_id> --flavor=<flavor_id>

The available images and flavors can be looked up as follows.::

	$ nova image-list
	$ nova flavor-list

While selecting a flavor keep in mind the memory you have on machine. If the host machines does not have enough memory, it will cause
problems. To simplify testing you can use flavor = 1. The boot is asynchronous and you will have to check the status of the boot. to check the boot status you can do::

	$ nova list

Also if you look into the n-sch screen you will have log information about the booting of the new instance.

Using the filtered scheduler and building a new custom filter: 
------------------------------------------------------------------------------

To build a custom filter you need to make sure to do the following:

#. Create a class which inherits nova.scheduler.filters.BaseHostFilter
#. Implement the `host_passes method`: This method for a given set of inputs
   returns a boolean value corresponding to whether the host passes
   the criteria posed by the filter. All the hosts that pass the
   criteria return true.

The code provided in **scripts/scheduler/temp.py under the reservation project** (`github link <https://github.com/cloudmesh/reservation/blob/master/scripts/scheduler/temp.py>`_) 

This is an example which uses some pseudo data to check whether or not the host passes the criteria. You may have to change the `host_names` to correspond to the
values you have in your hosts list(list of worker/compute nodes registered) Place the code in **/opt/stack/nova/nova/scheduler/filters/temp.py** .  

This filter looks up the temperature for the specific host from a made-up dictionary and also the threshold value and passes the host if the temperature is less than the threshold.

**GEREGOR GOT TILL HERE**


Modifying the Config file 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Modify the filter information in **/etc/nova/nova.conf** file.::

    scheduler_driver = nova.scheduler.filter_scheduler.FilterScheduler
    scheduler_available_filters = nova.scheduler.filters.temp.BasicTempFilter
    scheduler_default_filters = BasicTempFilter

Here the first line tells that we would like to use the FilteredScheduler which is the standard scheduler used by nova to handle filtered scheduling taskes. The second line tells us where to look for available filters. There can be multiple lines for multiple filters.However we can add any of the filters we need using the scheduler_available_filters. The
default_filters tells what default_filters you would like to use by default. This can be a comma separated string if you want to specify multiple filters. However it is necessary that the default filters are included in the available filters.

Testing
^^^^^^^

Testing can be done in a way similar to the one explained in the
section where the scheduler is created from scratch.


Code
--------------------------------------------------------------------

The source files used in this example are

#. A new scheduler: **scripts/scheduler/ip_scheduler.py under the reservation project** (`github link <https://github.com/cloudmesh/reservation/blob/master/scripts/scheduler/ip_scheduler.py>`_)

#. A filter for the filtered scheduler: **scripts/scheduler/temp.py under the reservation project** (`github link <https://github.com/cloudmesh/reservation/blob/master/scripts/scheduler/temp.py>`_)

Summary
---------------------------------------------------------------------

This tutorial assumes that the user has a devstack deployment.

Deployment: Building a new scheduler 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

** WHERE IS THE CODE ON GITHUB??**
 
#. Copy **scripts/scheduler/ip_scheduler.py under the reservation project** (`github link <https://github.com/cloudmesh/reservation/blob/master/scripts/scheduler/ip_scheduler.py>`_) to the /opt/stack/nova/nova/scheduler

#. Make changes to the hostname in the file. Find the word ‘sridhar’
   and replace it with the name of your devstack compute/worker node.

#. Make the following modifications to the configuration( **/etc/nova/nova.conf** )::

     scheduler_driver=nova.scheduler.ip_scheduler.IPScheduler


Deployment - Using existing filtered scheduler with new filters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Copy **scripts/scheduler/temp.py under the reservation project** (`github link <https://github.com/cloudmesh/reservation/blob/master/scripts/scheduler/temp.py>`_)
file and place to the **/opt/stack/nova/nova/scheduler/filters/**

#. Change the host_name in the downloaded file to whatever your
   host_name is. This should be name of the compute node/worker node. Search for the occurrence of the word ‘sridhar’. You can
   also add other hosts you have to the dictionary.

#. Make the following modifications to the configuration( **/etc/nova/nova.conf** )::
    scheduler_driver = nova.scheduler.filter_scheduler.FilterScheduler
    scheduler_available_filters = nova.scheduler.filters.temp.BasicTempFilter 
    scheduler_default_filters = BasicTempFilter

Testing:
^^^^^^^^^^^^^^^

#. If you dont have the screens running start them::
	
    $ screen -r stack

#. Navigate to the n-sch screen(screen 10). All your output regarding
   booting instances can be seen on this terminal. Do **Ctrl + A + 9** followed by **Ctrl + A + N**

#. If the screen was already running exit the n-sch screen(**Ctrl+C** when you are on the n-sch screen) followed by running the last command(use Up arrow). Do this every time you change the configuration file or code

#. On a new terminal go to the devstack source directory and run::

	$ source openrc demo

#. Copy the image id of favorite image. Image-ids can be obtained by::

	$ nova image-list

#. Boot instance using::

	$ nova boot <instance_name> --image=<image_id> --flavor=1

#. View status(gives status of all instances booted)::

	$ nova list

#. See the n-sch screen if there were any errors.

