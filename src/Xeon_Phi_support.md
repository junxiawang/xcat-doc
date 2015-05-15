<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Configure Host Node](#configure-host-node)
  - [Install Software for MIC Support](#install-software-for-mic-support)
  - [Configure Network Bridge](#configure-network-bridge)
- [MIC System Management](#mic-system-management)
  - [Discover the 'mic nodes' from the 'host node'](#discover-the-mic-nodes-from-the-host-node)
  - [How to Store the MIC Node in the xCAT DB](#how-to-store-the-mic-node-in-the-xcat-db)
  - [Get the Inventory Information for MIC](#get-the-inventory-information-for-mic)
  - [Get the Vitals Information](#get-the-vitals-information)
  - [Flash the Firmware](#flash-the-firmware)
  - [Network Configuration for MIC](#network-configuration-for-mic)
  - [Do the Remote Hardware Control](#do-the-remote-hardware-control)
  - [Check the Health for MIC](#check-the-health-for-mic)
  - [Remote Console for MIC](#remote-console-for-mic)
  - [Enable the Log for MIC](#enable-the-log-for-mic)
  - [Enable the Kernel Dump for MIC](#enable-the-kernel-dump-for-mic)
- [Boot the MIC with a Linux OS](#boot-the-mic-with-a-linux-os)
  - [The steps to manage the osimage](#the-steps-to-manage-the-osimage)
- [Install HPC Software for MIC node](#install-hpc-software-for-mic-node)
  - [Use PE Software as an Example:](#use-pe-software-as-an-example)
  - [The Rules for Packaging HPC Software as an RPM for Xeon Phi](#the-rules-for-packaging-hpc-software-as-an-rpm-for-xeon-phi)
  - [Internal Consideration of How to Install HPC Software in an xCAT Diskless Image](#internal-consideration-of-how-to-install-hpc-software-in-an-xcat-diskless-image)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


## Overview

Xeon Phi is an intel new released coprocessor which based on Intel Many Integrated Core (MIC) Architecture. It has many cores (more than 60) and packaged with PCIe card. Each Xeon server could install one or more (8 or more) Xeon Phi PCIe cards, we call the Xeon server 'host node' and call the Xeon Phi 'mic node' in this design. 'mic node' has firmware and can boot with a Linux Operating System. 

This design will cover the installation of software stack for Xeon Phi running and management on the 'host node', and cover the system management for 'mic node' (Xeon Phi card) like power on/off, rinv, rvitals, rflash, OS booting ... 

Since the management of Xeon Phi coprocessor with xCAT will follow a procedure, I organized this design follows the management flow like 'configure host node', 'scan mic nodes', 'configure mic nodes', 'boot os to mic nodes' ... 

Since the 'mic node' is attached to the 'host node', the similar relationship between 'hypervisor' and 'virtual machine guest' is used to design the relationship of 'host node' and 'mic node'. 'host node' is similar as 'hypervisor' that all the operation against the 'mic node' must be done through it. 'mic node' is similar as 'vm' that 'mic node' only can be existed with the 'host node'. 

## Configure Host Node

The first step to support the 'mic node' is to set up the 'host node'. This section will cover how to configure the 'host node' automatically. 

### Install Software for MIC Support

The Many Integrated Core (MIC) Platform Software Stack (MPSS) is a collection of software that used to support the mic. OFED package is used to support the communication between host and mic. These two software need to be installed on the host node before using the mic. 

The xCAT kit will be used to manage the software install/update of MPSS (http://software.intel.com/en-us/articles/intel-manycore-platform-software-stack-mpss). Since there are binaries and drivers in the mpss, that means the package is different for each OS like rh6.0, rh6.1..., sles11.1, sles11.2 ..., then the partial kit is a good choice for mpss. 

Except the installation of mpss rpm packages, there are pre and post scripts need to be run to set up the mpss env. 

  * Pre Script 

Since the MPSS has to be removed first before the new version update, the following commands need to be run to clean the env 
    
    yum remove --noplugins --disablerepo=* intel-mic\*
    zypper remove intel-mic\*
    

  * Post Script 

The MPSS need to be configured after the installation. The following commands need to be run to enable the basic configuration for mpss and start the service of mpss. 
    
    run 'micctrl --initdefaults'    # initialize the mpss environment
    run 'service mpss start'   # start the mpss service
    run 'chkconfig mpss on'    # set 'mpss' service to be boot automatically when boot the host node.
    check the status of the mpss: the mpss service has been started; the corresponding kernel modules have been loaded.
    

Todo: I'll add more description of how to create partial kit for mpss 

Todo: how to install OFED? with kit too? 

### Configure Network Bridge

The virtual bridge needs to be created on the 'host node' to enable the communicate between 'host', 'mic' and even beyond the 'host'. xCAT has a postscript 'xHRM' which can be used to create bridge. So if a bridge is needed, we can require customer to add an entry like 'xHRM bridgeprereq br0' in the postscripts attribute for host node to create bridge 'br0' automatically during install or update of 'host node'. 

Todo: configure vlan. 

Todo: Guang Cheng mentioned that we could add this part in the post script of mpss kit. But I think it's better to be separated. 

## MIC System Management

Since every mic node could be operated individually like 'power on/off', 'rinv, rvitals, rflash', 'os booting', every mic will be defined as an xCAT node. The default name of mic will be &lt;host name&gt;-micx, 'x' is the device number of the mic which started from 0 to n. 

### Discover the 'mic nodes' from the 'host node'

The rscan command can be used to scan the 'mic nodes' from the 'host node'. The rscan command will be implemented in the ipmi.pm that it will be called for the node that 'mgt=ipmi'. 
    
    # rscan ipmi
    type    name         id      host
    mic     n31-mic0     0       n31
    mic     n31-mic1     1       n31
    mic     n29-mic0     0       n29
    mic     n29-mic1     1       n29
    

Interface: rscan noderange [-u] [-w] [-z] 
    
    -u/-w add the scanned mics to the database
    -z display the scanned mics with stanza format
    

Implementation: The command 'micinfo -listDevices' will be run on the 'host node' to list all the mic devices. 

### How to Store the MIC Node in the xCAT DB

A new table named 'mic' will be added, and following attributes will be added to store the attributes for mic node. 
    
    node =&gt; 'The node name or group name.',
    host =&gt; 'The host node which the mic card installed on.',
    id =&gt; 'The device id of the mic node.',
    nodetype =&gt; 'The hardware type of the mic node. Generally, it is mic.',
    bridge =&gt; 'The virtual bridge on the host node which the mic connected to.',
    
    

The corresponding attribute names for *def command will be created as 'michost', 'micid', 'micbridge' ... 
    
    # lsdef m31-mic1
    Object name: n31-mic1
       groups=all,mic
       hwtype=mic
       mgt=mic
       michost=n31
       micid=1
    

### Get the Inventory Information for MIC

Note: the 'NotAvailable' output comes from my env, it should have a meaningful value. 
    
    rinv:  rinv &lt;mic node&gt; all
     Flash Version            : NotAvailable
     SMC Boot Loader Version  : NotAvailable
     uOS Version              : NotAvailable
     Device Serial Number     : NotAvailable  
     (#System information:)                    
     Vendor ID                : 8086           
     Device ID                : 2250           
     Subsystem ID             : 2500           
     Coprocessor Stepping ID  : 3              
     PCIe Width               : x16            
     PCIe Speed               : 5 GT/s         
     PCIe Max payload size    : 256 bytes      
     PCIe Max read req size   : 4096 bytes     
     Coprocessor Model        : 0x01           
     Coprocessor Model Ext    : 0x00           
     Coprocessor Type         : 0x00           
     Coprocessor Family       : 0x0b           
     Coprocessor Family Ext   : 0x00           
     Coprocessor Stepping     : B1             
     Board SKU                : NotAvailable   
     ECC Mode                 : NotAvailable   
     SMC HW Revision          : NotAvailable   
                                           
     (Cores information: )                     
     Total No of Active Cores : NotAvailable   
     Voltage                  : NotAvailable   
     Frequency                : NotAvailable   
    

Implementation: The command [micinfo -deviceinfo &lt;num&gt; \- group version/Board/Cores] will be run on host to get the information. 

### Get the Vitals Information
    
    rvitals &lt;mic&gt; all  
     Fan Speed Control        : NotAvailable
     SMC Firmware Version     : NotAvailable
     FSC Strap                : NotAvailable
     Fan RPM                  : NotAvailable
     Fan PWM                  : NotAvailable
     Die Temp                 : NotAvailable  
    

### Flash the Firmware

The 'mic card' has a 'bootloader' (it used to load uOS.) and an uOS (it used to boot mic to standby stat, then host communicates with uOS to boot real Linux OS on the mic. ) on the flash. rflash command can be used to update the 'bootloader' and 'uOS' in the flash for the 'mic node'. 
    
    rflash &lt;mic&gt; [-b] [-c] 
    -b update bootloader first
    -c To check whether the firmware file which will be flashed to mic is compatible with physical mic device.
    

Implementation: To make the firmware to be common, the firmware will be mounted from the MN/SN. Command [micflash -update -device -noreboot] will be run to flash. 

Todo: It's good to support that flash all mics for a host, the host node must be the target node, so the syntax will be 'rflash &lt;host node&gt; \--mic all'. Maybe someday, the 'all' could be replaced to '1,2...' (the device id). 

### Network Configuration for MIC

There are three methods to configure the network between mic and host. 

  1. Only enable communication channel between one mic and host. multiple mic on same host cannot communicate. 
  2. Enable communication between all mics inside one host. 
  3. Enable communication between all nics on all hosts in the same network. 

Only the scenario 3 will be supported. That means the 'mic node' can be seen in the whole cluster (include host and mic) 

A new command 'rmiccfg' will be added to configure the mic. 'rmiccfg network' is used to add the mic to bridge and configure an IP for mic. 
    
    rmiccfg &lt;mic node&gt; network=* #means get the bridge and ip parameters from tables. (hosts.ip and mic.bridge)
    rmiccfg &lt;mic node&gt; network={1.1.1.1,br0} # means the ip will be set to 1.1.1.1 and bridge will be set to br0
    

Note: the ip for the mic will be set to be static. 

### Do the Remote Hardware Control
    
    rpower &lt;mic&gt; [state] [on|off|reset|reboot -w -t timeout]
      state - will get the status of mic, output: resetting|ready|booting|online
      on - boot the mic to OS
      off - shutdown the OS
      boot - reboot the OS
      reset - reset the mic device
      -w -t can be used with 'on|off|reset|reboot' to wait the finish of the operation.
    

### Check the Health for MIC
    
    rmiccfg &lt;mic&gt; check
     The output looks like following:  
     Test 1 Ensure installation matches manifest : OK
     Test 2 Ensure host driver is loaded         : OK
     Test 3 Ensure driver matches manifest       : OK
     Test 4 Detect all listed devices            : OK
     MIC 0 Test 1 Find the device                       : OK
     MIC 0 Test 2 Check the POST code via PCI           : FAILED
     MIC 0 Test 2&gt; Current POST code is 12 (not FF) for MIC 0
     MIC 0 Test 3 Connect to the device                 : SKIPPED
     MIC 0 Test 3&gt; Prerequisite 'Ensure the device is online' failed:
     MIC 0 Test 3&gt;  The device is not online
     MIC 0 Test 4 Check for normal mode                 : SKIPPED
     MIC 0 Test 4&gt; Prerequisite 'Ensure the device is online' failed:
     MIC 0 Test 4&gt;  The device is not online
     MIC 0 Test 5 Check the POST code via SCIF          : SKIPPED
     MIC 0 Test 5&gt; Prerequisite 'Ensure the device is online' failed:
     MIC 0 Test 5&gt;  The device is not online
     MIC 0 Test 6 Send data to the device               : SKIPPED
     MIC 0 Test 6&gt; Prerequisite 'Check for normal mode' failed:
     MIC 0 Test 6&gt;  The device is not in normal mode
     MIC 0 Test 7 Compare the PCI configuration         : OK
     MIC 0 Test 8 Ensure Flash version matches manifest : SKIPPED
     MIC 0 Test 8&gt; Prerequisite 'Check for normal mode' failed:
     MIC 0 Test 8&gt;  The device is not in normal mode 
    

Implementation: call the 'miccheck &lt;device num&gt;' on the host node. 

### Remote Console for MIC
    
    rcons &lt;mic&gt;
    

Todo: will add more information. 

### Enable the Log for MIC

log messages to syslog on the host. 
    
    rmicfg &lt;mic node&gt; syslog={enable|disable} 
    

### Enable the Kernel Dump for MIC
    
    rmiccfg &lt;mic node&gt; kdump={enable|disable}
    

## Boot the MIC with a Linux OS

The file system of Linux for mic is organized with base dir, common dir, mic dir and overlay dir. The files in base dir is installed by MPSS and should not be changed. The files in the other dirs can be customized. 

The os image for the 'mic node' is created from the 'file system' which layout as 'base dir, common dir, mic dir and overlay dir'. The os image can be ramdisk or nfs-based format. In ramdisk format, the ramdisk file will be download to the ram of mic , then extracted and mounted in the ram. In nfs-based format, an individual osimage directory will be created on the host for each mic and will be mounted from mic when booting a mic. 

The advantage of 'ramdisk' format is that the access of system files will be fast since the files existed in the memory. The advantage of 'nfs-based' format is that it saves memory of mic (only mic only have 8G memory for all the cores). xCAT need support both. 

To make root file system to be common among the whole cluster, the root file system can be located on the management node/service node and is mounted to the hosts. 

### The steps to manage the osimage

  * Copy root file system to /install of MN 

The root file system is included in the mpss_gold_update_3-2.1.6720-13-rhel-6.2.tar (it includes all the mpss rpm packages). This step copies root file system from the mpss tar file (it can be downloaded from intel web site directly) to /install on the xCAT MN. After the running of copycds, the directory /install/mpss3-2.1 will be created and root file systems and Linux kernel for mic will be copied to the /install/mpss3-2.1. An osimage definition also will be created, the name could be 'mpss3-2.1-netboot' 
    
    copycds mpss_gold_update_3-2.1.6720-13-rhel-6.2.tar -n mpss3-2.1
    

  * Create the osimage 

This step will update the /etc/passwd, /etc/hosts, /root/.ssh in the root file system. And also install the software like 'PE' to the file system. 

Since package format of software is unknown (mostly I guess it could be a tar file which includes files of software and the configuration file for how to install the files to os image), how to install the software will be discussed later. 
    
    genimage mpss3-2.1-netboot
    

  * Prepare the individual osimage for each mic 

Since the 'individual osimage' for each mic will be created base on the 'root file system which format 'base dir, common dir, mic dir and overlay dir_ on the host , but the 'root file system' is located on MN, the MN:/install/ will be mounted to host first. Then base on the format of osimage: 'ramdisk' or 'nfs-based', the 'individual osimage' will be created. And also the specific configuration like 'IP of mic', 'bridge of mic' are configured after creating the 'individual osimage'._
    
    chdef -t osimage mpss3-2.1-netboot rootfstype={ramdisk|nfs}
    nodeset &lt;miv&gt; mpss3-2.1-netboot
    

  * Boot the mic node to load the osimage 
    
    rpower &lt;mic&gt; boot
    

## Install HPC Software for MIC node

Mic node only has 8G memory (without hard disk), and the 8G memory is shared by 64 cores in the mic node. To reduce the memory usage by the Operating System which running on mic node, Intel supplies a reduced Linux kernel and file system. The files which supplied by Intel are formatted with directory which contains all the selectable files + .filelist configuration which to specify that which files should be installed to which path on the mic. For example, Intel ships all the basic files for Linux file system in a directory named 'base', and a relative configuration file named 'base.filelist' is shipped to specify which files in 'base' directory should be installed to mic node. 

The software for hpc should be installed as an Overlay type, Overlay type is consist of a 'file directory' and .filelist configuration file, and Overlay type can be specified multiple times so that xCAT can add each hpc software as an Overlay type entry in mic configuration file. 

### Use PE Software as an Example:

Assume PE needs install following files to a target mic node: 
    
    /etc/init.d/pe  - The start script which needs be run after mic boot up to initiate/configure the PE
    /etc/pe.cfg     - Any PE configuration files in /etc
    /opt/pe/pe.bin  - Any PE files in /opt/pe
    /root/pe.run    - Any files in /root
    

As mentioned before, a pe.filelist should be introduced to specify where to install the files on mic node. Corresponding to above four files, the pe.filelist which includes following entries needs be added in /opt/mic/ 
    
    file /etc/init.d/pe etc/init.d/pe 0755 0 0
    file /root/pe.run root/pe.run 0644 0 0
    file /etc/pe.cfg etc/pe.cfg 0644 0 0
    dir /opt 0755 0 0
    dir /opt/pe 0755 0 0
    file /opt/pe/pe.bin opt/pe/pe.bin 0755 0 0
    

With above information, xCAT can create an overlay entry for pe in the configuration of mic. When boot of mic, the files listed in this part will be included in the target mic node. 

### The Rules for Packaging HPC Software as an RPM for Xeon Phi

  * The files should be normal files directly in the rpm, not in a tar file that is within the rpm. 

The files structure should look like following for PE in the pe.rpm: 
    
    /etc/init.d/pe
    /etc/pe.cfg
    /opt/pe/pe.bin
    /root/pe.run
    /opt/mic/pe.filelist
    

  * The script that is used to initiate and/or configure your software when the mic card is booting should be in the init.d format and be named '/etc/init.d/&lt;software name&gt;' (where &lt;software_name&gt; is, for example, "pe"). To let xCAT know the start and stop order in rc3 level of mic booting (rc3 is the default level for mic), this file needs to include a comment like '#start=x stop=y' (x, y is the number of order. 1-100) at beginning to specify the start/stop order in rc3 level. 
  * The .filelist which is used to configure the overlay should be named &lt;software name&gt;.filelist and must be put in '/opt/mic/'. xCAT will search it in '/opt/mic'. 
  * Scriptlets for the rpm (%post, etc.) need to be aware that they will be running either on the xcat mgmt node (during diskless image creation using genimage), or the xeon phi host node, not on the mic card. This means, for example, they should not start/stop daemons. The start of daemons should be added in /etc/init.d/&lt;software name&gt;. 
  * Any requirements your software has should be listed as Requires in the rpm spec file. Until mpss converts to yocto, the rpm dependencies will have to be handled in a special way by genimage. (This is because the hpc rpms for mic are actually installed on an x86_64 node, but dependencies are for binaries compiled for the mic card.) For this, the rpm spec file should specify "AutoReqProv: no" so rpm doesn't automatically generate any dependencies. The dependencies that the rpm specifies, using the Requires statement in the spec file, should specify the paths to the binaries or libraries, not rpm names. These binaries/libraries will have to be placed in a specified location that xcat defines. 

Following these rules will allow your rpm to upgrade properly and also be install either into an xcat diskless image, or manually be installed on the xeon phi host. (Installing into a running mic card won't be supported until mpss converts to yocto.) 

### Internal Consideration of How to Install HPC Software in an xCAT Diskless Image

After running copycds for the mpss on the xCAT management node, the default Linux file system for mic is put in /install/&lt;image name&gt;/opt/intel/mic/filesystem/. By default, only 'base' directory is included. To make a common method to manage all the HPC software which is installed for a mic node, the following procedure will be implemented by xcat code to create a diskless image for mic: 

  * The HPC software installation will be run by genimage command against the diskless image for mic. 
    
    genimage &lt;image name&gt;
    

  * The HPC software will be installed via genimage to a root of 'overlay/package': 
    
    /install/&lt;image name&gt;/opt/intel/mic/filesystem/overlay/package
    

  * Each product should have a .filelist to specify the selected files for creating the mic ramdisk. 
    
    /install/&lt;image name&gt;/opt/intel/mic/filesystem/overlay/package/opt/mic/&lt;software name&gt;.filelist
    

  * nodeset will create a ramfs for each mic node on the mic host 
    
    nodeset &lt;mic node&gt; osimage=&lt;image name&gt;
    

  * To add software to the osimage (during the nodeset command) xcat code will 

Search all .filelist in /install/&lt;image name&gt;/opt/intel/mic/filesystem/overlay/package/opt/mic/, then add software to ramfs. 

  * Add start script for &lt;software&gt; (in nodeset command) 

Search the file named &lt;software&gt; in /install/&lt;image name&gt;/opt/intel/mic/filesystem/overlay/package/etc/init.d/, get the start/stop order at beginning of this file, and then run 'micctrl --service=&lt;software name&gt; \--state=on --start=91 mic0' to add it as a start script for rc3. 

**How xcat will install hpc software to /install/&lt;image name&gt;/opt/intel/mic/filesystem/overlay/package/**

In this example, &lt;image name&gt; is 'mpss3-15-rh6.2'. 

To install a rpm software to another root, all the operation of rpm will be run in chroot format. To satisfy the dependencies of target HPC software, an host OS repo will be added, so when install HCP software, the dependency rpm will be searched in 'host OS repo'. It's a little tricky here that install rpm for mic but using dependency from host os. 

  * The procedure for Redhat: 

1\. cp &lt;software&gt;.rpm to /wxp/hpcrepo/ 

2\. run createrepo in /wxp/hpcrepo/ 

3\. create temporary yum.conf for HPC software installation 
    
    # cat micinstall.yum.conf
    [rh]
    name=rh
    baseurl=file:///install/rhels6.2/x86_64
    gpgcheck=0
    [hpc]
    name=hpc
    baseurl=file:///wxp/hpcrepo/
    gpgcheck=0
    

4\. Install the software 
    
    yum -c micinstall.yum.conf --installroot=/install/mpss3-15-rh6.2/opt/intel/mic/filesystem/overlay/package install &lt;software&gt;
    

  * The procedure for Sles: 

1\. copy software to /hpcpkg 

2\. create a repo for sles11 
    
    zypper -R /install/mpss3-15-rh6.2/opt/intel/mic/filesystem/overlay/package ar file:///root/iso/sles11.1/ sles11
    

3\. create a repo for software 
    
    zypper -R /install/mpss3-15-rh6.2/opt/intel/mic/filesystem/overlay/package ar file:///hpcpkg/ newpkg
    

4\. refresh the repo 
    
    zypper -R /install/mpss3-15-rh6.2/opt/intel/mic/filesystem/overlay/package refresh
    

5\. install software 
    
    zypper -R /install/mpss3-15-rh6.2/opt/intel/mic/filesystem/overlay/package install &lt;software&gt;
    

## Other Design Considerations

  * **Required reviewers**: 
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