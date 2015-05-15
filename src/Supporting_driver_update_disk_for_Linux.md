<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Interface](#interface)
- [Implementation](#implementation)
  - [[Diskfull]](#diskfull)
  - [[Diskless]](#diskless)
- [The driver installation for diskfull node](#the-driver-installation-for-diskfull-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Background

During the installation of diskfull node or netboot of diskless node, the initrd needs to supply the drivers to drive the devices like network card, scsi card which are needed during the installation or netboot. But sometimes, the drivers of some kinds of device are not included in the default initrd for diskfull. Linux supplies an approach which can load the "driver update disk" during the diskfull installation. The driver update disk is a formatted image which including the drivers and related configuration files. 

During the installation, admin can specify the kernel parameter "dd=path:/xx" or add the "driverdisk xx" entry in the kickstart/autoyast configuration file to make the installation program (anaconda/linuxrc) to load drivers from the "driver update disk" before the real installation. 

The deployment of Operating System is an important function for xCAT, how to use the "driver update disk" to drive the devices during the xCAT controlled installation/netboot will be described in this mini design. 

## Interface

User needs to put the driver update disks into the directory "/&lt;install&gt;/ driverdisk/&lt;os&gt;/&lt;arch&gt;/" base on the os and arch that the driver disk can support. xCAT will look for the driver update disk from this directory during the "nodeset command". Then hack the driver update disk and put drivers into the initrd and do some proper configuration so that the driver can be loaded automatically during the installation or netboot. 

## Implementation

### [Diskfull]

xCAT has three possible methods to load the driver update disk. 

  * 1\. Use the kernel parameter or add kickstart/autoyast configuration entry to make the installation program anaconda/linuxrc to load the "driver update disk" from network server (httpd, nfs or ftp). By this method, xCAT does not need to touch the initrd. But this method can NOT handle the case that the network device needs driver from "driver update disk". 
  * 2\. Insert the whole "driver update disk" image into the initrd and use the kernel parameter to notice the installation program anaconda/linuxrc to load the "driver update disk" from initrd. In this approach, the whole "driver update disk" will be put in the initrd and it will be loaded by anaconda/linuxrc. An issue for redhat is that the kernel parameter only can specify one "driver update disk", if there are multiple "driver update disks" need to be loaded during the installation, xCAT has to merge multiple "driver update disk" into one and put it into the initrd. 
  * 3\. Extract the drivers out from "driver update disk" and put it into the proper place of initrd, then the drivers will be loaded directly by installation program during the installation initialization. 

Method 1 can NOT handle the network driver, so it is NOT considered. 

Method 2 is good, but it has two problems: 1. xCAT still needs to hack the "driver update disk"; 2. For the redhat, the"driver update disk" can NOT handle the case that the initrd has the driver same with the driver in the "driver update disk". That means if the initrd has an old driver, then the old driver will be loaded first and the new driver in the "driver update disk" will not be used. Since the "driver update disk" is loaded later than the pci probe in which time the old driver has been loaded, and the new driver in the "driver update disk" will not replace the old one. 

Method 3 is a little complex, but it can handle all the cases. 

Base on these three methods, the redhat will merge all the drivers form driver disk to the initrd; the sles will insert the driver disk into the initrd and use the kernel parameter to load the driver disk. 

**The implementation steps:**

**[Rhel &lt;install&gt;/ driverdisk/&lt;os&gt;/&lt;arch&gt;/"**

  * 2\. Extract the content of initrd image to a directory. The kernel modules information are located in the /modules directory. The drivers are located in /modules/modules.cgz. 
  * 3\. For each "driver update disk", extract all the valid drivers (*.ko) (valid means match the kernel version and arch) out and inserts them into the driver modules located in the initrd. (The modules directory is /modules) This step will replace old driver with the new one. 
  * 4\. For each "driver update disk", merge the configuration files into the driver modules configuration files in the initrd. The old driver information will be removed from configuration files. (The configuration files include modinfo, modules.alias, modules.dep, pcitable) 
  * 5\. Repack the initrd image. 

**[Rhel &gt;= 6.0]** (The ppc and x86 have the same process) 

  * 1\. Get the "driver update disk" list from the directory: "/&lt;install&gt;/ driverdisk/&lt;os&gt;/&lt;arch&gt;/" 
  * 2\. Extract the content of initrd image to a directory. The kernel modules are located in the /lib/modules/&lt;kernel&gt;/. 
  * 3\. For each "driver update disk", extract all the valid drivers (*.ko) (valid means match the kernel version and arch) out and copy them to the initrd:/lib/modules/&lt;kernel&gt;/. If certain kernel modules existed, then over write, otherwise copy it to the initrd:/lib/modules/&lt;kernel&gt;/kernel/drivers/driverdisk/ 
  * 4\. Run the depmod to regenerate the modules.dep for the initrd 
  * 5\. Repack the initrd. 

**[Sles - ppc]**

  * 1\. Get the "driver update disk" list from the directory: "/&lt;install&gt;/ driverdisk/&lt;os&gt;/&lt;arch&gt;/" 
  * 2\. Copy the initrd from iso: /suseboot/initrd64, extract the content of initrd image to a directory. 
  * 3\. Make directory initrd:/driverdisk; copy all the driver update disk to the initrd:/driverdisk. 
  * 4\. Get the kernel from iso: /suseboot/linux64.gz 
  * 5\. Use the /lib/lilo/scripts/make_zimage_chrp.sh to repack the initrd and kernel to a inst64 file. 
  * 6\. Add the kernel parameter dud=file:/cus_driverdisk/ for each driver disk. 

**[Sles - x86]**

  * 1\. Get the "driver update disk" list from the directory: "/&lt;install&gt;/ driverdisk/&lt;os&gt;/&lt;arch&gt;/" 
  * 2\. Extract the content of initrd image to a directory. 
  * 3\. Make directory initrd:/driverdisk; copy all the driver update disk to the initrd:/driverdisk. 
  * 4\. Repack the initrd. 
  * 5\. Add the kernel parameter dud=file:/cus_driverdisk/ for each driver disk. 

### [Diskless]

For diskless netboot, there is no installation programs anaconda or linuxrc can help to load the "driver update disk" during the netboot process. xCAT has to extract the drivers out from "driver update disk" and insert them into the initrd. The initrd of diskless has different format with the diskfull one. 

**The implementation steps:**

**[Rhel]**

  * 1\. Get the "driver update disk" list from the directory: "/install/ driverdisk/&lt;os&gt;/&lt;arch&gt;/" 
  * 2\. For each "driver update disk", extract all the valid drivers (*.ko) (valid means match the kernel version and arch) out and copy them to the rootimage:/lib/modules/&lt;kernel&gt;/. If certain kernel modules existed, then over write, otherwise copy it to the rootimage:/lib/modules/&lt;kernel&gt;/kernel/drivers/driverdisk/ 
  * 3\. Run the depmod to regenerate the modules.dep for the rootimage. 
  * 4\. Add the name of drivers from driver disk into the network driver list, so that the original code logic can add them into the initrd. (It works for Rhel 5.x and 6.x) 

**[Sles]**

  * 1\. Get the "driver update disk" list from the directory: "/install/ driverdisk/&lt;os&gt;/&lt;arch&gt;/" 
  * 2\. For each "driver update disk", extract all the valid drivers (*.ko) (valid means match the kernel version and arch) out and copy them to the rootimage:/lib/modules/&lt;kernel&gt;/. If certain kernel modules existed, then over write, otherwise copy it to the rootimage:/lib/modules/&lt;kernel&gt;/kernel/drivers/driverdisk/ 
  * 3\. Figure out the driver loading order by the name of the first level directory in the driver disk. If there is module.order file, use the driver loading order in the module.order. 
  * 4\. Run the depmod to regenerate the modules.dep for the rootimage. 
  * 5\. Add the name of drivers from driver disk into the network driver list, so that the original code logic can add them into the initrd. 

## The driver installation for diskfull node

For the Redhat, after the installation, the drivers in the "driver update disk" will not be installed in the new installed system. 

For the sles, if the driver update disk has the kmod rpm packages, the kmod will be installed into the new installed system. 

If user wants to install a driver for a new installed system, the otherpkgs.pkglist can be used to install the kernel module rpm packages during the installation. 
