<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [What to sync to the Service Nodes](#what-to-sync-to-the-service-nodes)
  - [Commands affected](#commands-affected)
  - [Additional Design Points](#additional-design-points)
  - [Issues](#issues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

The problem that we are addressing is sometimes the Service Nodes(SN) which are being used to install the compute nodes in a hierarchical cluster have not been updated with the current postscripts, syncfiles and images from the Management Node before the install. In the past, the admin has been left responsible for making sure the Service Node is up to date and to know what needs to be synchronized to the service nodes. 

### What to sync to the Service Nodes

The design is to ensure that the following are updated on the Service Nodes: postscripts synclist files images needed for the compute node install Any additional files needed for that install ( otherpkgs, pkglists, etc) 

### Commands affected

Enhance **nodeset, nimnodeset and mkdsklsnode** to sync to the SN's during preprocessing on the Management node , any files that they use , so that we are sure that the files on the SN's are the latest level. A flag would be added to not-sync, but the default would be to always sync. 

Add a new flag to **updatenode**, that indicates that we want to synchronize the list on input Service Nodes. This synchronization would include everything under the site.installdir ( usually /install) with the **exception of the following**: /install/nim on AIX /install/&lt;os&gt; \- images put in /install by copycds on Linux /install/netboot - diskless images on Linux, only active images will be sync'd. 

Enhance **xdcp** ( rsync support) to allow exclusion lists. This depends on whether we decide to (1) create a list of things to sync, or (2) sync all of /install and create a list of things to exclude. Right now, we are leaning toward (2), because of not be absolutely sure of where the user may put files under /install that are needed during the install. Also, need to enhance xdcp so that it can rsync the service nodes given a servicenode list. Today , the interface is a compute node list. This is putting the syncfiles needed for the compute nodes in the temporary sync directory on the SN. We could just input the computenode list for the SN's and keep the old interface. Double processing though. 

### Additional Design Points

A requirement would be that everything that needs to be sync'd to the SN would be required to be in a directory under site.installdir ( /install). 

updatenode new function would always sync everything. We have taken in account the first time might be long, but afterwards it should be quick for small changes. updatenode will give feedback to the admin what is happening, so during a long sync, they do not think it is hung. Possibly need an enhancement to xdcp here. 

### Issues

One issue is rsync cannot successfully sync a statelite image due to the way it links files and directories. This has been a limitation in xCAT and scp has been used. Example of error: rhsn: symlink has no referent: "/install/netboot/rhels6/ppc64/test_ramdisk_statelite/rootimg/.default/etc/sysconfig/network-scripts/ifup" rhsn: symlink has no referent: "/install/netboot/rhels6/ppc64/test_ramdisk_statelite/rootimg/.default/etc/sysconfig/network-scripts/ifdown" rhsn: symlink has no referent: "/install/netboot/rhels6/ppc64/test_ramdisk_statelite/rootimg/lib/modules/2.6.32-71.el6.ppc64/source" 
