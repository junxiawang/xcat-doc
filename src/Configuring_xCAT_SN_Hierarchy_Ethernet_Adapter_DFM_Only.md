<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Define Hostnames for the Adapters](#define-hostnames-for-the-adapters)
  - [Modify and Use the configeth Postscript](#modify-and-use-the-configeth-postscript)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

In the Power 775 scaling cluster, If you plan to support DFM hardware control working through the xCAT SN, some of the hardware control commands will be dispatched from the management node to the service node. And the commands on the service node will communicate with the CECs' FSPs to do the operations. So it is important that the xCAT SN has the proper ethernet network adapters configured working with the xCAT HW service VLAN. You should make sure that it could be pinged successfully from the service node to the FSPs' IPs. 

The admin can automatically configure these network adapters as part of the adapter configuration script. 

If each FSP only has one available port, you just need to refer to the [Configuring_Secondary_Adapters] to configure 1 IP address for each service node. 

If there are dual service VLANs, each FSP will have two available Adapters which are connected to the service VLAN.. You need to refer to the following steps to configure 2 IP addresses for each service node. 

###Define Hostnames for the Adapters 

When you define the hostnames for two available adapters, you put the two IP addesses in the /etc/hosts directly, and run make hosts. If you want to put a regular expression in the xCAT hosts table, here is an example: 
 
~~~~   
    chdef -t group sn  \
       ip='|\D+(\d+)$|10.1.1.(0+$1)|'  \
       otherinterfaces='|\D+(\d+)$|-eth1:10.2.1.(0+$1)|,|\D+(\d+)$|-eth2:10.3.1.(0+$1)|'
~~~~         

  
If you have a group called sn that includes sn1, sn2, sn3, the above chdef command will give sn1 an IP address of 10.1.1.1 and an otherinterfaces setting of "-eth1:10.2.1.1,-eth2:10.3.1.1". It will give sn2 an IP address of 10.1.1.2 and an otherinterfaces setting of "-eth1:10.2.1.2,-eth2:10.3.1.2", etc. For a more detailed explanation of regular expressions in xCAT tables, see [xcatdb](http://xcat.sf.net/man5/xcatdb.5.html) . 

Once you have this entry in the xCAT hosts table, you can run: 
 
~~~~   
    makehosts sn
~~~~

and it will put these entries in the /etc/hosts table: 
    
~~~~    
    10.1.1.1  sn1 sn1.cluster.com
    10.2.1.1  sn1-eth1 sn1-eth1.cluster.com
    10.3.1.1  sn1-eth2 sn1-eth2.cluster.com
    10.1.1.2  sn2 sn2.cluster.com
    10.2.1.2  sn2-eth1 sn2-eth1.cluster.com
    10.3.1.2  sn2-eth2 sn2-eth2.cluster.com
    10.1.1.3  sn3 sn3.cluster.com
    10.2.1.3  sn3-eth1 sn3-eth1.cluster.com
    10.3.1.3  sn3-eth2 sn3-eth2.cluster.com
~~~~    

If you don't want to use regular expressions in the xCAT hosts table, you can put the secondary adapter IP addresses and hostnames directly in the /etc/hosts file by hand. 

Assuming you are using DNS for name resolution throughout the cluster (and not just using /etc/hosts), run the following command to copy the hostname/IP pairs from /etc/hosts to DNS: 

~~~~    
    makedns
~~~~

Verify that DNS now knows the hostname/IP of the secondary adapters: 
 
~~~~   
    nslookup sn1-eth1
    nslookup sn1-eth2
~~~~

If you are not using DNS for name resolution in your cluster, you need to ensure that the updated /etc/hosts file will get to the nodes during node deployment. 

### Modify and Use the configeth Postscript

Make a copy of the sample configeth postscript so you can customize it for your site: 

~~~~    
    cd /install/postscripts
    cp configeth snconfigeth1
    chmod 755 snconfigeth1
    cp configeth snconfigeth2
    chmod 755 snconfigeth2
~~~~

Edit snconfigeth1 and set the variables $nic_num and $netmask appropriately for your site. For example: 

~~~~    
    my $nic_num = 1;
    my $netmask = '255.255.0.0';
~~~~

Edit snconfigeth2 and set the variables $nic_num and $netmask appropriately for your site. For example: 
 
~~~~   
    my $nic_num = 2;
    my $netmask = '255.255.0.0';
~~~~

Put snconfigeth1 and snconfigeth2 in the postscripts table: 
  
~~~~  
    chdef -t group sn -p postscripts=snconfigeth1,snconfigeth2
~~~~

If one of your nodes is already installed/booted, you can test your postscript using updatenode: 

~~~~    
    updatenode sn1 -V -P snconfigeth1,snconfigeth2
~~~~

Once your postscript is working correctly, you can install or diskless boot your nodes and the secondary adapter will get configured automatically. 

Note: Do not forget that the new adapters interfaces hostnames must be resolvable on the node. To accomplish this on AIX you can use the NIM resolve.conf resource to automatically create a resolv.conf file on the nodes when they are installed/booted. On linux, DHCP will created the resolv.conf file. 

Note: AIX user in xCAT 2.8.3 or later should use postscript configeth_aix instead of configeth. 

If you wish to configure IB interfaces please refer to: [Managing_the_Infiniband_Network]. 
