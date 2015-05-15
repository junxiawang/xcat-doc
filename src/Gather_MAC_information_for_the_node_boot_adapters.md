<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Using getmacs](#using-getmacs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Using getmacs

Use the xCAT getmacs command to gather adapter information from the nodes. This command will return the MAC information for each Ethernet or HFI adapter available on the target node. The command can be used to either display the results or write the information directly to the database. If there are multiple adapters the first one will be written to the database and used as the install adapter for that node. 

The command can also be used to do a ping test on the adapter interfaces to determine which ones could be used to perform the network boot. In this case the first adapter that can be successfully used to ping the server will be written to the database. 

~~~~
 getmacs working with P775 
~~~~

The P775 cec supports two networks with the getmacs command. The default network in the P775 is the HFI which is used to communicate between all the P775 octants. There is also support for an Ethernet network which is used to communicate between the xCAT EMS, and other P775 server octants. It is important that all the networks are properly defined in the xCAT networks table. 

Before running getmacs you must first run the makeconservercf command. You need to run makeconservercf any time you add new nodes to the cluster. 

~~~~    
     makeconservercf
~~~~
    

Shut down all the nodes that you will be querying for MAC addresses. For example, to shut down all nodes in the group "compute" you could run the following command. 
 
~~~~   
   rpower compute off
~~~~
    

To display all adapter information but not write anything to the database you should use the "-d" flag. For example: 
 
~~~~   
    getmacs -d compute
~~~~
    

To retrieve the Ethernet MAC address for a P775 xCAT service node, you will need to provide the -D flag (ping test) with getmacs command. 

~~~~    
     getmacs <xcatsn> -D 
~~~~     
    

The output would be similar to the following. 
 
~~~~   
    Type Location Code MAC Address Full Path Name Ping Result Device Type
    ent U9125.F2A.024C362-V6-C2-T1 fef9dfb7c602 [/vdevice/l-lan@30000002](/vdevice/l-lan@30000002) successful virtual
    ent U9125.F2A.024C362-V6-C3-T1 fef9dfb7c603 /vdevice/l-lan@30000003 unsuccessful virtual
~~~~    

From this result you can see that " fef9dfb7c602" should be used for this service nodes MAC address. 

To retrieve the HFI MAC address used for an P775 xCAT compute nodes, your getmacs command does not require the -D flag since the first HFI adapter recognized will be used. 

~~~~    
     getmacs <HFInodes>      
~~~~    

The output for HFI interface would be similar to the following. 

~~~~    
    # Type  Location Code   MAC Address      Full Path Name  Ping Result
    hfi-ent U78A9.001.1122233-P1 020004030004 /hfi-iohub@300000000000002/hfi-ethernet@10 unsuccessful physical
    hfi-ent U78A9.001.1122233-P1 020004030004 /hfi-iohub@300000000000002/hfi-ethernet@11 unsuccessful physical
~~~~    

For more information on using the getmacs command see the man page. 

If you did not have the getmacs command write the MAC addresses directly to the database you can do it manually using the the chdef command. For example: 
 
~~~~   
    chdef -t node node01 mac=fef9dfb7c60
~~~~    
