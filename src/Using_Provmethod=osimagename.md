<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Create the Distro Repository on the MN](#create-the-distro-repository-on-the-mn)
- [Using an osimage Definition](#using-an-osimage-definition)
- [Select or Create an osimage Definition](#select-or-create-an-osimage-definition)
- [Set up pkglists](#set-up-pkglists)
- [Set up a postinstall script (optional)](#set-up-a-postinstall-script-optional)
- [Set up Files to be synchronized on the nodes](#set-up-files-to-be-synchronized-on-the-nodes)
- [Configure the nodes to use your osimage](#configure-the-nodes-to-use-your-osimage)
- [Generate and pack your image](#generate-and-pack-your-image)
  - [**Building an Image for a Different OS or Architecture**](#building-an-image-for-a-different-os-or-architecture)
  - [**Building an Image for the Same OS and Architecture as the MN**](#building-an-image-for-the-same-os-and-architecture-as-the-mn)
  - [**Installing a New Kernel in the Stateless Image**](#installing-a-new-kernel-in-the-stateless-image)
  - [**Installing New Kernel Drivers to Stateless Initrd**](#installing-new-kernel-drivers-to-stateless-initrd)
- [Boot the nodes](#boot-the-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Note: this section describes how to create a stateless image using the genimage command to install a list of rpms into the image. As an alternative, you can also capture an image from a running node and create a stateless image out of it. See [Capture_Linux_Image] for details. 


### Create the Distro Repository on the MN

The [copycds](http://xcat.sourceforge.net/man8/copycds.8.html) command copies the contents of the linux distro media to /install/&lt;os&gt;/&lt;arch&gt; so that it will be available to install nodes with or create diskless images. 

  * Obtain the Redhat or SLES ISOs or DVDs. 
  * If using an ISO, copy it to (or NFS mount it on) the management node, and then run: 
    
    copycds &lt;path&gt;/RHEL6.2-Server-20080430.0-x86_64-DVD.iso
    

  * If using a DVD, put it in the DVD drive of the management node and run: 
    
    copycds /dev/dvd       # or whatever the device name of your dvd drive is
    

Tip: if this is the same distro version as your management node, create a .repo file in /etc/yum.repos.d with content similar to: 
    
    [local-rhels6.2-x86_64]
    name=xCAT local rhels 6.2
    baseurl=file:/install/rhels6.2/x86_64
    enabled=1
    gpgcheck=0
    

This way, if you need some additional RPMs on your MN at a later, you can simply install them using yum. Or if you are installing other software on your MN that requires some additional RPMs from the disto, they will automatically be found and installed. 

### Using an osimage Definition

**Note: To use an osimage as your provisioning method, you need to be running xCAT 2.6.6 or later.**

The provmethod attribute of your nodes should contain the name of the osimage object definition that is being used for those nodes. The [osimage object](http://xcat.sourceforge.net/man7/osimage.7.html) contains paths for pkgs, templates, kernels, etc. If you haven't already, run [copycds](http://xcat.sourceforge.net/man8/copycds.8.html) to copy the distro rpms to /install. Default osimage objects are also defined when copycds is run. To view the osimages: 

~~~~    
    lsdef -t osimage          # see the list of osimages
    lsdef -t osimage <osimage-name>
          # see the attributes of a particular osimage
~~~~ 
    

### Select or Create an osimage Definition

From the list found above, select the osimage for your distro, architecture, provisioning method (install, netboot, statelite), and profile (compute, service, etc.). Although it is optional, we recommend you make a copy of the osimage, changing its name to a simpler name. For example: 
 
~~~~    
    lsdef -t osimage -z rhels6.3-x86_64-netboot-compute | sed 's/^[^ ]\+:/mycomputeimage:/' | mkdef -z

~~~~     

This displays the osimage "rhels6.3-x86_64-netboot-compute" in a format that can be used as input to mkdef, but on the way there it uses sed to modify the name of the object to "mycomputeimage". 

Initially, this osimage object points to templates, pkglists, etc. that are shipped by default with xCAT. And some attributes, for example otherpkglist and synclists, won't have any value at all because xCAT doesn't ship a default file for that. You can now change/fill in any [osimage attributes](http://xcat.sourceforge.net/man7/osimage.7.html) that you want. A general convention is that if you are modifying one of the default files that an osimage attribute points to, copy it into /install/custom and have your osimage point to it there. (If you modify the copy under /opt/xcat directly, it will be over-written the next time you upgrade xCAT.) An important attribute to change is the rootimgdir which will contain the generated osimage files so that you don't over-write an image built with the shipped definitions. To continue the previous example: 

~~~~     
      chdef -t osimage -o mycomputeimage rootimgdir=/install/netboot/rhels6.3/x86_64/mycomputeimage
~~~~     

### Set up pkglists

You likely want to customize the main pkglist for the image. This is the list of rpms or groups that will be installed from the distro. (Other rpms that they depend on will be installed automatically.) For example: 

~~~~     
    mkdir -p /install/custom/netboot/rh
    cp -p /opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.pkglist /install/custom/netboot/rh
    vi /install/custom/netboot/rh/compute.rhels6.x86_64.pkglist
    chdef -t osimage mycomputeimage pkglist=/install/custom/netboot/rh/compute.rhels6.x86_64.pkglist
~~~~     

The goal is to install the fewest number of rpms that still provides the function and applications that you need, because the resulting ramdisk will use real memory in your nodes. 

Also, check to see if the default exclude list excludes all files and directories you do not want in the image. The exclude list enables you to trim the image after the rpms are installed into the image, so that you can make the image as small as possible. 

~~~~     
    cp /opt/xcat/share/xcat/netboot/rh/compute.exlist /install/custom/netboot/rh
    vi /install/custom/netboot/rh/compute.exlist 
    chdef -t osimage mycomputeimage exlist=/install/custom/netboot/rh/compute.exlist
~~~~     

Make sure nothing is excluded in the exclude list that you need on the node. For example, if you require perl on your nodes, remove the line "./usr/lib/perl5*". 

[Install_OS_Updates](Install_OS_Updates) 

[Install_Additional_Packages](Install_Additional_Packages) 

### Set up a postinstall script (optional)

Postinstall scripts for diskless images are analogous to postscripts for diskfull installation. The postinstall script is run by genimage near the end of its processing. You can use it to do anything to your image that you want done every time you generate this kind of image. In the script you can install rpms that need special flags, or tweak the image in some way. There are some examples shipped in /opt/xcat/share/xcat/netboot/&lt;distro&gt;. If you create a postinstall script to be used by genimage, then point to it in your osimage definition. For example: 

~~~~     
    chdef -t osimage mycomputeimage postinstall=/install/custom/netboot/rh/compute.postinstall
~~~~     

### Set up Files to be synchronized on the nodes

Note: This is only supported for stateless nodes in xCAT 2.7 and above. 

Sync lists contain a list of files that should be sync'd from the management node to the image and to the running nodes. This allows you to have 1 copy of config files for a particular type of node and make sure that all those nodes are running with those config files. The sync list should contain a line for each file you want sync'd, specifying the path it has on the MN and the path it should be given on the node. For example: 

~~~~     
    /install/custom/syncfiles/compute/etc/motd -> /etc/motd
    /etc/hosts -> /etc/hosts
~~~~     

If you put the above contents in /install/custom/netboot/rh/compute.synclist, then: 

~~~~ 
    
    chdef -t osimage mycomputeimage synclists=/install/custom/netboot/rh/compute.synclist
~~~~     

For more details, see [Sync-ing_Config_Files_to_Nodes](Sync-ing_Config_Files_to_Nodes). 

### Configure the nodes to use your osimage

You can configure any noderange to use this osimage. In this example, we define that the whole compute group should use the image: 

~~~~    
     chdef -t group compute provmethod=mycomputeimage
~~~~     

Now that you have associated an osimage with nodes, if you want to list a node's attributes, including the osimage attributes all in one command: 

~~~~ 
    
    lsdef node1 --osimage
~~~~ 
    

### Generate and pack your image

There are other attributes that can be set in your osimage definition. See the [osimage man page](http://xcat.sourceforge.net/man7/osimage.7.html) for details. 

#### **Building an Image for a Different OS or Architecture**

If you are building an image for a different OS/architecture than is on the Management node, you need to follow this process: [Building_a_Stateless_Image_of_a_Different_Architecture_or_OS]. Note: different OS in this case means, for example, RHEL 5 vs. RHEL 6. If the difference is just an update level/service pack (e.g. RHEL 6.0 vs. RHEL 6.3), then you can build it on the MN. 

#### **Building an Image for the Same OS and Architecture as the MN**

If the image you are building is for nodes that are the same OS and architecture as the management node (the most common case), then you can follow the instructions here to run genimage on the management node. 

Run [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) to generate the image based on the mycomputeimage definition: 

~~~~ 
    
    genimage mycomputeimage
~~~~     

Before you pack the image, you have the opportunity to change any files in the image that you want to, by cd'ing to the rootimgdir (e.g. /install/netboot/rhels6/x86_64/compute/rootimg). Although, instead, we recommend that you make all changes to the image via your postinstall script, so that it is repeatable. 

The genimage command creates /etc/fstab in the image. If you want to, for example, limit the amount of space that can be used in /tmp and /var/tmp, you can add lines like the following to it (either by editing it by hand or via the postinstall script): 
 
~~~~    
    tmpfs   /tmp     tmpfs    defaults,size=50m             0 2
    tmpfs   /var/tmp     tmpfs    defaults,size=50m       0 2
~~~~     

But probably an easier way to accomplish this is to create a postscript to be run when the node boots up with the following lines: 

~~~~     
    logger -t xcat "$0: BEGIN"
    mount -o remount,size=50m /tmp/
    mount -o remount,size=50m /var/tmp/
    logger -t xcat "$0: END"
~~~~     

Assuming you call this postscript settmpsize, you can add this to the list of postscripts that should be run for your compute nodes by: 

~~~~ 
    
    chdef -t group compute -p postbootscripts=settmpsize
~~~~     

Now pack the image to create the ramdisk: 

~~~~     
    packimage mycomputeimage
~~~~     

  


#### **Installing a New Kernel in the Stateless Image**

**Note: This procedure assumes you are using xCAT 2.6.1 or later.**

The _kerneldir_ attribute in _linuximage_ table can be used to assign a directory containing kernel RPMs that can be installed into stateless/statelite images. The default for _kernerdir_ is _/install/kernels_.  To add a new kernel, create a directory named _&lt;kernelver&gt;_ under the _kerneldir_, and genimage will pick them up from there. 

The following examples assume you have the kernel RPM in /tmp and is using the default value for _kerneldir_ (_/install/kernels_).  

*The RPM names below are only examples, substitute your specific level and architecture.*


**[RHEL]:**

The RPM kernel package is usually named: _kernel-&lt;kernelver&gt;.rpm_.
For example, **kernel-2.6.32.10-0.5.x86_64.rpm** means _kernelver_=**2.6.32.10-0.5.x86_64**. 

~~~~ 
    mkdir -p /install/kernels/2.6.32.10-0.5.x86_64
    cp /tmp/kernel-2.6.32.10-0.5.x86_64.rpm /install/kernels/2.6.32.10-0.5.x86_64/
    createrepo /install/kernels/2.6.32.10-0.5.x86_64/
~~~~     
&nbsp;

Run genimage/packimage to update the image with the new kernel. 
**Note:** *If downgrading the kernel, you may need to first remove the rootimg directory.*

~~~~   
    genimage <imagename> -k 2.6.32.10-0.5.x86_64
    packimage <imagename>
~~~~  

&nbsp;

**[SLES]:** 

The RPM kernel package is usually separated into two parts: _kernel-&lt;arch&gt;-base_ and _kernel_&lt;arch&gt;. 
For example, /tmp contains the following two RPMs:

~~~~     
    kernel-ppc64-base-2.6.27.19-5.1.x86_64.rpm
    kernel-ppc64-2.6.27.19-5.1.x86_64.rpm
~~~~     
&nbsp;

*2.6.27.19-5.1.x86_64* is **NOT** the kernel version,  2.6.27.19-**5-**x86_64 is the kernel version.  
The "5.1.x86_64" is replaced with "5-x86_64". 

~~~~
    mkdir -p /install/kernels/2.6.27.19-5-x86_64/
    cp /tmp/kernel-ppc64-base-2.6.27.19-5.1.x86_64.rpm /install/kernels/2.6.27.19-5-x86_64/
    cp /tmp/kernel-ppc64-2.6.27.19-5.1.x86_64.rpm /install/kernels/2.6.27.19-5-x86_64/

~~~~     
&nbsp;

Run genimage/packimage to update the image with the new kernel. 
**Note:** *If downgrading the kernel, you may need to first remove the rootimg directory.*

Since the kernel version name is different from the kernel rpm package name, the -g flag **MUST** to be specified on the genimage command. 

~~~~
    genimage <imagename> -k 2.6.27.19-5-x86_64 -g 2.6.27.19-5.1
    packimage <imagename>
~~~~
&nbsp;

#### **Installing New Kernel Drivers to Stateless Initrd**

The kernel drivers in the stateless initrd are used for the devices during the netboot. If you are missing one or more kernel drivers for specific devices (especially for the network device), the netboot process will fail. xCAT offers two approaches to add additional drivers to the stateless initrd during the running of **genimage**. 

  * Use the '-n' flag to add new drivers to the stateless initrd 

~~~~     
    genimage <imagename> -n <new driver list>
~~~~     

Generally, the genimage command has a default driver list which will be added to the initrd. But if you specify the '-n' flag, the default driver list will be replaced with your &lt;new driver list&gt;. That means you need to include any drivers that you need from the default driver list into your &lt;new driver list&gt;. 

The default driver list: 
 
~~~~    
 
    rh-x86:   tg3 bnx2 bnx2x e1000 e1000e igb mlx_en virtio_net be2net
    rh-ppc:   e1000 e1000e igb ibmveth ehea
    sles-x86: tg3 bnx2 bnx2x e1000 e1000e igb mlx_en be2net
    sels-ppc: tg3 e1000 e1000e igb ibmveth ehea be2net
 
~~~~    

Note: With this approach, xCAT will search for the drivers in the rootimage. You need to make sure the drivers have been included in the rootimage before generating the initrd. You can install the drivers manually in an existing rootimage (using chroot) and run genimage again, or you can use a postinstall script to install drivers to the rootimage during your initial genimage run. 

  * Use the **driver rpm package** to add new drivers from rpm packages to the stateless initrd 

Refer to the doc [Using_Linux_Driver_Update_Disk#Driver_RPM_Package](Using_Linux_Driver_Update_Disk/#driver-rpm-package). 

### Boot the nodes

~~~~
    
    nodeset compute osimage=mycomputeimage
~~~~    

(If you need to update your diskless image sometime later, change your osimage attributes and the files they point to accordingly, and then rerun genimage, packimage, nodeset, and boot the nodes.) 

Now boot your nodes... 
