<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Overview](#1%5C-overview)
- [2\. Dependencies on AIX Features](#2%5C-dependencies-on-aix-features)
- [3\. Assumptions](#3%5C-assumptions)
- [4 Services provided for the compute nodes](#4-services-provided-for-the-compute-nodes)
  - [Default Gateway](#default-gateway)
  - [Nameserver](#nameserver)
  - [tftp and bootp](#tftp-and-bootp)
  - [Conserver](#conserver)
  - [Monserver](#monserver)
  - [ntp service](#ntp-service)
  - [hierarchichal hwctrl](#hierarchichal-hwctrl)
  - [xdsh](#xdsh)
- [5\. Architectural Diagram](#5%5C-architectural-diagram)
- [6\. External Interface](#6%5C-external-interface)
- [7\. Internal Design](#7%5C-internal-design)
  - [mkdsklsnode --setuphanfs flag](#mkdsklsnode---setuphanfs-flag)
  - [Postscript setupnfsv4replication](#postscript-setupnfsv4replication)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

**High Availability NFS on AIX service nodes**


## 1\. Overview

xCAT AIX diskless compute nodes need to mount NFS directories from the service node, each service node can serve hundreds of compute nodes, if the NFS service on the service node or the service node itself runs into problem, all the compute nodes served by this service node will be taken down immediately, so we have to consider providing the redundant NFS service for the compute nodes. 

The reason we are focusing on NFS and not all of these other services on the service nodes, is because NFS is the only one that will take the nodes down immediately and force a reboot, for most of the other services, the administrator will have a little while to run the utility to switch the nodes to another service node. For example, dhcp lease time can be made longer. they can specify multiple name servers in /etc/resolv.conf for the named high availability. See [HA_Service_Nodes_for_AIX] for more details about the high availability for the other services provided by the service ndoes. 

This documentation describes how to configure HA NFS on AIX service nodes, it is useful especially for the AIX service nodes that serve AIX diskless clients. For now, we are not planning to implement or document the HA NFS setup on Linux service nodes. 

Note: manual failover is not supported for this first release, only automatic failover is supported. 

## 2\. Dependencies on AIX Features

This HA NFS implementation heavily depends on some AIX features: 

1\. Shared root support for diskless nodes. 

AIX 61J adds a new feature named shared_root to improve the performance for AIX diskless deployment, the shared-root will be mounted as “/” by more than one diskless nodes. 

2\. NFSv4 replication 

The NFSv4 replication provides a way for high availability NFS, AIX added the NFSv4 replication support in AIX 61J. 

3\. STNFS replication 

The shared root support introduces the STNFS(Short Term Network File System), the STNFS enables the diskless nodes to write their changes to local memory and is invisible to other clients. The STNFS does not support NFSv4 replication until early 2012, the STNFS replication support is a key feature for this HA NFS on AIX service nodes. You can see more details about STNFS at http://publib.boulder.ibm.com/infocenter/aix/v6r1/index.jsp?topic=%2Fcom.ibm.aix.commadmn%2Fdoc%2Fcommadmndita%2Fnfs_short_term_filesystem.htm 

## 3\. Assumptions

This documentation describes a high availability and load-balancing solution, we need to make some assumptions and configuration restrictions: 

1.homogeneous cluster 

It should be a common configuration that all the nodes in one cluster are running exactly the same operating system version. 

2.shared-root configuration and read-mostly mounts 

The NFSv4 replication is designed for read-only or read-mostly mounts, the STNFS is designed for read-only mounts. To align with this, the shared_root configuration is required for HA NFS on AIX service nodes. 

3\. read-write mounts should be syncronized between the two service nodes. 

In shared_root configuration, most of the NFS mounts are read-only, only the limited statelite persistent files could be read-write mounts. Even for these statelite persistent mounts, the data syncronization between the service nodes should by the users. 

There are two typical types of read-write mounts that need to carefully be taken care of. 

  * **Paging space**, the paging space is mounted from the service nodes and it is possible that the AIX diskless clients will write to the paging space, if the paging space goes down while the AIX diskless clients are using the paging space, the operating system may crash immediately. So the directory for the paging spaces have to be syncronized between the service nodes. 
  * **Statelite persistent files**, the statelite persistent files might be written back frequently by the AIX diskless clients, so the directory for the statelite persistent files have to be syncronized between the service nodes. 

A recommended structure is to put all the AIX NIM resources files and statelite persistent files under the separate file system /install, then use GPFS and twin-tailed disks to replicate the /install file systems in the service nodes pairs. 

## 4 Services provided for the compute nodes

We know that NFS is not the only network service provided by the service nodes, we will have to take care of the other network services provided by the service nodes: 

### Default Gateway

The servicenode may act as the default gateway for the compute nodes served by this service node, if the service node is down, the client needs to switch over its default gateway to the backup service node. AIX provides a feature named Dead Gateway Detection (DGD) that can be used to provide gateway failover capability. xCAT will use [makeroutes](http://xcat.sourceforge.net/man8/makeroutes.8.html) to configure multiple default gateways for the compute nodes and setup the DGD to enable gateway failover. 

### Nameserver

We can specify both the primary and backup service nodes in /etc/resolv.conf on the compute nodes to enable the nameserver redundancy, but considering the dead nameserver may cause the hostname resolution performance degradation, using /etc/hosts for hostname resolution should be the right way to go for the service node redundancy scenario. 

### tftp and bootp

tftp and bootp are only used when the nodes are booting up, so lost of the service node will not cause tftp and bootp problem when the computes are already up and running. 

### Conserver

After the service node is down, rcons for the compute nodes will not work, the user needs to change the compute nodes' conserver attribute and rerun makeconservercf 

### Monserver

After the service node is down, monitoring through the service node will not work any more, the user needs to change the compute nodes' monserver attribute and rerun the monitoring configuration procedure. 

### ntp service

The ntp service lost will not cause the compute node problem, no additional action is needed for ntp service. 

### hierarchichal hwctrl

After the service node is down, hardware control through the service node will not work any more, the user needs to change the hcp's servicenode attribute and rerun the mkhwconn command. 

### xdsh

xdsh already supports the multiple service nodes. 

## 5\. Architectural Diagram

The core idea of this HA NFS implementation is to use NFS v4 replication to provide high availability NFS capability, each exportfs item on each service node will have a replication location on another service node, it means that when any of the exportfs items on the service node is unavailable to the NFS v4 clients, the NFS v4 clients will failover to the replication exportfs automatically. 

For the readonly (STNFS) file system (the bulk of the OS), the files only need to be replicated to both service nodes at the beginning (when the diskless image is created or updated). This can be accomplished by mkdsklsnode, which will detect if the target compute nodes have 2 service nodes listed in their noderes.servicenode attribute. If so, it will automatically copy the image from the EMS to both service nodes. 

For the readwrite (statelite) files, replication between the service nodes is more challenging. To accomplish this, the recommended configuration is that the SNs are all FC connected to 2 DS3524 external disks which contain the node images and statelite files. This file system is mounted on each service node as /install as a GPFS file system and GPFS (running on each SN) coordinates all updates to the disks from each SN. In this configuration, the readonly os files don't need to be copied by mkdsklsnode to both SNs (just one), but it still needs to create the NIM resources on both SNs. 

[[img src=Hanfs.jpg]] 

We need to categorize the service nodes into HA NFS domains, the information can be stored in the servicenode table by adding a new column “hanfsdomid”, the service nodes will the same hanfsdomid will be treated in the same HA NFS domain. 

## 6\. External Interface

Here are the steps to perform HA NFS setup on AIX service nodes: 

1\. Set the site.useNFSv4onAIX to "yes" right after the xCAT installation on management node. 

2\. Create a separate file system for /install on each service nodes, this can be done through NIM during the service node installation. The separate /install file system is required by NFSv4 replication, each NFSv4 replica must be a root of the file system. 

3\. Follow the procedure at [Setting_Up_an_AIX_Hierarchical_Cluster#Using_a_backup_service_node] to setup the primary and backup service nodes for the compute nodes. 

4\. **Run mkdsklsnode with a new flag "-S | --setuphanfs"**, do not specify flag "-p|--primarySN" or "- b|--backupSN" with mkdsklsnode command, we want the /install file systems on the service nodes pairs to be identical. 

5 A new postscripts setupnfsv4replication postscript will be added, you need to add this postscripts to the postscripts list for the compute nodes that will be using HA NFS on the service nodes. This postscripts will modify some failover related settings on the compute nodes. 

6 Run rnetboot or rpower to start the diskless boot 

7 Setup monitoring for the service nodes: [Monitor_and_Recover_Service_Nodes#Monitoring_Service_Nodes], when any of the service node fails, you should be able to get notification. 

8 At the sametime, the NFSv4 mounts on the compute nodes will failover to the standby service node transparently and automatically. 

9 If some of the non-critical services, like conserver, monserver and ntpserver are not configured as automatic failover between the service nodes, move them to the standby service node manually. 

10 Recover the failed service node: [Monitor_and_Recover_Service_Nodes#Recover_Service_Nodes] 

11 Whenever possible, reboot the compute nodes affected by the service node failure, to bring them back to their primary service node. 

  


## 7\. Internal Design

### mkdsklsnode --setuphanfs flag

What --setuphanfs flag needs to do is to configure NFSv4 replication on the service nodes. 

1\. Configure NFS v4 global settings, like enabling replication support through run command: _chnfs -R on_。 

2\. Unexport all the NFS exports under /install file system 

3\. Configure NFS v4 exports with replications settings, since each NFSv4 replica must be the root of a file system, so we will need to export the /install directory for all the compute nodes served by this service nodes pair. 

aixsn1:/#exportfs 

/install -replicas=/install@9.114.47.115:/install@9.114.47.104,vers=4,ro,root=* 

aixsn1:/# 

aixsn2:/#exportfs 

/install -replicas=/install@9.114.47.104:/install@9.114.47.115,vers=4,ro,root=* 

aixsn2:/# 

Note: STNFS replication requires to use ip address to specify the host of the replicas, and the nfs server itself has to be in the replicas list. 

### Postscript setupnfsv4replication

The default NFSv4 settings on the compute nodes will cause the failover to be much longer(about 5 minutes) than the diskless compute node could afford, we will have to perform some tuning for the NFSv4 settings. The two parameters are timeo and retrans, the timeo is the timeout value before NFSv4 client thinks the nfs access fails, the retrans means how many retries the nfs client will do when access fails, so theoritically the failovertime should be equal to "retrans*timeo", to avoid unnecessary failover when the nfs access fails caused by occasional problems like network workload burst, the setupnfsv4replication will set timeo=1 and retrans=3 by default, the user can modify the value according to their needs. 

Here is an example on how to configure the timeo and retrans on the nfs client side: 

  1. nfs4cl setfsoptions /usr timeo=1 
  1. nfs4cl setfsoptions /usr retrans=3 

We need to setup the tunning parameters timeo and retrans for all the NFSv4 mounts, like /usr and /.statelite/persistent for statelite configuration. 

These settings are only for NFSv4 mountes, the STNFS does not support failover parameters tuning for now, the timeout and replication timeout for STNFS are hard coded to 10 seconds and 20 seconds. 

To check the timeo and retrans settings for the file systems, use the following commands: 
    
    # nfs4cl showfs /usr
    
    Server      Remote Path          fsid                 Local Path        
    --------    ---------------      ---------------      ---------------   
    9.114.47.115 /install             0:42949672973        /usr              
            Current Server: 9.114.47.115:/install
            Replica Server: 9.114.47.104:/install
    options : ro,intr,nimperf,rsize=65536,wsize=65536,timeo=1,retrans=3,numclust=2,maxgroups=0,acregmin=14400,acregmax=14400,acdirmin=14400,acdirmax=14400,minpout=1250,maxpout=2500,sec=sys:krb5:krb5i:krb5p
    #
    
