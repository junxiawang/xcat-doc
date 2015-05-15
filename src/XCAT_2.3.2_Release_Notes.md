<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Changes in 2.3.2 Since 2.3.1](#changes-in-232-since-231)
- [Bugs Fixed in 2.3.2](#bugs-fixed-in-232)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.3.1 release. Also see the [XCAT_2.3.1_Release_Notes]. 

## Changes in 2.3.2 Since 2.3.1

  * The postscript behaviour has been restored to the xCAT 2.2 behavior (i.e. run before the reboot for RHEL installations). A new column in the postscripts table called postbootscripts allows you to specify postscripts that should run after the reboot. See http://xcat.sourceforge.net/man5/postscripts.5.html for details. 
  * New flexible NFS-root option that let's you specify which parts of the OS should be stateless and which should be stateful, and uses minimal memory on the node. See http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT-Statelite.pdf 
  * Support for Fedora 12 nodes 
  * A slightly new build and packaging process for xCAT on AIX. (More similar to the xCAT on linux process.) 
  * New CSM to xCAT migration doc: http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2CSMigration.pdf 
  * Many [documentation](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/index.html) updates 

## Bugs Fixed in 2.3.2

Many bugs were fixed in 2.3.2, for details see http://sourceforge.net/tracker2/?func=browse&amp;group_id=208749&amp;atid=1006945 . 
