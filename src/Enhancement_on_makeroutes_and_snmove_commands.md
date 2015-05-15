<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [makeroutes command](#makeroutes-command)
- [snmove command](#snmove-command)
- [How to setup routes in a hierarchical cluster](#how-to-setup-routes-in-a-hierarchical-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Note: this is an xCAT design document, not an xCAT user document. If you are an xCAT user, you are welcome to glean information from this design, but be aware that it may not have complete or up to date procedures.


# makeroutes command

The original makeroutes format was designed to create routes on the management node based on the data from CAT's **routes** table. The format was: 
    
      makeroutes [-r|--routename r1[,r2...]]
      makeroutes -d|--delete [-r|--routenames r1[,r2...]]
      makeroutes [-n|--net net] [-g|--gateway gw] [-m|--mask netmask]
      makeroutes  -d|--delete [-n|--net net] [-g|--gateway gw] [-m|--mask netmask]
      makeroutes [-h --help|-v|--version]
    

In this release, we want to be able set up the routes not only for the mn, but also for any nodes in the cluster. Thus a new column called **routenames** will be added in the **noderes** table to indicate what routes to setup for the node. It will be a comma separated list of rout names. The route name is defined in the **routes** table. For example: 
    
     # tabdump routes
     #routename,net,mask,gateway,ifname,comments,disable
     "**r2**","10.2.2.0","255.255.255.0","10.2.0.102","eth0",,
     "**r1**","10.2.1.0","255.255.255.0","10.2.0.101","eth1",,
    
    
     # tabdump noderes
     #node,servicenode,netboot,tftpserver,nfsserver,monserver,nfsdir,installnic,primarynic,discoverynics,cmdinterface,xcatmaster,current_osimage,next_osimage,nimserver,routenames,comments,disable
     "cn1","xcatsn21","yaboot",,"10.2.1.100",,,"eth0","eth0",,,"10.2.1.100",,,,**"r1,r2"**,,
    

The routes table can be setup manually by the admin or use xcatsetup command. The node range will be added to the command, and -n,-g and -m will be removed to reduced confusion. All the routes handled by this command will be entered in the **routes** table and the routes will be referenced by the route name only. Here is the new format for this command: 
    
      makeroutes [noderange] [-r|--routename r1[,r2...]]
      makeroutes [noderange] -d|--delete [-r|--routenames r1[,r2...]]
      makeroutes [-h --help|-v|--version]
    

when noderange is omitted, it will cretae/delete routes on the management nodes. 

For the mn, a **site** table key called **mnroutenames** will be used for the name of the routes that are to be setup on the mn. 

# snmove command

snmove command moves a group of nodes from one service node to another. It was released with xCAT 2.5. [Service_node_take_over](Service_node_take_over) In this release, the we have done some work on AIX. [Service_node_manual_takeover_on_AIX](Service_node_manual_takeover_on_AIX). In addition to that, the following two enhancements will be made: 

1\. Change the default gateway to be the destination SN if the **networks.gateway** is 'xcatmaster' for the node. 

When the gateway is 'xcatmaster' for the network the node is in, it means that the default gateway is the service node. The original default gateway was set to be the source sn. When there is a need to move the nodes to a new service node, the old sn may very well not be working, thus the default gateway will not be functioning. We must set the default gateway to be the destination sn. 

2\. Allow scripts to run 

xCAT runs some of postscripts like syslog, setupntp and mkresolvconf after a group of nodes are moved from one sn to another. Sometimes the user's application and software also need to be reconfigured after the nodes are moved to a new sn. A new flag **-P** will be added to the snmove command. It takes a list of postscripts and run them on the nodes. All the scripts will have to be saved under /install/postscripts. If no scripts are provided following -P, all postscripts for the nodes will be run. For example: 
    
      snmove node1-node15 -s sn1 -d sn2 -D sn2n -P myscript,myscript2
    

# How to setup routes in a hierarchical cluster

1\. Assuming we have a hierarchical cluster with 2 service nodes and 20 compute nodes. 

node1-node10 are in a group called grp1, and they are managed by sn1, the backup service node for it is sn2. 

node11-node20 are in a group called grp2, and they are managed by sn2, the backup service node for it is sn1. 

  
2\. For grp1, set 
    
      noderes.servicenode="sn1,sn2"
      noderes.xcatmaster="sn1-eth1"
    

For grp2, set: 
    
     noderes.servicenode="sn2,sn1"
     noderes.xcatmaster="sn2-eth1"
    

where sn1-eth1 and sn2-eth1 are the nics facing the nodes. 

  
3\. Networks: 

Assume mn, sn1 and sn2 are in one network called **mn_net**. 
    
     netname"mn_net"
     net=10.0.0.0
     netmask=255.255.255.0
     gateway=10.0.0.100
    
    
     mn's ip=10.0.0.100
     sn1's ip=10.0.0.101
     sn2's ip=10.0.0.102.
    

Assume sn1,sn2,grp1 and grp2 are in another network called **sn_net**. 
    
     netname="sn_net"
     net=10.1.0.0
     netmask=255.255.0.0
     gateway=&lt;xcatmaster&gt;
    

  

    
     sn1's ip=10.1.1.100
     grp1's ip=10.1.1.*
     sn2's ip=10.1.2.100
     grp2's ip=10.1.2.*
    

gateway=&lt;xcatmaster&gt; means that the node will use its service node as the default gateway. In this case, nodes in grp1 will have sn1 as the default gateway. nodes in grp2 will have sn2 as default gateway. 

  
4\. Define routes in the routes table 
    
     #routename,net,mask,gateway,ifname,comments,disable
     "mn_r1","10.1.0.0","255.255.0.0","10.0.0.101",,"This is for mn reaching grp1 through sn1",
     "mn_r2","10.1.0.0","255.255.0.0","10.0.0.102",,"This is for mn reaching grp2 through sn2",
     "node_r1","10.0.0.0","255.255.255.0","10.1.1.100",,"This is for grp1,grp2 reaching mn through sn1-eth1",
     "node_r2","10.0.0.0","255.255.255.0","10.1.2.100",,"This is for grp1,grp2 reaching mn through sn2-eth1",
    

  
5\. Define routes for the mn and nodes. 
    
      site.mnroutenames="mn_r1,mn_r2"
    

For all nodes in grp1 and grp2 
    
      noderes.routenames="node_r1,node_r2"
    

  
6\. Setup the routes on the mn. 
    
     makeroutes 
    

  
7\. Setup the routes on the node if they are up and running. 
    
     makeroutes grp1,grp1
    

  
8\. Add "setroute" to the postscripts.postbootscripts so that the defined routes will be automatically setup next then the node boots up. 
