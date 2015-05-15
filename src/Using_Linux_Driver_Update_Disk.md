<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Driver Update Disk](#driver-update-disk)
  - [Locate the Driver Update Disk](#locate-the-driver-update-disk)
  - [Inject the Drivers From the Driver Update Disk into the initrd](#inject-the-drivers-from-the-driver-update-disk-into-the-initrd)
- [Driver RPM Package](#driver-rpm-package)
  - [Set the Driver Name and Location of Driver RPM Packages](#set-the-driver-name-and-location-of-driver-rpm-packages)
  - [Inject the Drivers From the Driver RPM into the initrd](#inject-the-drivers-from-the-driver-rpm-into-the-initrd)
- [Note](#note)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Overview

During the installing or netbooting of a node, the drivers in the initrd will be used to drive the devices like network cards and IO devices to perform the installation/netbooting tasks. But sometimes the drivers for the new devices were not included in the default initrd shipped by Red Hat or Suse. A solution is to inject the new drivers into the initrd to drive the new device during the installation/netbooting process. 

Generally there are two approaches to inject the new drivers: Driver Update Disk and Drive RPM package. xCAT supports both. 

## Driver Update Disk

A "Driver Update Disk" is media which contains the drivers, firmware and related configuration files for certain devices. The driver update disk is always supplied by the vendor of the device. One driver update disk can contain multiple drivers for different OS releases and different hardware architectures. Red Hat and Suse have different driver update disk formats. 

### Locate the Driver Update Disk

There are two approaches for xCAT to find the driver disk (pick one): 

  * Specify the location of the driver disk in the osimage object (This is ONLY supported in 2.8 and later) 

The value for the 'driverupdatesrc' attribute is a comma separated driver disk list. The tag 'dud' must be specified before the full path of 'driver update disk' to specify the type of the file: 
  
~~~~  
    chdef -t osimage <osimagename> driverupdatesrc=dud:<full path of driver disk>
    
~~~~

  * Put the driver update disk in the directory &lt;installroot&gt;/driverdisk/&lt;os&gt;/&lt;arch&gt; (e.g. /install/driverdisk/sles11.1/x86_64). During the running of the 'genimage', 'geninitrd' or 'nodeset' command, xCAT will look for driver update disks in the directory &lt;installroot&gt;/driverdisk/&lt;os&gt;/&lt;arch&gt; . 

### Inject the Drivers From the Driver Update Disk into the initrd

  * If specifying the driver disk location in the osimage, the osimage object must be used to run the 'genimage' and 'nodeset': 

~~~~      
    [Stateless/Diskless]
      genimage <osimagename>
    [Statefull/Diskfull]
      nodeset <noderange> osimage=<osimagename>
     OR:
      geninitrd <osimagename>
      nodeset <noderange> osimage=<osimagename> --noupdateinitrd
~~~~      

Note: 'geninitrd' + 'nodeset --noupdateinitrd' is useful when you need to run nodeset frequently for a diskful node. 'geninitrd' only needs be run once to rebuild the initrd and 'nodeset --noupdateinitrd' will not touch the initrd and kernel in /tftpboot/xcat/osimage/&lt;osimage name&gt;/. 

~~~~  

If putting the driver disk in <installroot>/driverdisk/<os>/<arch>: 

     
    [Stateless/Diskless]
      Running 'genimage' in anyway will load the driver disk
    [Statefull/Diskfull]
      Running 'nodeset <nodenrage> in anyway will load the driver disk
~~~~     

## Driver RPM Package

Note: this option is only supported in xCAT 2.8 and later. 

The 'Driver RPM Package' is the rpm package which includes the drivers and firmware for the specific devices. The Driver RPM is the rpm package which is shipped by the Vendor of the device for a new device or a new kernel version. 

### Set the Driver Name and Location of Driver RPM Packages

The Driver RPM packages must be specified in the osimage object. 

Three attributes of osimage object can be used to specify the Driver RPM location and Driver names. If you want to load new drivers in the initrd, the 'netdrivers' attribute must be set. And one or both of the 'driverupdatesrc' and 'osupdatename' attributes must be set. If both of 'driverupdatesrc' and 'osupdatename' are set, the drivers in the 'driverupdatesrc' have higher priority. 

  * **netdrivers** \- comma separated driver names that need to be injected into the initrd. The postfix '.ko' can be ignored. 

The 'netdrivers' attribute must be set to specify the new driver list. If you want to load all the drivers from the driver rpms, use the keyword **allupdate**. Another keyword for the netdrivers attribute is **updateonly**, which means only the drivers located in the original initrd will be added to the newly built initrd from the driver rpms. This is useful to reduce the size of the new built initrd when the distro is updated, since there are many more drivers in the new kernel rpm than in the original initrd. Examples: 
 
~~~~   
    chdef -t osimage <osimagename> netdrivers=megaraid_sas.ko,igb.ko
    chdef -t osimage <osimagename> netdrivers=allupdate
    chdef -t osimage <osimagename> netdrivers=updateonly,igb.ko,new.ko
~~~~   

  * **driverupdatesrc** \- comma separated driver rpm packages (full path should be specified) 

A tag named 'rpm' can be specified before the full path of the rpm to specify the file type. The tag is optional since the default format is 'rpm' if no tag is specified. Example: 
 
~~~~   
    chdef -t osimage <osimagename> driverupdatesrc=rpm:<full path of driver disk1>,rpm:<full path of driver disk2>
    
~~~~

  * **osupdatename** \- comma separated 'osdistroupdate' objects. Each 'osdistroupdate' object specifies a Linux distro update. 

When geninitrd is run, 'kernel-*.rpm' will be searched in the osdistroupdate.dirpath to get all the rpm packages and then those rpms will be searched for drivers. Example: 

~~~~    
    mkdef -t osdistroupdate update1 dirpath=/install/rhels6.4/x86_64/
    chdef -t osimage <osimagename> osupdatename=update1
~~~~    

If 'osupdatename' is specified, the kernel shipped with the 'osupdatename' will be used to load the newly built initrd, then only the drivers matching the new kernel will be kept in the newly built initrd. If trying to use the 'osupdatename', the 'allupdate' or 'updateonly' should be added in the 'netdrivers' attribute, or all the necessary driver names for the new kernel need to be added in the 'netdrivers' attribute. Otherwise the new drivers for the new kernel will be missed in newly built initrd. 

### Inject the Drivers From the Driver RPM into the initrd

~~~~    
    [Stateless/Diskless]
      genimage <osimagename> [--ignorekernelchk]
    [Statefull/Diskfull]
      nodeset <noderange> osimage=<osimagename> [--ignorekernelchk]
     OR:
      geninitrd <osimagename> [--ignorekernelchk]
      nodeset <noderange> osimage=<osimagename> --noupdateinitrd
~~~~    

Note: 'geninitrd' + 'nodeset --noupdateinitrd' is useful when you need to run nodeset frequently for diskful nodes. 'geninitrd' only needs to be run once to rebuild the initrd and 'nodeset --noupdateinitrd' will not touch the initrd and kernel in /tftpboot/xcat/osimage/&lt;osimage name&gt;/. 

The option '--ignorekernelchk' is used to skip the kernel version checking when injecting drivers from osimage.driverupdatesrc. To use this flag, you should make sure the drivers in the driver rpms are usable for the target kernel. 

## Note

  * If the drivers from the driver disk or driver rpm are not already part of the installed or booted system, it's necessary to add the rpm packages for the drivers to the .pkglist or .otherpkglist of the osimage object to install them in the system. 
  * If a driver rpm needs to be loaded, the osimage object must be used for the 'nodeset' and 'genimage' command, instead of the older style profile approach. 
  * Both a Driver disk and a Driver rpm can be loaded in one 'nodeset' or 'genimage' invocation. 
