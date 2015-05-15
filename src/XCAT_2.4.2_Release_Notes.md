<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.4.2 Since 2.4.1](#new-function-in-242-since-241)
- [Bugs Fixed in 2.4.2](#bugs-fixed-in-242)
- [Known Issues and Work Around](#known-issues-and-work-around)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.4.1 release. Also see the [XCAT_2.4.1_Release_Notes]. 

## New Function in 2.4.2 Since 2.4.1

  * xCAT integration support for the IBM HPC software stack with the new optional xCAT-IBMhpc rpm. See [Setting_up_the_IBM_HPC_Stack_in_an_xCAT_Cluster]. 
  * chvm to manipulate storage/processor/memory parameters of VMWare guests 
  * rmigrate -f support to perform offline migration of VMWare guests from dead hypervisors 
  * rsetboot -p flag for IPMI devices to request persistence where supported 
  * bmcsetup may now auto-detect lan channels for wider IPMI hardware support 
  * Enhanced IBM ToolsCenter/ASU support 
  * statelite - The directory and its sub-items can be put into the litefile table 

## Bugs Fixed in 2.4.2

  * 2.3 Stateless image compatibility was addressed 
  * Fix yaboot in SLES11 POWER installations 
  * Detection of SLES11/SP1 media is fixed 

Many bugs were fixed in 2.4.2. For details see the [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945), or check the subversion commit history for the 2.4 branch for 5/1 - 5/20. 

## Known Issues and Work Around

  * Problem with getmacs on PS701/702 

The getmacs command does NOT work correctly. 

For PS701, user can display the MAC address by rinv command, then select the correct mac address and set to attribute mac.mac for installation. 

For PS702, user need to get the MAC address from SMS interface or from ARP table if the machine is in up state, then select the correct mac address and set to attribute mac.mac for installation. 
