<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Using provmethod=install,netboot or statelite**](#using-provmethodinstallnetboot-or-statelite)
  - [**Setup the pkglist and exlis**t](#setup-the-pkglist-and-exlist)
  - [**Setup the otherpkgs list file**](#setup-the-otherpkgs-list-file)
  - [**Setting up postinstall files**](#setting-up-postinstall-files)
  - [Setting up Files to be synchronized on the nodes](#setting-up-files-to-be-synchronized-on-the-nodes)
  - [**Generate/pack the image**](#generatepack-the-image)
  - [Build the stateless image off the MN](#build-the-stateless-image-off-the-mn)
  - [Test Boot the Stateless Image](#test-boot-the-stateless-image)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[No_Longer_Used_Warning](No_Longer_Used_Warning) 


#### **Using provmethod=install,netboot or statelite**

The provisioning method (provmethod) for node deployment determines the path for important files used during the image generation, install and updatenode process. The valid values for provmethod are install, netboot, statelite or an osimage name from the osimage table. 

To determine the current provmethod of your node, run lsdef and look at the provmethod setting. 
 
~~~~   
lsdef <nodename> | grep provmethod
~~~~    

&nbsp;
On Linux, if provmethod for the node is install, netboot, or statelite, the os, profile, and arch of that node are used to search for the files in /install/custom/<provmethod>/<platform>; first, and then in /opt/xcat/share/xcat/<provmethod>/<platform>.
    
    lsdef node1
    Object name: node1
       arch=x86_64
           .   
       profile=compute
       os=rhels6
       provmethod=netboot
    

In this example, since the provmethod is netboot and the os is rhels6 ( platform rh), the code will search first 
    
    /install/custom/netboot/rh  for compute* files
    

and then if not found will search 
    
    /opt/xcat/share/xcat/netboot/rh
    

  


  


##### **Setup the pkglist and exlis**t

Before building your stateless image, you need to check the pkglists that will be used to build the image. 

On Linux, the default list of rpms to added or exclude when building the image is shipped in the /opt/xcat/share/xcat/**netboot**/&lt;platform&gt; directory. Our example path is for **provmethod=netboot, replace netboot with install in the directory path**, for diskfull installs. 

  
On the management node, check the compute node package list to see if it has all the rpms required. Check the exclude list to see if it excludes all packages we do not want. 
    
    cd /opt/xcat/share/xcat/netboot/rh/
    vi compute.pkglist
    vi compute.exlist 
    

For example to add **vi** to be installed on the node, add the name of the vi rpm to compute.pkglist. Make sure nothing is excluded in compute.exlist that you need. For example, if you require perl on your nodes, remove ./usr/lib/perl5 from compute.exlist . Ensure that the pkglist contains bind-utils so that name resolution will work during boot. 

If you modify the current defaults for *.pkglist or *.exlist or *.postinstall, copy the shipped default lists to the **custom** directory, so your modifications will not be removed on the next xCAT rpm update. xCAT will first look in the custom directory for the files before going to the share directory. 
    
    cp /opt/xcat/share/xcat/**netboot**/rh/compute.pkglist /install/custom/netboot \
    /rh/compute.pkglist
    

**Note**: as an alternative to using genimage to create the stateless image, you can also capture an image from a running node and create a stateless image out of it. See [Capture_Linux_Image] for details. 

[[ref=Install_Additional_Packages]] 

##### **Setup the otherpkgs list file**

**Create your package list file, in the /install/custom/&lt;provmethod&gt;/&lt;platform&gt; where platform is your os name (rh,sles,fedora,etc).** The file for this provmethod should have the name &lt;profile&gt;.otherpkgs.pkglist. For example, for service nodes, the name might be service.otherpkgs.pkglist. For compute nodes, compute.otherpkgs.list. 

**There are examples under /opt/xcat/share/xcat/netboot/&lt;platform&gt; of typical *otherpkgs.pkglist files that can be copied to the appropriate directory and modified.**

##### **Setting up postinstall files**

Using postinstall files is optional. There are some examples shipped in /opt/xcat/share/xcat/netboot/&lt;platform&gt;. 

There are rules for which * postinstall files will be selected to be used by genimage for by the diskfull install process. 

If you are going to make modifications, copy the appropriate /opt/xcat/share/xcat/**netboot**/&lt;platform&gt;/*postinstall file to the 

/install/custom/netboot/&lt;platform&gt; directory, so that on the next update of xCAT you changes will not be overwritten. 
    
    cp opt/xcat/share/xcat/**netboot**/&lt;platform&gt;/*postinstall /install/custom/**netboot**/&lt;platform&gt;/.
    

Use these basic rules to edit the correct file in the **/install/custom/netboot/&lt;platform&gt;** directory. The rule allows you to customize your image down to the profile, os and architecture level, if needed. 

You will find *postinstall files of the following formats and they will process the files in the order of the below formats: 

  

    
    &lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.postinstall
    &lt;profile&gt;.&lt;arch&gt;.postinstall
    &lt;profile&gt;.&lt;os&gt;.postinstall
    &lt;profile&gt;.postinstall
    

  


**This means, if "&lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.postinstall" is there, it will be used first.**

  * If there is no such a file, then the "&lt;profile&gt;.&lt;arch&gt;.postinstall" file will be used. 
  * If there's no such a file , then the "&lt;profile&gt;.&lt;os&gt;.postinstall" file will be used. 
  * If there is no such file, then it will use "&lt;profile&gt;.postinstall". 

  


You can add more postinstall process ,if you want. The basic postinstall script (2.4) will be named &lt;profile&gt;.&lt;arch&gt;.postinstall ( e.g. compute.ppc64.postinstall). You can create one for a specific os by copying the shipped one to , for example, compute.rhels5.4.ppc64.postinstall 

##### Setting up Files to be synchronized on the nodes

Refer to the following documentation for setting up synclist files [Sync-ing_Config_Files_to_Nodes]. 

##### **Generate/pack the image**
    
    cd /opt/xcat/share/xcat/netboot/rh/
    ./genimage -i eth0 -n tg3,bnx2 -o rhels6 -p compute
    

  
The genimage will create a default /etc/fstab in the image, for example: 
    
    devpts  /dev/pts devpts   gid=5,mode=620 0 0
    tmpfs   /dev/shm tmpfs    defaults       0 0
    proc    /proc    proc     defaults       0 0
    sysfs   /sys     sysfs    defaults       0 0
    tmpfs   /tmp     tmpfs    defaults,size=10m             0 2
    tmpfs   /var/tmp     tmpfs    defaults,size=10m       0 2
    compute_x86_64    /   tmpfs   rw  0 1
    

  
If you want to change the defaults, on the management node, edit fstab in the image or use a postinstall script ( see below): 

**Edit fstab in the image:**
    
    cd /install/netboot/rhels6/x86_64/compute/rootimg/etc
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

**Use postinstall script**

Another way to change the fstab during image generation is to use a postinstall script. Add lines such as the following to your postinstall script and then follow the instructions for setting up your postinstall before running the genimage. 
    
    #-- Example how /etc/fstab can be automatically generated during image generation:
    cat &lt;END &gt;$installroot/etc/fstab
    proc            /proc    proc   rw 0 0
    sysfs           /sys     sysfs  rw 0 0
    devpts          /dev/pts devpts rw,gid=5,mode=620 0 0
    ${profile}_${arch}      /        tmpfs  rw 0 1
    none            /tmp     tmpfs  defaults,size=15m 0 2
    none            /var/tmp tmpfs  defaults,size=15m 0 2
    END
    

  


  


  * Pack the image: 
    
    packimage -o rhels6 -p compute -a x86_64
    

##### Build the stateless image off the MN

  * **If the stateless image you are building doesn't match the OS/architecture of the management node**, logon to the node with the desired architecture. Here the Management Node name is xcatmn. 

  

    
    ssh &lt;node&gt;
    mkdir /install
    mount xcatmn:/install /install ( make sure the mount is rw)
    

  
Create rhels6.repo: 
    
    cd /etc/yum.repos.d
    rm -f *.repo
    

  
Put the following lines in /etc/yum.repos.d/rhels6.repo: 
    
    [rhels6]
    name=rhels6 $releasever - $basearch
    baseurl=file:///install/rhels6/x86_64
    enabled=1
    gpgcheck=0
    

Test with: yum search gcc 

  
Copy the executables and files needed from the Management Node: 
    
    mkdir /root/netboot
    cd /root/netboot
    scp xcatmn:/opt/xcat/share/xcat/netboot/rh/genimage .
    scp xcatmn:/opt/xcat/share/xcat/netboot/rh/geninitrd .
    scp xcatmn:/opt/xcat/share/xcat/netboot/rh/compute.x86_64.pkglist .
    scp xcatmn:/opt/xcat/share/xcat/netboot/rh/compute.exlist .
    scp -r xcatmn:/opt/xcat/share/xcat/netboot/rh/dracut/ . 
    

  * Generate the image: 

To build the image on the node run: 
    
    ./genimage -i eth0 -n tg3 -o rhels6 -p compute
    

  


  * On the xCAT Management Node, edit fstab in the image, if you need to change the default. 

See the section above on building the stateless image on the MN. 

  


  * Pack the image on xcatmn: 
    
    packimage -o rhels6 -p compute -a x86_64
    

##### Test Boot the Stateless Image

You can continue to customize the image and then you can boot a node with the image: 

  

    
    nodeset &lt;nodename&gt; netboot
    rpower &lt;nodename&gt; boot
    

  
You can monitor the install by running: 
    
    rcons &lt;nodename&gt;
    tail -f /var/log/messages
    
