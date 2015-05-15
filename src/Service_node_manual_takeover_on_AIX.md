<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Initial deployment](#initial-deployment)
- [Service node takeover](#service-node-takeover)
- [Switching back](#switching-back)
- [Changed Commands](#changed-commands)
- [Documentation](#documentation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

For reliability, availability, and serviceability purposes users may wish to configure backup service nodes in hierarchical cluster environments. 

The backup service node will be configured to be able to quickly take over from the original service node if a problem occurs. 

This is not an automatic failover feature. You will have to initiate the switch from the primary service node to the backup manually. The xCAT support will handle most of the setup and transfer of the nodes to the new service node. 

**TODO** \- What is the easiest way for the admin to get notified of SN failure????? 

Abbreviations used below: 

    

MN&nbsp;: - management node. 
SN&nbsp;: - service node. 
CN&nbsp;: - compute node. 

## Initial deployment

Integrate the following steps into the hierarchical deployment process. 

  1. Make sure both the primary and backup service nodes are installed, configured, and can access the MN database. 
  2. When defining the CNs add the necessary service node values to the "_servicenode_" and "_xcatmaster_" attributes of the node definitions. 
  3. (Optional) Create an xCAT group for the nodes that are assigned to each SN. This will be useful when setting node attributes as well as providing an easy way to switch a set of nodes back to their original server. 

ISSUE: what about DNS or network routes etc.??? 

**Note-**

    

**xcatmaster:**&nbsp;: The hostname of the xCAT service node _as known by the node_. 
**servicenode:**&nbsp;: The hostname of the xCAT service node _as known by the management node_. 

To specify a backup service node you must specify a comma-separated list of two service nodes for the "servicenode" value. The first one will be the primary and the second will be the backup for that node. 

For the "_xcatmaster_" value you should only include the primary name of the service node _as known by the node_. 

In the simplest case the management node, service nodes, and compute nodes are all on the same network and the interface name of the service nodes will be same for either the management node or the compute node. 

For this case you could set the attributes as follows: 
    
           chdef &lt;noderange&gt;  servicenode="xcatsn1,xcatsn2" xcatmaster="xcatsn1"
    

However, in some network environments the name of the SN as known by the MN may be different than the name as known by the CN. (If they are on different networks.) 

In the following example assume the SN interface to the MN is on the "a" network and the interface to the CN is on the "b" network. To set the attributes you would run a command similar to the following. 
    
           chdef &lt;noderange&gt;  servicenode="xcatsn1a,xcatsn2a" xcatmaster="xcatsn1b"
    

The process can be simplified by creating xCAT node groups to use as the &lt;noderange&gt; in the **chdef** command. 

To create an xCAT node group containing all the nodes that have the service node "SN27" you could run a command similar to the following. 
    
            mkdef -t group -o SN27group -w  servicenode=SN27
    

**Note:** When using backup service nodes you should consider splitting the CNs between the two service nodes. This way if one fails you only need to move half your nodes to the other service node. 

When you run the **nimnodeset** or **mkdsklsnode** commands to initialize the CNs these commands will automatically replicate the required NIM resources on the SN used by the CN. If you have a backup SN specified then the replications and NIM definition will also be done on the backup SN. This will make it possible to do a quick takeover without having to wait for replication when you need to switch. You can use the "-b" option with these commands to avoid the replication on the backup service node, but in this case you will have to re-run **nimnodest** or **mkdsklsnode** before you can use the backup SN. 

## Service node takeover

1) **Initialize the nodes on the new SN (if needed)**

If the NIM replication hasn't been run on the new SN then you must run either **nimnodeset** (diskful) or **mkdsklsnode** (diskless) to get the new SN configured properly. 

2) **Use the xCAT "snmove" command to reset the node attributes to point to the backup SN.**
    
       Syntax:
       snmove noderange [-d|--dest sn2] [-D|--destn sn2n]
               [-i|--ignorenodes]
       snmove -s|--source sn1 [-S|--sourcen sn1n] [-d|--dest sn2]
               [-D|--destn sn2n] [-i|--ignorenodes]
       snmove [-h|--help|-v|--version]
    

For example, if the SN named "SN27" goes down you could switch all it's node to the backup SN by running a command similar to the following. 
    
         snmove -s SN27
    

The **snmove** command will check and set several node attribute values. 

    

**servicenode:**&nbsp;: This will be set to either the second server name in the _servicenode_ attribute list or the value provided on the command line. 
**xcatmaster:**&nbsp;: Set with either the value provided on the command line or it will be automatically determined from the _servicenode_ attribute. 
**nfsserver:**&nbsp;: If the value is set with the source service node then it will be set to the destination service node. 
**tftpserver:**&nbsp;: If the value is set with the source service node then it will be reset to the destination service node. 
**monserver:**&nbsp;: If set to the source service node then reset it to the destination _servicenode_ and _xcatmaster_ values. 
**conserver:**&nbsp;: If set to the source service node then reset it to the destination _servicenode_ and run **makeconservercf**. 

For diskful nodes it will also run the NIM **niminit** command on the nodes and rerun several xCAT customization scripts to reset whatever services need to be re-targeted. 

  
3) **Reboot the diskless nodes**

The diskless CNs will have to be re-booted to have them switch to the new SN. Shut down the diskless nodes and run the "**rnetboot**" command to reboot nodes. This command will get the new SN information from the xCAT database and perform a directed boot request from the node to the new SN. When the node boots up it will be configured as a client of the NIM master on the new SN. For example, to reboot all the nodes that are in the xCAT group "SN27group" you could run the following command. 
    
        rnetboot SN27group
    

To shut down the nodes you can use the **xdsh** command to run the **shutdown** command on the nodes. If that doesn't work you can use the **rpower** command to shut the nodes down. 

DO NOT try to use the **rpower** command to reboot the nodes. This would cause the node to try to reboot from the old SN. 

## Switching back

The process for switching nodes back will depend on what must be done to recover the original service node. Essentially the SN must have all the NIM resources and definitions etc. restored before you can use it. 

If all the configuration is still intact you can simply use the **snmove** command to switch the nodes back. 

If the configuration must be restored then you will have to run either the **mkdsklsnode** (diskless) or **nimnodeset** (diskful) command. These commands will re-configure the SN using the common osimages defined on the xCAT management node. 

For example: 
    
        mkdsklsnode SN27group
    

This command will check each node definition to get the osimage it is using. It will then check for the primary and backup service nodes and do the required configuration for the one that needs to be configured. 

Once the SN is ready you can run the **snmove** command to switch the node definitions to point to it. For example, if you assume the nodes are currently managed by the "SN28" service node then could could switch them back to the "SN27" SN with the following command. 
    
        svmove SN27group -d SN27
    

If your compute nodes are diskless then they must be rebooted using the **rnetboot** command in order to switch to the other service node. 

## Changed Commands

     1) **snmove**

    

  * Change the usage to support just the new SN name or just a list of nodes to switch. 
  * Update the Linux code to handle the new usage 
  * Reset database values(already done for Linux) 
  * warning message if more than two servicenode attribute values 
  * Run the nimclient command on diskful AIX nodes 
  * Check if the required node resources, definitions, and initializations are done on backup SN. Provide a warning message if not. 

     2) **rmnimimage**

    

    

  * Remove osimage resources from primary AND backup SNs. 

     3) **mkdsklsnode** and **nimnodeset**

    

    

  * Do the replication, defines, initializations on both the primary and secondary service nodes. 

     4) **xcat2nim**

    

    

  * Define the nodes on both SNs 

     5) **rmdsklsnodes**

    

    

  * Remove the diskless nodes on both the primary and backup service nodes. 

