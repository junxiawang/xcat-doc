<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Configure Ethernet Switches**](#configure-ethernet-switches)
- [SNMP V3 Configuration Example:](#snmp-v3-configuration-example)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### **Configure Ethernet Switches**

It is recommended that spanning tree be set in the switches to portfast or edge-port for faster boot performance. Please see the relevant switch documentation as to how to configure this item. 

It is recommended that lldp protocol in the switches is enabled to collect the switch and port information for compute node during discovery process. 

**Note:** this step is necessary if you want to use xCAT's automatic switch-based discovery (described later on in this document) for IPMI-controlled rack-mounted servers (including iDataPlex) and Flex chassis. If you have a small cluster and prefer to use the sequential discover method (described later) or manually enter the MACs for the hardware, you can skip this section. Although you may want to still set up your switches for management so you can use xCAT tools to manage them, as described in [Managing_Ethernet_Switches](Managing_Ethernet_Switches). 

xCAT will use the ethernet switches during node discovery to find out which switch port a particular MAC address is communicating over. This allows xCAT to match a random booting node with the proper node name in the database. To set up a switch, give it an IP address on its management port and enable basic SNMP functionality. (Typically, the SNMP agent in the switches is disabled by default.) The easiest method is to configure the switches to give the SNMP version 1 community string called "public" read access. This will allow xCAT to communicate to the switches without further customization. (xCAT will get the list of switches from the [switch](http://xcat.sourceforge.net/man5/switch.5.html) table.) If you want to use SNMP version 3 (e.g. for better security), see the example below. With SNMP V3 you also have to set the user/password and AuthProto (default is 'md5') in the [switches](http://xcat.sourceforge.net/man5/switches.5.html) table. 

If for some reason you can't configure SNMP on your switches, you can use sequential discovery or the more manual method of entering the nodes' MACs into the database. See [XCAT_iDataPlex_Cluster_Quick_Start#Discover_the_Nodes](XCAT_iDataPlex_Cluster_Quick_Start/#discover-the-nodes) for a description of your choices. 

### SNMP V3 Configuration Example:

xCAT supports many switch types, such as BNT and Cisco. Here is an example of configuring SNMP V3 on the Cisco switch 3750/3650: 

1\. First, user should switch to the configure mode by the following commands: 

~~~~    
    [root@x346n01 ~]# telnet xcat3750
    Trying 192.168.0.234...
    Connected to xcat3750.
    Escape character is '^]'.
    User Access Verification
    Password:
  
    
    xcat3750-1>enable
    Password:
    
    
    xcat3750-1#configure terminal
    Enter configuration commands, one per line.  End with CNTL/Z.
    xcat3750-1(config)#
~~~~   

2\. Configure the snmp-server on the switch: 

~~~~       
    Switch(config)# access-list 10 permit 192.168.0.20    # 192.168.0.20 is the IP of MN
    Switch(config)# snmp-server group xcatadmin v3 auth write v1default
    Switch(config)# snmp-server community public RO 10
    Switch(config)# snmp-server community private RW 10
    Switch(config)# snmp-server enable traps license?
~~~~       

3\. Configure the snmp user id (assuming a user/pw of xcat/passw0rd): 

~~~~       
    Switch(config)# snmp-server user xcat xcatadmin v3 auth SHA passw0rd access 10
~~~~       

4\. Check the snmp communication to the switch&nbsp;: 

  *      On the MN: make sure the snmp rpms have been installed. If not, install them: 

~~~~       
    yum install net-snmp net-snmp-utils
~~~~       

  *      Run the following command to check that the snmp communication has been setup successfully (assuming the IP of the switch is 192.168.0.234): 

~~~~       
    snmpwalk -v 3 -u xcat -a SHA -A passw0rd -X cluster -l authnoPriv 192.168.0.234 .1.3.6.1.2.1.2.2.1.2
    
~~~~  
 
Later on in this document, it will explain how to make sure the switch and switches tables are setup correctly. 
