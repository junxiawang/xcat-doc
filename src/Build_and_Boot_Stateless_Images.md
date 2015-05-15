<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Build and Boot Stateless Images](#build-and-boot-stateless-images)
  - [Select or Create an osimage Definition](#select-or-create-an-osimage-definition)
  - [Build the Stateless Image on the MN](#build-the-stateless-image-on-the-mn)
    - [Build the stateless image off the MN](#build-the-stateless-image-off-the-mn)
  - [**Test Boot the Stateless Image**](#test-boot-the-stateless-image)
  - [**Update the Stateless Image**](#update-the-stateless-image)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[No_Longer_Used_Warning](No_Longer_Used_Warning)


## Build and Boot Stateless Images

**Note this page is no longer used or supported.** ****

If you desire to build Linux stateless images and then boot nodes, instead of installing, then follow these instructions: 

Note: you can do both. You can have your nodes installed with one image, but stateless boot another image. This is convenient for testing new images. 

### Select or Create an osimage Definition

The copycds command also automatically creates several osimage defintions in the database that can be used for node deployment. To see them: 
    
    lsdef -t osimage          # see the list of osimages
    lsdef -t osimage &lt;osimage-name&gt;          # see the attributes of a particular osimage
    

From the list above, select the osimage for your distro, architecture, provisioning method (in this case install), and profile (compute, service, etc.). Although it is optional, we recommend you make a copy of the osimage, changing its name to a simpler name. For example: 
    
    lsdef -t osimage -z rhels6.2-x86_64-netboot-compute | sed 's/^[^ ]\+:/mycomputeimage:/' | mkdef -z
    

This displays the osimage "rhels6.2-x86_64-install-compute" in a format that can be used as input to mkdef, but on the way there it uses sed to modify the name of the object to "mycomputeimage". 

Initially, this osimage object points to templates, pkglists, etc. that are shipped by default with xCAT. And some attributes, for example otherpkglist and synclists, won't have any value at all because xCAT doesn't ship a default file for that. You can now change/fill in any [osimage attributes](http://xcat.sourceforge.net/man7/osimage.7.html) that you want. A general convention is that if you are modifying one of the default files that an osimage attribute points to, copy it into /install/custom and have your osimage point to it there. (If you modify the copy under /opt/xcat directly, it will be over-written the next time you upgrade xCAT.) 

But for now, we will use the default values in the osimage definition and continue on. (If you really want to see examples of modifying/creating the pkglist, template, otherpkgs pkglist, and sync file list, see the section [#Deploying_Stateless_Nodes]. Most of the examples there can be used for stateful nodes too.) 

### Build the Stateless Image on the MN

**Note**: as an alternative to using genimage to create the stateless image, you can also capture an image from a running node and create a stateless image out of it. See [Capture_Linux_Image] for details. 

  * Generate the image: 
    
    genimage mycomputeimage
    

  
The genimage will create a default /etc/fstab in the image, for example: 
    
    devpts  /dev/pts devpts   gid=5,mode=620 0 0
    tmpfs   /dev/shm tmpfs    defaults       0 0
    proc    /proc    proc     defaults       0 0
    sysfs   /sys     sysfs    defaults       0 0
    tmpfs   /tmp     tmpfs    defaults,size=10m             0 2
    tmpfs   /var/tmp     tmpfs    defaults,size=10m       0 2
    compute_x86_64    /   tmpfs   rw  0 1
    

  
If you want to change the defaults, on the management node, edit fstab in the image: 
    
    cd /install/netboot/fedora9/x86_64/compute/rootimg/etc
    cp fstab fstab.ORIG
    vi fstab
    

  

    
    proc /proc proc rw 0 0
    sysfs /sys sysfs rw 0 0
    devpts /dev/pts devpts rw,gid=5,mode=620 0 0
    #tmpfs /dev/shm tmpfs rw 0 0
    compute_x86_64 / tmpfs rw 0 1
    none /tmp tmpfs defaults,size=10m 0 2
    none /var/tmp tmpfs defaults,size=10m 0 2
    

_Note: adding /tmp and /var/tmp to /etc/fstab is optional, most installations can simply use /. It was documented her to show that you can restrict the size of filesystems, if you need to. The indicated values are just and example, and you may need much bigger filessystems, if running applications like OpenMPI. _

  


  * Pack the image: 
    
    packimage mycomputeimage
    

#### Build the stateless image off the MN

  * **If the stateless image you are building doesn't match the OS/architecture of the management node**, logon to the node with the desired architecture. Here the Management Node name is xcatmn. 

  

    
    ssh &lt;node&gt;
    mkdir /install
    mount xcatmn:/install /install ( make sure the mount is rw)
    

  
Create fedora.repo: 
    
    cd /etc/yum.repos.d
    rm -f *.repo
    

  
Put the following lines in /etc/yum.repos.d/fedora.repo: 
    
    [fedora]
    name=Fedora $releasever - $basearch
    baseurl=file:///install/fedora9/x86_64
    enabled=1
    gpgcheck=0
    

Test with: yum search gcc 

  
Copy the executables and files needed from the Management Node: 
    
    mkdir /root/netboot
    cd /root/netboot
    scp xcatmn:/opt/xcat/share/xcat/netboot/fedora/genimage .
    scp xcatmn:/opt/xcat/share/xcat/netboot/fedora/geninitrd .
    scp xcatmn:/opt/xcat/share/xcat/netboot/fedora/compute.x86_64.pkglist .
    scp xcatmn:/opt/xcat/share/xcat/netboot/fedora/compute.exlist .
    

  * Generate the image: 

To build the image on the node run: 
    
    genimage mycomputeimage
    

  


  * On the xCAT Management Node, edit fstab in the image, if you need to change the default. 

See the section above on building the stateless image on the MN. 

  


  * Pack the image on xcatmn: 
    
    packimage mycomputeimage
    

### **Test Boot the Stateless Image**

You can continue to customize the image and then you can boot a node with the image: 

  

    
    nodeset &lt;nodename&gt; osimage=mycomputeimage
    rpower &lt;nodename&gt; boot
    

  
You can monitor the install by running: 
    
    rcons &lt;nodename&gt;
    tail -f /var/log/messages
    

### **Update the Stateless Image**

To update the Stateless image, repeat the original process. Check your package list, adding or removing new rpms, run genimage and packimage again as documented here: 

[XCAT_BladeCenter_Linux_Cluster#Build_and_Boot_Stateless_Images] 
