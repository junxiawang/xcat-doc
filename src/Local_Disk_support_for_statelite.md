<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Interface](#interface)
  - [Configure that how to partition the local disk](#configure-that-how-to-partition-the-local-disk)
  - [Configure the files in the litefile table](#configure-the-files-in-the-litefile-table)
- [Implementation details](#implementation-details)
  - [Create the script 'localdisk' to perform the partitioning](#create-the-script-localdisk-to-perform-the-partitioning)
  - [Add the handling of 'getpartition' command in xcatd and 'getpartition.pm' plugin](#add-the-handling-of-getpartition-command-in-xcatd-and-getpartitionpm-plugin)
  - [Add the binaries which are needed to perform the script 'localdisk'](#add-the-binaries-which-are-needed-to-perform-the-script-localdisk)
  - [Perform the script 'localdisk'](#perform-the-script-localdisk)
  - [Handle the litefile with option 'localdisk'](#handle-the-litefile-with-option-localdisk)
- [Limitation](#limitation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{: Design Warning}} 


## Overview

The nfs-based statelite has some shortages that some persistent files like the log need to be accessed continually with plenty of communication data which causing the nfs performance issue, and also that the growing of the temporary files in node will eat up the ram space. Then xCAT figures out a function that enable a local hard disk for the statelite node so that the unimportant log files and temporary files can be put on the local disk to reduce the using of nfs network bandwidth and reduce the using of ram space. Also, a swap space could be enabled base on the local disk to facilitate the applications. 

## Interface

Customer needs to manipulate two places to enable the local disk support. 

### Configure that how to partition the local disk

Since the configuring of the local disk is a little complex, put it in a configuration file is a good choice. The configuration file is configured in the osimage attribute 'partitionfile' (linuximage.partitionfile). 

The format of the configuration file: 
    
    enable=yes
    enablepart=no
    
    [disk]
    dev=/dev/sdb
    clear=yes
    parts=100M-200M,1G-2G
    
    [disk]
    dev=/dev/sdc
    clear=yes
    parts=10,20,30
    
    [disk]
    dev=/dev/sda
    clear=yes
    parts=10,20,30
    
    [localspace]
    dev=/dev/sda1
    fstype=ext3
    
    [swapspace]
    dev=/dev/sda2
    

There are two global attributes 'enable' and 'enablepart' to control the enable and disable of the total function. 

  * enable: This feature only works when 'enable' set to 'yes'. If set to 'no', nothing will be done. 
  * enablepart: The partition action (refer to [disk] section) will be done only when 'enablepart=yes'. 

[disk] section is used to configure how to part a hard disk. 

  * dev: The path of the device file. 
  * clear: To specify that whether to clear all the existed partitions. 'yes' - to clear, otherwise do not clear. 
  * fstype: The fs type for the new created partition. 'ext3' is the default value if not setting. 
  * parts: The space range for the partition which will be created on the 'dev'. The valid format could be '&lt;startpoint&gt;-&lt;endpoint&gt;' or 'percentage of the disk'. So you could set it to '100M-10G' or '50'. If you set it to '50', that means 50% of the disk space will be assigned to partition which will be used for local space. 

[localspace] section is used to specify which partition will be used as local storage for the statelite node. 

  * dev: The path of the partition file. 
  * fstype: The fs type on the partition which specified in 'dev'. 

[swapspace]: section is used to configure the swap space for the statelite node. 

  * dev: The path of the partition file which will be used as the swap space. 

To enable this function for the node base on a specific osimage, create the configuration file and set the path to the partitionfile for the osimage like following: 
    
    chdef -t osimage partitionfile=/tmp/cfglocaldisk
    

### Configure the files in the litefile table
    
    For the files that customer would like to store it in the local disk, add an entry like following in the litefile table: (localdisk is the option to specify that this file or directory should be put in the local disk.)
    

"ALL","/tmp/","localdisk",, 

  


## Implementation details

### Create the script 'localdisk' to perform the partitioning

The code logic in the script: 
    
    Send a request command 'getpartition' to xcatd to get the partition configuration
    Parse the arguments which returned by 'getpartition' request
    If 'enable != yes', return directly
    If 'enablepart != yes', skip the partition section in [disk].
    To part a disk which specified in [disk]:
     Go through the partition information of the target disk which specified in 'dev' 
     if 'clear=yes', remove the current partition
     else record the existed partitions
     Calculate the 'start' and 'end' points for the partition if 'xxxxspace=percentage'
     Create partition on the target disk. And format the partition to the file system type which specified in 'fstype' parameter.
    If having [localspace], mount the partition 'dev' to /.sllocal
    If having [swapspace], create the swap space against 'dev' and enable it.
    

### Add the handling of 'getpartition' command in xcatd and 'getpartition.pm' plugin

Inside the 'getparition.pm' plugin, it will read the configuration file from linuximage.partitionfile and parse it, then generate a parameter list and send it to node. 

And add the entry in policy table to permit the running of this command from node: 
    
    chtab priority=7.1 policy.commands=getpartition policy.rule=allow
    

### Add the binaries which are needed to perform the script 'localdisk'

There are several binaries need to be injected to the initrd so that the partition script could be run. 
    
    parted mke2fs bc swapon swapoff chmod
    

### Perform the script 'localdisk'

The partition script 'localdisk' will be run before the running of 'rc.statelite' which is using to configure the lite files. 

### Handle the litefile with option 'localdisk'

Add changes in the 'rc.statelite' to support the option 'localdisk'. If the 'option=localdisk', mount the original file to the one in the /.sllocal 

## Limitation

1\. The partition configuration setting only can be set in osimage level. 
