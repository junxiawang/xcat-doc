<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Introduction](#introduction)
    - [Service Nodes](#service-nodes)
    - [Where Did I Come From and Where Am I Going?](#where-did-i-come-from-and-where-am-i-going)
    - [Service Node 101](#service-node-101)
  - [Setup the MN Hierarchical Database](#setup-the-mn-hierarchical-database)
  - [**Define the service nodes in the database**](#define-the-service-nodes-in-the-database)
    - [**Add Service Nodes to the nodelist Table**](#add-service-nodes-to-the-nodelist-table)
    - [**Add OS and Hardware Attributes to Service Nodes**](#add-os-and-hardware-attributes-to-service-nodes)
    - [**Add Service Nodes to the servicenode Table**](#add-service-nodes-to-the-servicenode-table)
    - [**Add Service Node Postscripts**](#add-service-node-postscripts)
    - [**Assigning Nodes to their Service Nodes**](#assigning-nodes-to-their-service-nodes)
      - [**Service Node Pools**](#service-node-pools)
        - [**Conserver and Monserver and Pools**](#conserver-and-monserver-and-pools)
    - [**Setup Site Table**](#setup-site-table)
    - [**Setup networks Table**](#setup-networks-table)
    - [**Verify the Tables**](#verify-the-tables)
    - [**Add additional adapters configuration script (optional)**](#add-additional-adapters-configuration-script-optional)
      - [**Configuring Secondary Adapters**](#configuring-secondary-adapters)
  - [**Gather MAC information for the install adapters**](#gather-mac-information-for-the-install-adapters)
  - [**Configure DHCP**](#configure-dhcp)
  - [Set Up the Service Nodes for Stateful (Diskful) Installation](#set-up-the-service-nodes-for-stateful-diskful-installation)
    - [Update the powerpc-utils-1.2.2-18.el6.ppc64.rpm in the rhels6 RPM repository (rhels6 only)](#update-the-powerpc-utils-122-18el6ppc64rpm-in-the-rhels6-rpm-repository-rhels6-only)
    - [Additional Configuration for Power 775 Clusters Only](#additional-configuration-for-power-775-clusters-only)
    - [Additional Configuration when using DB2](#additional-configuration-when-using-db2)
    - [Set the node status to ready for installation](#set-the-node-status-to-ready-for-installation)
    - [Initialize network boot to install Service Nodes](#initialize-network-boot-to-install-service-nodes)
    - [Initialize network boot to install Service Nodes in Power 775](#initialize-network-boot-to-install-service-nodes-in-power-775)
    - [Monitor the Installation](#monitor-the-installation)
    - [Update Service Node Diskfull Image](#update-service-node-diskfull-image)
  - [Setup the Service Node for Stateless Deployment](#setup-the-service-node-for-stateless-deployment)
    - [Build the Service Node Stateless Image](#build-the-service-node-stateless-image)
      - [**Update Service Node Stateless Image**](#update-service-node-stateless-image)
    - [Monitor install and boot](#monitor-install-and-boot)
  - [**Test Service Node installation**](#test-service-node-installation)
  - [Additional Configuration of the Service Nodes for Power 775 Clusters Only](#additional-configuration-of-the-service-nodes-for-power-775-clusters-only)
    - [Switch xcat-yaboot to yaboot released by RHEL](#switch-xcat-yaboot-to-yaboot-released-by-rhel)
    - [Copy the HFI driver and DHCP packages to service node](#copy-the-hfi-driver-and-dhcp-packages-to-service-node)
    - [Install the HFI device drivers and HFI enabled dhcp server on the xCAT SN](#install-the-hfi-device-drivers-and-hfi-enabled-dhcp-server-on-the-xcat-sn)
    - [Change yaboot to boot from customized kernel](#change-yaboot-to-boot-from-customized-kernel)
    - [Reset the service node to boot from the kernel with HFI](#reset-the-service-node-to-boot-from-the-kernel-with-hfi)
    - [Sync /etc/hosts to Service Node and configure HFI interfaces](#sync-etchosts-to-service-node-and-configure-hfi-interfaces)
    - [Create new network definition for HFI network](#create-new-network-definition-for-hfi-network)
  - [Define and install your Compute Nodes](#define-and-install-your-compute-nodes)
    - [Make /install available on the Service Nodes](#make-install-available-on-the-service-nodes)
    - [Make compute node syncfiles available on the servicenodes](#make-compute-node-syncfiles-available-on-the-servicenodes)
  - [Appendix A: Setup backup Service Nodes](#appendix-a-setup-backup-service-nodes)
    - [**Initial deployment**](#initial-deployment)
    - [**xdcp Behaviour with backup servicenodes**](#xdcp-behaviour-with-backup-servicenodes)
    - [**Synchronizing statelite persistent files**](#synchronizing-statelite-persistent-files)
    - [**Monitoring the service nodes**](#monitoring-the-service-nodes)
    - [**Switch to the backup SN**](#switch-to-the-backup-sn)
      - [**Move the nodes to the new service nodes**](#move-the-nodes-to-the-new-service-nodes)
      - [**Statelite migration**](#statelite-migration)
      - [**Boot the statelite nodes**](#boot-the-statelite-nodes)
    - [**Switching back**](#switching-back)
  - [Appendix B: Diagnostics](#appendix-b-diagnostics)
- [tabedit policy](#tabedit-policy)
- [priority,name,host,commands,noderange,parameters,time,rule,comments,disable](#prioritynamehostcommandsnoderangeparameterstimerulecommentsdisable)
  - [Appendix C: Migrating a Management Node to a Service Node](#appendix-c-migrating-a-management-node-to-a-service-node)
  - [Appendix D: Set up Hierarchical Conserver](#appendix-d-set-up-hierarchical-conserver)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

### Service Nodes

In large clusters, it is desirable to have more than one node (the Management Node - MN) handle the installation and management of the compute nodes. We call these additional nodes **service nodes (SN)**. The management node can delegate all management operations need for a compute node to the SN that is managing that compute node. You can have one or more service nodes set up to install and manage groups of compute nodes. See [XCAT_Overview,_Architecture,_and_Planning/#xcat-architecture](XCAT_Overview,_Architecture,_and_Planning/#xcat-architecture) for a high-level diagram showing this structure.

With xCAT, you have the choice of either having each service node install/manage a specific set of compute nodes, or having a **pool** of service nodes, any of which can respond to an installation request from a compute node. (Service node pools must be aligned with the network broadcast domains, because the way a compute node choose its SN for that boot is by whoever responds to the DHPC request broadcast first.) You can also have a hybrid of the 2 approaches, in which for each specific set of compute nodes you have 2 or more SNs in a pool.

### Where Did I Come From and Where Am I Going?

This document explains the basics for setting up a hierarchical Linux cluster using service nodes. The user of this document should be very familiar with setting up an xCAT non-hierarchical cluster. The document will cover only the additional steps needed to make the cluster hierarchical by setting up the SNs. It is assumed that you have already set up your management node according to the instructions in the relevant xCAT "cookbook" on the [XCAT_Documentation] page. For example:

  * [XCAT_iDataPlex_Cluster_Quick_Start](XCAT_iDataPlex_Cluster_Quick_Start)
  * [XCAT_system_x_support_for_IBM_Flex](XCAT_system_x_support_for_IBM_Flex)
  * [xCAT system p support for Linux on IBM Flex](XCAT_system_p_support_for_IBM_Flex)
  * [XCAT_pLinux_Clusters](XCAT_pLinux_Clusters)
  * [XCAT_pLinux_Clusters_775](XCAT_pLinux_Clusters_775)

Note: If using P775 hardware, reference the [XCAT_pLinux_Clusters_775] link above.

Once you have used **this** document to define your service nodes, you should return to the xCAT cookbook you are using to deploy the service nodes and then the compute nodes.

### Service Node 101

The SNs each run an instance of xcatd, just like the MN does. The xcatd's communicate with each other using the same XML/SSL protocol that the xCAT client uses to communicate with xcatd on the MN.

The service nodes need to communicate with the xCAT database on the Management Node. They do this by using the remote client capability of the database (i.e. they don't go through xcatd for that). Therefore the Management Node must be running one of the daemon-based databases supported by xCAT (PostgreSQL, MySQL, or DB2). (Currently DB2 is only supported in xCAT clusters of Power 775 nodes.) The default SQLite database does not support remote clients and cannot be used in hierarchical clusters. This document includes instructions for migrating your cluster from SQLite to one of the other databases. Since the initial install of xCAT will always set up SQLite, you must migrate to a database that supports remote clients before installing your service nodes.

xCAT will help you install your service nodes will install on the SNs xCAT software and other required rpms such as perl, the database client, and other pre-reqs. Service nodes require all the same software as the MN (because it can do all of the same functions), except that there is a special top level xCAT rpm for SNs called **xCATsn** vs. the **xCAT** rpm that is on the Management Node. The xCATsn rpm tells the SN that the xcatd on it should behave as an SN, not the MN.

## Setup the MN Hierarchical Database

Before setting up service nodes, you need to set up either MySQL, PostgreSQL, or DB2 as the xCAT Database on the Management Node. The database client on the Service Nodes will be set up later when the SNs are installed. MySQL and PostgreSQL are available with the Linux OS. DB2 is an IBM product and must be purchased and is only supported by xCAT in Power 775 clusters.

Follow the instructions in one of these documents for setting up the Management node to use the selected database:

  * To use MySQL or MariaDB:
    * Follow this documentation  and be sure to use the xCAT provided mysqlsetup command to setup the database for xCAT: [Setting_Up_MySQL_as_the_xCAT_DB]
  * To use PostgreSQL:
    * Follow this documentation and be sure and use the xCAT provided pgsqlsetup command to setup the database for xCAT: [Setting_Up_PostgreSQL_as_the_xCAT_DB]
  * To use DB2 (Power775 support only)
    * Follow the sections on setting up the Management Node. Be sure to use the xCAT provided db2sqlsetup command to setup the database for xCAT. At this time, do not do anything to setup the DB2 Client on the Service Nodes, so stop after you have run the db2sqlsetup script to setup the Management Node: [Setting_Up_DB2_as_the_xCAT_DB]

## **Define the service nodes in the database**

This document assumes that you have previously **defined** your compute nodes in the database. It is also possible at this point that you have generic entries in your db for the nodes you will use as service nodes as a result of the node discovery process. We are now going to show you how to add all the relevant database data for the service nodes (SN) such that the SN can be installed and managed from the Management Node (MN). In addition, you will be adding the information to the database that will tell xCAT which service nodes (SN) will service which compute nodes (CN).

For this example, we have two service nodes: **sn1** and **sn2**. We will call our Management Node: **mn1**. Note: service nodes are, by convention, in a group called **service**. Some of the commands in this document will use the group **service** to update all service nodes.

Note: a Service Node's service node is the Management Node; so a service node must have a direct connection to the management node. The compute nodes do not have to be directly attached to the Management Node, only to their service node. This will all have to be defined in your networks table.

### **Add Service Nodes to the nodelist Table**

Define your service nodes (if not defined already), and by convention we put them in a **service** group. We usually have a group **compute** for our compute nodes, to distinguish between the two types of nodes. (If you want to use your own group name for service nodes, rather than **service**, you need to change some defaults in the xCAT db that use the group name **service**. For example, in the postscripts table there is by default a group entry for service, with the appropriate postscripts to run when installing a service node. Also, the default kickstart/autoyast template, pkglist, etc that will be used have files names based on the profile name **service**.)

    mkdef sn1,sn2 groups=service,ipmi,all


### **Add OS and Hardware Attributes to Service Nodes**

When you ran copycds, it created several osimage definitions, including some appropriate for SNs. Display the list of osimages and choose one with "service" in the name:

~~~~
    lsdef -t osimage
~~~~


For this example, let's assume you chose the stateful osimage definition for rhels 6.3: rhels6.3-x86_64-install-service . If you want to modify any of the [osimage attributes](http://xcat.sourceforge.net/man7/osimage.7.html) (e.g. kickstart/autoyast template, pkglist, etc), make a copy of the osimage definition and also copy to /install/custom any files it points to that you are modifying.

Now set some of the common attributes for the SNs at the group level:

~~~~
    chdef -t group service arch=x86_64 os=rhels6.3 nodetype=osi profile=service netboot=xnba installnic=mac \
      primarynic=mac provmethod=rhels6.3-x86_64-install-service

~~~~

### **Add Service Nodes to the servicenode Table**

An entry must be created in the servicenode table for each service node or the service group. This table describes all the services you would like xcat to setup on the service nodes. (Even if you don't want xCAT to set up any services - unlikely - you must define the service nodes in the servicenode table with at least one attribute set (you can set it to 0), otherwise it will not be recognized as a service node.)

When the xcatd daemon is started or restarted on the service node, it will make sure all of the requested services are configured and started. (To temporarily avoid this when restarting xcatd, use "service xcatd **reload**" instead.)

To set up the minimum recommended services on the service nodes:

~~~~
    chdef -t group -o service setupnfs=1 setupdhcp=1 setuptftp=1 setupnameserver=1 setupconserver=1
~~~~


See the setup* attributes in the [node object definition man page](http://xcat.sourceforge.net/man7/node.7.html) for the services available. (The HTTP server is also started when setupnfs is set.) If you are using the setupntp postscript on the compute nodes, you should also set setupntp=1. For clusters with subnetted management networks (i.e. the network between the SN and its compute nodes is separate from the network between the MN and the SNs) you might want to also set setupipforward=1.

### **Add Service Node Postscripts**

By default, xCAT defines the **service** node group to have the "servicenode" postscript run when the SNs are installed or diskless booted. This postscript sets up the xcatd credentials and installs the xCAT software on the service nodes. If you have your own postscript that you want run on the SN during deployment of the SN, put it in /install/postscripts on the MN and add it to the service node postscripts or postbootscripts. For example:

~~~~
    chdef -t group -p service postscripts=<mypostscript>
~~~~

Notes:

  * For Red Hat type distros, the postscripts will be run before the reboot of a kickstart install, and the postbootscripts will be run after the reboot.
  * Make sure that the servicenode postscript is set to run before the otherpkgs postscript or you will see errors during the service node deployment.
  * The -p flag automatically adds the specified postscript at the end of the comma-separated list of postscripts (or postbootscripts).

If you are running additional software on the service nodes that need **ODBC** to access the database (e.g. LoadLeveler or TEAL), use this command to add the xCAT supplied postbootscript called "odbcsetup".

~~~~
    chdef -t group -p service postbootscripts=odbcsetup
~~~~


If using DB2 follow the instructions in this document for setting up the postscripts table to enable DB2 during servicenode installs. [Setting_Up_DB2_as_the_xCAT_DB]

### **Assigning Nodes to their Service Nodes**

The node attributes **servicenode** and **xcatmaster** define which SN services this particular node. The servicenode attribute for a compute node defines which SN the MN should send a command to (e.g. xdsh), and should be set to the hostname or IP address of the service node that the management node contacts it by. The xcatmaster attribute of the compute node defines which SN the compute node should boot from, and should be set to the hostname or IP address of the service node that the compute node contacts it by. Unless you are using service node pools, you must set the xcatmaster attribute for a node when using service nodes, even if it contains the same value as the node's servicenode attribute.

Host name resolution must have been setup in advance, with /etc/hosts, DNS or dhcp to ensure that the names put in this table can be resolved on the Management Node, Service nodes, and the compute nodes. It is easiest to have a node group of the compute nodes for each service node. For example, if all the nodes in node group compute1 are serviced by sn1 and all the nodes in node group compute2 are serviced by sn2:

~~~~
    chdef -t group compute1 servicenode=sn1 xcatmaster=sn1-c
    chdef -t group compute2 servicenode=sn2 xcatmaster=sn2-c
~~~~


Note: in this example, sn1 and sn2 are the node names of the service nodes (and therefore the hostnames associated with the NICs that the MN talks to). The hostnames sn1-c and sn2-c are associated with the SN NICs that communicate with their compute nodes.

Note: the attribute tftpserver defaults to the value of xcatmaster if not set, but in some releases of xCAT it has not defaulted correctly, so it is safer just to set it to the same value as xcatmaster.

These attributes will allow you to specify which service node should run the conserver (console) and monserver (monitoring) daemon for the nodes in the group specified in the command. In this example, we are having each node's primary SN also act as its conserver and monserver (the most typical setup).

~~~~
    chdef -t group compute1 conserver=sn1 monserver=sn1,sn1-c

    chdef -t group compute2 conserver=sn2 monserver=sn2,sn2-c
~~~~


#### **Service Node Pools**

Service Node Pools are multiple service nodes that service the same set of compute nodes. Having multiple service nodes allows backup service node(s) for a compute node when the primary service node is unavailable, or can be used for work-load balancing on the service nodes. But note that the selection of which SN will service which compute node is made at compute node boot time. After that, the selection of the SN for this compute node is fixed until the compute node is rebooted or the compute node is explicitly moved to another SN using the [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) command.

To use Service Node pools, you need to architect your network such that all of the compute nodes and service nodes in a partcular pool are on the same flat network. If you don't want the management node to respond to/manage some of the compute nodes, it shouldn't be on that same flat network. The site.dhcpinterfaces attribute should be set such that the SNs' DHCP daemon only listens on the NIC that faces the compute nodes, not the NIC that faces the MN. This avoids some timing issues when the SNs are being deployed (so that they don't respond to each other before they are completely ready). You also need to make sure the [networks](http://xcat.sourceforge.net/man5/networks.5.html) table accurately reflects the physical network structure.

To define a list of service nodes that support a set of compute nodes, set the servicenode attribute to a comma-delimited list of the service nodes. When running an xCAT command like xdsh or updatenode for compute nodes, the list will be processed left to right, picking the first service node on the list to run the command. If that service node is not available, then the next service node on the list will be chosen until the command is successful. Errors will be logged. If no service node on the list can process the command, then the error will be returned. You can provide some load-balancing by assigning your service nodes as we do below.

When using service node pools, the intent is to have the service node that responds first to the compute node's DHCP request during boot also be the xcatmaster, the tftpserver, and the NFS/http server for that node. Therefore, the xcatmaster and nfsserver attributes for nodes should not be set. When nodeset is run for the compute nodes, the service node interface on the network to the compute nodes should be defined and active, so that nodeset will default those attribute values to the "node ip facing" interface on that service node.

For example:

~~~~
    chdef -t node compute1 servicenode=sn1,sn2 xcatmaster="" nfsserver=""
    chdef -t node compute2 servicenode=sn2,sn1 xcatmaster="" nfsserver=""
~~~~


You need to set the sharedtftp site attribute to 0 so that the SNs will not automatically mount the /tftpboot directory from the management node:

    chdef -t site clustersite sharedtftp=0


For statefull (full-disk) node installs, you will need to use a local /install directory on each service node. The /install/autoinst/node> files generated by nodeset will contain values specific to that service node for correctly installing the nodes.

     chdef -t site clustersite installloc=""


With this setting, you will need to remember to rsync your /install directory from the xCAT management node to the service nodes anytime you change your /install/postscripts, custom osimage files, os repositories, or other directories. It is best to exclude the /install/autoinst directory from this rsync.

~~~~
      rsync -auv --exclude 'autoinst' /install sn1:/
~~~~


**Note:** If your service nodes are stateless and site.sharedtftp=0, if you reboot any service node when using servicenode pools, any data written to the local /tftpboot directory of that SN is lost. You will need to run nodeset for all of the compute nodes serviced by that SN again.

For additional information about service node pool related settings in the networks table, see [Setting_Up_a_Linux_Hierarchical_Cluster/#setup-networks-table](Setting_Up_a_Linux_Hierarchical_Cluster/#setup-networks-table).

##### **Conserver and Monserver and Pools**

The support of conserver and monserver with Service Node Pools is still not supported. You must explicitly assign these functions to a service node using the nodehm.conserver and noderes.monserver attribute as above.

### **Setup Site Table**

If you are **not** using the NFS-based statelite method of booting your compute nodes, set the installloc attribute to "/install". This instructs the service node to mount /install from the management node. (If you don't do this, you have to manually sync /install between the management node and the service nodes.)

~~~~
    chdef -t site  clustersite installloc="/install"
~~~~


For IPMI controlled nodes, if you want the out-of-band IPMI operations to be done directly from the management node (instead of being sent to the appropriate service node), set site.ipmidispatch=n.

If you want to throttle the rate at which nodes are booted up, you can set the following site attributes:

  * syspowerinterval
  * syspowermaxnodes
  * powerinterval (system p only)

See the [site table man page](http://xcat.sourceforge.net/man5/site.5.html) for details.

### **Setup networks Table**

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is on. You need to add entries for each network the service nodes use to communicate to the compute nodes.

For example:

~~~~
    mkdef -t network net1 net=10.5.1.0 mask=255.255.255.224 gateway=10.5.1.1
~~~~


If you want to set the nodes' xcatmaster as the default gateway for the nodes, the gateway attribute can be set to keyword "&lt;xcatmaster&gt;". In this case, xCAT code will automatically substitute the IP address of the node's xcatmaster for the keyword. Here is an example:

~~~~
    mkdef -t network net1 net=10.5.1.0 mask=255.255.255.224 gateway=<xcatmaster>
~~~~


The ipforward attribute should be enabled on all the xcatmaster nodes that will be acting as default gateways. You can set ipforward to 1 in the servicenode table or add the line "net.ipv4.ip_forward = 1" in file /etc/sysctl.conf and then run "sysctl -p /etc/sysctl.conf" manually to enable the ipforwarding.

**Note:**If using service node pools, the networks table dhcpserver attribute can be set to any single service node in your pool. The networks tftpserver, and nameserver attributes should be left blank. 

### **Verify the Tables**

To verify that the tables are set correctly, run lsdef on the service nodes, compute1, compute2:

~~~~
    lsdef service,compute1,compute2
~~~~


### **Add additional adapters configuration script (optional)**

It is possible to have additional adapter interfaces automatically configured when the nodes are booted. XCAT provides sample configuration scripts for ethernet, IB, and HFI adapters. These scripts can be used as-is or they can be modified to suit your particular environment. The ethernet sample is /install/postscript/configeth. When you have the configuration script that you want you can add it to the "postscripts" attribute as mentioned above. Make sure your script is in the /install/postscripts directory and that it is executable.

Note: For system p servers, if you plan to have your service node perform the hardware control functions for its compute nodes, it is necessary that the SN ethernet network adapters connected to the HW service VLAN be configured. For Power 775 clusters specifically, see [Configuring_xCAT_SN_Hierarchy_Ethernet_Adapter_DFM_Only] for more information.

#### **Configuring Secondary Adapters**

To configure secondary adapters, see [Configuring_Secondary_Adapters].

## **Gather MAC information for the install adapters**

[NOTE] you should get the MAC information for the service node firstly. After finishing the OS provision for service node, and create the connections between the hdwr_svr on the service node and the non-sn-CEC, you can get the MAC information for the compute node.

[Gather_MAC_information_for_the_node_boot_adapters](Gather_MAC_information_for_the_node_boot_adapters)

## **Configure DHCP**

Add the relevant networks into the DHCP configuration, refer to:

[XCAT_pLinux_Clusters/#setup-dhcp](XCAT_pLinux_Clusters/#setup-dhcp)


Add the defined nodes into the DHCP configuration, refer to:

[XCAT_pLinux_Clusters/#configure-dhcp](XCAT_pLinux_Clusters/#configure-dhcp)


## Set Up the Service Nodes for Stateful (Diskful) Installation

Any cluster using statelite compute nodes (include p775 clusters) must use a stateful (diskful) service nodes.

Note: If you are using diskless service nodes, go to [Setting_Up_a_Linux_Hierarchical_Cluster/#setup-the-service-node-for-stateless-deployment](Setting_Up_a_Linux_Hierarchical_Cluster/#setup-the-service-node-for-stateless-deployment)

First, go to the [Download_xCAT] site and download the level of the xCAT tarball you desire. Then go to http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux and get the latest xCAT dependency tarball. **Note: All xCAT service nodes must be at the exact same xCAT version as the xCAT Management Node.** Copy the files to the Management Node (MN) and untar them in the appropriate sub-directory of /install/post/otherpkgs: 4 **Note for the appropriate directory below, check the otherpkgdir=/install/post/otherpkgs/rhels6.4/ppc64 attribute of the osimage defined for the servicenode.**

For example for the osimage rhels6.4-ppc64-install-service****

~~~~
    mkdir -p /install/post/otherpkgs/**rhels6.4**/ppc64/xcat
    cd /install/post/otherpkgs/**rhels6.4**/ppc64/xcat
    tar jxvf core-rpms-snap.tar.bz2
    tar jxvf xcat-dep-*.tar.bz2

~~~~

For ubuntu14.04.1-ppc64el-install-service ****

~~~~
mkdir -p /install/post/otherpkgs/ubuntu14.04.1/ppc64el/
cd /install/post/otherpkgs/ubuntu14.04.1/ppc64el/
tar jxvf core-rpms-snap.tar.bz2
tar jxvf xcat-dep-ubuntu*.tar.bz2
~~~~

Next, add rpm names into your own version of service.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist file. In most cases, you can find an initial copy of this file under /opt/xcat/share/xcat/install/&lt;platform&gt; . If not, copy one from a similar platform.

~~~~
    mkdir -p /install/custom/install/rh
    cp /opt/xcat/share/xcat/install/rh/service.rhels6.ppc64.otherpkgs.pkglist /install/custom/install/rh
    vi /install/custom/install/rh/service.rhels6.ppc64.otherpkgs.pkglist
~~~~

For ubuntu14.04.1-ppc64el-install-service,

~~~~
    mkdir -p /install/custom/install/ubuntu/
    cp /opt/xcat/share/xcat/install/ubuntu/service.ubuntu.otherpkgs.pkglist   /install/custom/install/ubuntu/service.ubuntu.otherpkgs.pkglist
    vi /install/custom/install/ubuntu/service.ubuntu.otherpkgs.pkglist
~~~~


Add the following, if it is not there. You must include at least one rpm from each directory you want xCAT to use, because xCAT uses the paths to set up the yum/zypper repositories:

~~~~
    xcat/xcat-core/xCATsn
    xcat/xcat-dep/rh6/x86_64/conserver-xcat
    xcat/xcat-dep/rh6/ppc64/perl-Net-Telnet
    xcat/xcat-dep/rh6/ppc64/perl-Expect
~~~~

For ubuntu14.04.1-ppc64el-install-service, make sure the following entries are included in the /install/custom/install/ubuntu/service.ubuntu.otherpkgs.pkglist:

~~~~
    mariadb-client
    mariadb-common
    xcatsn
    conserver-xcat
~~~~

For ubuntu14.04.1-ppc64el-install-service, the "pkgdir" should include the online/local ubuntu official mirror with the following command:

~~~~

chdef -t osimage -o ubuntu14.04.1-ppc64el-install-service -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://ports.ubuntu.com/ubuntu-ports trusty universe,http://ports.ubuntu.com/ubuntu-ports trusty-updates universe"

~~~~


and the "otherpkgdir" should include the mirror under otherpkgdir on MN, this can be done with: 

~~~~
chdef -t osimage -o ubuntu14.04.1-ppc64el-install-service -p otherpkgdir="http:// < Name or ip of Management Node >/install/post/otherpkgs/ubuntu14.04.1/ppc64el/xcat-core/ trusty main,http://< Name or ip of Management Node >/install/post/otherpkgs/ubuntu14.04.1/ppc64el/xcat-dep/ trusty main"
~~~~





**Note: you will be installing the xCAT Service Node rpm xCATsn meta-package on the Service Node, not the xCAT Management Node meta-package. Do not install both.**

For Power 775 Clusters, you should add the DFM and hdwr_svr into the list of packages to be installed on the SN. Refer to: [Installing DFM and hdwr_svr on Linux SN](https://sourceforge.net/p/xcat/wiki/DFM_Service_Node_Hierarchy_support/#installing-dfm-and-hdwr_svr-on-linux-sn)

(TODO) This needs to be a real doc, not point to a mini-design..

If you want to setup disk mirroring(RAID1) on the service nodes, see [Use_RAID1_In_xCAT_Cluster] for more details.




### Update the powerpc-utils-1.2.2-18.el6.ppc64.rpm in the rhels6 RPM repository (rhels6 only)

  * This section could be removed after the powerpc-utils-1.2.2-18.el6.ppc64.rpm is built in the base rhels6 ISO.
  * The direct rpm download link is: ftp://linuxpatch.ncsa.uiuc.edu/PERCS/powerpc-utils-1.2.2-18.el6.ppc64.rpm
  * The update steps are as following:
    * put the new rpm in the base OS packages

~~~~
    cd  /install/rhels6/ppc64/Server/Packages
    mv powerpc-utils-1.2.2-17.el6.ppc64.rpm  /tmp
    cp /tmp/powerpc-utils-1.2.2-18.el6.ppc64.rpm .
    chmod +r powerpc-utils-1.2.2-18.el6.ppc64.rpm  # make sure that the rpm is be readable by other users
~~~~




  * create the repodata

~~~~
    cd /install/rhels6/ppc64/Server
    ls -al repodata/
         total 14316
         dr-xr-xr-x 2 root root    4096 Jul 20 09:34 .
         dr-xr-xr-x 3 root root    4096 Jul 20 09:34 ..
         -r--r--r-- 1 root root 1305862 Sep 22  2010 20dfb74c144014854d3b16313907ebcf30c9ef63346d632369a19a4add8388e7-other.sqlite.bz2
         -r--r--r-- 1 root root 1521372 Sep 22  2010 57b3c81512224bbb5cebbfcb6c7fd1f7eb99cca746c6c6a76fb64c64f47de102-primary.xml.gz
         -r--r--r-- 1 root root 2823613 Sep 22  2010 5f664ea798d1714d67f66910a6c92777ecbbe0bf3068d3026e6e90cc646153e4-primary.sqlite.bz2
         -r--r--r-- 1 root root 1418180 Sep 22  2010 7cec82d8ed95b8b60b3e1254f14ee8e0a479df002f98bb557c6ccad5724ae2c8-other.xml.gz
         -r--r--r-- 1 root root  194113 Sep 22  2010 90cbb67096e81821a2150d2b0a4f3776ab1a0161b54072a0bd33d5cadd1c234a-comps-rhel6-Server.xml.gz
         **-r--r--r-- 1 root root 1054944 Sep 22  2010 98462d05248098ef1724eddb2c0a127954aade64d4bb7d4e693cff32ab1e463c-comps-rhel6-Server.xml**
         -r--r--r-- 1 root root 3341671 Sep 22  2010 bb3456b3482596ec3aa34d517affc42543e2db3f4f2856c0827d88477073aa45-filelists.sqlite.bz2
         -r--r--r-- 1 root root 2965960 Sep 22  2010 eb991fd2bb9af16a24a066d840ce76365d396b364d3cdc81577e4cf6e03a15ae-filelists.xml.gz
         -r--r--r-- 1 root root    3829 Sep 22  2010 repomd.xml
         -r--r--r-- 1 root root    2581 Sep 22  2010 TRANS.TBL
    createrepo \
     -g repodata/98462d05248098ef1724eddb2c0a127954aade64d4bb7d4e693cff32ab1e463c-comps-rhel6-Server.xml .
~~~~

Note: you should use comps-rhel6-Server.xml with its key as the group file.


### Additional Configuration for Power 775 Clusters Only

  * Increase /boot filesystem size for service nodes

    A customized kernel is required on the service nodes to work with the HFI network. Since both the base and customized kernels will exist on the service nodes, the /boot filesystem will need be increased from the standard default when installing a service node.

    Note, increasing /boot is a workaround for using the customized kernel. After this kernel is accepted by the Linux Kernel community, only one kernel will be required on the service node, and this step will no longer be needed.

    Copy the service node Kickstart install template provided by xCAT to a custom location. For example:

~~~~
     cp /opt/xcat/share/xcat/install/rh/service.rhels6.ppc64.tmpl /install/custom/install/rh

~~~~

    Edit the copied file and change the line:

~~~~
     part /boot --size 50 --fstype ext4</pre>

    to:
     part /boot --size 200 --fstype ext4</pre>
~~~~


### Additional Configuration when using DB2

To have DB2 installed and configured during the install of the Service Node, you need to do the additional setup as documented in [https://sourceforge.net/p/xcat/wiki/Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn](https://sourceforge.net/p/xcat/wiki/Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn).

### Set the node status to ready for installation

Run nodeset to the osimage name defined in the provmethod attribute on your service node.

~~~~
    nodeset service osimage="<osimagename>"
~~~~



For example

~~~~
    nodeset service osimage="rhels6.3-x86_64-install-service"

~~~~

or

~~~~
    nodeset service osimage=rhels6.4-ppc64-install-service

~~~~

### Initialize network boot to install Service Nodes

~~~~
    rnetboot service

~~~~

### Initialize network boot to install Service Nodes in Power 775

Starting from xCAT 2.6 and working in Power 775 cluster, there are two ways to initialize a network boot: one way is that using rbootseq command to setup the boot device as network adapter for the compute node, and after that, you can issue rpower command to power on or reset the compute node to boot from network, another way is to use rnetboot to the compute node directly. Comparing between these two ways, rbootseq/rpower command doesn't require the console support and operate in the console, so it has a better performance. It is recommended to use rbootseq/rpower to setup the boot device to network adapter and initialize the network boot in Power 775 cluster.

Example of using rbootseq and rpower:

~~~~
    rbootseq service net
    rpower service boot
~~~~


### Monitor the Installation

Watch the installation progress using either wcons or rcons:

~~~~
    wcons service     # make sure DISPLAY is set to your X server/VNC or

    rcons <one-node-at-a-time>

    tail -f /var/log/messages
~~~~


Note: We have experienced one problem while trying to install RHEL6 diskful service node working with SAS disks. The service node cannot reboots from SAS disk after the RHEL6 operating system has been installed. We are waiting for the build with fixes from RHEL6 team, once meet this problem, you need to manually select the SAS disk to be the first boot device and boots from the SAS disk.

### Update Service Node Diskfull Image

If you need to update the service nodes later on with a new version of xCAT and its dependencies, obtain the new xCAT and xCAT dependencies rpms. (Follow the same steps that were followed in [Setting_Up_a_Linux_Hierarchical_Cluster/#set-up-the-service-nodes-for-stateful-diskful-installation](Setting_Up_a_Linux_Hierarchical_Cluster/#set-up-the-service-nodes-for-stateful-diskful-installation).

Update the service nodes with the new xCAT rpms:

~~~~
    updatenode service -S
~~~~


If you want to update the service nodes later on with a new release of Linux, you will need to follow the instructions in the Linux documentation, or use the following procedure **at your own risk**, it is not fully tested and not formally supported according to the Linux documentation:

1\. Run copycds on the management node to copy the installation image of the new Linux release, for example:

~~~~
    copycds /iso/RHEL6.2-20111117.0-Server-x86_64-DVD1.iso
~~~~


2\. Modify the os version of the service nodes, for example:

~~~~
    chdef <servicenode> os=rhels6.2
~~~~


3\. Run updatenode <servicenode> -P ospkgs to update the Linux on the service nodes to a new release:

~~~~
    updatenode <servicenode> -P ospkgs
~~~~


## Setup the Service Node for Stateless Deployment

**Note:** The stateless service node is not supported in ubuntu hierarchy cluster. For ubuntu, please skip this section.

If you want, your service nodes can be stateless (diskless). The service node must contain not only the OS, but also the xCAT software and its dependencies. In addition, a number of files are added to the service node to support the PostgreSQL, or MySQL database access from the service node to the Management node, and ssh access to the nodes that the service nodes services. (DB2 is not supported on diskless Service Nodes.) The following sections explain how to accomplish this.

### Build the Service Node Stateless Image

This section assumes you can build the stateless image on the management node because the service nodes are the same OS and architecture as the management node. If this is not the case, you need to build the image on a machine that matches the service node's OS/architecture.

  * Create an osimage definition. When you run copycds, xCAT will create a service node osimage definitions for that distribution. For a stateless service node, use the *-netboot-service definition.

~~~~
      lsdef -t osimage | grep -i service
        rhels6.4-ppc64-install-service  (osimage)
        rhels6.4-ppc64-netboot-service  (osimage)
        rhels6.4-ppc64-statelite-service  (osimage)
~~~~

~~~~
      lsdef -t osimage -l rhels6.3-ppc64-netboot-service
        Object name: rhels6.3-ppc64-netboot-service
            exlist=/opt/xcat/share/xcat/netboot/rh/service.exlist
            imagetype=linux
            osarch=ppc64
            osdistroname=rhels6.3-ppc64
            osname=Linux
            osvers=rhels6.3
            otherpkgdir=/install/post/otherpkgs/rhels6.3/ppc64
            otherpkglist=/opt/xcat/share/xcat/netboot/rh/service.rhels6.ppc64.otherpkgs.pkglist
            pkgdir=/install/rhels6.3/ppc64
            pkglist=/opt/xcat/share/xcat/netboot/rh/service.rhels6.ppc64.pkglist
            postinstall=/opt/xcat/share/xcat/netboot/rh/service.rhels6.ppc64.postinstall
            profile=service
            provmethod=netboot
            rootimgdir=/install/netboot/rhels6.3/ppc64/service
~~~~





  * You can check the service node packaging to see if it has all the rpms you require. We ship a basic requirements lists that will create a fully functional service node. However, you may want to customize your service node by adding additional operating system packages or modifying the files excluded by the exclude list. View the files referenced by the osimage pkglist, otherpkglist and exlist attributes:

~~~~
     cd /opt/xcat/share/xcat/netboot/rh/
     view service.rhels6.ppc64.pkglist
     view service.rhels6.ppc64.otherpkgs.pkglist
     view service.exlist

~~~~

     If you would like to change any of these files, copy them to a custom directory. This can be any directory you choose, but we recommend that you keep it /install somewhere. A good location is something like /install/custom/netboot/&lt;os&gt;/service. Make sure that your otherpkgs.pkglist file as an entry for

~~~~
     xcat/xcat-core/xCATsn
~~~~


     This is required to install the xCAT service node function into your image.

     You may also choose to create an appropriate /etc/fstab file in your service node image. Copy the script referenced by the postinstall attribute to your directory and modify it as you would like:

~~~~
     cp /opt/xcat/share/xcat/netboot/rh/service.rhels6.ppc64.postinstall /install/custom/netboot/rh
     vi /install/custom/netboot/rh
        # uncomment the sample fstab lines and change as needed:
        proc /proc proc rw 0 0
        sysfs /sys sysfs rw 0 0
        devpts /dev/pts devpts rw,gid=5,mode=620 0 0
        service_x86_64 / tmpfs rw 0 1
        none /tmp tmpfs defaults,size=10m 0 2
        none /var/tmp tmpfs defaults,size=10m 0 2
~~~~


    After modifying the files, you will need to update the osimage definition to reference these files. We recommend creating a new osimage definition for your custom image:

~~~~
      lsdef -t osimage -l rhels6.3-ppc64-netboot-service -z > /tmp/myservice.def
      vi /tmp/myservice.def
~~~~
         # change the name of the osimage definition
         # change any attributes that now need to reference your custom files
         # change the rootimgdir attribute replacing 'service'
           with a name to match your new osimage definition
~~~~
      cat /tmp/msyservice.def | mkdef -z
~~~~


     While you are here, if you'd like, you can do the same for your compute node images, creating custom files and new custom osimage definitions as you need to.

     For more information on the use and syntax of otherpkgs and pkglist files, see [Using_Updatenode].

  * Make your xCAT software available for otherpkgs processing:



  * If you downloaded xCAT to your management node for installation, place a copy of your xcat-core and xcat-dep in your otherpkgdir directory:

~~~~
     lsdef -t osimage -o rhels6.3-ppc64-netboot-service -i otherpkgdir
        Object name: rhels6.3-ppc64-netboot-service
            otherpkgdir=/install/post/otherpkgs/rhels6.3/ppc64
     cd /install/post/otherpkgs/rhels6.3/ppc64
     mkdir xcat
     cd xcat
     cp -Rp <current location of xcat-core>/xcat-core .
     cp -Rp <current location of xcat-dep>/xcat-dep .

~~~~



  * If you installed your management node directly from the Linux online repository, you will need to download the xcat-core and xcat-dep tarballs:





     First, go to the [Download xCAT](http://sourceforge.net/apps/wiki/xcat/index.php?title=Download_xCAT) page and download the level of xCAT tarball you desire. Then go to the [Download xCAT Dependencies](https://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/) page and download the latest xCAT dependency tarball. Place these into your otherpkdir directory:

~~~~
     lsdef -t osimage -o rhels6.3-ppc64-netboot-service -i otherpkgdir
        Object name: rhels6.3-ppc64-netboot-service
            otherpkgdir=/install/post/otherpkgs/rhels6.3/ppc64
     cd /install/post/otherpkgs/rhels6.3/ppc64
     mkdir xcat
     cd xcat
     mv <xcat-core tarball>  .
     tar -jxvf <xcat-core tarball>
     mv <xcat-dep tarball>   .
     tar -jxvf <xcat-dep tarball>

~~~~




  * Run image generation for your osimage definition:

~~~~
     genimage rhels6.3-ppc64-netboot-service
~~~~





  * Prevent DHCP from starting up until xcatd has had a chance to configure it:

~~~~
    chroot /install/netboot/rhels6.3/ppc64/service/rootimg chkconfig dhcpd off
    chroot /install/netboot/rhels6.3/ppc64/service/rootimg chkconfig dhcrelay off
~~~~





  * IF using NFS hybrid mode, export /install read-only in service node image:

~~~~
    cd /install/netboot/rhels6.3/ppc64/service/rootimg/etc
    echo '/install *(ro,no_root_squash,sync,fsid=13)' >exports
~~~~


  * Pack the image for your osimage definition:

~~~~
    packimage rhels6.3-ppc64-netboot-service

~~~~

  * Set the node status to ready for netboot using your osimage definition and your 'service' nodegroup:

~~~~
    nodeset service osimage=rhels6.3-ppc64-netboot-service
~~~~


  * To diskless boot the service nodes

~~~~
    rnetboot service

~~~~

  * To diskless boot the service nodes in Power 775

Starting from xCAT 2.6 and working in Power 775 cluster, there are two ways to initialize a network boot: one way is that using rbootseq command to setup the boot device as network adapter for the compute node, and after that, you can issue rpower command to power on or reset the compute node to boot from network, another way is to use rnetboot to the compute node directly. Comparing between these two ways, rbootseq/rpower command doesn't require the console support and operate in the console, so it has a better performance. It is recommended to use rbootseq/rpower to setup the boot device to network adapter and initialize the network boot in Power 775 cluster.

~~~~
    rbootseq service net
    rpower service boot
~~~~





#### **Update Service Node Stateless Image**

To update the xCAT software in the image at a later time:

  * Download the updated xcat-core and xcat-dep tarballs and place them in your osimage's otherpkgdir xcat directory as you did above.
  * Generate and repack the image and reboot your service node:
  * Run image generation for your osimage definition:

~~~~
     genimage rhels6.3-ppc64-netboot-service
     packimage rhels6.3-ppc64-netboot-service
     nodeset service osimage=rhels6.3-ppc64-netboot-service
     rnetboot service

~~~~


To diskless boot the service nodes in Power 775

Starting from xCAT 2.6 and working in Power 775 cluster, there are two ways to initialize a network boot: one way is that using rbootseq command to setup the boot device as network adapter for the compute node, and after that, you can issue rpower command to power on or reset the compute node to boot from network, another way is to use rnetboot to the compute node directly. Comparing between these two ways, rbootseq/rpower command doesn't require the console support and operate in the console, so it has a better performance. It is recommended to use rbootseq/rpower to setup the boot device to network adapter and initialize the network boot in Power 775 cluster.

~~~~
    rbootseq service net
    rpower service boot

~~~~




**Note: **The service nodes are set up as NFS-root servers for the compute nodes. Any time changes are made to any compute image on the mgmt node it will be necessary to sync all changes to all service nodes. In our case the /install directory is mounted on the servicenodes, so the update to the compute node image is automatically available. 

### Monitor install and boot

~~~~
    wcons service # make sure DISPLAY is set to your X server/VNC or
~~~~


~~~~
    rcons <one-node-at-a-time> # or do rcons for each node
~~~~


    tail -f /var/log/messages


## **Test Service Node installation**

  * ssh to the service nodes. You should not be prompted for a password.
  * Check to see that the xcat daemon xcatd is running.
  * Run some database command on the service node, e.g tabdump site, or nodels, and see that the database can be accessed from the service node.
  * Check that /install and /tftpboot are mounted on the service node from the Management Node, if appropriate.
  * Make sure that the Service Node has Name resolution for all nodes, it will service.




## Additional Configuration of the Service Nodes for Power 775 Clusters Only

### Switch xcat-yaboot to yaboot released by RHEL

Note: This is a workaround for the issue that xcat-yaboot is not working properly with netboot over HFI. After xcat-yaboot is rebuilt on top of yaboot version 1.3.17, this step is not required:

~~~~
    yum install yaboot
    mv /tftpboot/yaboot /tftpboot/yaboot.back
    cp /usr/lib/yaboot/yaboot /tftpboot/yaboot

~~~~




### Copy the HFI driver and DHCP packages to service node

~~~~
    xdcp c250f07c04ap01 -R /hfi /hfi

~~~~

### Install the HFI device drivers and HFI enabled dhcp server on the xCAT SN

~~~~
    xdsh c250f07c04ap01 rpm -ivh /hfi/dd/kernel-2.6.32-*.ppc64.rpm
    xdsh c250f07c04ap01 rpm -ivh /hfi/dd/kernel-headers-2.6.32-*.ppc64.rpm --force
    xdsh c250f07c04ap01 rpm -ivh /hfi/dd/hfi_util-*.el6.ppc64.rpm
    xdsh c250f07c04ap01 rpm -ivh /hfi/dd/hfi_ndai-*.el6.ppc64.rpm
    xdsh c250f07c04ap01 rpm -ivh /hfi/dhcp/net-tools-*.el6.ppc64.rpm --force
    xdsh c250f07c04ap01 rpm -ivh /hfi/dhcp/dhcp-*.el6.ppc64.rpm --force
    xdsh c250f07c04ap01 rpm -ivh /hfi/dhcp/dhclient-*.el6.ppc64.rpm
    xdsh c250f07c04ap01 /sbin/new-kernel-pkg --mkinitrd --depmod --install 2.6.32-71.el6.20110617.ppc64
    xdsh c250f07c04ap01 /sbin/new-kernel-pkg --rpmposttrans 2.6.32-71.el6.20110617.ppc64
~~~~


### Change yaboot to boot from customized kernel

Create soft links and change yaboot.conf to boot from the customized kernel with HFI support

~~~~
    xdsh c250f07c04ap01 ln -sf /boot/vmlinuz-2.6.32-71.el6.20110617.ppc64 /boot/vmlinuz
    xdsh c250f07c04ap01 ln -sf /boot/System.map-2.6.32-71.el6.20110617.ppc64 /boot/System.map

~~~~

Login to the service node and change the "default=" setting in /boot/etc/yaboot.conf to the new label with HFI support. For example, change it from:

~~~~
    boot=/dev/sda1
    init-message="Welcome to Red Hat Enterprise Linux!\nHit <TAB> for boot options"
    partition=3
    timeout=5
    install=/usr/lib/yaboot/yaboot
    delay=5
    enablecdboot
    enableofboot
    enablenetboot
    nonvram
    fstype=raw
    default=linux

    image=/vmlinuz-2.6.32hfi
    label=2.6.32hfi
    read-only
    initrd=/initrd-2.6.32hfi.img
    append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba"
    image=/vmlinuz-2.6.32-71.el6.ppc64
    label=linux
    read-only
    initrd=/initramfs-2.6.32-71.el6.ppc64.img
    append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us \
       console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba"

~~~~

TO:

~~~~
    boot=/dev/sda1
    init-message="Welcome to Red Hat Enterprise Linux!\nHit <TAB> for boot options"
    partition=3
    timeout=5
    install=/usr/lib/yaboot/yaboot
    delay=5
    enablecdboot
    enableofboot
    enablenetboot
    nonvram
    fstype=raw
    default=2.6.32-71.el6.20110617.ppc64

    image=/vmlinuz-2.6.32-71.el6.20110617.ppc64
    label=2.6.32-71.el6.20110617.ppc64
    read-only
    initrd=/initrd-2.6.32-71.el6.20110617.ppc64.img
    append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba"
    image=/vmlinuz-2.6.32-71.el6.ppc64
    label=linux
    read-only
    initrd=/initramfs-2.6.32-71.el6.ppc64.img
    append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us \
        console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba"
~~~~

### Reset the service node to boot from the kernel with HFI

~~~~
    xdsh c250f07c04ap01 reboot

~~~~

### Sync /etc/hosts to Service Node and configure HFI interfaces

Now the HFI interfaces should be available on the service node. Sync the /etc/hosts from MN to SN and run the confighfi postscript to configure the HFI interfaces with IP addresses.

~~~~
    xdcp c250f07c04ap01 /etc/hosts /etc/hosts
    chdef c250f07c04ap01 postscripts=confighfi
    updatenode c250f07c04ap01

~~~~

### Create new network definition for HFI network

Create new networks definitions in the xCAT database for the HFI interfaces. Generally there will be four HFI interfaces on the service nodes, so for each network, create an network entry.

~~~~
mkdef -t network -o hfinet0 net=20.0.0.0 mask=255.0.0.0 gateway=20.7.4.1 mgtifname=hf0 dhcpserver=20.7.4.1 \ 
      tftpserver=20.7.4.1 nameservers=20.7.4.1
mkdef -t network -o hfinet1 net=21.0.0.0 mask=255.0.0.0 gateway=21.7.4.1 mgtifname=hf1 dhcpserver=21.7.4.1 \
      tftpserver=21.7.4.1 nameservers=21.7.4.1
mkdef -t network -o hfinet2 net=22.0.0.0 mask=255.0.0.0 gateway=22.7.4.1 mgtifname=hf2 dhcpserver=22.7.4.1 \
      tftpserver=22.7.4.1 nameservers=22.7.4.1
mkdef -t network -o hfinet3 net=23.0.0.0 mask=255.0.0.0 gateway=23.7.4.1 mgtifname=hf3 dhcpserver=23.7.4.1 \
      tftpserver=23.7.4.1 nameservers=23.7.4.1
~~~~

where the above net, mask, and gateway are appropriate for your hf0,hf1,hf2 and hf3 network

## Define and install your Compute Nodes

### Make /install available on the Service Nodes

**Note that all of the files and directories pointed to by your osimages should be placed under the directory referred to in site.installdir (usually /install), so they will be available to the service nodes.** The installdir directory is mounted or copied to the service nodes during the hierarchical install of compute nodes from the service nodes.

If you are **not** using the NFS-based statelite method of booting your compute nodes and you are **not** using service node pools, set the installloc attribute to "/install". This instructs the service node to mount /install from the management node. (If you don't do this, you have to manually sync /install between the management node and the service nodes.)

~~~~
    chdef -t site  clustersite installloc="/install"
~~~~


### Make compute node syncfiles available on the servicenodes

If you are **not** using the NFS-based statelite method of booting your compute nodes, and you plan to use the syncfiles postscript to update files on the nodes during install, you must ensure that those files are sync'd to the servicenodes before the install of the compute nodes. To do this after your nodes are defined, you will need to run the following whenever the files in your synclist change on the Management Node:

~~~~
     updatenode <computenoderange> -f
~~~~


At this point you can return to the documentation for your cluster environment to define and deploy your compute nodes. For Power 775 Cluster, after the service node has been installed, you should create the connections between the hdwr_svr and non-sn_CEC, and then do other hardware control commands.

## Appendix A: Setup backup Service Nodes

For reliability, availability, and serviceability purposes you may wish to designate backup service nodes in your hierarchical cluster. The backup service node will be another active service node that is set up to easily take over from the original service node if a problem occurs. This is **not** an automatic fail over feature. You will have to initiate the switch from the primary service node to the backup manually. The xCAT support will handle most of the setup and transfer of the nodes to the new service node. This procedure can also be used to simply switch some compute nodes to a new service node, for example, for planned maintenance.

Abbreviations used below:

  * MN - management node.
  * SN - service node.
  * CN - compute node.

### **Initial deployment**

Integrate the following steps into the hierarchical deployment process described above.

  1. Make sure both the primary and backup service nodes are installed, configured, and can access the MN database.
  2. When defining the CNs add the necessary service node values to the "_servicenode_" and "_xcatmaster_" attributes of the [node definitions](http://xcat.sourceforge.net/man7/node.7.html).
  3. (Optional) Create an xCAT group for the nodes that are assigned to each SN. This will be useful when setting node attributes as well as providing an easy way to switch a set of nodes back to their original server.

To specify a backup service node you must specify a comma-separated list of two service nodes for the **servicenode** value of the compute node. The first one will be the primary and the second will be the backup (or new SN) for that node. Use the hostnames of the SNs as known by the MN.

For the **xcatmaster** value you should only include the primary SN, as known by the compute node.

In most hierarchical clusters, the networking is such that the name of the SN as known by the MN is different than the name as known by the CN. (If they are on different networks.)

In the following example assume the SN interface to the MN is on the "a" network and the interface to the CN is on the "b" network. To set the attributes you would run a command similar to the following.

~~~~
    chdef <noderange>  servicenode="xcatsn1a,xcatsn2a" xcatmaster="xcatsn1b"

~~~~

The process can be simplified by creating xCAT node groups to use as the &lt;noderange&gt; in the [chdef](http://xcat.sourceforge.net/man1/chdef.1.html) command. To create an xCAT node group containing all the nodes that have the service node "SN27" you could run a command similar to the following.

~~~~
    mkdef -t group sn1group members=node[01-20]
~~~~


**Note:** Normally backup service nodes are the primary SNs for other compute nodes. So, for example, if you have 2 SNs, configure half of the CNs to use the 1st SN as their primary SN, and the other half of CNs to use the 2nd SN as their primary SN. Then each SN would be configured to be the backup SN for the other half of CNs.

When you run [makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html), it will configure dhcp and tftp on both the primary and backup SNs, assuming they both have network access to the CNs. This will make it possible to do a quick SN takeover without having to wait for replication when you need to switch.

### **xdcp Behaviour with backup servicenodes**

The xdcp command in a hierarchical environment must first copy (scp) the files to the service nodes for them to be available to scp to the node from the service node that is it's master. The files are placed in /var/xcat/syncfiles directory by default, or what is set in site table SNsyncfiledir attribute. If the node has multiple service nodes assigned, then xdcp will copy the file to each of the service nodes assigned to the node. For example, here the files will be copied (scp) to both service1 and rhsn. lsdef cn4 | grep servicenode

~~~~
       servicenode=service1,rhsn
~~~~


If a service node is offline ( e.g. service1), then you will see errors on your xdcp command, and yet if rhsn is online then the xdcp will actually work. This may be a little confusing. For example, here service1 is offline, but we are able to use rhsn to complete the xdcp.

~~~~
    xdcp cn4  /tmp/lissa/file1 /tmp/file1

    service1: Permission denied (publickey,password,keyboard-interactive).
    service1: Permission denied (publickey,password,keyboard-interactive).
    service1: lost connection
    The following servicenodes: service1, have errors and cannot be updated
    Until the error is fixed, xdcp will not work to nodes serviced by these service nodes.


    xdsh cn4 ls /tmp/file1
    cn4: /tmp/file1

~~~~

### **Synchronizing statelite persistent files**

If you are using xCAT's "statelite" support, you may want to replicate your statelite files to the backup (or new) service node. This would be the case if you are using the service node as the server for the statelite persistent directory. In this case you need to copy your statelite files and directories to the backup service node and keep them synchronized over time. An easy and efficient way to do this would be to use the rsync command from the primary SN to the backup SN.

For example, to copy and/or update the /nodedata directory on the backup service node "sn2" you could run the following command on sn1:

~~~~
    rsync -auv /nodedata sn2:/
~~~~


**Note:** The xCAT [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) command has a new option -l to synchronize statelite files from the primary service node to the backup service node, but it is currently only implemented on AIX.

See [XCAT_Linux_Statelite] for details on using the xCAT statelite support.

### **Monitoring the service nodes**

In most cluster environments it is very important to monitor the state of the service nodes. If a SN fails for some reason you should switch nodes to the backup service node as soon as possible.

See [Monitor_and_Recover_Service_Nodes] for details on monitoring your service nodes.

### **Switch to the backup SN**

When an SN fails, or you want to bring it down for maintenance, use this procedure to move its CNs over to the backup SN.

#### **Move the nodes to the new service nodes**

Use the xCAT [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) to make the database updates necessary to move a set of nodes from one service node to another, and to make configuration modifications to the nodes.

For example, if you want to switch all the compute nodes that use service node "sn1" to the backup SN (sn2), run:

~~~~
    snmove -s sn1
~~~~


**Modified database attributes**

The **snmove** command will check and set several node attribute values.



**servicenode:**&nbsp;: This will be set to either the second server name in the servicenode attribute list or the value provided on the command line.
**xcatmaster:**&nbsp;: Set with either the value provided on the command line or it will be automatically determined from the servicenode attribute.
**nfsserver:**&nbsp;: If the value is set with the source service node then it will be set to the destination service node.
**tftpserver:**&nbsp;: If the value is set with the source service node then it will be reset to the destination service node.
**monserver:**&nbsp;: If set to the source service node then reset it to the destination servicenode and xcatmaster values.
**conserver:**&nbsp;: If set to the source service node then reset it to the destination servicenode and run **makeconservercf**

**Run postscripts on the nodes**

If the CNs are up at the time the **snmove** command is run then snmove will run postscripts on the CNs to reconfigure them for the new SN. The "syslog" postscript is always run. The "mkresolvconf" and "setupntp" scripts will be run IF they were included in the nodes postscript list.

You can also specify an additional list of postscripts to run.

**Modify system configuration on the nodes**

If the CNs are up the **snmove** command will also perform some configuration on the nodes such as setting the default gateway and modifying some configuration files used by xCAT.

#### **Statelite migration**

If you are using the xCAT statelite support you may need to modify the [statelite](http://xcat.sourceforge.net/man5/statelite.5.html) and [litetree](http://xcat.sourceforge.net/man5/litetree.5.html) tables. This would be necessary if any of the entries in the tables include the name of the primary service node as the server for the file or directory. In this case you would have to change those entries to the name of the backup service node. But a better solution is to use the variable **$noderes.xcatmaster** in the statelite and litetree tables. See [XCAT_Linux_Statelite] for details.

#### **Boot the statelite nodes**

For statelite nodes that do not use an external NFS server, if the original service node is down, the CNs it manages will be down too. You must run the [nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) command for those nodes and then boot the nodes after running snmove. For stateless nodes (and in some cases RAMDisk statelite nodes), the nodes will be up even if the original service node is down. However, make sure to run the nodeset command in case you need to reboot the nodes later.

**Note:** when moving p775 nodes, use the **rbootseq** and **rpower** commands to boot the nodes. If you do not use the rbootseq command, the nodes will still try to boot from the old SN.

### **Switching back**

The process for switching nodes back will depend on what must be done to recover the original service node. If the SN needed to be reinstalled, you need to set it up as an SN again and make sure the CN images are replicated to it. Once you've done this, or if the SN's configuration was not lost, then follow these steps to move the CNs back to their original SN:

  * Use snmove:

~~~~
    snmove sn1group -d sn1
~~~~


  * If these are statelite CNs:
    * rsync persistent files back to the original SN
    * run nodeset for these CNs
    * boot the CNs

## Appendix B: Diagnostics

  * **root ssh keys not setup** \-- If you are prompted for a password when ssh to the service node, then check to see if /root/.ssh has authorized_keys. If the directory does not exist or no keys, on the MN, run xdsh service -K, to exchange the ssh keys for root. You will be prompted for the root password, which should be the password you set for the key=system in the passwd table.
  * **XCAT rpms not on SN** \--On the SN, run rpm -qa | grep xCAT and make sure the appropriate xCAT rpms are installed on the servicenode. See the list of xCAT rpms in Set Up the Service Nodes for diskfull Installation. If rpms missing check your install setup as outlined in Build the Service Node Stateless Image for diskless or Set Up the Service Nodes for diskfull Installation for diskfull installs.
  * **otherpkgs(including xCAT rpms) installation failed on the SN** \--The OS repository is not created on the SN. When the "yum" command is processing the dependency, the rpm packages (including expect, nmap, and httpd, etc) required by xCATsn can't be found. In this case, please check whether the /install/postscripts/repos/&lt;osver&gt;/&lt;arch&gt;/ directory exists on the MN. If it is not on the MN, you need to re-run the "copycds" command, and there will be some file created under the /install/postscripts/repos/&lt;osver&gt;/&lt;arch&gt; directory on the MN. Then, you need to re-install the SN, and this issue should be gone.
  * **Error finding the database/starting xcatd **\-- If on the Service node when you run tabdump site, you get "Connection failure: IO::Socket::SSL: connect: Connection refused at /opt/xcat/lib/perl/xCAT/Client.pm". Then restart the xcatd daemon and see if it passes by running the command: service xcatd restart. If it fails with the same error, then check to see if /etc/xcat/cfgloc file exists. It should exist and be the same as /etc/xcat/cfgloc on the MN. If it is not there, copy it from the MN to the SN. The run service xcatd restart. This indicates the servicenode postscripts did not complete successfully. Check to see your postscripts table was setup correctly in Add Service Nodes postscripts to the postscripts table.
  * **Error accessing database/starting xcatd credential failure**\-- If you run tabdump site on the servicenode and you get "Connection failure: IO::Socket::SSL: SSL connect attempt failed because of handshake problemserror:14094418:SSL routines:SSL3_READ_BYTES:tlsv1 alert unknown ca at /opt/xcat/lib/perl/xCAT/Client.pm", check /etc/xcat/cert. The directory should contain the files ca.pem and server-cred.pem. These were suppose to transfer from the MN /etc/xcat/cert directory during the install. Also check the /etc/xcat/ca directory. This directory should contain most files from the /etc/xcat/ca directory on the MN. You can manually copy them from the MN to the SN, recursively. This indicates the the servicenode postscripts did not complete successfully. Check to see your postscripts table was setup correctly in Add Service Nodes postscripts to the postscripts table. Again service xcatd restart and try the tabdump site again.
  * **Missing ssh hostkeys --** Check to see if /etc/xcat/hostkeys on the SN, has the same files as /etc/xcat/hostkeys on the MN. These are the ssh keys that will be installed on the compute nodes, so root can ssh between compute nodes without password prompting. If they are not there copy them from the MN to the SN. Again, these should have been setup by the servicenode postscripts.
  * **Errors running hierarchical commands such as xdsh**  \-- xCAT has a number of commands that run hierarchically.  That is, the commands are sent from xcatd on the management node to the correct service node xcatd, which in turn processes the command and sends the results back to xcatd on the management node.  If a hierarchical command such as xcatd fails with something like "Error: Permission denied for request", check /var/log/messages on the management node for errors.  One error might be "Request matched no policy rule".  This may mean you will need to add policy table entries for your xCAT management node and service node:

~~~~

# tabedit policy
#priority,name,host,commands,noderange,parameters,time,rule,comments,disable
"1","root",,,,,,"allow",,
"1.2","mn1.cluster.com",,,,,,"allow",,
"1.3","mn1",,,,,,"allow",,
"1.4","sn1.cluster.com",,,,,,"allow",,
"1.5","sn1",,,,,,"allow",,
:

~~~~


## Appendix C: Migrating a Management Node to a Service Node

If you find you want to convert an existing Management Node to a Service Node, you need to work with the xCAT team. It is recommended for now, to backup your database, setup your new Management Server, and restore your database into it. Take the old Management Node and remove xCAT and all xCAT directories, and your database. See [Uninstalling_xCAT] and then follow the process for setting up a SN as if it is a new node.

## Appendix D: Set up Hierarchical Conserver

To allow you to open the rcons from the Management Node running the conserver daemon on the Service Nodes, do the following:


  * Set nodehm.conserver to be the service node (using the ip that faces the management node)

~~~~
    chdef -t <noderange> conserver=<servicenodeasknownbytheMN>
    makeconservercf
    service conserver stop
    service conserver start
~~~~