<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.4.3 since 2.4.2](#new-function-in-243-since-242)
- [Bugs Fixed in 2.4.3](#bugs-fixed-in-243)
- [Known Issues and Work Arounds in 2.4.3](#known-issues-and-work-arounds-in-243)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.4.2 release. Also see the [XCAT_2.4.2_Release_Notes]. 

## New Function in 2.4.3 since 2.4.2

  * VMWare performance enhancements 
  * Support for POWER 710, 720, 730, 740, and 795 

## Bugs Fixed in 2.4.3

  * Disable cipher suite 0 in IPMI 2.0 compliant BMCs 
  * Bootable Media Creator support fixes 
  * VMWare OUI prefixed mac addresses now mask out two high bits of the host portion 
  * Fix timing bug on long running VMWare tasks 
  * Systems lacking a proper FRU area 0 are now more gracefully handled 
  * Fix issues for DB2 and MySQL hosted configurations 
  * Fix routed nodestat requests 
  * Fix problem where tabgrep caused permission denied errors to the db 

Many bugs were fixed in 2.4.2. For details see the [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945), or check the subversion commit history for the 2.4 branch for 5/1 - 5/20. 

## Known Issues and Work Arounds in 2.4.3

  * Problem with getmacs on PS701/702 
    * The getmacs command does NOT work correctly. 
    * For PS701, user can display the MAC address by rinv command, then select the correct mac address and set to attribute mac.mac for installation. 
    * For PS702, user need to get the MAC address from SMS interface or from ARP table if the machine is in up state, then select the correct mac address and set to attribute mac.mac for installation. 
  * Paging space for AIX diskless nodes 
    * Even if you specify the psize= parameter to the mkdklsnode command, the paging size will be 0 
    * The work around is to run the following 2 commands, where &lt;OSIMAGE&gt; is the OS image name: 
    
    nim -o change -a nfs_vers=4 &lt;OSIMAGE&gt;_paging
    nim -o check &lt;OSIMAGE&gt;
