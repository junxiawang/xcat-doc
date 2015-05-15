<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [TEAL Function](#teal-function)
  - [Setting up TEAL on your xCAT Management Node](#setting-up-teal-on-your-xcat-management-node)
  - [Setting up TEAL GPFS collector nodes (optional)](#setting-up-teal-gpfs-collector-nodes-optional)
  - [TEAL Commands](#teal-commands)
    - [TEAL DB Tables](#teal-db-tables)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

As computing clusters grow larger and larger, the ability to diagnose and inform users of issues in the cluster becomes both more complicated and more important. Specifically, a cluster will generate some number of events, defined as noteworthy happenings, in response to the state of the hardware, systems software, and user jobs. These events need to be processed and analyzed to decide whether an alert needs to be sent to the system administrator, or Service Focal Point, regarding the state of the cluster. In addition, it is crucial to enable manual exploration of events and alerts. 

### TEAL Function

**IBM Toolkit for Event Analysis and Logging (TEAL)**, which will be running on the xCAT management node known as the Executive Management Server (EMS), will have a set of tools and interfaces which provide the ability to do the following general tasks: 

    

  * Gather event data. 
  * Analyze event data. 
  * Generate alerts. 
  * Filter alerts. 
  * Notify system administrators and others who consume and handle alerts. 

This document will provide the minimal steps on how to install the Teal product on your xCAT management node. You will need to make modifications to the processes outlined here to take advantage of advanced LoadLeveler features and to set this up correctly for your environment according to the TEAL documentation. 

These instructions are based on TEAL 1.1.0.0 (TEAL is only supported in xCAT hierarchical clusters at this time). If you are using a different version of TEAL, you may need to make adjustments to the information provided here. 

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster. **Note: the IBM DB2 database is required for Power 775 clusters.**

    

  * Your xCAT EMS is fully installed and configured. 
  * Your xCAT EMS is running with MySQL or DB2 database and ODBC access is correctly configured as TEAL prerequisites. If you do not have it ready, follow the instructions in [Setting_Up_MySQL_as_the_xCAT_DB] or [Setting_Up_DB2_as_the_xCAT_DB]. 

### Setting up TEAL on your xCAT Management Node

Download the Teal dependent rpm pyodbc, perl-Module-Load and teal rpm packages, and place them on your xCAT MN in a directory such as: /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/teal/. 

Then run rpm to install: 
    
     cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/teal
     rpm -Uvh pyodbc*
     rpm -Uvh perl-Module-Load*  (Linux only)
     rpm -Uvh teal*.rpm
    

Currently, TEAL is only supported on Power 755 clusters. TEAL requires xCAT using the DB2 database. xCAT provides instructions to set up TEAL on your xCAT EMS in a Power 755 cluster in the following document: [Setup_for_Power_775_Cluster_on_xCAT_MN/#implementation-with-teal-on-xcat-mn-for-power-775-cluster](Setup_for_Power_775_Cluster_on_xCAT_MN/#implementation-with-teal-on-xcat-mn-for-power-775-cluster) Follow these instructions to set up TEAL on your xCAT management node. 

### Setting up TEAL GPFS collector nodes (optional)

If you want to use the optional TEAL GPFS connector feature, install the teal-base and teal-gpfs packages onto your xCAT management node according to the steps above, then follow the instructions below to set up the xCAT service nodes as the TEAL GPFS connector nodes. The teal-gpfs related rpms/installps are shipped with the TEAL product. 

    

  * [Setting_up_GPFS_in_a_Stateful_Cluster] 
  * [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] 

### TEAL Commands

https://sourceforge.net/apps/mediawiki/pyteal/index.php?title=Command_Reference 

#### TEAL DB Tables

https://sourceforge.net/apps/mediawiki/pyteal/index.php?title=Database_Table_Reference 
