<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [chef installation](#chef-installation)
  - [On Ubuntu](#on-ubuntu)
  - [On Redhat](#on-redhat)
- [OpenStack Deployment with Chef](#openstack-deployment-with-chef)
  - [Configure the chef server(or workstation)](#configure-the-chef-serveror-workstation)
  - [Deploy openstack](#deploy-openstack)
    - [Modify the configuration file on server( or workstation)](#modify-the-configuration-file-on-server-or-workstation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## Introduction

This mini-design discusses how to use Chef to deploy OpenStack software. Chef is an an open-source automation configuration management tool written in Ruby and Erlang. It uses a pure-Ruby, domain-specific language (DSL) for writing system configuration "recipes" or "cookbooks". Chef was written by Opscode (http://www.opscode.com/chef/) and is released as open source under the Apache License 2.0. Chef is a DevOps tool used for configuring cloud services or to streamline the task of configuring a company's internal servers.Chef supports a wide variety of cloud providers including Amazon AWS, Google App Engine, OpenStack and so on. OpenStack (http://www.openstack.org/) is an open source software that provides infrastructure for cloud computing. 

This doc discusses how to setup chef server and client within xCAT cluster and then kick off the OpenStack deployment using chef. We'll have the following assumption: 

  * All the nodes have an external network that has internet connection and a internal network. 
  * The OpenStack controller will not be the same as the xCAT management node. This is due to the conflict of OpenStack DHCP and xCAT DHCP server. 

We'd like to divide it into following two functions: 

  1. chef installation 
  2. OpenStack deployment with chef 

Function #1 itself is a unique feature that allows user to use the chef deploying other applications. 

## chef installation

Chef comprises three main elements: a server, one (or more) nodes, and at least one workstation. 

Server - The Chef Server acts as a hub that is available to every node in the Chef organization. This ensures that the right cookbooks (and recipes) are available, that the right policies are being applied, that the node object used during the previous Chef run is available to the current Chef run, and that all of the nodes that will be maintained by Chef are registered and known to the Chef Server. 

Workstation - The workstation is the location from which cookbooks (and recipes) are authored, policy data (such as roles, environments, and data bags) are defined, data is synchronized with the Chef repository, and data is uploaded to the Chef Server. The workstation could be configured on the chef server. 

Client - Each node contains a chef-client that performs the various infrastructure automation tasks that each node requires. 

### On Ubuntu

The following 6 postscripts will be created, they will be installed under /install/postscripts directory. 

  1. install_chef_server It can be run on the mn as a script or on a node as a postscript to install and configure the chef server. It first installs the chef-server deb(or rpm) and then calls the config_chef_server script to modify the chef server configuration files. 
  2. install_chef_workstation It is run as a postscript on a node. It first download and installs the chef deb(or rpm) and then calls config_chef_workstation script to copy the admin.pem and chef-validator.pem from server to workstation, and then modify the knife.rb configuration file. 
  3. install_chef_client It is run as a postscript on a node. It first download and installs the chef deb(or rpm) and then calls config_chef_client script to modify the client.rb configuration file, and then run "/opt/chef/bin/chef-client" to register the client on the server. 
  4. config_chef_server It is called by install_chef_server on Ubuntu and the chef kit on RH (discussed later). It runs the "sudo chef-server-ctl reconfigure" to do the configuration. 
  5. config_chef_workstation It is called by install_chef_workstation on Ubuntu and the chef kit on RH (discussed later). It copies the admin.pem and chef-validator.pem from server to workstation, and then modifies the knife.rb configuration file. 
  6. config_chef_client It is called by install_chef_client on Ubuntu and the chef kit on RH (discussed later). It copies chef-validator.pem from server to client, and then modifies the client.rb configuration file. 

This is what the user will do when installing chef: 

First assign a node as a chefserver, the node can be mn or any node. 
    
       chdef -t site clustersite chefserver=&lt;nodename&gt;
    

If the chef server in mn, run 
    
       install_chef_server
    

If chef server is not mn, first add install_chef_server to the postscripts table for the node, 
    
       chdef -t node -o &lt;nodename&gt; -p postbootscripts=install_chef_server
    

Then run updatnode or redeploy the node: 
    
       updatenode &lt;nodename&gt; -P install_chef_server
     or
       rsetboot &lt;nodename&gt; net
       nodeset &lt;nodename&gt; osimage=&lt;imgname&gt;
       rpower &lt;nodename&gt; reset
    

To install chef workstation on nodes, first add install_chef_workstation to the postscripts table for the nodes, 
    
       chdef -t node -o &lt;noderange&gt; -p postbootscripts=install_chef_workstation 
    

Then run updatenode or redeploy the node: 
    
       updatenode &lt;noderange&gt; -P install_chef_workstation 
     or
       rsetboot &lt;noderange&gt; net
       nodeset &lt;noderange&gt; osimage=&lt;imgname&gt;
       rpower &lt;noderange&gt; reset
    

  
To install chef client on nodes, first add install_chef_client to the postscripts table for the nodes, 
    
       chdef -t node -o &lt;noderange&gt; -p postbootscripts=install_chef_client
    

Then run updatenode or redeploy the node: 
    
       updatenode &lt;noderange&gt; -P install_chef_client
     or
       rsetboot &lt;noderange&gt; net
       nodeset &lt;noderange&gt; osimage=&lt;imgname&gt;
       rpower &lt;noderange&gt; reset
    

### On Redhat

Under discussion and dev. 

## OpenStack Deployment with Chef

With automation setup by the OpenStack chef Modules, deploying OpenStack is quite easy, if everything goes well. If something is wrong, you have to debug the modules which is not that easy. Hope we setup everything up front so that the installation goes smoothly. 

**The following deployment is on Ubuntu 12.**

### Configure the chef server(or workstation)

1\. Add the ubuntu repos on the internet 
    
    ubuntusource="deb http://us.archive.ubuntu.com/ubuntu/ precise main\n
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main\n
    deb http://us.archive.ubuntu.com/ubuntu/ precise universe\n
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates universe\n
    "
    echo -e $ubuntusource &gt;&gt; /etc/apt/sources.list
    apt-get update
    

2\. install git and rake 
    
    apt-get install -y git rake
    

3\. download the cookbooks 
    
    mkdir -p /usr/ling/chef
    cd /usr/ling/chef
    
    
    git clone git://github.com/mattray/openstack-cookbooks.git
    cd /usr/ling/chef/openstack-cookbooks/cookbooks
    knife cookbook site download apache2 0.99.4
    knife cookbook site download apt 1.1.2
    knife cookbook site download mysql 1.0.5
    knife cookbook site download openssl 1.0.0
    knife cookbook site download rabbitmq 1.2.1
    
    
    tar -axvf apache2-0.99.4.tar.gz
    tar -axvf apt-1.1.2.tar.gz 
    tar -axvf mysql-1.0.5.tar.gz
    tar -axvf openssl-1.0.0.tar.gz
    tar -axvf rabbitmq-1.2.1.tar.gz
    

4\. upload the cookbooks 
    
    knife cookbook upload -a -o /usr/ling/chef/openstack-cookbooks/cookbooks
    knife cookbook list
      apache2    0.99.4
      apt        1.1.2
      glance     0.2.0
      mysql      1.0.5
      nova       0.3.0
      openssl    1.0.0
      rabbitmq   1.2.1
      swift      0.1.0
    

5\. Roles 
    
    cd /usr/ling/chef/openstack-cookbooks
    rake roles
    
    
    knife role list
     glance-single-machine
     nova-dashboard-server
     nova-db
     nova-multi-compute
     nova-multi-controller
     nova-rabbitmq-server
     nova-single-machine
    

6\. Configure Attributes for Deployment 
    
    cd /usr/ling/chef/openstack-cookbooks
    rake databag:upload_all
    knife node run_list add oscn2.ppd.pok.ibm.com "role[nova-single-machine]"
    

### Deploy openstack

#### Modify the configuration file on server( or workstation)

Modify the following files: 
    
    /usr/ling/chef/openstack-cookbooks/cookbooks/nova/recipes/config.rb  and mysql.rb
    diff config.rb config.rb.save
    88c88
    
    
