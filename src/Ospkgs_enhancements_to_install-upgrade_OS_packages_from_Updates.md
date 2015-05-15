<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Main Points](#main-points)
- [osimage definition and enhancement in ospkgs](#osimage-definition-and-enhancement-in-ospkgs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

The Mini-design of the item ospkgs enhancements to install/upgrade OS packages from Updates is as following: 

## Background

In xCAT, there are two methods to support osimage definition: 

(1)The first method is that when the provmethod is set to install/netboot/statelite, copycds will generate the default osimages as following: rhels6.2-ppc64-install-compute, rhels6.2-ppc64-netboot-compute, rhels6.2-ppc64-statelite-compute and so on. 

(2) The second method is that when the provmethod is set to one osimage, such as testimage which is defined by the users 

It's flexible to use the second method in xCAT. Actually, we recommend the customers to define the osimage, and set the provmethod to one osimage, instead of install/netboot/statelite. 

Currently, the pkgdir in the ospkgs scripts only supports one package path, and the kerneldir isn't support in the ospkgs. 

## Main Points

There are two parts in this item which will support for the second method of the osimage which is set to the provmethod, not support for the first method: 

1\. Support pkgdir with multiple paths in the ospkgs 

2\. Support kerneldir in the ospkgs 

**[NOTE:]**We will support this item in sles11 and rhels6. 

## osimage definition and enhancement in ospkgs

At present, the osimage definition may be as following: 
    
    Object name: testimg
       exlist=/opt/xcat/share/xcat/netboot/rh/compute.exlist
       imagetype=linux
       osarch=ppc64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/ppc64
       permission=755
       pkgdir=/install/rhels6.2/ppc64
       pkglist=/install/custom/netboot/rh/compute.rhels6.ppc64.pkglist
       postinstall=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.postinstall
       profile=compute
       provmethod=netboot
       rootimgdir=/install/netboot/rhels6.2/ppc64/testimg
    

To support the multiple paths of pkgdir and the kerneldir in the ospkgs, the osimage will be defined as following: 
    
    Object name: testimg
       exlist=/opt/xcat/share/xcat/netboot/rh/compute.exlist
       imagetype=linux
       kerneldir=/install/kernels
       osarch=ppc64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/ppc64
       permission=755
       pkgdir=/install/rhels6.2/ppc64/Server,/install/rhels6.2-updates/ppc64/Server
       pkglist=/install/custom/netboot/rh/compute.rhels6.ppc64.pkglist
       postinstall=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.postinstall
       profile=compute
       provmethod=netboot
       rootimgdir=/install/netboot/rhels6.2/ppc64/testimg
    

  
The ospkgs script will create the repos files for the kerneldir, and for each paths in the pkgdir. And when install/upgrade os packages, the repos files will be used. 
