<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Pre-install](#pre-install)
  - [Network wiring](#network-wiring)
- [Install the operating system](#install-the-operating-system)
- [Setup Networking](#setup-networking)
- [Install xCAT](#install-xcat)
- [Setup the xCAT tables](#setup-the-xcat-tables)
- [Advanced features](#advanced-features)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

**Note: Refer to [XCAT_iDataPlex_Cluster_Quick_Start] for a more up to date quick start guide.**

Directions for a basic xCAT server. Specificly written for **CentOS 5.2 x86_64**, but could be generalized for other installations 


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

## Setup Networking

Configure the Ethernet interfaces 
 
~~~~   
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

~~~~  


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

If the tabdump command works, xCAT is installed. If it doesn't work, check to ensure all previous steps completed sucessfully. 

Configure the site table.  
This will set the dns to forward requests for the (dns_ext_ip) network, set the domain to (cluster_dom), set the master and nameserver to (dns_et_ip), and set eth1 to be the dhcp server interface. 
 
~~~~   
    tabedit site
    
    #key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "master","(xcat_int_ip)",,
    "domain","(cluster_dom)",,
    "installdir","/install",,
    "timezone","America/Denver",,
    "nameservers","(xcat_int_ip)",,
    "forwarders","(dns_ext_ip)"
    "dhcpinterfaces","eth1"
    "ntpservers","0.north-america.pool.ntp.org"
~~~~

Setup the networks table 

~~~~    
    tabedit networks
~~~~

There should be an entry for each network the nodes need to access. In this case, DNS is forwarded to the 192.168.0.1 server: 
  
~~~~  
    tabedit networks
~~~~


~~~~     
netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,dynamicrange,nodehostname,comments,disable
    internal,"10.10.10.0","255.255.255.0","eth1","10.10.10.1","10.10.10.1","10.10.10.1","10.10.10.1",,,"10.10.10.200-10.10.10.254",,,
    external,"192.168.0.0","255.255.0.0","eth0",,,,"192.168.0.1",,,,

~~~~

## Setup the xCAT tables

These commands will insert lines into the noderes,passwd,chain and nodetype tables for a generic setup. Each table will default the the nodes group (compute). If there is a row for an individual node, those options will override the compute group options. 

~~~~    
    chdef -t group -o compute netboot=pxe tftpserver=(xcat_int_ip) nfsserver=(xcat_int_ip) installnic=eth0 primarynic=eth0
    chtab key=system passwd.username=root passwd.password=cluster
    chdef -t group -o compute os=centos5.2 arch=x86_64 profile=compute nodetype=osi
    chdef -t group -o compute chain="runcmd=standby" ondiscover=nodediscover
~~~~

Add Nodes:  
You can add nodes with one long command, or one table at a time. You can also use the chdef to change values in a table. 

One long line: 

~~~~    
    nodeadd n01 groups=compute,all mac.interface=eth0 hosts.ip=x.x.x.x mac.mac=00:00:00:00:00:00 nodehm.mgt=ipmi nodehm.power=ipmi
~~~~

Individual Tables: 

~~~~    
    tabedit hosts
    
    xcat,(xcat_int_ip)
    n01,(n01_ip)
    n02,(n02_ip)
    
    tabedit mac
    n01,eth0,(mac)
    n02,eth0,(mac)
    
    tabedit nodelist
    "n01","compute,all",,,
    "n01-ipmi","ipmi,all",,,
    "n02","compute,all",,,
    
    tabedit nodehm
    "n01","ipmi","ipmi",,,,,,,,,,
    "n02","ipmi","ipmi",,,,,,,,,,
~~~~

Create the hosts file 
 
~~~~   
    makehosts all
~~~~
  
Create the DHCP file 

~~~~    
    makedhcp -n
    makedhcp all
    service dhcpd restart
~~~~

assuming all the nodes and devices are in the "all" group, that command will work:  
_Note: dhcpd does NOT need to be restarted after adding a node via makedhcp, but does after running the "-n" option which creates a new file_

You will probably want to update your chkconfig for dhcp so that the service starts when the server boots: 
  
~~~~  
    chkconfig --level 345 dhcpd on
~~~~

Setup DNS 

  * _Note: Be sure to remove bind-chroot if you're using a centos 5.2 install (or any other system that uses it for that matter!) xCat doesn't work with bind-chroot, just the regular bind! (yum remove bind-chroot)_

Edit resolv.conf 
 
~~~~   
    vi /etc/resolv.conf
    set "search (xcat_dom)"
    set "nameserver (xcat_int_ip)"
~~~~

Build the DNS server 
    
    makedns
    makedns all
    service named restart

assuming all the nodes and devices are in the "all" group, this command will work:  
_Note: named DOES need to be restarted after running a makedns command_

Update chkconfig: 
 
~~~~   
    chkconfig --level 345 named on
~~~~

If you want your nodes to be able to route to the Internet through the headnode, run these two lines of code to enable masquerading: 

~~~~    
    echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/rc.local
    echo "echo 1 < /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
~~~~

Then, run /etc/rc.local to have the change take effect, or reboot. 

  
The xCAT server should now be completely configured. 

Setup Images 

  * Note: Do this for the DVD ISO and '''NOT''' the cd!
   
~~~~
    copycds CentOS-5.2-i386-bin-DVD.iso
~~~~

Install the node! 

~~~~
    
    rinstall n01
~~~~

## Advanced features

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
    packimage -o centos5.2 -p compute -a x86_64
    nodeset (nodename) netboot
    rpower (nodename) boot
~~~~
