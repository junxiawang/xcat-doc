<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Required Reviewers](#required-reviewers)
  - [Required Approvers](#required-approvers)
- [Overview](#overview)
- [Multiple zone support](#multiple-zone-support)
  - [root ssh keys](#root-ssh-keys)
    - [compute nodes](#compute-nodes)
    - [**switches, hardware control**](#switches-hardware-control)
    - [**Management Node**](#management-node)
    - [**Service Nodes**](#service-nodes)
  - [xCAT changes](#xcat-changes)
    - [**Table Changes**](#table-changes)
    - [**New Commands**](#new-commands)
      - [**mkzone**](#mkzone)
      - [**mkzone Implementation**](#mkzone-implementation)
      - [**rmzone**](#rmzone)
      - [**chzone**](#chzone)
    - [listing zone information](#listing-zone-information)
  - [Code changes](#code-changes)
  - [Rules for handling zone](#rules-for-handling-zone)
  - [Issues](#issues)
  - [Migration](#migration)
  - [Documentation](#documentation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

This document is the current design for Multiple zone support. 


### Required Reviewers

  * Linda Mellor 
  * Bin XA Xu (Platform) 

### Required Approvers

  * Guang Cheng Li 

## Overview

A new customer requirement is covered by this design. 

The requirement is to be able to take an xCAT Cluster managed by one xCAT Management Node and divide it into multiple zones. The nodes in each zone will share common root ssh keys. This allows the nodes in a zone to be able to ssh to each other without password, but cannot do the same to any node in another zone. You might even call them secure zones. 

Note:These zones share a common xCAT Management Node and database including the site table, which defines the attributes of the entire cluster. 

There will be no support for AIX. 

## Multiple zone support

The multiple zone support requires several enhancements to xCAT. 

### root ssh keys

Currently xCAT changes root ssh keys on the service nodes (SN) and compute nodes (CN) that are generated at install time to the root ssh keys from the Management node. It also changes the ssh hostkeys on the SN and CN to a set of pre-generated hostkeys from the MN. Putting the public key in the authorized-keys file on the service nodes and compute nodes allows passwordless ssh to the Service Nodes (SN) and the compute nodes from the Management Node (MN). This setup also allowed for passwordless ssh between all compute nodes and servicenodes. The pre-generated hostkey makes all nodes look like the same to ssh, so you are never prompted for updates to known_hosts 

#### compute nodes

Having zones that cannot passwordless ssh to nodes in other zones requires xCAT to generate a set of root ssh keys for each zone and install them on the compute nodes in that zone. In addition the MN public key must still be put in the authorized_keys file on all the nodes in the non-hierarchical cluster or the Service Node public key on all the nodes that it services for hierarchical support. 

  


#### **switches, hardware control**

We will still use the MN root ssh keys on any devices, switches, hardware control. All ssh access to these is done from the MN or SN, so they will not be part of any zone. 

#### **Management Node**

The management node cannot be assigned to a zone. xdsh -K and updatenode -k are already not allowed to the Management node. 

#### **Service Nodes**

Service nodes may be assigned to a zone. We need to document that if they are not in the same zone, then they will not be able to ssh passwordless to each other - service node pools will not work for example. 

### xCAT changes

To support multiple zones we have the proposed changes: 

#### **Table Changes**

A new table **zone** will be created. 

key:zone name 

sshkeydir - directory containing root ssh RSA keys. 

defaultzone - yes/1 or no/0 

Note: defaultzone, if not set, default is no. Only one defaultzone=yes is allowed and there must exist one default. 

sshbetweennodes - yes/1 or no/0, default is yes and that means we setup to allow passwordless root ssh between nodes 

  
The **nodelist** table will have a new attribute: 

zonename - this will be the name of the zone that the node is currently assigned to. 

#### **New Commands**

For this implementation we are proposing we can do the following: 

  * make a new zone 
  * remove an existing zone 
  * add nodes to a zone 
  * remove nodes from a zone 

  
Note: these command will be packaged in xCAT-client rpm. They must run on the Linux Management Node. There will be no support for AIX in this release. I think checking that the MN is Linux is enough for now when the command runs. We will check if any node in the noderange is AIX ( mixed clusters). 

##### **mkzone**

mkzone will be used to do the following: 

  * define a zone name 
  * optionally make it the default zone 
  * optionally assign nodes to the zone 
    * optionally add group &lt;zonename&gt;to the nodes in the noderange 
  * if root ssh private key provided then 
    * generated root ssh public key using input private key 
  * else 
    * generated the root ssh keys (RSA) 

##### **mkzone Implementation**

mkzone will have the following interface: 
    
    mkzone &lt;zonename &gt;  [ --defaultzone] [-k &lt;full path to the ssh RSA private key&gt;] [ -a &lt;noderange&gt;] [-g] [-f] [-s &lt;yes|no&gt;]  [-V]
    mkzone &lt;zonename&gt;/.ssh.
    

  *     * if --defaultzone is input, then it will set the zone.defaultzone attribute to yes; otherwise it will set to no. if --defaultzone is input and another zone is currently the default, then the -f flag must be used to force a change to the new defaultzone. If -f flag is not use an error will be returned and no change made. 
  * if -a &lt;noderange&gt; is defined 
    * For each node in the noderange it will add to the nodelist.zonename attribute for that node the zonename. 
    * if -g is defined 
      * it will add the group name zonename to each node in the noderange. 
  * If a ssh private key is supplied (-k), it will generate the ssh public key and store both in /etc/xcat/sshkeys/&lt;zonename&gt;/.ssh directory. 
  * If no (-k) then it will generate a set of root ssh keys for the zone and store them in /etc/xcat/sshkeys/&lt;zonename&gt;/.ssh. 
  * if -f is input with --defaultzone, then we will force a change of what is currently defined as the defaultzone to the current zone. Otherwise we will error out, if there is currently a defined default in the zone table. 

If there is no currently defined default zone, an error will be reported. There must be one default zone in the zone table. 

  * If -s entered, the zone.sshbetweennodes will be set to yes or no. It defaults to yes. 
  * If -h, displays usage 
  * If -v, displays release and build date 
  * if -V, verbose mode. 

##### **rmzone**
    
    rmzone  zonename [-g] [-f] [-V]
    rmzone &lt;zonename&gt;  on MN .
    

Note: Checks for id_rsa and id_rsa.pub in the directory. If not there will not remove the directory. This is to make sure that the rm -rf on the directory does not remove some arbitrary directory, since the directory will be taken from the zone table sshkeydir attribute. Also if the directory is /root/.ssh, I will not remove the id_rsa or id_rsa.pub file. That will be left to the admin. 

  * remove zone.zonename entry from the zone table. 
  * For each node with nodelist.zonename=zonename 
    * set nodelist.zonename=undefined 

Note:This means if there is a default zone still in the zone table that will be used as the nodes new zone. If the zone table is empty then it goes back to using &lt;roothome&gt;.ssh keys 

  *     * if -g entered, remove the zonename group from each of the nodes 
  * Checks you can only remove the defalultzone, if it is the last zone table entry. 
  * if rmzone is used to remove the defaultzone then the -f flag must be used. 
  * If -h, displays usage 
  * If -v, displays release and build date 
  * if -V, verbose mode. 

Note: If -f is not used then you will get an error and the zone will not be removed. Removing the default zone means that any node that does not have a zonename defined will not have ssh keys assigned. The admin should define a new default zone using chzone or mkzone before removing the default. 

##### **chzone**
    
    chzone  zonename [-k &lt;fullpath to the ssh private key&gt;] [-K] [-a &lt;noderange&gt; | -r &lt;noderange&gt;] [-g] [-f] {--default] [-s &lt;yes|no&gt;]  [-V]
    chzone &lt;noderange&gt; entered,  add nodes to zone 
    

  *     * change nodelist.zonename attribute to the zonename 
    * If -g entered add a group=zonename to the nodes 
  * If -r &lt;zonename&gt;/.ssh. 
  * (-a) will add the nodes in the noderange to the zone by changing the nodelistzonename to the nodes. 
    * (-g) will for each node add the group=zonename from the nodelist.groups attribute. 
  * (-r) will remove the nodes in the noderange from the zone by changing the nodelist.zonename attribute to the new zone name. 
    * (-g) will for each node remove the group=zonename from the nodelist.groups attribute. 
  * (--defaultzone) will cause the zone.defaultzone attribute for the input zonename to be set to yes. 
    * If another zone in the zone table is the current default, it's zone.defaultzone attribute will be set to no. 

Note: When you add and and remove node, it will not take affect until reinstall or xdsh -k / updatenode -K is run to update the ssh keys. 

#### listing zone information

With this implementation, the existing xCAT command can list needed zone information. 

  * lsdef -t zone - will list all defined zones 
  * lsdef -t zone -l - will list each zone and its attrbutes from the zone table (sshkeydir, defaultzone setting) 
  * lsdef -t node -w zonename=myzone will list all the nodes in the myzone. 
  * if you have used the -g flag to define the nodes in the group=zonename, then 
    * nodels zonename - gives you all the nodes in the zone 

### Code changes

This support affects several existing xCAT components: 

  * xdsh -K 
    * pick up zone keys 
    * sync zone keys to the service nodes 
  * updatenode -k 
    * should be covered by xdsh -K work 
  * getcredentials 
    * pick up zone keys - it will accept a zonename for to find out the path to the keys for ssh_root_key 
    * also need to add to return id_rsa.pub (ssh_root_key_pub). Only returns id_rsa (pvt) today. 
  * remoteshell - send zonename ( if set) to getcredentials request. Also request both public and private key if zonename. 
  * Postage.pm 
    * zone name will be added to the mypostscript table ZONENAME env variable. 
    * ENABLESSHBETWEENNODES must be set based on zone table setting and fix current code. See https://sourceforge.net/p/xcat/bugs/3994/ 
  * rspconfig - think no impact, hardware ssh is from MN or SN's. 
  * makeknownhosts - no change this works from the generated ssh host keys and we are not changing this. 

### Rules for handling zone

  * A node's nodelist.zonename attribute defines which zone it is currently assigned. Only one zone is supported. 
  * If a node's nodelist.zonename attribute is defined, the ssh keys of that zone will be used. If the zone is not in the zone table, it is an error. 
  * If a node's nodelist.zonename attribute is undefined: 
    * The zone which is the current defaultzone in the zone table will be used. If no defaultzone, report error. 

### Issues

Some of the issues discussed: 

  


  * Moving nodes from one zone to another. Security concerns? This has to do with when you move a node from one zone to another for a period of time, it still have passwordless access to the nodes in the other zone until updated. 
  * Are there problems running commands across zones, that is a noderange that span zones? 
  * Should Service Nodes be limited to servicing one zone? 
  * Hardware control, any issues/restrictions? 

Hierarchy support 

  * Hierarchy, the keys are put in /etc/xcat/sshkeys/&lt;zonename&gt;/.ssh by this design. To distribute them from a service node using remoteshell, they are going to need to exist on the service nodes in that same directory. They cannot be in a mounted directory because there is a private key. I would suggest that we use xdcp rsync to sync the /etc/xcat/sshkeys to the service nodes when the zone commands run and sync up this directory /etc/xcat/sshkeys with what is on the MN. Again though, we can have the issue of it being sync'd before the admin is ready and the next reboot of a node would pick up the wrong keys. Probably need another flag on the zone commands to sync service nodes. 

### Migration

If a node is not defined in a zone, root ssh keys and passwords must work as today. This makes sure that a xCAT upgrade does not disrupt an existing xCAT installation. This should work with this design. This is accomplished by the fact, we come up with an empty zone table. As long as no zones are defined, we use the old code paths and the site table sshbetweennodes attribute. Once they start using zones, we no longer support the site table sshbetweennodes attribute. You will set the zone table sshbetweennodes attribute for each zone. The groups option supported in the site table sshbetweennodes attribute will not be supported in the zone table. 

Would like to have all customers using a generated root ssh key. I think with this support documented, the mkzone command gives them the ability to switch from using root/.ssh keys to a new generated key. They can define their zone as all the compute nodes in their cluster. They can use the --defaultzone option. This leaves the change under their control. 

### Documentation

We would need a new document on setting this type of cluster up and managing it. Hierarchy adds even more complexity. 
