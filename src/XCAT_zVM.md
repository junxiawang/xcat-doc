<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Document Abstract](#document-abstract)
- [Terminology](#terminology)
- [Support on z/VM and Linux on System z](#support-on-zvm-and-linux-on-system-z)
- [Design Architecture](#design-architecture)
- [xCAT Setup](#xcat-setup)
- [xCAT Commands](#xcat-commands)
- [Installing Linux Using AutoYast or Kickstart](#installing-linux-using-autoyast-or-kickstart)
- [Installing Linux Using SCSI/FCP](#installing-linux-using-scsifcp)
- [Adding Software Packages](#adding-software-packages)
- [Cloning Virtual Servers](#cloning-virtual-servers)
- [Setting Up Ganglia on xCAT](#setting-up-ganglia-on-xcat)
  - [Red Hat Enterprise Linux](#red-hat-enterprise-linux)
  - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server)
- [Ganglia Monitoring on xCAT](#ganglia-monitoring-on-xcat)
- [Statelite](#statelite)
  - [Red Hat Enterprise Linux](#red-hat-enterprise-linux-1)
  - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server-1)
- [Updating Linux](#updating-linux)
- [Limitations](#limitations)
- [Appendix A: Setting Up a Second Network](#appendix-a-setting-up-a-second-network)
  - [Red Hat Enterprise Linux](#red-hat-enterprise-linux-2)
  - [SUSE Linux Enterprise Server 10](#suse-linux-enterprise-server-10)
  - [SUSE Linux Enterprise Server 11](#suse-linux-enterprise-server-11)
- [Appendix B: Customizing Autoyast and Kickstart](#appendix-b-customizing-autoyast-and-kickstart)
  - [Red Hat Enterprise Server](#red-hat-enterprise-server)
  - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server-2)
- [Appendix C: Setting up Network Address Translation](#appendix-c-setting-up-network-address-translation)
  - [Red Hat Enterprise Server](#red-hat-enterprise-server-1)
  - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server-3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Document Abstract

This document provides an overview and a quick start guide on basic z/VM and Linux on System z administration using xCAT. For technical support, please post your question(s) on the [mailing-list](https://lists.sourceforge.net/lists/listinfo/xcat-user). 

## Terminology

This section outlines the terminology used within this document. 

  * **DirMaint**: CMS application that helps manage an installation's VM directory. 
  * **Ganglia**: _"Ganglia consists of two unique daemons (gmond and gmetad), a PHP-based web frontend and a few other small utility programs. Gmond is a multi-threaded daemon which runs on each cluster node you want to monitor. Gmetad is the daemon that monitors the other nodes by periodically polling them, parsing the collected XML, and saving all the numeric, volatile metrics to the round-robin databases."_ \- Ganglia Development Team 
  * **Life cycle**: A collection of tasks that include: power on/off of a virtual server, and create/edit/delete of a virtual server. 
  * **SMAPI**: The Systems Management APIs simplify the task of managing many virtual images running under a single z/VM image. 
  * **Virtual server**: A server composed of virtualized resources. An operating system can be installed on a virtual server. 
  * **VMCP**: Linux module that allows execution of CP commands. 
  * CP: _"The Control Program (CP) is the operating system that underlies all of z/VM. It is responsible for virtualizing your z/Series machine's real hardware, and allowing many virtual machines to simultaneously share the hardware resource."_ \- IBM 
  * **xCAT**: xCAT (Extreme Cloud Administration Tool) is a toolkit that provides support for the deployment and administration of large cloud environments. 
  * **zHCP**: zHCP (System z Hardware control point) is a Linux virtual server that interfaces with SMAPI and CP and manages other virtual servers on z/VM. 
  * **AutoYaST**: _"AutoYaST is a system for installing one or more SUSE Linux systems automatically and without user intervention. AutoYaST installations are performed using an autoyast profile with installation and configuration data."_ -SUSE 
  * **Kickstart**: _"Automated installation for Red Hat. It uses a file containing the answers to all the questions that would normally be asked during a typical Red Hat Linux installation."_ -Red Hat 

## Support on z/VM and Linux on System z

This section provides a list of supported functionalities on xCAT for z/VM and Linux on System z. 

  


  1. Lifecycle Management 
    * Power on/off VM 
    * Create/edit/delete VM 
    * Migrate VM between any z/VM in an SSI cluster (only in z/VM 6.2) 
  2. Inventory 
    * Software and hardware inventory of VM or z/VM system 
    * Resource (e.g. disks, networks) inventory of z/VM system 
  3. Image Management 
    * Cloning VM 
    * Vanilla installation of Linux via Autoyast or Kickstart 
    * Provisioning diskless VM via NFS read-only root filesystem 
  4. Network Management 
    * Supports Layer 2 and 3 network switching for QDIO GLAN/VSWITCH and Hipersockets GLAN 
    * Create/edit/delete QDIO GLAN/VSWITCH and Hipersockets GLAN 
    * Add/delete virtual network devices to VM 
  5. Storage Management 
    * Manage ECKD/FBAnative SCSI disks within a disk pool 
    * Add/remove ECKD/FBA/native SCSI disks from VM 
    * Attach or detach ECKD/FBA/native SCSI disks to a z/VM system 
  6. OS Management 
    * Upgrading Linux OS 
    * Add/update/remove software packages on OS 
    * Basic xCAT functionalities, e.g. remote shell, post-scripts, rsync, etc. 
  7. Monitoring 
    * Linux monitoring using Ganglia 
  8. Others 
    * Full command line interface support 
    * Web user interface support 
    * Self-service portal to provision VM on demand 

## Design Architecture

This section provides an architectural overview of xCAT on z/VM and Linux on System z. 

  


[[img src=Architecture.png]] **Figure 1**. Shows the layout of xCAT on System z.

xCAT can be used to manage virtual servers spanning across multiple z/VM partitions. The xCAT management node (MN) runs on any Linux virtual server. It manages each z/VM partition using a System z hardware control point (zHCP) running on a privileged Linux virtual server. The zHCP interfaces with z/VM systems management API (SMAPI), directory manager (DirMaint), and control program layer (CP) to manage the z/VM partition. It utilizes a C socket interface to communicate with the SMAPI layer and VMCP Linux module to communicate with the CP layer. 

## xCAT Setup

Before continuing, you should have gone through the [xCAT Setup on zVM and Linux on System z](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_zVM_Setup). 

## xCAT Commands

This section lists the current xCAT commands supported on z/VM and Linux on System z. 

  
`rpower` \- Controls the power for a node or noderange.  
The syntax is: `rpower &lt;node&gt; [on|off|softoff|stat|reset|reboot|pause|unpause]`
    
    
    # rpower gpok3 stat
    gpok3: on
    

Note: You should cleanly shutdown the node by issuing `rpower &lt;node&gt; softoff`. 

  
`mkvm` \- Creates a new virtual server with the same profile/resources as the specified node (cloning). Alternatively, creates a new virtual server based on a directory entry.  
The syntax is: `mkvm &lt;new node&gt; /tmp/&lt;directory_entry_text_file&gt;`
    
    
    # mkvm gpok3 /tmp/dirEntry.txt
    gpok3: Creating user directory entry for LNX3... Done
    

The directory entry can also be piped into stdin, using `cat` or `echo`. 
    
    
    cat /tmp/dirEntry.txt | mkvm gpok3 -s
    gpok3: Creating user directory entry for LNX3... Done
    

For cloning, the syntax is: `mkvm &lt;target Linux&gt; &lt;source Linux&gt; pool=&lt;disk pool&gt;`
    
    
    # mkvm gpok4 gpok3 pool=POOL1
    gpok4: Cloning gpok3
    gpok4: Linking source disk (0100) as (1100)
    gpok4: Linking source disk (0101) as (1101)
    gpok4: Stopping LNX3... Done
    gpok4: Creating user directory entry
    gpok4: Granting VSwitch (VSW1) access for gpok3
    gpok4: Granting VSwitch (VSW2) access for gpok3
    gpok4: Adding minidisk (0100)
    gpok4: Adding minidisk (0101)
    gpok4: Disks added (2). Disks in user entry (2)
    gpok4: Linking target disk (0100) as (2100)
    gpok4: Copying source disk (1100) to target disk (2100) using FLASHCOPY
    gpok4: Mounting /dev/dasdg1 to /mnt/LNX3
    gpok4: Setting network configuration
    gpok4: Linking target disk (0101) as (2101)
    gpok4: Copying source disk (1101) to target disk (2101) using FLASHCOPY
    gpok4: Powering on
    gpok4: Detatching source disk (0101) at (1101)
    gpok4: Detatching source disk (0100) at (1100)
    gpok4: Starting LNX3... Done
    

  
`rmvm` \- Removes a virtual server.  
The syntax is: `rmvm &lt;node&gt;`. 
    
    
    # rmvm gpok3
    gpok3: Deleting virtual server LNX3... Done
    

  
`lstree` \- Display VM hierarchy. It is important to run `rscan -w &lt;hcp&gt;` to populate the `zvm` table before trying this command.  
The syntax is: `lstree &lt;hcp&gt;`. 
    
    
    CEC: 1ABCD
    |__LPAR: MNO1
       |__zVM: POKDEV61
          |__VM: gpok2 (LNX2)
          |__VM: gpok3 (LNX3)
          |__VM: gpok4 (LNX4)
          |__VM: gpok5 (LNX5)
    

  
`lsvm` \- List a virtual server's configuration. Options supported are: 

  * Show the directory entry.   
The syntax is: `lsvm &lt;node&gt;`
        
        
        # lsvm gpok3
        gpok3: USER LNX3 PWD 512M 1G G
        gpok3: INCLUDE LNXDFLT
        gpok3: COMMAND SET VSWITCH VSW2 GRANT LNX3
        

  * List the defined network names available for a given node.  
The syntax is: `lsvm &lt;node&gt; --getnetworknames`
        
        
        # lsvm gpok3 --getnetworknames
        gpok3: LAN:QDIO SYSTEM GLAN1
        gpok3: LAN:HIPERS SYSTEM GLAN2
        gpok3: LAN:QDIO SYSTEM GLAN3
        gpok3: VSWITCH SYSTEM VLANTST1
        gpok3: VSWITCH SYSTEM VLANTST2
        gpok3: VSWITCH SYSTEM VSW1
        gpok3: VSWITCH SYSTEM VSW2
        gpok3: VSWITCH SYSTEM VSW3
        

  * List the configuration for a given network.  
The syntax is: `lsvm &lt;node&gt; --getnetwork [network_name]`
        
        
        # lsvm gpok3 --getnetwork GLAN1
        gpok3: LAN SYSTEM GLAN1        Type: QDIO    Connected: 1    Maxconn: INFINITE
        gpok3:   PERSISTENT  UNRESTRICTED  IP                        Accounting: OFF
        gpok3:   IPTimeout: 5                 MAC Protection: Unspecified
        gpok3:   Isolation Status: OFF
        

  * List the disk pool names available.  
The syntax is: `lsvm &lt;node&gt; --diskpoolnames`
        
        
        # lsvm gpok3 --diskpoolnames
        gpok3: POOL1
        gpok3: POOL2
        gpok3: POOL3
        

  * List the configuration for a given disk pool.  
The syntax is: `lsvm &lt;node&gt; --diskpool [pool_name] [space (free or used)]`
        
        
        # lsvm gpok3 --diskpool POOL1 free
        gpok3: #VolID DevType StartAddr Size
        gpok3: EMC2C4 3390-09 0001 10016
        gpok3: EMC2C5 3390-09 0001 10016
        

`chhypervisor` \- Changes the z/VM hypervisor's configuration. This command is only available in the development build of xCAT at this time.  
Note this command will work only if the z/VM hypervisor definition is created:  

    
    
    # nodeadd pokdev61 groups=hosts hypervisor.type=zvm nodetype.os=zvm6.1 zvm.hcp=gpok2.endicott.ibm.com mgt=zvm
    

Here, `pokdev61` is the z/VM system name, `zvm6.1` is the z/VM version, and `gpok2.endicott.ibm.com` is the full domain name of the zHCP. 

Options supported are: 

  * Add a disk to a disk pool defined in the EXTENT CONTROL. The disk has to already be attached to SYSTEM and formatted using CPFMTXA or CPFORMAT.  
The syntax is: `chhypervisor &lt;node&gt; --adddisk2pool [function] [region] [volume] [group]`. Function type can be either: (4) Define region as full volume and add to group OR (5) Add existing region to group. If the volume already exists in the EXTENT CONTROL, use function 5. If the volume does not exist in the EXTENT CONTROL, but is attached to SYSTEM, use function 4.  

        
        
        # chhypervisor pokdev61 --adddisk2pool 4 DM1234 DM1234 POOL1
        gpok2: Adding DM1234 to POOL1... Done
        
        
        
        # chhypervisor pokdev61 --adddisk2pool 5 DM1234 POOL1
        gpok2: Adding DM1234 to POOL1... Done
        

  * Dynamically add an ECKD disk to a running z/VM system.  
The syntax is: `chhypervisor &lt;node&gt; --addeckd [device_number]`
        
        
        # chhypervisor pokdev61 --addeckd DM1234
        gpok2: Adding ECKD disk to system... Done
        

  * Dynamically add a SCSI disk to a running z/VM system. The SCSI disk is added to the system as an EDEV.  
The syntax is: `chhypervisor &lt;node&gt; --addscsi [device_number] [device_path] [option] [persist]`. 
    * `device_number` is the device number.
    * `device_path` is a comma separated string containing the FCP device number, WWPN, and LUN.
    * `option` can be: (1) add new SCSI (default), (2) add new path, or (3) delete path.
    * `persist` can be: (YES) SCSI device updated in active and configured system, or (NO) SCSI device updated only in active system.
        
        
        # chhypervisor pokdev61 --addscsi 9000 "1A23,500512345678c411,4012345100000000;1A89,500512345678c411,4012345200000000" 2 YES
        gpok2: Adding a real SCSI disk to system... Done
        

  * Create a virtual network LAN  
The syntax is: `chhypervisor &lt;node&gt; --addvlan [name] [owner] [type] [transport]`. 
    * `type` must be: (1) unrestricted simulated HiperSockets NIC, (2) unrestricted simulated QDIO NIC, (3) restricted simulated HiperSockets NIC, or (4) restricted simulated QDIO NIC.
    * `transport` must be: (0) unspecified, (1) IP, or (2) ethernet.
        
        
        # chhypervisor pokdev61 --addvlan GLAN1 SYSTEM 2 2
        gpok2: Creating virtual network LAN GLAN1... Done
        

  * Create a virtual switch  
The syntax is: `chhypervisor &lt;node&gt; --addvswitch [name] [osa_device_address] [port_name] [controller] [connect (0, 1, or 2)] [memory_queue] [router] [transport] [vlan_id] [port_type] [update] [gvrp] [native vlan]`. 
    * `name` is the name of the virtual switch.
    * `osa_device_address` is the real device address of a real OSA-Express QDIO device used to create the switch.
    * `port_name` is name used to identify the OSA Expanded adapter.
    * `port_name` is name used to identify the OSA Expanded adapter.
    * `controller` is the user Id controlling the real device.
    * (Optional) `memory_queue` is the QDIO buffer size in megabytes.
    * (Optional) `router` Specifies whether the OSA-Express QDIO device will act as a router to the virtual switch and it can be: (0) unspecified, (1) not a router, or (2) primary router.
    * (Optional) `transport` specifies the transport mechanism to be used and it can be: (0) unspecified, (1) IP, or (2) ethernet.
    * (Optional) `vlan_id` is the VLAN ID.
    * (Optional) `port_type` is the port type and it can be: (0) unspecified, (1) access, or (2) trunk.
    * (Optional) `update` can be: (0) unspecified, (1) create a virtual switch on the active system, (2) create a virtual switch on the active system and add the definition to the system configuration file, or (3) add the virtual switch definition to the system configuration file.
    * (Optional) `gvrp` can be: (0) unspecified, (1) GVRP, or (2) no-GVRP.
    * (Optional) `native_vlan` is the native VLAN.
        
        
        # chhypervisor pokdev61 --addvswitch VSW1 8050 FOOBAR DTCVSW1
        gpok2: Creating virtual switch VSW1... Done
        

  * Add a zFCP device to a device pool defined in xCAT. The device must have been carved up in the storage controller and configured with a WWPN/LUN before it can be added to the xCAT storage pool. z/VM does not have the ability to communicate directly with the storage controller to carve up disks dynamically.  
The syntax is: `chhypervisor &lt;node&gt; --addzfcp2pool [pool] [state (free or used)] [wwpn] [lun] [size] [range (optional)] [owner (optional)]`. Multiple WWPNs can be specified for the same LUN (multi-pathing), each separated with a semi-colon. 
        
        
        # chhypervisor pokdev61 --addzfcp2pool zfcp1 free 500501234567C890 4012345600000000 8G
        pokdev61: Adding zFCP device to zfcp1 pool... Done
        

  * Remove a disk from a disk pool defined in the EXTENT CONTROL.  
The syntax is: `chhypervisor &lt;node&gt; --removediskfrompool [function] [region] [group]`. Function type can be either: (1) Remove region, (2) Remove region from group, (3) Remove region from all groups, OR (7) Remove entire group   
  
Remove a region from the EXTENT CONTROL: 
        
        
        # chhypervisor pokdev61 --removediskfrompool 1 DM1234
        gpok2: Removing DM1234... Done
        

Remove a region from a group in the EXTENT CONTROL: 
        
        
        # chhypervisor pokdev61 --removediskfrompool 2 DM1234 POOL1
        gpok2: Removing DM1234 from POOL1... Done
        

Remove a region from all groups in the EXTENT CONTROL: 
        
        
        # chhypervisor pokdev61 --removediskfrompool 3 DM1234
        gpok2: Removing DM1234... Done
        

Remove group POOL1 in the EXTENT CONTROL (The second argument has no significance): 
        
        
        # chhypervisor pokdev61 --removediskfrompool 7 FOOBAR POOL1
        gpok2: Removing POOL1... Done
        

  * Delete a real SCSI disk (EDEV).  
The syntax is: `chhypervisor &lt;node&gt; --removescsi [device number] [persist (YES or NO)]`. 
    * `persist` can be: (NO) SCSI device is deleted on the active system, or (YES) SCSI device is deleted from the active system and permanent configuration for the system.
        
        
        # chhypervisor pokdev61 --removescsi 9000 YES
        pokdev61: Deleting a real SCSI disk for system... Done
        

  * Delete a virtual network LAN.  
The syntax is: `chhypervisor &lt;node&gt; --removevlan [name] [owner]`. 
        
        
        # chhypervisor pokdev61 --removevlan GLAN1 SYSTEM
        pokdev61: Deleting virtual network LAN GLAN1... Done
        

  * Delete a virtual switch.  
The syntax is: `chhypervisor &lt;node&gt; --removevswitch [name]`. 
        
        
        # chhypervisor pokdev61 --removevswitch VSW1
        pokdev61: Deleting virtual switch VSW1... Done
        

  * Remove a zFCP device from a device pool defined in xCAT.  
The syntax is: `chhypervisor &lt;node&gt; --removezfcpfrompool [pool] [lun] [wwpn (optional)]`
        
        
        # chhypervisor pokdev61 --removezfcpfrompool zfcp1 4012345600000000
        pokdev61: Removing zFCP device 4012345600000000 from zfcp1 pool... Done
        

  * Execute a SMAPI function.  
The syntax is: `chhypervisor &lt;node&gt; --smcli [function_name] [args]`
        
        
        # chhypervisor pokdev62 --smcli Image_Query_DM -T LNX3
        pokdev61: USER LNX3 PSWD 796M 1G G
        pokdev61: INCLUDE LNXDFLT
        pokdev61: COMMAND SET VSWITCH VSW2 GRANT LNX3
        pokdev61: MDISK 0100 3390 0001 10016 EMC123 MR
        pokdev61: *DVHOPT LNK0 LOG1 RCM1 SMS0 NPW1 LNGAMENG PWC20121011 CRC??
        

A list of APIs supported can be found by using the help flag, e.g. `chhypervisor pokdev62 --smcli -h`. Specific arguments associated with a SMAPI function can be found by using the help flag for the function, e.g. `chhypervisor pokdev62 --smcli Image_Query_DM -h`. Only [z/VM 6.2 SMAPI functions](http://publib.boulder.ibm.com/infocenter/zvm/v6r2/topic/com.ibm.zvm.v620.dmse6/toc.htm) or older are supported at this time. Additional SMAPI functions will be added in subsequent zHCP versions. 

If an API is not supported in the level of SMAPI, you will receive: 
        
        
          Return Code: 900
          Reason Code: 12
          Description: Specified function does not exist
        

`chvm` \- Changes the virtual machine's configuration. Note some option specifics are only in the development build. Options supported are: 

  * Adds a 3390 (ECKD) disk to a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --add3390 [disk pool] [device address (or auto)] [size (G, M, or cylinders)] [mode] [read password (optional)] [write password (optional)] [multi password (optional)]`. If 'auto' is specified in place of a device address, xCAT will find a freely available device address. 
        
        
        # chvm gpok3 --add3390 POOL1 0101 3338 MR
        gpok3: Adding disk 0101 to LNX3... Done
        
        # chvm gpok3 --add3390 POOL1 0102 2G MR
        gpok3: Adding disk 0102 to LNX3... Done
        

  * Adds a 3390 (ECKD) disk that is defined in a virtual machine's directory entry to that virtual machine's active configuration.  
The syntax is: `chvm &lt;node&gt; --add3390active [device address] [mode]`
        
        
        # chvm gpok3 --add3390active 0101 MR
        gpok3: Adding disk 0101 to LNX3... Done
        

  * Adds a 9336 (FBA) disk to a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --add9336 [disk pool] [virtual device (or auto)] [size (blocks)] [mode] [read password (optional)] [write password (optional)] [multi password (optional)]`. If 'auto' is specified in place of a device address, xCAT will find a freely available device address. 
        
        
        # chvm gpok3 --add9336 POOL3 0101 4194272 MR
        gpok3: Adding disk 0101 to LNX3... Done
        
        # chvm gpok3 --add9336 POOL3 0102 6G MR
        gpok3: Adding disk 0102 to LNX3... Done
        

  * Adds a network adapter to a virtual machine's directory entry (case sensitive).  
The syntax is: `chvm &lt;node&gt; --addnic [address] [type] [device count]`
        
        
        # chvm gpok3 --addnic 0600 QDIO 3
        gpok3: Adding NIC 0900 to LNX3... Done
        

  * Adds a virtual processor to a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --addprocessor [address]`
        
        
        # chvm gpok3 --addprocessor 01
        gpok3: Adding processor 01 to LNX3... Done
        

  * Adds a virtual processor to a virtual machine's active configuration (case sensitive).  
The syntax is: `chvm &lt;node&gt; --addprocessoractive [address] [type]`
        
        
        # chvm gpok3 --addprocessoractive 01 IFL
        gpok3: CPU 01 defined
        

  * Adds a v-disk to a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --addvdisk [device address] [size] [mode]`
        
        
        # chvm gpok3 --addvdisk 0300 2097120 MR
        gpok3: Adding V-Disk 0300 to LNX3... Done
        

  * Adds a zFCP device to a virtual machine. This command is only available in the development build of xCAT at this time.  
The syntax is: `chvm &lt;node&gt; --addzfcp [pool] [device_address] [loaddev (0 or 1)] [size] [tag (optional)] [wwpn (optional)] [lun (optional)]`.  
The device address must be a dedicated FCP channel attached to the virtual server. Use `dedicatedevice` option to dedicate the FCP channel. The loaddev option allows the virtual server to boot from the zFCP device that is to be attached. 
        
        
        # chvm gpok3 --addzfcp zfcp1 b15a 0 2g
        gpok3: Using device with WWPN/LUN of 500501234567C890/4012345600000000
        gpok3: Configuring FCP device to be persistent... Done
        gpok3: Adding FCP device... Done
        

  * Connects a given network adapter to a GuestLAN.  
The syntax is: `chvm &lt;node&gt; --connectnic2guestlan [address] [lan] [owner]`
        
        
        # chvm gpok3 --connectnic2guestlan 0600 GLAN1 LN1OWNR
        gpok3: Connecting NIC 0600 to GuestLan GLAN1 on LN1OWNR... Done
        

  * Connects a given network adapter to a vSwitch.  
The syntax is: `chvm &lt;node&gt; --connectnic2vswitch [address] [vswitch]`
        
        
        # chvm gpok3 --connectnic2vswitch 0600 VSW1
        gpok3: Connecting NIC 0600 to VSwitch VSW1 on LNX3... Done
        

  * Copy a disk attached to a given virtual machine.  
The syntax is: `chvm &lt;node&gt; --copydisk [target_address] [source_node] [source_address]`
    * `target_address` is the virtual address of the disk you are going to copy into.
    * `source_node` is the node where the source disk resides.
    * `source_address` is the virtual address of the disk you are going to copy from.
        
        # chvm gpok3 --copydisk 0100 gpok2 0101

  * Adds a dedicated device to a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --dedicatedevice [virtual device] [real device] [read-only (0 or 1)]`. Specify 1 for `read-only` if the virtual device is to be in read-only mode, otherwise, specify a 0. 
        
        
        # chvm gpok3 --dedicatedevice 0101 637F 0
        gpok3: Dedicating device 637F as 0101 to LNX3... Done
        

  * Deletes the IPL statement from the virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --deleteipl`
        
        
        # chvm gpok3 --deleteipl
        gpok3: Removing IPL statement on LNX3... Done
        

  * Disconnects a given network adapter.  
The syntax is: `chvm &lt;node&gt; --disconnectnic [address]`
        
        
        # chvm gpok3 --disconnectnic 0600
        gpok3: Disconnecting NIC 0600 on LNX3... Done
        

  * Formats a disk attached to a given virtual machine using dasdfmt (only ECKD disks supported). The disk should not be linked to any other virtual server, and the virtual server should be powered off. This command is best used after add3390().  
The syntax is: `chvm &lt;node&gt; --formatdisk [disk address] [multi password (optional)]`
        
        
        # chvm gpok3 --formatdisk 0100
        gpok3: Linking target disk (0100) as (1100)
        gpok3: Formating target disk (dasdg)
        gpok3: Detatching target disk (1100)
        gpok3: Done
        

  * Grant vSwitch access for given virtual machine.  
The syntax is: `chvm &lt;node&gt; --grantvswitch [vSwitch]`
        
        
        # chvm gpok3 --grantvswitch VSW1
        gpok3: Granting VSwitch (VSW1) access for LNX3... Done

  * Purge the reader contents of a virtual machine.  
The syntax is: `chvm &lt;node&gt; --purgerdr`
        
        
        # chvm gpok3 --purgerdr
        gpok3: Purging reader contents of LNX3
        

  * Removes a minidisk from a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --removedisk [virtual device]`
        
        
        # chvm gpok3 --removedisk 0101
        gpok3: Removing disk 0101 on LNX3... Done
        

  * Removes a network adapter from a virtual machine's directory entry.  
The syntax is: `chvm &lt;node&gt; --removenic [address]`
        
        
        # chvm gpok3 --removenic 0700
        gpok3: Removing NIC 0700 on LNX3... Done
        

  * Removes a processor from an active virtual machine's configuration.  
The syntax is: `chvm &lt;node&gt; --removeprocessor [address]`
        
        
        # chvm gpok3 --removeprocessor 01
        gpok3: Removing processor 01 on LNX3... Done
        

  * Removes the LOADDEV statement from a virtual machines's directory entry.  
The syntax is: `chvm &lt;node&gt; --removeloaddev [wwpn] [lun]`
        
        
        # chvm gpok3 --removeloaddev 500501234567C890 4012345600000000
        gpok3: Removing LOADDEV directory statements
        gpok3: Replacing user entry of LNX3... Done
        

  * Removes a zFCP device from a virtual machine. This command is only available in the development build of xCAT at this time.  
The syntax is: `chvm &lt;node&gt; --removezfcp [device address] [wwpn] [lun]`
        
        
        # chvm gpok3 --removezfcp b15a 500501234567C890 4012345600000000
        gpok3: Updating FCP device pool... Done
        gpok3: De-configuring FCP device on host... Done
        

  * Replaces a virtual server's directory entry.  
The syntax is: `chvm &lt;node&gt; --replacevs [directory entry]`. The directory entry can also be piped into stdin, using `cat` or `echo`. 
        
        
        # cat /tmp/dirEntry.txt | chvm gpok3 --replacevs 
        gpok3: Replacing user entry of LNX3... Done
        

  * Sets the IPL statement for a given virtual server.  
The syntax is: `chvm &lt;node&gt; --setipl [ipl target] [load parms] [parms]`
        
        
        # chvm gpok3 --setipl CMS
        gpok3: Setting IPL statement on LNX3... Done
        

  * Sets the LOADDEV statement for a given virtual server. This command is only available in the development build of xCAT at this time.  
The syntax is: `chvm &lt;node&gt; --setloaddev [wwpn] [lun]`
        
        
        # chvm gpok3 --setloaddev 5005076306138411 4014403000000000
        gpok3: Setting LOADDEV directory statements
        gpok3: Locking LINUX3... Done
        gpok3: Replacing user entry of LINUX3... Done
        

  * Sets the password for a given virtual server.  
The syntax is: `chvm &lt;node&gt; --setpassword [password]`
        
        
        # chvm gpok3 --setpassword PSSWD
        gpok3: Setting password for LNX3... Done
        

  * Delete a dedicated device from a virtual machine's active configuration and directory entry.  
The syntax is: `chvm &lt;node&gt; --undedicatedevice [virtual device]`
        
        
        # chvm gpok3 --undedicatedevice 1B89
        gpok3: Deleting dedicated device from LNX3's directory entry... Done
        

  
`rscan` \- Collects the node information from one or more hardware control points.  
The syntax is `rscan &lt;zhcp&gt; [-w]`. The `-w` option will populate the database with details collected by rscan. 
    
    
    # rscan gpok2
    gpok2:
      objtype=node
      arch=s390x
      os=sles10sp3
      hcp=gpok3.endicott.ibm.com
      userid=LINUX2
      nodetype=vm
      parent=POKDEV61
      groups=all
      mgt=zvm
    

  
`rinv` \- Remote hardware and software inventory. Options supported are: 

  * Collect the hardware and software inventory of a virtual machine.  
The syntax is: `rinv &lt;node&gt; &lt;all|config&gt;`. 
        
        
        # rinv gpok3 all
        gpok3: z/VM UserID: XCAT3
        gpok3: z/VM Host: POKDEV61
        gpok3:Operating System: SUSE Linux Enterprise Server 11 (s390x)
        gpok3: Architecture:	s390x
        gpok3: HCP: gpok3.endicott.ibm.com
        gpok3: Privileges: 
        gpok3:     Currently: G
        gpok3:     Directory: G
        gpok3: 
        gpok3: Total Memory:	796M
        gpok3: Processors: 
        gpok3:     CPU 01  ID  FF0C452E20978000 CP   CPUAFF ON
        gpok3:     CPU 00  ID  FF0C452E20978000 (BASE) CP   CPUAFF ON
        gpok3: 
        gpok3: Disks: 
        gpok3:     DASD 0100 3390 EMC2C6 R/W      10016 CYL ON DASD  C2C6 SUBCHANNEL = 0000
        gpok3:     DASD 0190 3390 EV61A2 R/O        107 CYL ON DASD  61A2 SUBCHANNEL = 000E
        gpok3:     DASD 0191 3390 EMC20D R/O       1000 CYL ON DASD  C20D SUBCHANNEL = 0013
        gpok3:     DASD 019D 3390 EV61A2 R/O        146 CYL ON DASD  61A2 SUBCHANNEL = 000F
        gpok3:     DASD 019E 3390 EV61A2 R/O        250 CYL ON DASD  61A2 SUBCHANNEL = 0010
        gpok3:     DASD 0300 9336 (VDSK) R/W     262144 BLK ON DASD  VDSK SUBCHANNEL = 0014
        gpok3:     DASD 0301 9336 (VDSK) R/W     524288 BLK ON DASD  VDSK SUBCHANNEL = 0015
        gpok3:     DASD 0402 3390 EV61A2 R/O        146 CYL ON DASD  61A2 SUBCHANNEL = 0011
        gpok3:     DASD 0592 3390 EV61A2 R/O         70 CYL ON DASD  61A2 SUBCHANNEL = 0012
        gpok3: 
        gpok3: NICs:	
        gpok3:     Adapter 0600.P00 Type: QDIO      Name: UNASSIGNED  Devices: 3
        gpok3:       MAC: 02-00-06-00-05-38         LAN: * None
        gpok3:     Adapter 0700.P00 Type: QDIO      Name: UNASSIGNED  Devices: 3
        gpok3:       MAC: 02-00-06-00-05-39         LAN: * None
        gpok3:     Adapter 0800.P00 Type: QDIO      Name: FOOBAR      Devices: 3
        gpok3:       MAC: 02-00-06-00-05-3A         VSWITCH: SYSTEM VSW2
        

Note the complete inventory can only be retrieved when the node is online. 

  * Collect the hardware and software inventory of a z/VM system.  
The syntax is: `rinv &lt;node&gt; &lt;all|config&gt;`. 
        
        
        # rinv pokdev61 all
        pokdev61: z/VM Host: POKDEV61
        pokdev61: zHCP: gpok3.endicott.ibm.com
        pokdev61: Architecture: s390x
        pokdev61: CEC Vendor: IBM
        pokdev61: CEC Model: 2097
        pokdev61: Hypervisor OS: z/VM 6.1.0
        pokdev61: Hypervisor Name: POKDEV61
        pokdev61: LPAR CPU Total: 10
        pokdev61: LPAR CPU Used: 10
        pokdev61: LPAR Memory Total: 16G
        pokdev61: LPAR Memory Used: 0M
        pokdev61: LPAR Memory Offline: 0
        

  * List the configuration for a given disk pool.  
The syntax is: `rinv &lt;node&gt; --diskpool [pool name] [space (free or used)]`
        
        
        # rinv pokdev61 --diskpool POOL1 free
        pokdev61: #VolID DevType StartAddr Size
        pokdev61: EMC2C4 3390-09 0001 10016
        pokdev61: EMC2C5 3390-09 0001 10016
        

  * List the disk pool names available.  
The syntax is: `rinv &lt;node&gt; --diskpoolnames`
        
        
        # rinv pokdev61 --diskpoolnames
        pokdev61: POOL1
        pokdev61: POOL2
        pokdev61: POOL3
        

  * List the state of real FCP adapter devices on the z/VM system.  
The syntax is: `rinv &lt;node&gt; --fcpdevices [state]`. The state can be either: active, free, or offline. 
        
        
        # rinv pokdev61 --fcpdevices free
        pokdev61: B150
        pokdev61: B151
        pokdev61: B152
        pokdev61: B153
        pokdev61: B154
        pokdev61: B155
        pokdev61: B156
        pokdev61: B157
        

  * List the defined network names available on the z/VM system.  
The syntax is: `rinv &lt;node&gt; --networknames`
        
        
        # rinv pokdev61 --networknames
        pokdev61: LAN:QDIO SYSTEM GLAN1
        pokdev61: LAN:HIPERS SYSTEM GLAN2
        pokdev61: LAN:QDIO SYSTEM GLAN3
        pokdev61: VSWITCH SYSTEM VLANTST1
        pokdev61: VSWITCH SYSTEM VLANTST2
        pokdev61: VSWITCH SYSTEM VSW1
        pokdev61: VSWITCH SYSTEM VSW2
        pokdev61: VSWITCH SYSTEM VSW3
        

  * List the configuration for a given network.  
The syntax is: `rinv &lt;node&gt; --network [networkname]`
        
        
        # rinv pokdev61 --network GLAN1
        pokdev61: LAN SYSTEM GLAN1        Type: QDIO    Connected: 1    Maxconn: INFINITE
        pokdev61:   PERSISTENT  UNRESTRICTED  IP                        Accounting: OFF
        pokdev61:   IPTimeout: 5                 MAC Protection: Unspecified
        pokdev61:   Isolation Status: OFF
        

  * Obtain the SSI and system status.  
The syntax is: `rinv &lt;node&gt; --ssi`
        
        
        # rinv pokdev62 --ssi
        pokdev62: ssi_name = POKSSI
        pokdev62: ssi_mode = Stable
        pokdev62: ssi_pdr = CVD964_on_D964
        pokdev62: cross_system_timeouts = Enabled
        pokdev62: output.ssiInfoCount = 4
        pokdev62: 
        pokdev62: member_slot = 1
        pokdev62: member_system_id = POKDEV62
        pokdev62: member_state = Joined
        pokdev62: member_pdr_heartbeat = 02/05/2013_22:34:40
        pokdev62: member_received_heartbeat = 02/05/2013_22:34:40
        pokdev62: 
        pokdev62: member_slot = 2
        pokdev62: member_system_id = POKTST62
        pokdev62: member_state = Joined
        pokdev62: member_pdr_heartbeat = 02/05/2013_22:34:28
        pokdev62: member_received_heartbeat = 02/05/2013_22:34:28
        

  * Obtain the SMAPI level installed on the z/VM system. 
        
        
        # rinv pokdev62 --smapilevel
        pokdev62: The API functional level is z/VM V6.2
        

  * Query all FCPs on a z/VM system and return a list of WWPNs. 
        
        
        # rinv pokdev62 --wwpn
        pokdev62: 0000000000234567
        pokdev62: 0000000000345678
        

  * List the devices in a given zFCP device pool.  
The syntax is: `rinv &lt;node&gt; --zfcppool [pool name] [space (free or used)]`
        
        
        # rinv pokdev61 --zfcppool zfcp1
        pokdev61: #status,wwpn,lun,size,owner,channel,tag
        pokdev61: free,500512345678c411,4012345100000000,2g,,,
        pokdev61: used,500512345678c411,4012345200000000,8192M,gpok4,b15a,replace_root_device
        pokdev61: free,500512345678c411,4012345300000000,8g,,,
        pokdev61: free,500512345678c411,4012345400000000,2g,,,
        pokdev61: free,500512345678c411,4012345600000000,2g,,,
        

  * List the known zFCP pool names. 
        
        
        # rinv pokdev62 --zfcppoolnames
        pokdev62: zfcp1
        pokdev62: zfcp2
        

`rmigrate` \- Migrate VM from one z/VM member to another in an SSI cluster (only in z/VM 6.2). This command is only available in the development build of xCAT at this time.  
The syntax is: `rmigrate &lt;node&gt; destination=[zvm member] action=[MOVE, TEST, or CANCEL] force=[ARCHITECTURE, DOMAIN, or STORAGE] immediate=[YES or NO] max_total=[total in seconds (optional)] max_quiesce=[quiesce in seconds(optional)]`. The key value pairs can be specified in any order. 

  * `destination` is the name of the destination z/VM system to which the specified virtual machine will be relocated.
  * `action` can be: (MOVE) initiate a VMRELOCATE MOVE of the VM, (TEST) determine if VM is eligible to be relocated, or (CANCEL) stop the relocation of VM.
  * `force` can be: (ARCHITECTURE) attempt relocation even though hardware architecture facilities or CP features are not available on destination system, (DOMAIN) attempt relocation even though VM would be moved outside of its domain, or (STORAGE) relocation should proceed even if CP determines that there are insufficient storage resources on destination system.
  * `immediate` can be: (YES) VMRELOCATE command will do one early pass through virtual machine storage and then go directly to the quiesce stage, or (NO) specifies immediate processing.
  * `max_total` is the maximum wait time for relocation to complete. Optional.
  * `max_quiesce` is the maximum quiesce time a VM may be stopped during a relocation attempt. Optional.
    
    
    # rmigrate gpok3 destination=poktst62 action=MOVE immediate=NO force="ARCHITECTURE DOMAIN STORAGE"
    gpok3: Running VMRELOCATE action=MOVE against LNX3... Done
    

`xdsh` \- Concurrently runs commands on multiple nodes.  
The syntax is: `xdsh &lt;node&gt; -e &lt;script&gt;`. 
    
    # xdsh gpok3 /tmp/myScript.sh
    

  
For a list of general xCAT commands, [click here](http://xcat.sourceforge.net/man1/xcat.1.html).  


For some commands above, such as `chvm`, a return code and reason code may be returned. xCAT will translate the meaning for most of these codes. In such cases where it could not, refer to the [Systems Management Application Programming (SMAPI)](http://publib.boulder.ibm.com/infocenter/zvm/v6r2/topic/com.ibm.zvm.v620.dmse6/hcsl8c1167.htm?path=6_18_5_2_0#wq1561) documentation, which lists the return codes and their description.  


In some cases, a return code of 596 may be returned. In this case, take the reason code that follows it and decipher it using the [Directory Maintenance Facility Messages](http://publib.boulder.ibm.com/infocenter/zvm/v5r4/topic/com.ibm.zvm.v54.hcpk2/msgs.htm#msgs) documentation. 

## Installing Linux Using AutoYast or Kickstart

This section provides details on the installation of Linux using autoyast or kickstart. 

  
There are two ways to install Linux onto a z/VM virtual server, depending on which Linux distribution you want. One is through autoyast, which is used to install SUSE Linux Enterprise Server (SLES) releases. The other is through kickstart, which is used to install Red Hat Enterprise Linux (RHEL) releases. 

  
Before you begin, make sure the following is done. 

  * The FTP server must be setup during the xCAT MN installation, and the FTP root directory (/install) must contain the appropriate Linux distribution. 
  * If you are managing an IP address range starting at 1 (e.g. 10.1.100.1), be sure that the netmask is set correctly (e.g. 255.255.255.0) on the xCAT MN or else the node you are trying to provision cannot find the repository. 

  
In the following example, we will provision a new node (gpok3) with a userID (LNX3) that is managed by our zHCP (gpok2). You will need to substitute the node name, userID, and zHCP name with appropriate values. 

  1. Logon the xCAT MN as root using a Putty terminal
  2. Create the node definition 
        
        
        # mkdef -t node -o gpok3 userid=LNX3 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all
        Object definitions have been created or modified.
        

Set the node's IP address and hostname (only if a regex is not set for the group) 
        
        
        # chtab node=gpok3 hosts.ip="10.1.100.3" hosts.hostnames="gpok3.endicott.ibm.com"
        

  3. Update /etc/hosts 
        
        # makehosts

  4. Update DNS 
        
        # makedns

  5. Define the directory entry for the new virtual server in a text file (dirEntry.txt). For our example, we used the following: 
        
        
        USER LNX3 PWD 512M 1G G
        INCLUDE LNXDFLT
        COMMAND SET VSWITCH VSW2 GRANT LNX3
        COMMAND COUPLE 0800 SYSTEM VSW2
        

Once you have defined the directory entry in a text file, create the virtual server by issuing the following command (the full file path must be given): 
        
        
        # mkvm gpok3 /tmp/dirEntry.txt
        gpok3: Creating user directory entry for LNUX3... Done
        

The directory entry text file should not contain any extra new lines (/n). A MAC address will be assigned to the user ID upon creation. 

  6. Copy the default autoyast/kickstart template and package list available in xCAT (if not already). Customize this template and package list (the ones you copied) to how you see fit. For more information on how to customize the template, see Appendix B.  
  
If you want to install a SUSE Linux Enterprise Server: 
        
        
        # mkdir -p /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/compute.sles10.s390x.tmpl /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/compute.sles10.s390x.pkglist /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/compute.sles11.s390x.tmpl /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/compute.sles11.s390x.pkglist /install/custom/install/sles
        

There are two templates available for SLES, one for SLES 10 (compute.sles10.s390x.tmpl) and the other for SLES 11 (compute.sles11.s390x.tmpl). It is recommended that you copy both templates into /install/custom/install/sles. 

  
If you want to install a Red Hat Enterprise Linux: 
        
        
        # mkdir -p /install/custom/install/rh
        # cp /opt/xcat/share/xcat/install/rh/compute.rhel5.s390x.tmpl /install/custom/install/rh
        # cp /opt/xcat/share/xcat/install/rh/compute.rhel5.s390x.pkglist /install/custom/install/rh
        # cp /opt/xcat/share/xcat/install/rh/compute.rhels6.s390x.tmpl /install/custom/install/rh/compute.rhel6.s390x.tmpl
        # cp /opt/xcat/share/xcat/install/rh/compute.rhels6.s390x.pkglist /install/custom/install/rh/compute.rhel6.s390x.pkglist
        

There are also two templates available for RHEL, one for RHEL 5 (compute.rhel5.s390x.tmpl) and the other for RHEL 6 (compute.rhels6.s390x.tmpl). It is recommended that you copy both templates into /install/custom/install/rh. 

  
The default templates are configured to use one 3390-mod9 with / mounted and use DHCP. The package lists (.pkglist) are configured to install the base software package. You should only customize the disks, partitioning, and install packages, and leave the network configuration alone. xCAT will handle the network configuration based on the xCAT hosts and networks table. 

  7. Add disks to the new node (the default autoyast/kickstart template available in xCAT requires 1 3390-MOD9 disks attached at 0100). 
        
        
        # chvm gpok3 --add3390 POOL1 0100 10016 MR
        gpok3: Adding disk 0100 to LNX3... Done
        

Be sure that each disk in the pool is attached to SYSTEM. 

  
Alternatively, you can use SCSI/FCP disks (which are seen by z/VM as 9336 disks), but you first need to configure the autoyast/kickstart template. See Appendix B for details. If you choose to have SCSI/FCP disks, you can add these disks to the new node using: 
        
        
        # chvm gpok3 --add9336 POOL3 0101 512 4194272 MR
        gpok3: Adding disk 0100 to LNX3... Done
        

  8. Set up the noderes and nodetype tables. You need to determine the OS and profile (autoyast/kickstart template) for the node. Here, we have nodetype.os=sles10sp3. You can find available OS and profiles by issuing: 
        
        # tabdump osimage

  
If you want to install a SUSE Linux Enterprise Server: 
        
        # chtab node=gpok3 noderes.netboot=zvm nodetype.os=sles10sp3 nodetype.arch=s390x nodetype.profile=compute

  
If you want to install a Red Hat Enterprise Linux: 
        
        # chtab node=gpok3 noderes.netboot=zvm nodetype.os=rhel5.4 nodetype.arch=s390x nodetype.profile=compute

  9. (Optional) If the xCAT MN is on multiple networks, such as 10.1.100.0/24 and 192.168.100.0/24, then you will need to specify the address to use for it during provisioning. For example, if the node you are provisioning is on the 192.168.100.0/24 network, and the IP address of the xCAT MN specified in site.master is 10.1.100.1, then you need to specify issue: 
        
        # nodech gpok3 noderes.xcatmaster=192.168.100.1

This is assuming 192.168.100.1 is the IP address of the xCAT MN on the 192.168.100.0/24 network. You only need to run the command if the node is on a different network than the one specified in site.master. This allows the autoyast/kickstart template and the software repository to be found for installation. 

  10. Verify the definition 
        
        # lsdef gpok3

It should look similar to this: 
        
        
        Object name: gpok3
             arch=s390x
             groups=all
             hcp=gpok2.endicott.ibm.com
             hostnames=gpok3.endicott.ibm.com
             ip=10.1.100.3
             mac=02:00:01:FF:FF:F0
             mgt=zvm
             netboot=zvm
             os=sles10sp3
             postbootscripts=otherpkgs
             postscripts=syslog,remoteshell,syncfiles
             profile=compute
             userid=LNX3
        

  11. Add the new node to DHCP 
        
        # makedhcp -a

  12. Prepare the new node for installation 
        
        
        # nodeset gpok3 install
        gpok3: Purging reader... Done
        gpok3: Punching kernel to reader... Done
        gpok3: Punching parm to reader... Done
        gpok3: Punching initrd to reader... Done
        gpok3: Kernel, parm, and initrd punched to reader.  Ready for boot.
        

  13. Boot the new node from reader 
        
        
        # rnetboot gpok3 ipl=00C
        gpok3: Starting LNX3... Done
        
        gpok3: Booting from 00C... Done
        

  14. In Gnome or KDE, open the VNC viewer to see the installation progress. It might take a couple of minutes before you can connect. 
        
        # vncviewer gpok3:1

The default VNC password is 12345678. If you have trouble connecting to the vncviewer, open a 3270 console to the node, try steps 11 and 12 again, and look at the progress on the console. 

  15. (Only for SLES 10 SP2 or older) Once the first phase of installation is complete, restart the virtual server to complete the final phase of installation 
        
        # rpower gpok3 reset

  16. The default password for the node can be found in the passwd table. See [Initializing Database](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_zVM_Setup#Initializing_Database) section step 4. The SSH keys should already be setup for the node.

## Installing Linux Using SCSI/FCP

This section provides details on the installation of Linux using SCSI/FCP. This feature is only available in the development build of xCAT at this time. xCAT has limited support for SCSI/FCP devices. Features such as NPIV are not currently supported, but will be in subsequent releases. 

  1. Logon the xCAT MN as root using a Putty terminal
  2. Create the z/VM hypervisor definition (if not already) 
        
        
        # nodeadd pokdev61 groups=hosts hypervisor.type=zvm nodetype.os=zvm6.1 zvm.hcp=gpok2.endicott.ibm.com mgt=zvm
        

  3. Create the node definition 
        
        
        # mkdef -t node -o gpok4 userid=LNX4 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all
        Object definitions have been created or modified.
        

Set the node's IP address and hostname (only if a regex is not set for the group) 
        
        
        # chtab node=gpok4 hosts.ip="10.1.100.4" hosts.hostnames="gpok4.endicott.ibm.com"
        

  4. Update /etc/hosts 
        
        # makehosts

  5. Update DNS 
        
        # makedns

  6. Define the directory entry for the new virtual server in a text file (dirEntry.txt). For our example, we used the following: 
        
        
        USER LNX4 PWD 512M 1G G
        INCLUDE LNXDFLT
        COMMAND SET VSWITCH VSW2 GRANT LNX4
        

Once you have defined the directory entry in a text file, create the virtual server by issuing the following command (the full file path must be given): 
        
        
        # mkvm gpok4 /tmp/dirEntry.txt
        gpok4: Creating user directory entry for LNX4... Done
        

The directory entry text file should not contain any extra new lines (/n). A MAC address will be assigned to the user ID upon creation. 

  7. Copy the default autoyast/kickstart template and package list available in xCAT (if not already). Customize this template and package list (the ones you copied) to how you see fit. For more information on how to customize the template, see Appendix B.  
  
If you want to install a SUSE Linux Enterprise Server: 
        
        
        # mkdir -p /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/zfcp.sles10.s390x.tmpl /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/zfcp.sles10.s390x.pkglist /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/zfcp.sles11.s390x.tmpl /install/custom/install/sles
        # cp /opt/xcat/share/xcat/install/sles/zfcp.sles11.s390x.pkglist /install/custom/install/sles
        

There are two templates available for SLES, one for SLES 10 (zfcp.sles10.s390x.tmpl) and the other for SLES 11 (zfcp.sles11.s390x.tmpl). It is recommended that you copy both templates into /install/custom/install/sles. 

  
If you want to install a Red Hat Enterprise Linux: 
        
        
        # mkdir -p /install/custom/install/rh
        # cp /opt/xcat/share/xcat/install/rh/zfcp.rhel5.s390x.tmpl /install/custom/install/rh
        # cp /opt/xcat/share/xcat/install/rh/zfcp.rhel5.s390x.pkglist /install/custom/install/rh
        # cp /opt/xcat/share/xcat/install/rh/zfcp.rhels6.s390x.tmpl /install/custom/install/rh/zfcp.rhel6.s390x.tmpl
        # cp /opt/xcat/share/xcat/install/rh/zfcp.rhels6.s390x.pkglist /install/custom/install/rh/zfcp.rhel6.s390x.pkglist
        

There are also two templates available for RHEL, one for RHEL 5 (zfcp.rhel5.s390x.tmpl) and the other for RHEL 6 (zfcp.rhels6.s390x.tmpl). It is recommended that you copy both templates into /install/custom/install/rh. 

  
The default templates are configured to use one SCSI device with / mounted and use DHCP. The package lists (.pkglist) are configured to install the base software package. You should only customize the disks, partitioning, and install packages, and leave the network configuration alone. xCAT will handle the network configuration based on the xCAT hosts and networks table. 

  8. Find a suitable FCP channel to dedicate to the virtual server. 
        
        
        # rinv pokdev61 --fcpdevices free
        pokdev61: B150
        pokdev61: B151
        pokdev61: B152
        pokdev61: B153
        pokdev61: B154
        pokdev61: B155
        pokdev61: B156
        pokdev61: B157
        pokdev61: B158
        pokdev61: B159
        pokdev61: B15A
        

  9. Dedicate the FCP channel to the virtual server 
        
        
        # chvm gpok4 --dedicatedevice B15A B15A 0
        gpok4: Dedicating device B15A as B15A to LNX4... Done
        

  10. Add disks to the new node (the default autoyast/kickstart template available in xCAT requires 1 SCSI/FCP disk with enough space for a Linux operating system). Note that a tag (`replace_root_device`) is specified. This tag identifies how the device will be partitioned in the autoyast/kickstart template. The appropriate WWPN/LUN will be substituted in place of this tag later on with the `nodeset` command. Also, one disk must be set as the LOADDEV device, allowing the virtual server to boot from it at IPL. 
        
        
        # chvm gpok4 --addzfcp zfcp1 b15a 1 8g replace_root_device
        gpok4: Using device with WWPN/LUN of 500501234567C890/4012345600000000
        gpok4: Adding FCP device... Done
        gpok4: Setting LOADDEV directory statements
        gpok4: Locking LNX4... Done
        gpok4: Replacing user entry of LNX4... Done
        

  11. Set up the noderes and nodetype tables. You need to determine the OS and profile (autoyast/kickstart template) for the node. Here, we have nodetype.os=sles11sp2. You can find available OS and profiles by issuing: 
        
        # tabdump osimage

  
If you want to install a SUSE Linux Enterprise Server: 
        
        # chtab node=gpok4 noderes.netboot=zvm nodetype.os=sles11sp2 nodetype.arch=s390x nodetype.profile=zfcp

  
If you want to install a Red Hat Enterprise Linux: 
        
         # chtab node=gpok4 noderes.netboot=zvm nodetype.os=rhel6.2 nodetype.arch=s390x nodetype.profile=zfcp

  12. (Optional) If the xCAT MN is on multiple networks, such as 10.1.100.0/24 and 192.168.100.0/24, then you will need to specify the address to use for it during provisioning. For example, if the node you are provisioning is on the 192.168.100.0/24 network, and the IP address of the xCAT MN specified in site.master is 10.1.100.1, then you need to specify issue: 
        
        # nodech gpok4 noderes.xcatmaster=192.168.100.1

This is assuming 192.168.100.1 is the IP address of the xCAT MN on the 192.168.100.0/24 network. You only need to run the command if the node is on a different network than the one specified in site.master. This allows the autoyast/kickstart template and the software repository to be found for installation. 

  13. Verify the definition 
        
        # lsdef gpok4

It should look similar to this: 
        
        
        Object name: gpok4
             arch=s390x
             groups=all
             hcp=gpok2.endicott.ibm.com
             hostnames=gpok4.endicott.ibm.com
             ip=10.1.100.4
             mac=02:00:01:FF:FF:EF
             mgt=zvm
             netboot=zvm
             os=sles11sp2
             postbootscripts=otherpkgs
             postscripts=syslog,remoteshell,syncfiles
             profile=compute
             userid=LNX4
        

  14. Add the new node to DHCP 
        
        # makedhcp -a

  15. Prepare the new node for installation 
        
        
        # nodeset gpok4 install
        gpok4: Inserting FCP devices into template... Done
        gpok4: Purging reader... Done
        gpok4: Punching kernel to reader... Done
        gpok4: Punching parm to reader... Done
        gpok4: Punching initrd to reader... Done
        gpok4: Kernel, parm, and initrd punched to reader.  Ready for boot.
        

  16. Boot the new node from reader 
        
        
        # rnetboot gpok4 ipl=00C
        gpok3: Starting LNX4... Done
        
        gpok3: Booting from 00C... Done
        

  17. In Gnome or KDE, open the VNC viewer to see the installation progress. It might take a couple of minutes before you can connect. 
        
        # vncviewer gpok4:1

The default VNC password is 12345678. If you have trouble connecting to the vncviewer, open a 3270 console to the node, try steps 11 and 12 again, and look at the progress on the console. 

  18. (Only for SLES 10 SP2 or older) Once the first phase of installation is complete, restart the virtual server to complete the final phase of installation 
        
        # rpower gpok4 reset

  19. The default password for the node can be found in the passwd table. See [Initializing Database](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_zVM_Setup#Initializing_Database) section step 4. The SSH keys should already be setup for the node.

## Adding Software Packages

This section shows how to add other software packages (ones available outside the OS distribution) into the autoyast/kickstart installation process. 

  
In the following example, we will add Ganglia (packaged with xCAT) and configure it during the autoyast/kickstart installation. 

  1. Put the RPMs you want to be installed under `/install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;` directory on the xCAT MN, where `&lt;os&gt;` and `&lt;arch&gt;` can be found in the nodetype table. It is important to note that the `&lt;os&gt;` name must match what is in the nodetype table. If it does not match, the additional software packages will not be installed. 
        
        
        # mkdir -p /install/post/otherpkgs/sles11sp1/s390x 
        # cp /root/xcat/xcat-dep/sles11/s390x/ganglia-gmond-3.1.1-1.s390x.rpm /install/post/otherpkgs/sles11sp1/s390x
        # cp /root/xcat/xcat-dep/sles11/s390x/libganglia-3.1.1-1.s390x.rpm /install/post/otherpkgs/sles11sp1/s390x
        # cp /root/xcat/xcat-dep/sles11/s390x/libconfuse-2.6-1.s390x.rpm /install/post/otherpkgs/sles11sp1/s390x
        

  2. Create a repository under the directory where you put the RPMs. Every time the RPM version is updated, you will need to recreate this repository using `createrepo`. 
        
        
        # cd /install/post/otherpkgs/sles11sp1/s390x
        # createrepo .
        Saving Primary metadata
        Saving file lists metadata
        Saving other metadata
        

  3. Put the package names (in our case, libconfuse, libganglia, and ganglia-gmond) to be installed in `/install/custom/install/&lt;os&gt;/&lt;profile&gt;.&lt;os&gt;.otherpkgs.pkglist`. For example 
        
        
        # cat /install/custom/install/sles/compute.sles11sp1.otherpkgs.pkglist
        libconfuse 
        libganglia 
        ganglia-gmond
        

The autoyast/kickstart install process picks up the RPMs listed in the otherpkgs.pkglist and installs them on to the nodes. 

  4. Most software packages require some kind of configuration. In the case of Ganglia, gmond needs to be configured to advertise to gmetad (on the xCAT MN). The configuration can be done using postscripts.  
Place the following script under /install/postscripts. 
        
        
        # cat /install/postscripts/confGanglia
        
        #!/bin/sh
        # Post-script to customize virtual machine
        
        # Install Ganglia
        echo "Configuring Ganglia..."
        
        # Get IP address of MS
        OS=`uname`
        echo "The OS is: $OS"
        ms_ip=$MONMASTER
        result=`ping -c1 $MONMASTER 2&gt;&1`
        if [ $? -eq 0 ]; then
            index1=`expr index "$result" "\("`
            index2=`expr index "$result" "\)"`
            pos=`expr $index1 + 1`
            length=`expr $index2 - $index1`
            length=`expr $length - 1`
            ms_ip=`expr substr "$result" $pos $length`
            echo "MS IP is: $ms_ip"
        fi
        
        CLUSTER=\"$MONSERVER\"
        echo "Cluster is: $CLUSTER"
        MASTER=$ms_ip
        gmond_conf="/etc/ganglia/gmond.conf"
        gmond_conf_old="/etc/gmond.conf"
        if [ $OS != "AIX" ]; then
            if [ -f  $gmond_conf ]; then
                grep "xCAT gmond settings done" $gmond_conf
                if [ $? -gt 0 ]; then
                    /bin/cp -f $gmond_conf /etc/ganglia/gmond.conf.orig
                    sed -i 's/setuid = yes/setuid = no/1' $gmond_conf
                    sed -i 's/name = "unspecified"/name='$CLUSTER'/1' $gmond_conf
                    sed -e "1,40s/mcast_join = .*/host = $MASTER/" $gmond_conf &gt; /etc/temp.conf
                    /bin/cp -f /etc/temp.conf $gmond_conf
                    sed -i 's/mcast_join/#/g' $gmond_conf
                    sed -i 's/bind/#/g' $gmond_conf
                    echo "# xCAT gmond setup end" &gt;&gt; $gmond_conf
                fi
            fi
        fi
         
        if [ $OS != "AIX" ]; then
            if [ -f $gmond_conf_old ]; then
                grep "xCAT gmond settings done" $gmond_conf_old
                if [ $? -gt 0 ]; then
                    /bin/cp -f $gmond_conf_old /etc/gmond.conf.orig
                    sed -i 's/setuid = yes/setuid = no/1' $gmond_conf_old
                    sed -i 's/name = "unspecified"/name='$CLUSTER'/1' $gmond_conf_old
                    sed -e "1,40s/mcast_join = .*/host = $MASTER/" $gmond_conf_old &gt; /etc/temp.conf
                    /bin/cp -f /etc/temp.conf $gmond_conf_old
                    sed -i 's/mcast_join/#/g' $gmond_conf_old
                    sed -i 's/bind/#/g' $gmond_conf_old
                    echo "# xCAT gmond settings done sh_old" &gt;&gt; $gmond_conf_old
                fi 
            fi
        fi
        
        # Start gmond
        /etc/init.d/gmond start
        

  5. Give the appropriate file permissions for the script 
        
        # chmod 755 /install/postscripts/confGanglia

  6. Specify the postscript to run at install time by putting it in the postscripts table in xCAT (using `tabedit`). In the case of Ganglia, the `otherpkgs` and `confGanglia` scripts need to be run after installation. `otherpkgs` script comes packaged with xCAT and `confGanglia` script is provided above. 
        
        
        # tabdump postscripts
        
        #node,postscripts,postbootscripts,comments,disable
        "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,
        "all","otherpkgs,confGanglia",,,
        

  7. You can optionally install other packages (e.g. Ganglia) after the autoyast/kickstart installation process by using: `updatenode &lt;node&gt; otherpkgs`. The node must be online for this to work. 
        
        
        # updatenode gpok3 otherpkgs
        gpok3: Running postscript: otherpkgs
        gpok3: NFSERVER=10.1.100.1
        gpok3: OTHERPKGDIR=10.1.100.1/post/otherpkgs/sles11sp1/s390x
        gpok3: Repository 'SUSE-Linux-Enterprise-Server-11-SP1 11.1.1-1.152' is up to date.
        gpok3: Repository 'sles11sp1' is up to date.
        gpok3: All repositories have been refreshed.
        gpok3: zypper --non-interactive update --auto-agree-with-license
        gpok3: Loading repository data...
        gpok3: Reading installed packages...
        gpok3: 
        gpok3: Nothing to do.
        gpok3: rpm -Uvh --replacepkgs  libconfuse* libganglia* ganglia-gmond*
        gpok3: warning: libconfuse-2.6-1.s390x.rpm: Header V3 DSA signature: NOKEY, key ID da736c68
        gpok3: Preparing...                ##################################################
        gpok3: libconfuse                  ##################################################
        gpok3: libganglia                  ##################################################
        gpok3: ganglia-gmond               ##################################################
        gpok3: insserv: warning: script 'S11xcatpostinit1' missing LSB tags and overrides
        gpok3: insserv: warning: script 'xcatpostinit1' missing LSB tags and overrides
        gpok3: gmond                     0:off  1:off  2:off  3:on   4:off  5:on   6:off
        gpok3: Running of postscripts has completed.
        

## Cloning Virtual Servers

This section shows how to clone a virtual server running Linux. Cloning is only supported on ECKD and FBA devices. 

  
In the following example, we will clone the virtual server that we created (gpok3) in the previous section _Installing Linux Using Autoyast or Kickstart_. The new virtual server will have the node name (gpok4) and user ID (LNX4) respectively, and managed by the same zHCP (gpok2). You will need to substitute the node name, user ID, and zHCP name with appropriate values. 

  1. Logon the xCAT MN as root using a Putty terminal (if not already)
  2. The source node must be online and accessible via SSH. If it is not online, bring it online. 
        
        # rpower gpok3 on

  3. Setup the SSH keys for the source node to be cloned (if not already) 
        
        # xdsh gpok3 -K

  4. Create the table definition for new node (gpok4) 
        
        
        # mkdef -t node -o gpok4 userid=LNX4 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all
        

Set the node's IP address and hostname (only if a regex is not set for the group) 
        
        
        # chtab node=gpok4 hosts.ip="10.1.100.4" hosts.hostnames="gpok4.endicott.ibm.com"
        

  5. Update /etc/hosts 
        
        # makehosts

  6. Update DNS 
        
        # makedns

  7. Add the new node to DHCP 
        
        # makedhcp -a

  8. In order to clone a virtual server running Linux, the partition must be mounted by path. This is done by default for the node (gpok3) that we created in the previous section and in general, for nodes provision by xCAT using the default templates.  
  
For SUSE Linux Enterprise Server:  
The root directory under /etc/fstab, which contains information on the system partitions and disks, should be similar to this: 
        
        /dev/disk/by-path/ccw-0.0.0100-part1  /  ext3  acl,user_xattr  1 1

The parameters under /etc/zipl.conf, which specifies which disks to bring online when the system is IPLed, should be similar to this: 
        
        parameters = "root=/dev/disk/by-path/ccw-0.0.0100-part1 TERM=dumb"

If you happen to edit zipl.conf, you must run `zipl` after you made the changes so that changes are written to the boot record. 

  9. Clone virtual server(s) running Linux: 
        
        
        # mkvm gpok4 gpok3 pool=POOL1
        gpok4: Cloning gpok3
        gpok4: Linking source disk (0100) as (1100)
        gpok4: Stopping LNX3... Done
        
        gpok4: Creating user directory entry
        gpok4: Granting VSwitch (VSW2) access for LNX3
        gpok4: Adding minidisk (0100)
        gpok4: Disks added (1). Disks in user entry (1)
        gpok4: Linking target disk (0100) as (2100)
        gpok4: Copying source disk (1100) to target disk (2100) using FLASHCOPY
        gpok4: Mounting /dev/dasde1 to /mnt/LNX3
        gpok4: Setting network configuration
        gpok4: Powering on
        gpok4: Detatching source disk (0100) at (1100)
        gpok4: Starting LNX3... Done
        
        gpok4: Done
        

This will create a virtual server (gpok4) identical to gpok3. It will use disks in disk pool POOL1. 

If FLASHCOPY is not enabled on your z/VM system, then this will take several minutes to complete depending on the number of nodes you want to clone. Also, FLASHCOPY will not work if the disks are not on the same storage facility. 

  10. Check the boot status of the node by pinging it: 
        
        
        # pping gpok4
        gpok4: ping
        

If the node returns a ping, then it is fully booted and you can start using it. If you try to SSH into the node and are prompted for a password, you need to setup the SSH keys for each for the new nodes: 
        
        
        # xdsh gpok4 -K
        Enter the password for the userid: root on the node where the ssh keys
        will be updated:
        
        /usr/bin/ssh setup is complete.
        return code = 0
        

## Setting Up Ganglia on xCAT

This section details how to the set up Ganglia on Linux on System z. 

  


### Red Hat Enterprise Linux

If you have Red Hat Enterprise Linux, follow the instructions below. 

  1. Logon the xCAT MN as root using a Putty terminal (if not already)
  2. Go into the directory where you extracted the xcat-dep tarball, e.g. /root/xcat. Locate the Ganglia RPMs under /root/xcat/xcat-dep/&lt;os&gt;/s390x, where &lt;os&gt; is the RHEL version you are running. Verify install the following RPMs are present. 
        
        
        rrdtool-1.4.5-0.20.s390x.rpm (RHEL 5.x only)
        libconfuse-2.6-1.s390x.rpm
        libganglia-3.1.1-1.s390x.rpm
        ganglia-gmetad-3.1.1-1.s390x.rpm
        ganglia-gmond-3.1.1-1.s390x.rpm
        ganglia-web-3.1.1-1.s390x.rpm
        

  3. Set up ganglia on the xCAT MN 
    * Install PHP and apache packages (if not already). Use yast to install the following packages 
            
            # yum install apr pkgconfig php-pear php-gd httpd

    * Install the Ganglia RPMs 
            
            
            # yum install ganglia-gmetad ganglia-gmond ganglia-web
            Loaded plugins: product-id, subscription-manager
            Updating Red Hat repositories.
            Setting up Install Process
            Resolving Dependencies
            --&gt; Running transaction check
            ---&gt; Package ganglia-gmetad.s390x 0:3.1.1-1 will be installed
            ---&gt; Package ganglia-gmond.s390x 0:3.1.1-1 will be installed
            ---&gt; Package ganglia-web.s390x 0:3.1.1-1 will be installed
            --&gt; Finished Dependency Resolution
            
            Dependencies Resolved
            
            
            
            ###### ====================================================================
            
            
             Package                Arch          Version            Repository        Size
            
            
            ###### ====================================================================
            
            
            Installing:
             ganglia-gmetad         s390x         3.1.1-1            xcat-dep          39 k
             ganglia-gmond          s390x         3.1.1-1            xcat-dep         283 k
             ganglia-web            s390x         3.1.1-1            xcat-dep         112 k
            
            Transaction Summary
            
            
            ###### ====================================================================
            
            
            Install       3 Package(s)
            
            Total download size: 435 k
            Installed size: 1.2 M
            Is this ok [y/N]: y
            Downloading Packages:
            
            
            * * *
            
            
            Total                                            79 MB/s | 435 kB     00:00     
            Running rpm_check_debug
            Running Transaction Test
            Transaction Test Succeeded
            Running Transaction
              Installing : ganglia-gmetad-3.1.1-1.s390x                                 1/3 
              Installing : ganglia-web-3.1.1-1.s390x                                    2/3 
              Installing : ganglia-gmond-3.1.1-1.s390x                                  3/3 
            duration: 73(ms)
            Installed products updated.
            
            Installed:
              ganglia-gmetad.s390x 0:3.1.1-1          ganglia-gmond.s390x 0:3.1.1-1         
              ganglia-web.s390x 0:3.1.1-1            
            
            Complete!
            

    * Restart the HTTP server 
            
            
            # service httpd restart
            Stopping httpd: [  OK  ]
            Starting httpd: [  OK  ]
            

    * Restart gmond and gmetad 
            
            
            # service gmetad restart
            Shutting down GANGLIA gmetad: [FAILED]
            Starting GANGLIA gmetad: [  OK  ]
            
            # service gmond restart
            Shutting down GANGLIA gmond: [FAILED]
            Starting GANGLIA gmond: [  OK  ]
            

  4. Create the directory /install/post/otherpkgs/&lt;os&gt;/s390x on the xCAT MN, where &lt;os&gt; is the SLES version you are running 
        
        # mkdir -p /install/post/otherpkgs/&lt;os&gt;/s390x

  5. Copy the following packages from /root/xcat/xcat-dep/&lt;os&gt;/s390x into /install/post/otherpkgs/&lt;os&gt;/s390x, where &lt;os&gt; is the SLES version you are running 
        
        
        libganglia-3.1.1-1.s390x.rpm
        libconfuse-2.6-1.s390x.rpm
        ganglia-gmond-3.1.1-1.s390x.rpm
        

  6. Refer to [Adding Software Packages](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_zVM#Adding_Software_Packages) section on how to automatically install Ganglia when provisioning nodes. 

### SUSE Linux Enterprise Server

If you have SUSE Linux, follow the instructions below. 

  1. Logon the xCAT MN as root using a Putty terminal (if not already)
  2. Go into the directory where you extracted the xcat-dep tarball, e.g. /root/xcat. Locate the Ganglia RPMs under /root/xcat/xcat-dep/&lt;os&gt;/s390x, where &lt;os&gt; is the SLES version you are running. Verify install the following RPMs are present. 
        
        
        # ls /root/xcat/xcat-dep/sles11/s390x
        ...
        ganglia-devel-3.1.1-1.s390x.rpm
        ganglia-gmetad-3.1.1-1.s390x.rpm
        ganglia-gmond-3.1.1-1.s390x.rpm
        ganglia-gmond-modules-python-3.1.1-1.s390x.rpm
        ganglia-web-3.1.1-1.s390x.rpm
        libconfuse-2.6-1.s390x.rpm
        libconfuse-devel-2.6-1.s390x.rpm
        libganglia-3.1.1-1.s390x.rpm
        ...
        

  3. Set up ganglia on the xCAT MN 
    * Install PHP and apache packages (if not already). Use yast to install the following packages 
            
            # zypper install libapr1 pkgconfig php5-pear php5-gd apache2 apache2-mod_php5

    * Install the Ganglia RPMs 
            
            
            # zypper install ganglia-gmetad ganglia-gmond ganglia-web
            Loading repository data...
            Reading installed packages...
            Resolving package dependencies...
            
            The following NEW packages are going to be installed:
              ganglia-gmetad ganglia-gmond ganglia-web libconfuse libganglia rrdtool 
            
            The following packages are not supported by their vendor:
              ganglia-gmetad ganglia-gmond ganglia-web libconfuse libganglia 
            
            6 new packages to install.
            Overall download size: 981.0 KiB. After the operation, additional 3.9 MiB will 
            be used.
            Continue? [y/n/?] (y): y
            Retrieving package rrdtool-1.3.4-2.8.s390x (1/6), 478.0 KiB (1.7 MiB unpacked)
            Retrieving: rrdtool-1.3.4-2.8.s390x.rpm [done]
            Installing: rrdtool-1.3.4-2.8 [done]
            Retrieving package ganglia-web-3.1.1-1.s390x (2/6), 106.0 KiB (222.0 KiB unpacked)
            Installing: ganglia-web-3.1.1-1 [done]
            Retrieving package libconfuse-2.6-1.s390x (3/6), 102.0 KiB (468.0 KiB unpacked)
            Installing: libconfuse-2.6-1 [done]
            Retrieving package libganglia-3.1.1-1.s390x (4/6), 77.0 KiB (252.0 KiB unpacked)
            Installing: libganglia-3.1.1-1 [done]
            Retrieving package ganglia-gmetad-3.1.1-1.s390x (5/6), 67.0 KiB (188.0 KiB unpacked)
            Installing: ganglia-gmetad-3.1.1-1 [done]
            Additional rpm output:
            gmetad                    0:off  1:off  2:off  3:on   4:off  5:on   6:off
            
            
            Retrieving package ganglia-gmond-3.1.1-1.s390x (6/6), 151.0 KiB (1.1 MiB unpacked)
            Installing: ganglia-gmond-3.1.1-1 [done]
            Additional rpm output:
            gmond                     0:off  1:off  2:off  3:on   4:off  5:on   6:off
            

    * Restart the apache server 
            
            
            # service apache2 restart
            Syntax OK
            Shutting down httpd2 (waiting for all children to terminate)         done
            Starting httpd2 (prefork)            
            

    * Restart gmond and gmetad 
            
            
            # service gmond restart
            Shutting down gmond                                                  done
            Starting gmond                                                       done
            
            # service gmetad restart
            Shutting down gmetad                                                 done
            Starting gmetad                                                      done
            

  4. Create the directory /install/post/otherpkgs/&lt;os&gt;/s390x on the xCAT MN, where &lt;os&gt; is the SLES version you are running 
        
        # mkdir -p /install/post/otherpkgs/&lt;os&gt;/s390x

  5. Copy the following packages from /root/xcat/xcat-dep/&lt;os&gt;/s390x into /install/post/otherpkgs/&lt;os&gt;/s390x, where &lt;os&gt; is the SLES version you are running 
        
        
        libganglia-3.1.1-1.s390x.rpm
        libconfuse-2.6-1.s390x.rpm
        ganglia-gmond-3.1.1-1.s390x.rpm
        

  6. Refer to [Adding Software Packages](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_zVM#Adding_Software_Packages) section on how to automatically install Ganglia when provisioning nodes. 

## Ganglia Monitoring on xCAT

This section details how to use Ganglia on Linux on System z. 

  


  1. Logon the xCAT MN as root using a Putty terminal (if not already)
  2. Transfer ganglia RPMs required to run gmond over to nodes you want to monitor 
        
        
        # xdcp &lt;node&gt; /install/post/otherpkgs/&lt;os&gt;/s390x/ganglia-gmond-3.1.1-1.s390x.rpm
        # xdcp &lt;node&gt; /install/post/otherpkgs/&lt;os&gt;/s390x/libconfuse-2.6-1.s390x.rpm
        # xdcp &lt;node&gt; /install/post/otherpkgs/&lt;os&gt;/s390x/libganglia-3.1.1-1.s390x.rpm
        

The command transfers the files into /root directory on the target nodes. 

  3. Install the RPMs 
        
        
        # xdsh &lt;node&gt; rpm -i libconfuse-2.6-1.s390x.rpm
        # xdsh &lt;node&gt; rpm -i libganglia-3.1.1-1.s390x.rpm
        # xdsh &lt;node&gt; rpm -i ganglia-gmond-3.1.1-1.s390x.rpm
        

Make sure the target node has _libapr1_ (SLES) or _apr_ (RHEL) package installed. 

  4. Ensure the nodetype of all nodes you wish to monitor have the type of _osi_. This can be done by editing the nodetype table. 
        
        # tabedit nodetype

  5. Add gangliamon to the monitoring table 
        
        # monadd gangliamon

  6. Configure the node 
        
        # moncfg gangliamon -r

This runs the ganglia configuration script on all the nodes. 

  7. If you want to start gangliamon: 
        
        # monstart gangliamon -r

The command will start the gmond daemon on all the nodes. The -r flag is required to ensure the gmond daemon is started on each node. You may also specify a particular node to start: 
        
        # monstart gangliamon gpok3 -r

If you want to stop gangliamon on all nodes: 
        
        # monstop gangliamon -r

## Statelite

This section details how to configure an NFS read-only root filesystem. For more details, refer to [xCAT Linux Statelite](http://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_Linux_Statelite). Note that you can only create statelite nodes that is of the same Linux distribution as your management node. For example, if your xCAT MN is SLES 11 SP1, you can only create SLES 11 SP1 statelite nodes. 

  


### Red Hat Enterprise Linux

If you have Red Hat Linux, follow the instructions below. 

  1. Logon the xCAT MN as root using a Putty terminal (if not already)
  2. Edit /etc/exports to export the /install directory. It should look similar to this: 
        
        
        /install *(rw,no_root_squash,sync,no_subtree_check)
        /lite/state *(rw,no_root_squash,sync,no_subtree_check)
        

  3. Restart the NFS server 
        
        # service nfs restart

  4. Edit the litefile table. This table specifies which files should be kept persistent across reboots. By default, all files are kept under tmpfs, unless a persistent, ro, or bind option is specified. Refer to the litefile table description for more details. 
        
        # tabedit litefile

Copy the following defaults into the litefile table. This is the minimal list of files you need. 
        
        
        #image,file,options,comments,disable
        "ALL","/etc/adjtime",,,
        "ALL","/etc/fstab",,,
        "ALL","/etc/lvm/",,,
        "ALL","/etc/mtab","link",,
        "ALL","/etc/syslog.conf",,,
        "ALL","/etc/syslog.conf.XCATORIG",,,
        "ALL","/etc/ntp.conf",,,
        "ALL","/etc/ntp.conf.predhclient",,,
        "ALL","/etc/resolv.conf",,,
        "ALL","/etc/resolv.conf.predhclient",,,
        "ALL","/etc/ssh/","persistent",,
        "ALL","/etc/sysconfig/",,,
        "ALL","/tmp/",,,
        "ALL","/var/",,,
        "ALL","/opt/xcat/",,,
        "ALL","/xcatpost/",,,
        "ALL","/root/.ssh/",,,
        

  5. Edit the litetree table. This table controls where the files specified in the litefile table come from. 
        
        # tabedit litetree

Copy the following into the litetree table. You will need to determine the Linux distribution you want. In our example, RHEL 5.4 is used. 
        
        
        #priority,image,directory,comments,disable
        "1.0",,"10.1.100.1:/install/netboot/rhel5.4/s390x/compute",,
        

  6. Edit the statelite table. This table controls where the permanent files are kept. 
        
        # tabedit statelite

Copy the following into the statelite table. You will need to determine the statelite node range and the IP address of the xCAT MN. In our example, the node range is _all_ and the IP address is _10.1.100.1_. 
        
        
        #node,image,statemnt,comments,disable
        "all",,"10.1.100.1:/lite/state",,
        

  7. Create the persistent directory 
        
        # mkdir -p /lite/state

  8. Ensure policies are set up correctly. When a node boots up, it queries the xCAT database to get the lite-files and the lite-tree. In order for this to work, the command must be set in the policy table to allow nodes to request it. (This should already be done automatically when xCAT was installed) 
        
        
        # chtab priority=4.7 policy.commands=litefile policy.rule=allow
        # chtab priority=4.8 policy.commands=litetree policy.rule=allow
        

  9. Download and copy the packages from the Linux distro media into /install (if not already) 
        
        # copycds -n xxx -a s390x /install/yyy.iso

Substitute xxx with the distribution name and yyy with the ISO name. 

  
For example, if you have a RHEL 5.4 ISO: 
        
        # copycds -n rhel5.4 -a s390x /install/RHEL5.4-Server-20090819.0-s390x-DVD.iso

  10. Create a list of packages that should be installed onto the statelite image. You should start with the base packages in the compute template and if desired, add more packages by editing the .pkglist. 
        
        
        # mkdir -p /install/custom/netboot/rh
        # cp /opt/xcat/share/xcat/netboot/sles/compute.rhe5.s390x.pkglist
        

  11. Create the statelite image 
        
        
        # genimage -i eth1 -n qeth -o rhel5.4 -p compute
        OS: rhel5.4
        Profile: compute
        Interface: eth1
        Network drivers: qeth
        Do you need to set up other interfaces? [y/n] n
        Which kernel do you want to use? [default] [Enter]
        

This command creates a _RHEL 5.4_ image with an _eth1_ interface, _qeth_ network driver, and uses the _compute_ profile. The interface used must match the xCAT MN interface that DHCP listens on. The genimage command creates an image under /install/netboot/rhel5.4/s390x/compute/rootimg. It also creates a ramdisk and kernel that is used to boot the statelite node. 

  12. Modify the statelite image by creating symbolic links with all the files listed under the litetree table 
        
        
        # liteimg -o rhel5.4 -a s390x -p compute
        going to modify /install/netboot/rhel5.4/s390x/compute/rootimg
        creating /install/netboot/rhel5.4/s390x/compute/rootimg/.statelite
        

  13. Create the statelite node definition.  
  
For our example, we will create a new node (gpok6) with a userID (LINUX6) that is managed by our zHCP (gpok2). You will need to substitute the node names, userIDs, and zHCP name with appropriate values. 
        
        # mkdef -t node -o gpok6 userid=LINUX6 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all

  14. Update /etc/hosts 
        
        # makehosts

  15. Update DNS 
        
        # makedns

  16. Create the new virtual machine using the desired directory entry. For our example, we used the following: 
        
        
        USER LNX6 PWD 512M 1G G
        COMMAND SET VSWITCH VSW2 GRANT LNX6
        CPU 00 BASE
        CPU 01
        IPL CMS
        MACHINE ESA 4
        CONSOLE 0009 3215 T
        NICDEF 0800 TYPE QDIO LAN SYSTEM VSW2
        SPOOL 000C 2540 READER *
        SPOOL 000D 2540 PUNCH A
        SPOOL 000E 1403 A
        LINK MAINT 0190 0190 RR
        LINK MAINT 019D 019D RR
        LINK MAINT 019E 019E RR
        

To create the virtual server, copy the directory entry above into a text file (dirEntry.txt) and issue the following command (the full file path must be given): 
        
        # mkvm gpok6 /tmp/dirEntry.txt

The new virtual server should be attached to the same VSWITCH as the one used by the hardware control point (in our case, VSW2) and have the same network adapter address (in our case, 0800) for the interface given in step 12 (in our case, eth1). 

  17. Add the new node to DHCP 
        
        # makedhcp -a

  18. Set up the noderes and nodetype tables. The values of nodetype.os and nodetype.profile were determined in step 11, where the statelite image was created. 
        
        # chtab node=xxx noderes.netboot=zvm nodetype.os=yyy nodetype.arch=s390x nodetype.profile=zzz

Substitute xxx with the node name, yyy with the operating system, and zzz with the profile name. 

  
In our example, we used the following: 
        
        # chtab node=gpok6 noderes.netboot=zvm nodetype.os=rhel5.4 nodetype.arch=s390x nodetype.profile=compute

  19. Prepare the node(s) to boot from the statelite image 
        
        # nodeset xxx statelite

Substitute xxx is the node name. 

  20. Boot the statelite node(s). During this process, the symbolic links are made to files listed under the litefile table. 
        
        # rnetboot xxx ipl=00c

Substitute xxx is the node name. 

**Caution**: Do no try to boot more than 20 nodes at one time. The xCAT MN will be bogged down as all the nodes are trying to access the NFS server at once. Try booting 20 or less at a time and waiting till those nodes are pingable before booting the next batch. 

  21. Check the boot status of the node(s) by pinging them: 
        
        # pping xxx

Substitute xxx with the node name. If the node returns a ping, then it is fully booted and you can start using it. 

  22. Clone this node as many times as you want to achieve the number of statelite nodes you desire. Refer to _Cloning Virtual Servers_ section above. In order to clone, the source statelite node must be online and have SSH keys setup. Once you have completed clonning, you will have to repeat steps 17 to 20 for all the cloned nodes. 

  


### SUSE Linux Enterprise Server

If you have SUSE Linux, follow the instructions below. 

  1. Logon the xCAT MN as root using a Putty terminal (if not already)
  2. Edit /etc/exports to export the /install directory. It should contain these two directories: 
        
        
        /install *(rw,no_root_squash,sync,no_subtree_check)
        /lite/state *(rw,no_root_squash,sync,no_subtree_check)
        

  3. Restart the NFS server 
        
        # service nfsserver restart

  4. Check that the NFS server is running 
        
        # rpcinfo -p

Make sure nfs is listed, e.g. 
        
        
        100003 2 tcp 2049 nfs
        100003 2 tcp 2049 nfs
        100003 3 tcp 2049 nfs
        100003 4 tcp 2049 nfs
        100003 2 udp 2049 nfs
        100003 3 udp 2049 nfs
        100003 4 udp 2049 nfs
        

  5. Edit the litefile table. This table specifies which files should be kept persistent across reboots. By default, all files are kept under tmpfs, unless a persistent, ro, or link option is specified. Refer to the litefile table description for more details. 
        
        
        # tabedit litefile
        

Copy the following defaults into the litefile table. This is the minimal list of files you need. 
        
        
        #image,file,options,comments,disable
        "ALL","/etc/lvm/",,,
        "ALL","/etc/mtab","link",,
        "ALL","/etc/ntp.conf",,,
        "ALL","/etc/ntp.conf.org",,,
        "ALL","/etc/resolv.conf",,,
        "ALL","/etc/ssh/","persistent",,
        "ALL","/etc/sysconfig/",,,
        "ALL","/etc/syslog-ng/",,,
        "ALL","/tmp/",,,
        "ALL","/var/",,,
        "ALL","/etc/yp.conf",,,
        "ALL","/etc/fstab",,,
        "ALL","/opt/xcat/",,,
        "ALL","/xcatpost/",,,
        "ALL","/root/.ssh/",,,
        

  6. Edit the litetree table. This table controls where the files specified in the litefile table come from. 
        
        # tabedit litetree

  7. Copy the following into the litetree table. You will need to determine the Linux distribution you want. In our example, SLES11 SP1 is used. 
        
        
        #priority,image,directory,comments,disable
        "1.0",,"10.1.100.1:/install/netboot/sles11sp1/s390x/compute",,
        

  8. Edit the statelite table. This table controls where the permanent files are kept. 
        
        # tabedit statelite

Copy the following into the statelite table. You will need to determine the statelite node range and the IP address of the xCAT MN. In our example, the node range is _all_ and the IP address is _10.1.100.1_. 
        
        
        #node,image,statemnt,comments,disable
        "all",,"10.1.100.1:/lite/state",,
        

  9. Create the persistent directory 
        
        # mkdir -p /lite/state

  10. Ensure policies are set up correctly. When a node boots up, it queries the xCAT database to get the lite-files and the lite-tree. In order for this to work, the command must be set in the policy table to allow nodes to request it. (This should already be done automatically when xCAT was installed) 
        
        
        # chtab priority=4.7 policy.commands=litefile policy.rule=allow
        # chtab priority=4.8 policy.commands=litetree policy.rule=allow
        

  11. Download and copy the packages from the Linux distro media into /install (if not already) 
        
        # copycds -n xxx -a s390x /install/yyy.iso

Substitute xxx with the distribution name and yyy with the ISO name. 

  
For example, if you have a SLES 11 SP1 ISO: 
        
        # copycds -n sles11sp1 -a s390x /install/SLES-11-SP1-DVD-s390x-GMC3-DVD1.iso

  12. Create a list of packages that should be installed onto the statelite image. You should start with the base packages in the compute template and if desired, add more packages by editing the .pkglist. 
        
        
        # mkdir -p /install/custom/netboot/sles
        # cp /opt/xcat/share/xcat/netboot/sles/compute.sles11.s390x.pkglist /install/custom/netboot/sles
        

  13. Create the statelite image 
        
        
        # genimage -i eth1 -n qeth -o sles11sp1 -p compute
        OS: sles11sp1
        Profile: compute
        Interface: eth1
        Network drivers: qeth
        Do you need to set up other interfaces? [y/n] n
        Which kernel do you want to use? [default] [Enter]
        

This command creates a _SLES11 SP1_ image with an _eth1_ interface, _qeth_ network driver, and uses the _compute_ profile. The interface used must match the xCAT MN interface that DHCP listens on. The genimage command creates an image under /install/netboot/sles11sp1/s390x/compute/rootimg. It also creates a ramdisk and kernel that is used to boot the statelite node. 

  14. Modify the statelite image by creating symbolic links with all the files listed under the litetree table 
        
        
        # liteimg -o sles11sp1 -a s390x -p compute
        going to modify /install/netboot/sles11sp1/s390x/compute/rootimg
        creating /install/netboot/sles11sp1/s390x/compute/rootimg/.statelite
        

  15. Create the statelite node definition.  
For our example, we will create a new node (gpok6) with a userID (LNX6) that is managed by our zHCP (gpok2). You will need to substitute the node names, userIDs, and zHCP name with appropriate values. 
        
        # mkdef -t node -o gpok6 userid=LINUX6 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all

  16. Update /etc/hosts 
        
        # makehosts

  17. Update DNS 
        
        # makedns

  18. Create the new virtual server using the desired directory entry. For our example, we used the following: 
        
        
        USER LNX6 PWD 512M 1G G
        COMMAND SET VSWITCH VSW2 GRANT LNX6
        CPU 00 BASE
        CPU 01
        IPL CMS
        MACHINE ESA 4
        CONSOLE 0009 3215 T
        NICDEF 0800 TYPE QDIO LAN SYSTEM VSW2
        SPOOL 000C 2540 READER *
        SPOOL 000D 2540 PUNCH A
        SPOOL 000E 1403 A
        LINK MAINT 0190 0190 RR
        LINK MAINT 019D 019D RR
        LINK MAINT 019E 019E RR
        

To create the virtual server, copy the directory entry above into a text file (dirEntry.txt) and issue the following command (the full file path must be given): 
        
        
        # mkvm gpok6 /tmp/dirEntry.txt
        

The new virtual server should be attached to the same vswitch as the one used by the hardware control point (in our case, VSW2) and have the same network adapter address (in our case, 0800) for the interface given in step 12 (in our case, eth1). 

  19. Add the new node to DHCP 
        
        # makedhcp -a

  20. Set up the noderes and nodetype tables. The values of nodetype.os and nodetype.profile were determined in step 11, where the statelite image was created. 
        
        # chtab node=xxx noderes.netboot=zvm nodetype.os=yyy nodetype.arch=s390x nodetype.profile=zzz

Substitute xxx with the node name, yyy with the operating system, and zzz with the profile name. 

  
In our example, we used the following: 
        
        # chtab node=gpok6 noderes.netboot=zvm nodetype.os=sles11sp1 nodetype.arch=s390x nodetype.profile=compute

  21. Prepare the node(s) to boot from the statelite image 
        
        # nodeset xxx statelite

where xxx is the node name. 

  22. Boot the statelite node(s). During this process, the symbolic links are made to files listed under the litefile table. 
        
        # rnetboot xxx ipl=00c

where xxx is the node name. 

  
Caution: Do no try to boot more than 20 nodes at one time. The xCAT MN will be bogged down as all the nodes are trying to access the NFS server at once. Try booting 20 or less at a time and waiting till those nodes are pingable before booting the next batch. 

  23. Check the boot status of the nodes by pinging them: 
        
        # pping xxx

Substitute xxx with the node name. If the node returns a ping, then it is fully booted and you can start using it. 

  24. Clone this node as many times as you want to achieve the number of statelite nodes you desire. Refer to _Cloning Virtual Servers_ section above. In order to clone, the source statelite node must be online and have SSH keys setup. Once you have completed clonning, you will have to repeat steps 19 to 22 for all the cloned nodes. 

## Updating Linux

This section details how to update the Linux operating system. 

  


  1. Download and extract the ISO into the xCAT install tree /install (if not already) 
        
        # copycds -n xxx -a s390x /install/yyy.iso

Substitute xxx with the distribution name and yyy with the ISO name. 

  
For example, if you have a SUSE Linux Enterprise Server 10 SP3 ISO: 
        
        
        # copycds -n sles10sp3 -a s390x /install/SLES-10-SP3-DVD-s390x-DVD1.iso
        Copying media to /install/sles10sp3/s390x/1
        Media copy operation successful
        

or if you have a Red Hat Enterprise Linux 5.4 ISO: 
        
        
        # copycds -n rhel5.4 -a s390x /install/RHEL5.4-Server-20090819.0-s390x-DVD.iso
        Copying media to /install/rhel5.4/s390x
        Media copy operation successful
        

  2. Update the node 
        
        # updatenode xxx -o yyy

Substitute xxx with the node name and yyy with the operating system version. 

  
For example, if you want to update gpok5 to RHEL5.4 (assuming gpok5 has RHEL 5.3): 
        
        # updatenode gpok5 -o rhel5.4

The command requires the node to be online. It will take several minutes to complete the update. You can only update to the next release. For example, you can only update RHEL5.3 to RHEL5.4. You cannot skip releases, e.g. updating RHEL5.3 to RHEL5.5. 

  
**Warning**: You cannot update SLES10.3 to SLES11. There is a bug in `rug` where you cannot add a repository/service. 

## Limitations

This section highlights the limitations of xCAT on z/VM and Linux on System z. 

  


  1. xCAT is only supported on z/VM 5.4 or newer. 
  2. zHCP is only supported on RHEL 5.4 or newer, and SLES 10 SP2 or newer. 
  3. The default autoyast and kickstart templates available on xCAT was tested on SLES 10.2/10.3/11/11.1/11.2 and RHEL 5.3/5.4/5.5/6.0/6.1/6.2. 
  4. Cloning LVM volumes is supported. However, it is not supported on nodes where the root file system is on an LVM volume. 
  5. CP Flashcopy is only supported on ECKD volumes. These volumes must be on the same storage facility. 
  6. Statelite is only supported on SLES 11 or newer, and RHEL 5.4 or newer. 
  7. Nodes that the zHCP manages must have the Linux VMCP module. 
  8. A layer 2 VSWITCH is required for DHCP. 
  9. In order for the xCAT MN to manage across multiple LPARs and CECs, you must use a layer 2 VSWITCH. The network hardware must be configured in such a way that these VSWITCHes can communicate across multiple LPARs and CECs. 

## Appendix A: Setting Up a Second Network

This section details how to setup a second network based on a layer 2 VSWITCH. 

  


### Red Hat Enterprise Linux

SSH to the desire Linux where you want to setup the private network. A network script must be added under /etc/sysconfig/network-scripts/ to let the system know about the new interface and a qeth group must be created under /sys/bus/ccwgroup/drivers/qeth/group. 

  
In the following example, we will configure an ethernet interface (_eth1_) for a layer 2 VSWITCH (_VSW2_) attached to _0800_. We will assume there is an existing ethernet interface (_eth0_) for a network card attached to _0600_. 

  
Copy the hardware settings from the existing network /etc/sysconfig/network-scripts/ifcfg-eth0. 
    
    # cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth1
    

  
Edit the network settings. 
    
    # vi /etc/sysconfig/network-scripts/ifcfg-eth1
    

It should look similar to the following: 
    
    # IBM QETH
    DEVICE=eth1
    ARP=no
    BOOTPROTO=static
    BROADCAST=10.1.100.255
    IPADDR=10.1.100.1
    IPV6INIT=yes
    IPV6_AUTOCONF=yes
    MTU=1500
    NETMASK=255.255.255.0
    NETTYPE=qeth
    NETWORK=10.1.100.0
    ONBOOT=yes
    PORTNAME=PORT800
    OPTIONS="layer2=1"
    SUBCHANNELS=0.0.0800,0.0.0801,0.0.0802
    

You need to substitute the broadcast, IP address, netmask, network, port name, and subchannels with appropriate values. If you have a layer 3 device, set OPTIONS="layer2=0". 

  
Load the qeth driver 
    
    # modprobe qeth
    

  
Create a qeth group device 
    
    # echo 0.0.0800,0.0.0801,0.0.0802 &gt; /sys/bus/ccwgroup/drivers/qeth/group
    

  
Declare the qeth group device as Layer 2 
    
    # echo 1 &gt; /sys/bus/ccwgroup/drivers/qeth/0.0.0800/layer2
    

  
Bring the device back online (you need to reset the device after each reboot) 
    
    # echo 1 &gt; /sys/bus/ccwgroup/drivers/qeth/0.0.0800/online
    

  
Verify the state of the device (1 = online) 
    
    # cat /sys/bus/ccwgroup/drivers/qeth/0.0.0800/online
    

  
Check to see what interface name was assigned to the device 
    
    # cat /sys/bus/ccwgroup/drivers/qeth/0.0.0800/if_name
    

  
A qeth device requires an alias definition in /etc/modprobe.conf. Edit this file and add an alias for your interface. (This action is not necessary in RHEL 6) 
    
    # vi /etc/modprobe.conf
    
    
    alias eth0 qeth
    alias eth1 qeth
    options dasd_mod dasd=0.0.0100,0.0.0103,0.0.0300,0.0.0301
    

  
Start the new interface 
    
    # ifup eth1
    

### SUSE Linux Enterprise Server 10

SSH to the desire Linux where you want to setup the private network. Two configuration files must be added under /etc/sysconfig/ to let the system know about the new interface, one for hardware and one for network settings. 

  
In the following example, we will configure an ethernet interface (_eth1_) for a layer 2 VSWITCH (_VSW2_) attached to _0800_. We will assume there is an existing ethernet interface (_eth0_) for a network card attached to _0600_. 

  
Copy the hardware settings from the existing network /etc/sysconfig/hardware/hwcfg-qeth-bus-ccw-0.0.0600. Both interfaces will use the qdio/qeth drivers, therefore, the configuration files can be identical except for the virtual addresses. The existing file is copied to specify the new NIC. The only difference needed is to change the _060X_ values to _080X_. 
    
    # cd /etc/sysconfig/hardware/
    

Edit the hardware settings. 
    
    # sed *600 -e 's/060/080/g' &gt; hwcfg-qeth-bus-ccw-0.0.0800
    

It should look similar to the following: 
    
    STARTMODE="auto"
    MODULE="qeth"
    MODULE_OPTIONS=""
    MODULE_UNLOAD="yes"
    SCRIPTUP="hwup-ccw"
    SCRIPTUP_ccw="hwup-ccw"
    SCRIPTUP_ccwgroup="hwup-qeth"
    SCRIPTDOWN="hwdown-ccw"
    CCW_CHAN_IDS="0.0.0800 0.0.0801 0.0.0802"
    CCW_CHAN_NUM="3"
    CCW_CHAN_MODE="OSAPORT"
    QETH_LAYER2_SUPPORT="1"
    

  
Copy the network settings from the existing network /etc/sysconfig/network/ifcfg-qeth-bus-ccw-0.0.0600. 
    
    # cd /etc/sysconfig/network
    # cp ifcfg-qeth-bus-ccw-0.0.0600 ifcfg-qeth-bus-ccw-0.0.0800
    

  
Edit the network settings. 
    
    # vi ifcfg-qeth-bus-ccw-0.0.0800
    

It should look similar to the following: 
    
    BOOTPROTO="static"
    UNIQUE=""
    STARTMODE="onboot"
    IPADDR="10.1.100.1"
    NETMASK="255.255.255.0"
    NETWORK="10.1.100.0"
    BROADCAST="10.1.100.255"
    _nm_name='qeth-bus-ccw-0.0.0800'
    

You need to substitute the broadcast, IP address, netmask, and network with appropriate values. 

  
Reboot the virtual server to have the changes take effect. 
    
    # reboot
    

  


### SUSE Linux Enterprise Server 11

SSH to the desire Linux where you want to setup the private network. A configuration file must be added under /etc/sysconfig/network and /etc/udev/rules.d to let the system know about the new interface. 

  
In the following example, we will configure an ethernet interface (_eth1_) for a layer 2 VSWITCH (_VSW2_) attached to _0800_. We will assume there is an existing ethernet interface (_eth0_) for a network card attached to _0600_. 

  
Copy the hardware settings from the existing network /etc/udev/rules.d/51-qeth-0.0.0600.rules. Both interfaces will use the qdio/qeth drivers, therefore, the configuration files can be identical except for the virtual addresses. The existing file is copied to specify the new NIC. The only difference needed is to change the _060X_ values to _080X_. 
    
    # sed /etc/udev/rules.d/51-qeth-0.0.0600.rules -e 's/060/080/g' &gt; /etc/udev/rules.d/51-qeth-0.0.0800.rules
    

Edit the udev rules 
    
    # vi /etc/udev/rules.d/51-qeth-0.0.0800.rules
    

It should look similar to the following: 
    
    # Configure qeth device at 0.0.0800/0.0.0801/0.0.0802
    ACTION=="add", SUBSYSTEM=="drivers", KERNEL=="qeth", IMPORT{program}="collect 0.0.0800 %k 0.0.0800 0.0.0801 0.0.0802 qeth"
    ACTION=="add", SUBSYSTEM=="ccw", KERNEL=="0.0.0800", IMPORT{program}="collect 0.0.0800 %k 0.0.0800 0.0.0801 0.0.0802 qeth"
    ACTION=="add", SUBSYSTEM=="ccw", KERNEL=="0.0.0801", IMPORT{program}="collect 0.0.0800 %k 0.0.0800 0.0.0801 0.0.0802 qeth"
    ACTION=="add", SUBSYSTEM=="ccw", KERNEL=="0.0.0802", IMPORT{program}="collect 0.0.0800 %k 0.0.0800 0.0.0801 0.0.0802 qeth" TEST=="[ccwgroup/0.0.0800]", GOTO="qeth-0.0.0800-end"
    ACTION=="add", SUBSYSTEM=="ccw", ENV{COLLECT_0.0.0800}=="0", ATTR{[drivers/ccwgroup:qeth]group}="0.0.0800,0.0.0801,0.0.0802"
    ACTION=="add", SUBSYSTEM=="drivers", KERNEL=="qeth", ENV{COLLECT_0.0.0800}=="0", ATTR{[drivers/ccwgroup:qeth]group}="0.0.0800,0.0.0801,0.0.0802" LABEL="qeth-0.0.0800-end"
    ACTION=="add", SUBSYSTEM=="ccwgroup", KERNEL=="0.0.0800", ATTR{portname}="OSAPORT"
    ACTION=="add", SUBSYSTEM=="ccwgroup", KERNEL=="0.0.0800", ATTR{portno}="0"
    ACTION=="add", SUBSYSTEM=="ccwgroup", KERNEL=="0.0.0800", ATTR{layer2}="1"
    ACTION=="add", SUBSYSTEM=="ccwgroup", KERNEL=="0.0.0800", ATTR{online}="1"
    

You must also enable layer2 for the device. Take note of `ATTR{layer2}="1"`. 

  
Copy the network settings from the existing network /etc/sysconfig/network/ifcfg-eth0. 
    
    # cp /etc/sysconfig/network/ifcfg-eth0 /etc/sysconfig/network/ifcfg-eth1
    

Edit the network settings. 
    
    # vi /etc/sysconfig/network/ifcfg-eth1
    

It should look similar to the following: 
    
    BOOTPROTO='static'
    IPADDR='10.1.100.1'
    BROADCAST='10.1.100.255'
    NETMASK='255.255.255.0'
    NETWORK='10.1.100.0'
    STARTMODE='onboot'
    NAME='OSA Express Network card (0.0.0800)'
    

  
Reboot the virtual server to have the changes take effect. 
    
    # reboot
    

## Appendix B: Customizing Autoyast and Kickstart

This section details how to customize the autoyast and kickstart templates. It should only serve as a quick guide on configuring the templates. It is beyond the scope of this document to go into details on configuring autoyast and kickstart. You need to go to the links provided below to get more information. 

  
Autoyast and kickstart allows you to customize a Linux system based on a template. While you would typically go through various panels to manually customize your Linux system during boot, you no longer have to with autoyast and kickstart. This allows you to configure a vanilla Linux system faster and more effectively. 

  


### Red Hat Enterprise Server

  1. Base your customization on the default template (compute.rhel5.s390x.tmpl) in /opt/xcat/share/xcat/install/rh/. This template is configured to setup the network for you using DHCP.
  2. Determine the number of disks (ECKD or SCSI) your vanilla system will have and the mount points for each disk. Note that there are no extra steps needed to specify the disk type.
  3. Copy the default template /opt/xcat/share/xcat/install/rh/xxx.tmpl, where xxx is the template name, into /install/custom/install/rh/. For our example, we will use compute.rhel5.s390x.tmpl: 
        
        # cp /opt/xcat/share/xcat/install/rh/compute.rhel5.s390x.tmpl /install/custom/install/rh/custom.rhel5.s390x.tmpl

The default templates are configured to use one 3390-mod9 with the root filesystem (/) mounted, install the base software package, and use DHCP. You can use it as a starting point and customize the disks, partitioning, install packages, and network configuration. 

  4. Add this template to the osimage table. For our example, we customized the kickstart template for RHEL 5.4 and added it to the osimage table using: 
        
        # chtab imagename=rhel5.4-s390x-install-custom osimage.profile=custom osimage.imagetype=linux osimage.provmethod=install osimage.osname=Linux osimage.osvers=rhel5.4 osimage.osarch=s390x

  5. Add the disk and mount point to the template using the following format: 
        
        
        clearpart --initlabel --drives=dasda,dasdb
        part / --fstype ext3 --size=100 --grow  --ondisk=dasda
        part /usr --fstype ext3 --size=100 --grow  --ondisk=dasdb
        

In the example above, a disk is added with a device name of _dasdb_. The disk will be mounted at _/usr_ and will have a _ext3_ file system. 

  6. If you want to assign a static IP address to the system, edit the network option so that it is similar to the one below. 
        
        
        network --bootproto=static --ip=replace_ip --netmask=replace_netmask --gateway=replace_gateway --nameserver=replace_nameserver --hostname=replace_hostname
        

During nodeset, xCAT will replace the placeholders (replace_*) with the appropriate values for the system. 

  7. Add the software you need to the `%packages` section.

  
For more information, refer to [Red Hat Enterprise Linux Installation Guide](http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/ch-kickstart2.html). 

### SUSE Linux Enterprise Server

An autoyast generator is available for SLES 10 and SLES 11. It will help create an autoyast template with the desired DASD, partition layout, and software. It will create an autoyast template that can be consumed by xCAT. For more advance configurations (e.g. LDAP), the autoyast template has to be configured manually. 

To generate an autoyast template: 

  1. Run mkay4z script under /opt/xcat/share/xcat/tools 
        
        
        # /opt/xcat/share/xcat/tools/mkay4z
        
        Creating autoyast template for Linux on System z...
        Select SUSE Linux Enterprise Server version? (10 or 11) 11
        Where do you want to place the template? (e.g. /tmp/custom.sles11.s390x.tmpl) /tmp/custom.sles11.s390x.tmpl
          Do you want to use DHCP? (yes or no) y
        
        CONFIGURING DASD...
        Select from the following options:
          (1) Add DASD
          (2) Remove DASD
          (3) Show DASD configuration
          (4) Go to next step
        1
          What is the virtual address? 100
          What is the type? (eckd or fba) eckd
        Select from the following options:
          (1) Add DASD
          (2) Remove DASD
          (3) Show DASD configuration
          (4) Go to next step
        1
          What is the virtual address? 101
          What is the type? (eckd or fba) eckd
        Select from the following options:
          (1) Add DASD
          (2) Remove DASD
          (3) Show DASD configuration
          (4) Go to next step
        4
        
        CONFIGURING PARTITIONS...
        Select a device from the list below to create a new partition.
        #  |   Device   |   Address   |   Type   
        
        
        * * *
        
        
        0   /dev/dasda   0.0.0100      dasd_eckd_mod
        1   /dev/dasdb   0.0.0101      dasd_eckd_mod
        Which device do you want to configure? (See list above)
        Leave blank and hit Enter to go to next step.
        0
          What is the filesystem for /dev/dasda? (ext2, ext3, ext4, or swap) ext4
          What is the partition size? (e.g. 1g, 2g, or max) max
          Do you want to assign it to an LVM group? (yes or no) n
          What is the mount point? /
        Which device do you want to configure? (See list above)
        Leave blank and hit Enter to go to next step.
        1
          What is the filesystem for /dev/dasdb? (ext2, ext3, ext4, or swap) ext4
          What is the partition size? (e.g. 1g, 2g, or max) max
          Do you want to assign it to an LVM group? (yes or no) n
          What is the mount point? /opt
        Which device do you want to configure? (See list above)
        Leave blank and hit Enter to go to next step.
        
        Done! See autoyast template under /tmp/custom.sles11.s390x.tmpl
        

The script will ask you several questions concerning the configuration in the autoyast template. It is designed to help you configure the disks, partitions, and networking in the autoyast template for xCAT. It is important to note that the template name is significant. The name should be in the following order: &lt;profile&gt;.&lt;osvers&gt;.s390x.tmpl. For more advanced configurations, you should manually edit the autoyast template. 

  2. Place the custom template generated by the mkay4z script under /install/custom/install/sles/. 
        
        
        # mv /tmp/custom.sles11.s390x.tmpl /install/custom/install/sles/
        

  3. The custom template will need an associated package list. Copy an existing package list, e.g. compute.sles11.s390x.pkglist, and make appropriate modifications. 
        
        
        # cp /install/custom/install/sles/compute.sles11.s390x.pkglist /install/custom/install/sles/custom.sles11.s390x.pkglist
        

Note that the name of the package list must match the template profile name. 

  4. Add this template to the osimage table. For our example, we customized the autoyast template for SLES 11 SP1 and added it to the osimage table using: 
        
        # chtab imagename=sles11sp1-s390x-install-custom osimage.profile=custom osimage.imagetype=linux osimage.provmethod=install osimage.osname=Linux osimage.osvers=sles11sp1 osimage.osarch=s390x

For more information, refer to [openSUSE AutoYast](http://www.suse.de/~ug/autoyast_doc/index.html). 

## Appendix C: Setting up Network Address Translation

This section details how to setup network address translation (NAT) on a Linux host. NAT supports both layer 2 and 3 network devices. The setup below uses iptables and port forwarding to allow hosts on a private network to gain access to a public network. It is important to note that the Linux host must have both external (public) and internal (private) interfaces. NAT will route packets appropriately between the public and private networks using iptables. It is also important to note that a host on the private network cannot be reached via the public network because it does not have a unique public IP address. However, this can be solved by assigning a unique port number on the Linux host (setup with NAT), so that packets sent to this port will be forwarding to the private host. 

### Red Hat Enterprise Server

This section details how to setup NAT on Red Hat Enterprise Server. It is assumed that the Linux host (10.1.100.1) already has both external and internal interfaces. The external interface (eth0) is on the 9.10.11.0/24 network. The internal interface (eth1) is on the 10.1.100.0/24 network. 

  1. Allow forwarding for the internal interface (eth1) 
        
        # iptables --append FORWARD --in-interface eth1 -j ACCEPT

  2. Allow hosts on the private network to mask requests using the public IP address of the Linux host 
        
        # iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE 

  3. Edit /etc/sysctl.conf and enable IP forwarding with the following setting 
        
        net.ipv4.ip_forward = 1

  4. Update the system configuration to enable IP forwarding 
        
        
        # sysctl -p /etc/sysctl.conf
        net.ipv4.ip_forward = 1
        net.ipv4.conf.default.rp_filter = 1
        net.ipv4.conf.default.accept_source_route = 0
        

  5. Allow appropriate services through the firewall. For example, allow SSH (port 22) through the firewall. 
        
        # iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 

  6. If you want a host (10.1.100.123) on the private network to be accessed publicly via SSH (port 22), you can forwarding the SSH request with the following command 
        
        
        # iptables -A PREROUTING -i eth+ -p tcp -m tcp --dport 2123 -j DNAT --to-destination 10.1.100.123:22
        # iptables -A FORWARD -d 10.1.100.123/32 -i eth+ -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
        

Any request coming through port 2123 will be forwarded to the host on port 22 on the private network. It is important to note that the port number used must be free and not in use by any other service. 

  7. Publicly access the host on the private network 
        
        # ssh root@10.1.100.1 -p 2123

  8. Verify the NAT configuration by logging into a host (10.1.100.123) on the private network and accessing an external site from that host 
        
        
        # ifconfig
        eth0      Link encap:Ethernet  HWaddr 02:00:01:FF:FE:FD  
                  inet addr:10.1.100.123  Bcast:10.1.100.255  Mask:255.255.255.0
                  inet6 addr: fd55:faaf:e1ab:263:0:6ff:feff:fefd/64 Scope:Global
                  inet6 addr: fe80::6ff:feff:fefd/64 Scope:Link
                  UP BROADCAST RUNNING MULTICAST  MTU:1492  Metric:1
                  RX packets:261657 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:314748 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000 
                  RX bytes:103074088 (98.2 Mb)  TX bytes:27570328 (26.2 Mb)
        
        lo        Link encap:Local Loopback  
                  inet addr:127.0.0.1  Mask:255.0.0.0
                  inet6 addr: ::1/128 Scope:Host
                  UP LOOPBACK RUNNING  MTU:16436  Metric:1
                  RX packets:29 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:29 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:7060 (6.8 Kb)  TX bytes:7060 (6.8 Kb)
        
        # ping -c 4 sourceforge.net
        PING sourceforge.net (216.34.181.60) 56(84) bytes of data.
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=1 ttl=236 time=30.2 ms
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=2 ttl=236 time=30.6 ms
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=3 ttl=236 time=30.0 ms
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=4 ttl=236 time=29.9 ms
        
        --- sourceforge.net ping statistics ---
        4 packets transmitted, 4 received, 0% packet loss, time 3004ms
        rtt min/avg/max/mdev = 29.908/30.224/30.666/0.357 ms
        

If the host cannot reach the external site, make sure that the gateway for the default route goes to the Linux host (10.1.100.1/gpok1) you had setup with NAT. 
        
        
        # route
        Kernel IP routing table
        Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
        10.1.100.0      *               255.255.255.0   U     0      0        0 eth0
        link-local      *               255.255.0.0     U     0      0        0 eth0
        loopback        *               255.0.0.0       U     0      0        0 lo
        default         gpok1.endicott. 0.0.0.0         UG    0      0        0 eth0
        

For more information, refer to [Red Hat Enterprise Linux 6 Security Guide](http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Security_Guide/sect-Security_Guide-Firewalls-FORWARD_and_NAT_Rules.html). 

### SUSE Linux Enterprise Server

This section details how to setup NAT on SUSE Linux Enterprise Server. It is assumed that the Linux host (10.1.100.1) already has both external and internal interfaces. The external interface (eth0) is on the 9.10.11.0/24 network. The internal interface (eth1) is on the 10.1.100.0/24 network. 

  1. Enable the SuSEfirewall2 boot scripts 
        
        
        # chkconfig SuSEfirewall2_init on
        # chkconfig SuSEfirewall2_setup on
        

  2. Edit /etc/sysconfig/SuSEfirewall2 such that it contains the following configurations 
        
        
        # Space separated interfaces that point to the internet
        FW_DEV_EXT="any eth0"
        
        # Space separated interfaces that point to the internal network
        FW_DEV_INT="eth1"
        
        # Activate routing between internet and internal network
        FW_ROUTE="yes"
        
        # Masquerade internal networks to the outside
        FW_MASQUERADE="yes"
        
        # Interfaces to masquerade on
        FW_MASQ_DEV="zone:ext"
        
        # Unrestricted access to the internet
        FW_MASQ_NETS="0/0"
        
        # Any internal user can connect any service on the firewall
        FW_PROTECT_FROM_INT="no"
        
        # Services on the firewall that should be accessible from untrusted networks
        FW_CONFIGURATIONS_EXT="apache2 apache2-ssl bind dhcp-server sshd vsftpd xorg-x11-server"
        
        # Services accessed from the internet should be allowed to masqueraded servers (on the internal network)
        FW_FORWARD_MASQ="0/0,10.1.100.123,tcp,2123,22"
        
        # Allow the firewall to reply to icmp echo requests
        FW_ALLOW_PING_FW="yes"
        

If you want a host (10.1.100.123) on the private network to be accessed publicly via SSH (port 22), you can forward the SSH request with the FW_FORWARD_MASQ option. Any request coming through port 2123 will be forwarded to the host on port 22 on the private network. It is important to note that the port number used must be free and not in use by any other service. 

It is important to note that the interfaces that point to the internet (FW_DEV_EXT), and interfaces that point to the internal network (FW_DEV_INT) need to be set correctly. If they are not set correctly, you will have problems provisioning using xCAT. 

  3. Restart SuSEfirewall2 and load the configuration 
        
        
        # SuSEfirewall2 stop; SuSEfirewall2 start
        SuSEfirewall2: batch committing...
        SuSEfirewall2: Firewall rules unloaded.
        SuSEfirewall2: Setting up rules from /etc/sysconfig/SuSEfirewall2 ...
        SuSEfirewall2: batch committing...
        SuSEfirewall2: Firewall rules successfully set
        

  4. Verify the NAT configuration by logging into a host (10.1.100.123) on the private network and accessing an external site from that host 
        
        
        # ifconfig
        eth0      Link encap:Ethernet  HWaddr 02:00:01:FF:FE:FD  
                  inet addr:10.1.100.123  Bcast:10.1.100.255  Mask:255.255.255.0
                  inet6 addr: fd55:faaf:e1ab:263:0:6ff:feff:fefd/64 Scope:Global
                  inet6 addr: fe80::6ff:feff:fefd/64 Scope:Link
                  UP BROADCAST RUNNING MULTICAST  MTU:1492  Metric:1
                  RX packets:261657 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:314748 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000 
                  RX bytes:103074088 (98.2 Mb)  TX bytes:27570328 (26.2 Mb)
        
        lo        Link encap:Local Loopback  
                  inet addr:127.0.0.1  Mask:255.0.0.0
                  inet6 addr: ::1/128 Scope:Host
                  UP LOOPBACK RUNNING  MTU:16436  Metric:1
                  RX packets:29 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:29 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:7060 (6.8 Kb)  TX bytes:7060 (6.8 Kb)
        
        # ping -c 4 sourceforge.net
        PING sourceforge.net (216.34.181.60) 56(84) bytes of data.
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=1 ttl=236 time=30.1 ms
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=2 ttl=236 time=30.3 ms
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=3 ttl=236 time=31.2 ms
        64 bytes from ch3.sourceforge.net (216.34.181.60): icmp_seq=4 ttl=236 time=30.3 ms
        
        --- sourceforge.net ping statistics ---
        4 packets transmitted, 4 received, 0% packet loss, time 3004ms
        rtt min/avg/max/mdev = 30.134/30.514/31.278/0.447 ms
        

If the host cannot reach the external site, make sure that the gateway for the default route goes to the Linux host (10.1.100.1/gpok1) you had setup with NAT. 
        
        
        # route
        Kernel IP routing table
        Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
        10.1.100.0      *               255.255.255.0   U     0      0        0 eth0
        link-local      *               255.255.0.0     U     0      0        0 eth0
        loopback        *               255.0.0.0       U     0      0        0 lo
        default         gpok1.endicott. 0.0.0.0         UG    0      0        0 eth0
        

For more information, refer to [openSUSE Security](http://doc.opensuse.org/documentation/html/openSUSE/opensuse-security/cha.security.firewall.html). 
