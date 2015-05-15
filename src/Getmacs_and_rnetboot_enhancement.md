<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Phase 1:**](#phase-1)
- [Phase 2:](#phase-2)
    - [1\. use apr protocal to get mac address](#1%5C-use-apr-protocal-to-get-mac-address)
    - [2\. kill all the child processes if hardware control commands received sigterm signal.](#2%5C-kill-all-the-child-processes-if-hardware-control-commands-received-sigterm-signal)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


# **Phase 1:**

**1\. Getmacs**

**Syntax:**  
getmacs [-h| --help]  
getmacs [-v| --version]  
getmacs noderange [-F filter]  
getmacs [-V| --verbose] noderange [-f][-d][-D [-S server] [-G gateway] [-C client]] 

**Description:**  
The output of getmacs has been changed in xCAT 2.3. Following is an example: 

_bash-3.2# getmacs xcat04,xcat05_  
_xcat04:_  
_#Type MAC_Address Phys_Port_Loc Adapter Port_Group Phys_Port Logical_Port VLan_  
_VSwitch Curr_Conn_Speed_  
_virtualio 7607DA0A1502 N/A N/A N/A N/A N/A 1 ETHERNET0 N/A_  
_hea 00145EB55787 T6 23000014 1 N/A 5 N/A N/A 1000_  
_xcat05:_  
_#Type MAC_Address Phys_Port_Loc Adapter Port_Group Phys_Port Logical_Port VLan_  
_VSwitch Curr_Conn_Speed_  
_virtualio 7607DFB07F02 N/A N/A N/A N/A N/A 1 ETHERNET0 N/A_  
_virtualio 7607DFB07F04 N/A N/A N/A N/A N/A 1 ETHERNET0 N/A_  
_hea 00145EB55788 T6 23000014 1 N/A 6 N/A N/A 1000_  
_hea 00145EB55790 T7 23000014 1 1 14 N/A N/A auto_

The background for this output change is that before the change, getmacs will open a console for  
each node and connect to open firmware of that node, dump all the adapters, read the mac address.  
This way takes long time and introduce the performance issues especially in scaling cluster.  
Now the way to get the mac address is that getmacs will connect to hmc and call lshwres on hmc  
to read the mac addresses of the nodes that managed by this hmc. This way reduce lots of efforts  
and time than before. The above output of getmacs is got from output of lshwres on hmc.  
-F option provides the capability to users to specify some filters which could select the right  
adapter user want. Following is an example of –F option: 

_bash-3.2# getmacs xcat05 -F Type=hea,Phys_Port_Loc=T6_  
_xcat05:_  
_#Type MAC_Address Phys_Port_Loc Adapter Port_Group Phys_Port Logical_Port VLan_  
_VSwitch Curr_Conn_Speed_  
_hea 00145EB55788 T6 23000014 1 N/A 6 N/A N/A 1000_

You should find that only one adapter is found according to the filters specified by user and this  
adapter will be written into xcat database.  
BTW, for all the ouput of getmacs, the first adapter listed will be written into xcat database(of  
course, if –d option provided, getmacs only display the mac addresses, no any adapter could be  
written into database).  
All the above explained the behavior of getmacs without any option and with –F option, next is  
about the –D [-S server] [-G gateway] [-C client].  
As always been complained before, getmacs doesn’t support ping test for multiple nodes, the old  
way to do ping test was that: getmacs xcat05 –S 192.168.0.10 –G 192.168.0.10 –C 192.168.0.11.  
User must specify all the network attributes for ping test, it means user can only specify one client  
IP for one node in each ping test command.  
Now the way to perform ping test can be anyone in the followings: 

getmacs xcat04,xcat05 –D  
getmacs xcat04,xcat05 –D –S 192.168.0.10  
getmacs xcat04,xcat05 –D –G 192.168.0.10  
getmacs xcat04,xcat05 –D –S 192.168.0.10 –G 192.168.0.10 

-D option tells getmacs to do ping test, if no –S, -G or –C specified, getmacs will read these  
attributes from xcat database and name server. So getmacs could support ping test for multiple  
nodes now. 

**2\. rnetboot**

**Syntax:**

rnetboot &lt;noderange&gt; [-s net|hd] [-f] [-V|--verbose]  
rnetboot [-h|--help|-v|--version] 

**Description:**

The same as before, -f is to still to force lpar immediately shutdown(Specify –i option in  
chsysstate command on hmc to that lpar).  
-s net|hd is newly added. Before we added it, the work flow of rnetboot is that: 1. shutdown the  
lpar, 2. boot the lpar to open firmware, 3. dump all the adapters, 4. do ping test to find the pingable  
adapter, 5. boot from that adapter.  
-s option didn’t change the workflow of rnetboot, but it added two actions. 1, if –s hd specified,  
before boot the lpar to open firmware, boot the lpar to sms first and then switch to open firmware  
mode. It is used to find the hard drives in sms(hard drive is the first hard drive of the node). 2.  
between step (4) and (5), rnetboot will set the boot device order if user specified –s option, -s hd  
means set first boot device to hard disk, -s net means set the first boot device to etnwork which is  
used to boot the lpar in step (5), -s hd,net means set the first boot device to hard driver, and set the  
second boot device to network. –s net,hd means set first boot device to network, second boot  
device to hard drive. 

We could get two benefits from this option:  
1\. rnetboot has performance issues in scaling cluster, because of the 5 steps that rnetboot did. If  
we have –s option, the first time we can use rnetboot to boot the lpar, besides set the boot device,  
so next time, user just need to use rpower to reboot the system(the boot device already been set in  
rnetboot). rpower is much quicker than rnetbot, since it just needs to login to hmc, and call  
chsysstat, don’t need to connect to hmc and dump the adapters and do ping test. This is much  
helpful especially for diskless node which have to run rnetboot to reboot the system every time  
before.  
2\. We have a thought that if lpar set to always boot from network, management node could also  
control the boot method of the compute node with rpower command from bootp/dhcp response.  
But we met one issue in this implementation on AIX, so I think don’t need to look into the details  
now for it now.  
Anyway, the new implemtation of rnetboot with –s option should help the performance in scaling  
cluster for diskless nodes, in some case, helpful for diskful node. 

  


# Phase 2:

### 1\. use apr protocal to get mac address

Interface change and UX impact:  
a. for getmacs command, add --arp option to indicate user wants to use apr protocal to get the mac address.  
\--arp cannot exist with -D option since -D is used to do ping test. 

Code change:  
a. check if the options are valid or not. --arp cannot exit with -D  
b. if arp specified, in PPC.pm, do:  
ping all the nodes, and use apr command to read the mac address. 

  


### 2\. kill all the child processes if hardware control commands received sigterm signal.

Interface change and UX impact:  
None 

Code change:  
a. in PPC.pm, add signal handler.  
b. in PPCmac.pm and PPCboot.pm, add signal handler (lpar_netboot).  
c. in lpar_netboot.expect, add signal handler to kill the spawned processes(hmc).  
d. makeconservercf should kill all the hmc connections first since makeconservercf is supposed to initialize all the connections. 
