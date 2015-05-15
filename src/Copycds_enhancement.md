<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [OPTIONS](#options)
- [RETURN VALUE](#return-value)
- [EXAMPLES](#examples)
- [NOTES](#notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

  
{{:Design Warning}} 


## NAME

copycds - Copies Linux distributions and service levels from CDs/DVDs to install directory. 

## SYNOPSIS

copycds [{-n|--name|--osver}=distroname] [{-a|--arch}=architecture] [{-p|--path}=ospkgpath] {iso|device-path} ... 

copycds [-i|--inspection] {iso|device-path} 

copycds [-h|--help] 

  


## DESCRIPTION

The copycds command copies all contents of Distribution CDs/DVDs or Service Pack CDs/DVDs to a destination directory. The destination directory is specified by -p option. The destination directory should only be a path under /install directory. If no path is specified, the default destination directory will be formed from the installdir site attribute and the distro name and architecture, for example: /install/sles11.2/ppc64. The copycds command can copy from one or more ISO files, or CD/DVD device path. You can specify -i or --inspection option to check whether the CDs/DVDs can be recognized by xCAT. If recognized, the distribution name, architecture and the disc no (the disc sequence number of CDs/DVDs in multi-disk distribution) of the CD/DVD is displayed. If xCAT doesn't recognize the CD/DVD, you must specify the -n and -a options. This is sometimes the case for distros that have very recently been released, and the xCAT code hasn't been updated for it yet. 

  


## OPTIONS

{-n|--name|--osver}=distroname 

The linux distro name and version that the ISO/DVD contains. Examples: rhels5.3, centos5.1, fedora9. 

{-a|--arch}=architecture 

The architecture of the linux distro on the ISO/DVD. Examples: x86, x86_64, ppc64. 

{-p|--path}=ospkgpath 

The destination directory to which the contents of ISO/DVD will be copied. The destination directory should be a path under /install directory. When this option is not specified, the default destination directory will be formed from the installdir site attribute and the distro name and architecture, for example: /install/sles11.2/ppc64. This option only supports distributions of sles and redhat. 

{-i|--inspection} 

Check whether xCAT can recognize the CD/DVDs in the argument list without any disc copy, display the os distribution name, architecture and disc no of each recognized CD/DVD. This option only supports distributions of sles and redhat. 

## RETURN VALUE

Zero: The command completed successfully. For the --inspection option, the ISO/DVD have been recognized successfully 

Nonzero: An Error has occurred. For the --inspection option, the ISO/DVD cannot be recognized 

  


## EXAMPLES
    
       To copy the RPMs from a set of ISOs that represent the CDs of a distro:
       copycds cd1.iso cd2.iso cd3.iso
    
    
       To copy the RPMs from a physical DVD to /depot/kits/3 directory:
       copycds -p /depot/kits/3 /dev/dvd
    
    
       To copy the RPMs from a DVD ISO of a very recently released distro:
       copycds -n rhels5.3 -a x86_64 dvd.iso
    
    
       To check whether a DVD ISO can be recognized by xCAT and display the recognized disc info:
       copycds -i /media/RHEL/6.0/RHEL6.0-20100922.1-Server-ppc64-DVD1.iso
    

  


## NOTES

1\. The -p and -i options currently only support distributions of sles and redhat. 

2\. The output format of copycds --inspection is: 
    
     OS Image:&lt;value&gt;
     DISTNAME:&lt;value&gt;
     ARCH:&lt;value&gt;
     DISCNO:&lt;value&gt;
    

As a example: 
    
     OS Image:/media/RHEL/6.2/RHEL6.2-20111117.0-Server-ppc64-DVD1.iso
     DISTNAME:rhels6.2
     ARCH:ppc64
     DISCNO:1
    

For the attributes failed to be recognized, the value will be blank. 

3\. For {-p|--path}=ospkgpath option,the destination directory should only be a path under /install directory. 
