{{:Design Warning}} 

On AIX: 

Before designing the workflow in xCAT, there are several statements we need to clarify: 

\- Each lpar will have 3 HFI window/mac available, and getmacs will get the first 3 available HFI windows/MAC from net-c interface for each lpar. 

\- It is more likely to use rbootseq and rpower to initialize a netboot in a large cluster. Since rpower is not able to get the HFI MAC address change on client node, mkdsklsnode or nimnodeset should prepare the nim resources for all the three HFI MACs on each node. So that rbootseq and rpower could initialize a netboot, and no matter which HFI mac is used for netboot on the client node, it should be get bootp response from bootp server and download the nim resources. 

\- All the HFI MAC address failover work is depending on bootp's multiple mac address entries in bootptab support. bootp is supporting multiple mac address mapping to the same ip address. 

\- The final and best solution is after NIM support HFI MAC address failover, which could help to deploy installation from any HFI interface, xCAT will interact with NIM only on all the HFI interfaces. Submitted one NIM feature to support HFI MAC address failover, the initial sizing for this feature is 1 py. 

CMVC: 174621 NIM supports HFI MAC address failover 

  
Work flow design: 

1\. Define a compute node definition in xCAT db from HMC/DFM. And add the node's ip to /etc/hosts or name resolution. 

2\. Define networks in networks table for each HFI interfaces. 
    
      There is one naming convention here to define HFI networks.  Attribute "mgtifname" in networks table must be "hf&lt;x&gt;" for HFI networks.
    

The reason for this naming convention is that some xCAT operations are not the same between ethernet and HFI, we need to distinguish if the client node is working on HFI or not. 

If the client node ip is in a hfi network with the mgtifname as "hf&lt;x&gt;", we will suppose this node is working on HFI and other xCAT commands will take the activities for HFI. 

HFI network definition example: 
    
      bash-3.2# tabdump networks
      #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,ddnsdomain,vlanid,comments,disable
      "20_0_0_0-255_0_0_0","20.0.0.0","255.0.0.0","hf0","10.255.255.254",,,,,,,,,,,
      "21_0_0_0-255_0_0_0","21.0.0.0","255.0.0.0","hf1","10.255.255.254",,,,,,,,,,,
      "22_0_0_0-255_0_0_0","22.0.0.0","255.0.0.0","hf2","10.255.255.254",,,,,,,,,,,
      "23_0_0_0-255_0_0_0","23.0.0.0","255.0.0.0","hf3","10.255.255.254",,,,,,,,,,,
    

3\. Define hfi networks in NIM. 

\- xcat2nim -t network -o &lt;node&gt; changes 

xcat2nim should determine if the client node ip is in hfi network or not. If true, it means the client node is working in HFI network and xcat2nim should define hfi networks in nim, instead of ethernet. 

  
4\. Issue "getmacs &lt;node&gt;" to get three HFI addresses and write them into mac table. 

\- getmacs's change The compute node might have ethernet adapters also. getmacs will get the HFI macs, besides ethernet macs. It is a question to decide which one should be written into xCAT db by default. 

The answer is it depends on the network definition that the client ip belongs to. If the client node ip is in HFI network, then HFI mac will be written into xCAT db by default. Otherwise, ethernet mac will be written into xCAT db by default. 
    
       bash-3.2# getmacs node1
       node1: 
       #Type  Phys_Port_Loc  MAC_Address  Adapter  Port_Group  Phys_Port  Logical_Port  VLan  VSwitch  Curr_Conn_Speed
       HFI  N/A  020004210004|020004210005|020004210006  N/A  N/A  N/A  N/A  N/A  N/A  N/A
    

5\. Modify nimnodeset and mkdsklsnode to support the multiple MAC addresses with one IP address/hostname. 

As described in the above statements, NIM doesn't support HFI MAC address failover so far, after xCAT defined one NIM machine and initialized nim boot to the machine, nimnodeset and mkdskless need to modify the /etc/bootptab manually to extend the only one entry for that machine to three entries with the same ip address and different hfi mac addresses. 

All the hfi interfaces should be defined in nim network, and assign them to the nim machine as installation interfaces for reference, even only one installation interface will finally take effort. 

