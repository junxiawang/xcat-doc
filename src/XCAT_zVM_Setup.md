<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Document Abstract](#document-abstract)
- [Terminology](#terminology)
- [Support on z/VM and Linux on System z](#support-on-zvm-and-linux-on-system-z)
- [Design Architecture](#design-architecture)
- [Prerequisite](#prerequisite)
  - [xCAT Management Node](#xcat-management-node)
  - [System z Hardware Control Point](#system-z-hardware-control-point)
- [Planning](#planning)
- [Installation of xCAT](#installation-of-xcat)
  - [Red Hat Enterprise Linux](#red-hat-enterprise-linux)
  - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server)
  - [Finalizing Installation](#finalizing-installation)
- [Installation of xCAT UI](#installation-of-xcat-ui)
  - [Red Hat Enterprise Linux](#red-hat-enterprise-linux-1)
  - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server-1)
  - [SSL Configuration](#ssl-configuration)
    - [Red Hat Enterprise Linux](#red-hat-enterprise-linux-2)
    - [SUSE Linux Enterprise Server](#suse-linux-enterprise-server-2)
- [Installation of zHCP](#installation-of-zhcp)
  - [Configuring z/VM, SMAPI, and DirMaint](#configuring-zvm-smapi-and-dirmaint)
  - [Configuring zHCP](#configuring-zhcp)
- [Initializing Database](#initializing-database)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Document Abstract

This document provides an overview and an installation guide for xCAT on z/VM and Linux on System z. For technical support, please post your question(s) on the [mailing-list](https://lists.sourceforge.net/lists/listinfo/xcat-user). 

**Note: The supported releases of z/VM are 6.2 and newer. A service contract is available for 6.2. For z/VM 6.3 an xCAT appliance is built in.**

**Documentation for the z/VM 6.3 built in xCAT setup is in the SMAPI Application Programming Guide in the [z/VM library](http://www-01.ibm.com/support/knowledgecenter/SSB27U_6.3.0/com.ibm.zvm.v630/zvminfoc03.htm)**

**z/VM 6.3 xCAT service information is at: <http://www.vm.ibm.com/sysman/xcmntlvl.html>**


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

## Prerequisite

This section details what is required before you setup xCAT on z/VM and Linux on System z. 

  


[[img src=Environment.jpg]] **Figure 1.** Sample environment

Before you can install xCAT, there are a couple of prerequisites. You need to have two virtual machines (one VM for the xCAT MN and the other for the zHCP) running Linux. You can optionally use one virtual machine (used as both the xCAT MN and zHCP). However, you need at least one zHCP per z/VM system. 

Both the xCAT MN and zHCP are linked to LNXMAINT, which contains files used by both CMS and Linux. LNXMAINT is a user that you create (if one is not already present). 

LNXMAINT has the following directory entry: 
    
    USER LNXMAINT PWD 64M 128M BEG
    INCLUDE TCPCMSU
    LINK TCPMAINT 0592 0592 RR
    MDISK 0191 3390 1 20 EM6340 MR
    MDISK 0192 3390 1 279 EM6341 MR
    

It is recommended that you have the following PROFILE EXEC on LNXMAINT 192 disk (which is linked to all virtual servers on the z/VM partition). 
    
    /* PROFILE EXEC for Linux virtual servers */
    'CP SET RUN ON'
    'CP SET PF11 RETRIEVE FORWARD'
    'CP SET PF12 RETRIEVE'
    'ACC 592 C'
    'PIPE CP QUERY' userid() '| var user'
    parse value user with id . dsc .
    if (dsc = 'DSC') then /* User is disconnected */
        'CP IPL 100'
    else /* User is interactive -> prompt */
    do
        say 'Do you want to IPL Linux from minidisk 100? y/n'
        parse upper pull answer .
        if (answer = 'Y') then 'CP IPL 100'
    end /* else */
    

This statement in the PROFILE EXEC enables each virtual machine to IPL 100 upon startup. 

  
For more information on how to setup z/VM, refer to [Virtualization Cookbook for SLES 11 SP1](http://www.redbooks.ibm.com/abstracts/sg247931.html?Open) or [Virtualization Cookbook for RHEL 6.0 on z/VM](http://www.redbooks.ibm.com/abstracts/sg247932.html). 

  


### xCAT Management Node

In our development environment, the xCAT MN has the following directory entry: 
    
    USER LNX1 PWD 1G 2G G
    INCLUDE LNXDFLT
    COMMAND SET VSWITCH VSW2 GRANT LNX1
    MDISK 0100 3390 0001 10016 EMC21A MR
    MDISK 0101 3390 0001 10016 EMC21C MR
    MDISK 0102 3390 0001 10016 EMC28B MR
    

where the user profile, LNXDFLT, contains: 
    
    PROFILE LNXDFLT
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
    LINK MAINT 019E 019E RR
    LINK LNXMAINT 0192 0191 RR
    

To install Linux onto this virtual server, we used the following parm file: 
    
    ramdisk_size=65536 root=/dev/ram1 ro init=/linuxrc TERM=dumb        
    HostIP=10.1.100.1 Hostname=gpok1.endicott.ibm.com          
    Gateway=10.1.100.1 Netmask=255.255.255.0                       
    Broadcast=10.1.100.255 Layer2=1 OSAHWaddr=02:00:06:FF:FF:FF     
    ReadChannel=0.0.0800  WriteChannel=0.0.0801  DataChannel=0.0.0802
    Nameserver=10.1.100.1                                          
    portname=FOOBAR                                                     
    portno=0                                                            
    Install=nfs://10.1.100.254/install/SLES-11-SP1-DVD-s390x-GMC3-DVD1.iso
    UseVNC=1 VNCPassword=12345678                                       
    InstNetDev=osa OsaInterface=qdio OsaMedium=eth Manual=0
    

  
It is recommended that you use LVM for the install directory (/install), so you are not constrained by disk size. In our development environment, we allocated 4GB to the root filesystem (/) and the rest (17GB) into an LVM partition for /install. The xCAT MN is connected to NICDEF 0800 which uses VSW2, a layer 2 VSWITCH. If you plan to have your virtual machines use DHCP, each virtual server must be connected to a layer 2 VSWITCH. It is recommended that you create a layer 2 VSWITCH, which will allow virtual machines to communicate across LPARs and CECs. 

The xCAT MN can run on any Linux distribution, SLES or RHEL. In our development environment, the xCAT MN was setup on SLES 11 SP1 with Server Base, Gnome, and X Windows packages installed. You need Gnome desktop in order to use VNC viewer. 

### System z Hardware Control Point

In our development environment, the zHCP has the following directory entry: 
    
    USER LNX2 PWD 512M 1G ABCDG
    COMMAND SET VSWITCH VSW2 GRANT LNX2
    CPU 00 BASE
    CPU 01
    IPL CMS
    MACHINE ESA 4
    OPTION LNKNOPAS
    CONSOLE 0009 3215 T
    NICDEF 0800 TYPE QDIO LAN SYSTEM VSW2
    SPOOL 000C 2540 READER *
    SPOOL 000D 2540 PUNCH A
    SPOOL 000E 1403 A
    LINK MAINT 0190 0190 RR
    LINK MAINT 019E 019E RR
    LINK LNXMAINT 0192 0191 RR
    MDISK 0100 3390 1 10016 EMC278
    

To install Linux onto this virtual server, we used the following parm file: 
    
    ramdisk_size=65536 root=/dev/ram1 ro init=/linuxrc TERM=dumb        
    HostIP=10.1.100.2 Hostname=gpok1.endicott.ibm.com             
    Gateway=10.1.100.2 Netmask=255.255.255.0                         
    Broadcast=10.1.100.255 Layer2=1 OSAHWaddr=02:00:06:FF:FF:FE       
    ReadChannel=0.0.0800  WriteChannel=0.0.0801  DataChannel=0.0.0802 
    Nameserver=10.1.100.1                                             
    portname=FOOBAR                                                     
    portno=0                                                            
    Install=nfs://10.1.100.1/install/SLES-10-SP3-DVD-s390x-DVD1.iso
    UseVNC=1 VNCPassword=12345678                                       
    InstNetDev=osa OsaInterface=qdio OsaMedium=eth Manual=0
    

It is recommended that you mount the root filesystem (/) onto MDISK 0100. You do not need 10016 cylinders allocated to the zHCP, but you do need enough for small Linux operating system. The zHCP is connected to NICDEF 0800 which uses VSW2, a layer 2 VSWITCH. The NICDEF must be specified in the directory entry and not in a profile. The zHCP has A, B, C, D, and G privileges. It needs class A privilege to use the FORCE command, class B privilege to use the ATTACH and FLASHCOPY command (if permitted), class C privilege to use the SEND command, and class D privilege to use the PURGE command. 

Since there are only a few privileged CP commands needed by the zHCP, it is possible to create a custom privilege class, instead of using ABCDG privilege classes. It is recommended that you create a custom privilege class (e.g. X) in order to mitigate possible threats to the z/VM system managed by the zHCP. See [XCAT_zVM_Setup/#installation-of-zhcp](XCAT_zVM_Setup/#installation-of-zhcp).

The zHCP can run on any Linux distribution, SLES or RHEL. In our development environment, the zHCP was setup on SLES 10 SP3 with Server Base package installed. 

## Planning

This section helps you plan the layout of the xCAT cloud environment. 

You can find the configuration we used in our development environment below in the table. You should plan out how your cloud environment would be configured based on the examples given. 

  * **Network:**
    * Gateway: 10.1.100.1 
    * Netmask: 255.255.255.0 
    * IP range: 10.1.100.1-10.1.100.254 
    * Hostname range: gpok1-gpok254 
    * Broadcast: 10.1.100.255 
    * Nameserver: 10.1.100.1 
  * **FTP server containing Linux ISOs:**
    * IP: 10.1.100.254 
  * **xCAT management node:**
    * Hostname: gpok1.endicott.ibm.com 
    * IP: 10.1.100.1 
    * UserID: LNX1 
  * **Hardware control point(s):**
    * Hostname: gpok2.endicott.ibm.com 
    * IP: 10.1.100.2 
    * UserID: LNX2 
    * LPAR: POKDEV61 
    * Network: VSW2 (layer 2 VSWITCH) 

## Installation of xCAT

This section details how to install the xCAT management node. 

  


### Red Hat Enterprise Linux

If you have a Red Hat Linux, follow the instructions below. 

  1. Logon as root using a Putty terminal
  2. Disable SELinux 
        
        # echo 0 > /selinux/enforce

The command above will switch off enforcement temporarily, until you reboot the system.  
To make it permanent, edit /etc/selinux/config and change SELINUX=enforcing to SELINUX=permissive. 

  3. Add the RHEL repository to yum
    * Create a repository file 
            
            # touch /etc/yum.repos.d/rhel-dvd.repo

    * Insert the following into the repository file rhel-dvd.repo 
            
             
            [rhel-dvd]
            name=RHEL DVD
            baseurl=ftp://xxx-ftp-path
            enabled=1
            gpgcheck=1
            

where xxx-ftp-path is the FTP path to the RHEL DVD. For example: 
            
            
            [rhel-dvd]
            name=RHEL DVD
            baseurl=ftp://10.1.100.254/rhel6.2/s390x/Server
            enabled=1
            gpgcheck=1
            

    * Download the `RPM-GPG-KEY-redhat-release` from the FTP server (e.g. [ftp://10.1.100.254/rhel6.2/s390x/)](ftp://10.1.100.254/rhel6.2/s390x/) onto this node.
    * Import the key 
            
            # rpm --import RPM-GPG-KEY-redhat-release

  4. Make an xcat directory under /root 
        
        # mkdir /root/xcat

  5. Download the latest xCAT tarballs, xcat-core-xxx.tar.bz2 and xcat-dep-xxx.tar.bz2 (where xxx is the release and version number) from [Download_xCAT] onto /root/xcat 
  6. Extract the contents of each tarball 
        
        
        # cd /root/xcat
        # tar jxf xcat-core-xxx.tar.bz2
        # tar jxf xcat-dep-xxx.tar.bz2
        

  7. Create a yum repositories for xCAT  
If you have Red Hat Enterprise Linux 5: 
        
        
        # /root/xcat/xcat-dep/rh5/s390x/mklocalrepo.sh
        # /root/xcat/xcat-core/mklocalrepo.sh
        

If you have Red Hat Enterprise Linux 6: 
        
         
        # /root/xcat/xcat-dep/rh6/s390x/mklocalrepo.sh
        # /root/xcat/xcat-core/mklocalrepo.sh
        

  8. Use `yum` to install xCAT 
        
        
        # yum clean metadata
        # yum install xCAT
        

Ignore the warning messages (if any) about the keys and accept them. 

### SUSE Linux Enterprise Server

If you have a SUSE Linux, follow the instructions below. 

  1. Logon as root using a Putty terminal
  2. Install the DHCP server through yast (if not already) 
        
        # zypper install dhcp-server

  3. Make an xcat directory under /root 
        
        # mkdir /root/xcat

  4. Download the latest xCAT tarballs, xcat-core-xxx.tar.bz2 and xcat-dep-xxx.tar.bz2 (where xxx is the version number) from [Download_xCAT] onto /root/xcat 
  5. Extract the contents of each tarball 
        
        
        # cd /root/xcat
        # tar jxf xcat-core-xxx.tar.bz2
        # tar jxf xcat-dep-xxx.tar.bz2
        

  6. Add the xCAT repositories to zypper 
    * If you have SUSE Linux Enterprise Server 10: 
            
            
            # zypper sa file:///root/xcat/xcat-dep/sles10/s390x xCAT-dep
            # zypper sa file:///root/xcat/xcat-core xcat-core
            

    * If you have SUSE Linux Enterprise Server 11: 
            
            
            # zypper ar file:///root/xcat/xcat-dep/sles11/s390x xCAT-dep
            # zypper ar file:///root/xcat/xcat-core xcat-core
            

Ignore the warning messages (if any) about the keys and accept them. 

  7. Use zypper to install xCAT 
        
        # zypper install xCAT

### Finalizing Installation

Continue with the following steps once you completed installing xCAT: 

  1. Add the xCAT commands to path 
        
        # source /etc/profile.d/xcat.sh

  2. Check if the database is initialize 
        
        # tabdump site

The output should look similar to the following: 
        
        
        #key,value,comments,disable
        "blademaxp","64",,
        "domain","endicott.ibm.com",,
        "fsptimeout","0",,
        "installdir","/install",,
        "ipmimaxp","64",,
        "ipmiretries","3",,
        "ipmitimeout","2",,
        "consoleondemand","no",,
        "master","10.1.100.1",,
        "maxssh","8",,
        "ppcmaxp","64",,
        "ppcretry","3",,
        "ppctimeout","0",,
        "rsh","/usr/bin/ssh",,
        "rcp","/usr/bin/scp",,
        "sharedtftp","0",,
        "SNsyncfiledir","/var/xcat/syncfiles",,
        "tftpdir","/tftpboot",,
        "xcatdport","3001",,
        "xcatiport","3002",,
        "xcatconfdir","/etc/xcat",,
        "timezone","US/Eastern",,
        "nameservers","10.1.100.1",,
        

  3. Setup an FTP server on the xCAT MN to contain Linux distributions
    * Download the desire Linux ISO into /install
    * Go into /install directory 
            
            # cd /install

    * Extract the ISO into the xCAT install tree /install 
            
            # copycds -n xxx -a s390x /install/yyy.iso

where xxx is the distribution name and yyy is the ISO name.  
  
For example, if you have a SUSE Linux Enterprise Server 10 SP3 ISO: 
            
            
            # copycds -n sles10sp3 -a s390x /install/SLES-10-SP3-DVD-s390x-DVD1.iso
            Copying media to /install/sles11sp1/s390x/1
            Media copy operation successful
            

or if you have a Red Hat Enterprise Linux 5.4 ISO: 
            
            
            # copycds -n rhel5.4 -a s390x /install/RHEL5.4-Server-20090819.0-s390x-DVD.iso
            Copying media to /install/rhel5.4/s390x
            Media copy operation successful
            

    * Remove the ISO from /install since we do not need the ISO any longer, and it consumes disk space 
            
            # rm /install/SLES-10-SP3-DVD-s390x-DVD1.iso

## Installation of xCAT UI

This section details the installation of the xCAT UI. The xCAT UI is supported on Google Chrome, Mozilla Firefox, and Opera. It is not fully supported on Microsoft Internet Explorer. Instructions on using the xCAT UI can be found in the [xCAT UI tutorial](http://xcat.sourceforge.net/pdf/xCAT-UI-Tutorial.pdf). You can also find videos showing how to use the xCAT UI on [YouTube](http://www.youtube.com/xcatuser). 

  


### Red Hat Enterprise Linux

If you have a Red Hat Linux, follow the instructions below. 

  1. Use yum to install the following packages (accept the dependencies) 
        
        # yum install php httpd mod_ssl

  2. Allow httpd to make network connections (if SELinux is enabled) 
        
        # /usr/sbin/setsebool httpd_can_network_connect=1

  3. Install the xCAT-UI 
        
        # yum install xCAT-UI

### SUSE Linux Enterprise Server

If you have a SUSE Linux, follow the instructions below. 

  1. Use zypper to install the following packages (accept the dependencies) 
        
        # zypper in php5-openssl apache2 apache2-mod_php5
         or
        # zypper in php53-openssl apache2 apache2-mod_php53  (SLES 11)



  2. Install the xCAT-UI (accept the dependencies) 
        
        # zypper in xCAT-UI

### SSL Configuration

This section details the configuration of SSL on the xCAT server. SSL stands for Secure Socket Layer, which is a security protocol for communications over networks. 

  


#### Red Hat Enterprise Linux

If you have a Red Hat Linux, follow the instructions below. 

  1. Install mod_ssl and openssl (if not already) 
        
        # yum install mod_ssl openssl

This will create the mod_ssl configuration file at /etc/httpd/conf.d/ssl.conf, which is included in the main Apache HTTP Server configuration file by default. 

  2. Restart Apache HTTP server 
        
        # service httpd restart

#### SUSE Linux Enterprise Server

If you have a SUSE Linux, follow the instructions below. You can find the following instructions from &lt;http://en.opensuse.org/Apache_Howto_SSL&gt;. 

  1. Apache should be set to start with SSL. Verify with the following command 
        
        
        # a2enmod ssl
         "ssl" already present
        

  2. Make sure that SSL is active 
        
        # a2enflag SSL

  3. Create self signed keys 
        
        # gensslcert

  4. Copy `/etc/apache2/vhosts.d/vhost-ssl.template` to `/etc/apache2/vhosts.d/vhost-ssl.conf`
        
        # cp /etc/apache2/vhosts.d/vhost-ssl.template /etc/apache2/vhosts.d/vhost-ssl.conf

  5. For the enabled modules, server flags, generated keys and vhosts to take effect, restart the apache service 
        
        
        # service apache2 restart
        Syntax OK
        Shutting down httpd2 (waiting for all children to terminate)         done
        Starting httpd2 (prefork)
        

  6. Open a browser (Firefox) to the xCAT UI at https://xxx/xcat, where xxx is the host name of the xCAT MN. For example, [https://gpok1.endicott.ibm.com/xcat](https://gpok254.endicott.ibm.com/xcat). You will get a "Untrusted certificate" warning when you first try to access the URL. This is expected because of the use of a self-signed certificate.

## Installation of zHCP

This section details the installation of the zHCP. Before continuing, note that the user directory entry for the zHCP should be similar to the one below. 
    
    
    USER LNX2 PWD 512M 1G ABCDG
    COMMAND SET VSWITCH VSW2 GRANT LNX2
    CPU 00 BASE
    CPU 01
    IPL CMS
    MACHINE ESA 4
    OPTION LNKNOPAS
    CONSOLE 0009 3215 T
    NICDEF 0800 TYPE QDIO LAN SYSTEM VSW2
    SPOOL 000C 2540 READER *
    SPOOL 000D 2540 PUNCH A
    SPOOL 000E 1403 A
    LINK MAINT 0190 0190 RR
    LINK MAINT 019D 019D RR
    LINK MAINT 019E 019E RR
    LINK LNXMAINT 0192 0191 RR
    LINK TCPMAINT 0592 0592 RR
    MDISK 0100 3390 1 10016 EMC278
    

It is important to include OPTION LNKNOPAS in the user directory entry because it is needed by the zHCP to link to disks of other virtual machines. Also, it is important to note that the zHCP uses one network device (in our development environment, VSWITCH VSW2). It is possible for the zHCP to use more than one network device. However, the network devices must be specified in the directory entry and not in a profile. The zHCP has A, B, C, D, and G privileges. It needs class A privilege to use the FORCE command, class B privilege to use the FLASHCOPY command (if permitted), class C privilege to use the SEND command, and class D privilege to use the PURGE command.  


Since there are only a few privileged CP commands needed by the zHCP, it is possible to create a custom privilege class, instead of using ABCDG privilege classes. It is recommended that you create a custom privilege class (e.g. X) in order to mitigate possible threats to the z/VM system managed by the zHCP. Privilege classes are denoted by the letters A through Z and the numbers 1 through 6. Classes I through Z and numbers 1 through 6 are available to be used in your installation. The user directory entry for the zHCP should be similar to the one below. 
    
    
    USER LNX2 PWD 512M 1G GX
    COMMAND SET VSWITCH VSW2 GRANT LNX2
    CPU 00 BASE
    CPU 01
    IPL CMS
    MACHINE ESA 4
    OPTION LNKNOPAS
    CONSOLE 0009 3215 T
    NICDEF 0800 TYPE QDIO LAN SYSTEM VSW2
    SPOOL 000C 2540 READER *
    SPOOL 000D 2540 PUNCH A
    SPOOL 000E 1403 A
    LINK MAINT 0190 0190 RR
    LINK MAINT 019D 019D RR
    LINK MAINT 019E 019E RR
    LINK LNXMAINT 0192 0191 RR
    LINK TCPMAINT 0592 0592 RR
    MDISK 0100 3390 1 10016 EMC278
    

### Configuring z/VM, SMAPI, and DirMaint

Perform the following steps to prepare a Linux virtual server for installation of the System z Hardware Control Point (zHCP) 

  1. If you plan on using a custom privilege class, modify the z/VM system configuration file. The SYSTEM CONFIG file contains the primary system definitions used when CP is booted (IPLed). 
    * Open a 3270 console, logon MAINT, and issue the following commands 
    * To edit the SYSTEM CONFIG file, the MAINT CF1 minidisk must be released as a CP disk via the CPRELASE command. The CP disks are queried via the QUERY CPDISK command. Note the MAINT CF1 disk is accessed as CP disk A before it is released but not after. 
            
            
            ==> q cpdisk
            Label Userid Vdev Mode Stat Vol-ID Rdev Type StartLoc EndLoc
            MNTCF1 MAINT 0CF1 A R/O MVA740 A740 CKD 39 158
            MNTCF2 MAINT 0CF2 B R/O MVA740 A740 CKD 159 278
            MNTCF3 MAINT 0CF3 C R/O MVA740 A740 CKD 279 398
            
            ==> cprel a
            CPRELEASE request for disk A scheduled.
            HCPZAC6730I CPRELEASE request for disk A completed.
            
            ==> q cpdisk
            Label Userid Vdev Mode Stat Vol-ID Rdev Type StartLoc EndLoc
            MNTCF2 MAINT 0CF2 B R/O MVA740 A740 CKD 159 278
            MNTCF3 MAINT 0CF3 C R/O MVA740 A740 CKD 279 398
            

    * Once it is released you are able to access the MAINT CF1 disk read-write. Use the LINK command with multi-read (MR) parameter and ACCESS command to get read-write access to the minidisk. 
            
            
            ==> link * cf1 cf1 mr
            
            ==> acc cf1 f
            

    * Now the MAINT CF1 disk is accessed read-write as your F disk. First make a backup copy of the vanilla SYSTEM CONFIG file using the COPYFILE command with the OLDDATE parameter so the file's timestamp is not modified, then edit the original copy. 
            
            
            ==> copy system config f system conforig f (oldd
            

    * Edit the SYSTEM CONFIG file 
            
            
            ==> xedit system config f
            

    * The following commands need to be added to allow the zHCP Linux system to manage virtual machines. A custom privilege class named X is created. If the privilege class is taken, use another letter, such as Z. Privilege classes are denoted by the letters A through Z and the numbers 1 through 6. Classes I through Z and numbers 1 through 6 are available to be used in your installation. 
            
            
            /********************************************************************/
            /* ZHCP PRIVCLASS SETUP                                             */
            /********************************************************************/
            MODIFY CMD FORCE                   IBMCLASS A PRIVCLASS AX
            MODIFY CMD FLASHCOPY               IBMCLASS B PRIVCLASS BX 
            MODIFY CMD SEND                    IBMCLASS C PRIVCLASS CX
            MODIFY CMD PURGE                   IBMCLASS D PRIVCLASS DX
            

    * Test your changes with the CPSYNTAX command which is on the MAINT 193 disk. Pay attention to the output. If you get any syntax errors, fix them before proceeding. 
            
            
            ==> acc 193 g
            
            ==> cpsyntax system config f
            CONFIGURATION FILE PROCESSING COMPLETE -- NO ERRORS ENCOUNTERED.
            

    * Release and detach the MAINT CF1 disk with the RELEASE command and DETACH parameter. Then put it back online with the CPACCESS command. 
            
            
            ==> rel f (det
            DASD 0CF1 DETACHED
            
            ==> cpacc * cf1 a
            CPACCESS request for mode A scheduled.
            HCPZAC6732I CPACCESS request for MAINT's 0CF1 in mode A completed.
            
            ==> q cpdisk
            Label Userid Vdev Mode Stat Vol-ID Rdev Type StartLoc EndLoc
            MNTCF1 MAINT 0CF1 A R/O MVA740 A740 CKD 39 158
            MNTCF2 MAINT 0CF2 B R/O MVA740 A740 CKD 159 278
            MNTCF3 MAINT 0CF3 C R/O MVA740 A740 CKD 279 398
            

  2. Install and configure SMAPI and DirMaint for each z/VM partition. Refer to [System Management Application programming](http://http://pic.dhe.ibm.com/infocenter/zvm/v6r3/index.jsp) or (step 1: _Configure and start DirMaint_ and step 2: _Configure SMAPI server environment_) [Installing the IBM z/VM Manageability Access Point Agent](http://publib.boulder.ibm.com/infocenter/director/v6r2x/topic/com.ibm.director.install.helps.doc/fqm0_t_installing_z_map_agents.html).  
  
**Notes:**  

    * The directory entries for SMAPI request servers need to be created in z/VM 5.4 and 6.1 (or newer). The SMAPI request servers are already present in z/VM 6.2. The following is the recommended directory entry for each SMAPI request server (VSMREQIN, VSMREQIU, VSMREQI6, VSMPROXY, VSMREQIM). Note that they do not require special privilege classes. 
            
            
            USER name name 128M 512M G
            IPL CMS PARM AUTOCR
            OPTION DIAG88
            MACHINE ESA
            IUCV auth MSGLIMIT 255
            IUCV *VMEVENT
            IUCV *SCLP
            CONSOLE 0009 3215 T
            NAMESAVE VSMDCSS
            SPOOL 000C 2540 READER *
            SPOOL 000D 2540 PUNCH A
            SPOOL 000E 1403 A
            LINK MAINT 190 190 RR
            LINK MAINT 19E 19E RR
            LINK MAINT 193 193 RR
            LINK TCPMAINT 591 591 RR
            LINK TCPMAINT 592 592 RR
            MDISK 191 3390 2398 025 610RES MR READ WRITE MULTIPLE
            
            where name and auth are:
            VSMREQIN, VSMREQI6, along with ANY for the AF_INET/AF_INET6 request server(s)
            VSMREQIU and ALLOW for the AF_IUCV request server(s)
            VSMPROXY and ANY for the AF_SCLP request server
            

The line `IUCV *SCLP` is required only for the AF_SCLP request server. Keep in mind that neither request servers nor worker servers can run with multiple CPUs defined. If you are applying service updates to an existing system, you may currently have less than 128M defined in your `USER name name` statement. IBM recommends that you increase this amount to at least 128M (Note that 512M is the maximum allowed).  
  


    * The following is the recommended directory entry for the worker servers (including VSMGUARD, VSMWORK1, VSMWORK2, and VSMWORK3). Since the worker servers process requests that require various privileges, the worker servers must have all of the privilege classes (A through G). 
            
            
            USER name name 128M 512M ABCDEFG
            IPL CMS PARM AUTOCR
            OPTION DIAG88 MAINTCCW LNKS LNKE
            MACHINE ESA
            IUCV ANY MSGLIMIT 255
            CONSOLE 0009 3215 T
            NAMESAVE VSMDCSS
            SPOOL 000C 2540 READER *
            SPOOL 000D 2540 PUNCH A
            SPOOL 000E 1403 A
            LINK MAINT 190 190 RR
            LINK MAINT 19E 19E RR
            LINK MAINT 193 193 RR
            LINK MAINT CF1 CF1 MD
            LINK MAINT CF2 CF2 MD
            LINK TCPMAINT 591 591 RR
            LINK TCPMAINT 592 592 RR
            MDISK 191 3390 2398 025 610RES MR READ WRITE MULTIPLE
            
            where name is VSMWORK1, VSMWORK2, or VSMWORK3
            

Keep in mind that neither request servers nor worker servers can run with multiple CPUs defined. If you are applying service updates to an existing system, you may currently have less than 128M defined in your `USER name name` statement. IBM recommends that you increase this amount to at least 128M (Note that 512M is the maximum allowed). 

  3. Grant the zHCP access to DirMaint. 
    * Open a 3270 console, logon MAINT, and issue the following commands, substituting LNX2 used in this example with the user ID of your virtual machine. 
            
            
            ==> DIRM FOR ALL AUTHFOR LNX2 CMDL 140A CMDS ADGHOPS
            DVHXMT1191I Your AUTHFOR request has been sent for processing.
            DVHREQ2288I Your AUTHFOR request for ALL at * has been accepted.
            DVHREQ2289I Your AUTHFOR request for ALL at * has completed; with RC =
            DVHREQ2289I 0.
            
            ==> DIRM FOR ALL AUTHFOR LNX2 CMDL 150A CMDS ADGHOPS
            DVHXMT1191I Your AUTHFOR request has been sent for processing.
            DVHREQ2288I Your AUTHFOR request for ALL at * has been accepted.
            DVHREQ2289I Your AUTHFOR request for ALL at * has completed; with RC =
            DVHREQ2289I 0.
            

    * Change VSMWORK1 AUTHLIST 
            
            
            ==> SET FILEPOOL VMSYS
            
            ==> QUERY FILEPOOL CONNECT
            Userid Connected
            VSMWORK1 Yes
            VSMWORK2 Yes
            VSMWORK3 Yes
            VSMREQIN Yes
            VSMREQIU Yes
            VSMPROXY Yes
            MAINT Yes
            
            ==> ACCESS VMSYS:VSMWORK1.DATA A (FORCERW
            DMSACR724I VMSYS:VSMWORK1.DATA replaces A (0191)
            
            ==> ACCESS VMSYS:VSMWORK1. B (FORCERW
            DMSACR724I VMSYS:VSMWORK1. replaces B (05E5)
            
            ==> X VSMWORK1 AUTHLIST B
            00001 DO.NOT.REMOVE
            00002 MAINT ALL
            00003 VSMPROXY ALL
            00004 VSMWORK1 ALL
            

    * Copy the line where VSMWORK1 is specified by inserting a double quote in the prefix area and pressing enter. Substitute VSMWORK1 with the user ID you wish to have DIRMAINT access (in our case LNX2). The VSMWORK1 AUTHLIST should be similar to the this: 
            
            
            00001 DO.NOT.REMOVE
            00002 MAINT ALL
            00003 VSMPROXY ALL
            00004 VSMWORK1 ALL
            00005 LNX2 ALL
            

    * Restart SMAPI 
            
            
            ==> FORCE VSMWORK1
            ==> XAUTOLOG VSMWORK1
            

  4. Give the virtual machine where you will install the zHCP A, B, C, D, and G class privileges. The zHCP needs class A privilege to use the FORCE command, class B privilege to use the FLASHCOPY command (if available), class C privilege to use the SEND command, and class D privilege to use the PURGE command. If you are using a custom user class, give the virtual server the custom privilege class (e.g. X) in place of these classes. In order for the zHCP to have these class privileges, you must open a 3270 console, logon to MAINT after the user has been created, and issue: 
        
        ==> DIRM FORUSER LNX2 CLASS ABCDG

  5. Log off MAINT 
        
        ==> LOGOFF

### Configuring zHCP

**Warning** The NICDEF statements for the zHCP must be contained in the directory entry and not in a profile. 

  1. Logon to the xCAT MN as root using a Putty terminal
  2. Go into the directory where you extracted the xcat-dep tarball, e.g. /root/xcat. Send the zHCP RPM (zhcp-2.0-1.s390x.rpm) located in /root/xcat/xcat-dep/&lt;os&gt;/s390x to the zHCP, where &lt;os&gt; is the operating system installed on the zHCP. For example, 
        
        # scp /root/xcat/xcat-dep/sles10/s390x/zhcp-2.0-1.s390x.rpm root@10.1.100.2:

  3. Exit the Putty session to the xCAT MN 
  4. Logon to the zHCP Linux as root using a Putty terminal
  5. Load Linux VMCP module (if not already) 
        
        # modprobe vmcp

  6. Configure the VMCP module to load every time the system is booted. 
    * If you have Red Hat Enterprise Linux:  
Create /etc/rc.modules and add the following line to the file: 
            
            modprobe vmcp

Set the following permission to the file: 
            
            chmod +x /etc/rc.modules

    * If you have SUSE Linux Enterprise Server:  
Edit /etc/sysconfig/kernel and add the VMCP module to the MODULES_LOADED_ON_BOOT parameter: 
            
            MODULES_LOADED_ON_BOOT="vmcp"

  7. Install the zHCP 
        
        # rpm -Uvh zhcp-2.0-1.s390x.rpm

  8. xCAT will automatically generate a MAC address for new virtual machines. It uses the USERPREFIX obtained from `vmcp query vmlan` as the MAC address prefix. If the USERPREFIX is not available, it will default to the MACPREFIX. The MAC address suffix is automatically generated, starting at FFFFF0, called the MACID. As more virtual machines are created, the MACID will be decremented. You can customize where the MACID starts at by echoing the 6 hexadecimal digits into /opt/zhcp/conf/next_macid. xCAT will generate /opt/zhcp/conf/next_macid the first time you create a virtual machine, if one does not exist.  
  
It is important to note that in an SSI cluster, the MACID (/opt/zhcp/conf/next_macid) must be staggered on each zHCP in order to avoid MAC address collision. You could set next_macid to FFFFF0 on zHCP #1, set next_macid to EFFFF0 on zHCP #2, set next_macid to DFFFF0 on zHCP #3, etc. 

## Initializing Database

This section details how to manage z/VM and Linux on System z using xCAT. 

  


  1. Logon the xCAT MN as root using a Putty terminal
  2. Load Linux VMCP module on the xCAT MN (if not already) 
        
        # modprobe vmcp

  3. If you do not wish to allow nodes to SSH between each other without a password, turn off the feature 
        
        # chtab key=sshbetweennodes site.value='NOGROUPS'

  4. Set up the passwd table. This table will contain the default password for new nodes installed through autoyast/kickstart and other methods. 
        
        # chtab key=system passwd.username=root passwd.password=xxx

Substitute xxx with the root password. 

  5. If you do not plan to use regular expressions to represent the IP address and hostname, skip to the next step.  
  
Set up the hosts table (it will be used to setup /etc/hosts). You need to determine the regular expression that represents the nodes that xCAT will manage. 
        
        # chtab node=xxx hosts.ip="yyy" hosts.hostnames="zzz"

Substitute xxx with the node range, yyy with the regular expression for the IP addresses, and zzz with the regular expression for the hostnames. You could use the following online tool to construct your regular expression: &lt;http://gskinner.com/RegExr/&gt;. Each time a new node is added to xCAT, you will need to run makehosts. You will need to setup the hosts table for each group you create.  
  


In our development environment, we setup nodes belonging to group=all to have hostnames of gpok1, gpok2, etc. and IP addresses of 10.1.100.1, 10.1.100.2, etc. in /etc/hosts with the following: 
        
        # chtab node=all hosts.ip="|gpok(\d+)|10.1.100.(\$1+0)|" hosts.hostnames="|(.*)|(\$1).endicott.ibm.com|"

  6. Setup the networks table. You need to set the DHCP, DNS, and FTP server to the IP address of your xCAT MN.  
  
In our development environment, we setup up the xCAT MN to manage the network 10.1.100.0, which has a netmask of 255.255.255.0, a gateway of 10.1.100.1, and on an ethernet interface eth1. Our DHCP, DNS, and FTP servers are at 10.1.100.1. This is the command that we used: 
        
        # chtab net=10.1.100.0 networks.mask=255.255.255.0 networks.mgtifname=eth1 networks.gateway=10.1.100.1 networks.dhcpserver=10.1.100.1 networks.tftpserver=10.1.100.1 networks.nameservers=10.1.100.1

  7. If you do not plan to use DHCP, skip to the next step.  
  
Define the DHCP interfaces in the site table to limit which network the DHCP server will listen on. In our development environment, we setup eth1 as the interface where we have the DHCP server listening on. 
        
        # chtab key=dhcpinterfaces site.value='all|eth1'

  8. Edit the nameserver and master in the site table to point it to the xCAT MN. In our development environment, we setup our nameserver and master to be 10.1.100.1. 
        
        
        # chtab key=nameservers site.value='10.1.100.1'
        # chtab key=master site.value='10.1.100.1'
        

  9. Configure the DHCP server (if you plan to use it) 
    * Add networks into the DHCP configuration 
            
            # makedhcp -n

    * Restart DHCP 
            
            
            # service dhcpd restart
            Shutting down DHCP server              done
            Starting DHCP server [chroot]          done
            

  10. Configure the DNS server, for more information see: [Cluster_Name_Resolution]
    * Restart DNS 
            
            
            # service named restart
            Shutting down name server BIND  waiting for named to shut down (29s) done
            Starting name server BIND                                            done
            

    * Start DNS on boot 
            
            # chkconfig --level 345 named on

  11. Start by adding the zHCP node into the datatabase (Use the DNS hostname of that node when adding). In our development environment, our zHCP has a hostname of gpok2, a userID of LNX2, and belonged to the group=all. **Done automatically in z/VM 6.3** This is the command that we used: 
        
        
        # mkdef -t node -o gpok2 userid=LNX2 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all
        1 object definitions have been created or modified.
        

Set the node's IP address and hostname (only if a regex is not set for the group) 
        
        
        # chtab node=gpok2 hosts.ip="10.1.100.2" hosts.hostnames="gpok2.endicott.ibm.com"
        

  12. Add the z/VM hypervisor definition into the database. **Done automatically in z/VM 6.3**
        
        
        # nodeadd pokdev61 groups=hosts hypervisor.type=zvm nodetype.os=zvm6.1 zvm.hcp=gpok2.endicott.ibm.com mgt=zvm
        

Here, pokdev61 is the z/VM system name, zvm6.1 is the z/VM version, and gpok2.endicott.ibm.com is the full domain name of the zHCP. 

  13. Add more nodes (if any) that you want to manage into the database. For example, if you have a node with a hostname of gpok3 and userID of LNX3 on the same z/VM partition (managed by the zHCP on gpok2), you would use the following command: 
        
        
        # mkdef -t node -o gpok3 userid=LNX3 hcp=gpok2.endicott.ibm.com mgt=zvm groups=all
        1 object definitions have been created or modified.
        

The node IP address should follow the rule you specified in the hosts table (step 4).  
  


Set the node's IP address and hostname (only if a regex is not set for the group) 
        
        
        # chtab node=gpok3 hosts.ip="10.1.100.3" hosts.hostnames="gpok3.endicott.ibm.com"
        

  14. Update /etc/hosts 
        
        # makehosts

  15. Update DNS 
        
        
        # makedns
        Handling localhost in /etc/hosts.
        Handling gpok3 in /etc/hosts.
        Getting reverse zones, this may take several minutes in scaling cluster.
        Completed getting reverse zones.
        Updating zones.
        Completed updating zones.
        Updating DNS records, this may take several minutes in scaling cluster.
        Completed updating DNS records.
        DNS setup is completed
        

  16. Setup the SSH keys for the node range that you want to manage 
        
        # xdsh xxx -K

Substitute xxx with the node range. For example, if you were to setup the SSH keys for the nodes you added above in steps 10 and 11, you can use: 
        
        
        # xdsh all -K
        Enter the password for the userid: root on the node where the ssh keys 
        will be updated:
        
        /usr/bin/ssh setup is complete.
        return code = 0
        

The xdsh command will prompt you for a root password. It is the root password for the node or group you are trying to push the public SSH key to. It is recommended that you put nodes with the same root password into the same group. More importantly, the xdsh command will only work for nodes that are online. 

  17. Start using supported xCAT commands. At this point, you could use the xCAT UI to start managing your virtual servers. However, you should go through the [XCAT_zVM] document in order to understand the concepts and how the xCAT UI works in the background. You can find videos showing how to use the xCAT UI on [YouTube](http://www.youtube.com/xcatuser). 
