<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Solutions](#solutions)
  - [Advantages](#advantages)
  - [Disadvantages](#disadvantages)
  - [Limitations](#limitations)
- [Configuring Statelite](#configuring-statelite)
  - [**litefile table**](#litefile-table)
    - [Sample Data for a RedHat statelite setup.](#sample-data-for-a-redhat-statelite-setup)
    - [Sample Data for Redhat6 statelite setup](#sample-data-for-redhat6-statelite-setup)
    - [Sample Data for SLES11 statelite setup](#sample-data-for-sles11-statelite-setup)
    - [**Sample Data for Fedora13/14 statelite setup**](#sample-data-for-fedora1314-statelite-setup)
    - [/etc/resolv.conf](#etcresolvconf)
  - [**litetree** table](#litetree-table)
  - [**statelite table**](#statelite-table)
  - [Policy](#policy)
  - [Add Linux Distro Packages](#add-linux-distro-packages)
  - [**Generate the statelite image for compute node provmethod=osimage**](#generate-the-statelite-image-for-compute-node-provmethodosimage)
    - [**Using provmethod=osimagename**](#using-provmethodosimagename)
    - [**Setup to use an osimage name**](#setup-to-use-an-osimage-name)
    - [**Create your statelite osimage**](#create-your-statelite-osimage)
      - [**Create the osimage definition**](#create-the-osimage-definition)
      - [**Setup pkglists**](#setup-pkglists)
      - [Install other specific packages](#install-other-specific-packages)
      - [**Setting up postinstall files (optional)**](#setting-up-postinstall-files-optional)
      - [Configure postinstall files for Power 775 (Optional)](#configure-postinstall-files-for-power-775-optional)
      - [Setting up Files to be synchronized on the nodes](#setting-up-files-to-be-synchronized-on-the-nodes)
      - [Setup the node to use your osimage](#setup-the-node-to-use-your-osimage)
      - [Generate/pack your image](#generatepack-your-image)
      - [Generate/Pack your image for Power 775](#generatepack-your-image-for-power-775)
      - [**Boot the node**](#boot-the-node)
  - [Generate the statelite image for compute node provmethod=statelite](#generate-the-statelite-image-for-compute-node-provmethodstatelite)
    - [Make the compute node add/exclude packaging list](#make-the-compute-node-addexclude-packaging-list)
    - [Setting up postinstall files](#setting-up-postinstall-files)
    - [**Configure postinstall files for Power 775 (Optional)**](#configure-postinstall-files-for-power-775-optional)
    - [Run image generation](#run-image-generation)
    - [Run image generation for Power 775](#run-image-generation-for-power-775)
    - [Sync /etc/hosts to the diskless image for Power 775](#sync-etchosts-to-the-diskless-image-for-power-775)
    - [Pack the image](#pack-the-image)
  - [**Add Third-Party Software**](#add-third-party-software)
  - [**Create Statelite Image**](#create-statelite-image)
    - [**The postinstall file**](#the-postinstall-file)
    - [The genimage Command](#the-genimage-command)
  - [Setting up Post install scripts for statelite](#setting-up-post-install-scripts-for-statelite)
  - [Modify statelite image](#modify-statelite-image)
  - [(Optional) Switch to the RAMdisk-based solution](#optional-switch-to-the-ramdisk-based-solution)
  - [Run liteimg command](#run-liteimg-command)
  - [Set the boot state to statelite](#set-the-boot-state-to-statelite)
  - [Install the Node](#install-the-node)
- [Commands](#commands)
- [Statelite Directory Structure](#statelite-directory-structure)
  - [**The noderes Table**](#the-noderes-table)
- [Adding/updating software and files for the running nodes](#addingupdating-software-and-files-for-the-running-nodes)
  - [Make changes to the files which configured in the litefile table](#make-changes-to-the-files-which-configured-in-the-litefile-table)
  - [Make changes to the common files](#make-changes-to-the-common-files)
- [Hierarchy Support](#hierarchy-support)
  - [Setup the diskfull service node](#setup-the-diskfull-service-node)
  - [Generate the statelite image](#generate-the-statelite-image)
  - [Sync the /install directory](#sync-the-install-directory)
  - [Set the boot state to statelite](#set-the-boot-state-to-statelite-1)
  - [Install the Node](#install-the-node-1)
- [Advanced Statelite features](#advanced-statelite-features)
  - [Both directory and its child items coexist in litefile table](#both-directory-and-its-child-items-coexist-in-litefile-table)
  - [The hierarchy scenarios](#the-hierarchy-scenarios)
  - [litetree table](#litetree-table)
  - [Installing a new Kernel in the statelite image (This is not verified)](#installing-a-new-kernel-in-the-statelite-image-this-is-not-verified)
  - [Enabling the **localdisk** Option](#enabling-the-localdisk-option)
- [Debugging techniques](#debugging-techniques)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document details the design and setup for the statelite solution of xCAT. Statelite is an intermediate state between .stateful. and .stateless..

Statelite provides two kinds of efficient and flexible diskless solutions, most of the OS image can be NFS mounted read-only, or the OS image can be in the ramdisk with tmpfs type. Different from the state-less solution, statelite provides a configurable list of directories and files that can be read-write. These read-write directories and files can either be persistent across reboots, or volatile (which means restoring to the original state after reboot).

### Solutions

Currently, there are two solutions, **NFSROOT-based** and **RAMdisk-based**.

There is an attribute named rootfstype in the osimage xCAT data objects. If it is set to "ramdisk", the RAMdisk-based statelite solution will be enabled. If it is left as blank, or set to "nfs", the NFSROOT-base statelite solution will be enabled.

The default solution is NFSROOT-based. In the NFSROOT-based solution, the ROOTFS is NFS mounted read-only.

In the RAMdisk-based statelite solution, one image file will be downloaded when the node is booting up, and the file will be extracted to the ramdisk, and used as the ROOTFS.

### Advantages

Statelite offers the following **advantages** over xCAT's stateless (RAMdisk) implementation:

  1. Some files can be made persistent over reboot. This is useful for license files or database servers where some state is needed. However, you still get the advantage of only having to manage a single image.
  2. Changes to hundreds of machines can take place instantly, and automatically, by updating one main image. In most cases, machines do not need to reboot for these changes to take affect. (**only for the NFSROOT-based solution**)
  3. Ease of administration by being able to lock down an image. Many parts of the image can be read-only, so no modifications can transpire without updating the central image.
  4. Files can be managed in a hierarchical manner. For example: Suppose you have a machine that is in one lab in Tokyo and another in London. You could set table values for those machines in the xCAT database to allow machines to sync from different places based on their attributes. This allows you to have one base image with multiple sources of file overlay.
  5. Ideal for virtualization. In a virtual environment, you may not want a disk image (neither stateless nor stateful) on every virtual node as it consumes memory and disk. Virtualizing with the statelite approach allows for images to be smaller, easier to manage, use less disk, less memory, and more flexible.




### Disadvantages

However, there're still several disadvantages, especially for the **NFSROOT**-based solution.

  1. NFS Root requires more network traffic to run as the majority of the disk image runs over NFS. This may depend on your workload, but can be minimized. Since the bulk of the image is read-only, NFS caching on the server helps minimize the disk access on the server, and NFS caching on the client helps reduce the network traffic.
  2. NFS Root can be complex to set up. As more files are created in different places, there are greater chances for failures. This flexibility is also one of the great virtues of Statelite. The image can work in nearly any environment.

### Limitations

Currently, statelite has only been tested on Red Hat and Red Hat Clone environments on x86_64 and ppc64 platforms, and also SLES11 (SuSE Linux Enterprise Server 11) on POWER systems. There is no reason to think SLES11 on x86_64 will not work, and we are in the process of testing that.

Only one statelite image may be defined for a node or noderange.

## Configuring Statelite

Getting started with Statelite provisioning requires that you have xCAT set up and running. Before continuing with the rest of this document, the xCAT management node must be set up, and the nodes' hardware control, resource, and type attributes must be defined as described here: [Setting_Up_a_Linux_xCAT_Mgmt_Node]


The operating system image files and the statelite files can be put on the service nodes or the management node, or any external NFS server. If you want to put all the operating system images and/or statelite files on an external NFS server, refer to the documentation [External_NFS_Server_Support_With_Linux_Statelite] for more details.

### **litefile table**

The [litefile](http://xcat.sourceforge.net/man5/litefile.5.html) table specifies the directories and files on the statelite nodes that should be read/write, persistent, or read-only overlay. All other files in the statelite nodes come from the read-only statelite image. The first column in the litefile table is the image name this row applies to. It can be an exact [osimage](http://xcat.sourceforge.net/man7/osimage.7.html) definition name, an osimage group (set in the groups attribute of osimages), or the keyword ALL.

The second column in the litefile table is the full path of the directory or file on the node that you are setting options for.

The third column in the litefile table specifies options for the directory or file:

  1. **tmpfs **\- It provides a file or directory for the node to use when booting, its permission will be the same as the original version on the server. In most cases, it is read-write; however, on the next statelite boot, the original version of the file or directory on the server will be used, it means it is non-persistent. This option can be performed on files and directories.
  2. **rw **\- Same as Above.Its name "rw" does NOT mean it always be read-write, even in most cases it is read-write. Do not confuse it with the "rw" permission in the file system.
  3. **persistent** \- It provides a mounted file or directory that is copied to the xCAT persistent location and then over-mounted on the local file or directory. Anything written to that file or directory is preserved. It means, if the file/directory does not exist at first, it will be copied to the persistent location. Next time the file/directory in the persistent location will be used. The file/directory will be persistent across reboots. Its permission will be the same as the original one in the statelite location. It requires the statelite table to be filled out with a spot for persistent statelite. This option can be performed on files and directories.
  4. **con **\- The contents of the pathname are concatenated to the contents of the existing file. For this directive the searching in the litetree hierarchy does not stop when the first match is found. All files found in the hierarchy will be concatenated to the file when found. The permission of the file will be "-rw-r--r--", which means it is read-write for the root user, but readonly for the others. It is non-persistent, when the node reboots, all changes to the file will be lost. It can only be performed on files. Do not use it for one directory.
  5. **ro **\- The file/directory will be overmounted read-only on the local file/directory. It will be located in the directory hierarchy specified in the litetree table. Changes made to this file or directory on the server will be immediately seen in this file/directory on the node. This option requires that the file/directory to be mounted must be available in one of the entries in the litetree table. This option can be performed on files and directories.
  6. **tmpfs,rw**\- Only for compatibility it is used as the **default** option if you leave the options column blank. It has the same semantics with the **link** option, so when adding new items into the _litefile table, the **link** option is recommended.
  7. **link **\- It provides one file/directory for the node to use when booting, it is copied from the server, and will be placed in tmpfs on the booted node. In the local file system of the booted node, it is one symbolic link to one file/directory in tmpfs. And the permission of the symbolic link is "lrwxrwxrwx", which is not the real permission of the file/directory on the node. So for some application sensitive to file permissions, it will be one issue to use "link" as its option, for example, "/root/.ssh/", which is used for SSH, should NOT use "link" as its option. It is non-persistent, when the node is rebooted, all changes to the file/directory will be lost. This option can be performed on files and directories.
  8. **link,ro **\- The file is readonly, and will be placed in tmpfs on the booted node. In the local file system of the booted node, it is one symbolic link to the tmpfs. It is non-persistent, when the node is rebooted, all changes to the file/directory will be lost. This option requires that the file/directory to be mounted must be available in one of the entries in the litetree table. The option can be performed on files and directories.
  9. **link,con** -It works similar to the "con" option. All the files found in the litetree hierarchy will be concatenated to the file when found. The final file will be put to the tmpfs on the booted node. In the local file system of the booted node, it is one symbolic link to the file/directory in tmpfs. It is non-persistent, when the node is rebooted, all changes to the file will be lost. The option can only be performed on files.
  10. **link,persistent** \- It provides a mounted file or directory that is copied to the xCAT persistent location and then over-mounted to the tmpfs on the booted node, and finally the symbolic link in the local file system will be linked to the over-mounted tmpfs file/directory on the booted node. The file/directory will be persistent across reboots. The permission of the file/directory where the symbolic link points to will be the same as the original one in the statelite location. It requires the statelite table to be filled out with a spot for persistent statelite. The option can be performed on files and directories.

  11. **localdisk** \- The file or directory will be stored in the local disk of the statelite node. Refer to the section [To enable the localdisk option](XCAT_Linux_Statelite/#enabling-the-localdisk-option) to enable the 'localdisk' support.

Currently, we don't handle the relative links very well. The relative links are commonly used by the system libraries, for example, under **/lib/** directory, there will be one relative link matching one .so file. So, when you add one relative link to the litefile table (We don't recommend ), make sure the real file also be included, or you can put its directory name into the litefile table. However, most of the users will not put the relative links in the litefile table.


The setup for RedHat and SLES are below.

'Note: '**It is recommended that you specify at least the entries listed below in the litefile table, because most of these files need to be writeable for the node to boot up successfully. When any changes are made to their options'**, make sure they '**won't affect the whole system.**

#### Sample Data for a RedHat statelite setup.

**This is the minimal list of files needed, you can add additional files to the litefile table. **


Notice that at all files are in tmpfs, the default for the options field. This gives you an NFS root solution with no persistent storage.

~~~~


    #image,file,options,comments,disable
    "ALL","/etc/adjtime","tmpfs",,
    "ALL","/etc/fstab","tmpfs",,
    "ALL","/etc/lvm/","tmpfs",,
    "ALL","/etc/syslog.conf","tmpfs",,
    "ALL","/etc/syslog.conf.XCATORIG","tmpfs",,
    "ALL","/etc/ntp.conf","tmpfs",,
    "ALL","/etc/ntp.conf.predhclient","tmpfs",,
    "ALL","/etc/resolv.conf","tmpfs",,
    "ALL","/etc/resolv.conf.predhclient","tmpfs",,
    "ALL","/etc/ssh/","tmpfs",,
    "ALL","/etc/sysconfig/","tmpfs",,
    "ALL","/etc/inittab","tmpfs",,
    "ALL","/tmp/","tmpfs",,
    "ALL","/var/","tmpfs",,
    "ALL","/opt/xcat/","tmpfs",,
    "ALL","/xcatpost/","tmpfs",,
    "ALL","/root/.ssh/","tmpfs",,
~~~~


#### Sample Data for Redhat6 statelite setup

**This is the minimal list of files needed, you can add additional files to the litefile table.**

~~~~
    #image,file,options,comments,disable
    "ALL","/etc/adjtime","tmpfs",,
    "ALL","/etc/securetty","tmpfs",,
    "ALL","/etc/lvm/","tmpfs",,
    "ALL","/etc/ntp.conf","tmpfs",,
    "ALL","/etc/rsyslog.conf","tmpfs",,
    "ALL","/etc/rsyslog.conf.XCATORIG","tmpfs",,
    "ALL","/etc/udev/","tmpfs",,
    "ALL","/etc/ntp.conf.predhclient","tmpfs",,
    "ALL","/etc/resolv.conf","tmpfs",,
    "ALL","/etc/yp.conf","tmpfs",,
    "ALL","/etc/resolv.conf.predhclient","tmpfs",,
    "ALL","/etc/sysconfig/","tmpfs",,
    "ALL","/etc/ssh/","tmpfs",,
    "ALL","/etc/inittab","tmpfs",,
    "ALL","/tmp/","tmpfs",,
    "ALL","/var/","tmpfs",,
    "ALL","/opt/xcat/","tmpfs",,
    "ALL","/xcatpost/","tmpfs",,
    "ALL","/root/.ssh/","tmpfs",,
~~~~


#### Sample Data for SLES11 statelite setup

**This is the minimal list of files needed, you can add additional files to the litefile table. **




~~~~
    #image,file,options,comments,disable
    "ALL","/etc/lvm/","tmpfs",,
    "ALL","/etc/ntp.conf","tmpfs",,
    "ALL","/etc/ntp.conf.org","tmpfs",,
    "ALL","/etc/resolv.conf","tmpfs",,
    "ALL","/etc/ssh/","tmpfs",,
    "ALL","/etc/sysconfig/","tmpfs",,
    "ALL","/etc/syslog-ng/","tmpfs",,
    "ALL","/etc/inittab","tmpfs",,
    "ALL","/tmp/","tmpfs",,
    "ALL","/var/","tmpfs",,
    "ALL","/etc/yp.conf","tmpfs",,
    "ALL","/etc/fstab","tmpfs",,
    "ALL","/opt/xcat/","tmpfs",,
    "ALL","/xcatpost/","tmpfs",,
    "ALL","/root/.ssh/","tmpfs",,
~~~~


#### **Sample Data for Fedora13/14 statelite setup**

Refer to the setup of Redhat6.


Use the command

~~~~
    tabedit litefile
~~~~


to copy/paste the above sample lines into the litefile table.




#### /etc/resolv.conf

Special setup for /etc/resolv.conf needed. **Note:** The following issue has been fixed in the 2.5.x and 2.6 releases. If you are using the latest Version 2.6 build, or Version 2.5.*, the instructions below for setting up /etc/resolv.conf can be ignored. Go to the section "litetree table".

We have two solutions:

1) Edit the /.default/etc/resolv.conf file in the statelite image

Make sure you know the domain and nameserver for all the statelite nodes,

then edit the file .default/etc/resolv.conf in the statelite image like this:

~~~~
    search <DOMAIN>
    nameserver <NAMESERVER>
~~~~


Replace &lt;DOMAIN&gt; with the domain for all the statelite nodes.

Replace &lt;NAMESERVER&gt; with the nameserver for all the statelite nodes.


Or you can:

2) Put one working /etc/resolv.conf file to one NFS directory, then, add the
NFS directory to the litetree table. For example, create one directory named
/lite/tree/, and export it as one NFS directory on your MN; then, put one
working /etc/resolv.conf into /lite/tree. Finally, add one entry to the
litetree table like this:

~~~~
    #priority,image,directory,comments,disable
    1,,"<MN IP>:/lite/tree",,
~~~~


Replace &lt;MNIP&gt; with your MN's IP address.

### **litetree** table

The litetree table controls where the initial content of the files in the litefile table come from, and the long term content of the "ro" files. When a node boots up in statelite mode, it will by default copy all of its tmpfs files from the /.default directory of the root image, so there is not required to set up a litetree table. If you decide that you want some of the files pulled from different locations that are different per node, you can use this table. See Advanced Statelite features.


You can choose to use the defaults and not set up a litetree table.

### **statelite table**

You may want some files in the image to be stored permanently, to survive reboots. This is done by entering the information into the statelite table.


See the [statelite man page](http://xcat.sourceforge.net/man5/statelite.5.html) for description of the attributes.


Note: In the statelite table, the node or nodegroups in the table must be unique; that is a node or group should appear only once in the first column table. This makes sure that only one statelite image can be assigned to a node. See Limitations.


An example would be:

~~~~
    "compute",,"<nfssvr_ip>:/gpfs/state",,
~~~~



Any nodes in the compute node group will have their state stored in the /gpfs/state directory on the machine with &lt;nfssvr_ip&gt; as its IP address. The image attribute should be left blank - currently it is not used.


When the node boots up, then the value of the statemnt attribute will be mounted to /.statelite/persistent. The code will then create the following subdirectory /.statelite/persistent/&lt;nodename&gt; if there are persistent files that have been added in the litefile table. This directory will be the root of the image for this node's persistent files. By default, xCAT will do a hard NFS mount of the directory. You can change the mount options by setting the mntopts attribute in the statelite table.


Also, to set the statemnt attribute, you can use variables from xCAT database. It follows the same grammar as the litetree table. For example:

~~~~
     #node,image,statemnt,mntopts,comments,disable
     "hv32lpar05",,"$noderes.nfsserver:/lite/state/$nodetype.profile","soft,timeo=30",,
~~~~



**Note**: Do not name your persistent storage directory with the node name, as the node name will be added in the directory automatically. If you do, then a directory named /state/n01 will have its state tree inside /state/n01/n01.

### Policy

Ensure policies are set up correctly in the Policy Table. When a node boots up, it queries the xCAT database to get the litefile and litetree table information. In order for this to work, the commands (of the same name) must be set in the policy table to allow nodes to request it. This should happen automatically when xCAT is installed, but you may want to verify that the following lines are in the policy table:




~~~~
    chdef -t policy -o 4.7 commands=litefile rule=allow
    chdef -t policy -o 4.8 commands=litetree rule=allow
~~~~


### Add Linux Distro Packages

If you haven't already done so, copy the packages from the distro media into /install. For example:

~~~~
    copycds /iso/RHEL5.2-Server-20080430.0-x86_64-DVD.iso
~~~~



Now create a list of distro packages that should be installed into the image. You should start with the base packages in the compute template. These are required. The shipped templates are found in the /opt/xcat/share/xcat/netboot/&lt;os&gt; directory. You can use these defaults, but if you modify them first copy them into the

/install/custom/netboot/&lt;os&gt; directory, so the modifications will not be lost on the next xCAT upgrade. The code will first look in the "custom" directory before looking in the "share" path.


For example:

~~~~
    mkdir -p /install/custom/netboot/rh
    cd /install/custom/netboot/rh
    cp /opt/xcat/share/xcat/netboot/rh/compute.pkglist compute.pkglist
~~~~


You can then add more packages to the compute pkglist by editing compute.pkglist.

### **Generate the statelite image for compute node provmethod=osimage**

There are two ways to setup to generate a statelite image. You can use the node's provisioning method set to statelite. There is a more convenient method, to use the provisioning method set to an osimage name. If you desire to use statelite, go to the section: [XCAT_Linux_Statelite/#generate-the-statelite-image-for-compute-node-provmethodosimage](XCAT_Linux_Statelite/#generate-the-statelite-image-for-compute-node-provmethodosimage).

#### **Using provmethod=osimagename**

**To use an osimage as your provisioning method, you should be running xCAT 2.6.6 or later.** The provisioning method (provmethod) for node deployment determines the path for important files used during the image generation, install and updatenode process. The valid values for provmethod are **install, netboot, statelite** or an **osimage name** from the osimage table.

To determine the current provmethod of your node, run:

~~~~
    lsdef <noderange>
~~~~


Look at the provmethod attribute setting.

If an osimage name is specified for the provmethod, the osimage attribute settings stored in the osimage and linuximage table (for Linux) or the osimage and nimimage table (for AIX) are used to locate the files for templates, *pkglists, syncfiles, etc.

**Note: syncfiles is not currently supported for statelite nodes**. See attributes in the osimage, linuximage and nimimage tables. (For example:

~~~~
     tabdump -d osimage  - common to both AIX and Linux
     tabdump -d linuximage - Linux specific
     tabdump -d nimimage - AIX specific
~~~~


or:

~~~~
     lsdef -h -t osimage   - to list all the image attributes
     lsdef -t osimage      - to list the images you currently have defined
     lsdef -t osimage -o <imagename>    - to list all the attribute settings for that image
~~~~





There are advantages to use provmethod=osimagename. You can specify in the *image table any directory that you want to use to hold your template, *pkglists,otherpkgs*, syncfile etc and not be limited to the directory defined in the site table installdir attribute (usually /install) and the search paths structure used by xCAT when the provmethod is install,netboot or statelite.

**For a hierarchical cluster, the files must be placed under the site table installdir attribute path (usually /install ) directory, so they will be available when mounted on the service nodes.** The site table installdir directory, is mounted or copied to the service nodes during the hierarchical install of compute nodes from the service nodes.

#### **Setup to use an osimage name**

For our example, we are going to create a new compute node test osimage for rhels6 on ppc64. This works fine for other archtectures ( e.g. x86_64). Just substitute your architecture in the paths ( e.g. x86_64). We will set up a test directory structure that we can use to create our image. Later we can just move that into production.


Use the copycds command to copy the appropriate iso image into the /install directory for xCAT. The copycds commands will copy the contents to /install/rhels6/&lt;arch&gt;. For example:

~~~~
    mkdir /iso
    cd /iso
    copycds RHEL6.0-20100922.1-Server-ppc64-DVD1.iso
~~~~


The contents are copied into /install/rhels6/ppc64/

When copycds runs, it will automatically create default osimage names and paths in the osimage table and the linuximage table based on the os and architecture you are using. It will create images for install, netboot and for statelite. You can use these defaults as a starting point to create your own osimage definitions, or you can create your own image definition. We are going to use the statelite generated image for our example.

The configuration files pointed to by the attributes are the defaults shipped with xCAT. We will want to copy them to the /install directory, in our example the /install/test directory and modify them as needed.

~~~~
     lsdef -t osimage -o rhels6-ppc64-statelite-compute
     Object name: rhels6-ppc64-statelite-compute
       imagetype=linux
       nodebootif=eth0
       osarch=ppc64
       osdistro=rh
       osname=Linux
       osvers=rhels6
       otherpkgdir=/install/post/otherpkgs/rhels6/ppc64
       permission=755
       pkgdir=/install/rhels6/ppc64
       pkglist=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.pkglist
       postinstall=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.postinstall
       profile=compute
       provmethod=statelite
       rootimgdir=/install/netboot/rhels6/ppc64/compute
~~~~


#### **Create your statelite osimage**

Setup your osimage/linuximage tables with new test image name, osvers,osarch, and paths to all the files for building and installing the node. So using the above generated "**rhels6-ppc64-statelite-compute**" as an example, I am going to create my own image.The value for the provmethod attribute is statelite in my example.

      mkdef -t osimage -o redhat6img \
      profile=compute imagetype=linux provmethod=statelite osarch=ppc64 osname=linux osvers=rhels6


Check your setup:

~~~~
     lsdef -t osimage redhat6img
     Object name: redhat6img
       imagetype=linux
       osarch=ppc64
       osname=linux
       osvers=rhels6
       profile=compute
       provmethod=statelite
~~~~


##### **Create the osimage definition**

Add the paths to your *pkglist, syncfile, etc to the osimage definition, that you require. Note, if you modify the files on the /opt/xcat/share/... path then copy to the appropriate /install/custom/... path. Remember all files must be under /install if using hierarchy (service nodes).

Copy the sample *list files and modify as needed:

~~~~
    mkdir -p /install/test/netboot/rh
    cp -p /opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.pkglist \
    /install/test/netboot/rh/compute.pkglist
    cp -p /opt/xcat/share/xcat/netboot/rh/compute.exlist \
    /install/test/netboot/rh/compute.exlist
~~~~





~~~~
    chdef -t osimage -o redhat6img \
      pkgdir=/install/rhels6/ppc64 \
      pkglist=/install/test/netboot/rh/compute.pkglist \
      exlist=/install/test/netboot/rh/compute.exlist \
      rootimgdir=/install/test/netboot/rh/ppc64/compute

~~~~

Check your setup:

~~~~
    lsdef -t osimage -o redhat6img
    Object name: redhat6img
       exlist=/install/test/netboot/rh/compute.exlist
       imagetype=linux
       osarch=ppc64
       osname=linux
       osvers=rhels6
       pkgdir=/install/rhels6/ppc64
       pkglist=/install/test/netboot/rh/compute.pkglist
       profile=compute
       provmethod=statelite
       rootimgdir=/install/test/netboot/rh/ppc64/compute
~~~~


##### **Setup pkglists**

In the above example, you have defined your pkglist to be in /install/test/netboot/rh/compute.pkglist.

Edit compute.pkglist and compute.exlist as needed.

~~~~
    cd /install/test/netboot/rh/
    vi compute.pkglist compute.exlist
~~~~


For example to add vi to be installed on the node, add the name of the vi rpm to compute.pkglist. Make sure nothing is excluded in compute.exlist that you need.

##### Install other specific packages

Make the directory to hold additional rpms to install on the compute node.

~~~~
    mkdir -p /install/test/post/otherpkgs/rh/ppc64
~~~~


Now copy all the additional OS rpms you want to install into /install/test/post/otherpkgs/rh/ppc64.

If are a Power 775 cluster:' For rhels 6, you need to install the powerpc-utils-1.2.2-18.el6.ppc64.rpm into the diskless image during genimage:

1\. download the rpm from the link:

~~~~
     ftp://linuxpatch.ncsa.uiuc.edu/PERCS/powerpc-utils-1.2.2-18.el6.ppc64.rpm
~~~~


2\. add to /install/test/post/otherpkgs/rh/ppc64 directory and /install/test/netboot/rh/otherpkgs.pkglist file

In our example edit the compute.otherpkgs.pkglist file and add the one rpm.

~~~~
    vi /install/test/netboot/rh/compute.otherpkgs.pkglist
    powerpc-utils-*
~~~~



If you add any additional rpms, you **MUST** create repodata for this directory. You can use the "createrepo" command to create repodata.

At first you need to create one text file which contains the complete list of files to include in the repository. The name of the text file is rpms.list and must be in /install/test/post/otherpkgs/rh/ppc64 directory. Create rpms.list:

~~~~
    cd /install/test/post/otherpkgs/rh/ppc64
    ls *.rpm > rpms.list
~~~~



Then, run the following command to create the repodata for the newly-added packages:

~~~~
    createrepo -i rpms.list /install/test/post/otherpkgs/rh/ppc64
~~~~


The createrepo command with -i rpms.list option will create the repository for the rpm packages listed in the rpms.list file. It won't destroy or affect the rpm packages that are in the same directory, but have been included into another repository.

**Or**, if you create a **sub-directory** to contain the rpm packages, for example, named **other** in /install/test/post/otherpkgs/rh/ppc64. Run the following command to create repodata for the directory /install/test/post/otherpkgs/rh/ppc64.

~~~~
    createrepo /install/post/otherpkgs/<os>/<arch>/**other**
~~~~


Note: Replace **other** with your real directory name.


Define the location of of your otherpkgs in your osimage:

~~~~
    chdef -t osimage -o redhat6img \
    otherpkgdir=/install/test/post/otherpkgs/rh/ppc64 \
    otherpkglist=/install/test/netboot/rh/compute.otherpkgs.pkglist
~~~~



**There are examples under /opt/xcat/share/xcat/netboot/&lt;platform&gt; of typical *otherpkgs.pkglist files that can used as an example of the format.**

##### **Setting up postinstall files (optional)**

**If you have a Power 775 cluster go to the next section "Configure postinstall files for Power 775 (Optional)".**

Using postinstall files is optional. There are some examples shipped in /opt/xcat/share/xcat/netboot/&lt;platform&gt;.

If you define a postinstall file to be used by genimage, then

~~~~
     chdef -t osimage -o redhat6img postinstall=<your postinstall file path>.
~~~~


##### Configure postinstall files for Power 775 (Optional)

**IF not using Power 775 hardware, skip this section.** **** The HFI kernel can be installed by xCAT automatically. Other packages, such as hfi_util and nettools, require the rpm options --nodeps or --force respectively, which xCAT cannot handle automatically. We need to modify the postinstall file to install those packages during the diskless image generation.

Add the following lines to /install/test/netboot/rh/hfi.postinstall. (You can use any name you desire for the file, this is an example.

~~~~
    cp /hfi/dd/* /install/test/netboot/rh/ppc64/compute/rootimg/tmp/
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhclient-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhcp-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/kernel-headers-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/net-tools-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_ndai-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_util-*.rpm' --force
~~~~


Now update the image definition with the postinstall file location:

~~~~
    chdef -t osimage -o redhat6img postinstall=/install/test/netboot/rh/hfi.postinstall
~~~~


##### Setting up Files to be synchronized on the nodes

If you need to setup synclist, create you synclist file: See doc for setting up synclists: [Sync-ing_Config_Files_to_Nodes]

##### Setup the node to use your osimage

~~~~
     chdef -t node -o node1 provmethod=redhat6img
     lsdef node1 | grep provmethod

       provmethod=redhat6img
~~~~


##### Generate/pack your image

If you have a Power 775 cluster, go to the next section on **Generate Pack image for Power 775**. Run the following command to generate the image based on your osimage named redhat6img. Adjust your genimage parameters to your architecture and network settings. See **man genimage**.&nbsp;:

~~~~
    genimage  -n ibmveth redhat6img
    liteimg redhat6img
~~~~


The genimage will create a default /etc/fstab in the image, for example:

~~~~
    devpts  /dev/pts devpts   gid=5,mode=620 0 0
    tmpfs   /dev/shm tmpfs    defaults       0 0
    proc    /proc    proc     defaults       0 0
    sysfs   /sys     sysfs    defaults       0 0
    tmpfs   /tmp     tmpfs    defaults,size=10m             0 2
    tmpfs   /var/tmp     tmpfs    defaults,size=10m       0 2
    compute_x86_64    /   tmpfs   rw  0 1
~~~~



If you want to change the defaults, on the management node, edit fstab in the image:

~~~~
    cd /install/netboot/rhels6/x86_64/compute/rootimg/etc
    cp fstab fstab.ORIG
    vi fstab
~~~~


Change these settings:


~~~~
    proc /proc proc rw 0 0
    sysfs /sys sysfs rw 0 0
    devpts /dev/pts devpts rw,gid=5,mode=620 0 0
    #tmpfs /dev/shm tmpfs rw 0 0
    compute_x86_64 / tmpfs rw 0 1
    none /tmp tmpfs defaults,size=10m 0 2
    none /var/tmp tmpfs defaults,size=10m 0 2
~~~~


Note: adding /tmp and /var/tmp to /etc/fstab is optional, most installations can simply use /. It was documented her to show that you can restrict the size of filesystems, if you need to. The indicated values are just and example, and you may need much bigger filessystems, if running applications like OpenMPI.

##### Generate/Pack your image for Power 775

If not using Power 775 hardware, skip this section and go to "**Boot the node**". In Power 775, there is a HFI enabled kernel required in the diskless image. The compute nodes could boot from this customized kernel and boot from HFI interfaces.

~~~~
    chdef -t osimage -o redhat6img kerneldir=/install/kernels
    cp /hfi/dd/kernel-2.6.32-71.el6.20110617.ppc64.rpm /install/kernels/
    genimage -i hf0 -n hf_if  -k 2.6.32-71.el6.20110617.ppc64 redhat6img
~~~~

Sync /etc/hosts to the diskless image for Power 775

This is used by the postscript hficonfig to configure all the HFI interfaces on the compute nodes. Setup a synclist file containing this line:

~~~~
    /etc/hosts -> /etc/hosts
~~~~


The file can be put anywhere, but let's assume you name it /tmp/synchosts.

Make sure you have an OS image object in the xCAT database associated with your nodes and issue command:

~~~~
    xdcp -i <imagepath> -F /tmp/synchosts
~~~~


&lt;imagepath> stands for the OS image path. This is the directory we defined when we setup our image. To find the path run:

~~~~
    lsdef -t image -o redhat6img | grep rootimgdir
      /install/netboot/rhels6/ppc64/compute
~~~~


Then run the following command:

~~~~
    xdcp -i /install/netboot/rhels6/ppc64/compute/rootimg -F /tmp/synchosts
~~~~


  * pack the image

~~~~
    liteimg redhat6img
~~~~


##### **Boot the node**

~~~~
    nodeset node1 osimage=redhat6img
    rpower node1 off
    rpower node1 on
~~~~


### Generate the statelite image for compute node provmethod=statelite

Typically, you can build your statelite compute node image on the Management Node, if it has the same OS and architecture as the node.



If the statelite image you are building doesn't match the OS/architecture of the Management Node, logon to the node with the desired architecture.

~~~~
    ssh <node>
    mkdir /install
    mount xcatmn:/install /install ( make sure the mount is rw)
~~~~





#### Make the compute node add/exclude packaging list

The default list of rpms to added or exclude to the statelite images is shipped in the following directory:

~~~~
    /opt/xcat/share/xcat/netboot/<platform>
~~~~


If you want to modify the current defaults for *.pkglist or *.exlist or *.postinstall, copy the shipped default lists to the following directory.

~~~~
    /install/custom/netboot/<platform> directory
~~~~


If you want to exclude more packages, add them into the following exlist file:

~~~~
    /install/custom/netboot/<platform>/<profile>.exlist
~~~~


Add more packages names that need to be installed on the statelite node into the pkglist file

~~~~
    /install/custom/netboot/<platform>/<profile>.pkglist
~~~~


#### Setting up postinstall files

There are rules ( release 2.4 or later) for which * postinstall files will be selected to be used by genimage.

If you are going to make modifications, do the following command:

~~~~
    cp opt/xcat/share/xcat/netboot/<platform>/*postinstall /install/custom/netboot/<platform>/.
~~~~


Use these basic rules to edit the correct file in the /install/custom/netboot/&lt;platform&gt; directory. 
The rule allows you to customize your image down to the profile, os and architecture level, if needed.

You will find *postinstall files of the following formats and **genimage** will process the files in the order of the below formats:

~~~~
    <profile>.<os>.<arch>.postinstall
    <profile>.<arch>.postinstall
    <profile>.<os>.postinstall
    <profile>.postinstall

~~~~




This means, if "&lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.postinstall" is there, it will be used first.

  * If there is no such a file, then the "&lt;profile&gt;.&lt;arch&gt;.postinstall" file will be used.
  * If there's no such a file , then the "&lt;profile&gt;.&lt;os&gt;.postinstall" file will be used.
  * If there is no such file, then it will use "&lt;profile&gt;.postinstall".


**Make sure you have the basic postinstall script setup in the directory to run for your genimage.** **The one shipped will setup fstab and rcons to work properly and is required.**

You can add more postinstall process ,if you want. The basic postinstall script (2.4) will be named &lt;profile&gt;.&lt;arch&gt;.postinstall ( e.g. compute.ppc64.postinstall). You can create one for a specific os by copying the shipped one to , for example, compute.rhels5.4.ppc64.postinstall


Note: you can use the sample here: /opt/xcat/share/xcat/netboot/&lt;platform&gt;/

For RH:

Add following packages name into the &lt;profile&gt;.pkglist

~~~~
    bash
    nfs-utils
    stunnel
    dhclient
    kernel
    openssh-server
    openssh-clients
    busybox-anaconda
    wget
    vim-minimal
    ntp

~~~~

For SLES:

Add following packages name into the &lt;profile&gt;.pkglist

~~~~
    aaa_base
    bash
    nfs-utils
    dhcpcd
    kernel
    openssh
    psmisc
    wget
    sysconfig
    syslog-ng
    klogd
    vim
~~~~


#### **Configure postinstall files for Power 775 (Optional)**

The HFI kernel can be installed by xCAT automatically. Other packages, such as hfi_util and nettools, require the rpm options --nodeps or --force respectively, which xCAT cannot handle automatically. We need to modify the postinstall file to install those packages during the statelite image generation.

Add the following lines to /install/custom/netboot/rh/compute.rhels6.ppc64.postinstall. (rhels6 stands for the OS version - it should be the same as the previous step.)

~~~~
    cp /hfi/dd/* /install/netboot/rhels6/ppc64/compute/rootimg/tmp/
    chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhclient-*.rpm' --force
    chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhcp-*.rpm' --force
    chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/kernel-headers-*.rpm' --force
    chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/net-tools-*.rpm' --force
    chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_ndai-*.rpm' --force
    chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_util-*.rpm' --force

~~~~

#### Run image generation

For RH:

~~~~
    genimage rhels6.2-ppc64-install-compute
~~~~





#### Run image generation for Power 775

RH: In Power 775, there is a HFI enabled kernel required in the image. The compute nodes could boot from this customized kernel and boot from HFI interfaces.

~~~~
    cp /hfi/dd/kernel-2.6.32-71.el6.20110617.ppc64.rpm /install/kernels/
    genimage -i hf0 -n hf_if -k 2.6.32-71.el6.20110617.ppc64 rhels6.2-ppc64-install-compute
~~~~


#### Sync /etc/hosts to the diskless image for Power 775

This is used by the postscript hficonfig to configure all the HFI interfaces on the compute nodes. Setup a synclist file containing this line:

~~~~
    /etc/hosts -> /etc/hosts
~~~~


The file can be put anywhere, but let's assume you name it /tmp/synchosts.

Make sure you have an OS image object in the xCAT database associated with your nodes and issue command:

~~~~
    xdcp -i <imagepath> -F /tmp/synchosts
~~~~


&lt;imagepath&gt; stands for the OS image path. Generally it will be located in /install/netboot directory, for example, if the image path is /install/netboot/rhels6/ppc64/compute/rootimg, the command will be:

~~~~
    xdcp -i /install/netboot/rhels6/ppc64/compute/rootimg -F /tmp/synchosts
~~~~


#### Pack the image

For RH:

~~~~
    liteimg rhels6.2-ppc64-install-compute
~~~~


### **Add Third-Party Software**

If you have additional software that you want in the image, you can add it to the distro package directory that was created in the previous step and then rerun createrepo. But if you want to keep your distro package directory pristine, with only distro files in it, you can use xCAT's otherpkgs support:


Create a directory on your management node named "/install/post/otherpkgs/&lt;OS&gt;/&lt;ARCH&gt;, and put your third party rpm packages into the directory:




~~~~
    mkdir /install/post/otherpkgs/rhels5.3/x86_64
~~~~


Copy the rpms in the directory


Go to the directory /install/custom/netboot/&lt;OS&gt; and add the names of the RPM packages you want in the image into the &lt;profile&gt;.otherpkgs.pkglist file.




~~~~
    cd /install/custom/netboot/rh
    vi compute.otherpkgs.pkglist
~~~~



Note: if some of these RPMs will need write permissions to files on the node, add those files or directories into the litefile table.


Create the repository to contain the rpm packages you just added in. After createrepo is installed, you need to create one text file which contains the complete list of files to include in the repository. For example, the name of the text file is **rpms.list** in /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt; directory, include the list into rpms.list:

~~~~
    cd /install/post/otherpkgs/<os>/<arch>
    ls *.rpm >rpms.list
~~~~



Or, if you create a sub-directory to contain the rpm packages, for example named "other" in "/install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;". Run the following commands to add the rpm packages under the "other directory to this repo:

~~~~
    cd /install/post/otherpkgs/<os>/<arch>
    ls other/*.rpm >>rpms.list
~~~~



Finally, run the following command to create repodata for the directory:

~~~~
    createrepo -i rpms.list /install/post/otherpkgs/<os>/<arch>
~~~~



The "createrepo" command with "-i rpms.list" option will create the repository for the rpm packages listed in the "rpms.list" file. It won't destroy and affect the rpm packages which is in the same directory but have been included into another repository.


Create the .repolist file for your own repository in the same directory as above. The file name is: &lt;PROFILE&gt;.&lt;OS&gt;.&lt;ARCH&gt;.repolist . The file format is:

~~~~
    Type|URL|name
~~~~


For example, if the repository is local, you can add the repository information in /install/custom/netboot/rh/compute.rh.repolist:

~~~~
    plaindir|file:///install/post/otherpkgs/rhel5.3/x86_64|otherpkgs
~~~~



If there is a remote repository, you can add the repository information as:

~~~~
    rpm-md|http://xcat.sourceforge.net/yum/xcat-dep/rhel5.3/x86_64|xcat-dep
    rpm-md|http://xcat.sourceforge.net/yum/devel/core-snap|core-snap
~~~~


### **Create Statelite Image**

**Note**: as an alternative to using genimage to create the statelite image, you can also capture an image from a running node and create a statelite image out of it. See [Capture_Linux_Image] for details.




#### **The postinstall file**

By editing the .postinstall file for your profile, you can automate the customization of the root image when the root image is generated by the "genimage" command. XCAT supplies a basic *postinstall file with some **required **setup already in the script. Make sure there is at least one *postinstall file that will be used when you run genimage. The one shipped will setup fstab and rcons to work properly.


The *postinstall files can be found in "/opt/xcat/share/xcat/netboot/&lt;OS&gt;/" directories. If you need to create your own *postinstall file, first you should copy the basic setup supplied in the appropriate *postinstall files. You can add more postinstall process , if you want. If you do modify the script, you should save it in /install/custom/netboot/&lt;os&gt;, so it will not be overlayed with the next install.

The postinstall file is actually a bash script, you can add your own code to the basic function supplied in the file.

To set the postinstall file for you osimage:

~~~~
     chdef -t osimage rhels6.2-ppc64-install-compute postinstall=/your/post/install/file
~~~~


#### The genimage Command

After all our tables are set up, it is time to create a base image. In this example, the operating system is RedHat 5.3, and the name of the image is "compute", so that all the compute nodes will use that image. Make sure that compute is also the name of the profile for the node in the nodetype table. For example:




~~~~
    lsdef <node> | grep profile
~~~~





~~~~
    genimage -i eth0 -n mlx4_core,mlx4_en,igb,bnx2 rhels6.2-ppc64-install-compute
~~~~



The genimage command will do several things:

  1. It will create an image in /install/netboot/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg. For example:/install/netboot/rhels5.3/x86_64/compute/rootimg
  2. It will create a ramdisk and kernel that can be used to boot the initial node.


One new option to genimage named --permission is added for statelite mode, you can assign user-definable permission for /.statelite directory. The default permission is 755. For example:

~~~~
    genimage -n mlx4_core,mlx4_en,igb,bnx2 --permission 777 rhels6.2-ppc64-install-compute
~~~~


would make the permission 777 instead of the 755 default

### Setting up Post install scripts for statelite

The rules to create post install scripts for statelite image is the same as the rules for stateless/diskless install images.

There're two kinds of postscripts for statelite (also for stateless/diskless).


The first kind of postscript is executed at genimage time, it is executed again the image itself on the MN . It was setup in The postinstall file section before the image was generated.


The second kind of postscript is the script that runs on the node during node deployment time. During init.d timeframe, /etc/init.d/gettyset calls /opt/xcat/xcatdsklspost that is in the image. This script uses wget to get all the postscripts under mn:/install/postscripts and copy them to the /xcatpost directory on the node. It uses openssl or stunnel to connect to the xcatd on the mn to get all the postscript names for the node from the postscripts table. It then runs the postscripts for the node.

For NFS-based statelite on Power 775 server, bond0 is not supported to configure, you will need to update the confighfi postscript to comment out the lines for bond0 configuration. See bug [3939](https://sourceforge.net/p/xcat/bugs/3939/).

Comment out the following lines in confighfi:

From:

~~~~
       # Configure bond0 on Linux
       if lsmod | grep bonding
       then
           rmmod bonding
       fi
~~~~


To:

~~~~
       ifdown bond0
       ifup bond0
       bond-mld > m.out 2>&1 &

~~~~

See [Postscripts_and_Prescripts]

### Modify statelite image

Since the files that were now just created will be the default for all the files listed in the litefile table, you can edit the image directly by visiting the root tree in:




~~~~
    /install/netboot/<os>/<arch>/<profile>/rootimg
    cd /install/netboot/rhels5.3/x86_64/compute/rootimg

~~~~


You can run chroot to make additional changes in the image, for example, yum/zypper updates/install using the -installroot flag.

### (Optional) Switch to the RAMdisk-based solution

If you want the node to boot with a RAMdisk-based image instead of the NFS-base image, set the **rootfstype** attribute for the osimage to 'ramdisk'. For example:

~~~~
    chdef -t osimage -o rhels6-ppc64-statelite-compute rootfstype=ramdisk
~~~~


### Run liteimg command

The liteimg command will modify your statelite image (the image that genimage just created) by creating a series of links. Once you are satisfied your image contains what you want it to, run liteimg &lt;imagename&gt;, or liteimg -o &lt;os&gt; -a &lt;arch&gt; -p &lt;profile&gt; -t &lt;rootfstype&gt;. "-t &lt;rootfstype&gt;" is optional, there're two options for -t: **ramdisk** and **nfs**. If "-t &lt;rootfstype&gt;" is not specified, it is equivalent to -t nfs. For example:

~~~~
    liteimg rhels6-ppc64-statelite-compute
~~~~



For files with link options, the liteimg command creates two levels of indirection, so that files can be modified while in their image state as well as during runtime. For example, a file like $imageroot/etc/ntp.conf with link option in the litefile table, will have the following operations done to it:


In our case $imageroot is /install/netboot/rhels5.3/x86_64/compute/rootimg


The liteimg script, for example, does the following to create the two levels of indirection.




~~~~
    mkdir -p $imageroot/.default/etc
    mkdir -p $imageroot/.statelite/tmpfs/etc
    mv $imgroot/etc/ntp.conf $imgroot/.default/etc
    cd $imgroot/.statelite/tmpfs/etc
    ln -sf ../../../.default/etc/ntp.conf .
    cd $imgroot/etc
    ln -sf ../.statelite/tmpfs/etc/ntp.conf .
~~~~



When finished, the original file will reside in $imgroot/.default/etc/ntp.conf. $imgroot/etc/ntp.conf will link to $imgroot/.statelite/tmpfs/etc/ntp.conf which will in turn link to $imgroot/.default/etc/ntp.conf


But for files without link options, the liteimg command only creates clones in $imageroot/.default/ directory, when the node is booting up, the mount command with --bind option will get the corresponding files from the litetree places or .default directory to the sysroot directory.


Note: If you make any changes to your litefile table after running liteimg then you will need to rerun liteimg again. This is because files and directories need to have the two levels of redirects created.

### Set the boot state to statelite

Make sure you have set up all the attributes in your node definitions correctly following the node installation instructions corresponding to your hardware:

[XCAT_iDataPlex_Advanced_Setup]

[XCAT_BladeCenter_Linux_Cluster]

[XCAT_pLinux_Clusters]


You can now deploy the node by running the following commmands:

~~~~
    nodeset <noderange> osimage=<imagename>;
~~~~


This will create the necessary files in /tftpboot/etc for the node to boot correctly.

Note: if you want to boot the <noderange> with the **RAMDisk-based** statelite rootimg, the **nodeset <noderange> osimage=<imagename>** command **MUST** be used to create the booting configuration files for the node.

### Install the Node

Finally, reboot the node so that it boots up in statelite mode.


**For x86_64 platform:**




~~~~
    rpower <noderange> boot
~~~~



Nodeset will have generated the appropriate PXE file so that the node boots from the nfsroot image. This file will look similar to the following:




~~~~
    #statelite rhel5.3-x86_64-compute
    DEFAULT xCAT
    LABEL xCAT
    KERNEL xcat/netboot/rhel5.3/x86_64/compute/kernel
    APPEND initrd=xcat/netboot/rhel5.3/x86_64/compute/initrd.gz
    NFSROOT=172.10.0.1:/install/netboot/rhel5.3/x86_64/compute
    STATEMNT=cnfs:/gpfs/state XCAT=172.10.0.1:3001 console=tty0 console=ttyS0,115200n8r

~~~~


**For POWER platform:**


Run the following command to boot up the nodes into statelite mode:

For non-POWER 775 platform:

~~~~
    rnetboot <noderange>

~~~~

For Power 775 platform:

~~~~
    rbootseq <noderange> hfi
    rpower <noderange>  reset
~~~~


Nodeset will have generated the appropriate yaboot.conf-MAC-ADDRESS file so that the node boots off the nfsroot image. This file will look similar to the following:




~~~~
    #statelite rhel5.3-ppc64-compute
    timeout=5
    image=xcat/netboot/rhel5.3/ppc64/compute/kernel
    label=xcat
    initrd=xcat/netboot/rhel5.3/ppc64/compute/initrd.gz
    append="NFSROOT=192.168.11.108:/install/netboot/rhel5.3/ppc64/compute
    STATEMNT= XCAT=192.168.11.108:3001 "

~~~~


You can then use rcons or wcons to watch the node boot up.

## Commands

The following commands are in /opt/xcat/bin:




~~~~
    litefile <nodename>
~~~~

  * Shows all the statelite files that are not to be taken from the base of the image.




~~~~
    litetree <nodename>
~~~~

  * Shows the NFS mount points for a node.




~~~~
    liteimg <image name>
~~~~

  * Creates a series of symbolic links in an image that is compatible with statelite booting.




~~~~
    lslite -i <imagename>
~~~~

  * Displays a summary of the statelite information defined for &lt;imagename&gt;.




~~~~
    lslite <noderange>
~~~~

  * Displays a summary of the statelite information defined for the &lt;noderange&gt;

## Statelite Directory Structure

Each statelite image will have the following directories:

~~~~
    /.statelite/tmpfs/
    /.default/
    /etc/init.d/statelite
~~~~

All files with link options, which are symbolic links, will link to /.statelite/tmpfs.

tmpfs files that are persistent link to /.statelite/persistent/&lt;nodename&gt;/ /.statelite/persistent/&lt;nodename&gt; is the directory where the node's individual storage will be mounted to.

/.default is where default files will be copied to from the image to tmpfs if the files are not found in the litetree hierarchy.

### **The noderes Table**

noderes.nfsserver attribute can be set for the NFSroot server. If this is not set, then the defaul is the Management Node.

noderes.nfsdir can be set. If this is not set, the the default is /install

## Adding/updating software and files for the running nodes

### Make changes to the files which configured in the litefile table

During the preparation or booting of node against statelite mode, there are specific processes to handle the files which configured in the litefile table. The following operations need to be done after made changes to the statelite files.

**Run liteimg against the osimage and reboot the node**



  * Added, removed or changed the entries in the litefile table

**reboot the node**



  * Changed the location directory in the litetree table
  * Changed the location directory in the statelite table
  * Changed, removed the original files in the location of litetree or statelite table

Note: Thing should not do:



  * When there are node running on the nfs-based statelite osimage, do not run the packimage against this osimage.

### Make changes to the common files

Because most of system files for the nodes are NFS mounted on the Management Node with read-only option, installing or updating software and files should be done to the image. The image is located under /install/netboot/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg directory.


To install or update an rpm, do the following:

  * Install the rpm package into rootimg

~~~~
     rpm --root /install/netboot/<os>/<arch>/<profile>/rootimg -ivh rpm_name
~~~~


  * Restart the software application on the nodes

~~~~
     xdsh <noderange> <restart_this_software_command>
~~~~


It is recommended to follow the section(Adding third party softeware) to add the new rpm to the otherpkgs.pkglist file, so that the rpm will get installed into the new image next time the image is rebuilt.

Note: The newly added rpms are not shown when running rpm -qa on the nodes although the rpm is installed. It will shown next time the node is rebooted.


To create or update a file for the nodes, just modify the file in the image and restart any application that uses the file.

For the ramdisk-based node, you need to reboot the node to take the changes.

## Hierarchy Support

In the statelite environment, the service node needs to provide NFS service for the compute node with statelite, the service nodes must to be setup with diskfull installation.

### Setup the diskfull service node

To setup one diskfull service node, refer to the document:

[Setting_Up_a_Linux_Hierarchical_Cluster]




Since statelite is a kind of NFS-hybrid method, you should remove the installloc attribute in the site table. This makes sure that the service node does not mount the /install directory from the management node on the service node.

### Generate the statelite image

To generate the statelite image for your own profile follow instructions in [XCAT_Linux_Statelite/#create-your-statelite-osimage](XCAT_Linux_Statelite/#create-your-statelite-osimage).




NOTE: if the NFS directories defined in the litetree table are on the service node, it is better to setup the NFS directories in the service node following the chapter 2.3.

### Sync the /install directory

The command prsync is used to sync the /install directory to the service nodes.

Run the following:

~~~~
    cd /
    prsync install <sn>:/
~~~~


&lt;sn&gt; is the hostname of the service node you defined.

Since the prsync command will sync all the contents in the /install directory to the service nodes, the first time will take a long time. But after the first time, it will take very short time to sync.


NOTE: if you make any changes in the /install directory on the management node, and the changes can affect the statelite image, you need to sync the /install directory to the service node again.

### Set the boot state to statelite

You can now deploy the node:




~~~~
    nodeset <noderange> osimage=rhel5.3-x86_64-statelite-compute
~~~~



This will create the necessary files in /tftpboot for the node to boot correctly.

### Install the Node

Follow the instructions in Install the Node. [Install_the_Node](XCAT_Linux_Statelite/#install-the-node).

## Advanced Statelite features

### Both directory and its child items coexist in litefile table

As described in the above chapters, we can add the files/directories to litefile table. Sometimes, it is necessary to put one directory and also its child item(s) into the litefile table. Due to the implementation of the statelite on Linux, some scenarios works, but some doesn't work.


Here are some examples of both directory and its child items coexisting:

  * Both the parent directory and the child file coexist:

~~~~
    "ALL","/root/testblank/",,,
    "ALL","/root/testblank/tempfschild","tempfs",,
~~~~


  * One more complex example:

~~~~
    "ALL","/root/",,,
    "ALL","/root/testblank/tempfschild","tempfs",,
~~~~


  * Another more complex example, but we don't intend to support such one scenario:

~~~~
    "ALL","/root/",,,
    "ALL","/root/testblank/",,,
    "ALL","/root/testblank/tempfschild","tempfs",,
~~~~


For example, in scenario 1, the parent is /root/testblank/, and the child is /root/testblank/tempfschild.
In scenario 2, the parent is /root/, and the child is /root/testblank/tempfschild.
In order to describe the hierarchy scenarios we can use , "P" to denote parent, and "C" to denote child.

### The hierarchy scenarios

<!---
begin_xcat_table;
numcols=3;
colwidths=7,25,40;
-->


| Option | Example | Remarks
---------|---------|---------
P:tmpfs C:tmpfs | "ALL","/root/testblank/",,, "ALL","/root/testblanktempfschild","tempfs",, | Both the parent and the child are mounted to tmpfs on the booted node following their respective options.Only the parent are mounted to the local file system.
P:tmpfs C:persistent| "ALL","/root/testblank/",,, "ALL","/root/testblank/testpersfile","persistent",,|   Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent is mounted to the local file system.
P:persistent C:tmpfs|"ALL","/root/testblank/","persistent",, "ALL","/root/testblank/tempfschild",,,| Not permitted now. But plan to support it.
P:persistent C:persistent|"ALL","/root/testblank/","persistent",, "ALL","/root/testblank/testpersfile","persistent",,| Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent are mounted to the local file system.
P:ro C:any | |  Not permitted
P:tmpfs C:ro| | Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent are mounted to the local file system.
P:tmpfs C:con | | Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent are mounted to the local file system.
P:link C:link |"ALL","/root/testlink/","link",, "ALL","/root/testlink/testlinkchild","link",, | Both the parent and the child are created in tmpfs on the booted node following their respective options; there's only one symbolic link of the parent is created in the local file system.
P: link C: link,persistent |"ALL","/root/testlinkpers/","link",, "ALL","/root/testlink/testlinkchild","link,persistent" | Both the parent and the child are created in tmpfs on the booted node following their respective options; there's only one symbolic link of the parent is created in the local file system.
P: link persistent C: link |"ALL","/root/testlinkpers/","link,persistent",, "ALL","/root/testlink/testlinkchild","link" |NOT permitted
P: link, persistent C: link, persistent |"ALL","/root/testlinkpers/","link,persistent",, "ALL","/root/testlink/testlinkperschild","link,persistent",, |Both the parent and the child are created in tmpfs on the booted node following the "link,persistent" way; there's only one symbolic link of the parent is created in the local file system.
P: link C: link,ro |"ALL","/root/testlink/","link",, "ALL","/root/testlink/testlinkro","link,ro",, |Both the parent and the child are created in tmpfs on the booted node, there's only one symbolic link of the parent is created in the local file system.
P: link C: link,con |"ALL","/root/testlink/","link",, "ALL","/root/testlink/testlinkconchild","link,con",,  |Both the parent and the child are created in tmpfs on the booted node, there's only one symbolic link of the parent in the local file system.
P:link.persistent C: link,ro | |NOT Permitted
P:link,persistent C: link,con | |NOT Permitted
P: tmpfs C: link | |NOT Permitted
P: link C: persistent | |NOT Permitted

<!---
end_xcat_table
-->



### litetree table

The litetree table controls where the initial content of the files in the litefile table come from, and the long term content of the "ro" files. When a node boots up in statelite mode, it will by default copy all of its tmpfs files from the /.default directory of the root image, so there is not requirement to setup a litetree table. If you decide that you want some of the files pulled from different locations that are different per node, you can use this table.


See [litetree man page](http://xcat.sourceforge.net/man5/litetree.5.html) for description of attributes.


For example, a user may have two directories with a different /etc/motd that should be used for nodes in two locations:


~~~~

    10.0.0.1:/syncdirs/newyork-590Madison/rhels5.4/x86_64/compute/etc/motd
    10.0.0.1:/syncdirs/shanghai-11foo/rhels5.4/x86_64/compute/etc/motd
~~~~



You can specify this in one row in the litetree table:

~~~~
    1,,10.0.0.1:/syncdirs/$nodepos.room/$nodetype.os/$nodetype.arch/$nodetype.profile
~~~~



When each statelite node boots, the variables in the litetree table will be substituted with the values for that node to locate the correct directory to use. Assuming that /etc/motd was specified in the litefile table, it will be searched for in all of the directories specified in the litetree table and found in this one.


You may also want to look by default into directories containing the node name first:

$noderes.nfsserver:/syncdirs/$node


The litetree prioritizes where node files are found. The first field is the priority. The second field is the image name (ALL for all images) and the final field is the mount point.


Our example is as follows:

~~~~
    1,,$noderes.nfsserver:/statelite/$node
    2,,cnfs:/gpfs/dallas/
~~~~



The two directories /statelite/$node on the node's $noderes.nfsserver and the /gpfs/dallas on the node cnfs contain root tree structures that are sparsely populated with files that we want to place in those nodes. If files are not found in the first directory, it goes to the next directory. If none of the files can be found in the litetree hierarchy, then they are searched for in /.default on the local image.

### Installing a new Kernel in the statelite image (This is not verified)

Obtain you new kernel and kernel modules on the MN, for example here we have a new SLES kernel.


Copy the kernel into /boot&nbsp;:

~~~~
    cp **vmlinux-2.6.32.10-0.5-ppc64**/boot
~~~~



Copy the kernel modules into /lib/modules/&lt;new kernel directory&gt;

~~~~
    /lib/modules # ls -al
    total 16
    drwxr-xr-x 4 root root 4096 Apr 19 10:39 .
    drwxr-xr-x 17 root root 4096 Apr 13 08:39 ..
    drwxr-xr-x 3 root root 4096 Apr 13 08:51 2.6.32.10-0.4-ppc64
    **drwxr-xr-x 4 root root 4096 Apr 19 10:12 2.6.32.10-0.5-ppc64**
~~~~


Run genimage to update the statelite image with the new kernel

~~~~
     genimage -k 2.6.32.10-0.5-ppc64 <osimage_name>
~~~~


then after a nodeset command and netboot..

~~~~
    uname -a
~~~~


shows the new kernel.

### Enabling the **localdisk** Option

Note: You can skip this section if **not** using the 'localdisk' option in your litefile table. The localdisk option for statelite nodes is available in 2.8.1 or later. The localdisk option for stateless nodes is available in 2.8.2 or later.

Several things need to be done to enable the 'localdisk' support:

**Define how to partition the local disk**

When a node is deployed, the local hard disk needs to be partitioned and formatted before it can be used. This section explains how provide a configuration file that tells xCAT to partition a local disk and make it ready to use for the directories listed in the litefile table with the "localdisk" option.

The configuration file needs to be specified in the 'partitionfile' attribute of the osimage definition. The configuration file includes several parts:

  * Global parameters to control enabling or disabling the function
  * [disk] part to control the partitioning of the disk
  * [localspace] part to control which partition will be used to store the localdisk directories listed in the litefile table
  * [swapspace] part to control the enablement of the swap space for the node.

An example localdisk configuration file:


~~~~
    enable=yes
    enablepart=no

    [disk]
    dev=/dev/sdb
    clear=yes
    parts=100M-200M,1G-2G

    [disk]
    dev=/dev/sda
    clear=yes
    parts=10,20,30

    [disk]
    dev=/dev/sdc
    clear=yes
    parts=10,20,30

    [localspace]
    dev=/dev/sda1
    fstype=ext3

    [swapspace]
    dev=/dev/sda2
~~~~


The two global parameters 'enable' and 'enablepart' can be used to control the enabling/disabling of the functions:

  * enable: The localdisk feature only works when 'enable' is set to 'yes'. If it is set to 'no', the localdisk configuration will not be run.
  * enablepart: The partition action (refer to the [disk] section) will be run only when 'enablepart=yes'.

The [disk] section is used to configure how to partition a hard disk:

  * dev: The path of the device file.
  * clear: If set to 'yes' it will clear all the existing partitions on this disk.
  * fstype: The file system type for the new created partitions. 'ext3' is the default value if not set.
  * parts: A comma separated list of space ranges, one for each partition that will be created on the device. The valid format for each space range is '&lt;startpoint&gt;-&lt;endpoint&gt;' or '&lt;percentage of the disk&gt;'. For example, you could set it to '100M-10G' or '50'. If you set it to '50', that means 50% of the disk space will be assigned to that partition.

The [localspace] section is used to specify which partition will be used as local storage for the node.

  * dev: The path of the partition.
  * fstype: The file system type on the partition.

[swapspace]: section is used to configure the swap space for the statelite node.

  * dev: The path of the partition file which will be used as the swap space.

To enable the local disk capability, create the configuration file (for example in /install/custom) and set the path in the partitionfile attribute for the osimage:

~~~~
    chdef -t osimage partitionfile=/install/custom/cfglocaldisk
~~~~


Now all nodes that use this osimage (i.e. have their provmethod attribute set to this osimage definition name), will have its local disk configured.

**Configure the files in the litefile table**

For the files/directories that you would like xCAT to store on the local disk, add an entry in the litefile table like this:

~~~~
    "ALL","/tmp/","localdisk",,
~~~~


Note: you do not need to specify the swap space in the litefile table. Just putting it in the partitionfile config file is enough.

**Add an entry in policy table to permit the running of the 'getpartitioin' command from the node**

~~~~
    chtab priority=7.1 policy.commands=getpartition policy.rule=allow
~~~~


**If Using the RAMdisk-based Image**

If you want to use the local disk option with a RAMdisk-based image (as opposed to an NFS-based image), remember to follow the instructions in [XCAT_Linux_Statelite/#optional-switch-to-the-ramdisk-based-solution](XCAT_Linux_Statelite/#optional-switch-to-the-ramdisk-based-solution).

If your reason for using a RAMdisk image is to avoid compute node runtime dependencies on the service node or management node, then the only entries you should have in the litefile table should be files/dirs that use the localdisk option.

## Debugging techniques

  * When a node boots up in statelite mode, there is a script that runs called statelite that is in the root directory of $imageroot/etc/init.d/statelite. This script is not run as part of the rc scripts, but as part of the pre-switch root environment. Thus, all the linking is done in this script. There is a "set x" near the top of the file. You can uncomment it and see what the script runs. You will then see lots of mkdirs and links on the console.
  * You can also set the machine to shell. Just add the word "shell" on the end of the pxeboot file of the node in the append line. This will make the init script in the initramfs pause 3 times before doing a switch_root.
  * When all the files are linked they are logged in /.statelite/statelite.log on the node. You can get into the node after it has booted and look in the /.statelite directory.


