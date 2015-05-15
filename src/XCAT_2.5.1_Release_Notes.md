<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.5.1 Since 2.5](#new-function-in-251-since-25)
- [Bugs Fixed in 2.5.1](#bugs-fixed-in-251)
- [Known Issues and Work Arounds](#known-issues-and-work-arounds)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.5 release. Also see the [XCAT_2.5_Release_Notes]. 

## New Function in 2.5.1 Since 2.5

  * Official support for RHEL 6 
  * Statelite support on AIX 
  * Reorganized, revamped [XCAT_Documentation] 
  * OS dump via iSCSI is now provided for AIX stateless and statelite nodes as an experimental feature. The iscsi dump support is described in [section 3 of the "xCAT AIX Diskless Nodes" doc](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_AIX_Diskless_Nodes#ISCSI_dump_support). 

## Bugs Fixed in 2.5.1

Many bugs were fixed in 2.5.1. For details see the [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945), or check the subversion commit history for the 2.5 branch. 

## Known Issues and Work Arounds

  * The AIX support for the "notify" option when defining a NIM dump resource is not currently working. In an xCAT cluster this option would be specified with the mknimimage command. Do not attempt to use this option at this time. 
