<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Configuration requirements](#configuration-requirements)
- [Configuration procedure](#configuration-procedure)
  - [Configure hardware RAID on the two management nodes](#configure-hardware-raid-on-the-two-management-nodes)
  - [Install OS on the primary management node](#install-os-on-the-primary-management-node)
  - [Initial failover test](#initial-failover-test)
  - [Setup xCAT on the Primary Management Node](#setup-xcat-on-the-primary-management-node)
  - [Continue setting up the cluster](#continue-setting-up-the-cluster)
- [Failover](#failover)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This documentation illustrates how to setup a second management node, or standby management node, in your cluster to provide high availability management capability, using RAID1 configuration inside the management node and physically moving the disks between the two management nodes. 

When one disk fails on the primary xCAT management node, replace the failed disk and use the RAID1 functionality to reconstruct the RAID1. 

When the primary xCAT management node fails, the administrator can shutdown the failed primary management node, unplug the disks from the primary management node and insert the disks into the standby management node, power on the standby management node and then the standby management immediately takes over the cluster management role. 

This HAMN approach is primarily intended for clusters in which the management node manages diskful nodes or linux stateless nodes. This also includes hierarchical clusters in which the management node only directly manages the diskful or linux stateless service nodes, and the compute nodes managed by the service nodes can be of any type. 

This documentation is not primarily intended for clusters in which the nodes directly managed by the management node are linux statelite or aix diskless nodes, because the nodes depend on the management node being up to run its operating system over NFS. But if the nodes use only readonly nfs mounts from the MN management node, then you can use this doc as long as you recognize that your nodes will go down while you are failing over to the standby management node. 

## Configuration requirements

  * The hardware type/model are not required to be identical on the two management nodes, but it is recommended to use similar hardware configuration on the two management nodes, at least have similar hardware capability on the two management nodes to support the same operating system and have similar management capability. 
  * Hardware RAID: Most of the IBM servers provide hardware RAID option, it is assumed that the hardware RAID configuration will be used in this HAMN configuration, if hardware RAID is not available on your servers, the software RAID **MIGHT** also work, but use it at your own risk, the doc [Use_RAID1_In_xCAT_Cluster](Use_RAID1_In_xCAT_Cluster) gives more details on how to configure the software on Linux, and the AIX disk mirroring feature could provide software RAID1 capability. 
  * The network connections on the two management nodes must be the same, the _ethx_ on the standby management node must be connected to same network with the _ethx_ on the primary management node. 
  * Use router/switch for routing: if the nodes in the cluster need to connect to the external network through gateway, the gateway should be on the router/switch instead of the management node, the router/switch have their own redundancy. 

## Configuration procedure

### Configure hardware RAID on the two management nodes

Follow the server documentation to setup the hardware RAID1 on the standby management node first, and then move the disks to the primary management node, setup hardware RAID1 on the primary management node. 

### Install OS on the primary management node

Install operating system on the primary management node using whatever method and configure the network interfaces. 

Make sure the attribute **HWADDR** is not specified in the network interface configuration file, like ifcfg-eth0. 

### Initial failover test

This is a sanity check, need to make sure the disks work on the two management nodes, just in case the disks do not work on the standby management node, we do not need to redo too much. DO NOT skip this step. 

Power off the primary management node, unplug the disks from the primary management node and insert them into the standby management node, boot up the standby management node and make sure the operating system is working correctly, and the network interfaces could connect to the network. 

If there are more than one network interfaces managed by the same network driver, like e1000, the network interfaces sequence might be different on the two management nodes even if the hardware configuration is identical on the two management nodes, you need to test the network connections during initial configuration to make sure it works. 

It is unlikely to happen, but just in case the ip addresses on the management node are assigned by DHCP, make sure the DHCP server is configured to assign the same ip address to the network interfaces on the two management nodes. 

After this, fail back to the primary management node, using the same procedure mentioned above. 

### Setup xCAT on the Primary Management Node

Follow the doc [Setting_Up_a_Linux_xCAT_Mgmt_Node] or [XCAT_AIX_Cluster_Overview_and_Mgmt_Node] to setup xCAT on the primary management node 

### Continue setting up the cluster

You can now continue to setup your cluster. Return to using the primary management node. Now setup your cluster using the following documentation, depending on your Hardware,OS and type of install you want to do on the Nodes. 

  * [XCAT System p Hardware Management](XCAT_System_p_Hardware_Management) 
  * [XCAT Power 775 Hardware Management](XCAT_Power_775_Hardware_Management)
  * [Setting Up an AIX Hierarchical Cluster](Setting_Up_an_AIX_Hierarchical_Cluster) 
  * [Setting Up a Linux Hierarchical Cluster](Setting_Up_a_Linux_Hierarchical_Cluster) 
  * [XCAT AIX Diskless Nodes](XCAT_AIX_Diskless_Nodes) 
  * [XCAT pLinux Clusters](XCAT_pLinux_Clusters) 
  * [XCAT Linux Statelite](XCAT_Linux_Statelite) 

For all the xCAT docs: https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/

During the cluster setup, there is one important thing to consider: 

  * Network services on management node 

Avoid using the management node to provide network services that are needed to be run continuously, like DHCP, named, ntp, put these network services on the service nodes if possible, multiple service nodes can provide network services redundancy, for example, use more than one service nodes as the name servers, DHCP servers and ntp servers for each compute node; if there is no service node configured in the cluster at all, static configuration on the compute nodes, like static ip address and /etc/hosts name resolution, can be used to eliminate the dependency with the management node. 

## Failover

The failover procedure is simple and straightforward: 

1\. Shutdown the primary management node 

2\. Unplug the disks from the primary management node, insert these disks into the standby management node 

3\. Boot up the standby management node 

4\. Verify the standby management node could now perform all the cluster management operations. 
