<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Quick tips on xCAT commands](#quick-tips-on-xcat-commands)
- [Prepare the xCAT Management Node](#prepare-the-xcat-management-node)
  - [Ensure that SELinux is Disabled on RHEL](#ensure-that-selinux-is-disabled-on-rhel)
  - [** Disable the Firewall**](#-disable-the-firewall)
  - [DNS](#dns)
- [Install and Configure xCAT on the Management Node](#install-and-configure-xcat-on-the-management-node)
  - [Discover Hardware](#discover-hardware)
  - [Define and Configure Nodes](#define-and-configure-nodes)
- [Deploy the Nodes](#deploy-the-nodes)
  - [Stateful (Diskfull) Install](#stateful-diskfull-install)
  - [Stateless (Diskless) Boot](#stateless-diskless-boot)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

Note: if you are using P775 hardware, do not use this document. Use: [XCAT_pLinux_Clusters_775].
IF you are not very familiar with setting up PLinux clusters, you probably need  more complete instructions on setting up the cluster.  Use the following documentation.  [XCAT_pLinux_Clusters].


## Introduction

This guide is a general quick reference for installing xCAT on IBM Power machines. xCAT provides full documentation for many different pLinux scenarios. Start with the information here first, then refer to the specific documentation for your environment if you need more information on commands and detailed setup. 

Complete guide: 

  * [XCAT pLinux Clusters](XCAT_pLinux_Clusters)

  
This guide was written using the following setup. Newer versions of Distros and xCAT and other PowerLinux servers should work correctly, but may not have been explicitly tested: 

  * Hardware: **Power7**
  * Hardware Control: **HMC**
  * Virtualization: Yes, **PowerVM** (HMC based) 
  * Distros: **RHEL6.2** and **SLES 11 SP2**
  * xCAT version (latest stable): **2.8.x**

### Quick tips on xCAT commands

Objects versus Tables: 

  * `lsdef, chdef, mkdef` are commands to change object definitions in the xCAT database. Since one object may reference more than one table, the preference is to use these commands 
  * `chtab, tabdump` will manage tables in the xCAT database. 

Remote commands: 

  * `rpower, rscan, rinstall, rnetboot` \- interfaces to hardware management operations 

  
See more information at
[Listing_and_Modifying_the_Database](Listing_and_Modifying_the_Database)


## Prepare the xCAT Management Node

Install your distro: 

  * Refer to your distro manual or other procedures you may use to install the distro on your xCAT management node 
  * Verify you have your yum or zypper repository correctly setup 
  * You will need to have a copy of the distro ISO, or mounted via NFS, or in DVD. In this example, we are using RHEL6.2 in /iso/RHEL6.2-20111117.0-Server-ppc64-DVD1.iso 

Add xCAT repositories (xcat-core and xcat-dep): 
    
~~~~   
    $ cd /etc/yum.repos.d
    wget http://sourceforge.net/projects/xcat/files/yum/2.8/xcat-core/xCAT-core.repo
    wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/ppc64/xCAT-dep.repo
~~~~    

  
Check network configuration 

The MN will be configured with two interfaces: one facing the external network (LAN) and another facing the private network 

Example: 

~~~~
  * LAN: 
    * domain: austin.ibm.com 
    * Management Node (MN) IP: 9.3.189.137/24 
    * Hostname: junoltc01 
    * Nameservers: 9.0.7.1,9.0.6.11 
  * Private network 
    * domain: mine.austin.ibm.com 
    * Hostname:junoltc01 
    * MN IP: 192.168.0.100/24 
  * HMC: aphmc5.austin.ibm.com (9.3.110.122) 
~~~~
  
Important files to check: 

  * `/etc/sysconfig/network`: HOSTNAME should be correctly set (`HOSTNAME=junoltc01`). In SLES, file is /etc/HOSTNAME 
  * `/etc/sysconfig/network-scripts/ifcfg-eth#`&nbsp;: eth0 is configured to LAN, while eth1 is configured to the xCAT private network 
  * `/etc/resolv.conf`: domain should point to the private domain, as well as search. nameservers should have the private MN ip. 
    
~~~~   
    $ cat /etc/resolv.conf 
    domain mine.austin.ibm.com
    search mine.austin.ibm.com
    nameserver 192.168.0.100
~~~~    

     On xCAT 2.7 or later, you don't to need to configure the /etc/resolv.conf facing the private network. 

  * `/etc/hosts` (see DNS section below for other choices of DNS configuration). It should contain dns resolution information for the management node, compute node(s) and the hmc: 
    
~~~~    
    $ cat /etc/hosts
    ...
    192.168.0.100   junoltc01 junoltc01.mine.austin.ibm.com   #MN
    192.168.0.103   junoltc03 junoltc03.mine.austin.ibm.com   #Compute node (diskful install)
    192.168.0.109   junoltc09 junoltc09.mine.austin.ibm.com   #Compute node (diskless install)
    
    
    9.3.110.122     aphmc5 aphmc5.austin.ibm.com		  # HMC 
~~~~    

###  Ensure that SELinux is Disabled on RHEL

**Note:** you can skip this step in xCAT 2.8.1 and above, because xCAT does it automatically when it is installed. 

To disable SELinux manually: 

~~~~    
    echo 0 &gt; /selinux/enforce
    sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
~~~~    
    

### ** Disable the Firewall**

**Note:** you can skip this step in xCAT 2.8 and above, because xCAT does it automatically when it is installed. 

The management node provides many services to the cluster nodes, but the firewall on the management node can interfere with this. If your cluster is on a secure network, the easiest thing to do is to disable the firewall on the Management Mode: 

For RH: 

~~~~    
    service iptables stop
    chkconfig iptables off
~~~~    
    

If disabling the firewall completely isn't an option, configure iptables to allow the following services on the NIC that faces the cluster: DHCP, TFTP, NFS, HTTP, DNS. 

For SLES: 

~~~~   
    SuSEfirewall2 stop
~~~~    

  


### DNS

This quickstart uses DNS configuration setup through /etc/hosts. For other DNS configuration methods,refer to: {Cluster_Name_Resolution]

## Install and Configure xCAT on the Management Node

Install xCAT 
    
~~~~    
    $ yum install xCAT
~~~~    

Check running services. Restart services if necessary. 
    
~~~~    
    $ service <name> status
    $ service <name> restart
    

  * httpd 
  * nfs 
  * named (dns) (optional) 
  * tftp/tftpd (it may be running as a xinetd service if atftp-xcat was not installed) 
  * xcatd 
  * firewall disabled (all policies accepting all in `iptables -L`) 

~~~~

Check site table 

Important fields: 

  * domain: should point to the network xCAT will manage the nodes (i.e, the private network) 
  * nameservers: refer to the xCAT dns server ip (also, the private network) 
  * master: as above 
  * forwarders: the external communication 
  * dhcpinterfaces: should have the xCAT network interface 

To change the site table 
    
~~~~    
    $ chdef -t site master=192.168.0.100 domain=mine.austin.ibm.com nameservers=192.168.0.100 forwarders=9.0.7.1,9.0.6.11 dhcpinterfaces=eth1
~~~~    

To check the site table configuration 
    
~~~~    
    $ tabdump site
    ...
    "master","192.168.0.100",,
    "forwarders","9.0.7.1,9.0.6.11",,
    "nameservers","192.168.0.100",,
    "domain","mine.austin.ibm.com",,
    "dhcpinterfaces","eth1",,
    ...
    "consoleondemand","yes",,
    
~~~~
  
Check networks table 

No changes needed if the setup above was correctly performed. 
    
~~~~    
    $ tabdump networks
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,ddnsdomain,vlanid,domain,comments,disable
    "9_3_189_0-255_255_255_0","9.3.189.0","255.255.255.0","eth0","9.3.189.1",,"9.3.189.137",,,,,,,,,,
    "192_168_0_0-255_255_255_0","192.168.0.0","255.255.255.0","eth1","<xcatmaster>",,"192.168.0.100",,,,"192.168.0.1-192.168.0.99",,,,,,
 
~~~~   

Define the dynamic range for dhcp server(Optional) 

The dynamic range is only needed by the hardware discovery process, if you will not do the hardware discovery, setting dynamic range might bring in side-effects for the ip addresses assignment in the network. 
    
~~~~   
    $ chdef -t network -o 192_168_0_0-255_255_255_0 dynamicrange="192.168.0.1-192.168.0.99"
~~~~    

  
Add the default account for root, when nodes are installed. 
    
~~~~    
    $ chtab key=system passwd.username=root passwd.password=cluster
~~~~    

  
Configure the hmc node 
    
~~~~      
    $ mkdef -t node -o aphmc groups=hmc,all nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc1234
    
~~~~  
  


### Discover Hardware

We assume the virtualized partitions (LPARs) are already set using HMC (or IVM). 

Create nodes for systems and frames under the hmc. (See also stanza files for other ways to configure it. See:
[XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems/#discover-hmcsframececs-and-define-them-in-xcat-db](XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems/#discover-hmcsframececs-and-define-them-in-xcat-db)


~~~~      
    $ rscan -w aphmc5
~~~~      

Run make* scripts 
    
~~~~      
    $ makeconservercf    # enable remote console
    $ makedhcp -n        # configure dhcp server
    $ makedhcp -a
    $ makedns            # configure dns server
~~~~      

See [Debugging_xCAT_Problems] for more debugging information on those commands. 

Copy distro image to /install. You need to download the distro image (or mount it using NFS) to a directory in your disk. The example here is using RHEL6.2 (see that xCAT uses rhels6.2), and the ISO image is on /iso/ 
    
~~~~      
    $ copycds -n rhels6.2 -a ppc64 /iso/RHEL6.2-20111117.0-Server-ppc64-DVD1.iso
    $ ls /install/rhels6.2/ppc64   # verify copy was successfull
~~~~      

### Define and Configure Nodes

Add group to identify nodes that will be managed 
    
~~~~      
    $ chdef junoltc0[39] groups=cn -p 
    $ lsdef cn -i groups
    Object name: junoltc03
        groups=lpar,all,cn
    Object name: junoltc09
        groups=lpar,all,cn
~~~~      

Test if console is working for nodes 
    
~~~~      
    $ rcons junoltc03
~~~~      

See [Debugging_xCAT_Problems], if you have problems with the console 

  
Get nodes mac addresses. Attention, if you have more than one interface, you need to specify which one you need to write in the `mac` table (See `man getmacs`) 
    
~~~~      
    $ getmacs cn
    
    junoltc03: 
    #Type  Phys_Port_Loc  MAC_Address  Adapter  Port_Group  Phys_Port  Logical_Port  VLan  VSwitch  Curr_Conn_Speed
    virtualio  N/A  d2:08:3b:d6:7c:04  N/A  N/A  N/A  N/A  1  ETHERNET1  N/A
    
    junoltc09: 
    #Type  Phys_Port_Loc  MAC_Address  Adapter  Port_Group  Phys_Port  Logical_Port  VLan  VSwitch  Curr_Conn_Speed
    virtualio  N/A  d2:08:30:4d:6d:04  N/A  N/A  N/A  N/A  1  ETHERNET1  N/A
    
    $ tabdump mac
    #node,interface,mac,comments,disable
    "junoltc03",,"d2:08:3b:d6:7c:04",,
    "junoltc09",,"d2:08:30:4d:6d:04",,
    

  
End definition of nodes 
~~~~  

~~~~      
    
    $ chdef cn netboot=yaboot tftpserver=192.168.0.100 nfsserver=192.168.0.100 xcatmaster=192.168.0.100 installnic="eth1" primarynic="eth1"
~~~~      

Setup nodes for OS deployment Here, we are going to deploy RHEL6.2 
    
~~~~      
    $ chdef cn os=rhel6.2 profile=compute arch=ppc64
~~~~      

We are ready now to deploy the distro in the compute nodes! 

## Deploy the Nodes

When you ran copycds, osimage definitions for your distro were automatically created: 

~~~~      
     lsdef -t osimage
~~~~      
    

For basic operating system installations, you can use one of these images without modification. Review the contents of the files referenced by the osimage definition you choose. For image customization, see [Using_Provmethod%3Dosimagename] 

### Stateful (Diskfull) Install

Choose and review a stateful osimage definition: 
 
~~~~     
      lsdef -t osimage -o rhels6.2-ppc64-install-compute -l
~~~~      

Set node to diskfull install and run installation: 
    
~~~~      
    #TRY THIS
    $ nodeset junoltc03 osimage=rhels6.2-ppc64-install-compute
    $ lsdef junoltc03  # check all node parameters are correctly set
    ...
    $ rpower junoltc03 reset
    
    # OR THIS
    $ rinstall -O rhels6.2-ppc64-install-compute junoltc03
    
    # to follow the installation process
    $ rcons junoltc03  #run from another terminal
~~~~      

### Stateless (Diskless) Boot

You need to generate an installation image before proceeding with netbooting. Review your chosen osimage definition: 
 
~~~~     
      lsdef -t osimage -o rhels6.2-ppc64-netboot-compute -l
~~~~      

Generate and pack your diskless image: 
    
~~~~      
    $ genimage rhels6.2-ppc64-install-compute
    $ packimage rhels6.2-ppc64-install-compute
~~~~      

Set node to diskless install and network boot the node to load the image: 
    
~~~~      
    $ nodeset junoltc09 osimage=rhels6.2-ppc64-install-compute
    $ lsdef junoltc09  # check all node parameters are correctly set
    ...
~~~~  

~~~~      
    # NETWORK BOOT THE NODE:
    $ rpower junoltc09 reset
    # OR 
    $ rnetboot junoltc09
    
    # to follow the installation process
    $ rcons junoltc09  #run from another terminal
~~~~      

  
Trouble with TFTP server, console, remote installation, configuration? See [Debugging_xCAT_Problems] 

  
Complete guides: 

  * [XCAT_pLinux_Clusters]
  
