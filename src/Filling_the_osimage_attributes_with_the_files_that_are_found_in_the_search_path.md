<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Feature purpose](#feature-purpose)
- [External interface](#external-interface)
- [Internal](#internal)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## Feature purpose

To fill in the osimage attribute automatically when define or change define of osimage. The main osimage attributes included are: template(only for diskfull), pkglist, pkgdir, otherpkglist, otherpkgdir, exlist(only for diskless), postinstall(only for diskless), rootimgdir 

## External interface

  1. add an option "-u" for mkdef/chdef comand to automatically set osimage attribute. 
  2. For chdef, if no attr=value parameter specified, just redo the file seaching. 
    
    mkdef imagename -u provmethod=&lt;install|netboot|statelite&gt; profile=&lt;xxx&gt; [attr=value]
    chdef imagename -u [provmethod=&lt;install|netboot|statelite&gt;]|[profile=&lt;xxx&gt;]|[attr=value]  
    cat stanza_file | mkdef -z -u
    cat stanza_file | chdef -z -u
    

note: The provmethod and profile options are pre-requisite for mkdef. If osvers or osarch is not specified, the corresponding value of the management node will be used. 

The commands may work as the following: 
    
    [root@rhmn ~]# mkdef redhat6img -u profile=compute provmethod=statelite
    1 object definitions have been created or modified.
    [root@rhmn ~]# lsdef -t osimage redhat6img
    Object name: redhat6img
       exlist=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.exlist
       imagetype=linux
       osarch=x86_64
       osdistroname=rhels6.2-x86_64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/x86_64
       pkgdir=/install/rhels6.2/x86_64
       pkglist=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.pkglist
       postinstall=/opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.postinstall
       profile=compute
       provmethod=statelite
       rootimgdir=/install/netboot/rhels6.2/x86_64/compute
    [root@rhmn ~]# chdef redhat6img -u provmethod=install
    1 object definitions have been created or modified.
    [root@rhmn ~]# lsdef -t osimage redhat6img           
    Object name: redhat6img
       imagetype=linux
       osarch=x86_64
       osdistroname=rhels6.2-x86_64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/x86_64
       pkgdir=/install/rhels6.2/x86_64
       pkglist=/opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.pkglist
       profile=compute
       provmethod=install
       template=/opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.tmpl
    

The following examples show that the original options are alse working if option '-u' is added. 
    
    [root@rhmn ~]# chdef -t osimage -o redhat6img -u -n rh6img
    Changed the object name from redhat6img to rh6img.
    [root@rhmn ~]# mkdef redhat6img -u profile=compute provmethod=install
    1 object definitions have been created or modified.
    [root@rhmn ~]# chdef redhat6img,rh6img -u osarch=ppc64
    2 object definitions have been created or modified.
    [root@rhmn ~]# lsdef -t osimage rh6img
    Object name: rh6img
       imagetype=linux
       osarch=ppc64
       osdistroname=rhels6.2-ppc64
       osname=Linux
       osvers=rhels6.2
       otherpkgdir=/install/post/otherpkgs/rhels6.2/ppc64
       pkgdir=/install/rhels6.2/ppc64
       pkglist=/opt/xcat/share/xcat/install/rh/compute.rhels6.ppc64.pkglist
       profile=compute
       provmethod=install
       template=/opt/xcat/share/xcat/install/rh/compute.rhels6.ppc64.tmpl
    

## Internal

1\. If option '-u' specified, try to search files(tmpl_file, otherpkgs_list_file, pkglist_file, synclist_file) based on the specified parameters (osarch,osvers,provmethod,profile,imagetype). First search customized path($installroot/custom/netboot/$osname), and then default path(/opt/xcat/share/xcat/netboot/$osname/). 

2\. Treat those searched files as specified parameters passing into the main process of mkdef or chdef. 

3\. Update osimage table and linuximage table. 

  


## Other Design Considerations

  * **Required reviewers**: Bruce Potter, Guang Cheng, Ling Gao, Linda 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
