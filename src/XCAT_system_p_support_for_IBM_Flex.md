<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Terminology](#terminology)
  - [Command Man Pages and Database Attribute Descriptions](#command-man-pages-and-database-attribute-descriptions)
- [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
- [Install xCAT on the Management Node](#install-xcat-on-the-management-node)
- [Downloading and Installing DFM](#downloading-and-installing-dfm)
- [Use xCAT to Configure Services on the Management Node](#use-xcat-to-configure-services-on-the-management-node)
  - [Setup /etc/hosts File](#setup-etchosts-file)
  - [Setup DNS](#setup-dns)
  - [Setup DHCP](#setup-dhcp)
- [Define the CMMs and Switches](#define-the-cmms-and-switches)
- [CMM Discovery and Configuration](#cmm-discovery-and-configuration)
- [Create node object definitions of flex blade servers](#create-node-object-definitions-of-flex-blade-servers)
  - [Create predefined nodes in the Database first and run rscan -u to Discovery](#create-predefined-nodes-in-the-database-first-and-run-rscan--u-to-discovery)
    - [Run rscan -u to discover all the compute node servers.](#run-rscan--u-to-discover-all-the-compute-node-servers)
  - [Create object definition of flex blades by discovery using stanza files](#create-object-definition-of-flex-blades-by-discovery-using-stanza-files)
  - [Set the network configuration for the fsp](#set-the-network-configuration-for-the-fsp)
  - [Modify blade server device names](#modify-blade-server-device-names)
- [Create the hardware server connection for the IBM Flex power 7 server](#create-the-hardware-server-connection-for-the-ibm-flex-power-7-server)
  - [Update the FSP firmware (optional)](#update-the-fsp-firmware-optional)
- [Prepare for Node Deployment](#prepare-for-node-deployment)
- [Update the IBM Flex Power 7 Server firmware](#update-the-ibm-flex-power-7-server-firmware)
- [Deploying an OS on the Blades](#deploying-an-os-on-the-blades)
- [Deploying Stateless Nodes](#deploying-stateless-nodes)
- [Installing Stateful Nodes](#installing-stateful-nodes)
- [Appendix 1: IBM Flex Recovery and CMM Redundancy](#appendix-1-ibm-flex-recovery-and-cmm-redundancy)
  - [Replacement of CMM](#replacement-of-cmm)
  - [CMM Redundancy](#cmm-redundancy)
    - [Fail over software reset from CMM GUI](#fail-over-software-reset-from-cmm-gui)
    - [Fail over software reset from CMM CLI](#fail-over-software-reset-from-cmm-cli)
    - [Fail over hardware reset of CMM](#fail-over-hardware-reset-of-cmm)
- [Appendix 2: CMM and Flexible Service Processor(FSP) password](#appendix-2-cmm-and-flexible-service-processorfsp-password)
  - [Errors caused by an FSP authentication problem](#errors-caused-by-an-fsp-authentication-problem)
- [Appendix 3: Updating Firmware on Flex Ethernet and IB Switch Modules](#appendix-3-updating-firmware-on-flex-ethernet-and-ib-switch-modules)
    - [Firmware Update using CLI](#firmware-update-using-cli)
- [**Appendix 4 Perform Deferred Firmware upgrades for Flex blade CEC **](#appendix-4-perform-deferred-firmware-upgrades-for-flex-blade-cec-)
    - [**Deferred firmware update Background**](#deferred-firmware-update-background)
    - [**temp/perm side, pending_power_on_side attributes in Deferred firmware update**](#tempperm-side-pending_power_on_side-attributes-in-deferred-firmware-update)
    - [**The procedure of the deferred firmware update **](#the-procedure-of-the-deferred-firmware-update-)
- [Appendix 5 lshwconn LINE DOWN after power outage](#appendix-5-lshwconn-line-down-after-power-outage)
- [**Appendix 6: Migrate your Management Node to a new Service Pack of Linux**](#appendix-6-migrate-your-management-node-to-a-new-service-pack-of-linux)
- [**Appendix 7: Install your Management Node to a new Release of Linux**](#appendix-7-install-your-management-node-to-a-new-release-of-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Introduction

IBM Flex combines networking, storage and servers in a single offering. It's consist of an IBM Flex Chassis, one or two Chassis Management Modules(CMM) and Power 7 and x86 compute node servers. The type of the management module for IBM Flex is 'cmm', and the Power 7 compute node servers include the IBM Flex System. p260, p460, and 24L Power 7 servers as well as the IBM Flex System. x240 Compute Node which is an x86 Intel-processor based server. **In this document only the management of POWER 7 servers running Linux will be covered.**

IBM Flex System. p260, p460, and 24L Power 7 servers need to be managed by a xCAT Management Node (MN) which is to be created on a standalone System P7 server. There needs to be a proper ethernet network communication between the xCAT MN to the CMMs, and to all the compute node through the Ethernet Switch Module. The xCAT support uses the hardware type 'hwtype=blade' to manage the P7 Flex blade servers working through the CMM management module). IBM Flex xCAT will use a management type of 'mgt=fsp' to control the POWER 7 servers which is done through the xCAT DFM (Direct FSP Management)). For xCAT IBM Flex Power 7 servers, the management approach is mixture of 'blade' and 'fsp'. Most of the discovery work will be done through CMM and the hardware management work with the server's FSP directly.

### Terminology

The following terms will be used in this document:

xCAT DFM: Direct FSP Management is the name that we will use to describe the ability for xCAT software to communicate directly to the IBM FLex Power 7 server's service processor without the use of the HMC for management.

Chassis Management Module(CMM) - this term is used to reflect the pair of management modules installed in the rear of the chassis which have an Ethernet connection. The CMM is used to discover the servers within the chassis and for some data collection regarding the servers and chassis.

Compute node: This term is used to refer to the servers in an IBM Flex system. Compute nodes can be either Power 7 servers or x86 Intel based servers.

blade node: blade node refers to a node with the hwtype set to blade and represents the whole blade server. And the hcp attribute of the blade is set to the FSP's IP.

### Command Man Pages and Database Attribute Descriptions

  * All of the commands used in this document are described in the [xCAT man pages](http://xcat.sourceforge.net/man1/xcat.1.html).
  * All of the database attributes referred to in this document are described in the [xCAT database object and table descriptions](http://xcat.sourceforge.net/man5/xcatdb.5.html).

## Prepare the Management Node for xCAT Installation


[Prepare_the_Management_Node_for_xCAT_Installation](Prepare_the_Management_Node_for_xCAT_Installation)

**Note:** for Flex hardware, the switch configuration is only needed to discover (really to locate) the CMMs. The location of each blade is determined by the CMMs.

## Install xCAT on the Management Node


[Install_xCAT_on_the_Management_Node](Install_xCAT_on_the_Management_Node)

## Downloading and Installing DFM

This requires the new xCAT Direct FSP Management(dfm) plugin and hardware server(hdwr_svr) plugin, which are not part of the core xCAT open source, but are available as a free download from IBM. You must download this and install them on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document.

Download xCAT-dfm RPM: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&amp;release=All&amp;platform=All&amp;function=all

Download ISNM-hdwr_svr RPM: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+High+Performance+Computing+%28HPC%29+Hardware+Server&amp;release=All&amp;platform=All&amp;function=all

Download the suitable dfm and hdwr_svr packages for different OSes. Once you have downloaded these packages, install the hardware server package first, and then install DFM.

If you have been following the xCAT documentation, you should already have the yum repositories set up to pull in whatever xCAT dependencies and distro RPMs are needed (libstdc++.ppc, libgcc.ppc, openssl.ppc, etc.).

~~~~
    yum install xCAT-dfm-* ISNM-hdwr_svr-*
~~~~


## Use xCAT to Configure Services on the Management Node

### Setup /etc/hosts File

Since the map between the xCAT node names and IP addresses have been added in the xCAT database, you can run the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) xCAT command to create the /etc/hosts file from the xCAT database. (You can skip this step if you are creating /etc/hosts manually.)

~~~~
    makehosts switch,blade,cmm
~~~~


Verify the entries have been created in the file /etc/hosts.

### Setup DNS

To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN:

  * Ensure that /etc/sysconfig/named does not have ROOTDIR set
  * Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can't answer to these servers.

~~~~
    chdef -t site forwarders=1.2.3.4,1.2.5.6
~~~~


  * Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above, but is an easy way to test that your DNS is configured properly.)

~~~~
    search cluster
    nameserver 10.1.0.1
~~~~


  * Run makedns

~~~~
    makedns
~~~~


For more information about name resolution in an xCAT Cluster, see [Cluster_Name_Resolution].

### Setup DHCP

You usually don't want your DHCP server listening on your public (site) network, so set site.dhcpinterfaces to your MN's cluster facing NICs. For example:

~~~~
    chdef -t site dhcpinterfaces=eth1
~~~~


Then this will get the network stanza part of the DHCP configuration (including the dynamic range) set:

~~~~
    makedhcp -n
~~~~


The IP/MAC mappings for the nodes will be added to DHCP automatically as the nodes are discovered.

## Define the CMMs and Switches

[Define_the_CMMs_and_Switches](Define_the_CMMs_and_Switches)

## CMM Discovery and Configuration

[CMM_Discovery_and_Configuration](CMM_Discovery_and_Configuration)

## Create node object definitions of flex blade servers

There are different methods used to create the flex blade node objects in the xCAT database. One method is to create the predefined node objects, and then update the node objects using ""rscan -u "". The other method is to create ""rscan -z"", and then manually update the flex blade stanza file. The admin can then create the node objects using the stanza file.

### Create predefined nodes in the Database first and run rscan -u to Discovery

This implementation should only be used when there are uniformed blade configurations working in the chassis. If there are mixtures of single and double wide blades in the chassis, the admin will need to remove unused blade node objects.

First just create the predefined node based on cmm and blade location, add the list of blades and the groups they belong too:

~~~~
    nodeadd cmm[01-02]node[01-14] groups=all,blade
~~~~


Change the blade definitions with the common attributes.

~~~~
    chdef -t  group blade mgt=fsp cons=fsp
~~~~


The attribute 'mpa' should be set to the node name of cmm. The attribute 'slotid' should be set to the physical slot id of the blade. The attribute 'hcp' should be set to the IP that admin try to assign to the fsp of the blade. Use chdef with patterns that will map to the settings you require.

~~~~
    chdef -t group blade mpa='|cmm(\d+)node(\d+)|cmm($1)|'slotid='|cmm(\d+)node(\d+)|($2+0)|' hcp='|cmm(\d+)node(\d+)|10.0.($1+0).($2+0)|****'
~~~~


List the blade entries to review the blade the definitions created.

~~~~
    [root@c870f3ap01 ~]# nodels blade
    cmm01node01
    cmm01node03
    cmm01node05
    cmm01node07
    cmm01node09
    cmm01node10
    cmm01node11
~~~~


Use lsdef to check each entry to validate the hcp, slotid, and hsp attributes:

~~~~
    [root@c870f3ap01 ~]# lsdef cmm01node01
    Object name: cmm01node01
    cons=fsp
    groups=blade,all
    hcp=12.0.0.32
    hwtype=blade
    id=1
    mgt=fsp
    mpa=cmm01
    mtm=789542X
    nodetype=ppc,osi
    parent=cmm01
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
    serial=10F752A
    slotid=1
~~~~


#### Run rscan -u to discover all the compute node servers.

The **rscan -u** will match the xCAT nodes which have been defined in the xCAT database and update them instead of create a new one. It will also provide an error message that specifies if the blade node object is not found in the xCAT database. This type of error should happen when there is a configuration where the chassis contains both single wide and double wide blade configurations. The admin can execute the **rmdef** command for any unused blade node objects.

~~~~
    rscan cmm -u
~~~~


(For "rscan" details see: http://xcat.sourceforge.net/man1/rscan.1.html )

    If there are a mixture of single and double wide blade in the chassis, the admin should remove the unused blade objects from the xCAT DB.


~~~~
    rmdef  <cmmxxnodeyy>
~~~~


### Create object definition of flex blades by discovery using stanza files

This method is suggested when there are a different mix of flex blades being used in the flex blade cluster.

The rscan command reads the actual configuration of blade server in the CMM and creates node definitions in the xCAT database to reflect them. This command will create node objects for the target CMM, and the flex blades on the CMM in a stanza file. The admin should manually update the different nodes objects to specify the proper node names they want to use in the xCAT cluster. The admin may also want to change the hcp=&lt;FSP IP&gt; to be a different IP address than what was provided by DHCP server. If the CMM node object is already created, you can remove the CMM entries from the stanza file. You may need to add the "id=0" attribute to cmm objects.

There are unique differences between System P and System X Flex blade node objects working with rscan command. The big differences are the following attributes.

For System P Flex blades

~~~~
    mgt=fsp
    cons=fsp
    id=1
    slotid=<blade slot>
    hcp=<FSP IP>
~~~~


For System X Flex blades

~~~~
    mgt not set,   admin can update  with mgt=ipmi
    cons not set,  admin can update with cons=ipmi
    slotid=<blade slot>
    id attribute is not used
    there is no hcp
~~~~



Run the **rscan** command against all of the CMMs to create a stanza file for the definitions of all the compute node servers.

~~~~
    rscan cmm -z >nodes.stanza
~~~~


The Power 7 compute node stanza file is like this:

~~~~
    SN#YL10JH184084:
           objtype=node
           nodetype=ppc,osi
           slotid=1
           id=1
           mtm=789542X
           serial=10F69BA
           mpa=flexcmm01
           parent=flexcmm01
           hcp=70.0.0.41
           groups=blade,all
           mgt=fsp
           cons=fsp
           hwtype=blade
    SN#Y110UF18P003:
           objtype=node
           nodetype=ppc,osi
           slotid=3
           id=1
           mtm=789522X
           serial=10F75AA
           mpa=flexcmm01
           parent=flexcmm01
           hcp=70.0.0.22
           groups=blade,all
           mgt=fsp
           cons=fsp
           hwtype=blade
~~~~


In a stanza file, the user can get the blade server with the attributes hcp (fsp of the blade), mtm, serial and id attributions. For the stanza file above, the node SN#YL10JH184084 is a power blade(nodetype=ppc,hwtype=blade,mpa=cmm01). In order to easily access or operate those compute node servers, the user can edit the stanza file and give the node the name user want them to be for definition of each compute node server.

For Power 7 compute nodes the administrator will change the object name and hcp attribute for the IP of fsp. For example, the user can modify the definition of SN#YL10JH184084 as followings:

~~~~
    cmm01node01:
       objtype=node
       cons=fsp
       groups=blade,all
       hcp=70.0.0.41
       hwtype=blade
       slotid=3
       id=1
       mgt=fsp
       mpa=cmm01
       mtm=789542X
       nodetype=ppc,osi
       parent=flexcmm01
       serial=10F69BA
       slotid=1
~~~~


Then create the definitions in the database:

~~~~
    cat nodes.stanza | mkdef -z
~~~~


If CMM node objects are not updated from the target stanza file, make sure that the """id=0""" attribute is updated for the CMMs.

~~~~
     chdef cmm  id=0
~~~~


### Set the network configuration for the fsp

The FSP for the System P flex blade will initially be setup as a dynamic IP address. The admin can choose to use this IP, or has the option to change it to another static IP address in the service VLAN. This FSP IP is controlled by the ""hcp"" attribute for the node. You can use mkdef/chdef or rscan to update the hcp entries to set the proper FSP IP addresses. The rspconfig command with the network=* option will set the FSP IP address to the value you specified in the hcp attribute.

~~~~
    chdef  cmm01node01 hcp=12.0.0.101
    rspconfig blade network=*
~~~~


### Modify blade server device names

In order to conveniently manage the blade servers, the customer may want to have a cleaner name for the blade node. The following command can be used to modify a blade device name.

~~~~
    rspconfig singlenode textid="cmm01node01"
~~~~


The following command can be used to change a group of blade device name to the node names that are defined in xCAT DB.

~~~~
    rspconfig blade textid=*
~~~~


## Create the hardware server connection for the IBM Flex power 7 server

1\. Add the server's connections for the DFM management:

~~~~
    mkhwconn blade -t
~~~~


2\. check the connections are LINE_UP:

~~~~
    lshwconn blade
~~~~


3\. make sure the server powered on

~~~~
    rpower blade state
    rpower blade on
~~~~





### Update the FSP firmware (optional)

This is accomplished by using the rflash xCAT command from the xCAT Management node. The admin should download the supported GFW from the IBM Fix central website, and place it in a directory that is available to be read by the xCAT Management node. The default firmware option with rflash is working with "disruptive". Since the Flex blades work with DFM, the admin may use the rflash "deferred" firmware option which is listed in the Appendix.

1\. Use rinv command to get the current firmware levels of the blades' FSPs:

~~~~
    rinv bladenoderange firm
~~~~


(For "rinv" details see: http://xcat.sourceforge.net/man1/rinv.1.html )

2.Use the rflash command to update the firmware levels for the blades' FSPs. Then validate that the new firmware is loaded:

For firmware disruptive update, you should make sure the blade in power off state firstly.

~~~~
     rpower bladenoderange off
~~~~


And then use rflash to do the update:

~~~~
    rflash bladenoderange -p <directory> --activate disruptive
~~~~


(For "rflash" details see: http://xcat.sourceforge.net/man1/rflash.1.html )

~~~~
    rinv bladenoderange firm
~~~~


Note: If there is an error during the rflash update where the firmware is not loaded properly, you ran reference the firmware recovery procedure at the following xCAT document location.
[XCAT_Power_775_Hardware_Management/#recover-the-system-from-a-pp-situation-because-of-the-failed-firmware-update](XCAT_Power_775_Hardware_Management/#recover-the-system-from-a-pp-situation-because-of-the-failed-firmware-update).

3\. Verify that the blades are healthy, then power on and boot up the blades:

~~~~
    rpower bladenoderange state
    rvitals bladenoderange lcds
    rpower bladenoderange on
~~~~



(For "rvitals" details see: http://xcat.sourceforge.net/man1/rvitals.1.html )

## Prepare for Node Deployment

**rcons configuration**

  * It is important that the admin disable the Serial Over Lan (SOL) support on the CMM, so that xCAT DFM can control the remote console for the System P flex blades:

~~~~
    rspconfig cmm solcfg=disable
~~~~


  * Update conserver configuration

~~~~
    makeconservercf
~~~~


  * Check rcons. Before running rcons to open the console, make sure the Power 7 Servers are on:

~~~~
    rpower blade state  # if any of the nodes are off, then run...
    rpower blade on
~~~~


~~~~
    rcons onebladenode
~~~~


**Set the 'getmac' attribute to 'blade' **

~~~~
    chdef blade getmac=blade
~~~~


**Update the mac table with the MAC address of Each Blade**

In order to successfully deploy the OS you need to get the MAC for each blades in-band NIC that is connected to the management network and store it in the blade node object.

You can display all of the MACs for blades:

~~~~
    # getmacs cmm01node11 -d
    MAC Address 1: 34:40:b5:be:c0:08
    MAC Address 2: 34:40:b5:be:c0:0c
~~~~


To get the **first** MAC for each blade and store it in the database:

~~~~
    getmacs blade
~~~~


If you want to use the MAC for an adapter **other** than the first one, use the **-i** option of getmacs. For example:

~~~~
    getmacs blade -i eth1
~~~~


To display the MACs just collected:

~~~~
    # lsdef blade -ci mac
    cmm01node01: mac=34:40:b5:be:c0:08
    ...
~~~~


**Set the Boot String for Each Blade**

Ensure the blades are powered to onstandby (already done when collecting the MAC addresses).

~~~~
    rpower blade onstandby
~~~~



Then run [rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html) to set the blades to boot from the network first:

~~~~
    rbootseq blade net
~~~~


After using rbootseq to set the boot string, you should run rpower with reset to make the boot string permanent:

~~~~
    rpower blade reset
~~~~


Note: you can leave the blades always booting from the network first. Even for stateful nodes that have already been installed with a valid boot image on their hard disk, they will contact DHCP on the xCAT management node and it will instruct the nodes to boot from their hard disk.

## Update the IBM Flex Power 7 Server firmware

This is accomplished by using the rflash xCAT command from the xCAT Management node. The admin should download the supported GFW from the IBM Fix central website, and place it in a directory that is available to be read by the xCAT Management node.

1\. Use rinv command to get the current firmware levels of the IBM Flex Power 7 Server:

~~~~
    rinv bladenoderange firm (output to be added here)
~~~~


2.Use the rflash command to update the firmware levels for the IBM Flex Power 7 Server. Then validate that the new firmware is loaded:

For firmware disruptive update, you should make sure the server in power off state firstly.

~~~~
     rpower bladenoderange state
     rpower bladenoderange off
~~~~


And then use rflash to do the update:

~~~~
    rflash bladenoderange -p <directory> --activate disruptive
    (output to be added here)
    rinv bladenoderange firm
~~~~


3\. Verify that the blades are healthy and power on the servers:

~~~~
    rpower bladenoderange state
    rpower bladenoderange on
~~~~


## Deploying an OS on the Blades

  * If you want to define one or more stateless (diskless) OS images and boot the nodes with those, see section [XCAT_system_p_support_for_IBM_Flex/#deploying-stateless-nodes](XCAT_system_p_support_for_IBM_Flex/#deploying-stateless-nodes). This method has the advantage of managing the images in a central place, and having only one image per node type.
  * In you want to install your nodes as stateful (diskful) nodes, follow section [XCAT_system_p_support_for_IBM_Flex/#installing-stateful-nodes](XCAT_system_p_support_for_IBM_Flex/#installing-stateful-nodes).
  * If you want to have nfs-root statelite nodes, see [XCAT_Linux_Statelite]. This has the same advantage of managing the images from a central place. It has the added benefit of using less memory on the node while allowing larger images. But it has the drawback of making the nodes dependent on the management node or service nodes (i.e. if the management/service node goes down, the compute nodes booted from it go down too).
  * If you have a very large cluster (more than 500 nodes), at this point you should follow [Setting_Up_a_Linux_Hierarchical_Cluster] to install and configure your service nodes. After that you can return here to install or diskless boot your compute nodes.

## Deploying Stateless Nodes

**Note: this section is included from another document. Some of the examples refer to "x86_64". Just substitute "ppc64" instead.**


[Using_Provmethod=osimagename](Using_Provmethod=osimagename)

~~~~
    rpower blade boot
~~~~


## Installing Stateful Nodes

**Note: this section is included from another document. Some of the examples refer to "x86_64". Just substitute "ppc64" instead. Also, the rsetboot command is not necessary with Flex Power 7 blades.**


[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes)

## Appendix 1: IBM Flex Recovery and CMM Redundancy

The CMM is the gateway for the hardware management and monitoring communication for the Flex chassis and the Flex P7 blades. If you lose the network communication between the xCAT MN and the primary CMM, you can not execute any hardware management commands to the CMM or blades. If the Flex P7 blades and Ethernet SM are running, the blades should be able to keep running for some time.

### Replacement of CMM

If you only have one CMM configured in your Flex chassis, you will need to work with IBM service to fix this CMM quickly, since you will not be able to properly manage the Flex blades until you have a working CMM. The CMM replacement activity is to execute CMM HW discovery on new CMM, where you locate the new MAC address and current DHCP dynamic IP address for CMM. You then update the CMM node object's "mac" and "otherinterfaces" attributes with data found from hardware discovery. Once the CMM node object has new data, we execute the configuration CMM steps working with rspconfig. Once the CMM is configured using the static IP, the DHCP and mac address is not referenced.

The following scenario is to replace the CMM working with node object "cmm01" with a static IP of 10.1.100.1.

Locate new mac and DHCP IP for replacement CMM
~~~~
     lsslp -m -z -s CMM > /tmp/cmm01.stanza   
~~~~

Update cmm01 object with new mac and current DHCP IP

~~~~     
     chdef cmm01 otherinterfaces=<dhcpip> mac=<macaddr>  
~~~~

Set password for USERID for new cmm0

~~~~
     rspconfig cmm01 USERID=<new_passwd>  1
~~~~

Set new cmm01 back to original static IP

~~~~
     rspconfig cmm01 initnetwork=*
~~~~

Enable ssh and snmp for new cmm01

~~~~      
     rspconfig cmm01 sshcfg=enable snmpcfg=enable  
~~~~


### CMM Redundancy

The recommended support strategy with xCAT is to setup each Flex chassis with 2 CMM's where the primary CMM is located in bay 1 and the standby CMM is in bay 2. Each CMM needs to have their own ethernet connection into the xCAT HW VLAN, and the primary CMM must be configured as a static IP that is listed in the xCAT DB. The xCAT MN only can communicate with the primary CMM when executing hardware management commands. The Standby CMM is only there as a backup, and will take ownership as the primary CMM using the same static IP. The xCAT Flex only supports the default CMM redundancy configuration, and does not support the advanced failover settings. The activity for CMM fail over is that the standby CMM takes over the roll of the primary CMM, and that failed CMM is setup as the standby CMM when registered by the Flex chassis. The xCAT MN will lose it's network connection to the primary CMM during the CMM fail over, but will automatically reconnect back to the new primary CMM when it completes the failover in about 3-4 minutes

The fail over from the primary CMM to the standby CMM happens in the following scenarios.

     Admin executes software failover from the CMM GUI
     Admin executed software failover using the CMM CLI
     Admin physically pulls out primary CMM from the Flex chassis


#### Fail over software reset from CMM GUI

The admin will have a network connection into the CMM, and has activated the CMM GUI. They will reference the "Mgt Module Management" and select on the "Restart" . The admin selects the "Restart and Switch to Standby Management Module" . This will cause the primary CMM to reset, and will change the setting of primary to the "Standby CMM" which now becomes the new primary CMM when the fail over completes.

#### Fail over software reset from CMM CLI

The admin will have a network connection into the CMM, and has a ssh connection into primary CMM with USERID from xCAT MN. The admin use CMM CLI command "env -T" to get to the primary CMM then executes command "reset -f" for the CMM failover. This will cause the primary CMM to reset, and will change the setting of primary to the "Standby CMM" which now becomes the new primary CMM when the fail over completes.

~~~~
     # ssh USERID@cmm01
      Hostname:              cmm01
      Static IP address:     10.0.100.1
      Burned-in MAC address: 5F:FF:FF:FF:FF:FF
      DHCP:                  Disabled - Use static IP configuration.
     system> env -T system:mm[1]
     OK
     system:mm[1]> reset -f
~~~~


#### Fail over hardware reset of CMM

The scenario is when there is a physical activity where the primary CMM is pulled from the chassis. There are different reasons why the admin may want pull out the CMM. This could be when the CMM is no longer working properly or there is an issue with the ethernet interface of the primary CMM. At this time when the primary CMM is pulled, it will do an automatic failover to the standby CMM, and the standby CMM is now the primary. The admin can work IBM or network support to understand the CMM or network failure. When the failed CMM is ready, the admin can just plug it in the Flex chassis, and it will now become the new Standby CMM. The admin can schedule a CMM software fail over if they want to swap back to the original CMM primary.

## Appendix 2: CMM and Flexible Service Processor(FSP) password

In the IBM Flex chassis the architecture is designed to simplify some aspects of the systems management of the chassis. As part of this goal the IBM Flex system has integrated the CMM USERID and password into the IBM Flex system p compute nodes FSP. This is done through an internal LDAP server on the CMM serving the userids and passwords to LDAP on the FSPs. What this means to the system xCAT administrator is that the CMM USERID is tightly coupled with xCAT DFM authentication of the FSP. xCAT hardware control failures to authenticate on the FSP is likely the result of an issue with the chassis CMM USERID password. This section will provide commands which will help you determine that you have an authentication problem, verify that its an issue with the CMM USERID password, as well as how to resolve the problem.

### Errors caused by an FSP authentication problem

The system administrator may first notice a problem with some of the hardware control 
commands giving an authentication error.

~~~~
   rpower cmm01node01 stat
    cmm01node01: Error: state=CEC AUTHENTICATION FAILED, 
       type=02, MTMS=7895-42X*10F752A, sp=primary, slot=A, ipadd=12.0.0.32, 
           alt_ipadd=unavailable
~~~~


Checking the connection to the FSP shows that the authenication for this FSP is failing:

~~~~
    lshwconn cmm01node01
    cmm01node01: sp=primary,ipadd=12.0.0.32,alt_ipadd=unavailable,state=CEC 
         AUTHENTICATION FAILED
~~~~


This could be caused by the USERID password being expired on the CMM. You can check with the following:

~~~~
    ssh USERID@cmm01 users -T mm[1]
    system> users -T mm[1]
    Users
    =====
    USERID
      Group(s): supervisor
      Max 0 session(s) allowed
      1 active session(s)
      Account is active
      **Password is expired**
      Password is compliant
      Number of SSH public keys installed for this user: 3
    User Permission Groups
    ======================

~~~~


In order to correct this problem you need to activate the CMM USERID and then remove and add the connections to the FSP.

~~~~
     ssh USERID@cmm01 accseccfg -pe 0 -T mm[1]
~~~~


Checking the USERID password is active:

~~~~
     ssh USERID@cmm01 users -T mm[2]
    system> users -T mm[2]
    Users
    =====
    USERID
      Group(s): supervisor
      Max 0 session(s) allowed
      1 active session(s)
      **Account is active**
      Password does not expire
      Password is compliant
      Number of SSH public keys installed for this user: 3
    User Permission Groups
    ======================
~~~~


Second you need to remove and add back each FSP connection for this chassis to create new connections:

~~~~
     rmhwconn cmm01node01
     mkhwconn cmm01node01 -t
~~~~


The last step is to check the connection:

~~~~
    lshwconn cmm01node01
    cmm01node01: sp=primary,ipadd=12.0.0.32,alt_ipadd=unavailable,state=LINE UP
~~~~


## Appendix 3: Updating Firmware on Flex Ethernet and IB Switch Modules

This section provides manual procedures to help update the firmware for Ethernet and Infiniband (IB) Switch modules. There is more detail information can be referenced in the IBM Flex System documentation under Network switches: http://publib.boulder.ibm.com/infocenter/flexsys/information/

The IB6131 Switch module is a Mellanox IB switch, and you down load firmware (image-PPC_M460EX-SX_3.2.xxx.img) from the Mellanox website into your xCAT Management Node or server that can communicate to Flex IB6131 switch module. We provided the firmware update procedure for the Mellanox IB switches including IB6131 Switch module in our xCAT document Managing the Mellanox Infiniband Network: [Managing_the_Mellanox_Infiniband_Network/#mellanox-switch-and-adapter-firmware-update](Managing_the_Mellanox_Infiniband_Network/#mellanox-switch-and-adapter-firmware-update).

The IBM Flex system supports Ethernet switch modules models (EN2092 (1GB), EN4093 (10GB), and the firmware is available from the IBM Support Portal http://www-947.ibm.com/support/entry/portal/overview?brandind=hardware~puresystems~pureflex_system. The firmware update procedure used with the Flex Ethernet (EN2092) switch module which will reference two firmware images for **OS** (GbScSE-1G-10G-7.5.1.xx_OS.img) and **Boot** (GbScSE-1G-10G-7.5.1.x_Boot.img). These images should be placed on the xCAT MN or FTP server in the **/tftpboot** directory. Make sure that this server has proper ethernet communication to the Ethernet switch module.

#### Firmware Update using CLI

1) Login to the Ethernet switch using the "admin" userid and specify the admin password.

~~~~
       ssh admin@<switchipaddr>
~~~~


2) Get into boot directory, and list current image settings with cur command. This includes 2 OS images called image1 and image2,and will specify which image is the current boot image.

~~~~
       >> boot
       >> cur
~~~~


3) Get the new Ethernet **OS** image file from the ftp server to replace the older image on the ethernet switch using **gtimg** command. The gtimg command will prompt you for full path OS image file name, ftp/root userid, and password. It will ask to specify "data" port, and a confirmation to complete the download, and flashes the update. An example of EN2092 OS image would be "GbScSE-1G-10G-7.5.1.0_OS.img", and replaces "image2" on the ethernet switch.

~~~~
       >> gtimg image2 <FTP server> GbScSE-1G-10G-7.5.1.0_OS.img
          Enter name of file on FTP/TFTP server: /tftpboot/GbScSE-1G-10G-7.5.1.0_OS.img
          Enter username for FTP server or hit return for TFTP server: root
          Enter password for username on FTP server:  <root password>
          Enter the port to use for downloading the image ["data"|"mgt"]: "data"
          Confirm download operation [y/n]: y
~~~~


4) Get the new Ethernet **boot** image file from the ftp server to replace cuurent boot image on the ethernet switch using **gtimg** command. The gtimg command will prompt you for full path OS image file name, ftp/root userid, and password. It will ask to specify "data" port, and a confirmation to complete the download, and flashes the update. An example of EN2092 OS image would be "GbScSE-1G-10G-7.5.1.0_Boot.img", and will point to new boot image2.

~~~~
       >> gtimg image2 <FTP server> GbScSE-1G-10G-7.5.1.0_Boot.img
          Enter name of file on FTP/TFTP server: /tftpboot/GbScSE-1G-10G-7.5.1.0_Boot.img
          Enter username for FTP server or hit return for TFTP server: root
          Enter password for username on FTP server:  <root password>
          Enter the port to use for downloading the image ["data"|"mgt"]: "data"
          Confirm download operation [y/n]: y
~~~~


5) Validate the current image settings with **cur** command, where image2 now has the latest firmware level, and that the current boot image is working with latest image2 file. You can then execute the **reset** command to boot the ethernet switch using the latest firmware level.

~~~~
       >> cur
       >> reset
~~~~


## **Appendix 4 Perform Deferred Firmware upgrades for Flex blade CEC **

#### **Deferred firmware update Background**

It may take some time to execute a disruptive firmware update in a large cluster. To reduce the down time of the cluster, customers may want to flash new firmware levels while the Flex blades are up and running, The deferred firmware update will load the new firmware into the T (temp) side, but will not activate it like the disruptive firmware. The customer can continue to run with the P (perm) side and can wait for a maintenance window where they can activate and boot the blades/cec with new firmware levels.

#### **temp/perm side, pending_power_on_side attributes in Deferred firmware update**

The deferred firmware update includes 2 parts: The first part (1) is to apply the firmware to the T (temp) sides of Flex blade FSPs when the cluster is up and running. The second part (2) is to activate the new firmware on the blades at a scheduled time.

The default setting is that the CEC/FSPs are working from the temp side (current_power_on_side). During part(1) of the deferred firmware update implementation, the CEC will continue to run on the perm side while the rflash of the new firmware levels will installed to the temp side. It is very important that the perm side contains the current stable version of firmware. The perm side is usually only used as a recovery environment when working with firmware updates.

When executing a reboot to the blade (FSPs), it will run on the side which the pending_power_on_side attribute is set. After we finish the part (1), the admin will want to make sure the pending_power_on_side attribute is set to "perm" if the blades want to be rebooted working with the older stable firmware. When you are ready to activate the new firmware and reboot the blades, you will want to make sure the pending_power_on_side attribute is set to "temp".

#### **The procedure of the deferred firmware update **

Before starting the deferred firmware update, the admin should first make sure that the most recent stable firmware level has been applied to the P (perm) side. We should note that T-side firmware will be moved over to the P-side automatically when we execute the rflash of the new firmware into the T (temp) side.

1.1 Apply the firmware for Flex blades

~~~~
      rinv <blade> firm
~~~~


1.2 Apply the new GFW code into the blade's FSPs

~~~~
      rflash <blade> -p <rpm_directory> --activate deferred
~~~~


1.3 Check to make sure the proper Firmware levels have been loaded into the temp side (new) and the perm side (previous) for the Frames or CECs. The rflash working with "deferred" should now specify Current Power on side to now be "perm":

~~~~
      rinv <blade> firm
~~~~


2\. Setup Cecs/blades pending power to Perm (needed for CEC/blade reboot -- power off/on)

In part 1, the new firmware is now loaded on the temp side. If you need to keep the Flex blade active for a period of time (such as several days) we need to make sure we are working with previous firmware level, which is running on the P-side. You should change the pending_power_on_side attribute from temp to perm.

~~~~
      rspconfig <blade> pending_power_on_side
~~~~
      If not, set CEC's the pending power on side to P-side:
~~~~
      rspconfig <blade> pending_power_on_side=perm
~~~~


3.Activate the new firmware at schedule time

The new firmware level has been loaded on the temp side, and it is time to activate the blade/CECs with new firmware level. The admin should make sure the pending_power_on_side is now set back from perm to temp.

3.1 Check if the pending power on side for CEC are on T-side

~~~~
      rspconfig <blade> pending_power_on_side
      If not, set the pending power on side to T-side
      rspconfig <blade> pending_power_on_side=temp
~~~~


3.2 Power off the target Flex blades

~~~~
      rpower <blade> off
~~~~


3.3 Reboot the service processor for the CECs/blade

~~~~
       rpower <blade> resetsp
~~~~


Wait for 5-10 minutes for FSPs to restart. When the connections become LINE_UP again, the FSPs have finished the reboot.

~~~~
       lshwconn <blade>
~~~~


3.4 Verify that the cec/blade updates are the new firmware level and that they are using the temp side for the current_power_on_side .

~~~~
       rinv <blade> firm
~~~~


3.5 Power on the Flex blades and bring up the Flex blade cluster. The power on of the flex blades will be based on the install environment.

If this is a diskful environment, the admin should be able to "rpower &lt;blade> on " to bring the blade up on the local disk.

~~~~
      rpower  <blade> on
~~~~


If this is a diskless environment, the admin should power up the blade to onstandby, set the boot sequence to network, and reset the blade.

~~~~
      rpower <blade> onstandby
      rbootseq <blade> net
      rpower <blade> reset
~~~~





## Appendix 5 lshwconn LINE DOWN after power outage

Testing has shown that when a chassis looses power and is started back up it is possible that the connections to the blade FSPs will be LINE DOWN. If this occurs you should reset the CMM for the chassis with this problem.

~~~~
     ssh USERID@cmm01 service -T mm[1] -vr
~~~~


## **Appendix 6: Migrate your Management Node to a new Service Pack of Linux**

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


The documentation [Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux)  gives a sample procedure on how to update the management node or service nodes to a new service pack of Linux.

## **Appendix 7: Install your Management Node to a new Release of Linux**

First backup critical xCAT data to another server so it will not be loss during OS install.

  * Back up the xcat database using xcatsnap, important config files and other system config files for reference and for restore later. Prune some of the larger tables:

~~~~
     tabprune eventlog -a
     tabprune auditlog -a
     tabprune isnm_perf -a (Power 775 only)
     tabprune isnm_perf_sum -a (Power 775 only)
     xcatsnap
~~~~

xcatsnap will capture database, config files. You should copy to another host. By default it will create in /tmp/xcatsnap two files, for example:
~~~~
     xcatsnap.hpcrhmn.10110922.log
     xcatsnap.hpcrhmn.10110922.tar.gz
~~~~
Back up from /install directory, all images, custom setup data that you want to save. and move to another server. xcatsnap will not backup the install directory.

After the OS install:

  * Proceed to to setup the xCAT MN as a new xCAT MN using the instructions in this document.

