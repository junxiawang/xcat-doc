<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Option 1: Manual Service Node Fail Over and Readonly File Replication](#option-1-manual-service-node-fail-over-and-readonly-file-replication)
  - [Shared Disks](#shared-disks)
  - [Fail Over of Readonly Files](#fail-over-of-readonly-files)
  - [Limitations, Notes and Issues](#limitations-notes-and-issues)
- [Option 2: Service Nodes with GPFS and Shared Disks](#option-2-service-nodes-with-gpfs-and-shared-disks)
  - [Affect on Other Software Components](#affect-on-other-software-components)
  - [Limitations, Notes and Issues](#limitations-notes-and-issues-1)
- [Option 3: External GPFS/CNFS Cluster](#option-3-external-gpfscnfs-cluster)
  - [Limitations, Notes and Issues](#limitations-notes-and-issues-2)
- [Option 4: Service Nodes with Share Disks and Power HA](#option-4-service-nodes-with-share-disks-and-power-ha)
  - [Advantages of using PowerHA](#advantages-of-using-powerha)
  - [Limitations, Notes and Issues](#limitations-notes-and-issues-3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Introduction

AIX diskless nodes depend on their service nodes for many services: bootp, tftp, default gateway, name serving, NTP, etc. The most significant service is NFS to access OS files, statelite data, and paging space. Since providing HA NFS service for a large number of nodes is not trivial, there is a spectrum of solutions that range from partial HA to complete HA. The complexity of setting it up and maintaining it is inversely proportional to the level of HA. So we will give an summary of the choices so you can pick the one that best fits your HA and maintenance goals. They are listed from least HA to most HA. 

## Option 1: Manual Service Node Fail Over and Readonly File Replication

The most basic capability is that xCAT makes it easy to manually move compute nodes to another service node (SN) when their SN fails. Without any other provisions, this means that the compute nodes serviced by the failed SN go down, and they are rebooted when they are moved to the other SN. This is achieved by the following xCAT commands: 

  * The [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html) command will copy NIM resources, the OS image, and statelite files to both the primary SN and secondary SN, so when you move computes nodes to the secondary SN, everything will be there that they need. 
  * Service nodes can be monitored so you can be alerted quickly when they fail. See [Monitor and Recover Service Nodes](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Monitor_and_Recover_Service_Nodes#Monitoring_Service_Nodes). 
  * The [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) command will move the target compute nodes from one SN to another SN, copying the statelite files to the new SN and rebooting the compute nodes in the process. You can also periodically run snmove with the new -l option to just sync the statelite files from one SN to another, in case the primary SN crashes unexpectedly (before you can run snmove). 

See [Setting Up an AIX Hierarchical Cluster](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Setting_Up_an_AIX_Hierarchical_Cluster#Switching_to_a_backup_service_node) for details. NIM should be configured to use NFSv4 by setting the [site table](http://xcat.sourceforge.net/man5/site.5.html) attribute useNFSv4onAIX. This positions the nodes to use nfsv4 client replication fail over when you are ready, and also allows for large (up to 64GB) paging spaces. For additional details about using NFSv4 with NIM, see the [AIX NIM NFSv4 support](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=AIX_NIM_NFSv4_support) mini-design. 

### Shared Disks

As an incremental improvement to this manual approach, the SNs can be FC connected to 2 DS3524 external disks which contains the node images, statelite files, and paging space. This increases the disk capacity of each SN and increases the write performance. The recommended organization and layout of the data on the external disk is: 

  * Each SN has a VG on the external disks, with a unique name that corresponds to the SN node name. For example, the 1st SN's VG would be called xcat1, the 2nd SN's VG would be called xcat2, etc. Each one of the VGs should have **4 LVs/file systems**: 
  * **The 1st LV/file system** will hold the readonly OS image files that are associated with the NIM resources (shared root, /usr, etc.). This should be mirrored and be mounted at /install on the SN. Each SN will have its own (identical) copy of this file system. When mkdsklsnode is run for all of the compute nodes, the NIM resource definitions will be created on the SNs (they are stored in the ODM that is local to each SN), and the associated files will be prsync'd to the SNs. Assuming the same images are used on all of the compute nodes, the contents of /install on all the SNs will be the same. 
  * **The 2nd LV/file system** will hold the readwrite/statelite files for the compute nodes served by this SN: This should be mirrored and named and mounted at a location that relates to the SN name. For example, name/mount the LV on the 1st SN /nodedata1. This will give you the option, in the case of a SN failure, to mount its statelite LV/file system on the SN that is taking over, and not have to copy the statelite data there. (In this case, the snmove command will need a new flag to tell it not to sync the statelite files to the backup SN (because they will already be there.) Each set of compute nodes can be pointed to a different statelite location, by defining groups for each set of nodes served an SN, and then filling in the [statelite](http://xcat.sourceforge.net/man5/statelite.5.html) table with something like: 
    
    #node,image,statemnt,mntopts,comments,disable
    "sn1nodes",,"$noderes.xcatmaster:/nodedata1","soft,timeo=30",,
    "sn2nodes",,"$noderes.xcatmaster:/nodedata2","soft,timeo=30",,

     Using the variable **$noderes.xcatmaster** means the node will mount its statelite files from the correct SN, even if snmove has been used to move the node to another SN. But hardcoding **/nodedata1** for all of the nodes that are originally served by sn1, means that even if those nodes are moved over to sn2, they will still mount their statelite files from /nodedata1 on sn2 (which can be mounted on sn2 from the external disk). 

  * **The 3rd LV/file system** will hold the paging spaces for the compute nodes served by this SN. Each node will have two 64 GB paging files created by a postscript (in addition to the small one created by NIM during boot time). This should **not** be mirrored, to improve write performance, and should be mounted at the same location on each SN. This is because xCAT associates the NIM resource for the paging space with the OS image, not the node. Assuming all of you computes nodes are running the same image, the compute nodes from sn1 will be expecting the paging at the same path as the compute nodes from sn2. Also, it is easiest to mount the paging LV/file system at /install/nim/paging, because mknimimage wants to put all resource files under the same top level directory. These choices also position you well for the next solution using GPFS. The downside of this approach is that until you use GPFS to share a single paging file system, each SN has to allocate enough paging space on its own LV/file system for its own compute nodes plus nodes that can be failed over to it. This means you need to allocate 2 * n * p amount of paging space, where n is the number of SNs and p is the amount of paging space 1 set of compute nodes needs. This amount could be reduced to (n+1) * p, by leaving unallocated on the shared disk physical partitions equal to p and then when a SN fails, assigning those unallocated physical partitions to the SN that takes over for it. 
  * **The 4th LV/file system** will hold the dump targets for the compute nodes served by this SN. This should **not** be mirrored, to improve write performance, and should be mounted at the same location on each SN (for example, /install/nim/dump). 

At a high level, the recommended steps to set up the SNs with external disks in this way are: 

  * Before connecting the SNs to the external disks, install the SNs from the EMS using xCAT. (We want the OS of the SN to be on its local/internal disks. We are investigating how to tell NIM to avoid all of the external disks, even if they are attached.) 
  * Remove the /install file system that xCAT created on the local disk. 
  * Connect the external disks to the SNs via fiber channel. Verify the SNs can see them using the lspv command. 
  * On each SN create the VG and 3 LV/file systems as described above (/install, /nodedata1, /paging1). 
  * Set up the statelite table and NIM paging resources to point to these file systems. 
  * Create/customize the [postscript](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Postscripts_and_Prescripts) that creates the two 64 GB paging spaces to create them in the correct file system: 
    * Use "mkps -t nfs $MASTER &lt;file&gt;" to create the paging spaces 
    * The $MASTER environment variable is set by xCAT to be the node's SN. 
    * The postscript should set the file name appropriately, based on the node's name ($NODE). 
  * Run "updatenode -P" for all SNs to run the postscript. 

When, for example, sn1 fails, and you want to move its compute nodes to sn2: 

  * On sn2, run "varyonvg xcat1" to get access to its file systems. 
  * Mount /nodedata1 from the xcat1 VG. 
  * Run "snmove -s sn1 -d sn2" to move the nodes over to sn2. 
  * Boot the nodes. 

### Fail Over of Readonly Files

As another incremental improvement to this manual approach, the readonly OS files (STNFS and the /usr file system) can be easily failed over to the secondary SN in real time using nfsv4 replication. Since mkdsklsnode has already copied the OS image to both SNs, and it is not changed by compute nodes, the nfsv4 client fail over is sufficient to allow the compute nodes to keep accessing the OS files. This can be configured automatically by mkdsklsnode by adding the --setuphanfs flag to it. 

### Limitations, Notes and Issues

In this approach, neither the statelite files or the paging space is failed over in real time. If the paging space is currently not being used (i.e. you haven't exhausted real memory on the compute nodes), the nodes can continue to run even though the nfs server for the paging space (the primary SN) is not available. The effect of the statelite files not failing over in real time depends on what you define as statelite files for your compute nodes. If they are just a few simple log files, you have the option to tell xCAT to mount the statelite files with the soft option, which will cause the writes to fail when the primary SN goes down, but not hang those processes in the compute nodes. 

Note: there is currently a question about whether AIX writes to the paging space even before real memory is exhausted. There are apparently several complex conditions in which AIX will write to paging space before real memory is fully used up. This is being investigated. 

## Option 2: Service Nodes with GPFS and Shared Disks

In this approach, the SNs are all FC connected to 2 DS3524 external disks which contains the node images, statelite files, and paging space. The file systems containing this data are mounted on the SNs. The statelite files are in a GPFS file system and GPFS coordinates all updates to it from each SN. From the nodes, both readonly and statelite files are failed over using the NFSv4 client replication fail over feature. 

In this approach, it is best to also have the EMS connected to the external disks, so that it can write image files directly into /install on the external disks. (Although this is not an absolute requirement.) Then mkdsklsnode doesn't have to copy the OS files to any of the SNs, since they will already be on the external disks for all SNs to see. (Use the new -d mkdsklsnode flag for this.) mkdsklsnode still has to create the NIM resources on each SN (because NIM definitions are stored in the ODM and not in /install). It is not necessary to sync the statelite files between SNs, because they all see the same copy of them. The client is configured for NFSv4 client fail over using the mkdsklsnode --setuphanfs flag and the setupnfsv4replication postscript. For more details about this approach, see the [HA NFS on AIX service nodes](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=HA_NFS_on_AIX_service_nodes) mini-design. Some additional information can be found in the [HA Service Nodes for AIX](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=HA_Service_Nodes_for_AIX) mini-design. 

The layout of the file systems on the external disks will be similar to what is described in the previous section, but with the following differences: 

  * There only needs to be one copy of the /install file system (not one per SN). This file system will be written by the EMS and read by all the SNs. 
  * There only needs to be one file system for the statelite persistent files. So instead of having /nodedata1, /nodedata2, etc., there can be a single file system /nodedata (or if you want to keep it in the /install file system, /install/nodedata) that has a subdirectory for each node. This way you don't need a separate entry in the statelite table for each SN's set of nodes. Instead, the statelite table can look like this: 
    
    #node,image,statemnt,mntopts,comments,disable
    "sn1nodes",,"$noderes.xcatmaster:/nodedata",,,

  * The paging spaces and dump files can be under /install (like described in the previous section), for example /install/nim/paging and /install/nim/dump, respectively. But the difference from the previous section is that you only have 1 copy of these directories that are shared by all SNs, instead of a separate copy for each SN. These directories should configured in GPFS to not mirror them, for performance reasons. 

### Affect on Other Software Components

There are a few components that normally run on the service nodes that under certain circumstances need access to the application GPFS cluster. Since a node can't be (directly) in 2 GPFS clusters at once, some changes in the placement or configuration of these components must be made, now that the SNs are in their own GPFS cluster. The components that can be affected by this are: 

  * LL schedd daemons - need to store the spool files in a common file system. This could be the SN GPFS cluster if all the schedd's run on the SNs. But the schedd's normally need a file system that is common with the compute nodes where the application executables are stored. If you want this in GPFS, it has to be in the application GPFS cluster. Also, if you use C/R, it needs access to the application GPFS cluster. 
  * LL central mgr, regional mgr, and schedd's - need access to the database if using the database option for LL. The following LL features need the database option: rolling updates, C/R, and the future energy aware scheduling feature 
  * TEAL GPFS monitoring - needs to run on the GPFS monitoring collector node of the application GPFS cluster and needs access to the database 

There are a few different ways to satisfy these requirements: 

  1. Run LL with the traditional config files, not the database option. If you don't need any of the LL features that require the DB option (listed above), then you can run the central mgr, resource mgr, regional mgrs, and schedd's on other utility nodes, not the SNs. If you want TEAL GPFS monitoring, you still need to find a place for that, which means you have to set up another utility lpar that is part of the application GPFS cluster and has a disk so it can have the db2 client on it, or run with the new DB2 lite client that can run diskless. Either way, the utility node needs to contact the EMS, so it either needs an ethernet adapter in it, or routing has to be set up through the SNs. 
  2. If you are not using C/R and you don't need more schedd's than the number of SNs, you can run your LL daemons on the SNs. In this option, you also need a different common file system between the SNs and computer nodes for the application executables to be stored. You still have the same issue with the TEAL GPFS monitoring. 

### Limitations, Notes and Issues

  * There is a problem in NIM in which it won't allow a SPOT to be created in a GPFS files system (a SPOT created elsewhere can be copied into GPFS). This means for now the EMS can't use the GPFS shared file system as /install - only the SNs can share it. There is a hack that the AIX team gave us to work around this for now, but we will need a real fix. 
  * The NIM dskl_init command can't be run on both the primary &amp; backup SN when they share /install (only the primary). So we have to wait and run dskl_init on the backup at snmove time. 
  * Retargetting the dump resource after the fail over is still being explored. 
  * By default, NIM resources won't store their associated files in gpfs (only jsf or jsf2). xCAT will have to make a code change to set the environment variable "NIM_ATTR_FORCE=yes" to enable storing in gpfs. This works for all NIM resources &lt;s&gt;except during "nim -o update"&lt;/s&gt;(have not been able to recreate the "nim -o update" error -- seems to work). For now, this can be worked around manually, but is another thing AIX has to fix. 
  * The SN shutdown order has to be changed to shutdown the NFS server before GPFS, so that NFS doesn't keep trying to serve files backed by GPFS. 
  * An ifix has been provided by AIX to not lose NFS data during a fail over. 
  * Two STNFS fixes have been provided by AIX to fix bugs with continued access to the shared_root filesystem after NFS failover. 
  * When /install is shared between the SNs, and optionally the MN, we have to be careful during mkdsklsnode about 2 SNs writing to the same files. Before xcat code changes to handle this, the work around is to only run mkdsklsnode to 1 SN at a time (with -p so it won't even do it to the backup). We will make code changes in xcat 2.7 (including a new site attribute "sharedinstall") to handle this automatically. 
  * In this approach, the paging space is currently not failed over in real time, because it currently doesn't support nfsv4 client replication fail over. If paging space really isn't used, then this can be an acceptable limitation. (See paging space notes above.) 
  * Note: there is currently an issue with using NFSv4 replication client fail over for readwrite files, even when GPFS is ensuring that the files are the same regardless of which SN the are accessed from. A small timing window exists in which the client sends a request to update a file and the server updates it, but before it sends the acknowledgement to the client, the server crashes. When the client fails over to the other server (which has the updated file thanks to GPFS) and resends the update request, the client will detect that the modification time the client and server think the file has are different and bail out, marking the file "dead" until the client closes and reopens the file. This is a precaution, because the NFS client has no way of verifying that this is the exact same file that it updated on the other server. AIX development is sizing a configuration option in which we could tell it not to mark the file dead in this case because GPFS is ensuring the consistency of the files between the servers. 
  * Currently, paging space can't be stored in GPFS directly (without going through NFS). Although AIX could probably support this via the "-t ps_helper psname" flag, the GPFS client would have to have all of its memory pinned (so it could never be swapped out). Currently, GPFS doesn't support that. 
  * Proof-of-concept testing with xCAT 2.7 has completed. See [XCAT_HASN_with_GPFS] draft documentation for using xCAT with this setup. 

## Option 3: External GPFS/CNFS Cluster

With this approach, a separate set of 3 linux svrs are set up with GPFS/CNFS to provide a HA NFS service. Redundant routing is set up from the HFI network, through the SNs, to the LAN the CNFS service is on, using AIX's dead gateway detection capability. The xCAT SNs network boot the compute nodes, pointing them to the CNFS service. (The admin sets the noderes.nfsserver attribute for the compute nodes.) From the nodes, both readonly and statelite files are always available w/o the need of the NFSv4 client replication feature. 

A few extra steps are needed when copying new images to the SNs to get the OS, statelite, and paging files on the CNFS server. See [External NFS Server Support With AIX Stateless And Statelite](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=External_NFS_Server_Support_With_AIX_Stateless_And_Statelite) for details. Some additional information can be found in the [HA Service Nodes for AIX - using External NFS Server](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=HA_Service_Nodes_for_AIX_-_using_External_NFS_Server) mini-design. 

### Limitations, Notes and Issues

Note: currently AIX paging space only supports nfsv2 or nfsv4, whereas CNFS only supports nfsv2 or nfsv3. That only leaves nfsv2 in common and that has a limit on the file system size of 2 GB, which is not big enough for paging space. This means that to store your AIX paging in CNFS, you'll have to create multiple paging spaces. NIM will create one during node boot, then you can add more using the mkps command in a postscript. 

## Option 4: Service Nodes with Share Disks and Power HA

In this approach, the SNs are FC attached to 2 DS3524 external disks and are all configured in a [Power HA](http://www-03.ibm.com/systems/power/software/availability/) cluster. Power HA (version 7.1.1) will provide takeover function for all 3 categories of NFS: readonly OS image files, readwrite statelite persistent files, and paging space files. The HA NFS component of Power HA will be used. This helps with configuring the resource groups more easily. For the admin, it is mostly a process of stating the file systems to export. Mutual takeover can be used so that all service nodes can be active (i.e. no cold standy SNs needed). NFS v4 will be used for its improved security and recovery as compared to NFSv2/3. Through Power HA's IP take-over and handling of NFS locks and dup cache, the fail over is transparent to the NFS clients, except for a delay during the fail over. 

Some Power HA documentation for further details: 

  * http://publib.boulder.ibm.com/infocenter/aix/v7r1/topic/com.ibm.aix.powerha.navigation/powerha_pdf.htm 
  * http://www.redbooks.ibm.com/redbooks/pdfs/sg247845.pdf 
  * http://publib.boulder.ibm.com/infocenter/aix/v7r1/topic/com.ibm.aix.clusteraware/clusteraware_pdf.pdf 
  * http://publib.boulder.ibm.com/infocenter/aix/v7r1/index.jsp?topic=%2Fcom.ibm.aix.powerha.plangd%2Fha_plan_shared_lvm.htm 

The following is old but has good information. It does not match the current interface. 

  * http://www.ibm.com/developerworks/aix/library/au-powerhaintro/index.html?ca=dgr-lnxw06POWER-HACMPdth-AIX 

  


The LV/file system layout on the external disks will be similar to what is described in the Manual Service Node Fail Over section, with a few differences: 

  * Each SN will have its own copy of the OS image files, mounted at /install. Since each SN's copy of /install is identical, this file system does **not** need to be failed over to the other SN by Power HA. 
  * The statelite persistent files will be the same: a SN-specific name for each SN, for example /nodedata1 or /install/nodedata1. This file system needs to be failed over to the new SN. 
  * The paging file system is a little more difficult, because it has to be failed over to the new SN, so it should have a SN-specific name like /install/nim/paging1 (so it doesn't go on top of the paging space already on the new SN). But currently xCAT configures the paging space to be in the same path for all nodes that use the same OS image. But a way around this is for the postscript that is creating the 64 GB paging spaces to put them in a directory specific to the SN (e.g. /install/nim/paging1) and then remove the paging space that NIM created in the common location, e.g. /install/nim/paging. The /install/nim/paging1 file system needs to be failed over by Power HA. 
  * For the dump location, you can use a non-SN-specific location (e.g. /install/nim/dump) if you don't need to have Power HA to fail it over, because you don't need to support a compute node successfully failing over while it is dumping. If you do need to support that, then you need to play some naming games like you did for paging. 

This solution is still being investigated. 

### Advantages of using PowerHA

  * PowerHA is a proven solution to provide high availability services for the system p and AIX configuration. 
  * PowerHA provides availability enhancements to NFS, including the nfs locking support. 

### Limitations, Notes and Issues

  * **Failover time**: typical NFS failover with PowerHA may take 1-5 minutes. The failover will perform a lot of activities like umount shared disks, mount shared disks, varyon VGs, exportfs, restart nfs service, etc. Even if the configuration is simple enough and we do performance tuning very carefully, the failover time will not be less than 1-2 minutes. The diskless clients may not be able to survive for such a long time period, although with hard mounts the NFS clients should keep retrying indefinitely. 
  * **Configuration complexity**: The IBM HPC organization is not familiar with the PowerHA configuration. The field team told us that a typical PowerHA deployment for a customer production system may take 3 or 4 days. Supposedly, the HA NFS component is easier to configure because it defines the resource groups for you. The xCAT service node is a fairly well-defined environment, so we may be able to provide instructions that streamline the Power HA/HA NFS configuration. This depends on how many conflicts there are between Power HA and xCAT/NIM (see below). 
  * Will there be a conflict between xCAT, NIM, and PowerHA with exports?? When creating NIM resources on the SNs, NIM generally wants to export associated files. But Power HA wants to controls all of the exports. But NIM has a feature where if a directory above the directory they just allocated is already exported NIM won't try to export it. So this should allow Power HA to control the exports. There may be other conflicts between xCAT/NIM and Power HA. This is being investigated. 
  * xCAT currently doesn't have any function to help in setting up a Power HA cluster, but we will probably provide a short writeup with some suggestions on how to configure Power HA for this specific environment. 
