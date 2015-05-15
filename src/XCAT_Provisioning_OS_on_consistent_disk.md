<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [The main idea](#the-main-idea)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



Note: this is an xCAT design document, not an xCAT user document. If you are an xCAT user, you are welcome to glean information from this design, but be aware that it may not have complete or up to date procedures.

##Overview
On p8LE bare metal machine, someone found that the ubuntu 14.10 won't be installed on consistent disk if there are multiple hard disk, such as 4 and more. We found that the disk name of the harddisk can be different when kernel runs. The requirement are:
1. choose a consistent disk to provision OS
2. if there were OS had been installed, we need to be able to reinstall it.  

##The main idea
1. List all the partitions, and mount then one by one and check if there is "boot" directory. This step can cover the "boot" partition on the same partition with root partition or not.
2. If not found, we will choose the disk(not include partitions) with the minimal device path. The device path is consistent and won't change automatically.
3. If both the 2 steps above can not found a correct disk, we will use "sda".

Scenario haven't cover:
If there are multiple OS have been installed on the machine, xCAT won't be able to choose the consistent disk to install OS on. For example, the first OS is located on sda on the previous boot, and the name sda is assigned to another disk in this boot.  


##Other Design Considerations

    Required reviewers:
    Required approvers: Guang Cheng
    Database schema changes: N/A
    Affect on other components: N/A
    External interface changes, documentation, and usability issues: N/A
    Packaging, installation, dependencies: N/A
    Portability and platforms (HW/SW) supported: N/A
    Performance and scaling considerations: N/A
    Migration and coexistence: N/A
    Serviceability: N/A
    Security: N/A
    NLS and accessibility: N/A
    Invention protection: N/A
