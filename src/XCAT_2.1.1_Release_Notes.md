<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Changes in xCAT 2.1.1 Compared to xCAT 2.1](#changes-in-xcat-211-compared-to-xcat-21)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Changes in xCAT 2.1.1 Compared to xCAT 2.1

Feature changes: 

  * New revacuate command added. Given a Xen host, it will live migrate all guests to valid candidates. 
  * Add xen kickstart template. 
  * makedhcp now uses networks table instead of live networks to permit relay dhcp operation 
  * Support cdrom and boot sequence control for Xen guests. 
  * nodech now puts explicit blanks per node on request to allow blanking an inherited attribute 
  * Implement wvid for IBM BladeCenter (note: a KVM credential is exposed via ps output, requires AMM firmware [BPET46C](http://www-304.ibm.com/systems/support/supportsite.wss/docdisplay?lndocid=MIGR-5078305&brandind=5000020)) and Xen. 
  * Added fanout option in rmcmon for configuring nodes to avoid NFS issues. 
  * Scaling enhancement for RMC monitoring. 
  * Usability improvements on updatenode command. 
  * Usability improvements to sinv command and support for rinv 
  * xdsh can run against an installation image on the Management Node. 

Bug fixes: 

  * Fix problem where Xen guests with block devices had incorrect XML generated for it 
  * Fix some Xen rpower output strings 
  * Fix some problems where Xen actions were not tracked accurately in the vm table 
  * Fix a problem where gPXE directives were not correctly in DHCP configuration files 
  * Fix a problem where networking would not work in a Xen 3.3 guest. 
  * Fix a problem where certain types of stacking cables were considered equivalent to ethernet ports in scanning 
  * Prevent community string index in switch plugin when no index is applicable. 
  * Fix a problem where impossible ports on certain Cisco switches were scanned. 
  * Fix a problem where iDataplex thermal profiles were implemented in a manner that only worked on dx340. Command should now work on dx320 and dx360 as well. 
  * Fix syslog-ng postscript for SLES10 
  * Fix a problem where xcatd cannot start if noderes table is not created. 
  * Fix a problem where xCAT-rmc rpm cannot be installed. 
  * Added random delay up to 10 seconds in xcataixpost so that the image server will not get accessed by all the nodes at the same time. 
