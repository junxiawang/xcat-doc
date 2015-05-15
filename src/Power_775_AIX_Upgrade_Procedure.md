<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Step A: (Prep Work)](#step-a-prep-work)
  - [On the Backup EMS](#on-the-backup-ems)
  - [On the Primary EMS](#on-the-primary-ems)
- [Step B: U**pdate All Service Nodes (Maintenance window #1)**](#step-b-update-all-service-nodes-maintenance-window-#1)
- [**Step C: Build and distribute new images**](#step-c-build-and-distribute-new-images)
- [**Step D: Reboot Cluster (Maintenance window #2)**](#step-d-reboot-cluster-maintenance-window-#2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Introduction

This documentation describes a process for upgrading the software and firmware on a AIX Power775 Cluster. 

## Step A: (Prep Work)

  1. Create a mksysb of the EMS ( Primary/Backup) create a mksysb for the Service Nodes. This will allow you to quickly revert to your previous Cluster level. Put these mysysb images on a backup file system. Backup your database if you do not have a recent backup. If there is any important data that is not on rootvg and shared disks, make a backup for the data also.I recommend using the new binary process for dumpxCATdb/restorexCATdb.
See doc:[Setting_Up_DB2_as_the_xCAT_DB/#backuprestore-the-database-with-db2-commands](Setting_Up_DB2_as_the_xCAT_DB/#backuprestore-the-database-with-db2-commands).



### On the Backup EMS

  1. On the Backup EMS, start the local DB2 database. su - xcatdb , db2start. 
  2. In the following order, update new software: DB2, xCAT, DFM, LL, ISNM.hdwr_svr, TEAL, and then AIX. The shared disk on the backup EMS should not be mounted during the software upgrade. After software upgrade, make sure xCAT,LL, ISNM.hdwr_svr , TEAL daemons are stopped, and finally db2stop the database. 
    * Note: You may delay upgrade of ISNM.hdwr_svr to be at the same time as the upgrade of ISNM.cnm below. But the DFM and xCAT software must be upgraded at the same time. 
  3. Reboot the Backup EMS. No daemons for xCAT, LL, HDWR_SVR, TEAL should be running. The database should also not be running. If it is, run: su - xcatdb; db2stop . 

### On the Primary EMS

  1. On the Primary EMS, in the following order, update the software for: DB2, xCAT, DFM, LL, TEAL, AIX . You usually can upgrade ISNM.hdw_svr but not ISNM.cnm package since the ISNM.cnm software may sync with CEC firmware. 
    * If LL is configured using the database option, after updating LL, run: perl `which lldbupdate` 
    * You can reference the following documentation for LL, TEAL, and ISNM: 
      * LoadLeveler documentation: [Tivoli Workload Scheduler LoadLeveler library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html)
      * TEAL information: https://sourceforge.net/apps/mediawiki/pyteal/index.php?title=Main_Page 
      * ISNM configuration from P775 Guide: http://www.ibm.com/developerworks/wikis/download/attachments/162267485/p775_planning_installation_guide.rev1.2.pdf?version=1 
  2. Reboot Primary EMS. This scenario has to be reviewed when running LL with Database. If we need to update the DB2 software,it requires stopping all daemons that access the database, which causes LL on xCAT SN to be stopped. 
  3. Update xCAT on All Service Nodes following this process:
[Updating_AIX_Software_on_xCAT_Nodes/#upgrading-xcat-on-service-nodes](Updating_AIX_Software_on_xCAT_Nodes/#upgrading-xcat-on-service-nodes).
Do not use the instxcat script, since it is only used for the EMS only!
  4. If using multibos support - prep the alternate BOS on the Service Nodes here (do not update the hfi driver)http://publib.boulder.ibm.com/infocenter/pseries/v5r3/topic/com.ibm.aix.install/doc/insgdrf/multibosutility.htm?resultof=%22%6d%75%6c%74%69%62%6f%73%22%20 

## Step B: U**pdate All Service Nodes (Maintenance window #1)**

  * **Option 1:** Using updatenode 
  1. Shutdown the compute nodes. 
  2. Stop xcatd on the Service Node ( only required if DB2 upgrade). 
  3. From the Primary EMS, update software using (updatenode or xdsh)for DB2, LL, AIX (no new hfi driver)software on the Service Nodes in that order. 
  4. Follow the DB2 upgrade on SN process:
[Setting_Up_DB2_as_the_xCAT_DB/#appendix-binstalling-db2-fix-packs](Setting_Up_DB2_as_the_xCAT_DB/#appendix-binstalling-db2-fix-packs).
  5. Reboot the Service Nodes 
  6. Start LL on the service node (using xdsh &lt;service node&gt; llctl start) 
  7. Bring up the compute nodes, if you shut them down in step 2. 
  8. Start LL on the compute nodes ( using xdsh &lt;group&gt; llrctl start). 
  * **Option 2:** Using multibos - 
  1. Shutdown the compute nodes. 
  2. Reboot the Service Nodes to the alternate bos. 
  3. Start LL on the service nodes (using xdsh &lt;service node&gt; llctl start) 
  4. Bring up the compute nodes, if you shut them down in step 2. 
  5. Start LL on the compute nodes ( using xdsh &lt;group&gt; llrctl start). 

## **Step C: Build and distribute new images**

**Note:** Between the maintenance windows - jobs can be running during this time, if you want. 

  1. Add new hfi drivers to lpp source on the EMS for images. 
  2. Build all new images (mknimimage) for nodes. 
  3. Run mkdsklsnode -n on the EMS for all Compute Nodes 

## **Step D: Reboot Cluster (Maintenance window #2)**

  1. Prepare your Frame and CEC firmware for upgrade. You may look to use the Deferred firmware option. 
    * Follow the instructions found in [XCAT_Power_775_Hardware_Management/#updating-the-bpa-and-fsp-firmware-using-xcat-dfm](XCAT_Power_775_Hardware_Management/#updating-the-bpa-and-fsp-firmware-using-xcat-dfm).
  2. Upgrade ISNM.cnm and ISNM.hdwr_svr, if not already upgraded, on both the Primary EMS and Backup EMS 
  3. Run updatenode to update latest hfi drivers on the xCAT Service Nodes. 
  4. At this time you can complete the firmware updates for Frame and CECs. This requires shutting down the P775 cluster for compute nodes, login nodes, GPFS I/O server, and xCAT SN nodes, and then bringing it all back up. 
    1. You will need to power down the CECs, complete the firmware updates, and initialize ISNM on EMS and CECs. 
    2. You can then power on the CECs, where xCAT SNs are available. 
    3. Make sure to bringup the GPFS I/O servers, and then login nodes, compute nodes, with the new HPC diskless images. 
    4. Verify that LL is enabled, and that the nodes are available and run test jobs. 
