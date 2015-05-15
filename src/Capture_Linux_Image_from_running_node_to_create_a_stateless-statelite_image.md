<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Basic Idea](#basic-idea)
- [xCAT Interface](#xcat-interface)
  - [New xCAT command: **capimage**](#new-xcat-command-capimage)
  - [The files/direcotries to be excluded](#the-filesdirecotries-to-be-excluded)
- [The implementation](#the-implementation)
- [Notes](#notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

This feature aims to capture the image from running node to create a stateless/statelite image. Currently it support Linux only. 


## Basic Idea

There're many available capture utility candidates, including **cpio**, **tar**, **pax** and **afio**. These utilites handle the files as the targets to be archieved and they are capable of _excluding specific files and/or directories from the targets_. They are even create a single archive which contains files from multiple file systems. 

**Note**: the _cpio_ utility was standardized in POSIX. 1-1988, and was dropped from the later version, starting with POSIX. 1-2001 due to its 8 GB filesize limit. The POSIX standardized _pax_ utility can be used to read and write cpio archives instead. 

  * In order to capture the Linux image, we need to specify one diskful Linux node. 
  * We also need one file to contain the files excluded from the image, the files and directories in this file will be excluded. 
  * The diskful Linux node should be managed by xCAT, because _xdsh_ and _xdcp_ are necessary. 
  * Following the existing _genimage_ code to generate stateless image: 
    
     /bin/find . ! -path './xxxx*' |cpio -H newc -o |gzip -c - &gt; /tmp/rootimg.gz 
    

  * Use the _xdcp_ command to copy the _rootimg.gz_ file from the specified diskful node to the MN. 
  * Extract the contents of _rootimg.gz_ to _/install/netboot/&lt;osver&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg_
  * Perform the _genimage_ command on the _/install/netbot/&lt;osver&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg_ directory 
  * Run the _packimage_ or _liteimg_ command 
  * Run the _nodeset &lt;nr&gt; statelite/netboot_ command 

## xCAT Interface

### New xCAT command: **capimage**
    
     capimage node [ -p|--profile &lt;profile&gt; ] 
    

Requirements: 

  * The _node_ here should be one **diskful** Linux node; 
  * _-p_ is optional, the user can specify the profile name for the statelite/stateless image to be created; if not specified, the current _profile_ attribute of the _node_ will be used for the image to be created. 

### The files/direcotries to be excluded

Some files/directories should be excluded when capturing the diskful Linux image from the running node, or else capturing will be failed. In my investagation, the following directories should be excluded: 
    
     /tmp/
     /proc/
     /sys/
     /dev/
     /xcatpost/
     /install/
    

## The implementation

  * Parse the paramaters of the _capimage_ command, get the _node_ name and the _profile_ name; 
  * Build the command 
    
     /bin/find / ! -path './tmp*' ! -path './proc*' ! -path './sys*' ! -path './dev*' ! -path './xcatpost*' ! -path './install*' |cpio -H newc -o |gzip -c - &gt; /tmp/rootimg.gz
    

  * Use _xdsh_ and the command above to capture and generate the image on the specified diskful node. 
  * Use _xdcp_ to copy the _/tmp/rootimg.gz_ file from the specified diskful node 
  * Extract the contents of _rootimg.gz_ to the _/install/netboot/&lt;osver&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg_ directory on MN. 
  * Create the directories excluded when capturing the image 
    
     /tmp/
     /proc/
     /sys/
     /dev/
    

The next steps will be documented. 

  * Run the _genimage_ command with the_&lt;osver&gt;_, _&lt;arch&gt;_, _&lt;profile&gt;_ option. 
  * Run the _liteimg_/_packimage_ command 
  * Run the _nodeset &lt;nr&gt; statelite/netboot_ command 

## Notes

It seems the root image captured from the diskful node requires many memory capabilities. For example, I captured the image from the diskful Linux node, which is installed by xCAT; then I tried to boot one LPAR with this image, but it always failed until I updated the memory capability to 5120MB. Here is output of the _df -h_ command, you can see the usage of the memory in the stateless mode: 
    
    [root@945n02 ~]# df -h
    Filesystem            Size  Used Avail Use% Mounted on
    test_ppc64            2.5G  2.3G  190M  93% /
    tmpfs                 2.5G     0  2.5G   0% /dev/shm
    tmpfs                  10M  192K  9.9M   2% /tmp
    tmpfs                  10M     0   10M   0% /var/tmp
    
