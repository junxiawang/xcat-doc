<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT Overview](#xcat-overview)
  - [Overview of xCAT's Features:](#overview-of-xcats-features)
  - [What To Do Next](#what-to-do-next)
- [xCAT Architecture](#xcat-architecture)
- [Networks in an xCAT Cluster](#networks-in-an-xcat-cluster)
- [xCAT Planning](#xcat-planning)
  - [Do You Need Hierarchy in Your Cluster?](#do-you-need-hierarchy-in-your-cluster)
    - [Service Nodes](#service-nodes)
    - [Network Hierarchy](#network-hierarchy)
  - [xCAT Cluster Node Types](#xcat-cluster-node-types)
  - [Design an xCAT Cluster for High Availability](#design-an-xcat-cluster-for-high-availability)
    - [Service Node Pools With No HA Software](#service-node-pools-with-no-ha-software)
    - [HA Management Node](#ha-management-node)
    - [HA Service Nodes](#ha-service-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## xCAT Overview

xCAT's purpose is to enable you to manage large numbers of servers used for any type of technical computing (HPC clusters, clouds, render farms, web farms, online gaming infrastructure, financial services, datacenters, etc.). xCAT is known for its exceptional scaling, for its wide variety of supported hardware, operating systems, and virtualization platforms, and for its complete day 0 setup capabilities. 

### Overview of xCAT's Features:

  * Discovery of hardware on the network, with automatic definition of it in the xCAT database 
  * Update of firmware, and BIOS/UEFI settings 
  * Remote management of the hardware: power on/off, console, boot order control, inventory, vpd data, envirionmentals 
    * Supported hardware: x86_64 (IPMI controlled), POWER, system z (zVM/zLinux) 
  * Definition of OS images: 
    * Via [copycds](http://xcat.sourceforge.net/man8/copycds.8.html) and setting of the [osimage definition attributes](http://xcat.sourceforge.net/man7/osimage.7.html), you can define OS images that then can be used with any of the OS deployment choices below. 
  * Several OS deployment choices: 
    * Scripted installation of stateful (diskful) nodes 
    * Network boot of stateless (diskless RAMdisk) nodes 
    * Network boot of statelite (diskless NFS-root) nodes 
    * Supported OS's: RHEL, CentOS, Scientific Linux, Fedora, Oracle Linux, SLES, Debian, Ubuntu, AIX, Windows 
  * Virtualization management: create VMs, deploy VMs, manage VMs, mirgrate VMs 
    * Supported virtualization platforms: VMWare, RHEV, KVM, PowerVM, zVM 
  * Management of node services: DNS, HTTP, DHCP, TFTP, NFS, NTP 
  * Central management of configuration files 
  * Parallel commands to all nodes: ping, copy, sync, run commands, node comparison 
  * Installation and configuration of monitoring tools 
  * Installation of HPC products (GPFS, Parallel Environment, LSF, compilers, etc.) 

For more details, see [XCAT_Features]. 

### What To Do Next

After you review the Architecture and Planning sections below, start with the xCAT "cookbook" that applies to your type of environment: 

  * x86_64, IPMI-controlled, rack mounted servers: [XCAT_iDataPlex_Cluster_Quick_Start] 
  * IBM Flex servers: [XCAT_system_x_support_for_IBM_Flex] or [xCAT system p support for Linux on IBM Flex](XCAT_system_p_support_for_IBM_Flex) or [xCAT system p support for AIX on IBM Flex](XCAT_support_for_AIX_on_system_P_Flex_Blades) 
  * IBM System p servers running Linux: [xCAT pLinux Clusters - Quick Start](XCAT_Power_QuickStart) or [xCAT pLinux Clusters - Full Documentation](XCAT_pLinux_Clusters) 
  * IBM System p servers running AIX: [XCAT_AIX_Cluster_Overview_and_Mgmt_Node] 
  * IBM System z Linux virtual machines within zVM: [xCAT zVM and zLinux](XCAT_zVM) 

All of these documents (and much more) are available on the [XCAT_Documentation] page. 

## xCAT Architecture

The following diagram shows the basic structure of the management software in an xCAT-managed cluster: 

[[img src=Xcat-arch.png]] 

**Notes:**

  * The service nodes are optional. See [Do you need hierarchy in your cluster.](XCAT_Overview,_Architecture,_and_Planning/#do-you-need-hierarchy-in-your-cluster)
    * The service nodes access the database on the management node over the network 
  * This diagram is representative of clusters of IPMI-controlled nodes or IBM Flex nodes. Clusters of system p servers or zVM virtual machines will be a little different. 
  * dhcpd, tftpd, httpd: these are the deployment services. xCAT configures them and then they respond to the netbooting nodes. On AIX, nfsd is used instead of httpd. 
  * The compute nodes can be stateful, stateless, or statelite 
  * The SP is the service processor (e.g. the IMM or FSP) and is used for out-of-band hardware control 

## Networks in an xCAT Cluster

The networks that are typically used in a cluster are: 

  * Management network - used by the management node to install and manage the OS of the nodes. The MN and in-band NIC of the nodes are connected to this network. If you have a large cluster with service nodes, sometimes this network is segregated into separate VLANs for each service node. See [Setting_Up_a_Linux_Hierarchical_Cluster] for details. 
  * Service network - used by the management node to control the nodes out of band via the BMC. If the BMCs are configured in shared mode, then this network can be combined with the management network. 
  * Application network - used by the HPC applications on the compute nodes. Usually an IB network. 
  * Site (Public) network - used to access the management node and sometimes for the compute nodes to provide services to the site. 

## xCAT Planning

Before setting up your cluster, there are a few things that are important to think through first, because it is much easier to go in the direction you want right from the beginning, instead of changing course midway through. 

### Do You Need Hierarchy in Your Cluster?

#### Service Nodes

For very large clusters, xCAT has the ability to distribute the management operations to service nodes. This allows the management node to delegate all management responsibilities for a set of compute or storage nodes to a service node so that the management node doesn't get overloaded. Although xCAT automates a lot of the aspects of deploying and configuring the services, it still adds complexity to your cluster. So the question is: at what size cluster do you need to start using service nodes?? The exact answer depends on a lot of factors (mgmt node size, network speed, node type, OS, frequency of node deployment, etc.), but here are some general guidelines for how many nodes a single mgmt node (or single service node) can handle: 

  * Linux: 
    * Stateful or Stateless: 500 nodes 
    * Statelite: 250 nodes 
  * AIX: 150 nodes 

These numbers can be higher (approximately double) if you are willing to "stage" the more intensive operations, like node deployment. 

Of course, there are some reasons to use service nodes that are not related to scale, for example, if some of your nodes are far away (network-wise) from the mgmt node. 

#### Network Hierarchy

For large clusters, you may want to divide the management network into separate subnets to limit the broadcast domains. (Service nodes and subnets don't have to coincide, although they often do.) xCAT clusters as large as 3500 nodes have used a single broadcast domain. 

Some cluster administrators also choose to sub-divide the application interconnect to limit the network contention between separate parallel jobs. 

### xCAT Cluster Node Types

Although xCAT gives you a lot of flexibility to mix and match its capabilities to create a custom cluster, in the end you may not end up with the cluster characteristics you wanted, if you don't understand the pros/cons of each capability. This section describes 3 standard node types that you can choose from, gives the pros and cons of each, and describes the cluster characteristics that will result from each. 

  * **Stateful** (diskfull): traditional cluster with OS on each node's local disk. 
    * Main advantage: this approach is familiar to most admins, and they typically have many years of experience with it 
    * Main disadvantage: you have to manage all of the individual OS copies 
  * **Stateless**: nodes boot from a RAMdisk OS image downloaded from the xCAT mgmt node or service node at boot time. (This option is not available on AIX.) 
    * Main advantage: central management of OS image, but nodes are not tethered to the mgmt node or service node it booted from 
    * Main disadvantage: you can't use a large image with many different applications all in the image for varied users, because it uses too much of the node's memory to store the ramdisk.&nbsp; (To mitigate this disadvantage, you can put your large application binaries and libraries in gpfs to reduce the ramdisk size. This requires some manual configuration of the image.) 
    * Scratch disk:&nbsp; Each node can also have a local "scratch" disk for swap, /tmp, /var, log files, dumps, etc.&nbsp; The purpose of the scratch disk is to provide a location for files that are written to by the node that can become quite large or for files that you don't want to have disappear when the node reboots.&nbsp; There should be nothing put on the scratch disk that represents the node's "state", so that if the disk fails you can simply replace it and reboot the node. A scratch disk would typically be used for situations like: job scheduling preemption is required (which needs a lot of swap space), the applications write large temp files, or you want to keep gpfs log or trace files persistently. (As a partial alternative to using the scratch disk, customers can choose to put /tmp /var/tmp, and log files (except GPFS logs files) in GPFS, but must be willing to accept the dependency on GPFS.) 
    * Statelite persistent files:&nbsp; xCAT supports layering some statelite persistent files/dirs on top of a ramdisk node.&nbsp; The statelite persistent files are nfs mounted.&nbsp; In this case, as little as possible should be in statelite persistent files, at least nothing that will cause the node to hang if the nfs mount goes away. 
  * **Statelite**: nodes boot from an NFS-root diskless OS image. 
    * Main advantages: can use large image with many different applications for varied users, and software that needs a diskfull-like environment will probably work w/o changes. 
    * Main disadvantage: nodes are tethered to service node and therefore go down when the service node goes down.&nbsp; This should be mitigated by configuring the services nodes with all of the hardware HA features available (RAID, power, fans, etc.). 
    * Scratch disk:&nbsp; Each node should also have a local "scratch" disk for swap, /tmp, /var, dumps, etc.&nbsp; The purpose of the scratch disk is to provide a location for files that are written to that can become quite large or that are written to often.&nbsp; There should be nothing put on the scratch disk that represents the node's "state", so that if the disk fails you can simply replace it and reboot the node.&nbsp; Small files that are written often can be put in tmpfs instead.&nbsp; As a partial alternative to this, customers can choose to put /tmp /var/tmp, and log files in GPFS, but must be willing to accept the dependency on GPFS. 
    * Statelite persistent files:&nbsp; you can put whatever you feel is necessary in statelite persistent files, although you should still avoid unnecessary files and files with a high write volume in statelite for performance reasons.&nbsp; The service nodes (or mgmt node) needs to have sufficient cpu, memory, network bandwidth, and a robust enough disk subsystem to handle the nfs traffic from statelite nodes.&nbsp; Exactly what is required depends on the number of nodes per service node, and the write volume of the statelite persistent files/dirs.&nbsp; Often the bottleneck on the service nodes is too few disk spindles. 

If you are not sure which node type to use for your cluster, **we recommend stateless nodes** for linux clusters (for AIX clusters we recommend stateful nodes), because this gives you a way to centrally manage your node images, without incurring a runtime single point of failure in the management node or service node. And the main disadvantage of stateless nodes (use of memory) can be mitigated with the approaches suggested in that section. 

### Design an xCAT Cluster for High Availability

Everyone wants their cluster to be as reliable and available as possible, but there are multiple ways to achieve that end goal. Availability and complexity are inversely proportional. You should choose an approach that balances these 2 in a way that fits your environment the best. Here's a few choices in order of least complex to more complex. 

#### Service Node Pools With No HA Software

[Service node pools](Setting_Up_a_Linux_Hierarchical_Cluster/#service-node-pools) is an xCAT approach in which more than one service node (SN) is in the broadcast domain for a set of nodes. When each node netboots, it chooses an available SN by which one responds to its DHCP request 1st. When services are set up on the node (e.g. DNS), xCAT configures the services to use at that SN and one other SN in the pool. That way, if one SN goes down, the node can keep running, and the next time it netboots it will automatically choose another SN. 

This approach is most often used with stateless nodes because that environment is more dynamic. It can possibly be used with stateful nodes (with a little more effort), but that type of node doesn't netboot nearly as often so a more manual operation (snmove) is needed in that case move a node to different SNs. 

It is best to have the SNs be as robust as possible, for example, if they are diskfull, configure them with at least 2 disks that are RAID'ed together. 

In smaller clusters, the management node (MN) can be part of the SN pool with one other SN. 

In larger clusters, if the network topology dictates that the MN is only for managing the SNs (not the compute nodes), then you need a plan for what to do if the MN fails. Since the cluster can continue to run if the MN is down temporarily, the plan could be as simple as have a backup MN w/o any disks. If the primary MN fails, move its RAID'ed disks to the backup MN and power it on. 

#### HA Management Node

If you want to use HA software on your management node to synchronize data and fail over services to a backup MN, see [Highly_Available_Management_Node], which discusses the different options and the pros and cons. 

It is important to note that some HA-related software like DRDB, Pacemaker, and Corosync is **not** officially supported by IBM, meaning that if you have a problem specifically with that software, you will have to go to the open source community or another vendor to get a fix. 

#### HA Service Nodes

When you have NFS-based diskless (statelite) nodes, there is sometimes the motivation make the NFS serving highly available among all of the service nodes. This is **not** recommended because it is a very complex configuration. In our opinion, the complexity of this setup can nullify much of the availibility you hope to gain. If you need your compute nodes to be highly available, you should strongly consider stateful or stateless nodes. 

If you still have reasons to pursue HA service nodes: 

  * For AIX, see [XCAT_HASN_with_GPFS] 
  * For linux, a couple prototype clusters have been set up in which the NFS service on the SNs is provided by GPFS CNFS (Clustered NFS). A howto is being written to describe the setup as an example. Stay tuned. 
