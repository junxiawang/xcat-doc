Currently, the osimage definition is as follows: 

[root@hv32s5fp12 ~]# lsdef -t osimage -o full 
    
    Object name: full
       imagetype=linux
       osarch=ppc64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/ppc64
       **pkgdir=/install/rhels6.2/ppc64**
       pkglist=/opt/xcat/share/xcat/install/rh/compute.rhels6.ppc64.pkglist
       postbootscripts=KIT_PCM_setupego
       profile=compute
       provmethod=install
       template=/opt/xcat/share/xcat/install/rh/compute.rhels6.ppc64.tmpl
    

  
And in the item of ospkgs enhancements to install/upgrade OS packages from Updates, the users can append other paths for pkgdir, and the osimage definition could be: 

[root@hv32s5fp12 ~]# lsdef -t osimage -o full 
    
    Object name: full
       imagetype=linux
       osarch=ppc64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/ppc64
       **pkgdir=/install/rhels6.2/ppc64,/install/updates**
       pkglist=/opt/xcat/share/xcat/install/rh/compute.rhels6.ppc64.pkglist
       postbootscripts=KIT_PCM_setupego
       profile=compute
       provmethod=install
       template=/opt/xcat/share/xcat/install/rh/compute.rhels6.ppc64.tmpl
    

**Notes:**

**(1)all the pkg dirs should be in the site.installdir directory**

**(2) all the pkg names in the pkglist should be in the os based pkg dir, and in the other paths for pkgdir, there should be the updates of some os based pkgs**

**(3)in the os base pkg dir, there are default repository data. And in the other pkg dir(s), the users should make sure there are repository data. If not, use "createrepo" command to create them. **

  
When user run updatenode with ospkgs, it will do the update from the multiple paths. 

When the osimage.pkgdir with multiple path, PCM requires it could do the genimage and diskfull installation. 

1\. For genimage 

At the beginning, the genimage should create the repositories for each pkg path, and generate the rootimage from the multiple paths of pkgdir. 

We can change the code in ./xCAT-server/share/xcat/netboot/rh/genimage for rhels and ./xCAT-server/share/xcat/netboot/sles/genimage for sles11. 

2\. For diskfull installation 

2.1 Problem 

Currently, for rhels, nodeset addes the repository of the pkgdir into the yaboot configuration file, such as: 

append="quiet repo=http://11.10.3.1:80/install/rhels6.2/ppc64/ ks=http://11.10.3.1:80/install/autoinst/cn001 ksdevice=9a:ca:be:a9:ad:02" 

The option repo= "tells anaconda where to find the packages for installation. This option must point to a valid yum repository. It is analagous to the older method= option, but repo= makes it more clear exactly what is meant. **This option may appear only once on the command line.** It corresponds to the kickstart command install (whereas kickstart command repo is used for additional repositories). " 

for sles, nodeset addes the repository of the pkgdir into the yaboot configure file for ppc64 (xnba and the &lt;node&gt;.elilo for x86_64). 

imgargs kernel quiet autoyast=http://10.1.0.227:80/install/autoinst/dx360m3n05 install=http://10.1.0.227:80/install/sles11.2/x86_64/1 netdevice=5C:F3:FC:A8:BF:58 console=tty0 console=ttyS0,115200n8r BOOTIF=01-${netX/machyp} 

It looks like we could not add the multiple repositories into the yaboot/xnba config file. 

2.2 Solution 

We have discussed a solution for PCM, as follows: 
    
    (1) the first path in the value of osimage.pkgdir should be the OS base pkg dir. such as pkgdir=/install/rhels6.2/ppc64**,/install/updates**
    (2) nodeset will use the first path as the repository
    (3) add the ospkgs into the **postbootscripts**, such as postbootscripts=syncfiles,**ospkgs**,otherpkgs
    (4) continue to do the full installation
    
