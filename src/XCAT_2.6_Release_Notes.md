<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Limitations and Known Issues](#limitations-and-known-issues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

  * New Commands. See corresponding man pages for details: 
    * [lsxcatd](http://xcat.sourceforge.net/man1/lsxcatd.1.html) \- List daemon information 
    * xcsv - Reformat output of rvitals and similar in CSV format 
    * [imgcapture](http://xcat.sourceforge.net/man1/imgcapture.1.html) \- capture image from running node to create a stateless/statelite image - only for linux 
  * Enhanced Commands. See corresponding man pages for details: 
    * [tabdump](http://xcat.sourceforge.net/man8/tabdump.8.html) -w - allows selective dump of table rows 
    * [xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html) \- now supports the automatic running of postscripts after files are rsync'd to the nodes. See the xdcp man page and Sync-ing_Config_Files_to_Nodes#postscript_support. 
    * [makeroutes](http://xcat.sourceforge.net/man8/makeroutes.8.html) \- added ability to specify routes for compute nodes 
    * [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) \- Service node manual failover - added support for AIX and enhancements for linux 
    * [monshow](http://xcat.sourceforge.net/man1/monshow.1.html) \- Now also shows RMC events (in addition to RMC performance info) 
  * Support for statelite semantics on top of a ramdisk diskless node 
  * Support for DB2 on RHEL 6 
  * xCAT now supports the automatic setup of DB2 client on the Service Node during Service Node install. 
  * [Documentation](Shared_Disks_HA_Mgmt_Node) of how to manually fail over an xCAT management node to a backup using a shared disk 
  * Support on AIX for using a [separate NFS server](External_NFS_Server_Support_With_AIX_Stateless_And_Statelite) for diskless nodes 
  * Documented [External_NFS_Server_Support_With_Linux_Statelite] 
  * HPC integration set up of login nodes - pkg lists, postscripts, etc. for what needs to be installed on/configured for a login node. 
  * Support for [alt_disk install](XCAT_support_for_NIM_alternate_disk_installation) and/or multibos on diskfull AIX nodes 
  * Exploitation of batched event hierarchical support (attributes on the Condition class that indicate when a batched event file is ready to be processed) 
  * Documented [Hints_and_Tips_for_Large_Scale_Clusters] 
  * Support for setting up kdump for linux diskless nodes 
  * OS dump via iSCSI AIX stateless and statelite nodes. The iscsi dump support is described in [section 3 of the "xCAT AIX Diskless Nodes" doc](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_AIX_Diskless_Nodes#ISCSI_dump_support). 
  * AIX 71B/61N support for p7 &amp; p6 
  * Added [documentation](Managing_the_Infiniband_Network) for IB support on system p on RHEL 6 
  * Ability to set up the compute node's service node as the default gateway by setting [networks.gateway](http://xcat.sourceforge.net/man5/networks.5.html)] to "&lt;xcatmaster&gt;" 
  * A new attribute, site.excludenodes, to specify a list of nodes/groups that should always be excluded from all xcat commands (e.g. the list of nodes the currently have hardware problems). 
  * Enhanced IPv6 support 
    * ddns plugin will now push IPv6 /etc/hosts entries into DNS 
    * DHCPv6 bindings based on client DUID-UUID for ISC DHCP 4.x (used in RHEL6) 
    * Windows, ESXi, and RHEL6 support for using DUID-UUID on the client side 
  * Per network dynamic dns suffix allows each network to potentially have a different IPv6 suffix. Useful for dual stack and multihomed nodes in dynamic address use (e.g. node1.cluster.example.com, node1.ib.cluster.example.com, node1.ipv6.cluster.example.com is now possible). 
  * Enhancements to xcatmon/appstatus to monitor the HPC application (GPFS, LAPI and LoadLeveler) status in xCAT cluster. Added some new sample scripts for lcmd and dcmd. See [Monitoring HPC application status](Monitoring_an_xCAT_Cluster#Monitoring_HPC_application_status). 
  * Partial support for vSphere 5 

## Limitations and Known Issues

For additional issues, see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945)
