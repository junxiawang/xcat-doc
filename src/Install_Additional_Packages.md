<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Installing Additional Packages Using an Otherpkgs Pkglist](#installing-additional-packages-using-an-otherpkgs-pkglist)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Installing Additional Packages Using an Otherpkgs Pkglist

If you have additional rpms (rpms **not** in the distro) that you also want installed, make a directory to hold them, create a list of the rpms you want installed, and add that information to the osimage definition: 

  * Create a directory to hold the additional rpms: 
    
    mkdir -p /install/post/otherpkgs/rh/x86_64
    cd /install/post/otherpkgs/rh/x86_64
    cp /myrpms/* .
    createrepo .
    

**NOTE**: when the management node is rhels6.x, and the otherpkgs repository data is for rhels5.x, we should run createrepo with "-s md5". Such as: 
    
    createrepo -s md5 .
    

  * Create a file that lists the additional rpms that should be installed. For example, in /install/custom/netboot/rh/compute.otherpkgs.pkglist put: 
    
    myrpm1
    myrpm2
    myrpm3
    

  * Add both the directory and the file to the osimage definition: 
    
    chdef -t osimage mycomputeimage otherpkgdir=/install/post/otherpkgs/rh/x86_64 otherpkglist=/install/custom/netboot/rh/compute.otherpkgs.pkglist
    

If you add more rpms at a later time, you must run createrepo again. The createrepo command is in the createrepo rpm, which for RHEL is in the 1st DVD, but for SLES is in the SDK DVD. 

If you have **multiple sets of rpms** that you want to **keep separate** to keep them organized, you can put them in separate sub-directories in the otherpkgdir. If you do this, you need to do the following extra things, in addition to the steps above: 

  * Run createrepo in each sub-directory 
  * In your otherpkgs.pkglist, list at least 1 file from each sub-directory. (During installation, xCAT will define a yum or zypper repository for each directory you reference in your otherpkgs.pkglist.) For example: 
    
    xcat/xcat-core/xCATsn
    xcat/xcat-dep/rh6/x86_64/conserver-xcat
    

There are some examples of otherpkgs.pkglist in /opt/xcat/share/xcat/netboot/&lt;distro&gt;/service.*.otherpkgs.pkglist that show the format. 

Note: the otherpkgs postbootscript should by default be associated with every node. Use lsdef to check: 
    
    lsdef node1 -i postbootscripts
    

If it is not, you need to add it. For example, add it for all of the nodes in the "compute" group: 
    
    chdef -p -t group compute postbootscripts=otherpkgs
    
