<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Assumptions](#assumptions)
- [Network setup](#network-setup)
- [Install the operating system](#install-the-operating-system)
- [Install xCAT](#install-xcat)
- [Setup the xCAT tables](#setup-the-xcat-tables)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning) 

This page gives directions for creating an xCAT server that utilizes your networks existing DHCP/DNS server. These directions are specific to CentOS 5.2 x86_64, but could be generalized for other installations 


## Assumptions

In this tutorial, the following assumptions are made: 

  * IP of dhcp/nameserver is 10.10.10.1 
  * IP of headnode (xcat) is 10.10.10.100 

## Network setup

This setup assumes your xcat node has eth0 plugged into your network, along with the compute nodes. 

## Install the operating system

A basic Desktop install will do fine. Turn off the Firewall and SELinux to be able to access the node from your network 

## Install xCAT

Add the xCAT package repositories  
Note: These are for the current release. See the [Download](http://xcat.sourceforge.net/yum/download.html) page for the location of the latest snapshot repo, and other operating systems. 
 
~~~~   
    cd /etc/yum.repos.d
    wget http://xcat.sourceforge.net/yum/xcat-core/xCAT-core.repo
    wget http://xcat.sourceforge.net/yum/xcat-dep/rh5/x86_64/xCAT-dep.repo
    yum clean metadata
    yum install xCAT
~~~~

Verify the install 

~~~~
    
    source /etc/profile.d/xcat.sh
    tabdump site
~~~~

If the tabdump command works, xCAT is installed. 

Enter the nodes into your DHCP and DNS servers unless they are already there. This requires the MAC addresses of all the nodes, and should assign them names and static IPs. You will also need the MAC addresses for the mac table, so that xCAT can identify them as it PXE boots them. 

## Setup the xCAT tables

The Site table - this table defines your xCAT environment  
The default values will probably look just like this: 
    
    tabdump site
    
    #key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "master","10.10.10.100",,
    "domain","cridomain",,
    "installdir","/install",,
    "timezone","America/Denver",,
    "nameservers","10.10.10.1",,

Setup the nodelist table 
    
    tabedit nodelist
    "n01","compute,all",,,
    "n01-ipmi","ipmi,all",,,
    "n02","compute,all",,,
    ...

Setup the mac table 
    
    n01,eth0,00:11:22:33:44:55:66
    n02,eth0,00:11:22:33:44:55:67
    ...

Setup the nodehm table 
    
    tabedit nodehm
    "n01","ipmi","ipmi",,,,,,,,,,
    "n02","ipmi","ipmi",,,,,,,,,,
    ...

Setup the noderes,passwd,chain and nodetype tables 
    
    chdef -t group -o compute netboot=pxe tftpserver=10.10.10.100 nfsserver=10.10.10.100 installnic=eth0 primarynic=eth0
    chtab key=system passwd.username=root passwd.password=cluster
    chdef -t group -o compute os=centos5.2 arch=x86_64 profile=compute nodetype=osi
    chdef -t group -o compute chain="runcmd=standby" ondiscover=nodediscover

The networks table should look similar to this by default: 
    
    tabedit networks
     ,"10.10.10.0","255.255.255.0","eth0",,,"10.10.10.100","10.10.10.1",,,,

Setup Images 

do this for the DVD and '''NOT''' the cd! 
 
~~~~   
    copycds CentOS-5.2-i386-bin-DVD.iso
    mknb x86_64
~~~~

Install the node 
  
~~~~  
    rinstall n01
~~~~

  
To create a netboot image: 

~~~~ 
cd /opt/xcat/share/xcat/netboot/centos  
./genimage -i eth0 -n e1000,bnx2 -o centos5.2 -p compute  
cd /install/netboot/centos5.2/x86_64/compute/rootimg/etc/  
cp fstab fstab.ORIG  
vi fstab 
~~~~
    
add these lines:

~~~~

compute_x86_64 / tmpfs rw 0 1  
none /tmp tmpfs defaults,size=10m 0 2  
none /var/tmp tmpfs defaults,size=10m 0 2  
~~~~    

Now run these commands

~~~~
packimage -o centos5.2 -p compute -a x86_64  
nodeset (nodename) netboot  
rpower (nodename) boot 
~~~~
