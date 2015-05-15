<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Terminology](#terminology)
  - [Overview of Cluster Setup Process](#overview-of-cluster-setup-process)
  - [Example Networks and Naming Conventions Used in This Document](#example-networks-and-naming-conventions-used-in-this-document)
  - [Distro-specific Steps](#distro-specific-steps)
  - [Command Man Pages and Database Attribute Descriptions](#command-man-pages-and-database-attribute-descriptions)
- [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
- [Install xCAT on the Management Node](#install-xcat-on-the-management-node)
- [Use xCAT to Configure Services on the Management Node](#use-xcat-to-configure-services-on-the-management-node)
  - [Setup DNS](#setup-dns)
  - [Setup DHCP](#setup-dhcp)
  - [Setup TFTP](#setup-tftp)
  - [Setup conserver](#setup-conserver)
- [Define the CMMs and Switches](#define-the-cmms-and-switches)
- [CMM Discovery and Configuration](#cmm-discovery-and-configuration)
- [Create node object definitions of System X flex blade servers](#create-node-object-definitions-of-system-x-flex-blade-servers)
  - [Option 1: Pre-define Nodes and Run rscan -u](#option-1-pre-define-nodes-and-run-rscan--u)
  - [Option 2: Run rscan -z to Generate a Node Stanza File](#option-2-run-rscan--z-to-generate-a-node-stanza-file)
  - [Option 3: Pre-define Nodes and Run slpdiscover for xCAT 2.7](#option-3-pre-define-nodes-and-run-slpdiscover-for-xcat-27)
  - [Setup /etc/hosts File](#setup-etchosts-file)
  - [Configure the Blades](#configure-the-blades)
    - [Set the network configuration for the IMM](#set-the-network-configuration-for-the-imm)
    - [Set the password for the IMM](#set-the-password-for-the-imm)
    - [Modify blade server device names](#modify-blade-server-device-names)
    - [Using ASU to Update Hardware Settings on the Nodes](#using-asu-to-update-hardware-settings-on-the-nodes)
- [Collect the MAC Addresses in Preparation for Deployment](#collect-the-mac-addresses-in-preparation-for-deployment)
- [Deploying an OS on the Blades](#deploying-an-os-on-the-blades)
- [Deploying Stateless Nodes](#deploying-stateless-nodes)
- [Installing Stateful Nodes](#installing-stateful-nodes)
  - [**Begin Installation**](#begin-installation)
- [Where Do I Go From Here?](#where-do-i-go-from-here)
- [Appendix 1: Update the CMM firmware](#appendix-1-update-the-cmm-firmware)
- [Appendix 2: Update the Blade Node Firmware](#appendix-2-update-the-blade-node-firmware)
- [Appendix 3: Updating Firmware on Flex Ethernet and IB Switch Modules](#appendix-3-updating-firmware-on-flex-ethernet-and-ib-switch-modules)
    - [Firmware Update using CLI](#firmware-update-using-cli)
- [Appendix 4: Run Discovery](#appendix-4-run-discovery)
  - [Checking the Result of the slpdiscover or lsslp --flexdiscover Command](#checking-the-result-of-the-slpdiscover-or-lsslp---flexdiscover-command)
- [**Appendix 5: Migrate your Management Node to a new Service Pack of Linux**](#appendix-5-migrate-your-management-node-to-a-new-service-pack-of-linux)
- [**Appendix 6: Install your Management Node to a new Release of Linux**](#appendix-6-install-your-management-node-to-a-new-release-of-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

IBM Flex combines networking, storage, and compute nodes in a single offering. It's consist of an IBM Flex Chassis, one or two Chassis Management Modules(CMM) and compute nodes. The compute nodes include the IBM Flex System™ p260, p460, and 24L Power 7 servers as well as the IBM Flex System™ x240 x86 server. **In this document only the management of x240 blade server will be covered.**

### Terminology

The following terms will be used in this document: 

  * **MN** \- the xCAT management node. 
  * **Chassis Management Module (CMM)** \- management module(s) installed in the rear of the chassis and connected by ethernet to the MN. The CMM is used to discover the blades within the chassis and for some data collection regarding the blades and chassis. 
  * **Blade** \- the compute nodes with the chassis. 
  * **IMM** \- the Integrated Management Module in each blade that is use to control the blade hardware out-of-band. Also known as the BMC (Baseboard Management Controller). 
  * **Switch Modules** \- the ethernet and IB switches within the chassis. 

### Overview of Cluster Setup Process

Here is a summary of the steps required to set up the cluster and what this document will take you through: 

  1. Prepare the management node - doing these things before installing the xCAT software helps the process to go more smoothly. 
  2. Install the xCAT software on the management node. 
  3. Configure some cluster wide information 
  4. Define a little bit of information in the xCAT database about the ethernet switches and nodes - this is necessary to direct the node discovery process. 
  5. Have xCAT configure and start several network daemons - this is necessary for both node discovery and node installation. 
  6. Discovery the nodes - during this phase, xCAT configures the BMC's and collects many attributes about each node and stores them in the database. 
  7. Set up the OS images and install the nodes. 

### Example Networks and Naming Conventions Used in This Document

In the examples used throughout in this document, the following networks and naming conventions are used: 

  * The service network: 10.0.0.0/255.255.0.0 
    * The CMMs have IP addresses like 10.0.50.&lt;chassisnum&gt; and hostnames like cmm&lt;chassisnum&gt;
    * The blade IMMs have IP addresses like 10.0.&lt;chassisnum&gt;.&lt;bladenum&gt;
    * The switch management ports have IP addresses like 10.0.60.&lt;switchnum&gt; and hostnames like switch&lt;switchnum&gt;
  * The management network: 10.1.0.0/255.255.0.0 
    * The management node IP address is 10.1.0.1 
    * The OS on the blades have IP addresses like 10.1.&lt;chassisnum&gt;.&lt;bladenum&gt; and hostnames like cmm&lt;chassisnum&gt;node&lt;bladenum&gt;

### Distro-specific Steps

  * [RH] indicates that step only needs to be done for RHEL and Red Hat based distros (CentOS, Scientific Linux, and in most cases Fedora). 
  * [SLES] indicates that step only needs to be done for SLES. 

### Command Man Pages and Database Attribute Descriptions

  * All of the commands used in this document are described in the [xCAT man pages](http://xcat.sourceforge.net/man1/xcat.1.html). 
  * All of the database attributes referred to in this document are described in the [xCAT database object and table descriptions](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

## Prepare the Management Node for xCAT Installation

[Prepare_the_Management_Node_for_xCAT_Installation](Prepare_the_Management_Node_for_xCAT_Installation)

[Configure_ethernet_switches](Configure_ethernet_switches) 

  
**Note:** for Flex hardware, the switch configuration is only needed to discover (really to locate) the CMMs. The location of each blade is determined by the CMMs. 

## Install xCAT on the Management Node

[Install_xCAT_on_the_Management_Node](Install_xCAT_on_the_Management_Node) 

## Use xCAT to Configure Services on the Management Node

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

### Setup TFTP

Nothing to do here - the TFTP server configuration was done by xCAT when it was installed on the Management Node. 

### Setup conserver
 
~~~~   
    makeconservercf
~~~~    

## Define the CMMs and Switches

[Define_the_CMMs_and_Switches](Define_the_CMMs_and_Switches) 

## CMM Discovery and Configuration

[CMM_Discovery_and_Configuration](CMM_Discovery_and_Configuration) 

## Create node object definitions of System X flex blade servers

There are multiple options for getting the blades defined in the xCAT database: The first 2 options are to be used for xCAT 2.8 and later releases. The third option is to be used for our System X flex blade support with xCAT 2.7. 

  * **Option 1:** Pre-define skeleton blade objects in the database and then use rscan -u to update them with specific data for each blade (e.g. serial # and mac). 
  * **Option 2:** Run rscan -z to create a node stanza file of all of the blade definitions. Edit the file to provide your own node names, and then pipe the file into mkdef. 
  * **Option 3:** Pre-define skeleton blade objects in the database and then use slpdiscover to update them with specific data for each blade (e.g ipmi table, mac). 

### Option 1: Pre-define Nodes and Run rscan -u

This implementation is most useful when you have uniform blade configurations. If there is a mixture of single and double wide blades in the chassis, you will have to remove the unused blade node definitions in the database after doing the mkdef below. 

First, pre-define the blades. It is easiest to base the node names on the cmm and slot location: 

~~~~    
    mkdef cmm[01-02]node[01-14] groups=blade,all
~~~~    

At a group level, define the [node attributes](http://xcat.sourceforge.net/man7/node.7.html) that are the same for all blades: 

~~~~    
    chdef -t group blade mgt=ipmi cons=ipmi getmac=blade nodetype=mp,osi hwtype=blade installnic=mac \
    profile=compute netboot=xnba arch=x86_64
~~~~    

Now define the node attributes that vary for each blade: 

  * **mpa**: the node name of the CMM this blade is in. 
  * **slotid**: the physical chassis slot id that this blade is in. 
  * **bmc**: the static IP address that admin wants assigned to the IMM of the blade. 

You can use regular expressions for this to define the atrributes for all blades in one command
See
[Listing_and_Modifying_the_Database/#using-regular-expressions-in-the-xcat-tables](Listing_and_Modifying_the_Database/#using-regular-expressions-in-the-xcat-tables)
 for an explanation of how to use regular expressions in the xCAT database): 
  
~~~~  
    chdef -t group blade mpa='|cmm(\d+)node(\d+)|cmm($1)|' \
    slotid='|cmm(\d+)node(\d+)|($2+0)|' bmc='|cmm(\d+)node(\d+)|10.0.($1+0).($2+0)|
~~~~    

To ensure that the attribute values are set the way you want them to be, list one node: 

~~~~    
    lsdef cmm02node05 -i mpa,slotid,bmc
    Object name: cmm02node05
      bmc=10.0.2.5
      mpa=cmm02
      slotid=5 
~~~~    

Now run rscan -u to discover all the blade servers and add the hardware-related attributes to the node skeleton definitions you previously created. The 'rscan -u' command will match the xCAT nodes which have been defined in the xCAT database with the actual blades in the chassis and get attributes like the serial number and mac. 
 
~~~~   
    rscan cmm -u
~~~~    

Note: If you get an error message in hardware control commands later on that a blade can't be communicated with, it could be that the chassis contains both single wide and double wide blade configurations, so you have some blade definitions in the database that don't actually exist in the chassis. If this is the case, use the rmdef command to remove the appropriate blade node objects. 

### Option 2: Run rscan -z to Generate a Node Stanza File

Note: This method is suggested when you have a mix of single and double-wide flex blades. 

The rscan -z command reads the actual configuration of chassis and creates node definitions in a stanza file for the CMMs and each blade. The stanza file should have all of the correct node attributes that can be piped into chdef, except the node names. This is because xCAT doesn't yet have any way of knowing what node name you want each blade to have. Therefore, you need to manually edit the file to change the node names to what you want to use. 

Run the [rscan](http://xcat.sourceforge.net/man1/rscan.1.html) command against all of the CMMs to create a stanza file that contains all of the blades: 

~~~~    
    rscan cmm -z >nodes.stanza
~~~~    

The following is a sample of the stanza data of one blade from rscan: 

~~~~    
    sn#y030bg168034:
           objtype=node
           nodetype=mp
           slotid=5
           mtm=8737AC1
           serial=xxxxxxx
           mpa=cmm02
           groups=xblade,all
           mgt=ipmi
           cons=ipmi
           hwtype=blade
~~~~    

For a description of each attribute, see [node attributes](http://xcat.sourceforge.net/man7/node.7.html). 

Edit nodes.stanza and do 2 things: 

  * Remove the stanzas for the CMMs (because you already have those defined in the database). You can identify the CMM stanzas as the ones with "hwtype=cmm" and "id=0". 
  * Replace the node name of each blade stanza with the node name you want that blade to have. The node names are the lines that are **not** indented and usually start with "sn#" and then the serial number. 

Then pipe this into chdef to create the node definitions in the database: 
  
~~~~  
    cat nodes.stanza | chdef -z
~~~~    

### Option 3: Pre-define Nodes and Run slpdiscover for xCAT 2.7

The support for System X flex blades in xCAT 2.7 follows similar support as the previous x blades. There were modifications made in xCAT 2.8 to enhance the xCAT Flex blade support. The main differences in xCAT 2.7 is that hwtype and getmacs attributes are not used. The id (not slotid) attribute is used to reference the physical slot location. The rscan command does not support System X flex blades, where the slpdiscover command is used to update ipmi hardware information for each blade. 

This implementation is most useful when you have uniform blade configurations. If there is a mixture of single and double wide blades in the chassis, you will have to remove the unused blade node definitions in the database after doing the mkdef below. 

First, pre-define the blades. It is easiest to base the node names on the cmm and slot location: 

~~~~    
    mkdef cmm[01-02]node[01-14] groups=blade,all
~~~~    

At a group level, define the [node attributes](http://xcat.sourceforge.net/man7/node.7.html) that are the same for all blades: 

~~~~    
    chdef -t group blade mgt=ipmi cons=ipmi nodetype=mp,osi installnic=mac \
    profile=compute netboot=xnba arch=x86_64
~~~~    

Now define the node attributes that vary for each blade: 

  * **mpa**: the node name of the CMM this blade is in. 
  * **id**: the physical chassis slot id that this blade is in. 
  * **bmc**: the static IP address that admin wants assigned to the IMM of the blade. 

You can use regular expressions for this to define the attributes for all blades in one command, see 
[Listing_and_Modifying_the_Database/#using-regular-expressions-in-the-xcat-tables](Listing_and_Modifying_the_Database/#using-regular-expressions-in-the-xcat-tables)
 for an explanation of how to use regular expressions in the xCAT database): 
 
~~~~   
    chdef -t group blade mpa='|cmm(\d+)node(\d+)|cmm($1)|' \
    id='|cmm(\d+)node(\d+)|($2+0)|' bmc='|cmm(\d+)node(\d+)|10.0.($1+0).($2+0)|
~~~~    

To ensure that the attribute values are set the way you want them to be, list one node: 

~~~~    
    lsdef cmm02node05 -i mpa,id,bmc
    Object name: cmm02node05
      bmc=10.0.2.5
      mpa=cmm02
      id=5 
~~~~    

Now run slpdiscover to discover the blade servers and add the hardware-related attributes for the nodes. The 'slpdiscover' command matches the xCAT nodes defined in the xCAT database with the actual blades in the chassis and updates the ipmi table. 

~~~~    
    slpdiscover
~~~~    

  


### Setup /etc/hosts File

Since the map between the xCAT node names and IP addresses have been added in the xCAT database, you can run the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) xCAT command to create the /etc/hosts file from the xCAT database. (You can skip this step if you are creating /etc/hosts manually.) 

~~~~    
    makehosts switch,blade,cmm
~~~~    

Verify the entries have been created in the file /etc/hosts. 

  


Push the entries into the DNS: 

  
~~~~
    
    makedns
~~~~    

### Configure the Blades

#### Set the network configuration for the IMM

Use the rspconfig command to set the IMM IP address to a permanent static IP address. 
 
~~~~   
    rspconfig blade network=*
~~~~    

#### Set the password for the IMM

If you are initializing the flex blade IMM for the first time 

~~~~    
      rspconfig blade USERID=*
~~~~    

If the password for CMM and the flex blade IMM have issues and are not in sync, the admin can reset the passwords for both the CMM and IMMs in the chassis by running . 
 
~~~~   
      rspconfig cmm01  USERID=<password> updateBMC=y
~~~~    

#### Modify blade server device names

You may want to change IMM device name of each blade (the name the CMM knows it by) to be the same as the xCAT node name of the blade: 
  
~~~~  
    rspconfig blade textid=*
~~~~    

#### Using ASU to Update Hardware Settings on the Nodes

For Flex system x blades you need to set the following hardware settings to enable the console (for rcons): 
 
~~~~   
    set DevicesandIOPorts.Com1ActiveAfterBoot Enable
    set DevicesandIOPorts.SerialPortSharing Enable
    set DevicesandIOPorts.SerialPortAccessMode Dedicated
    set DevicesandIOPorts.RemoteConsole Enable
~~~~    

 
See [XCAT_iDataPlex_Advanced_Setup/#using-asu-to-update-cmos-uefi-or-bios-settings-on-the-nodes](XCAT_iDataPlex_Advanced_Setup/#using-asu-to-update-cmos-uefi-or-bios-settings-on-the-nodes) for how to set these ASU settings. 

## Collect the MAC Addresses in Preparation for Deployment

In order to successfully deploy the OS you need to get the MAC for each blades in-band NIC that is connected to the management network and store it in the blade node object. 

You can display all of the MACs for blades: 
 
~~~~   
    rinv cmm01node11 mac
    cmm01node11: MAC Address 1: 34:40:b5:be:c0:08
    cmm01node11: MAC Address 2: 34:40:b5:be:c0:0c
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
     lsdef blade -ci mac
    cmm01node01: mac=34:40:b5:be:c0:08
    ...
~~~~    

## Deploying an OS on the Blades

  * If you want to define one or more stateless (diskless) OS images and boot the nodes with those, see section [XCAT_system_x_support_for_IBM_Flex/#deploying-stateless-nodes](XCAT_system_x_support_for_IBM_Flex/#deploying-stateless-nodes). This method has the advantage of managing the images in a central place, and having only one image per node type. 
  * In you want to install your nodes as stateful (diskful) nodes, follow section [XCAT_system_x_support_for_IBM_Flex/#installing_stateful_nodes](XCAT_system_x_support_for_IBM_Flex/#installing_stateful_nodes).
  * If you want to have nfs-root statelite nodes, see [XCAT_Linux_Statelite]. This has the same advantage of managing the images from a central place. It has the added benefit of using less memory on the node while allowing larger images. But it has the drawback of making the nodes dependent on the management node or service nodes (i.e. if the management/service node goes down, the compute nodes booted from it go down too). 
  * If you have a very large cluster (more than 500 nodes), at this point you should follow [Setting_Up_a_Linux_Hierarchical_Cluster] to install and configure your service nodes. After that you can return here to install or diskless boot your compute nodes. 

## Deploying Stateless Nodes

[Using_Provmethod=osimagename](Using_Provmethod=osimagename) 
    
~~~~
    rsetboot compute net
    rpower compute boot
~~~~    

## Installing Stateful Nodes

[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes) 

### **Begin Installation**

The [nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) command tells xCAT what you want to do next with this node, [rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html) tells the node hardware to boot from the network for the next boot, and powering on the node using [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) starts the installation process: 

~~~~    
    nodeset compute osimage=mycomputeimage
    rsetboot compute net
    rpower compute boot
~~~~    

Tip: when nodeset is run, it processes the kickstart or autoyast template associated with the osimage, plugging in node-specific attributes, and creates a specific kickstart/autoyast file for each node in /install/autoinst. If you need to customize the template, make a copy of the template file that is pointed to by the osimage.template attribute and edit that file (or the files it includes). 

[Monitor_Installation](Monitor_Installation) 

  


  


## Where Do I Go From Here?

Now that your basic cluster is set up, here are suggestions for additional reading: 

  * To help configure your networks: 
    * [Managing_the_Mellanox_Infiniband_Network] 
    * [Managing_Ethernet_Switches] 
  * To install other HPC products: 
    * [IBM_HPC_Stack_in_an_xCAT_Cluster] 
  * For on-going management of the cluster: 
    * [Using_Updatenode] 
    * [Monitoring_an_xCAT_Cluster] 
  * If you want to create multiple virtual machines in each physical server: 
    * [XCAT_Virtualization_with_VMWare] 
    * [XCAT_Virtualization_with_KVM] 
    * [XCAT_Virtualization_with_RHEV] 

## Appendix 1: Update the CMM firmware

The CMM firmware can be updated by loading the latest **cmefs.uxp** firmware file using the CMM **update** command working with the http interface. The administrator needs to download firmware from IBM Fix Central. The compressed tar file will need to be uncompressed and unzipped to extract the firmware update files. Place the cmefs.uxp file in a specified directory on the xCAT MN. 

Once the firmware is unzipped and the cmefs.uxp is placed in the directory on the xCAT MN you can use the CMM **update** command to update the new firmware on one chassis at a time or on all chassis managed by xCAT MN. More details on the CMM update command can be found at: http://publib.boulder.ibm.com/infocenter/flexsys/information/index.jsp?topic=%2Fcom.ibm.acc.cmm.doc%2Fcli_command_update.html 

The format of the update command is: flash (-u) the file and reboot (-r) afterwards 

~~~~    
    update -T system:mm[1] -r -u http://<server>/<MN directory>/<update file>
~~~~    

flash (-u), show progress (-v), and reboot (-r) afterwards 

~~~~
    
    update -T system:mm[1] -v -r -u http://<server>/<MN directory>/<update file>
~~~~    

To update firmware and restart a single CMM cmm01 from xCAT MN 70.0.0.1 use: 

~~~~    
    ssh USERID@cmm01 update -T system:mm[1] -v -r -u http://70.0.0.1/firmware/cmefs.uxp
~~~~    

If unprompted password is setup on all CMMs then you can use xCAT psh to update all CMMs in the cluster at once. 
 
~~~~   
    psh -l USERID cmm update -T system:mm[1] -v -u http://70.0.0.1/firmware/cmefs.uxp
~~~~    

If you are experiencing a "Unsupported security level" message after the CMM firmware was updated then you should run the following command to overcome this issue. 

~~~~    
    rspconfig cmm sshcfg=enable snmpcfg=enable
~~~~    

## Appendix 2: Update the Blade Node Firmware

The firmware of the blades can be updated by following: [XCAT_iDataPlex_Advanced_Setup/#updating_node_firmware](XCAT_iDataPlex_Advanced_Setup/#updating_node_firmware) . 

  


## Appendix 3: Updating Firmware on Flex Ethernet and IB Switch Modules

This section provides manual procedures to help update the firmware for Ethernet and Infiniband (IB) Switch modules. There is more detail information can be referenced in the IBM Flex System documentation under Network switches: http://publib.boulder.ibm.com/infocenter/flexsys/information/ 

The IB6131 Switch module is a Mellanox IB switch, and you down load firmware (image-PPC_M460EX-SX_3.2.xxx.img) from the Mellanox website into your xCAT Management Node or server that can communicate to Flex IB6131 switch module. We provided the firmware update procedure for the Mellanox IB switches including IB6131 Switch module in our xCAT document Managing the Mellanox Infiniband Network: https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Managing_the_Mellanox_Infiniband_Network#Mellanox_Switch_and_Adapter_Firmware_Update 

The IBM Flex system supports Ethernet switch modules models (EN2092 (1GB), EN4093 (10GB), and the firmware is available from the IBM Support Portal http://www-947.ibm.com/support/entry/portal/overview?brandind=hardware~puresystems~pureflex_system. The firmware update procedure used with the Flex Ethernet (EN2092) switch module which will reference two firmware images for **OS** (GbScSE-1G-10G-7.5.1.xx_OS.img) and **Boot** (GbScSE-1G-10G-7.5.1.x_Boot.img). These images should be placed on the xCAT MN or FTP server in the **/tftpboot** directory. Make sure that this server has proper ethernet communication to the Ethernet switch module. 

#### Firmware Update using CLI

1) Login to the Ethernet switch using the "admin" userid and specify the admin password. 

~~~~    
       ssh admin@<switchipaddr> 
~~~~    

2) Get into boot directory, and list current image settings with cur command. This includes 2 OS images called image1 and image2,and will specify which image is the current boot image. 
    
       >> boot
       >> cur
    

3) Get the new Ethernet **OS** image file from the ftp server to replace the older image on the ethernet switch using **gtimg** command. The gtimg command will prompt you for full path OS image file name, ftp/root userid, and password. It will ask to specify "data" port, and a confirmation to complete the download, and flashes the update. An example of EN2092 OS image would be "GbScSE-1G-10G-7.5.1.0_OS.img", and replaces "image2" on the ethernet switch. 
 
~~~~   
       >> gtimg image2 &lt;FTP server&gt; GbScSE-1G-10G-7.5.1.0_OS.img
          Enter name of file on FTP/TFTP server: /tftpboot/GbScSE-1G-10G-7.5.1.0_OS.img
          Enter username for FTP server or hit return for TFTP server: _root_
          Enter password for username on FTP server:  <root password>
          Enter the port to use for downloading the image ["data"|"mgt"]: "data"
          Confirm download operation [y/n]: y
~~~~    

4) Get the new Ethernet **boot** image file from the ftp server to replace cuurent boot image on the ethernet switch using **gtimg** command. The gtimg command will prompt you for full path OS image file name, ftp/root userid, and password. It will ask to specify "data" port, and a confirmation to complete the download, and flashes the update. An example of EN2092 OS image would be "GbScSE-1G-10G-7.5.1.0_Boot.img", and will point to new boot image2. 

~~~~    
       >> gtimg image2 &lt;FTP server&gt; GbScSE-1G-10G-7.5.1.0_Boot.img
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

## Appendix 4: Run Discovery

This section has been moved to an appendix because the discovery method for 2.7.7 and 2.8.1 was modified to be consistent for both p and x Flex blades. The methods below are no longer the preferred methods but are kept here for administrators which may have used these methods previously. 

xCAT provides a command call slpdiscover (in xCAT 2.7) or lsslp --flexdiscover (in xCAT 2.8 and above) to detect the CMM and blade hardware, and configure it. It does the following things: 

  * use SLP to detect the CMMs and IMMs on the network 
  * identify which CMM is which, based on the switch port it is connected to and correlate that to a CMM node in the database 
  * configure each CMM using the IP address, userid, and password in the database for that node 
  * identify which blade each IMM corresponds to by matching the slot id returned by SLP and the slot id in the database 
  * configure the IMM using the IP address, userid, and password in the database for that node (if there is no IP address set in the bmc attribute for a blade, xCAT will determine the IPv6 address to use for that IMM and set it in the bmc attribute of the blade) 

Notes: 

  * For the CMMs, xCAT will use the "blade" row in the passwd table or the username and password attributes for the node. 
  * For the IMMs, xCAT will use the "ipmi" row in the passwd table or the bmcusername and bmcpassword attributes for the blade. 
  * xCAT only supports the CMM connecting to the vlan 1 of the switch setting. 
  * If you have run slpdiscover or lsslp --flexdiscover before and you want to re-discover the hardware, delete the mac attribute for the CMMs and the ipmi.bmcid attributes for the blades. 

Run the discover command (tail -f /var/log/messages to follow the progress): 
 
~~~~   
     lsslp --flexdiscover           # or use slpdiscover for xCAT 2.7
    cmm01: Found service:management-hardware.IBM:chassis-management-module at address 10.0.255.7
    cmm01: Ignoring target in bay 8, no node found with mp.mpa/mp.id matching
    Configuration of cmm01node05[10.0.1.5] commencing, configuration may take a few minutes to take effect
~~~~    

Note: the message "cmm01: Ignoring target in bay 7, no node found with mp.mpa/mp.id matching" that it could not fine a blade in the database with this mpa and id attributes. 

### Checking the Result of the slpdiscover or lsslp --flexdiscover Command

After slpdiscover/lsslp --flexdiscover completes, hardware control for the CMMs and blades should be configured properly. First check to see if the mac attribute is set for all of the CMMs and the ipmi.bmcid attribute is set for all of the blades: 
  
~~~~  
    lsdef cmm -c -i mac
    nodels blade ipmi.bmcid
~~~~    

If they are, then verify hardware control is working: 


~~~~    
    rpower blade stat | xcoll
    ====================================
    blade
    ====================================
    on
~~~~    

  
~~~~
    
    rinv cmm01node11 vpd
    cmm01node11: System Description: IBM Flex System x240+10Gb Fabric
    cmm01node11: System Model/MTM: 8737AC1
    cmm01node11: System Serial Number: 23FFP63
    cmm01node11: Chassis Serial Number: 23FFP63
    cmm01node11: Device ID: 32
    cmm01node11: Manufacturer ID: IBM (20301)
    cmm01node11: BMC Firmware: 1.34 (1AOO27Q 2012/05/04 22:00:54)
    cmm01node11: Product ID: 321
~~~~    

## **Appendix 5: Migrate your Management Node to a new Service Pack of Linux**

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

  
The documentation 
[Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux)
gives a sample procedure on how to update the management node or service nodes to a new service pack of Linux. 

## **Appendix 6: Install your Management Node to a new Release of Linux**

First backup critical xCAT data to another server so it will not be loss during OS install. 

  * Back up the xcat database using xcatsnap, important config files and other system config files for reference and for restore later. Prune some of the larger tables: 

~~~~
     tabprune eventlog -a 
     tabprune auditlog -a 
     tabprune isnm_perf -a (Power 775 only) 
     tabprune isnm_perf_sum -a (Power 775 only) 
~~~~
  * Run xcatsnap ( will capture database, config files) and copy to another host. By default it will create in /tmp/xcatsnap two files, for example: 

~~~~
    xcatsnap.hpcrhmn.10110922.log 
    xcatsnap.hpcrhmn.10110922.tar.gz 
~~~~

  * Back up from /install directory, all images, custom setup data that you want to save. and move to another server. xcatsnap will not backup images. 

After the OS install: 

  * Proceed to to setup the xCAT MN as a new xCAT MN using the instructions in this document. 
