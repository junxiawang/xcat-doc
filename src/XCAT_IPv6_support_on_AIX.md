<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [XCAT IPv6 support on AIX](#xcat-ipv6-support-on-aix)
- [1\. Feature restrictions in IPv6 environment](#1%5C-feature-restrictions-in-ipv6-environment)
- [2\. External Differences](#2%5C-external-differences)
- [2.1 IP addresses allocation](#21-ip-addresses-allocation)
- [2.2 bootp boot vs tftp boot](#22-bootp-boot-vs-tftp-boot)
- [2.3 NIM master initialization](#23-nim-master-initialization)
- [2.4 NIM resources](#24-nim-resources)
- [2.5 sshd configuration](#25-sshd-configuration)
- [2.6 networks table](#26-networks-table)
- [2.7 Considerations for IPv4 and IPv6 mixed cluster](#27-considerations-for-ipv4-and-ipv6-mixed-cluster)
- [3\. References](#3%5C-references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## XCAT IPv6 support on AIX

This documentation illustrates how to configure and use the xCAT in IPv6 environment on AIX. The xCAT IPv6 configuration on Linux will be described in a different document. 

We have tried to support all the xCAT features in IPv6 environment, but it turned out that some of the xCAT features can not work in IPv6 environment due to various reasons, such as the xCAT prerequisite library does not support IPv6; we have tried to keep the IPv6 configuration steps to be as similar as the IPv4 configuration, but there are still some differences. This documentation will focus on: 1) xCAT features limitation in IPv6 environment. 2) the differences between IPv4 configuration and IPv6 configuration. We assume the readers for this documentation are familiar with general xCAT configuration and have xCAT knowledge in IPv4 environment, the same configurations steps for both the IPv4 and IPv6 environment will NOT be covered in this documentation. 

  


## 1\. Feature restrictions in IPv6 environment

1)Hardware discovery: the openslp package being used by xCAT does not support IPv6, the first openslp version that supports IPv6 is openslp 1.3.0, however, xCAT is still using openslp 1.2.1, porting the xCAT patches for openslp to a newer openslp version needs a huge amount of work, we could not cover this in xCAT 2.5, will leave the hardware discovery support in IPv6 environment on xCAT 2.6 or later. 

2)renergy: renergy relies on several open source libraries... 

3)Infiniband support: needs to make sure the IB switches support IPv6, but some of the IB scripts will be run on compute nodes and the IB scripts are written in Perl. Note: Brian Croswell mentioned that some other teams are using IB in IPv6 environment, so there should not be significant problems. 

4)autogpfsd: Not sure about the background and how to use this add-on, so do not change this add-on to support IPv6. 

5)getmacs –arp is not supported in IPv6 environment, the arp is only for IPv4, the protocol NDP(Neighbor Discovery Protocol) can be used to show the mapping between MAC address and IPv6 address. Maybe will add the ndp as the getmacs method for IPv6 in the future, but not in the first pass. Here is an example: -bash-3.2# ndp -a e115v3p6n04 (4000::186) at link#3 0:14:5e:c8:5c:8c [ethernet] hv32lpar06 (fe80::221:5eff:fea3:76b0) at link#3 0:21:5e:a3:76:b0 [ethernet] e96m5sq02 (fe80::bc38:50ff:fe00:2005) at link#1 0:0:0:0:0:0 [loopback] permanent -bash-3.2# 

6)IPv6 on Power blades are not supported in this first pass?? 

7)hierarchy will not be supported in xCAT 2.5, the mysql does not support IPv6 and we are investigating to use postgresql as an alternative for mysq. 

8)Cross subnet NIM installation will not be supported in xCAT 2.5 

9)The management node has to use the same IP version to communicate with all the compute nodes, i.e., IPv4 or IPv6, the managment node can not communicate with some compute nodes through IPv4 and communicate with some other nodes through IPv6. However, the compute nodes can have secondary adapters configured with different IP versions than the adapter communicating with the managment node, the secondary ip addresses can be configured using postscripts such as configeth. 

Note: AIX user in xCAT 2.8.3 or later should use postscript configeth_aix instead of configeth. 

## 2\. External Differences

## 2.1 IP addresses allocation

