<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Requirement/Restriction](#requirementrestriction)
- [External Interfaces](#external-interfaces)
  - [Packages](#packages)
  - [imgcapture changes](#imgcapture-changes)
  - [sysclone osimage repository](#sysclone-osimage-repository)
  - [nodeset not changed](#nodeset-not-changed)
- [Internal Implementation](#internal-implementation)
  - [imgcapture.pm changed](#imgcapturepm-changed)
  - [anaconda.pm changed](#anacondapm-changed)
- [Design Considerations](#design-considerations)
  - [xcat-sysclone rpm](#xcat-sysclone-rpm)
  - [updatenode](#updatenode)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

NOTE: This page is still under construction. 


## Overview

Imaged Provisioning leverages an open source tool called [SystemImager](http://www.systemimager.org). SystemImager is software that automates GNU/Linux installs, software distribution, and production deployment. The standard method of image creation in SystemImager involves cloning of a pre-installed machine, the golden-client. In this way, the user can customize and tweak the golden-client’s configuration according to his needs, verify it’s proper operation, and be assured that the image, once deployed, will behave in the same way as the golden-client. The main goal of the project is to make deployment of large numbers of computers easy. 

xCAT integrates the image creation and system cloning features from SystemImager, to have the ability of capturing osimage from a diskful node(as golden client in SystemImager term) to clone diskful nodes with this osimage. This is a new provision methos, we call it "**sysclone**". 

## Requirement/Restriction

  * **sysclone** is supported in xcat2.8 or beyond. 
  * No hierarchy support in xcat2.8. (need discuss if we really need hierarchy support, or requirement driven?) 
  * AIX is not supported. If you want AIX cloning install, refer to AIX mksysb procedure. 
  * RedHat6.x on System x(x3550) have been tested, Software RAID or LVM are not included. 
  * The node we will capture osimage from(the golden client) should be a diskful Linux node, managed by the xCAT management node, and the remote shell between the management node and the node should have been configured. 
  * Ensure SystemImager packages have been already installed on both the management node and the golden client. Use updatenode/otherpackages to install them on the golden client.(will document this procedure in sysclone documentation.) 
  * The hard disk on the target nodes must be equal or larger than the golden client. 

## External Interfaces

### Packages

Since SystemImager packages are a little big(about 20M for each arch), we will make a separate xcat-dep tarball xcat-sysclone to pick them up. The user can download this tarball from xCAT download site only when he wants to use the **sysclone** provmethod. 

We do not want the user to download SystemImager packages from SystemImager official download site directly, because it might be very possible that someone will contribute new codes to this open source project while it might break our functions. The xcat-sysclone tarball has been tested by our fvt, should be more stable. 

Package list for SystemImager: 
    
       size   rpm
       60039  perl-AppConfig-1.52-4.noarch.rpm
       88234  systemconfigurator-2.2.11-1.noarch.rpm
       22120  systemimager-bittorrent-4.2.0-0.91svn4568.el6.noarch.rpm  (optional)
       72488  systemimager-client-4.2.0-0.91svn4568.el6.noarch.rpm
       49024  systemimager-common-4.2.0-0.91svn4568.el6.noarch.rpm
       53344  systemimager-flamethrower-4.2.0-0.91svn4568.el6.noarch.rpm  (optional)
      408760  systemimager-server-4.2.0-0.91svn4568.el6.noarch.rpm
    23361484  systemimager-x86_64boot-standard-4.2.0-0.91svn4568.el6.noarch.rpm  (optional)
    17929592  systemimager-x86_64initrd_template-4.2.0-0.91svn4568.el6.noarch.rpm
    

Provide sysclone.&lt;osname&gt;.&lt;arch&gt;.otherpkgs.pkglists to help install SystemImager packages onto the golden client. For example, sysclone.rhels6.x86_64.otherpkgs.pkglist 

**Question**: do we need to build these rpms by ourselves as xcat-dep does? or can download them directly as shared by other SystemImager contributors? 

### imgcapture changes

The existing imgcapture command is used to capture an osimage from a diskful Linux node, then install stateless/statelite nodes. Since **sysclone** is different than the original imgcapture usage, so add a new flag -t|--type. -t diskless(or some other word) is used to keep the original logic, -t sysclone is used for the new logic. We can reduce the effect to the existing logic by this. 

usage change: 
    
      imgcapture &lt;node&gt; -t sysclone -o &lt;osimage&gt;     #The &lt;node&gt; is the golden client in systemimager term. 
      imgcapture &lt;node&gt; -t diskless xxxxx 
    

In imgcapture &lt;node&gt; -t sysclone, the osimage is not predefined, imgcapture will create the osimage definition after capture completed. Set osimage.provmethod=sysclone to identify this new provmethod. 

Here is an example of basic diskful osimage definition: 
    
    Object name: rhels6.3-x86_64-install-compute
       imagetype=linux
       osarch=x86_64
       osdistroname=rhels6.3-x86_64
       osname=Linux
       osvers=rhels6.3
       otherpkgdir=/install/post/otherpkgs/rhels6.3/x86_64
       pkgdir=/install/rhels6.3/x86_64
       pkglist=/opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.pkglist
       profile=compute
       provmethod=install
       template=/opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.tmpl
    

Here is an example of sysclone osimage definition: 
    
    Object name: rhel6.3img
       imagetype=linux
       osarch=x86_64
       osdistroname= (changed!)
       osname=Linux
       osvers=rhels6.3
       otherpkgdir=/install/post/otherpkgs/rhels6.3/x86_64
       pkgdir= (changed!)
       pkglist= (changed!)
       profile= (changed!)
       provmethod=sysclone (changed!)
       template= (changed!)
       postscripts=efibootloader,update_network(new added!)
    

### sysclone osimage repository

The sysclone osimage repository is located in /install/sysclone/images/&lt;osimage&gt; by default, it's specified in /etc/systemimager/systemimager.conf: 
    
      DEFAULT_IMAGE_DIR = /install/sysclone/images 
      DEFAULT_OVERRIDE_DIR = /install/sysclone/overrides 
      AUTOINSTALL_SCRIPT_DIR = /install/sysclone/scripts 
    

    Note: since the scripts and overrides can be shared among different images, so they are separate directories under /install/sysclone. These directories are used by rsync daemon. 

**Question**: currently we do not support customizing the location for the sysclone osimage, which means all sysclone osimages will be put in the same home directory /install/sysclone/images. We might need to check with PCM team if this could work for them. If PCM requires a different home directory, we need to add a new flag to imgcapture to specify the image location, such as -l|--location. 

### nodeset not changed

This implementation does not impact the external interface of nodeset, just use it as before. 

## Internal Implementation

### imgcapture.pm changed

  * On the golden client: 

    Use xCAT::Utils-&gt;runxcmd to execute xdsh to the golden client: 

  * Check if systemimager packages have been installed. Report error and exit if not. 
  * Fix the shipped default inittab - /usr/share/systemimager/boot/x86_64/standard/initrd_template/etc/inittab, make output to tty instead of askfirst. 
  * LANG=C si_prepareclient --server &lt;xcatmaster&gt; \--my-modules --yes 

  * On the management node: 

    

  * Configure sysclone image repository in /etc/systemimager/systemimager.conf: 
    
      DEFAULT_IMAGE_DIR = /install/sysclone/images 
      DEFAULT_OVERRIDE_DIR = /install/sysclone/overrides 
      AUTOINSTALL_SCRIPT_DIR = /install/sysclone/scripts
    

    

  * LANG=C si_getimage -golden-client &lt;node&gt; -image &lt;osimage&gt; -ip-assignment dhcp -post-install reboot -quiet -update-script YES 
  * Create xcat osimage definition. 

### anaconda.pm changed

Add a new subroutine mksysclone(), similar with mkinstall() except: 

    

  * Modify /etc/systemimager/cluster.xml to associate the osimage with target node. 
  * Copy the scripts below from /install/postscripts/ to /install/systemimager/scripts/post-install: 
    
          runxcatpost     # used as a starter to run "xcatdsklspost 1 -m" for postscripts including efibootloader, update_network, or any customer specified postscripts.
    

**Question**: do we need to run xcatdsklspost by default? or just let user run updatenode after cloning completed? 

    

  * Copy kernel and initrd retrieved from golden client to /tftpboot/xcat/&lt;osver&gt;/&lt;arch&gt;/&lt;profile&gt;/ 

**Question**: will /tftpboot/xcat/&lt;osver&gt;/&lt;arch&gt;/&lt;profile&gt;/ be changed to /tftpboot/xcat/&lt;osimage&gt;? since for sysclone osimage, we have empty osimage.profile. 

    

  * Modify /tftpboot/xcat/xnba/nodes/&lt;node&gt;.elilo 
    
      remove repo=xxx ks=xxx 
      add ramdisk_size=200000
    

## Design Considerations

### xcat-sysclone rpm

This feature brings new otherpkgs.pkglists(so far sysclone.rhels6.x86_64.otherpkgs.pkglist, will add other pkglists for other os and arch) and new postscripts(efibootloader, update_network), so maybe it's ok to build a separate rpm, let's say xcat-sysclone, to ship these new files, we can specify systemimager rpms as xcat-sysclone dependencies in spec file, so when xcat-sysclone installed, the corresponding systemimager rpms can be installed automatically on xcat management node. 

But there are other code changes not included in the new files, such as imgcapture.pm, anaconda.pm(maybe sles.pm, etc..later), so not sure if we really need to build this new rpm or just merge the changes to existing xcat core. 

### updatenode

After the compute node is cloned, we can take it as a common diskful node, so updatenode can be used to perform the following node updates: 

    

  * Distribute and synchronize files. 
  * Install or update software on diskfull nodes. 
  * Run postscripts. 
  * Update the ssh keys and host keys. 

## Other Design Considerations

  * **Required reviewers**: Bruce, Jarrod, Guang Cheng 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: imgcapture 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
