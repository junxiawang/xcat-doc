<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Requirement](#requirement)
- [Basic Idea](#basic-idea)
- [Implementation](#implementation)
  - [Collecting data](#collecting-data)
  - [Saving the data in xCAT DB](#saving-the-data-in-xcat-db)
  - [Limitations](#limitations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


## Requirement

Some cluster users require that xCAT saves the hardware inventory such as cpu count, memory size and hard disk size in the xCAT database for easy access. This feature request has been giving lower priority until recently when customers wanted to register baremetal nodes discovered by xCAT to OpenStack cluster. The OpenStack baremetal registration requires that the following attributes be given: 

  * mac address 
  * number of cpus 
  * memory size 
  * disk size 

xCAT has already saved the node's mac address in the mac table. We need to save other information as well in xCAT database. 

## Basic Idea

When nodes are being discovered by xCAT, there is a script in genesis kernel that collects node information such as mac address in band. We need to add some code there to collect more necessary information. The collected information are sent back to xcatd on the server so that it can be stored in xCAT database. 

## Implementation

### Collecting data

dodiscovery script in xCAT-genesis-script rpm will handle the collection. We'll add code to collect hard disk size since other information are collected already. There are many ways to get hard disk sizes: 

  * lshw -C disk -short 
  * cat /proc/partitions 
  * cat/sys/dev/blocks/sd*/size 
  * dmesg | grep 'logical blocks' 

We choose to use cat /proc/partitions because lshw is not shipped with most of the Linux distros. 

After the data collection, the dodiscovery script sends the data to the xcatd on the server that responded its DHCP request. The command sent to the xcatd is called 'findme'. 

### Saving the data in xCAT DB

A new table will be created for storing this kind of data. It will be named 'hwinv', meaning hardware inventory. The column names will be: 

  * cputype 
  * cpucount 
  * memory 
  * disksize 
  * comments 
  * disable 

These attributes will also be added to the node definition so that they will be shown by lsdef command for a node. We can add more inventories in future releases. 

Upon receiving the 'findme' command, xCAT will save the data in this new table. 

### Limitations

The following shows the discovery types and if they support the node hardware inventory data collection for this release. 

  * switch discovery (yes) 
  * sequential discovery (yes) 
  * profiled discovery (?) 
  * blade discovery (no) 
  * hpblade discovery (no) 
