<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Installation Methods](#installation-methods)
- [xCAT Installation Process](#xcat-installation-process)
  - [Network Boot](#network-boot)
    - [PXE](#pxe)
    - [Etherboot/GRUB](#etherbootgrub)
    - [PXE64](#pxe64)
    - [CHRP](#chrp)
    - [User Defined](#user-defined)
  - [Bootloader](#bootloader)
    - [PXE](#pxe-1)
    - [Etherboot/GRUB](#etherbootgrub-1)
    - [PXE64](#pxe64-1)
    - [CHRP](#chrp-1)
    - [User Defined](#user-defined-1)
    - [PXE](#pxe-2)
    - [Etherboot/GRUB](#etherbootgrub-2)
    - [PXE64](#pxe64-2)
    - [CHRP](#chrp-2)
  - [Installer](#installer)
  - [Post Install](#post-install)
  - [Reboot](#reboot)
- [How to Install a Node](#how-to-install-a-node)
  - [Determining what to install on each node](#determining-what-to-install-on-each-node)
  - [Kickstart and Autoyast Templates](#kickstart-and-autoyast-templates)
  - [Variable Substitution](#variable-substitution)
    - [XCATVAR](#xcatvar)
    - [ENV](#env)
    - [Table defined variable](#table-defined-variable)
    - [COMMAND](#command)
- [Support](#support)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


 **Please note that this document was valid for xCAT 1 and is not completely correct for xCAT 2. It is posted here so that it can be updated and corrected, since this information is not otherwise available on the Wiki.**

The purpose of this document is to describe the various methods to remotely install an OS with xCAT. This document assumes that xCAT 1.2.0 or later is installed and that your management server is configured. As noted above, many details may be incorrect for xCAT 2. 

The term noderange refers to xCAT's internal facility to perform an operation on a range of nodes, please read the noderange.5 man page for details. 

Look to the $XCATROOT/sameples/etc files for a place to start. 


## Installation Methods

xCAT supports the following automated unattended network installation methods: 

  * Red Hat Kickstart (x86, x86_64, ia64, and ppc64) 
  * SuSE Autoyast (x86, x86_64, ia64, and ppc64) 
  * Imaging (PartImage) (x86, x86_64) 
  * SystemImager 
  * User defined TFTP boot file 

## xCAT Installation Process

The xCAT node installation process is best illustrated by the diagram in Figure 1.

[[img src=xCAT_install_process.gif]] 

### Network Boot

All nodes DHCP/BOOTP from the network. The xCAT DHCP server will provide the necessary TFTP information for the node to TFTP download a bootloader and execute it. xCAT supports the following net boot methods: 

#### PXE

The x86 and x86_64 industry standard for network booting. Most network adapters and on-board NICs support PXE. It is necessary that all nodes supporting PXE boot the network before local hard drive or xCAT will fail to force the node to install. Please read the xCAT Stage1 HOWTO for more details. 

#### Etherboot/GRUB

Etherboot provides a method for non-PXE enabled machines to net boot. xCAT Etherboot support uses standard Etherboot floppies or CDs but chains to nbgrub as the bootloader. It is necessary that all nodes using Etherboot boot the floppy/CD-ROM before local hard drive or xCAT will fail to force the node to install. Use the xCAT command makebootdisk to create boot floppies and CDs. 

#### PXE64

The ia64 Intel standard for network booting. All EFI-based ia64 machines support PXE64 on the on-board NIC. It is necessary that all nodes using EFI/PXE64 have an EFI entry "Ethernet" as the first entry. Please read the xCAT Stage1 HOWTO for more details. 

#### CHRP

The ppc64 standard for booting. PPC64-based machines boot OpenFirmware and require a serial console monitor to switch from network to HD boot. For each node/blade sol.bc must be setup in $XCATROOT/etc/conserver.cf and rbootseq run to boot HD before Network. Currently only Bladecenter JS20 is supported. 

#### User Defined

If you have a boot loader for terminal servers, switches, or nodes that is not included with xCAT simply place in /tftpboot (or whatever you defined in $XCATROOT/etc/site.tab as tftpdir). 

The network bootloader is defined for each node in $XCATROOT/etc/nodehm.tab. Valid values are: 

  * pxe

For PXE enabled nodes. 
  * nbgrub

For Etherboot/GRUB enabled nodes. 
  * elilo

For PXE64 enabled nodes. 
  * chrp

For ppc64 nodes (JS20). 
  * file:filename

For user defined where filename is the file to be TFTP downloaded and executed from /tftpboot (or whatever you defined in $XCATROOT/etc/site.tab as tftpdir). 

Any updates to $XCATROOT/etc/nodehm.tab will require that makedhcp be run for nodes changed. 

### Bootloader

After the correct bootloader has been downloaded via TFTP and executed, the bootloader requests a node-specific configuration file to tell it what to do. Usually, the file tells the bootloader to request a kernel and initrd image and boot, or to exit the bootloader and boot from the HD. 

The following are the bootloader files assuming the **tftpdir** field in the **site** table is 
    
    /tftpboot

: 

#### PXE
    
    /tftpboot/pxelinux.0

#### Etherboot/GRUB
    
    /tftpboot/grub/nbgrub.nic

where nic is defined in the **nodehm** table as **eth0**

#### PXE64
    
    /tftpboot/elilo.efi

#### CHRP
    
    /tftpboot/chrp/nodename.img

(A symlink set to point to the correct combined compressed kernel/initrd image in /tftpboot/xcat/OSVER/ARCH) 

#### User Defined
    
    /tftpboot/filename

(as defined in the **nodehm** table as **file:filename**) 

**Bootloader configuration file locations:**

#### PXE
    
    /tftpboot/pxelinux.cfg/FILENAME

where FILENAME is the node name. A symbolic link is also created, the name of which is the hex equivalent of the IP address of the node (e.g. 199.88.179.201 would be C758B3C9). If the node specific configuration file is missing then the file default is used to boot the local HD. 

#### Etherboot/GRUB

/tftpboot/grub/filename. Where filename is nodename.grub. 

#### PXE64

/tftpboot/elilo/filename. Where filename is the hex equivalent of the IP address of the node with a .conf extension (e.g. 199.88.179.201 would be C758B3C9.conf). A link IP address .conf file is also created for backwards compatibility with older xCAT elilo.efi bootloaders. 

#### CHRP

/tftpboot/chrp/filename. Where filename is nodename. 

Bootloader configuration files are created by the nodeset command. 

### Installer

The bootloader configuration file for all installation methods defines the necessary kernel, kernel options, and initrd image for installation. After the kernel and initrd images are downloaded via TFTP, the bootloader then boots Linux and installation starts. 

Kernel, initrd images, and uncooked bootloader configurations files (kernel options) are located in the **site** table. The default value of **tftpdir** is 
    
    /tftpboot

: 
    
    /tftpboot/xcat/OSVER/ARCH

where OSVER is the xCAT short OS version name (e.g. rh72) and ARCH is the hardware architecture type (x86, x86_64, or ia64). The bootloader configuration files, kernels, and initrd images are placed in the appropriate TFTP directory automatically when rinstall, winstall, or nodeset is run. 

NOTE: Previous versions of xCAT required that a script (mkks, mkimage, mk*, etc...) was run to create the files. This version of xCAT detects changes in template files and xCAT .tab files and creates the necessary files on demand. 

After the installer starts it gets the installation configuration file via NFS. Installation configuration files (such as Kickstart scripts) are located in 
    
    INSTALLDIR/autoinst

where INSTALLDIR is the **installdir** field in the **site** table, OSVER is the OS to be installed, and ARCH is the hardware architecture type. The name of the installation configuration is based on the resource group and node type defined in the **noderes** and **nodetype** tables. These files are auto-generated from template files [ (described below)](#Kickstart_and_Autoyast_Templates_) when the **nodeset** command is run. 

After the installation configuration file is parsed, installation begins installing from the installation sources: 
    
    INSTALLDIR/OSVER/ARCH

The copycds command will setup the above directory correctly for automated installs. 

### Post Install

At the end of each installation method, post installation scripts are run to customize the installation. Then the node contacts the management node to change the bootloader configuration file to boot the local HD (nodeset noderange boot). 

The post-install script simply mounts xCAT from the management server and runs a single master script (postage) that uses a rules-based system to determine what collection of smaller manageable reusable scripts to run to customize the installation. 

All of the post scripts are located in 
    
    INSTALLDIR/postscripts

. Modifications to the core scripts or custom scripts should be placed in 
    
    INSTALLDIR/postscripts/custom

. The table **postsripts** determines what scripts are run and in what order they get run. Postscript rules and actions are defined in the file 
    
    /etc/xcat/postscripts.rules

and are formatted: 
    
       RULE {
           script [args]
           script [args]
           script [args]
           ...
       }
    

Rules are defined as VAR=REGEX where VAR may be any exported environmental variable, ALL, or NODERANGE (special, see below). 

Regular expressions (REGEX or regex) are a powerful way to define a match. The Perl regex engine is used to parse the rules. Please do not confuse regex with shell expansion characters. E.g. compute* does NOT match anything starting with 'compute' as bash would. compute.* is the correct regex for a that match. man perlre for regex docs. (BTW, regex compute* matches 'comput' with 0 or more 'e's at the end.) 

There is no need to place beginning and end markers (^$) in your regex. They are added automatically. 

Actions are defined as: script [optional args] 

A special action/script "STOP" will stop processing all rules and exit. 

Scripts are run top-down multiples rules can match. 

Nesting with () and operators _and_, _or_, and _not_ are supported. 

The following VARs are exported by xCAT: 
    
    OSVER=(rh62|rh70|rh71|rh72|rh73|rh80|rh9|rhas21|rhes21|rhws21|suse81|sles8)
    OSVER is the OS that has just been installed.  OSVER may be defined by regex. (e.g. rh.* is "anything starting with rh")
       
    ARCH=(x86|x86_64|ia64)
    ARCH is the hardware architecture (uname -m). ARCH may be defined by regex.
     
    NODERANGE=(e.g. node1-node10)
    NODERANGE follows the xCAT noderange format as defined by noderange.5 (man noderange). Regex is supported as part of noderange, however it must be prefixed with a '@', e.g. (@node.* is "anything starting with node").
    
    NODETYPE=(e.g. compute)
    NODETYPE is the node type image defined in the etc/nodetype.tab 3rd field. NODETYPE may be defined by regex.
    
    NODERES=(e.g. compute)
    NODERES is the node resource group defined in etc/noderes.tab. Regex is supported.
    
    ALL (Apply to all)
    TABLE:TABLENAME:KEY:FIELD=
    

The last rule is special and is determined at runtime. 

TABLENAME is the name of an xCAT table located in $XCATROOT/etc. You may create your own tables. 

KEY is the first field of any xCAT table. $NODENAME and $NODERES are special values for key, usually the key is a fixed name, however many xCAT tables start with a node or resource group name. 

FIELD is a numeric value for fields associated with KEY. The first field is 1. Special names are available (e.g. $nodehm_eth0) and are defined in $XCATROOT/lib/functions. Any environmental variable can be used. 

E.g.: 
    
    TABLE:nodehm.tab:$NODENAME:$nodehm_eth0=e1000

Would only execute scripts where eth0 was defined as e1000 in nodehm.tab for any node. 

You can use the script $XCATROOT/bin/postrules NODENAME to parse this table to test your rules. 

E.g.: 
    
    postrules node1
    

Example rules with comments: 
    
    # Setup syslog for any RH or SuSE8.x or SuSE SLES8 OS
    OSVER=rh.* or OSVER=sles8 or OSVER=suse8.* {
        syslog
    }
       
    # update/add packages for any RH or SuSE8.x or SuSE SLES8 OS
    (OSVER=rh.* or OSVER=sles8 or OSVER=suse8.*) {
        updaterpms nodeps
        otherrpms
        forcerpms
    }
    
    # update kernel for any SuSE8.x or SuSE SLES8 OS with
    # a hardware architecture of x86 or ia64 with the latest
    # kernel
    (OSVER=sles8 or OSVER=suse8.*) and (ARCH=x86 or ARCH=ia64) {
         updatekernel latest
    }
    
    # update the kernel for SLES8/x86_64 with the latest
    # numa kernel
    OSVER=sles8 and ARCH=x86_64 {
        updatekernel latest numa
    }
    
    # update any RH OS but RH72 with the latest kernel
    OSVER=rh.* and not OSVER=rh72 {
        updatekernel latest
    }
       
    # update RH72/ia64 with the 2.4.9-32 uni kernel
    OSVER=rh72 and ARCH=ia64 {
        updatekernel 2.4.9-34 uni
    }
       
    # Setup PBS only if this node's resource group
    # has a 'Y' in the PBS column for any RH or
    # SuSE SLES8 or SuSE 8.x OS
    TABLE:noderes.tab:$NODERES:$noderes_pbs=Y and
    (OSVER=rh.* or OSVER=sles8 or OSVER=suse8.*) {
        openpbs
    }
       
    # Setup Myrinet for SLES8/ia64 is this node's
    # resource group has a 'Y' in the GM column and
    # if this node is in the noderange of myrid
    TABLE:noderes.tab:$NODERES:$noderes_gm=Y and OSVER=sles8 and ARCH=ia64 and NODERANGE=myrid {
        myrinet 2.0.3_Linux 2.4.19-SMP
    }
    

Most place postscripts in the correct order in postscripts.tab for readability. 

### Reboot

At the end of the install the node reboots. 

## How to Install a Node

The command rinstall calls nodeset to setup the bootloader configuration file and the node installation configuration file then forces the node to boot (rpower noderange boot) and initiates the installation. 

### Determining what to install on each node

How does xCAT know what to put on each node? That is entirely up to you. All the xCAT tables play a part in the characteristics of the node, namely **noderes**, **nodehm**, **nodetype**. **noderes** contains most of the information on where to install from and other common characteristics of each node. **nodehm** also plays a role in how to install and other hardware related setup. **nodetype** directly relates to the installation type and template that will be used for each node. 

Use the command **lsdef** to display what will be installed on each node. 

E.g. 
    
    lsdef node1
    

Output: 
    
    arch=x86_64
    currchain=boot
    currstate=install centos54-x86_64-compute
    groups=compute,all
    ...
    

**currstate** shows that CentoOS 5.4 will be installed on an x86_64 architecture with profile _compute_. 

### Kickstart and Autoyast Templates

Define a custom template (.tmpl file) in INSTALLDIR/custom/install/OSVER. The name of the template file should be the same as the node profile in the **nodetype** table. Sample files are located in $XCATROOT/share/xcat/install. 

Template files are standard [Kickstart](https://access.redhat.com/knowledge/docs/en-US/Red_Hat_Enterprise_Linux/5/html/Installation_Guide/ch-kickstart2.html) and [Autoyast](http://doc.opensuse.org/projects/autoyast/) files. Please read [Kickstart](https://access.redhat.com/knowledge/docs/en-US/Red_Hat_Enterprise_Linux/5/html/Installation_Guide/ch-kickstart2.html) and [Autoyast](http://doc.opensuse.org/projects/autoyast/) documentation for details. There are a few exceptions: 

  1. xCAT installation processing scripts can perform variable substitution replacing #VAR# tags in your .tmpl files with xCAT variables in $XCATROOT/etc/*.tab files. 
  2. xCAT post installation support is a very flexible unified system for node customization. The most important post installation script is updating the management servers boot flag for that node to prevent the node from installing over and over again. Use the post installation code included in the base templates. 

### Variable Substitution

Variables are defined as #VAR# where VAR may be (listed by precedence): 

#### XCATVAR

An xCAT internally defined variable. This type of variable is proprietary to xCAT and is required for xCAT node installation support. Current xCAT variables that are not stored but calculated: 
    
    MASTER 	Management Server Hostname
    MASTER_IP 	Management Server IP
    MASTER_IPS 	All Mangement Server IPs (for multi homed, routed clusters)
    RSH 	Using RSH Y or N
    OSVER 	OS Version as defined in $XCATROOT/etc/nodetype.tab
    ARCH 	Architecture as defined in $XCATROOT/etc/nodetype.tab
    NODERES 	Node resource group
    NODETYPE 	Node image/template type as defined in $XCATROOT/etc/nodetype.tab
    INSTALL_NFS 	NFS installation server as defined in $XCATROOT/etc/noderes.tab
    INSTALL_NFS_IP 	NFS installation server IP as defined in DNS
    INSTALL_SRC_DIR 	Installation source directory.  installdir as defined in $XCATROOT/etc/site.tab/OSVER/ARCH, e.g. /install/rh73/x86
    INSTALL_CF_DIR 	Installation configuration directory.  installdir as defined in $XCATROOT/etc/site.tab/scripts/OSVER/ARCH, e.g. /install/scripts/rh73/x86
    INSTALL_CF_FILE 	Installation configuration file name in INSTALL_CF_DIR
    KERNEL 	Kernel name
    INITRD 	Initrd name
    

#### ENV

Any exported environmental variable can be substituted. E.g.: 
    
    #ENV:PATH#
    

#### Table defined variable

This type of variable is pulled directly from $XCATROOT/etc/*.tab files and must be in the format: 
    
    #TABLE:tablename.tab:key:(field|*)#
    

E.g. 
    
    #TABLE:noderes.tab:$NODERES:$noderes_serial#
    

The key and field may be fixed or existing exported environmental variables. You may create your own tables with any content you like. $XCATROOT/lib/functions variables for field numbers for TABLE lookups: 
    
    nodehm_power 	 
    nodehm_reset 	 
    nodehm_cad 	 
    nodehm_vitals 	 
    nodehm_inv 	 
    nodehm_cons 	 
    nodehm_bioscons 	 
    nodehm_eventlogs 	 
    nodehm_getmacs 	 
    nodehm_netboot 	 
    nodehm_eth0 	 
    nodehm_gcons 	 
    nodehm_serialbios 	 
    nodehm_beacon 	 
    nodehm_bootseq 	 
    nodehm_serialbps 	 
    noderes_tftp 	 
    noderes_nfs_install 	 
    noderes_install_dir 	 
    noderes_serial 	 
    noderes_usenis 	 
    noderes_install_roll 	 
    noderes_acct 	 
    noderes_gm 	 
    noderes_pbs 	 
    noderes_access 	 
    noderes_gpfs 	 
    noderes_netdevice 	 
    noderes_prinic 	 
    nodetype_osver 	 
    nodetype_arch 	 
    nodetype_image 	 
    

#### COMMAND

Any command can be run have its output substituted. E.g.: 
    
    #COMMAND:cat #ENV:XCATROOT#/etc/raidconfig.ks#
    

## Support

&lt;http://xcat.org&gt;

Egan Ford August 2004 
