<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Limitations and Known Issues](#limitations-and-known-issues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New Function and Changes in Behavior

  * Support for OS updates: SLES 11 SP1, RHEL 5.5, Fedora12, AIX 5.3.12, AIX 6.1.5 
  * Ability to import and export Linux Stateless, Statelite, and Stateful images. See the man page for imgexport and imgimport. This is the easiest way to share xCAT images. 
  * Support for DB2 on AIX and p-Linux as the xCAT database (still experimental) See [xCAT2SetupDB2.pdf](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2SetupDB2.pdf)
  * Faster KVM virtualization management at scale 
  * Faster setting of table values for large noderanges 
  * nodels --blame flag to display if the attribute values came from a group entry in the table or a node specific entry 
  * IPMI rewrite with increased performance, lower overhead, and IPMI 2.0 support 
  * Windows 7/Windows 2k8r2 deployment 
  * Some initial work with RHEL6 beta deployment support, but not officially supported yet. 
  * New auditlog table. All xcat commands run from the Management Node will be logged. 
  * New command tabprune to support maintaining the auditlog and eventlog 
  * Energy management support for system p 755 and BladeCenter. 
  * New attribute in site table (powerinterval) to let the rpower wait for a while between each operation, it is useful especially when using rpower to boot diskless nodes in scaling environment. 
  * Improve conserver scaling via hierarchical support 
  * Plugin loading improvements: warn if 2 different values for the same handled command, load with eval so a syntax error doesn't disable the whole daemon. 
  * Appstatus support - monitor and fill in nodelist.appstatus for things like ssh, gpfs, etc. The xcatmon plugin can monitor this periodically. A new flag on nodestat (-u) will correct any out of date status values right then. 
  * Additional statelite enhancements. See [xCAT-Statelite.pdf](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT-Statelite.pdf)
  * Support relative paths in all the commands that accept paths (see bug 2873693 comments) 
  * mkvm can create the single partition that is needed for p5 and p6 systems in clusters 
  * Option to change pw of MM/FSP/BPA in rspconfig: use old pw to connect, chg pw in device, if successful, change it in db. 
  * New -k flag on updatenode updates the ssh keys and host keys for the service nodes and compute nodes, and updates the ca and credentials to the service nodes. 
  * Performance improvements for the *def commands. 
  * Added a -s readonly (spy mode) option to rcons. 
  * Enhancement to prescript framework to allow optionally calling the prescript once for each node. 
  * Option to have NIM to use nimsh 
  * Enhancements for updating software for AIX diskless and diskfull systems. 
  * New postscript (setbootfromnet) to persistently set the system p boot parameters from linux 
  * Newly rewritten DNS plugin available (dns.pm.experimental). Many enhancements. Original DNS plugin (bind.pm) still the default. 
  * Active Directory machine account creation (partial depedency on experimental DNS plugin). 
  * Enhanced performance in various at-scale operations that manipulate table data. 
  * Enhancements to genimage, packimage, and updatenode to support "#INCLUDE: ...#" entries in all pkglist, otherpkgs.pkglist, and exlist files 
  * Enhancements to genimage and updatenode to support "#NEW_INSTALL_LIST#" entries in all pkglist and otherpkgs.pkglist files to allow lists of rpms to be installed in separate steps 
  * Enhancements to support "#INCLUDE_PKGLIST: ...#" entry in SLES AutoYaST templates to convert an included xCAT pkglist file to XML &lt;package&gt; ... &lt;/package&gt; format. 
  * rinv to report uEFI version (IBM rackmount/iDPX tested). 

## Limitations and Known Issues

For details see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945) . 
