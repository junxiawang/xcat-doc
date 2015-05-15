<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [AIX overview](#aix-overview)
  - [Flex overview](#flex-overview)
  - [Terminology](#terminology)
- [Switching databases](#switching-databases)
- [Setup for a Flex blade cluster](#setup-for-a-flex-blade-cluster)
  - [Downloading and Installing DFM](#downloading-and-installing-dfm)
  - [Hardware Discovery](#hardware-discovery)
    - [Overview](#overview)
    - [Preparation for the discovery](#preparation-for-the-discovery)
    - [Discovery the cmm by the lsslp command](#discovery-the-cmm-by-the-lsslp-command)
  - [Configure the cmm](#configure-the-cmm)
  - [Update the CMM firmware (optional)](#update-the-cmm-firmware-optional)
  - [CMM Security and Password Expiration](#cmm-security-and-password-expiration)
- [Defining networks](#defining-networks)
- [Defining blade nodes](#defining-blade-nodes)
  - [Creating blade node definitions](#creating-blade-node-definitions)
    - [Create object definition of blade server in the Database first and run rscan -u to Discovery](#create-object-definition-of-blade-server-in-the-database-first-and-run-rscan--u-to-discovery)
      - [Define the blade server node definitions](#define-the-blade-server-node-definitions)
      - [Run rscan -u to discover all the compute node servers.](#run-rscan--u-to-discover-all-the-compute-node-servers)
    - [Create object definition of blade server by discovery directly](#create-object-definition-of-blade-server-by-discovery-directly)
  - [Set the network configuration for the fsp](#set-the-network-configuration-for-the-fsp)
  - [Modify blade server device names](#modify-blade-server-device-names)
- [Create the hardware server connection for the blades' FSPs](#create-the-hardware-server-connection-for-the-blades-fsps)
  - [Update the FSP firmware (optional)](#update-the-fsp-firmware-optional)
- [Get the MAC addresses for the nodes](#get-the-mac-addresses-for-the-nodes)
  - [Set the 'getmac' attribute to 'blade'](#set-the-getmac-attribute-to-blade)
  - [run the getmacs command to display all the macs](#run-the-getmacs-command-to-display-all-the-macs)
  - [Set the 'installnic' attribute](#set-the-installnic-attribute)
  - [Setup etc hosts](#setup-etc-hosts)
  - [Using Node Groups](#using-node-groups)
  - [AIX Servicenodes](#aix-servicenodes)
  - [Installing AIX Diskfull nodes](#installing-aix-diskfull-nodes)
- [Booting Flex blade nodes](#booting-flex-blade-nodes)
  - [Make sure the blades are in the "on" state](#make-sure-the-blades-are-in-the-on-state)
  - [Using a remote console](#using-a-remote-console)
    - [Make sure the SOL on the CMM has been disabled](#make-sure-the-sol-on-the-cmm-has-been-disabled)
    - [Update the conserver configuration](#update-the-conserver-configuration)
    - [Check rcons function](#check-rcons-function)
  - [set the bootlist on the node](#set-the-bootlist-on-the-node)
  - [Initiate a network boot of the nodes](#initiate-a-network-boot-of-the-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


**=============== NOTICE ====================**

This is work in progress. It is not ready to be used or reviewed!!!!!! 

============================================****

  



## Introduction

### AIX overview

[aix_overview](aix_overview) 

### Flex overview

IBM Flex combines networking, storage and servers in a single offering. It's consist of an IBM Flex Chassis, one or two Chassis Management Modules(CMM) and Power 7 and x86 compute node servers. The type of the management module for IBM Flex is 'cmm', and the blade servers include the IBM Flex System™ p260, p460, and 24L Power 7 servers as well as the IBM Flex System™ x240 Compute Node which is an x86 Intel-processor based server. **In this document only the management of POWER 7 blade server will be covered.**

IBM Flex System™ p260, p460, and 24L Power 7 server hardware management: Generally, xCAT uses the management type 'blade' to manage the blade center and blade server (The management work is done through the management module). For IBM Flex xCAT will use a management type of 'fsp' to management the POWER 7 blade servers(The management work is done through the xCAT DFM (Direct FSP Management)). For xCAT IBM Flex Power 7 servers, the management approach will be the mix of 'blade' and 'fsp'. Most of the discovery work will be done through CMM and most of the hardware management work will be done through blade's FSP directly 

### Terminology

The following terms will be used in this document: 

  * **Direct FSP Management(DFM)** \- This is the name that we will use to describe the ability for xCAT software to communicate directly to the IBM FLex Power pblade's service processor without the use of the HMC for management. 
  * **Chassis Management Module(CMM)** \- This term is used to reflect the pair of management modules installed in the rear of the chassis which have an Ethernet connection. The CMM is used to discover the servers within the chassis and for some data collection regarding the servers and chassis. 
  * **blade node** \- Blade node refers to a node with the hwtype set to _blade_ and represents the whole blade server. The hcp attribute of the blade is set to the FSP's IP. 
  * **standalone** \- An AIX node that has it's operating system installed on a local disk. 
  * **rte** \- A network installation method supported by NIM that uses a NIM lpp_source resource to install a standalone node. 
  * **mksysb**\- A network installation method supported by NIM that uses a system backup of one node (mksysb image) to install other standalone cluster nodes. 
  * **diskful**\- For AIX systems this means that the node has local disk storage that is used for the operating system. (A standalone node.) Diskfull AIX nodes are typically installed using the NIM **rte** or **mksysb** install methods. 
  * **diskless**\- The operating system is not stored on local disk. For AIX systems this means the file systems are mounted from a NIM server. 

## Switching databases

[Switching Databases](Switching Databases) 

## Setup for a Flex blade cluster

### Downloading and Installing DFM

**TBD**

This requires the new xCAT Direct FSP Management(dfm) plugin and hardware server(hdwr_svr) plugin, which are not part of the core xCAT open source, but are available as a free download from IBM. You must download this and install them on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document. 

Download xCAT-dfm RPM: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&amp;release=All&amp;platform=All&amp;function=all 

Download ISNM-hdwr_svr RPM: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+High+Performance+Computing+%28HPC%29+Hardware+Server&amp;release=All&amp;platform=All&amp;function=all 

Download the suitable dfm and hdwr_svr packages for different OSes. Once you have downloaded these packages, install the hardware server package first, and then install DFM. 

rhels: 

If you have been following the xCAT documentation, you should already have the yum repositories set up to pull in whatever xCAT dependencies and distro RPMs are needed (libstdc++.ppc, libgcc.ppc, openssl.ppc, etc.). 
    
    yum install xCAT-dfm-*.ppc64.rpm ISNM-hdwr_svr-*.ppc64.rpm
    

### Hardware Discovery

#### Overview

The discovery procedure is used to simplify the cluster environment setup for the administrator especially for the cluster with thousands of nodes. Administrator needs to connect the ethernet and provide the power before the discovery process is started. Firstly, discover the CMM and configure the cmm node , then discover and configure the blade server/fsp. 

#### Preparation for the discovery

1\. The Ethernet interface of CMM and xCAT management node have been connected to the service VLAN so that xCAT management node can connect to the hardware to do the hardware discovery and management work. 

2\. Configure a dhcp dynamic range for the CMM and FSPs to get the temporary IP to finished the hardware discovery. In this example, the 10.0.0.0/16 will be used as the service vlan, and the 10.0.200.0/24 will be used as the temporary network for the discovery of cmm. 

Note: As part of RH6.2, the dhcpd daemon will require the "dhcpd" user to be added to the "/etc/passwd file" . The dhcpd user should be added automatically when the dhcp.ppc64 rpm is installed. If you need to add it by hand, run: adduser -s /sbin/nologin -d / dhcpd 
    
    chdef -t network 10_0_0_0-255_255_0_0 dynamicrange=10.0.200.1-10.0.200.200
    makedhcp -n
    service dhcpd restart               # linux
    startsrc -s dhcpsd                  # AIX
    

#### Discovery the cmm by the lsslp command

1\. Power on all of the chassis. This will cause the CMMs to get the temporary DHCP IP from the xCAT management node. 2\. Run the lsslp to discover the CMMs: 
    
    lsslp -m -z -s CMM &gt; /tmp/cmm.stanza
    

3\. Edit the stanza file to give the meaningful node name for the cmms (The mpa attribute should have the same value with the name). Simply the names can be set as cmm01 to cmm99. These CMM node names will require name resolution (added to /etc/host). 4\. Define the CMMs to the xCAT database: 
    
    cat /tmp/cmm.stanza | mkdef -z
    

5\. Define the static IP for all the cmms 
    
    chdef -t group cmm ip='|cmm(\d+)|10.0.100.($1+0)|'
    

6\. Add the CMM node names into the /etc/hosts, and dns resolution if being used for name resolution. 
    
    makehosts cmm
    makedns cmm
    

### Configure the cmm

1\. If the user want to change the password for USERID to another one, the following command can be used: 
    
    rspconfig cmm USERID=&lt;new_passwd&gt;
    

2\. Initialize the network configuration for cmms. The static IP will be configured to the cmm. 
    
    rspconfig cmm initnetwork=*
    

3\. Enable the ssh,snmp for all the cmms 

Notes: Once you reset or restart the CMM, also run this command to avoid "Unsupported security level" issue: 
    
    rspconfig cmm sshcfg=enable snmpcfg=enable
    

### Update the CMM firmware (optional)

The CMM firmware can be updated by loading the new **cmefs.uxp** firmware file using the CMM **update** command working with the http or tftp interface. Since the AIX xCAT MN does not usually support http, we have provided CMM update instructions working with tftp. The administrator needs to download firmware from IBM Fix Central. The compressed tar file will need to be uncompressed and unzipped to extract the firmware update files. You need to place the cmefs.uxp file in the /tftpboot directory on the xCAT MN for CMM update to work properly. 

Once the firmware is unzipped and the cmefs.uxp is placed in the /tftpboot directory on the xCAT MN you can use the CMM **update** command to update the firmware on one chassis at a time or on all chassis managed by xCAT MN. More details on the CMM update command can be found at: http://publib.boulder.ibm.com/infocenter/flexsys/information/index.jsp?topic=%2Fcom.ibm.acc.cmm.doc%2Fcli_command_update.html 

The format of the update command is: flash (-u) the CMM firmware file and reboot (-r) afterwards 
    
    update -T system:mm[1] -r -u tftp://&lt;server&gt;/&lt;update file&gt;
    

flash (-u), show progress (-v), and reboot (-r) afterwards 
    
    update -T system:mm[1] -v -r -u tftp://&lt;server&gt;/&lt;update file&gt;
    

Note: Make sure the CMM firmware file cmefs.uxp is placed in /tftpboot directory on xCAT MN. The tftp interface from the CMM will reference the /tftpboot as the default location. 

To update firmware and restart a single CMM cmm01 from xCAT MN 70.0.0.1 use: 
    
    ssh USERID@cmm01 update -T system:mm[1] -v  -r -u tftp://70.0.0.1/cmefs.uxp
    

If unprompted password is setup on all CMMs then you can use xCAT psh to update all CMMs in the cluster at once. 
    
    psh cmm  -l USERID update -T system:mm[1] -v -u tftp://70.0.0.1/cmefs.uxp
    

If you are experiencing a "Unsupported security level" message after the CMM firmware was updated then you should run the following command to overcome this issue. 
    
    rspconfig cmm sshcfg=enable snmpcfg=enable
    

  


### CMM Security and Password Expiration

The default security setting for the CMM is secure. This setting will require that the CMM user USERID password be changed within 90 days by default. You can change the password expiration date with the CMM accseccfg command. The following are examples of changing the expiration date. 

Change the password expiration date to 300 days: 
    
     accseccfg -pe 300 -T mm[1]
    

Change the expiration date to not expire: 
    
     accseccfg -pe 0 -T mm[1]
    

More details on the CMM accseccfg command can be found at: http://publib.boulder.ibm.com/infocenter/flexsys/information/index.jsp?topic=%2Fcom.ibm.acc.cmm.doc%2Fcli_command_accseccfg.html 

If the CMM user USERID password has expired and you are getting message stating that it is expired you can use the xCAT rspconfig command to change the password to a new password. 
    
     rspconfig cmm01 USERID=Passw0rd1
    

## Defining networks

[Defining Networks](Defining Networks) 

  


## Defining blade nodes

### Creating blade node definitions

The blade server definition can be created in two different ways: 

  * Create object definition of blade server in the Database first and run rscan -u to Discovery 
  * Create object definition of blade server by discovery directly 

#### Create object definition of blade server in the Database first and run rscan -u to Discovery

This implementation should only be used when there are uniformed blade configurations working in the chassis. If there are mixtures of single and double wide blades in the chassis, the admin will need to remove unused blade node objects. 

##### Define the blade server node definitions

The attribute 'mpa' should be set to the node name of cmm. The attribute 'slotid' should be set to the physical slot id of the blade. The attribute 'hcp' should be set to the IP that admin try to assign to the fsp of the blade. 
    
    mkdef cmm[01-02]node[01-14] groups=all,blade mgt=fsp cons=fsp chdef -t group blade mpa='|cmm(\d+)node(\d+)|cmm($1)|
    'slotid='|cmm(\d+)node(\d+)|($2+0)|' hcp='|cmm(\d+)node(\d+)|10.0.($1+0).($2+0)|' mgt=fsp
    
    [root@c870f3ap01 ~]# nodels blade
    cmm01node01
    cmm01node03
    cmm01node05
    cmm01node07
    cmm01node09
    cmm01node10
    cmm01node11
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
    [root@c870f3ap01 ~]#
    

##### Run rscan -u to discover all the compute node servers.

The 'rscan -u' will match the xCAT nodes which have been defined in the xCAT database and update them instead of create a new one. It will also provide an error message that specifies if the blade node object is not found in the xCAT database. This type of error should happen when there is a configuration where the chassis contains both single wide and double wide blade configurations. The admin can execute the rmdef command for any unused blade node objects. 
    
    rscan cmm -u
    
    
    If there are a mixture of single and double wide blade in the chassis, the admin should remove the unused blade objects from the xCAT DB.
    
    
    rmdef  &lt;cmmxxnodeyy&gt;
   

#### Create object definition of blade server by discovery directly

The rscan command reads the actual configuration of blade server in the CMM and creates node definitions in the xCAT database to reflect them. Run the rscan command against all of the CMMs to create a stanza file for the definitions of all the compute node servers. 
    
    rscan cmm -z &gt;nodes.stanza
    

The Power 7 compute node stanza file is like this: 
    
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
    

In a stanza file, the user can get the blade server with the attributes hcp (fsp of the blade), mtm, serial and id attributions. For the stanza file above, the node SN#YL10JH184084 is a pblade(nodetype=ppc,hwtype=blade,mpa=cmm01). In order to easily access or operate those compute node servers, the user can edit the stanza file and give the node the name user want them to be for definition of each compute node server. 

For Power 7 compute nodes the administrator will change the object name and hcp attribute for the IP of fsp. For example, the user can modify the definition of SN#YL10JH184084 as followings: 
    
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
    

Then create the definitions in the database: 
    
    cat nodes.stanza | mkdef -z
   

### Set the network configuration for the fsp
    
    rspconfig blade network=*
    

### Modify blade server device names

In order to conveniently manage the blade servers, the customer may wan to have a cleaner name for the blade node. The following command can be used to modify a blade device name. 
    
    rspconfig singlenode textid="cmm01node01"
    

The following command can be used to change a group of blade device name to the node names that are defined in xCAT DB. 
    
    rspconfig blade textid=*
    

## Create the hardware server connection for the blades' FSPs

1\. Add the blade's fsp connections for the DFM management: 
    
    mkhwconn blade -t
   

2\. check the connections are LINE_UP: 
    
    lshwconn blade
    

3\. make sure the blade server powered on 
    
    rpower blade state 
    rpower blade on
    

### Update the FSP firmware (optional)

This is accomplished by using the rflash xCAT command from the xCAT Management node. The admin should download the supported GFW from the IBM Fix central website, and place it in a directory that is available to be read by the xCAT Management node. 

1\. Use rinv command to get the current firmware levels of the blades' FSPs: 
    
   rinv bladenoderange firm
    
    
    (output to be added here)
    

2.Use the rflash command to update the firmware levels for the blades' FSPs. Then validate that the new firmware is loaded: 

For firmware disruptive update, you should make sure the blade in power off state firstly. 
    
     rpower bladenoderange off
    

And then use rflash to do the update: 
    
    rflash bladenoderange -p &lt;directory&gt; --activate disruptive
    
    (output to be added here) 
    
    
    rinv bladenoderange firm
    

3\. Verify that the blades are healthy and power on the blades: 
    
    rpower bladenoderange state
    rvitals bladenoderange lcds
    rpower bladenoderange on
    

## Get the MAC addresses for the nodes

IBM Flex POWER 7 blades support getting the mac address through the CMM. 

### Set the 'getmac' attribute to 'blade'
    
    chdef cmm01node01 getmac=blade
    

**Note**: Since the Firmware is not stable at present, the following 2 steps are recommended to get the mac address for the specified interface. 

### run the getmacs command to display all the macs
    
    getmacs cmm01node01 -d
    

### Set the 'installnic' attribute

Set the 'installnic' attribute to specify the mac address for which interface will be collected. The admin shall exactly know witch interface is connected. 

**Note**: If 4 mac addresses are gotten, they all are the mac addresses of the blade. The x can start from 0(map to the eth0 of the blade) to 3. If 5 mac addresses are gotten, the 1st mac address must be the mac address of the blade's FSP, so the x will start from 1(map to the eth0 of the blade) to 4. 
    
    chdef cmm01node01 installnic=enx
   
    
    getmacs cmm01node01
 
### Setup etc hosts   

[setup_hosts](setup_hosts)

### Using Node Groups

[Node_Group_Support](Node_Group_Support) 

### AIX Servicenodes

[Using_AIX_service_nodes](Using_AIX_service_nodes) 

### Installing AIX Diskfull nodes

[XCAT_AIX_RTE_Diskfull_Nodes]

## Booting Flex blade nodes

### Make sure the blades are in the "on" state

To check the state you can run: 
    
    rpower bladenoderange stat  
    

If node is off then run: 
    
    rpower bladenoderange on
    

### Using a remote console

#### Make sure the SOL on the CMM has been disabled

Run the following commands: 
    
    rspconfig cmm solcfg
    rspconfig cmm solcfg=disable
    

#### Update the conserver configuration

Run the following commands, you will need to run these commands anytime you add nodes to the cluster. 
    
    makeconservercf 
    stopsrc -s conserver 
    startsrc -s conserver
    

#### Check rcons function

Run the **rcons** command to check if it is functioning properly. 
    
    rcons onebladenode
    

If the blade is in the "off" state, it will specify "Destination BLADE is in POWER OFF state, Please power it on and wait.". If this is the case then you need to change the blade tothe "on" state. 
    
    rpower onebladenode on
    

### set the bootlist on the node

Use the xCAT **rbootseq** command to set the boot device on the nodes. 
    
    rbootseq bladenoderange net
    

### Initiate a network boot of the nodes

Use the **rpower** command to initiate a network boot of the node. 
    
    rpower bladenoderange cycle
    
