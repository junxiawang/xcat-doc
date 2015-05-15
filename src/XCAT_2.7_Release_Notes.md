<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
  - [All Environments](#all-environments)
  - [x86_64 Hardware](#x86_64-hardware)
  - [Linux](#linux)
  - [AIX](#aix)
- [Key Bugs Fixed](#key-bugs-fixed)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 


## New Function and Changes in Behavior

### All Environments

  * xcatd memory usage has been decreased by about two thirds 
  * xCAT can now hot-load most plugin updates without a server restart. 
  * xCAT now supports a [site.xcatmaxconnections](http://xcat.sourceforge.net/man5/site.5.html) tunable to either restrict number of allowed SSL connections to fit in lower memory budget or increase it for more speed at the expense of memory usage. 
  * [xcatdebug](http://xcat.sourceforge.net/man8/xcatdebug.8.html) command can be used to enable trace for xcatd and xcatd plugins without restarting the xcatd. 
  * New [automated test framework](http://xcat.sourceforge.net/man1/xcattest.1.html) for xCAT. 
  * New [lstree](http://xcat.sourceforge.net/man1/lstree.1.html) command to display the tree of service node hierarchy, hardware hierarchy, or VM hierarchy 
  * [makedns](http://xcat.sourceforge.net/man8/makedns.8.html) enhancement: 
    * By default, the DNS on the management node is configured. It is no longer necessary to make /etc/resolv.conf on the MN point to the DNS that makedns should configure. 
    * Support new option -e to provide the flexibility to update the DNS records to an external DNS server which is listed in the /etc/resolv.conf on the management node. 
    * named starts up automatically after system reboot. 
  * [site.ntpservers](http://xcat.sourceforge.net/man5/site.5.html) and [networks.ntpservers](http://xcat.sourceforge.net/man5/networks.5.html) can be set to keyword "&lt;xcatmaster&gt;" to specify that the management node or service node should be used for each compute node's time server. 

### x86_64 Hardware

  * xCAT Genesis boot image supersedes nbfs for x86_64 node discovery and other generic boot environment tasks: 
    * To use it, install the xCAT-genesis-x86_64 RPM on the MN from the latest [xcat-dep](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux) tarball. 
    * Contains to glibc, 32 &amp; 64 bit userspace libraries and utilities from CentOS 6.x, and allows execution of more binaries without lots of library wrangling 
    * Uses CentOS 6.x kernel, and adds several drivers 
    * Gathers more hardware inventory data (processors, memory, wwpn, etc) 
    * Runs IBM UpdateExpress 
    * LLDP (Link Layer Discovery Protocol) support 
    * Optional enhanced host authentication through ethernet switches 
    * Faster boot 
    * Debug shell on tty2 
    * UEFI and legacy x86 boot modes supported 
    * nbfs remains available 
  * IPMI now honors [site.syspowerinterval](http://xcat.sourceforge.net/man5/site.5.html) and [site.syspowermaxnodes](http://xcat.sourceforge.net/man5/site.5.html) to optionally throttle rpower operations. 
  * IPMI allows for new attribute [site.ipmidispatch](http://xcat.sourceforge.net/man5/site.5.html) to be set to '0' to disable dispatching the IPMI hardware operations to the service nodes. 
  * Allow for per-node override of tftpdir to allow for mount-managed service node tftp content or surrogate service node tftp content 
  * KVM plugin now allows the administrator to specify a more traditional password for VNC/SPICE access using [vm.vidpassword](http://xcat.sourceforge.net/man5/vm.5.html)
  * Improved logging of node discovery attempts 
  * General support of new IBM 'M4' generation hardware 
  * Enhanced out-of-band inventory data on new IBM system x servers 
  * Can now rpower suspend select IBM servers 
  * OS installers are now allowed to go graphical if no text console is specified 
  * ESXi5 support now includes stateful install in addition to the previous stateless boot support 
  * xnba now supports UEFI boot of relevant operating systems (ESXi 5, SLES11, RHEL6, Win2k8, Win7) 
  * Aids to help monitor Mellanox IB networks. See [Managing_the_Mellanox_Infiniband_Network]. 

### Linux

  * The servicenode postscript now calls xcatserver and xcatclient for Linux. You do not need all three in the postscript list. (It will not hurt if they are there.) The install or update of xCAT will cleanup the list in the postscripts table. So where you previously saw "servicenode,xcatserver,xcatclient" you will only see "servicenode". 
  * Switch to using the version of tftp that comes in the distro, instead of the atftp-xcat RPM in the xcat-dep tarball. 
  * Load distro DVD disc id's from a separate file (/opt/xcat/lib/perl/xCAT/data/discinfo.pm), instead of them being in the plugins. This makes it easier for users to modify this file to try out a new version of a distro. 
  * Removed the requirement to setup and use FTP to download the postscripts to the nodes. Uses httpd now. 
  * Documentation on how to setup RAID1 for Linux diskful installation. See [Use_RAID1_In_xCAT_Cluster] 
  * General support for RHEL 6.2 
  * xCATs installation/configuration IBM HPC products on RHEL 6.2 is experimental until 2.7.1 
  * Rolling updates on SLES 11 SP1 and RHEL 6.2 is experimental until 2.7.1 
  * Mellanox IB QDR support on IBM system p and system x servers 
  * Support for Nagios monitoring plugin 

### AIX

  * [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html) supports new option ( -d) to Only define the NIM resources on the service nodes. 
  * Support for using NFS v4 with AIX diskless nodes. 
  * Experimental code for real-time service node fail over on AIX. This code depends on some fixes in AIX that are not available yet, so this code is just for investigation on a non-production system. 
  * [dumpxCATdb](http://xcat.sourceforge.net/man1/dumpxCATdb.1.html) \- added -b option for those running the DB2 database. It will use the DB2 database dump utilities to create a binary backup of the entire DB2 xCAT instance. See also the [xCAT DB2 doc](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Setting_Up_DB2_as_the_xCAT_DB#Backup.2FRestore_the_database_with_DB2_Commands). Also supported on p775 linux. 
  * [restorexCATdb](http://xcat.sourceforge.net/man1/restorexCATdb.1.html) \- added -b option for those running the DB2 database. This will restore the database from the binary backup taken using DB2 Utilities. Also supported on p775 linux. 

## Key Bugs Fixed

See the [xCAT 2.7 SourceForge bugs](https://sourceforge.net/tracker/?limit=100&func=&group_id=208749&atid=1006945&assignee=&status=1&category=&artgroup=&keyword=&submitter=&artifact_id=&assignee=&status=&category=&artgroup=1942641&submitter=&keyword=&artifact_id=&submit=Filter&mass_category=&mass_priority=&mass_resolution=&mass_assignee=&mass_artgroup=&mass_status=&mass_cannedresponse=&_visit_cookie=bffc5bd7283d8a0a38256d3329e3894a). 

## Restrictions and Known Problems

  * Upgrading the management node (MN) and the service node (SN) to xCAT 2.7 from xCAT 2.6.11 and below will need some extra work. This is because two dependency rpms are replaced with the new ones: conserver is replaced by conserver-xcat, atftp-xcat is replaced by tftp or tftp-server. You need to follow the following instructions to do the upgrade: 
  1. Remove conserver and atftp-xcat from both MN and SN using **rpm -e --nodeps** command. 
  2. Locate any customized otherpks.pkglist files under /install/custom/... directory. Replace conserver with conserver-xcat. 
  3. To upgrade MN, run **yum/zypper update '*xCAT*'**
  4. To upgrade SN, untar the latest xcat-core and xcat-dep tarballs into /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/xcat and then run **updatenode service -P otherpkgs**
  * When xcatd is restarted on a service node, it displays an error msg from the litetree command: https://sourceforge.net/tracker/?func=detail&amp;aid=3508572&amp;group_id=208749&amp;atid=1006945 
  * When a service node boots up, it displays the following error message on the console: Use of uninitialized value $ENV{"XCATROOT"}.... See https://sourceforge.net/tracker/?func=detail&amp;aid=3508456&amp;group_id=208749&amp;atid=1006945 
  * When a p775 compute node boots up, although it displays the error "ln: cannot unlink /etc/drivers/if_ml", the ml0 interface is still configured: https://sourceforge.net/tracker/?func=detail&amp;aid=3508440&amp;group_id=208749&amp;atid=1006945 
  * When site.disjointdhcps=0 and noderes.netboot=xnba, nodeset will give error from the service node that is not in the same subnet as the node. You can ignore the error because the nodes can still boot up without problem. Another problem is that the xcatd cannot start on the service node which does not have any nodes within its subnet. This will be fixed in xCAT 2.7.1. You can set site.disjointdhcps=1 to avoid this problem. 
  * Because of change in mpa table definition you will get warnings on upgrade if using sqlite or Postgresql. These are just warnings and the table change occurs. https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3504404&amp;group_id=208749&amp;atid=1006945 
  * When upgrading xCAT to 2.7, you may see the following error when the xCAT-server RPM is installed: 
    
    Reloading xCATd Can't locate xCAT/Enabletrace.pm in @INC...

     This is caused by xCAT-server being installed before perl-xCAT, and xcatd is being restarted before the new version of perl-xCAT is installed. The error message can be ignored, because xcatd will be restarted again when perl-xCAT is installed and then it will pick up the correct files. See [SourceForge bug about this](https://sourceforge.net/tracker/index.php?func=detail&aid=3504211&group_id=208749&atid=1006945). This will be fixed in 2.7.1. 

  * Booting lots of lpars, some hang on c31 (Power 775) - Will be fixed 2.6.12 and 2.7.1. Efix available. See bug for details https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3485032&amp;group_id=208749&amp;atid=1006945# 
  * Password process for Blades incorrect: https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3510200&amp;group_id=208749&amp;atid=1006945 
  * For the full bug list, see http://sourceforge.net/tracker2/?func=browse&amp;group_id=208749&amp;atid=1006945 
