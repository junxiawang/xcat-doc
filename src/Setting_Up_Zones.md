<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Migration](#migration)
- [Set Up Zones](#set-up-zones)
  - [ssh key path](#ssh-key-path)
    - [**sshbetweennodes**](#sshbetweennodes)
- [Using Zone Commands](#using-zone-commands)
  - [Making a zone](#making-a-zone)
  - [Changing a zone](#changing-a-zone)
  - [Removing zones](#removing-zones)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

In xCAT 2.8.4 and later releases, xCAT will support a concept of multiple **zones** in the Cluster. If using hierarchy, be sure that your service nodes are at the same level as the Management Node as is always required by xCAT. 

Although this is one xCAT Cluster managed by one Management Node (MN) using the same site table for cluster definitions, the nodes in the cluster can be divided into multiple zones that have their root ssh keys managed separately. 

Each defined zone has it own root's ssh RSA keys, so that any node assigned to that zone can be setup for root on a node in the zone to be able to ssh without a password to any other node in the same zone. The idea is that nodes in one zone cannot ssh without being prompted for a password to nodes in another zone. 

Currently xCAT changes root ssh keys on the service nodes (SN) and compute nodes (CN) that are generated at install time to the root ssh keys from the Management node. It also changes the ssh hostkeys on the SN and CN to a set of pre-generated hostkeys from the MN. Putting the RSA public key in the authorized-keys file on the service nodes and compute nodes allows passwordless ssh to the Service Nodes (SN) and the compute nodes from the Management Node (MN). Today, by default, all nodes in the xCAT cluster are setup to be able to passwordless ssh to other nodes except when using the site sshbetweennodes attribute. More on that later. The pre-generated hostkey makes all nodes look like the same to ssh, so you are never prompted for updates to known_hosts 

The new support only addresses the way we generate and distribute root's ssh RSA keys. Hostkey generation and distribution is not affected. It only supports setting up zones for the root userid. Non-root users are not affected. The Management node (MN) and Service Nodes (SN) are still setup so that root can ssh without password to the nodes from the MN and SN's for xCAT command to work. Also, the SN's should be able to ssh to each other with a password. Compute nodes and Service Nodes are **not** setup by xCAT to be able to ssh to the Management Node without being prompted for a password. This is to protect the Management Node. 

In the past, the setup allowed compute nodes to be able to ssh to the SN's without a password. Using zones, will no longer allow this to happen. Using zones only allows compute nodes to ssh without password to compute node, unless you add the service node into the zone which is not considered a good idea. 

  * IF you put the service node in a zone, it will no longer be able to ssh to the other servicenodes with being prompted for a password. 
  * Allowing the compute node to ssh to the service node, could allow the service node to be compromised, by anyone who gained access to the compute node. 
  * It is recommended to not put the service nodes in any zones and then they will use the **default zone** which today will assign the root's home directory ssh keys as in previous releases. More on the **default zone** later. 

## Migration

If you do not wish to use zones, your cluster will continue to work as before. The root ssh keys for the nodes will be taken from the Management node's root's home directory ssh keys or the Service node's root's home directory ssh keys (hierarchical case) and put on the nodes when installing, running xdsh -K or updatenode -k. To continue to operate this way, **do not define a zone**. The moment you define a zone in the database, you will begin using zones in xCAT. 

## Set Up Zones

Setting up zones only applies to nodes. We will still use the MN root ssh keys on any devices, switches, hardware control. All ssh access to these devices is done from the MN or SN. The commands that distribute keys to these entities will not recognize zones (e.g. rspconfig, xdsh -K --devicetype). You should never define, the Management Node in a zone. The zone commands will not allow this. 

### ssh key path

The ssh keys will be generated and store in /etc/xcat/sshkeys/&lt;zonename&gt;/.ssh directory. You must not change this path. xCAT will manage and sync this directory to the service nodes as need for hierarchy. 

#### **sshbetweennodes**

When using zones, the site table sshbetweennodes attribute is no longer use. You will get a warning that it is no longer used, if it is set. You can just remove the setting to get rid of the warning. The zone table sshbetweennodes attribute is used so this can be assigned for each zone. When using zones, the attribute can only be set to yes/no. Lists of nodegroups are not supported as was supported in the site sshbetweennodes attributes. With the ability of creating zones, you should be able to setup your nodes groups to allow or not allow passwordless root ssh as before. 

## Using Zone Commands

There are three new commands to support zones: 

  * mkzone - Creates the zones 
  * chzone - changes a previously created zone 
  * rmzone - removes a zone 

There is a lot of information in the man page for each of these commands which you should reference. 

**Note**: It is highly recommended that you only use the zone commands for creating and maintaining your zones. They do a lot of maintaining of tables and directories for the zones when they are run. 

### Making a zone

The first time you run mkzone, it is going to create two zones. It will create the zone you request, but automatically add the xCAT default zone. This command creates the two zones , but does not assign it to any nodes. There is a new attribute on the nodes called zonename. As long as it is not defined for the node, then the node will use what is currently defined in the database as the defaultzone. In our case above, you see that xcatdefault is the default zone and the ssh keys will come from /root/.ssh. 

**Note:** if zones are defined in the zone table, there must be one and only one default zone. If a node does not have a zonename defined and there is no defaultzone in the zone table, it will get an error and no keys will be distribute. 

For example: 
 
~~~~   
    mkzone zone1
    
    
    lsdef -t zone -l
    Object name: xcatdefault
       defaultzone=yes
       sshbetweennodes=yes
       sshkeydir=/root/.ssh
    Object name: zone1
       defaultzone=no
       sshbetweennodes=yes
       sshkeydir=/etc/xcat/sshkeys/zone1/.ssh
~~~~     

Another example which makes the zone and defines the nodes in the **mycompute** group in the zone and also automatically creates a group on each node by the zonename is the following: 
 
~~~~    
    makezone zone2  -a mycompute -g
    
    
    [manage-02][/root](/root)> lsdef mycompute
    Object name: node1
       groups=zone2,mycompute
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles
       zonename=zone2
~~~~     

  
At this time we have only created the zone, assigned the nodes and generated the SSH RSA keys to be distributed to the node. To setup the ssh keys on the nodes in the zone, run the following **updatenode** command. It will distribute the new keys to the nodes, it will automatically sync the zone key directory to any service nodes and it will regenerated your mypostscript.&lt;nodename&gt; files to include the zonename, if you are using precreatemypostscripts enabled. 

~~~~     
    updatenode mycompute -k
~~~~     

You can also use the following command but it will not regenerated the mypostscript.&lt;nodename&gt; file. 

~~~~     
    xdsh mycompute -K
~~~~     

  
If you need to install the nodes, then run the following commands. They will do everything during the install that the updatenode did. Running nodeset is very important, because it will regenerate the mypostscript file to include the zonename attribute. 
 
~~~~    
     nodeset mycompute osimage=mycomputeimage
     rsetboot mycompute net
     rpower mycompute boot
~~~~     

### Changing a zone

After you create a zone, you can use the chzone command to make changes. Some of the things you can do are the following: 

  * add nodes to the zone 
  * remove nodes from the zone 
  * regenerated the keys 
  * change sshbetweennodes setting 
  * make it the default zone 

The following command will add node1-node10 to zone1 and create a group called zone1 on each of the nodes. 
 
~~~~    
    chzone zone1 -a node1-node10 -g
~~~~     

The following command will remove node20-node30 from zone1 and remove the group zone1 from those nodes. 

~~~~     
    chzone zone1 -r node2--node30 -g
~~~~     

  
The following command will change zone1 such that root cannot ssh between the nodes without entering a password. 
 
~~~~    
    chzone zone1 -s no
    
    
    lsdef -t zone zone1
    Object name: zone1
       defaultzone=no
       sshbetweennodes=no
       sshkeydir=/etc/xcat/sshkeys/zone1/.ssh
~~~~     

  
The following command will change zone1 to the default zone. Note, you must use the -f flag to force the change. There can only be one default zone in the zone table. 
   
~~~~  
    chzone zone1 -f --defaultzone
    
    
    lsdef -t zone -l
    Object name: xcatdefault
       defaultzone=no
       sshbetweennodes=yes
       sshkeydir=/root/.ssh
    Object name: zone1
       defaultzone=yes
       sshbetweennodes=no
       sshkeydir=/etc/xcat/sshkeys/zone1/.ssh
~~~~     

Finally, if your root ssh keys become corrupted or compromised you can regenerate them: 
 
~~~~    
    chzone zone1 -K

~~~~     

or 

~~~~     
    chzone zone1 -k <path to SSH RSH private key>

~~~~     

  
As with the mkzone commands, these commands have only changed the definitions in the database, you must run the following to distribute the keys. 

~~~~     
     updatenode mycompute -k
~~~~     

or 
 
~~~~    
     xdsh mycompute -K

~~~~     

### Removing zones

The rmzone command will remove a zone from the database. It will also remove the zone name from the zonename attribute on all the nodes currently defined in the zone and as an option (-g) will remove the group zonename from the nodes. The zonename attribute will be undefined, which means the next time the keys are distributed, they will be picked up from the defaultzone. It will also remove the /etc/xcat/sshkeys/&lt;zonename&gt; directory. 

**Note:** rmzone will always remove the zonename defined on the nodes in the zone. If you use other xCAT commands and end up with a zonename defined on the node that is not defined in the zone table, when you try to distribute the keys you will get errors and the keys will not be distributed. 

  

~~~~     
      rmzone zone1 -g
~~~~     

If you want to remove the default zone, you must use the -f flag. You probably only need this to remove all the zones in the zone table. If you want to change the default zone, you should use the chzone command. 

**Note:** if you remove the default zone and nodes have the zonename attribute undefined, you will get errors when you try to distribute keys. 
  
~~~~   
      rmzone zone1 -g -f
~~~~     

  
As with the other zone commands, after the location of a nodes root ssh keys has changed you should use one of the following commands to update the keys on the nodes: 
 
~~~~    
     updatenode mycompute -k
~~~~     

or 

~~~~     
     xdsh mycompute -K
~~~~     
