<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Using VirtualBox Nodes](#using-virtualbox-nodes)
- [Cookbooks](#cookbooks)
- [Options for Virtual Clusters](#options-for-virtual-clusters)
- [Interconnection between xCAT and VirtualBox](#interconnection-between-xcat-and-virtualbox)
- [Setting up xCAT](#setting-up-xcat)
- [Virtual Clusters using more than one physical machine](#virtual-clusters-using-more-than-one-physical-machine)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


## Using VirtualBox Nodes

This file handles the VirtualBox plugin, which is now included in xCAT 2.2 release. 

  


## Cookbooks

  * [Using VirtualBox Nodes - Step by Step](Using_VirtualBox_Nodes_Step_by_Step) 

  


## Options for Virtual Clusters

There are several options for Virtual Clusters that can be realized with VirtualBox and xCAT management.  
The following figure shows two major options: 

[Image:Xcat_vbox_master_options.png] 

One option (a) is the installation of xCAT besides VirtualBox to manage its virtual compute nodes.  
The management network will be realized through VirtualBox Virtual Host Interfaces (HIFs) - virtual network interfaces for each virtual machine on the physical host machine. 

Another option (b) is the installation of VirtualBox on any of the supported operating systems.  
In this case one virtual machine becomes the management node (with Linux and xCAT installed).  
The management network can then be realized with VirtualBox Internal Networking only, which is fast an secure. The management node can be accessed through NAT or HIF. 

  


## Interconnection between xCAT and VirtualBox

Convenient functions, like installing compute nodes over the network, already work if xCAT and VirtualBox machines are located in the same network with DHCP enabled.  
In order to switch on and off VirtualBox machines and thus to boot and reinstall them, the VirtualBox plugin for xCAT comes into play.  
The interconnection is shown in the following figure: 

[Image:Xcat_vbox_network_connection.png] 

The blue box shows the management node, no matter if this is a physical machine running xCAT (and VirtualBox) or if it is a virtual machine inside a VirtualBox instance.  
Only a network connection between that management node and the VirtualBox Web Service needs to be established. The Web Service comes with the VirtualBox installation and needs to be started on each host machine. The VirtualBox Web Service speaks the Simple Object Access Protocol (SOAP) and functions as one of the interfaces to all VirtualBox settings and its virtual machines. 

  


## Setting up xCAT

Each VirtualBox Web Service needs to be registered in the new **websrv** xCAT table with its TCP/IP Port and login credentials. Their _nodetype_ Attributes needs to be set to _**websrv**_ in the _nodetype_ table and their _ip_ Attribute to the according IP Address in the _host_ table.  
The mapping between virtual machines and theirs host machines will be specified in the existing **vm** xCAT 2.1 table, simply using their xCAT names. Finally each virtual machine requires the _mgt_ or at least the _power_ Attibute to be set to **vbox** in the _nodehm_ table.  
See a more detailled description with examples in the cookbook [Using VirtualBox Nodes - Step by Step](Using_VirtualBox_Nodes_Step_by_Step) . 

  


## Virtual Clusters using more than one physical machine

The Virtual Cluster does not need to be restricted on one physical machine.  
Several VirtualBox host machines can be managed by xCAT as long as a network connection exists. 

For example the previous option that uses a virtual management node (b) results in the following network configuration: 

 
[[img src=Xcat_vbox_network_hifs.png]]

Each virtual machine has a virtual network interface (**V**), which is connected to one VirtualBox Host Interface (**H**IF).  
All VirtualBox HIFs need to be connected to one of the host machine's physical network interfaces (**P**) with help of a software bridge.  
Finally there must be a connection between the host machines.  
The VirtualBox User Manual gives a very good explanation of how to implement the different networking options: http://www.virtualbox.org/wiki/Downloads . 

With use of service nodes, the advantages of VirtualBox Internal Networking might also be used for such Virtual Clusters: 


[[img src=Xcat_vbox_network_options.png]] 

While the first option (a) needs HIFs for each virtual machine as mentioned above, the second option (b) can utilize the VirtualBox Internal networking for the management network between the copute and service nodes and just use two HIFs for the interconnection. The latter option prevents to send all the management network traffic through the physical network interfaces, even if not explicitly needed. 

So there are lots of Virtual Cluster options, which can be realized with the VirtualBox - xCAT combination. 
