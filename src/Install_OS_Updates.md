<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Installing OS Updates By Setting linuximage.pkgdir(only support for rhels and sles)](#installing-os-updates-by-setting-linuximagepkgdironly-support-for-rhels-and-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Installing OS Updates By Setting linuximage.pkgdir(only support for rhels and sles)

The linuximage.pkgdir is the name of the directory where the distro packages are stored. It can be set to multiple paths. The multiple paths must be separated by ",". The first path is the value of osimage.pkgdir and must be the OS base pkg directory path, such as pkgdir=/install/rhels6.5/x86_64,/install/updates/rhels6.5/x86_64 . In the os base pkg path, there is default repository data. In the other pkg path(s), the users should make sure there is repository data. If not, use "createrepo" command to create them. 

If you have additional os update rpms (rpms may be come directly the os website, or from one of the os supplemental/SDK DVDs) that you also want installed, make a directory to hold them, create a list of the rpms you want installed, and add that information to the osimage definition: 

  * Create a directory to hold the additional rpms: 

~~~~    
    mkdir -p /install/updates/rhels6.5/x86_64 
    cd /install/updates/rhels6.5/x86_64 
    cp /myrpms/* .
~~~~   

OR, if you have a supplemental or SDK iso image that came with your OS distro, you can use copycds:

~~~~
    copycds RHEL6.5-Supplementary-DVD1.iso -n rhels6.5-supp
~~~~


If there is no repository data in the directory, you can run "createrepo" to create it: 

~~~~    
    createrepo .
~~~~    

The createrepo command is in the createrepo rpm, which for RHEL is in the 1st DVD, but for SLES is in the SDK DVD. 

**NOTE**: when the management node is rhels6.x, and the otherpkgs repository data is for rhels5.x, we should run createrepo with "-s md5". Such as: 

~~~~    
    createrepo -s md5 .
~~~~    

  * Append the additional packages to install into the corresponding pkglist. For example, in /install/custom/install/rh/compute.rhels6.x86_64.pkglist, append: 
    

~~~~
    ...
    myrpm1
    myrpm2
    myrpm3
~~~~

Remember, if you add more rpms at a later time, you must run createrepo again. 
    

  * If not already specified, set the custom pkglist file in your osimage definition: 
 
~~~~   
    chdef -t osimage mycomputeimage pkglist=/install/custom/install/rh/compute.rhels6.x86_64.pkglist
~~~~    
 

  * Add the new directory to the list of package directories in your osimage definition: 

~~~~   
    chdef -t osimage mycomputeimage -p pkgdir=/install/updates/rhels6.5/x86_64
~~~~    

OR, if you used copycds:

~~~~   
    chdef -t osimage mycomputeimage -p pkgdir=/install/rhels6.5-supp/x86_64
~~~~    



Note: After making the above changes, 

  * For diskfull install, run "nodeset &lt;noderange&gt; mycomputeimage" to pick up the changes, and then boot up the nodes 
  * For diskless or statelite, run genimage to install the packages into the image, and then packimage or liteimg and boot up the nodes. 
  * If the nodes are up, run "updatenode &lt;noderange&gt; ospkgs" to update the packages. 
  * These functions are only supported for rhels6.x and sles11.x 
