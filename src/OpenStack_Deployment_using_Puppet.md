<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Puppet server and client installation](#puppet-server-and-client-installation)
  - [On Ubuntu](#on-ubuntu)
  - [On Redhat](#on-redhat)
- [OpenStack Deployment with Puppet](#openstack-deployment-with-puppet)
  - [Configure the Puppet server](#configure-the-puppet-server)
  - [Deploy OpenStack on the nodes](#deploy-openstack-on-the-nodes)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## Introduction

This mini-design discusses how to use Puppet to deploy OpenStack software. Puppet is an automation software that helps system administrators manage software throughout its life cycle, from provisioning and configuration to patch management and compliance. Puppet is available as both open source and commercial software. We only support the open source Puppet in xCAT. Puppet lab (https://puppetlabs.com/) provides many modules that automates the deployment of some critical applications such as OpenStack. OpenStack (http://www.openstack.org/) is an open source software that provides infrastructure for cloud computing. 

This doc discusses how to setup puppet server and client within xCAT cluster and then kick off the OpenStack deployment using puppet. We'll have the following assumption: 

  * All the nodes have an external network that has internet connection and a internal network. 
  * The OpenStack controller will not be the same as the xCAT management node. This is due to the conflict of OpenStack DHCP and xCAT DHCP server. 

We'd like to divide it into following two functions: 

  1. Puppet server and client installation 
  2. OpenStack deployment with puppet 

Function #1 itself is a unique feature that allows user to use the puppet deploying other applications. 

## Puppet server and client installation

Puppet server and client can be installed on many operating systems. Due to time limit, we'll limit it to Ubuntu and RedHat for xCAT 2.8.1 release. 

### On Ubuntu

The following 4 postscripts will be created, they will be installed under /install/postscripts directory. 

  1. install_puppet_server It can be run on the mn as a script or on a node as a postscript to install and configure the puppet server. It first installs the puppet-server rpm and its dependencies and then calls the config_puppet_server script to modify the puppet server configuration files. And then it restarts the puppet server so that the new configuration can take effect. 
  2. install_puppet_client It is run as a postscript on a node. It first download and installs the puppet client rpm and its dependencies and then calls config_puppet_client script to modify the puppet client configuration files. It does NOT start the puppet agent because it may kick off the application deployment prematurely. 
  3. config_puppet_server It is called by install_puppet_server on Ubuntu and the puppet kit on RH (discussed later). It sets the **certname** in /etc/puppet/puppet.conf file. This name will be referenced as the puppet server name by the client in order to certify with the server. A **site.puppetserver** value will be used as the **certname** if it is defined, otherwise **site.master** will be used. It also sets up the /etc/puppet/autosign.conf file so that the client certification can be done automatically. 
  4. config_puppet_client It is called by install_puppet_client on Ubuntu and the puppet kit on RH (discussed later). It sets the **server** name and its own node name in /etc/puppet/puppet.conf file. 

This is what the user will do when installing puppet: 

First assign a node as a puppet server, the node can be mn or any node. 
    
       chdef -t site clustersite puppetserver=&lt;nodename&gt;
    

If the puppet server is mn, run 
    
       install_puppet_server
    

If puppet server is not mn, first add install_puppet_server to the postscripts table for the node, 
    
       chdef -t node -o &lt;nodename&gt; -p postbootscripts=install_puppet_server
    

Then run updatnode or redeploy the node: 
    
       updatenode &lt;nodename&gt; -P install_puppet_server
     or
       rsetboot &lt;nodename&gt; net
       nodeset &lt;nodename&gt; osimage=&lt;imgname&gt;
       rpower &lt;nodename&gt; reset
    

To install puppet client on nodes, first add install_puppet_client to the postscripts table for the nodes, 
    
       chdef -t node -o &lt;noderange&gt; -p postbootscripts=install_puppet_client
    

Then run updatenode or redeploy the node: 
    
       updatenode &lt;noderange&gt; -P install_puppet_client
     or
       rsetbootseq &lt;noderange&gt; net
       nodeset &lt;noderange&gt; osimage=&lt;imgname&gt;
       rpower &lt;noderange&gt; reset
    

  


### On Redhat

A kit will be used to install the puppet server and client on RedHat and other platform. In this release we'll create a kit just for rhels6 with x86_64 architecture. The puppet rpms and the dependency packages will be downloaded from https://yum.puppetlabs.com/el/6/dependencies/x86_64/ and https://yum.puppetlabs.com/el/6/products/x86_64/ 

The name of the kit is called **puppet**. There will be 2 kit components in the kit: 

  * puppet_server_kit 
  * puppet_client_kit 

The buildkit.conf file looks like this: 
    
     kit:
       basename=puppet
       description=Kit for installing puppet server and client
       version=1.0
       ostype=Linux
       kitlicense=EPL
      
      
     kitrepo:
      kitrepoid=rhels6_x86_64
      osbasename=rhels
      osmajorversion=6
      #osminorversion=
      osarch=x86_64
     
      #compat_osbasenames=
      
      
     kitcomponent:
       basename=puppet_client_kit
       description=For installing puppet client
       version=1.0
       release=1
       serverroles=servicenode,compute
       kitrepoid=rhels6_x86_64
       kitpkgdeps=puppet
       postinstall=client.rpm_post
       postbootscripts=client.post
      
     kitcomponent:
       basename=puppet_server_kit
       description=For installing puppet server
       version=1.0
       release=1
       serverroles=mgtnode
       kitrepoid=rhels6_x86_64
       kitpkgdeps=puppet-server
       postinstall=server.rpm_post
       postbootscripts=server.post
      
      
     kitpackage:
       filename=puppet-3*
       kitrepoid=rhels6_x86_64
       isexternalpkg=no
       rpm_prebuiltdir=rhels6/x86_64
      
     kitpackage:
       filename=puppet-server-*
       kitrepoid=rhels6_x86_64
       isexternalpkg=no
       rpm_prebuiltdir=rhels6/x86_64
      
     kitpackage:
       filename=*
       kitrepoid=rhels6_x86_64
       isexternalpkg=no
       rpm_prebuiltdir=rhels6/x86_64
    

The server.rpm_post and client.rpm_post are used as the %post script for the **puppet_server_kit.rpm** and **puppet_client_kit.rpm** meta packages respectively. They are used to configure the puppet after it is installed. server.rpm_post calls config_puppet_server and client.rpm_post calls config_puppet_client. However, this will not work for stateless/statelite when the puppet rpms are installed into images by genimage command. This is because both config* scripts need the environmental variables such as $NODE, $PUPPETSERVER and $SITEMASTER etc. in order to do the configuration for puppet. When genimage is called, these environmental variables are not set and the $NODE cannot be the same for every node. In order to solve this problem, two other scripts server.post and client.post will be used as the postbootscripts in the **postscripts** table for the nodes. 

The client.rpm_post looks like this: 
    
       if [ -f "/proc/cmdline" ]; then   # prevent running it during install into chroot image
           #configure the puppet agent configuration files
           /xcatpost/config_puppet_client "$@"
       fi
       exit 0
    

The client.post looks like this: 
    
       if [ "$NODESETSTATE" = "install" ]; then
           #prevent getting called during full install bootup
           #because the function will be called in the rpm %post section instead
           exit 0
       else
           #configure the puppet agent configuration files
           /xcatpost/config_puppet_client "$@"
       fi
       exit 0
    

  
The following is the user instruction on how to install puppet server and client on RH, assuming mn is the puppet server. 

Add mn on the xCAT DB 
    
       xcatconfig -m
    

Please make sure that there is an image name assigned to the mn and each node. To check, run 
    
       lsdef &lt;nodename&gt; provmethod
    

Add puppet server name in the site table 
    
       chdef -t site clustersite puppetserver=&lt;mnname&gt;
    

Download the puppet kit 
    
       wget http://xcat.sourceforge.net/#download... (TBD)
    

Add the kit in xCAT 
    
       addkit puppet-1.0-Linux.tar.bz2
       addkitcomp -i &lt;mn_image_name&gt; puppet_server_kit
       addkitcomp -i &lt;node_image_name&gt; puppet_client_kit
    

To install the puppet server on the mn, run 
    
       updatenode &lt;mnname&gt;  -P otherpkgs
    

To install the puppet client on the node, run updatenode or redeploy the node. Please make sure yum is installed on all the nodes. 
    
       updatenode &lt;noderange&gt; -P otherpkgs
     or
       rsetbootseq &lt;noderange&gt; net
       nodeset &lt;noderange&gt; osimage=&lt;imgname&gt;
       rpower &lt;noderange&gt; reset
    

## OpenStack Deployment with Puppet

With automation setup by the OpenStack Puppet Modules, deploying OpenStack is quite easy, if everything goes well. If something is wrong, you have to debug the modules which is not that easy. Hope we setup everything up front so that the installation goes smoothly. 

### Configure the Puppet server

1\. Load the OpenStack modules 
    
      puppet module install puppetlabs-openstack
      puppet module list
    

2\. Create a site manifest site.pp for OpenStack 
    
      cat /etc/puppet/modules/openstack/examples/site.pp &gt;&gt; /etc/puppet/manifests/site.pp
    

Note: There is 2 errors in /etc/puppet/manifests/site.pp file, they are found when deploying OpenStack Folsom on Ubuntu 12.04.2. You may need to make the following changes for your cluster: In 'openstack::controller' class, comment out export_resources entry and add a entry for secret_key. So the last two entried of the class look like this: 
    
       #export_resources    =&gt; false,
       secret_key           =&gt; 'dummy_secret_key',
    

Note: I have created a script for step 1 and 2, but feel it is not worth to check in. This should not be a big burden for the user anyway. 

3\. Input cluster info in the site.pp file Now you can modify the file /etc/puppet/manifests/site.pp and input the network info and the a few passwords. We usually make all the passwords the same. The following entries must be filled: 
    
       $public_interface        = 'eth0'
       $private_interface       = 'eth1'
       # credentials
       $admin_email             = 'root@localhost'
       $admin_password          = 'keystone_admin'
       $keystone_db_password    = 'keystone_db_pass'
       $keystone_admin_token    = 'keystone_admin_token'
       $nova_db_password        = 'nova_pass'
       $nova_user_password      = 'nova_pass'
       $glance_db_password      = 'glance_pass'
       $glance_user_password    = 'glance_pass'
       $rabbit_password         = 'openstack_rabbit_password'
       $rabbit_user             = 'openstack_rabbit_user'
       $fixed_network_range     = '10.0.0.0/24'
       $floating_network_range  = '192.168.101.64/28'
      
       $controller_node_address  = '192.168.101.11'
    

Add the OpenStack controller and compute nodes in the site.pp file. You can replace "node /openstack_controller/" and "node /openstack_compute/" or "node /openstack_all/" with the node names of your cluster, for example: 
    
       node "node1" {
          class { 'openstack::controller':
           ...
       }
    
    
       node "node2,node3" {
          class { 'openstack::compute':
          ...
       }
    

### Deploy OpenStack on the nodes

1\. Setup the OpenStack repo on the nodes 
    
       chdef -t node -o &lt;noderange&gt; -p postbootscripts=setup_openstack_repo
       updatenode &lt;noderange&gt; -P  setup_openstack_repo
    

setup_openstack_repo has hard coded OpenStack repositories which you can modify to fit your needs. It uses the following repositories: 

  * Ubuntu: http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/folsom main 
  * RH: TBD 

2\. Deploy OpenStack 
    
       xdsh &lt;controller_nodename&gt; "puppet agent -t"
       xdsh &lt;compute_nodenames&gt; "puppet agent -t"
    

Now OpenStack is installed and configured on your node. Please refer to Puppet's own doc /etc/puppet/modules/openstack/README.md for detailed instructions on how to use puppet to deploy OpenStack 

## Other Design Considerations

  * **Required reviewers**: Bruce Potter, Guang Cheng, Jie Hua 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
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
