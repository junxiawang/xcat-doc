<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Terminology](#terminology)
- [Example of Networking Planning](#example-of-networking-planning)
- [Main Procedure of using xCAT/OpenStack-chef-Cookbook to Setup clouds](#main-procedure-of-using-xcatopenstack-chef-cookbook-to-setup-clouds)
  - [Prepare the Management Node for xCAT-OpenStack Installation](#prepare-the-management-node-for-xcat-openstack-installation)
  - [Install xCAT-OpenStack on the Management Node](#install-xcat-openstack-on-the-management-node)
  - [node definition](#node-definition)
  - [Configure xCAT](#configure-xcat)
    - [set the IPs of the network interfaces for the nodes](#set-the-ips-of-the-network-interfaces-for-the-nodes)
    - [assign the chef-server for the chef-client nodes](#assign-the-chef-server-for-the-chef-client-nodes)
    - [define the cloud and generate the cloud data](#define-the-cloud-and-generate-the-cloud-data)
  - [Set the node's roles in the cfgmgt table](#set-the-nodes-roles-in-the-cfgmgt-table)
  - [install the chef-server node](#install-the-chef-server-node)
  - [prepare the repository for chef-client nodes](#prepare-the-repository-for-chef-client-nodes)
  - [Deploy OpenStack](#deploy-openstack)
    - [solution 1: set up the OpenStack during OpenStack nodes provision](#solution-1-set-up-the-openstack-during-openstack-nodes-provision)
    - [solution 2: set up the OpenStack after OpenStack nodes provision](#solution-2-set-up-the-openstack-after-openstack-nodes-provision)
  - [Testing OpenStack Cloud](#testing-openstack-cloud)
- [Internal](#internal)
  - [install_chef_client Script Enhancement](#install_chef_client-script-enhancement)
  - [Add New Attributes to clouds Table](#add-new-attributes-to-clouds-table)
  - [About the enviornment files Generation](#about-the-enviornment-files-generation)
  - [Add one new postscript to &nbsp;: /install/postscripts/loadclouddata](#add-one-new-postscript-to-&nbsp-installpostscriptsloadclouddata)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

  



## Introduction

This mini-design discusses how to use xCAT/OpenStack-Chef-Cookbook to set up clouds. OpenStack-Chef-Cookbooks is from https://github.com/stackforge/ . We can get one overview from the doc 
    
     http://www.joinfu.com/2013/05/working-with-the-openstack-code-review-and-ci-system-chef-edition/
     https://wiki.openstack.org/wiki/Chef/GettingStarted
    

We will integrate the xCAT/OpenStack-chef-Cookbook to set up clouds, and make the setup more easier, and more automatically. 

This doc discusses the procedure including xCAT MN installation, chef-server/chef-client installation and clouds deployment. And the "Internal" section will discuss the implementations. We'll have the following assumption: 

  * All the nodes have an external network that has internet connection and a internal network. 
  * The OpenStack controller will not be the same as the xCAT management node. This is due to the conflict of OpenStack DHCP and xCAT DHCP server. 

We'd like to divide it into following two functions: 

  1. Main Procedure of using xCAT/OpenStack-chef-Cookbook to Setup clouds 
  2. Internal Implementation 

## Terminology

The following terms will be used in this document: 

**xCAT Management node**: xCAT Management node is used to manage one or more clouds cluster. And it's used to do hardware control, install OS on other nodes, software maintenance, cloud deployment and so on. 

**chef-server node**: A node which install the chef-server. It can be in the same node with xCAT management node, or not. xCAT management node will provide OpenStack chef cookbooks to the chef-server, and deploy OpenStack through chef-server. 

**chef-client node**: is the nodes which we will deploy OpenStack on. The chef-client nodes will communicate with the chef-server node. 

**controller node**: An OpenStack node to manage one OpenStack cloud. It provides Databases (with MySQL), Messages Queue (Rabbitmq for　Ubuntu, and Qpid for Redhat), Keystone, Glance, Nova (without nova-compute), Cinder, Quantum Server, Dashboard (with Horizon) and so on. 

**network node**: the OpenStack Networking service on a separate node which will act as the network node. It also can be within the cloud controller. In this doc, we will consider it as a separate node. 

**compute node**： One or more compute nodes provide capacity for tenant instances (nova VMs) to run. Compute nodes run nova-compute, and OpenStack Networking plugin agents. OpenStack Networking agents on each compute node communicate with the network node to provide network services to virtual machine instances. 

## Example of Networking Planning

OpenStack networking is a little complicated. There are several use cases in the OpenStack-Network(quantum) document. You can get more info from the following link: 
    
     http://docs.openstack.org/grizzly/openstack-network/admin/content/use_cases.html
    

And you also can get more info about how to configure the network manually for some of the use cases. 
    
    http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo.html
    

In this part, I would like to introduce the network Planning for our solution. We can take the [Per-tenant Routers with Private Networks](http://docs.openstack.org/grizzly/openstack-network/admin/content/app_demo_routers_with_private_networks.html) as an example. The whole hardware network topology looks like: 

[[img src=XCAT-Chef-OpenStack-image1.png]] 

From the above example figure, the xCAT management node is known as 'mgt', the chef-server node names are chefserver01-chefserver10, the chef-client node names are cloudAnode001-couldAnode240, and the domain will be 'clusters.com'. All the nodes are not in the figure. 

There are 3 networks: 

1\. Management network: is shared by the xCAT management, chef management and OpenStack management. 

2\. Data Network: is used by the nova vm instances. 

3\. External Network: is used by all the nodes to access the public internet. 

## Main Procedure of using xCAT/OpenStack-chef-Cookbook to Setup clouds

### Prepare the Management Node for xCAT-OpenStack Installation

OS provision of xCAT management node 

### Install xCAT-OpenStack on the Management Node

install xCAT-OpenStack meta-meta and its prerequisite packages 
    
     yum install xCAT-OpenStack
    

The following will be in the packages: 

1) the schema definition for cloud/clouds tables 

2) scripts to configure OpenStack 

3) the OpenStack Chef cookbooks repository(including cookbooks, example/template of environment files, roles and so on). After installation, it will be in /install/chef-cookbooks/ directory. There may be many different repositories in the /install/chef-cookbooks/ 

### node definition

hardware discovery automatically(sequential discovery, or discovery based on switch ports, or based on SLP) or define the nodes manually ... 

### Configure xCAT

#### set the IPs of the network interfaces for the nodes

According to the OpenStack network topology, we need to configure all the chef-server/chef-client nodes Ethernet interfaces at first. 

1\. set the nics table 

  * For one node: 
    
     chdef &lt;one_node&gt;  nicips.eth0=10.1.89.8  nicips.eth1=11.1.89.8  nicips.eth2=12.1.89.8  
    

  * For very large openstack cluster, there may be many nodes including many controller nodes, network nodes, and compute nodes. xCAT could use regular expression to set the IPs. We can put many nodes in one group, such as &lt;cloudA_nodes_group&gt;, the nodes definition may looks like: 
    
     chdef cloudAnode[001-240] groups=&lt;cloudA_nodes_group&gt;,all
    

And we can use regular expression to set the IPs for the nodes， such as&nbsp;: 
    
     chdef &lt;cloudA_nodes_group&gt;  nicips.eth0='|cloudAnode(\d+)|10.1.89.($1+0)|' nicips.eth1='|cloudAnode(\d+)|11.1.89.($1+0)|'  nicips.eth2='|cloudAnode(\d+)|12.1.89.($1+0)|'  
    

About the regular expression in xCAT, you can get more info from http://xcat.sourceforge.net/man5/xcatdb.5.html 

2\. Set the postscripts for nodes 
    
     chdef &lt;one_node&gt; -p postbootscripts=confignics
      or 
     chdef &lt;cloudA_nodes_group&gt; -p postbootscripts=confignics
    

  * NOTE: I plan to add one section to introduce "OpenStack network topology plan" at the beginning of the procedure. 

#### assign the chef-server for the chef-client nodes

For one node, 
    
      chdef cloudAnode001 cfgmgr=chef cfgserver=chefserver001  
    

For a noderange, we can use 
    
      chdef cloudAnode001-cloudAnode240 cfgmgr=chef cfgserver=chefserver001
    

  * Note: if the cfgmgr.cfgserver is empty, the cfgserver will be &lt;xcatmaster&gt; by default. 

#### define the cloud and generate the cloud data

1 define the cloud 

For example: 
    
      mkdef -t  cloud -o &lt;cloud_name&gt;  controller=oscn2 ......
    

Currently, most of the attributes in clouds table are for nova-network. The attributes publicnet,novanet,mgtnet,vmnet will not be used in Quantum. There is a discussion about it later. 

2 generate the cloud data 

generate the environment files/databag files on xCAT MN (The command will be discussed later) 
    
     makeclouddata  &lt;cloudnameA, cloudnameB&gt;  
     or
     makeclouddata
    

### Set the node's roles in the cfgmgt table

The &lt;roles_value&gt; could be allinone-compute, os-compute-single-controller, os-compute-networker, os-compute-worker. These 4 roles are typical. 
    
     chdef oscn2 roles=&lt;roles_value&gt;
    

If we want to deploy the OpenStack more flexible, we need to get more roles using chef's knife command, and the &lt;roles_value&gt; can be set to a list of the chef roles. The users can check the roles in the chef cookbook repository, for example(/install/chef-cookbooks/grizzy-xcat/roles). 

  


### install the chef-server node

xCAT management node will install OS on the chef-server node, and then install the chef-server on the chef-server node. 

xCAT is automatically adding and authenticating the chef clients to the chef server. So it's required that we should install the chef-server at first, and then chef-client. 

For rhels, we will use the chef kit, and add the chef_server_kit,chef_workstation_kit components to the image of the node that will be the chef server; for ubuntu, we will add the add install_chef_server,install_chef_workstation to the postscripts for the node. 

If the chef-server and the xCAT　MN are not the same node. when we install the OS on the chef-server node, the chef-server will also be installed on the node. If the chef-server and the xCAT MN are the same node, we can use "updatenode ..." command to install the chef-server on the xCAT MN. We can get more details from [Adding_Chef_in_xCAT_Cluster](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Adding_Chef_in_xCAT_Cluster)

  * Note: The OpenStack Chef cookbooks repository will be in the /install on the management node, and this /install will be mounted on the chef-server node. 

When finishing this step, on the chef-server node, we will have completed that 
    
    1. install the OS 
    2. install the chef-server
    3. upload the openstack-cookbooks to the chef-server
    4. upload the roles to the chef-server
    5. create the chef-client nodes on the chef-server
    6. assign the role to the chef-client nodes
    7. assign the environment name to the chef-client nodes
    

Once the cookbooks/roles are uploaded on the chef-server, the users can run the following command to see which roles can be used: 
    
     xdsh &lt;chef-server_node&gt; knife role list
    

### prepare the repository for chef-client nodes

The chef-client nodes will be used to deploy OpenStack. 

Prepare the repository for openstack on all the OpenStack node(also the chef-client nodes) 

For redhat, the rdo-release-grizzly-1.noarch.rpm will be packed into the chef-kit, and it will be a new kit component. It will install the rdo-release-grizzly-1.noarch.rpm on the chef-server. 

For Ubuntu, it need to add the openstack repository on ubuntu into the /etc/apt/sources.list ( using otherpkgsdir&nbsp;?), refresh the repository -- There will be a new postscript to do add the repository and refresh the repository. 

### Deploy OpenStack

There are 2 solutions to setup the OpenStack: 

  * Make the OpenStack setup at the end of the OS provision. install/deploy the &lt;controller&gt; at first, and then install/deploy the &lt;network_node&gt;, and install/deploy the &lt;compute_node&gt; at last. 
  * At first, install all the OpenStack nodes(chef-client node) OS. And then use _updatenode_ command to deploy OpenStack. 

In this procedure, we will list the two solutions here: 

#### solution 1: set up the OpenStack during OpenStack nodes provision

1\. Set the postscripts for OpenStack nodes Add a new function ito the chef-client script: copy the keys from &lt;chef-server_node&gt;:/etc/chef-server/ to &lt;chef-client&gt;
    
       chdef cloudAnode001-cloudAnode240 -p postbootscripts=chef-client
    

2\. Install the controller node OS 

3\. Install the network node OS 

4\. Install the compute node OS 

#### solution 2: set up the OpenStack after OpenStack nodes provision

1 install the OS and chef-client, and update the OpenStack repository 

For rhels, we will use the chef kit, and add the chef_client_kit component to the image of the node that will be the chef server; for ubuntu, we will add the add install_chef_client to the postscript for the node. So when we install the OS on the chef-server node, the chef-server will also be installed on the node. 

2\. Setup OpenStack****

2.1 upload the cookbooks, roles, environment file to the &lt;chef-server-nodes&gt;, and then assign the role to the chef client nodes on the &lt;chef-server-nodes&gt;
    
     updatenode &lt;chef-server-nodes&gt;  loadclouddata
    

2.2 . Deploy the controller node 
    
     updatenode  &lt;controller&gt; -P chef-client
    

2.3. Deploy the network node 
    
     updatenode  &lt;network_node&gt; -P chef-client
    

2.4. Deploy the compute node 
    
     updatenode  &lt;computer&gt; -P chef-client
    

output message to each node for debug. When -V, it will output all the messages to the terminal. 

### Testing OpenStack Cloud

## Internal

### install_chef_client Script Enhancement

1 the config_chef_client script will be changed or invoked by a new postcript /install/postscripts/chef-client 

2 when the chef-server and xCAT MN are one the same node, the script config_chef_client couldn't scp the *.pem from chef-server to chef-client directly. This should be fixed. 

### Add New Attributes to clouds Table

Currently, the clouds table includes the following attributes. 
    
     #name,controller,publicnet,novanet,mgtnet,vmnet,adminpw,dbpwcomments,disable
    

But the attributes publicnet,novanet,mgtnet,vmnet are for OpenStack nova-network, not used in quantum. For some attributes which are usefull for OpenStack, So we need to add them into the cloud table. 

Remove the attribute publicnet,novanet,mgtnet,vmnet,adminpw,dbpwcomments firstly, we may add it again in the clouds table. Currently, I don't want to add them once. 

The following attribute may be added into the clouds table: 

  1. controller -- The controller of the OpenStack cloud 
  2. hostip -- The host IP is in openstack management network on the controller node. It's always the rabbitmq's host IP and nova_metadata_ip. 
  3. pubinterface -- Interface to use for external bridge. The default value is eth1. (external_network_bridge_interface in the environment template. ) 
  4. mgtinterface -- Interface to use for openstack management. It's supposed that the mgtinterface for all the nodes are the same, and in the same network. 
  5. datainterface -- Interface to use for OpenStack nova vm communication. It's supposed that the datainterface for all the nodes are the same, and in the same network. 
  6. virttype -- What hypervisor software layer to use with libvirt (e.g., kvm, qemu). 
  7. template -- Every cloud should be related to one environment template file. The absolute path is required. 
  8. repository -- Every cloud should be related to the openstack-chef-cookbooks. The absolute path is required. In the repository, there are cookbooks/, environments/, roles and on on. 
  9. tenant_network_type -- (It's not using now and default in the template files.) Type of network to allocate for tenant networks.The default value 'local' is useful only for single-box testing and provides no connectivity between hosts. You MUST either change this to 'vlan' and configure network_vlan_ranges below or change this to 'gre' and configure tunnel_id_ranges below in order for tenant networks to provide connectivity between hosts. 
  10. bridge_mappings -- (In the first step, I would not add it into clouds table, but it's important. Do it later.) -- not using. 

The following attributes will be in the environment template files: 
    
    developer_mode, db_bind_interface, mq_bind_interface, identity_bind_interface, image_api_bind_interface, image_registry_bind_interface, 
    dashboard_use_ssl,  nova_metadata_ip, rabbit_host_ip, network_api_bind_interface, external_network_bridge_interface, allow_overlapping_ips,
    use_namespaces, tenant_network_type, tunnel_id_ranges, enable_tunneling, local_ip_interface,network_vlan_ranges, bridge_mappings ,
    identity_service_chef_role, compute_rabbit_host, network_service_type, libvirt_virt_type, libvirt_bind_interface ....
    

For DB, we can use mysql, and postgresql to setup openstack. And we may also support for DB2. I just try the mysql, and there are some attributes I don't list above: such as&nbsp;: 
    
    mysql_allow_remote_root , mysql_root_network_acl
    

For network, there are some 3-rd part plugin, such as bigswitch, cisco, nec, linuxbridge and so on. I don't try them. I just try the openvswitch and L3-agent. 

For message queue, we will have two: rabbitmq for ubuntu, and qpid for redhat. 

For storage, there may be more back-end in future. 

We couldn't put so many attributes into our cloud table. We can put some basic attributes, and some attributes which are needed by one typical configuration into the cloud table. The users can define most of the attribute through the cloud table. And then run our new command **mkchefdata** to generate a environment file, if needed, he/she could edit the environment file directly to add more attribute/value. Is it acceptable&nbsp;? 

So I have one question here: Could we only put the attributes in the cloud table for the use cases in the openstack network document? For example&nbsp;: db(mysql), network plugin(openvswtich and L3-agent), messaging(rabbitmq for ubuntu, or qpid for redhat ), and the typical configuration is **per tenant routers with private networks**, and the tenant network type is **GRE** . 

What are your ideas&nbsp;? 

### About the enviornment files Generation

1 Add some templates for environment file. We can support the "per-tenant Router with Private network" at first. 

The environment template will be located in /opt/xcat/share/xcat/openstack_environments. These files will be packed into the xCAT-OpenStack-xxx.rpm . 

2 Add a new command to generate the environment files according to the clouds table, data_bags file 
    
        /opt/xcat/sbin/makeclouddata
    

This command will run on the xCAT MN. 

### Add one new postscript to &nbsp;: /install/postscripts/loadclouddata
    
     1 upload cookbooks, roles to the chef-server 
     2 upload the environment file, 
     3 upload the databag file ?
     4. assign the roles to the &lt;chef-client-node&gt; on the &lt;chef-server-node&gt;
    

This script will run on &lt;chef-server&gt; . The script could upload the cookbooks/roles/environment files, may be not only for OpenStack. 

And I would like to make this script default for OpenStack. So the default cookbooks,roles and environment directories are in the /install/openstack-chef-repo/, the environment files are &lt;cloudname&gt;.rb . 

The roles will be from cfgmgt.roles for &lt;chef-client-node&gt;, and the enviornment_name will be the cloud. cloudname for &lt;chef-client-node&gt; . The two attribute will be put into the mypostscript.tmpl. The script will invoke the knife command to assign the roles/environment_name to the chef-client. Such as: 
    
     knife node run_list add rhcn2.ppd.pok.ibm.com "role[single-compute]"
     knife exec -E 'nodes.transform("chef_environment:_default") { |n| n.chef_environment("production") }'
    

## Other Design Considerations

  * **Required reviewers**: Bruce, Linda, Guang Cheng, Gao Ling, Sun Jing and etc. 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: clouds 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