AIX team indicates that if the NIM master and the NIM clients are in the same subnet, then only the link local address will work. And it seems for me that we can not have both link local address and global unicast ip address configured on the same interface. So it implies that we can only use link local address in cluster. The link local addresses starts with binary 1111 1110 10. The link local addresses can be configured automatically using command autoconf6 -6i &lt;interface_name&gt;, and the link local address can be calculated using MAC address, a script /opt/xcat/share/xcat/tools/mac2linklocal is now being shipped with xCAT that can be used to calculate the link local address from mac address. Here is the IPv6 assignment table from whitepaper “IPv6 on AIX 5L”: 

[[img src=ipv6addr.jpg]] 

Since the link local address is calculated from the MAC address, so the administrator can not assign the link local addresses in advance. Calculating and inputting the link local addresses one by one is not easy and is not an acceptable way. A new flag “-m” will be added to the makehost command, the makehosts -m will pdates /etc/hosts file with IPv6 link local addresses, and the link local addresses are generated from the mac addresses stored in mac table. 

## 2.2 bootp boot vs tftp boot

In IPv4 environment, the openfirmware uses bootp protocol to boot the node through network; however, in IPv6 environment, openfirmware uses tftp boot, all the parameters client ip address, server ip address, gateway ip address and the tftp file need to be specified with the openfirmware boot command or through SMS, the openfirmware will not send bootp request to the NIM master. Here is an example of IPv6 tftp boot setup in SMS: 

1\. Client IP Address [FE80::221:5EFF:fEA3:76B0] 

2\. Server IP Address [FE80::BC38:50FF:FE00:2005] 

3\. Gateway Link Local IP Address [FE80::BC38:50FF:FE00:2005] 

4\. Full TFTP Filename [hv32lpar06] 

Please be aware that the tftp boot gateway must be an IPv6 link local address, so when creating the networks table, the gateway should be an IPv6 link local address also. 

## 2.3 NIM master initialization

Unlike the NIM master initialization in IPv4 environment, the NIM master initialization in IPv6 environment is more complicated, the script nim_master_setup does not support IPv6, we need to use several separate AIX and NIM commands to initialize the NIM master in IPv6 environment. The mknimimage command will take care of the IPv6 NIM master initialization, if you would like to initialize the IPv6 NIM master manually, refer to the following steps: 

a.Start ndp service: 

  1. startsrc -s ndpd-host 

b.Configure nfs domain for nfs version 4 

  1. chnfsdom cluster.com 
  2. stopsrc -g nfs 
  3. startsrc -g nfs 

c.Install filesets bos.sysmgt.nim.master bos.sysmgt.nim.spot 

  1. installp -FacqXY -d /61H bos.sysmgt.nim.master bos.sysmgt.nim.spot 

d. Initiate nim master 

  1. nimconfig -aplatform=chrp -anetboot_kernel=64 -acable_type=N/A -a netname=master -apif_name=en0 

e.Configure nim master 

  1. nim -o change -a global_export=yes master 
  2. nim -o change -a nfs_domain=clusters.com master 

f.Create IPv6 network objects 

  1. nim -o define -t ent6 -a net_addr=2000:: -a routing1="default fe80::21a:64ff:fe45:e950" network6 

g.Add an IPv6 interface to master 

  1. nim -o change -a if2="network6 hv32lpar06 fe80::21a:64ff:fe45:e950" -a cable_type2=N/A master 

## 2.4 NIM resources

The concepts of the NIM resources in IPv6 environment are the same as the IPv4 configuration, but there are some configuration differences, the NIM resources in IPv6 environment need to support NFS version 4. 

To create the NIM resources with NFSv4 capability, one additional attribute “-a nfs_vers=4” is required when creating the NIM resources, I have tried to change the existing NIM resources to support NFS version 4 through SMIT and NIM commands but failed, the resources are shown with nfs_vers=4 but the NIM client can not mount these resources exports, I am not exactly sure if it is an AIX problem or more configuration steps are needed, so let's specify the “-a nfs_vers=4” when creating any NIM resources in IPv6 environment. The NIM resources are created in several ways, the lpp_source, spot, bosinst_data are created by mknimimage command, the xcataixscript is created by nimnodeset command, and the installp_bundle xCATaixSSL and xCATaixSSL are created manually. 

