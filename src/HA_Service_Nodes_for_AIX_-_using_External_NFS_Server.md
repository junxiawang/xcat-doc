<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [xCAT High Availability Service Nodes](#xcat-high-availability-service-nodes)
- [Process Example](#process-example)
  - [Install the Service Nodes](#install-the-service-nodes)
  - [Define xCAT compute nodes](#define-xcat-compute-nodes)
    - [Set “nfsserver”](#set-%E2%80%9Cnfsserver%E2%80%9D)
    - [Set "servicenode" and "xcatmaster"](#set-servicenode-and-xcatmaster)
  - [Define xCAT Groups (optional)](#define-xcat-groups-optional)
  - [Setup the node prescripts to sync files to the external NFS server](#setup-the-node-prescripts-to-sync-files-to-the-external-nfs-server)
  - [Set up statelite support](#set-up-statelite-support)
  - [Create a diskless osimage](#create-a-diskless-osimage)
    - [Required resources](#required-resources)
    - [Handling paging resource](#handling-paging-resource)
    - [Dump resource (optional)](#dump-resource-optional)
  - [Set up post boot scripts for compute nodes](#set-up-post-boot-scripts-for-compute-nodes)
    - [backupgateway(?) postscript](#backupgateway-postscript)
  - [Monitoring the service nodes](#monitoring-the-service-nodes)
  - [Initialize the AIX/NIM diskless nodes](#initialize-the-aixnim-diskless-nodes)
  - [Initiate a network boot](#initiate-a-network-boot)
- [When a service node crashes](#when-a-service-node-crashes)
  - [detecting a failover](#detecting-a-failover)
  - [completing the failover](#completing-the-failover)
    - [using snmove](#using-snmove)
  - [Recover the failed service node =](#recover-the-failed-service-node-)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

HA Service Nodes for AIX - using External NFS Server 

**NOTICE: This is work in progress!!!!!!**


## Overview

### xCAT High Availability Service Nodes

An AIX diskless node depends on filesystems NFS mounted from a server. Normally this server is the NIM master. 

In a hierarchical cluster the service node is the NIM master. If the NFS service on the service node or the service node itself runs into a problem, all the compute nodes served by this service node will be taken down immediately. 

_This document illustrates how to use an external highly available NFS server together with a backup service node to provide enhanced availability for cluster compute nodes._

The external NFS server must be set up with HA capability, for example, SONAS or GPFS CNFS. 

The core idea of this external NFS server support is to redirect all the NFS mounts on the stateless/statelite nodes to an external NFS server, the external NFS server can be any configuration as long as it could provide HA NFS capability and sufficient performance to handle thousands of NFS mounts. 

If a service node fails, the compute nodes served by it will not be affected immediately. Applications can continue run on the compute nodes. However, to complete the transfer to the backup service node you must run the xCAT "snmove" command as soon as the service node failure is detected. 

  


## Process Example

This is an example of the basic steps you could perform to setup a HASN. These steps should be integrated into the process described in the hierarchical document. ([Setting_Up_an_AIX_Hierarchical_Cluster]) 

Details for the example: 

MN: xcatmn1 SNs: xcatsn11,xcatsn12 CNs: compute01 - compute20 networks: \- ethernet for MN and SN installs \- HFI for SN and CN installs 

groups: \- xcatsn11nodes \- xcatsn12nodes 

  


### Install the Service Nodes

### Define xCAT compute nodes

#### Set “nfsserver”

Set the node attribute “nfsserver” to hostname of the external NFS server. Example: 
    
    _**chdef node01 nfsserver=extnfs01**_
    

  


#### Set "servicenode" and "xcatmaster"

Add the service node values to the "servicenode" and "xcatmaster" attributes of the node definitions. 

**Note-**

    

**xcatmaster:**&nbsp;: The hostname of the xCAT service node _as known by the node_. 
**servicenode:**&nbsp;: The hostname of the xCAT service node _as known by the management node_. 

To specify a backup service node you must specify a comma-separated list of two service nodes for the "servicenode" value. The first one will be the primary and the second will be the backup for that node. 

For the "_xcatmaster_" value you should only include the primary name of the service node _as known by the node_. 

In the following example "xcatsn1,xcatsn2" are the names of the service nodes as known by the xCAT management node and "xcatsn1-hfi0" is the name of the primary service node as known by the nodes. 
    
           _**chdef node01 servicenode="xcatsn1,xcatsn2" xcatmaster="xcatsn1-hfi0**_"
    

See [Setting_Up_an_AIX_Hierarchical_Cluster#Using_a_backup_service_node] for more information on setting up primary and backup service nodes for the compute nodes. 

**Note:** When using backup service nodes you should consider splitting the compute nodes between the two service nodes for performance reasons. 

  


### Define xCAT Groups (optional)

Create an xCAT group for the nodes that are assigned to each SN. This will be useful when setting node attributes as well as providing an easy way to switch a set of nodes back to their original server. 

To create an xCAT node group (SN1nodes) containing all the nodes that have the service node "xcatsn1" you could run a command similar to the following. 
    
            mkdef -t group -o SN1nodes -w  servicenode=xcatsn1
    

  


### Setup the node prescripts to sync files to the external NFS server

### Set up statelite support

AIX statelite is actually the shared_root stateless plus “overlay” for specific files or directories through the information in tables **statelite**, **litefile** and **litetree**. 

Put the statelite persistent directory in a /install subdirectory. 

The statelite persistent files may be written to frequently by the AIX diskless clients, so it is important to keep the statelite directories syncronized between the service nodes. 

Statelite files/dirs have to be sync'd with backup SNs (?? cron job??) example? 

  
Example table entries. 

**statelite table**

**litefile table**

**litetree table**

See statelite doc for details. 

  


### Create a diskless osimage

#### Required resources

\- spot, shared_root, 
    
    _**mkdsklsnode -V -t diskless -r -s /myimages 71dskls**_
    

#### Handling paging resource

The paging space is mounted from the service nodes and it is possible that the AIX diskless clients will write to the paging space, if the paging space goes down while the AIX diskless clients are using the paging space, the operating system may crash immediately. So the directory for the paging spaces have to be syncronized between the service nodes. 

#### Dump resource (optional)

can define dump res but would have to reboot node to have it dump to the backup SN 

\- if dump res is needed then node will have to be rebooted \- can set up dump res on SN2 but need reboot for it to work 

### Set up post boot scripts for compute nodes

#### backupgateway(?) postscript

AIX version 5.0 allows a host to discover if one of its gateways is down (called dead gateway detection) and, if so, choose a backup gateway, if one has been configured. Dead gateway detection can be passive (the default) or active. 

In passive mode, a host looks for an alternate gateway when normal TCP or ARP requests notice the gateway is not responding. Passive mode provides a ?best effort? service and requires very little overhead, but there may be a lag of several minutes before a dead gateway is noticed. 

In active mode, the host periodically pings the gateways. If a gateway fails to respond to several consecutive pings, the host chooses an alternate gateway. Active mode incurs added overhead, but maintains high availability for your network 

\- In postscript - create additional static route using the backup SN as gateway \- if primary SN crashes the AIX DGD switches to backup gw (SN2) \- use makeroutes or new postscript??? 

I noticed in your write-up you mentioned using makeroutes to set up multiple default gateways. This seems like the logical thing to do however there are some issues. 

For example: 

  1. I don't think AIX allows you to define multiple "default" routes. If you try to define a second it just overwrites the first. At least that's the way it used to work - unless this changed in the latest AIX release. 
  2. makeroutes uses the "route add ..." command but I think we might want to use chdev so that the route info is saved in the odm and is persistent across boots. (Probably doesn't matter for diskless nodes but might for diskful?) 
  3. There are additional attributes we'd have to include in our route table - ( like hopcount and active_dgd?). 
  4. We'll probably want to use DGD in passive mode since active might be too much overhead. In passive mode it's likely the admins will want to be able to set additional system tunables (using the "no" command) For example, to set the time to wait before considering the gateway "dead". ("The passive_dgd, dgd_packets_lost, and dgd_retry_time parameters can all be configured using the no command.") For active dgd you can set dgd_ping_time. 

  
"backupgateway"(?) postscript 

\- creates backup route \- In postscript - create additional static route using the backup SN as gateway \- if primary SN crashes the AIX DGD switches to backup gw (SN2) 

\- need to investigate tuning and options for DGD - active vs. passive 
    
             also - dgd_retry_time etc.
    

if test -z 'lsdev -C -S1 -F name -l inet0' then &gt; mkdev -t inet 

&gt; chdev -l inet0 -a route=net,-hopcount,0,-netmask,&lt;mask&gt;,-if,&lt;int&gt;,-active_dgd,-static&lt;netname&gt;,&lt;gateway&gt; ex. mask = 255.255.0.0 int = en0 netname=9.114.47.0 gateway= 9.114.154.126 

&gt; use "no" cmd to set tunables 

### Monitoring the service nodes

Setup monitoring for the service nodes: [Monitor_and_Recover_Service_Nodes#Monitoring_Service_Nodes], when any of the service node fails, you should be able to get notification. 

\- give example 

### Initialize the AIX/NIM diskless nodes

**Run mkdsklsnode with a new flag "-s | --setuphanfs"**, do not specify flag "-p|--primarySN" or "- b|--backupSN" with mkdsklsnode command, we want the /install file systems on the service nodes pairs to be identical. 

\- do sn config concurrently!!! \- ex. 

### Initiate a network boot

Run rnetboot or rbootseq/rpower to start the diskless boot 

## When a service node crashes

### detecting a failover

  1. use monitoring to detect SN failure 
  2. Use&nbsp;???? to check nfsv4 replication failover 

### completing the failover

After the service node is down, hardware control through the service node will not work any more, the user needs to change the hcp's servicenode attribute and rerun the mkhwconn command. 

The NFSv4 mounts on the compute nodes will fail over to the standby service node transparently and automatically 

As soon as the fail over is detected you must run the xCAT snmove command 

#### using snmove

\- If some of the non-critical services, like conserver, monserver and ntpserver are not configured as automatic failover between the service nodes, move them to the standby service node manually. == 

\- run snmove to re-target the nodes and update the xCAT db 

++++ \- reset /etc/xcatinfo on node \- syslog/errlog? \- LL config file ( switch order of SNs?) 

1) Name Resolution 

Set by snmove command???? 

We can specify both the primary and backup service nodes in /etc/resolv.conf on the compute nodes to enable the nameserver redundancy, but considering the dead nameserver may cause the hostname resolution performance degradation, using /etc/hosts for hostname resolution should be the right way to go for the service node redundancy scenario. 

2) Conserver 

Set by snmove command 

After the service node is down, rcons for the compute nodes will not work, the user needs to change the compute nodes' conserver attribute and rerun makeconserverc. 

3) Monserver 

After the service node is down, monitoring through the service node will not work any more, the user needs to change the compute nodes' monserver attribute and rerun the monitoring configuration procedure. 

  


### Recover the failed service node =

\- how force the failover back to the original SN?? \- run snmove with special option??? 
