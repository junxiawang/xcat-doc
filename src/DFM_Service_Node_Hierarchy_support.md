<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [MN vs. SN ownership and responsibilities](#mn-vs-sn-ownership-and-responsibilities)
- [xCAT DB attributes](#xcat-db-attributes)
  - [LPARs](#lpars)
  - [CECs and Frames](#cecs-and-frames)
  - [Hosts table](#hosts-table)
- [Installing RPMs for DFM on the SN](#installing-rpms-for-dfm-on-the-sn)
  - [Downloading DFM and hdwr_svr packages](#downloading-dfm-and-hdwr_svr-packages)
  - [Installing DFM and hdwr_svr](#installing-dfm-and-hdwr_svr)
    - [Installing DFM and hdwr_svr on Linux SN](#installing-dfm-and-hdwr_svr-on-linux-sn)
    - [Installing DFM and hdwr_svr on AIX SN](#installing-dfm-and-hdwr_svr-on-aix-sn)
- [Conserver Setting](#conserver-setting)
- [Setting servicenode, xcatmaster and conserver for DFM HW Ctrl Cmds](#setting-servicenode-xcatmaster-and-conserver-for-dfm-hw-ctrl-cmds)
- [**Configuring xCAT SN Hierarchy Ethernet Adapters(Power 775 DFM Only) **](#configuring-xcat-sn-hierarchy-ethernet-adapterspower-775-dfm-only-)
- [DFM configuration for hardware server connections](#dfm-configuration-for-hardware-server-connections)
- [DFM rpower on flow when OS provision](#dfm-rpower-on-flow-when-os-provision)
- [CEC down/up policy](#cec-downup-policy)
  - [CEC Up Policy](#cec-up-policy)
  - [CEC down policy](#cec-down-policy)
- [Firmware update sequence](#firmware-update-sequence)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This Doc will describe the support for Hierarchy support using DFM. 


## Overview

Previously support for DFM was restricted to all Direct FSP Management being performed from the Management Node. With the new support administrators will be able to configure the SN as the supported DFM control point for nodes which it manages. This document will describe the changes to xCAT required to support this configuration as well as the configuration information that will need to be defined to allow it to work properly. 

This support will only be documenting the configuration of the xCAT DB and the Service Nodes to allow xCAT commands to automatically determine when to run on the SN and when to run on the EMS. 

  * Every node/nodegroup has explict noderes.servicenode, noderes.xcatmaster, etc., entries. The user must ensure that each servicenode listed in one of those attributes is also added to the servicenode table for correct servicenode install/configuration. 
  * The SN will need to have the Cluster Service Network ethernet interfaces defined during OS installation. Descriptions of what xCAT DB entries are needed and what postscripts need to run to configure the network interfaces. 

For general hierarchy description it is worth reviewing or referencing the following: 

[Hierarchical_Design]  section on New_servicenode_Table 

For the flow of setting up a Hierarchical Cluster, we can refer to the following two docs: 

  * [Setting_Up_an_AIX_Hierarchical_Cluster] 
  * [Setting_Up_a_Linux_Hierarchical_Cluster] 

## MN vs. SN ownership and responsibilities

In order to support DFM hierarchy there needs to be clear roles and responsibilities of the MN and the SN in relation to the DFM and OS image management. 

It is clear that the SN cannot manage the CEC power within which it resides since it would never be able to power itself on after a power off. The MN will be the DFM HCP for the SN CEC. 

We also need the MN to control all of the frames since the SNs cannot control the frame in which they reside. 

Here is a summary of the split in MN and SN ownership for DFM hierarchy: 

  


MN and SN Functional Ownership 

function / hardware target MN  SN 

DFM Frames 
X 

DFM SN CEC
X 

DFM SN LPAR 
X 

OS image SN LPAR
X 

DFM SN CEC non-SN LPARs 
X 

OS image SN CEC non-SN LPARs 
X 

DFM non SN CECs 
X 

DFM non SN CEC LPARs 
X 

OS image non SN CEC LPARs 
X 

Note: While DFM for the SN CEC non-SN LPARs is performed by the MN, these LPARs have their OS support provided by the SN. This is done for scaling reasons as a very large cluster would have too many LPARs to support from a single place if it were to support OS images for them all from the MN. 

## xCAT DB attributes

This section will discuss the xCAT DB attributes which determine the MN and SN hierarchy configuration and control. 

The noderes.servicenode entry is used to override the default of the MN by naming a specific SN to be used instead. This can be used to control areas like xdsh by associating an lpar node definition with a noderes.servicenode setting. DFM can be redirected to a SN by associating an FSP or BPA node definition with a specific SN using the noderes.servicenode setting. This control will allow the administrator to define specific associations depending on the capabilities which are being managed. In our previous example there were some CEC LPARs which need to have the OS served by the SN but the DFM controlled by the MN. Using the noderes.servicenode settings we can accomplish this mixed support. 

### LPARs

The lpar node definitions for the SN CEC non-SN lpars will set noderes.servicenode to this SN. 

The lpar node definitions for all non-SN CECs will set noderes.servicenode to this SN. 

### CECs and Frames

The SN CEC definitions, which is the "parent" of the SN LPAR and all the other LPARs on the SN CEC, will NOT set its noderes.servicenode and therefore use the MN. 

All the non-SN CECs definitions will set noderes.servicenode to SN. 

All Frame definitions will NOT set noderes.servicenode and therefore use the MN. 

### Hosts table

The xCAT hosts table is used to allow customers to define any other no OS install network interfaces that need to be defined on that host. We will use this capability to define the SN Cluster Service Network Ethernet interfaces. Adding the interface information for each SN in this table will result in the creation of the hostname entries required for hostname resolution. 

Here is an example of what would be done to define a Cluster Service Network ethernet interface for a SN. 

## Installing RPMs for DFM on the SN

This section will discuss which RPMs are required for the SN to be able to perform hardware control. It will also contain information on how the required RPMs will be distributed to the SN in AIX and Linux. Currently we will require the DFM and the hardware server RPMs. 

The "[Setting_Up_an_AIX_Hierarchical_Cluster]" and "[Setting_Up_a_Linux_Hierarchical_Cluster]" documents will need to be updated to include the tasks of installing the DFM and hardware server RPMs on the service node. This information is currently missing from those sections. 

Here is the excerpt from this document: 

For most operations, the Power 775 is managed directly by xCAT, not using the HMC. This requires the new xCAT Direct FSP Management plugin (xCAT-dfm-*.ppc64.rpm), which is not part of the core xCAT open source, but is available as a free download from IBM. You must download this and install it on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document.

### Downloading DFM and hdwr_svr packages

Download DFM and the pre-requisite hardware server package from [Fix Central](http://www-933.ibm.com/support/fixcentral/)&nbsp;: 
    
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

### Installing DFM and hdwr_svr

#### Installing DFM and hdwr_svr on Linux SN

We should put this part in the section [Set Up the Service Nodes for Diskfull Installation ](Setting_Up_a_Linux_Hierarchical_Cluster) of the doc [Setting_Up_a_Linux_Hierarchical_Cluster] to add the DFM and hdwr_svr into the list of packages to be installed on the SN. 
    
     mkdir -p /install/post/otherpkgs/&lt;osver&gt;/&lt;arch&gt;/dfm
    

For example, for rhels6: 
    
    mkdir -p /install/post/otherpkgs/rhels6/ppc64/dfm
    

And then, put the DFM and hdwr_svr packages in the dfm directory just created. 

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/dfm directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you: 
    
    createrepo  /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/dfm
    

If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. (For SLES I think it is on the SDK DVD.) 

Next, add rpm names into the service.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist file. In most cases, this file is already created under /opt/xcat/share/xcat/install/&lt;os&gt; directory. If it is not, you can create your own by referencing the existing ones. 
    
    vi /install/custom/install/&lt;os&gt;/service.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist
    

Besides the required xCAT packages for service node, and append the following: 
    
    dfm/xCAT-dfm
    dfm/ISNM-hdwr_svr-RHEL
    

After the Initialize network boot to install Service Nodes in Power 775 section in (Setting_Up_a_Linux_Hierarchical_Cluster] , the DFM and hdwr_svr will be installed on the Linux SN automatically. 

#### Installing DFM and hdwr_svr on AIX SN

We should put this part in the section Add required service node software in  [Setting_Up_an_AIX_Hierarchical_Cluster]  or the doc [Setting_Up_an_AIX_Hierarchical_Cluster] to add the DFM and hdwr_svr into the configure file. 
    
    mkdir -p /install/post/otherpkgs/aix/ppc64/dfm
    

Copy the DFM and hdwr_svr the packages to the suggested target location on the xCAT MN: 
    
     /install/post/otherpkgs/aix/ppc64/dfm
    

Edit the bundle for AIX Service Node. Assuming you are using AIX 71, you should edit the file: 
    
     /opt/xcat/share/xcat/installp_bundles/xCATaixSN71.bnd
    

And add the following into the bundle file: 
    
     I:isnm.hdwr_svr
     R:xCAT-dfm*
    

The required software must be copied to the NIM lpp_source that is being used for the service node image. Assuming you are using AIX 7.1 you could copy all the appropriate rpms to your lpp_source resource (ex. 710SNimage_lpp_source) using the following commands: 
    
     nim -o update packages=all -a source=/install/post/otherpkgs/aix/ppc64/dfm 710SNimage_lpp_source
    

The NIM command will find the correct directories and update the appropriate lpp_source resource directories. 

After Initiate a network boot in [Setting_Up_an_AIX_Hierarchical_Cluster]  or Initiate a network boot for Power 775 support in [Setting_Up_an_AIX_Hierarchical_Cluster], the DFM and hdwr_svr will be installed on the AIX SN automatically. 

## Conserver Setting

  * Conserver will always use nodehm.conserver to determine who should have the console for each node. 
  * The cmd makeconservercf should be distributed to the service nodes based on nodehm.conserver 

[**NOTE**] The nodehm.conserver should be the same as the service node which is set for the hw ctrl point(CEC) of the node. Otherwise the getmacs/rnetboot will not work. 

## Setting servicenode, xcatmaster and conserver for DFM HW Ctrl Cmds

There are 5 different nodes which should be considered: SN-CEC, SN, SN-CEC-nonSN-LPARs, non-SN-CEC, and non-SN-CEC-LPARs. The values of the noderes.servicenode and noderes.xcatmaster attributes of the CEC nodes will determine whether the HW Ctrl Cmds will be done by the DFM on the MN directly, or be distributed to the SN. The values of the noderes.servicenode and noderes.xcatmaster attributes of the LPARs nodes will determine whether the software management will be done on the MN directly, or distributed to the SN. The **rcons** will use the nodehm.conserver attribute in [#Conserver] session which will determine who should have the console for each node. 

_1\. For the SN-CECs_

  * Key Attributes: 

The noderes.servicenode and noderes.xcatmaster attributes of these CEC are not set, or set to MN. 

  * HW Ctrl: 

The HW ctrl commands will be done by the DFM on the MN directly. 

_2\. For the SN:_

  * Key Attributes: 

The nodehm.conserver, noderes.servicenode and noderes.xcatmaster attributes of these SN are not set, or set to MN. 

  * HW Ctrl&nbsp;: 

The HW ctrl commands will be done by the DFM on the MN directly. 

  * Software Management(serving the boot image, xdsh, etc.): 

The software management commands will be done on the MN directly. 

_3\. For the SN-CEC-nonSN-LPARs:_

  * Key Attributes: 

The nodehm.conserver attribute are not set, or set to MN. The noderes.servicenode and noderes.xcatmaster attributes are set to SN for these LPARs nodes. 

  * HW Ctrl: 

The HW ctrl commands will be done by the DFM on the MN directly. 

  * Software Management(serving the boot image, xdsh, etc.): 

The software management commands will be distributed to the SN. 

_4\. For the non-SN-CECs_

  * Key Attributes: 

The noderes.servicenode and noderes.xcatmaster attributes of these CECs are set to SN. 

  * HW Ctrl: 

The HW ctrl commands will be distributed to the SN. 

_5\. For the non-SN-CEC-LPARs_

  * Key Attributes: 

The nodehm.conserver, noderes.servicenode and noderes.xcatmaster attributes of these LPARs are set to SN. 

  * HW Ctrl: 

The HW ctrl commands will be distributed to the SN. 

  * Software Management(serving the boot image, xdsh, etc.): 

The software management commands will be distributed to the SN. 

_For Example:_

  * If noderes.servicenode is set for a hw ctrl point(CEC), then hw ctrl cmds should be distributed to the SN 
    * I.e. if "rpower node1 on" is run, xcat 1st looks up the hcp (e.g. ppc.hcp) of node1. Assume it is called CEC1. Then it looks up noderes.servicenode for CEC1. If that is set, for example, to sn1, then the rpower cmd will be dispatch to sn1 and then sn1 will contact CEC1 to power on node1. 
  * If noderes.servicenode is not set for a hw ctrl point CEC, then hw ctrl commands should be run on the MN directly. 

## **Configuring xCAT SN Hierarchy Ethernet Adapters(Power 775 DFM Only) **

[Configuring xCAT SN Hierarchy Ethernet Adapter DFM Only] 

## DFM configuration for hardware server connections

This section will discuss what needs to be configured and defined on the SN to allow for DFM to use hardware server to communicate to the CECs and Frames. 

Since the CEC and Frame node definitions are already created on the MN, this step is primarily using this data to create the entries in the hardware server configuration file. This task is done by running the **mkhwconn** command for each FSP of the CECs and BPA of the Frame. The **mkhwconn** command will run on the MN. 

Currently, xCAT supports creating hdwr_svr connections for xCAT(tool type: lpar) and CNM(tool type: fnm). 

_1\. hdwr_svr connections for xCAT(tool type: lpar)_

According to the definitions of the CEC in the section [#xCAT_DB_attributes], for &lt;SN-CECs&gt;, the noderes.servicenode and noderes.xcatmaster attributes of these CEC are not set, or set to MN; for &lt;non-SN-CECs&gt;, the noderes.servicenode and noderes.xcatmaster attributes of these CECs are set to SN. 

About the SN CEC, the following command will create the connection between the hdwr_svr on the MN and the CEC: 
    
     mkhwconn &lt;sn-CECs&gt; -t
     lshwconn &lt;sn-CECs&gt;
    

Use the lshwconn command to check the connection state, and the final expected connections state is "**LINE　UP**" 

**Before running the hardware control commands which will be distributed to the SN, finishing the OS provision for SN is a required prerequisite.**

About the non-SN CEC, this command will create the connections between the hdwr_svr on the SN and the CEC: 
    
     mkhwconn &lt;non-SN-CECs&gt; -t
    

According to the definitions of the Frame in the section [#xCAT_DB_attributes], the following command will create the connection between the hdwr_svr on the SN and the Frame. Finishing the OS provision for SN is a prerequisite for this command. 
    
     mkhwconn frame -t
    

And then run the following command to check the connection state, and the final expected connections state is "**LINE　UP**" 
    
     lshwconn frame
    

_2\. hdwr_svr connection for CNM(tool type: fnm)_

In xCAT DFM Hierarchy environment, CNM is not support on the SN, and CNM needs a connection to every CEC in the cluster to be able to manage the details of the HFI connectivity. So the hdwr_svr will be available only on the xCAT EMS working with the "fnm" hardware connection. mkhwconn will create the hdwr_svr connections for CNM on the MN to the CECs directly. 
    
     mkhwconn cec -t -T fnm
     lshwconn -T fnm
    

## DFM rpower on flow when OS provision

As part of the rpower flow working with P775 IH cluster, it is important to include power on for all GPFS I/O server nodes prior to compute nodes. And the compute nodes could not get the image from the SNs when the CEC powers up. The SNs should be powered on firstly, and only if the OS provision for SNs is finished, we can power on the computes nodes. So We should require the rpower on order: 
    
     1. power on the CECs to standby state
     2A. power on the SNs  (includes LL servers)
     2B. power on the GPFS I/O server working with DE's
     2C. power on  Utility  nodes (not as important but needed)  
     3. power on the compute nodes
    

## CEC down/up policy

In the DFM Hierarchical environment, the power operating on the non-sn-CECs are done through the service node. So there are some CEC down/up policy should be followed. 

### CEC Up Policy
    
    
    1. Power on SN-CECs to standby/operating state
    2. Power SNs on with OS 
    3. Create the connections from the SNs to the non-sn-CECs
    4. Power on the non-sn-CECs
    5. Power on all the compute LPARs

### CEC down policy
    
    
    1. Power off all the compute LPARs
    2. Power off the non-sn-CECs
    3. Power off the SNs
    4. Power off the SN-CECs

## Firmware update sequence
    
    
    1. Power off all the CECs
    2. Do the firmware update for the Frames' BPAs
    3. Do the firmware update for the sn-CECs' FSPs
    4. Power on the sn-CECs
    5. Power SNs on with OS 
    6. Create the connections from the SNs to the non-sn-CECs
    7. Do the firmware update for the non-sn-CECs' FSPs
    
