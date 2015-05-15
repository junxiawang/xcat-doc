<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Defect fixes](#defect-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

These are the changes since the xCAT 2.6.7 release. 

## New Function and Changes in Behavior

  * New Commands. See corresponding man pages for details: 
    * tabch, same function as chtab but runs as a plugin under xcatd for additional security. See http://xcat.sourceforge.net/man8/tabch.8.html 
  * Enhanced Commands. See corresponding man pages for details: 
    * tabprune new options #of days. See http://xcat.sourceforge.net/man8/tabprune.8.html 
  * Fully support parameters for postscripts 
    * Parameters can be added in the postscripts table like script1,script2 p1 p2,script3... 
    * Parameters can be included in the updatenode -P command. For example: updatenode noderange -P "script p1 p2" 
  * HA EMS on Power 775 
  * External NFS server support on Power 775 
  * Add /proc file system by default for AIX diskless nodes 
  * xcatsetup supports new syntax like f[1-6]c[01-12]p[01,05,09,13,17,21,25,29] inhostname-range keyword 
  * xcatsetup to support BPA name using Frame nd CEC 
  * SLES 10 SP4 diskful installation support 
  * xcatdebug, See man page for more details and [Debugging_xCAT_Problems] 
  * Disk mirroring support with SLES 11 [Use_RAID1_In_xCAT_Cluster] 

## Defect fixes

  * DNS forwarder cannot work on AIX platform 
  * rspconfig query for deconfigured resources on Power 775 

## Restrictions and Known Problems

  * For AIX diskless nodes, the xcatmaster attribute in the database must be an ip address of the Service Node as known by the node. The current NIM creation of a diskless image builds the /etc/hosts file with only the long hostname of the service node, so putting a short hostname in the xcatmaster attribute will not resolve on the node. If there is no hierarchy, then the site table master attribute is used and that also must be the ip address of the Management Node as known by the nodes. This affects the setup of syslog and node to node passwordless ssh support on the AIX diskless nodes during install. 
