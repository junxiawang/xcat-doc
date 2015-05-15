<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bugs Fixed](#key-bugs-fixed)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note! This version has not been released yet!!!!!!!!!!!!!!!!**

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

None. 

## Key Bugs Fixed

  * For additional bugs fixed, see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945)

## Restrictions and Known Problems

  * Upgrading the management node (MN) and the service node (SN) to xCAT 2.6.12 from xCAT 2.6.11 and below will need some extra work. This is because one dependency rpm is replaced with a new one: conserver is replaced by conserver-xcat. You need to follow the following instructions to do the upgrade: 
  1. Remove conserver from both MN and SN using **rpm -e --nodeps conserver** command. 
  2. Locate any customized otherpks.pkglist files under /install/custom/... directory. Replace conserver with conserver-xcat. 
  3. To upgrade MN, run **yum/zypper update '*xCAT*'**
  4. To upgrade SN, untar the latest xcat-core and xcat-dep tarballs into /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/xcat and then run **updatenode service -P otherpkgs**
