<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bugs Fixed](#key-bugs-fixed)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

None. 

## Key Bugs Fixed

  * [PMR46317 (U) error runing updatenode -P servicenode](https://sourceforge.net/tracker/?func=detail&aid=3485485&group_id=208749&atid=1006945)
  * [Utils.pm in servicenode ps breaks Linux SN diskfull install Linux only](https://sourceforge.net/tracker/?func=detail&aid=3485029&group_id=208749&atid=1006945)
  * [PMR 37901 -syspowerinterval not working with onstanby action](https://sourceforge.net/tracker/?func=detail&aid=3485080&group_id=208749&atid=1006945)
  * [unexpected statelite table after 'snmove node'](https://sourceforge.net/tracker/?func=detail&aid=3474362&group_id=208749&atid=1006945)
  * [incorrect return information for rspconfig](https://sourceforge.net/tracker/?func=detail&aid=3472764&group_id=208749&atid=1006945)
  * [Update BPA replacement doc for Plinux support](https://sourceforge.net/tracker/?func=detail&aid=3469440&group_id=208749&atid=1006945)
  * [xcatsetup: the IP of fsp 40.63.01.2 has 0 at head of a part](https://sourceforge.net/tracker/?func=detail&aid=3467860&group_id=208749&atid=1006945)
  * [can mkhwconn support --port 0,1](https://sourceforge.net/tracker/?func=detail&aid=3455153&group_id=208749&atid=1006945)
  * [mknimimage -u hangs when requrested in install rpms](https://sourceforge.net/tracker/?func=detail&aid=3443438&group_id=208749&atid=1006945)
  * [xcatd: SSL Listener crashes](https://sourceforge.net/tracker/?func=detail&aid=3413113&group_id=208749&atid=1006945)
  * [please update doc Setting up PE in a Stateful Cluster](https://sourceforge.net/tracker/?func=detail&aid=3411391&group_id=208749&atid=1006945)
  * [need additional OS packages](https://sourceforge.net/tracker/?func=detail&aid=3165548&group_id=208749&atid=1006945)

For additional bugs fixed, see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945)

## Restrictions and Known Problems

  * In DB2 environment, if you run updatenode &lt;sn&gt; -P servicenode, the cfgloc file is deleted on the SN and has to be recopied to the SN. http://sourceforge.net/tracker/?func=detail&amp;aid=3495906&amp;group_id=208749&amp;atid=1006945 
  * Update of xCAT software on LInux removes the the DB2 setup of /etc/profile.d/xcat.sh and xcat.csh https://sourceforge.net/tracker/?func=detail&amp;aid=3474407&amp;group_id=208749&amp;atid=1006945 
  * IPV6 entry in networks table not handled correctly. https://sourceforge.net/tracker/?func=detail&amp;aid=3502630&amp;group_id=208749&amp;atid=1006945 
  * For LL using DB2 need to set authentication client. https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3502735&amp;group_id=208749&amp;atid=1006945 
