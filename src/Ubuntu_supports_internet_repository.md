<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [problems](#problems)
- [Interface](#interface)
  - [specify the repository](#specify-the-repository)
  - [compute node can not access internet](#compute-node-can-not-access-internet)
- [Internal Implementation](#internal-implementation)
  - [stateful](#stateful)
  - [stateless](#stateless)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

This is the mini-design of supporting internet/local official distribution repository for other packages installation on the ubuntu compute node. The Ubuntu iso only contains the basic packages which used for OS installation(657MB), it can not satisfy the otherpkg installtion on compute node. Ubuntu has many official distribution repository mirrors on the internet, so compute node can use the official distribution repository mirror for the other pakcages installation. 

If want to use ospkglist file method to install packages, before adding package name into this file, should ensure the package is contained in the ubuntu iso. All packages that does not contained in the ubuntu iso should use otherpkg method to install. 

### problems

  * where specify the internet repository? 
  * If the compute node can not access the internet, how to use the official distribution repository? 

## Interface

### specify the repository

Use the otherpkgdir attribute in linuximage table to save the internet repository URL, so xCAT should support multiple otherpkgdirs (currently only on ubuntu), and repository direcotries are splited by ','. 

  * modify the otherpkgdir attribute for osimage object. 
    
    chdef -t osimage &lt;osimage name&gt; otherpkgdir="/install/ubuntu12.04.1/x86_64/,http://us.archive.ubuntu.com/ubuntu/ precise main"
    

The first directory is a repository on MN, the method of creating local repository on management node will be introduced in the Ubuntu quick start document. The second one is a official mirror URL on the internet. the _precise_ means the suite for the ubuntu version. the _main_ means the base component which will be used. 

  * create an otherpkglist file, /install/custom/install/ubuntu/compute.otherpkgs.pkglist. Add the packages' name into thist file. And modify the otherpkglist attribute for osimage object. 
    
    chdef -t osimage &lt;osimage name&gt; otherpkglist=/install/custom/install/ubuntu/compute.otherpkgs.pkglist
    

### compute node can not access internet

There are 2 scenarios: 

1\. The management node can access the internet 

    a. Install the Squit on management node, and configure the proxy server. (introduced in the quick start) 
    b. add the aptproxy script to the postscript(a new script), it can configure the apt to use proxy when downloading packages. 

2\. The management node can not access the internet either 

    a. If the packages installed on the compute node change frequently, 

    i. use "apt-mirror" to create a local mirror. 
    ii. add this local mirror to the otherpkgdir attribute, apt on the compute node can download packages from this local mirror. 
    b. else 

    i. use "apt-rdepends" to find out all dependent packages' name. 
    ii. use "apt-get install &lt;packages' name&gt; -d" to download all needed packages 
    iii. copy these packages to management node, use "dpkg-scanpackages" to create a repository on the management node. (introduced in the quick start) 

## Internal Implementation

Only the internet distribution mirror includes some code modification, the local repository on the management node use the current process. 

### stateful

  * otherpkgs script 

All repositories which used for other packages installation are saved in "/etc/apt/sources.list.d/xCAT-otherpkgs.list". When parse the $OTHERPKGDIR, and the os belongs to ubuntu, 

    a. split the $OTHERPKGDIR by ',' 
    b. if the repo started by http, add it into the xCAT-otherpkgs.list directly. 
    c. if the repo does not started by http, should did some modification to the repo address, and append to the xCAT-otherpkgs.lis. 

  * aptproxy script 

add a file /etc/apt/apt.conf.d/proxy, append a line to specify this proxy server. 

### stateless

  * genimage 

    a. add the otherpkgdir into the /&lt;rootimagedir&gt;/etc/apt/sources.list.d/xCAT-otherpkgs.list, similar with the stateful scenario. 
    b. backup the /&lt;rootimagedir&gt;/etc/hosts and resolv.conf in the stateless root image. 
    c. copy the management node's /etc/hosts and /etc/resolv.conf to the /&lt;rootimagedir&gt;, it can access the internet after chroot 
    d. install other packages into the root image. 
    e. recover the /&lt;rootimagedir&gt;/etc/hosts and resolv.conf 

  * genimage.pm 

    a. the value of --otherpkgdir should be embraced by ". 

## Other Design Considerations

  * **Required reviewers**: Bruce, Gao Ling, Li Guang Cheng, Jin Jie Hua 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: the ubuntu quick start document 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
