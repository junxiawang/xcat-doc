<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Overview of Cluster Setup Process](#overview-of-cluster-setup-process)
  - [Distro-specific Steps](#distro-specific-steps)
  - [Command Man Pages and Database Attribute Descriptions](#command-man-pages-and-database-attribute-descriptions)
- [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
- [Install xCAT on the Management Node](#install-xcat-on-the-management-node)
- [Configure xCAT](#configure-xcat)
    - [**(Optional)Setup the DHCP interfaces in site table**](#optionalsetup-the-dhcp-interfaces-in-site-table)
- [Discover and Define Your System p Hardware](#discover-and-define-your-system-p-hardware)
- [Setting up a Linux Hierarchical Cluster](#setting-up-a-linux-hierarchical-cluster)
- [Complete the Definition of the Compute Nodes](#complete-the-definition-of-the-compute-nodes)
  - [Define xCAT groups](#define-xcat-groups)
  - [Update the attributes of the node](#update-the-attributes-of-the-node)
    - [**RHEL 7 Notes**](#rhel-7-notes)
  - [Configure conserver](#configure-conserver)
    - [**Update conserver configuration**](#update-conserver-configuration)
    - [**Check rcons**](#check-rcons)
  - [Check hardware control setup to the nodes](#check-hardware-control-setup-to-the-nodes)
  - [Update the mac table with the address of the node(s)](#update-the-mac-table-with-the-address-of-the-nodes)
    - [**Configure DHCP**](#configure-dhcp)
  - [(Optional)Set up customization scripts](#optionalset-up-customization-scripts)
- [Install Stateful Nodes](#install-stateful-nodes)
  - [Begin Installation](#begin-installation)
  - [Use network boot to start the installation](#use-network-boot-to-start-the-installation)
- [Stateless Node Deployment](#stateless-node-deployment)
  - [Use network boot to start the installation for the nodes](#use-network-boot-to-start-the-installation-for-the-nodes)
  - [Check the installation result](#check-the-installation-result)
  - [Remove an image](#remove-an-image)
- [Statelite Node Deployment](#statelite-node-deployment)
- [Advanced features](#advanced-features)
  - [Use the driver update disk:](#use-the-driver-update-disk)
  - [Setup Kdump Service over Ethernet/HFI on diskless Linux (for xCAT 2.6 and higher)](#setup-kdump-service-over-ethernethfi-on-diskless-linux-for-xcat-26-and-higher)
    - [**Generate rootimage for diskless/statelite**](#generate-rootimage-for-disklessstatelite)
    - [The Remaining Steps](#the-remaining-steps)
    - [Additional configuration](#additional-configuration)
- [References](#references)
- [**Appendix A: Migrate your Management Node to a new Service Pack of Linux**](#appendix-a-migrate-your-management-node-to-a-new-service-pack-of-linux)
- [**Appendix B: Install your Management Node to a new Release of Linux**](#appendix-b-install-your-management-node-to-a-new-release-of-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**Note: if you are using P775 hardware, do not use this document.**  Use: [XCAT_pLinux_Clusters_775].


## Introduction

This cookbook provides instructions on how to use xCAT to create and deploy a Linux cluster on IBM power system machines.
**Note: if you are using P775 hardware, do not use this document.**  Use: [XCAT_pLinux_Clusters_775].



The power system machines have the following characteristics:

  * May have multiple LPARs (an LPAR will be the target machine to install an operating system image on, i.e. the LPAR will be the compute node).
  * The Ethernet card and SCSI disk can be virtual devices.
  * An HMC or xCAT DFM (Direct FSP/BPA Management) is used for the HCP (hardware control point) to control them.

xCAT supports three types of installations for compute nodes: Diskfull installation (Statefull), Diskless Stateless, and [Diskless Statelite](XCAT_Linux_Statelite). xCAT also supports hierarchical clusters where one or more service nodes are used to handle the installation and management of compute nodes. (Instructions and references will be given later in this document for setting up a hierarchical cluster.)

This document will guide you through installing xCAT on your management node, configuring your cluster, deploying a Linux operating system to your compute nodes, and optionally upgrading firmware on your power system hardware.




### Overview of Cluster Setup Process

Here is a summary of the steps required to set up the cluster and what this document will take you through:

  1. Prepare the management node - doing these things before installing the xCAT software helps the process to go more smoothly.
  2. Install the xCAT software on the management node.
  3. Configure some cluster wide information
  4. Define a little bit of information in the xCAT database about the ethernet switches and nodes - this is necessary to direct the node discovery process.
  5. Have xCAT configure and start several network daemons - this is necessary for both node discovery and node installation.
  6. Discovery the nodes - during this phase, xCAT configures the FSP's and collects many attributes about each node and stores them in the database.
  7. Set up the OS images and install the nodes.

### Distro-specific Steps

  * \[RH\] indicates that step only needs to be done for RHEL and Red Hat based distros (CentOS, Scientific Linux, and in most cases Fedora).
  * \[SLES\] indicates that step only needs to be done for SLES.

### Command Man Pages and Database Attribute Descriptions

  * All of the commands used in this document are described in the [xCAT man pages](http://xcat.sourceforge.net/man1/xcat.1.html).
  * All of the database attributes referred to in this document are described in the [xCAT database object and table descriptions](http://xcat.sourceforge.net/man5/xcatdb.5.html).

## Prepare the Management Node for xCAT Installation

[Prepare_the_Management_Node_for_xCAT_Installation](Prepare_the_Management_Node_for_xCAT_Installation)

## Install xCAT on the Management Node

[Install_xCAT_on_the_Management_Node](Install_xCAT_on_the_Management_Node)

## Configure xCAT

[Configuring_xCAT](Configuring_xCAT)

#### **(Optional)Setup the DHCP interfaces in site table**

To set up the site table dhcp interfaces for your system p cluster, identify the correct interfaces that xCAT should listen to on your management node and service nodes:

~~~~
     chdef -t site dhcpinterfaces='pmanagenode|eth1;service|eth0'
     makedhcp -n
     service dhcpd restart
~~~~



## Discover and Define Your System p Hardware

The next steps are to discover your hardware on the nextwork, defined it in the xCAT database, configure xCAT's hardware control, and do the initial definition of the LPARs as the compute nodes. These steps are explained in the following 2 documents. Use the one that applies to your environment:

  * For DFM managed system p cluster, use [XCAT System p Hardware Management for HMC Managed Systems](XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems)
  * For HMC managed system p cluster, use [xCAT System p Hardware Management for DFM Managed Systems](xCAT_System_p_Hardware_Management_for_DFM_Managed_Systems)

After performing the steps in one of those documents, return here and continue on in this document.


## Setting up a Linux Hierarchical Cluster

For large clusters, you can distribute most of the xCAT services from the management node to xCAT service nodes. Doing so, creates a "hierarchical cluster". The following document describes additional xCAT management node configuration for a Linux Hierarchical Cluster, how to install your service nodes, and how to configure your compute nodes to be managed by service nodes.

[Setting_Up_a_Linux_Hierarchical_Cluster]


Setting up a hierarchical cluster assumes more advanced knowledge of xCAT node definition, deployment, and management. If this is your first time setting up an xCAT cluster, you should skip this step for now and experiment with a simple cluster managed directly from your xCAT management node to become familiar with all the different concepts and processes.

## Complete the Definition of the Compute Nodes

The hardware management documents explained how to get the LPARs of the CECs defined as nodes in the xCAT database. Before deploying an OS on the nodes, you must set some additional attributes of the nodes.

### Define xCAT groups

See the following [Node Group Support](Node_Group_Support),for more details on how to define xCAT groups. For the example below add the compute group to the nodes.

~~~~
    chdef -t node -o pnode1,pnode2 -p groups=compute
~~~~


### Update the attributes of the node

~~~~
    chdef -t node -o pnode1 netboot=yaboot tftpserver=192.168.0.1 nfsserver=192.168.0.1
    monserver=192.168.0.1 xcatmaster=192.168.0.1 installnic=mac primarynic=mac
~~~~

**Note:**

*Make sure the attributes "installnic" and "primarynic" are set up by the correct Ethernet or HFI Interface of compute node. Otherwise the compute node installation may hang on requesting information from an incorrect interface. The "installnic" and "primarynic" can also be set to mac address if you are not sure about the Ethernet interface name, the mac address can be got through getmacs command. The installnic" and "primarynic" can also be set to keyword "mac", which means that the network interface specified by the mac address in the mac table will be used.

*Make sure that the address used above ( 192.168.0.1) is the address of the Management Node as known by the node. Also make sure site.master has this address.

*Make sure the attributes "netboot" is set correctly according to the OS and hardware platform:

~~~~

"pxe" or "xnba": for X86* platform;
"yaboot": for IBM Power platform;
"grub2-tftp" or "grub2-http": for IBM Power LE platform, Redhat7.x and newer Redhat family on Power BE platform. The difference between the 2 is the file transfer protocol of grub2 to fetch the os kernel and initrd;
"grub2": same as "grub2-tftp" to keep backward compatibility.

~~~~

#### **RHEL 7 Notes** ####

*If you are using RHEL7, "yaboot" is deprecated, the netboot method for system P must be set to "grub2". 

~~~~
    chdef -t node -o pnode1 netboot=grub2
~~~~

*Redhat 7 provides methods for consistent and predictable network device naming for network interfaces. These features change the name of network interfaces from traditional "eth[0...9]" to predictable network device names, see[CONSISTENT NETWORK DEVICE NAMING](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/ch-Consistent_Network_Device_Naming.html). In case you need to preserve the "ethX" naming scheme, please specify the option "net.ifnames=0" in "addkcmdline" attribute of node or osimage to prevent the consistent network device renaming.

~~~~
    chdef -t node -o pnode1 -p addkcmdline=net.ifnames=0
~~~~


### Configure conserver

The xCAT rcons command uses the conserver package to provide support for multiple read-only consoles on a single node and the console logging. For example, if a user has a read-write console session open on node node1, other users could also log in to that console session on node1 as read-only users. This allows sharing a console server session between multiple users for diagnostic or other collaborative purposes. The console logging function will log the console output and activities for any node with remote console attributes set to the following file which an be replayed for debugging or any other purposes:

~~~~
    /var/log/consoles/<node_name>
~~~~


Note: /var/log/consoles/<node_name> is the default console logging file, could be changed through updating the "logfile" attribute in /etc/conserver.cf

#### **Update conserver configuration**

Each xCAT node with remote console attributes set should be added into the conserver configuration file to make the rcons work. The xCAT command **makeconservercf** will put all the nodes into conserver configuration file /etc/conserver.cf. The makeconservercf command must be run when there is any node definition changes that will affect the conserver, such as adding new nodes, removing nodes or changing the nodes' remote console settings.

To add or remove new nodes for conserver support:

~~~~
    makeconservercf
    service conserver stop
    service conserver start
~~~~


#### **Check rcons** #####

The functions rnetboot and getmacs depend on conserver functions, check it is available.

~~~~
    rcons pnode1
~~~~


If it works ok, you will get into the console interface of the pnode1. If it does not work, review your rcons setup as documented in previous steps.


### Check hardware control setup to the nodes

See if you setup is correct at this point, run rpower to check node status:

~~~~
    rpower pnode1 stat
~~~~


### Update the mac table with the address of the node(s)

**Before run getmacs, make sure the node is off.** The reason is the HMC may not be able to shutdown linux nodes which are in running state.

You can force the lpar shutdown with:

~~~~
    rpower pnode1 off
~~~~

Run the getmacs command with -D flag to get the mac address of the system p node:

~~~~
    getmacs -D pnode1 
~~~~

The getmacs -D command will reboot the nodes to openfirmware console and input openfirmware commands to list the network adapters, and then use the ping test to try which network adapter is connected to the management node. This is a time consuming process and does not handle the scalability configuration well, if the system p nodes are managed through DFM and the nodes only have virtual network adapters(LHEA and SEA), use getmacs command without -D will make the process be much quicker, but the only problem is that getmacs will not be able to know which network adapter could be used to connect to the management node.

~~~~
    getmacs pnode1
~~~~


The output looks like following:

~~~~
    pnode1:
    Type Location Code MAC Address Full Path Name Ping Result Device Type
    ent U9133.55A.10E093F-V4-C5-T1 f2:60:f0:00:40:05 /vdevice/l-lan@30000005 virtual
~~~~


And the Mac address will be written into the xCAT mac table. Run to verify:

~~~~
    tabdump mac
~~~~


#### **Configure DHCP**

Add the defined nodes into the DHCP configuration:

~~~~
     makedhcp pnode1
~~~~


Restart the dhcp service:

~~~~
     service dhcpd restart
~~~~


### (Optional)Set up customization scripts

xCAT supports the running of customization scripts on the nodes when they are installed. You can see what scripts xCAT will run by default by looking at the xcatdefaults entry in the xCAT postscripts table. The postscripts attribute of the node definition can be used to specify the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run.

To check current postscript and postbootscripts setting:

~~~~
    tabdump postscripts
~~~~


For example, if you want to have your two scripts called foo and bar run on node node01 you could add them to the postscripts table:

    chdef -t node -o node01 -p postscripts=foo,bar


For more information on creating and setting up customization scripts: [Postscripts_and_Prescripts]

## Install Stateful Nodes

[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes)

### Begin Installation


    nodeset compute osimage=mycomputeimage


Now boot your nodes... 


### Use network boot to start the installation

~~~~
    rnetboot compute
~~~~

The rnetboot is a time consuming process and does not handle the scalability configuration well, if the system p nodes are managed through DFM, the commands rbootseq and rpower will make the process be much more effective:

~~~~
    rbootseq compute net 
    rpower compute reset

~~~~

[Monitor_Installation](Monitor_Installation)

[Install_Additional_Packages](Install_Additional_Packages)

[Install_OS_Updates](Install_OS_Updates)


## Stateless Node Deployment

The following section (and its subsections) is the standard xCAT procedure for building and deploying a linux stateless image. Some of the example commands refer to the x86_64 architecture, but the procedure is the same on ppc64. Just replace x86_64 with ppc64. Also, when it comes time to boot the nodes, use rnetboot instead of rpower.


[Using_Provmethod=osimagename](Using_Provmethod=osimagename)




### Use network boot to start the installation for the nodes

~~~~
    rnetboot compute
~~~~

When the statelss node is and up and running, the xCAT postscripts will set the node to boot from network, so you could use **rpower compute reset** for the subsequent stateless bootups.

The rnetboot is a time consuming process and does not handle the scalability configuration well, if the system p nodes are managed through DFM, the commands rbootseq and rpower will make the process be much more effective:

~~~~
    rbootseq compute net 
    rpower compute reset

~~~~


### Check the installation result

After the node installation is completed successfully, the node's status will be changed to **booted**, the following command to check the node's status:

~~~~
    lsdef compute -i status
~~~~



When the node's status is changed to **booted**, you can also check ssh service on the node is working and you can login without password.

Note: Do not run ssh or xdsh against the node until the node installation is completed successfully. Running ssh or xdsh against the node before the node installation completed may result in ssh hostkeys issues.


If ssh is working but cannot login without password, setup the ssh key to the compute node using xdsh:

~~~~
    xdsh compute -K
~~~~



After exchanging ssh key, following command should work.

~~~~
    xdsh compute date
~~~~


### Remove an image

If you want to remove an image, rmimage is used to remove the Linux stateless or statelite image from the file system. It is better to use this command than just remove the filesystem yourself, because it also remove appropriate links to real files system that may be distroyed on your Management Node, if you just use the rm -rf command.


You can specify the &lt;os&gt;, &lt;arch&gt; and &lt;profile&gt; value to the rmimagecommand:

~~~~
    rmimage -o <os> -a <arch> -p <profile>
~~~~


Or, you can specify one imagename to the command:

~~~~
    rmimage <imagename>
~~~~


## Statelite Node Deployment

Statelite is an xCAT feature which allows you to have mostly stateless nodes (for ease of management), but tell xCAT that just a little bit of state should be kept in a few specific files or directories that are persistent for each node. If you would like to use this feature, refer to the [XCAT_Linux_Statelite] documentation.

## Advanced features

### Use the driver update disk:

Refer to [Using_Linux_Driver_Update_Disk].

### Setup Kdump Service over Ethernet/HFI on diskless Linux (for xCAT 2.6 and higher)

Follow [Kdump over Ethernet or HFI for Linux diskless nodes] to define the diskless image object.

#### **Generate rootimage for diskless/statelite**


Follow [XCAT_pLinux_Clusters#Stateless_node_deployment](XCAT_pLinux_Clusters/#stateless-node-deployment) to generate the diskless rootimg . Follow [XCAT_Linux_Statelite](XCAT_Linux_Statelite) to generate the statelite image.

#### The Remaining Steps

Follow the documents including [[xCAT_pLinux_Clusters](http://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_pLinux_Clusters)] and [[xCAT_Linux_Statelite](http://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_Linux_Statelite)] to setup the diskless/statelite image, and to make the specified noderange booting with the diskless/statelite image.

#### Additional configuration

After noderange booted up with the diskless/statelite image, add a dynamic ip range into networks table to the network used for compute node installation. This dynamic ip range should be large enough accommodate all of the nodes on the network. For example:

~~~~
     #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,ddnsdomain,vlanid,comments,disable
     "hfinet","20.0.0.0","255.0.0.0","hf0","20.7.4.1","20.7.4.1","20.7.4.1","20.7.4.1",,,"20.7.4.100-20.7.4.200",,,,,
~~~~


## References

  * [xCAT web site](http://xcat.sf.net/)
  * [xCAT man pages](http://xcat.sf.net/man1/xcat.1.html)
  * [xCAT DB table descriptions](http://xcat.sf.net/man5/xcatdb.5.html)
  * [Monitoring Your Cluster with xCAT](Monitoring_an_xCAT_Cluster)
  * [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]
  * [xCAT wiki](http://xcat.wiki.sourceforge.net/)
  * [xCAT mailing list](http://xcat.org/mailman/listinfo/xcat-user)
  * [xCAT bugs](https://sourceforge.net/tracker/?group_id=208749&atid=1006945)
  * [xCAT feature requests](https://sourceforge.net/tracker/?group_id=208749&atid=1006948)

## **Appendix A: Migrate your Management Node to a new Service Pack of Linux**

If you need to migrate your xCAT Management Node with a new SP level of Linux, for example rhels6.1 to rhels6.2 you should as a precautionary measure:

  * Backup database and save critical files to be used if needed to reference or restore using xcatsnap. Move the xcatsnap log and *gz file off the Management Node.
  * Backup images and custom data in /install and move off the Management Node.
  * service xcatd stop
  * service xcatd stop on any service nodes
  * Migrate to the new SP level of Linux.
  * service xcatd start

If you have any Service Nodes:

  * Migrate to the new SP level of linux and reinstall the servicenode with xCAT following normal procedures.
  * service xcatd start


The document:

[Setting_Up_a_Linux_xCAT_Mgmt_Node#Appendix_D:_Upgrade_your_Management_Node_to_a_new_Service_Pack_of_Linux](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux)
gives a sample procedure on how to update the management node or service nodes to a new service pack of Linux.

## **Appendix B: Install your Management Node to a new Release of Linux**

First backup critical xCAT data to another server so it will not be loss during OS install.

  * Back up the xcat database using xcatsnap, important config files and other system config files for reference and for restore later. Prune some of the larger tables:

~~~~
   tabprune eventlog -a
   tabprune auditlog -a
~~~~

  * Run xcatsnap ( will capture database, config files) and copy to another host. By default it will create in /tmp/xcatsnap two files, for example:

~~~~
    xcatsnap
~~~~   

produces:

~~~~
    /tmp/xcatsnap.hpcrhmn.10110922.log
    /tmp/xcatsnap.hpcrhmn.10110922.tar.gz
~~~~

  * Back up from /install directory, all images, custom setup data that you want to save. and move to another server. xcatsnap will not backup images.

After the OS install:

  * Proceed to to setup the xCAT MN as a new xCAT MN using the instructions in this document.


