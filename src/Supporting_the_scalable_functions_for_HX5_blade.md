<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [The functions will be supported for HX5](#the-functions-will-be-supported-for-hx5)
  - [lsflexnode:](#lsflexnode)
  - [mkflexnode](#mkflexnode)
  - [rmflexnode](#rmflexnode)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

HX5 is a new scalable blade server which is developed base on the eX5 technology. It can be expanded by MD - Memory Drawer (Which also occupy a blade slot) to support more memory, and two of the HX5 also can be connected together to supply high performance. 

There are several new concepts for this new blade: 
    
     Complex: It contains all the HX5 blades and Memory Drawers that connected together by card. That means it represents all the connected devices.
     Partition: A logic concept which containing part of the devices in a complex. Each partition can map to a system to install Operating System. Each partition could have 1HX5, 1HX5+1MD or 2HX5+2MD. (MD is the Memory Drawer)
     Blade slot node: The physical devices which installed in the slots of a chassis. It can be a HX5 or MD.
    

After the physical installation of HX5, the complex information can be gotten from AMM, it includes how many partitions and nodes are existing in this complex. Then the partitions can be created for this complex base on the node information of the complex. Then the partition can be power on to work. 

Each HX5 has two CPU sockets, if user want to have a four CPU system, a partition with 2 HX5 can be created for this requirement. 

## The functions will be supported for HX5

### lsflexnode:

A 'lsflexnode' command is needed to display the complex, parition and node information in a chassis. It also can just display the information for a specific node. 

Displaying all the complex, partition and node for a chassis, and relationship between them. (The value of some attribute will be replaced with description) 
    
    $ lsflexnode amm1
       amm1: Complex - 24068
       amm1: ..Partition number - 1
       amm1: ..Complex node number - 2
       amm1: ..Partition = 1
       amm1: ....Partition Mode - partition
       amm1: ....Partition node number - 1
       amm1: ....Partition status - poweredoff
       amm1: ....Node - 0 (logic id)
       amm1: ......Node state - poweredoff
       amm1: ......Node slot - 14
       amm1: ......Node type - processor
       amm1: ......Node resource - 2 (1866 MHz) / 8 (2 GB)
       amm1: ......Node role - secondary
       amm1: ..Partition = unassigned
       amm1: ....Node - 13 (logic id)
       amm1: ......Node state - poweredoff
       amm1: ......Node slot - 13
       amm1: ......Node type - processor
       amm1: ......Node resource - 2 (1866 MHz) / 8 (2 GB)
       amm1: ......Node role - unassigned
    

  
Displaying the attributes of a node which belong to a complex. 
    
    $ lsflexnode b13
       blade1: Flexnode state - poweredoff
       blade1: Complex id - 24068
       blade1: Partition id - 1
       blade1: Slot14: Node state - poweredoff
       blade1: Slot14: Node slot - 14
       blade1: Slot14: Node type - processor
       blade1: Slot14: Node resource - 2 (1866 MHz) / 8 (2 GB)
       blade1: Slot14: Node role - secondary
    

  


### mkflexnode

Creating a flexible node is to create a partition which including all the slots defined in the xCAT blade node. 

We do NOT need to define the complex and partition nodes in the xCAT. Just use the mp.id in the blade definition to express combination information of this node. Before defining it, user can uses the 'lsfexnode' command to display all the complex, partition and nodes for a chassis, so that they can know which nodes can be combined together. 

Define a blade node with slot range in the mp.id attribute 
    
    $ sudo lsdef b13
    Object name: b13
       arch=x86_64
       chain=shell
       currchain=shell
       currstate=shell
       groups=blade,compute,all
       id=13-14
       
    

Create a partition 
    
    $ mkflexnode b13
    

### rmflexnode

Delete a flexible node which created by the mkflexnode command. 
    
    $ rmflexnode b13
    
