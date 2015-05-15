<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Distro-specific Steps](#distro-specific-steps)
  - [Command Man Pages and Database Attribute Descriptions](#command-man-pages-and-database-attribute-descriptions)
- [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
- [Install xCAT on the Management Node](#install-xcat-on-the-management-node)
- [Configure xCAT](#configure-xcat)
  - [Networks Table](#networks-table)
  - [passwd Table](#passwd-table)
  - [Setup DNS](#setup-dns)
  - [Setup DHCP](#setup-dhcp)
  - [Setup TFTP](#setup-tftp)
  - [Setup conserver](#setup-conserver)
- [Define and Configure the AMMs](#define-and-configure-the-amms)
  - [Set Up AMMs](#set-up-amms)
  - [Change AMM password](#change-amm-password)
  - [Update the AMM Firmware, If Necessary](#update-the-amm-firmware-if-necessary)
- [Define Compute Nodes in the Database](#define-compute-nodes-in-the-database)
  - [Get MAC Addresses for the Blades](#get-mac-addresses-for-the-blades)
  - [Add Compute Nodes to DHCP](#add-compute-nodes-to-dhcp)
  - [Setup Blade for net boot](#setup-blade-for-net-boot)
- [Deploying Nodes](#deploying-nodes)
- [Installing Stateful Nodes](#installing-stateful-nodes)
  - [Begin Installation](#begin-installation)
- [Deploying Stateless Nodes](#deploying-stateless-nodes)
- [Where Do I Go From Here?](#where-do-i-go-from-here)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)
 


## Introduction

This document provides step-by-step instructions for setting up an example stateful or stateless cluster for a BladeCenter. 

### Distro-specific Steps

  * [RH] indicates that step only needs to be done for RHEL and Red Hat based distros (CentOS, Scientific Linux, and in most cases Fedora). 
  * [SLES] indicates that step only needs to be done for SLES. 

### Command Man Pages and Database Attribute Descriptions

  * All of the commands used in this document are described in the[xCAT man pages](http://xcat.sourceforge.net/man1/xcat.1.html). 
  * All of the database attributes referred to in this document are described in the[xCAT database object and table descriptions](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

## Prepare the Management Node for xCAT Installation


[Prepare_the_Management_Node_for_xCAT_Installation](Prepare_the_Management_Node_for_xCAT_Installation)

## Install xCAT on the Management Node

 
[Install_xCAT_on_the_Management_Node](Install_xCAT_on_the_Management_Node)

## Configure xCAT

### Networks Table

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is connected to. Now is the time to add to the networks table any other networks in the cluster, or update existing networks in the table. 

For a sample Networks Setup, see the following example: [Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example). 

### passwd Table

The password should be set in the passwd table that will be assigned to root when the node is installed. You can modify this table using tabedit. To change the default password for root on the nodes, change the system line. To change the password to be used for the AMMs, change the blade line. 
 
~~~~   
    tabedit passwd
    #key,username,password,cryptmethod,comments,disable
    "system","root","cluster",,,
    "blade","USERID","PASSW0RD",,,
~~~~    

### Setup DNS

To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN: 

  * Ensure that /etc/sysconfig/named does not have ROOTDIR set 
  * Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can't answer to these servers. 
  
~~~~  
    chdef -t site forwarders=1.2.3.4,1.2.5.6
~~~~    

  * Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above.) 
 
~~~~  
    search cluster
    nameserver 172.20.0.1
~~~~    

  * Run makedns 
    
    makedns -n
    

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

Nothing to do here - the TFTP server is done by xCAT during the Management Node install. 

### Setup conserver

~~~~    
    makeconservercf
~~~~    

## Define and Configure the AMMs

**xCAT requires the AMM management module. It does not support MM's.**

  * Add the node definitions that represent the AMMs and switches within the chassis: 
 
~~~~   
    nodeadd amm1-amm5 groups=mm,all
    nodeadd sw1-sw5 groups=nortel,switch,all
~~~~    

  * Set attributes that are common to the whole group or are regular expression: 

~~~~    
    chdef -t group mm mgt=blade hwtype=mm nodetype=mm password=<mypw> mpa='/\z//' ip='|10.20.0.($1)|'

~~~~
    
Notes: 

  * the expression used for the mpa attribute just means make it the same as the node name. 
  * The expression used for the ip attribute means for the last octet use the number in the node name (i.e. amm2 would be 10.20.0.2). 
  * For more info see [Listing_and_Modifying_the_Database]. 

  * Verify the attributes are set to what you want: 
 
~~~~   
    lsdef mm -l
~~~~    

  * Add the MMs to name resolution: 
  
~~~~  
    makehosts mm
    makedns mm
~~~~    

### Set Up AMMs

Use [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) to configure the network settings on the MM and for the switch module. 

**Note: Using rspconfig to set up the MMs' network is an optional step, it is necessary only when the MMs' network are not already setup correctly.** ****

Set up all of the MMs' network configuration based on what's in the xCAT DB: 
 
~~~~   
    rspconfig mm network='*'
~~~~    

Alternatively, you can configure each MM individually and manually: 
 
~~~~   
    rspconfig amm1 network=10.20.0.1,amm1,10.20.0.254,255.255.255.0
    ...
~~~~    

Note: the network parameters in the command above are: ip,host,gateway,netmask 

Set up the switch module network information for each switch: 

~~~~    
    rspconfig amm1 swnet=10.20.0.101,10.20.0.254,255.255.255.0
    ...
~~~~    

Note: the IP addresses in the commands above are: ip,gateway,netmask 

After setting the network settings of the MM and switch module, then enable SNMP and password-less ssh between the xCAT management node and the AMM: 

~~~~    
    rspconfig mm snmpcfg=enable sshcfg=enable
    rspconfig mm pd1=redwoperf pd2=redwoperf
    rpower mm reset
~~~~    

Test the ssh set up to see if password-less ssh is enabled: 
  
~~~~  
    psh -l USERID mm info -T mm[1]
~~~~    

For SOL to work best telnet to each nortel switch (default pw is "admin") and run: 
 
~~~~   
    /cfg/port int1/gig/auto off
    .
    .
    /cfg/port int14/gig/auto off
    cd
    apply
    save
~~~~    

Do this for each port (I.e. int2, int3, etc.) 

### Change AMM password

Be sure password-less ssh is enabled between the Manage Node and the AMM. See above. 

Set the password on the MM (must be the same as in the xCAT DB): 
  
~~~~ 
    rspconfig mm USERID=<mypw>
~~~~    

Alternatively, if you want to set it manually, then for each AMM: 

  * List the users on the AMM by running the following command. Write down the user "id" of the USERID, here the id is "1". 
 
~~~~   
    ssh -l USERID amm1 "users -T mm[1]"
    amm:
    amm: system&gt; users -T mm[1]
    amm: **1. USERID** 
    amm: 3 active session(s)
    amm: Password compliant
    amm: Account active
    amm:    Role:supervisor
    amm:    Blades:1|2|3|4|5|6|7|8|9|10|11|12|13|14
    amm:    Chassis:1
    amm:    Modules:1|2|3|4|5|6|7|8|9|10
    amm: Number of SSH public keys installed for this user: 3
    amm: 2. <not used>
    amm: 3. <not used>
    amm: 4. <not used>
            .
            .
~~~~    

  * Change the password of USERID on the AMM: 
 
~~~~   
    ssh -l USERID amm1 "users -T mm[1] **-1** -op PASSW0RD -p PASSW1RD"
    amm:
    amm: system&gt; users -T mm[1] -1 -op PASSW0RD -p PASSW1RD
    amm: OK
~~~~    

Verify the hardware control commands are working: 
 
~~~~   
    rvitals amm all
~~~~    

returns: 

~~~~    
    amm: Blower/Fan 1: 74% RPM Good state
    amm: Blower/Fan 2: 74% RPM Good state
    amm: Blower/Fan 3: % RPM Unknown state
    amm: Blower/Fan 4: % RPM Unknown state
                    .
                    .
~~~~    

### Update the AMM Firmware, If Necessary

Updating AMM Firmware can be done through the web GUI or can be done in parallel with psh. To do it in parallel using psh: 

Download Firmware from http://www-304.ibm.com/systems/support/supportsite.wss/docdisplay?brandind=5000008&amp;lndocid=MIGR-5073383 to the management node: 
  
~~~~  
    cd /tftpboot/
    unzip ibm_fw_amm_bpet36k_anyos_noarch.zip
~~~~    

Perform the update: 
  
~~~~  
    psh -l USERID mm "update -i 10.20.0.200 -l CNETCMUS.pkt -v -T mm[1]"
~~~~    

Note: 10.20.0.200 should be the IP address and the management node on the service network. 

Reset the AMM, they will take a few minutes to come back online 
  
~~~~  
    psh -l USERID mm "reset -T mm[1]"
~~~~    

You can display the current version of firmware with: 
 
~~~~   
    psh -l USERID mm "info -T mm[1]" | grep "Build ID"
~~~~    

## Define Compute Nodes in the Database

Note: For more information about the node attributes used in this section, see [&lt;http://xcat.sourceforge.net/man7/node.7.html&gt; node attributes]. 

  * Add the node definitions that represent the blades: 

~~~~    
    nodeadd blade01-blade50 groups=blade,compute,all
~~~~    

  * Set attributes that are common to the whole group or are regular expression: 
    
 
~~~~
   chdef -t group blade mgt=blade cons=blade hwtype=blade nodetype=blade serialspeed=115200 serialport=1 netboot=xnba tftpserver=10.20.0.200
    chdef -t group blade mpa='|amm(($1-1)/14+1)|' id='|(($1-1)%14+1)|' ip='|10.0.0.($1+0)|'
~~~~    

     Notes: 

  * 10.20.0.200 should be the IP address and the management node on the service network. 
  * the expression used for the mpa attribute means the 1st 14 blades are in the 1st amm, the next 14 blades and in the next amm, etc. 
  * the expression used for id sets the slot id correctly for each blade assuming there are 14 blades in each chassis. 
  * The expression used for the ip attribute means for the last octet use the number in the node name (i.e. blade02 would be 10.0.0.2). 
  * For more info on Regular expressionssee [Listing_and_Modifying_the_Database]. 
  * if you are using JS blades, do not set serialspeed or serialport. 

  * Verify the attributes are set to what you want by listing them for one blade: 

~~~~    
    lsdef blade20
~~~~    

  * Add the blades to name resolution: 

~~~~    
    makehosts blade
    makedns blade
~~~~    

  * Add the blades to conserver: 
 
~~~~  
    makeconservercf
~~~~    

  * Make sure hardware control works: 

~~~~    
    rpower blade stat
~~~~    

Test rcons for a few nodes: 
 
~~~~   
    rcons blade01
~~~~    

If you have problems with conserver: 

  * Are you setting the blade bios versions correctly? 
  * Are you setting xCAT tables correctly ( check your nodehm table)? 

To check the bios version, check your docs ( for example for a hs21 blade):_http://download.boulder.ibm.com/ibmdl/pub/systems/support/system_x_cluster/hs21-cmos-settings-v1.1.htm_

If you want the MTM and serial numbers of the blades in the xCAT DB, you can run: 
  
~~~~  
    rscan mm -u
~~~~    

### Get MAC Addresses for the Blades

Collect the blade MACs from the MMs: 

~~~~    
    getmacs blade
~~~~    

Note: The getmacs will get the mac address of the first network interface, to get the mac address of the other network interfaces, use getmacs &lt;nodename&gt; -i eth&lt;x&gt;. 

To verify the mac addresses are set in the DB: 
  
~~~~  
    lsdef blade -i mac -c
~~~~    

### Add Compute Nodes to DHCP

~~~~    
    makedhcp blade
~~~~    

### Setup Blade for net boot
 
~~~~   
    rbootseq <nodename> net,hd
~~~~    

## Deploying Nodes

  * In you want to install your nodes as stateful (diskful) nodes, follow the next section[XCAT_BladeCenter_Linux_Cluster/#installing-stateful-nodes](XCAT_BladeCenter_Linux_Cluster/#installing-stateful-nodes)). 
  * If you want to define one or more stateless (diskless) OS images and boot the nodes with those, see section [XCAT_BladeCenter_Linux_Cluster/#deploying-stateless-nodes](XCAT_BladeCenter_Linux_Cluster/#deploying-stateless-nodes). This method has the advantage of managing the images in a central place, and having only one image per node type. 
  * If you want to have nfs-root statelite nodes, see [XCAT_Linux_Statelite]. This has the same advantage of managing the images from a central place. It has the added benefit of using less memory on the node while allowing larger images. But it has the drawback of making the nodes dependent on the management node or service nodes (i.e. if the management/service node goes down, the compute nodes booted from it go down too). 
  * If you have a very large cluster (more than 500 nodes), at this point you should follow [Setting_Up_a_Linux_Hierarchical_Cluster] to install and configure your service nodes. After that you can return here to install or diskless boot your compute nodes. 

## Installing Stateful Nodes


[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes)


### Begin Installation

The [nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) command tells xCAT what you want to do next with this node, [rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html) tells the node hardware to boot from the network for the next boot, and powering on the node using[rpower](http://xcat.sourceforge.net/man1/rpower.1.html) starts the installation process: 
   
~~~~ 
    nodeset compute osimage=mycomputeimage
    rpower compute boot
~~~~    

Tip: when nodeset is run, it processes the kickstart or autoyast template associated with the osimage, plugging in node-specific attributes, and creates a specific kickstart/autoyast file for each node in /install/autoinst. If you need to customize the template, make a copy of the template file that is pointed to by the osimage.template attribute and edit that file (or the files it includes). 

 
[Monitor_Installation](Monitor_Installation)

## Deploying Stateless Nodes

 
[Using_Provmethod=osimagename](Using_Provmethod=osimagename)
 
~~~~   
    rpower compute boot
~~~~    

  


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
