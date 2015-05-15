<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Changing the Hosthame/IP address on the Linux nodes managed by xCAT](#changing-the-hosthameip-address-on-the-linux-nodes-managed-by-xcat)
  - [Changing nodes that are Service Nodes](#changing-nodes-that-are-service-nodes)
    - [Database Changes for Service Nodes](#database-changes-for-service-nodes)
- [Changing domain names](#changing-domain-names)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


This document is a general process for Linux and may not cover all cluster configuration.


## Changing the Hosthame/IP address on the Linux nodes managed by xCAT
If you need to change the hostname and/or the ip address of a compute node, you need to do the following on the Management Node.  If the node is a Service Node, you still do  the following and then also the additional steps outlined below.
Change your networks table definitions, to match the new cluster setup.

~~~~

lsdef -t network -l
~~~~

Remove the nodes from DNS configuration

~~~~

makedns -d <noderange>

~~~~

Remove the nodes from the DHCP configuration

~~~~

makedhcp -d <noderange>

~~~~

Remove the nodes from the conserver configuration

~~~~
makeconservercf -d <noderange>

~~~~

Change the hostname in the xCAT database (This command only supports one at a time). For many nodes you will have to write a script.

~~~~
 chdef -t node -o node1 -n node2  (changes node1 to node2 in the database)

~~~~

Change the name and ip address in the /etc/hosts file
If you do not use the hosts table in xCAT to create the /etc/hosts file, then edit the /etc/hosts file and change your hostnames/ipaddresses.
If you use the xCAT hosts table, and  your nodes are defined by name in the hosts table, the hosts table will have been updated with the new names when we changed the node name using  chdef command.  If the hosts tables contains a reqular expression, you will have to rework the regular expression to match your new hostnames/ip addresses.
If not using a regular expression in the hosts table, then you can run

~~~~
nodech <newnodename> hosts.ip="x.xx.xx.xx" - will change the ip address for the new hostname in the hosts table.
 makehosts <noderange> - adds the all the nodes in the noderange back into /etc/hosts from the definition in the xCAT hosts table.

~~~~

Configure the new names into the DNS setup

~~~~
makedns -n

~~~~

Configure the new names into the DHCP setup

~~~~

makedhcp -a
~~~~

Configure the new names for conserver

~~~~

makeconservercf
~~~~

Update the service nodes
If you are using service nodes to install the nodes, and using /etc/hosts for hostname resolution, you will need to copy the new /etc/hosts from the Management Node to the service nodes and run makedns -n on the service nodes.

~~~~

 xdcp <servicenodes>  /etc/hosts /etc/hosts
 xdsh <servicenodes> makedns -n
~~~~

Now you will reinstall the nodes to pick up all changes

~~~~

nodeset <noderange>  netboot (diskless)  or install (diskfull)
~~~~

Use your normal command to install the nodes (rinstall,rnetboot,etc).

### Changing nodes that are Service Nodes
In addition to the steps for changing any managed Linux node, if the node is a service node then you must also do the following:
 If the ip address that changed for the Service Node, is the node-facing ip address, then change the xcatmaster attribute for all nodes managed by the service node to the new hostname/ip address
 Change any other setting in the database for the use of the service node by the old ip address. One way to check for this is to run the following, where 10.6.1.1 is the old address of the service node:

~~~~

 lsdef -t node -l | grep "10.6.0.1"
 nfsserver=10.6.0.1
 servicenode=10.6.0.1
~~~~


You can see the old address shows  up in several attributes, for example conserver.  To find out which nodes have that invalid address, run

~~~~

 nfsserver="10.6.0.1"
 cn1  (node)
 cn2  (node)
 cn3  (node)
 cn4  (node)
~~~~


So to change the nfsserver address for cn1,cn2,cn3,cn4 run the following:

~~~~

 chdef -t node cn1-cn4 nfsserver=<newipaddress>
~~~~


You will need to do the same for any other attributes assigned the old ip address of the Service Node.

#### Database Changes for Service Nodes
If the ip address that changes for the Service Nodes, is the address facing the Management Node, then there are required database changes on the Management Node. The database server on the Management Node has been setup to allow access from the service nodes which are database clients.  This access is by hostname and/or ip address.  You will need to change that access for the new hostnames and/or ip address.  This affects MySQL and PostgreSQL database servers.   You probably want to remove the access allowed by the old address or hostname.

The following links tell you how to setup the new access:

For MySQL:



[Setting_Up_MySQL_as_the_xCAT_DB granting-or-revoking-access-to-the-mysql-database-to-service-node-clients](Setting_Up_MySQL_as_the_xCAT_DB/#granting-or-revoking-access-to-the-mysql-database-to-service-node-clients)


For PostgreSQL:

You will need to add/change the ip address that allow access to the PostgreSQL server as documented in this procedure:


[Setting_Up_PostgreSQL_as_the_xCAT_DB setting-up-the-service-nodes-hierarchy](Setting_Up_PostgreSQL_as_the_xCAT_DB/#setting-up-the-service-nodes-hierarchy)

## Changing domain names
If you need to change the domain name on the cluster,  review the following documentation.

[Changing_the_Management_Node_Hostname_and_or_IP domain-name-changed](Changing_the_Management_Node_Hostname_and_or_IP/#domain-name-changed)



