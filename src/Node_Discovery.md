<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Summary of Usage](#summary-of-usage)
- [How to prepare for the process to work.](#how-to-prepare-for-the-process-to-work)
- [How the process works](#how-the-process-works)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning) 

**Note: Refer to [XCAT_iDataPlex_Cluster_Quick_Start] for a more up to date quick start guide.**

One of the significant features of xCAT 2 is the node discovery approach. It ultimately performs the role of associating node MAC addresses with IP based on some physical cue (ethernet port or Bladecenter slot). It has the same goal as getmacs fulfilled historically, except it is node initiated, has more context to enable accomodation of more complex configurations, and automated. 

### Summary of Usage

-Before you begin:  
-run makenetworks (this shouldn't be required, but to have a bullet-proof process....)  
-xcatd must be able to resolve nodenames to ip addresses (/etc/hosts, dns, whatever, if ping &lt;nodename&gt; can figure out the ip address, xCAT will be able to as well  
-Ethernet networks must have a dynamic range (dynamicrange column of networks be set for the network or an alias sharing that VLAN, e.g. chdef -t network -o clusternet net=172.16.0.0 dynamicrange=172.16.255.1-172.16.255.200 ). Range should be at the least as large as the number of unknown nodes you anticipate at once. Generally my dynamic ranges are bigger than my entire cluster, but bigger than one rack of equipment may be a good metric too, suspect people know how much unknown stuff they are going to turn on at once.  
-The nodes must exist in nodelist table  
-(mp.mpa and mp.id) or (switch.switch and switch.port) table values must exist for nodes, for blades or rackmounts respectively  
-If using switches, IP configuration and SNMPv1 read access must be done on the switch equipment  
-if bladecenters, if rpower works to the blade, discovery should work for the blade, so that setup is identical  
-For extra coolness, chain.chain attribute can guide through. For example, ipmi servers may want runcmd=bmcsetup in the chain to get out-of-band working automagically.  
-Actions:  
-makedhcp -n (if you had to add a dynamic range, this will actually push it to dhcp server)  
-tail -f /var/log/messages to get ready to watch the show  
-make nodes boot up, hit power buttons  
-Nodes get discovered, example: 

Oct 9 13:22:07 mgt dhcpd: DHCPDISCOVER from 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:08 mgt dhcpd: DHCPOFFER on 172.31.0.68 to 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:12 mgt dhcpd: DHCPREQUEST for 172.31.0.68 (172.16.0.1) from 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:12 mgt dhcpd: DHCPACK on 172.31.0.68 to 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.0 to 172.31.0.68:2070  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.0 to 172.31.0.68:2071  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/01-00-1a-64-20-04-cf to 172.31.0.68:57089  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/AC1F0044 to 172.31.0.68:57090  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/AC1F004 to 172.31.0.68:57091  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/AC1F00 to 172.31.0.68:57092  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/AC1F0 to 172.31.0.68:57093  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/AC1F to 172.31.0.68:57094  
Oct 9 13:22:12 mgt atftpd[20065]: Serving pxelinux.cfg/AC1 to 172.31.0.68:57095  
Oct 9 13:22:12 mgt atftpd[20065]: Serving xcat/nbk.x86 to 172.31.0.68:57096  
Oct 9 13:22:12 mgt atftpd[20065]: Serving xcat/nbfs.x86.gz to 172.31.0.68:57097  
Oct 9 13:22:29 mgt dhcpd: DHCPDISCOVER from 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:30 mgt dhcpd: DHCPOFFER on 172.31.0.90 to 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:30 mgt dhcpd: DHCPREQUEST for 172.31.0.90 (172.16.0.1) from 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:30 mgt dhcpd: DHCPACK on 172.31.0.90 to 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:46 mgt xCAT: xCAT: Allowing getdestiny  
Oct 9 13:22:55 mgt xCAT node discovery: n46 has been discovered  
Oct 9 13:22:55 mgt dhcpd: DHCPRELEASE from 00:1a:64:20:04:cf specified requested-address.  
Oct 9 13:22:55 mgt dhcpd: DHCPRELEASE of 172.31.0.90 from 00:1a:64:20:04:cf via eth1 (found)  
Oct 9 13:22:55 mgt dhcpd: DHCPDISCOVER from 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:55 mgt dhcpd: DHCPOFFER on 172.20.102.6 to 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:55 mgt dhcpd: uid lease 172.31.0.90 for client 00:1a:64:20:04:cf is duplicate on eth1  
Oct 9 13:22:55 mgt dhcpd: DHCPREQUEST for 172.20.102.6 (172.16.0.1) from 00:1a:64:20:04:cf via eth1  
Oct 9 13:22:55 mgt dhcpd: DHCPACK on 172.20.102.6 to 00:1a:64:20:04:cf via eth1  
Oct 9 13:23:07 mgt xCAT: xCAT: Allowing getdestiny from n46  
Oct 9 13:23:08 mgt xCAT: xCAT: Allowing nextdestiny from n46  
Oct 9 13:23:09 mgt xCAT: xCAT: Allowing getbmcconfig from n46  
Oct 9 13:23:15 mgt xCAT: xCAT: Allowing getdestiny from n46 

We see  
a) PXE DHCP request and subsequent tftp transfer, notice it failing over to generic configuration  
b) 36 seconds of discovery setup, including another dhcp (linux dhcp in this case)  
c) the node get's discovered and changes IP within 10 seconds. Note the duplicate uid lease message. It's probably going to happen, but examining the code, the dynamic one will get trumped and is actually marked usable by dhcpd, but dhcpd avoids reallocating dynamic addresses even if valid until the pool is exhausted, so it will continue to remember the old data.  
d) the node with it's new identity configures the BMC. 

In the example, n46 was fresh replacement, slid in, power button hit, walked to my chair. Within two minutes of the power button press, the node could be sshed into and rpower stat could be run, all configured based on it's physical location. 

### How to prepare for the process to work.

For every network where it is desirable to be able to discover interfaces, a dynamicrange field should be defined in networks for that network. This should not overlap any IP range you normally expect to use in a static fashion. This can either be a subset of your IP range, or you can, using the distribution tools, add a separate, aliased network that shares the same interface. xCAT will intelligently search for identities on networks sharing the same interface on a management server. To dictate a sequence of events to happen upon discovery, define the chain.chain value for the nodes. For rackmount, IPMI based servers, runcmd=bmcsetup,standby will auto-configure BMCs and then wait for a manual nodeset to do anything else, but with an ssh session open. Firmware management, netboot, boot might be other things to add. Skip runcmd=bmcsetup for blade servers. For blades, the mp table must be configured, and for rackmount servers, the switch table must be configured. Hit power button on servers to kick off the process 

### How the process works

When an unknown node attempts to netboot, it will be assigned a dynamic address from the pool. As the dynamic address doesn't map to any real node, the network boot loader will acquire a generic linux image from the boot server (xCAT-nbroot). That image then attempts to bring up all network interfaces it can find using DHCP (all interfaces that can will get dynamic addresses on various networks). It then tries each in turn to reach as many likely xCAT servers as are possible (DHCP server and xcatd= paramater passed at boot time). The xCAT server upon being reached instructs the node to execute discovery. The node begins looping, sending UDP datagrams to the xCAT server from a privileged port ( 
