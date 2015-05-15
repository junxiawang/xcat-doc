<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Changes of xCAT Interface](#changes-of-xcat-interface)
  - [Modify the pkglist file](#modify-the-pkglist-file)
  - [Download the dracut, dracut-network, dracut-kernel and kexec-tools](#download-the-dracut-dracut-network-dracut-kernel-and-kexec-tools)
  - [Modify the other package list file](#modify-the-other-package-list-file)
  - [The exclude file](#the-exclude-file)
  - [Define dump attribute](#define-dump-attribute)
  - [The _crashkernelsize_ attribute](#the-_crashkernelsize_-attribute)
  - [The enablekdump postscript](#the-enablekdump-postscript)
  - [Provision](#provision)
  - [Notes](#notes)
  - [Testing](#testing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This document illustrates how to configure and use fadump on the RHEL6 diskless nodes on power 775 by xCAT. 


## Overview

Fadump means "Firmware-Assisted Dump". The goal of firmware-assisted dump is to enable the dump of a crashed system, and to do so from a fully-reset system, and to minimize the total elapsed time until the system is back in production use. Can refer [Firmware-Assisted Dump](http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob_plain;f=Documentation/powerpc/firmware-assisted-dump.txt;hb=HEAD) for more introduction. 

## Changes of xCAT Interface

### Modify the pkglist file

For RHEL6, there're two rpm packages should be **deleted**: 

  * dracut 
  * dracut-network 

The pkglist file location is defined as an attribute in osimage object, can fetch it by 
    
    lsdef -t osimage -o &lt;osimage name&gt;
    

The default location is **/opt/xcat/share/xcat/netboot/rh/&lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.pkglist**. You can create the customeized pkglist file, and change the pkglist attribute in osimage object with 
    
    chdef -t osimage -o &lt;osimage name&gt; pkglist=&lt;the customized pkglist file path&gt;
    

### Download the dracut, dracut-network, dracut-kernel and kexec-tools

Download the [dracut], [dracut-network], [dracut-kernel] and [kexec-tools]. Save all of these 4 rpms into other packages directory. Run the createrepo to create yum repo: 
    
    createrepo  &lt;the rpms save path&gt;
    

The other packages directory is defined as the **otherpkgdir**attribute in osimage object. It can be got and changed by xCAT command like the paglist file. 

### Modify the other package list file

Create a other packages list file, like /install/custom/netboot/rh/fadump.otherpkgs.pkglist. Add the 4 rpms into this file: 
    
    dracut
    dracut-kernel
    dracut-network
    kexec-tools
    

The other packages list file is defined as the **otherpkglist**attribute in osimage object. It can be got and changed by xCAT command like the paglist file. 

### The exclude file

The base diskless image excludes the **/boot** directory, but it is required for kdump. Update the _&lt;profile&gt;.exlist_ and remove the entry for **/boot**. Usually, the _&lt;profile&gt;.exlist_ file is located in _/opt/xcat/share/xcat/netboot/&lt;platform&gt;_, and the user-customized _&lt;profile&gt;.exlist_ should be located in _/install/custom/netboot/&lt;platform&gt;/_. Then run _packimage_ or _liteimg_ command. 

### Define dump attribute

Change the **dump** attribute in osimage object: 
    
    chdef -t osimage -o &lt;osimage name&gt; dump=fadump:nfs://&lt;nfs_server_ip&gt;/&lt;fadump_path&gt;
    

The **&lt;nfs_server_ip&gt;** can be excluded if the destination NFS server is the service or management node. 
    
    chdef -t osimage -o &lt;osimage name&gt; dump=fadump:nfs:///&lt;fadump_path&gt;
    

### The _crashkernelsize_ attribute

If you do not set this attribute, the default value will be 
    
     256M@32M
    

When your node start, and meet the kdump start error like this 
    
     Your running kernel is using more than 70% of the amount of space you reserved for kdump, you should consider increasing your crashkernel
    

You should modify this attribute by chdef command: 
    
     chdef -t osimage &lt;image name&gt; crashkernelsize=512M@32M
    

If 512M@32M is not large enough, you should change the crashkernelsize larger like 1024M untill the error message disappear. For Power775, the suggested size is 3072M@32M. 

### The enablekdump postscript

This postscript _enablekdump_ is used to start the kdump service when the node is booting up. 
    
     chdef -t node &lt;node range&gt; -p postscripts=enablekdump
    

### Provision

Run **genimage &lt;osimage name&gt;**, **packimage &lt;osimage name&gt;**, **nodeset &lt;node range&gt; osimage=&lt;osimage name&gt;** to deploy the nodes. 

### Notes

Currently, only _NFS_ is supported for the setup of kdump. 

If the _dump_ attribute is not set, the fadump service will not be enabled. 

Please make sure the NFS remote path(**fadump:nfs://&lt;nfs_server_ip&gt;/&lt;kdump_path&gt;**) is exported and it is read-writeable to the node where fadump service is enabled. 

### Testing

Fadump testing method is same with fadump, refer [ How to trigger kernel panic on Linux](Kdump_over_Ethernet/HFI_for_Linux_diskless_nodes#How_to_trigger_kernel_panic_on_Linux_) 
