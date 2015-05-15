<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Install Puppet on Ubuntu](#install-puppet-on-ubuntu)
- [Install Puppet On Redhat](#install-puppet-on-redhat)
- [Using Puppet](#using-puppet)
- [Appendix](#appendix)
  - [Assign OS Image to a Node](#assign-os-image-to-a-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**Note: This page is under construction**


## Introduction

Puppet is an automation software that helps system administrators manage software throughout its life cycle, from provisioning and configuration to patch management and compliance. Puppet is available as both open source and commercial software. We only support the open source Puppet in xCAT. Puppetlab (https://puppetlabs.com/) provides many modules that automates the deployment of some critical applications such as OpenStack.

This doc discusses how to setup puppet server and client within xCAT cluster.

Puppet server and client can be installed on many operating systems. Due to the time constraint, we'll limit it to Ubuntu and RedHat on x86_64 architecture for xCAT 2.8.1 release.

## Install Puppet on Ubuntu

Assumption:

  * The xCAT management and all the nodes involved have external internet connection. If not, please setup and use a proxy server.

1\. Add the puppet server name in the site table. The puppet server can be xCAT management node or any other node in the cluster.

~~~~
       chdef -t site clustersite puppetserver=<nodename>
~~~~


2\. If the puppet server is the management node, then run

~~~~
       /install/postscripts/install_puppet_server
~~~~


3\. If puppet server is not the management node, first add install_puppet_server to the postscripts table for the node,

~~~~
       chdef -t node -o <nodename> -p postbootscripts=install_puppet_server
~~~~


If the node is up and running, then run the following command to install the puppet server.

~~~~
       updatenode <nodename> -P install_puppet_server
~~~~


If the node is not up, then redeploy the node to get puppet server installed.

~~~~
       rsetboot <nodename> net
       nodeset <nodename> osimage=<image_name>
       rpower <nodename> boot
~~~~


4\. To install puppet client on nodes, first add install_puppet_client to the postscripts table for the nodes,

~~~~
       chdef -t node -o <noderange> -p postbootscripts=install_puppet_client
~~~~


If the node is up, then run the following command to install the puppet client.

~~~~
       updatenode <noderange> -P install_puppet_client
~~~~


If the node is not up, then redeploy the node to get puppet client installed.

~~~~
       rsetbootseq <noderange> net
       nodeset <noderange> osimage=<image_name>
       rpower <noderange> boot
~~~~


## Install Puppet On Redhat

A kit will be used to install the puppet server and client on RedHat and other platforms. Please refer to [Using_Software_Kits_in_OS_Images] for general kit concepts.


The name of the kit is called **puppet**. The puppet kit contains

  * the puppet server and client packages from puppetlab (&lt;https://yum.puppetlabs.com/el/6/products/x86_64/&gt;)
  * the dependency packages (&lt;https://yum.puppetlabs.com/el/6/dependencies/x86_64/&gt;)
  * the necessary configuration scripts.

There are 2 kit components from this kit:

  * puppet_server_kit
  * puppet_client_kit


The follow steps show how to install Puppet server and client using the puppet kit.

1\. Add the puppet server name in the site table. The puppet server can be the xCAT management node or any other node in the cluster.

~~~~
       chdef -t site clustersite puppetserver=<nodename>
~~~~


2\. Download and add the puppet kit in xCAT

~~~~
      cd /tmp
      wget http://sourceforge.net/projects/xcat/files/kits/puppet/x86_64/puppet-3.1.1-1-rhels-6-x86_64.tar.bz2
      addkit /tmp/puppet-3.1.1-1-rhels-6-x86_64.tar.bz2
~~~~


Now you can list the full names of the kit components from this kit:

~~~~
       #lsdef -t kitcomponent | grep puppet
       puppet_client_kit-3.1.1-1-rhels-6-x86_64  (kitcomponent)
       puppet_server_kit-3.1.1-1-rhels-6-x86_64  (kitcomponent)
~~~~


3\. Install puppet server

First, add the puppet_server_kit components to the image of the node that will be the puppet server.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name> puppet_server_kit
~~~~


If there is no os image assigned to the node, please refer to the [Assign_OS_Image_to_a_Node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node) section at the end of this document.

To install the puppet server, please make sure yum is installed on the node. And then run updatenode or redeploy the node.

~~~~
       updatenode <nodename> -P otherpkgs
~~~~

     or
~~~~

       rsetbootseq <nodename> net
       nodeset <nodename> osimage=<image_name>
       rpower <nodename> boot
~~~~


4\. Install puppet client

First, add the puppet_client_kit components to the image of the node that will be the puppet client.

To find out the name of the image for a node, run

~~~~
       lsdef <nodename> -i provmethod
~~~~


Then run

~~~~
       addkitcomp -i <image_name> puppet_client_kit
~~~~


If there is no os image assigned to the node, please refer to the [Assign_OS_Image_to_a_Node](Adding_Puppet_in_xCAT_Cluster/#assign-os-image-to-a-node) section at the end of this doucument.

To install the puppet client, please make sure yum is installed on all the node. And then run updatenode or redeploy the node.

~~~~
       updatenode <noderange> -P otherpkgs
~~~~

     or

~~~~

       rsetbootseq <noderange> net
       nodeset <noderange> osimage=<image_name>
       rpower <noderange> boot
~~~~


## Using Puppet

Puppet is installed, xCAT has already made the Puppet server-client authentication automated during the above installation procedure. The Puppet client will be automatically certified when it starts.

Now you can run the Puppet commands on the puppet server and client. All the commands start with puppet.

~~~~
       puppet help
~~~~


It shows you all the Puppet commands. Puppet can be used to manage the nodes where Puppet client is installed. You describe node configurations in an easy-to-read declarative language, and Puppet will bring your systems into the desired state and keep them there. The /etc/puppet/manifests/site.pp file is the starting point where you define your node configuration. For example:

~~~~
       # vi /etc/puppet/manifests/site.pp
       node 'node1' {
          file {'ntp.conf':
              path    => '/etc/ntp.conf',
              ensure  => file,
              content => template('ntp/ntp.conf'),
              owner   => root,
              mode    => 0644,
           }
           package {'ntp':
               ensure => installed,
               before => File['ntp.conf'],
           }
           service {'ntpd':
             ensure    => running,
             subscribe => File['ntp.conf'],
           }
       }

~~~~

This tells the agent to create a ntp.conf file, install ntp package and start ntpd on node1. You can start the configuration by running the following command on node1:

~~~~
       puppet agent -t
~~~~


Or run the remote command on the Puppet server:

~~~~
       xdsh node1 "puppet agent -t"
~~~~


Please refer to http://docs.puppetlabs.com/puppet/3/reference/ for more details.

## Appendix

### Assign OS Image to a Node

To check the OS image name associated with a node, run

~~~~
       lsdef <nodename> -i provmethod
~~~~


If there is no OS image assigned to the node, you need to first find out what images are available in the cluster:

~~~~
       lsdef -t osimage
~~~~


Then choose an appropriate image and assign it to the node:

~~~~
       chdef <nodename> provmethod=<image_name>
~~~~


The xCAT management node is a special node in the cluster, and is very often not even defined in the xCAT database. To check:

~~~~
       lsdef __mgmtnode
~~~~

     where __mgmtnode is a node group name designated for the management node.


To define it in xCAT database, run

~~~~
       xcatconfig -m
~~~~


Then assign an image to it:

~~~~
       chdef __mgmtnode provmethod=<image_name>
~~~~



