<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Install Chef on Ubuntu](#install-chef-on-ubuntu)
  - [Assign the Chef server](#assign-the-chef-server)
  - [Install the chef server and workstation](#install-the-chef-server-and-workstation)
    - [If the chef server and the workstation are on the same node](#if-the-chef-server-and-the-workstation-are-on-the-same-node)
    - [If the chef server and the workstation are not on the same node](#if-the-chef-server-and-the-workstation-are-not-on-the-same-node)
    - [If the chef server is also an http server](#if-the-chef-server-is-also-an-http-server)
  - [Install chef client on nodes](#install-chef-client-on-nodes)
- [Install Chef On Redhat](#install-chef-on-redhat)
  - [Assign the Chef server](#assign-the-chef-server-1)
  - [Download and add the chef kit in xCAT](#download-and-add-the-chef-kit-in-xcat)
  - [Install chef server and workstation](#install-chef-server-and-workstation)
    - [If the chef server and the workstation are on the same node](#if-the-chef-server-and-the-workstation-are-on-the-same-node-1)
    - [If the chef server and the workstation are not on the same node](#if-the-chef-server-and-the-workstation-are-not-on-the-same-node-1)
    - [If the chef server is also an http server](#if-the-chef-server-is-also-an-http-server-1)
  - [Install chef client](#install-chef-client)
- [Test Chef Installation](#test-chef-installation)
- [Using Chef](#using-chef)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


**Note: This page is under construction**


## Introduction

Chef is an an open-source automation configuration management tool written in Ruby and Erlang. It uses a pure-Ruby, domain-specific language (DSL) for writing system configuration "recipes" or "cookbooks". Chef was written by Opscode (http://www.opscode.com/chef/) and is released as open source under the Apache License 2.0. Chef is a DevOps tool used for configuring cloud services or to streamline the task of configuring a company's internal servers.Chef supports a wide variety of cloud providers including Amazon AWS, Google App Engine, OpenStack and so on. OpenStack (http://www.openstack.org/) is an open source software that provides infrastructure for cloud computing.

This doc discusses how to setup chef server, workstation and client within xCAT cluster. See the xCAT document [Deploying_OpenStack] for how to then kick off the OpenStack deployment using chef.

Chef can be installed on many operating systems. Due to the time constraint, we'll limit it to Ubuntu 12 and rhels 6.x on x86_64 architecture for xCAT 2.8.1 release.

Note: xCAT is automatically adding and authenticating the workstation to the server, and the clients to the server. So it's required that we should install chef-server at first, and then chef-workstation, and finally chef-client.

## Install Chef on Ubuntu

Assumption:

  * The xCAT management and all the nodes involved have external internet connection. If not, please setup and use a proxy server.

### Assign the Chef server

In xCAT 2.8.2 and above, we support that assigning chef server to each chef client.

~~~~
      chdef <chef-client_noderange>  cfgmgr=chef cfgserver=<chef-server_nodename>
~~~~


If the chef server and the chef workstation are not in one node, we also can assign the chef server to the chef workstation.

~~~~
      chdef <chef-workstattion_nodename>  cfgmgr=chef cfgserver=<chef-server_nodename>
~~~~


### Install the chef server and workstation

#### If the chef server and the workstation are on the same node

1 If the chef server is the management node, then run

~~~~
       /install/postscripts/install_chef_server
       /install/postscripts/install_chef_workstation
~~~~


2 If chefserver is not the management node, first add install_chef_server,install_chef_workstation to the postscripts table for the node,

~~~~
       chdef -t node -o <nodename> -p postbootscripts=install_chef_server,install_chef_workstation
~~~~


If the node is up and running, then run the following command to install the chef server and the workstation.

~~~~
       updatenode <nodename> -P install_chef_server,install_chef_workstation
~~~~


If the node is not up, then redeploy the node to get chef server and workstation installed.

~~~~
       rsetboot <nodename> net
       nodeset <nodename> osimage=<image_name>
       rpower <nodename> boot
~~~~


#### If the chef server and the workstation are not on the same node

1 If the chef server is the management node.

1.1 install the chef server, run

~~~~
       /install/postscripts/install_chef_server
~~~~


if the chef server is not the management node, first add install_chef_server to the postscripts table for the node,

~~~~
       chdef -t node -o <nodename> -p postbootscripts=install_chef_server
~~~~


If the node is up and running, then run the following command to install the chef server and the workstation.

~~~~
       updatenode <nodename> -P install_chef_server
~~~~


If the node is not up, run rsetboot/nodeset/rpower to redeploy the &lt;nodename&gt; to get chef server and workstation installed.

1.2 install the workstation

Before start installing the workstation, you should make sure the chef server is working well.

~~~~
      xdsh <noderange_server> chef-server-ctl  status
~~~~


first add install_chef_workstation to the postscripts table for the node,

~~~~
       chdef -t node -o <nodename_workstation> -p postbootscripts=install_chef_workstation
~~~~


If the node is up and running, then run the following command to install the chef workstation.

~~~~
       updatenode <nodename_workstation> -P install_chef_workstation
~~~~


If the node is not up, run rsetboot/nodeset/rpower to redeploy the &lt;nodename_workstation&gt; to get chef workstation installed.

#### If the chef server is also an http server

Chef uses an internal configuration of the nginx service to handle its httpd communications, which by default uses port 80. This may directly conflict with a configured httpd server on the same system. If your chef server also needs to run httpd, which is true if your chef server will run on your xCAT management node, you may need to configure a new port for the Chef nginx service:

~~~~
      vi /etc/chef-server/chef-server.rb
          # add this entry with a new port number of your choice:
          nginx['non_ssl_port'] = 4000
~~~~

~~~~
      /usr/bin/chef-server-ctl reconfigure
~~~~


To verify that both httpd and chef are running correctly:

~~~~
      # service httpd status
      httpd (pid  111) is running...
~~~~

~~~~
      # knife client list
      chef-validator
      chef-webui
~~~~


If you see the following error from knife commands:

~~~~
      # knife client list
      ERROR: Errno::ECONNRESET: Connection reset by peer - SSL_connect
~~~~


This may be an indication that the nginx service is not running correctly. To verify:

~~~~
      # ps -ef | grep -i nginx
      root       929   913  0 19:08 ?        00:00:00 runsv nginx
      root       937   929  0 19:08 ?        00:00:00 svlogd -tt /var/log/chef-server/nginx
      root       952   929  0 19:08 ?        00:00:00 nginx: master process /opt/chef-server/embedded/sbin/nginx -c     /var/opt/chef-server/nginx/etc/nginx.conf
      497        988   952  0 19:08 ?        00:00:00 nginx: worker process
      497        989   952  0 19:08 ?        00:00:00 nginx: worker process
      497        990   952  0 19:08 ?        00:00:00 nginx: worker process
      497        991   952  0 19:08 ?        00:00:00 nginx: worker process
      497        992   952  0 19:08 ?        00:00:00 nginx: cache manager process
~~~~


If you do not see master and worker processes, nginx is not running correctly. Make sure you do not have a port conflict with your httpd service.

### Install chef client on nodes

Before start installing the chef client, you should make sure the chef server/workstation is working well.

~~~~
      xdsh <noderange_workstation> knife client list
~~~~


first add install_chef_client to the postscripts table for the nodes,

~~~~
       chdef -t node -o <noderange> -p postbootscripts=install_chef_client
~~~~


If the node is up, then run the following command to install the chef client.

~~~~
       updatenode <noderange> -P install_chef_client
~~~~


If the node is not up, run rsetboot/nodeset/rpower to redeploy the &lt;noderange&gt; to get chef client installed.

~~~~
       rsetbootseq <noderange> net
       nodeset <noderange> osimage=<image_name>
       rpower <noderange> boot
~~~~


## Install Chef On Redhat

A kit will be used to install the chef server, workstation and client on RedHat and other platforms. Please refer to [Using_Software_Kits_in_OS_Images]for the general concept about kit.

The name of the kit is called **chef**. The chef kit contains

  * the chef server and chef packages from opscode (&lt;http://www.opscode.com/chef/install/&gt;)
  * the necessary configuration scripts.

There are 3 kit components from this kit:

  * chef_server_kit
  * chef_workstation_kit
  * chef_client_kit

The follow steps show how to install Chef server, workstation and client using the chef kit.

### Assign the Chef server

In xCAT 2.8.2 and above, we support that assigning chef server to each chef client.

~~~~
      chdef <chef-client_noderange>  cfgmgr=chef cfgserver=<chef-server_nodename>
~~~~


If the chef server and the chef workstation are not in one node, we also can assign the chef server to the chef workstation.

~~~~
      chdef <chef-workstattion_nodename>  cfgmgr=chef cfgserver=<chef-server_nodename>
~~~~


### Download and add the chef kit in xCAT

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


### Install chef server and workstation

#### If the chef server and the workstation are on the same node

First, add the chef_server_kit,chef_workstation_kit components to the image of the node that will be the chef server.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name> chef_server_kit,chef_workstation_kit
~~~~


If there is no os image assigned to the node, please refer to the [Assign os image to a node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node) section.

To install the chef server and workstation, please make sure yum is installed on the node. And then run updatenode or redeploy the node.

~~~~
       updatenode <nodename> -P otherpkgs
     or
       rsetbootseq <nodename> net
       nodeset <nodename> osimage=<image_name>
       rpower <nodename> boot
~~~~


#### If the chef server and the workstation are not on the same node

1 Install the chef server

First, add the chef_server_kit components to the image of the node that will be the chef server.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name_for_server> chef_server_kit
~~~~


If there is no os image assigned to the node, please refer to the [Assign os image to a node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node).

To install the chef server, please make sure yum is installed on the node. And then run updatenode or redeploy the node.

~~~~
       updatenode <nodename> -P otherpkgs
~~~~

     or

~~~~
       rsetbootseq <nodename> net
       nodeset <nodename> osimage=<image_name>
       rpower <nodename> boot
~~~~


2 Install the chef workstation

Before start installing the workstation, you should make sure the chef server is working well.

~~~~
      xdsh <noderange_server> chef-server-ctl  status
~~~~



First, add the chef_workstation_kit components to the image of the node that will be the chef server.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename_workstation> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name_for_workstation> chef_workstation_kit
~~~~


If there is no os image assigned to the node, please refer to the [Assign os image to a node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node) section.

To install the chef server and workstation, please make sure yum is installed on the node. And then run updatenode or redeploy the &lt;nodename_workstation&gt; .

~~~~
       updatenode <nodename_workstation> -P otherpkgs
~~~~
     or
~~~~
       rsetbootseq <nodename_workstation> net
       nodeset <nodename_workstation> osimage=<image_name>
       rpower <nodename_workstation> boot
       rsetbootseq <nodename_workstation> net
~~~~





#### If the chef server is also an http server

Chef uses an internal configuration of the nginx service to handle its httpd communications, which by default uses port 80. This may directly conflict with a configured httpd server on the same system. If your chef server also needs to run httpd, which is true if your chef server will run on your xCAT management node, you may need to configure a new port for the Chef nginx service:

~~~~
      vi /etc/chef-server/chef-server.rb
          # add this entry with a new port number of your choice:
          nginx['non_ssl_port'] = 4000
~~~~

~~~~
      /usr/bin/chef-server-ctl reconfigure
~~~~


To verify that both httpd and chef are running correctly:

~~~~
      # service httpd status
      httpd (pid  111) is running...
      # knife client list
      chef-validator
      chef-webui
~~~~


If you see the following error from knife commands:

~~~~
      # knife client list
      ERROR: Errno::ECONNRESET: Connection reset by peer - SSL_connect
~~~~


This may be an indication that the nginx service is not running correctly. To verify:

~~~~
      # ps -ef | grep -i nginx
      root       929   913  0 19:08 ?        00:00:00 runsv nginx
      root       937   929  0 19:08 ?        00:00:00 svlogd -tt /var/log/chef-server/nginx
      root       952   929  0 19:08 ?        00:00:00 nginx: master process /opt/chef-server/embedded/sbin/nginx -c     /var/opt/chef-server/nginx/etc/nginx.conf
      497        988   952  0 19:08 ?        00:00:00 nginx: worker process
      497        989   952  0 19:08 ?        00:00:00 nginx: worker process
      497        990   952  0 19:08 ?        00:00:00 nginx: worker process
      497        991   952  0 19:08 ?        00:00:00 nginx: worker process
      497        992   952  0 19:08 ?        00:00:00 nginx: cache manager process
~~~~


If you do not see master and worker processes, nginx is not running correctly. Make sure you do not have a port conflict with your httpd service.

### Install chef client

Before start installing the chef client, you should make sure the chef server/workstation is working well.

~~~~
      xdsh <noderange_workstation> knife client list
~~~~


First, add the chef client_kit components to the image of the node that will be the chef client.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename_client> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name_for_client> chef_client_kit
~~~~


If there is no os image assigned to the node, please refer to the [Assign os image to a node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node) section.

To install the chef client, please make sure yum is installed on all the node. And then run updatenode or redeploy the &lt;noderange_clients&gt;.

~~~~
       updatenode <noderange_clients> -P otherpkgs
~~~~
     or
~~~~
       rsetbootseq <noderange_clients> net
       nodeset <noderange_clients> osimage=<image_name>
       rpower <noderange_clients> boot
~~~~


## Test Chef Installation

    Add chef commands path to the path:
~~~~
     cat /etc/profile.d/chef.sh
        PATH=/opt/chef/embedded/bin:$PATH
        export PATH
     xdcp <noderange_workstations>  /etc/profile.d/chef.sh  /etc/profile.d
     xdsh <noderange_workstations> source /etc/profile.d/chef.sh
~~~~



Check to see knife command work

~~~~
     xdsh <noderange_workstations>  knife client list
~~~~


The output should similar to the following:

~~~~
     chef-validator
     chef-webui
     osrh2.ppd.pok.ibm.com
~~~~


And you should see from the output that the chef-client is registered on the chef-server.

## Using Chef

1\. Remove the chef installation scripts from the node attributes(only for Ubuntu)

Once we set up the chef environment, we need to remove the chef installation scripts from the node attributes to avoiding updating again.

~~~~
     [root@ls21n01 ~]# lsdef oscn1 -i postbootscripts
      Object name: oscn1
          postbootscripts=otherpkgs,install_chef_server,install_chef_workstation
      [root@ls21n01 ~]# chdef oscn1  postbootscripts=otherpkgs
~~~~



2\. About the chef cookbooks

We always install the chef-server and chef-workstation on the same node. Before using the chef, you should put the chef cookbooks on the chef-workstation, such as

/usr/openstack-cookbooks-repo/

There are several basic directories and files in this repo:

~~~~
      ls /usr/openstack-cookbooks-repo/
      README  build  cookbooks  environment roles  ...
~~~~


And then in the /usr/openstack-cookbooks-repo/, using knife command to upload the environment, cookbooks and roles:

~~~~
     knife environment from file roles/example.json
     knife cookbook upload -o cookbooks --all
     knife role from file roles/*.rb
~~~~



For instructions on using Chef to install OpenStack in your cluster, see the xCAT document [Deploying_OpenStack].


3\. You can get more information from the chef official site:

      http://www.opscode.com/chef/


