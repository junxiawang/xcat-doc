<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Setup IP routes between the MN and the CNs](#setup-ip-routes-between-the-mn-and-the-cns)
  - [Overview](#overview)
  - [Implementation](#implementation)
    - [Setup service node IP forwarding](#setup-service-node-ip-forwarding)
    - [Setup routing](#setup-routing)
    - [makeroutes command](#makeroutes-command)
    - [Modify makedhcp command](#modify-makedhcp-command)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Setup IP routes between the MN and the CNs

### Overview

In a large cluster where service nodes are needed, the networks is often configured in one of the following ways. 

  1. The MN and SNs are in a network, the SNs and CNs are in a different network. (Figure 1) 
  2. The MN, SNs and CNs are all in a flat network. (Figure 2) 
  3. The MN and SNs are in a network, each SN has its own network with a subset of CNs. (Figure 3) 

[[img src=F1.JPG]] [[img src=F2.JPG]] [[img src=F3.JPG]] 

There is often need to be able to ping or ssh from the MN to the CNs. However, in case 1 and 3, the MN and the CNs are not in a same network, the SN will be used as gateway to connect the MN to the CNs. xCAT will help setting up the routes automatically if it is required by the user. 

### Implementation

There are two steps involved in setting up the IP connection between the MN and CNs. The first is to configure the SNs to enable **IP forwarding**. The second is to setup the routing table on the MN. In order the make it automated, the user needs to input the requirements into xCAT database. 

#### Setup service node IP forwarding

A new column called **ipforward** in the servicenode table will be added. It can be set by hand or by **makeroutes** (see later) command. When xcatd on a service node is started (without the -r option), AAsn.pm will check this value. If it is set to 1, the ip forwarding will be enabled on it and if 0 the ip forwarding will be disabled. 

#### Setup routing

Routing will be specified in the **routes** table. The table has the following columns: 

  * routename (primary key) 
  * net 
  * mask 
  * gateway 
  * ifname 
  * metric&nbsp;?? 

For PERCS cluster, the routing info will be specified in the xCAT configuration file and this table will be populated by the **xcatsetup** command. 

The routes specified in the xCAT **routes** table will be added to the Kernel IP routing table for the os by **makeroutes** command. 

#### makeroutes command

This new command will read the routing info from xCAT's **routes** table and then add the routes to the Kernel IP routing table for the os. It also gets all the gateways from the table, if a gateway is a service node, it then make servicenode.ipforward=1 and then goes to the service node and enable the ipforwarding on that service node. 
    
       **makeroutes -v|-h**
       **makeroutes [-r routenames]**  
                    add given routes to the os route table. routenames is a list of comma separated route names defined in the **routes** table. If omitted, all routes defined in the **routes** table will be added to the os route table.
       **makeroutes -d [-r routenames]** 
                    delete given routes from the os route table. routenames is a list of comma separated route names defined in the **routes** table. If omitted, all routes defined in the **routes** table will be deleted from the os route table.
       **makeroutes [-n net] [-m mask] [-g gateway]**
                    add the specified routes into the os route table.
       **makeroutes -d [-n net] [-m mask] [-g gateway]**
                    remove the specified routes from the os route table.
    

#### Modify makedhcp command

With current implementation of **makedhcp**, the dhcp leases file on a service node contains all the nodes that is within the same network. This is not feasible for a large cluster where all SNs and CNs are in flat network, the .leases file will contain all the CNs which will be huge. For DHCP request/response, we still want to break the CNs into groups according to the noderes.servicenode settings for the nodes. A new **site** table attribute called **disjointdhcps** will be used to indicate if the grouping is used or not. The **makedhcp** command will check for this setting and create the .leases files accordingly on the service nodes. All the flags for **makedhcp** remain the same. 
