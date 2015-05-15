<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [What is Supported and What is Not](#what-is-supported-and-what-is-not)
- [Install a Linux Management Node](#install-a-linux-management-node)
- [Setup xCAT database on the MN](#setup-xcat-database-on-the-mn)
- [Install an AIX Service Node(s)](#install-an-aix-service-nodes)
- [Define the  AIX Service Node(s) as xCAT nodes](#define-the--aix-service-nodes-as-xcat-nodes)
- [Setup the remoteshell from management node to service node(s)](#setup-the-remoteshell-from-management-node-to-service-nodes)
- [Set nimprime attribute in the site table](#set-nimprime-attribute-in-the-site-table)
- [Install xCAT Service Node packages on Service Node(s)](#install-xcat-service-node-packages-on-service-nodes)
- [Setup the AIX Service Node](#setup-the-aix-service-node)
- [Make the AIX images available on the Service Node](#make-the-aix-images-available-on-the-service-node)
- [Install or diskless boot the AIX compute nodes](#install-or-diskless-boot-the-aix-compute-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview 

'''Note: this support is under investigation and not ready for general use!'''

This “How-To” illustrates how to install AIX diskful and diskless compute nodes using Linux management node and AIX service node. 

A cluster with both Linux nodes and AIX nodes is called “mixed cluster”. XCAT 2 only supports Linux management node to manage AIX service node and compute nodes for now. More scenarios will be supported in the future.

The process to setup mixed cluster is quite similar with the process to setup the normal xCAT 2 AIX cluster, only with some special steps. This “How-To” will not illustrates all the steps to setup a normal  xCAT 2 AIX cluster, the link to the xCAT 2 AIX documentation is provided when necessary.

### What is Supported and What is Not 

* The Management must be Linux (one of the Linux OS's supported by xCAT).   It can be either system p or system x architecture.
* You must have one or more AIX service nodes to install and support AIX compute nodes.  One of the AIX service nodes must be defined as the NIM prime
* If you have both system x and system p linux nodes, the see also the instructions in 
[Mixed_Cluster_Support_for_SLES]

* Since you will be using hierarchy (service nodes), you must use either MySQL or Postgresql for the xCAT database.  DB2 is another option, but requires a license and is not supported on system x by xCAT. 
* The first implementation of mixed AIX/Linux clusters only supports diskfull installs of the nodes(?). Stateless and statelite will be considered in future releases, if there is a requirement. 
* Power 775 hardware is not support in a mixed cluster.


## Install a Linux Management Node 

Refer to the  section titled “Install a Linux Management Node” in the following document for details on how to install a Linux management node. 

[XCAT_pLinux_Clusters]



Note: When the Linux management node is running on a system x server, the perl-IO-Stty needs to be installed on the management node to perform hardware control operations on the the system p service nodes and compute nodes.

## Setup xCAT database on the MN

Since the mixed cluster is actually a hierarchical structure, you will not be able to use the SQlite default database.  You can use MySQL, or Postgresql.  
Use the documentation under "Hierarchy for Large Clusters", to help you setup your database and a Linux Hierarchical Cluster.
[XCAT_Documentation]
MySQL is an easy one to use because it requires almost no code on the clients, which will be your service nodes in xCAT.



## Install an AIX Service Node(s) 

To configure a mixed cluster with Linux management node and AIX compute nodes,  there must be one or more  AIX service node machines to act as the AIX NIM Prime. All the necessary NIM resources will be created on the NIM Prime/Service Node (SN)  and then the AIX service nodes provides the NIM resources to the compute nodes.  In the current release, xCAT 2 only supports the scenario that the NIM Prime and service node is on the same machine.

The AIX NIM Prime SN can be installed through various ways such as  AIX CD/DVD media or NIM.  The SSL and SSH filesets are needed by xCAT, so please make sure the SSL and SSH filesets are installed on the SN. You can refer to the two AIX installp bundle files xCATaixSSL.bnd and xCATaixSSH.bnd , which are shipped with the xCAT image core-aix-<version>.tar.gz file, for the detailed packages list.

If the AIX servicenode is not install with xCAT, then run updatenode <servicenode> -s  to updatenode the /etc/xcatinfo file on the node.

## Define the  AIX Service Node(s) as xCAT nodes 

The following documentation will help to define your nodes and service nodes to xCAT.  There will have to be additional setup for the mixed cluster.


[XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems]
[xCAT_System_p_Hardware_Management_for_DFM_Managed_Systems]

[Setting_Up_an_AIX_Hierarchical_Cluster]


The “xcatdefaults” postscripts in the postscripts table are different on Linux management node and AIX management node.  In particular there are two xCAT scripts remoteshell for Linux and aixremoteshell for AIX. This is fixed in xCAT 2.8 ( you can define only remoteshell and it will take care of both Linux and AIX nodes).   We  are going to add the aixremoteshell script to the postscripts for the AIX nodes.   We are leaving the remoteshell script in for now ( it will fail on AIX).  Future releases of xCAT will merge these two and fix this problem. syncfiles only runs during install so will not actually be run during updatenode, thus having a duplicate will not be an issue.  You use updatenode -F to sync files. 

Prior to xCAT 2.8, Your AIX Service node(s) should be created with these additional options:

~~~~
 chdef <nodename> -p groups=aixservice setupnameserver=no os=AIX
 chtab node=aixservice postscripts.postscripts=aixremoteshell,syncfiles \  
 postscripts.postbootscripts=servicenode
~~~~

The results of lsdef where your nodename is substituted for snode1 below should look something like the following:

~~~~
  lsdef snode1
 Object name: snode1
    cons=hmc
    groups=groups=lpar,all,aixservice
    hcp=ac0131a
    id=10
    mgt=hmc
    nodetype=lpar,osi
    os=AIX
    parent=p1vsp01
    postbootscripts=otherpkgs,servicenode
    postscripts=syslog,'''remoteshell,syncfiles''',aixremoteshell,syncfiles
    profile=Normal
    setupnameserver=no

~~~~

As of xCAT2.8, the remoteshell postscript will call aixremoteshell, if running on an AIX node. You do not need to change the defaults for your AIX node.
So your lsdef of your nodename in xCAT 2.8 or later can look like the following:

~~~~
  lsdef snode1
 Object name: snode1
    cons=hmc
    groups=groups=lpar,all,aixservice
    hcp=ac0131a
    id=10
    mgt=hmc
    nodetype=lpar,osi
    os=AIX
    parent=p1vsp01
    postbootscripts=otherpkgs,servicenode
    postscripts=syslog,remoteshell,syncfiles
    profile=Normal
    setupnameserver=no

~~~~

## Setup the remoteshell from management node to service node(s) 

At this point you need to setup ssh keys on the Service Node.  Note the service node must have a password assigned to root.  You will be prompted for it.

~~~~ 
 xdsh aixservice -K
~~~~



## Set nimprime attribute in the site table 

xCAT site table has an attribute “nimprime” to specify the hostname of the NIM Prime, use the following command to set the nimprime attribute in the site table.

~~~~
 chdef -t site -o clustersite nimprime=<NIM Prime Host Name>
~~~~

Substitute the NIM Prime hostname as appropriate, our example was snode1

When setting the nimprime, you must explicitly your AIX service nodes to point to the site.master as their service nodes

For each AIX servicenode where the ip address below is the value of the site.master attribute. 

~~~~
  chdef -t node <aixservicenode>  servicenode=192.168.5.93 xcatmaster=192.168.5.93
~~~~

## Install xCAT Service Node packages on Service Node(s) 


Various ways can be used to install the xCAT service node packages on the AIX service node(s). Note these are the same as the Management Node packages except you will be installing the xCATSN-2.x.x* package, '''not''' the xCAT-2.x.x* package. For example, you can copy all the xCAT service node packages to the AIX service node(s)  and install these packages by running geninstall/rpm command on the service node(s) separately or by running xdsh command against the service node(s) to install the service node packages on all the service node(s) at same time; the updatenode software maintenance function is another option.

Refer the AIX installp bundle file xCATaixSN2.bnd, which is shipped with the xCAT image core-aix-<version>.tar.gz file, for the detailed service node packages list.


You will need to make sure that the Database rpms and the perl-DBD for the database are installed on the SN for the database you have chosen.   xCAT ships the rpms for both MySQL and PostgreSQL.   For the Service Node using MySQL, you will only need the perl-DBD-mysql*  installed and the /etc/xcat/cfgloc file copied from the Management Node.  For PostgreSQL install the rpms and also copy /etc/xcat/cfgloc to the SN.  No other setup is required on Service Node.  Follow the appropriate xCAT database doc for adding access to the database on the Management Node for each of your service nodes. 

After you have done this, restart the xcatd on the Service Node and run 

~~~~
 lsxcatd -a
~~~~

It should show you are using the correct database.  Run

~~~~
 tabdump site
~~~~

You should get the site table from the MN.

## Setup the AIX Service Node 

At this point, you should be able to created the required SSL credentials and copy the ssh keys to the Service Node by running on the MN:

~~~~
 updatenode aixservice -k -V
~~~~

You can then run all your service node postscripts from the MN:

~~~~
 updatenode aixservice -P
~~~~


To validate the service node setup, log in the service node and run tabdump site to see if it works.  Or run xdsh aixservice "/opt/xcat/sbin/tabdump site" from the MN. 

## Make the AIX images available on the Service Node 

All the NIM resources will be created on the Service Node, so the AIX images must be made available on the SN. The AIX images could be the AIX product media, a directory containing the AIX images,  or the name of an existing NIM lpp_source resource. The full path of the AIX images on the SN will be used by the commands mknimimage and mkdsklsnode.


## Install or diskless boot the AIX compute nodes 

After the AIX images are made available on the SN, all the subsequent steps are exactly the same with the homogeneous AIX cluster. Refer to the following documents for details on how to install or diskless boot the AIX compute nodes.

[XCAT_AIX_Diskless_Nodes]

[XCAT_AIX_RTE_Diskfull_Nodes]

[XCAT_AIX_mksysb_Diskfull_Nodes]