<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Required Reviewers](#required-reviewers)
  - [Required Approvers](#required-approvers)
- [Overview](#overview)
- [Multiple SubCluster support](#multiple-subcluster-support)
  - [root ssh keys](#root-ssh-keys)
    - [compute nodes](#compute-nodes)
    - [service nodes](#service-nodes)
  - [root password](#root-password)
  - [xCAT changes](#xcat-changes)
    - [**Table Changes**](#table-changes)
    - [**New Commands**](#new-commands)
      - [**mksubcluster**](#mksubcluster)
      - [**Implementation**](#implementation)
      - [**rmsubcluster**](#rmsubcluster)
      - [**chsubcluster**](#chsubcluster)
    - [**chsubcluster implemenation**](#chsubcluster-implemenation)
  - [Code changes](#code-changes)
  - [Issues](#issues)
  - [Migration](#migration)
  - [Documentation](#documentation)
- [mkvlan enhancements](#mkvlan-enhancements)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

  
[Design_Warning](Design_Warning) 

This design is replaced with [Multiple_Zone_Support] 

  



### Required Reviewers

  * Linda Mellor 

### Required Approvers

  * Guang Cheng Li 

## Overview

Two new customer requirements are covered by this design. 

The first requirement is to be able to take an xCAT Cluster managed by one xCAT Management Node and divide it into multiple subclusters. The nodes in each subcluster will share common ssh keys and root password. This allows the nodes in a subcluster to be able to ssh to each other without password, but cannot do the same to any node in another subcluster. 

Note:We are calling these subclusters, because they share a common xCAT Management Node and database including the site table which defines the attributes of the entire cluster. 

The second requirement is for mkvlan enhancements (TBD). 

## Multiple SubCluster support

The multiple subcluster support requires several enhancements to xCAT. 

### root ssh keys

Currently xCAT changes root ssh keys on the service nodes (SN) and compute nodes (CN) that are generated at install time to the root ssh keys from the Management node. It also changes the ssh hostkeys on the SN and CN to a set of pre-generated hostkeys from the MN. Putting the public key in the authorized-keys file on the service nodes and compute nodes allows passwordless ssh to the Service Nodes (SN) and the compute nodes from the Management Node (MN). This setup also allowed for passwordless ssh between all compute nodes and servicenodes. The pre-generated hostkey makes all nodes look like the same to ssh, so you are never prompted for updates to known_hosts 

#### compute nodes

Having subclusters that cannot passwordless ssh to nodes in other subclusters requires xCAT to generate a set of root ssh keys for each subcluster and install them on the compute nodes in that subcluster. In addition the MN public key must still be put in the authorized_keys file on the nodes in the non-hierarchical cluster or the SN public key for hierarchical support. 

Question: How about the common ssh hostkeys? Should we generate a set of those for each subcluster? 

#### service nodes

We will still use the MN root ssh keys on any service nodes. Service Nodes would not be allowed to be a member of a subcluster. 

### root password

Currently xCAT puts the root password on the node only during install. It is taken from the passwd table where key=system. The new subcluster support requires a unique password for each subcluster to be installed. 

### xCAT changes

To support multiple subclusters we have the proposed changes: 

#### **Table Changes**

A new table **Cluster** will be created. 

key:subcluster name 

password - root password for this subcluster 

sshkeydir - directory containing root ssh RSA keys. 

#### **New Commands**

For this implementation we are proposing we can make a subcluster, remove a subcluster, but not be able to move nodes from one subcluster to another. I think this is very complex and out of the scope of being supported in 2.8.4. This can be debated. 

##### **mksubcluster**

mksubcluster will be used to do the following: 

  * define a subcluster name 
  * assign nodes to the subcluster 
  * if root to ssh private key provided then 
    * generated root ssh public key using input private key 
  * else 
    * generated the root ssh keys (RSA) 
  * take in the root password for the subcluster 

##### **Implementation**

mksubcluster will have the following interface: 
    
    mksubcluster &lt;noderange&gt; -n &lt;subclustername&gt;  [-k &lt;full path to the ssh private key&gt;]
    

Note: The command will prompt for the subcluster root password or take env variable containing password. 

It will do the following: 

  * For each node in the noderange it will add to the nodelist.groups attribute, a new group by the subclustername. 

  


  * If a ssh private key is supplied (-k), it will generate the ssh public key and store both in /etc/xcat/sshkeys/&lt;subclustername&gt; directory. 
  * If no (-k) then it will generate a set of root ssh keys for the cluster and store them in /etc/xcat/sshkeys/&lt;subclustername&gt;

  


  * It will create a cluster.password table entry with the key=subclustername, password the input root password and the cluster.sshkeydir attribute with the directory name containing the keys /etc/xcat/sshkeys/&lt;subclustername&gt;. 

##### **rmsubcluster**
    
    rmsubcluster  -n &lt;subclustername&gt;
    

rmsubcluster will be used to do the following: 

  * remove nodes from their defined subcluster - remove the subcluster group. 
  * cleanup /etc/xcat/sshkeys/&lt;subclustername&gt;
  * remove cluster.subclustername entry. 
  * Cleanup root ssh keys for that subcluster and cluster table entry. 

##### **chsubcluster**
    
    chsubcluster  -n &lt;subclustername&gt; [-p]  [-k  &lt;full path to the ssh private key&gt;] [-K] [-a &lt;noderange&gt; [-r &lt;noderange&gt;]
    

Note: if using the -p flag will prompt for password or take env variable containing password. 

chsubcluster will be used to do the following: 

  * change the password (-p) 
  * regenerate ssh keys (-k) using input private key 
  * regeneate ssh keys ( -K) both private and public 
  * add nodes to subcluster ( -a) 
  * remove nodes from subcluster ( -r) 

#### **chsubcluster implemenation**

  * (-p) will update the cluster table with the new password. 
  * (-k)| (-K) will generate new keys and update /etc/xcat/sshkeys/&lt;subclustername&gt;. 
  *     * update cluster.sshkeysdir attribute ( not sure if needed) 
  * (-a) will add the nodes in the noderange to the subcluster by adding the group subcluster name to the nodes. I guess at this point we need to make sure it is not in any other subcluster. This will not take affect until reinstall or xdsh -k / updatenode -K is run to update the ssh keys. Also we need to address the issue of the user will have to change the osimage for the node to pick up the new root password. 
  * (-r) will remove the nodes in the noderange by removing the nodelist.group subcluster attribute. 

### Code changes

This support affects several existing xCAT components: 

  * xdsh -k 
  * updatenode -K 
  * getcredentials 
  * remoteshell 
  * Postage.pm - subcluster name must be added to the mypostscript table 
  * rspconfig - think no impact, hardware ssh is from MN or SN's. 
  * nodeset ( put appropriate passwd for install) 
  * packimage, liteimg - we have design work to do here because genimage/packimage/liteimg do not support a noderange thus currently can only support updating the image with passwd table system entry. 

### Issues

Some of the issues discussed: 

  * Support for multiple root passwords in stateless and statelite images. Interface does not support. 
  * Moving nodes from one subcluster to another. Security concerns? This has to do with when you move a node from one subcluster to another for a period of time, it still have passwordless access to the nodes in the other subcluster until updated. 
  * Are there problems running commands across subclusters, that is a noderange that span subclusters? 
  * Should Service Nodes be limited to servicing one subcluster? 
  * Hardware control, any issues/restrictions? 

### Migration

If a node is not defined in a subcluster, root ssh keys and passwords must work as today. This makes sure that a xCAT upgrade does not disrupt an existing xCAT cluster. 

Would like to have all customers using a generated root ssh key even if not using subclusters. If the node is not defined in a subcluster, then the key would be generated and stored in /etc/xcat/sshkeys/xcat(maybe system). How could we migrate current customers without disruption. 

### Documentation

We would need maybe a new document on setting this type of cluster up and managing it. Hierarchy adds even more complexity. 

## mkvlan enhancements

Needed mkvlan enhancements (TBD). But here a come comments about current support. 

Currently it only supports Cisco and some modules of BNT switches (EN4093,G8000,G8124,G8264, 8264E). To support more BNT modules, we need to update the OID table because each BNT modules uses different OIDs for the same function (a very bad design by BNT). And to support other switch vendors like Juniper, a significant code change needs to be done because currently Juniper does not support vlan function through SNMP interface. We have to use its own libraries to have it done. This needs framework change in our vlan code. 