mknimimage will take care of the NFS version 4 support for resources lpp_source, spot, bosinst_data and NIM script. And the nimnodeset will take care of NFS version 4 support for resource xcataixscript. The following commands can be used to enable the NFS version 4 support for installp_bundle xCATaixSSL and xCATaixSSL. 

_nim -o define -t installp_bundle -a server=master -a nfs_vers=4 -a location=/install/nim/installp_bundle/xCATaixSSL.bnd xCATaixSSL_

nim -o define -t installp_bundle -a server=master -a nfs_vers=4 -a location=/install/nim/installp_bundle/xCATaixSSH.bnd xCATaixSSH__

A new flag --nfsv4 will be added to the mknimimage command, if the --nfsv4 is specified, the NIM resources will be created with NFS v4 support. The nimnodeset command will determine the NFS version based on the nodes' ip address. 

  


## 2.5 sshd configuration

The default sshd configuration on AIX does not enable IPv6 support, the line "ListenAddress&nbsp;::" has to been uncommented in /etc/ssh/sshd_config to enable the IPv6 support with sshd. If you want to enable both IPv4 and IPv6 for sshd configuration, the line "ListenAddress 0.0.0.0" also needs to be uncommented. 

  


## 2.6 networks table

The IPv6 network address and subnet are different with the IPv4, here is an example of IPv6 entry in networks table: netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,comments,disable "ipv6net","fe80::","64","en1","fe80::bc38:50ff:fe00:2003",,,,,,,,, 

The "fe80::" is the network address, the "64" is the prefix length. We are not using the IPv6 netmask such as "ffff:ffff:ffff:ffff:0000:0000:0000:0000" because the IPv6 prefix length makes more sense from user interface perspective, the xCAT code will do the prefixlength to netmask conversion internally if necessary. 

## 2.7 Considerations for IPv4 and IPv6 mixed cluster

It is true that most of the customers could not use pure IPv6 environment in the near future due to IPv6 support issues with software or hardware, so xCAT needs to provide flexibilities to support IPv4 and IPv6 mixed cluster. 

I am not seeing obvious problems if the users only want to use xCAT to perform routine system management tasks in IPv4 and IPv6 mixed cluster, but for operating systems deployment, I do not think we could support IPv4 and IPv6 mixed cluster, there are too many network services do not support IPv4 and IPv6 mixed environment such as dhcp/dhcpv6 and nfsv3/nfsv4. 

So only one IP version stack should be used to perform operating system deployment, after the operating system deployment is done, then the xCAT postscripts or distributed shell commands can be used to do further network configurations such as configure IPv4 and IPv6 mixed cluster. 

Since the xCAT management node may have both IPv4 and IPv6 addresses configured, xCAT needs to know which IP version should be used, for most of the commands against specific nodes such as pping &lt;node_range&gt;, xCAT could know the IP version according to the node's ip address, if the node's ip address is an IPv4 address, then should use IPv4 tools(e.g., ping); if the node's ip address is an IPv6 address, then the IPv6 tools(e.g., ping6) should be used. However, there are also some xCAT commands are not for specific nodes, such as mknimimage, makedhcp -a and makenetworks, for such kind of xCAT commands, we need some way to identify the IP version. 

Adding a flag to all of these commands that are not for specific nodes to identify the IP version is a clear and easy way, but not an elegant and transparent way. Using a big switch such as “ipv6cluster” in site table should be able to work, but we want to make the IPv4 and IPv6 differences as transparent as possible to the users, we will try to not add new flag to commands, but if it is absolutely necessary, adding new flags to commands will be a proper way. 

## 3\. References

1.Whitepaper “IPV6 on AIX 5L” . http://www-03.ibm.com/systems/resources/systems_p_os_aix_whitepapers_pdf_aix_ipv6.pdf 

2.HPC IPv6 White Paper. https://rs6000.pok.ibm.com/afs/apd/project/security/ipv6/hpc.IPv6.wp.v1.5.doc 

3.Open Firmware Recommended Practice: iSCSI and TFTP Booting Extensions 
