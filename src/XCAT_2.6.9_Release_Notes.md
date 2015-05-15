<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bugs Fixed](#key-bugs-fixed)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

  * Increased timeout value for query of LEDs from Bladecenter 
  * AIX 7.1.1 support 
  * Ability to set BSR setting on p775 
  * Performance improvements for DFM p775 hardware control 
  * Stateful deployment of AIX over HFI 
  * Postscript to set up disk mirroring on an AIX stateful node 
  * Mixed clusters of system x and system p hardware running SLES: [Mixed_Cluster_Support_for_SLES] 
  * xcatsnap improvements 
  * Hardware replacement procedure documentation(P775A+ part) 
    * [Power_775_Cluster_Recovery]

## Key Bugs Fixed

  * 3412934 - Improve output from genimage 
  * 3414742 - xdsh -K did not work if userid was in LDAP (not in /etc/passwd) 
  * 3430879 - improve configeth sample postscript and documentation 
  * 3411554 - CentOS 6 image gen is missing dracut link 
  * 3377379 - genimage plugin hangs when postinstall script prompts 
  * 3412259 - lsslp couldn't get parent for some cecs 
  * 3419608 - mkdsklsnode fails first time for hfi_net 
  * 3427796 - additional options needed in aixvgsetup 
  * 3390380 - sles10SP4: genimage error with dbus not found 
  * 3428290 - xcat fork memory errors with rbootseq 
  * 3428344 - Confighfi support for Torrent 2.1 HFI netwk 
  * 3398468 - AIX diskless CNs miss paging space in large p7 
  * 3426911 - support for site.powerinterval added 

For additional bugs fixed, see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945)

## Restrictions and Known Problems

  * The rpm package conserver-xcat was added in the dependency package to replace conserver. If encountering the issue that conserver-xcat conflicts with conserver when updating of xCAT from 2.6.9 to 2.7, remove the conserver manually first and try again. 
  * When powering on multiple p775 CECs or powering on LPARs of multiple p775 CECs via rpower, set site.powerinterval to 30 before running rpower. See https://sourceforge.net/tracker/?func=detail&amp;aid=3426911&amp;group_id=208749&amp;atid=1006945 for details. 
  * The rnetboot command for p775 LPARs won't correctly set the default bootlist in AIX diskless nodes so the LPAR can be rpower'd next time. Also, the default bootlist can sometimes change after the user sets it. The workaround for now is to always run rbootseq before running rpower on for p775 LPARs. See https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3435969&amp;group_id=208749&amp;atid=1006945 for details. 
  * AIX is shipping it's own chdef and psh command in AIX 7.1.1. With normal installation they fall first in the path, so you may be surprised by the fact your man page and command are not what you expect when you run chdef of psh. You are going to need to update your profile to put the xcat paths before the OS chdef and psh, and also modify the MANPATH to put the xCAT man page first. https://sourceforge.net/tracker/?func=detail&amp;aid=3424615&amp;group_id=208749&amp;atid=1006945 
