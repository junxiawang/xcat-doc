<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Adding the Management Node](#adding-the-management-node)
  - [xdsh/xdcp](#xdshxdcp)
  - [updatenode](#updatenode)
  - [Restrictions and limitations](#restrictions-and-limitations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)
  



## Overview

**This document is a work in progress.**

As of the xCAT 2.8 release, you can add the Management Node to the xCAT database and manage it with xCAT. Note: as of 2.8.1 it will also add the Management Node to the servicenode table and setup default services. Below is a 2.8.1 example, with servicenode setup on Linux. 

### Adding the Management Node

To add the Management Node, use the xcatconfig -m interface. This will add it to the xCAT database such that xCAT code can recognize it as the Management Node. 
  
~~~~  
    xcatconfig -m
~~~~    

~~~~    
    lsdef __mgmtnode
    Object name: xcat20rrmn
       groups=__mgmtnode
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell
       setuptftp=yes
~~~~    

As of 2.8.1, on Linux the servicenode tftpserver attribute will be set on by default. The servicenode ftpserver will be set based on the setting of the site table vsftp setting. If changed the servicenode setting will override the site table vsftp setting. 

On AIX, the Management Node is put in the servicenode table but no attributes are set to start services by default. 

### xdsh/xdcp

You can use xdsh/xdcp on the Management Node without setting up ssh keys. The commands will recognize that they are running local and use sh,cp, and local rsync. 

### updatenode

You can run updatenode -P,-S,-F on the Management Node to itself. More setup may be required. 

TBD: Talk about Management Node image creation. 

### Restrictions and limitations

  * You can add additional groups to the Management Node definition in the database, but do not remove the __mgmtnode group. 
  * It is highly recommended not to assign the management node with the compute nodes in a group, or put the Management Node in the "all" group. This is to avoid accidentally running commands you would not want to on the Management Node. 
  * The xdsh -K, updatenode -k and remoteshell postscript will not run on the Management Node; so as to not change the ssh setup. 
  * If you set the servicenode table dhcpserver attribute, xCAT will only start dhcpd if not running. This is only supported on Linux. 
  * Any changes to the servicenode table, only perform the setup when the xcatd daemon is restarted. 
