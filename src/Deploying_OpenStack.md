<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Deploying OpenStack with Chef](#deploying-openstack-with-chef)
  - [Overview](#overview)
  - [Terminology](#terminology)
  - [Example of Networking Planning](#example-of-networking-planning)
  - [Procedure of Deploy OpenStack Cloud from Bare Metal](#procedure-of-deploy-openstack-cloud-from-bare-metal)
  - [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
  - [Install xCAT-OpenStack on the Management Node](#install-xcat-openstack-on-the-management-node)
    - [Prepare to Install xCAT Directly from the Internet-hosted Repository](#prepare-to-install-xcat-directly-from-the-internet-hosted-repository)
    - [Make Required Packages From the Distro Available](#make-required-packages-from-the-distro-available)
    - [Install xCAT-OpenStack Packages](#install-xcat-openstack-packages)
    - [Quick Test of xCAT-OpenStack Installation](#quick-test-of-xcat-openstack-installation)
  - [Configure xCAT](#configure-xcat)
    - [Networks Table](#networks-table)
    - [passwd Table](#passwd-table)
    - [Setup DNS](#setup-dns)
    - [Setup DHCP](#setup-dhcp)
    - [Setup TFTP](#setup-tftp)
    - [Setup conserver](#setup-conserver)
  - [Node Definition and Discovery](#node-definition-and-discovery)
  - [Configure chef-server nodes and cloud nodes](#configure-chef-server-nodes-and-cloud-nodes)
    - [set the IPs of the network interfaces for the nodes](#set-the-ips-of-the-network-interfaces-for-the-nodes)
    - [assign the chef-server and roles for the chef-client nodes](#assign-the-chef-server-and-roles-for-the-chef-client-nodes)
    - [define the cloud and generate the cloud data](#define-the-cloud-and-generate-the-cloud-data)
    - [add the /etc/hosts and /etc/resolv.conf to the syclist](#add-the-etchosts-and-etcresolvconf-to-the-syclist)
  - [install the chef-server node](#install-the-chef-server-node)
  - [prepare the repository for chef-client nodes](#prepare-the-repository-for-chef-client-nodes)
  - [Deploy OpenStack](#deploy-openstack)
    - [solution 1: set up the OpenStack during OpenStack nodes provision](#solution-1-set-up-the-openstack-during-openstack-nodes-provision)
    - [solution 2: set up the OpenStack after OpenStack nodes provision](#solution-2-set-up-the-openstack-after-openstack-nodes-provision)
  - [Now test OpenStack Cloud](#now-test-openstack-cloud)
- [Deploying OpenStack with Puppet](#deploying-openstack-with-puppet)
  - [On Redhat](#on-redhat)
  - [On Ubuntu](#on-ubuntu)
  - [Configure the Puppet Server for OpenStack Grizzly](#configure-the-puppet-server-for-openstack-grizzly)
  - [Configure the Puppet Server for OpenStack Folsom](#configure-the-puppet-server-for-openstack-folsom)
- [Testing OpenStack Cloud](#testing-openstack-cloud)
- [Accessing Internet through Proxy Server](#accessing-internet-through-proxy-server)
  - [On Ubuntu/Debian](#on-ubuntudebian)
  - [On Redhat/Fedora/CentOS](#on-redhatfedoracentos)
- [Appendix](#appendix)
  - [Demo of Deploying OpenStack with Chef](#demo-of-deploying-openstack-with-chef)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


Note: This page is under construction.



## Introduction

OpenStack (http://www.openstack.org/) is an Infrastructure as a Service (IaaS) cloud computing project that is free open source software released under the terms of the Apache License. The project is managed by the OpenStack Foundation, a non-profit corporate entity established in September 2012 to promote, protect and empower OpenStack software and its community.

There are many ways to deploy OpenStack software. Two commonly used methods are using Chef or Puppet. Chef and Puppet are open source infrastructure and configuration management systems that automate software deployment to client nodes.

This document discusses how to install OpenStack software using Chef in an xCAT cluster.

Note: Preliminary support for using Puppet to install the Folsum version of OpenStack was added to xCAT 2.8.1, but has not been updated for Grizzly or follow-on. In order to focus limited development and test resources, xCAT will only provide support for using Chef in future releases.

We make the following assumptions:

  * All the bare metal nodes have disks and are installed by xCAT.
  * All the bare metal nodes have at least two network connections: (1) an external network that has internet connection and (2) an internal network. If the nodes do not have an internet connection, please setup the xCAT management node as a proxy server. Please refer to the section [Deploying_OpenStack/#accessing-internet-through-proxy-server](Deploying_OpenStack/#accessing-internet-through-proxy-server) for details.
  * The OpenStack controller will not be the same as the xCAT management node. This is required to avoid conflicts between OpenStack DHCP (dnsmasq) and xCAT DHCP services.

## Deploying OpenStack with Chef

### Overview

In xCAT 2.8.3, xCAT supports using OpenStack-Chef-Cookbook to set up clouds. We integrate the OpenStack-Chef-Cookbooks in xCAT-OpenStack Meta-Meta packages. The main part of OpenStack-Chef-Cookbooks are from https://github.com/stackforge/ . We can get one overview from the doc

~~~~
     http://www.joinfu.com/2013/05/working-with-the-openstack-code-review-and-ci-system-chef-edition/
     https://wiki.openstack.org/wiki/Chef/GettingStarted
~~~~


NOTICE: You should notice the OpenStack-Chef-Cookbooks in xCAT are not always the latest. We test it, and it should work well. You also can use the latest community OpenStack-Chef-Cookbooks, and if you find any problems, you can contact us.

With xCAT 2.8.3, you can deploy OpenStack using Chef for the following operating systems on x86_64 architecture only.

       OpenStack Grizzly release

           On RedHat 6.3
           On Ubuntu 12.04.2


It support 2 use cases:

  1. Using xCAT to deploy multiple chef-server nodes, and deploy each clouds through each chef-server node.
  2. For each chef-server node, it supports deploying different clouds based on different cloud templates files through one version OpenStack-Chef-Cookbooks repository.

### Terminology

The following terms will be used in this document:

xCAT Management node: xCAT Management node is used to manage one or more clouds cluster. And it's used to do hardware control, install OS on other nodes, software maintenance, cloud deployment and so on.

chef-server node: A node which install the chef-server. It can be in the same node with xCAT management node, or not. xCAT management node will provide OpenStack chef cookbooks to the chef-server, and deploy OpenStack through chef-server.

chef-client node: is the nodes which we will deploy OpenStack on. The chef-client nodes will communicate with the chef-server node.

controller node: An OpenStack node to manage one OpenStack cloud. It provides Databases (with MySQL), Messages Queue (Rabbitmq for.Ubuntu, and Qpid for Redhat), Keystone, Glance, Nova (without nova-compute), Cinder, Quantum Server, Dashboard (with Horizon) and so on.

network node: the OpenStack Networking service on a separate node which will act as the network node. It also can be within the cloud controller. In this doc, we will consider it as a separate node.

compute node. One or more compute nodes provide capacity for tenant instances (nova VMs) to run. Compute nodes run nova-compute, and OpenStack Networking plugin agents. OpenStack Networking agents on each compute node communicate with the network node to provide network services to virtual machine instances.

Data Bag: (xCAT 2.8.4 and above feature)A data bag is a global variable that is stored as JSON data and is accessible from the chef-server node. The contents of a data bag can vary, but they often include sensitive information (such as database passwords). The xCAT scripts use [[knife](http://docs.opscode.com/knife_data_bag.html)] command to create the databag. Before we run the command, it's required that the data bag folders and data bag item JSON files exist. The data bag folders are in /install/chef-cookbooks/&lt;openstack-release-name&gt;-xcat/databags/. And there are 4 different data bag types: db_passwords, service_passwords, user_passwords, and secrets. You can modify the databag items in each data bag directory.

Secret Keys: (xCAT 2.8.4 and above feature) Encrypting a data bag requires a secret key. A secret key can be created in any number of ways. xCAT script use OpenSSL to generate a random number, which can then be used as the secret key.

### Example of Networking Planning

OpenStack networking is a little complicated. There are several use cases in the OpenStack-Network(quantum) document. You can get more info from the following link:

~~~~
     http://docs.openstack.org/grizzly/openstack-network/admin/content/use_cases.html
~~~~


And you also can get more info about how to configure the network manually for some of the use cases.

    http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo.html


In this part, I would like to introduce the network Planning for our solution. We can take the [Per-tenant Routers with Private Networks](http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo_routers_with_private_networks.html) as an example. The whole hardware network topology looks like:

[[img src=XCAT-Chef-OpenStack-image1.png]]


From the above example figure, the xCAT management node is known as 'mgt', the chef-server node names are chefserver01-chefserver10, the chef-client node names are cloudAnode001-couldAnode240 in the CloudA, and the domain will be 'clusters.com'. All the nodes are not in the figure.

There are 3 networks:

  1. Management network: is shared by the xCAT management, chef management and OpenStack management. In the above figure, we can see that the eth1 interface of each node will be in the management network. In this example, we use subnet 10.1.0.0 with a netmask of 255.255.0.0(/16) for it.
  2. Data Network: is used by the nova vm instances. From the above figure, we can see that the eth2 interface of each cloud node will be in the Data Network. In this example, we use subnet 172.16.0.0 with a netmask of 255.255.0.0(/16) for it.
  3. External Network: is used by all the nodes to access the public internet. From the above figure, we can see that the eth0 of each node will be used to access the external network. In this example, we use subnet 9.114.0.0 with a netmask of 255.255.0.0(/16) for it.

For the IP addresses of the nodes:

  * The management node: eth0 - 9.114.113.1, eth1 - 10.1.113.1
  * The chef-server nodes: eth0 - 9.114.34.+nodenum , eth1 - 10.1.34.+nodenum
  * The chef-client nodes: eth0 - 9.114.54.+nodenum , eth1 - 10.1.54.+nodenum , eth2 172.16.54.+nodenum

### Procedure of Deploy OpenStack Cloud from Bare Metal

  1. Prepare the management node - doing these things before installing the xCAT software helps the process to go more smoothly.
  2. Install the xCAT-OpenStack software on the management node.
  3. Configure some cluster information
  4. Node Definition and Discovery
  5. Installing Chef-server nodes
  6. Prepare the repository for chef-client nodes
  7. Deploy OpenStack Solution 1 - set up the OpenStack during OpenStack nodes provision
  8. Deploy OpenStack Solution 2 - set up the OpenStack during OpenStack nodes provision
  9. Testing OpenStack Cloud

### Prepare the Management Node for xCAT Installation

Before installing xCAT on the Management Node, we need to prepare the Management Node for xCAT Installation. Follow this section to prepare the Management Node.

See the following documentation:

[Prepare_the_Management_Node_for_xCAT_Installation]

### Install xCAT-OpenStack on the Management Node

Because the xCAT Management node could access the internet directly. So We can install directly from the internet-hosted repository

#### Prepare to Install xCAT Directly from the Internet-hosted Repository

When using the live internet repository, you need to first make sure that name resolution on your management node is at least set up enough to resolve sourceforge.net. Then make sure the correct repo files are in /etc/yum.repos.d:

To get the current official release:

~~~~
    wget http://sourceforge.net/projects/xcat/files/yum/<xCAT-release>/xcat-core/xCAT-core.repo
~~~~


for example:

~~~~
    cd /etc/yum.repos.d
    wget http://sourceforge.net/projects/xcat/files/yum/2.8/xcat-core/xCAT-core.repo
~~~~


To get the deps package:

~~~~
wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/<OS-release>/<arch>/xCAT-dep.repo
~~~~

for example:

~~~~
    wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64/xCAT-dep.repo
~~~~


#### Make Required Packages From the Distro Available

xCAT uses on several packages that come from the Linux distro. Follow this section to create the repository of the OS on the Management Node.

See the following documentation:

[Setting_Up_the_OS_Repository_on_the_Mgmt_Node]

#### Install xCAT-OpenStack Packages

[RH]: Use yum to install xCAT-OpenStack and all the dependencies:

~~~~
    yum clean metadata
    yum install xCAT-OpenStack
~~~~


#### Quick Test of xCAT-OpenStack Installation

Add xCAT commands to the path by running the following:

~~~~
    source /etc/profile.d/xcat.sh
~~~~


Check to see the database is initialized:

~~~~
    tabdump site
~~~~


The output should similar to the following:

~~~~
    key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "installdir","/install",,
         .
         .
         .
~~~~


Check to see the cloud table exists:

~~~~
     tabdump cloud
~~~~


The ouput should similar to the following:

~~~~
     #node,cloudname,comments,disable
~~~~



If the tabdump command does not work, see [Debugging_xCAT_Problems].

### Configure xCAT

#### Networks Table

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is connected to. Now is the time to add to the networks table any other networks in the cluster, or update existing networks in the table.

For a sample Networks Setup, see the following example: [Setting_Up_a_Linux_xCAT_Mgmt_Node#Appendix_A:_Network_Table_Setup_Example](etting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example)

#### passwd Table

The password should be set in the passwd table that will be assigned to root when the node is installed. You can modify this table using tabedit. To change the default password for root on the nodes, change the system line. To change the password to be used for the BMCs, change the ipmi line.

~~~~
    tabedit passwd
    #key,username,password,cryptmethod,comments,disable
    "system","root","cluster",,,
    "ipmi","USERID","PASSW0RD",,,
~~~~


#### Setup DNS

To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN:

  * Ensure that /etc/sysconfig/named does not have ROOTDIR set
  * Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can't answer to these servers.

~~~~
    chdef -t site forwarders=1.2.3.4,1.2.5.6
~~~~


  * Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above.)

~~~~
    search cluster
    nameserver 10.1.113.1
~~~~


  * Run makedns

~~~~
    makedns -n
~~~~


For more information about name resolution in an xCAT Cluster, see [Cluster_Name_Resolution].

#### Setup DHCP

You usually don't want your DHCP server listening on your public (site) network, so set site.dhcpinterfaces to your MN's cluster facing NICs. For example:

~~~~
    chdef -t site dhcpinterfaces=eth1
~~~~


Then this will get the network stanza part of the DHCP configuration (including the dynamic range) set:

~~~~
    makedhcp -n
~~~~


The IP/MAC mappings for the nodes will be added to DHCP automatically as the nodes are discovered.

#### Setup TFTP

Nothing to do here - the TFTP server is done by xCAT during the Management Node install.

#### Setup conserver

~~~~
    makeconservercf
~~~~


### Node Definition and Discovery

You can refer to the doc [XCAT_iDataPlex_Cluster_Quick_Start/#node-definition-and-discovery](XCAT_iDataPlex_Cluster_Quick_Start/#node-definition-and-discovery) to do you nodes discovery.

Before doing discovery, you should put more attention on the following tips:

  * Declare a dynamic range of addresses for discovery

If you want to run a discovery process, a dynamic range must be defined in the networks table. It's used for the nodes to get an IP address before xCAT knows their MAC addresses.

In this case(the example above), we'll designate 10.1.255.1-10.1.255.254 as a dynamic range:

~~~~
    chdef -t network 10_1_0_0-255_255_0_0 dynamicrange=10.1.255.1-10.1.255.254
~~~~


  * Define the node:

~~~~
    mkdef chefserver[01-10]  groups=ipmi,idataplex,compute,chefserver,all
    mkdef cloudA[001-100]    groups=ipmi,idataplex,compute,cloudA,all
~~~~


  * Setup /etc/hosts and DNS

~~~~
    127.0.0.1               localhost.localdomain localhost
    ::1                     localhost6.localdomain6 localhost6
    ###
    10.1.113.1   mgt mgt.cluster
    10.1.34.1   chefserver01 chefserver01.clusters.com
    10.1.34.2   chefserver02 chefserver02.clusters.com
    10.1.34.3   chefserver03 chefserver03.clusters.com
    ...
    ...
    10.1.54.1   cloudA001 cloudA001.clusters.com
    10.1.54.2   cloudA002 cloudA002.clusters.com
    10.1.54.3   cloudA003 cloudA003.clusters.com
    ...
    ...

~~~~

Add the node ip mapping to the DNS.

~~~~
    makedns
~~~~


### Configure chef-server nodes and cloud nodes

#### set the IPs of the network interfaces for the nodes

According to the OpenStack network topology, we need to configure all the chef-server/chef-client nodes Ethernet interfaces at first.

1\. set the nics table

  * For one node:

~~~~
     chdef <one_node>  nicips.eth0=9.114.54.1  nicips.eth1=10.1.54.1  nicips.eth2=172.16.54.1
~~~~


  * For very large openstack cluster, there may be many nodes including many controller nodes, network nodes, and compute nodes. xCAT could use regular expression to set the IPs. We can put many nodes in one group, such as &lt;cloudA_nodes_group&gt;, the nodes definition may looks like:

~~~~
     chdef cloudA[001-240] groups=<cloudA_nodes_group>,all
~~~~


And we can use regular expression to set the IPs for the cloudA nodes. such as&nbsp;:

~~~~
     chdef <cloudA_nodes_group>  nicips.eth0='|cloudA(\d+)|9.114.54.($1+0)|' nicips.eth1='|cloudA(\d+)|10.1.54.($1+0)|'  nicips.eth2='|cloudA(\d+)|172.16.54.($1+0)|'

~~~~

About the regular expression in xCAT, you can get more info from http://xcat.sourceforge.net/man5/xcatdb.5.html

  * If there are mulitple chefserver nodes, we also can use the regular express, such as:

~~~~
     chdef chefserver nicips.eth0='|cloudA(\d+)|9.114.34.($1+0)|' nicips.eth1='|cloudA(\d+)|10.1.34.($1+0)|'  nicips.eth2='|cloudA(\d+)|172.16.34.($1+0)|'

~~~~

2\. Set the postscripts for nodes

~~~~
     chdef <one_node> -p postscripts="confignics -s "
~~~~

      or

~~~~
     chdef <cloudA_nodes_group> -p postscripts="confignics -s"
~~~~


3\. Set the postscripts configgw to configure the public router as the default value

~~~~
      chdef <one_node> -p postbootscripts="configgw eth0 "
~~~~

      or

~~~~
     chdef <cloudA_nodes_group> -p postbootscripts="configgw eth0"
~~~~


  * Note: in the example, the eth0 should be the public interface.

#### assign the chef-server and roles for the chef-client nodes

For one node,

~~~~
      chdef cloudA001 cfgmgr=chef cfgserver=chefserver01  cfgmgtroles=<roles_value>
~~~~


For a noderange, we can use

~~~~
      chdef cloudA002-cloudA240 cfgmgr=chef cfgserver=chefserver01 cfgmgtroles=<roles_value>
~~~~


Note: 1.if the cfgmgr.cfgserver is empty, the cfgserver will be &lt;xcatmaster&gt; by default.

2\. The &lt;roles_value&gt; could be allinone-compute, os-single-controller, os-l2-l3-networker, os-computer. These 4 roles are typical.

The role allinone-compute will be used to deploy all of the services for Openstack in a single node.

The role os-single-controller, os-l2-l3-networker, and os-computer should be used in one cloud. The os-single-controller will be for a controller node, and the controller node should be deployed at first. And the os-l2-l3-networker will be for one network node, and the network node should be deployed once the controller node has been set up successful. And the os-computer can be assigned to one(or multiple) compute node(s), and the compute node should be deployed after the network node has been set up successful.

The users can check the roles in the chef cookbook repository, for example(/install/chef-cookbooks/grizzy-xcat/roles). And the &lt;roles_value&gt; can be set to a list of the chef roles. Once the chef-server has been set up, you can get more roles using chef's knife command.

#### define the cloud and generate the cloud data

1 define the cloud

For example:

~~~~
      mkdef -t  cloud -o <cloud_name>  controller=cloudA001 hostip=10.1.54.1 pubinterface=eth0 mgtinterface=eth1 datainterface=eth2 template="/opt/xcat/share/xcat/templates/cloud_environment/grizzly_per-tenant_routers_with_private_networks.rb.tmpl"  repository="/install/chef-cookbooks/grizzly-xcat/"  virttype=kvm

~~~~

Note:

  * The template files are in /opt/xcat/share/xcat/templates/cloud_environment. When defining cloud, you should specify one template file to meet your requirement. And you also can write your own template file if needed.
  * (xCAT 2.8.4 and above feature) The template grizzly_keystone_swift_allinone.rb.tmpl is used to configure swift with keystone(all in one). If you use this template to define cloud, you should change the values of "proxy-cidr" and "object-cidr" according to your network environment.
  * (xCAT 2.8.4 and above feature) Some template files are develop_mode=false, and others are develop_mode=true. You should use what you needed. When develop_mode=false, you can change the password through databag(/install/chef-cookbooks/&lt;openstack-release-name>-xcat/databags/)
  * the attribute virttype: if you set up the openstack compute node on virtual machine, the virttype should be set to "qemu"; If you set up the openstack compute node on physical node, the virttype should be set to "kvm"

2\. set the cloud attribute for the openstack nodes

~~~~
    chdef <one_node> cloud=<cloud_name>
~~~~

     or

~~~~
    chdef <cloudA_nodes_group> cloud=<cloud_name>
~~~~



3\. generate the cloud data

generate the environment files on xCAT MN

~~~~
     makeclouddata  <cloudnameA, cloudnameB>
~~~~

     or

~~~~
     makeclouddata
~~~~


#### add the /etc/hosts and /etc/resolv.conf to the syclist

~~~~
     mkdir -p  /install/custom/install/<osname>/
     vim /install/custom/install/ubuntu/compute.synclist
      /etc/hosts -> /etc/hosts
      /etc/resolv.conf -> /etc/resolv.conf
     chdef <image_name>  synclists=/install/custom/install/<osname>/compute.synclist
~~~~


### install the chef-server node

xCAT is automatically adding and authenticating the chef clients to the chef server. So it's required that we should install the chef-server at first, and then chef-client.

About the diskfull installation, you can get more information from [xCAT_iDataPlex_Cluster_Quick_Start/#installing-stateful-nodes](XCAT_iDataPlex_Cluster_Quick_Start/#installing-stateful-nodes).

Before doing the diskfull installation, you should put more attentions on the following tips:

  * Configure the chef-server installation for chef-server node

For rhels, we will use the chef kit, and add the chef_server_kit,chef_workstation_kit components to the image of the node that will be the chef server:

1.download the lastest kit from http://sourceforge.net/projects/xcat/files/kits/chef/x86_64/, for example

~~~~
      cd /tmp
      wget http://sourceforge.net/projects/xcat/files/kits/chef/x86_64/chef-11.4.0-1-rhels-6-x86_64.tar.bz2/download
      addkit /tmp/chef-11.4.0-1-rhels-6-x86_64.tar.bz2

~~~~

Now you can list the full names of the kit components from this kit:

~~~~
       #lsdef -t kitcomponent | grep chef
       chef_client_kit-11.4.0-1-rhels-6-x86_64  (kitcomponent)
       chef_server_kit-11.0.6-1-rhels-6-x86_64  (kitcomponent)
       chef_workstation_kit-11.4.0-1-rhels-6-x86_64  (kitcomponent)
~~~~


2\. add the chef_server_kit,chef_workstation_kit components to the image of the node that will be the chef server.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name> chef_server_kit,chef_workstation_kit
~~~~


If there is no os image assigned to the node, please refer to the [Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node) section.


for ubuntu, we will add the add _install_chef_server,install_chef_workstation to the postscripts for the node.

~~~~
    chdef <chefserver>  -p postbootscripts=install_chef_server,install_chef_workstation
~~~~


If the chef-server and the xCAT.MN are not the same node. when we install the OS on the chef-server node, the chef-server will also be installed on the node. If the chef-server and the xCAT MN are the same node, we can use "updatenode ..." command to install the chef-server on the xCAT MN. We can get more details from [Adding_Chef_in_xCAT_Cluster].

  * assign the postbootscripts mountinstall and loadclouddata

The script mountinstall will run on the chef-server, and mount the /install directory from the xCAT management node. The OpenStack Chef cookbooks repository is in the /install directory. The loadclouddata will load the cloud info on the chef-server. Run the following command:

~~~~
     chdef <chefserver> -p postbootscripts=mountinstall,loadclouddata
~~~~


(xCAT 2.8.4 and above feature)If you use the environment template file develop_mode=false in the clouds definition, you should run the following command:

~~~~
     chdef <chefserver> -p postbootscripts=mountinstall,"loadclouddata --nodevmode"
~~~~


When finishing this step, on the chef-server node, we will have completed that

    1. install the OS
    2. install the chef-server
    3. upload the openstack-cookbooks to the chef-server
    4. upload the roles to the chef-server
    5. create the chef-client nodes on the chef-server
    6. assign the role to the chef-client nodes
    7. assign the environment name to the chef-client nodes



Once the cookbooks/roles are uploaded on the chef-server, the users can run the following command to see which roles can be used:

~~~~
     xdsh <chef-server_node> knife role list
~~~~


### prepare the repository for chef-client nodes

The chef-client nodes will be used to deploy OpenStack. Prepare the repository for openstack on all the OpenStack node(also the chef-client nodes):

For redhat, you can get rdo-release-grizzly-3.noarch.rpm

~~~~
     wget -c http://repos.fedorapeople.org/repos/openstack/openstack-grizzly/rdo-release-grizzly-3.noarch.rpm
~~~~


And then put the rdo-release-grizzly-3.noarch.rpm will in the otherpkglist. You can get the details about the otherpkgs function from the link [Install_Additional_Packages]

### Deploy OpenStack

There are 2 solutions to setup the OpenStack:

  * Make the OpenStack setup at the end of the OS provision. install/deploy the &lt;controller&gt; at first, and then install/deploy the &lt;network_node&gt;, and install/deploy the &lt;compute_node&gt; at last.
  * At first, install all the OpenStack nodes(chef-client node) OS. And then use _updatenode_ command to deploy OpenStack.

In this procedure, we will list the two solutions here:

#### solution 1: set up the OpenStack during OpenStack nodes provision

1\. Set the postscripts for OpenStack nodes

~~~~
       chdef cloudAnode001-cloudAnode240 -p postbootscripts=install_chef_client
~~~~


  * Note: For the use case [Per-tenant Routers with Private Networks](http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo_routers_with_private_networks.html), it will create the external network bridge to the Open vSwitch (br-ex) on the network node, so we need to use the configbr-ex postscript to configure the br-ex:

~~~~
     chdef <network_node>  -p postbootscripts="confignics --script configbr-ex"
~~~~


2\. Install the controller node OS

3\. Install the network node OS

4\. Install the compute node OS

#### solution 2: set up the OpenStack after OpenStack nodes provision

1 install the OS and chef-client, and update the OpenStack repository

For rhels, we will use the chef kit, and add the chef_client_kit component to the image of the node that will be the chef server;

for ubuntu, we will add the add install_chef_client to the postscript for the node.

So when we install the OS on the chef-client node, the chef-client will also be installed on the node.

2\. Setup OpenStack

2.1 upload the cookbooks, roles, environment file to the <chef-server-nodes>, and then assign the role to the chef client nodes on the <chef-server-nodes>

~~~~
     updatenode <chef-server-nodes>  -P loadclouddata
~~~~


(xCAT 2.8.4 and above feature)If you use the environment template file develop_mode=false in the clouds definition, you should run the following command:

~~~~
     updatenode <chef-server-nodes>  -P "loadclouddata --nodevmode"
~~~~


2.2 . Deploy the controller node

~~~~
     updatenode  <controller> -P chef-client
~~~~


2.3. Deploy the network node

~~~~
     updatenode  <network_node> -P chef-client
~~~~


  * Note: For the use case [Per-tenant Routers with Private Networks](http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo_routers_with_private_networks.html), it will create the external network bridge to the Open vSwitch (br-ex) on the network node, so we need to use the configbr-ex postscript to configure the br-ex:

~~~~
     updatenode <network_node>  -P "confignics --script configbr-ex"
~~~~


2.4. Deploy the compute node

~~~~
     updatenode  <computer> -P chef-client
~~~~


output message to each node for debug. When -V, it will output all the messages to the terminal.

### Now test OpenStack Cloud

For the Per-tenant Routers with Private Networks, you can refer to the following doc to do the verification:

~~~~
      http://docs.openstack.org/grizzly/openstack-network/admin/content/demo_per_tenant_router_network_config.html
~~~~


We put all the steps for Per-tenant Routers with Private Networks here for reference:

[Script_CloudTest_xCAT_Per-tenant_Routers_with_Private_Networks](Script_CloudTest_xCAT_Per-tenant_Routers_with_Private_Networks)


Note that standing up the Grizzly OpenStack cluster through xCAT 2.8.3 on RH 6.4 is not fully supported and tested at this time. However, a successful scenario was repeatedly executed for the Per-tenant Routers with Private Networks with some manual configuration steps to overcome some issues. Follow this link for notes and steps taken: [Scenario_for_Deploying_Grizzly_on_RH64]

For other verification of the network configurations, you can refer to the related sections in the doc:

~~~~
     http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo.html
~~~~


(xCAT 2.8.4 and above feature)To Test the cinder all in one, you can refer to the steps in the following link.

~~~~
     [Test_Steps_of_xCAT_cinder_allinone]
~~~~


(xCAT 2.8.4 and above feature)To Test the keystone and swift all in one, you can refer to the steps in the following link.

~~~~
     [Test_Steps_of_xCAT_keystone_swift_allinone]
~~~~


## Deploying OpenStack with Puppet

With xCAT 2.8.1, you can deploy OpenStack using Puppet for the following operating systems on x86_64 architecture only.

  * OpenStack Grizzly release



  * On RedHat 6.4
  * On Ubuntu 12.04.2

  * OpenStack Folsom release



  * On RedHat 6.3
  * On Ubuntu 12.04.2

First, please refer to [Adding_Puppet_in_xCAT_Cluster] to install the Puppet server on the xCAT management node and Puppet client on other nodes. Then follow the instructions below to deploy OpenStack. Please note that all the commands below are done on the xCAT management node.

### On Redhat

1\. Configure Puppet server to deploy OpenStack

For OpenStack Grizzly release, please refer to [Configure_the_Puppet_Server_for_OpenStack_Grizzly](Deploying_OpenStack/#configure-the-puppet-server-for-openstack-grizzly)

For OpenStack Folsom release, please refer to [Configure_the_Puppet_Server_for_OpenStack_Folsom](Deploying_OpenStack/#configure-the-puppet-server-for-openstack-folsom)

2\. Set up the OpenStack repository

For OpenStack Grizzly release:

The OpenStack repository is automatically set up by puppet. There are new 'openstack::repo' modules that are included in the configuration.




For OpenStack Folsom release:

~~~~
       mkdir -p /install/post/otherpkgs/rhels6.3/x86_64/ops_deps/
       cd /install/post/otherpkgs/rhels6.3/x86_64/ops_deps/
       wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
       wget ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/6.0/x86_64/updates/security/zlib-1.2.3-29.el6.x86_64.rpm
       createrepo .
       echo "ops_deps/epel-release" >> /install/custom/install/rh/compute.otherpkgs.pkglist
       echo "ops_deps/zlib" /install/custom/install/rh/compute.otherpkgs.pkglist
       updatenode <noderange> -P otherpkgs
~~~~


where compute.otherpkgs.pkglist is the otherpkglist file for the node image.


3\. Deploy OpenStack to the nodes

Make sure the node has yum installed and make sure it has internet access. Please refer to [Deploying_OpenStack/#accessing-internet-through-proxy-server](Deploying_OpenStack/#accessing-internet-through-proxy-server) for help.

Restart the puppet master on the xCAT management node to ensure all configuration changes that you have made are recognized:

~~~~
      service puppetmaster restart
~~~~


Then run the following command to deploy the OpenStack controller node:

~~~~
       xdsh <controller_nodename> -s "puppet agent -t"
~~~~


Ensure that the controller is correctly installed and OpenStack services are running:

~~~~
        xdsh <controller_nodename> nova-manage service list
~~~~


Deploy the OpenStack compute nodes:

~~~~
       xdsh <compute_nodenames> -s "puppet agent -t"
~~~~


Now OpenStack is installed and configured on your nodes. Refer to [Testing_OpenStack_Cloud](Deploying_OpenStack/#testing-openstack-cloud) for testing.

Please refer to Puppet's own doc /etc/puppet/modules/openstack/README.md for detailed instructions on how to configure manifests files for more complected OpenStack clouds.

### On Ubuntu

1\. Configure Puppet Server

For OpenStack Grizzly release, please refer to [Configure_the_Puppet_Server_for_OpenStack_Grizzly](Deploying_OpenStack/#configure-the-puppet-server-for-openstack-grizzly)

For OpenStack Folsom release, please refer to [Configure_the_Puppet_Server_for_OpenStack_Folsom](Deploying_OpenStack/#configure-the-puppet-server-for-openstack-folsom)

2\. Set up the OpenStack repository for the nodes

Run the following commands on the management node.

For OpenStack Grizzly release

~~~~
       chdef -t node -o <noderange> -p postbootscripts=setup_openstack_repo
       updatenode <noderange> -P  setup_openstack_repo
~~~~


For OpenStack Folsom release

~~~~
       chdef -t node -o <noderange> -p postbootscripts="setup_openstack_repo folsom"
       updatenode <noderange> -P  "setup_openstack_repo folsom"
~~~~


setup_openstack_repo has hard coded OpenStack repositories which you can modify to fit your needs. It uses the following repositories:

~~~~
     http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/<openstack_release_name> main
~~~~


3\. Deploy OpenStack to the nodes

Make sure the node has yum installed and make sure it has internet access. Please refer to [Deploying_OpenStack/#accessing-internet-through-proxy-server](Deploying_OpenStack/#accessing-internet-through-proxy-server) for help. Then run the following commands to deploy the OpenStack to the nodes.

~~~~
       xdsh <controller_nodename> -s "puppet agent -t"
       xdsh <compute_nodenames> -s "puppet agent -t"
~~~~


Now OpenStack is installed and configured on your nodes. Refer to [Testing_OpenStack_Cloud](Deploying_OpenStack/#testing-openstack-cloud) for testing.

Please refer to Puppet's own doc /etc/puppet/modules/openstack/README.md for detailed instructions on how to configure manifests files for more complected OpenStack clouds.

### Configure the Puppet Server for OpenStack Grizzly

1\. Load the OpenStack modules

Download the modules from puppetlabs:

~~~~
      puppet module install puppetlabs-openstack
      puppet module list
~~~~


Apply a fix for RedHat:

~~~~
      vi /etc/puppet/modules/openstack/manifests/repo/rdo.pp
   #<<< change 2nd line below:    >>>
         $dist = $::operatingsystem ? {
   #        'CentOS' => 'epel',
   #   <<< to: >>>
           /(CentOS|RedHat|Scientific|SLC)/ => 'epel',
           'Fedora' => 'fedora',
         }
~~~~

2\. Create a site manifest site.pp for OpenStack

Copy [[site.pp for Grizzly release]] file to /etc/puppet/manifests/site.pp.


3\. Input cluster info in the site manifest file site.pp

Now you can modify the file /etc/puppet/manifests/site.pp and input the network info and a few passwords. We usually make all the passwords the same. The following is an example to show the entries that have been modified:

~~~~
 $public_interface        = 'eth0'
 $private_interface       = 'eth1'

 # credentials
 $admin_email             = 'root@localhost'
 $admin_password          = 'mypassw0rd'
 $keystone_db_password    = 'mypassw0rd'
 $keystone_admin_token    = 'service_token'
 $nova_db_password        = 'mypassw0rd'
 $nova_user_password      = 'mypassw0rd'
 $glance_db_password      = 'mypassw0rd'
 $glance_user_password    = 'mypassw0rd'
 $rabbit_password         = 'mypassw0rd'
 $rabbit_user             = 'openstack_rabbit_user'

 # networks
 $fixed_network_range     = '10.0.0.0/24'
 $floating_network_range  = '192.168.101.64/28'

 # servers
 $controller_node_address  = '192.168.101.11'
~~~~

4\. Add the nodes

Create the directory and file to specify your nodes. For example, if 'node1' is your OpenStack controller node and 'node2' and node3' are your compute nodes:

~~~~
  mkdir /etc/puppet/manifests/nodes
  vi /etc/puppet/manifests/nodes/allnodes.pp
      # OpenStack cluster nodes
      node  "node1" inherits openstack_controller {
      }

      node  "node2","node3"  inherits openstack_compute {
      }
~~~~

### Configure the Puppet Server for OpenStack Folsom
1\. Load the OpenStack modules

The puppetlabs-openstack modules have been released for OpenStack Folsom.

~~~~
   puppet module install --version 1.1.0 puppetlabs-openstack
   puppet module list
~~~~

2\. Create a site manifest site.pp for OpenStack
   cat /etc/puppet/modules/openstack/examples/site.pp >> /etc/puppet/manifests/site.pp
Note: There are 2 errors in /etc/puppet/manifests/site.pp file, they are found when deploying OpenStack Folsom on Ubuntu 12.04.2. You may need to make the following changes for your cluster:
In 'openstack::controller' class, comment out export_resources entry and add a entry for secret_key. So the last two entries of the class look like this:

~~~~
    #export_resources    => false,
    secret_key           => 'dummy_secret_key',
~~~~


3\. Input cluster info in the site manifest file site.pp

Now you can modify the file /etc/puppet/manifests/site.pp and input the network info and the a few passwords. We usually make all the passwords the same. The following is an example to show the entries that have been modified:

~~~~
    $public_interface        = 'eth0'
    $private_interface       = 'eth1'
    # credentials
    $admin_email             = 'root@localhost'
    $admin_password          = 'mypassw0rd'
    $keystone_db_password    = 'mypassw0rd'
    $keystone_admin_token    = 'keystone_admin_token'
    $nova_db_password        = 'mypassw0rd'
    $nova_user_password      = 'mypassw0rd'
    $glance_db_password      = 'mypassw0rd'
    $glance_user_password    = 'mypassw0rd'
    $rabbit_password         = 'mypassw0rd'
    $rabbit_user             = 'nova'
    $fixed_network_range     = '10.0.0.0/24'
    $floating_network_range  = '192.168.101.64/28'

    $controller_node_address  = '192.168.101.11'
~~~~

Add the OpenStack controller and compute nodes in the site.pp file.
You can replace "node /openstack_controller/" and "node /openstack_compute/" or "node /openstack_all/" with the node names of your cluster, for example:
Replace


~~~~
    node /openstack_controller/ {
       ...
    }
with
    node "node1" {
         ...
    }
~~~~

Replace


~~~~
    node /openstack_compute/ {
       ...
    }
with
    node "node2","node3" {
       ...
    }

~~~~

## Testing OpenStack Cloud
Once the controller and compute nodes are deployed, you can create a vm using OpenStack commands. Here is how:

1\. On the controller, make sure all the services are up and running.


~~~~
    nova-manage service list
    source /root/openrc
~~~~

2\. Download an image, you can download it to the management node and copy it to the controller node.

~~~~
    cd /tmp
    wget <nowiki>https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img</nowiki>
~~~~


3\. Add the image to the OpenStack database.

For Grizzly:


~~~~
    glance image-create  --name cirros_image --is-public true --container-format bare --disk-format qcow2 --file /openstack_images/cirros-0.3.0-x86_64-disk.img
~~~~

For Folsom:


~~~~
    glance add name='cirros_image' is_public=true container_format=bare disk_format=qcow2 < cirros-0.3.0-x86_64-disk.img
~~~~

4\. Create a public and private key pair, then add it to nova.


~~~~
    ssh-keygen -f /tmp/id_rsa -t rsa -N <nowiki>''</nowiki>
    nova keypair-add --pub_key /tmp/id_rsa.pub key_cirros
~~~~

5\. Create a security group, allow ssh and ping

~~~~
    nova secgroup-create nova_test 'my test group'
    nova secgroup-add-rule nova_test tcp 22 22 0.0.0.0/0
    nova secgroup-add-rule nova_test icmp -1 -1 0.0.0.0/0
~~~~

6\. Boot the image.


~~~~
    glance image-list
    nova boot --flavor 1 --security_groups nova_test --image <imageid> --key_name key_cirros cirros_test_vm
~~~~

where the imageid can be obtain from the following command.

~~~~
    glance index | grep 'cirros_image'
~~~~


7\. Get a floating ip and assign it to the newly created vm.

~~~~
   nova floating-ip-create
   nova add-floating-ip cirros_test_vm <ip>
~~~~

8\. Wait a few minutes for the vm to boot up and then you can logon the vm.

~~~~
   nova show cirros_test_vm
   <nowiki>ssh cirros@<ip> -i /tmp/id_rsa -o StrictHostKeyChecking=no</nowiki>
~~~~




## Accessing Internet through Proxy Server

Squid is one of the most popular and most used proxy servers. It comes with the most of the os distro. It is easy to use.

### On Ubuntu/Debian

1\. Setup the xCAT management node as the proxy server

~~~~
       apt-get install squid3
       vi /etc/squid3/squid.conf
~~~~


Add the following to the squid.conf file

~~~~
     visible_hostname <host_name_of_box>
     http_port 3128
     acl <ACL_name> src <ip_address/netmask>
     http_access allow <ACL_name>
~~~~


For example:

~~~~
     visible_hostname mgt1
     http_port 3128
     acl localnet src 172.20.0.0/16
     http_access allow localnet
~~~~


Restart the squid3

~~~~
     service squid3 restart
~~~~


Note: these are the most basic options necessary for squid to take traffic from a subnet and proxy it out. You might want to put more care into refining that file to make it more secure, but for just pushing traffic, it works just fine.


2\. Setup the node to access internet through the proxy server

You can make the apt aware of the proxy server:

~~~~
    xdsh <noderange> "echo 'Acquire::http::Proxy \"http://mn_ip:3128\";' >> /etc/apt/apt.conf.d/10proxy"
~~~~


where mn_ip is the ip address of the xCAT management node that the node has access to.

For example, the /etc/apt/apt.conf.d/10proxy looks like this:

~~~~
       #cat /etc/apt/apt.conf.d/10proxy
       Acquire::http::Proxy "http://172.20.0.1:3128";
~~~~


If anything else on the node needs to proxy out, (e.g. wget), you need to set a system wide environment variable.

~~~~
       xdsh <noderange> "echo 'http_proxy=\"http://mn_ip:3128/\"' >> /etc/environment"
~~~~


Then the /etc/environment on the node looks like this:

~~~~
       #cat /etc/environment
       PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
       http_proxy="http://172.20.0.1:3128/"
~~~~





### On Redhat/Fedora/CentOS

1\. Setup the xCAT management node as the proxy server

~~~~
       yum install squid
       chkconfig squid on
       service squid restart
~~~~


2\. Setup the node to access internet through the proxy server

You can make the yum aware of the proxy server:

~~~~
       xdsh <noderange> "echo 'proxy=http://mn_ip:3128' >> /etc/yum.conf"
~~~~


where mn_ip is the ip address of the xCAT management node that the node has access to.




## Appendix

### Demo of Deploying OpenStack with Chef

There is a demo of deploying OpenStack with Chef in xCAT cluster, and you can get the demo from the following link:

~~~~
     http://sourceforge.net/projects/xcat/files/OpenStack/xCAT_OpenStack_Demo.tar/download
~~~~


Once you get the file xCAT_OpenStack_Demo.tar from the link, you can un-tar the xCAT_OpenStack_Demo.tar to get the details, such as the OpenStack Demo.ppt ,and the video files. The video has been divided in 4 parts:

  1. introduction
  2. configure the chef-server
  3. configure the cloudA(Per-tenant routers with private networks)
  4. configure the allinone

For each video part, you can open the .html files to watch the video.


