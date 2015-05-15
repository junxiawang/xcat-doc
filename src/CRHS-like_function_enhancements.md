<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Planning](#1%5C-planning)
  - [1.1 Information About the Example Used in This Design](#11-information-about-the-example-used-in-this-design)
  - [1.2 Planning for hostnames and ip addresses](#12-planning-for-hostnames-and-ip-addresses)
  - [1.3 Planning for mapping between the hostnames and physical hardware components](#13-planning-for-mapping-between-the-hostnames-and-physical-hardware-components)
- [2\. Setup DHCP server on MN](#2%5C-setup-dhcp-server-on-mn)
- [3\. Power on all the frames and CECs](#3%5C-power-on-all-the-frames-and-cecs)
- [4\. Update xCAT tables](#4%5C-update-xcat-tables)
  - [4.1 Update the mapping between hostnames and ip addresses](#41-update-the-mapping-between-hostnames-and-ip-addresses)
    - [4.1.1 Update nodelist table](#411-update-nodelist-table)
    - [4.1.2 Update hosts table(optional)](#412-update-hosts-tableoptional)
  - [4.2 Update the mapping between the hostnames and the physical hardware components](#42-update-the-mapping-between-the-hostnames-and-the-physical-hardware-components)
    - [4.2.1 Use switch port information](#421-use-switch-port-information)
    - [4.2.2 Use vpd information](#422-use-vpd-information)
- [5\. Discover the HMCs, FSPs and BPAs](#5%5C-discover-the-hmcs-fsps-and-bpas)
  - [5.1 Random ip address](#51-random-ip-address)
    - [5.1.1 Use stanza file](#511-use-stanza-file)
    - [5.1.2 Update xCAT database directly](#512-update-xcat-database-directly)
  - [5.2 Permanent ip addresses](#52-permanent-ip-addresses)
    - [5.2.1 Use stanza file](#521-use-stanza-file)
    - [5.2.2 Update xCAT database directly](#522-update-xcat-database-directly)
- [6\. Connect FSPS and BPAs to HMC](#6%5C-connect-fsps-and-bpas-to-hmc)
- [7\. Set initial password for FSP/BPA if they are brand new machines](#7%5C-set-initial-password-for-fspbpa-if-they-are-brand-new-machines)
- [8\. Run rspconfig to setup the frame numbers](#8%5C-run-rspconfig-to-setup-the-frame-numbers)
- [9\. Run rspconfig to setup hostnames on the FSPs and BPAs](#9%5C-run-rspconfig-to-setup-hostnames-on-the-fsps-and-bpas)
- [10\. Others](#10%5C-others)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## 1\. Planning

### 1.1 Information About the Example Used in This Design

In this design, we use an example cluster for simplicity. The example cluster has 16 IH frames, in each frame there are 16 IH machines. Assume user design their machine as following: 

**name:**

frame name: frame1a is the A side of BPA in frame #1, and frame1b is the B side of BPA in frame #1, and so on. 

CEC name: from f1c1-f1c16 (in frame1) to f16c1-f16c16 (in frame 16) 

HMC name: the frame1 through frame 8 are managed by hmc1(10.0.0.101), the frame 9 through frame 16 are managed by hmc2(10.0.0.102) 

group name: group fsp will be used to represent all CEC nodes, and group bpa will represent all fram nodes. To make the regular expression in xCAT DB easier, I'd like to add 2 more groups for BPA nodes: bpa-a will be used to represent all BPA side A nodes, and bpa-b will be used for all BPA side B nodes. 

**network:**

the service network will be running with IP addresses in subnet 10.0.0.0/255.255.0.0. But the 172.20.0.0/255.255.0.0 will be used for the random ip addresses assigned to all the FSPs/BPAs in the first power on process. 

The IP of core switch in service network is 10.0.0.254. 

frame #1 will be connected to port 1 on the core switch, with port name "Gi1/1", frame #2 will to connected to "Gi1/2", and so on. 

The 2 sides of BPA in frame1 will get IP from DHCP (on xCAT MN): 10.0.1.1/10.0.1.2, 2 sides of BPA in frame2 will get 10.2.1.3/10.2.1.4, and so on. 

FSPs in frame #1 will get IP from 10.0.2.1 to 10.0.2.16, FSP in frame #2 will get IP from 10.0.2.17 to 10.0.2.32 

xCAT MN will be connected to service network with IP 10.0.0.1 (eth0). 

Note: In the examples throughout this design, node groups and regular expressions are used, you can specify any separate nodes and specific attributes for the nodes. 

### 1.2 Planning for hostnames and ip addresses

For xCAT hardware discovery feature, the prerequisite information is the hostnames and ip addresses allocation for all the FSPs and BPAs. The mapping between hostnames and ip addresses and the mapping between hostnames and physical hardware components has to be settled down before proceeding with the xCAT hardware discovery function. 

Note: If it is a migration scenario such as migrating the CSM CRHS environment to xCAT and it is OK for you to use the default FSP/BPA host names, i.e., Server-&lt;Model&gt;-&lt;Type&gt;-&lt;SerialNumber&gt;-&lt;Side&gt;, then all the steps in "Planning" section are not necessary at all, you can skip all the steps in sections "Planning". If the FSPs and BPAs already have static ip addresses, then all the steps in "Setup DHCP server on MN" section are not necessary, you can skip all the steps in sections "Setup DHCP server on MN". All the HMC connections have to be cleaned up and all the HMCs have to be changed back to standalone mode before proceeding with the xCAT hardware discovery. 

Each FSP side and BPA side should have one ip address assigned, and Each ip address should have a hostname defined, the FSPs and BPAs are indexed by hostnames. 

The ip addresses for FSPs and BPAs are got from the DHCP server on xCAT management node, the DHCP service process in the hardware discovery is a little bit complex, there are two types of ip addresses allocation mechanism that can be used in the hardware discovery process: random ip addresses or permanent ip addresses. 

DHCP service can be configured to use dynamic ip range in the DHCP configuration file, or use the MAC addresses and ip addresses mapping in leases file. When using dynamic ip range, each DHCP client will be assigned a random ip address at first, after that, the previous ip address and the lease expire information will be used to determine if the DHCP client will get a new ip address when the DHCP client restarts. When using MAC addresses and ip addresses mapping in DHCP leases file, each DHCP client will get a specific ip address, we call it permanent ip address, if the DHCP client MAC address and ip address mapping is configured in the DHCP leases file, after that, the DHCP client will get the same ip address upon each restart. 

**Random ip addresses:** When the FSPs and BPAs are brought up first time, since the MAC addresses for the FSPs and BPAs are not known yet, we can not specify the MAC address and ip address mapping in DHCP leases file, we can only specify a dynamic ip range in DHCP configuration file, so each FSP or BPA will get a random ip address. As mentioned above, the random ip address for each FSP or BPA may change in the future when the DHCP client on FSP or BPA restarts, however, if we specify a large enough dynamic ip range to aviod the ip addresses reuse, the random ip addresses can be similar as "permanent" ones. This solution has been validated in CSM CRHS solution. So the random ip address solution should be able to work. Please be aware that using the random DHCP ip addresses will increase the maintainance effort because you do not exactly know which hardware component has which ip address, at the same time, using random DHCP ip addresses opens an error windows that the FSPs/BPAs ip addresses may be changed during the FSPs/BPAs reboot, the FSPs/BPAs ip addresses change will result in HMC connection lost then you have to do some manual steps to recover. However, the random DHCP ip addresses solution should be able to work well for most of the scenarios, CSM CRHS has been using this solution for a long while. 

**Permanent ip addresses:** the permanent ip addresses is clearer and easier to mantain, to achieve the permanent ip addresses goal, a method is to specify the MAC address and ip address mapping for each FSP and BPA in the DHCP leases file. Of course, getting the MAC address for each FSP and BPA is complex and time consuming unless the FSPs and BPAs have already got ip addresses from DHCP server, then we can simply ping the ip addresses and the mac addresses will be added to the arp cache. lsslp will collect the mac address and add the ip address mapping into DHCP leases file. 

Either the solution "Random ip addresses" or solution "Permanent ip addresses" can be used, the administrator needs to select one solution as the ip addresses assignment mechanism. 

The HMC host names should be resolvable through /etc/hosts or DNS before proceeding with the hardware discovery process. 

### 1.3 Planning for mapping between the hostnames and physical hardware components

Several tables need to be updated to specify the mapping between the hostnames and physical hardware components, the mapping will tell xCAT on which physical hardware component the hostname is referring to. For example, the hostname f1c1 can be actually pointing to the CEC 9125-F2A-SN027ACB4, or pointing to the CEC with cage id 3 connected to the first port in the core switch. 

xCAT currently supports two ways to specify the mapping between the hostnames and physical hardware compoents: switch port and vpd. You can select either of the methods based on your cluster configuration; if you understand the network connections very well for each FSPs/BPAs and the switch supports SNMP protocol, use the switch port method is a good choice. If you do not quite understand the network connections or the switch does not support SNMP well, then using vpd information is another chioce for you 

## 2\. Setup DHCP server on MN

The DHCP service process in the hardware discovery is a little bit complex. All the FSPs and BPAs ip addresses are obtained from DHCP server on xCAT management node or standalone DHCP server, and the ip addresses tend to be changed dynamiclly. The floating FSP/BPA ip addresses are hard to maintain and error prone, so a better solution is to use the permanent ip addresses, the permanent ip addresses is clearer and easier to mantain. 

The method that system x hardware discovery feature is being used can work for system p also, before the FSPs and BPAs first power on, an ip addresses range will be added into dhcpd.conf or dhcpsd.conf file, during the FSPs and BPAs first power on, the FSPs and BPAs will get floating ip addresses, then lsslp command will get the mac addresses for all the FSPs and BPAs and writes the ip addresses and mac addresses mapping information into DHCP leases file, after that, lsslp log in the ASMI and restart the network interfaces for all the FSPs and CECs then all the FSPs and BPAs will get permanent ip addresses. 

To avoid confliction between the "random ip addresses" and "permanent ip addresses", two separate subnets can be used. In this design, we will use subnet 172.20.0.0/255.255.0.0 for the floating ip addresses and use subnet 10.0.0.0/255.255.0.0 for the permanent ip addresses. 

So the process will be: 

1\. Update the networks table to include the floating ip addresses range: 
    
    
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,comments,disable
    randomipnet, "172.0.0.0","255.255.0.0","eth0:0",,"172.20.0.1",,,,,"172.20.0.2-172.20.0.254",,,
    svcnet,"10.0.0.0","255.255.0.0","eth0",,"10.0.0.1",,,,,,,,
    

If the random ip addresses solution is selected, the "randomipnet" is not necessary in the "networks" table, but the dynamic ip range should be specified for the "svcnet", here is an example: 
    
    
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,comments,disable
    svcnet,"10.0.0.0","255.255.0.0","eth0",,"10.0.0.1",,,,,"10.0.1.1-10.0.2.255",,,
    

2\. If two subnets are needed, we need one ip address from each subnet configured on the management node. Either two separate network interface cards or alias ip addresses on one network interface card could work. Using alias ip address on one network interface card will reduce the configuration complexity. For Linux, the ethx:y can be configured directly to act as the alias ip address for ethx; on AIX, the command chdev -l enx -a alias4=&lt;ipaddress&gt;,&lt;subnet&gt; can be used to configure the alias ip address on enx. Of course, if the random DHCP ip address solution is selected, then this step is not necessary. 

3\. Run makedhcp to start dhcp server with dynamic IP range 

## 3\. Power on all the frames and CECs

Power on the frames/CECs manually, since the DHCP server is configured with dynamic ip range, then all the FSPs and BPAs will get floating IP addresses. The floating ip addresses are only for temporary use, the lsslp will use these floating ip addresses for further configuration, so it is not necessary to try to understand which ip addresses are assigned to which FSPs or BPAs. 

  


## 4\. Update xCAT tables

Some information mentioned in the "Planning" section should be added into xCAT tables before running the hardware discovery. The information includes the node names, the mapping between the ip addresses and hostnames, the mapping between the hostnames and the physical hardware components. 

### 4.1 Update the mapping between hostnames and ip addresses

#### 4.1.1 Update nodelist table

The "nodelist" table stores all the hostnames and groups information for all the nodes. Before proceeding with the hardware discovery process, the "nodelist" table needs to be updated to include all the FSPs and BPAs hostnames information. 
    
    
    #node,groups,status,appstatus,primarysn,comments,disable
    frame1a,"all,bpa,bpa-a"
    frame1b,"all,bpa,bpa-b"
    ... ...
    frame16a,"all,bpa,bpa-a"
    frame16b,"all,bpa,bpa-b"
    f1c1,"all,fsp"
    f1c2,"all,fsp"
    ... ...
    f16c16,"all,fsp"
    

In the nodelist table, each node may have different status and appstatus in the future, so we could not use "groups" in nodelist table, each node has to be listed separately in the nodelist table. It is time consuming to input all the nodes into nodelist table, the mkdef command can be used to add all the nodes nodelist table: 
    
    
    mkdef frame1a-frame16a groups="all,bpa,bpa-a"
    mkdef frame1b-frame16b groups="all,bpa,bpa-b"
    for i in `seq 1 16`;do mkdef f$ic1-f$ic16 groups="all,fsp";done
    

#### 4.1.2 Update hosts table(optional)

The "hosts" table stores the hostnames and ip addresses for all the nodes. For hardware discovery scenario, the hostnames and ip addresses information for all the FSPs and BPAs should be in "hosts" table before proceeding with the hardware discovery process. This step is optional, if you do not want to assign specific ip address to each FSP or BPA and does not care about using the random DHCP ip addresses for all the FSPs and BPAs, the "hosts" table does not need to be updated. Please be aware that using the random DHCP ip addresses will increase the maintainance effort because you do not exactly know which hardware component has which ip address, at the same time, using random DHCP ip addresses opens an error windows that the FSPs/BPAs ip addresses may be changed during the FSPs/BPAs reboot, the FSPs/BPAs ip addresses change will result in HMC connection lost then you have to do some manual steps to recover. However, the random DHCP ip addresses solution should be able to work well for most of the scenarios, CSM CRHS has been using this solution for a long while. 
    
    
    hosts table
    #node,ip                              ,hostnames,comments,disable
    fsp,  "|\D+(\d+)\D+(\d+)$|10.0.2.((($1-1)*16)+$2)|"
    bpa-a,"|\D+(\d+)\D+$|10.0.1.(($1*2-1))|"
    bpa-b,"|\D+(\d+)\D+$|10.0.1.(($1*2))|"
    

Note: If the CECs have two FSPs installed such as the POWER 595 systems, both the two FSPs should be added into the xCAT database. Here is an example: 
    
    
    #node,ip                              ,hostnames,comments,disable
    fsp-a,  "|\D+(\d+)\D+(\d+)$|10.0.2.((($1-1)*16)+$2)|"
    fsp-b,  "|\D+(\d+)\D+(\d+)$|10.0.2.((($1-1)*16)+$2+1)|"
    bpa-a,"|\D+(\d+)\D+$|10.0.1.(($1*2-1))|"
    bpa-b,"|\D+(\d+)\D+$|10.0.1.(($1*2))|"
    

### 4.2 Update the mapping between the hostnames and the physical hardware components

#### 4.2.1 Use switch port information

The switch port method uses the switch connection information to determine which hardware component that the hostname is pointing to. The "switch" table needs to be updated to indicate which switch port the FSP/BPA connects to. For example: 

Each frame and CEC should have an entry in the "switch" table to indicate which switch port it is connected to. For example: 
    
    
    #node,switch,     port,vlan,interface,comments,disable
    bpa  ,10.0.0.254,"|\D+(\d+)\D+$|Gi1/(($1))|"
    fsp  ,10,0.0.254,"|\D+(\d+)\D+\d+$|Gi1/(($1))|"
    

For high end CECs, the "ppc" table also needs to be updated to include the cage id information for each FSP. For low end CECs, the "ppc" table does not need to be updated. 
    
    
    #node,hcp,   id,                         pprofile,parent,supernode,comments,disable
    fsp,     ,  "|\D+\d+\D+(\d+)$|(($1))|"
    

#### 4.2.2 Use vpd information

For the high end servers such as POWER 595, only the BPAs MTMS information is necessary, for the low end servers such as POWER 520, the FSPs MTMS information is needed. You have two options to get the MTMS information for all the BPAs or FSPs, you can copy the BPAs or FSPs MTMS information from the front rear of the BPA or CEC manually; or run lsslp to get the basic hardware information from the lsslp output. 

  
Since all the FSPs and BPAs have got ip addresses though the ip addresses are random ones, the lsslp command can be run to get the basic hardware information, but not all the necessary information is available such as the hostname and ip addresses mapping. lsslp has a flag named "--vpdtable" to generate the VPD information into a format that is similar to the vpd table, you can copy and paste all the vpd information from the lsslp output to vpd table. 

Run: lsslp -s BPA -z -i 10.0.0.1 --vpdtable &gt; /stanza/file/path 

OR 

Run: lsslp -s FSP -z -i 10.0.0.1 --vpdtable &gt; /stanza/file/path 

  
The vpd methods uses the MTMS and parent information to determine which hardware component that the hostname is pointing to. For high end servers environment, the "vpd" table needs to be updated to include the BPA MTMS information and the FSP side information, if the systems only have one FSP for each CEC, then the FSP side information is not necessary in vpd table. For the low end servers environment, the "vpd" table needs to be updated to include the FSP MTMS information. All the MTMS information for the BPAs or FSPs can be obtained from the stanza file /stanza/file/path. Here is an example of the stanza file content: 
    
    
    "","99200G1","9A00-100","A",,,
    "","99200G1","9A00-100","B",,,
    	... ...
    "","99410D1","9A00-100","A",,,
    "","99410D1","9A00-100","B",,,
    

Copy the stanza file content to the vpd table, add the host names for each item, then the vpd table will look like: 
    
    
    #node,serial,mtm,side,asset,comments,disable
    "frame1a","99200G1","9A00-100","A",,,
    "frame1b","99200G1","9A00-100","B",,,
    	... ...
    "frame16a","99410D1","9A00-100","A",,,
    "frame16b","99410D1","9A00-100","B",,,
    

Note: The frames MTMS information can be obtained from the stanza file. For low end servers, the FSPs MTMS information can be obtained from the stanza file. 

For high end CECs, the "ppc" table also needs to be updated to include the cage id information and the BPA information for each FSP. For low end CECs, the "ppc" table does not need to be updated. 
    
    
    #node,hcp,   id,                         pprofile,parent,supernode,comments,disable
    fsp,     ,  "|\D+\d+\D+(\d+)$|(($1))|",,"|\D+\(d+)\D+\d+$|(frame($1)a)|",,,
    

## 5\. Discover the HMCs, FSPs and BPAs

The basic logic of lsslp command can be described as: 

  1. Run openslp command to get SLP responses from all the HMCs, BPAs or FSPs. 
  2. Parse the SLP responses, generate the nodes attributes based on the SLP responses information and the xCAT tables information described in section "Update xCAT tables". 
  3. If the -w flag is specified, write the node attributes to xCAT database; otherwise, write the node attributes to stdout, stanza file can be used to redirect the output. 
  4. If the flag --updatehosts is specified, the ip address information will also be updated into the xCAT database or the stanza file. 
  5. If the --makedhcp flag is specified, update DHCP leases file to include the MAC and ip addresses mapping, and internally call makedhcp to setup the DHCP service. 
  6. If the --resetnet flag is specified, the rspconfig will login the ASMI and reset the network interfaces on BPAs or FSPs to let the BPAs or FSPs get the new ip addresses from DHCP server 

The --makedhcp can not be used without -w flag. 

Here are several common configuration scenarios, different lsslp flags will be used in the different scenarios, if the random ip address solution is selected, then use the steps in 5.1; if the permanent ip address solution is selected, then use the steps in 5.2. 

### 5.1 Random ip address

If the random ip address solution is selected, we do not need to run makedhcp or reset network interfaces or BPAs/FSPs, but need to update hosts table. If you want to review stanza file before writting the nodes into xCAT database, then use the steps in 5.1.1; if you want to write the nodes into xCAT database directly, use the steps in 5.1.2. 

#### 5.1.1 Use stanza file

  1. lsslp -s HMC -z -i 10.0.0.1 &gt; /hmc/stanza/file 
  2. Review the HMC stanza file and make modifications if necessary. 
  3. cat /hmc/stanza/file | mkdef -z  
&nbsp;
  4. Run lsslp -s BPA -z -i 10.0.0.1 -M {switchport|vpd} --updatehosts &gt; /bpa/stanza/file 
  5. Review the BPA stanza file and make modifications if necessary. 
  6. cat /bpa/stanza/file | mkdef -z  
&nbsp;
  7. Run lsslp -s FSP -z -i 10.0.0.1 -M {switchport|vpd} --updatehosts &gt; /bpa/stanza/file 
  8. Review the BPA stanza file and make modifications if necessary. 
  9. cat /bpa/stanza/file | mkdef -z 

#### 5.1.2 Update xCAT database directly

  1. lsslp -s HMC -w -i 10.0.0.1 
  2. Run lsslp -s BPA -w -i 10.0.0.1 -M {switchport|vpd} --updatehosts 
  3. Run lsslp -s FSP -w -i 10.0.0.1 -M {switchport|vpd} --updatehosts 

  


### 5.2 Permanent ip addresses

If the permanent ip address solution is selected, lsslp need to run makedhcp and reset network interfaces or BPAs/FSPs, but does not need to update hosts table. If you want to review stanza file before writting the nodes into xCAT database, then use the steps in 5.2.1; if you want to write the nodes into xCAT database directly, use the steps in 5.2.2. 

#### 5.2.1 Use stanza file

  1. lsslp -s HMC -z -i 10.0.0.1 &gt; /hmc/stanza/file 
  2. Review the HMC stanza file and make modifications if necessary. 
  3. cat /hmc/stanza/file | mkdef -z  
&nbsp;
  4. lsslp -s BPA -z -i 10.0.0.1 -M {switchport|vpd} &gt; /bpa/stanza/file 
  5. Review the BPA stanza file and make modifications if necessary. 
  6. cat /bpa/stanza/file | mkdef -z  
&nbsp;
  7. lsslp -s FSP -z -i 10.0.0.1 -M {switchport|vpd} &gt; /bpa/stanza/file 
  8. Review the BPA stanza file and make modifications if necessary. 
  9. cat /bpa/stanza/file | mkdef -z  
&nbsp;
  10. makedhcp -a 
  11. rspconfig frame --resetnet 
  12. rspconfig cec --resetnet 

Note: the rspconfig --resetnet does not need to rerun the slp client to perform discovery, it simply uses the ip addresses information in the "ip" attribute or "otherinterfaces" attribute in the hosts table to login the ASMI and do the network interface reset. Since the "otherinterfaces" attribute is used to temporarily store the random ip addresses information, so the rspconfig --resetnet will remove the "otherinterfaces" items from hosts table. 

#### 5.2.2 Update xCAT database directly

  1. lsslp -s HMC -w -i 10.0.0.1 
  2. lsslp -s BPA -w -i 10.0.0.1 -M {switchport|vpd} --makedhcp 
  3. lsslp -s FSP -z -i 10.0.0.1 -M {switchport|vpd} --makedhcp 

## 6\. Connect FSPS and BPAs to HMC

There are two ways to specify the HMC for each FSP and BPA, use the xCAT table or through the mkhwconn -p flag, either way can be used. 

Here is an example of the xCAT table method: 
    
    
    ppc table:
    #node,hcp,   id,                         pprofile,parent,supernode,comments,disable
    bpa,  "|\D+(\d+)\D+$|hmc(($1/8))|" 
    fsp,  "|\D+(\d+)\D+\d+$|hmc($1/8)|" 
    

Run mkhwconn bpa -t 

Run mkhwconn fsp -t 

## 7\. Set initial password for FSP/BPA if they are brand new machines
    
    
    rspconfig bpa HMC_passwd=abc123
    rspconfig bpa general_passwd=abc123
    rspconfig bpa admin_passwd=abc123
    rspconfig fsp HMC_passwd=abc123
    rspconfig fsp general_passwd=abc123
    rspconfig fsp admin_passwd=abc123
    

## 8\. Run rspconfig to setup the frame numbers

To setup the frame numbers, the frame numbers information should first be added to ppc table: 
    
    
    ppc table:
    #node,hcp,   id,                         pprofile,parent,supernode,comments,disable
    bpa,  "|\D+(\d+)\D+$|hmc(($1/8))|", "|\D+(\d+)\D+$|(($1))|"
    
    
    
    rspconfig bpa frame=*
    

## 9\. Run rspconfig to setup hostnames on the FSPs and BPAs

All the FSPs and BPAs hostnames mentioned above are only used in the xCAT database, the rspconfig command can be used to setup the hostnames on the FSPs and BPAs, 
    
    
    rspconfig fsp hostname=*
    rspconfig bpa hostname=*
    

## 10\. Others

  * enable dev/celogin on FSP/BPA if needed 
  * remove service parition if needed 
  * create full partition if needed 
