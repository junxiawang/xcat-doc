<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [xCAT Installation on an iDataplex Configuration](#xcat-installation-on-an-idataplex-configuration)
    - [Example Configuration Used in This Document](#example-configuration-used-in-this-document)
    - [Overview of Cluster Setup Process](#overview-of-cluster-setup-process)
    - [Distro-specific Steps](#distro-specific-steps)
    - [Command Man Pages and Database Attribute Descriptions](#command-man-pages-and-database-attribute-descriptions)
  - [Prepare the Management Node for xCAT Installation](#prepare-the-management-node-for-xcat-installation)
  - [Install xCAT on the Management Node](#install-xcat-on-the-management-node)
  - [**Configure xCAT**](#configure-xcat)
    - [**Networks Table**](#networks-table)
    - [**passwd Table**](#passwd-table)
    - [**Setup DNS**](#setup-dns)
    - [**Setup DHCP**](#setup-dhcp)
    - [**Setup TFTP**](#setup-tftp)
    - [**Setup conserver**](#setup-conserver)
  - [Node Definition and Discovery](#node-definition-and-discovery)
    - [Declare a dynamic range of addresses for discovery](#declare-a-dynamic-range-of-addresses-for-discovery)
    - [**Load the e1350 Templates**](#load-the-e1350-templates)
    - [**Add Nodes to the nodelist Table**](#add-nodes-to-the-nodelist-table)
    - [Configure conserver](#configure-conserver)
      - [**Update conserver configuration**](#update-conserver-configuration)
    - [**Declare use of SOL**](#declare-use-of-sol)
    - [**Setup /etc/hosts and DNS**](#setup-etchosts-and-dns)
    - [Discover the Nodes](#discover-the-nodes)
    - [Option 1: Sequential Discovery](#option-1-sequential-discovery)
      - [**Initialize the discovery process**](#initialize-the-discovery-process)
      - [**Power on the nodes sequentially**](#power-on-the-nodes-sequentially)
      - [**Display information about the discovery process**](#display-information-about-the-discovery-process)
    - [Option 2: Switch Discovery](#option-2-switch-discovery)
      - [**Switch-related Tables**](#switch-related-tables)
    - [Option 3: Manually Discover Nodes](#option-3-manually-discover-nodes)
    - [**Run the discovery**](#run-the-discovery)
    - [**Monitoring Node Discovery**](#monitoring-node-discovery)
- [~~~~    ](#)
- [        n1,n10,n11,n75,n76,n77,n78,n79,n8,n80,n81,n82,n83,n84,n85,n86,n87,n88,n89,n9,n90,n91](#n1n10n11n75n76n77n78n79n8n80n81n82n83n84n85n86n87n88n89n9n90n91)
- [](#)
- [ n53,n54,n55,n56,n57,n58,n59,n6,n60,n61,n62,n63,n64,n65,n66,n67,n68,n69,n7,n70,n71,n72,n73,n74](#n53n54n55n56n57n58n59n6n60n61n62n63n64n65n66n67n68n69n7n70n71n72n73n74)
- [    ](#)
- [    ipmi](#ipmi)
    - [Verfiy HW Management Configuration](#verfiy-hw-management-configuration)
- [](#-1)
- [    ipmi](#ipmi-1)
    - [HW Settings Necessary for Remote Console](#hw-settings-necessary-for-remote-console)
  - [Deploying Nodes](#deploying-nodes)
  - [Installing Stateful Nodes](#installing-stateful-nodes)
    - [**Begin Installation**](#begin-installation)
  - [Deploying Stateless Nodes](#deploying-stateless-nodes)
  - [**Useful Applications of xCAT commands**](#useful-applications-of-xcat-commands)
    - [**Adding groups to a set of nodes**](#adding-groups-to-a-set-of-nodes)
    - [**Listing attributes**](#listing-attributes)
    - [**Verifying consistency and version of firmware**](#verifying-consistency-and-version-of-firmware)
    - [Verifying or Setting ASU Settings](#verifying-or-setting-asu-settings)
    - [Managing the IB Network](#managing-the-ib-network)
    - [**Reading and interpreting sensor readings**](#reading-and-interpreting-sensor-readings)
  - [Where Do I Go From Here?](#where-do-i-go-from-here)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

This document describes the steps necessary to quickly set up a cluster with IBM system x, rack-mounted servers. Although the examples given in this document are specific to iDataplex hardware (because that's the most common server type used for clusters), the basic instructions apply to any x86_64, IPMI-controlled, rack-mounted servers. 


## xCAT Installation on an iDataplex Configuration

This document is meant to get you going as quickly as possible and therefore only goes through the most common scenario. For additional scenarios and setup tasks, see [XCAT_iDataPlex_Advanced_Setup]. 

### Example Configuration Used in This Document

This configuration will have a single dx360 Management Node with 167 other dx360 servers as nodes. The OS deployed will be RH Enterprise Linux 6.2, x86_64 edition. Here is a diagram of the racks: 

[[img src=Idataplex-image1.png]] 

In our example, the management node is known as 'mgt', the node namess are n1-n167, and the domain will be 'cluster'. We will use the BMCs in shared mode so they will share the NIC on each node that the node's operating system communicates to the xCAT management node over. This is call the management LAN. We will use subnet 172.16.0.0 with a netmask of 255.240.0.0 (/12) for it. (This provides an IP address range of 172.16.0.1 - 172.31.255.254 .) We will use the following subsets of this range for: 

  * The management node: 172.20.0.1 
  * The node OSes: 172.20.100+racknum.nodenuminrack 
  * The node BMCs: 172.29.100+racknum.nodenuminrack 
  * The management port of the switches: 172.30.50.switchnum 
  * The DHPC dynamic range for unknown nodes: 172.20.255.1 - 172.20.255.254 

  
The network is physically laid out such that port number on a switch is equal to the U position number within a column, like this: 

[[img src=Idataplex-image2.png]] 

### Overview of Cluster Setup Process

Here is a summary of the steps required to set up the cluster and what this document will take you through: 

  1. Prepare the management node - doing these things before installing the xCAT software helps the process to go more smoothly. 
  2. Install the xCAT software on the management node. 
  3. Configure some cluster wide information 
  4. Define a little bit of information in the xCAT database about the ethernet switches and nodes - this is necessary to direct the node discovery process. 
  5. Have xCAT configure and start several network daemons - this is necessary for both node discovery and node installation. 
  6. Discovery the nodes - during this phase, xCAT configures the BMC's and collects many attributes about each node and stores them in the database. 
  7. Set up the OS images and install the nodes. 

### Distro-specific Steps

  * [RH] indicates that step only needs to be done for RHEL and Red Hat based distros (CentOS, Scientific Linux, and in most cases Fedora). 
  * [SLES] indicates that step only needs to be done for SLES. 

### Command Man Pages and Database Attribute Descriptions

  * All of the commands used in this document are described in the [xCAT man pages](http://xcat.sourceforge.net/man1/xcat.1.html). 
  * All of the database attributes referred to in this document are described in the [xCAT database object and table descriptions](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

## Prepare the Management Node for xCAT Installation

[Prepare_the_Management_Node_for_xCAT_Installation](Prepare_the_Management_Node_for_xCAT_Installation)
[Configure_ethernet_switches](Configure_ethernet_switches)

## Install xCAT on the Management Node

[Install_xCAT_on_the_Management_Node](Install_xCAT_on_the_Management_Node) 

## **Configure xCAT**

### **Networks Table**

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is connected to. Now is the time to add to the networks table any other networks in the cluster, or update existing networks in the table. 

For a sample Networks Setup, see the following example: [Setting_Up_a_Linux_xCAT_Mgmt_Node#Appendix_A:_Network_Table_Setup_Example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example)

### **passwd Table**

The password should be set in the passwd table that will be assigned to root when the node is installed. You can modify this table using tabedit. To change the default password for root on the nodes, change the system line. To change the password to be used for the BMCs, change the ipmi line. 
    
    tabedit passwd
    #key,username,password,cryptmethod,comments,disable
    "system","root","cluster",,,
    "ipmi","USERID","PASSW0RD",,,
    

### **Setup DNS**

To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN: 

  * Ensure that /etc/sysconfig/named does not have ROOTDIR set 
  * Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can't answer to these servers. 
 
~~~~   
    chdef -t site forwarders=1.2.3.4,1.2.5.6
~~~~    

  * Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above.) 


~~~~     
    search cluster
    nameserver 172.20.0.1
~~~~     

  * Run makedns 

~~~~     
    makedns -n
~~~~     

For more information about name resolution in an xCAT Cluster, see [Cluster_Name_Resolution]. 

### **Setup DHCP**

You usually don't want your DHCP server listening on your public (site) network, so set site.dhcpinterfaces to your MN's cluster facing NICs. For example: 

~~~~     
    chdef -t site dhcpinterfaces=eth1
~~~~     

Then this will get the network stanza part of the DHCP configuration (including the dynamic range) set: 

~~~~     
    makedhcp -n
~~~~     

The IP/MAC mappings for the nodes will be added to DHCP automatically as the nodes are discovered. 

### **Setup TFTP**

Nothing to do here - the TFTP server is done by xCAT during the Management Node install. 

### **Setup conserver**

~~~~     
    makeconservercf
~~~~     

## Node Definition and Discovery

### Declare a dynamic range of addresses for discovery

If you want to run a discovery process, a dynamic range must be defined in the networks table. It's used for the nodes to get an IP address before xCAT knows their MAC addresses. 

In this case, we'll designate 172.20.255.1-172.20.255.254 as a dynamic range: 
    
    chdef -t network 172_16_0_0-255_240_0_0 dynamicrange=172.20.255.1-172.20.255.254
    

### **Load the e1350 Templates**

Several xCAT database tables must be filled in while setting up an iDataPlex cluster. To make this process easier, xCAT provides several template files in /opt/xcat/share/xcat/templates/e1350/. These files contain regular expressions that describe the naming patterns in the cluster. With xCAT's regular expression support, one line in a table can define one or more attribute values for all the nodes in a node group. (For more information on xCAT's database regular expressions, see http://xcat.sourceforge.net/man5/xcatdb.5.html .) To load the default templates into your database: 
    
    cd /opt/xcat/share/xcat/templates/e1350/
    for i in *csv; do tabrestore $i; done
    

These templates contain entries for a lot of different node groups, but we will be using the following node groups: 

  * **ipmi** \- the nodes controlled via IPMI. 
  * **idataplex** \- the iDataPlex nodes 
  * **42perswitch** \- the nodes that are connected to 42 port switches 
  * **compute** \- all of the compute nodes 
  * **84bmcperrack** \- the BMCs that are in a fully populated rack of iDataPlex 
  * **switch** \- the ethernet switches in the cluster 

In our example, ipmi, idataplex, 42perswitch, and compute will all have the exact same membership because all of our iDataPlex nodes have those characteristics. 

The templates automatically define the following attributes and naming conventions: 

  * The iDataPlex compute nodes: 
    * node names are of the form &lt;string&gt;&lt;number&gt;, for example n1 
    * **ip**: 172.20.100+racknum.nodenuminrack 
    * **bmc**: the bmc with the same number as the node 
    * **switch**: divide the node number by 42 to get the switch number 
    * **switchport**: the nodes are plugged into 42-port ethernet switches in order of node number 
    * **mgt**: 'ipmi' 
    * **netboot**: 'xnba' 
    * **profile**: 'compute' 
    * **rack**: node number divided by 84 
    * **unit**: in the range of A1 - A42 for the 1st 42 nodes in each rack, and in the range of C1 - C42 for the 2nd 42 nodes in each rack 
    * **chain**: 'runcmd=bmcsetup,shell' 
    * **ondiscover**: 'nodediscover' 
  * The BMCs: 
    * node names are of the form &lt;node name&gt;-bmc, for example n001-bmc 
    * **ip**: 172.29.100+racknum.nodenuminrack 
  * The management connection to each ethernet switch: 
    * node names are of the form switch&lt;number&gt;, for example switch1 
    * **ip**: 172.30.50.switchnum 

For a description of the attribute names in bold above, see the [node object definition](http://xcat.sourceforge.net/man7/node.7.html). 

If these conventions don't work for your situation, you can either: 

  1. modify the regular expressions - see [XCAT_iDataPlex_Advanced_Setup#Template_modification_example](XCAT_iDataPlex_Advanced_Setup/#template-modification-example)
  2. or manually define each node - see [XCAT_iDataPlex_Advanced_Setup#Manually_setup_the_node_attributes_instead_of_using_the_templates_or_switch_discovery](XCAT_iDataPlex_Advanced_Setup/#manually-setup-the-node-attributes-instead-of-using-the-templates-or-switch-discovery)

### **Add Nodes to the nodelist Table**

Now you can use the power of the templates to define the nodes quickly. By simply adding the nodes to the correct groups, they will pick up all of the attributes of that group: 
    
    nodeadd n[001-167] groups=ipmi,idataplex,42perswitch,compute,all
    nodeadd n[001-167]-bmc groups=84bmcperrack
    nodeadd switch1-switch4 groups=switch



   

    

To change the list of nodes you just defined to a shared BMC port: 

~~~~    
    chdef -t group -o ipmi bmcport="0"
~~~~    

If the BMCs are configured in shared mode, then this network can be combined with the management network. The bmcport attribute is used by bmcsetup in discovery to configure the BMC port. The bmcport values are "0"=shared, "1"=dedicated, or blank to leave the BMC port unchanged. 

To see the list of nodes you just defined: 
    
    nodels
    

To see all of the attributes that the combination of the templates and your nodelist have defined for a few sample nodes: 

~~~~    
    lsdef n100,n100-bmc,switch2
~~~~    

This is the easiest way to verify that the regular expressions in the templates are giving you attribute values you are happy with. (Or, if you modified the regular expressions, that you did it correctly.) 

### Configure conserver

The xCAT rcons command uses the conserver package to provide support for multiple read-only consoles on a single node and the console logging. For example, if a user has a read-write console session open on node node1, other users could also log in to that console session on node1 as read-only users. This allows sharing a console server session between multiple users for diagnostic or other collaborative purposes. The console logging function will log the console output and activities for any node with remote console attributes set to the following file which an be replayed for debugging or any other purposes: 

~~~~    
    /var/log/consoles/<management node>
~~~~
    

Note: conserver=&lt;management node&gt; is the default, so it optional in the command 

#### **Update conserver configuration**

Each xCAT node with remote console attributes set should be added into the conserver configuration file to make the rcons work. The xCAT command **makeconservercf** will put all the nodes into conserver configuration file /etc/conserver.cf. The makeconservercf command must be run when there is any node definition changes that will affect the conserver, such as adding new nodes, removing nodes or changing the nodes' remote console settings. 

To add or remove new nodes for conserver support: 
    
    makeconservercf
    service conserver stop
    service conserver start
    

### **Declare use of SOL**

If not using a terminal server, SOL is recommended, but not required to be configured. To instruct xCAT to configure SOL in installed operating systems on dx340 systems: 

~~~~    
    chdef -t group -o compute serialport=1 serialspeed=19200 serialflow=hard
~~~~    

For dx360-m2 and newer use: 
 
~~~~   
    chdef -t group -o compute serialport=0 serialspeed=115200 serialflow=hard
~~~~    

### **Setup /etc/hosts and DNS**

Since the mapping between the xCAT node names and IP addresses have been added in the hosts table by the e1350 template, you can run the **makehosts** xCAT command to create the /etc/hosts file from the xCAT hosts table. (You can skip this step if creating /etc/hosts manually.) 

~~~~     
    makehosts switch,idataplex,ipmi
~~~~     

Verify the entries have been created in the file /etc/hosts. For example your /etc/hosts should look like this: 
 

~~~~    
    127.0.0.1               localhost.localdomain localhost
    ::1                     localhost6.localdomain6 localhost6
    ###
    172.20.0.1 mgt mgt.cluster
    172.20.101.1 n1 n1.cluster
    172.20.101.2 n2 n2.cluster
    172.20.101.3 n3 n3.cluster
    172.20.101.4 n4 n4.cluster
    172.20.101.5 n5 n5.cluster
    172.20.101.6 n6 n6.cluster
    172.20.101.7 n7 n7.cluster
                  .
                  .
                  .
~~~~     

Add the node/ip mapping to the DNS. 

~~~~     
    makedns
~~~~     

### Discover the Nodes

xCAT supports 3 approaches to discover the new physical nodes and define them to xCAT database: 

  * Option 1: Sequential Discovery 

This is a simple approach in which you give xCAT a range of node names to be given to the discovered nodes, and then you power the nodes on sequentially (usually in physical order), and each node is given the next node name in the noderange. 

  * Option 2: Switch Discovery 

With this approach, xCAT assumes the nodes are plugged into your ethernet switches in an orderly fashion. So it uses each node's switch port number to determine where it is physically located in the racks and therefore what node name it should be given. This method requires a little more setup (configuring the switches and defining the switch table). But the advantage of this method is that you can power all of the nodes on at the same time and xCAT will sort out which node is which. This can save you a lot of time in a large cluster. 

  * Option 3: Manual Discovery 

If you don't want to use either of the automatically discovery processes, just follow the manual discovery process. 

Choose just one of these options and follow the corresponding section below (and skip the other two). 

### Option 1: Sequential Discovery

**Note: This feature is only supported in xCAT 2.8.1 and higher.**

Sequential Discovery means the new nodes will be discovered one by one. The nodes will be given names from a 'node name pool' in the order they are powered on. 

#### **Initialize the discovery process**

Specify the node name pool by giving a noderange to the nodediscoverstart command: 

~~~~     
    nodediscoverstart noderange=n[001-010]
~~~~     

The value of noderange should be in the xCAT [noderange](http://xcat.sourceforge.net/man3/noderange.3.html) format. 

Note: other node attributes can be given to nodediscoverstart so that xCAT will assign those attributes to the nodes as they are discovered. We aren't showing that in this document, because we already predefined the nodes, the groups they are in, and several attributes (provided by the e1350 templates). If you don't want to predefine nodes, you can give more attributes to nodediscoverstart and have it define the nodes. See the [nodediscoverstart man page](http://xcat.sourceforge.net/man1/nodediscoverstart.1.html) for details. 

#### **Power on the nodes sequentially**

At this point you can physically power on the nodes one at a time, in the order you want them to receive their node names. 

#### **Display information about the discovery process**

There are additional nodediscover commands you can run during the discovery process. See their [man pages](http://xcat.sourceforge.net/man1/xcat.1.html) for more details. 

  * Verify the status of discovery 

~~~~     
    nodediscoverstatus
~~~~     

  * Show the nodes that have been discovered so far: 

~~~~     
    nodediscoverls -t seq -l
~~~~ 
    

  * Stop the current sequential discovery process: 

~~~~     
    nodediscoverstop
~~~~     

Note: The sequential discovery process will be stopped automatically when all of the node names in the node name pool are used up. 

### Option 2: Switch Discovery

This method of discovery assumes that you have the nodes plugged into your ethernet switches in an orderly fashion. So we use each nodes switch port number to determine where it is physically located in the racks and therefore what node name it should be given. 

To use this discovery method, you must have already configured the switches as described in (/#configure-ethernet-switches] 

#### **Switch-related Tables**

The table templates already put group-oriented regular expression entries in the switch table. Use lsdef for a sample node to see if the switch and switchport attributes are correct. If not, use chdef or tabedit to change the values. 

If you configured your switches to use SNMP V3, then you need to define several attributes in the switches table. Assuming all of your switches use the same values, you can set these attributes at the group level: 
    
    tabch switch=switch switches.snmpversion=3 switches.username=xcat switches.password=passw0rd switches.auth=sha
    

### Option 3: Manually Discover Nodes

Prerequisite: The dynamic dhcp range must be configured before you power on the nodes. 

If you have a few nodes which were not discovered by Sequential Discovery or Switch Discovery, you could find them in discoverydata table using the [nodediscoverls](http://xcat.sourceforge.net/man1/nodediscoverls.1.html). The undiscovered nodes are those that have a discovery method value of 'undef' in the discoverydata table. 

Display the undefined nodes with the nodediscoverls command: 

~~~~     
    nodediscoverls -t undef
     UUID                                    NODE                METHOD         MTM       SERIAL   
     61E5F2D7-0D59-11E2-A7BC-3440B5BEDBB1    undef               undef          786310X   1052EF1  
     FC5F8852-CB97-11E1-8D59-E41F13EEB1BA    undef               undef          7914B2A   06DVAC9   
     96656F17-6482-E011-9954-5CF3FC317F68    undef               undef          7377D2C   99A2007
~~~~     

If you want to manually define an 'undefined' node to a specific free node name, use the [nodediscoverdef](http://xcat.sourceforge.net/man1/nodediscoverdef.1.html) command (available in xCAT 2.8.2 or higher). 

For example, if you have a free node name n10 and you want to assign the undefined node whose uuid is '61E5F2D7-0D59-11E2-A7BC-3440B5BEDBB1' to n10, run: 

~~~~     
    nodediscoverdef -u 61E5F2D7-0D59-11E2-A7BC-3440B5BEDBB1 -n n10
~~~~     

After manually defining it, the 'node name' and 'discovery method' attributes of the node will be changed. You can display the changed attributes using the nodediscoverls command: 

~~~~     
     nodediscoverls
     UUID                                    NODE                METHOD         MTM       SERIAL  
     **61E5F2D7-0D59-11E2-A7BC-3440B5BEDBB1    n10                 manual         786310X   1052EF1**
     FC5F8852-CB97-11E1-8D59-E41F13EEB1BA    undef               undef          7914B2A   06DVAC9   
     96656F17-6482-E011-9954-5CF3FC317F68    undef               undef          7377D2C   99A2007
~~~~     

You can now also run 'lsdef n10' to see that the 'mac address' and 'mtm' have been updated to the node definition. If the next task like **bmcsetup** has been set in the [chain](http://xcat.sourceforge.net/man5/chain.5.html) table, this step will have been started the running of the nodediscoverdef command. 

### **Run the discovery**

If you want to update node firmware when you discover the nodes, follow the steps in 
[XCAT_iDataPlex_Advanced_Setup#Updating_Node_Firmware](XCAT_iDataPlex_Advanced_Setup/#updating-node-firmware) before continuing.

If you want to automatically deploy the nodes after they are discovered, follow the steps in 
[XCAT_iDataPlex_Advanced_Setup#Automatically_Deploying_Nodes_After_Discovery](CAT_iDataPlex_Advanced_Setup/#automatically-deploying-nodes-after-discovery) before continuing. (But if you are new to xCAT, we don't recommend this.) 

To initiate any of the 3 discover methods, walk over to systems and **hit the power buttons**. For the sequential discovery method power the nodes on in the order that you want them to be given the node names. Wait a short time (about 30 seconds) between each node to ensure they will contact xcatd in the correct order. For the switch and manual discovery processes, you can power on all of the nodes at the same time. 

On the MN watch nodes being discovered by: 

~~~~     
    tail -f /var/log/messages
~~~~     

Look for the dhcp requests, the xCAT discovery requests, and the "&lt;node&gt; has been discovered" messages. 

A quick summary of what is happening during the discovery process is: 

  * the nodes request a DHCP IP address and PXE boot instructions 
  * the DHCP server on the MN responds with a dynamic IP address and the xCAT genesis boot kernel 
  * the genesis boot kernel running on the node sends the MAC and MTMS to xcatd on the MN 
  * xcatd asks the switches which port this MAC is on so that it can correlate this physical node with the proper node entry in the database. (Switch Discovery only) 
  * xcatd uses specified node name pool to get the proper node entry. (Sequential Discovery only) 
    * stores the node's MTMS in the db 
    * puts the MAC/IP pair in the DHCP configuration 
    * sends several of the node attributes to the genesis kernel on the node 
  * the genesis kernel configures the BMC with the proper IP address, userid, and password, and then just drops into a shell 

After a successful discovery process, the following attributes will be added to the database for each node. (You can verify this by running lsdef &lt;node&gt; ): 

  * mac - the MAC address of the in-band NIC used to manage this node 
  * mtm - the hardware type (machine-model) 
  * serial - the hardware serial number 

If you cannot discover the nodes successfully, see the next section [XCAT_iDataPlex_Cluster_Quick_Start#Manually_Discover_Nodes](XCAT_iDataPlex_Cluster_Quick_Start#option-3-manually-discover-nodes). 

If at some later time you want to force a re-discover of a node, run:  

~~~~  
    makedhcp -d <noderange>
~~~~
    

and then reboot the node(s). 

### **Monitoring Node Discovery**

When the bmcsetup process completes on each node (about 5-10 minutes), xCAT genesis will drop into a shell and wait indefinitely (and change the node's currstate attribute to "shell"). You can monitor the progress of the nodes using: 

~~~~
    
    watch -d 'nodels ipmi chain.currstate|xcoll'
~~~~   

Before all nodes complete, you will see output like: 
    
    
~~~~    
====================================  
        n1,n10,n11,n75,n76,n77,n78,n79,n8,n80,n81,n82,n83,n84,n85,n86,n87,n88,n89,n9,n90,n91
====================================
    
shell

====================================  
    
n31,n32,n33,n34,n35,n36,n37,n38,n39,n4,n40,n41,n42,n43,n44,n45,n46,n47,n48,n49,n5,n50,n51,n52,
 n53,n54,n55,n56,n57,n58,n59,n6,n60,n61,n62,n63,n64,n65,n66,n67,n68,n69,n7,n70,n71,n72,n73,n74
====================================   
  
   
    runcmd=bmcsetup
~~~~    

When all nodes have made it to the shell, xcoll will just show that the whole nodegroup "ipmi" has the output "shell":  
    
~~~~  
  
    
====================================     
    ipmi
==================================== 
    
    
shell
    
~~~~
When the nodes are in the xCAT genesis shell, you can ssh or psh to any of the nodes to check anything you want. 

### Verfiy HW Management Configuration

At this point, the BMCs should all be configured and ready for hardware management. To verify this: 
    
~~~~ 
   
  rpower ipmi stat | xcoll

===================================     
    ipmi
===================================     

    on
~~~~    

### HW Settings Necessary for Remote Console

To get the remote console working for each node, some uEFI hardware settings must have specific values. First check the settings, and if they aren't correct, then set them properly. This can be done via the ASU utility. The settings are slightly different, depending on the hardware type: 

  * For the **dx360-m3** and earlier machines create a file called asu-show with contents: 

~~~~    
    show uEFI.Com1ActiveAfterBoot
    show uEFI.SerialPortSharing
    show uEFI.SerialPortAccessMode
    show uEFI.RemoteConsoleRedirection
~~~~    

     And create a file called asu-set with contents: 
 
~~~~   
    set uEFI.Com1ActiveAfterBoot Enable
    set uEFI.SerialPortSharing Enable
    set uEFI.SerialPortAccessMode Dedicated
    set uEFI.RemoteConsoleRedirection Enable
 
~~~~   

  * For **dx360-m4** and later machines create a file called asu-show with contents: 

~~~~    
    show DevicesandIOPorts.Com1ActiveAfterBoot
    show DevicesandIOPorts.SerialPortSharing
    show DevicesandIOPorts.SerialPortAccessMode
    show DevicesandIOPorts.RemoteConsole
~~~~    

     And create a file called asu-set with contents: 

~~~~    
    set DevicesandIOPorts.Com1ActiveAfterBoot Enable
    set DevicesandIOPorts.SerialPortSharing Enable
    set DevicesandIOPorts.SerialPortAccessMode Dedicated
    set DevicesandIOPorts.RemoteConsole Enable
~~~~    

Then for **both** types of machines, use the [pasu](http://xcat.sourceforge.net/man1/pasu.1.html) tool to check these settings: 

~~~~    
    pasu -b asu-show ipmi | xcoll    # Or you can check just one node and assume the rest are the same
~~~~    

If the settings are not correct, then set them: 

~~~~    
    pasu -b asu-set ipmi | xcoll
~~~~    

For alternate ways to set the ASU settings, see [XCAT_iDataPlex_Advanced_Setup#Using_ASU_to_Update_CMOS,_uEFI,_or_BIOS_Settings_on_the_Nodes](XCAT_iDataPlex_Advanced_Setup/#using-asu-to-update-cmos-uefi-or-bios-settings-on-the-nodes). 

Now the remote console should work. Verify it on one node by running: 
  
~~~~  
    rcons <node>
~~~~
    

To verify that you can see the genesis shell prompt (after hitting enter). To exit rcons type: ctrl-shift-E (all together), then "c", the ".". 

You are now ready to choose an operating system and deployment method for the nodes.... 

## Deploying Nodes

  * In you want to install your nodes as stateful (diskful) nodes, follow the next section [XCAT_iDataPlex_Cluster_Quick_Start#Installing_Stateful_Nodes](XCAT_iDataPlex_Cluster_Quick_Start/#installing-stateful-nodes). 
  * If you want to define one or more stateless (diskless) OS images and boot the nodes with those, see section [XCAT_iDataPlex_Cluster_Quick_Start#Deploying_Stateless_Nodes](XCAT_iDataPlex_Cluster_Quick_Start/#deploying-stateless-nodes). This method has the advantage of managing the images in a central place, and having only one image per node type. 
  * If you want to have nfs-root statelite nodes, see [XCAT_Linux_Statelite](XCAT_Linux_Statelite). This has the same advantage of managing the images from a central place. It has the added benefit of using less memory on the node while allowing larger images. But it has the drawback of making the nodes dependent on the management node or service nodes (i.e. if the management/service node goes down, the compute nodes booted from it go down too). 
  * If you have a very large cluster (more than 500 nodes), at this point you should follow [Setting_Up_a_Linux_Hierarchical_Cluster](Setting_Up_a_Linux_Hierarchical_Cluster) to install and configure your service nodes. After that you can return here to install or diskless boot your compute nodes. 

## Installing Stateful Nodes

[Installing_Stateful_Linux_Nodes](Installing_Stateful_Linux_Nodes)

### **Begin Installation**

The [nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) command tells xCAT what you want to do next with this node, [rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html) tells the node hardware to boot from the network for the next boot, and powering on the node using [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) starts the installation process: 
    
    nodeset compute osimage=mycomputeimage
    rsetboot compute net
    rpower compute boot
    

Tip: when nodeset is run, it processes the kickstart or autoyast template associated with the osimage, plugging in node-specific attributes, and creates a specific kickstart/autoyast file for each node in /install/autoinst. If you need to customize the template, make a copy of the template file that is pointed to by the osimage.template attribute and edit that file (or the files it includes). 

[Monitor_Installation](Monitor_Installation) 

  
 


## Deploying Stateless Nodes

[Using_Provmethod=osimagename](Using_Provmethod=osimagename) 
    
~~~~
    rsetboot compute net
    rpower compute boot
~~~~    

## **Useful Applications of xCAT commands**

This section gives some examples of using key commands and command combinations in useful ways. For any xCAT command, typing '**man &lt;command&gt;'** will give details about using that command. For a list of xCAT commands grouped by category, see [XCAT_Commands]. For all the xCAT man pages, see http://xcat.sourceforge.net/man1/xcat.1.html . 

### **Adding groups to a set of nodes**

In this configuration, a handy convenience group would be the lower systems in the chassis, the ones able to read temperature and fanspeed. In this case, the odd systems would be on the bottom, so to do this with a regular expression: 

~~~~
        nodech '/n.*[13579]$' groups,=bottom
~~~~    

or explicitly 

~~~~    
    chdef -p n1-n9,n11-n19,n21-n29,n31-n39,n41-n49,n51-n59,n61-n69,n71-79,n81-n89,
    n91-n99,n101-n109,n111-119,n121-n129,n131-139,n141-n149,n151-n159,n161-n167 groups="bottom"
~~~~    

### **Listing attributes**

We can list discovered and expanded versions of attributes (Actual vpd should appear instead of *)&nbsp;: 

~~~~    
    # nodels n97 nodepos.rack nodepos.u vpd.serial vpd.mtm 
    n97: nodepos.u: A-13
    n97: nodepos.rack: 2
    n97: vpd.serial: ********
    n97: vpd.mtm: *******
~~~~    

You can also list all the attributes: 

~~~~    
    #lsdef n97 
    Object name: n97
       arch=x86_64
            .
       groups=bottom,ipmi,idataplex,42perswitch,compute,all
            .
            .
            .
       rack=1    
       unit=A1
~~~~    

### **Verifying consistency and version of firmware**

xCAT provides parallel commands and the sinv (inventory) command, to analyze the consistency of the cluster. See (parallel-commands-and-inventory)

Combining the use of in-band and out-of-band utilities with the xcoll utility, it is possible to quickly analyze the level and consistency of firmware across the servers: 

~~~~    
    mgt# rinv n1-n3 mprom|xcoll 
    ==================================== 
    n1,n2,n3
    ==================================== 
    BMC Firmware: 1.18
~~~~    

The BMC does not have the BIOS version, so to do the same for that, use psh: 

~~~~    
    mgt# psh n1-n3 dmidecode|grep "BIOS Information" -A4|grep Version|xcoll 
    ==================================== 
    n1,n2,n3
    ==================================== 
    Version: I1E123A
~~~~    

To update the firmware on your nodes, see [XCAT_iDataPlex_Advanced_Setup#Updating_Node_Firmware](XCAT_iDataPlex_Advanced_Setup/#updating-node-firmware). 

### Verifying or Setting ASU Settings

To do this, see [XCAT_iDataPlex_Advanced_Setup#Using_ASU_to_Update_CMOS,_uEFI,_or_BIOS_Settings_on_the_Nodes](XCAT_iDataPlex_Advanced_Setup/#using-asu-to-update-cmos-uefi-or-bios-settings-on-the-nodes).

### Managing the IB Network

xCAT has several utilities to help manage and monitor the Mellanox IB network. See [Managing_the_Mellanox_Infiniband_Network]. 

### **Reading and interpreting sensor readings**

If the configuration is louder than expected (iDataplex chassis should nominally have a fairly modest noise impact), find the nodes with elevated fanspeed: 

~~~~    
    # rvitals bottom fanspeed|sort -k 4|tail -n 3
    n3: PSU FAN3: 2160 RPM
    n3: PSU FAN4: 2240 RPM
    n3: PSU FAN1: 2320 RPM
    
~~~~
  
In this example, the fanspeeds are pretty typical. If fan speeds are elevated, there may be a thermal issue. In a dx340 system, if near 10,000 RPM, there is probably either a defective sensor or misprogrammed power supply. 

  
To find the warmest detected temperatures in a configuration: 

~~~~    
    # rvitals bottom temp|grep Domain|sort -t: -k 3|tail -n 3
    n3: Domain B Therm 1: 46 C (115 F)
    n7: Domain A Therm 1: 47 C (117 F)
    n3: Domain A Therm 1: 49 C (120 F)
~~~~    

Change tail to head in the above examples to seek the slowest fans/lowest temperatures. Currently, an iDataplex chassis without a planar tray in the top position will report '0 C' for Domain B temperatures. 

For more options, see rvitals manpage: http://xcat.sourceforge.net/man1/rvitals.1.html 

## Where Do I Go From Here?

Now that your basic cluster is set up, here are suggestions for additional reading: 

  * To help configure your networks: 
    * [Managing_the_Mellanox_Infiniband_Network] 
    * [Managing_Ethernet_Switches] 
  * To install other HPC products: 
    * [IBM_HPC_Stack_in_an_xCAT_Cluster] 
  * For on-going management of the cluster: 
    * [Using_Updatenode] 
    * [Monitoring_an_xCAT_Cluster] 
  * If you want to create multiple virtual machines in each physical server: 
    * [XCAT_Virtualization_with_VMWare] 
    * [XCAT_Virtualization_with_KVM] 
    * [XCAT_Virtualization_with_RHEV] 
