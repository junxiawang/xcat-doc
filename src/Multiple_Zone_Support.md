<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Required Reviewers](#required-reviewers)
  - [Required Approvers](#required-approvers)
- [Overview](#overview)
- [Multiple zone support](#multiple-zone-support)
  - [root ssh keys](#root-ssh-keys)
    - [compute nodes](#compute-nodes)
    - [service nodes](#service-nodes)
    - [**switches, hardware control**](#switches-hardware-control)
  - [xCAT changes](#xcat-changes)
    - [**Table Changes**](#table-changes)
    - [**New Commands**](#new-commands)
      - [**mkzone**](#mkzone)
      - [**mkzone Implementation**](#mkzone-implementation)
      - [**rmzone**](#rmzone)
      - [**chzone**](#chzone)
      - [**chzone implemenation**](#chzone-implemenation)
      - [**lszone**](#lszone)
  - [Code changes](#code-changes)
  - [Rules for handling zone](#rules-for-handling-zone)
  - [Issues](#issues)
  - [Migration](#migration)
  - [Documentation](#documentation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

  
Note: See [Multiple_Zone_Support2] 


### Required Reviewers

  * Linda Mellor 
  * Bin XA Xu (Platform) 

### Required Approvers

  * Guang Cheng Li 

## Overview

Two new customer requirements are covered by this design. 

The first requirement is to be able to take an xCAT Cluster managed by one xCAT Management Node and divide it into multiple zones. The nodes in each zone will share common root ssh keys. This allows the nodes in a zone to be able to ssh to each other without password, but cannot do the same to any node in another zone. You might even call them secure zones. 

Note:These zones share a common xCAT Management Node and database including the site table, which defines the attributes of the entire cluster. 

There will be no support for AIX. 

## Multiple zone support

The multiple zone support requires several enhancements to xCAT. 

### root ssh keys

Currently xCAT changes root ssh keys on the service nodes (SN) and compute nodes (CN) that are generated at install time to the root ssh keys from the Management node. It also changes the ssh hostkeys on the SN and CN to a set of pre-generated hostkeys from the MN. Putting the public key in the authorized-keys file on the service nodes and compute nodes allows passwordless ssh to the Service Nodes (SN) and the compute nodes from the Management Node (MN). This setup also allowed for passwordless ssh between all compute nodes and servicenodes. The pre-generated hostkey makes all nodes look like the same to ssh, so you are never prompted for updates to known_hosts 

#### compute nodes

Having zones that cannot passwordless ssh to nodes in other zones requires xCAT to generate a set of root ssh keys for each zone and install them on the compute nodes in that zone. In addition the MN public key must still be put in the authorized_keys file on all the nodes in the non-hierarchical cluster or the Service Node public key on all the nodes that it services for hierarchical support. 

  


#### service nodes

We will still use the MN root ssh keys on any service nodes. Service Nodes would not be allowed to be a member of a zone. Service nodes must be able to ssh passwordless to each other, especially to support Service nodes pools. 

#### **switches, hardware control**

We will still use the MN root ssh keys on any devices, switches, hardware control. All ssh access to these is done from the MN or SN, so they will not be part of any zone. 

  


### xCAT changes

To support multiple zones we have the proposed changes: 

#### **Table Changes**

A new table **zone** will be created. 

key:zone name 

sshkeydir - directory containing root ssh RSA keys. 

#### **New Commands**

For this implementation we are proposing we can do the following: 

  * make a new zone 
  * remove an existing zone 
  * add nodes to a zone 
  * remove nodes from a zone 
  * but not be able to move nodes from one zone to another. 

Move, I think this is very complex and out of the scope of being supported in 2.8.4. This can be debated. 

Note: these command will be packaged in xCAT-server rpm. They must run on the Linux Management Node. There will be no support for AIX in this release. I think checking that the MN is Linux is enough for now when the command runs. We could check if any node in the noderange is AIX ( mixed clusters). 

##### **mkzone**

mkzone will be used to do the following: 

  * define a zone name 
  * assign nodes to the zone 
  * if root ssh private key provided then 
    * generated root ssh public key using input private key 
  * else 
    * generated the root ssh keys (RSA) 

  


##### **mkzone Implementation**

mkzone will have the following interface: 
    
    mkzone &lt;noderange&gt; &lt;zonename&gt; |  --defaultzone&gt; [-k &lt;full path to the ssh private key&gt;]
    

Note:-k optional, -n or --default provided 

It will do the following: 

  * For each node in the noderange it will add to the nodelist.groups attribute, a new group by the zonename or if the --defaultzone flag is set then the new group will be the default __Managed. 
  * If a ssh private key is supplied (-k), it will generate the ssh public key and store both in /etc/xcat/sshkeys/&lt;zonename&gt; directory. 
  * If no (-k) then it will generate a set of root ssh keys for the zone and store them in /etc/xcat/sshkeys/&lt;zonename&gt;. 
  * It will create a zone table entry with the key=zonename or __Managed ( --defaultzone option) and the zone.sshkeydir attribute with the directory name containing the keys /etc/xcat/sshkeys/&lt;zonename&gt;. 

##### **rmzone**
    
    rmzone  -n &lt;zonename&gt;
    

rmzone will be used to do the following: 

  * remove nodes from their defined zone - remove the zonename group. 
  * cleanup /etc/xcat/sshkeys/&lt;zonename&gt;
  * remove zone.zonename entry. 
  * Cleanup root ssh keys for that zone and zone table entry. 
  * rmzone will error, if zonename is the default __Managed zone. 

##### **chzone**
    
    chzone  -n &lt;zonename&gt;   [-k  &lt;full path to the ssh private key&gt;] [-K] [-a &lt;noderange&gt; [-r &lt;noderange&gt;]
    

  


chzone will be used to do the following: 

  * regenerate ssh keys (-k) using input private key 
  * regeneate ssh keys ( -K) both private and public 
  * add nodes to zone ( -a) 
  * remove nodes from zone ( -r) 

##### **chzone implemenation**

  * (-k)| (-K) will generate new keys and update /etc/xcat/sshkeys/&lt;zonename&gt;. 
  *     * update zone.sshkeysdir attribute ( not sure if needed) 
  * (-a) will add the nodes in the noderange to the zone by adding the group zonename to the nodes. I guess at this point we need to make sure it is not in any other zone. This will not take affect until reinstall or xdsh -k / updatenode -K is run to update the ssh keys. 
  * (-r) will remove the nodes in the noderange from the zone by removing the nodelist.group zonename attribute. 

  


##### **lszone**
    
    lszone [ -n &lt;zonename&gt; ]
    

  


lszone will be used to do the following: 

  * If no parameters, will show a list of zones defined 
  * If zonename provided, will show the path to the ssh keys 

Note: nodels zonename will display all the nodes assigned. 

### Code changes

This support affects several existing xCAT components: 

  * xdsh -k 
  * updatenode -K 
  * getcredentials 
  * remoteshell 
  * Postage.pm - zone name must be added to the mypostscript table 
  * rspconfig - think no impact, hardware ssh is from MN or SN's. 

### Rules for handling zone

  * A node may be in no more than 2 zones, the default __Managed zone and a user defined zone. 
    * If a node is in the __Managed zone and a user defined zone, the root ssh keys for the user defined zone will be used on the nodes. 
  * A node may be only in the __Managed zone. 
    * If a node is only in the __Managed zone, the root ssh keys defined for the __Managed zone will be used. 
  * A node does not have to be a member of a zone. 
    * If a node is not in any zone, then ~/.ssh keys will be used. 

### Issues

Some of the issues discussed: 

  


  * Moving nodes from one zone to another. Security concerns? This has to do with when you move a node from one zone to another for a period of time, it still have passwordless access to the nodes in the other zone until updated. 
  * Are there problems running commands across zones, that is a noderange that span zones? 
  * Should Service Nodes be limited to servicing one zone? 
  * Hardware control, any issues/restrictions? 

### Migration

If a node is not defined in a zone, root ssh keys and passwords must work as today. This makes sure that a xCAT upgrade does not disrupt an existing xCAT installation. 

Would like to have all customers using a generated root ssh key. I think with this support documented, the mkzone command gives them the ability to switch from using root/.ssh keys to a new generated key. They can define their zone as all the compute nodes in their cluster. They can use the --defaultzone option. This leaves the change under their control. 

### Documentation

We would need a new document on setting this type of cluster up and managing it. Hierarchy adds even more complexity. 
