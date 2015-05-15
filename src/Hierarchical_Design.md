<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Attribute Summary](#attribute-summary)
- [New servicenode Table](#new-servicenode-table)
- [Environments to Support](#environments-to-support)
- [Makedhcp](#makedhcp)
- [Nodeset](#nodeset)
- [Makedns](#makedns)
- [Makenetworks](#makenetworks)
- [Conserver](#conserver)
- [Distributing Commands Run by the Admin on the MN](#distributing-commands-run-by-the-admin-on-the-mn)
- [HW Ctrl Cmds](#hw-ctrl-cmds)
- [Scaling and HA Considerations](#scaling-and-ha-considerations)
- [Database Access](#database-access)
- [Setting Up the Service Nodes](#setting-up-the-service-nodes)
- [Details for Specific Commands](#details-for-specific-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

A few rules about how xCAT should behave in a hierarchical cluster (i.e. a cluster w/service nodes). 


## Attribute Summary

  * noderes.servicenode: the service node for this node as known by the mn. Used normally for distributing out cmds from the mn. 
  * noderes.xcatmaster: the service node for this node as known by the node. The default for several of the attrs below. 
  * noderes.tftpserver: the tftp service node for this node as known by the node (defaults back to noderes.xcatmaster) 
  * noderes.nfsserver: the service node that this node should get files from via http, ftp, etc. (as known by the node). 
  * noderes.monserver: the monitoring event collection point. Two hostnames separated by a comma: as known by mn, and as known by node 
  * nodehm.conserver: the service node that should provide console access to this node (as known by the mn) 
  * networks.dhcpserver: specifies the dhcpserver on each network. 
  * If the noderes/nodehm specific attrs are not specified for a node: 
    * if the servicenode table has at least one entry, try to guess which service node(s) should service this node based on networks 
    * if the servicenode table is empty, assume the node is serviced by the mn 

## New servicenode Table

  * Lists all the service nodes in your cluster and what services they should be running. You can set servicenode-related attributes in nodehm or noderes to explicitly state that either a specific sn or the mn should be used. 
  * Attributes: 
    * node - hostname of service node (as known by mn) 
    * nameserver - yes or 1 to set up dns caching (default is yes) 
    * dhcpserver - yes or 1 (default is yes) (may support including NIC names, dynamic range, noderange, but this is still being discussed) 
    * tftpserver - yes or 1 (default is yes) 
    * nfsserver - yes or 1 (default is yes) Note that this doesn't necessarily mean nfs. It is a general attr for any file access services (e.g. http, ftp) 
    * conserver - yes or 1 (default is yes) 
    * monserver - yes or 1 (default is yes) 
    * ntpserver - yes or 1 (default is yes) 
    * ldapserver - yes or 1 (ldap proxy) (default is yes) 
    * (can't have syslog in this table because the sn needs to set up syslog before the db access is established) 

## Environments to Support

  * Subnetted Service Nodes - Each service node is on its own subnet with the nodes it is responsible for. 
    * Every node/nodegroup has explict noderes.servicenode, noderes.xcatmaster, etc., entries. The user must ensure that each servicenode listed in one of those attributes is also added to the servicenode table for correct servicenode install/configuration. 
  * Pooled Service Nodes - The cluster network is logically flat and any service node can service any node. 
    * All service nodes are listed in the service node table. (The nodename key in the servicenode table is "as known by the management node".) 
    * noderes.xcatmaster is null, indicating that the SN that responds to the node boot should be its SN. 
    * noderes.servicenode can contain a list of SNs, so that top down cmds like xdsh can be dispatched to any one of them (trying them in order) 
  * Combination of Subnetted and Pooled Service Nodes - Compute nodes are segregated into subnets, but within each subnet there is a pool of service nodes. 
    * noderes.xcatmaster is null, indicating that the SN that responds to the node boot should be its SN. 
    * noderes.servicenode can contain a list of SNs in that pool, so that top down cmds like xdsh can be dispatched to any one of them (trying them in order) 
  * site.disjointdhcps should be set to 1 so that the dhcpd.conf on the SN will be filled in with only the nodes that have that SN listed in their noderes.servicenode attribute 

## Makedhcp

  * Command will be sent to all service nodes in servicenode table that have dhcpserver attr filled in. 
  * On each service node: 
    * the NICs on the SN will be compared to the xcat networks table and all nodes that are on a subnet with this SN will be put in its dhcpd.conf 

## Nodeset

  * For now, service nodes that have servicenode.tftpserver filled in will always mount /tftpboot read/write. 
  * This means the nodeset cmd can be done completely from the mn. 
  * This also means there is no need for guessing, because all sn's that have the tftp service set up will be able to serve any node. 

## Makedns

  * Every sn in the servicenode table that has the nameserver attr filled in will have dns set up on it. 
  * The DNS on the SN is just a forwarding/caching DNS set up to forward all requests to the MN, and then remember the answer 

For more information about name resolution in an xCAT Cluster, refer to the following: 

[Cluster_Name_Resolution] 

## Makenetworks

  * The cmd should be sent to every sn in the servicenode table, so that it can discover its networks. 

## Conserver

  * Conserver will always use nodehm.conserver to determine who should have the console for each node. 
  * The cmd makeconservercf should be distributed to the service nodes based on nodehm.conserver 

## Distributing Commands Run by the Admin on the MN

  * Use noderes.servicenode to determine who should run the cmd for each node 
  * For nodes that don't have a noderes.servicenode value, randomly distribute the cmds to the sn's in the servicenode table 

## HW Ctrl Cmds

  * If noderes.servicenode is set for a hw ctrl point (mm, hmc, fsp, etc.), then hw ctrl cmds should be distributed to those service nodes 
    * I.e. if "rpower node1 on" is run, xcat 1st looks up the hcp (e.g. ppc.hcp) of node1. Assume it is called fsp1. Then it looks up noderes.servicenode for fsp1. If that is set, for example, to sn1, then the rpower cmd will be dispatch to sn1 and then sn1 will contact fsp1 to power on node1. 

## Scaling and HA Considerations

The goal for the service nodes is to configure them such that we can have more than one in a building block and any node in that BB can be serviced by any service node in the BB.&nbsp; This way if we need better scaling within the BB, we can simply add more service nodes.&nbsp; And to provide HA we can simply have multiple service nodes and if one service node goes down, the other service nodes within the BB can pick up the load.&nbsp; For example, all service nodes within a BB have DHCP and/or NIM configured for all the compute nodes in the BB, and have all the same OS images on them.&nbsp; Thus when a compute node boots, it will broadcast PXE or bootp for a server, and whichever service node responds first can deploy the node. 

The paragraph above states the ultimate goal, but there may be some services that can't be set up this way.&nbsp; In these cases, we may have to divide up responsibility of the compute nodes between the service nodes.&nbsp; But we want to limit the number of services we have to do this for, so we limit how much we have to fail over to another service node when one service node dies. 

Also, not all services for a compute node have to be provided by the same service node.&nbsp; For example, TFTP can be served from one machine, DHCP from another, and NFS from another. 

## Database Access

Information about all the nodes in the whole cluster is kept in the xCAT DB on the management node (EMS).&nbsp; This is the master source of the data.&nbsp; Specific information that is needed by a service node for a specific operation must be accessed somehow from the management node.&nbsp; There are several possible ways to do this: 

  * Every plugin is structured such that it is split into 2 functions:&nbsp; preprocess_request() and process_request().&nbsp; The preprocess_request() function queries the DB for whatever data it needs (for that operation for the nodes specified) and stores it temporarily in internal hash tables.&nbsp; The hash tables are passed to process_request() to actually perform the operation.&nbsp; When a plugin is executed directly on the MN, both are run in succession.&nbsp; When the operation needs to be distributed out to the service nodes, preprocess_request() is run on the MN, then the data is passed to the appropriate SNs and process_request() is run on the SNs. *The is the preferred solution.* 
  * Have the SN query the MN for the data it needs, using the client/server protocol.&nbsp; For example, when a service node needs to be configured to respond correctly to compute node PXE requests, the makedhcp command is run on the SN and it is passed a list of nodes that this service node is responsible for.&nbsp; This command queries the particular node attributes it needs, using the client/server connection to xcatd on the management node.&nbsp; Then it writes out dhcpd.conf. *This will cause a scaling bottleneck on the management node* for large clusters, because all the service nodes will be asking the management node for data at the same time? 

## Setting Up the Service Nodes

The management node installs (or diskless boots) the service nodes and uses the servicenode postinstall script to set up the node as a service node. 

## Details for Specific Commands

Because the scaling challenges for each operation vary greatly, we can't use the same approach for every operation.&nbsp; This section enumerates many of the commands and operations and describes what approach will be used for each to overcome the scaling issues. (This info may be out of date): 

  * PXE Booting Compute Nodes:&nbsp; DHCP will be configured on each service node to respond to the PXE requests for its nodes.&nbsp; The /tftpboot file system will be mounted from the management node so it will have all the proper hex files.&nbsp; The /install file system will also be mounted from the MN so the OS image files will be available if the compute node is being installed or diskless booted. 
  * For system p support, each service node is a NIM master.&nbsp; The MN is a NIM master also and originally all the SPOT and lpp_source resources on the MN should be put in /install.&nbsp; Since this file system will be mounted on the service nodes, the appropriate NIM resources can be defined on each service node and refer (when necessary) to the software files in /install.&nbsp; (Configuring NIM automatically configures the bootp daemon.) 
  * The rpower command for system x (BMC) will be passed along to the service nodes (along with the node list and attributes) via the xcat client/server mechanism.&nbsp; The service node will communicate with each node's BMC to perform the operation.&nbsp; Note, that the BMC user/pw info must also be sent, so the client/server XML communication may need to be encrypted. 
  * Should the "simple" rpower commands (query, on, off) for system p be done straight from the MN (w/o involving the service node), since it is really the HMC that has to implement it anyway?? 
  * The boot-to-openfirmware rpower command will be distributed to the service nodes. 
  * The compute nodes will forward their syslog entries to the service node.&nbsp; Will the service nodes forward all syslog entries to the MN? 
  * Each service node will run an intermediate DNS daemon. 
  * Each service node will run an intermediate NTP daemon. 
  * One designated service node in each BB will run conserver and the compute nodes will have their consoles directed to that.&nbsp; The rconsole command on the MN will connect to the conserver on the relevant SN.&nbsp; A specific conserver.cf for each SN needs to be generated with just its CNs. 
  * Each node will have a MonitorService attribute to designate which service node will be the collection point for events and performance monitoring info. 
