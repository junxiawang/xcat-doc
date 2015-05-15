<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.4.1 Since 2.4](#new-function-in-241-since-24)
- [Bugs Fixed in 2.4.1](#bugs-fixed-in-241)
- [Known Issues and Work Around](#known-issues-and-work-around)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.4 release. Also see the [XCAT_2.4_Release_Notes]. 

## New Function in 2.4.1 Since 2.4

  * Added the site.auditskipcmds attribute to specify xcat commands that should not be logged in the auditlog. 
  * Added -a flag to restorexCATdb to specify that the auditlog and eventlog tables should not be skipped. 
  * Allow skipping AAsn via site table option 'bypassservicesetup' 

## Bugs Fixed in 2.4.1

Many bugs were fixed in 2.4.1. For details see the [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945), or check the subversion commit history for the 2.4 branch for 5/1 - 5/20. 

## Known Issues and Work Around

  * Has problem to support PS701/702 

The getmacs command does NOT work correctly. 

For PS701, user can display the MAC address by rinv command, then select the correct mac address and set to attribute mac.mac for installation. 

For PS702, user need to get the MAC address from SMS interface or from ARP table if the machine is in up state, then select the correct mac address and set to attribute mac.mac for installation. 
