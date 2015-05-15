<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [The following changes are in xCAT 2.1 compared to xCAT 2.0:](#the-following-changes-are-in-xcat-21-compared-to-xcat-20)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## The following changes are in xCAT 2.1 compared to xCAT 2.0:

  * All major xCAT functions now supported on AIX and system p hardware (see [AIX Cookbook](http://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2onAIX.pdf)): 
    * database commands 
    * hardware discovery 
    * hardware control commands (e.g. rpower, rinv, getmacs, etc.) and rcons 
    * node deployment: full install, cloning (mksysb), diskless 
    * p commands and xdsh/xdcp 
    * monitoring plugins: RMC, Ganglia 
    * hierarchy (still in progress) 
    * virtualization commands (mkvm, etc.) 
  * [Windows copycds/rinstall](XCAT_Windows) (security implications, Administrator password in unattend.xml, only Win2k8, needs more media/profiles added) 
  * Windows imagex support (imaging, no documents on how to properly prepare an image for unattend apply yet.) 
  * [Xen full virtualized support](XCAT_Xen) (tested with RHEL5.2 provided Xen host and RHEL5.2 and Windows 2008 guests), paravirtualized not yet implemented. Lacks rinv/rvitals. 
  * [rmigrate command](http://xcat.sourceforge.net/man1/rmigrate.1.html) created to request live migration of a virtualized guest from one host to another. 
  * New Table API functions, getNodesAttribs and setNodesAttribs. This allows the Table to make optimized at-scale calls to the database. getNodesAttribs is significantly faster, setNodesAttribs is not yet performance optimized. 
  * Performance enhancements on many commands. The performance of several commands when faced with hundreds to thousands of nodes has been improved orders of magnitude (example, for a test environment one command took 30 seconds to process 500 nodes in xCAT 2.0, that command now takes less than 10 seconds to process 10,000 nodes). 
    * makedhcp 
    * makeconservercf 
    * nodeset netboot 
    * rpower/rvitals/rinv/etc 
    * makehosts 
    * nodels 
    * All commands needing to expand noderanges 
  * nodels and nodech now supports selection criteria: 
    * nodels all switch.switch==switch1 (list nodes from all group where switch column of switch table is switch1) 
    * nodels all switch.switch!=switch1 (list all other nodes that don't match) 
    * nodels all switch.switch=~/1$/ (list all nodes that are on a switch that ends in 1 (switch1, switch11, etc) 
    * nodels all switch.switch~=/1$/ (list all nodes not matched above. 
    * nodels all switch.switch=~/switch/ switch.switch (list all switch.switch values where switch.switch has the word switch in it) 
    * nodels all mp.mpa==amm1 mp.id (list slot numbers of all nodes on amm1). 
    * nodech all nodepos.rack==2 groups,=rack2 (put all nodes with nodepos.rack of 2 into a rack2 group) 
  * Console backend startup (xen/blade/ipmi) now are throttled by xCATd, and won't exhaust DB connections if xCATd wouldn't 
  * Enhanced IPMI support: 
    * reventlog decodes more, including IPMI 2.0 extended log data 
    * reventlog on read-only no longer susceptible to 'Invalid or cancelled reservation id' 
    * rbeacon now uses IPMI v2 variant when available to ensure rbeacon on lasts more than 255 seconds. 
  * bmcsetup now requires control of a privileged port on target node to divulge data 
  * [Support for MySQL](http://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2.SetupMySQL.pdf) as a configuration backend 
  * Noderange based acls in the policy are now implemented 
  * copycds now displays percentages as it goes 
  * Reduce number of processes per typical command 
  * xdsh to run commands in diskless images on the management node 
  * Software/firmware inventory command to nodes. Software inventory to images. 
  * Enhanced monitoring: 
    * New commands: monadd, moncfg mondecfg). 
    * Monitoring plugin for Ganglia. 
    * Monitoring plug-in for Performance Co-pilot (PCP) 
    * Updated monitoring plugin for RMC. 
  * Automatic installation of any additional rpms requested by the user during node deployment phase and after the nodes are up and running. 
  * Node status update (nodelist.status is updated during the node deployment, node power on/off process). 
  * SNMPv3 may now be used to scan switches (run "man switches" for table setup to do this instead of snmpv1 default) 
  * SOL console on x336/x346 servers now implemented 
  * gPXE enabled iSCSI support for Linux on x86 and Windows 2008 (experimental). 