## Documentation

     1) **snmove man page**
    
        **NAME**
             **snmove** - Move xCAT compute nodes from one xCAT service node to a backup service node.
       
       **SYNOPSIS**
              snmove noderange [-d|--dest sn2] [-D|--destn sn2n]
                    [-i|--ignorenodes]
              
              snmove -s|--source sn1 [-S|--sourcen sn1n] [-d|--dest sn2]
                   [-D|--destn sn2n] [-i|--ignorenodes]
             
              snmove [-h|--help|-v|--version]
       
       **DESCRIPTION**
             The snmove command moves a node or nodes from one service node to
             another.
            
             The use of backup service nodes in an xCAT hierarchical cluster can
             help improve the overall reliability, availability, and serviceability
             of the cluster.
            
             Before you run the snmove command it is assumed that the backup
             service node has been configured properly to manage the new node
             or nodes. (See the xCAT document named
             "Using xCAT Service Nodes with AIX" for information on how to set
             up backup AIX service nodes.).
            
             The snmove command can use the information stored in the xCAT
             database or information passed in on the command line to determine
             the current service node and the backup service node.
             
             To specify the primary and backup service nodes you can set the
             "servicenode" and "xcatmaster" attributes of the node definitions.
    
    
             The servicenode attribute is the hostname of the xCAT service node
             as it is known by the management node. The xcatmaster attribute
              is the hostname of the xCAT service node as known by the node.
             The servicenode attribute should be set to a comma-separated list
             so that the primary service node is first and the backup service
             node is second.  The xcatmaster attribute must be set to the
             hostname of the pimary service node as it is known by the node.
             
             When the snmove command is run it modifies the xCAT database to
             switch the the primary server to the backup server.
            
             It will also check the other services that are being used for the
             node, such as NFS, TFTP etc.  and if they were set to the original
             service node they will be changed to point to the backup service node. 
             
             If the -i option is specified, the nodes themselves will not be modified.
             Otherwise, syslog and NTP will be changed to use the new service node
             The user can run other postscripts using the updatenode command, after
             this command is done, to setup other applications such as monitoring.
             For AIX diskful (standalone) systems the snmove command will run the
             **nimclient -p** command on the node so that it will recognize the new
             service node as it's NIM master.
            
             When the snmove command is executed the new service node must be running but
             the original service node may be down.
           
        **OPTIONS**
             -s|--source
                       Specifies the hostname of the source service node
                       adapter facing the management node. It can be
                       found in the servicenode table.
             -S|--sourcen
                       Specifies the hostname of the source service node
                       adapter facing the nodes.
              -d|--dest Specifies the hostname of the destination service
                       node adapter facing the management node. It can be
                       found in the servicenode table.
             -D|--destn
                       Specifies the hostname of the destination service
                       node adapter facing the nodes.
             -i|--ignorenodes
                       No action will be done on the nodes. If not
                       specified, the syslog and setup ntp postscritps
                       will be rerun on the nodes to switch the syslog
                       and NTP server.
             -h|--help
                       Display usage message.
             -v|--version
                       Command Version.
        **EXAMPLES**
           
             1. To move a groups of nodes from one server nodes to
                another:
    
    
                  **snmove group1 -d xcatsn02 -D xcatsn02-eth1**
    
    
             2. To move all the nodes from one service nodes to another:
    
    
                  **snmove -s xcatsn01 -S xcatsn01-eth1 -d xcatsn02 -D xcatsn02-eth1**
    
    
             3. Move any nodes that have sn1 as their primary server to the backup SN set in the xCAT node definition.
            
                   **snmove -s sn1**
            
             4. Move all the nodes in the xCAT group named "nodegroup1" to their backup SNs.
             
                   **snmove nodegroup1** 
           
             5. Move all the nodes in xCAT group  "sngroup1" to the SN named "xcatsn2"
            
                   **snmove sngroup1 -d xcatsn2** 
             
        **FILES**
             /opt/xcat/sbin/snmove
       
        **SEE ALSO**
             noderange(3)
          
           
    

     4) '_**Using xCAT Service Nodes with AIX'**_ \- xCAT How-To 

A new section called **Using an AIX service node backup** will be added to the AIX service node documentation to explain how to use the service node backup feature. The content of this new section will be very similar to the "Overview", "Initial Deployment", "Service node takeover", and "Switching back" sections above. 
