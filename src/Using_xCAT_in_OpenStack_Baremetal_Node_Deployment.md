<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Node Discovery and Registration](#node-discovery-and-registration)
- [Image Registration](#image-registration)
- [OpenStack Baremetal Node Deployment](#openstack-baremetal-node-deployment)
- [Appendix: Using DevStack to install OpenStack](#appendix-using-devstack-to-install-openstack)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

Baremetal node deployment in OpenStack is not very mature yet. The released [nova-baremetal implementation](https://wiki.openstack.org/wiki/Baremetal) is not good enough to be used in real business world in terms of performance. And it lacks of node discovery, hardware control, firmware updates, sensor readings and monitoring etc. [Ironic](https://wiki.openstack.org/wiki/Ironic) will replace nova-baremetal in the future for OpenStack, but it will take a while for Ironic to become mature and have all these features implemented. However, in the meanwhile, some customers demand to have baremetal solution for their OpenStack clouds that is fully functioning. To close this gap, an xCAT baremetal driver is introduced. With this solution, the system administrator can use xCAT to discover baremetal nodes, setup service (hardware control) processors, create install images etc. Then he/she can register the baremetal nodes and the images in OpenStack. Once the cloud is setup by the system administrator, the end user can acquire baremetal nodes using the OpenStack commands such as **nove boot**, the same way they do with the nova baremetal driver and Ironic driver. Under the cover, the xCAT driver is used to deploy the baremetal node. It is seamless to the end user.

While Ironic and nova-baremetal supports only rack-mounted servers and a few operating systems, xCAT baremetal driver virtually supports all operating systems and hardware types (including system x and p) that xCAT supports.

## Installation

Assume that you have an xCAT cluster that has a management node (mn) and an OpenStack controller node (ocn).

**1\. Install OpenStack on the controller node**

The OpenStack components can be installed by:

  * xCAT see [Deploying_OpenStack], or
  * DevStack see [Appendix:Using_DevStack_to_install_OpenStack](Using_xCAT_in_OpenStack_Baremetal_Node_Deployment/#appendix-using-devstack-to-install-openstack).

This document assumes that the controller node will have all the OpenStack components (all-in-one). You can put the OpenStack compute host in a different node if you want.

Please make sure that the OpenStack environment variable are setup in the shell so that you do not need to specify them on the command line. This is also needed by xCAT baremetal node registration and deployment. The following is an example:

~~~~
      #vi /etc/profile.d/openstack.sh
      export OS_NO_CACHE=true
      export OS_TENANT_NAME=admin
      export OS_USERNAME=admin
      export OS_PASSWORD='password'
      export OS_AUTH_URL="http://192.168.1.201:5000/v2.0/"
      export OS_AUTH_STRATEGY=keystone
      export SERVICE_TOKEN=admin
      export SERVICE_ENDPOINT=http://192.168.1.201:35357/v2.0/
      export KEYSTONE_ADMIN_TOKEN=keystone_admin_token
~~~~



**2\. Set up xCAT client on the controller and compute host**

On the controller node and the compute host: first setup xCAT repository. Please refor to [Install_xCAT_on_the_Management_Node](XCAT_iDataPlex_Cluster_Quick_Start/#install-xcat-on-the-management-node) for how to setup xCAT repository. Then install xCAT-client.

~~~~
     yum install perl-xCAT xCAT-client
~~~~


Copy the xCAT root credentials to the nodes:

~~~~
     mkdir -p ~/.xcat
     scp mn:~/.xcat/* ~/.xcat/
~~~~


Setup environment variable:

~~~~
     echo "export XCATHOST=mn_ip:3001" >> /etc/profile.d/xcat.sh
     echo "setenv XCATHOST mn_ip:3001" >> /etc/profile.d/xcat.csh
~~~~


Exit out and log in to the node again. Test the xCAT client.

~~~~
     nodels
~~~~



**3\. Install and configure xCAT baremetal driver**

For all-in-one case, the compute host is the controller node.

First, install xCAT-OpenStack-baremetal on mn and the compute host.

~~~~
     yum install xCAT-OpenStack-baremetal
~~~~


On the mn restart xcatd:

~~~~
      service xcatd restart
~~~~


On the compute host and the controller node, comment out the following in /etc/nova/nova.conf file:

~~~~
     #firewall_driver = nova.virt.libvirt.firewall.IptablesFirewallDriver
     #compute_driver = libvirt.LibvirtDriver
~~~~


Modify /etc/nova/nova/conf. Make sure the following entries are in the file.

~~~~
     [DEFAULT]
     reserved_host_memory_mb = 0
     ram_allocation_ratio = 1.0
     scheduler_host_manager = nova.scheduler.baremetal_host_manager.BaremetalHostManager
     compute_driver = xcat.openstack.baremetal.driver.xCATBareMetalDriver
     firewall_driver = nova.virt.firewall.NoopFirewallDriver

     [baremetal]
     tftp_root = /tftpboot
     #power_manager = nova.virt.baremetal.ipmi.IPMI
     #driver = nova.virt.baremetal.pxe.PXE
     instance_type_extra_specs = cpu_arch:x86_64
     sql_connection = mysql://<root>:<password>@<controller_ip>/nova_bm?charset=utf8

     [xcat]
     deploy_timeout = 0
     deploy_checking_interval = 10
     reboot_timeout = 0
     reboot_checking_interval = 5
~~~~


On the controller node, create baremetal database nova_bm:

~~~~
      mysql -p<password> -e "CREATE DATABASE nova_bm"
      mysql -p<password> -e "GRANT ALL ON nova_bm.* TO 'stack'@'<compute_host_ip>' IDENTIFIED BY '<password>'"
      mysql -p<password> -e "GRANT ALL ON nova_bm.* TO 'admin'@'<compute_host_ip>' IDENTIFIED BY '<password>'"

~~~~

On the controller, create tables for nova_bm database:

~~~~
      nova-baremetal-manage db sync
~~~~


On both controller and the compute host, add the following in the /usr/bin/nova-compute file. This will add the xCAT baremetal driver path to OpenStack.

~~~~
      sys.path.append("/opt/xcat/lib/python/")   #add this before the line if name_
~~~~



Restart some OpenStack processes:

  * On the controller, kill and restart nova-api and nova-scheduler.
  * On the compute host, kill and restart nova-api and nova-compute.

~~~~
      ps -ef |grep nova
      kill -9 xxxx yyyy zzzz
        where xxxx yyy zzz are process ids for nova-api, nova-compute and nova-scheduler.
      /usr/bin/python /usr/bin/nova-api --config-file /etc/nova/nova.conf&
      /usr/bin/python /usr/bin/nova-scheduler --config-file /etc/nova/nova.conf&
      /usr/bin/python /usr/bin/nova-compute --config-file /etc/nova/nova.conf&
~~~~


Now run nova command to make sure all the nova services are up and running:

~~~~
     nova service-list
     +------------------+-------+----------+----------+-------+----------------------------+-----------------+
     | Binary           | Host  | Zone     | Status   | State | Updated_at                 | Disabled Reason |
     +------------------+-------+----------+----------+-------+----------------------------+-----------------+
     | nova-conductor   | node1 | internal | enabled  | up    | 2013-12-12T17:19:40.000000 | None            |
     | nova-cert        | node1 | internal | enabled  | up    | 2013-12-12T17:19:40.000000 | None            |
     | nova-consoleauth | node1 | internal | enabled  | up    | 2013-12-12T17:19:45.000000 | None            |
     | nova-compute     | node1 | nova     | enabled  | up    | 2013-12-12T17:19:41.000000 | None            |
     | nova-scheduler   | node1 | internal | enabled  | up    | 2013-12-12T17:19:41.000000 | None            |
     +------------------+-------+----------+----------+-------+----------------------------+-----------------+

~~~~

## Node Discovery and Registration

**1\. Use xCAT to discovery the node**

xCAT has several [node discovery](XCAT_iDataPlex_Cluster_Quick_Start/#node-definition-and-discovery) methods. During the node discovery, the nodes mac address, CPU count, memory size and disk sizes will be discovered and saved in the following xCAT tables:

  * mac
  * hwinv

The node's BMC ip address, user name and password are saved in the **ipmi** table. For other types of hardware, please find the relevant topics from [XCAT_Documentation].

Once nodes are discovered, you will assign a static ip address to the node in /etc/hosts on the xCAT management network and run the following commands to setup DNS and dhcp for the nodes

~~~~
     makehosts
     makedhcp
~~~~



**2\. Register the node into OpenStack**

First make sure the node is properly defined in the xCAT cluster.

  * bmc,username and password are defined in ipmi table for the node. (This is for system x rack-mounted servers. For system p and other hardware types, different tables will be filled in xCAT.)
  * mac is defined in the mac table for the node.
  * cpucount,memory and disksize are defined in the hwinv table for the node.

Here is an example:

~~~~
     # lsdef node1
     Object name: node1
       bmc=10.1.0.1
       bmcpassword=PASSW0RD
       bmcusername=USERID
       cpucount=8
       cputype=blah
       disksize=250
       groups=ling,ipmi,all
       installnic=mac
       ip=10.11.0.1
       mac=11:22:33:44:55:66
       memory=2555MB
       mgt=ipmi
       netboot=xnba
       nfsserver=10.1.0.10
~~~~


Then run opsaddbmnode command:

~~~~
      opsaddbmnode <node_name> -s <compute_host_name>
~~~~

or

~~~~

      opsaddbmnode <noderange> -s <compute_host_name>
~~~~


This command runs OpenStack **nova baremetal-node-create** command under the cover to register the node in nova_bm database. You can run the following OpenStack command to make sure that the node is properly registered in OpenStack.

~~~~
      nova baremetal-node-list
      +----+------------+------+-----------+---------+-------------+-------------+-------------+-------------+---------------+
      | ID | Host       | CPUs | Memory_MB | Disk_GB | MAC Address | PM Address  | PM Username | PM Password | Terminal Port |
      +----+------------+------+-----------+---------+-------------+-------------+-------------+-------------+---------------+
      | 1  | computehost | 8    | 2555      | 250     |             | 10.1.0.138  | USERID      |             | -             |
      | 2  | computehost | 4    | 4098      | 300     |             | -           | -           |             | -             |
      +----+------------+------+-----------+---------+-------------+-------------+-------------+-------------+---------------+

~~~~

Note: Node 2 not have bmc info because it is a different hardware type. It is okay. The xCAT baremetal driver can still deploy it as long as it is configured correctly in xCAT tables.

## Image Registration

xCAT supports stateless, stateful and statelite images. The admin can help the user create images using the xCAT. Please see [Deploying Nodes](XCAT_iDataPlex_Cluster_Quick_Start/#deploying-nodes) for details. The following command can list all the image names in xCAT cluster.

~~~~
      lsdef -t osimage
~~~~


The following command list a specific image in details.

~~~~
      lsdef -t osimage -o <image_name>
~~~~


You can use the following command to add selected xCAT image names into OpenStack.

~~~~
      opsaddimage <image_name> -c <controller_node_name>
~~~~

or

~~~~
      opsaddimage <image_name1,image_name2...> -c <controller_node_name>
~~~~


This command runs **glance image-create** under the cover to register the image in OpenStack. You can use the following OpenStack to make sure that the image is properly registered in OpenStack.

~~~~
      glance image-list
~~~~


## OpenStack Baremetal Node Deployment

Now the cloud is setup for the user. The user can acquire the baremetal nodes through OpenStack commands. First create a flavor for the nodes to be requested.

~~~~
      nova flavor-create myflavor 200 1024 100 2
         where 200 is the flavor id,
               1024 is the size of the memory,
               100 is the side of the disk and
               2 is the number of cpus.
~~~~


Then request a node.

~~~~
      nova boot --flavor 200 --image image_name mynode --nic net-id=<id>
~~~~


where &lt;id&gt; is id of the 'fixed' network. For example, it is the 10.1.0.0 network in the appendix below. The network id can be obtained using the following command.

~~~~
      neutron net-list
~~~~


You can also login as a tenant, create your own network, then boot the node using the tenant defined network. Please refer to [Testing OpenStack Cloud](Deploying_OpenStack/#testing-openstack-cloud) for how to create network for a tenant. Remember to substitute the command 'quantum' with 'neutron' because OpenStack has renamed the network component.

## Appendix: Using DevStack to install OpenStack

[DevStack](http://devstack.org/) is used to setup OpenStack cloud for development environment. This environment can also be used in the real production mode. This section demonstrate how to setup an "all-in-one" OpenStack cloud using DevStack. The "all-in-one" configuration allows you to install all of the Openstack components on one node.

**1\. Choose a node in an xCAT cluster, install RHELS 6.* on it**

**2\. Install git**

~~~~
      yum install git
~~~~


**3\. Create a user name that has sudo right**

~~~~
       groupadd stack
       useradd -g stack -s /bin/bash -d /opt/stack -m stack
       echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
~~~~



**4\. Install DevStack**

~~~~
      su - stack
      cd /opt/stack
      git clone https://github.com/openstack-dev/devstack.git
~~~~


**5\. Configure DevStack**

~~~~
      cd /opt/stack/devstack
      vi /opt/stack/devstack/localrc
~~~~


Add the following in /opt/stack/devstack/localrc file, the ip ranges are just examples. The 192.168.1.0 network is the public network. The 10.1.0.0 network is the private network. Please modify it to fit your network configuration.

~~~~
      HOST_IP=192.168.1.201
      FLAT_INTERFACE=eth0
      FIXED_RANGE=10.1.0.0/24
      FIXED_NETWORK_SIZE=254
      FLOATING_RANGE=192.168.1.0/24
      LOGFILE=/opt/stack/logs/stack.sh.log
      ADMIN_PASSWORD=password
      MYSQL_PASSWORD=password
      RABBIT_PASSWORD=password
      SERVICE_PASSWORD=password
      SERVICE_TOKEN=cluster
      PUBLIC_NETWORK_GATEWAY=192.168.1.201

      Q_FLOATING_ALLOCATION_POOL=start=192.168.1.1,end=192.168.1.200

      disable_service n-net
      enable_service q-svc
      enable_service q-agt
      enable_service q-dhcp
      enable_service q-l3
      enable_service q-meta
      enable_service neutron
~~~~


**6\. Install OpenStack components**

Switch to a stable release of OpenStack and run DevStack to install it.

~~~~
      cd /opt/stack/devstack
      git checkout stable/havana
      ./stack.sh
      exit  (exit out stack user)
~~~~


Now as root,

~~~~
      vi /etc/profile.d/openstack.sh
~~~~


Add the following to the file to setup the environmental variables for OpenStack.

~~~~
      export OS_NO_CACHE=true
      export OS_TENANT_NAME=admin
      export OS_USERNAME=admin
      export OS_PASSWORD='password'
      export OS_AUTH_URL="http://192.168.1.201:5000/v2.0/"
      export OS_AUTH_STRATEGY=keystone
      export SERVICE_TOKEN=admin
      export SERVICE_ENDPOINT=http://192.168.1.201:35357/v2.0/
      export KEYSTONE_ADMIN_TOKEN=keystone_admin_token
~~~~


Source the file to export environmental variables.

~~~~
      source /etc/profile.d/openstack.sh
~~~~


Now the cloud is setup and you can run OpenStack commands.

~~~~
      nova service-list
      neutron net-list
      glance image-list
~~~~


