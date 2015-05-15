<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Terminology](#terminology)
  - [Overview of Cluster Setup Process](#overview-of-cluster-setup-process)
  - [Distro-specific Steps](#distro-specific-steps)
  - [Command Man Pages and Database Attribute Descriptions](#command-man-pages-and-database-attribute-descriptions)
- [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
- [Configure Ethernet Switches](#configure-ethernet-switches)
- [Install xCAT on the Management Node](#install-xcat-on-the-management-node)
- [Use xCAT to Configure Services on the Management Node](#use-xcat-to-configure-services-on-the-management-node)
  - [**Networks Table**](#networks-table)
  - [**passwd Table**](#passwd-table)
  - [Setup DNS](#setup-dns)
  - [Setup conserver](#setup-conserver)
- [Define the FPCs and Switches](#define-the-fpcs-and-switches)
- [FPC Discovery and Configuration](#fpc-discovery-and-configuration)
  - [Update the FPC firmware (optional)](#update-the-fpc-firmware-optional)
- [Node Definition and Discovery](#node-definition-and-discovery)
  - [Declare a dynamic range of addresses for discovery](#declare-a-dynamic-range-of-addresses-for-discovery)
  - [Create the node definitions](#create-the-node-definitions)
  - [**Declare use of SOL**](#declare-use-of-sol)
  - [Setup /etc/hosts File](#setup-etchosts-file)
  - [Switch Discovery](#switch-discovery)
    - [**Switch-related Tables**](#switch-related-tables)
  - [**Monitoring Node Discovery**](#monitoring-node-discovery)
  - [Verify  HW Management Configuration](#verify--hw-management-configuration)
  - [HW Settings Necessary for Remote Console](#hw-settings-necessary-for-remote-console)
- [Deploying Nodes](#deploying-nodes)
- [Installing Stateful Nodes](#installing-stateful-nodes)
  - [**Begin Installation**](#begin-installation)
- [Deploying Stateless Nodes](#deploying-stateless-nodes)
- [S3 support](#s3-support)
- [Where Do I Go From Here?](#where-do-i-go-from-here)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 

This document describes the steps necessary to quickly set up a cluster with IBM NeXtScale servers. 


## Introduction

IBM NeXtScale combines networking, storage, and compute nodes in a single offering. It's consist of an IBM NeXtScale Chassis, one Fan Power Controller and compute nodes. The compute nodes include the IBM NeXtScale nx360 M4 servers. 

### Terminology

The following terms will be used in this document: 

  * **MN** \- the xCAT management node. 
  * **Fan Power Controller (FPC)** \- The FPC is installed in the rear of the chassis and connected by ethernet to the MN. The FPC is used to list power and fan settings as well as logically reseat the NeXtScale servers. 
  * **Blade** \- the NeXtScale compute nodes within the chassis. 
  * **IMM** \- the Integrated Management Module in each node that is use to control the node hardware out-of-band. Also known as the BMC (Baseboard Management Controller). 
  * **Switch Modules** \- the ethernet and IB switches within the chassis. 

### Overview of Cluster Setup Process

Here is a summary of the steps required to set up the cluster and what this document will take you through: 

  1. Prepare the management node - doing these things before installing the xCAT software helps the process to go more smoothly. 
  2. Install the xCAT software on the management node. 
  3. Configure some cluster wide information 
  4. Define a little bit of information in the xCAT database about the ethernet switches and nodes - this is necessary to detect the node in the discovery process. 
  5. Have xCAT configure and start several network daemons - this is necessary for both node discovery and node installation. 
  6. Discovery the nodes - during this phase, xCAT configures the FPCs and BMC's and collects many attributes about each node and stores them in the database. 
  7. Set up the OS images and install the nodes. 

  


### Distro-specific Steps

  * [RH] indicates that step only needs to be done for RHEL and Red Hat based distros (CentOS, Scientific Linux, and in most cases Fedora). 
  * [SLES] indicates that step only needs to be done for SLES. 

### Command Man Pages and Database Attribute Descriptions

  * All of the commands used in this document are described in the [xCAT man pages](http://xcat.sourceforge.net/man1/xcat.1.html). 
  * All of the database attributes referred to in this document are described in the [xCAT database object and table descriptions](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

## Prepare the Management Node for xCAT Installation

[Prepare_the_Management_Node_for_xCAT_Installation](Prepare_the_Management_Node_for_xCAT_Installation) 

## Configure Ethernet Switches

[Configure_ethernet_switches](Configure_ethernet_switches) 

## Install xCAT on the Management Node

[Install_xCAT_on_the_Management_Node](Install_xCAT_on_the_Management_Node) 

## Use xCAT to Configure Services on the Management Node

### **Networks Table**

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is connected to. Now is the time to add to the networks table any other networks in the cluster, or update existing networks in the table. 

For a sample Networks Setup, see the following example: [Network_Table_Setup_Example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example).

### **passwd Table**

The password should be set in the passwd table that will be assigned to root when the node is installed. You can modify this table using tabedit. To change the default password for root on the nodes, change the system line. To change the password to be used for the BMCs, change the ipmi line. 
    
    tabedit passwd
    #key,username,password,cryptmethod,comments,disable
    "system","root","cluster",,,
    "ipmi","USERID","PASSW0RD",,,
    

  


### Setup DNS

To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN: 

  * Ensure that /etc/sysconfig/named does not have ROOTDIR set 
  * Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can't answer to these servers. 
    
    chdef -t site forwarders=1.2.3.4,1.2.5.6
    

  * Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above, but is an easy way to test that your DNS is configured properly.) 
    
    search cluster
    nameserver 10.1.0.1
    

  * Run makedns 
    
    makedns
    

For more information about name resolution in an xCAT Cluster, see [Cluster_Name_Resolution]. 

  


### Setup conserver
    
    makeconservercf
    

  


## Define the FPCs and Switches

First just add the list of FPCs and the groups they belong to: 
    
    nodeadd fpc[01-15] groups=fpc,all
    

Now define attributes that are the same for all FPCs. These can be defined at the group level. For a description of the attribute names, see the [node object definition](http://xcat.sourceforge.net/man7/node.7.html). 
    
    chdef -t group fpc mgt=ipmi bmcpassword=PASSW0RD bmcusername=USERID cons=ipmi mgt=ipmi nodetype=fpc
    

  
Next define the attributes that vary for each FPC. There are 2 different ways to do this. Assuming your naming conventions follow a regular pattern, the fastest way to do this is use regular expressions at the group level: 
    
    chdef -t group fpc  bmc='|(.*)|($1)|' ip='|fpc(\d+)|10.0.50.($1+0)|'
    

Note: The Flow for FPC IP addressing is 
1) initially each FPC has a default IP address of 192.168.0.100, as of 2.8.6 you can input the default ip address with --ip flag on configfpc.   
2) You run a new command "configfpc" to discover each FPC 
3) configfpc will change each discovered FPC default IP address to the permanent static IP address which is specified here as the ip attribute. 

This chdef might look confusing at first, but once you parse it, it's not too bad. The regular expression syntax in xcat database attribute values follows the form: 
    
    |pattern-to-match-on-the-nodename|value-to-give-the-attribute|
    

You use parentheses to indicate what should be matched on the left side and substituted on the right side. So for example, the bmc attribute above is: 
    
    |(.*)|($1)|
    

This means match the entire nodename (.*) and substitute it as the value for mpa. This is what we want because for FPCs the mpa attribute should be set to itself. 

For the ip attribute above, it is: 
    
    |fpc(\d+)|10.0.50.($1+0)|
    

This means match the number part of the node name and use it as the last part of the IP address. (Adding 0 to the value just converts it from a string to a number to get rid of any leading zeros, i.e. change 09 to 9.) So for fpc07, the ip attribute will be 10.0.50.7. 

For more information on xCAT's database regular expressions, see http://xcat.sourceforge.net/man5/xcatdb.5.html . To verify that the regular expressions are producing what you want, run lsdef for a node and confirm that the values are correct. 

If you don't want to use regular expressions, you can create a stanza file containing the node attribute values: 
    
    fpc01:
      bmc=fpc01
      ip=10.0.50.1
    fpc02:
      bmc=fpc02
      ip=10.0.50.2
    ...
    

Then pipe this into chdef: 
  
~~~~  
    cat <stanzafile> | chdef -z
~~~~    

When you are done defining the FPCs, listing one should look like this: 
    
    # lsdef fpc07
    Object name: feihu-fpc
       bmc=fpc07
       bmcpassword=PASSW0RD
       bmcusername=USERID
       groups=fpc
       mgt=ipmi
       ip=10.0.50.7
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles
    

## FPC Discovery and Configuration

In this section you will perform the FPC discovery and configuration of for the FPC. 

During the FPC discovery process all FPCs are discovered using the xCAT **configfpc** command. 

In large clusters the **configfpc** automated method for discovering is used to map each FPC MAC to the FPC port defined in the Ethernet switch SNMP data from which each chassis FPC is connected. 

To use this method the xCAT switch and switches tables must be configured. The xCAT switch table will need to be updated with the switch port that each FPC is connected. The xCAT switches table must contain the SNMP access information. 

Add the FPC switch/port information to the switch table. 
    
    # tabdump switch
    #node,switch,port,vlan,interface,comments,disable
    "fpc01","switch","0/1",,,,
    "fpc02","switch","0/2",,,,
    

where: node is the fpc node object name switch is the hostname of the switch port is the switch port id. Note that xCAT does not need the complete port name. Preceding non numeric characters are ignored. 

If you configured your switches to use SNMP V3, then you need to define several attributes in the switches table. Assuming all of your switches use the same values, you can set these attributes at the group level: 
    
    tabch switch=switch switches.snmpversion=3 switches.username=xcatadmin switches.password=passw0rd switches.auth=SHA
    
    
    # tabdump switches
    #switch,snmpversion,username,password,privacy,auth,linkports,sshusername,sshpassword,switchtype,comments,disable
    "switch","3","xcatadmin","passw0rd",,"SHA",,,,,,
    

Note: It might also be necessary to allow authentication at the VLAN level 
    
    snmp-server group xcatadmin v3 auth context vlan-230
    

Discover and configure each the xCAT FPC node. 
    
    configfpc -i eth0
    
    
    Found FPC with default IP 192.168.0.100 and MAC 6c:ae:8b:08:20:35
    Configured FPC with MAC 6c:ae:8b:08:20:35 as fpc01 (10.1.147.170)
    Verified the FPC with MAC 6c:ae:8b:08:20:35 is responding to the new IP 10.1.147.170 as node fpc01
    There are no more FPCs with the default IP address to process
    

Check the internet IP parameters values to make sure they were enabled properly on each FPC. 
    
    rspconfig cmm01 netmask gateway ip 
    
    fpc: BMC Netmask: 255.255.0.0
    fpc: BMC Gateway: 10.1.1.171
    fpc: BMC IP: 10.1.147.170
    

  


### Update the FPC firmware (optional)

This section specifies how to update the FPC firmware. You can run the xCAT "rinv fpc01 firmware" command to list the fpc firmware level. 
    
    rinv  fpc01 firmware
    
    
    fpc01: BMC Firmware: 2.01
    

The FPC firmware can be updated by running the rflash command and providing the FPC node name and the location of the file preceded by "http://" and the IP address of the xCAT MN interface which is on the same VLAN as the FPC. 

Once the firmware is unzipped and the ibm_fw_fpc_&lt;fw level&gt;.rom file is placed in the /install/firmware directory, or another directory within /install on the xCAT MN, you can use the rflash command to update the firmware on one chassis at a time or on all chassis managed by xCAT MN. 

The format of the rflash command is: 
    
    rflash fpc01 http://10.1.147.171/install/firmware/ibm_fw_fpc_fhet17a-2.02_anyos_noarch.rom
    

Note: The firmware file ibm_fw_fpc_fhet17a-2.02_anyos_noarch.rom was downloaded to the /install/firmware directory in this example. 

You can run the xCAT "rinv fpc01 firmware" command to list the new fpc01 firmware. 
    
     rinv  fpc01 firmware
    
    
    fpc01: BMC Firmware: 2.02
    

## Node Definition and Discovery

### Declare a dynamic range of addresses for discovery

If you want to run a discovery process, a dynamic range must be defined in the networks table. It's used for the nodes to get an IP address before xCAT knows their MAC addresses. 

In this case, we'll designate 172.20.255.1-172.20.255.254 as a dynamic range: 
   
~~~~ 
    chdef -t network 172_16_0_0-255_240_0_0 dynamicrange=172.20.255.1-172.20.255.254
~~~~    

### Create the node definitions

Now you can define the NeXtScale node definitions: 
 
~~~~   
    nodeadd n[001-167] groups=ipmi,compute,all bmc=70.1.147.173 bmcpassword=PASSW0RD bmcusername=USERID cons=ipmi ip=70.1.147.163 mgt=ipmi 
~~~~    

To change the list of nodes you just defined to a shared BMC port: 
  
~~~~  
    chdef -t group -o ipmi bmcport="0"
~~~~    

If the BMCs are configured in shared mode, then this network can be combined with the management network. The bmcport attribute is used by bmcsetup in discovery to configure the BMC port. The bmcport values are "0"=shared, "1"=dedicated, or blank to leave the BMC port unchanged. 

To see the list of nodes you just defined: 
    
~~~~
    nodels
~~~~    

To see all of the attributes that the combination of the templates and your nodelist have defined for a few sample nodes: 
    
~~~~
    lsdef n100,n101,n104
~~~~    

This is the easiest way to verify that the regular expressions in the templates are giving you attribute values you are happy with. (Or, if you modified the regular expressions, that you did it correctly.) 

### **Declare use of SOL**

If not using a terminal server, SOL is recommended, but not required to be configured. To instruct xCAT to configure SOL in installed operating systems on NeXtScale systems: 
 
~~~~   
    chdef -t group -o compute serialport=0 serialspeed=115200 serialflow=hard
~~~~    

  


### Setup /etc/hosts File

Since the map between the xCAT node names and IP addresses have been added in the xCAT database, you can run the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) xCAT command to create the /etc/hosts file from the xCAT database. (You can skip this step if you are creating /etc/hosts manually.) 
    
~~~~
    makehosts switch,blade,cmm
~~~~    

Verify the entries have been created in the file /etc/hosts. 

Add the node ip mapping to the DNS. 
  
~~~~  
    makedns
~~~~    

### Switch Discovery

This method of discovery assumes that you have the nodes plugged into your ethernet switches in an orderly fashion. So we use each nodes switch port number to determine where it is physically located in the racks and therefore what node name it should be given. 

To use this discovery method, you must have already configured the switches as described in [Configure_Ethernet_Switches](XCAT_NeXtScale_Clusters/#configure_ethernet_switches).

#### **Switch-related Tables**

The table templates already put group-oriented regular expression entries in the switch table. Use lsdef for a sample node to see if the switch and switchport attributes are correct. If not, use chdef or tabedit to change the values. 

If you configured your switches to use SNMP V3, then you need to define several attributes in the switches table. Assuming all of your switches use the same values, you can set these attributes at the group level: 
   
~~~~ 
    tabch switch=switch switches.snmpversion=3 switches.username=xcat switches.password=passw0rd switches.auth=sha

~~~~    

  
To initiate any discover walk over to systems and **hit the power buttons**. For the switch you can power on all of the nodes at the same time. 

On the MN watch nodes being discovered by: 
   
~~~~ 
    tail -f /var/log/messages
~~~~    

Look for the dhcp requests, the xCAT discovery requests, and the "&lt;node&gt; has been discovered" messages. 

A quick summary of what is happening during the discovery process is: 

  * the nodes request a DHCP IP address and PXE boot instructions 
  * the DHCP server on the MN responds with a dynamic IP address and the xCAT genesis boot kernel 
  * the genesis boot kernel running on the node sends the MAC and MTMS to xcatd on the MN 
  * xcatd asks the switches which port this MAC is on so that it can correlate this physical node with the proper node entry in the database. (Switch Discovery only) 
  * xcatd uses specified node name pool to get the proper node entry. (Sequential Discovery only) 
    * stores the node's MTMS in the db 
    * puts the MAC/IP pair in the DHCP configuration 
    * sends several of the node attributes to the genesis kernel on the node 
  * the genesis kernel configures the BMC with the proper IP address, userid, and password, and then just drops into a shell 

After a successful discovery process, the following attributes will be added to the database for each node. (You can verify this by running lsdef &lt;node&gt; ): 

  * mac - the MAC address of the in-band NIC used to manage this node 
  * mtm - the hardware type (machine-model) 
  * serial - the hardware serial number 

If you cannot discover the nodes successfully, see the next section [#Manually_Discover_Nodes]. 

If at some later time you want to force a re-discover of a node, run: 
  
~~~~  
    makedhcp -d <noderange>
~~~~    

and then reboot the node(s). 

### **Monitoring Node Discovery**

When the bmcsetup process completes on each node (about 5-10 minutes), xCAT genesis will drop into a shell and wait indefinitely (and change the node's currstate attribute to "shell"). You can monitor the progress of the nodes using: 
   
~~~~ 
    watch -d 'nodels ipmi chain.currstate|xcoll'
~~~~    

Before all nodes complete, you will see output like: 
    
    
~~~~    
    
    ###### ========================    
    
    n1,n10,n11,n75,n76,n77,n78,n79,n8,n80,n81,n82,n83,n84,n85,n86,n87,n88,n89,n9,n90,n91    
    
    ###### ========================    
    
    shell    
    
    
    ###### ========================    
    
    n31,n32,n33,n34,n35,n36,n37,n38,n39,n4,n40,n41,n42,n43,n44,n45,n46,n47,n48,n49,n5,n50,n51,n52,
     n53,n54,n55,n56,n57,n58,n59,n6,n60,n61,n62,n63,n64,n65,n66,n67,n68,n69,n7,n70,n71,n72,n73,n74
    
    
    ###### ========================
    
    
    runcmd=bmcsetup
~~~~    

When all nodes have made it to the shell, xcoll will just show that the whole nodegroup "ipmi" has the output "shell": 
    
    
~~~~    
    
    ###### ========================
    
    
    ipmi
    
    
    ###### ========================
    
    
    shell
~~~~    

When the nodes are in the xCAT genesis shell, you can ssh or psh to any of the nodes to check anything you want. 

### Verify  HW Management Configuration

At this point, the BMCs should all be configured and ready for hardware management. To verify this: 
    
    
    # rpower ipmi stat | xcoll
    
    
    ###### ========================
    
    
    ipmi
    
    
    ###### ========================
    
    
    on
    

  


### HW Settings Necessary for Remote Console

To get the remote console working for each node, some uEFI hardware settings must have specific values. First check the settings, and if they aren't correct, then set them properly. This can be done via the ASU utility. 

Create a file called asu-show with contents: 

~~~~    
    show DevicesandIOPorts.Com1ActiveAfterBoot
    show DevicesandIOPorts.SerialPortSharing
    show DevicesandIOPorts.SerialPortAccessMode
    show DevicesandIOPorts.RemoteConsole
~~~~
    

And create a file called asu-set with contents: 

~~~~    
    set DevicesandIOPorts.Com1ActiveAfterBoot Enable
    set DevicesandIOPorts.SerialPortSharing Enable
    set DevicesandIOPorts.SerialPortAccessMode Dedicated
    set DevicesandIOPorts.RemoteConsole Enable
~~~~    

Then use the [pasu](http://xcat.sourceforge.net/man1/pasu.1.html) tool to check these settings: 
 
~~~~   
    pasu -b asu-show ipmi | xcoll    # Or you can check just one node and assume the rest are the same
~~~~    

If the settings are not correct, then set them: 
 
~~~~   
    pasu -b asu-set ipmi | xcoll
~~~~    

For alternate ways to set the ASU settings, see [Using_ASU_to_Update_CMOS,_uEFI,_or_BIOS_Settings_on_the_Nodes](XCAT_iDataPlex_Advanced_Setup/#using-asu-to-update-cmos-uefi-or-bios-settings-on-the-nodes). 

Now the remote console should work. Verify it on one node by running: 
 
~~~~   
    rcons <node>
~~~~    

To verify that you can see the genesis shell prompt (after hitting enter). To exit rcons type: ctrl-shift-E (all together), then "c", the ".". 

You are now ready to choose an operating system and deployment method for the nodes.... 

  


## Deploying Nodes

  * In you want to install your nodes as stateful (diskful) nodes, follow the next section[Installing_Stateful_Nodes](XCAT_NeXtScale_Clusters/#installing-stateful-nodes). 
  * If you want to define one or more stateless (diskless) OS images and boot the nodes with those, see section [Deploying_Stateless_Nodes](XCAT_NeXtScale_Clusters/#deploying-stateless-nodes). This method has the advantage of managing the images in a central place, and having only one image per node type. 
  * If you want to have nfs-root statelite nodes, see [XCAT_Linux_Statelite]. This has the same advantage of managing the images from a central place. It has the added benefit of using less memory on the node while allowing larger images. But it has the drawback of making the nodes dependent on the management node or service nodes (i.e. if the management/service node goes down, the compute nodes booted from it go down too). 
  * If you have a very large cluster (more than 500 nodes), at this point you should follow[Setting_Up_a_Linux_Hierarchical_Cluster] to install and configure your service nodes. After that you can return here to install or diskless boot your compute nodes. 

## Installing Stateful Nodes

[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes)

### **Begin Installation**

The [nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) command tells xCAT what you want to do next with this node, [rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html)tells the node hardware to boot from the network for the next boot, and powering on the node using [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) starts the installation process: 
    
    nodeset compute osimage=mycomputeimage
    rsetboot compute net
    rpower compute boot
    

Tip: when nodeset is run, it processes the kickstart or autoyast template associated with the osimage, plugging in node-specific attributes, and creates a specific kickstart/autoyast file for each node in /install/autoinst. If you need to customize the template, make a copy of the template file that is pointed to by the osimage.template attribute and edit that file (or the files it includes). 

[Monitor_Installation](Monitor_Installation) 

  


## Deploying Stateless Nodes

[Using_Provmethod=osimagename](Using_Provmethod=osimagename) 
    
    rsetboot compute net
    rpower compute boot
    

## S3 support

Xcat can support rpower suspend/wake for NeXtScale nodes, but need extra configuration. below are the configuration on redhat. 

  * Install ’acpid’  package on NeXtScale node. 
    
    xdsh &lt;NeXtScaleNode&gt; "yum install -y acpid"
    

  * Log in NeXtScale node, add two configuration files (suspend and suspend_event)on NeXtScale node. 
    
    /etc/pm/config.d/suspend
    S2RAM_OPTS="--force --vbe_save --vbe_post --vbe_mode"
    
    
    /etc/acpi/events/suspend_event
    event=button/sleep.*
    action=/usr/sbin/pm-suspend
    

  * enable 'Power.S3Enable'  parameter on NeXtScale node 
    
    [root@xcatmn]# echo "set Power.S3Enable Enable" &gt; power-setting 
    [root@xcatmn]# pasu -b power-setting feihunode02
    .....
    feihunode02: Power.S3Enable=Enable
    .....
    

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
