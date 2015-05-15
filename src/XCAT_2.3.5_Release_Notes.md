<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Changes in 2.3.5 Since 2.3.4](#changes-in-235-since-234)
- [Bugs Fixed in 2.3.5](#bugs-fixed-in-235)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.3.4 release. Also see the [XCAT_2.3.4_Release_Notes]. 

## Changes in 2.3.5 Since 2.3.4

  * Add CentOS5.5 disc id 
  * Backport 2.4 Cisco trunk mode support 
  * Add an option to skip automatic setup of ftp 
  * Be explicit about vm placement on power on in the face of vmware clusters 

## Bugs Fixed in 2.3.5

  * PBS_HOME wrong, should be /var/spool/torque (not /var/spool/pbs) 
  * fix error rinstall compute node1 interpreting noderange as compute,node1 (feature 2991651) 
  * fix rsync multiple nodes hierarchy problem building from file name ( multiple SNsyncfiledir in path) 
  * Fix problem where pxelinux.cfg directory missing would fail 
  * Fix configuration datastore identification in vmware environments not using xCAT auto-attach when scsi is requested 
  * Backport dealing with questions interfering with poweron of vmware vms 
  * Backport scsi disk feature from 2.4 vmware support 
  * Backport ToolsCenter fixes from 2.4 branch 
  * Fix rspconfig network for IBM BladeCenter 
  * Many more bugs were fixed in 2.3.4. For details see http://sourceforge.net/tracker2/?func=browse&amp;group_id=208749&amp;atid=1006945 . 
