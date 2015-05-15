<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Prerequisite](#prerequisite)
- [Connect to xcatd Through IPv6](#connect-to-xcatd-through-ipv6)
- [Configure IPv6 Addresses and Gateway on the Compute Nodes for Ethernet Adapters](#configure-ipv6-addresses-and-gateway-on-the-compute-nodes-for-ethernet-adapters)
- [Configure IPv6 Addresses on the Compute Nodes for InfiniBand Adapters](#configure-ipv6-addresses-on-the-compute-nodes-for-infiniband-adapters)
- [Configure IPv6 Routing on the Compute Nodes](#configure-ipv6-routing-on-the-compute-nodes)
- [Setup the Ipforward for IPv6 on MN](#setup-the-ipforward-for-ipv6-on-mn)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


Note: this doc only works for xCAT 2.8.1 and above and on a  Linux cluster.

IPv6 support on Ubuntu is not covered by this doc.


## Overview

This doc indicates how to configure IPv6 in xCAT cluster, the high level logic of using IPv6 in xCAT cluster is: 

  * xcat clients can connect to xcatd on the management node using ipv6 
  * The os provisioning is done through ipv4 network. 
  * The ethernet adapters and Infiniband adapters on the compute nodes could be configured with ipv4 only, or ipv6 only, or both 
  * The compute nodes could use ipv6 default gateway to communicate with the external ipv6 nodes. 
  * The compute nodes could be configured to communicate with different ipv6 subnets through different gateway. 
  * The management node should have ipv6 forwarding enabled in case the compute nodes will use the management node as the ipv6 gateway. 

The specific support xcat needs to provide: 

  * xcatd accepts connections through IPv6 
  * Use makehosts command to setup IPv6 hostnames in /etc/hosts 
  * Use confignics postscript to configure the IPv6 addresses on the compute nodes, for both Ethernet and Infiniband 
  * Use confignics postscript to configure IPv6 gateway on the compute nodes, for both Ethernet and Infiniband 
  * Use makeroutes to configure IPv6 routing on the compute nodes, for both Ethernet and Infiniband 
  * xcatconfig will configure IPv6 forwarding if there is any non-link-local IPv6 network setup on the management node. 

## Prerequisite

To configure IPv6 environment, the perl IPv6 packages need to be installed on the management node: 

~~~~    
     yum install perl-IO-Socket-INET6 perl-IO-Socket-SSL perl-Socket6
     service xcatd stop
     service xcatd start
~~~~    

## Connect to xcatd Through IPv6

The xCAT remote clients, usually on the login nodes, could connect to the xcatd on the management node. There are not too many differences between connecting to xcatd through IPv4 address and IPv6 address, you could refer to [Granting_Users_xCAT_privileges/#setup-login-node-remote-client](Granting_Users_xCAT_privileges/#setup-login-node-remote-client) for details on how to setup remote client, here is the summarized procedure of setting up remote client and connecting to xcatd through IPv6: 

1\. Install required packages on remote client, including perl-xCAT-*, xCAT-client-* from xcat-core and perl-IO-Socket-SSL*, perl-Net-SSLeay-*, perl-DBI-* from xcat-dep. 

2\. Setup credentials on the remote client. For root user, simply copy the ~/.xcat from the management node; for non-root user, run command /opt/xcat/share/xcat/scripts/setup-local-client.sh &lt;username&gt; as root on the management node, then copy the ~/.xcat from the management node to remote clients. 

3\. Use environment variable XCATHOST to specify the machine that runs xcatd. The basic syntax of XCATHOST is &lt;nodename or ipaddr&gt;:3001, there are some variants with using IPv6 addresses, and here are some examples: 

Connect to xcatd through global IPv6 address: 

~~~~    
     export XCATHOST=[fd57:faaf:e1ab:336:21a:64ff:fee5:aaa]:3001
     nodels
~~~~    

  * Connect to xcatd through link local IPv6 address: 

~~~~    
     export XCATHOST=[fe80::21a:64ff:fe02:c4%eth0]:3001   # the %eth0 indicates the outbound interface 
     nodels
~~~~    

  * Connects to xcatd through the the global IPv6 hostname: 

~~~~    
     export XCATHOST=mn-ipv6-global:3001
     nodels
~~~~    

  * Connects to xcatd through the link local IPv6 hostname: 

~~~~    
     export XCATHOST=mn-ipv6-ll%eth0:3001    # the %eth0 indicates the outbound interface 
     nodels
~~~~    

## Configure IPv6 Addresses and Gateway on the Compute Nodes for Ethernet Adapters

1\. Plan the IPv6 addresses for the compute nodes 

For the IPv6 addresses allocation, there are two choices: either defining the ip addresses in the nics table manually, or use the DHCPv6/RA to assign dynamic IPv6 addresses and use ddns to map the hostnames and nic. Setting up the DHCPv6/RA to assign IPv6 addresses is beyond the scope of this doc, this doc will only cover the first scenario, i.e., defining the ip addresses in the nics table manually. 

2\. Specify the node ip addresses and gateway configuration in nics table. 

Here is an example on how to configure the IPv4/IPv6 addresses for the Ethernet adapters in the nics table. 

~~~~    
     [root@ls21n01 ~]# tabdump nics
     #node,nicips,nichostnamesuffixes,nictypes,niccustomscripts,nicnetworks,nicaliases,comments,disable
     "ipv6cn1","eth0!10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b,eth1!11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b,eth2!12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b","eth0!|-eth0-ipv6-1|-eth0-ipv6-2,eth1!-eth1|-eth1-ipv6-1|-eth1-ipv6-2,eth2!-eth2|-eth2-ipv6-1|-eth2-ipv6-2","eth0!Ethernet,eth1!Ethernet,eth2!Ethernet",,"eth0!10_1_0_0-255_255_0_0|fd56::/64|2000::/64,eth1!11_1_0_0-255_255_0_0|fd57::/64|2001::/64,eth2!12_1_0_0-255_255_0_0|fd58::/64|2002::/64",,,
       
~~~~    

3\. Add network entries for the nics in the networks table 

~~~~    
     [root@ls21n01 ~]# tabdump networks
     #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
     "10_1_0_0-255_255_0_0","10.1.0.0","255.255.0.0","eth1","<xcatmaster>",,"10.1.0.218",,,,,,,,,,"clusters.com",,
     "11_1_0_0-255_255_0_0","11.1.0.0","255.255.0.0","eth1",,,,,,,,,,,,,"clusters.com",,
     "12_1_0_0-255_255_0_0","12.1.0.0","255.255.0.0","eth1",,,,,,,,,,,,,"clusters.com",,
     "fd56::/64","fd56::/64","/64","eth0","fd56::214:5eff:fe15:1",,,,,,,,,,,,"clusters.com",,
     "fd57::/64","fd57::/64","/64","eth1",,,,,,,,,,,,,"clusters.com",,
     "fd58::/64","fd58::/64","/64","eth2",,,,,,,,,,,,,"clusters.com",,
     "2000::/64","2000::/64","/64","eth0",,,,,,,,,,,,,"clusters.com",,
     "2001::/64","2001::/64","/64","eth1",,,,,,,,,,,,,"clusters.com",,
     "2002::/64","2002::/64","/64","eth2",,,,,,,,,,,,,"clusters.com",,
      
~~~~    

In this example, the fd56::214:5eff:fe15:1 is used as the IPv6 default gateway for the compute node ipv6cn1. Please be aware that only one IPv6 default gateway could be specified, if you would like to setup different gateways for different IPv6 subnets, see the section "**Configure IPv6 routing on the compute nodes**" for more details. 

4\. Setup /etc/hosts for the IPv6 entries 

The makehosts is able to setup both the IPv4 hostnames and IPv6 hostnames in /etc/hosts based on information stored in the nics table, here is an example: 

4.1. Run makehosts to setup the IPv6 entries in /etc/hosts 

~~~~    
     makehosts ipv6cn1
~~~~    

4.2. Check the IPv6 entries are setup correctly in /etc/hosts 

~~~~    
     [root@ls21n01 ~]# cat /etc/hosts | grep ipv6cn1
     12.1.89.7 ipv6cn1-eth2 ipv6cn1-eth2.clusters.com  
     fd58::214:5eff:fe15:849b ipv6cn1-eth2-ipv6-1 ipv6cn1-eth2-ipv6-1.clusters.com  
     2002::214:5eff:fe15:849b ipv6cn1-eth2-ipv6-2 ipv6cn1-eth2-ipv6-2.clusters.com  
     11.1.89.7 ipv6cn1-eth1 ipv6cn1-eth1.clusters.com  
     fd57::214:5eff:fe15:849b ipv6cn1-eth1-ipv6-1 ipv6cn1-eth1-ipv6-1.clusters.com  
     2001::214:5eff:fe15:849b ipv6cn1-eth1-ipv6-2 ipv6cn1-eth1-ipv6-2.clusters.com  
     10.1.89.7 ipv6cn1 ipv6cn1.clusters.com  
     fd56::214:5eff:fe15:849b ipv6cn1-eth0-ipv6-1 ipv6cn1-eth0-ipv6-1.clusters.com  
     2000::214:5eff:fe15:849b ipv6cn1-eth0-ipv6-2 ipv6cn1-eth0-ipv6-2.clusters.com  
    
~~~~    

5\. Configure IPv4/IPv6 addresses and IPv6 default gateway on the compute node 

The postscript **confignics** can configure the IPv4 and IPv6 addresses and gateway on the compute nodes. It could be called through whatever possible ways: 

5.1 Setup the IPv4/IPv6 addresses and IPv6 default gateway on the compute node during operating system provisioning 
  
~~~~  
     chdef ipv6cn1 -p postscripts=confignics
     or
     chdef ipv6cn1 -p postscripts="confignics -s"
~~~~    

The "-s" flag specified with confignics indicates that the installation nic should be setup as static configuration using the information in the nics table. 
    
     nodeset ipv6cn1 osimage=xxx
     rpower ipv6cn1 reset
    

5.2 Setup the IPv4/IPv6 addresses and IPv6 default gateway on the compute node through updatenode 
 
~~~~   
     updatenode ipv6cn1 -P confignics
     or
     updatenode ipv6cn1 -P "confignics -s"
~~~~    

  
The "-s" flag specified with confignics indicates that the installation nic should be setup as static configuration using the information in the nics table. 

6\. Verify the configuration on the compute nodes 

When the confignics finishes setup the IPv4 and IPv6 addresses and gateway on the compute nodes, the following commands could be used to verify the configuration: 
 
~~~~   
     [root@ipv6cn1 ~]# ifconfig
     eth0    Link encap:Ethernet  HWaddr 42:C6:0A:01:59:07  
             inet addr:10.1.89.7  Bcast:10.1.255.255  Mask:255.255.0.0
             inet6 addr: 2000::214:5eff:fe15:849b/64 Scope:Global
             inet6 addr: fd56::214:5eff:fe15:849b/64 Scope:Global
             inet6 addr: fe80::40c6:aff:fe01:5907/64 Scope:Link
             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
             RX packets:14663 errors:0 dropped:0 overruns:0 frame:0
             TX packets:959 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000 
             RX bytes:1053278 (1.0 MiB)  TX bytes:130254 (127.2 KiB)
     
     eth1    Link encap:Ethernet  HWaddr 42:56:0A:01:59:07  
             inet addr:11.1.89.7  Bcast:11.1.255.255  Mask:255.255.0.0
             inet6 addr: fd55:faaf:e1ab:336:4056:aff:fe01:5907/64 Scope:Global
             inet6 addr: fe80::4056:aff:fe01:5907/64 Scope:Link
             inet6 addr: 2001::214:5eff:fe15:849b/64 Scope:Global
             inet6 addr: fd57::214:5eff:fe15:849b/64 Scope:Global
             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
             RX packets:12833 errors:0 dropped:0 overruns:0 frame:0
             TX packets:21 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000 
             RX bytes:824536 (805.2 KiB)  TX bytes:1642 (1.6 KiB)
     
     eth2    Link encap:Ethernet  HWaddr 42:0D:0A:01:59:07  
             inet addr:12.1.89.7  Bcast:12.1.255.255  Mask:255.255.0.0
             inet6 addr: 2002::214:5eff:fe15:849b/64 Scope:Global
             inet6 addr: fd58::214:5eff:fe15:849b/64 Scope:Global
             inet6 addr: fe80::400d:aff:fe01:5907/64 Scope:Link
             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
             RX packets:34 errors:0 dropped:0 overruns:0 frame:0
             TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000 
             RX bytes:3696 (3.6 KiB)  TX bytes:1226 (1.1 KiB)
~~~~
    

  

~~~~    
     [root@ipv6cn1 ~]# ip -6 route show  default
     default via fd56::214:5eff:fe15:1 dev eth0  metric 1  mtu 1500 advmss 1440 hoplimit 4294967295
     default via fe80::226:88ff:fe57:b7f0 dev eth1  proto kernel  metric 1024  expires 0sec mtu 1500 advmss 1440 hoplimit 64
~~~~
     
    

## Configure IPv6 Addresses on the Compute Nodes for InfiniBand Adapters

Here is an example on how to configure the IPv4/IPv6 addresses for the Infiniband adapters using the nics table. 

~~~~    
     [root@ls21n01 ~]# tabdump nics
     "dx360m3n06","ib0!11.1.89.10|21.1.89.10|fd57::214:5eff:fe15:8496|2000::214:5eff:fe15:8496,ib1!12.1.89.10|22.1.89.10|fd58::214:5eff:fe15:8496|2001::214:5eff:fe15:8496","ib0!-ib0|-ib0-2|-ib0-ipv6-1|-ib0-ipv6-2,ib1!-ib1|-ib1-2|-ib1-ipv6-1|-ib1-ipv6-2","ib0!Infiniband,ib1!Infiniband",,"ib0!11_1_0_0-255_255_0_0|21_1_0_0-255_255_0_0|fd57::/64|2000::/64,ib1!12_1_0_0-255_255_0_0|22_1_0_0-255_255_0_0|fd58::/64|2001::/64",,,
~~~~
      
    

3\. Add network entries for the nics in the networks table 

~~~~    
     [root@ls21n01 ~]# tabdump networks
     #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
     "11_1_0_0-255_255_0_0","11.1.0.0","255.255.0.0","ib0",,,,,,,,,,,,,"clusters.com",,
     "21_1_0_0-255_255_0_0","21.1.0.0","255.255.0.0","ib0",,,,,,,,,,,,,"clusters.com",,
     "12_1_0_0-255_255_0_0","12.1.0.0","255.255.0.0","ib1",,,,,,,,,,,,,"clusters.com",,
     "22_1_0_0-255_255_0_0","22.1.0.0","255.255.0.0","ib1",,,,,,,,,,,,,"clusters.com",,
     "fd57::/64","fd57::/64","/64","ib0",,,,,,,,,,,,,"clusters.com",,
     "fd58::/64","fd58::/64","/64","ib1",,,,,,,,,,,,,"clusters.com",,
     "2000::/64","2000::/64","/64","ib0",,,,,,,,,,,,,"clusters.com",,
     "2001::/64","2001::/64","/64","ib1",,,,,,,,,,,,,"clusters.com",,
~~~~
    

4\. Setup /etc/hosts for the Infiniband IPv6 entries 

The makehosts is able to setup both the IPv4 hostnames and IPv6 hostnames in /etc/hosts based on information stored in the nics table, here is an example: 

4.1. Run makehosts to setup the IPv6 entries in /etc/hosts 
   
~~~~ 
     makehosts dx360m3n06
~~~~    

4.2. Check the IPv6 entries are setup correctly in /etc/hosts 
  
~~~~  
     [root@ls21n01 ~]# cat /etc/hosts | grep dx360m3n06
     10.1.0.236 dx360m3n06.clusters.com dx360m3n06
     12.1.89.10 dx360m3n06-ib2 dx360m3n06-ib2.clusters.com 
     22.1.89.10 dx360m3n06-ib2-2 dx360m3n06-ib2-2.clusters.com 
     fd58::214:5eff:fe15:8496 dx360m3n06-ib2-ipv6-1 dx360m3n06-ib2-ipv6-1.clusters.com 
     2001::214:5eff:fe15:8496 dx360m3n06-ib2-ipv6-2 dx360m3n06-ib2-ipv6-2.clusters.com 
     11.1.89.10 dx360m3n06-ib1 dx360m3n06-ib1.clusters.com 
     21.1.89.10 dx360m3n06-ib1-2 dx360m3n06-ib1-2.clusters.com 
     fd57::214:5eff:fe15:8496 dx360m3n06-ib1-ipv6-1 dx360m3n06-ib1-ipv6-1.clusters.com 
     2000::214:5eff:fe15:8496 dx360m3n06-ib1-ipv6-2 dx360m3n06-ib1-ipv6-2.clusters.com 
~~~~
    

5\. Configure IPv4/IPv6 addresses for the Infiniband adapters 

The postscript **confignics** can configure the IPv4 and IPv6 addresses for the Infiniband adapters. It could be called through whatever possible ways: 

5.1 Setup the IPv4/IPv6 addresses for the Infiniband adapters during operating system provisioning 
 
~~~~   
     chdef dx360m3n06 -p postscripts=confignics
    
    
     nodeset ipv6cn1 osimage=xxx
     rpower ipv6cn1 reset
~~~~    

5.2 Setup the IPv4/IPv6 addresses and IPv6 default gateway on the compute node through updatenode 

~~~~    
     updatenode ipv6cn1 -P confignics
~~~~    
    

6\. Verify the configuration on the compute nodes 

When the confignics finishes setup the IPv4 and IPv6 addresses for the Infiniband adapters, the following commands could be used to verify the configuration: 
  
~~~~  
     [root@dx360m3n06 ~]# ip addr show dev ib0
     9: ib0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65520 qdisc pfifo_fast state UP qlen 1024
       link/infiniband 80:00:00:48:fe:80:00:00:00:00:00:01:00:02:c9:03:00:4e:47:cf brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
       inet 11.1.89.10/16 brd 11.1.255.255 scope global ib0
       inet 21.1.89.10/16 brd 21.1.255.255 scope global ib0:2
       inet6 2000::214:5eff:fe15:8496/64 scope global 
          valid_lft forever preferred_lft forever
       inet6 fd57::214:5eff:fe15:8496/64 scope global 
          valid_lft forever preferred_lft forever
       inet6 fe80::202:c903:4e:47cf/64 scope link 
          valid_lft forever preferred_lft forever
     [root@dx360m3n06 ~]# ip addr show dev ib1
     10: ib1: <BROADCAST,MULTICAST,UP> mtu 65520 qdisc pfifo_fast state UNKNOWN qlen 1024
       link/infiniband 80:00:00:49:fe:80:00:00:00:00:00:00:00:02:c9:03:00:4e:47:d0 brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
       inet 12.1.89.10/16 brd 12.1.255.255 scope global ib1
       inet 22.1.89.10/16 brd 22.1.255.255 scope global ib1:2
       inet6 2001::214:5eff:fe15:8496/64 scope global tentative 
          valid_lft forever preferred_lft forever
       inet6 fd58::214:5eff:fe15:8496/64 scope global tentative 
          valid_lft forever preferred_lft forever
~~~~
     
    

**Note: xCAT only covers the IPoIB IPv6 configuration on the compute nodes from the IP layer perspective, the IPv6 in IPoIB configuration depends on the Infiniband IPv6 support structure, like Infiniband switches, operating systems and device drivers, you might need to do more configuration for IPv6 work in IPoIB environment, or even worse, it is possible the IPv6 could not work with some specific IPoIB configuration.**

## Configure IPv6 Routing on the Compute Nodes

The IPv6 routing setup on the compute nodes follows the same procedure as the IPv6 routing setup. 

1\. Add the network routes in the routes table 
 
~~~~   
     [root@ls21n01 ~]# tabdump routes
     #routename,net,mask,gateway,ifname,comments,disable
     "13route","13.1.0.0","255.255.0.0","11.1.89.1",,,
     "14route","14.1.0.0","255.255.0.0","12.1.89.1",,,
     "fd59route","fd59::/64","/64","fd56::214:5eff:fe15:1","eth0",,
     
~~~~    

2\. Associate the routes to the compute nodes 
 
~~~~   
     [root@ls21n01 ~]# chdef ipv6cn1 routenames=13route,14route,fd59route
     1 object definitions have been created or modified.
~~~~
      
    

3\. Setup up the routing 

To setup the routes on the management node: 
 
~~~~   
     makeroutes -r 13route,14route,fd59route
~~~~    

To setup the routes on the compute nodes during operating system provisioning: 

~~~~    
     chdef ipv6cn1 -p postscripts=setroute
     nodeset ipv6cn1 osimage
     rpower ipv6cn1 reset
~~~~    

To setup the routes on the compute nodes when the compute nodes are up and running: 

~~~~    
     makeroutes ipv6cn1 -r 13route,14route,fd59route
~~~~    

To remove the routes on the management node: 

~~~~    
     makeroutes -d -r 13route,14route,fd59route
~~~~    

To remove the routes on the compute nodes: 

~~~~    
     makeroutes ipv6cn1 -d -r 13route,14route,fd59route
~~~~    

4\. Verify the routing setup 

When the makeroutes finishes the routes setup on the management node or compute nodes, the following commands could be used to verify the routes setup. 
 
~~~~   
     [root@ipv6cn1 ~]# ip route show
     14.1.0.0/16 via 12.1.89.1 dev eth2 
     12.1.0.0/16 dev eth2  proto kernel  scope link  src 12.1.89.7 
     10.1.0.0/16 dev eth0  proto kernel  scope link  src 10.1.89.7 
     13.1.0.0/16 via 11.1.89.1 dev eth1 
     169.254.0.0/16 dev eth0  scope link  metric 1002 
     169.254.0.0/16 dev eth1  scope link  metric 1003 
     169.254.0.0/16 dev eth2  scope link  metric 1004 
     11.1.0.0/16 dev eth1  proto kernel  scope link  src 11.1.89.7 
~~~~
     
    
~~~~    
     [root@ipv6cn1 ~]# ip -6 route show fd59::/64
     fd59::/64 via fd56::214:5eff:fe15:1 dev eth0  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
~~~~
     
    

On RedHat: 

~~~~    
     [root@ipv6cn1 ~]# cat /etc/sysconfig/static-routes
     # xCAT_CONFIG_START
     any net 13.1.0.0 netmask 255.255.0.0 gw 11.1.89.1 
     any net 14.1.0.0 netmask 255.255.0.0 gw 12.1.89.1 
     # xCAT_CONFIG_END
     [root@ipv6cn1 ~]# cat /etc/sysconfig/static-routes-ipv6 
     # xCAT_CONFIG_START
     eth0 fd59::/64 fd56::214:5eff:fe15:1
     # xCAT_CONFIG_END
~~~~
     
    

On SLES: 

~~~~    
     ipv6cn2:~ # cat /etc/sysconfig/network/routes 
     default fd56::214:5eff:fe15:1 - -
     # xCAT_CONFIG_START
     13.1.0.0 11.1.89.1 255.255.0.0
     14.1.0.0 12.1.89.1 255.255.0.0 
     fd59::/64 fd56::214:5eff:fe15:1 - -
     # xCAT_CONFIG_END
     
~~~~    

## Setup the Ipforward for IPv6 on MN

If there is any IPv6 network entry is defined in the networks table, when the xCAT is installed on the management node, the IPv6 forwarding will be enabled. 

To check the IPv6 forwarding on the management node: 
 
~~~~   
     [root@ls21n01 ~]# cat /etc/sysctl.conf | grep net.ipv6.conf.all.forwarding
     net.ipv6.conf.all.forwarding = 1
     [root@ls21n01 ~]# cat /proc/sys/net/ipv6/conf/all/forwarding
     1
~~~~
     
    

Note: this is a temporary solution, in some future xCAT release, the network services setup on the management node will be based on the information in the servicenode table.
