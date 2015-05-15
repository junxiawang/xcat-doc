<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [AIX overview](#aix-overview)
  - [Flex overview](#flex-overview)
  - [Terminology](#terminology)
- [Setting up the xCAT MN for IBM Flex](#setting-up-the-xcat-mn-for-ibm-flex)
- [xCAT Hierarchy and MySQL databases](#xcat-hierarchy-and-mysql-databases)
- [Downloading and Installing DFM](#downloading-and-installing-dfm)
- [Define the CMMs and Switches](#define-the-cmms-and-switches)
- [CMM_Discovery_and_Configuration](#cmm_discovery_and_configuration)
- [Create node object definitions of flex blade servers](#create-node-object-definitions-of-flex-blade-servers)
  - [Create predefined nodes in the Database first and run rscan -u to Discovery](#create-predefined-nodes-in-the-database-first-and-run-rscan--u-to-discovery)
    - [Run rscan -u to discover all the compute node servers.](#run-rscan--u-to-discover-all-the-compute-node-servers)
  - [Create object definition of flex blades by discovery using stanza files](#create-object-definition-of-flex-blades-by-discovery-using-stanza-files)
  - [Set the network configuration for the fsp](#set-the-network-configuration-for-the-fsp)
  - [Modify blade server device names](#modify-blade-server-device-names)
- [Create the hardware server connection for the blades' FSPs](#create-the-hardware-server-connection-for-the-blades-fsps)
  - [Update the FSP firmware (optional)](#update-the-fsp-firmware-optional)
- [Get the MAC addresses for the nodes](#get-the-mac-addresses-for-the-nodes)
  - [Set the 'getmac' attribute to 'blade'](#set-the-getmac-attribute-to-blade)
  - [run the getmacs command to display all the macs](#run-the-getmacs-command-to-display-all-the-macs)
  - [Add option '-i' to specify the interface](#add-option--i-to-specify-the-interface)
- [Using AIX service nodes](#using-aix-service-nodes)
- [Booting Flex blade nodes](#booting-flex-blade-nodes)
  - [Make sure the blades are in the "on" state](#make-sure-the-blades-are-in-the-on-state)
  - [Using a remote console](#using-a-remote-console)
    - [Make sure the SOL on the CMM has been disabled](#make-sure-the-sol-on-the-cmm-has-been-disabled)
    - [Update the conserver configuration](#update-the-conserver-configuration)
    - [Check rcons function](#check-rcons-function)
  - [set the bootlist on the node](#set-the-bootlist-on-the-node)
  - [Initiate a network boot of the nodes](#initiate-a-network-boot-of-the-nodes)
- [Appendix 1: IBM Flex Recovery and CMM Redundancy](#appendix-1-ibm-flex-recovery-and-cmm-redundancy)
  - [Replacement of CMM](#replacement-of-cmm)
  - [CMM Redundancy](#cmm-redundancy)
    - [Fail over software reset from CMM GUI](#fail-over-software-reset-from-cmm-gui)
    - [Fail over software reset from CMM CLI](#fail-over-software-reset-from-cmm-cli)
    - [Fail over hardware reset of CMM](#fail-over-hardware-reset-of-cmm)
- [Appendix 2: CMM and Felxible Service Processor(FSP) password](#appendix-2-cmm-and-felxible-service-processorfsp-password)
  - [Errors caused by an FSP authentication problem](#errors-caused-by-an-fsp-authentication-problem)
- [Appendix 3: Updating Firmware on Flex Ethernet and IB Switch Modules](#appendix-3-updating-firmware-on-flex-ethernet-and-ib-switch-modules)
    - [Firmware Update using CLI](#firmware-update-using-cli)
- [**Appendix 4 Perform Deferred Firmware upgrades for Flex blade CEC **](#appendix-4-perform-deferred-firmware-upgrades-for-flex-blade-cec-)
    - [**Deferred firmware update Background**](#deferred-firmware-update-background)
    - [**temp/perm side, pending_power_on_side attributes in Deferred firmware update**](#tempperm-side-pending_power_on_side-attributes-in-deferred-firmware-update)
    - [**The procedure of the deferred firmware update **](#the-procedure-of-the-deferred-firmware-update-)
- [Appendix 5 Connect Flex P blades to HMC for Teal SFP (Not yet supported)](#appendix-5-connect-flex-p-blades-to-hmc-for-teal-sfp-not-yet-supported)
- [Diagnostics](#diagnostics)
  - [lshwconn LINE DOWN after power outage](#lshwconn-line-down-after-power-outage)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Introduction

### AIX overview

[AIX_Overview](AIX_Overview) 

### Flex overview

IBM Flex combines networking, storage and servers in a single offering. It consist of an IBM Flex Chassis, one or two Chassis Management Modules(CMM) and Power 7 and/or x86 compute node servers. The type of the management module for IBM Flex is 'cmm', and the blade servers include the IBM Flex System™ p260, p460, and 24L Power 7 servers as well as the IBM Flex System™ x240 Compute Node which is an x86 Intel-processor based server. **In this document only the management of POWER 7 blade server will be covered.**

IBM Flex System™ p260, p460, and 24L Power 7 servers need to be managed by a xCAT Management Node (MN) which is to be created on a standalone System P7 server. There needs to be an ethernet commectivity between the xCAT MN to the CMMs, and to all the compute node through the Ethernet Switch Module. The xCAT support uses the hardware type 'hwtype=blade' to manage the P7 Flex blade servers working through the CMM management module). IBM Flex xCAT will use a management type of 'mgt=fsp' to control the POWER 7 servers which is done through the xCAT DFM (Direct FSP Management)). For xCAT IBM Flex Power 7 servers, the management approach is mixture of 'blade' and 'fsp'. Most of the discovery work will be done through CMM and the hardware management work with the server's FSP directly. 

### Terminology

The following terms will be used in this document: 

  * **Direct FSP Management(DFM)** \- This is the name that we will use to describe the ability for xCAT software to communicate directly to the IBM FLex Power pblade's service processor without the use of the HMC for management. 
  * **Chassis Management Module(CMM)** \- This term is used to reflect the pair of management modules installed in the rear of the chassis which have an Ethernet connection. The CMM is used to discover the servers within the chassis and for some data collection regarding the servers and chassis. 
  * **blade node** \- Blade node refers to a node with the hwtype set to blade and represents the whole blade server. The hcp attribute of the blade is set to the FSP's IP. 
  * **FSP** \- Flexible Service Processor (FSP). This is the service processor within the IBM Flex Power blade. 

## Setting up the xCAT MN for IBM Flex

It is required that you create the xCAT MN on a standalone System P7 server that has proper ethernet connectivity to the CMMs and the PuerFlex blades. The xCAT administrator should reference the general xCAT MN procedures listed in the System P Linux or System P AIX guides and then follow the PureFlex instructions listed below. 

For System P Linux: 
[XCAT_pLinux_Clusters/#install-xcat-on-the-management-node](XCAT_pLinux_Clusters/#install-xcat-on-the-management-node). 

For System P AIX: 
[XCAT_AIX_Cluster_Overview_and_Mgmt_Node] 

## xCAT Hierarchy and MySQL databases

If you are using service nodes you must switch to a database that supports remote access. XCAT currently supports MySQL, and PostgreSQL. As a convenience, the xCAT site provides downloads for MySQL and PostgreSQL. 

You may continue to use the SQlite database that is installed by default with xCAT if you are not using service nodes. 

( [xcat-postgresql-snap201007150920.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-postgresql-snap201007150920.tar.gz/download) and [xcat-mysql-201005260807.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-mysql-201005260807.tar.gz/download) ) 

The HPC solution for IBM Flex only supports the MySQL database at this time. 

See the following xCAT documents for instructions on how to configure MySQL database. 

[Setting_Up_MySQL_as_the_xCAT_DB] 

When configuring the new database you will need to add access for each of your service nodes. The process for this is described in the documentation mentioned above. 

The database tar files that are available on the xCAT web site may contain multiple versions of RPMs - one for each AIX operating system level. When you are copying required software to your lpp_source resource make sure you copy the rpm that coincides with your OS level. Do not copy multiple versions of the same rpm to the NIM lpp_source directory. 

## Downloading and Installing DFM

This requires the new xCAT Direct FSP Management(dfm) plugin and hardware server(hdwr_svr) plugin, which are not part of the core xCAT open source, but are available as a free download from IBM. You must download this and install them on your xCAT management node. 

Download the suitable dfm and hdwr_svr packages from IBM Fix Central for supported OS. Once you have downloaded these packages, install the hardware server package first, and then install DFM. 

Download xCAT-dfm RPM: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&amp;release=All&amp;platform=All&amp;function=all 

Download ISNM-hdwr_svr packages: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+High+Performance+Computing+%28HPC%29+Hardware+Server&amp;release=All&amp;platform=All&amp;function=all 

  
The ISNM hardware server base isnm.hdwr_svr and PTFs images along with the xCAT DFM rpm package needs to be downloaded and then installed on the xCAT MN . 

Download the ISNM hardware server installp and the DFM aix rpm packages to the xCAT MN, and place the packages in a directory such as 
 
~~~~   
    /install/post/otherpkgs/aix/ppc64/dfm
~~~~     

Install the hdwr_svr installp packages, and then install the dfm rpm package. 

~~~~     
    cd /install/post/otherpkgs/aix/ppc64/dfm
    inutoc .
    installp -agQXYd . isnm.hdwr_svr  
    rpm -Uvh  xCAT-dfm*.aix5.3.ppc.rpm
~~~~     

## Define the CMMs and Switches


[Define_the_CMMs_and_Switches](Define_the_CMMs_and_Switches)

## CMM_Discovery_and_Configuration

 
[CMM_Discovery_and_Configuration](CMM_Discovery_and_Configuration)

  
Add the CMM node names into the /etc/hosts, and dns resolution if being used for name resolution. 

~~~~     
    makehosts cmm
    makedns cmm
~~~~     

(For "makehosts" details see: http://xcat.sourceforge.net/man1/makehosts.1.html ) 

  


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
    'chdef -t group blade mpa='|cmm(\d+)node(\d+)|cmm($1)|'slotid='|cmm(\d+)node(\d+)|($2+0)|' \
     hcp='|cmm(\d+)node(\d+)|10.0.($1+0).($2+0)|****
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

The rscan command reads the actual configuration of blade server in the CMM and creates node definitions in the xCAT database to reflect them. This command will create node objects for the target CMM, and the flex blades on the CMM in a stanza file. The admin should manually update the different nodes objects to specify the proper node names they want to use in the xCAT cluster. The admin may also want to change the hcp=&lt;FSP IP&gt; to be a different IP address than what was provided by DHCP server. If the CMM node object is already created, you can remove the CMM entries from the stanza file. You may need to add the "id=0" attribute to cmm objects later. 

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
    id is not used
    slotid=<blade slot> 
~~~~ 

    there is no hcp   
    

  
Run the **rscan** command against all of the CMMs to create a stanza file for the definitions of all the compute node servers. 
    
    rscan cmm -z >nodes.stanza
    

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

The FSP for the System P flex blade will initially be setup as a dynamic IP address. The admin can choose to use this IP, or has the option to change it to another static IP address in the service VLAN. This FSP IP is controlled by the hcp attribute for the node. You can use mkdef/chdef or rscan to update the hcp entries to set the proper FSP IP addresses. The rspconfig command with the network=* option will set the FSP IP address to the value you specified in the hcp attribute. 

~~~~     
    chdef  cmm01node01 hcp=12.0.0.101    
    rspconfig blade network=*
~~~~     

### Modify blade server device names

In order to conveniently manage the blade servers, the customer may wan to have a cleaner name for the blade node. The following command can be used to modify a blade device name. 
   
~~~~  
    rspconfig singlenode textid="cmm01node01"
~~~~     

The following command can be used to change a group of blade device name to the node names that are defined in xCAT DB. 

~~~~     
    rspconfig blade textid=*
~~~~     

## Create the hardware server connection for the blades' FSPs

1\. Add the blade's fsp connections for the DFM management: 
 
~~~~    
    mkhwconn blade -t
~~~~     

(For "mkhwconn" details see: http://xcat.sourceforge.net/man1/mkhwconn.1.html ) 

2\. check the connections are LINE_UP: 

~~~~     
    lshwconn blade
~~~~     

(For "lshwconn" details see: http://xcat.sourceforge.net/man1/lshwconn.1.html ) 

3\. make sure the blade server powered on 

~~~~     
    rpower blade state 
    rpower blade on
~~~~     

(For "rpower" details see: http://xcat.sourceforge.net/man1/rpower.1.html ) 

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
[XCAT_Power_775_Hardware_Management/#recover-the-system-from-a-pp-situation-because-of-the-failed-firmware-update](XCAT_Power_775_Hardware_Management/#recover-the-system-from-a-pp-situation-because-of-the-failed-firmware-update) 

3\. Verify that the blades are healthy, then power on and boot up the blades: 

~~~~     
    rpower bladenoderange state
    rvitals bladenoderange lcds
    rpower bladenoderange on
~~~~     
    

(For "rvitals" details see: http://xcat.sourceforge.net/man1/rvitals.1.html ) 

## Get the MAC addresses for the nodes

IBM Flex POWER 7 blades support getting the mac address through the CMM. 

### Set the 'getmac' attribute to 'blade'
    
    chdef cmm01node01 getmac=blade
    

**Note**: Since the Firmware is not stable at present, the following 2 steps are recommended to get the mac address for the specified interface. 

### run the getmacs command to display all the macs
 
~~~~    
    getmacs cmm01node01 -d
~~~~     

### Add option '-i' to specify the interface

The option '-i' for 'getmacs' can be used to specify the interface whose mac address will be collected. The admin shall exactly know which interface is connected. 

**Note**: If 4 mac addresses are gotten, they all are the mac addresses of the blade. The N can start from 0(map to the eth0 of the blade) to 3. If 5 mac addresses are gotten, the 1st mac address must be the mac address of the blade's FSP, so the N will start from 1(map to the eth0 of the blade) to 4. 
 
~~~~    
    getmacs cmm01node01 -i enN
~~~~     

(For "getmacs" details see: http://xcat.sourceforge.net/man1/getmacs.1.html ) 

[Updating_etc_hosts](Updating_etc_hosts) 

[Node_Group_Support](Node_Group_Support) 

## Using AIX service nodes

If you wish to use xCAT service nodes in your cluster environment you must follow the process described in this section to properly install and configure the service nodes. 

Select the following link. 

[Using_AIX_service_nodes] 



[XCAT_AIX_RTE_Diskfull_Nodes]

## Booting Flex blade nodes

### Make sure the blades are in the "on" state

To check the state you can run: 
  
~~~~   
    rpower bladenoderange stat  
~~~~     

If node is off then run: 

~~~~     
    rpower bladenoderange on
~~~~     

(For "rpower" details see: http://xcat.sourceforge.net/man1/rpower.1.html ) 

### Using a remote console

#### Make sure the SOL on the CMM has been disabled

It is important that the admin disable the Serial Over Lan (SOL) support on the CMM, so that xCAT DFM can control the remote console for the System P flex blades. Please execute the rspconfig command to each CMM. Run the following commands: 
 
~~~~    
    rspconfig cmm solcfg 
    rspconfig cmm solcfg=disable
~~~~     

(For "rspconfig" details see: http://xcat.sourceforge.net/man1/rspconfig.1.html ) 

#### Update the conserver configuration

Run the following commands: 

~~~~     
    makeconservercf 
    stopsrc -s conserver 
    startsrc -s conserver
~~~~     

(For "makeconservercf" details see: http://xcat.sourceforge.net/man1/makeconservercf.1.html ) 

#### Check rcons function

Run the **rcons** command to check if it is functioning properly. 

~~~~     
    rcons onebladenode
~~~~     

(For "rcons" details see: http://xcat.sourceforge.net/man1/rcons.1.html ) 

If the blade is in the "off" state, it will specify "Destination BLADE is in POWER OFF state, Please power it on and wait.". If this is the case then you need to change the blade to the "on" state. 
    
    rpower onebladenode on
    

### set the bootlist on the node

rbootseq requires that the node is powered on. Use the onstandby rpower option to power the node on and leave it in the standby state. 

~~~~     
    rpower bladenoderange onstandby
~~~~     

Use the xCAT **rbootseq** command to set the boot device on the nodes. 

~~~~     
    rbootseq bladenoderange net
~~~~     

(For "rbootseq" details see: http://xcat.sourceforge.net/man1/rbootseq.1.html ) 

### Initiate a network boot of the nodes

Use the **rpower** command to initiate a network boot of the node. 

~~~~     
    rpower bladenoderange reset
~~~~     

## Appendix 1: IBM Flex Recovery and CMM Redundancy

The CMM is the gateway for the hardware management and monitoring communication for the Flex chassis and the Flex P7 blades. If you lose the network communication between the xCAT MN and the primary CMM, you can not execute any hardware management commands to the CMM or blades. If the Flex P7 blades and Ethernet SM are running, the blades should be able to keep running for some time. 

### Replacement of CMM

If you only have one CMM configured in your Flex chassis, you will need to work with IBM service to fix this CMM quickly, since you will not be able to properly manage the Flex blades until you have a working CMM. The CMM replacement activity is to execute CMM HW discovery on new CMM, where you locate the new MAC address and current DHCP dynamic IP address for CMM. You then update the CMM node object's "mac" and "otherinterfaces" attributes with data found from hardware discovery. Once the CMM node object has new data, we execute the configuration CMM steps working with rspconfig. Once the CMM is configured using the static IP, the DHCP and mac address is not referenced. 

The following scenario is to replace the CMM working with node object "cmm01" with a static IP of 10.1.100.1. 
 
~~~~    
     lsslp -m -z -s CMM &gt; /tmp/cmm01.stanza   (Locate new mac and DHCP IP for replacement CMM
     chdef cmm01 otherinterfaces=&lt;dhcpip&gt; mac=&lt;macaddr&gt;  (Update cmm01 object with new mac and current DHCP IP) 
     rspconfig cmm01 USERID=&lt;new_passwd&gt;  (Set password for USERID for new cmm01
     rspconfig cmm01 initnetwork=*      (Set new cmm01 back to original static IP
     rspconfig cmm01 sshcfg=enable snmpcfg=enable  Enable ssh and snmp for new cmm01
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
     system&gt; env -T system:mm[1]
     OK
     system:mm[1]&gt; reset -f
~~~~     

#### Fail over hardware reset of CMM

The scenario is when there is a physical activity where the primary CMM is pulled from the chassis. There are different reasons why the admin may want pull out the CMM. This could be when the CMM is no longer working properly or there is an issue with the ethernet interface of the primary CMM. At this time when the primary CMM is pulled, it will do an automatic failover to the standby CMM, and the standby CMM is now the primary. The admin can work IBM or network support to understand the CMM or network failure. When the failed CMM is ready, the admin can just plug it in the Flex chassis, and it will now become the new Standby CMM. The admin can schedule a CMM software fail over if they want to swap back to the original CMM primary. 

## Appendix 2: CMM and Felxible Service Processor(FSP) password

In the IBM Flex chassis the architecture is designed to simplify some aspects of the systems management of the chassis. As part of this goal the IBM Flex system has integrated the CMM USERID and password into the IBM Flex system p compute nodes FSP. This is done through an internal LDAP server on the CMM serving the userids and passwords to LDAP on the FSPs. What this means to the system xCAT administrator is that the CMM USERID is tightly coupled with xCAT DFM authentication of the FSP. xCAT hardware control failures to authenticate on the FSP is likely the result of an issue with the chassis CMM USERID password. This section will provide commands which will help you determine that you have an authentication problem, verify that its an issue with the CMM USERID password, as well as how to resolve the problem. 

### Errors caused by an FSP authentication problem

The system administrator may first notice a problem with some of the hardware control commands giving an authentication error. 

~~~~     
    > rpower cmm01node01 stat
    cmm01node01: Error: state=CEC AUTHENTICATION FAILED, type=02, MTMS=7895-42X*10F752A, sp=primary, slot=A, ipadd=12.0.0.32, alt_ipadd=unavailable
 
~~~~    

Checking the connection to the FSP shows that the authenication for this FSP is failing: 

~~~~     
    > lshwconn cmm01node01
    cmm01node01: sp=primary,ipadd=12.0.0.32,alt_ipadd=unavailable,state=CEC AUTHENTICATION FAILED
~~~~     

This could be caused by the USERID password being expired on the CMM. You can check with the following: 

~~~~     
    > ssh USERID@cmm01 users -T mm[1]
    system&gt; users -T mm[1]
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
    > ssh USERID@cmm01 accseccfg -pe 0 -T mm[1]
~~~~     

Checking the USERID password is active: 

~~~~     
    > ssh USERID@cmm01 users -T mm[2]
    system&gt; users -T mm[2]
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
    > rmhwconn cmm01node01
    > mkhwconn cmm01node01 -t 
~~~~     

The last step is to check the connection: 

~~~~     
    > lshwconn cmm01node01
    cmm01node01: sp=primary,ipadd=12.0.0.32,alt_ipadd=unavailable,state=LINE UP
~~~~     

## Appendix 3: Updating Firmware on Flex Ethernet and IB Switch Modules

This section provides manual procedures to help update the firmware for Ethernet and Infiniband (IB) Switch modules. There is more detail information can be referenced in the IBM Flex System documentation under Network switches: http://publib.boulder.ibm.com/infocenter/flexsys/information/ 

The IB6131 Switch module is a Mellanox IB switch, and you down load firmware (image-PPC_M460EX-SX_3.2.xxx.img) from the Mellanox website into your xCAT Management Node or server that can communicate to Flex IB6131 switch module. We provided the firmware update procedure for the Mellanox IB switches including IB6131 Switch module in our xCAT document Managing the Mellanox Infiniband Network:
[Managing_the_Mellanox_Infiniband_Network/#mellanox-switch-and-adapter-firmware-update](Managing_the_Mellanox_Infiniband_Network/#mellanox-switch-and-adapter-firmware-update)



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
          Confirm download operation [y/n]:  y
~~~~     

5) Validate the current image settings with **cur** command, where image2 now has the latest firmware level, and that the current boot image is working with latest image2 file. You can then execute the **reset** command to boot the ethernet switch using the latest firmware level. 

~~~~     
       >> cur_
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
      If not, set CEC's the pending power on side to P-side:
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

If this is a diskful environment, the admin should be able to "rpower &lt;blade&gt; on " to bring the blade up on the local disk. 
 
~~~~    
      rpower  <blade> on
~~~~     

If this is a diskless environment, the admin should power up the blade to onstandby, set the boot sequence to network, and reset the blade. 

~~~~     
      rpower <blade> onstandby  
      rbootseq <blade> net 
      rpower <blade> reset
~~~~     

## Appendix 5 Connect Flex P blades to HMC for Teal SFP (Not yet supported)

This section discusses the capability to allow System P flex blades to be connected to HMCs for Service Focal Point (SFP). You make sure that the target HMCs have been defined as HMC nodes in your xCAT database. You allow the xCAT MN to make the hardware connection between the blades and the HMC. The xCAT MN will continue to use the xCAT DFM for remote hardware commands to ccmmunicate directly to the blade FSPs. 

The admin needs to create an HMC node object using the mkdef or chdef commands for each HMC. The admin can also set the username and password directly to the HMC node object which will be added to the **ppchcp** table. T You need to make sure that there is proper SSH connection from the xCAT MN to the HMC. 

~~~~     
    mkdef -t node -o hmc1 groups=hmc,all nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc1234
    rspconfig  <HMC node>  sshcfg=enable
~~~~     

You need to execute the mkhwconn -s &lt;HMC&gt; to Flex P blades to reference the target HMC working with the "sfp" attribute. The command will create new hardware connection on the HMC to the Flex P blades. After the connection is made to the HMC, the CE should be able to use the HMC for SFP events. 

~~~~     
    mkhwconn blade -s <HMC node>  
~~~~     

The CE should now be able to locate the SFP events from the HMC. There is a possibility that Teal may require this setup. 

If you want to remove the hardware connection from the HMC to the Flex P blade, use the rmhwconn -s &lt;HMC&gt; command. 

~~~~     
    rmhwconn blade -s <HMC node>
~~~~     

## Diagnostics
### lshwconn LINE DOWN after power outage

Testing has shown that when a chassis looses power and is started back up it is possible that the connections to the blade FSPs will be LINE DOWN. If this occurs you should reset the CMM for the chassis with this problem. 
 
~~~~    
    >> ssh USERID@cmm01 service -T mm[1] -vr
~~~~     
