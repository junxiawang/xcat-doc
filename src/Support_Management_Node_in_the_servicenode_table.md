<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Adding the Management Node to the Service Node table](#adding-the-management-node-to-the-service-node-table)
    - [Changes to xcatconfig](#changes-to-xcatconfig)
    - [AAsn.pm](#aasnpm)
  - [Check current code accessing the servicenode table](#check-current-code-accessing-the-servicenode-table)
    - [ServiceNodeUtils.pm](#servicenodeutilspm)
    - [Utils.pm](#utilspm)
    - [Service Node table reads](#service-node-table-reads)
- [Future](#future)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

In 2.8, we have a new attribute, dhcpinterfaces, to be defined for the servicenodes and the management node in the servicenode table. This attribute will override the site.dhcpinterfaces attribute, if defined. As a result we will need to allow the __mgmtnode group to be added to the servicenode table. In the past, only service nodes were allowed in the table. We have to investigate the current code use of the servicenode table. PCM needed the dhcpinterfaces in some table that we can use a node group to map their profile to a group in the database. 

  


### Adding the Management Node to the Service Node table

This change will be in xCAT 2.8.2 and covered by SF defect 3052. 

#### Changes to xcatconfig

xcatconfig -m today adds the Management node to the database with the group defined as __mgmtnode. This function will also create a service node entry for the Management Node for the __mgmtnode group. The attributes that are currently setup on AIX or Linux by default in AAsn.pm will be set in the servicenode table. 

#### AAsn.pm

AAsn.pm will be modified to first check if the Management Node is defined in the database. If it is not defined in the servicenode table, it will setup the services that are currently setup by default on the management ndoe. If it is defined, it will honor the attributes set in the servicenode table for the management node and only setup those services. AAsn.pm does not remove or stop any services. 

### Check current code accessing the servicenode table

#### ServiceNodeUtils.pm

  * readSNInfo 
    * Does not use the servicenode table. 
  * isServiceReq 
    * used by AAsn.pm on the ServiceNode. Supplies IP/hostname of "ME". No impact. 
  * getAllSN - lists servicenodes 
    * called by plugins (aixinstall.pm,routes.pm) and db2sqlsetup (change password). to get the list of servicenode names. Even if we do a postgresql change password,we could work this out. This probably should be changed to exclude the MN. Problem is just excluding "ME" will not work because the plugins are calling on the servicenode out of process_request. I think maybe we need to insist the MN is put in as __mgmtnode and we exclude that group. We need to have a parameter to return the Management Node. aixinstall.pm does not care. routes should not get the management node. 
  * getSNandNodes - lists servicenodes and the nodes they service 
    * Called by AAsn.pm and snmove.pm. AAsn.pm uses to setup dhcp, but checks against "ME". snmove not so sure about the logic, but looks as if it is checking for a particular compute node in the returned values and then determining the SN. Does not use the servicenode table. 
  * getSNList- returns list of service nodes that enable a service (e.g dhcpserver). 
    * Need to look at the use of this routine, dhcp.pm. routes.pm, networks.pm 
    * This probably needs the MN not returned. Need to add an interface to also return the Management Node, like getAllSN. 
  * get_ServiceNode - gets the service node for the input node 
    * numberous plugins use this routine. This is the central routine for determining the current servicenode. Does not use the servicenode table at all. 
  * getSNformattedhash - calls get_ServiceNode and formats output 
    * See comments on get_ServiceNode, does not actually use the servicenode table 
  * getSNandCPnodes - Takes node range and returns an array of service nodes and an array of other nodes. 
    * used by updatenode for security. Right now updatenode already checks for MN in the list and error out, but it would probably be good to put a check in this routine also, or note that the MN could be in the list. 

#### Utils.pm

  * isSN - Reads the servicenode table and see if the node input is in it. Filter out MN as above. 
    * Lot of use of this. Checks for a particular nodename so should be ok. 
  * isServiceNode - checks for /etc/xCATSN 
  * isMN - checks for /etc/xCATMN 

#### Service Node table reads

  * setup.pm - writes to the table. 

## Future

  * setup.pm - maybe add entry to the servicenode table for the MN 
  * routes.pm - maybe add entry for ipforwarding for the MN. 
