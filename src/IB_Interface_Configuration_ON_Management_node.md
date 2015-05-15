<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Select the correct sample scripts](#select-the-correct-sample-scripts)
- [Modify the sample postscript](#modify-the-sample-postscript)
  - [(AIX Only) Temporary Fix for Adapter Node Name](#aix-only-temporary-fix-for-adapter-node-name)
- [Modify the /etc/hosts file](#modify-the-etchosts-file)
  - [**Using makehosts**](#using-makehosts)
  - [**Define the IB Switch(Optional)**](#define-the-ib-switchoptional)
- [Update networks table with IB sub-network](#update-networks-table-with-ib-sub-network)
- [Setup name server on management node](#setup-name-server-on-management-node)
- [Check the IB network](#check-the-ib-network)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note: To configure IB interfaces with xCAT 2.8 and above, see [Configuring_Secondary_Adapters].**

XCAT provides two sample postscripts - **configiba.1port** and **configiba.2ports** to configure the IB secondary adapter. These two scripts can run on either AIX and Linux nodes. 

There are two ways to configure IB interfaces, either during node installation or using the updatenode command to update the node after the node is installed. Most of the configuration steps for the two ways are the same. 


### Select the correct sample scripts

The two scripts are stored in /opt/xcat/share/xcat/ib/scripts. Each IB adapter has two ports. If there is only one port available per adapter, you should use **configiba.1port**. If two ports are available per adapter, use the script **configiba.2ports**. 

For example: 

One port available: 

~~~~
    
    cp /opt/xcat/share/xcat/ib/scripts/configiba.1port /install/postscripts/configiba
~~~~    

Two ports available: 
 
~~~~   
    cp /opt/xcat/share/xcat/ib/scripts/configiba.2ports /install/postscripts/configiba
~~~~    

**Note: A new postscript /install/postscripts/configib is shipped with xCAT 2.8, the configib postscript works with the new "nics" table and confignic postscript, which where introduced in xCAT 2.8 also. The configiba.1port and configiba.2ports will still work but will be in maintenance mode.**

### Modify the sample postscript

  * Modify the netmask and gateway values: 

In the sample postscript, the netmask is hardcoded to 255.255.255.0 and the gateway is hardcoded to "X.X.255.254". If these values are not appropriate for your environment, change them in the script. 

If the IB interface name is not a simple combination of short hostname and ibX or netmask and gateway does not meet the user's requirement, then modify the sample script , as in the example below: 

  * Modify the hostname and IP address scheme: 

The default scheme used by the postscript to determine the hostname and IP address for each IB interfaces is: 

  1. form the hostname of the IB interface by concatenating the node name with the interface name 
  2. resolve this hostname to get the IP address associated with it 
  3. use this hostname and IP address to configure the IB interface 

If this scheme doesn't work for you, then modify it in the postscript. For example, if the node name of the compute node is xcat01-en (a hostname of *-eth* is not supported) , and the IB interface name is xcat01-ib0, xcat01-ib1, etc. The user should modify the /install/postscript/configiba as follows: 

change: 
   
~~~~ 
    if [ $NODE ]
    then
        hostname="$NODE-$nic"
    else
        hostname="$HOST-$nic"
    fi
~~~~    

to 
    
~~~~
    fullname=`echo $NODE | cut -c 1-11`
    hostname="$fullname-$nic"
~~~~    

For additional information about the hostname/IP address scheme, see the documentation for configuring additional ethernet adapters, which uses a similar scheme: [Configuring_Secondary_Adapters]. 

  * Modify the IB adapter number: 

It is assumed every node has one IB adapter, if there are two adapters available on each node, modify the /install/postscript/configiba as following: (In some old xCAT release, please check the two sample postscripts(configiba.1port and configiba.2ports) ) 
    
~~~~
    for num in 0 1
~~~~    

to 

~~~~    
    for num in 0 1 2 3
~~~~    

In the latest release, the script could find the adapter number by commands, so this step is not needed. 

  * Modify the active port number: 

For AIX, in the configiba.1port script, it assumes that the port 1 of the IB is Active, and the port 2 is Down. In your environment , if the port 2 is Active and port 1 is Down, you should change the port=1 to port=2 manually before using it. 

Such as: 

From 
 
~~~~   
    #Configure the IB interfaces.  Customize the port num.
    iba_num=$num
    ib_adapter="iba$iba_num"
    port=1
~~~~    

To 

~~~~    
    #Configure the IB interfaces.  Customize the port num.
    iba_num=$num
    ib_adapter="iba$iba_num"
    port=2
~~~~
    

#### (AIX Only) Temporary Fix for Adapter Node Name

To aid in monitoring and debugging the IB fabric, it is very useful for each endpoint to have the proper node name associated with it. In linux clusters this happens automatically as it should. In AIX clusters, the AIX device driver doesn't yet put the node name correctly into the IB NIC definition. The AIX developement team is working on a fix for this, but in the mean time, the xCAT configiba postscript can be modified as shown below to accomplish it. Note that this will work well for AIX diskless nodes, since the postscript will run every time the node boots. For AIX diskful nodes, the postscript will only be run during initial install of the node. You will also need to add a similar script to an rc file for subsequent boots. 

Replace this section in the configiba script: 
    

~~~~    
            elif [ $PLTFRM == "AIX" ]
            then
                lsdev -C | grep icm | grep Available
                if [ $? -ne 0 ]
                then
                    mkdev -c management -s infiniband -t icm
                    if [ $? -ne 0 ]
                    then
                        mkdev -l icm
                        if [ $? -ne 0 ]
                        then
                            exit $?
                        fi
                    fi
                fi
    
                #Configure the IB interfaces.  Customize the port num.
                iba_num=$num
                ib_adapter="iba$iba_num"
                port=1
                mkiba -a $ip -i $nic -A $ib_adapter -p $port -P -1 -S up -m $netmask
            fi

~~~~    

with this: 

~~~~    
    
    elif [ $PLTFRM == "AIX" ]
            then
                if [ $num -eq 0 ]
                then
                   rmdev -dl ib0
                   rmdev -dl iba0
                   rmdev -dl ib1
                   rmdev -dl iba1
                   rmdev -dl ib2
                   rmdev -dl iba2
                   rmdev -dl ib3
                   rmdev -dl iba3
                   rmdev -dl icm
                   mkdev -c management -s infiniband -t icm
                   cfgmgr
                fi
    
                #Configure the IB interfaces.  Customize the port num.
                iba_num=$num
                ib_adapter="iba$iba_num"
                port=1
                mkiba -a $ip -i $nic -A $ib_adapter -p $port -P -1 -S up -m $netmask -k on
            fi
~~~~    

### Modify the /etc/hosts file

The IP address entries for IB interfaces in /etc/hosts on the xCAT management node should use a hostname that is a combination of the node name (usually the short hostname) and the unique IB interface name. 

The format should be as follows: 
  
~~~~  
    <ip_address_for_this_ib_interface>   <node_short_hostname-ib_interfacename>
~~~~    

For example: 

xcat01 is the node name, xcat01-ib0, xcat01-ib1, xcat01-ib2, etc. are the host names for the IB interfaces on xcat01. 

For AIX, ml0 interface is also required to be setup together with IB interfaces. It follows the same name conversion with IB interfaces. 

Following is an example of /etc/hosts for AIX: 
 
~~~~   
    192.168.0.10 xcat01
    192.168.1.10 xcat01-ib0
    192.168.2.10 xcat01-ib1
    192.168.3.10 xcat01-ib2
    192.168.4.10 xcat01-ib3
    192.168.5.10 xcat01-ml0
~~~~    

  


#### **Using makehosts**

For large networks, you can more easily maintain your /etc/hosts file by using the xCAT makehosts command. If your node hostnames and IP addresses follow a regular pattern, use a few regular expressions in the hosts table and then easily generate /etc/hosts using makehosts. See the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) man page for options. 

For example, add a line to the hosts table like the one below, where compute is a group of nodes that are defined in your system. 
  
~~~~  
    node,ip,hostnames,otherinterfaces,comments,disable 
    "compute","|\D+(\d+)|192.168.0.(9+($1))|",,"|\D+(\d+)|xcat($1)-ib0:192.168.1.(9+($1))|",,
~~~~    

Run 
 
~~~~   
     makehosts
~~~~    

The regular expressions above have the format: |pattern-match-on-the-nodename|value-to-put-in-this-col| . In this example, there is a regular expression for the ip column and a regular expression for the otherinterfaces column: 

  * ip column: match node names that have the format xxx-## . Extract the number part of the name and add it to 192.168.0.9 to form the ip address. 
  * otherinterfaces column: match node names that have the format xxx-## . Extract the number part of the name and create an entry like xcat01-ib0:192.168.1.10 . 

See the [xcatdb man page](http://xcat.sourceforge.net/man5/xcatdb.5.html) for a more complete explanation of regular expressions in xCAT tables. 

Now that you have the regular expressions set up, each time you add a new node to the group, run makehosts &lt;newnode&gt; and it will be added to your /etc/hosts file. 

#### **Define the IB Switch(Optional)**

Add the address of the IB Switch to /etc/hosts 

~~~~    
    9.118.47.172 ibswitch
~~~~    

### Update networks table with IB sub-network

For example: 
   
~~~~ 
 chdef -t network -o en0 net=192.168.0.0 mask=255.255.255.0 mgtifname=en0 nameservers=192.168.0.13
 chdef -t network -o ib0 net=192.168.1.0 mask=255.255.255.0 mgtifname=ib0
 chdef -t network -o ib1 net=192.168.2.0 mask=255.255.255.0 mgtifname=ib1
 chdef -t network -o ib2 net=192.168.3.0 mask=255.255.255.0 mgtifname=ib2
 chdef -t network -o ib3 net=192.168.4.0 mask=255.255.255.0 mgtifname=ib3
 chdef -t network -o ib4 net=192.168.5.0 mask=255.255.255.0 mgtifname=ib4
~~~~    

Note: Attributes gateway, dhcpserver, tftpserver, and nameservers in networks table are not necessary for IB networks, since the xCAT management work is still running on ethernet. But nameservers on ethernet network need to be set for the DNS server which will provide name resolution for IB interfaces. 

### Setup name server on management node

Put IB interface entries in /etc/hosts into DNS and restart the DNS: 

For Linux Management Nodes: 
 
~~~~   
    makedns
    service named restart
~~~~
    

For AIX Management Nodes: 

~~~~    
    makedns
    stopsrc -s named
    startsrc -s named
~~~~    

### Check the IB network

Check if DNS resolution of the IB network has been setup successfully on management node . If not, check the steps the previous setup steps. 

~~~~    
    nslookup xcat01-ib0
    nslookup xcat01-ib1
~~~~    
