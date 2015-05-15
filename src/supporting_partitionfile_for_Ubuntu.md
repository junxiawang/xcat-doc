<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [The mini-design of supporting partitionfile for Ubuntu](#the-mini-design-of-supporting-partitionfile-for-ubuntu)
  - [Background](#background)
- [tabdump -d linuximage](#tabdump--d-linuximage)
  - [Design Consideration](#design-consideration)
- [Alternatively, you may specify a disk to partition. If the system has only](#alternatively-you-may-specify-a-disk-to-partition-if-the-system-has-only)
- [one disk the installer will default to using that, but otherwise the device](#one-disk-the-installer-will-default-to-using-that-but-otherwise-the-device)
- [name must be given in traditional, non-devfs format (so e.g. /dev/hda or](#name-must-be-given-in-traditional-non-devfs-format-so-eg-devhda-or)
- [/dev/sda, and not e.g. /dev/discs/disc0/disc).](#devsda-and-not-eg-devdiscsdisc0disc)
- [For example, to use the first SCSI/SATA hard disk:](#for-example-to-use-the-first-scsisata-hard-disk)
- [d-i partman-auto/disk string /dev/sda](#d-i-partman-autodisk-string-devsda)
- [If you have a way to get a recipe file into the d-i environment, you can](#if-you-have-a-way-to-get-a-recipe-file-into-the-d-i-environment-you-can)
- [just point at it.](#just-point-at-it)
- [d-i partman-auto/expert_recipe_file string /hd-media/recipe](#d-i-partman-autoexpert_recipe_file-string-hd-mediarecipe)
  - [Interface and Implementation](#interface-and-implementation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

The mini-design of supporting partitionfile for Ubuntu
======================================================

 
Background
----------

In xCAT, there is a attribute to specify the customized disk partition file for linux image provision. 
The detail: 

~~~~

#tabdump -d linuximage
partitionfile:  The path of the configuration file which will be used to partition the disk for the node. For stateful osimages,two types of files are supported: "<partition file absolute path>" which contains a partitioning definition that will be inserted directly into the generated autoinst configuration file and must be formatted for the corresponding OS installer (e.g. kickstart for RedHat, autoyast for SLES).  "s:<partitioning script absolute path>" which specifies a shell script that will be run from the OS installer configuration file %pre section;  the script must write the correct partitioning definition into the file /tmp/partitionfile on the node which will be included into the configuration file during the install process. For statelite osimages, partitionfile should specify "<partition file absolute path>";  see the xCAT Statelite documentation for the xCAT defined format of this configuration file.

~~~~
 
However, this feature has not been supported in Ubuntu provisioning yet. Since there are some special syntax in preseed to specify the partition related parameters, the design should be as flexible as possible to support the regular/LVM/Raid partition method in preseed, while keeping a consistent user interface with existed  Redhat/SLES partition file customization.
 
Design Consideration
--------------------

Using preseeding to partition the harddisk is limited to what is supported by “partman-auto”. You can choose to partition either existing free space on a disk or a whole disk. The layout of the disk can be determined by using a predefined recipe, a custom recipe from a recipe file or a recipe included in the preconfiguration file.
Preseeding of advanced partition setups using RAID, LVM and encryption is supported, but not with the full flexibility possible when partitioning during a non-preseeded install.
“partman-auto” requires some parameters to finish the customized partition automation. Some mandatory parameters:

~~~~

# Alternatively, you may specify a disk to partition. If the system has only
# one disk the installer will default to using that, but otherwise the device
# name must be given in traditional, non-devfs format (so e.g. /dev/hda or
# /dev/sda, and not e.g. /dev/discs/disc0/disc).
# For example, to use the first SCSI/SATA hard disk:
#d-i partman-auto/disk string /dev/sda
 # Or provide a recipe of your own...
# If you have a way to get a recipe file into the d-i environment, you can
# just point at it.
#d-i partman-auto/expert_recipe_file string /hd-media/recipe
 
~~~~

Besides the parameters listed above, there are some optional paramters which should be taken into consideration for some special cases.
 
“partman-auto/disk” should be specified with the disk(s) to partition, “partman-auto/expert_recipe_file” should be specified with the recipe file which specifies the layout of the partitions.
 
For ubuntu, the linuximage.partitionfile should include both the disks(or the script to determine it) and recipe file (or the script to generate it).
 
Interface and Implementation
----------------------------

The value of linuximage.partitionfile should include one or more of the following values delimited with “,” :

~~~~

d:<absolute path to the disk file>
<absolute path to the recipe file>
 
sr:<absolute path to the recipe script>
sd:<absolute path to the disk script>
 
~~~~
 
The **disk file** contains the names of the disks to partition in traditional, non-devfs format, delimited with space “ ”, for example, 

~~~~

/dev/sda /dev/sdb 

~~~~
 
The detailed information of the **recipe file** can be found in the files partman-auto-recipe.txt and partman-auto-raid-recipe.txt included in the debian-installer package. Both files are also available from the debian-installer source repository. 
 
The **disk script** runs before partitioning and writes the **disk file** described above which containing the names of disks to partition,in traditional, non-devfs format and delimited with space “ ”, to a file /tmp/partitiondisk .
 
The **recipe script** writes the **recipe file** described above to a file /tmp/partitionfile and sets other required “partman-auto” paramters  with “debconf-set”.  
 
If the **disk file(script)** or the **recipe file(script)** is not specified in linuximage.partitionfile, the default partition scheme will be used. 
 