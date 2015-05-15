<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [deps table](#deps-table)
- [function flow](#function-flow)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


Mini Design for Coordinated Cluster Shutdown & Bringup

The nodes in the cluster are not standalone, there are some dependencies between the nodes. Especially when bring up or shutdown the nodes in the cluster, the dependencies should be taken into account, otherwise, some of the resources in the cluster may be messed up, for example, the I/O node should not be shut down before the clients served by this I/O node are shutdown; the compute nodes should not be brought up before the service node is up and running. This design describes how the cluster can be shut down or brought up gracefully according to the dependencies between the nodes.


##deps table 


There is an existing xCAT table “deps” that can contain the dependencies between the nodes;  the only command needs to consider the “deps” table is the “rpower”, the rnetboot and getmacs will eventually call rpower to power off/on the nodes.

The “deps” table can be filled in through two ways: using the cluster setup wizard or filling in the table manually. Here is an example of the “deps” table:

node,nodedep,msdelay,cmd,comments,disable

"f1nodes","sn1","10000","on",,

"sn1","f1nodes","10000","off",,

The table content indicates that the node ''sn1'' must be powered on before all the nodes in node group ''f1nodes'' are powered on, and all the nodes in nodegroup ''f1nodes'' musted be powered off before the node ''sn1'' is powered off.

##function flow 


This feature is to have rpower command check the information in “deps” table,  power on and power off the nodes according to the dependencies between the nodes. If a group of nodes that do not depend on any other node outside of the group are passed to rpower command, then power on or power off the nodes sequentially according to the dependencies; if the node that one or more nodes depend is not passed to rpower command, then print a warning message to indicate that the administrator should make sure the nodes are in correct state. 

Let's describe the logic using an example: there are 10 nodes in the cluster,  ''ionode1'' is the I/O node, the ''node1'' to ''node9'' are the compute nodes,  it means that the ''node1'' to ''node9'' depends on ''ionode1'', the ''ionode1'' must be powered on before the ''node1'' to ''node9'' are powered on, the ''node1'' to ''node9'' must be powered off before the ''ionode1'' is powered off. The deps table should look like:


node,nodedep,msdelay,cmd,comments,disable

"cn","ionode1","10000","on",,

"ionode1","cn","10000","off,softoff,reset",,

Note: the node group ''cn'' includes the node1 to node9.

Here is the behavior of rpower command with different parameters:

'''1.rpower cn,ionode1 on'''

Try to power on ionode1 first, then power on node1 to node9 after 10000 milliseconds.

'''2.rpower cn,ionode1 off'''

Try to power off node1 to node9 first, then power off ionode1 after 1000 milliseconds.

'''3.rpower cn on'''

Print a warning message to indicate the administrator should make sure the ionode1 is in correct state, and then power on the node1 to node9

'''4.rpower cn off'''

Power off node1 to node9.

'''5.rpower ionode1 off'''

Print a warning message to indicate that the administrator should make sure the node1 to node9 are in correct state, and then power off the ionode1

'''6.rpower ionode1 on'''

Power on ionode1


Note: Hierachy dependency is supported. for example, if the cn1 depends on sn1, and the sn1 depends on ionode1. rpower command will operate cn1 first and then sn1 and finally ionode1.