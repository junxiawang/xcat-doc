<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Pre-install](#pre-install)
  - [Network wiring](#network-wiring)
- [Install the operating system](#install-the-operating-system)
- [Install xCAT](#install-xcat)
- [Setup Networking](#setup-networking)
- [Setup the xCAT tables](#setup-the-xcat-tables)
- [Advanced features](#advanced-features)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

Directions for setting up xCAT on a Fedora 10 server, and enabling it to use kvm. 


## Pre-install

Before installing, these decisions need to be made: 

  * Internal IP of headnode - referred to as (xcat_int_ip) 
  * External IP (internet connected) of headnode - referred to as (xcat_ext_ip) 
  * External DNS server IP - referred to as (dns_ext_ip) 
  * Cluster domain - referred to as (cluster_dom) 

### Network wiring

This setup assumes your xCAT node has eth0 plugged into an existing network, connected to the internet and using DHCP. Eth1 is attached to the switch that the compute nodes are attached to. 

## Install the operating system

A basic Desktop install will do fine. Turn off the Firewall and SELinux to be able to access the node from your network (most xCAT servers are already behind a company firewall). Install all updates. 

## Install xCAT

Add the xCAT package repositories  
Note: These are for the latest snapshot release which include all the necessary features. It is expected that full support for these features will be in the xCAT 2.2 stable release. See the [Download](http://xcat.sourceforge.net/yum/download.html) page for more info. 

There is not yet a Fedora 10 repository, so we will use the redhat 5 repositroy. There is one dependancy that it does not fulfill, so it must be manually installed first: 
    
    wget http://xcat.sourceforge.net/yum/xcat-dep/fedora9/x86_64/conserver-8.1.16-8.x86_64.rpm
    rpm -i conserver-8.1.16-8.x86_64.rpm
    cd /etc/yum.repos.d
    wget http://xcat.sourceforge.net/yum/devel/core-snap/xCAT-core-snap.repo
    wget http://xcat.sourceforge.net/yum/xcat-dep/rh5/x86_64/xCAT-dep.repo
    yum clean metadata
    yum install xCAT

Verify the install 
    
    source /etc/profile.d/xcat.sh
    tabdump site

If the tabdump command works, xCAT is installed. 

## Setup Networking

Configure the Ethernet interfaces 
    
    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    
    DEVICE=eth0
    PEERDNS=no
    BOOTPROTO=dhcp
    HWADDR=00:14:5E:6B:18:21
    ONBOOT=yes
    
    ifdown eth0 && ifup eth0
    
    vi /etc/sysconfig/network-scripts/ifcfg-eth1
    
    DEVICE=eth1
    BOOTPROTO=static
    HWADDR=00:14:5E:6B:18:22
    ONBOOT=yes
    IPADDR=(xcat_int_ip)
    NETMASK=255.255.255.0
    
    ifdown eth1 && ifup eth1

Configure the site table.  
This will set the dns to forward requests for the 192.168.0.1 network, set the domain to cluster, set the master and nameserver to 192.168.0.1, and set eth1 to be the dhcp interface. 
    
    tabedit site
    
    #key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "master","10.10.10.100",,
    "domain","cluster",,
    "installdir","/install",,
    "timezone","America/Denver",,
    "nameservers","192.168.0.1",,
    "forwarders","192.168.0.1"
    "dhcpinterfaces","eth1"
    "ntpservers","0.north-america.pool.ntp.org"

Add the xCAT node and compute nodes to the hosts file 
    
    vi /etc/hosts
    10.10.10.1 xcat
    10.10.10.101 n01
    10.10.10
    ...

Setup the mac table 
    
    n01,eth0,00:11:22:33:44:55:66
    n02,eth0,00:11:22:33:44:55:67
    ...

Setup the networks table 
    
    tabedit networks

There should be an entry for each network the nodes need to access. In this case, DNS is forwarded to the 192.168.0.1 server: 
    
    tabedit networks
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,dynamicrange,nodehostname,comments,disable
    ,"10.10.10.0","255.255.255.0","eth1","10.10.10.1","10.10.10.1","10.10.10.1","192.168.0.1","10.10.10.200-10.10.10.250",,,
    ,"192.168.0.0","255.255.0.0","eth0",,,,"192.168.0.1",,,,

Build the DHCP file 
    
    makedhcp -n
    service dhcpd restart

Setup DNS  
Be sure to remove bind-chroot if you're using a centos 5.2 install  
(or any other system that uses it for that matter!)  
xCat doesn't work with bind-chroot, just the regular bind! 
    
    yum remove bind-chroot

Edit resolv.conf 
    
    vi /etc/resolv.conf
    set "search cluster"
    set "nameserver 10.10.10.1"

Build the DNS server 
    
    makedns
    service named start

## Setup the xCAT tables

The Site table - this table defines your xCAT environment 

Setup the nodelist table 
    
    tabedit nodelist
    "n01","compute,all",,,
    "n01-ipmi","ipmi,all",,,
    "n02","compute,all",,,
    ...

Setup the nodehm table 
    
    tabedit nodehm
    "n01","ipmi","ipmi",,,,,,,,,,
    "n02","ipmi","ipmi",,,,,,,,,,
    ...

Setup the noderes,passwd,chain and nodetype tables 
    
    chtab node=compute noderes.netboot=pxe noderes.tftpserver=10.10.10.100 noderes.nfsserver=10.10.10.100 noderes.installnic=eth0 noderes.primarynic=eth0
    chtab key=system passwd.username=root passwd.password=cluster
    chtab node=compute nodetype.os=centos5.2 nodetype.arch=x86_64 nodetype.profile=compute nodetype.nodetype=osi
    chtab node=compute chain.chain="runcmd=standby" chain.ondiscover=nodediscover

Setup Images -do this for the DVD and ISO and '''NOT''' the cd! 
    
    copycds CentOS-5.2-i386-bin-DVD.iso

Create the PXE boot files 
    
    mknb x86_64

Install the node! 
    
    rinstall n01

## Advanced features

To create a netboot image:  
cd /opt/xcat/share/xcat/netboot/centos  
./genimage -i eth0 -n e1000,bnx2 -o centos5.2 -p compute  
cd /install/netboot/centos5.2/x86_64/compute/rootimg/etc/  
cp fstab fstab.ORIG  
vi fstab 
    
    add these lines:

compute_x86_64 / tmpfs rw 0 1  
none /tmp tmpfs defaults,size=10m 0 2  
none /var/tmp tmpfs defaults,size=10m 0 2  


    wq  


packimage -o centos5.2 -p compute -a x86_64  
nodeset (nodename) netboot  
rpower (nodename) boot 
