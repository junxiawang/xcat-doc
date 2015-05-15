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
- [Discover and Define Your System p 775 Hardware](#discover-and-define-your-system-p-775-hardware)
- [Additional Management Node (EMS) setup](#additional-management-node-ems-setup)
  - [Downloading and Installing DFM and hdwr_svr](#downloading-and-installing-dfm-and-hdwr_svr)
  - [Obtain additional packages for HFI network](#obtain-additional-packages-for-hfi-network)
  - [Install LoadLeveler](#install-loadleveler)
  - [**Install Teal**](#install-teal)
  - [**Install ISNM**](#install-isnm)
    - [**Install ISNM prerequisite software**](#install-isnm-prerequisite-software)
  - [Discover and define hardware components](#discover-and-define-hardware-components)
  - [Install and Configure ISNM](#install-and-configure-isnm)
    - [**Check the hardware component and site definitions.**](#check-the-hardware-component-and-site-definitions)
    - [**Hardware server connections**](#hardware-server-connections)
    - [** Start CNMD and setup Master ISR ID&nbsp;:**](#-start-cnmd-and-setup-master-isr-id&nbsp)
  - [Configure DFM Hierarchically (Optional)](#configure-dfm-hierarchically-optional)
- [Setup the xCAT MN for a Hierarchical Cluster](#setup-the-xcat-mn-for-a-hierarchical-cluster)
- [Complete the Definition of the Compute Nodes](#complete-the-definition-of-the-compute-nodes)
  - [Define xCAT groups](#define-xcat-groups)
  - [Update the attributes of the node](#update-the-attributes-of-the-node)
    - [Check the site.master value](#check-the-sitemaster-value)
    - [Set the type attributes of the node](#set-the-type-attributes-of-the-node)
  - [Configure conserver](#configure-conserver)
    - [**Update conserver configuration**](#update-conserver-configuration)
  - [Check rcons(rnetboot and getmacs depend on it)](#check-rconsrnetboot-and-getmacs-depend-on-it)
  - [Check hardware control setup to the nodes](#check-hardware-control-setup-to-the-nodes)
  - [Update the mac table with the address of the node(s)](#update-the-mac-table-with-the-address-of-the-nodes)
  - [Update the mac table with the address of the node(s) for Power 775](#update-the-mac-table-with-the-address-of-the-nodes-for-power-775)
    - [**Configure DHCP**](#configure-dhcp)
  - [Set up customization scripts (optional)](#set-up-customization-scripts-optional)
- [Install Stateful Nodes](#install-stateful-nodes)
  - [Begin Installation](#begin-installation)
  - [Use network boot to start the installation](#use-network-boot-to-start-the-installation)
  - [Alternative network boot in Power 775](#alternative-network-boot-in-power-775)
- [Stateless Node Deployment](#stateless-node-deployment)
  - [Use network boot to start the installation for p775 nodes](#use-network-boot-to-start-the-installation-for-p775-nodes)
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

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

This cookbook provides instructions on how to use xCAT to create and deploy a Linux cluster on IBM power 775 system machines.  For other power hardware use [XCAT_pLinux_Clusters].

The power system machines have the following characteristics:

  * May have multiple LPARs (an LPAR will be the target machine to install an operating system image on, i.e. the LPAR will be the compute node).
  * The Ethernet card and SCSI disk can be virtual devices.
  * An HMC or xCAT DFM (Direct FSP/BPA Management) is used for the HCP (hardware control point) to control them.

xCAT supports three types of installations for compute nodes: Diskfull installation (Statefull), Diskless Stateless, and [Diskless Statelite](XCAT_Linux_Statelite). xCAT also supports hierarchical clusters where one or more service nodes are used to handle the installation and management of compute nodes. (Instructions and references will be given later in this document for setting up a hierarchical cluster.)

This document will guide you through installing xCAT on your management node, configuring your cluster, deploying a Linux operating system to your compute nodes, and optionally upgrading firmware on your power system hardware.




### Overview of Cluster Setup Process

Here is a summary of the steps required to set up the cluster and what this document will take you through:

  1. Prepare the management node - doing these things before installing the xCAT software helps the process to go more smoothly.
  2. Install the xCAT software on the management node (EMS).
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



~~~~
     chdef -t site dhcpinterfaces='pmanagenode|eth1;service|hf0'
     makedhcp -n
     service dhcpd restart
~~~~

## Discover and Define Your System p 775 Hardware

The next steps are to discover your hardware on the nextwork, defined it in the xCAT database, configure xCAT's hardware control, and do the initial definition of the LPARs as the compute nodes. These steps are explained in the following document :

  *  [XCAT_Power_775_Hardware_Management]
 

After performing those steps  return here and continue on in this document.

## Additional Management Node (EMS) setup


The xCAT Management Node must be configured and running on the DB2 database on P775,  before installing the following cluster hardware components.

This section describes the additional setup required for the Power 775 support. This includes the setup of the cluster hardware components and the installation of TEAL, ISNM, and LoadLeveler on the xCAT management node. TEAL, ISNM and LoadLeveler have dependencies on each other so all three must be installed.

### Downloading and Installing DFM and hdwr_svr

Refer to the following documentation for downloading and installing DFM and hdwr_svr in an HPC cluster: [Downloading and Installing DFM](https://sourceforge.net/apps/wiki/xcat/index.php?title=XCAT_Power_775_Hardware_Management#Downloading_and_Installing_DFM)

### Obtain additional packages for HFI network

To work with HFI network in Power 775 clusters, the following RPMs and scripts must be obtained from IBM and put on the xCAT MN in the suggested directories. These packages and files should exist as part of the IBM LTC RH6 customized kernel:

    /hfi/dd/kernel-2.6.32-*.ppc64.rpm
    /hfi/dd/kernel-headers-2.6.32-*.ppc64.rpm
    /hfi/dd/hfi_util-*.el6.ppc64.rpm
    /hfi/dd/hfi_ndai-*.el6.ppc64.rpm


    /hfi/dhcp/net-tools-*.el6.ppc64.rpm
    /hfi/dhcp/dhcp-*.el6.ppc64.rpm
    /hfi/dhcp/dhclient-*.el6.ppc64.rpm


### Install LoadLeveler

Refer to the following documentation for setting up LL in an HPC cluster:

  * [Setting_up_LoadLeveler_in_a_Stateful_Cluster]
  * [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster]

### **Install Teal**

Download the Teal prerequisite rpm packages and the Teal product rpms to your xCAT management. The Teal packages should be available from Teal website: http://sourceforge.net/projects/pyteal/files/ The Teal product does have prerequisites on the LoadL resource manager. Place the packages in a directory such as:

    /install/post/otherpkgs/rhels6/ppc64/teal


The Teal prerequisites are:

     gdbm-1.8.3-5
     readline-4.3-2
     python-2.6.2-2
     perl-Module-Load-0.16-115
     pyodbc-2.1.7-1   ***  this is in the latest xCAT deps package


Other than pyodbc, these rpms were most likely installed with your base RedHat installation. If these rpms are not installed, run a command similar to the following to install:

     yum install gdbm.ppc64 readline.ppc64 python.ppc64 perl-Module-Load.ppc64


The Teal rpms for the xCAT EMS are:

    teal-base-1.1.0.0-1.ppc64.rpm -used with base Teal support
    teal-ll-1.1.0.0-1.ppc64.rpm -used with LL teal
    teal-sfp-1.1.0.0-1.ppc64.rpm -used with HMC Service focal point
    teal-isnm-1.1.0.0-1.ppc64.rpm -used with isnm Teal
    teal-pnsd-1.1.0.0-1.ppc64.rpm -used with PE  pnsd teal


There are other Teal rpms for GPFS that will be required on the Power 775 cluster. GPFS is not required on the EMS, but will be required on GPFS I/O server nodes The teal-gpfs-sn-1.1.0.0-1 rpms has dependencies for gpfs.base and libmmantras.so.

    teal-gpfs-1.1.0.0-1.ppc64.rpm     -used with base GPFS
    teal-gpfs-sn-1.1.0.0-1.ppc64.rpm  -used with GPFS server nodes


To install:

~~~~
     yum install pyodbc
     cd /install/post/otherpkgs/<os>/<arch>/teal
     rpm -Uvh ./teal*.rpm
~~~~

The teal executables are located in /opt/teal/bin directory on the EMS. For more information on Teal please refer to the Teal documentation. (Need to add pointer when available)

Teal tables should viewed using tllsalert and tllsevent commands, or xCAT database commands (e.g. tabedit, tabdump).

For full list of teal commands: https://sourceforge.net/apps/mediawiki/pyteal/index.php?title=Command_Reference

If there are changes to be made for Teal tables, they should be made only using the following teal commands:

    tlchalert : close an alert that has been resolved.  It will also close all duplicate alerts that have been reported.
    tlrmalert : remove select/all alerts that have been closed that are not associated with other alerts.
    tlrmevent : remove select/all events that are not associated with an alert that is still being saved in the alert log.


Typically a user will do these steps to manage Teal alerts and maintain the Teal tables:

    Resolve the active/open alerts and then remove them with tlchalert
~~~~
    tlrmalert --older-than <timestamp> to remove the alerts that are no longer required
    tlrmevent --older-than <timestamp> to remove the events that are no longer required
~~~~

### **Install ISNM**

Download the ISNM packages to the xCAT MN and place them in a directory such as

~~~~

    /install/post/otherpkgs/<os>/ppc64/isnm
~~~~

#### **Install ISNM prerequisite software**

  * Install RSCT

     rpm .ivh rsct.core.utils-3.1.0.2-10266.ppc.rpm rsct.core-3.1.0.2-10266.ppc.rpm  src-1.3.1.1-10266.ppc.rpm


Obtain RSCT from: https://www14.software.ibm.com/webapp/iwm/web/preLogin.do?lang=en_US&amp;source=stg-rmc


There is one hdwr_svr lib that is not in the package that must be manually placed in /usr/lib on the Managment Node. ( This will be fixed soon). Right now the lib is in the following backing tree:

    /project/spreldenali/build/rdenali1107b/export/ppc64_redhat_6.0.0/usr/lib/libnetchmcx.so
    cp -p libnetchmcx.so /usr/lib


### Discover and define hardware components

The System P hardware components must be discovered, configured and defined in the xCAT database. If you haven't done so already, follow the steps in [XCAT_Power_775_Hardware_Management].

### Install and Configure ISNM

Install the ISNM package:

~~~~
    cd /install/post/otherpkgs/<os>/<arch>/isnm
    rpm -Uvh ./ISNM-cnm*.rpm
~~~~

Note: you should have already installed the hardware server ISNM-hdwr_svr*.rpm as part of xCAT's DFM.

    **NOTE**
    There should be pointer to the ISNM documentation in the High Performance Clustering
    using 9125-F2C  that describes   HFI-ISR network for Power 775  cluster.
    This would be a good place to describe how the HFI is being used with xCAT.
    We can provide a pointer where the admin should locate the HFI device drivers.
    If you are only trying to communicate over hfi from one octant to another in the same CEC,
    the CNM daemon must be running on the EMS.  and the master ISR ID must be loaded to the CEC.
    If you are communicating over the HFI from one CEC to another, the HFI cable links
    (Dlinks and/or LR links) must be physically configured between the Power 775 CECs.



#### **Check the hardware component and site definitions.**

The CNM HFI network requires that the Power 775 frame and cecs be physically installed and properly defined in the xCAT DataBase. This activity should have already been accomplished following the xCAT Power 775 Hardware Management guide. The CNM HFI network requires the following additional data to be defined in the xCAT DB.

Check that the correct Topology has been set in the site table. The topology definition is based on the the number of CECs and type of HFI network configured for your Power 775 cluster.

     lsdef -t site -i topology   (should be one of supported configs 8D, 32D, 128D)
     If there is no topology value found you can set the value with xCAT chdef command
     chdef -t site  topology=32D


Check to make sure that the frame and the CECs node objects have the proper definitions. The frame must be connected to the EMS with DFM, and the frame number is assigned in the "id" attribute. The lsdef frame lists all the frame objects in your cluster, check that each frame has the frame number defined id=&lt;frame #&gt; . If the frame number is not correct, you should execute xCAT command "rspconfig" to set the frame number. The command below will set "id" to 17 for frame17 node, and will update frame number to 17 in the BPA .

     lsdef  frame -i id  (check id attribute to see frame id number assigned for each frame object&gt;
     rspconfig frame17 frame=17
     Note: To change a frame id number with rspconfig, the P775 cecs must be powered off. This activity will take a few minutes
           to complete, and the bpa's will lose HW connections since the BPS'a need to be rebooted to change the configuration.



Check to make sure that the Power 775 cluster has the proper node attributes defined in the xCAT DB.

     lpars/octants - nodes should have hwtype=lpar, hcp and parent has the proper CEC node assigned.
     fsp nodes - should have hwtype=fsp, hcp is set to itself, and parent has proper CEC node assigned.
     cec nodes - should have hwtype=cec, hcp is set to itself, and parent has the proper Frame node assigned.
     bpa nodes - should have hwtype=bpa, hcp is set to itself, and parent has the proper Frame node assigned.
     frame nodes - should have hwtype=frame, hcp is set to itself, and parent is blank or will have a building block number


Check to make sure that the cec node objects have the proper "supernode" attribute defined. The supernode will specify the HFI configuration being used by the cec. You should also make sure the cage id is properly defined where the "id" attribute matches the cage position for the CEC node. The CNM daemon and configuration commands will setup the Master ISR identifier for each cec. This will allow the HFI communications to work between the Power 775 cluster.

     lsdef  cec -i id,supernode  (check that supernode and id attributes are correct for each cec object)
     chdef  f17c01  supernode=0,0   (will set HFI supernode setting)


#### **Hardware server connections**

The CNM hardware server daemon will be started as part of the Power 775 Hardware setup working with DFM. The hardware server daemon is used by both xCAT and CNM to track the hardware connections between the xCAT EMS and the Frame/BPA and CEC/FSPs. There are two different connections "tooltype" used with the hardware server daemon and the xCAT mkhwconn command. The tooltype "lpar' is used by the xCAT DFM support, and the tooltype "fnm" is used by the CNM support.

    mkhwconn frame17 -t -T fnm   (will make the HW connection for the frame17  frame and cecs (drawers))
    mkhwconn cec -t -T fnm


The hardware server daemon works with the /var/opt/isnm/hdwr_svr/data/HmcNetConfig file. The expectation is that HmcNetConfig file will get created as part of the first mkhwconn execution working with xCAT DFM . The CNM will add additional connections for the "fnm" HW connections.

There are hardware server log files that are created and saved under /var/opt/isnm/hdwr_svr/log directory. If you have issues with hardware server daemon, you may want to check the recent "hdwr_svr.log.*" log files. If you need to take a hardware server daemon dump, you can execute "kill -USR1 &lt;hdwr_svr.pid&gt; (this will create the hdwr_svr dump file)

#### ** Start CNMD and setup Master ISR ID&nbsp;:**

Once all the xCAT definitions are properly updated with CNM configuration data, It is time to start up the CNM daemon and load ounthe proper ISR data in the CECs. Make sure that all the CECs have been powered off prior to the initialization of the CNM daemon. This is necessary to setup the proper HFI configuration data in the Frame and CECs. You can execute the CNM command "chnwm" to activate or deactivate the CNM daemon for AIX EMS

    /opt/isnm/cnm/bin/chnwm -d  (take down the CNM daemon)
    rpower cec  off             (power down all cecs)
    /opt/isnm/cnm/bin/chnwm -a   (activate the CNM daemon)


You can execute the Linux "service" command to activate or deactivite the CNM daemon for Linux EMS.

    service cnmd stop     (take down the CNM daemon)
    rpower cec off        (power down all cecs)
    service cnmd  start   (activate the CNM daemon)


You can now load the HFI master ISR identifier on the Power 775 frame and cecs. This will be accomplished using the ISNM command "chnwsvrconfig". You will need to specify this command for your frame/cecs in you P775 cluster.

    /opt/isnm/cnm/bin/chnwsvrconfig  -A   (will configure all associated P775 Frames/cecs with HFI data)
    /opt/isnm/cnm/bin/chnwsvrconfig  -f 17 -c 3   (will configure one cec in P775 frame 17 with cage id 3)


You can now verify that the CNM daemon and HFI configuration is working by executing the CNM command "nmcmd" to dump the drawer status information. This will list the current state of the drawers working with CNM. Please reference the HPC using the 9125-F2C guide for more detail about CNM commands, implementation, and debug.

     /opt/isnm/cnm/bin/nmcmd -D -D
     # nmcmd -D -D
     Frame 17  Cage 3 Supernode 0 Drawer 0 STANDBY
     Frame 17  Cage 5 Supernode 0 Drawer 2 STANDBY
     Frame 17  Cage 4 Supernode 0 Drawer 1 STANDBY


### Configure DFM Hierarchically (Optional)

Depending on how large your cluster is, you may find that DFM performs better if the operations are sent to the FSPs via the service nodes. See [Overview of Using DFM Hierarchically](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_Power_775_Hardware_Management#Overview_of_Using_DFM_Hierarchically) to get an overview of how to use DFM Hierarchically.

## Setup the xCAT MN for a Hierarchical Cluster

For large clusters, you can distribute most of the xCAT services from the management node to xCAT service nodes. Doing so, creates a "hierarchical cluster". The following document describes additional xCAT management node configuration for a Linux Hierarchical Cluster, how to install your service nodes, and how to configure your compute nodes to be managed by service nodes.

[Setting_Up_a_Linux_Hierarchical_Cluster]

Note: Hierarchical Clusters are required for Power 775 clusters in order to deploy and manage compute nodes across the HFI network. In addition to setting up xCAT cluster hierarchy, the above document also contains important instructions specific to configuring and managing your Power 775 cluster.

Setting up a hierarchical cluster assumes more advanced knowledge of xCAT node definition, deployment, and management. If this is your first time setting up an xCAT cluster, you should skip this step for now and experiment with a simple cluster managed directly from your xCAT management node to become familiar with all the different concepts and processes.

## Complete the Definition of the Compute Nodes

The hardware management documents explained how to get the LPARs of the CECs defined as nodes in the xCAT database. Before deploying an OS on the nodes, you must set some additional attributes of the nodes.

### Define xCAT groups

See the following [Node_Group_Support],for more details on how to define xCAT groups. For the example below add the compute group to the nodes.

    chdef -t node -o pnode1,pnode2 -p groups=compute


### Update the attributes of the node

    chdef -t node -o pnode1 netboot=yaboot tftpserver=192.168.0.1 nfsserver=192.168.0.1
    monserver=192.168.0.1 xcatmaster=192.168.0.1 installnic="eth0" primarynic="eth0"



**Note: Make sure the attributes "installnic" and "primarynic" are set up by the correct Ethernet or HFI Interface of compute node. Otherwise the compute node installation may hang on requesting information from an incorrect interface. The "installnic" and "primarynic" can also be set to mac address if you are not sure about the Ethernet interface name, the mac address can be got through getmacs command. The installnic" and "primarynic" can also be set to keyword "mac", which means that the network interface specified by the mac address in the mac table will be used.**

**Make sure that the address used above ( 192.168.0.1) is the address of the Management Node as known by the node. Also make sure site.master has this address.**


**If you are using redhat 7 (RHEL7), "yaboot" is deprecated, the netboot method for system P is must be  "grub2"**Make sure that the address used above ( 192.168.0.1) is the address of the Management Node as known by the node. Also make sure site.master has this address.**
. So, set "netboot" attribute to "grub2" to provision Redhat 7 on ppc64 node.**

#### Check the site.master value

Make sure site.master is the address or name known by the node


To change site.master to this address:




    chdef -t site -o clustersite master="192.168.0.1"


#### Set the type attributes of the node

~~~~
    chdef -t node -o pnode1 os=<os> arch=ppc64 profile=compute
~~~~

For valid options:

     tabdump -d nodetype


### Configure conserver

The xCAT rcons command uses the conserver package to provide support for multiple read-only consoles on a single node and the console logging. For example, if a user has a read-write console session open on node node1, other users could also log in to that console session on node1 as read-only users. This allows sharing a console server session between multiple users for diagnostic or other collaborative purposes. The console logging function will log the console output and activities for any node with remote console attributes set to the following file which an be replayed for debugging or any other purposes:

~~~~
    /var/log/consoles/<management node>
~~~~


Note: conserver=&lt;management node&gt; is the default, so it optional in the command

#### **Update conserver configuration**

Each xCAT node with remote console attributes set should be added into the conserver configuration file to make the rcons work. The xCAT command **makeconservercf** will put all the nodes into conserver configuration file /etc/conserver.cf. The makeconservercf command must be run when there is any node definition changes that will affect the conserver, such as adding new nodes, removing nodes or changing the nodes' remote console settings.

To add or remove new nodes for conserver support:

    makeconservercf
    service conserver stop
    service conserver start


### Check rcons(rnetboot and getmacs depend on it)

The functions rnetboot and getmacs depend on conserver functions, check it is available.

    rcons pnode1


If it works ok, you will get into the console interface of the pnode1. If it does not work, review your rcons setup as documented in previous steps.

### Check hardware control setup to the nodes

See if you setup is correct at this point, run rpower to check node status:




    rpower pnode1 stat


### Update the mac table with the address of the node(s)

**Before run getmacs, make sure the node is off.** The reason is the HMC cannot shutdown linux nodes which are in running state.

You can force the lpar shutdown with:

    rpower pnode1 stat, if node is on then run
    rpower pnode1 off



If there's only one Ethernet adapter on the node or you have specified the installnic or primarynic attribute of the node, using following command can get the correct mac address.

Check for *nic definition, by running

    lsdef pnode1


To set installnic or primarynic:

    chdef -t pnode1 -o blade01 installnic=eth0 primarynic=eth1


Get mac addresses:

    getmacs pnode1


If there are more than one Ethernet adapters on the node, and you don't know which one has been configured for the installation process, or the lpar is just created and there is no active profile for that lpar, or the lpar is on a P5 system and there is no lhea/sea ethernet adapters, then you have to specify more parameters for the lpar to try to figure out an available interface by using the ping operation. Run this command:

    getmacs pnode1 -D -S 192.168.0.1 -G 192.168.0.10



The output looks like following:

    pnode1:
    Type Location Code MAC Address Full Path Name Ping Result Device Type
    ent U9133.55A.10E093F-V4-C5-T1 f2:60:f0:00:40:05 /vdevice/l-lan@30000005 virtual


And the Mac address will be written into the xCAT mac table. Run to verify:

    tabdump mac


### Update the mac table with the address of the node(s) for Power 775

To set installnic or primarynic:

    chdef -t node -o c250f07c04ap13 installnic=hf0 primarynic=hf1


Get mac addresses:

    getmacs c250f07c04ap13 -D





#### **Configure DHCP**

Add the defined nodes into the DHCP configuration:

     makedhcp c250f07c04ap13


Restart the dhcp service:

     service dhcpd restart


### Set up customization scripts (optional)

xCAT supports the running of customization scripts on the nodes when they are installed. You can see what scripts xCAT will run by default by looking at the xcatdefaults entry in the xCAT postscripts database table. The postscripts attribute of the node definition can be used to specify the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run.

To check current postscript and postbootscripts setting:

    tabdump postscripts


For example, if you want to have your two scripts called foo and bar run on node node01 you could add them to the postscripts table:

    **chdef -t node -o node01 -p postscripts=foo,bar**


(The -p flag means to add these to whatever is already set.)

For more information on creating and setting up Post*scripts: [Postscripts_and_Prescripts]

## Install Stateful Nodes

[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes)

### Begin Installation

### Use network boot to start the installation

    rnetboot compute


### Alternative network boot in Power 775

For Power 775 nodes, you can also initiate network boot using the [rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html) and [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) commands, but this method is not recommended for diskfull p775 service nodes.


[Monitor_Installation](Monitor_Installation)





[Install_Additional_Packages](Install_Additional_Packages)

[Install_OS_Updates](Install_OS_Updates)







## Stateless Node Deployment

The following section (and its subsections) is the standard xCAT procedure for building and deploying a linux stateless image. Some of the example commands refer to the x86_64 architecture, but the procedure is the same on ppc64. Just replace x86_64 with ppc64. Also, when it comes time to boot the nodes, use rnetboot instead of rpower.

In addition, to build and deploy  a stateless image on a **p775** cluster, do these additional things when following the procedure below:

  * In the section for installing other packages, add the [powerpc-utils rpm](ftp://linuxpatch.ncsa.uiuc.edu/PERCS/powerpc-utils-1.2.2-18.el6.ppc64.rpm) to the otherpkgs directory and the otherpkglist.
  * In the section for using postinstall files, add the following lines to your postinstall script (the location of the rootimg should be changed to your location):

    cp /hfi/dd/* /install/test/netboot/rh/ppc64/compute/rootimg/tmp/
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhclient-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhcp-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/kernel-headers-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/net-tools-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_ndai-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_util-*.rpm' --force

  * In the Generate/Pack image section, put the p775 custom kernel in /install/kernels and use a genimage command like:

    genimage -i hf0 -n hf_if -k 2.6.32-71.el6.20110617.ppc64 redhat6img


  * Also verify that name resolution will be set up correctly on the nodes. This is necessary for the confighfi postscript to configure the HFI NICs properly. See [Cluster_Name_Resolution] for details about setting up name resolution.
  * When it it comes time to boot the nodes, use rbootseq and rpower.

[Using_Provmethod=osimagename](Using_Provmethod=osimagename)







### Use network boot to start the installation for p775 nodes

Starting with xCAT 2.6, Power 775 diskless nodes can also be network booted using the [rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html) and [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) commands. This is recommended (instead of rnetboot) for diskless p775 nodes, because it is faster:

    rbootseq compute hfi
    rpower compute on


Note: if your diskless p775 node has an ethernet adapter and you are trying to network boot it via that NIC, instead of the HFI NIC, then use "net" instead of "hfi" as the argument to the rbootseq command. This is an unusual case.

### Check the installation result

After the node installation is completed successfully, the node's status will be changed to **booted**, the following command to check the node's status:

    lsdef compute -i status



When the node's status is changed to **booted**, you can also check ssh service on the node is working and you can login without password.

Note: Do not run ssh or xdsh against the node until the node installation is completed successfully. Running ssh or xdsh against the node before the node installation completed may result in ssh hostkeys issues.


If ssh is working but cannot login without password, setup the ssh key to the compute node using xdsh:

    xdsh compute -K



After exchanging ssh key, following command should work.

    xdsh compute date


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

     #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,ddnsdomain,vlanid,comments,disable
     "hfinet","20.0.0.0","255.0.0.0","hf0","20.7.4.1","20.7.4.1","20.7.4.1","20.7.4.1",,,"20.7.4.100-20.7.4.200",,,,,


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
  *     * tabprune eventlog -a
    * tabprune auditlog -a
    * tabprune isnm_perf -a 
    * tabprune isnm_perf_sum -a 
  * Run xcatsnap ( will capture database, config files) and copy to another host. By default it will create in /tmp/xcatsnap two files, for example:
    * xcatsnap.hpcrhmn.10110922.log
    * xcatsnap.hpcrhmn.10110922.tar.gz
  * Back up from /install directory, all images, custom setup data that you want to save. and move to another server. xcatsnap will not backup images.

After the OS install:

  * Proceed to to setup the xCAT MN as a new xCAT MN using the instructions in this document.

