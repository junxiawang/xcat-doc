<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2 User Tips and Tricks](#xcat-2-user-tips-and-tricks)
  - [Setting the Time Zone of a Diskless Image](#setting-the-time-zone-of-a-diskless-image)
  - [Wiping Node Hard Drives](#wiping-node-hard-drives)
  - [Use "nodeset &lt;nr&gt; shell" Instead of a Recovery CD](#use-nodeset-&ltnr&gt-shell-instead-of-a-recovery-cd)
  - [Use lsdef to list node attributes](#use-lsdef-to-list-node-attributes)
  - [Database Documentation](#database-documentation)
  - [Use Regular Expressions in Your Tables to Greatly Reduce the Size of the Tables](#use-regular-expressions-in-your-tables-to-greatly-reduce-the-size-of-the-tables)
  - [Install ESX 3.5](#install-esx-35)
  - [Install Server Notes](#install-server-notes)
  - [What to do if RHELS 6.x install fails with "cleardisksel" error](#what-to-do-if-rhels-6x-install-fails-with-cleardisksel-error)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# xCAT 2 User Tips and Tricks

## Setting the Time Zone of a Diskless Image

~~~~

   <pre>cat >/install/netboot/.......rootimg/etc/sysconfig/clock <<EOF
    ZONE="US/Mountain"
    UTC=true
    ARC=false
    EOF

    cp -f /usr/share/zoneinfo/MST7MDT /install/netboot/.......rootimg/etc/localtime</pre>

~~~~

The above will change the default to US/Mountain - MST7MDT time. 

* * *

## Wiping Node Hard Drives

This tip comes from Shadd, off of the xcat mailing list: its a quick and dirty way to wipe the hard drives in the cluster. 

~~~~
  psh all dd if=/dev/urandom of=/dev/hda && dd if=/dev/zero of=/dev/hda 
~~~~

if you want to erase all drives on all nodes that should be enough just change hda to sda if it is scsi 

* * *

  


## Use "nodeset &lt;nr&gt; shell" Instead of a Recovery CD

Why use a rescue CD when you can "nodeset &lt;noderange&gt; shell"? On the next boot, you should be able to psh, ssh, mount, vi, etc etc etc. The "nodeset &lt;noderange&gt; shell" command is like a builtin rescue CD for many nodes. 

* * *

  


## Use lsdef to list node attributes

All of the *def (object definition) commands know which tables all the attributes belong. And since they default to working with the node object type, **lsdef nodename** will list all the attributes that are set for this node in any table. 

* * *

## Database Documentation

An overview of all the tables can be viewed by running **man xcatdb** or by going to the [xCAT Database Man Pages](http://xcat.sf.net/man5/xcatdb.5.html). A description of a specific table is available using **man tablename** . 

  


* * *

## Use Regular Expressions in Your Tables to Greatly Reduce the Size of the Tables

In all the node-related tables (except for the **nodelist** table), you can use regular expressions in a single row to represent many rows that would be only slightly different and conform to a pattern. See [xCAT Database Man Pages](http://xcat.sf.net/man5/xcatdb.5.html) for details and examples. 

* * *

## Install ESX 3.5

[See here for tutorial ](ESX_3.5_&amp;_xCAT) 

## Install Server Notes

[Here are notes to set up an install server with SLES10.1 ](InstallServer) 

## What to do if RHELS 6.x install fails with "cleardisksel" error

If RHELS 6.x fails to install using xCAT 2.7 or later, then the problem could due to the fact that xCAT now puts the "cmdline" argument on the kernel command line when installing RHELS 6.x on a node. Then if the RHELS 6.x kickstart install template does not include something defining the partitions (e.g., installing onto a pre-partitioned drive), then the following error will occur: 
    
    Examining storage devices
    In interactive step cleardiskssel, can't continue

One way to work around this, in the pre-partitioned drive install case, is to add the following line to the kickstart install template: 
    
~~~~
    clearpart --none
~~~~

* * *
