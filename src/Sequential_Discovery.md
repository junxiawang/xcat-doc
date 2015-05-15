<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Interface](#interface)
  - [Start the discovery process:](#start-the-discovery-process)
  - [Stop the discovery process:](#stop-the-discovery-process)
  - [List the discovered nodes:](#list-the-discovered-nodes)
  - [Display the status of the discovery:](#display-the-status-of-the-discovery)
  - [Manually discovery a node:](#manually-discovery-a-node)
  - [Start the discovery process](#start-the-discovery-process)
  - [Stop the discovery process](#stop-the-discovery-process)
  - [List the discovered nodes](#list-the-discovered-nodes)
  - [Findme process](#findme-process)
  - [Manually discovery a node](#manually-discovery-a-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

The 'switch-port-based' discovery has been supported by xCAT for a long time, in which the physical location of the new discovered node is calculated and mapped by 'switch+port' that the node connected to. That means the switch and port information must be set correctly before the discovery. But many xCAT users said: the 'switch-port-based' discovery is powerful but hard to manage, is that possible to run the discovery without 'switch+port' for the cluster that don't care the physical location of the nodes (Or don't care accurate location like just need to know the discovered node in which rack). Then xCAT decide to implement the 'sequential discovery' which just simply assign a hostname and IP for the new discovered node but don't care the physical location, or the location information could be set in static. 

PCM has implemented a similar discovery function in the xCAT, it named 'profile' discovery. There are four commands 'nodediscoverls, nodediscoverstart, nodediscoverstatus, nodediscoverstop' are designed to manage the discovery process. 

In the 'profile' discovery circumstance: 

  * 'nodediscoverstart' is used to start the discovery process. several profiles need to be set to specify the rules that which network, hostname, osimage should be used for the discovered node. And a flag is set to identify that the discovery has been started. 
  * 'nodediscoverls' is used to list the discovered nodes. 
  * 'nodediscoverstatus' is used to display that whether the discovery has been started. 
  * 'nodediscoverstop' is used to stop the discovery process and clean the environment. 

Since the functions of 'sequential discovery' and 'profile discovery' are similar, the above four commands will be reused for 'sequential discovery'. 

Except the above four commands, another command 'nodediscoverdef' will be added to handle the node which sent discovery request but not handled by xCAT discovery process. 

## Interface

### Start the discovery process:

Syntax of the command: 

    nodediscoverstart noderange=&lt;noderange&gt; hostiprange=&lt;ips-ipe&gt; bmciprange=&lt;ips-ipe&gt; [groups=&lt;groups&gt;] [rack=&lt;rack&gt;] [chassis=&lt;chassis&gt;] [height=&lt;height&gt;] [unit=&lt;unit&gt;] 

    

    'noderange' - Specify a bunch of node names which could be used for the new discovered nodes. (Refer to xCAT 'noderange' man page.) The nodes do not need to be predefined before the discovery. e.g. node[01-10] 

    

    '(host|bmc)iprange' - Specify a bunch of ips that could be assigned to the new discovered nodes. The format could be 'start_ip-end_ip' or 'noderange format'. e.g. 192.168.1.0-192.168.2.255 or 192.168.[1-2].[10-20] 

    

    '[groups=&lt;groups&gt;]' - Specify the group of the new node. If not specified, the default is 'all'. 

    

    '[rack=&lt;rack&gt;] [chassis=&lt;chassis&gt;] [height=&lt;height&gt;] [unit=&lt;unit&gt;] [rank=rank]' - The specific physical location that set to the new discovered node. They are static parameters that will be same for all the discovered nodes in a discovery cycle. 

At the beginning of the command, a message will be displayed that which type of discovery is running: sequential discovery or profile discovery. And then a message will be displayed that how many available node names can be used. Since sometimes the noderange has been used for discovery that some of the node names in the noderange have been defined. 

e.g. '40 node names are available for the discovery' 

Note: need a message (doc or displayed by nodediscoverstart command?) to reminder user to enable the 'LLDP' on the switch so that the switch information could be discovery automatically. 

### Stop the discovery process:

Syntax of the command: 

    nodediscoverstop -v -h 

This command will stop the discovery process and clean the environment like restore the dhcpd configuration. 

Display how many nodes were discovery in the last discovery circle. 

e.g. '20 nodes have been discovered, node1, node2 ...' 

### List the discovered nodes:

Syntax of the command: 

  * nodediscoverls -v -h 
  * nodedisoverls (without argument) 

    Display the Sequential discovered node, when Sequential discovery is running; 
    Display the Profile discovered node, when Profile discovery is running; 
    Display all the nodes in the discoverydata table, when both Sequential and Profile discovery are NOT running. 

  * nodediscoverls -t seq|profile|switch|blade|undef 

    Display the specific type of nodes from discoverydata table that don't care whether the Sequential or Profile discovery is running. 

  * nodediscoverls -t undef [-l] [-u uuid] 

    Display the undefined nodes 

e.g. 
    
    nodename	ip		mac			date
    node1		192.168.1.0	xx:xx:xx:xx:xx:xx	xxx
    node2		192.168.1.1	xx:xx:xx:xx:xx:xx	xxx
    2 nodes have been discovered, node1, node2, ...
    

  


### Display the status of the discovery:

Syntax of the command: 
    
    nodediscoverstatus -v -h
    

Display the status of the discovery process: 

    'Node discovery for all nodes using profiles is running' (This is the message that PCM is using) 
    'Node discovery for all nodes using sequential discovery is running' 

Display the arguments that used for the discovery. 

### Manually discovery a node:

For the node which sent request but did not handled by any plugin (The appearance is that no node was defined for this request), we add a command 'nodediscoverdef' that help to define it manually. And plus the 'nodediscoverdef' command could be used to clean up the discovered entries. 

  * nodediscoverdef -u uuid -n node 

Define the entry which uuid is &lt;ifname&gt;!value,&lt;ifname&gt;!value,...' e.g. eth0!192.168.0.1,eth1!10.1.0.1 

The columns definition for this table: 

    uuid - the key of the table 
    node - the node name which assigned to the discovered node 
    method - the method could be one of: switch, blade, profile, sequential 
    discoverytime - the last time that get the discovery message 
    arch - the architecture of the node. e.g. x86_64 
    cpucount - the cpu number of the node. e.g. 32 
    cputype - the cpu type of the node. e.g. 'Intel(R) Xeon(R) CPU E5-2690 0 @ 2.90GHz' 
    memory - the size of the memory of the node. e.g. '198460852' 
    mtm - the machine type model of the node. e.g. '786310X' 
    serial - the serial number of the node. e.g. '1052EFB' 

    nicdriver - the driver of the nic. e.g. 'eth0!be2net,eth1!be2net' 
    nicipv4 - the ipv4 address of the nic. e.g. 'eth0!10.0.0.212/8' (only eth0 has ip configured) 
    nichwaddr - the hardware address of the nic. e.g. 'eth0!34:40:B5:BE:DB:B0,eth1!34:40:B5:BE:DB:B4' 
    nicpci - the pic device of the nic. e.g. 'eth0!0000:0c:00.0,eth1!0000:0c:00.1' 
    nicloc - the location of the nic. e.g. 'eth0!Onboard Ethernet 1,eth1!Onboard Ethernet 2' 
    niconboard - the onboard info of the nic. e.g. 'eth0!1,eth1!2' 
    nicfirm - the firmware description of the nic. e.g. 'eth0!ServerEngines BE3 Controller,eth1!ServerEngines BE3 Controller' 

    switchname - the switch name which the nic connected to. e.g. 'eth0!c909f06sw01' 
    switchaddr - the address of the switch which the nic connected to. e.g. 'eth0!192.168.70.120' 
    switchdesc - the description of the switch which the nic connected to. e.g. 'eth0!IBM Flex System Fabric EN4093 10Gb Scalable Switch, flash image: version 7.2.6, boot image: version 7.2.6' 
    switchport - the port of the switch that the nic connected to. e.g. 'eth0!INTA2' 

    otherdata - the left data which is not parsed to specific attributes (the complete message comes from genesis) 

For every discovery request, if a plugin (switch, blade, profile, sequential) has handled the discovery request successfully, add/update an entry with the uuid as key in the discoverydata table. 

### Start the discovery process

PCM 'profile' discovery is using the 'site.__PCMDiscover' to specify that 'profile' discovery is running. For sequential discovery, a new site attribute 'site.__SEQDiscover' is set to specify that 'sequential discovery' is running. 

For nodediscoverstart command, if 'noderange=&lt;noderange&gt;' is specified, set 'site.__SEQDiscover=xxx'; if 'networkprofile/imageprofile/hostnameformat' is specified, set 'site.__PCMDiscover=xxx'. 'xxx' is the parameters which passed to the nodediscoverstart command. 'xxx' will be used for findme and nodediscoverstop/status. 

Only one of the 'sequential discovery' and 'profile discovery' could be in running status. If 'site.__SEQDiscover' or 'site.__PCMDiscover' has been set, display an error message. 

Check the dynamic IP range has been set for the corresponding network object. 

Clean up the the entries that the 'discovery method' is 'sequential' from the discoverydata table. 

Calculate the number of the available node name and available IP address. If number of IP address less than number of node names, display an error message. 

[Algorithm] 
    
    Get all nodes from nodelist table, if 'mac' has been set, push to '%existed_nodes'
    Get all the nodes from noderange to '@nodes_pool'
    Calculate all the nodes which in @nodes_pool, but not in '%existed_nodes'.
    
    
    Get all nodes from hosts table to '%used_ip'
    Calculate the available IPs from IP range: startip-endip or 192.168.[1-2].[1-255]
    Calculate all the IPs from step 2', but not existed in '%used_ip'.
    

Looks like we need several places to store the parameters like noderange, iprange, dhcpcfgflag. 'profile' discovery stores the parameters in 'site.__PCMDiscover'. For 'sequential discovery', the parameters also could be stored in the 'site.__SEQDiscover'. The findme will get the parameters from site table. 

### Stop the discovery process

Clean the 'site.__SEQDiscover'; 

Get the number of the discovered node from discoverydata table which 'discovery method' is 'sequential'. 

The specific type of entries are removed when manually run nodediscoverstop. The entries should be kept when the discovery stopped automatically that I prefer that user could run 'nodediscoverls' to show the discovered node after the auto stop. 

### List the discovered nodes

Find the entries from discoverydata table which 'discovery method' is 'sequential'. 

Display the status of the discovery: 

    Check whether 'site.__SEQDiscover' was set and display the discovery is running or not. 

Display the arguments that used for the discovery. 

### Findme process

When a node get into discovery process, it'll send a 'findme' request to xcatd. 'sequential discovery' will implement a findme function to handle the new node definition. 

When the findme of 'sequential discovery' is invoked: 

Check the sequential discovery is running, otherwise try to add an entry to discoverydata table if no entry in the table with the 'uuid' of the node, this entry will be used to record the undefined node.&nbsp;? 

Get a free node name: 
    
    get all nodes from nodelist table, if mac has been set, push to '%existed_nodes'
    get all the nodes from noderange to '@nodes_pool'
    for each node in @nodes_pool, check whether it existed in '%existed_nodes', if not, it's a free node name.
    

Get a free host IP: 
    
    get all nodes from hosts table to '%used_ip'
    calculate the available IPs from IP range: startip-endip or 192.168.[1-2].[1-255]
    For each IP, check whether it existed in '%used_ip', if not, it's a free host ip.
    

If NO free node name is found, display an error message and stop the discovery process. Otherwise, go ahead 

Define/Update the node with the [node name] which get from above logic; 

Set the [host ip] of the node from the above logic; 

Set the [mac,arch,mtms] of the node from the findme request message; 

Set the [switch name, switch ip, switch port] attributes will be updated to switch,switches,hosts tables; 

If 'rack, chassis, height, unit' were specified when running 'nodediscoverstart', set them to the node accordantly. 

Define the bmc node with the node name append a '-bmc' suffix. e.g. 'node1-bmc' The IP address for the bmc comes from the available IP from bmciprange parameter. See algorithm that get the free host IP. 

Record the discovery result in the discoverydata table. 

### Manually discovery a node

Go through the disocverydata table, if there's entry that the 'node' column is not defined, this entry is a undefined node. 

The procedure inside: 

  * nodediscoverdef -u uuid -n node 
    
    Get the entry which uuid is 
    
