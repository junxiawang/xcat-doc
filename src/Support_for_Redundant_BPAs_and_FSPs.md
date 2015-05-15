<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [**MiniDesign For Redundant FSP/BPA**](#minidesign-for-redundant-fspbpa)
- [Definitions, Terms](#definitions-terms)
- [Planning](#planning)
  - [Planning for hostnames and ip addresses](#planning-for-hostnames-and-ip-addresses)
  - [Planning for mapping between the hostnames and physical hardware components](#planning-for-mapping-between-the-hostnames-and-physical-hardware-components)
- [xCAT DB desgin:](#xcat-db-desgin)
  - [nodelist table](#nodelist-table)
  - [ppc table](#ppc-table)
  - [vpd table](#vpd-table)
  - [mac table](#mac-table)
- [Hardware discovery.](#hardware-discovery)
  - [Setup dhcp server on MN](#setup-dhcp-server-on-mn)
- [netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,](#netnamenetmaskmgtifnamegatewaydhcpservertftpservernameservers)
  - [Power on all the frames and CECs](#power-on-all-the-frames-and-cecs)
  - [Update mapping between hostnames and physical hardware components](#update-mapping-between-hostnames-and-physical-hardware-components)
- [node,serial,mtm,side,asset,comments,disable](#nodeserialmtmsideassetcommentsdisable)
  - [Discover HMCs/frame/CECs in order, and define them in xCAT DB.](#discover-hmcsframececs-in-order-and-define-them-in-xcat-db)
- [Connect FSPS and BPAs to HMC](#connect-fsps-and-bpas-to-hmc)
- [Changes from hardware control commands:](#changes-from-hardware-control-commands)
- [Changes from lsdef/nodels commands:](#changes-from-lsdefnodels-commands)
- [nodels bpa](#nodels-bpa)
- [lsdef -z Server-9A01-100-SN0P1P056:](#lsdef--z-server-9a01-100-sn0p1p056)
- [nodels -S bpa](#nodels--s-bpa)
- [lsdef -z -S Server-9A01-100-SN0P1P056,192.168.200.48](#lsdef--z--s-server-9a01-100-sn0p1p05619216820048)
  - [Migration in hardware discovery:](#migration-in-hardware-discovery)
  - [Migration in making hardware connections:](#migration-in-making-hardware-connections)
  - [Migration in other hardware control commands:](#migration-in-other-hardware-control-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## **MiniDesign For Redundant FSP/BPA**

# Definitions, Terms

We have following naming conventions defined in this design: 

  * Service Network 

The Service Network is an Ethernet network connecting the HMCs, BPCs, and FSPs in a cluster. 

  * Building Block 

Building block a section of a cluster consisting of 3 frames which contain both P7IH server drawers and storage drawers. 

  * Framenode 

In a frame that has redundant BPAs, the term Frame node is representing the two redundant BPAs with same mtms in the frame. In one frame, there will be only one Frame node defined by xCAT. 

  * BPAnode 

BPA node represents for one port on one bpa, so in one frame there will be four BPA nodes defined by xCAT sine there will two BPAs and each BPA has two ports. The relationship between Frame node and BPA node from system admins perspective is that they can use the only Frame node definition per frame for all the xCAT hardware control commands, xCAT will figure out what are the BPA nodes and their attributes for hardware connections. 

  * CECnode 

In the CEC that has redundant fsps, CEC node represents for the two redundant fsps with the same mtms. So in one CEC, there will be only one CEC node defined by xCAT. 

  * FSPnode 

FSP node represents for one port on one FSP. In one CEC, there will be two FSPs and each FSP has two ports, there will be four FSP nodes defined by xCAT. Same as the relationship between Frame node and BPA node, system admins can just use the CEC node for all the hardware control commands, xCAT will figure out what are the four FSP nodes and their attributes for hardware connections. 

  * slot 

In the server with redundant BPA and FSP, there will be two BPAs in one frame and two FSPs in one CEC. We use the term 鈥渟lot鈥?to identify which BPA or FSP is primary and which is backup. 

  * port 

There will be two ports on one BPA or FSP. 

  


# Planning

In xCAT hardware discovery feature, the prerequisite information is the hostnames and ip addresses allocation for all the Frames, BPAs, CECs and FSPs. The mapping between Frame/CEC hostnames and ip addresses and the mapping between ip address and physical hardware components has to be settled down before proceeding with the xCAT hardware discovery function. 

  


## Planning for hostnames and ip addresses

The ip addresses for FSPs and BPAs are got from the DHCP server on xCAT management node, the DHCP service process in the hardware discovery is a little bit complex, there are two types of ip addresses allocation mechanism that can be used in the hardware discovery process: random ip addresses or permanent ip addresses. 

  
**Random ip addresses:** When the FSPs and BPAs are brought up first time, since the MAC addresses for the FSPs and BPAs are not known yet, we can not specify the MAC address and ip address mapping in DHCP leases file, we can only specify a dynamic ip range in DHCP configuration file, so each FSP or BPA will get a random ip address. As mentioned above, the random ip address for each FSP or BPA may change in the future when the DHCP client on FSP or BPA restarts, however, if we specify a large enough dynamic ip range to aviod the ip addresses reuse, the random ip addresses can be similar as "permanent" ones. This solution has been validated in CSM CRHS solution. So the random ip address solution should be able to work. Please be aware that using the random DHCP ip addresses will increase the maintainance effort because you do not exactly know which hardware component has which ip address, at the same time, using random DHCP ip addresses opens an error windows that the FSPs/BPAs ip addresses may be changed during the FSPs/BPAs reboot, the FSPs/BPAs ip addresses change will result in HMC connection lost then you have to do some manual steps to recover. However, the random DHCP ip addresses solution should be able to work well for most of the scenarios, CSM CRHS has been using this solution for a long while. 

  
**Permanent ip addresses:** the permanent ip addresses is clearer and easier to mantain, to achieve the permanent ip addresses goal, a method is to specify the MAC address and ip address mapping for each FSP and BPA in the DHCP leases file. Of course, getting the MAC address for each FSP and BPA is complex and time consuming unless the FSPs and BPAs have already got ip addresses from DHCP server, then we can simply ping the ip addresses and the mac addresses will be added to the arp cache. lsslp will collect the mac address and add the ip address mapping into DHCP leases file. 

  
Either the solution "Random ip addresses" or solution "Permanent ip addresses" can be used, the administrator needs to select one solution as the ip addresses assignment mechanism. 

## Planning for mapping between the hostnames and physical hardware components

Several tables need to be updated to specify the mapping between the hostnames and physical hardware components, the mapping will tell xCAT on which physical hardware component the hostname is referring to. For example, the hostname f1c1 can be actually pointing to the CEC 9125-F2A-SN027ACB4, or pointing to the CEC with cage id 3 connected to the first port in the core switch. 

  
There are two ways to specify the mapping between the hostnames and physical hardware compoents: switch port and vpd. You can select either of the methods based on your cluster configuration; if you understand the network connections very well for each FSPs/BPAs and the switch supports SNMP protocol, use the switch port method is a good choice. If you do not quite understand the network connections or the switch does not support SNMP well, then using vpd information is another choice for you. xCAT currently supports vpd, and it is used by default. 

For system p servers, we will only provide the vpd mode in this document. 

# xCAT DB desgin:

Several tables need be updated for redundancy BPA/FSP implementation. 

## nodelist table

A new attribute will be added in nodelist table, 

  * hidden 0 or 1. 1 will be set for BPAnodes and FSPnodes because we trade FSP and BPA nodes as the internal node type and will not recommend the user to do the operation for them. If 1 is set, lsdef and nodels won't list them when you list all of the nodes or all the nodes in a group. A new flag -S added to nodels and lsdef in case the user still want to list these hidden nodes. 

## ppc table

We will add one new attribute to the ppc table, 

  * nodetype the type of object in this row could be: frame,bpa,cec,fsp,lpar. (frame means it is a Framenode,bpa represents for BPAnode,cec represents for CECnode, fsp represents for FSPnode, lpar represents for the partition). 
  * For parent attribute For Framenode, the parent attribute will be blank. For BPAnode, parent will be set to Framenode. For CECnode, parent will be set to Framenode. For FSPnode, parent will be set to CECnode.  


## vpd table

  * Side For BPAnode and FSPnode, the id will be a character conjuncted a number by a minus, e.g. A-0 which mean the BPA/FSP in slot 1(slot 0 with side B, slot 1 with A), and the 1nd port (port 0 with 0, port 1 with 1)on that FSP. 

## mac table

All the BPAnodes and FSPnodes will be added into mac table by lsslp automatically. Framenodes and CECnodes will not. 

# Hardware discovery.

We will give example to explain how to setup DHCP server with xCAT and disover the hardwares. 

## Setup dhcp server on MN

Before the FSPs and BPAs first power on, an ip addresses range will be added into dhcpd.conf on Linux or dhcpsd.conf file on AIX, during the FSPs and BPAs first power on, the FSPs and BPAs will get random ip addresses. 

#netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers, 

ntpservers,logservers,dynamicrange,nodehostname,comments,disable 

"RandomIPRange","192.168.0.0","255.255.0.0","en0","192.168.200.205","192.168.200. 

205","192.168.200.205","192.168.200.205",,"192.168.200.205","192.168.200.1-192.168.200.100",,, 

  


## Power on all the frames and CECs

Since the DHCP server is now configured with a dynamic ip range in the HW service subnet, all the FSPs and BPAs will get dynamic HW IP addresses from the DHCP server. 

## Update mapping between hostnames and physical hardware components

Note:This step is optional if you want to use specific hostnames for BPA on high end servers or CEC on low end servers. If the default hostnames for BPA and FSPs generated by xCAT are acceptable, you can skip this step. 

  


  * **Update vpd table**  
For the high end servers, only the BPAs MTMS information is necessary, for the low end servers, the CECs MTMS information is needed. You have two options to get the MTMS information for all the BPAs or FSPs, you can copy the BPAs or CECs MTMS information from the front rear of the BPA or CEC manually; or run lsslp to get the basic hardware information from the lsslp output. 

Since all the FSPs and BPAs have got ip addresses though the ip addresses are random ones, the lsslp command can be run to get the basic hardware information, but not all the necessary information is available such as the hostname and ip addresses mapping. 

  
Run _lsslp -s BPA -z -i 192.168.200.205 &gt; /stanza/file/path_

OR 

Run _lsslp -s FSP -z -i 192.168.200.205 &gt; /stanza/file/path_

  
This methods uses the Frame or CEC MTMS information to determine which hardware component that the hostname is pointing to. For high end servers environment, "vpd" table needs to be updated to include the Framenode MTMS information, For the low end servers environment, "vpd" table needs to be updated to contain the CEC MTMS information. All the MTMS information for the Frame or CEC can be got from the stanza file /stanza/file/path.For high end servers: 

vpd table: 

#node,serial,mtm,side,asset,comments,disable 

"frame1","99200G1","9A00-100",,,, 

... ... 

"frame3","99201WM","9458-100",,,, 

For low end servers: 

vpd table: 

"cec1","9920652","9A00-FHB",,,, 

... ... 

"cec3","9920672","9A00-FHB",,,, 

Note: The frames MTMS information can be got from the stanza file. For low end servers, the CECs MTMS information can be got from the stanza file. 

  


## Discover HMCs/frame/CECs in order, and define them in xCAT DB.

Till now, all the required hardware infromation to work with VPD method have been collected and defined in xCAT DB, issue lsslp to discovery HMC, Frame, and CEC seperately: 

lsslp -s HMC -i 192.168.200.205 -w --makedhcp 

lsslp -s FRAME -i 192.168.200.205 -w --makedhcp 

lsslp -s CEC -i 192.168.200.205 -w --makedhcp 

rspconfig hmc --resetnet 

rspconfig frame --resetnet 

rspconfig cec --resetnet 

The basic logic and actions with vpd method inside lsslp command are: 

1) Run openslp command to get SLP responses from all the HMCs, BPAs or FSPs. 

  1. Parse the SLP responses: 
  * Generate the Framenode and CECnode definitions with mtms in SLP responses. If user defined specific Framenode and CECnode hostnames with mtms, xCAT will go to vpd table to find the correct hostnames for Framenode and CECnode. 

Each Framenode or CECnode will have attribute hidden=0 setting into nodelist table. nodels and lsdef command could list the nodes. 

Each Framenode and CECnode will have attribute nodetype setting in nodetype talbe and hwtype setting in ppc table. The type of CECnode is cec and Framenode is frame. 

  
For those high-end System P servers (IH and HE servers), CECnode will have attribute parent setting to the Framenode name that is controlling it. For Framenode, the parent attribute will be blank or the building block number setting by. An example of Framenode and CECnode definition: 

Server-9A01-100-SN0P1P056: objtype=node groups=bpa,all hcp=Server-9A01-100-SN0P1P056 hidden=0 mgt=bpa mtm=9A01-100 nodetype=ppc hwtype=frame serial=0P1P056 

Server-9A01-100-SN1021C3P: objtype=node groups=fsp,all hcp=Server-9A01-100-SN1021C3P hidden=0 mgt=fsp mtm=9A01-100 parent=Server-9A01-100-SN0P1P056 //Setting to Framenode nodetype=ppc hwtype=cec serial=1021C3P* 

Generate the BPAnode and FSPnode definition. 

The nodenames will be IP addresses. In the case of redundant BPAs and FSPs, there are two BPAs in a frame and two FSPs in a CEC, and each BPA and FSP has two ports, so there will be four node definitions per BPA or FSP. 

Each node will have attribute hidden=1 setting into nodelist table, which means these nodes will not be seen by nodels and lsdef commands. User still can see these nodes attribute with -S option in nodels and lsdef commands. 

Each node will have attribute nodetype in nodetype table and hwtype in ppc table. 

  
An example of BPAnode and FSPnode definition: 

192.168.200.48: objtype=node groups=bpa,all hcp=Server-9A01-100-SN0P1P056 hidden=1 id=4 mac=001a645457be mgt=bpa mtm=9A01-100 parent=Server-9A01-100-SN0P1P056 serial=0P1P056 type=bpa side=B-1 

  
192.168.200.100: objtype=node groups=fsp,all hcp=Server-9A01-100-SN1021C3P hidden=1 id=4 mac=00215e7e3325 mgt=fsp mtm=9A01-100 parent=Server-9A01-100-SN1021C3P serial=1021C3P side=B-0 type=fsp 

  


  1. Specify -w to write all the node attributes to xCAT database; otherwise, write the node attributes to stdout, stanza file can be used to redirect the output. 
  2. Specify --makedhcp flag to internally call 鈥渕akedhcp -S鈥?to setup the DHCP service and update DHCP leases file to include the MAC and ip addresses mapping. This option could make the ip addresses to be persistent, so the same BPA or FSP can get the same ip address after it reboots. 
  3. Specify --resetnet flag to login to ASMI interface on hardwares and restart the network interfaces. 

# Connect FSPS and BPAs to HMC

There are two ways to specify the HMC for each FSP and BPA, use mkhwconn -t flag to use the setting inxCAT table or through the mkhwconn -p flag, either way can be used. 

  
Changes in mkhwconn/lshwconn/rmhwconn command: 

  1. If the parameter 鈥渘oderange鈥?are Framenodes or CECnodes. xCAT needs to go to ppc table and find out the BPAnode and FSPnode whose鈥減arent鈥漚ttributes setting to the Framenode or CECnode. After getting all the corresponding BPAnodes and FSPnodes, xCAT could get all the ip addresses on the same Frame and CEC, and send them to fsp-api to take actions. 
  2. If the parameter 鈥渘oderange鈥?are BPAnodes or FSPnodes, it means users just want to work with the specified BPA or FSP ports, xCAT will only add/list/remove the connections for the specific ports. 

# Changes from hardware control commands:

Same as mkhwconn/lshwconn/rmhwconn, the noderange parameter to the hardware control commands should be the Framenode and CECnode names. xCAT needs to go to ppc table and find out the BPAnode and FSPnode whose鈥減arent鈥漚ttribute setting to the Framenode or CECnode. After getting all the corresponding BPAnodes and FSPnodes, xCAT could get all the ip addresses on the same Frame and CEC, and send them to fsp-api to take actions. 

  


# Changes from lsdef/nodels commands:

By default, lsdef and nodels commands can only display the Framenode and CECnode. For example: 

#nodels bpa 

Server-9A01-100-SN0P1P056 

#lsdef -z Server-9A01-100-SN0P1P056: 

objtype=node 

groups=bpa,all 

hcp=Server-9A01-100-SN0P1P056 

hidden=0 

mgt=bpa 

parent=Server-9A01-100-SN0P1P056 

type=frame 

  
To list the BPAnode and FSPnode, a new flag -S needs to add for lsdef and nodels commands, for example: 

#nodels -S bpa 

Server-9A01-100-SN0P1P056,192.168.200.48 

#lsdef -z -S Server-9A01-100-SN0P1P056,192.168.200.48 

192.168.200.48: 

objtype=node 

groups=bpa,all 

hcp=Server-9A01-100-SN0P1P056 

hidden=1 

id=0 

mac=001a645457be 

mgt=bpa 

mtm=9A01-100 

parent=Server-9A01-100-SN0P1P056 

serial=0P1P056 

side=0:1 

type=bpa 

Server-9A01-100-SN0P1P056: 

objtype=node 

groups=bpa,all 

hcp=Server-9A01-100-SN0P1P056 

hidden=0 

mgt=bpa 

parent=Server-9A01-100-SN0P1P056 

type=frame= Migration = For migration from xCAT 2.5 or older version, we will split it to three parts: hardware discovery, make hardware connections, and other hardware control commands: 

## Migration in hardware discovery:

lsslp commmand is designed for hardware discovery. In the case that there are existing hardware data generated by xCAT 2.5 or even older: 

If user specified lsslp -n option to discover new hardwares, the existing data will not be changed. Otherwise, 

  * For BPAs, generate the new Frame node and set the new BPAnode's parent to Frame node. The Frame nodename could be generated by xCAT or user defined Frame names. Change the attribute 鈥渟ide鈥?to new format. 
  * Same scenario applies for FSP nodes. One more thing is to specify the CECnode's parent to Framenode. 
  * In direct attch, lookup ppc table and update the hcp and parent attributes for lpars to be CECnode. 
  * Without direct attach, lookup ppc table and update the parent attributes only to be CECnode for lpars. 

## Migration in making hardware connections:

mkhwconn/lshwconn/rmhwconn will accept the frame, bpa, cec, and fsp as the "node range" parameter. 

  
The workflow to work with frame and cec nodes have been described above. 

  
There are two reasons of why we need to accept bpa and fsp nodes as "node range" parameter: 

  1. Users might have the hardware data already and don't want to run lsslp to discover the hardwares, generate the hardware data with new DB design again. 
  2. It is possible that user wants to do more accurate control to any specific port. We can give this capability to users.  


  
The workflow to work with bpa and fsp nodes is that xCAT will check the attribute "parent" of bpa and fsp nodes. If their parents are setting to frame or cec nodes, it means the data are generated by xCAT 2.6. Mkhwconn/lshwconn/rmhwconn will only work with this port. Otherwise, go to find and proceed with all other bpa and fsp nodes with the same MTMS. This is the same way with xCAT 2.4 and 2.5. 

## Migration in other hardware control commands:

All the hardware control commands need to handle the data generated by xCAT 2.6 and xCAT 2.5 or older. 

  
An enhancement might be to add funtion in rscan -u option which give user the capability to revert the existing data generated by xCAT 2.5 or older to the new DB design, without re-do the hardware discovery work. This is used for future use, with this change, our new code in the future like xCAT 2.7 can only care the new DB design. Otherwise, we will always think of the data design in xCAT 2.5. 

  * For BPAs, generate the new Frame node and set the new BPAnode's parent to Frame node. The Frame nodename could be generated by xCAT or user defined Frame names. Change the attribute "id"to new format. 
  * Same scenario applies for FSP nodes. One more thing is to specify the CECnode's parent to Framenode. 
  * In direct attch, lookup ppc table and update the hcp and parent attributes for lpars to be CECnode.  
Without direct attach, lookup ppc table and update the parent attributes only to be CECnode for lpars. 
