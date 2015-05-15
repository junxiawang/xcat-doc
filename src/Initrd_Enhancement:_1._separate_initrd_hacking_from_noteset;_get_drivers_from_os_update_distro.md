<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [New Requirements from PCM](#new-requirements-from-pcm)
  - [Understand the New Requirements in xCAT](#understand-the-new-requirements-in-xcat)
- [Outside Interface](#outside-interface)
  - [Generate the Initrd for Stateful Osimage Separately](#generate-the-initrd-for-stateful-osimage-separately)
  - [Run nodeset to Avoid Initrd Update](#run-nodeset-to-avoid-initrd-update)
- [Implementation](#implementation)
  - [The Geninitrd Command](#the-geninitrd-command)
    - [**How to Search the Driver RPMs**](#how-to-search-the-driver-rpms)
    - [**How to Update the Initrd**](#how-to-update-the-initrd)
    - [**How to Update the Linux Kernel**](#how-to-update-the-linux-kernel)
  - [The Nodeset --noupdateinitrd Flag](#the-nodeset---noupdateinitrd-flag)
- [A Work Flow of How to Use Geninitrd and Nodeset Command to Avoid the Initrd Update for Every Nodeset run](#a-work-flow-of-how-to-use-geninitrd-and-nodeset-command-to-avoid-the-initrd-update-for-every-nodeset-run)
  - [Customer adds a custom driver or OS update to a stateful osimage](#customer-adds-a-custom-driver-or-os-update-to-a-stateful-osimage)
  - [Customer runs the "geninitrd &lt;osimage&gt;" command to update the stateful osimage's kernel and initrd files](#customer-runs-the-geninitrd-&ltosimage&gt-command-to-update-the-stateful-osimages-kernel-and-initrd-files)
  - [Customer runs the "nodeset &lt;noderange&gt; osimage=&lt;osimage&gt; \--noupdateinitrd" command to updates the boot files for the nodes which are using the updated stateful osimage](#customer-runs-the-nodeset-&ltnoderange&gt-osimage&ltosimage&gt-%5C--noupdateinitrd-command-to-updates-the-boot-files-for-the-nodes-which-are-using-the-updated-stateful-osimage)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

Currently, xCAT supports to hack the initrd for stateful osimage that loading additional drivers from rpm packages. The usage procedure is: 

  1. Set the rpm path to driverupdatesrc attribute for the osimage &lt;osimg1&gt;; 
  2. Set the name drivers to netdrivers attribute for the osimage &lt;osimg1&gt;. 
  3. Run 'nodeset osimage=osimg1' command, the drivers from driverupdatesrc will be injected to initrd of the &lt;osimg1&gt;. 

### New Requirements from PCM

  * De-couple initrd build process from nodeset (for stateful nodes) 

When nodeset updates the initrd for stateful nodes with third-party kernel drivers, nodeset takes 50-60 sec to run. The longer running time will affect the performance of some PCM operations that depend on nodeset (like node discovery, node import, node reinstall, etc.). Is it possible to de-couple the initrd build process from nodeset? 

  * Rebuild initrd with updated kernel drivers (for stateful nodes) 

If we define an "osdistroupdate" object which has an updated kernel package, link the "osdistroupdate" to a stateful osimage, and then run nodeset on the nodes in the stateful osimage, the nodeset cmd copies the boot initrd from the base OS distro to /tftpboot/xcat/osimage/&lt;osimage&gt;. We would like nodeset to rebuild the boot initrd with the drivers from the updated kernel package. 

### Understand the New Requirements in xCAT

  * The hacking of initrd should not be run every time, since it affects the performance of nodeset (runing once is enough). A new command 'geninitrd' will be added to regenerate (hack) the initrd for an osimage. And a flag '--noupdateinitrd' will be added to nodeset command to avoid the initrd update. If no '--noupdateinitrd' flag is specified for nodeset command, it will work as before. 
  * The paths (osdistroupdate.dirpath) of update distro which set in the osupdatename attribute of osimage will be searched to get the drivers for initrd update. If the updated Linux kernel is included in the update distro, the new **Linux kernel** should also be used to replace the original kernel of the osimage. 

## Outside Interface

### Generate the Initrd for Stateful Osimage Separately

A new command 'geninitrd' is added to regenerate initrd for stateful osimage. 
    
    geninitrd &lt;osimage&gt;
    

The updated driver names are specified in osimage.netdrivers. The value could be comma separated driver names or key word 'allupdate' that update all the drivers from driver rpms. 

The search paths for driver rpms include: osimage.driverupdatesrc, (osimage.osupdatename + osdistroupdate.dirpath). The drivers in osimage.driverupdatesrc has higher priority. If there are multiple osdistroupdate in the osimage.osupdatename, the drivers in the later one has the higher priority. 

### Run nodeset to Avoid Initrd Update

A new flag '--noupdateinitrd' is added for nodeset command to avoid the initrd update. 
    
    nodeset &lt;noderange&gt; osimage=&lt;osimage&gt; --noupdateinitrd
    

If **\--noupdateinitrd** is specified, the nodeset will avoid the initrd and kernel copying from osimage repo like /install/rhels6.3/x86_64/ to /tftpboot/xcat/osimage/rhels6.3-x86_64-install-compute/ 

## Implementation

### The Geninitrd Command

A new plugin 'geninitrd.pm' will be added to handle the 'geninitrd' command. In the geninitrd::preprocess_request(), if 'sharedtftp' is not set to yes or 1, the command request will be dispatched to all the service node. In the process_request(), the osimage information will be gotten from tables to know what's the os distro (rh, sles ...), then call the insert_dd() function in the anaconda.pm or sles.pm according to the distro type to update the initrd. 

#### **How to Search the Driver RPMs**

The os update distro is defined as xCAT obj type 'osdistroupdate', it can be set to the attribute 'osupdatename' of osimage to specify the update distro list. 

If set the 'osimg1-&gt;osupdatename = osup1,osup2' (refer to osimage table), that means osup1 and osup2 are two os update distros with type 'osdistroupdate'. And if osup1-&gt;dirpath = /osup1/, and osup2-&gt;dirpath = /osup2/ (refer to table osdistroupdate), that means if run 'geninitrd', the paths '/osup1' and '/osup2' will be searched to get the rpm packages which name match the format 'kernerl-*.rpm'. 

Plus the original search path 'linuximage.driverupdatesrc', there will be two places to search the rpms for update to date drivers. The drivers in 'linuximage.driverupdatesrc' will have high priority. That means the rpm search order will be: osup1, osup2, osupX..., driverupdatesrc. If the drivers file for certain driver exists in the rpm which in the later search path, it will replace the previous one. 

e.g. for driver bnx2.ko, if it existed in osup1, osup2 and driverupdatesrc, the one in driverupdatesrc will be used. 

#### **How to Update the Initrd**

The original initrd will be copied from e.g. /install/rhels6.3/x86_64/ to /tftpboot/xcat/osimage/rhels6.3-x86_64-install-compute/ first and inject the drivers from the driver rpms base on the value of osimage.netdrivers. 

  * If the value of osimage.netdrivers is comma separated driver names, drivers in the list will be injected to initrd. 
  * If the value of osimage.netdrivers is key word 'allupdate', all the drivers from driver rpms will be injected to initrd. 

#### **How to Update the Linux Kernel**

The latest Linux kernel in the kernel-*.rpm from update distro will be searched and copied to the /tftpboot/xcat/osimage/&lt;osimage name&gt;/ when running the geninitrd command against an osimage. 

Code will not compare that which Linux kernel is the latest one if there are multiple os update distros in osimage.osupdatename. The kernel in the last one which listed in the osimage.osupdatename will be copied to /tftpboot/xcat/osimage/rhels6.3-x86_64-install-compute/ and used as the latest kernel for initrd. 

e.g. if osimg1-&gt;osupdatename = osup1,osup2, the kernel from osup2 will be used. 

### The Nodeset --noupdateinitrd Flag

The **\--noupdateinitrd** argument will be passed from netboot method plugin like xnba.pm to destiny.pm and then passed to anaconda.pm or sles.pm. In the anaconda.pm and sles.pm, if **\--noupdateinitrd** is specified, nodeset will avoid the initrd and kernel copying from /install/rhels6.3/x86_64/ to /tftpboot/xcat/osimage/rhels6.3-x86_64-install-compute/ 

## A Work Flow of How to Use Geninitrd and Nodeset Command to Avoid the Initrd Update for Every Nodeset run

### Customer adds a custom driver or OS update to a stateful osimage

    The custom driver is defined using osimage.netdrivers 
    The driver rpm is defined using osimage.driverupdatesrc attributes. 
    The OS update is defined using osimage.osupdatename + osdistroupdate.dirpath attributes. 

### Customer runs the "geninitrd &lt;osimage&gt;" command to update the stateful osimage's kernel and initrd files

  * The kernel file is updated by geninitrd as follows: 

If the osimage has an OS update, and that update has a new kernel package, then the vmlinuz file from the new kernel package is copied to /tftpboot/xcat/osimages/&lt;osimages&gt;

If the osimage does not have an OS update, then the vmlinuz file from the original OS distro (e.g., /install/rhels6.3/x86_64) is copied to /tftpboot/xcat/osimages/&lt;osimages&gt;

  * The initrd file is updated by geninitrd as follows: 

If the osimage has an OS update, or custom driver defined, the initrd is re-built and copied to /tftpboot/xcat/osimages/&lt;osimage&gt;

If the osimage does not have an OS update nor a custom driver defined, then the initrd file from the original OS distro (e.g., /install/rhels6.3/x86_64) is copied to /tftpboot/xcat/osimages/&lt;osimages&gt;

### Customer runs the "nodeset &lt;noderange&gt; osimage=&lt;osimage&gt; \--noupdateinitrd" command to updates the boot files for the nodes which are using the updated stateful osimage

The "--noupdateinitrd" flag will prevent nodeset from overwriting the existing vmlinuz and initrd files in /tftpboot/xcat/osimages/&lt;osimages&gt;

## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: add a new command geninitrd 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
