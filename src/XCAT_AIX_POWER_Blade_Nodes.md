<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Prepare the installation source](#prepare-the-installation-source)
  - [Prepare the installation CD or iso file of AIX](#prepare-the-installation-cd-or-iso-file-of-aix)
    - [If you have an installation CD of AIX operating system](#if-you-have-an-installation-cd-of-aix-operating-system)
    - [If you have an installation iso file of the AIX](#if-you-have-an-installation-iso-file-of-the-aix)
  - [**Download the xCAT and dependency packages**](#download-the-xcat-and-dependency-packages)
- [Install xCAT and related packages](#install-xcat-and-related-packages)
  - [**Install the dependency packages**](#install-the-dependency-packages)
    - [Install the openssl](#install-the-openssl)
    - [Install openssh](#install-openssh)
    - [Update the packages information installed by installp into the rpm database](#update-the-packages-information-installed-by-installp-into-the-rpm-database)
  - [**Install xCAT on the AIX**](#install-xcat-on-the-aix)
    - [**Install the dependency packages of xCAT**](#install-the-dependency-packages-of-xcat)
    - [**Install the core packages of xCAT**](#install-the-core-packages-of-xcat)
  - [Verify the installation](#verify-the-installation)
- [Setup the services for the Management Node](#setup-the-services-for-the-management-node)
  - [Setup the services](#setup-the-services)
  - [Verify following xCAT required services are in active status](#verify-following-xcat-required-services-are-in-active-status)
- [An example of the cluster](#an-example-of-the-cluster)
- [Create the NIM image](#create-the-nim-image)
  - [**Create default image for NIM**](#create-default-image-for-nim)
  - [**For diskfull installation**](#for-diskfull-installation)
  - [For mksysb method installation](#for-mksysb-method-installation)
  - [For stateless installation](#for-stateless-installation)
  - [**Update the osimage with SSH/SSL software**](#update-the-osimage-with-sshssl-software)
- [Setup the attributes for the cluster](#setup-the-attributes-for-the-cluster)
  - [**Define the AMM object**](#define-the-amm-object)
    - [**Define AMMs as Nodes**](#define-amms-as-nodes)
    - [**Define the hardware control type for the management modules**](#define-the-hardware-control-type-for-the-management-modules)
    - [**Define the mpa (Hardware control attribute) for the management modules**](#define-the-mpa-hardware-control-attribute-for-the-management-modules)
    - [**Define the ip and hostname of mamagement modules**](#define-the-ip-and-hostname-of-mamagement-modules)
  - [**Setup the AMMs**](#setup-the-amms)
    - [**Enable the snmp and ssh services**](#enable-the-snmp-and-ssh-services)
    - [**Update the firmware of AMM**](#update-the-firmware-of-amm)
  - [**Create the xcat networks**](#create-the-xcat-networks)
  - [**Set Up the Password Table**](#set-up-the-password-table)
- [Define the compute node](#define-the-compute-node)
  - [**Define the nodes of blade by rscan**](#define-the-nodes-of-blade-by-rscan)
  - [**Add the nodes into the group grp_blade**](#add-the-nodes-into-the-group-grp_blade)
  - [**Setup the attributes of the node**](#setup-the-attributes-of-the-node)
  - [**Set the IP and hostname of the node**](#set-the-ip-and-hostname-of-the-node)
    - [**Set Up the nodehm table**](#set-up-the-nodehm-table)
    - [**Setup the noderes table**](#setup-the-noderes-table)
  - [**Get MAC addresses**](#get-mac-addresses)
- [Initialize the AIX/NIM nodes](#initialize-the-aixnim-nodes)
  - [**For a diskfull installation**](#for-a-diskfull-installation)
  - [For a mksysb installation](#for-a-mksysb-installation)
  - [For stateless (diskless) installation](#for-stateless-diskless-installation)
- [Setup the console](#setup-the-console)
  - [**Setup the conserver**](#setup-the-conserver)
  - [**Set the console parameter [rte/mksysb]**](#set-the-console-parameter-rtemksysb)
  - [**Open a console to monitor the installation process**](#open-a-console-to-monitor-the-installation-process)
- [Install the nodes](#install-the-nodes)
  - [**Set the boot sequence**](#set-the-boot-sequence)
  - [**Start the installation**](#start-the-installation)
- [Advanced management](#advanced-management)
  - [Trouble shooting tips](#trouble-shooting-tips)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note: this xCAT document is for the original IBM JS2x BladeCenter blades. If you are looking for the Flex POWER 7 blades (p260, p460, and 24L), see [XCAT_support_for_AIX_on_system_P_Flex_Blades].**


## Introduction

The document focuses on the step by step installation introduction for AIX on JS blade center specific scenario. If you have any concern about the operation detail in this document, there are several documents you can also reference for more information: 

[XCAT_BladeCenter_Linux_Cluster] 

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node] 

[XCAT_AIX_mksysb_Diskfull_Nodes] 

[XCAT_AIX_Diskless_Nodes] 

## Prepare the installation source

### Prepare the installation CD or iso file of AIX

#### If you have an installation CD of AIX operating system

Put the CD into the CDROM of the management node, and figure out which CDROM device that the CD just put in. If you just have one CDROM, the device name should be '/dev/cd0'. 

In the command mknimimage which make the NIM image, you can use the '/dev/cd0' as the source directory. 

  
If you like, you also can mount the /dev/cd0 to a directory 
    
    mount -rv cdrfs /dev/cd0 /mnt
    

And use the /mnt as the source directory of the mknimimage command. 

#### If you have an installation iso file of the AIX

Since AIX does not support mount an iso file to a directory, you need to copy this iso file to a Linux server and mount it to a directory, then copy all the directories and files to a real directory. At last, export the real directory out to the management node. 

  
**On the Linux server:**
    
    mount -o loop dvd.GOLD_SP1_61D.v1.iso /mnt
    cp -r /mnt/* /export_cd/*
    export the /export_cd directory out to the management node
    

  
**On the management node:**
    
    mount Linux_server:/export_cd /mnt
    

### **Download the xCAT and dependency packages**

Note: recent levels of AIX 6.1 and later ship openssh and openssl as installp in the base OS and you do not have to download and install them. 

OpenSSH: 

&lt;http://sourceforge.net/projects/openssh-aix&gt;

For example: you download the openssl package: openssl.9.8.801.tar.Z 

  
OpenSSL: 

&lt;https://www14.software.ibm.com/webapp/iwm/web/preLogin.do?source=aixbp&gt;

For example: you download the openssh package openssh-5.0_aix61.tar.Z 

  
Get the latest version of xCAT core packages and xCAT dependency packages: 
    
    dep-aix-*.tar.gz
    core-aix-*.tar.gz
    

&lt;http://xcat.sourceforge.net/aix/download.html&gt;

## Install xCAT and related packages

### **Install the dependency packages**

Change into the directory that stores the openssh and openssl you just downloaded. 

#### Install the openssl

Note: may already be installed in the OS: check with lslpp -l | grep openssl 
    
    gunzip openssl.9.8.801.tar.Z
    tar xvf openssl.9.8.801.tar
    cd openssl.9.8.801
    installp -a -Y -d . openssl
    

#### Install openssh

Note: may already be installed in the OS&nbsp;: check with lslpp -l | grep openssh 
    
    gunzip openssh-5.0_aix61.tar.Z
    tar xvf openssh-5.0_aix61.tar
    installp -a -Y -d . openssh
    

#### Update the packages information installed by installp into the rpm database
    
    /usr/sbin/updtvpkg
    

### **Install xCAT on the AIX**

#### **Install the dependency packages of xCAT**
    
    gunzip dep-aix-*.tar.gz
    tar xvf dep-aix-*.tar
    ./instoss
    

#### **Install the core packages of xCAT**
    
    gunzip core-aix-2.1.1.tar.gz
    tar xvf core-aix-2.1.1.tar
    ./instxcat
    

_Note: If you want that the file path of xCAT are added into $PATH immediately, please logout current shell and login again._

### Verify the installation

Run the "`lsdef -h`" to check if the xCAT daemon is working. 

Check to see if the initial xCAT definitions have been created. 
    
    lsdef -t site -l
    

## Setup the services for the Management Node

### Setup the services

Refer to the part '**Overview of xCAT support for AIX'** of [xCAT2onAIX.pdf](https://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2onAIX.pdf) **to setup the following services on the management node:**
    
    Syslog setup
    DNS setup
    Remote shell setup
    NTP setup
    

### Verify following xCAT required services are in active status
    
    lssrc -s inetd
    lssrc -g nfs
    

If certain services are inoperative or need to be updated, use the following command to restart the service: 
    
    stopsrc -s &lt;service&gt;    
    startsrc -s &lt;service&gt;
    

## An example of the cluster

In order to simplify the introduction of the xCAT management process, an example will be used. 

In this example, the cluster has one management node and three compute nodes. One compute nodes will be installed by the diskfull method, one will be installed by mksysb method and the last one will be booted stateless. 

  

    
    **Management node**
        **Name:** mgt_node
        **IP: **192.168.0.1
    
    
    **Compute nodes**
        **Name: **blade_rte - This node will be installed by diskfull method
        **IP: **192.168.0.10
        **Name: **blade_mksysb -  This node will be installed by mksysb method
        **IP: **192.168.0.20
        **Name: **blade_stateless -  This node will be booted in stateless model
        **IP: **192.168.0.30
    

_Note: There three compute nodes can be managed by different management module, or located in different blade centers._

  

    
    **Management module**
        **Name: **mm_js - The management module which will manage all the three compute nodes.
        **IP: **192.168.0.100
    
    
    **Group of management module**
        **Name:** grp_mm - this group includes all the management modules that you want to manage.
    
    
    **Group of blade **
        **Name: **grp_blade - this group contains all the compute nodes that you want to manage.
        **Name: **grp_rte - this group contains all the compute nodes that will be installed by diskfull method.
        **Name: **grp_mksysb - this group contains all the compute nodes that will be installed by mksysb method.
        **Name: **grp_stateless - this group contains all the compute nodes that will be booted in stateless model.
    

## Create the NIM image

The xCAT _osimage _definition contains information that can be used to install an AIX operating system. You can create different osimages for different requirements. 

### **Create default image for NIM**

mknimimage command can be used to create the xCAT osimage that defined the required NIM installation resources 

### **For diskfull installation**

You can use following command to create a default osimage for a diskfull installation. 
    
    mknimimage -V -s /mnt 610image
    

_Note: you can refer to the [XCAT_AIX_mksysb_Diskfull_Nodes] to customize the osimage for diskfull installation._

### For mksysb method installation

You can use following two kinds of sources to create the mksysb image: 

1\. A node with a diskfull install, and that it has been updated and configured as desired. 

2\. A backup image that created by mksysb command. 

In the example, the node which installed by diskfull will be used as the source to create the mksysb image. Since a diskfull installed node is needed, the detail of creating NIM image will be introduced in the section 'Initialize the AIX/NIM nodes' of this document. 

  
_Note: you can refer to the part '**Create an operating system image'** of [XCAT_AIX_mksysb_Diskfull_Nodes] to get more detail information._

### For stateless installation

You use following command to create a default osimage for stateless installation. 
    
    mknimimage -V -t diskless -s /mnt 61cosi
    

  
_Note: you can refer to the part '**Create an operating system image'** of [XCAT_AIX_Diskless_Nodes] to customize the osimage for stateless installation._

### **Update the osimage with SSH/SSL software**

You will have to install _openssl _and _openssh _along with several additional requisite software packages. 

To help facilitate this task xCAT ships two AIX installp_bundle files. They are called xCATaixSSL.bnd and xCATaixSSH.bnd, and they are included in the xCAT tar file. 

The basic process is: 

  * Copy the required software to the lpp_source resource that you used to create your SPOT. 
  * Define the bundle NIM resource 
  * Install the software in the SPOT. (This step only needed by diskless osimage) 
  * Add the bundle resources into the xCAT osimage definition 

  
**Copy the software**

You will need the openssl and openssh packages that you installed on the management server earlier in this process. You will also need some prerequisite RPM packages that were included in the xCAT dependency tar file. The easiest way to copy the software to the correct locations is to use the "nim -o update .." command. Just provide the directory that contains your software and the NIM 

lpp_source resource name. (ie. "61cosi_lpp_source"). 

For example, update the software into the 610image lpp source: 

Copy all the packages which list in the xCATaixSSL.bnd and xCATaixSSH.bnd to directory /tmp/myimages, then run following command: 
    
    nim -o update -a packages=all -a source=/tmp/myimages 610image_lpp_source
    

  
**Define the bundle resource**

Copy the bundle files ( xCATaixSN.bnd and xCATaixSSH.bnd) to a location where they can be defined as a NIM resource, for example "/install/nim/installp_bundle". 

To define the NIM resources you can run the following commands. 
    
    nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/xCATaixSSL.bnd xCATaixSSL
    nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/xCATaixSSH.bnd xCATaixSSH
    

_**Note**: You cannot update a SPOT that is currently allocated. To check to see if the SPOT is allocated you could run the following command:_
    
    lsnim -l &lt;spot name&gt;
    

  
**Install the software into the SPOT. (For diskless)**

To install additional software in the SPOT you can use the "mknimimage -u" command. 

To Install the softwares into the SPOT. 
    
    mknimimage -u 61cosi installp_bundle="xCATaixSSL,xCATaixSSH" installp_flags=agcQX
    

Refer to the NIM documentation for more information on how to use the NIM commands mentioned above. 

  
**Add the bundle resources into the xCAT osimage definition**

This step is necessary for diskfull osimage, so that NIM can know which bundles should be installed on the node. For diskless osimage, although it is not required it would be good to add the xCATaixSSL and xCATaixSSH bundle names to the xCAT osimage definition. This is a way to have a record of what additional software has been installed in the SPOT. 

To add the nim bundles into the xCAT osimage: 
    
    chdef -t osimage -o 610image installp_bundle="xCATaixSSL,xCATaixSSH"
    

## Setup the attributes for the cluster

### **Define the AMM object**

AMM is the management module of the Blade Center, it's the hardware control point of the blade nodes to be managed for rpower, rcons, rscan, rbootseq funtions. 

xCAT requires the AMM management module. It does not support MM's. 

In this section, the AMM will be defined as an xCAT node object, then you can use this object in the xCAT commands like rspconfig. In addition, all the management modules will be added into one or multiple group to simplify the operation against multiple management module objects. 

#### **Define AMMs as Nodes**

Add an AMM named mm_js as a node object and add it into the management module group grp_mm. 
    
    nodeadd mm_js groups=all,grp_mm
    

#### **Define the hardware control type for the management modules**

Define all the management modules in the grp_mm group use the **blade** as their management model. 
    
    chdef -t node -o grp_mm mgt=blade    
    

#### **Define the mpa (Hardware control attribute) for the management modules**

For the management module object, set the mpa attribute as itself. 
    
    chdef -t node -o mm_js mpa=mm_js
    

#### **Define the ip and hostname of mamagement modules**
    
    chdef -t node -o mm_js ip=192.168.0.100
    makehosts
    

### **Setup the AMMs**

**Note: Only the AMM is supported. If your blade center just has MM, you need to replace it with AMM to complete the management process.**

#### **Enable the snmp and ssh services**

Enable the snmp and ssh services for all management modules in the group **grp_mm**. 
    
    rspconfig grp_mm snmpcfg=enable sshcfg=enable
    rspconfig grp_mm pd1=redwoperf pd2=redwoperf
    

#### **Update the firmware of AMM**

If you get this message "SSH supported on AMM with minimum firmware BPET32", that means the firmware needs to be upgraded. 

Download it from IBM web site, and unpackage it to the /tftpboot 

From the AMM, run the command: 
    
    update -i ip_of_src  -l cnetrgus.pkt -v -T mm[1]; reset -T mm[1]
    

### **Create the xcat networks**

Specify which network will be used for the installation process. 

You need to specify a name for the network and values for the following attributes. 

**net** The network address. 

**mask** The network mask. 

**gateway** The network gateway. 
    
    mkdef -t network -o xcat_ent1 net=192.168.0.0 mask=255.255.255.0 gateway=192.168.0.1
    

Note: If your cluster has multiple subnets for compute nodes, then corresponding xCAT and NIM network need to be created. 

### **Set Up the Password Table**

Add the needed passwords to the passwd table for installation. 

The "system" password will be the password assigned to the root account of new installed node. The "blade" password will be used for communicating with the management module. 
    
    chtab key=system passwd.username=root passwd.password=cluster
    chtab key=blade passwd.username=USERID passwd.password=PASSW0RD
    

_Note: In above examples, the values of the username and password are for example, you should set them depend on your specific situation._

## Define the compute node

### **Define the nodes of blade by rscan**

Use the rscan command to scan all the blades which managed by the management modules in the group grp_mm. 
    
    rscan grp_mm -z &gt; bld.stanza
    

All the blades definition have been written into the bld.stanza. You can remove the definition of the blades that will not be managed from the bld.stanza. And then perform the following command to define the blade nodes. 
    
    cat bld.stanza | mkdef -z
    lsdef blade
    

After this step, you can find all the blade nodes blade_rte, blade_mksysb and blade_stateless which managed by grp_mm have been defined in the management node. 

### **Add the nodes into the group grp_blade**
    
    chdef -t node -o  blade_rte groups=grp_blade,grp_rte,blade,all
    chdef -t node -o  blade_mksysb groups=grp_blade,grp_mksysb,blade,all
    chdef -t node -o  blade_sateless groups=grp_blade,grp_stateless,blade,all
    

### **Setup the attributes of the node**

### **Set the IP and hostname of the node**
    
    chdef -t node -o blade_rte ip=192.168.0.10
    chdef -t node -o blade_mksysb ip=192.168.0.20
    chdef -t node -o blade_stateless ip=192.168.0.30
    
    
    makehosts
    

#### **Set Up the nodehm table**

Specify that the Blade Center management module should be used for hardware management. 
    
    chdef -t node -o grp_blade mgt=blade cons=blade
    

#### **Setup the noderes table**

You need to specify the **installnic** of the compute nodes before the installation. 
    
    chdef -t node -o grp_blade installnic=eth0 primarynic=eth0
    

_Note: The attribute installnic is the network adapter on the node that will be used for OS deployment. The attribute primarynic is the network adapter on the node that will be used for xCAT management._

### **Get MAC addresses**

Substitute the group named: **grp_blade** for **aixnodes** below. 

{{:Gather_MAC_information_for_the_node_boot_adapters}} 

## Initialize the AIX/NIM nodes

### **For a diskfull installation**

Create the NIM client definition: 
    
    xcat2nim -t node grp_rte
    

  
Initialize the AIX/NIM nodes: 
    
    nimnodeset -i 610image grp_rte
    

### For a mksysb installation

The mksysb method described here relys on the node blade_rte which was installed diskfull. 

_Note:Please make sure the node **blade_rte** has been installed successfully by the diskfull method before starting this step._

  
**[Prerequisite]**: Change the entry 'fsize = 2097151' to 'fsize = -1' in the default section of /etc/security/limits file on the source node blade_rte to make sure it has enough file size to store the mksysb file.Create the mksysb image 
    
    mknimimage -m mksysb -n blade_rte 610sysb spot=610image
    

  


  * Create the NIM client definition: 
    
    xcat2nim -t node  grp_mksysb
    

  
Initialize the AIX/NIM nodes: 
    
    nimnodeset -i 610sysb grp_mksysb
    

### For stateless (diskless) installation

Define and initialize the NIM machines which contained in the grp_stateless 
    
    mkdsklsnode -i 61cosi  grp_stateless
    

  
After this step, you can use the 'lsnim -l' to display the NIM machines which have been defined. 

  


## Setup the console

### **Setup the conserver**

Configure the conserver and start it, if it was not already done when you ran getmacs. 
    
    makeconservercf
    

### **Set the console parameter [rte/mksysb]**

Set the CONSOLE to /dev/vty0, so that you can get the console output from the rcons command in the installation process. 
    
    vi /install/nim/bosinst_data/610image_bosinst_data
    Modify the attribute CONSOLE from:
        CONSOLE = Default
    to
        CONSOLE =/dev/vty0
    

### **Open a console to monitor the installation process**
    
    rcons  blade_rte
    

## Install the nodes

### **Set the boot sequence**

Set the network as the first boot sequence, the hard disk as the next boot sequence. 
    
    rbootseq grp_blade net,hd
    

### **Start the installation**

Use the rpower command to restart the nodes in the grp_blade group, and then all nodes will boot up from network to start the installation. 
    
    rpower grp_blade reset
    

## Advanced management

To get following advanced management functions, please refer to the following documentation: 

[XCAT_BladeCenter_Linux_Cluster] 

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node] 

[XCAT_AIX_mksysb_Diskfull_Nodes] 

[XCAT_AIX_Diskless_Nodes] 

  


  * Install additional software 
  * Add or modify files 
  * Using other NIM resources 
  * Booting a "dataless" node 
  * Specifying additional values for the NIM node initialization 
  * Updating AIX diskless nodes using xCAT 
  * Removing NIM machine definitions 
  * Removing NIM resources 

  


### Trouble shooting tips

  1. rcons command does not display output after installation 
    1. run following command on the up running node: chcons /dev/vty0 
      1. Check /etc/bootptab to make sure an entry exists for the node. 
      2. Check that the information in /tftpboot/&lt;node&gt;.info is correct. 
      3. Stop and restart inetd: 
        1. stopsrc -s inetd  
startsrc -s inetd 
      4. Stop and restart tftpd: 
        1. stopsrc -s tftpd  
startsrc -s tftpd 
