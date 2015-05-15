<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Terminology](#terminology)
  - [Downloading and Installing DFM](#downloading-and-installing-dfm)
- [Discovering and Defining New Power 775 Hardware](#discovering-and-defining-new-power-775-hardware)
  - [Initiate a network boot over HFI](#initiate-a-network-boot-over-hfi)
  - [**Discovery Overview**](#discovery-overview)
  - [Define the Service LAN(s) in the Database and DHCP](#define-the-service-lans-in-the-database-and-dhcp)
    - [**Enable SLP on Juniper Switches **](#enable-slp-on-juniper-switches-)
    - [**Configure xCAT Service VLANs **](#configure-xcat-service-vlans-)
  - [Set consoleondemand in the site table to yes](#set-consoleondemand-in-the-site-table-to-yes)
  - [Power On and Configure the HMCs](#power-on-and-configure-the-hmcs)
    - [**Discover HMCs and define them in xCAT DB**](#discover-hmcs-and-define-them-in-xcat-db)
    - [**Define the HMC hscroot password in the database**](#define-the-hmc-hscroot-password-in-the-database)
    - [**Enable ssh interface to the HMC**](#enable-ssh-interface-to-the-hmc)
    - [**Change HMC hscroot password**](#change-hmc-hscroot-password)
  - [Define the Frame Name/MTMS Mapping](#define-the-frame-namemtms-mapping)
  - [Use xcatsetup to Create Initial Definitions in the Database](#use-xcatsetup-to-create-initial-definitions-in-the-database)
  - [Creating Initial Node Definitions Manually](#creating-initial-node-definitions-manually)
  - [Discover the BPAs, Modify Their Network Information, and Connect To Them](#discover-the-bpas-modify-their-network-information-and-connect-to-them)
  - [Power On the FSPs, Discover Them, Modify Network Information, and Connect](#power-on-the-fsps-discover-them-modify-network-information-and-connect)
  - [Update the CEC firmware, and Validate CECs Can Power Up](#update-the-cec-firmware-and-validate-cecs-can-power-up)
  - [Define the LPAR Nodes and Create the Service/Utility LPARs](#define-the-lpar-nodes-and-create-the-serviceutility-lpars)
    - [**Define LPAR Nodes with xcatsetup**](#define-lpar-nodes-with-xcatsetup)
    - [**Define LPAR Nodes with rscan**](#define-lpar-nodes-with-rscan)
    - [**Splitting the Service Node Octant into Multiple LPARS**](#splitting-the-service-node-octant-into-multiple-lpars)
- [xCAT Direct FSP and BPA Management Capabilities](#xcat-direct-fsp-and-bpa-management-capabilities)
  - [xCAT commands which were modified to add DFM support](#xcat-commands-which-were-modified-to-add-dfm-support)
  - [Overview of Using DFM Hierarchically](#overview-of-using-dfm-hierarchically)
  - [Defining xCAT DFM and HMC hardware connections to Frames and CECs](#defining-xcat-dfm-and-hmc-hardware-connections-to-frames-and-cecs)
  - [Make HMC hardware connections to Frames for Service Focal point](#make-hmc-hardware-connections-to-frames-for-service-focal-point)
  - [**Using rspconfig**](#using-rspconfig)
    - [**rspconfig to update password (optional)**](#rspconfig-to-update-password-optional)
    - [**rspconfig to update frame number (optional)**](#rspconfig-to-update-frame-number-optional)
    - [**rspconfig to query or request huge page memory (optional)**](#rspconfig-to-query-or-request-huge-page-memory-optional)
  - [Using the *vm commands to define partitions in xCAT DFM](#using-the-vm-commands-to-define-partitions-in-xcat-dfm)
      - [**The Power 775 Partitioning Overview**](#the-power-775-partitioning-overview)
    - [Power 775 Manufacturing Defaults](#power-775-manufacturing-defaults)
    - [**chvm**](#chvm)
    - [**lsvm**](#lsvm)
    - [**Some examples for the partitioning commands**](#some-examples-for-the-partitioning-commands)
        - [For chvm](#for-chvm)
        - [For lsvm](#for-lsvm)
  - [Using xCAT DFM rpower support to control the Frame, CEC, and LPAR power](#using-xcat-dfm-rpower-support-to-control-the-frame-cec-and-lpar-power)
    - [rpower actions on a Frame](#rpower-actions-on-a-frame)
    - [rpower actions on an CEC](#rpower-actions-on-an-cec)
    - [rpower actions on an LPAR](#rpower-actions-on-an-lpar)
  - [Updating the BPA and FSP firmware using xCAT DFM](#updating-the-bpa-and-fsp-firmware-using-xcat-dfm)
    - [**Overview**](#overview)
    - [**Preparing for a firmware upgrade**](#preparing-for-a-firmware-upgrade)
    - [**Perform disruptive Firmware update for Frame/CEC on Power 775**](#perform-disruptive-firmware-update-for-framecec-on-power-775)
    - [**Perform Deferred Firmware upgrades for frame/CEC on Power 775**](#perform-deferred-firmware-upgrades-for-framecec-on-power-775)
      - [**Deferred firmware update Background**](#deferred-firmware-update-background)
      - [**temp/perm side, pending_power_on_side attributes in Deferred firmware update**](#tempperm-side-pending_power_on_side-attributes-in-deferred-firmware-update)
      - [**The procedure of the deferred firmware update **](#the-procedure-of-the-deferred-firmware-update-)
      - [**Recover the system if the power code/firmware failed to be loaded (Available for both CECs and Frames)**](#recover-the-system-if-the-power-codefirmware-failed-to-be-loaded-available-for-both-cecs-and-frames)
    - [**Recovery procedure if the new firmware does not perform well (Available for CECs and Frames)**](#recovery-procedure-if-the-new-firmware-does-not-perform-well-available-for-cecs-and-frames)
    - [**Commit currently activated LIC update(copy T to P) for a CEC/Frame on Power 775**](#commit-currently-activated-lic-updatecopy-t-to-p-for-a-cecframe-on-power-775)
    - [**Recover the system from a P/P situation because of the failed firmware update**](#recover-the-system-from-a-pp-situation-because-of-the-failed-firmware-update)
  - [Opening a remote console to the CEC LPAR using xCAT DFM](#opening-a-remote-console-to-the-cec-lpar-using-xcat-dfm)
  - [Enable 'dev' and 'celogin1' login for CEC/Frame (optional)](#enable-dev-and-celogin1-login-for-cecframe-optional)
- [Hardware Discovery Directly from the xCAT Management Node](#hardware-discovery-directly-from-the-xcat-management-node)
- [Energy Management](#energy-management)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

This cookbook provide information about initializing, discovering, defining, and managing the system **Power 775** hardware. **Everything described in this document is only supported in xCAT 2.6.6 and above.** If you have other system p hardware, see [XCAT_System_p_Hardware_Management] .

If you are setting up a Power 775 cluster hierarchical cluster, it's better to get an overview about the hardware and software management of the SN and CN from the doc:

  * [DFM_Service_Node_Hierarchy_support].

For the whole flow of setting up a Hierarchical Cluster, we can refer to the following two docs:

  * [Setting_Up_an_AIX_Hierarchical_Cluster]
  * [Setting_Up_a_Linux_Hierarchical_Cluster]

More information about the Power 775 related software can be found at:

  * https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+Overview
  * https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+-+Cluster+Guide

### Terminology

The following terms will be used in this document:

**xCAT DFM**: Direct FSP Management is the name that we will use to describe the ability for xCAT software to communicate directly to the System p server's service processor without the use of the HMC for management.

**Frame node**: A node with hwtype set to frame represents a high end System P server 24 inch frame.

**BPA node**: is node with a hwtype set to bpa and it represents one port on one bpa (each BPA has two ports). For xCAT's purposes, the BPA is the service processor that controls the frame. The relationship between Frame node and BPA node from system admin's perspective is that the admin should always use the Frame node definition for the xCAT hardware control commands and xCAT will figure out which BPA nodes and their ip addresses to use for hardware service processor connections.

**CEC node**: A node with attribute hwtype set to cec which represents a System P CEC (i.e. one physical server).

**FSP node**: FSP node is a node with the hwtype set to fsp and represents one port on the FSP. In one CEC with redundant FSPs, there will be two FSPs and each FSP has two ports. There will be four FSP nodes defined by xCAT per server with redundant FSPs. Similar to the relationship between Frame node and BPA node, system admins will always use the CEC node for the hardware control commands. xCAT will automatically use the four FSP node definitions and their attributes for hardware connections.

### Downloading and Installing DFM

For most operations, the Power 775 is managed directly by xCAT, not using the HMC. This requires the **new xCAT Direct FSP Management plugin** (xCAT-dfm-*.ppc64.rpm), which is not part of the core xCAT open source, but is available as a free download from IBM. You must download this and install it on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document.

Download [DFM](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&release=All&platform=All&function=all) and the prerequisite [hardware server](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&product=ibm/Other+software/IBM+High+Performance+Computing+%28HPC%29+Hardware+Server&release=All&platform=All&function=all) package from [Fix Central](http://www-933.ibm.com/support/fixcentral/)&nbsp;:

    Product Group:      Power
    Product:            Cluster Software
    Cluster Software:   direct FSP management plug-in for xCAT


And

    Product Group:      Power
    Product:            Cluster Software
    Cluster Software:   HPC Hardware Server


  * xCAT-dfm RPM
  * ISNM-hdwr_svr RPM (linux)
  * isnm.hdwr_svr installp package (AIX)

The downloaded packages contains the installable rpm which has been tar-ed and zipped(compressed). After downloading these packages, uncompress, untar and install the hardware server package first and then do the same for the DFM package:

**[RH]:**

If you have been following the xCAT documentation, you should already have the yum repositories set up to pull in whatever xCAT dependencies and distro RPMs are needed (libstdc++.ppc, libgcc.ppc, openssl.ppc, etc.).

~~~~
    yum install xCAT-dfm-*.ppc64.rpm ISNM-hdwr_svr-*.ppc64.rpm
~~~~



**[AIX]:**

~~~~
    installp -d . -agQXY isnm.hdwr_svr
    rpm -Uvh xCAT-dfm-*.ppc.rpm
~~~~


## Discovering and Defining New Power 775 Hardware

When setting up a new cluster, you can use the xCAT commands [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html) and [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to specify the proper definition of all of the cluster hardware in the xCAT database, by automatically discovering and defining them. This is optional - you can define all of the hardware in the database by hand, but that can be confusing and error prone.

**Note:** this document focuses on the following environment:

  * Power 775 clusters
  * using permanent IP addresses for BPA and FSPs (instead of random/dynamic addresses)
  * direct fsp/bpa management (DFM)
  * supporting (optionally) redundant FSPs and BPAs
  * firewall should be disable on the EMS otherwise the command lsslp will return no response and can't discover nodes.

If you want to discover and define older system p hardware, read [XCAT_System_p_Hardware_Management].

The hardware discovery should be performed after the Management Node is installed and configured with xCAT as indicated by this flow:

  1. Install the OS on the management node
  2. Install the xCAT prereqs and xCAT software on the management node
  3. Configure xCAT and other services on the management node
  4. **Discover and define the cluster hardware components**
  5. Set up and install service nodes
  6. Create the images that should be installed or booted on the node

### Initiate a network boot over HFI

[Initiate_a_network_boot_over_HFI_on_Power_775](Initiate_a_network_boot_over_HFI_on_Power_775)

### **Discovery Overview**

Here is the **summary** of the steps needed to discover the hardware and defined it properly in the database. Each step of the summary is explained in more detail in the subsequent sections.

  * Define the service LAN(s) in the database
  * Configure the networks in dhpcd
  * Power on and configure the HMCs
  * Manually power on the Power 775 frames
  * Collect the VPD information (MTM and serial number) for each frame and define the name you want each frame to have
  * Define initial definitions in the xCAT database for the hardware components either manually or using xcatsetup
  * Use lsslp to discover the BPAs, match them with the corresponding frame and BPA objects in the database (using the mtms), and write additional attributes for the frames and BPAs in the database.
  * Configure dhcpd with the permanent ip/mac pairs for all the BPAs
  * Use xCAT to connect to and configure the BPAs
  * Associate the frames with the appropriate HMC
  * Verify the hw ctrl setup is correct for the frames and the BPAs
  * Get the frames out of rack standby so you can fill the frames and power up the FSPs
  * Use lsslp to discover the FSPs, match them with the corresponding CEC and FSP objects in the database (using the cage # and frame mtms), and write additional attributes for the CECs and FSPs in the database.
  * Configure dhcpd with the permanent ip/mac pairs for all the FSPs
  * Use xCAT to connect to and configure the FSPs
  * Verify the hw ctrl setup is correct for the CECs and the FSPs
  * Associate the CECs with the appropriate HMC
  * Define the LPARs as nodes in the xCAT database using either xcatsetup or rscan
  * Split some octants into multiple LPARs (optional)

Easy, right? Each step is explained in more detail below.

In the examples given below, it is assumed that you have redundant service LANs and that the xCAT management node has 2 NICs, each connected to one of the service LANs. The subnet of the first example service LAN is 10.230.0.0/255.255.0.0 and the subnet of the 2nd example service LAN is 10.231.0.0/255.255.0.0 .

### Define the Service LAN(s) in the Database and DHCP

xCAT uses [SLP](http://en.wikipedia.org/wiki/Service_Location_Protocol) to discover the hardware components on the service networks. Before doing this, you must validate the following:

  * Make sure that xCAT MN, Frame BPAs, and HMC ethernet connections are physically attached to service LAN ethernet switches.
  * The Frame BPAs ports are 1G. Ensure they are connected to 1G ports on the service LAN ethernet switches.
  * Make sure SLP protocol is supported on the service LAN switches, where IGMP-Snooping is enabled, and Internet Protocol address (239.0.0.0) was set working with Cisco switches. Please reference information below if using Juniper switches.
  * Configure the xCAT MN to give dynamic DHCP IP addresses to the hardware components so that they can respond to SLP broadcasts.

#### **Enable SLP on Juniper Switches **

The P775 cluster may be using the Juniper ethernet switch to support the BPA/FSP HW service VLANS. The information below was provided by P775 network administrator on how to enable Juniper switch working with igmp-snooping for SLP support. We recommend to remove the HW service vlans from igmp-snooping protocol settings. The default configuration for igmp-snooping on the IBM J48E switch is to enable igmp-snooping for all VLANs:

~~~~
    protocols {
           igmp-snooping {
           vlan all;
~~~~


Assuming there are multiple ethernet vlans being supported(HW service and management)on Juniper switch, the igmp-snooping configuration should enable igmp-snooping for only the cluster management VLAN and not the HW service VLANs.

~~~~
    protocols {
           igmp-snooping {
           vlan management;
~~~~


The Juniper administrator commands to make this change are the following after entering into edit mode:

~~~~
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
     admin@j48052# commit synchronize  (use the 'synchronize' if more than one switch configured in virtual chassis)

~~~~

#### **Configure xCAT Service VLANs **

This section provide the commands used to setup the xCAT HW service VLANs into the the xCAT database and dhcp server environment.

**Note**: if you are adding new additional hardware to an existing cluster (not initially creating the cluster) then you can skip this section. If you are adding new networks to the cluster, then you will need to execute some steps in this section.

If you haven't already, configure with static IP addresses the management node's NICs that are connected to the service vlan and cluster management .

If you already had the management node's service LAN NICs configured when you installed xcat, it automatically ran "makenetworks" and created the necessary entries in the networks table. If not, run:

~~~~
    makenetworks
~~~~


Now set the networks.dynamicrange attribute for each service LAN. For example the following represents 2 HW service VLANS&nbsp;:

~~~~
    chdef -t network 10_230_0_0-255_255_0_0 dynamicrange=10.230.200.1-10.230.200.200
    chdef -t network 10_231_0_0-255_255_0_0 dynamicrange=10.231.200.1-10.231.200.200
~~~~

**Note:** on AIX, the permanent IP addresses that the BPAs and FSPs will eventually be given must also be in the dynamic range. DHCP will give out dynamic addresses starting from the bottom of the dynamic range, so plan to have the permanent addresses be higher in the range such that there will be no collisions. For example, make the dynamic range 10.230.1.1-10.230.3.200, then plan to have the BPA permanent IP addresses in the 10.230.2.* range and the FSPs in the 10.230.3.*. Assuming you have less than 254 BPAs and FSPs, DHCP will initially give them dynamic addresses in the 10.230.1.* range. On linux, the dynamic range should **not** include the permanent IP addresses, and should therefore be big enough to just contain the dynamic addresses.

If you want the network definitions to have more user friendly names in the database, you can set them to anything you want. For example:

~~~~
    chdef -t network 10_230_0_0-255_255_0_0 -n servicelan1
    chdef -t network 10_231_0_0-255_255_0_0 -n servicelan2
~~~~

Set [site](http://xcat.sourceforge.net/man5/site.5.html).dhcpinterfaces to the list of NICs (on the management node and service nodes) that DHCP should listen on. For the management node, this is normally the NICs that are connected to the service LAN and the NICs connected to the cluster management LAN. For the service node it should only be the NIC connected to the compute node LAN:

~~~~
     chdef -t site clustersite dhcpinterfaces='mgmtnode|eth1,eth2,eth3,eth4;service|hf0'
~~~~


Set the powerinterval in the site table to 30. This is needed to meet the demand of the large number LPARs in the Power 775 system. For more information see By default it is 0.
See [Hints_and_Tips_for_Large_Scale_Clusters].





~~~~
     chdef -t site clustersite powerinterval=30
~~~~


On AIX, you have to stop the bootp daemon before starting dhcp, because they listen on the same port number:

    Stop bootp from starting on reboot or restart of inetd by commenting out the bootps line in /etc/inetd.conf file:



    #bootps dgram udp wait root /usr/sbin/bootpd bootpd /etc/bootptab

    Restart inetd and kill bootp just to make sure:



~~~~
    refresh -s inetd                            # restart the inetd subsystem


    kill `ps -ef | grep bootp | grep -v grep | awk '{print $2}' ` # stop the bootp daemon
~~~~

    Uncomment this line in /etc/rc.tcpip so that dhcpsd will start after a reboot.



~~~~
    start /usr/sbin/dhcpsd "$src_running"             # start up the DHCP Server
~~~~

Have xCAT configure the service network stanza for dhcpd and then start the daemon:

~~~~
    makedhcp -n
    service dhcpd restart   # linux
    startsrc -s dhcpsd      # AIX

~~~~

Look at the DHCP configuration file on the xCAT management node to ensure that it contains only the networks you want:

~~~~
    cat /etc/dhcpd.conf        # Linux, except for RHEL6
    cat /etc/dhcp/dhcpd.conf   # RHEL6
    cat /etc/dhcpsd.cnf        # AIX
~~~~


If you need to make updates to the DHCP configuration file, you should stop the DHCP daemon, edit the DHCP configuration file, and then restart the DHCP daemon on your xCAT MN.

### Set consoleondemand in the site table to yes

Before run any DFM hardware control commands in the large cluster, you should make sure the consoleondemand in the site table is set to yes. This is needed to meet the demand of the large number LPARs and CECs. In the Power 775 system, console is opened by fsp-api which sends command to the HWS. When set to 'no', all the consoles will be opened, and it will affect the performance of the DFM hardware control commands. When set to 'yes', conserver connects and creates the console output only when the user opens the console. Default is no on Linux, yes on AIX.

~~~~
     chdef -t site clustersite consoleondemand=yes
~~~~


After you change the change the consoleondemand=yes, you should run makeconservercf to take effects.

~~~~
     makeconservercf
~~~~


### Power On and Configure the HMCs

There is a new work item to support remote discovery and connectivity to the HMC from xCAT MN. This section is currently TBD, but will cover some of the following:

  * Manually collect MACs of HMCs and create database definitions manually (including the ipmi table)
  * makedhcp hmc
  * Enable: SLP, SSH, SOL (if not enabled from the factory)
  * Disable DHCP
  * Configure the IMM

The xCAT admin will manually need to connect the HMC at this time.

**Setting up the HMC network for use by xCAT**

Reference the HMC website and documentation for more knowledge. The following are minimal steps required to Setup the HMC network for Static IP,and enable SLP and SSH ports working with HMC GUI.

  * Open the HMC GUI, Select **HMC Management**, then **Change Network Settings**.
  * Select **Customize Network Configuration**, and then** LAN Adapters **.
  * Select **Ethernet interface **configured on the service network.
  * Click on the **Details **button.
  * Select **Basic Settings**, Click on **Open**, and **Specify IP address.**
  * Fill in **IP address**, **Netmask**for HMC static IP on the xCAT service network.
  * Make sure that DHCP Server box is not selected and is blank.
  * Select on **Firewall Settings**, Click on **SLP, Secure Shell, **in the upper window.(You may also want to enable other HMC Firewall settings)
  * Click on the **Allow incoming **button for each required setting.
  * Make sure you Select OK at the bottom of the window to save your updates.
  * Reboot the HMC, and then make sure Network changes are properly working.

#### **Discover HMCs and define them in xCAT DB**

This section will describe the hardware discovery of the HMCs and their requirement to support Service Focal Point (SFP) working with Power 775 clusters. You will execute xCAT commands "lsslp" and "mkdef" to define the HMC nodes in xCAT DB. See man page of lsslp for details.

Note: Even if you use xCAT Direct FSP Management, you still need to discover the HMC, and make the connections between HMC and the xCAT MN. The HMC will always be used for Service Focal Point, Service Repair and Verify procedures.

Run lsslp to locate the HMC information and write into a HMC stanza file. The IP address is the address assigned to the hardware service network on the EMS.

~~~~
     lsslp -s HMC -i 10.230.0.0,10.231.0.0 -z > /hmc/stanza/file
~~~~


Review the HMC stanza file and make necessary modifications. You will want to include the username and password attributes, and update HMC ip attribute to the proper ip address of the service network for the target HMC node. Make sure that the ip address and host name is resolvable in the xCAT cluster name resolution (/etc/hosts, DNS).


Write the HMC stanza information into xCAT DB with xCAT command mkdef.

~~~~
    cat /hmc/stanza/file | mkdef -z
~~~~


#### **Define the HMC hscroot password in the database**

You will need to supply the current hscroot password to xCAT by defining it in the passwd table in the database.

~~~~
    chtab key=hmc passwd.username=hscroot passwd.password=<current password>
~~~~


#### **Enable ssh interface to the HMC**

You will want to enable the SSH interface between the xCAT MN and HMC, so the xCAT commands will run without being prompted for passwords. Run the "rspconfig" command to do this:

~~~~
     rspconfig  <HMC node>  sshcfg=enable
~~~~


After you setup the ssh keys to the HMC with the rspconfig command, xCAT will no longer need the hscroot password in the database and it can be removed. It will be needed in the future, if root's ssh keys are ever regenerated on the EMS. If ssh keys are regenerated, then the **rspconfig &lt;HMC node&gt; sshcfg=enable command** will have to be rerun, and the new password will need to be available in the database on the EMS.

#### **Change HMC hscroot password**

If you change hscroot password on the HMC, you should update the xCAT database password file with the new password. See "Define the HMC hscroot password". You do not need to rerun rspconfig &lt;HMC node&gt; sshcfg=enable because changing the password does not affect ssh keys.

### Define the Frame Name/MTMS Mapping

SLP gives xCAT a list of hardware components on the network, without telling it the physical location of each. This means that xCAT does not have a way to give each component a sensible name without getting a little bit of information from you: the mapping between the name you want each frame to have and its MTMS (machine type, model, and serial #).

To provide this information, first manually power on the frames. (If the frames are being powered on (EPO'ed), the BPAs will come up in rack standy mode. At this point there will not be any power to the CEC FSPs so they will not yet be able to be discovered. So we must first discover the frames, get them defined in the database, and make connections to them, so we can get them out of rack standby mode. This process will be accomplished in the next several sections.)

**At this point, you should do one of the next 2 sections, but not both. If you want to use xcatsetup to define nodes, follow the steps in the green section entitled "Use xcatsetup to Create Initial Definitions in the Database". If you want to create the nodes manually, follow the steps in the blue section entitled "Creating Initial Node Definitions Manually". After following either the green or blue section, continue with the section "Discover the BPAs, Modify Their Network Information, and Connect To Them".**




### Use xcatsetup to Create Initial Definitions in the Database

The [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html) command creates initial node definitions in the xCAT database, based on naming conventions and IP address ranges that you provide via a cluster configuration file. In a later step, xCAT will combine this information with the SLP information discovered on the service network to create a complete picture of your cluster hardware components. **Note:** If the xcatsetup command does not apply well to your cluster because your naming patterns have too many exceptions, you can instead create node definitions manually. See the section
[XCAT_Power_775_Hardware_Management/#creating-initial-node-definitions-manually](XCAT_Power_775_Hardware_Management/#creating-initial-node-definitions-manually) for instructions on how to do that.

Create a cluster config file with information about the hardware components that should be defined. Note that you are not only specifying the naming pattern for the HMCs, frames, and CECs, but also the permanent IP addresses you want the BPAs and FSPs to have. (When the BPAs and FSPs initially power on, they will get dynamic IP addresses from DHCP. Once you are done with this whole discovery chapter, DHCP will always provide the IP addresses you define in the cluster config file. We call these the "permanent" IP addresses.) For a detailed description of the cluster config file, see the [xcatsetup man page](http://xcat.sourceforge.net/man8/xcatsetup.8.html). Here's a sample config file:

Have xCAT generate a stanza file of frame definitions (with MTMS) so you can easily give each one a name:

~~~~
    lsslp -s FRAME -i 10.230.0.0,10.231.0.0 --vpdtable > vpd-frame.stanza
~~~~


Note: -m won't be used and multicast will be the one of the default way of lsslp from xCAT 2.7.3.

Edit the stanza file to give the desired node name to each frame object, identifying the frames by MTMS. (The node name is the identifier before the colon. See the [xcatstanzafile man page](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html) for details.) The node names should help indicate frame position (e.g. frame01, frame02, etc.) because xCAT will use that information to understand the physical order of the hardware.

Create a file called supernodelist.txt that specifies the supernode numbers for all of the CECs. For example,

~~~~
     frame61: 0,1,16
     frame62: 17,32
     frame63: 33,48,49
~~~~


Now create the cluster config file. Here is a simple configuration file example.

~~~~
    # A small cluster config file for a single 2 frame bldg block.
    # Just the hmcs, frames, bpas, cecs, and fsps are created.
    xcat-site:
     use-direct-fsp-control = 1

    xcat-hmcs:
     hostname-range = hmc[1-3]
     starting-ip = 40.0.0.110

    xcat-frames:
     hostname-range = frame[1-3]
     num-frames-per-hmc = 1
     vpd-file = vpd-frame.stanza
       # This assumes you have 2 service LANs:  a primary service LAN 40.x.y.z/255.0.0.0 that all of the port 0's
       # are connected to, and a backup service LAN 41.x.y.z/255.0.0.0 that all of the port 1's are connected to.
       # "x" is the frame number and "z" is the bpa/fsp id (1 for the first BPA/FSP in the Frame/CEC, 2 for the
       # second BPA/FSP in the Frame/CEC). For BPAs "y" is always be 0 and for FSPs "y" is the cec id.
     vlan-1 = 40
     vlan-2 = 41

    xcat-cecs:
     hostname-range = f[1-3]c[01-12]
     num-cecs-per-frame = 12
     supernode-list = supernodelist.txt

~~~~


Run xcatsetup to create the initial node definitions:

~~~~
    xcatsetup <config-file-name>
~~~~

This writes the following essential attributes to the database (more attributes are written, but these are the attributes that are necessary for running lsslp later on):

  * frames: nodelist.node, nodelist.groups, ppc.nodetype, vpd.serial, vpd.mtm nodetype.nodetype
  * bpas: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent, nodetype.nodetype
  * cecs: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent, ppc.cageid, nodetype.nodetype
  * fsps: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent, nodetype.nodetype
  * creates groups: hmc, frame, bpa, cec, fsp

Note: unlike most nodes in the xCAT database, the BPAs and FSPs will use their IP address (the permanent one) as their node name. The BPA and FSP nodes are also hidden by default and will normally not be displayed by the [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) command. Use the -S option of [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) to display the hidden nodes.

### Creating Initial Node Definitions Manually

If the xcatsetup command does not apply well to your cluster because your naming patterns have too many exceptions, you can create node definitions manually to prepare for running lsslp. (If you used xcatsetup, skip this section.)

Before running lsslp ensure the BPAs picked up a temporary ip address from DHCP. Otherwise lsslp will return with no reponses.

    For AIX DHCP environment, you can execute the "dadmin" command  .

~~~~
    dadmin -s | grep -v Free  # AIX only
~~~~


    For RH6 DHCP environment, you can check the "dhcpd.leases"
    files located under /var/lib/dhcpd directory

~~~~
    cat /var/lib/dhcpd/dhcpd.leases
~~~~


Run lsslp to produce a stanza file of the frames and BPAs:

~~~~
    lsslp -s FRAME -i 10.230.0.0,10.231.0.0 -z >frames.stanza
~~~~


Edit the stanza file to give the frames the symbolic node names you want, and the BPAs the IP addresses you want. Adjust the parent and hcp attributes accordingly. Leave the otherinterfaces attribute set to the dynamic DHCP addresses. See the [xcatstanzafile man page](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html)] for the syntax.

Note: the IP addresses you choose for BPAs should not be in the DHCP dynamic range.

  * Note: It is assumed the serial numbers are provided via documentation that came with the machine. The mac addresses cannot be added until the devices acquire a temporary ip address.

**Frame node**: Here is an example of the attributes that should be set for the frame nodes:

~~~~
    frame14:
     objtype=node
     groups=frame,all
     hcp=frame14
     id=14
     mgt=bpa
     mtm=78AC-100
     nodetype=ppc
     hwtype=frame
     parent=1
     serial=BB50026
     sfp=hmc1
~~~~


In the above example, the attribute meanings are:

  * hcp - the hardware control point for this frame. For DFM, it is always set to itself.
  * id - the frame number.
  * mgt - the type of the hardware control point (hcp). bpa means xCAT will manage it directly without the HMC.
  * mtm - the machine type and model
  * parent - the parent for this frame. It will be set to blank, or contain the building block number.
  * serial - serial number of the frame
  * sfp - the HMC that is connected to this frame for the purpose of collecting hardware serviceable events.

**BPA node**: Here is an example of the attributes that should be set for the BPA nodes:

~~~~
    10.230.2.14:
     objtype=node
     groups=bpa,all
     side=A-0
     nodetype=ppc
     hwtype=bpa
     parent=frame14
     mac=00:09:6b:ad:07:b5
     hidden=1
~~~~


  * side - &lt;BPA&gt;-&lt;port&gt; The side attribute refers to which BPA, A or B, which is determined by the slot value returned from lsslp command. It also lists the physical port within each BPA which is determined by the IP address order from the lsslp response. This information is used internally when communicating with the BPAs.
  * parent - always set to the frame node that this BPA is part of.
  * mac - the mac address of the BPA, which is got from lsslp.
  * hidden - set to 1 means that xCAT will hide the node by default in nodels and lsdef output. Normally BPA nodes are hidden because you usually only have to use the frame nodes for management. To see the BPA nodes in the nodels or lsdef output, use the -S flag.

Create the frame and BPA objects in the xCAT database:

~~~~
    cat frames.stanza | mkdef -z
~~~~


** Frame in Rack Standby **: If you are working with brand new frames, they may still be in "rackstandby" mode, which means there is no power to the CECs, which means the FSPs can not respond to the lsslp commands below at this time. If this is your situation, complete the next section [XCAT_Power_775_Hardware_Management/#discover-the-bpas-modify-their-network-information-and-connect-to-them](XCAT_Power_775_Hardware_Management/#discover-the-bpas-modify-their-network-information-and-connect-to-them) now to get the frames out of rackstandby mode. Then return to this section and complete the lsslp and mkdef commands for the CECs and FSPs.

Run lsslp to produce a stanza file of the CECs and FSPs:

~~~~
    lsslp -s CEC -i 10.230.0.0,10.231.0.0 -z >cecs.stanza

~~~~

Edit the stanza file to give the CECs the symbolic node names you want, and the FSPs the IP addresses you want. Adjust the parent and hcp attributes accordingly. Leave the otherinterfaces attribute set to the dynamic DHCP addresses.

Note: the IP addresses you choose for FSPs should not be in the DHCP dynamic range.

**CEC node**: Here is an example of the attributes that should be set for the CEC nodes:

~~~~
    cec06:
     objtype=node
     groups=cec,all
     hcp=cec06
     id=6
     mgt=fsp
     mtm=9125-F2C
     nodetype=ppc
     hwtype=cec
     parent=frame14
     serial=02D8B25
     sfp=hmc1
     supernode=7,0
~~~~


In above example, the attributes:

  * hcp - the hardware control point for this CEC. For DFM, it is always set to itself.
  * id - the cage number of this CEC in a 24 inch frame
  * mgt - is set to fsp
  * mtm - the machine type and model
  * parent - the frame node that this CEC is in
  * serial - serial number of the cec
  * sfp - the HMC that is connected to this CEC for the purpose of collecting hardware serviceable events.
  * supernode - the HFI network supernode number that this CEC is part of. See the ISNM documentation for what to set this to.

To go along with the CEC supernode numbers, set the HFI switch topology value in the xCAT site table. See the ISNM documentation for the correct value.

~~~~
    chdef -t site topology=32D
~~~~


**FSP node**: Here is an example of the attributes that should be set for the FSP nodes:

~~~~
    10.230.4.6:
     objtype=node
     groups=all,fsp
     nodetype=ppc
     hwtype=fsp
     parent=cec06
     side=A-0
     mac=00:09:6b:ad:07:b3
     hidden=1
~~~~


  * side - &lt;FSP&gt;-&lt;port&gt; The side attribute refers to which FSP, A or B, which is determined by the slot value returned from lsslp command. It also lists the physical port within each FSP which is determined by the IP address order from the lsslp response. This information is used internally when communicating with the FSPs.
  * parent - set to the CEC that this FSP is in.
  * mac - the mac address of the FSP, which is got from lsslp.
  * hidden - set to 1 means that xCAT will hide the node by default in nodels and lsdef output. Normally FSP nodes are hidden because you usually only have to use the CEC nodes for management. To see the FSP nodes in the nodels or lsdef output, use the -S flag.

Create the CEC and FSP objects in the xCAT database:

~~~~
    cat cecs.stanza | mkdef -z
~~~~


</div> </div>


### Discover the BPAs, Modify Their Network Information, and Connect To Them

Discover the BPAs on the network, match them with the corresponding frames and BPAs in the database (using the mtms), and write additional attributes in the database (like mac addresses). The -i flag uses the ip addresses that is configured for dhcp.

~~~~
    lsslp -s FRAME -i 10.230.0.0,10.231.0.0 -w
~~~~


Verify that the frame and BPA definitions in the database are correct.

~~~~
    lsdef frame
    lsdef bpa -S      # normally BPAs are hidden from output, so need the -S flag
~~~~

Verify that:

  * The parent of the BPA's is set to the frame object it is in
  * The frame id attribute is set to the frame number you would like it to have
  * The frame parent is set to the building block number it is in (optional)

Configure DHCP with the permanent ip/mac pairs so that it will always give the BPAs their permanent IP address from now on:

~~~~
    makedhcp bpa
~~~~


Create nodename/ip mapping for BPAs:

~~~~
    makehosts bpa
~~~~


Verify that the proper IP/MAC pairs were configured in dhcp:

~~~~
    cat /var/lib/dhcpd/dhcpd.leases      # RHEL 6
    cat /var/lib/dhcp/db/dhcpd.leases    # SLES 11
    cat /etc/dhcpsd.cnf                 # AIX

~~~~

To enable xCAT to connect to the BPAs, you must add the current passwords for the frames/BPAs in the xCAT database. If the password for all of the frames is the same, you can set the username/password in the passwd table:

~~~~
    chtab key=bpa,username=HMC passwd.password=xxx
    chtab key=bpa,username=admin passwd.password=yyy
    chtab key=bpa,username=general passwd.password=zzz

~~~~

If the passwords for some of the frames/BPAs are different, you can set the passwords for individual frames/BPAs in the ppcdirect table:

~~~~
    chdef frame1 passwd.HMC=xxx passwd.admin=yyy passwd.general=zzz
~~~~


The BPAs will send their DHCP request to the DHCP server about every five minutes. So after the DHCP configured, the BPAs will get their permanent IP addresses about five minutes later. The [pping](http://xcat.sourceforge.net/man1/pping.1.html) can be a help to see if the BPAs has got new IP addresses. If the BPA has got its permanent IP address, the pping result will be: "bpa1:ping".

~~~~
    pping bpa
~~~~


For the BPAs who can't refresh their IP addresses, the --resetnet option, the [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) command expects each BPA's otherinterfaces attribute to be set to the dynamic IP address that it currently has, and the node name of the BPA to be set to the permanent IP address you want it to have.

~~~~
    rspconfig bpa1 --resetnet
~~~~


  * Note: the --resetnet may fail if enough time has elasped that the BPAs already automatically renewed their leases and received the new permanent IP addresses. In that case, just confirm that DHCP server has the proper IPs configured. If rspconfig does not work properly you may need to EPO the P775 frame for the new BPA primary IPs to get assigned.

Have xCAT's DFM daemon (hdwr_server) on the xCAT EMS establish connections to all of the frames for the primary service VLAN: The default attributes for mkhwconn are -T lpar and --port 0 for the primary hardware service VLAN.

~~~~
    mkhwconn frame -t
~~~~


The support for Dual hardware service VLANs is not currently supported for the P775 cluster in xCAT 2.6.6. If the admin needs to work with a 2nd hardware service VLAN, they need to specify the -T lpar and --port 1 options to establish connections to the second service VLAN for each BPA of the frames.

~~~~
    mkhwconn frame -t -T lpar --port 1
~~~~


Verify the hardware connections were made successfully for the primary service VLAN. If the admin does allocate a second service VLAN for the cluster, these hardware connections may show a "LINE DOWN".

~~~~
    lshwconn frame
    frame14: 40.14.0.1: side=a,ipadd=40.14.0.1,alt_ipadd=unavailable,state=LINE UP
    frame14: 40.14.0.2: side=b,ipadd=40.14.0.2,alt_ipadd=unavailable,state=LINE UP
~~~~

If the BPA passwords are still the factory defaults, you must change them before running any other commands to them:

~~~~
    rspconfig frame general_passwd=general,<newpd>
    rspconfig frame admin_passwd=admin,<newpd>
    rspconfig frame HMC_passwd=,<newpd>
~~~~

Verify the hardware control setup is correct for the frames. If this is the initial frame setup or an EPO happened, the BPAs will at rack standby state. The normal state of the BPAs if not in "rack standby" should be at "Both BPAs at standby" state.:

~~~~
    rpower frame state
    frame14: BPA state - Both BPAs at rack standby

    lshwconn frame
    frame14(40.14.0.2): resource_type=frame,side=b,ipaddr=192.168.200.239,alt_ipaddr=unavailable,state=Connected
    frame14(40.14.0.1): resource_type=frame,side=a,ipaddr=192.168.200.247,alt_ipaddr=unavailable,state=Connected
    frame14(20.0.0.167): Connection not found
    frame14(20.0.0.168): Connection not found
~~~~

There is a possibility that you will need to update the frame power code firmware as part of the P775 installation. Make sure you locate and down load the supported P775 power code and firmware from IBM Fix Central to a directory on your xCAT MN. The rflash command references this GFW directory and updates the frame power code for your frames. Make sure that there is space available in /tmp file system since rflash temporarily places GFW tracking files under /tmp/fwupdate. You will update the CECs firmware at a later time. Before do the firmware update, make sure the pending power on side of the Frames' BPAs are temp. If not, set it to temp.

~~~~
    rspconfig frame pending_power_on_side
    rspconfig frame pending_power_on_side=temp
~~~~

And then, start the update.

~~~~
    rflash frame -p <directory> --activate disruptive
    (output to be added here)
    rinv frame firm
~~~~

Set the frame number in each frame object: You should first check to make sure you have setup the "id" attribute to match the proper frame number. If the frame id=0, you should update using the "chdef" for each frame object.

~~~~
    rspconfig frame 'frame=*'
~~~~

Note: at this point in the process, the CECs should not have power to them yet. But if for some reason they do, they must be powered off before the frame number can be set.

Set the system name of the frame to match the node name in the xCAT database. This will cause the frame names displayed in the HMC to match the frame names in the xCAT database.

    rspconfig frame 'sysname=*'

To enable xCAT to connect Frames to the target HMC, you must add the current HMC username password for the frame nodes in the xCAT database. If the password for all of the frames are the same, you can set the username/password in the passwd table; if unique passwords are used, they must be updated in the ppcdirect table.

~~~~
    chtab key=frame,username=HMC passwd.password=xxx
~~~~


Associate the HMCs with the appropriate frames: You should first make sure that the frame objects have setup the "sfp" attribute to the proper HMC node object. This is needed to allow the frame to support connections to the BPA through DFM and the HMC. You also need to make sure that there is proper SSH connection from the EMS to the HMC.

~~~~
    mkhwconn frame -s
~~~~


Inform the hardware installation team that the HMCs should now be able to recognize the frames and that they may begin to fill the water in the frames.

**Note:** the HMC may list the frames as incomplete.

Have the hardware installation team inform you when the water fill procedure is complete. Then use xCAT to move the frames out of rack standby mode so the final top-off procedure can be completed on the HMC:

~~~~
    rpower frame exit_rackstandby
~~~~


Verify the state of the frames:

~~~~
    rpower frame state
    frame14: BPA state - Both BPAs at standby
~~~~


### Power On the FSPs, Discover Them, Modify Network Information, and Connect

When the frames exited rackstandby mode in the end of the last section, the FSPs were powered on. This should have caused the FSPs to request and receive a dynamic IP address from DHCP. The MAC addresses cannot be collected by the lsslp command below until this has taken place.

Run lsslp to discover the CECs/FSPs, and match the discovered hardware with the corresponding objects in the database, and write additional attributes in the database. The -i flag specifies the ip subnet that is configured as the dynamic range in DHCP.

~~~~
    lsslp -s CEC -i 10.230.0.0,10.231.0.0 -w
~~~~


For each FSP discovered on the network, the lsslp command uses the cage # and its parent (frame) MTMS to match the correct CEC entry in the database. The attributes that will be written to the database are:

  * the mtms of each CEC object
  * the MAC for each FSP will be stored in the mac.mac attribute and the dynamic IP address of each FSP object will be temporarily stored in the hosts.otherinterfaces attribute.

You can confirm these settings by running:

~~~~
    lsdef -i mtm,serial cec
    lsdef -S -i mac,otherinterfaces fsp
~~~~


You can compare this information to the labels on the front of the CECs to verify that the matching worked correctly. Review/verify all of the attributes of the CECs and FSPs:

~~~~
    lsdef cec
    lsdef fsp -S      # normally FSPs are hidden from output, so need the -S flag
~~~~

Verify that:

  * The parent of the FSPs are set to the CEC they are in
  * The parent of the CECs are set to the frame they are in
  * The supernode attribute is set for each CEC

Configure DHCP with the permanent ip/mac pairs so that it will always give the FSPs their permanent IP address from now on:

~~~~
    makedhcp fsp
~~~~


Create nodename/ip mapping for FSPs:

~~~~
    makehosts fsp
~~~~


Verify that the proper IP/MAC pairs were configured in dhcp:

~~~~
    cat /var/lib/dhcpd/dhcpd.leases # RHEL 6
    cat /var/lib/dhcp/db/dhcpd.leases # SLES 11
    cat /etc/db_file.cr # AIX
~~~~


The FSPs will send their DHCP request to the DHCP server about every five minutes. So after the DHCP configured, the FSPs will get their permanent IP addresses about five minutes later. The [pping](http://xcat.sourceforge.net/man1/pping.1.html) can be a help to see if the FSPs has got new IP addresses. If the FSP has got its permanent IP address, the pping result will be: "FSP1:ping".

~~~~
    pping fsp
~~~~


For the FSPs who can't refresh their IP addresses, the --resetnet option, the [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) command expects each FSP's otherinterfaces attribute to be set to the dynamic IP address that it currently has, and the node name of the FSP to be set to the permanent IP address you want it to have.

~~~~
    rspconfig fsp1 --resetnet
~~~~


  * Note: the --resetnet may fail if enough time has elasped that the CECs already automatically renewed their leases and received the new IP addresses. In that case, just confirm that they have the correct IP address.

If you want to verify that all the BPAs and FSPs now have the correct IP addresses and are defined in the database with the correct parents, you can run lsslp to have it match what it discovers on the network with what is defined in the database:


~~~~
    $ lsslp -i 10.230.0.0,10.231.0.0
    BPA     78AC-100    9920035        A-0   40.11.0.1      f11c00bpca_a
    BPA     78AC-100    9920035        B-0   40.11.0.2      f11c00bpcb_a
    CEC     9125-F2C    02C4D86                             f11c01
    FSP     9125-F2C    02C4D86        A-0   40.11.1.1      f11c01fsp1_a
    FSP     9125-F2C    02C4D86        B-0   40.11.1.2      f11c01fsp2_a
    CEC     9125-F2C    02C4E06                             f11c02
    FSP     9125-F2C    02C4E06        A-0   40.11.2.1      f11c02fsp1_a
    FSP     9125-F2C    02C4E06        B-0   40.11.2.2      f11c02fsp2_a
    ...
    CEC     9125-F2C    02C5066                             f12c12
    FSP     9125-F2C    02C5066        A-0   40.12.12.1     f12c12fsp1_a
    FSP     9125-F2C    02C5066        B-0   40.12.12.2     f12c12fsp2_a
    FRAME   78AC-100    9920035                             frame11
    FRAME   78AC-100    9920033                             frame12

~~~~

To enable xCAT to connect to the FSPs, you must add the current passwords for the CEC/FSPs in the xCAT database. If the password for all of the CECs is the same, you can set the username/password in the passwd table:

~~~~
    chtab key=fsp,username=HMC passwd.password=xxx
    chtab key=fsp,username=admin passwd.password=yyy
    chtab key=fsp,username=general passwd.password=zzz
~~~~


If the passwords for some of the CEC/FSPs are different, you can set the passwords for individual CEC/FSPs in the ppcdirect table:

~~~~
    chdef cec1 passwd.HMC=xxx passwd.admin=yyy passwd.general=zzz
~~~~


Have xCAT's DFM daemon (called hw server) establish connections to all of the CECs:

~~~~
    mkhwconn cec -t
~~~~


For Dual VLAN, need to specify the --port option to establish the two connections for each FSP of the CECs:

~~~~
    mkhwconn cec -t -T lpar
    mkhwconn cec -t -T lpar --port 1
~~~~


If the FSP passwords are still the factory defaults, you must change them before running any other commands to them:

~~~~
    rspconfig cec general_passwd=general,<newpd>
    rspconfig cec admin_passwd=admin,<newpd>
    rspconfig cec HMC_passwd=abc123,<newpd>
~~~~

Set the system name of the CEC to match the node name in the xCAT database. This will cause the CEC names displayed in the HMC to match the CEC names in the xCAT database.

~~~~
    rspconfig cec 'sysname=*'
~~~~


To enable xCAT to connect CECs to the target HMC, you must add the current HMC username password for the cec nodes in the xCAT database. If the password for all of the cecs are the same, you can set the username/password in the passwd table; if unique passwords are used, they must be updated in the ppcdirect table.

~~~~
    chtab key=cec,username=HMC passwd.password=xxx
~~~~


Associate the HMCs with the appropriate CECs:

~~~~
    mkhwconn cec -s
~~~~


Verify the connections were made successfully:

~~~~
    lshwconn cec
    (output to be added here)
~~~~

Verify the hardware control setup is correct for the CECs:

~~~~
    rpower cec state
    (output to be added here)
~~~~

~~~~
    lshwconn cec -s
    cec1(192.168.200.239): resource_type=frame,side=b,ipaddr=192.168.200.239,alt_ipaddr=unavailable,state=Connected
    cec1(192.168.200.247): resource_type=frame,side=a,ipaddr=192.168.200.247,alt_ipaddr=unavailable,state=Connected
    cec1(20.0.0.167): Connection not found
    cec1(20.0.0.168): Connection not found
~~~~

### Update the CEC firmware, and Validate CECs Can Power Up

The admin should plan to upgrade the firmware for both the Bulk Power Code (BPC), and the CEC firmware. This is accomplished by using the rflash xCAT command from the xCAT EMS. The admin should download the supported GFW from the IBM Fix central website, and place it in a directory that is available to be read by the xCAT EMS.

Use rinv command to get the current firmware levels of the frames and CECs:

~~~~
    rinv frame firm
    rinv cec firm
    (output to be added here)
~~~~

Make sure the pending power on side of the CEC's FSPs are temp. If not, set it to temp.

~~~~
    rspconfig cec pending_power_on_side
    rspconfig cec pending_power_on_side=temp
~~~~

Use the rflash command to update the firmware levels for the CECs. Then validate that the new firmware is loaded:

~~~~
    rflash cec -p <directory> --activate disruptive
    (output to be added here)
    rinv cec firm
~~~~

Verify that the CECs are healthy:

~~~~
    rpower cec state
    rvitals cec lcds
~~~~

You may want to check that the CNM switch configuration data is properly defined in the xCAT DB prior to powering up the CECs and working with the Octant/LPAR definitions. This activity may save you some CEC reboot time later.

Check that the correct HFI switch topology has been set in the site table. The topology definition is based on the the number of CECs and type of HFI network configured for your Power 775 cluster.

~~~~
     lsdef -t site -l -i topology     # should be one of supported configs: 8D, 32D, 128D
~~~~


Check to make sure that the CEC node objects have the proper "supernode" attribute defined. The supernode will specify the HFI configuration being used by the CEC. You should also make sure the cage id is properly defined where the "id" attribute matches the cage position for the CEC node. The CNM daemon and configuration commands will setup the Master ISR identifier for each CEC. This will allow the HFI communications to work within the Power 775 cluster.

~~~~
     lsdef  cec     # check supernode and id attribute for each cec object
~~~~


The P775 admin can now power on the CECs, and validate they come up to working state. You can monitor the power up of the CECs using the rpower and rvitals command. You are looking for the CECs to be "Operating" with a finished good state. If they are not in the "Operating" state, additional hardware debug will be necessary to understand the failure.

~~~~
    rpower cec on
    rvitals cec lcds
    rpower cec state
~~~~

When we power on all the cecs within a frame, we must put a 30 second delay between each CEC within one frame. We use the syspowerinterval attribute in the site table to control the cec boot up speed.

~~~~
      chdef -t site syspowerinterval=30
~~~~


And then put the all the cecs within one frame as a group, and power them on:

~~~~
      rpower cecswithin_one_frame on
~~~~


For 12 CECs within one Frame, the rpower will take about 5m33s.

Check the HMCs for any SFP service events that were generated during CEC boot. Then, make sure there are no unexpected deconfigured resources in the CECs:

~~~~
    rinv cec deconfig
~~~~


### Define the LPAR Nodes and Create the Service/Utility LPARs

You can define the LPAR nodes in different ways: use xcatsetup, or implement manually with xCAT commands. Using xcatsetup will be faster/easier for large clusters because it will generate the lpar configuration based on a cluster configuration file. Alternatively, the admin can define the lpars in the database using the xCAT rscan command to create a lpar stanza file. You need to then edit the stanza file to modify the node name of each LPAR. This approach is simpler for small clusters, but becomes tedious quickly for large clusters.

**Follow either the green section entitled "Define LPAR Nodes with xcatsetup" or the blue section entitled "Define LPAR Nodes with rscan" (but not both). After that, continue on with the section "Splitting the Service Node Octant into Multiple LPARS".**




#### **Define LPAR Nodes with xcatsetup**

Use the [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html) config file that you used earlier in this document to define the hardware components. To that file, add stanzas for xcat-lpars, xcat-service-nodes, xcat-storage-nodes, and xcat-compute-nodes. Here's an example:

~~~~
    # A small cluster config file for a single 2 frame bldg block.
    # Just the hmcs, frames, bpas, cecs, and fsps are created.
    xcat-site:
    use-direct-fsp-control = 1

    xcat-hmcs:
    hostname-range = hmc[1-2]

    xcat-frames:
    hostname-range = frame[1-2]
    num-frames-per-hmc = 1
    vpd-file = vpd-frame.stanza
       # This assumes you have 2 service LANs:  a primary service LAN 40.x.y.z/255.0.0.0 that all of the port 0's
       # are connected to, and a backup service LAN 41.x.y.z/255.0.0.0 that all of the port 1's are connected to.
       # "x" is the frame number and "z" is the bpa/fsp id (1 for the first BPA/FSP in the Frame/CEC, 2 for the
       # second BPA/FSP in the Frame/CEC). For BPAs "y" is always be 0 and for FSPs "y" is the cec id.
     vlan-1 = 40
     vlan-2 = 41

    xcat-cecs:
    hostname-range = cec[01-24]
    num-cecs-per-frame = 12

    xcat-building-blocks:
     num-frames-per-bb = 2
     num-cecs-per-bb = 24

    xcat-lpars:
    num-lpars-per-cec = 8

    xcat-service-nodes:
    num-service-nodes-per-bb = 1
    cec-positions-in-bb = 1
    # this is for the ethernet NIC on each SN
    hostname-range = sn1
    starting-ip = 10.250.1.1
    # this value is the same format as the
    # hosts.otherinterfaces attribute except
    # the IP addresses are starting IP addresses
    otherinterfaces = -hf0:10.251.1.1,-hf1:11.251.1.1,-hf2:12.251.1.1,-hf3:13.251.1.1,-ml0:14.251.1.1
    # if you want the service nodes to route traffic
    # between the MN and compute nodes,
    # then provide the netmask that should be used
    # for each compute network the service
    # nodes are connected to.  The netmask should
    # limit the ip range to just the compute
    # nodes served by this service node.
    route-masks = -hf0:255.255.0.0,-hf1:255.255.0.0,-hf2:255.255.0.0,-hf3:255.255.0.0,-ml0:255.255.0.0

    xcat-storage-nodes:
    num-storage-nodes-per-bb = 2
    cec-positions-in-bb = 12,24
    hostname-range = stor1-stor2
    starting-ip = 10.252.1.1
    aliases = -hf0
    otherinterfaces = -hf1:11.253.1.1,-hf2:12.253.1.1,-hf3:13.253.1.1,-ml0:14.253.1.1

    xcat-compute-nodes:
    hostname-range = n001-n189
    starting-ip = 10.1.1.1
    aliases = -hf0
    # ml0 is for aix.  For linux, use bond0 instead.
    otherinterfaces = -hf1:11.1.1.1,-hf2:12.1.1.1,-hf3:13.1.1.1,-ml0:14.1.1.1
~~~~

Now run xcatsetup with this config file, telling it to just process the new stanzas (since we already created the hardware components earlier):

~~~~
    xcatsetup -s xcat-lpars,xcat-service-nodes,xcat-storage-nodes,xcat-compute-nodes <config-file-name>
~~~~

This will create definitions in the database for the service nodes, storage nodes, and compute nodes with the proper attributes and located in the proper LPARs/CECs. Use the [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) command to display the node definitions to confirm they were created the way you want them.

By default, all of these LPARs already exist in the CECs themselves, with one exception: if you plan to split the service node octant into multiple LPARs (because you don't need all of the octant's resources for the service node), that must be done manually. An example of doing this will be covered in the next section.

#### **Define LPAR Nodes with rscan**

The [rscan](http://xcat.sourceforge.net/man1/rscan.1.html) command reads the actual LPAR configuration in the CEC and creates node definitions in the xCAT database to reflect them. Before use rscan, you should put the cec in operating or standby state. If you already used the xcatsetup command to create the LPAR node definitions, you can skip this section.

Run the [rscan](http://xcat.sourceforge.net/man1/rscan.1.html) command against all of the CECs to create a stanza file of LPAR node definitions:

~~~~
    rscan cec -z >nodes.stanza
~~~~

Edit the stanza file and give each LPAR definition the node name that you want it to have. Remember to name the service node and storage node LPARs the way you want them, and to set the servicenode and xcatmaster attributes of all the non-service node LPARs to the appropriate service node name. Then create the definitions in the database:

~~~~
    cat nodes.stanza | mkdef -z
~~~~

Use the [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) command to display the node definitions to confirm they were created the way you want them.

#### **Splitting the Service Node Octant into Multiple LPARS**

In most cases, the service nodes don't need all of the resources of the octant it is in. Normally, the service node only needs 25% of the CPUs and memory in the octant, unless you are also running the Loadleveler central manager on that service node, in which case we recommend 50% of the resources. This leaves the other 75% or 50% of the resources for an additional LPAR of your choosing: utility node, login node, etc. To create a second LPAR in a service node octant, follow these steps:

  * List the LPARs in the CEC to confirm the current configuration:

~~~~
    lsvm cec01
    1: 520/U78A9.001.312M001-P1-C14/0x21010208/0/0
    1: 514/U78A9.001.312M001-P1-C17/0x21010202/0/0
    1: 513/U78A9.001.312M001-P1-C15/0x21010201/0/0
    1: 512/U78A9.001.312M001-P1-C16/0x21010200/0/0
    1: 569/U78A9.001.312M001-P1-C1/0x21010239/0/0
    1: 568/U78A9.001.312M001-P1-C2/0x21010238/0/0
    1: 561/U78A9.001.312M001-P1-C3/0x21010231/0/0
    1: 560/U78A9.001.312M001-P1-C4/0x21010230/0/0
    1: 553/U78A9.001.312M001-P1-C5/0x21010229/0/0
    1: 552/U78A9.001.312M001-P1-C6/0x21010228/0/0
    1: 545/U78A9.001.312M001-P1-C7/0x21010221/0/0
    1: 544/U78A9.001.312M001-P1-C8/0x21010220/0/0
    1: 537/U78A9.001.312M001-P1-C9/0x21010219/0/0
    1: 536/U78A9.001.312M001-P1-C10/0x21010218/0/0
    1: 529/U78A9.001.312M001-P1-C11/0x21010211/0/0
    1: 528/U78A9.001.312M001-P1-C12/0x21010210/0/0
    1: 521/U78A9.001.312M001-P1-C13/0x21010209/0/0
    cec01: PendingPumpMode=1,CurrentPumpMode=1,OctantCount=8:
    OctantID=0,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=1,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=2,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=3,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=4,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=5,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=6,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=7,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2

~~~~

  * Create a group entry for the Utility node and the attributes that will be the same for this type of node (only have to do this once):

~~~~
    mkdef -t group util mgt=fsp cons=fsp netboot=yaboot nodetype=ppc,osi
    chtab node=util ppc.nodetype=lpar   # soon you can add hwtype=lpar to the mkdef cmd instead of this
~~~~


  * Create the utility LPAR node definition in the xCAT database:

~~~~
    mkdef util01 groups=util,all mgt=fsp hcp=cec01 parent=cec01 id=2 servicenode=sn01 xcatmaster=sn01-hf0
~~~~


  * Create two lpars on the first octant for the utility and service node. This will split the first octant 50/50 and the rest of the lpars will remain allocated with all available memory and CPU. See chvm manpage for more options.

~~~~
    chvm sn01,util01  -i 1 -m non-interleaved -r 0:2
~~~~


  * Verify the Pending now says '2', and Current OctCfg still says '1':

~~~~
    lsvm cec01
~~~~


  * Re-IPL the CEC to have the octant reconfiguration take effect:

~~~~
    rpower cec01 off
    rpower cec01 on

~~~~

  * Verify the Current OctCfg now says '2':

~~~~
    lsvm cec01
~~~~


  * Capture the resources assigned to LPAR 1. All the resources will be assigned to the service node by default. If adapters need to be moved (like ethernet adapters for utility nodes or SAS adapters for I/O nodes) then gather the current configuration.

~~~~
    lsvm sn01 > resources.txt
    1: 520/U78A9.001.312M001-P1-C14/0x21010208/0/0
    1: 514/U78A9.001.312M001-P1-C17/0x21010202/0/0
    1: 513/U78A9.001.312M001-P1-C15/0x21010201/0/0
    1: 512/U78A9.001.312M001-P1-C16/0x21010200/0/0
    1: 569/U78A9.001.312M001-P1-C1/0x21010239/0/0
    1: 568/U78A9.001.312M001-P1-C2/0x21010238/0/0
    1: 561/U78A9.001.312M001-P1-C3/0x21010231/0/0
    1: 560/U78A9.001.312M001-P1-C4/0x21010230/0/0
    1: 553/U78A9.001.312M001-P1-C5/0x21010229/0/0
    1: 552/U78A9.001.312M001-P1-C6/0x21010228/0/0
    1: 545/U78A9.001.312M001-P1-C7/0x21010221/0/0
    1: 544/U78A9.001.312M001-P1-C8/0x21010220/0/0
    1: 537/U78A9.001.312M001-P1-C9/0x21010219/0/0
    1: 536/U78A9.001.312M001-P1-C10/0x21010218/0/0
    1: 529/U78A9.001.312M001-P1-C11/0x21010211/0/0
    1: 528/U78A9.001.312M001-P1-C12/0x21010210/0/0
    1: 521/U78A9.001.312M001-P1-C13/0x21010209/0/0
~~~~


  * The LPARs being reconfigured must be powered off to make any changes for the I/O configuration.

~~~~
    rpower sn01,util01 off
~~~~


  * Edit resources.txt to change the LPAR id 1 to be LPAR id 2 to move resources assigned from LPAR 1 to LPAR 2.

~~~~
    1: 520/U78A9.001.312M001-P1-C14/0x21010208/0/0
    1: 514/U78A9.001.312M001-P1-C17/0x21010202/0/0
    1: 513/U78A9.001.312M001-P1-C15/0x21010201/0/0
    1: 512/U78A9.001.312M001-P1-C16/0x21010200/0/0
    1: 569/U78A9.001.312M001-P1-C1/0x21010239/0/0
    1: 568/U78A9.001.312M001-P1-C2/0x21010238/0/0
    1: 561/U78A9.001.312M001-P1-C3/0x21010231/0/0
    1: 560/U78A9.001.312M001-P1-C4/0x21010230/0/0
    1: 553/U78A9.001.312M001-P1-C5/0x21010229/0/0
    1: 552/U78A9.001.312M001-P1-C6/0x21010228/0/0
    1: 545/U78A9.001.312M001-P1-C7/0x21010221/0/0
    1: 544/U78A9.001.312M001-P1-C8/0x21010220/0/0
    1: 537/U78A9.001.312M001-P1-C9/0x21010219/0/0
    1: 536/U78A9.001.312M001-P1-C10/0x21010218/0/0
    2: 529/U78A9.001.312M001-P1-C11/0x21010211/0/0
    2: 528/U78A9.001.312M001-P1-C12/0x21010210/0/0
    2: 521/U78A9.001.312M001-P1-C13/0x21010209/0/0

~~~~

  * Then reassign those resources moving from lpar1 "sn01" to lpar2 "util01" which will be updated in the CEC:

~~~~
    cat resources.txt | chvm sn01,util01

~~~~

  * Revalidate that the I/O resources are moved by executing the lsvm command against the 2 lpars.

~~~~
    lsvm  sn01,util01
~~~~


  * Power on the LPARs with the new resources:

~~~~
    rpower sn01,util01 on
~~~~


## xCAT Direct FSP and BPA Management Capabilities

**Note:** this chapter is an overview of xCAT's DFM capabilities and **not** a list of steps to be performed during cluster set. This is not a continuation of the Discovery chapter.

xCAT has the capability to manage system p hardware by communicating directly with the FSPs and BPAs of the hardware, instead of using the HMC. This is called Direct FSP/BPA Management (DFM). (Note that the HMC is still used to collect hardware service events.) This section gives an overview of using these capabilities.

### xCAT commands which were modified to add DFM support

Several xCAT commands were modified to add DFM support:

DFM Support

<!---
begin_xcat_table;
numcols=2;
colwidths=10,30;
-->


|Command | Function
---------|-------------------------
|rpower |LPAR and Drawer Power
|rpower |P7IH - Transition low power states
|rcons  |Remote Console
|rflash |Firmware support for FSP and BPA
|rinv   | Get the firmware level of FSP and BPA; get the deconfigured resource of CEC
|rvitals|Display LCD values; Get the rack environmental information
|getmacs|Adapter information collection
|rvitals|List environmental information
|mkhwconn/rmhwconn|Make and remove FSP and BPA hardware connections
|lshwconn|List hardware connection status
|rnetboot|Remote network boot
|lsvm, chvm|LPAR list, creation and removal; I/O slot assignment
|rbootseq|sets the net or hfi device as the first boot device for the specified PPC LPARs
|rspconfig|FSP and BPA password support; get and modify the frame number


<!---
end_xcat_table
-->


### Overview of Using DFM Hierarchically

For the large clusters, we recommend that you set up the DFM hw ctrl hierarchically, so that each service node executes the hw ctrl operations for its nodes (instead of the EMS doing it for all nodes). Hhere is a summary of the procedure:

  1. On the EMS, remove the LPAR Tooltype connections for non-sn-CECs (non-sn-CECs means the CEC objects that do not contain a SN): rmhwconn &lt;non-SN-CECs&gt;
  2. For non-sn-CECs, set the servicenode attribute (noderes.servicenode) to the SN
  3. Set the conserver attribute (nodehm.conserver) for all the non-SN LPARs
    1. set nodehm.conserver of the LPARs in the non-sn-CECs to SN
    2. set the nodehm.conserver of the non-SN LPARs in the sn-CECs to EMS, or do not set it.
  4. Install dfm and hdwr_svr on the SNs
  5. Configure the SN NICs that are connected to the service LANs
  6. From the EMS, for the non-SN cecs, run: mkhwconn &lt;non-SN-CECs&gt; -t
  7. Test/verify setup with lshwconn and rpower state

For the whole flow of setting up a Hierarchical Cluster, refer to the following two docs:

  * [Setting_Up_an_AIX_Hierarchical_Cluster]
  * [Setting_Up_a_Linux_Hierarchical_Cluster]

### Defining xCAT DFM and HMC hardware connections to Frames and CECs

The xCAT administrator can set up the xCAT cluster to connect the Frames and CECs to selected HMCs, xCAT management node, and xCAT service nodes that are attached to the xCAT cluster service VLAN. They can also setup a security environment with passwords used with the HMC, Frame, and CEC. This section will describe what is needed to make the connections to the system p hardware and how to use the mkhwconn, lshwconn, and rmhwconn commands.

  * **Set proper passwords for CEC/Frame/HMC**

The passwords used with CEC/Frame userids 'HMC', 'general' and 'admin' needs to be set correctly in xCAT table **ppcdirect** or table **passwd**, if the cluster is not going to use the default passwords.

Here is an example of table ppcdirect:

~~~~
    #hcp,username,password,comments,disable
    "frame1","HMC","abc123",,
    "frame1","general","abc123",,
    "frame1","admin","abc123",,
    "cec16c1","HMC","abc123",,
    "cec16c1","general","abc123",,
    "cec16c1","admin","abc123",,
~~~~


The passwords used with the HMC nodes working with userid hscroot is located in the xCAT table ppchcp. If you are using xCAT Direct Managment, you need to make the connections between CEC/Frames and xCAT management node, instead of HMC, so you need to set passwords for HMCs.

Here is an example of table ppchcp:

~~~~
    #hcp,username,password,comments,disable
    "c76v1hmc02","hscroot","abc123",,
~~~~


### Make HMC hardware connections to Frames for Service Focal point

Since the HMC is required for our Service Focal Point (SFP) support, it needs to be connected to the designated Frames and be connected on the xCAT MN. To allow the xCAT MN to support DFM and HMC at the same time, xCAT has provided a new attribute "sfp" in the ppc table that can get assigned to each Power 775 Frame node.

The mkhwconn command allows the xCAT administrator to properly setup the BPA/FSP connection between the xCAT management node and Frames/Cecs working with DFM.

~~~~
    mkhwconn noderange -t [-T tooltype] [--port port_value]
~~~~


Note: For xCAT 2.6.6 code support, we only support P775 HW connections working with the primary HW service VLAN. The --port value specifies which service VLAN will be used to create the connection to the FSP/BPA. The value could be 0 or 1. The default value for port will be 0 which is the primary service VLAN. It will be listed in the vpd table where the side column should be as A-0 and B-0; If the port value is 1 this will make HW connections to the back up HW service VLAN, and will represent the side column as A-1 and B-1.

This command will make the proper connections on the target xCAT management node if the Frame is not already connected. To work with xCAT DFM, you should have defined the HMC, admin, and general passwords for Frames in ppcdirect table, run mkhwconn to create the HW connections between xCAT management node and Frames using DFM.

~~~~
    mkhwconn frame1 -t -T lpar
~~~~


For Dual VLAN (not supported in xCAT 2.6.6), we need to specify the --port option to create backup connections for each BPA:

~~~~
    mkhwconn frame1 -t -T lpar --port 1
~~~~


To assign the sfp attribute for the HMC, execute the "chdef" command to the target Frame node object. The admin then executes the "mkhwconn" to connect the target Frame and known CEC to the HMC node object that was previously defined.

~~~~
    chdef frame1 sfp=c76v1hmc02
    mkhwconn frame1 -s
~~~~


will result with Frame node frame1 to be connected by HMC node c76v1hmc02.

See mkhwconn man page for details of this command




  * **List frames/CECs from HMC**

There is the lshwconn command that will provide the current Frame/CEC connection data that is specified on a target HMC, xCAT management node if using xCAT Direct Managementsupport. This information currently provides the Frame/CEC nodes, the FSP/BPA IP address, and the connection status of the BPA/FSP used for the target HMC/xCAT management node.

**Run the following to locate the Frame servers working with connections.**

~~~~
    lshwconn <HMC node>
~~~~


See lshwconn man page for the details.

### **Using rspconfig**

#### **rspconfig to update password (optional)**

The xCAT admin can run the rspconfig command to modify the HMC, admin, and general userid passwords on the Frame/CEC servers. The Frame/CEC servers are pre-set by System P manufacturing using default passwords.

You can use the same password logic for all the System P frames and CECs in your xCAT cluster, or specify unique passwords for HMC, admin, and general userids for selected Frame or CEC server node. You can only execute one Frame/CEC userid one at a time with the rspconfig command in xCAT2.4 . The following contains the rspconfig changing the HMC userid password from access to abc123 used with the Frame and CEC.




~~~~
    rspconfig <frame> HMC_passwd=access,abc123
    rspconfig <cec> HMC_passwd=access,abc123

~~~~

Note:

The default password for userid HMC on Frame/CEC is empty, so if the frame or CEC is new or has been reset to manufactory setting, you can use the following command to initialize the userid HMC's password:

~~~~
    rspconfig <cec> HMC_passwd=,abc123
~~~~


The defualt passwords for userids admin and general are admin and general, so there is no difference between initializing passwords and changing passwords for userids admin and general.

#### **rspconfig to update frame number (optional)**

The xCAT administratorcan run the rspconfig command to specify the frame number information when working with 24 inch frames that contain the BPA logic. This information is helpful for large System P clusters where many frames are being used. The rspconfig command will allow the xCAT admin to list the current frame number, or can set Frame server node to a specific frame number. The admin can work with the ppc table to setup the frame number or execute one Frame server at a time. Setting the frame number is a disruptive command which requires all CECs to be powered off prior to issuing the command.




~~~~
    rspconfig <frame> frame (list current frame number)
    rspconfig <frame> frame=4 (change Frame number to now be frame 4)

~~~~




#### **rspconfig to query or request huge page memory (optional)**

The huge page memory can be used to increase performance for certain applications in specific customer environments, such as the running DB2 on AIX and applications using large mapping on Linux.

You can use the same password logic for all the System P frames and CECs in your xCAT cluster, or specify unique passwords for HMC, admin, and general userids for selected Frame or CEC server node. You can only execute one Frame/CEC userid one at a time with the rspconfig command in xCAT2.4 . The following contains the rspconfig changing the HMC userid password from access to abc123 used with the Frame and CEC.




~~~~
    rspconfig <cec> huge_page
    rspconfig <cec> huge_page=<NUM>
~~~~


Note:

If no value specified, it means query huge page information for the specified CECs, if a CEC is specified, the specified huge_page value NUM will be used as the requested number of huge pages for the CEC, if CECs are specified, it means to request the same NUM huge pages for all the specified CECs.

### Using the *vm commands to define partitions in xCAT DFM

Now that the definitions are in the database and the hardware connections have been made, the xCAT administrator can use the chvm and lsvm commands to define the LPARs within each CEC.

THIS SECTION IS STILL UNDER CONSTRUCTION AND WILL BE UPDATED WITH MORE DETAIL ON THE USE OF THESE COMMANDS

##### **The Power 775 Partitioning Overview**

#### Power 775 Manufacturing Defaults

The Power 775 is configured with a default set of LPARs from manufacturing. These defaults are intended to support the HPC environment and are specific to the needs of the HPC clusters. The default rules are as follows:

  1. Any IO adapters in a CEC will be assigned to the first partition. This includes the disk drive adapters, Ethernet adapters, external storage adapters, etc.
  2. Any CEC with a disk drive will cause the first octant to have a 25/75 LPAR split with the first LPAR being assigned all the IO including the disk drive and giving it 25% of cores and memory. The second partition in this octant will have 75% of the cores and memory.
  3. All other octants will be defined as full partitions.

These rules were defined to make the initial configuration match the cluster requirements for our HPC customers. This will allow the CECs with the disk drives and Ethernet adapters to be setup with the hardware needed to act as the service node while only using the minimal number of cores and memory. It also allows for the automatic assignment of the CEC with the external Disk drives to be assigned to a partition to be used as the GPFS NSD server. These defaults are intended to simplify the bring-up process by preconfiguring the CECs with a set of defaults which should meet most of our customers requirements. Should you need to change these default LPAR configurations we provide commands to do this which are discussed in this section.

**Octant Overview**

The Power 775 CEC contains up to eight octants with each octant containing up to four 8-core P7 processors, associated memory and a single Torrent hub. These octants are defined as octant 0 through octant 7.

**Octant Partition Configurations**

The octants can be logically partitioned into one of a preset number of configurations which define the split of resources for processors and memory per partition. The preset configurations are:

      1. One partition containing all resources [100]
      2. Two partitions with each containing equal resources [50, 50]
      3. Three partitions with the first two partitions containing 25
         percent of the resources and the third partition containing 50
         percent of the resources [25, 25, 50]
      4. Four partitions with each containing equal resources [25, 25, 25, 25]
      5. Two partitions with the first partition containing 25 percent
         of the resources and the second partition containing 75 percent
         of the resources. [25, 75]


The lparid is fixed regardless of how many partitions are defined such that the first lpar in an octant will always have a fixed value. If other partitions are defined for the octant they are defined with the following lparid:

~~~~
    Octant ID 0 - lparid 1, lparid 2, lparid 3, lparid 4
    Octant ID 1 - lparid 5, lparid 6, lparid 7, lparid 8
    Octant ID 2 - lparid 9, lparid 10, lparid 11, lparid 12
    Octant ID 3 - lparid 13, lparid 14, lparid 15, lparid 16
    Octant ID 4 - lparid 17, lparid 18, lparid 19, lparid 20
    Octant ID 5 - lparid 21, lparid 22, lparid 23, lparid 24
    Octant ID 6 - lparid 25, lparid 26, lparid 27, lparid 28
    Octant ID 7 - lparid 29, lparid 30, lparid 31, lparid 32
~~~~

With the default configuration of eight octants with one partition per octant, the lpars are defined with lpar ids of 1, 5, 9, 13, 17, 21, 25 and 29.

**Octant Memory**

The memory of an octant can also be configured to use interleaved or non-interleaved memory. Non-interleaved mode means that memory allocations are only interleaved across the two memory controllers on the local chip in an octant. This is also known as 2MC mode. Interleaved means memory allocations are interleaved across all eight memory controllers in the octant. If an octant is to be partitioned then its memory interleaving value MUST BE non-interleaved. For more information on this please see the Firmware Pervasive Level Design Document for PERCS P7IH and Torrent IO Hub.

The Memory Interleaving Mode can be set to the following values:

     1 - interleaved (also 8MC mode)
     2 - non-interleaved (also 2MC mode)


You may see a value of "0" returned for the memory interleaving value in the lsvm output. This is the default value from the factory or may be seen after a firmware upgrade. If the current memory interleave value is set to 0 then the chvm command must be used to set it to either 1 or 2.

**Pump Mode and memory interleaving**

The pump mode determines what is allowed for the interleaving of memory per CEC. The pump mode has 2 valid values:

~~~~
     0x01 - Node Pump Mode
     0x02 - Chip Pump Mode
~~~~


The default Pump Mode on the CEC is 0x01 (Node Pump Mode). This value allows the memory interleave value to be set to either interleaved or non-interleaved for the octant. A pump mode of Chip Pump Mode forces the memory interleave mode to be non-interleaved for the octant. However, the pump mode value can not be changed by customers and should always be 0x01 - Node Pump Mode.


xCAT partition related commands for Power 775 The partition commands for Power 775 are different from P5 &amp; P6 implementation based on the unique hardware configuration in the Power 775:

#### **chvm**

[chvm](http://xcat.sourceforge.net/man1/chvm.1.html) is designed to set the Octant configure value to split the CPU and memory for partitions, and set Octant Memory interleaving value. The chvm will only set the pending attributes value. After chvm, the CEC needs to be rebooted manually for the pending values to be enabled. Before reboot the cec, the administrator can use chvm to change the partition plan. If the the partition needs I/O slots, the administrator should use chvm to assign the I/O slots.

chvm is also designed to assign the I/O slots to the new LPAR. Both the current IO owning LPAR and the new IO owning LPAR must be powered off before an IO assignment. Otherwise, if the I/O slot is belonged to an LPAR and the LPAR is power on, the command will return an error when trying to assign that slot to a different lpar.

syntax:

~~~~
    chvm [-V| --verbose] noderange -i id [-m memory_interleaving] -r partition_rule
    chvm [-V| --verbose] noderange [-p profile]
~~~~

options:


    -i Starting numeric id of the newly created partitions. The id value only could be 1, 5, 9, 13, 17, 21, 25 and 29.
    -m memory interleaving. The setting value only could be 1 or 2. 2 means non-interleaved mode, the memory cannot be shared across the processors in an octant.  1 means interleaved mode, the memory can be shared. The default value of memory interleaving in chvm is 1 .
    -r partition rule.
    If all the octants configuration value are same in one CEC,  it will be  " -r  0-7:value" .
    If the octants use the different configuration value in one cec, it will be "-r 0:value1,1:value2,...7:value7", or "-r 0:value1,1-7:value2" and so on.
    The octants configuration value for one Octant could be  1, 2, 3, 4, 5.

    The meanings of the octants configuration value  are as following:

    1 - One partition with all cpus and memory of the octant
    2 - Two partitions with a 50/50 split of cpus and memory
    3 - Three partitions with a 25/25/50 split of cpus and memory
    4 - Four partitions with a 25/25/25/25 split of cpus and memory
    5 - Two partitions with a 25/75 split of cpus and memory

    -p the I/O profile.

    The administrator should use [lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html) to get the profile content, and then edit the content, and add the node name with ":" manually before the I/O which will be assigned to the node. It looks like:

~~~~
    lparid1:bus_id1/physical_location_code/drc_index/owner_type/owner/description
    lparid1:bus_id2/physical_location_code/drc_index/owner_type/owner/description
    ...
    lparid2:bus_id/physical_location_code/drc_index/owner_type/owner/description
    ...

    lparidn:bus_id/physical_location_code/drc_index/owner_type/owner/description

    ...
~~~~

The chvm also supports that the file being piped to the command is in above profile format.

#### **lsvm**

[lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html) lists all partition I/O slots information for the partitions specified in noderange. If noderange is a CEC, it gets the CEC's pump mode value, octant's memory interleaving value, the all the octants configure value, and all the I/O slots information

syntax:

~~~~
    lsvm noderange [-l|--long]
~~~~

If no option specify, the output is similar too:

~~~~
    lparid1:bus_id1/physical_location_code/drc_index/owner_type/owner/description
    lparid1:bus_id2/physical_location_code/drc_index/owner_type/owner/description
    ...
    lparid2:bus_id/physical_location_code/drc_index/owner_type/owner/description
    ...

    lparidn:bus_id/physical_location_code/drc_index/owner_type/owner/description

    cecname: octant configuration value

If option -l or --long specify, the output is similar too:

    lpar_name1: lparid1: bus_id1/physical_location_code/drc_index/owner_type/owner/description: BSR_array_number1: Min1/Req1/Max1
    lpar_name1: lparid1: bus_id2/physical_location_code/drc_index/owner_type/owner/description: BSR_array_number1: Min1/Req1/Max1
    ...
    lpar_name2: lparid2: bus_id/physical_location_code/drc_index/owner_type/owner/description: BSR_array_number2: Min2/Req2/Max2
    ...

    lpar_namen: lparidn: bus_id/physical_location_code/drc_index/owner_type/owner/description: BSR_array_numbern: Minn/Reqn/Maxn

    cecname: octant configuration value
~~~~

#### **Some examples for the partitioning commands**

###### For chvm

1\. To create a new partition lpar1 on the first octant of the cec, lpar1 will use all the cpu and memory of the octant 0, enter:

~~~~
    mkdef -t node -o lpar1 mgt=fsp groups=all parent=cec01 nodetype=ppc,osi hwtype=lpar hcp=cec01
~~~~

then:

~~~~
    chvm lpar1 -i 1 -m 1 -r 0:1
~~~~

Output is similar to:


~~~~
    lpar1: Success
    cec01: For Power 775, if chvm succeeds, please reboot the CEC cec01 before using chvm to assign the I/O slots
~~~~

2\. To create a new partition lpar1-lpar2 on the first octant of the cec, each lpar will use 50% cpu and 50% memory of the octant 0, enter:

~~~~
    mkdef -t node -o lpar1-lpar2 mgt=fsp groups=all parent=cec01 nodetype=ppc,osi hwtype=lpar hcp=cec01

~~~~

then:

~~~~
    chvm lpar1-lpar2 -i 1 -m 2 -r 0:2
~~~~

Output is similar to:


~~~~
    lpar1: Success
    lpar2: Success
    cec01: For Power 775, if chvm succeeds, please reboot the CEC cec01 before using chvm to assign the I/O slots

~~~~

3\. To create new partitions lpar1-lpar32 on the whole cec, each LPAR will use 25% cpu and 25% memory of each octant, enter:

~~~~
    mkdef -t node -o lpar1-lpar32 nodetype=ppc,osi hwtype=lpar  mgt=fsp groups=all parent=cec01  hcp=cec01
~~~~

then:

~~~~
    chvm lpar1-lpar32 -i 1 -m 2 -r 0-7:4
~~~~


Output is similar to:


~~~~
    lpar1: Success
    lpar10: Success
    lpar11: Success
    lpar12: Success
    lpar13: Success
    lpar14: Success
    lpar15: Success
    lpar16: Success
    lpar17: Success
    lpar18: Success
    lpar19: Success
    lpar2: Success
    lpar20: Success
    lpar21: Success
    lpar22: Success
    lpar23: Success
    lpar24: Success
    lpar25: Success
    lpar26: Success
    lpar27: Success
    lpar28: Success
    lpar29: Success
    lpar3: Success
    lpar30: Success
    lpar31: Success
    lpar32: Success
    lpar4: Success
    lpar5: Success
    lpar6: Success
    lpar7: Success
    lpar8: Success
    lpar9: Success
    cec01: For Power 775, if chvm succeeds, please reboot the CEC cec01 before using chvm to assign the I/O slots
~~~~


4\. To create new partitions lpar1-lpar8 on the whole cec, each LPAR will use all the cpu and memory of each octant, enter:

~~~~
    mkdef -t node -o lpar1-lpar8 nodetype=ppc,osi hwtype=lpar  mgt=fsp groups=all parent=cec01  hcp=cec01
~~~~

then:

~~~~
    chvm lpar1-lpar8 -i 1 -m 1 -r 0-7:1
~~~~


Output is similar to:


~~~~
    lpar1: Success
    lpar2: Success
    lpar3: Success
    lpar4: Success
    lpar5: Success
    lpar6: Success
    lpar7: Success
    lpar8: Success
    cec01: For Power 775, if chvm succeeds, please reboot the CEC cec01 before using chvm to assign the I/O slots
~~~~

5\. To create new partitions lpar1-lpar9, the lpar1 will use 25% CPU and 25% memory of the first octant, and lpar2 will use 75% CPU and memory of the first octant. lpar3-lpar9 will use all the cpu and memory of each octant. Note that the chvm command does not support both memory interleaving values in one call. Therefore the chvm must be entered twice, once for "-m 2" for partitioned octants and again for "-m 1" for single lpar octants. For example:

~~~~
    mkdef -t node -o lpar1-lpar9 mgt=fsp groups=all parent=cec1 nodetype=ppc,osi hwtype=lpar hcp=cec1
~~~~

then:

~~~~
    chvm lpar1-lpar9 -i 1 -m 2 -r 0:5
    chvm lpar3-lpar9 -i 5 -m 1 -r 1-7:1
~~~~


Output is similar to:


~~~~
    lpar1: Success
    lpar2: Success
    cec1: For Power 775, if chvm succeeds, please reboot the CEC cec1 before using chvm to assign the I/O slots
    lpar3: Success
    lpar4: Success
    lpar5: Success
    lpar6: Success
    lpar7: Success
    lpar8: Success
    lpar9: Success
    cec1: For Power 775, if chvm succeeds, please reboot the CEC cec1 before using chvm to assign the I/O slots
~~~~

6\. To change the I/O slot profile for lpar4 using the configuration data in the file /tmp/lparfile, the I/O slots information is similar to:

~~~~
    4: 514/U78A9.001.0123456-P1-C17/0x21010202/2/1
    4: 513/U78A9.001.0123456-P1-C15/0x21010201/2/1
    4: 512/U78A9.001.0123456-P1-C16/0x21010200/2/1
~~~~

then run the command:

~~~~
    cat /tmp/lparfile | chvm lpar4
~~~~

7\. To change the I/O slot profile for lpar1-lpar8 using the configuration data in the file /tmp/lparfile. Users can use the output of lsvm.and remove the cec information, and modify the lpar id before each I/O, and run the command as following:

~~~~
    chvm lpar1-lpar8 -p /tmp/lparfile
~~~~

###### For lsvm

1\. To list the I/O slot information of lpar1, enter:

~~~~
    lsvm lpar1
~~~~

Output is similar to:

~~~~
    1: 514/U78A9.001.0123456-P1-C17/0x21010202/2/1
    1: 513/U78A9.001.0123456-P1-C15/0x21010201/2/1
    1: 512/U78A9.001.0123456-P1-C16/0x21010200/2/1
~~~~

2\. To list the I/O slot information and octant configuration of cec1, enter:

~~~~
    lsvm cec1
~~~~

Output is similar to:

~~~~
    1: 514/U78A9.001.0123456-P1-C17/0x21010202/2/1
    1: 513/U78A9.001.0123456-P1-C15/0x21010201/2/1
    1: 512/U78A9.001.0123456-P1-C16/0x21010200/2/1
    13: 537/U78A9.001.0123456-P1-C9/0x21010219/2/13
    13: 536/U78A9.001.0123456-P1-C10/0x21010218/2/13
    17: 545/U78A9.001.0123456-P1-C7/0x21010221/2/17
    17: 544/U78A9.001.0123456-P1-C8/0x21010220/2/17
    21: 553/U78A9.001.0123456-P1-C5/0x21010229/2/21
    21: 552/U78A9.001.0123456-P1-C6/0x21010228/2/21
    25: 569/U78A9.001.0123456-P1-C1/0x21010239/2/25
    25: 561/U78A9.001.0123456-P1-C3/0x21010231/2/25
    25: 560/U78A9.001.0123456-P1-C4/0x21010230/2/25
    29: 568/U78A9.001.0123456-P1-C2/0x21010238/2/29
    5: 521/U78A9.001.0123456-P1-C13/0x21010209/2/5
    5: 520/U78A9.001.0123456-P1-C14/0x21010208/2/5
    9: 529/U78A9.001.0123456-P1-C11/0x21010211/2/9
    9: 528/U78A9.001.0123456-P1-C12/0x21010210/2/9
    cec1:  PendingPumpMode=1,CurrentPumpMode=1,OctantCount=8:
    OctantID=0,PendingOctCfg=5,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=1,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=2,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=3,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=4,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=5,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=6,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
    OctantID=7,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=1;
~~~~

3\. To list the detailed I/O slot information and octant configuration of cec1, enter:

~~~~
    lsvm cec1 -l
~~~~

Output is similar to:

~~~~
    cec1:
    lpar1: 1: 514/U78A9.001.0123456-P1-C17/0x21010202/2/1: 16: 0/3/3
    lpar1: 1: 513/U78A9.001.0123456-P1-C15/0x21010201/2/1: 16: 0/3/3
    lpar1: 1: 512/U78A9.001.0123456-P1-C16/0x21010200/2/1: 16: 0/3/3
    lpar13: 13: 537/U78A9.001.0123456-P1-C9/0x21010219/2/13: 16: 0/3/3
    lpar13: 13: 536/U78A9.001.0123456-P1-C10/0x21010218/2/13: 16: 0/3/3
    lpar17: 17: 545/U78A9.001.0123456-P1-C7/0x21010221/2/17: 16: 0/0/0
    lpar17: 17: 544/U78A9.001.0123456-P1-C8/0x21010220/2/17: 16: 0/0/0
    lpar21: 21: 553/U78A9.001.0123456-P1-C5/0x21010229/2/21: 16: 0/0/0
    lpar21: 21: 552/U78A9.001.0123456-P1-C6/0x21010228/2/21.16: 0/0/0
    lpar25: 25: 569/U78A9.001.0123456-P1-C1/0x21010239/2/25.16: 0/0/0
    lpar25: 25: 561/U78A9.001.0123456-P1-C3/0x21010231/2/25.16: 0/0/0
    lpar25: 25: 560/U78A9.001.0123456-P1-C4/0x21010230/2/25.16: 0/0/0
    lpar29: 29: 568/U78A9.001.0123456-P1-C2/0x21010238/2/29.8: 0/0/0
    lpar5: 5: 521/U78A9.001.0123456-P1-C13/0x21010209/2/5.8: 0/3/3
    lpar5: 5: 520/U78A9.001.0123456-P1-C14/0x21010208/2/5.8: 0/3/3
    lpar9: 9: 529/U78A9.001.0123456-P1-C11/0x21010211/2/9.16: 0/3/3
    lpar9: 9: 528/U78A9.001.0123456-P1-C12/0x21010210/2/9.16: 0/3/3
    PendingPumpMode=1,CurrentPumpMode=1,OctantCount=8:
    OctantID=0,PendingOctCfg=5,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=1,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=2,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=3,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=4,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=5,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=6,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    OctantID=7,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
    Number of BSR arrays: 256, Bytes per BSR array: 4096, Available BSR arrays: 0;
    Available huge page memory(in pages):     0
    Configurable huge page memory(in pages):  12
    Page Size(in GB):                         16
    Maximum huge page memory(in pages):       24
    Requested huge page memory(in pages):     15;
~~~~

### Using xCAT DFM rpower support to control the Frame, CEC, and LPAR power

This section will outline the general xCAT DFM rpower support as well as new support for the P7IH servers. See the rpower man page for more detail for each option.

Here is a list of xCAT DFM supported rpower options.

~~~~
    rpower <noderange> [on|onstandby|off|reset|stat|state|boot|of|sms|lowpower|rackstandby|exit_rackstandby]
~~~~


Administrators will need to control power for different hardware boundaries depending on the tasks being performed. During an initial startup of a cluster they will be issuing commands to the BPA to bring up the frame and start the FSPs. Once the FSPs are up they will issue commands to IPL the CEC and later commands to the FSP to start each LPAR. During normal operation they may wish to reboot LPARs to cause them to use an updated OS level. Each of these commmands require the administrator to select the appropriate Frame, CEC, or LPAR as the noderange.

#### rpower actions on a Frame

The following actions are supported for a nodelist of Frame

~~~~
    rpower <noderange> [rackstandby|exit_rackstandby|stat|state]
~~~~


#### rpower actions on an CEC

The following actions are supported for a nodelist of CEC

~~~~
    rpower <noderange> [on|off|stat|state|lowpower]
~~~~


For lowpower , turn CEC to low power state (state EOCT). This is a disruptive operation which requires the CEC to be powered off prior to entering low power mode. And we can use "power off" command to get out of lowepower state.

#### rpower actions on an LPAR

The following actions are supported for a nodelist of LPAR

~~~~
    rpower <noderange> [on|off|reset|stat|state|boot|of|sms]
~~~~


### Updating the BPA and FSP firmware using xCAT DFM

#### **Overview**

The xCAT DFM supoprt includes the ability to apply firmware updates to the Frame and CEC using the rflash command

The xCAT DFM firmware related commands are rspconfig, rinv and rflash. And the noderange **MUST** be CEC and Frame.

1\. use rspconfig to set the pending power on side

~~~~
     rspconfig <noderange>  pending_power_on_side
~~~~


~~~~
     rspconfig <noderange> pending_power_on_side={temp|perm}
~~~~


2\. Use rinv with the option firm to get the firmware level of the CECs or Frames

~~~~
    rinv <noderange> firm
~~~~


3\. use the rflash command to perform firmware updates.

~~~~
    rflash  <noderange> -p directory --activate  <disruptive|deferred> [-d data_directory]
~~~~


~~~~
    rflash <noderange> [--commit|--recover]
~~~~


The rflash command initiates Firmware updates for the CECs and Frames.

The flash chip system P managed system or power subsystem stores firmware in two locations, referred to as the temporary side and the permanent side. By default, most system P systems boot from the temporary side of the flash. When the rflash command updates code, the current contents of the temporary side are written to the permanent side, and the new code is written to the temporary side. The new code is then activated. Therefore, the two sides of the flash will contain different levels of code when the update has completed.

In Direct FSP/BPA Management, there is -d &lt;data_directory&gt; option. The default value is /tmp. When do firmware update, rflash will put some related data from rpm packages in &lt;data_directory&gt; directory, so the execution of rflash will require available disk space in &lt;data_directory&gt; for the command to properly execute:

For one GFW rpm packages and power code rpm package , if the GFW rpm package size is gfw_rpmsize, and the Power code rpm package size is power_rpmsize, it requires that the available disk space should be more than:

       1.5*gfw_rpmsize + 1.5*power_rpmsize



The --activate flag determines how the affected systems activate the new code. In currently Direct FSP/BPA Management, our rflash doesn't support concurrent option, and only support disruptive and deferred.

The disruptive option will cause any affected systems that are powered on to be powered down before installing and activating the update. So we require that the systems should be powered off before do the firmware update.

The deferred option will load the new firmware into the T (temp) side, but will not activate it like the disruptive firmware. The customer will continue to run the Frames and CECs working with the P (perm) side and can wait for a maintenance window where they can activate and boot the Frame/CECs with new firmware levels. Refer to the section [Perform_Deferred_Firmware_upgrades_for_frameFCEC_on_Power_775](XCAT_Power_775_Hardware_Management/#perform-deferred-firmware-upgrades-for-framecec-on-power-775) below to get more details.

**Note**: When doing the firmware update on the frame's BPAs, rflash flashes the LIC code into the BPAs, and then reboots the BPAs to activate the new firmware, and then issues the ACDL action at last. ACDL means Auto Code Down Load of the Power/Thermal subsystem which updates other parts in the frame. All the actions of ACDL are done within the frame automatically. In most of the time, about 10 minutes later, the ACDL will finish automatically. During the ACDL, it doesn't affect any hardware control operations on the related CECs, and ACDL only pertains to power /thermal FRUs. That's the expected behavior.

The --commit flag is used to copy the contents of the temporary side of the flash to the permanent side. This flag should be used after updating code and verifying correct system operation.

The --recover flag is used to copy the permanent side of the flash chip back to the temporary side. This flag should be used to recover from a corrupt flash operation, so that the previously running code can be restored.

For Power 775, the rflash command takes effect on the primary and secondary FSPs or BPAs almost in parallel.

The detailed information will be added to the xCAT rflash manpage.

#### **Preparing for a firmware upgrade**

To prepare for the firmware upgrade download the Microcode update package and associated XML file from the IBM Web site:

http://www-933.ibm.com/support/fixcentral/ .

Go to [Fix Central](http://www-933.ibm.com/support/fixcentral/) and use the following options:

      Product Group = Power
      Product = Firmware, SDMC, and HMC
      Machine type-model = 9125-F2C


#### **Perform disruptive Firmware update for Frame/CEC on Power 775**

Check firmware level

~~~~
    rinv <noderange> firm
~~~~


Update the firmware

Download the Microcode update package and associated XML file from the IBM Web site:

http://www-933.ibm.com/support/fixcentral/ .

Go to [Fix Central](http://www-933.ibm.com/support/fixcentral/) and use the following options:

      Product Group = Power
      Product = Firmware, SDMC, and HMC
      Machine type-model = 9125-F2C



Create the /tmp/fw directory, if necessary, and copy the downloaded files to the /tmp/fw directory.

Run the rflash command with the --activate flag to specify the update mode to perform the updates.Please see the "rflash" manpage for more information.

~~~~
    rflash  <noderange> -p /tmp/fw --activate disruptive
~~~~


Notes:

System Power 775 firmware updates can require time to complete and there is no visual indication that the command is proceeding.

#### **Perform Deferred Firmware upgrades for frame/CEC on Power 775**

##### **Deferred firmware update Background**

It takes more than 2 hours to finish the disruptive firmware update in a large P775 cluster. To reduce the down time of the cluster, customers may want to flash new firmware levels while the cecs are up and running, The deferred firmware update will load the new firmware into the T (temp) side, but will not activate it like the disruptive firmware. The customer will continue to run the Frames and CECs working with the P (perm) side and can wait for a maintenance window where they can activate and boot the Frame/CECs with new firmware levels.

##### **temp/perm side, pending_power_on_side attributes in Deferred firmware update**

The deferred firmware update includes 2 parts: The first part (1) is to apply the firmware to the T (temp) sides of Frames' BPAs and CECs' FSPs when the cluster is up and running. The second part (2) is to activate the new firmware on the Frames and Cecs at a scheduled time.

The default setting is that the CEC/FSPs are working from the temp side (current_power_on_side). During part(1) of the deferred firmware update implementation, the CEC will continue to run on the perm side while the rflash of the new firmware levels will installed to the temp side. It is very important that the perm side contains the current stable version of firmware. The perm side is usually only used as a recovery environment when working with firmware updates.

When executing a reboot the CEC (FSPs), the CEC will run on the side which the pending_power_on_side attribute is set. After we finish the part (1), the admin will want to make sure the pending_power_on_side attribute is set to "perm" if the CECs want to be rebooted working with the older stable firmware. When you are ready to activate the new firmware and reboot the Cecs,you will want to make sure the pending_power_on_side attribute is set to "temp".

##### **The procedure of the deferred firmware update **

Before starting the deferred firmware update, the admin should first make sure that the most recent stable firmware level has been applied to the P (perm) side. We should note that T-side firmware will be moved over to the P-side automatically when we execute the rflash of the new firmware into the T (temp) side.

1\. Apply the firmware for Frame and CECs

In this part, rflash command with --activate deferred is used to load the firmware to the Frame and CECs, while the Frame and CECs are in running state. The admins should make sure that the Frame power code is loaded first and that GFW levels are compatible with power code.

1.1 Check the Firmware level of the Frames or CECs:

~~~~
      rinv <noderange> firm
~~~~


Then, download the suitable power code for Frame or GFW code for CEC. For example, if the Release Level of the CEC is '01AFxxx', the code witch has the same perfix '01AF' is suitable for updating.

To prepare for the firmware upgrade download the Microcode update package and associated XML file from the IBM Web site:

http://www-933.ibm.com/support/fixcentral/ .

Go to [Fix Central](http://www-933.ibm.com/support/fixcentral/) and use the following options:

      Product Group = Power
      Product = Firmware, SDMC, and HMC
      Machine type-model = 9125-F2C


1.2 Apply the power code into the Frames's BPAs

~~~~
      rflash <frame> -p <rpm_directory> --activate deferred
~~~~


1.3 Apply the GFW code into the CECs's FSPs

~~~~
      rflash <cec> -p <rpm_directory> --activate deferred
~~~~


1.4 Check to make sure the proper Firmware levels have been loaded into the temp side (new) and the perm side (previous) for the Frames or CECs. The rflash working with "deferred" should now specify Current Power on side to now be "perm":

~~~~
      rinv <noderange> firm
~~~~


2\. Setup Cecs pending power to Perm (needed for CEC reboot -- power off/on)

In part 1, the new firmware is now loaded on the temp side. If you need to keep the Frame and CECs active for a period of time (such as several days) we need to make sure we are working with previous firmware level, which is running on the P-side. You should change the pending_power_on_side attribute from temp to perm. The expectation is that the admin should only need to set the CECs pending_power_on_side, but the admin can also set the frame environment if needed.

~~~~
      rspconfig <cec> pending_power_on_side
      If not, set CEC's the pending power on side to P-side:
      rspconfig <cec> pending_power_on_side=perm
~~~~


**Note**: The P775 system should continue to run working on the P-side with previous level firmware until you are ready to activate the new firmware , since the pending_power_on_side has been set to perm side, this will make sure that the CECs will be powered up working with the previous firmware level. This may be necessary if the CECs have an issue, or that the admin may need to reboot one of the CECs prior to the scheduled outage.

3.Activate the new firmware at schedule time

The new firmware level has been loaded on the temp side, and it is time to activate the Frame and CECs with new firmware level. The admin should make sure the pending_power_on_side is now set back from perm to temp.

3.1 Check if the pending power on side for Frame and CEC are T-side

~~~~
      rspconfig <frame> pending_power_on_side
      rspconfig <cec> pending_power_on_side
      If not, set the pending power on side to T-side
      rspconfig <frame> pending_power_on_side=temp
      rspconfig <cec> pending_power_on_side=temp
~~~~


3.2 Power off all CECs

~~~~
      rpower cec off
~~~~


3.3 reboot the service processors and do ACDL for Frames

When all of the CECs are powered off, the admin should reboot the BPAs to activate the new power code in the BPAs, and run Auto Code Down Load (ACDL) of the Power/Thermal subsystem which updates other parts in the Frame. The ACDL really a small code update of the firmware on all the miscellaneous electrical components, such as fans and pumps, that are part of the Frame and are controlled by the BPC.

At the end of the BPAs rebooting, it will run the ACDL automatically, but we want to issue a manual ACDL to make sure the automatic ACDL was successful. The manual ACDL is a 'double-check' to make sure ACDL runs properly.

3.3.1 Reboot the Frames' BPAs

~~~~
       rpower <frame> resetsp
~~~~


Wait for 5-10 minutes for BPA to restart. When the connections become LINE_UP again, the BPAs have finished the reboot.

~~~~
       lshwconn <frame>
~~~~


3.3.2 Execute the manual ACDL

~~~~
       rflash <frame> --bpa_acdl
~~~~


3.4 Verify that the frame updates are the new power code level and that they are using the temp side for the current_power_on_side .

~~~~
      rinv <frame> firm
~~~~


3.5 Reboot the service processor for the CECs

~~~~
       rpower <cec> resetsp
~~~~


Wait for 5-10 minutes for FSPs to restart. When the connections become LINE_UP again, the FSPs have finished the reboot.

~~~~
       lshwconn <cec>
~~~~


3.6 Verify that the cec updates are the new firmware level and that they are using the temp side for the current_power_on_side .

~~~~
       rinv <cec> firm
~~~~


3.7 Power on the CECs and bring up the Power 775 cluster .

**Note**: Before doing the rpower on the CECs, make sure all P775 software is synchronized with CEC firmware. The Power 775 admin should check that the CNM/HFI software environment is updated on the EMS and that the HPC software is updated in the diskful and diskless images to properly work with the new firmware on the CECs.

~~~~
       rpower <cec> on
~~~~


##### **Recover the system if the power code/firmware failed to be loaded (Available for both CECs and Frames)**

If the power code/firmware failed to be loaded or be stopped in purpose, refer to the section [Recover_the_system_from_a_PP_situation_because_of_the_failed_firmware_update](XCAT_Power_775_Hardware_Management/#recover-the-system-from-a-pp-situation-because-of-the-failed-firmware-update) to recover the system.

#### **Recovery procedure if the new firmware does not perform well (Available for CECs and Frames)**

1\. Make sure the pending_power_on_side be temp

~~~~
      rspconfig <cec> pending_power_on_side
~~~~


If not, set the pending power on side to T-side

~~~~
      rspconfig <cec> pending_power_on_side=temp
~~~~


2\. Copy the P-side firmware to T-side

      rflash <cec> --recover


And then the CECs will be running the T-side with the original firmware from P-side.

#### **Commit currently activated LIC update(copy T to P) for a CEC/Frame on Power 775**

Check firmware level

Refer to the environment setup in the section 'Firmware upgrade for CEC on Power 775' to make sure the firmware version is correct.

Commit the firmware LIC

Run the rflash command with the commit flag.

~~~~
    rflash  <noderange> --commit
~~~~


Notes:

When the --commit or --recover two flags is used, the noderange is CEC for Power 775, and it will take effect for managed systems. If it is frame for Power 775, and will take effect for power subsystems only.

#### **Recover the system from a P/P situation because of the failed firmware update**

Before running the following steps, make sure the connections to both the primary FSP and the secondary FSP(or both the BPC A and the BPC B) are LINE UP.

~~~~
     lshwconn cec01
      cec01: 40.17.1.1: sp=primary,ipadd=40.17.1.1,alt_ipadd=unavailable,state=LINE UP
      cec01: 40.17.1.2: sp=secondary,ipadd=40.17.1.2,alt_ipadd=unavailable,state=LINE UP
~~~~


The following steps could be used to recover the system from the Current Boot Side P/P situation, if the system is on P/P side because of the failed firmware update. **All the steps should be run**:

(1) check if the current power on side is perm(P-side):

~~~~
      rinv cec01 firm
~~~~


If yes, switch step(2); otherwise, NOT do the following steps because the current boot side is T-side.

(2) check if the pending power on side is T:

~~~~
      rspconfig cec01 pending_power_on_side
~~~~


If not, set the pending power on side to T:

~~~~
     rspconfig cec01 pending_power_on_side=temp
~~~~


(3) remove the current connection

~~~~
      rmhwconn cec01
~~~~


(4) recreate the connections:

~~~~
      mkhwconn cec01 -t
~~~~


(5) make sure the connections states are LINE UP:

~~~~
      lshwconn cec01
~~~~


(It's required that the states are LINE.UP. Maybe need to wait for several minutes)

(6) recover the system

~~~~
      rflash cec01  --recover
~~~~


(7) Check the result:

~~~~
       rinv cec01 firm
~~~~


The current power on side will be temp(T-side).

### Opening a remote console to the CEC LPAR using xCAT DFM

xCAT DM rcons supports the capability of opening a remote console to one or more LPARs. This section will outline this capability and the use of rcons to open consoles using xCAT DFM.

See the rcons man page for details and other options.

~~~~
    rcons <noderange>
~~~~


By changing the nodelist specification you can use the rcons command to open a coneole to the BPA or FSP ASM menu. It can also be used to open a console to an LPAR OS prompt. This support is useful to access the ASM menus and also to access the console for an LPAR. Common uses for rconsole include opening a console to monitor node installation or boot processing. rcons may be used when other network access to an LPAR is not available and to understand the state of the OS on the LPAR.

### Enable 'dev' and 'celogin1' login for CEC/Frame (optional)

Depending on the class of your systems, the dev user may or may not be enabled by default. P5 (Squadrons) systems have dev enabled, and by default have a dynamic password, P6 (Eclipz) and P7 (Apollo) have dev disabled. The celogin is always enabled and has a dynamic password by default. You should access http://w3.pok.ibm.com/organization/prodeng/pw/ to enter the Password Request page to get the dynamic password. And then put the username .celogin. and password in the passwd table, or input the username .celogin. and the password of CEC/Frame into the ppcdirect table. Before using our rspconfig command, we should make sure that the username .celogin. and password are valid.

Because this function is implemented through ASMI, the users should make sure the "enableASMI=yes" in the site table. If not, please run the following commmand:

~~~~
      chdef -t site enableASMI=yes
~~~~



And then, check 'dev' and 'celogin1' state for CEC/Frame

~~~~
    rspconfig <noderange> dev
    rspconfig <noderange> celogin1
~~~~


If needed, run the following command to enable or disable the 'dev' and 'celogin1' accounts.

~~~~
    rspconfig <noderange> dev={enable|disable}
    rspconfig <noderange> celogin1={enable|disable}
~~~~


After this operation, we require users to set the enableASMI=no in the site table:

~~~~
     chdef -t site enableASMI=no
~~~~

## Hardware Discovery Directly from the xCAT Management Node

For information on Hardware Discover Directly from the xCAT MN.    See
[XCAT_Power_775_Hardware_Management/#appendix-system-p-hardware-discovery-directly-from-xcat-mn](XCAT_Power_775_Hardware_Management/#appendix-system-p-hardware-discovery-directly-from-xcat-mn)

## Energy Management

[Energy_Management](Energy_Management)
