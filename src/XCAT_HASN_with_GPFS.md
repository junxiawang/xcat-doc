<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**XCAT Highly Available AIX Service Nodes (HASN) with GPFS**](#xcat-highly-available-aix-service-nodes-hasn-with-gpfs)
- [Overview of Hardware and Cluster Configuration](#overview-of-hardware-and-cluster-configuration)
  - [Using a shared filesystem](#using-a-shared-filesystem)
  - [Considerations for Other Software Components](#considerations-for-other-software-components)
- [Limitations, Notes and Issues](#limitations-notes-and-issues)
- [Software Pre-requisites](#software-pre-requisites)
- [**HASN Setup Process**](#hasn-setup-process)
  - [**Assumptions**](#assumptions)
  - [**Preparing an existing cluster**](#preparing-an-existing-cluster)
    - [**Hardware setup for the shared file system**](#hardware-setup-for-the-shared-file-system)
    - [**Software setup for the shared file system**](#software-setup-for-the-shared-file-system)
    - [**Create shared file system on SNs (GPFS)**](#create-shared-file-system-on-sns-gpfs)
    - [**(Optional) Back up local /install on SNs**](#optional-back-up-local-install-on-sns)
    - [**Migrate xCAT /install contents**](#migrate-xcat-install-contents)
    - [**Migrate statelite data**](#migrate-statelite-data)
      - [**Statelite setup**](#statelite-setup)
    - [**Migrate non-xCAT /install contents**](#migrate-non-xcat-install-contents)
    - [**Configure the EMS**](#configure-the-ems)
    - [**Configure the SNs**](#configure-the-sns)
    - [**Configure SN startup and shutdown**](#configure-sn-startup-and-shutdown)
  - [**Preparing OS Images**](#preparing-os-images)
    - [**Update or create NIM installp_bundle resources**](#update-or-create-nim-installp_bundle-resources)
    - [**Convert all existing NIM images to NFSv4**](#convert-all-existing-nim-images-to-nfsv4)
    - [**Create and/or update xCAT osimages**](#create-andor-update-xcat-osimages)
    - [Updating the lpp_source](#updating-the-lpp_source)
    - [Updating the spot](#updating-the-spot)
    - [Remove resolv_conf resource](#remove-resolv_conf-resource)
    - [Special handling for dump and paging resources](#special-handling-for-dump-and-paging-resources)
    - [**Clean out all old NIM resources on the service nodes**](#clean-out-all-old-nim-resources-on-the-service-nodes)
  - [**Installing cluster nodes**](#installing-cluster-nodes)
    - [**Create compute node groups for primary service nodes**](#create-compute-node-groups-for-primary-service-nodes)
    - [**Update xCAT node definitions**](#update-xcat-node-definitions)
    - [**Shut down the cluster nodes**](#shut-down-the-cluster-nodes)
    - [**Remove the NIM client definitions from the SNs**](#remove-the-nim-client-definitions-from-the-sns)
    - [**Remove NIM resources from the SNs**](#remove-nim-resources-from-the-sns)
    - [**Clean up the NFS exports**](#clean-up-the-nfs-exports)
    - [**Migrate statelite and other data**](#migrate-statelite-and-other-data)
    - [**Switch to shared GPFS /install directory**](#switch-to-shared-gpfs-install-directory)
    - [**Additional SN software updates**](#additional-sn-software-updates)
    - [**Run mkdsklsnode**](#run-mkdsklsnode)
      - [mkdsklsnode for backup SNs](#mkdsklsnode-for-backup-sns)
      - [**mkdsklsnode for primary SNs**](#mkdsklsnode-for-primary-sns)
    - [**Verify the NFSv4 replication setup**](#verify-the-nfsv4-replication-setup)
    - [**Boot nodes**](#boot-nodes)
    - [**Verify node setup and function**](#verify-node-setup-and-function)
  - [SN failover process](#sn-failover-process)
    - [**Discover a primary SN failure**](#discover-a-primary-sn-failure)
    - [**Move nodes to the backup SN**](#move-nodes-to-the-backup-sn)
    - [**Verify the move**](#verify-the-move)
    - [**Reboot nodes - (optional)**](#reboot-nodes---optional)
  - [_Diagnostic hints and tips](#_diagnostic-hints-and-tips)
  - [Reverting to the primary service node](#reverting-to-the-primary-service-node)
  - [Working in a HASN environment](#working-in-a-hasn-environment)
    - [Removing NIM client definitions](#removing-nim-client-definitions)
    - [Removing old NIM resources](#removing-old-nim-resources)
  - [Setting up the Teal GPFS monitoring utility node](#setting-up-the-teal-gpfs-monitoring-utility-node)
    - [Software prereqs](#software-prereqs)
    - [**Setup DB2 Data Server Client code on the EMS**](#setup-db2-data-server-client-code-on-the-ems)
    - [**Configure DB2 Data Server Client**](#configure-db2-data-server-client)
      - [**db2dsdriver.cfg**](#db2dsdrivercfg)
      - [**db2cli.ini**](#db2cliini)
      - [**Using unixODBC**](#using-unixodbc)
    - [**Build the teal-gpfs diskless image**](#build-the-teal-gpfs-diskless-image)
      - [**Modify image with extra db2driver and odbc config files**](#modify-image-with-extra-db2driver-and-odbc-config-files)
    - [**Configure Network for IP forwarding**](#configure-network-for-ip-forwarding)
    - [Install the image and test DB connection](#install-the-image-and-test-db-connection)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**Warning: the HA service node capability described in this document is not for general use. It is a complex environment that should only be used by some select p775 customers running AIX that work directly with xCAT development while setting it up.**


## **XCAT Highly Available AIX Service Nodes (HASN) with GPFS**

**(Using AIX NFS v4 Client Replication Failover with GPFS filesystems.)**

AIX diskless nodes depend on their service nodes for many services: bootp, tftp, default gateway, name serving, NTP, etc. The most significant service is NFS to access OS files, statelite data, and paging space. This document describes how to use GPFS and NFSv4 client replication failover support to provide continuous NFS operation of the your HPC cluster if the NFS services provided by a service node become unavailable, whether due to failure of that service node or for other reasons.

If you experience a failure with one of your service nodes, and you have determined that the issues cannot be resolved quickly, you may wish to then use the xCAT **snmove** command to move the nodes managed by that service node to the defined backup service node in order to maintain full xCAT management and functionality of those nodes. The **snmove** command for AIX disklesss nodes provides the following function for the nodes:

  * changes xCAT database values for the nodes to switch the primary and backup servicenode values
  * changes syslog forwarding to the new servicenode
  * changes NTP to sync time updates from the new servicenode
  * changes the default gateway to the new servicenode (if old SN set)
  * retargets the dump device to the new servicenode
  * changes the bootlist to network boot from the new servicenode
  * changes NIM configuration files on the new servicenode to correctly respond to the network boot requests
  * updates statelite tables in the xCAT database and on the service node so that the next node reboot will use the new servicenode as its statelite server
  * optionally runs postscripts specified by the admin




## Overview of Hardware and Cluster Configuration

The main premise of this support is to use a shared /install filesystem across all service nodes. This filesystem will reside in a separate GPFS cluster, and NFSv4 with defined replicas will be used to export that filesystem to the diskless nodes in the cluster.

Optionally, future support may include allowing the xCAT EMS to also be connected to that same /install filesystem (this is not supported yet, and this document describes only the service node configuration).

### Using a shared filesystem

  * All service nodes in the cluster are FC connected to external disks which will be used to hold a common copy of the node images, statelite files, and paging space.
  * The disks are owned by GPFS, and all service nodes are in one GPFS cluster. Note that is a separate small management cluster (referred to here as the "admin GPFS cluster"), and is disjoint from the large GPFS application data cluster (referred to here as the "application GPFS cluster") that all of the compute and storage nodes belong to.
  * A common /install filesystem in the admin GPFS cluster will be used for all data except for dump resources
  * OPTIONAL: The EMS can also be attached to the external disks and included in the GPFS cluster. In this case, the /install filesystem will be common across the EMS and all service nodes.

     NOTE: This option is not yet supported by xCAT.

  * Each service node will NFSv4 export the /install filesystem with its backup service node NFS server replica specified (automatically set in the /etc/exports file by the xCAT mkdsklsnode command).
  * Compute node definitions in xCAT will have both a primary and a backup service node defined. The cluster will be configured with these "pairs" of service nodes, such that each service node in a pair is a backup to the other.
  * Compute nodes will NFSv4 mount the appropriate /install filesystems and be configured for NFSv4 client replication failover. This will include the /usr read-only filesystem, the shared-root filesystem which will be managed by STNFS on the compute node, the filesystem used for xCAT statelite data, and the paging space. The dump resources must NOT reside in a GPFS filesystem - these can either be a jfs* filesystem in the attached storage or in the local servicenode harddrives.

During normal cluster operation, if a compute node is no longer able to access its NFS server, it will failover to the configured replica backup server. Since both NFS servers are using GPFS to back the filesystem, the replica server will be able to continue to serve the identical data to the compute node. However, there is no automatic failover capability for the dump resource - no dump capability will be available until the xCAT **snmove** command is run to retarget the compute node's dump device to its backup service node.

### Considerations for Other Software Components

There are a few components (e.g. LoadLeveler daemons) that normally run on the service nodes that under certain circumstances need access to the application GPFS cluster. Since a service node can't be directly in 2 GPFS clusters at once, some changes in the placement or configuration of these components must be made, now that the service nodes are in their own GPFS cluster. Our recommendation is that the service nodes remotely mount the GPFS application cluster file system so that the LL daemons can still have access to this file system even though the service node is primarily in the SN GPFS cluster.

The only component this doesn't work for is the TEAL GPFS monitoring collector. This component needs to be on a node that is actually in the GPFS application cluster (remotely mounting it is not sufficient), but is also needs access to the DB. To solve this, the collector node can run the new db2driver package that uses a minimum DB2 client to run the required ODBC interface on a diskless node. This can be a utility node that has network access to the xCAT EMS either through appropriate routing or through an ethernet interface connected to the EMS network.

For reference, in case you want to run the components on other nodes when you switch to HA SN, here are the components requirements:

  * LL schedd daemons - need to store the spool files in a common file system. This could be the SN admin GPFS cluster if all the schedd's run on the SNs, but it is more typically the GPFS application cluster. The schedd's also normally need a file system that is common with the compute nodes where the application executables are stored, which is often the user home directories in the application GPFS cluster. For checkpoint/restart, the schedd's also need access to the GPFS application cluster.
  * LL central mgr, resource mgr, regional mgr, and schedd's - need access to the database if using the database option for LL, which currently is only available from the xCAT EMS and service nodes. (LL is not capable of accessing the DB2 database through the new db2driver package that uses a minimum DB2 client to run the ODBC interface from a diskless node.) The following LL features need the database option: rolling updates, TEAL monitoring, and the future energy aware scheduling feature. If you do not need to use these features, you can run LL with the traditional config files instead of the database option and move these LL services off the SNs onto utility nodes.
  * TEAL GPFS monitoring - needs to run on the GPFS monitoring collector node of the application GPFS cluster and needs access to the database.

## Limitations, Notes and Issues

  * The support described in this document is for high availability of NFSv4 to your diskless nodes. You will need to review all other services that your diskless nodes require from its service node. Other items may require additional configuration to your cluster. Some things to check:



  * external network routing -- If your nodes require continuous access to an external network, and you have currently set up a route through the service node, this network connection will be lost if the service node fails. The xCAT **snmove** will change the default route for a node to its backup service node. However, since this is a manualy admin operation and will not be switched over until the **snmove** command is run. If external network access cannot be interrupted due to a service node failure, you will need to implement something like the AIX dead gateway detection function (and be aware of the possible side affects to OS jitter or other issues when using that support). xCAT does not provide this function.
  * name resolution -- If your nodes are using its service node or an external name server for name resolution (e.g. an /etc/resolv.conf file, NIS, LDAP, etc.), operations on the node may be impacted if that service node goes down, or if access to an external name server is lost due to routing through that service node (see previous issue). This document assumes that the nodes are using local name resolution and running with a fully populated /etc/hosts file. It may be possible to list multiple name servers in your /etc/resolv.conf, but you will need to evaluate the performance impact to your cluster if one of those servers goes down. The ssh daemon in particular has very long timeouts, and often appears hung if there are problems with name resolution.
  * NTP server -- If your nodes use its service node as its NTP server (site.ntpservers="&lt;xcatmaster&gt;"), and you use the xCAT setupntp postscript to configure this support, the xCAT snmove command will reconfigure NTP on the node to the backup server. However, if the service node goes down, the node will not be able to do automatic NTP updates until snmove is run by the admin.
  * error logging -- If your nodes are forwarding syslog messages to its service node (default xCAT configuration), subsequent messages will be lost if the service node goes down. The xCAT **snmove** command will reconfigure syslog on the nodes to forward messages to the new service node.

  * You will need to remember that with a shared /install filesystems, the NIM files that are created there are visible to multiple NIM masters. xCAT code accommodates this when running NIM commands on multiple service nodes accessing the same directories and files. If you directly run NIM commands, remember that you can easily corrupt the NIM environment on another server without even realizing it. Use extreme caution when running NIM commands directly, and understand how the results of that command may affect other NIM servers accessing the identical /install/nim directories and files.
  * Since the NIM masters on both the primary and backup SNs for a compute node need to manipulate the identical client directories and files in the shared /install filesystem, you MUST NOT run the mkdsklsnode command on both the primary and backup service nodes at the same time for a given xCAT node. Also, in order for the xCAT **snmove** function to work correctly, you must run "mkdsklsnode -b .." to create your NIM machine definitions on the backup service node BEFORE running "mkdskslnode -p" which will create the correct client files to reference the active NIM master.
  * When migrating /install from local filesystems on the service nodes to the shared GPFS /install filesystem, this process requires that all of the NIM resources on the service nodes first be removed, and then recreated by running a new mkdsklsnode command for all of the compute nodes after switching over to the shared /install.
  * The dump resource CANNOT reside in a GPFS filesystem. This is not supported by AIX. The resources can either be a jfs* filesystem in the attached storage subsystem or reside in the local SN harddrives. There is no automatic failover capability for the dump resource - no dump capability will be available until the xCAT **snmove** command is run to retarget the compute node's dump device to its backup service node.
  * The service node OS service startup order (/etc/inittab) must be changed to start the admin GPFS cluster before trying to start NFS. Running NFS with no active GPFS filesystem to back the exported directories caused strange hangs on compute nodes that had that service node registered as its primary NFS server even though it had failed over and was running from the backup replica server. Therefore, you should modify /etc/inittab on the service nodes to control the startup order of NFS and GPFS correctly, moving the call for rc.nfs to after the start of GPFS.
  * The service node OS service shutdown order has to be changed to shutdown the NFS daemons before GPFS, so that NFS doesn't keep trying to serve files backed by GPFS.
  * Similarly, if you need to stop and restart GPFS on a service node, make sure to stop/start these services in the following order:



  1. exportfs -ua
  2. stopsrc -g nfs
  3. mmshutdown
  4. mmstartup
  5. startsrc -g nfs (or /etc/rc.nfs)
  6. exportfs -a

  * If the xCAT xdsh command (and some other xCAT hierarchical commands) detects that the primary service node is not available, it will use the backup service node to process the command. You will notice a performance degradation while xCAT times out trying to contact the primary service node if it is down. Also, if the primary service node is still active, but has network problems in communicating with its compute nodes, the NFSv4 client replication will failover to the backup service node to maintain node operation. However, xCAT xdsh commands to those nodes will fail since xCAT is still able to work with the service node, but the service node can no longer reach its compute nodes.
  * Paging space is now available with an ifix for the NFSv4 client replication fail over support. Instructions for use are included below. Note that NIM does not recognize this type of paging space. Therefore, the paging space files will need to manually be created in the shared /install GPFS filesystem, and then configured on the nodes through an xCAT postscript. That postscript will also need to remove the default swapnfs0 paging space on the nodes since the NIM NFS mount of that space was not done with the correct NVSv4 client replication information, and it may cause a system hang in a failover situation.
  * There is currently an issue with using NFSv4 replication client fail over for readwrite files, even when GPFS is ensuring that the files are the same regardless of which SN the are accessed from. A small timing window exists in which the client sends a request to update a file and the server updates it, but before it sends the acknowledgement to the client, the server crashes. When the client fails over to the other server (which has the updated file thanks to GPFS) and resends the update request, the client will detect that the modification time the client and server think the file has are different and bail out, marking the file "dead" until the client closes and reopens the file. This is a precaution, because the NFS client has no way of verifying that this is the exact same file that it updated on the other server. AIX development is sizing a configuration option in which we could tell it not to mark the file dead in this case because GPFS is ensuring the consistency of the files between the servers.

    Note - we have not yet directly experienced this condition in any of our testing.

  * If "site.sharedinstall=all" (currently not supported), all NIM resources on the EMS will be created directly in the GPFS filesystem, including your lpp_source and spot resources. By default, NIM resources cannot be created with associated files in a GPFS filesystem (only jsf or jsf2 filesystems are supported). To bypass this restriction all NIM commands must be run with either the environment variable "NIM_ATTR_FORCE=yes" set, or by using the 'nim -F' force flag directly on each command. All xCAT commands have been changed to accommodate this setting. However, it is often necessary for an admin to run NIM commands directly. When doing so, be sure to use one of these force options.

## Software Pre-requisites

1) xCAT version 2.7.2 or higher.

2) Base OS: AIX 7.1 TL1 SP3 (7100-01-03-1207)

3) AIX ifixes:



  * IV22221m03.epkg.Z

     Package Content:
     IV14334: stnfs I/O error after NFSv4 replication failover
     IV16758: error accessing file after NFSv4 client replication failover
     IV15048: additional privileges required for rolelist command
     IV22221: IMPLEMENT NFS V4 PAGING SPACE REPLICATION



  * IV27038: NFSV4 diskless client hang with nfsrgyd dependancy
    These fixes are available from the AIX download site:
     ftp://public.dhe.ibm.com/aix/ifixes/

4) xCAT ifixes



  * SF3548436.120801.epkg.Z

    A tar file (SF3548436.ifix.tar) containing this epkg file is attached to svn bug #3548436. View the svn bug report and download the tar file to get the ifix.

    (https://sourceforge.net/tracker/?atid=1006945&amp;group_id=208749&amp;func=browse)

    This ifix is for xCAT version 2.7.2. It is a cumulative ifix that includes the following previous fixes:



  * SF3526650.120629.epkg.Z
  * SF3547581.120724.epkg.Z

    Make sure to read the README file, that is included in the tar file, before applying this fix.

## **HASN Setup Process**

### **Assumptions**

This procedure assumes the following:



  1. You are starting with an existing cluster.
  2. The EMS is installed with the correct xCAT code, configured, and operational.
  3. Service Nodes (SNs) are installed with correct xCAT code, configured, and operational.
  4. Network routing from the EMS to the compute nodes is set up correctly so that if one service node goes down, there are other routes to reach the compute node network.
  5. Release 2.7.2 of xCAT is installed on the EMS and SNs.
  6. You are running AIX 7.1.1 SP3 release levels that contain NFSv4 fixes on the EMS and Service Nodes and that new compute node images will be built with the same AIX level and fixes.

### **Preparing an existing cluster**

    **Note**: If starting over with a new cluster then refer to the
    [Setting_Up_an_AIX_Hierarchical_Cluster]
    document for details on how to install an xCAT EMS and service nodes (SN).


**Do not remove any xCAT or NIM information from the EMS.**

#### **Hardware setup for the shared file system**

Note: the following 2 diagrams do 'not' imply that you can have 2 separate /install files systems in GPFS within the same xCAT cluster - one for one set of service nodes and another for the other set of service nodes. All the service nodes in the xCAT cluster must use the same /install file system in the same GPFS cluster.

Storage Setup Configuration When Service Nodes Also Have Local Disks for their OS


[[img src=StorageSetup01.jpg]]

  * This configuration may be used when the systems housing the service nodes have enough slots available to accommodate internal drives for the service node as well as the fiber channel HBAs for connectivity to the external storage to be used with the GPFS setup.
  * The amount of storage in the configuration should be sized adequately based on the desired storage capacity desired as well as the overall I/O throughput desired from the setup.
  * If there are more service nodes than the host ports on the fiber channel storage controller units then the use of fiber channel switches may be required.
  * Typically the configuration would have two identically configured fiber channel controller setups. Using two controller setups along with GPFS replication will provide data protection beyond that provided at the RAID array level.
  * The external storage is typically configured in 4+2P RAID6 arrays with one LUN per array. The use of 256KB segment during the array creation will allow for a GPFS file system block size of 1MB. Alternately a segment size of 128KB may also be used which will allow for a GPFS file system block size of 512KB.




Storage Setup Configuration When Service Nodes Also Do Not Have Local Disks for their OS


[[img src=StorageSetup02.jpg]]

  * This configuration may be used when the systems housing the service nodes DO NOT have enough slots available to accommodate internal drives for the service node as well as the fiber channel HBAs for connectivity to the external storage to be used with the GPFS setup thus necessitating that the service nodes boot over fiber channel from the external storage.
  * The amount of storage in the configuration should be sized adequately based on the desired storage capacity desired as well as the overall I/O throughput desired from the setup.
  * If there are more service nodes than the host ports on the fiber channel storage controller units then the use of fiber channel switches may be required.
  * Typically the configuration would have two identically configured fiber channel controller setups. Using two controller setups along with GPFS replication will provide data protection beyond that provided at the RAID array level.
  * The external storage is typically configured in 4+2P RAID6 arrays with one LUN per array. The use of 256KB segment during the array creation will allow for a GPFS file system block size of 1MB. Alternately a segment size of 128KB may also be used which will allow for a GPFS file system block size of 512KB.
  * The disks to be used for the boot of the service node(s) can be RAIDED (for example RAID1) or non-RAIDED. The use of storage partitioning is recommended to isolate the disks used for the service node booting from those to be used with the GPFS setup.

#### **Software setup for the shared file system**

Perform the necessary admin steps to assign the fibre channel I/O adapter slots to the selected xCAT SN octant/LPAR (the xCAT chvm command may be used to do this). The xCAT SN LPAR and serving CEC may need to be taken down to make I/O slot changes to the xCAT SN configuration.

Ensure that the assigned SAN Disks being used with the GPFS cluster can be allocated back to the assigned fibre channel adapters and the SAN disks can be seen on the target xCAT SNs .

#### **Create shared file system on SNs (GPFS)**

[PUNEET/BIN_-_PLEASE_ADD_DETAIL_HERE_AS_REQUIRED]

Recommendations for the GPFS setup

  * All the service nodes from a cluster/sub-cluster should typically belong to a GPFS cluster.
  * The GPFS cluster should be configured over the Ethernet interfaces on the service nodes.
  * Recommended block sizes for the GPFS file system in the setup are 1MB or 512KB.
  * Optionally the EMS can also be a part of this GPFS setup.

Layout of the file systems on the external disks:

  * There is only ONE COMMON /install file system across all service nodes in the cluster/sub-cluster. Optionally, this file system can also be available on the EMS, and written directly there.
  * There is only one file system for the statelite persistent files. To make NFS exports simple, this can be under the /install filesystem.
  * The paging spaces will need to be under /install/nim, for example /install/nim/paging. This directory should be configured such that it is not replicated at the GPFS level. This is for optimal use of the space in the GPFS file system as well as for performance reasons.

For now, mount the GPFS /install filesystem on a temporary mount point on the SNs, such as /install-gpfs. This will need to be changed to /install later in the process.

#### **(Optional) Back up local /install on SNs**

Since this process will remove all existing data from the local /install/nim directories on your service nodes, you may choose to make a backup copy of the /install filesystem at this time.




#### **Migrate xCAT /install contents**

The contents of the local /install filesystems on your SNs will need to be copied into the new shared GPFS /install-gpfs filesystem. You should NOT copy over the /install/nim directory -- this will need to be completely re-created in order to ensure NIM is configured correctly for each SN.

Most of the xCAT data should be identical for each local SN /install directory in your cluster. This includes sub-directories such as:

~~~~
     /install/custom
     /install/post
     /install/prescripts
     /install/postscripts
~~~~

It will only be necessary to copy these subdirectories from one SN into /install-gpfs. Therefore, you can just log into one SN and use **rsync** to copy the files and directories to the shared file system.




#### **Migrate statelite data**

You must create the directory for your persistent statelite data in the /install-gpfs filesystem. e.g. from one SN:

~~~~
      mkdir /install-gpfs/statelite_data
~~~~


(Optional) At this time, you may choose to place an initial copy of your persistent data into the /install-gpfs filesysem. However, since the compute nodes in your cluster are currently running, they are still updating their persistent files, so you will need to re-sync this data again later after bringing down the cluster. Depending on the amount and stability of your persistent data, the subsequent **rsync** can take much less time and help reduce your cluster outage time.

Use **rsync** to do the initial copy from your current statelite directory. You should run this **rsync** from one SN at a time to copy data into the shared /install-gpfs filesystem. This will ensure that if you happen to have more than one SN that has a subdirectory for the same compute node, you will not run into collisions copying from multiple SNs at the same time. Make sure to use the **rsync -u** (update) option to ensure stale data from an older SN does not overwrite the data from an active SN.

Note: You do not need to worry about changing /etc/exports to correctly export your statelite directory since you are placing it in /install-gpfs. Later in the process, you will rename the filesystem to /install, and xCAT will add the correct /install export for NFSv4 replication to /etc/exports when mkdsklsnode runs.

##### **Statelite setup**

The statelite table will need to be set up so that each service node is the NFS server for its compute nodes. You should use the "$noderes.xcatmaster" substitution string instead of specifying the actual service node so that when xCAT changes the service node database values for the compute nodes during an [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) operation, this table will still have correct information. Also, you should specify NFS option "vers=4" as a mount option. The entry should look something like:

~~~~
    #node,image,statemnt,mntopts,comments,disable
    "compute",,"$noderes.xcatmaster:/install/statelite_data","vers=4",,
~~~~

REMINDER: If you have an entry in your litefile table for persistent AIX logs, you MUST redirect your console log to another location, especially in this environment. The NFSv4 client replication failover support logs messages during failover, and if the console log location is in a persistent directory, which is actively failing over, you can hang your failover. If you have an entry in your litefile similar to:

~~~~
      tabdump litefile

       #image,file,options,comments,disable
       "ALL","/var/adm/ras/","persistent","for GPFS",
~~~~

Be sure that you have a postscript that runs during node boot to redirect the console log:

~~~~

    /usr/sbin/swcons -p /tmp/conslog
~~~~

(or some other local location)

For more information, see: [XCAT_AIX_Diskless_Nodes/#Preserving_system_log_files](XCAT_AIX_Diskless_Nodes/#Preserving_system_log_files)

#### **Migrate non-xCAT /install contents**

If you have any other non-xCAT data in your local /install filesystems, you will first need to determine if this data is identical across all service nodes, or if you will need to create a directory structure to support unique files for each SN. Based on that determination, copy the data into /install-gpfs as appropriate.




#### **Configure the EMS**

  * Verify that the following attributes and values are set in the xCAT site definition:

~~~~
    nameservers=         (set to null so xCAT will not create a resolv.conf resource for the nodes)
    domain=<domain_name> (this is required by NFSv4)
    useNFSv4onAIX="yes"  (must specify NFSv4 support)
    sharedinstall="sns"  (indicates /install is shared across service nodes)
~~~~


You could set these values using the following command:

~~~~

    chdef -t site nameservers="" domain=mycluster.com
    useNFSv4onAIX="yes" sharedinstall="sns"
~~~~

Also, verify that your xCAT networks table does not have a nameservers value set for your cluster network:

~~~~
    lsdef -t network -i nameservers

~~~~

  * NFSv4 requires that the file /etc/nfs/local_domain contains a single entry with your cluster domain name. Verify that this file exists and is correct. If the file does not exist, create it now.
  * If you are using DB2 for your xCAT database, you will need to change your /etc/exports to export your DB2 source directory as NFSv4 to ensure any future service node re-installs work correctly:

~~~~
      /mntdb2 -vers=4,sec=sys:krb5p:krb5i:krb5:dh,rw
~~~~


and run the 'exportfs -a' command to re-export the change.

  * Verify that all required software and updates are installed.

    See [XCAT_HASN_with_GPFS/#Software_Pre-requisites](XCAT_HASN_with_GPFS/#Software_Pre-requisites) for a complete list.

  * If you intend to define dump resources for your compute nodes then make sure you have installed the prequisite software. See [XCAT_AIX_Diskless_Nodes/#ISCSI_dump_support](XCAT_AIX_Diskless_Nodes/#ISCSI_dump_support) for details.

#### **Configure the SNs**

  * Verify that each service node has the required NFSv4 file /etc/nfs/local_domain correctly set:

~~~~
      xdsh service cat /etc/nfs/local_domain | xcoll
~~~~


If not, copy the file from the EMS to each SN:

~~~~
      xdcp service /etc/nfs/local_domain /etc/nfs/
~~~~


  * Verify that all required software and updates are installed.

    See [XCAT_HASN_with_GPFS/#Software_Pre-requisites](XCAT_HASN_with_GPFS/#Software_Pre-requisites)  for complete list.




    You can use the [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html)command to update the SNs.

  * If you intend to define dump resources for your compute nodes then make sure you have installed the prequisite software. See [XCAT_AIX_Diskless_Nodes/#ISCSI_dump_support](XCAT_AIX_Diskless_Nodes/#ISCSI_dump_support) for details.

NOTE: If any software changes you are making require you to reboot the service node, you may wish to postpone this work until you shutdown the cluster nodes later in the process.

#### **Configure SN startup and shutdown**

On each service node, the AIX OS startup order has to be changed to start GPFS before NFS and xcatd, since both rely on the /install directory being active. Edit /etc/inittab on each service node.

~~~~
    vi /etc/inittab
~~~~

Move the calls to /etc/rc.nfs and xcatd to AFTER the start of GPFS, making sure GPFS is active before starting these services.

On each service node, the AIX OS shutdown order has to be changed to shutdown the NFS server before GPFS, so that NFS doesn't keep trying to serve files backed by GPFS. Add the following to /etc/rc.shutdown on each service node:

~~~~
    vi /etc/rc.shutdown and add:
    stopsrc -s nfsd
    exit 0
~~~~

You may wish to keep copies of these files on the EMS and add them to synclists for your service nodes. Then, if you ever need to re-install your service nodes, these files will be updated correctly at that time.

### **Preparing OS Images**

#### **Update or create NIM installp_bundle resources**

(There is nothing unique required in this step for HASN support)

Create or update NIM installp_bundle files that you wish to use with your osimages.

Also, if you are upgrading to a new version of xCAT, you should check any installp_bundles that you use that were provided as sample bundle files by xCAT. If these sample bundle files are updated in the new version of xCAT you should update your NIM installp_bundle files appropriately.

The list of bundle files you have defined may include:

  1. xCATaixCN71
  2. xCATaixHFIdd
  3. IBMhpc_base
  4. IBMhpc_all

To define a NIM installp_bundle resource you can run a command similar to the following:

~~~~
    nim -Fo define -t installp_bundle -a location=/install/nim/installp_bundle/xCATaixCN71.bnd \
    -a server=master xCATaixCN71**
~~~~


You can modify a bundle file by simply editing it. It does not have to be re-defined.

Note: It is important when using multiple bundle files that the first bundle in the list be xCATaixCN71 since this contains the 'rpm' lpp package which is required for installing subsequent bundle files.

#### **Convert all existing NIM images to NFSv4**

If your cluster was setup with NFSv3 you will need to convert all existing NIM images to NFSv4. On the EMS, for each existing OS image definition, run:

~~~~
    mknimimage -u <osimage_name> nfs_vers=4
~~~~





#### **Create and/or update xCAT osimages**

You will need to build images with the correct version of AIX, all of the required fixes for NFS v4 client replcation failover support, and your desired HPC software stack. You can use existing xCAT osimage definitions or you can create new ones using the xCAT [mknimimage](http://xcat.sourceforge.net/man1/mknimimage.1.html) command.

To create a new osimage you could run a command similar to the following:

~~~~
    mknimimage -V -r -s /myimages -t diskless <osimage name>
    installp_bundle="xCATaixCN71,xCATaixHFIdd,IBMhpc_base,IBMhpc_all"
~~~~





#### Updating the lpp_source

Whether you are using an existing lpp_source or you created a new one you must make sure you copy any new software prerequisites or updates to the NIM lpp_source resource for the osimage.

The easiest way to do this is to use the "nim -o update" command.

For example, to copy all software from the /tmp/myimages directory you could run the following command.

~~~~
    nim -o update -a packages=all -a source=/tmp/myimages <lpp_source name>
~~~~


This command will automatically copy installp, rpm, and emgr packages to the correct location in the lpp_source subdirectories.

Once you have copied all you software to the lpp_source it would be good to run the following two commands.

~~~~
    nim -Fo check <lpp_source name>
~~~~


And.

~~~~
    chkosimage -V <spot name>
~~~~


See [chkosimage](http://xcat.sourceforge.net/man1/chkosimage.1.html) for details.

#### Updating the spot

You can use the the xCAT [mknimimage](http://xcat.sourceforge.net/man1/mknimimage.1.html), [xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html), or [xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html) commands to update the spot software on the EMS.

For example, to install the IV15048m03.120516.epkg.Z ifix you could run the following command.

~~~~
    mknimimage -V -u <spot name> otherpkgs="E:IV15048m03.120516.epkg.Z  "
~~~~


Check the spot.

~~~~
    nim -Fo check <spot name>
~~~~


Verify that the ifixes are applied to the spot.

~~~~
    xcatchroot -i <spot name> "emgr -l"
~~~~



Some notes regarding spot updates:

  * xCAT 2.7.2 made some required changes to the rc.dd_boot script that gets built into the spot. If you are using a spot that was created with an older version of xCAT, you will need to create a new spot using your lpp_source. Do NOT use a spot that was created by copying an older spot.
  * The ifixes for the NFS4 replication support require updates to the boot image *chrp* files that get built in the /tftpboot directory. You will need to make sure that a new 'nim -Fo check &lt;spot name&gt;' gets run on each service node after this ifix has been applied to your spot and copied down to the service node by mkdsklsnode. Verify that all of the service node /tftpboot/*chrp* files for your image have been updated (i.e. have new timestamps) after running mkdsklsnode.

#### Remove resolv_conf resource

This procedure recommends that you do not run your nodes with an /etc/resolv.conf file, and use a fully populated /etc/hosts file in your diskless image. See Limitations,Notes and Issues[XCAT_HASN_with_GPFS] above.

If your OS image has a resolv_conf resource assigned to it then remove it.

~~~~
      lsdef -t osimage -o <image name>  -i resolv_conf
~~~~


If set, remove it:

~~~~
      chdef -t osimage -o <image name> resolv_conf=''
~~~~


**Also, make sure the "nameservers" attribute is NOT set** in either the xCAT site definition or the xCAT network definitions. If the "nameservers" is set then xCAT will attempt to create a default NIM "resolv_conf" resource for the nodes.

By default, xCAT will use the /etc/hosts from your EMS to populate the OS image. If you require a different /etc/hosts, copy it into your spot and shared_root:

~~~~
      cp <your compute node hosts> /install/nim/spot/<spot name>/usr/lpp/bos/inst_root/etc/hosts
      cp <your compute node hosts> /install/nim/shared_root/<shared root name>/etc/hosts
~~~~


You may also want to configure the order of name resolution search to use local files first by setting the correct values in the netsvc.conf file in those same locations in the spot and shared_root.

#### Special handling for dump and paging resources

**Dump resource**

Due to current NIM limitations a dump resource cannot be created in the shared file system.

If you wish to define a dump resource to be included in an osimage definition you must use NIM directly to create the resource in a separate local file system on the EMS. (For example /export/nim.)

Once the dump resource is created you can add its name to your osimage definition.

~~~~
    chdef -t osimage -o <osimage name> dump=<dump res name>
~~~~


Note: If you have multiple osimages you should create a different NIM dump resource for each one.

When the **mkdsklsnode** command creates the resources on the SNs it will create the dump resources in a local filesystem with the same name, e.g. /export/nim. If you want these directories to exist in filesystems on the external storage subsystem, you will need to create those filesystems and have them available on each SN before running the **mkdsklsnode** command.

**Paging resource**

NOTE: NIM does not support paging space with NFSv4 client failover. Therefore, the paging space files will need to manually be created in the shared /install GPFS filesystem, and then configured on the nodes through an xCAT postscript. That postscript will also need to remove the default swapnfs0 paging space on the nodes since the NIM NFS mount of that space was not done with the correct NVSv4 client replication information, and it may cause a system hang in a failover situation.

NOTE 2: The mkps flags ':fur' are specific for failover support. If you previously created the postscript below prior to using the paging failover support, make sure to replace the old ':wam' flags with ':fur'.

On one SN, create the paging files for all of the compute nodes in your cluster in the shared /install filesystem. Do NOT place the files in the same directory NIM will be using for the node's paging resource containing the initial swapnfs0 paging device (e.g. do NOT put swapnfs1 in /install/nim/paging/&lt;image&gt;_paging/&lt;node&gt;) since all the files in that directory are removed during rmdsklsnode.

For example, to create 128G of swap space for each node do:

~~~~
      mkdir /install/paging
      # For each compute node:
      mkdir /install/paging/<compute node>
      dd if=/dev/zero of=/install/paging/<node>/swapnfs1 bs=1024k count=65536
      dd if=/dev/zero of=/install/paging/<node>/swapnfs2 bs=1024k count=65536
~~~~



Set up a new postscript to run on the compute node to activate that paging space with replication/failover support and disable the default swapnfs0. e.g. 'vi nfsv4mkps':

~~~~
      #!/bin/sh

      rmps swapnfs1
      rmps swapnfs2

      mkps -t nfs $MASTER /install/paging/`hostname -s`/swapnfs1:fur
      mkps -t nfs $MASTER /install/paging/`hostname -s`/swapnfs2:fur

      swapon /dev/swapnfs1
      swapon /dev/swapnfs2

      swapoff /dev/swapnfs0
      rmps swapnfs0
~~~~


Add the postscript to your xCAT node definitions:

~~~~
      chdef <compute_nodes>  -p postscripts=nfsv4mkps
~~~~


Typically to view paging configuration information on a node, you would use the 'lsps' command. The "Server Hostname" listed in the output of this command is the primary NFS server for the paging space. Even if NFSv4 client failover has occurred, the 'lsps' output will not reflect the actual NFS server that is servicing the mount. AIX does not provide a utility to view the current active NFS server for the paging space.

#### **Clean out all old NIM resources on the service nodes**

Review all NIM resources you have defined on your service nodes:

~~~~
      xdsh service lsnim | xcoll
      lsdef -t osimage
~~~~


Remove all OS images from your service nodes that are not actively being used by the cluster at this time. You can use the rmnimimage command to help with this:

~~~~
      rmnimimage -V -s service <image name>
~~~~


Review the remaining NIM resources, again:

~~~~
      xdsh service lsnim | xcoll
~~~~


Use NIM commands to remove any remaining unused resources from each service node. Do NOT remove any resources actively being used by your running cluster, or the NIM master or network definitions. If you're not sure, do not remove the resources at this time, and wait until you bring down the compute nodes later.

### **Installing cluster nodes**

#### **Create compute node groups for primary service nodes**

If you do not already have a separate nodegroup for all nodes managed by a service node, you may wish to create these nodegroups now to make the following management easier.

#### **Update xCAT node definitions**

  * Add new postscript **setupnfsv4replication**.

xCAT has provided a new postscript **setupnfsv4replication** that needs to be run on each node to set up the NFS v4 client support for failover. This script contains some tuning settings that you may wish to adjust for your cluster:

~~~~
      $::NFSRETRIES = 3;
      $::NFSTIMEO = 1;   # in tenths of a second, i.e. NFSTIMEO=1 is 0.1 seconds
~~~~


NFSTIMEO is how long NFS will wait for a response from the server before timing out. NFSRETRIES is the number of times NFS will try to contact the server before initiating a failover to the backup server. If you do change this postscript, be sure to remember to copy the updates to your new shared /install filesystem on one of the service nodes:

~~~~
      xdcp <any service node> /install/postscripts/setupnfsv4replication /install-gpfs/postscripts/
~~~~


    Note: If you have already migrated to the shared /install directory on your service, the target directory would be /install/postscripts instead.

The following example assumes you are using a 'compute' nodegroup entry in your xCAT postscripts table.

~~~~
    chdef -t group compute -p postscripts=setupnfsv4replication
~~~~


  * Set primary and backup SNs in node definition.

The "servicenode" attribute values must be the names of the service nodes as they are known by the EMS. The "xcatmaster" attribute value must be the name of the primary server as known by the nodes.

~~~~
    chdef -t node -o <SNgroupname> servicenode=<primarySN>,<backupSN>  xcatmaster=<nodeprimarySN>
~~~~


#### **Shut down the cluster nodes**

In the following example, "compute" is the name of an xCAT node group containing all the cluster compute nodes.

~~~~
    xdsh compute "/usr/sbin/shutdown -F &"
~~~~


#### **Remove the NIM client definitions from the SNs**

The following command will remove all the NIM client definitions from both primary and backup service nodes. See the [rmdsklsnode](http://xcat.sourceforge.net/man1/rmdsklsnode.1.html) man page for additonal details.

~~~~
    rmdsklsnode -V -f compute
~~~~


#### **Remove NIM resources from the SNs**

The existing NIM resources need to be removed on each service node. (With the original /install filesystem still in place.)

In the following example, "service" is the name of the xCAT node group containing all the xCAT service nodes, and "&lt;osimagename&gt;" should be substituted with the actual name of an xCAT osimage object.


~~~~
    rmnimimage -V -f -d -s service <osimagename>
~~~~


See [rmnimimage](http://xcat.sourceforge.net/man1/rmnimimage.1.html) for additional details.

When this command is complete it would be good to check the service nodes to make sure there are no other NIM resources still defined. For each service node (or from EMS with 'xdsh service'), run **lsnim** to list whatever NIM resources may be remaining. Remove any random resources that are no longer needed (you should NOT remove basic NIM resources such as master, network, etc.)

#### **Clean up the NFS exports**

On each service node, clean up the NFS exports.



  1. Edit /etc/exports and remove all entries related to /install. The xCAT **mkdsklsnode** command will create new entries for NFSv4 replication when it is run later in this process.
  2. If your statelite persistent directory will not be located in the shared /install GPFS filesystem (we strongly recommend that it IS located in shared /install), edit /etc/exports and add an NFSv4 entry specifying the correct replica server.
  3. Re-do the exports

~~~~
    exportfs -ua
    exportfs -a  (if there are any entries left in /etc/exports)
~~~~


#### **Migrate statelite and other data**

Use **rsync** to copy all the persistent data from your current statelite directory, and all other data from your /install directory that may have changed since the initial copy. Even if you did take an initial copy earlier in the process, you will want to do this again now to pick up any changes that have been written since then. You should run this rsync from one SN at a time to copy data into the shared /install-gpfs filesystem. Especially for statelite data, this will ensure that if you happen to have more than one SN that has a subdirectory for the same compute node, you will not run into collisions copying from multiple SNs at the same time. Make sure to use the **rsync -u** (update) option to ensure stale data from an older SN does not overwrite the data from an active SN.




#### **Switch to shared GPFS /install directory**

On each service node, deactivate (in whatever way you choose: rename, overmount, etc.) the local /install filesystem. Change your GPFS cluster configuration so the mount point for your shared GPFS /install-gpfs filesystem is switched to /install. Depending on how the old local /install filesystem was originally created, this may also require updates to /etc/filesystems.

#### **Additional SN software updates**

If you postponed updating software on your service nodes because of required reboots, you should apply that software now and reboot the SNs.

After the SNs come back up, make sure that the admin GPFS cluster is running and NFS has started correctly.

#### **Run mkdsklsnode**

Make sure /etc/exports on service nodes do not contain any old entries. If so, remove, and run:

~~~~
    exportfs -ua
~~~~


When using a shared file system across the SNs you must run the [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html) command on the backup SNs first and then run it for the primary SNs.

This is necessary since there are some install-related files that are server-specific. The server that is configured last is the one the node will boot from first.

**NOTE:** When running mkdsklsnode you may, in certain cases, see the following error:

    Error: there is already one directory named "", but the entry in litefile table is set to one file, please check it
    Error: Could not complete the statelite setup.
    Error: Could not update the SPOT


If you see this error simply re-run the command.

##### mkdsklsnode for backup SNs

~~~~
    mkdsklsnode -V -S -b -i <osimage name>  <noderange>
~~~~


Use the -S flag to setup the NFSv4 replication settings on the SNs.

**Note**: Once you are sure that the "mkdsklnsode -S" option has been run for each service node in the cluster it is no longer necessary to include the "-S" option in subsequent calls to **mkdsklsnode**. (Although it will not cause any problems if you do.)

Also, be aware that the first time you run **mkdsklsnode**, it will take a while to copy all of the resources down to your service node shared /install directory. **mkdsklsnode** uses the **rsync** command, so after the initial copy, subsequent updates should be much quicker.

If you are using a dump resource you can specify the dump type to be collected from the client. The values are "selective", "full", and "none". If the configdump attribute is set to "full" or "selective" the client will automatically be configured to dump to an iSCSI target device. The "selective" memory dump will avoid dumping user data. The "full" memory dump will dump all the memory of the client partition. Selective and full memory dumps will be stored in subdirectory of the dump resource allocated to the client. This attribute is saved in the xCAT osimage definition.

For example:

~~~~
    mkdsklsnode -V -S -b -i <osimage name>  <noderange> configdump=selective
~~~~


To verify the setup on the SNs you could use **xdsh** to run the **lsnim** command on the SNs.

To check for the resource and node definitions you could run:

~~~~
    xdsh <SN name> "lsnim"
~~~~


To get the details of the NIM client definition you could run"

~~~~
    xdsh <SN name> "lsnim"
~~~~


##### **mkdsklsnode for primary SNs**

To set up the primary service nodes run the same command you just ran on the backup SNs only use the "-p" option instead of the "-b" option.

~~~~
    mkdsklsnode -V -S -p -k -i <osimage name>  <noderange>
~~~~


Note the use of the '-k' flag. By default, the mkdsklsnode command will run the NIM sync_roots operation on the xCAT management node to sync the shared_root resource with any changes that may have been made to the spot. If you KNOW you have not made any image changes since your last mkdsklsnode run, you can skip this step (and save yourself several minutes) by using the '-k' flag.

#### **Verify the NFSv4 replication setup**

Verify the NFSv4 replication is exported correctly for your service node pairs:

~~~~
    xdsh service cat /etc/exports | xcoll


    ====================================
    c250f10c12ap01
    ====================================
    /install -replicas=/install@20.10.12.1:/install@20.10.12.17,vers=4,rw,noauto,root=*
    ====================================
    c250f10c12ap17
    ====================================
    /install -replicas=/install@20.10.12.17:/install@20.10.12.1,vers=4,rw,noauto,root=*

~~~~

#### **Boot nodes**

~~~~
    rbootseq compute hfi
    rpower compute on
~~~~


#### **Verify node setup and function**

If you specified a dump resource you can check if the primary dump device has been set on the node by running:

~~~~
    xdsh <node> "sysdumpdev"
~~~~


Verify the NFSv4 replication is configured correctly your nodes:

~~~~
    xdsh compute,storage nfs4cl showfs | xcoll
~~~~


~~~~
    xdsh compute,storage nfs4cl showfs /usr
~~~~


Depending on your network load, you may actually see some nodes using the NFS server from their backup service node. This is acceptable. If you see too much random activity, and would like to tune the failover to be more tolerant of heavy network traffic, you can modify the values in the xCAT setupnfsv4replication postscript as previously described in [XCAT_HASN_with_GPFS/#Update_xCAT_node_definitions](XCAT_HASN_with_GPFS/#Update_xCAT_node_definitions).


If you want to test your NFSv4 client replication failover, here is a simple procedure to stop the nfsd daemon on one service node and watch the nodes switch over to using NFS from their backup service node:

     s1 = service node 1
     s2 = service node 2
     c1 = all compute nodes managed by s1, backup s2
     c2 = all compute nodes managed by s2, backup s1

~~~~
    xdsh c1,c2 nfs4cl showfs | xcoll
~~~~


should show c1 filesystems served by s1 and c2 filesystems served by s2

~~~~
    xdsh s1 stopsrc -s nfsd
    xdsh c1,c2 ls /usr | xcoll
    xdsh c1,c2 nfs4cl showfs | xcoll
~~~~


should show all nodes getting /usr from s2 now (depending on NFS caching, it may take additional activity on the c1 nodes to have all filesystems failover to s2)

**TESTING NOTE** At this point, you can restart NFS on s1. You can continue testing by  shutting down NFS on s2 and watching all nodes failover to s1. Once NFS is back up on both service nodes, over time, the clients should eventually switch back to using their primary server.

### SN failover process

#### **Discover a primary SN failure**

[Monitor_and_Recover_Service_Nodes]

#### **Move nodes to the backup SN**

The nodes will continue running after the primary service node goes down, however, you should move the nodes to the backup SN as soon as possible.

Use the xCAT [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) command to move a set of nodes to the backup service node.

**Note**: Since we have already run **mkdsklsnode** on the backup SN we know that the NIM resources have been defined and nodes initialized.

In the case where a primary SN fails you can run the **snmove** command with the node group you created for this SN. For example, if the name of the node group is "SN27group" then you could run the following command:

~~~~
    snmove -V SN27group
~~~~

You can also specify scripts to be run on the nodes by using the "-P" option.

~~~~
    snmove -V SN27group -P myscript
~~~~


(Make sure the script has benn added to the /install/postscripts directory and that it has the correct permissions.)

#### **Verify the move**

The **snmove** command performs several steps to both keep the nodes running and to prepare the backup service node for the next time the nodes need to be booted.

This includes the following:

  1. Update the "servicenode" and "xcatmaster" attributes in xCAT node definitions.
  2. Update the xCAT statelite tables in the case where the failed SN is specifically mentioned.
  3. Re-do the xCAT statelite files and copy them to the new SN. (These files are used internally by xCAT and will be needed for when the nodes are next booted.)
  4. Restores server-specific system configuration files to the .client_data directory in the shared_root resource. These are files that NIM will used the next time the node is booted. [(TBD-insert_description_of_client_data_files.)]
  5. Re-target the primary dump device on the nodes to the new SN, if a dump resource has been allocated. This means that future system dumps will go to the new SN.
  6. Update the /etc/xcatinfo file on the nodes to point to the new SN.
  7. Update the default gateway on the nodes if set to the old SN.
  8. Run specified scripts on the nodes. (See the man page for details.)

You can verify some of these steps by running the following commands.

  * Check if the node definitions have been modified:

~~~~

    lsdef <noderange> -i servicenode,xcatmaster -c | xcoll

~~~~

  * Check the primary dump device on the nodes.

~~~~
    xdsh <noderange> "/bin/sysdumpdev"
~~~~


Make sure the primary dump device has been reset.

  * Check the default gateway.

~~~~
    xdsh <noderange> "/bin/netstat -rn"
~~~~


  * Check the contents of the /etc/xcatinfo file.

~~~~
    xdsh <noderange> "/bin/cat /etc/xcatinfo"
~~~~


See if the server is the name of the new SN.

#### **Reboot nodes - (optional)**

The nodes should continue running after the primary SN goes down, however, it is adviseable to reboot the node at soon as possible.

When the nodes are rebooted they will automatically boot from the new SN.

~~~~
    xdsh compute "shutdown -F &"
    rpower compute on**
~~~~


### _Diagnostic hints and tips

During development and testing of this support, we have gathered some diagnostic hints and tips that may help you if you are experiencing problems in configuring or executing the support described in this document:

  * During diskless node boot, if the node hangs with LED values of 610 or 611, that usually indicates there is a problem mounting the NFS filesystems correctly. Some things to check:



  * Your NFS daemons are running correctly on the service nodes
  * Your GPFS admin cluster managing the /install directory is operational
  * You have set the xCAT site.useNFSv4onAIX to 'yes'
  * Your NIM resources are all defined with nfs_vers=4. Run 'lsnim -a nfs_vers' on the EMS and each service node to verify.
  * Your /etc/exports on the service nodes have specified the correct NFSv4 replica info for the /install filesystem. For example:

~~~~
      /install -noauto,replicas=/install@20.1.1.1:/install@20.1.2.1,vers=4,rw,root=*
~~~~





### Reverting to the primary service node

The process for switching nodes back will depend on what must be done to recover the original service node. Essentially the SN must have all the NIM resources and definitions restored and operations completed before you can use it.

If you are using the xCAT statelite support then you must make sure you have the latest files and directories copied over and that you make any necessary changes to the statelite and/or litetree tables.

If all the configuration is still intact you can simply use the **snmove** command to switch the nodes back.

If the configuration must be restored then you will have to run the **mkdsklsnode** command. This commands will re-configure the SN using the common osimages defined on the xCAT management node.

Remember that this SN would now be considered the backup SN, so when you run **mkdsklsnode** you need to use the "-b" option.

Once the SN is ready you can run the **snmove** command to switch the node definitions to point to it. For example, to move all the nodes in the "SN27group" back to the original SN you could run the following command.

~~~~
    **svmove -V SN27group**
~~~~


The next time you reboot the nodes they will boot from the original SN.

### Working in a HASN environment

#### Removing NIM client definitions

  * Must run **rmdsklsnode** on primary first and then the backup SN.

#### Removing old NIM resources

  * Must run **rmnimimage** for one SN first then run it for the rest.




### Setting up the Teal GPFS monitoring utility node

Because Teal-gpfs monitoring must be in the application GPFS cluster, we must move the teal.gpfs-sn ( will we change this name) off the service node to a utility node that is in the compute node cluster. Since the teal package requires access to the database server, we will also be installing and configuring a new db2driver package that have a minimum DB2 client that can run the required ODBC interface on a diskless node.

#### Software prereqs

You will have to obtain the db2driver code and the required level of the teal.gpfs-sn code from IBM that supports this function. The db2driver code is available at the following location on fix central and is available to anyone holding the HPC DB2 license.

http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm/Information+Management&amp;product=ibm/Information+Management/IBM+Data+Server+Client+Packages&amp;release=9.7.*&amp;platform=All&amp;function=fixId&amp;fixids=*-dsdriver-*FP005&amp;includeSupersedes=0

The following DB2 driver software package was tested and works with the DB2 9.7.4 or 9.7.5 WSER Server code.

~~~~
    v9.7fp5_aix64_dsdriver.tar.gz
~~~~


You will need to obtain the appropriate level of TEAL and GPFS and rsct.core.sensorrm code. The teal.gpfs-sn lpp is required on the node with the corresponding gpfs.base and rsct.core.sensorrm

#### **Setup DB2 Data Server Client code on the EMS**

We will configure the Data Server Client in the /db2client directory on the EMS machine. We will use this setup to update the image for the utility node that will run it.

*** install unzip rpm, if not already available.**

Note the Data Server Client code requires unzip. Make sure it is available before continuing:

    AIX:
     Get unzip from Linux Toolbox, if not already available.

~~~~
     rpm -i unzip-5.51-1.aix5.1.ppc.rpm for diskfull.   For AIX diskless need to add to statelite image.
~~~~



*** Extract the Data Server Client Code on the EMS**

~~~~
     mkdir /db2client
     cd /db2client
     cp ..../v9.7fp5_aix64_dsdriver.tar.gz .
     gunzip v9.7fp5_aix64_dsdriver.tar.gz
     tar -xvf v9.7fp5_aix64_dsdriver.tar
     export PATH=/db2client/dsdriver/bin:$PATH
     export LIBPATH=/db2client/dsdriver/lib:$LIBPATH
~~~~



  * **Setup Data Server Client**


This script will only automatically setup the 64 bit driver. We must manually extract the 32 bit driver.

~~~~
    cd /db2client/dsdriver
    ./installDSdriver
    cd  odbc_cli_driver
    cd odbc_cli_driver/*32
    uncompress *.tar.Z
    tar -xvf *.tar

~~~~

  * **Fix directory and files owner/group**

Note: the package I downloaded had sub-directories not defined with the bin owner/ bin group. To be sure, do the following:

~~~~
     cd /db2client
     chown -R bin *
     chgrp -R bin *

~~~~

***Create shared lib on 32 bit path (AIX)**

~~~~
    cd /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/lib
    ar -x libdb2.a
    mv shr.o libdb2.so
~~~~


#### **Configure DB2 Data Server Client**

The DB2 Data Server Client has several configuration files that must be setup.

##### **db2dsdriver.cfg**

The db2dsdriver.cfg configuration file contains database directory information and client configuration parameters in a human-readable format.

The db2dsdriver.cfg configuration file is a XML file that is based on the db2dsdriver.xsd schema definition file. The db2dsdriver.cfg configuration file contains various keywords and values that can be used to enable various features to a supported database through ODBC, CLI, .NET, OLE DB, PHP, or Ruby applications. The keywords can be associated globally for all database connections, or they can be associated with specific database source name (DSN) or database connection.

~~~~
    cd /db2client/dsdriver/cfg
    cp db2dsdriver.cfg.sample  db2dsdriver.cfg
    chmod 755 db2dsdriver.cfg
    vi db2dsdriver.cfg
~~~~



Here is a sample setup for a node accessing the xcatdb database on the Management Node p7saixmn1.p7sim.com

~~~~
    <configuration>
      <dsncollection>
        <dsn alias="xcatdb" name="xcatdb" host="p7saixmn1.p7sim.com" port="50001"/>
      </dsncollection>
      <databases>
         <database name="xcatdb" host="p7saixmn1.p7sim.com" port="50001">
         </database>
      </databases>
    </configuration>
~~~~


##### **db2cli.ini**

The CLI/ODBC initialization file (db2cli.ini) contains various keywords and values that can be used to configure the behavior of CLI and the applications using it.

The keywords are associated with the database alias name, and affect all CLI and ODBC applications that access the database.

~~~~
    cd /db2client/dsdriver/cfg
    cp db2cli.ini.sample db2cli.ini
    chmod 0600 db2cli.ini
~~~~


Here is a sample db2cli.in file containing information needed to access the xcatdb database, using instance xcatdb and password cluster. Note this file should only be readable by root.

~~~~
    [xcatdb]
    uid=xcatdb
    pwd=cluster

~~~~




For 32 bit, copy the /db2client/dsdriver/cfg files to /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/cfg

~~~~
    cd /db2client/dsdriver/cfg
    cp db2cli.ini /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/cfg
    cp db2dsdriver.cfg /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/cfg
~~~~


##### **Using unixODBC**

The unixODBC files are still needed. The following are sample configurations files that must be created and added to the image (this step comes later). Substitute your database (xcatdb) password in for **db2root** below. The remaining information in the files should be the same.

~~~~
    cat /db2client/odbc.ini
    [xcatdb]
    Driver   = DB2
    DATABASE = xcatdb
~~~~


~~~~
    cat /db2client/odbcinst.ini
    [DB2]
    Description =  DB2 Driver
    Driver   = /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/lib/libdb2.so
    FileUsage = 1
    DontDLClose = 1
    Threading = 0
~~~~


~~~~
    cat /db2client/db2cli.ini
    [xcatdb]
    pwd=db2root
    uid=xcatdb
~~~~


#### **Build the teal-gpfs diskless image**

You will need the following levels to support the teal-gpfs on the utility node.

~~~~
    teal.gpfs-sn (SP5)
    gpfs.base 3.4.0.13 or later
    rsct.core.sensorrm 3.1.2.0 or later
~~~~


We have create a new diskless image for the teal.gpfs-sn utiltity node. Here is a sample Bundle file:

~~~~
    # sample bundle file for teal-gpfs utility node
    I:rpm.rte
    I:openssl.base
    I:openssl.license
    I:openssh.base
    I:openssh.man.en_US
    I:openssh.msg.en_US
    I:gpfs.base
    I:gpfs.gnr
    I:gpfs.msg.en_US
    I:rsct.core.sensorrm
    I:teal.gpfs-sn
    # RPMs
    R:popt*
    R:rsync*
    # using Perl 5.10.1
    R:perl-Net_SSLeay.pm-1.30-3*
    R:perl-IO-Socket-SSL*
    R:unixODBC*
    R:unzip*  (optional) since we are setting up db2driver on the EMS
~~~~


With this additional bundle file, build the diskless image for the teal-gpfs utiltiy node.

##### **Modify image with extra db2driver and odbc config files**

Copy /db2client directory and subdirectories into the image, that were setup on the EMS.

~~~~
    cp -rp /db2client /install/nim/spot/<image name>/usr/lpp/bos/inst_root
~~~~


Copy /db2client/odbc.init into the image.

~~~~
    cp /db2client/odbc.ini /install/nim/spot/<image name>/usr/lpp/bos/inst_root/etc
~~~~


Copy /db2client/odbcinst.ini into the image.

~~~~
    cp /db2client/odbcinst.ini /install/nim/spot/<image name>/usr/lpp/bos/inst_root/etc
~~~~


Copy /db2client/db2cli.ini into the image

~~~~
    cp /db2client/db2cli.ini /install/nim/spot/<image name>/usr/lpp/bos/inst_root
~~~~


Copy /etc/xcat/cfgloc into the image

~~~~
    mkdir /install/nim/spot/<image name>/usr/lpp/bos/inst_root/etc/xcat
    cp /etc/xcat/cfgloc /install/nim/spot/<image name>/usr/lpp/bos/inst_root/etc/xcat
~~~~


#### **Configure Network for IP forwarding**

Configure IP forwarding such that the Utility Node can access the DB2 Server on the EMS.

#### Install the image and test DB connection

After the Utility node boots, test the DB2 setup by running the following, to see if you can connect to the DB2 database on the EMS.

~~~~
    /usr/local/bin/isql -v xcatdb
~~~~

