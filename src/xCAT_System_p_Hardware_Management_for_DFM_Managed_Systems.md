<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Terminology](#terminology)
  - [Downloading and Installing DFM](#downloading-and-installing-dfm)
- [Discovering and Defining New PowerLinux Hardware](#discovering-and-defining-new-powerlinux-hardware)
  - [**Discovery Overview**](#discovery-overview)
  - [Define the Service LAN(s) in the Database and DHCP](#define-the-service-lans-in-the-database-and-dhcp)
    - [**Enable SLP on Juniper Switches **](#enable-slp-on-juniper-switches-)
    - [**Configure xCAT Service VLANs **](#configure-xcat-service-vlans-)
  - [Set consoleondemand in the site table to yes](#set-consoleondemand-in-the-site-table-to-yes)
  - [Power On the FSPs, Discover Them, Modify Network Information, and Connect](#power-on-the-fsps-discover-them-modify-network-information-and-connect)
    - [Predefine CEC and FSP node object in xCAT db and update DNS](#predefine-cec-and-fsp-node-object-in-xcat-db-and-update-dns)
    - [Power on the CECs and do hardware discovery](#power-on-the-cecs-and-do-hardware-discovery)
    - [Update dhcp configuration file](#update-dhcp-configuration-file)
  - [Update the CEC Firmware (optional), and Validate CECs Can Power Up](#update-the-cec-firmware-optional-and-validate-cecs-can-power-up)
  - [Define the LPAR Nodes with rscan](#define-the-lpar-nodes-with-rscan)
  - [Create Additional Partitions in the CECs](#create-additional-partitions-in-the-cecs)
    - [Deal with the default partition](#deal-with-the-default-partition)
    - [List out all the resources on the CEC](#list-out-all-the-resources-on-the-cec)
    - [Partitions Operations](#partitions-operations)
      - [Create Node Definitions for Partition](#create-node-definitions-for-partition)
      - [Physical Partitions Operation](#physical-partitions-operation)
      - [Full partition Operation](#full-partition-operation)
      - [VIOS partition Operation](#vios-partition-operation)
      - [normal LPAR partition Operation](#normal-lpar-partition-operation)
    - [Remove partition](#remove-partition)
- [OS provisioning and configuration for VIOS partition(Optional)](#os-provisioning-and-configuration-for-vios-partitionoptional)
  - [install OS for VIOS partition](#install-os-for-vios-partition)
    - [create suitable vios OS image](#create-suitable-vios-os-image)
    - [configure the ip address for the vios partition](#configure-the-ip-address-for-the-vios-partition)
    - [configure password for specific user 'padmin' of VIOS](#configure-password-for-specific-user-padmin-of-vios)
    - [configure DNS resolution](#configure-dns-resolution)
    - [configure node's conserver](#configure-nodes-conserver)
    - [get the mac address of a vios partition](#get-the-mac-address-of-a-vios-partition)
    - [set provmethod for the partition and install OS](#set-provmethod-for-the-partition-and-install-os)
  - [configure virtual adapters for VIOS partition](#configure-virtual-adapters-for-vios-partition)
    - [list all the virtual adapter created for VIOS partition](#list-all-the-virtual-adapter-created-for-vios-partition)
    - [config SEA](#config-sea)
      - [list all the virtual device](#list-all-the-virtual-device)
      - [match virtual device show in OS with the vritual Ethernet adapter created with *vm](#match-virtual-device-show-in-os-with-the-vritual-ethernet-adapter-created-with-vm)
        - [list the vpd infomation for a virtual device.](#list-the-vpd-infomation-for-a-virtual-device)
        - [Manually match the Hardware Location code:](#manually-match-the-hardware-location-code)
      - [create virtual SEA adapter](#create-virtual-sea-adapter)
      - [configure address information for the SEA adapter](#configure-address-information-for-the-sea-adapter)
      - [check the SEA adapter, you can get a new "shared Ethernet Adapter"](#check-the-sea-adapter-you-can-get-a-new-shared-ethernet-adapter)
    - [config vSCSI server](#config-vscsi-server)
      - [Find out the vscsi server adapter](#find-out-the-vscsi-server-adapter)
      - [match virtual device show in OS with the vritual SCSI adapter created with *vm](#match-virtual-device-show-in-os-with-the-vritual-scsi-adapter-created-with-vm)
        - [list the vpd infomation for a virtual device.](#list-the-vpd-infomation-for-a-virtual-device-1)
        - [Manually match the Hardware Location code:](#manually-match-the-hardware-location-code-1)
      - [list out the physical volumes](#list-out-the-physical-volumes)
      - [create LV](#create-lv)
      - [attach the 20G logical volume to a virtual SCSI server adapter](#attach-the-20g-logical-volume-to-a-virtual-scsi-server-adapter)
      - [check the mapping](#check-the-mapping)
  - [Set up the SSH keys for the user to the VIOS partition if need](#set-up-the-ssh-keys-for-the-user-to-the-vios-partition-if-need)
- [Energy Management](#energy-management)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Introduction

This document provides information about initializing, discovering, defining, and managing the **PowerLinux** (IBM Power 7R1/7R2/7R4 and IBM Power 8 S Class servers) hardware. **If not expressly stated, everything described in this document is supported in xCAT 2.7 and above.**
Currently, xCAT support 3 kind of hardware arch to manage the **PowerLinux** machine, they are ppc64(RH and sles), x86_64(RH and sles) and ppc64le(RH7.1). 

### Terminology

The following terms will be used in this document: 

**xCAT DFM**: Direct FSP Management is the name that we use to describe the ability for xCAT software to communicate directly to the System p server's service processor without the use of the HMC for management. 

**CEC node**: A node with attribute hwtype set to _cec_ which represents a System P CEC (i.e. one physical server). 

**FSP node**: FSP node is a node with the hwtype set to _fsp_ and represents one port on the FSP. Each FSP has two ports, so there can be two FSP nodes defined by xCAT per CEC. System admins will always use the CEC node for the hardware control commands. xCAT will automatically use the four FSP node definitions and their attributes for hardware connections. 

**Service LAN**: The network that connects the xCAT mgmt node (and service nodes if you have them) to the FSPs to control the nodes out of band. 

**Management LAN**: The network that connects the xCAT mgmt node (and service nodes if you have them) to the in-band NIC of the nodes to deploy the OS and do other mgmt operations to the nodes. 

### Downloading and Installing DFM

Most of the operations mentioned in this document, are done through DFM, not using the HMC. This requires the **xCAT Direct FSP Management plugin** (xCAT-dfm-*.*.rpm), which is **not** part of the core xCAT open source, but is available as a free download from IBM. You must download this and install it on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document. 

Download [DFM](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&release=All&platform=All&function=all) and the prerequisite [hardware server](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&product=ibm/Other+software/IBM+High+Performance+Computing+%28HPC%29+Hardware+Server&release=All&platform=All&function=all) package from [Fix Central](http://www-933.ibm.com/support/fixcentral/)&nbsp;: 
    
    Product Group:      Cluster Software
    Product:            direct FSP management plug-in for xCAT
    

And 
    
    Product Group:      Cluster Software
    Product:            IBM High Performance Computing (HPC) Hardware Server

  * xCAT-dfm RPM
**[RH7.1 ppc64le]:** 
  * HARDWARESVR-1.2.0.0-powerLE-Linux
**[RH on ppc64]:**
  * HARDWARESVR-1.2.0.0-power-Linux
**[RH on x86_64]:**
  * HARDWARESVR-1.2.0.0-x86_64-Linux-RHEL6

The downloaded packages contain the installable rpm which has been tar-ed and zipped(compressed). After downloading these packages, uncompress, untar and install the hardware server package first and then do the same for the DFM package: 

If you followed the xCAT documentation to install xCAT on the mgmt node, you should already have the yum repositories set up to pull in whatever xCAT dependencies and distro RPMs are needed (libstdc++, libgcc, openssl, etc.). 
    
    yum install xCAT-dfm-*.rpm ISNM-hdwr_svr-*.rpm
    

## Discovering and Defining New PowerLinux Hardware

When setting up a new cluster, you can use the xCAT command [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to create the proper definition of all of the cluster hardware in the xCAT database, by automatically discovering and defining them. This is optional - you can define all of the hardware in the database by hand, but that can be confusing, time consuming, and error prone. 

**Note:** this document focuses on the following environment: 

  * PowerLinux Cluster 
  * using dynamic IP addresses for FSPs 
  * direct FSP management (DFM) 

The hardware discovery should be performed after the Management Node is installed and configured with xCAT as indicated by this flow: 

  1. Install the OS on the management node 
  2. Install the xCAT prereqs and xCAT software on the management node 
  3. Configure xCAT and other services on the management node 
  4. **Discover and define the cluster hardware components**
  5. Create the images that should be installed or booted on the node 

Note: the firewall should be disabled on the mgmt node, otherwise the command lsslp will return no responses and can't discover nodes. 

### **Discovery Overview**

Here is the **summary** of the steps needed to discover the hardware and define it properly in the database. Each step of the summary is explained in more detail in the subsequent sections. 

  * Define the service LAN(s) in the database 
  * Configure the networks in dhpcd 
  * Manually power on the PowerLinux machines 
  * Use lsslp to discover the FSPs, match them with the corresponding CEC and FSP objects in the database, and write additional attributes for the CECs and FSPs in the database. 
  * Configure dhcpd with the permanent ip/mac pairs for all the FSPs 
  * Use xCAT to connect to and configure the FSPs 
  * Verify the hw ctrl setup is correct for the CECs and the FSPs 
  * Define the LPARs as nodes in the xCAT database using rscan 
  * Create additional LPARs in each CEC (optional) 

Each step is explained in more detail below. 

In the examples given below, it is assumed that the xCAT management node has 2 NICs, one is connected to service lan 10.0.0.0/255.255.255.0, another is connected to service lan 192.168.0.0/255.255.255.0. 

### Define the Service LAN(s) in the Database and DHCP

xCAT uses [SLP](http://en.wikipedia.org/wiki/Service_Location_Protocol) to discover the hardware components on the service networks. Before doing this, you must validate the following: 

  * Make sure that the xCAT MN and CEC FSP ethernet connections are physically attached to service LAN ethernet switches. 
  * The CEC FSP ports are 1G, so you must ensure they are connected to 1G ports on the service LAN ethernet switches. 
  * Make sure SLP protocol is supported on the service LAN switches by enabling IGMP-Snooping. Please reference information below if using Juniper switches. 
  * Configure dhcpd with a dynamic range to give dynamic DHCP IP addresses to the hardware components so that they can respond to SLP broadcasts. (xCAT can do this, as explained below.) 

#### **Enable SLP on Juniper Switches **

The power linux cluster may be using the Juniper ethernet switch to support the FSP HW service VLANS. The information below was on how to enable Juniper switch working with igmp-snooping for SLP support. We recommend to remove the HW service vlans from igmp-snooping protocol settings. The default configuration for igmp-snooping on the IBM J48E switch is to enable igmp-snooping for all VLANs: 
    
    protocols {
           igmp-snooping {
           vlan all;
    

The Juniper administrator commands to make this change are the following after entering into edit mode: 
    
    {master:0}[edit]
     admin@j48052# edit protocols igmp-snooping
    {master:0}[edit protocols igmp-snooping]
     admin@j48052# show vlan all;
    {master:0}[edit protocols igmp-snooping]
     admin@j48052# set vlan management
    {master:0}[edit protocols igmp-snooping]
     admin@j48052# delete vlan all
    {master:0}[edit protocols igmp-snooping]
     admin@j48052# show vlan management;
    {master:0}[edit protocols igmp-snooping]
     admin@j48052# commit check
    if clean, then
    {master:0}[edit protocols igmp-snooping]
     admin@j48052# commit synchronize  

Note:use the 'synchronize' if more than one switch configured in virtual chassis
    

#### **Configure xCAT Service VLANs **

This section provides the commands used to set up the xCAT HW service VLANs in the the xCAT database and dhcp server environment. 

**Note**: if you are adding new additional hardware to an existing cluster (not initially creating the cluster) then you can skip this section. If you are adding new networks to the cluster, then you will need to execute some steps in this section. 

If you haven't already, configure with static IP addresses the management node's NICs that are connected to the service VLAN and cluster management VLAN. 

If you already had the management node's service LAN NICs configured when you installed xcat, it automatically ran "makenetworks" and created the necessary entries in the networks table. If not, run: 

~~~~     
    makenetworks
~~~~     

Now set the networks.dynamicrange attribute for each service LAN. For example the following represents 2 HW VLANS:
 
~~~~    
    chdef -t network 10_0_0_0-255_255_255_0 dynamicrange=10.0.0.20-10.0.0.200
    chdef -t network 192_168_0_0-255_255_255_0 dynamicrange=192.168.0.20-192.168.0.200
~~~~ 

If you want the network definitions to have more user friendly names in the database, you can set them to anything you want. For example: 

~~~~     
    chdef -t network 10_230_0_0-255_255_0_0 -n servicelan1
    chdef -t network 10_231_0_0-255_255_0_0 -n servicelan2
~~~~ 

Set [site](http://xcat.sourceforge.net/man5/site.5.html).dhcpinterfaces to the list of NICs (on the management node and service nodes) that DHCP should listen on. For the management node, this is normally the NICs that are connected to the service LAN and the NICs connected to the cluster management LAN: 

~~~~     
     chdef -t site clustersite dhcpinterfaces='mgmtnode|eth1,eth2,eth3,eth4'
~~~~     

Have xCAT configure the service network stanza for dhcpd and then start the daemon: 
    
~~~~ 
    makedhcp -n
    service dhcpd restart
~~~~     

Look at the DHCP configuration file on the xCAT management node to ensure that it contains only the networks you want: 

~~~~     
    cat /etc/dhcp/dhcpd.conf
~~~~     

If you need to make updates to the DHCP configuration file, you should stop the DHCP daemon, edit the DHCP configuration file, and then restart the DHCP daemon on your xCAT MN. 

### Set consoleondemand in the site table to yes

Before running any DFM hardware control commands in a large cluster, you should make sure the consoleondemand attribute in the site table is set to "yes". This is needed if there is a large number of LPARs and CECs. In the Power clusters that use DFM, the consoles are opened by fsp-api which sends command to the HWS daemon, which connects to the FSP. When set to 'no', all the consoles will be opened immediately (for logging), and it will affect the performance of the DFM hardware control commands. When set to 'yes', conserver connects to and logs the console output only when the user opens the console using the [rcons](http://xcat.sourceforge.net/man1/rcons.1.html) command. The default is "no" on Linux, and "yes" on AIX. 

~~~~     
     chdef -t site clustersite consoleondemand=yes
~~~~     

After you change the change the consoleondemand=yes, you should run makeconservercf to take effects. 
    
~~~~ 
     makeconservercf
~~~~     

### Power On the FSPs, Discover Them, Modify Network Information, and Connect

For PowerLinux systems, the Machine Type/Model and Serial information was printed on the front panel of the Physical Server. The following steps can be used to make the hardware discovery process much easier. 

#### Predefine CEC and FSP node object in xCAT db and update DNS

~~~~     
    mkdef cec01 nodetype=ppc mtm=8246-L1D serial=100A9DA groups=cec,all mgt=fsp hwtype=cec
    mkdef cec01_fsp nodetype=ppc mtm=8246-L1D serial=100A9DA \
       groups=fsp,all mgt=fsp parent=cec01 hwtype=fsp side=A-0 ip=10.0.0.21
    makehosts
~~~~     

**Note**: The ip value for the FSP node is the permanent ip address that you'd like to assigned to it. It must be not belong to the DHCP dynamicrange you set in 'networks' table. **makehosts** will create the permanent ip address and nodename mapping. 

#### Power on the CECs and do hardware discovery

When power is applied to the CECs, the FSPs power on. This should cause the FSPs to request and receive a dynamic IP address from DHCP. Information about the FSPs &amp; CECs cannot be collected by the lsslp command below until this has taken place. 

Run [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to discover the CECs/FSPs, and write additional attributes in the database. 

~~~~     
    lsslp -s CEC -w
~~~~     

For each FSP that was discovered on the network, the mac and parent attributes of the FSP node will be updated. You can confirm it by running: 
  
~~~~   
    lsdef -S cec1_fsp -i mac,parent
~~~~     

Review/verify all of the attributes of the CECs and FSPs: 
 
~~~~    
    lsdef cec 
    lsdef fsp -S      # normally FSPs are hidden from output, so you need the -S flag
~~~~ 

Verify that: 

  * The parent of the FSPs are set to the CEC they are in 
  * The hcp of the CECs are set to themselves 

#### Update dhcp configuration file

Configure DHCP with the static ip/mac pairs so that it will always give the FSPs their permanent IP address from now on: 

~~~~     
    makedhcp -n
    makedhcp -a
~~~~     

Verify that the proper IP/MAC pairs were configured in dhcp: 

~~~~     
    cat /var/lib/dhcpd/dhcpd.leases # RHEL 6
~~~~     

The FSPs will renew their DHCP lease from the DHCP server about every five minutes. So after the DHCP daemon on the MN is configured (via makedhcp), the FSPs will get their permanent IP addresses sometime between 0 and 5 minutes later. The [pping](http://xcat.sourceforge.net/man1/pping.1.html) command can be used to see if the FSPs have obtained their new IP addresses. If an FSP has obtained its permanent IP address, the pping result will be: "&lt;fsp ip&gt;: ping". 

~~~~     
    pping fsp
~~~~     

For the FSPs that can't refresh their IP addresses, the --resetnet option of the [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) command can be used to force it. The rspconfig expects each FSP's otherinterfaces attribute to be set to the dynamic IP address that it currently has. 
 
~~~~    
    rspconfig cec02 --resetnet
~~~~     

  * Note: the rspconfig --resetnet command may fail if between the pping command and the rspconfig cmd, the FSP automatically renewed its lease and received the new IP address. In that case, run pping again to confirm. 

To enable xCAT to connect to the FSPs, you must add the current passwords for the CEC/FSPs in the xCAT database. If the password for all of the CECs is the same, you can set the username/password in the passwd table: 

~~~~     
    chtab key=fsp,username=HMC passwd.password=xxx
    chtab key=fsp,username=admin passwd.password=yyy
    chtab key=fsp,username=general passwd.password=zzz
~~~~     

If the passwords for some of the CEC/FSPs are different, you can set the passwords for individual CEC/FSPs in the ppcdirect table: 
 
~~~~    
    chdef cec01 passwd.HMC=xxx passwd.admin=yyy passwd.general=zzz
~~~~     

Have xCAT's DFM daemon (called hw server) establish connections to all of the CEC/FSPs: 

~~~~     
    mkhwconn cec -t
~~~~     

If the FSP passwords are still the factory defaults, you must change them before running any other commands to them: 
 
~~~~    
    rspconfig cec general_passwd=,<newpd>
    rspconfig cec admin_passwd=,<newpd>
    rspconfig cec HMC_passwd=,<newpd>
~~~~ 

Set the system name of the CEC to match the node name in the xCAT database. This is convenient because then the CEC names displayed in the ASM interface will match the CEC names in the xCAT database. 
 
~~~~    
    rspconfig cec 'sysname=*'
~~~~     

Verify the connections were made successfully: 

~~~~     
     lshwconn cec
    cec01: sp=primary,ipadd=10.0.0.21,alt_ipadd=unavailable,state=LINE UP
    ...
~~~~ 

Verify the hardware control setup is correct for the CECs: 

~~~~     
    rpower cec state
    cec01: operating
    ...
~~~~ 

### Update the CEC Firmware (optional), and Validate CECs Can Power Up

The admin may need to upgrade the firmware of the CEC. This is accomplished by using the [rflash](http://xcat.sourceforge.net/man1/rflash.1.html) xCAT command from the xCAT MN. The admin should download the supported GFW from the IBM Fix central website, and place it in a directory that is available to be read by the xCAT MN. 

Use [rinv](http://xcat.sourceforge.net/man1/rinv.1.html) command to get the current firmware levels of the CECs: 

~~~~     
    rinv cec firm
    cec01: Release Level  : 01AL770
    cec01: Active Level   : 048
    cec01: Installed Level: 048
    cec01: Accepted Level : 048
    cec01: Release Level Primary: 01AL770
    cec01: Level Primary  : 048
    cec01: Current Power on side Primary: temp
    ...
~~~~ 

Make sure the pending-power-on side of the CEC's FSPs is set to temp. If not, set it to temp. 
 
~~~~    
    rspconfig cec pending_power_on_side 
    rspconfig cec pending_power_on_side=temp
~~~~ 

Download the Microcode update package(end with rpm) and associated XML file from [Fix Central](http://www-933.ibm.com/support/fixcentral/). 
The "Product Group" shall be "Power", "Product" shall be the Machine Type/Model of your power machine, and choose suitable entry in "Select from XXX" pulldown list. The files are similar to:

~~~~
    01SV810_108_081.rpm
    01SV810_108_081.xml
~~~~

Use the rflash command to update the firmware levels for the CECs. Then validate that the new firmware is loaded: 

~~~~     
    rflash cec -p <directory> --activate disruptive
    rinv cec firm 
~~~~ 

The admin can now power on the CECs, and validate they come up to working state. You can monitor the power up of the CECs using the rpower and rvitals command. You are looking for the CECs to be "Operating" with a finished good state. If they are not in the "Operating" state, additional hardware debug will be necessary to understand the failure. 
 
~~~~    
    rpower cec on
    rvitals cec lcds
    rpower cec state 
~~~~ 

### Define the LPAR Nodes with rscan

The [rscan](http://xcat.sourceforge.net/man1/rscan.1.html) command reads the actual LPAR configuration in the CEC and creates node definitions in the xCAT database to reflect them. Before using rscan, you should put the cec in operating or standby state. 

Run the [rscan](http://xcat.sourceforge.net/man1/rscan.1.html) command against all of the CECs to create a stanza file of LPAR node definitions: 
 
~~~~   
    rscan cec -z > nodes.stanza
~~~~ 

Edit the stanza file and give each LPAR definition the node name that you want it to have. Then create the definitions in the database: 

~~~~     
    cat nodes.stanza | mkdef -z
~~~~ 

Use the [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) command to display the node definitions to confirm they were created the way you want them. 

In some situation especially the factory default CECs, there will only be one single LPAR in each CEC that has all of the resources assigned to it. The following steps can be used to simple you definition. 

~~~~    
    nodeadd cec[01-08]n01 groups=lpar,all
    chdef -t group lpar parent='|(cec\d+).*|($1)|' id='|cec\d+n0?(\d+)|($1+0)|' hwtype=lpar nodetype=ppc,osi 
    rscan cec -w 
~~~~     

**Note**: **rscan cec -w** will update node definitions if they are matching by attributes 'parent' and 'id', and write nodes that doesn't match. 

In the end, you will get a node object **cec01n01** for the default partition on CEC **cec01**. It will be similar to: 

~~~~     
     lsdef cec01n01
    Object name: cec01n01
        groups=lpar,all
        hcp=cec01
        hwtype=lpar
        id=1
        mgt=fsp
        mtm=8246-L1D
        nodetype=ppc,osi
        parent=cec01
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles
        serial=100A9DA 
~~~~ 

### Create Additional Partitions in the CECs

By default, in IBM Power CECs there will be a default full partition which has all of the physical resources assigned to it. The DB node object representing the default partition was created in the previous section _Define the LPAR Nodes with rscan_. You need to delete this default partition first before doing other partition operations. 



#### Deal with the default partition

For a new PowerLinux server, there is a default full partition with OS installed on it. The default partition object has been defined in last step, we suppose the object name is 'cec01n01'. 

1\. Modify the power off policy for all of the CECs to avoid the CEC shutdown after the default partition is powered off and removed. 
 
~~~~    
    rspconfig cec01 cec_off_policy=stayon
~~~~     

2\. Power off the default partition since partitions can only be removed in power off ("Not Activated") state. 

~~~~     
    rpower cec01n01 off
~~~~     

3\. Remove the partition from the CEC and release all the physical resource assigned to it. 

~~~~     
    rmvm cec01n01
~~~~
     
**Note**: The sections list below don't need to be operated step by step. Each section can fulfill one function completely. 

#### List out all the resources on the CEC

In order to customize the partitions more efficiently, the admin needs to know all the resources in the CEC: 

~~~~     
    [root@xcatmn ~]# lsvm cec
    cec01: HYP Configurable Processors: 4, Avail Processors: 4.
    HYP Configurable Memory:16.00 GB(256 regions).
    HYP Available Memory:   15.38 GB(246 regions).
    HYP Memory Region Size: 0.06 GB(64 MB).
    cec01: All Physical I/O info:
    65535,517,U78AB.001.WZSJW8D-P1-C6,0x21010205,0xffff(Empty Slot)
    65535,516,U78AB.001.WZSJW8D-P1-C5,0x21010204,0xffff(Empty Slot)
    65535,515,U78AB.001.WZSJW8D-P1-C4,0x21010203,0xffff(Empty Slot)
    65535,514,U78AB.001.WZSJW8D-P1-C3,0x21010202,0x200(Ethernet Controller)
    65535,513,U78AB.001.WZSJW8D-P1-C2,0x21010201,0x0(Non VGA device)
    65535,13,U78AB.001.WZSJW8D-P1-C7,0x2104000d,0x200(Ethernet Controller)
    65535,12,U78AB.001.WZSJW8D-P1-C18,0x2103000c,0xffff(Empty Slot)
    65535,11,U78AB.001.WZSJW8D-P1-T5,0x2102000b,0x1003(Unknown Device)
    65535,10,U78AB.001.WZSJW8D-P1-T9,0x2101000a,0x104(RAID Controller)
    cec01: Huge Page Memory
    Available huge page memory(in pages):     0
    Configurable huge page memory(in pages):  0
    Page Size(in GB):                         16
    Maximum huge page memory(in pages):       1
    Requested huge page memory(in pages):     0
    cec01: Barrier Synchronization Register(BSR)
    Number of BSR arrays: 256
    Bytes per BSR array:  4096
    Available BSR array:  256
~~~~     

**Note**: The lines immedidiately following "All Physical I/O info" represent all the physical I/O resource information, and is in the format: "owner_lparid,slot_id,physical resource name,drc_index,slot_class_code(class discription)". The 'drc index' is short for Dynamic Resource Configuration Index, which uniquely indicates a physical I/O resource in a Power server. 

#### Partitions Operations

This section describes how to do partition for powerLinux hardware with DFM. There are four kinds of partition are supported right now: 1\. full partition 2\. physical partition 3\. VIOS partition 4\. normal LPAR 

##### Create Node Definitions for Partition

Before creating partitions in a CEC, please make sure the partition definition had been created. If not exists, you can create the definition with the following command. 

~~~~    
  mkdef cec01n01 mgt=fsp cons=fsp nodetype=ppc,osi id=2 hcp=cec01 parent=cec01 hwtype=lpar groups=lpar,all    

  1 object definitions have been created or modified. 
~~~~ 

If you like to use the node definition updated with "rscan cec -w", you can modify the attribute of the node with the following command. 

~~~~     
     chdef cec01n01 mgt=fsp cons=fsp id=2 hcp=cec01 parent=cec01  
    1 object definitions have been created or modified. 
~~~~ 

**Note**: The 'hcp' and 'parent' attributes shall be set as the object name of the CEC that you'd like to create partition on. The customized partition must start with id '2', since rcons doesn't work for id '1' in some situations. 

The node definition is similar to: 

~~~~ 
    [root@xcatmn ~]# lsdef cec01n01
    Object name: cec01n01
        cons=fsp
        groups=lpar,all
        hcp=cec01
        hwtype=lpar
        id=2
        mgt=fsp
        nodetype=ppc,osi
        parent=cec01
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles
~~~~ 

##### Physical Partitions Operation

  * Option 1: Modify LPAR Node Definition and Create LPAR 
~~~~     
    [root@xcatmn ~]# chdef cec01n01 vmcpus=1/4/4 vmmemory=1/16/16 vmphyslots=0x2101000a,0x2104000d 
    1 object definitions have been created or modified.
    
    [root@xcatmn ~]# mkvm cec01n01
    cec01n01: Done
~~~~ 

After the partition is created, check the partition resources: 

~~~~     
    [root@xcatmn ~]# lsvm cec01n01
    cec01n01: Lpar Processor Info:
    Curr Processor Min: 1.
    Curr Processor Req: 4.
    Curr Processor Max: 4.
    cec01n01: Lpar Memory Info:
    Curr Memory Min: 1.00 GB(16 regions).
    Curr Memory Req: 15.25 GB(244 regions).
    Curr Memory Max: 16.00 GB(256 regions).
    cec01n01: 1,13,U78AB.001.WZSJW8D-P1-C7,0x2104000d,0x200(Ethernet Controller)
    cec01n01: 1,10,U78AB.001.WZSJW8D-P1-T9,0x2101000a,0x104(RAID Controller)
    cec01n01: 0/0/0
    cec01n01: 0.
~~~~ 

  * Option 2: Create LPAR by Passing the Resource Arguments Directly to mkvm 
    
~~~~ 
    [root@xcatmn ~]# mkvm cec01n01 vmcpus=1/4/4 vmmemory=1/16/16 vmphyslots=0x2101000a,0x2104000d,0x21010202,0x21010201,0x2102000b vmothersetting=bsr:128
    cec01n01: Done
~~~~ 

Check the resources for the new partition: 

~~~~     
    [root@xcatmn ~]# lsvm cec01n01
    cec01n01: Lpar Processor Info:
    Curr Processor Min: 1.
    Curr Processor Req: 4.
    Curr Processor Max: 4.
    cec01n01: Lpar Memory Info:
    Curr Memory Min: 1.00 GB(16 regions).
    Curr Memory Req: 15.25 GB(244 regions).
    Curr Memory Max: 16.00 GB(256 regions).
    cec01n01: 1,514,U78AB.001.WZSJW8D-P1-C3,0x21010202,0x200(Ethernet Controller)
    cec01n01: 1,513,U78AB.001.WZSJW8D-P1-C2,0x21010201,0x0(Non VGA device)
    cec01n01: 1,13,U78AB.001.WZSJW8D-P1-C7,0x2104000d,0x200(Ethernet Controller)
    cec01n01: 1,11,U78AB.001.WZSJW8D-P1-T5,0x2102000b,0x1003(Unknown Device)
    cec01n01: 1,10,U78AB.001.WZSJW8D-P1-T9,0x2101000a,0x104(RAID Controller)
    cec01n01: 0/0/0
    cec01n01: 128.
~~~~     

If you would like to modify the resources assigned of a partition, you can use [chvm](http://xcat.sourceforge.net/man1/chvm.1.html). Here is an example that modifies the cpu, memory, and physical slot info for the specified partition. 

~~~~    
    chvm cec01n01 vmcpus=1/2/4 vmmemory=1/8/16 add_physlots=0x21010203,0x2103000c vmothersetting=bsr:256
    cec01n01: Success
    cec01n01: Success
    cec01n01: Success
    cec01n01: Success
~~~~

Checking the resources after modifying:

~~~~
    
    lsvm cec01n01
    cec01n01: Lpar Processor Info:
    Curr Processor Min: 1.
    Curr Processor Req: 2.
    Curr Processor Max: 4.
    cec01n01: Lpar Memory Info:
    Curr Memory Min: 1.00 GB(16 regions).
    Curr Memory Req: 8.00 GB(128 regions).
    Curr Memory Max: 16.00 GB(256 regions).
    cec01n01: 1,515,U78AB.001.WZSJW8D-P1-C4,0x21010203,0xffff(Empty Slot)
    cec01n01: 1,514,U78AB.001.WZSJW8D-P1-C3,0x21010202,0x200(Ethernet Controller)
    cec01n01: 1,513,U78AB.001.WZSJW8D-P1-C2,0x21010201,0x0(Non VGA device)
    cec01n01: 1,13,U78AB.001.WZSJW8D-P1-C7,0x2104000d,0x200(Ethernet Controller)
    cec01n01: 1,12,U78AB.001.WZSJW8D-P1-C18,0x2103000c,0xffff(Empty Slot)
    cec01n01: 1,11,U78AB.001.WZSJW8D-P1-T5,0x2102000b,0x1003(Unknown Device)
    cec01n01: 1,10,U78AB.001.WZSJW8D-P1-T9,0x2101000a,0x104(RAID Controller)
    cec01n01: 0/0/0
    cec01n01: 256.
~~~~

**Note**: the partition configuration parameters be modified using **chvm** will take effect in next boot. 

##### Full partition Operation

Option 'full' for **mkvm** can be used to create a full partition. 

~~~~
    
    mkvm cec01n01 --full
    cec01n01: Done

~~~~

Checking the resources: 

~~~~ 
    
    lsvm cec01n01
    cec01n01: Lpar Processor Info:
    Curr Processor Min: 1.
    Curr Processor Req: 4.
    Curr Processor Max: 4.
    cec01n01: Lpar Memory Info:
    Curr Memory Min: 0.25 GB(4 regions).
    Curr Memory Req: 15.25 GB(244 regions).
    Curr Memory Max: 16.00 GB(256 regions).
    cec01n01: 1,517,U78AB.001.WZSJW8D-P1-C6,0x21010205,0xffff(Empty Slot)
    cec01n01: 1,516,U78AB.001.WZSJW8D-P1-C5,0x21010204,0xffff(Empty Slot)
    cec01n01: 1,515,U78AB.001.WZSJW8D-P1-C4,0x21010203,0xffff(Empty Slot)
    cec01n01: 1,514,U78AB.001.WZSJW8D-P1-C3,0x21010202,0x200(Ethernet Controller)
    cec01n01: 1,513,U78AB.001.WZSJW8D-P1-C2,0x21010201,0x0(Non VGA device)
    cec01n01: 1,13,U78AB.001.WZSJW8D-P1-C7,0x2104000d,0x200(Ethernet Controller)
    cec01n01: 1,12,U78AB.001.WZSJW8D-P1-C18,0x2103000c,0xffff(Empty Slot)
    cec01n01: 1,11,U78AB.001.WZSJW8D-P1-T5,0x2102000b,0x1003(Unknown Device)
    cec01n01: 1,10,U78AB.001.WZSJW8D-P1-T9,0x2101000a,0x104(RAID Controller)
    cec01n01: 0/0/0
    cec01n01: 256.
    
~~~~
  


##### VIOS partition Operation

1\. To create the partition 

  * Option 1: specify partition parameters with *def command 
    
    chdef <node> vmcpus=1/2/4 vmmemory=1/8/16 [vmphyslots=0x21010202,0x2104000d,0x2101000a] vmnics=vlan1,vlan2 vmstorage=5
    Notes: vmnics=vlan1,vlan2  specify the vlan ID of virtual Ethernet adapter that will be created.
           vmstorage=5  specify the virtual scsi server adapter will be created on VIOS partition.
    
    mkvm <node> --vios
    Notes:  --vios: used to specify that you are now creating a vios partition
            If not specified vmphyslots, all the physical resource will be allocated to the VIOS partition.

  * Option 2: specify partition parameters with *vm command 
    
    mkvm node --vios vmcpus=1/2/4 vmmemory=1/8/16 [vmphyslots=0x21010202,0x2104000d,0x2101000a] 
    vmnics=vlan1,vlan2 vmstorage=5
    

2\. To change the partition configuration 
    
    chvm node  --vios \
    vmcpus=1/2/4 vmmemory=1/8/16 [add_physlots=0x21010202,0x2104000d,0x2101000a] add_vmnics=vlan3,vlan4 add_vmstorage=5
    chvm node del_physlots=add_physlots=0x21010202,0x2104000d,0x2101000a
    chvm node del_vadapter=slot_id
    Notes: The new parameter for vmcpus, vmmemory and add_physlots will take affect for the next
             power off of the node.
           The virtual adapter created for add_vmnics, add_vmstorage will take affect immediately, but  
           you shall restart the node to apply those virtual adapter into OS.
           For add_vmnics, the admin shall makesure no duplicated vlan ids used.
           The slot_id for del_vadapter can only be deleted when the node is powered off or the virtual 
           adapter has not been applied to node OS yet.

##### normal LPAR partition Operation

1\. To create the partition 

  * Option 1: specify partition parameters with *def command 

~~~~     
    chdef <node> vmcpus=1/2/4 vmmemory=1/8/16 [vmphyslots=0x21010202] vmnics=vlan1 \
     vmstorage=viosnodename:slotid
~~~~ 
    Notes: vmnics=vlan1  specify the vlan ID of virtual Ethernet adapter that will be created.
           vmstorage=viosnodename:slotid  specify the vios node name and virtual scsi server adapter slot that the vscsi client adapter created on logical partition will connect to.

~~~~     
    mkvm <node>
~~~~     

  * Option 2: specify partition parameters with *vm command 

~~~~     
    mkvm node vmcpus=1/2/4 vmmemory=1/8/16 [vmphyslots=0x21010202] vmnics=vlan1 vmstorage=viosnodename:slotid
~~~~     

2\. To change the partition configuration 

~~~~     
    chvm node  vmcpus=1/2/4 vmmemory=1/8/16 [add_physlots=0x21010202] add_vmnics=vlan1 add_vmstorage=viosnodename:slotid
    chvm node del_physlots=0x21010202
    chvm node del_vadapter=slot_id
~~~~ 

#### Remove partition

The command **rmvm** can be used to remove all the resources assigned to the specified partition. 
 
~~~~    
     rmvm cec01n01
    cec01n01: Done
~~~~ 

## OS provisioning and configuration for VIOS partition(Optional)

### install OS for VIOS partition

#### create suitable vios OS image

There will be two iso file for a single vios OS, the admin must run copycds for the two iso file in order: 
 
~~~~    
    copycds -n vios2.2.2.2 -a ppc64 /iso/dvdimage.v1.iso
    copycds -n vios2.2.2.2 -a ppc64 /iso/dvdimage.v2.iso
~~~~     

After copycds, an osimage object will be created like this: 

~~~~ 
    
    lsdef -t osimage vios2.2.2.2_sysb
    Object name: vios2.2.2.2_sysb
        imagetype=NIM
        osarch=ppc64
        osdistroname=vios2.2.2.2
        osname=AIX
        provmethod=nimol

~~~~ 

#### configure the ip address for the vios partition

To configure ip address for vios partition, you can either though adding ip,hostname pair into /etc/hosts or through the following command: 

~~~~     
    chdef node ip=x.x.x.x
    makehost node
~~~~     

#### configure password for specific user 'padmin' of VIOS
 
~~~~    
    chtab key=vios passwd.username=padmin passwd.password=cluster
~~~~     

#### configure DNS resolution

~~~~     
    makedns -n
    makedns -a
~~~~     

#### configure node's conserver

~~~~     
    makeconservercf node
~~~~     

#### get the mac address of a vios partition

~~~~     
    getmacs node -D
~~~~     

#### set provmethod for the partition and install OS

~~~~ 
    
    chdef node netboot=nimol
    nodeset node osimage= vios2.2.2.2_sysb
    rbootseq node net
    rpower node reset

~~~~ 

    Note: The installnic had been configured to be the physical
          adapter of a SEA adapter if there were virtual Ethernet adapter created.

### configure virtual adapters for VIOS partition

This section is about configuring virtual adapters. 

#### list all the virtual adapter created for VIOS partition

~~~~
    lsvm vios1
    ...
    vios1: 2,0,U8247.22L.10112CA-V2-C0,0x30000000,vSerial Server
    vios1: 2,1,U8247.22L.10112CA-V2-C1,0x30000001,vSerial Server
    vios1: 2,3,U8247.22L.10112CA-V2-C3,0x30000003,vEth (port_vlanid=1,mac_addr=423609722279)
    vios1: 2,4,U8247.22L.10112CA-V2-C4,0x30000004,vEth (port_vlanid=2,mac_addr=421f0972227a)
    vios1: 2,5,U8247.22L.10112CA-V2-C5,0x30000005,vSCSI Server
    vios1: 2,6,U8247.22L.10112CA-V2-C6,0x30000006,vSCSI Server
    ...
~~~~

#### config SEA

##### list all the virtual device

~~~~ 
     xdsh vios1 -l padmin "ioscli lsdev -type adapter"
    vios1: name             status      description
    vios1: ent0             Defined     N/A
    vios1: ent1             Defined     N/A
    vios1: ent2             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent3             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent4             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent5             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent6             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent7             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent8             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent9             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent10            Available   PCIe2 10GbE SFP+ SR 4-port Converged Network Adapter (df1020e214100f04)
    vios1: ent11            Available   PCIe2 10GbE SFP+ SR 4-port Converged Network Adapter (df1020e214100f04)
    vios1: ent12            Available   PCIe2 100/1000 Base-TX 4-port Converged Network Adapter (df1020e214103c04)
    vios1: ent13            Available   PCIe2 100/1000 Base-TX 4-port Converged Network Adapter (df1020e214103c04)
    vios1: ent14            Available   Virtual I/O Ethernet Adapter (l-lan)
    vios1: ent15            Available   Virtual I/O Ethernet Adapter (l-lan)
    vios1: vhost0           Available   Virtual SCSI Server Adapter
    vios1: vhost1           Available   Virtual SCSI Server Adapter
    vios1: vsa0             Available   LPAR Virtual Serial Adapter
~~~~ 

##### match virtual device show in OS with the vritual Ethernet adapter created with *vm

In order to match the virtual device such as ent14/ent15 with the virtual ethernet adapter created with *vm, you need to first list the vpd information for the device, then match the "Hardware Location Code" with the slot information list in 'lsvm'.    

###### list the vpd infomation for a virtual device.

~~~~
        xdsh vios1 -l padmin "ioscli lsdev -dev ent14 -vpd"
    vios1:   ent14            U8247.22L.10112CA-V2-C3-T1  Virtual I/O Ethernet Adapter (l-lan)
    vios1: 
    vios1:         Network Address.............423609722279
    vios1:         Displayable Message.........Virtual I/O Ethernet Adapter (l-lan)
    vios1:         Hardware Location Code......U8247.22L.10112CA-V2-C3-T1
    vios1: 
    vios1:   PLATFORM SPECIFIC
    vios1: 
    vios1:   Name:  l-lan
    vios1:     Node:  l-lan@30000003
    vios1:     Device Type:  network
    vios1:     Physical Location: U8247.22L.10112CA-V2-C3-T1
~~~~

###### Manually match the Hardware Location code:

You can get "vios1: 2,3,U8247.22L.10112CA-V2-C3,0x30000003,vEth (port_vlanid=1,mac_addr=423609722279)" contain the same Location code "U8247.22L.10112CA-V2-C3" with ent14, so the virtual slot num for ent14 is '3'. For more information about the meaning of lsvm output, pls reference manpage of [lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html).

##### create virtual SEA adapter

~~~~ 
    
    xdsh vios1 -l padmin "ioscli mkvdev -sea ent2 -vadapter ent14 -default ent14 -defaultid 1"
    vios1: ent16 Available
    vios1: en16
    vios1: et16

~~~~ 

##### configure address information for the SEA adapter

~~~~ 
    
xdsh vios1 -l padmin "ioscli mktcpip -hostname vios1 -inetaddr 192.168.100.1 -interface en16 \
    -netmask 255.255.255.0"
~~~~     

##### check the SEA adapter, you can get a new "shared Ethernet Adapter"

~~~~     
     xdsh vios1 -l padmin "ioscli lsdev -type adapter"
    vios1: name             status      description
    vios1: ent0             Defined     N/A
    vios1: ent1             Defined     N/A
    vios1: ent2             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent3             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent4             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent5             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent6             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent7             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent8             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent9             Available   4-Port Gigabit Ethernet PCI-Express Adapter (e414571614102004)
    vios1: ent10            Available   PCIe2 10GbE SFP+ SR 4-port Converged Network Adapter (df1020e214100f04)
    vios1: ent11            Available   PCIe2 10GbE SFP+ SR 4-port Converged Network Adapter (df1020e214100f04)
    vios1: ent12            Available   PCIe2 100/1000 Base-TX 4-port Converged Network Adapter (df1020e214103c04)
    vios1: ent13            Available   PCIe2 100/1000 Base-TX 4-port Converged Network Adapter (df1020e214103c04)
    vios1: ent14            Available   Virtual I/O Ethernet Adapter (l-lan)
    vios1: ent15            Available   Virtual I/O Ethernet Adapter (l-lan)
    vios1: ent16            Available   Shared Ethernet Adapter
~~~~ 

#### config vSCSI server

##### Find out the vscsi server adapter

~~~~ 
     xdsh vios1 -l padmin "ioscli lsdev -type adapter"
    vios1: name             status      description
...
    vios1: vhost0           Available   Virtual SCSI Server Adapter
    vios1: vhost1           Available   Virtual SCSI Server Adapter
    vios1: vsa0             Available   LPAR Virtual Serial Adapter

~~~~ 

You can get 2 vscsi server adapter vhost0, vhost1 here. 

##### match virtual device show in OS with the vritual SCSI adapter created with *vm

In order to match the virtual device such as vhost0/vhost1 with the virtual SCSI adapter created with *vm, you need to first list the vpd information for the device, then match the "Hardware Location Code" with the slot information list in 'lsvm'.    

###### list the vpd infomation for a virtual device.

~~~~
    xdsh vios1 -l padmin "ioscli lsdev -dev vhost0 -vpd"
    vios1:   vhost0           U8247.22L.10112CA-V2-C5  Virtual SCSI Server Adapter
    vios1: 
    vios1:         Hardware Location Code......U8247.22L.10112CA-V2-C5
    vios1: 
    vios1:   PLATFORM SPECIFIC
    vios1: 
    vios1:   Name:  v-scsi-host
    vios1:     Node:  v-scsi-host@30000005
    vios1:     Physical Location: U8247.22L.10112CA-V2-C5
~~~~

###### Manually match the Hardware Location code:

You can get "vios1: 2,5,U8247.22L.10112CA-V2-C5,0x30000005,vSCSI Server" contain the same Location code "U8247.22L.10112CA-V2-C5" with vhost0, so the virtual slot num for vhost0 is '5'. For more information about the meaning of lsvm output, pls reference manpage of [lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html).

##### list out the physical volumes

~~~~ 
    
    xdsh vios1 -l padmin "ioscli lspv"               
    vios1: NAME          PVID                                           VG               STATUS
    vios1: hdisk0           0001592a32970e2c                     rootvg           active

~~~~ 

##### create LV

All the hard disk are assigned to Volume Group rootvg, so we create a logical volume on it 

~~~~     
    xdsh vios1 -l padmin "ioscli mklv -lv rootvg_20G rootvg 20G"
    vios1: rootvg_20G

~~~~ 

##### attach the 20G logical volume to a virtual SCSI server adapter

~~~~ 
    
    xdsh vios1 -l padmin "ioscli mkvdev -vdev rootvg_20G -vadapter vhost0"      
    vios1: vtscsi0 Available
~~~~ 

##### check the mapping

~~~~ 
    xdsh vios1 -l padmin "ioscli lsmap -vadapter vhost0"                  
    vios1: SVSA            Physloc                                      Client Partition ID
    vios1: --------------- -------------------------------------------- ------------------
    vios1: vhost0          U8247.22L.10112CA-V2-C5                      0x00000000
    vios1: 
    vios1: VTD                   vtscsi0
    vios1: Status                Available
    vios1: LUN                   0x8100000000000000
    vios1: Backing device        rootvg_20G
    vios1: Physloc               
    vios1: Mirrored              N/A
~~~~ 

### Set up the SSH keys for the user to the VIOS partition if need

The following command can be used to set up the SSH key for VIOS partition. 

~~~~ 
    
    DSH_REMOTE_PASSWORD=<xxxx> xdsh vios1 -K -l padmin --devicetype=vios
    /usr/bin/ssh setup is complete.
    return code = 0

~~~~ 

~~~~ 
    xdsh vios1 -l padmin date
    vios1: Tue May 27 01:51:46 CDT 2014 
~~~~ 

## Energy Management

IBM Power Servers support the Energy management capabilities like to query and monitor the 

* Power Saving Status
* Power Capping Status
* Power Consumption
* CPU Frequency
* Ambient temperature
* Fan Speed
*  ... 

and to set the 

* Power Saving
* Power Capping
* CPU frequency

xCAT offers the command 'renergy' to manipulate the Energy related features for Power Server. Refer to the man page of [renergy](http://xcat.sourceforge.net/man1/renergy.1.html) to get the detail of usage.