Another change in nimnodeset and mkdsklsnode is that it should determine if the client node ip is in hfi network or not. If true, it means the client node is working in hfi network, we need to assign hfi network as the installation interface to it and boot from hfi. Otherwise, assign ethernet network to it and boot from ethernet. 

6\. Issue rnetboot to boot from HFI devices. 

\- rnetboot change 

Even rbootseq and rpower are more likely used in large cluster, we still need rnetboot to support HFI mac address failover, to try to boot from each hfi mac that is written in mac table, if booting from the first mac failed, rnetboot should try to boot from the next hfi mac. 

Another change in rnetboot is that it should determine if the client node ip is in hfi network or not. If true, it means the client node should boot from hfi. Otherwise, it should boot from ethernet. 

  


  


On Linux: 

There are also some statements that we should know before starts the topic: 

1\. On each Octant, there will 256 HFI windows and up to 4 lpars. The first 4 windows will be allocated by phyp. So for each lpar, there will be at least (256-4)/4=63 windows/HFI MAC available. 2\. getmacs will only get the first 3 available HFI windows/MAC from net-c interface. 3\. Open firmware will firstly try to open the first available window and generate HFI MAC address, use this HFI MAC for bootp request and other stuff. OS will take this MAC to hf0. If OF failed to open the first window, it will open the second window and generate another HFI MAC address. OS will assign this MAC to hf0 too. If this window still failed, OF will open the next window, untill there are no available window assign to this lpar. 

For example, getmacs gets three HFI MAC addresses: 02:00:02:00:00:04|02:00:02:00:00:05|02:00:02:00:00:06 

Then later if OF cannot open the first two windows, the current HFI MAC addresses will be: 02:00:02:00:00:06|02:00:02:00:00:07|02:00:02:00:00:08 

It is possible that all the three HFI MAC addresses got from getmacs are not valid while OF tried to use them. But xCAT will only work with the original three HFI MAC. In this case, user has to rerun getmacs to get the current valid HFI MAC addresses. 

Design discussion: 

The general idea to wrok with HFI MAC address failover is that we will use the same IP address/hostname to map the three HFI MAC addresses. So any one MAC can get the same IP address and hostname, this makes our implementation much simpler. 

Following is the work flow on Linux: 

1\. Define a compute node definition from HMC/DFM. 

Comparing with booting over ethernet, following attributes should be set: intallnic - set to hf0, hf2, or hf4. generally it is setting to hf0. primarynic - set to hf0, hf2, or hf4. Generally it is setting to hf0. 

2\. Issue "getmacs node1" to get three HFI addresses and write them into mac table. 

\- The compute node might have ethernet adapter also, not sure if we still need the "--hfi" option to getmacs even without ping test to indicate user wants to use HFI adapters, without ping test? Currently "--hfi" is only worked with "-D" option for ping test and get mac from OF. So if there are ethernet and HFI adapters both, getmacs will write hfi MAC address to mac table with "--hfi" option, and will write ethernet MAC address without "--hfi" option. 

3\. Modify DHCP to support the multiple MAC addresses with one IP address/hostname. 

\- xCAT will only have one node hostname and IP address for installation. But in DHCP, each dhcp entry needs a unique hostname, we can put node1-hf0, node1-hf2, node1-hf4 as the entry names in dhcp lease file. \- Today I tested DHCP working with HFI. There is a problem in HFI DD that, if we firstly set an IP to a HFI interface on a compute node, do a ping test to the server, it succeeds and server will write the arp table with this HFI MAC. Then I shutdown this lpar, and assign the same IP address to another lpar with HFI, do a ping test from that lpar, the ping test always failed, because of arp table doesn't get updated. If I manually update the arp table to currentl HFI MAC, ping test succeed. That means currently HFI DD doesn't support to reuse IP address to different lpars/MACs. Need to talk to HFI DD team. 

4\. nodeset need to create several installation resources to each MAC addresses, to serve the request with uncertain MAC address. 

\- create three /tftpboot/etc/&lt;configfile&gt; with different MAC addresses. 

5\. set boot string and rpower to install the compute node. 

6\. Add confighfi postscript to configure other HFI interfaces after node booted up. 

\- To work with confighfi postscript, named server needs to be setup on SN/MN for other HFI interfaces, or /etc/hosts should has been synced to compute node. \- Finally this script should support to configure hfi/bind/ml interfaces on AIX and Linux both. \- Write static IP to each HFI interface. 
