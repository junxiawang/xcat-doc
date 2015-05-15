The **configeth** sample postscript can be used to automatically configure additional ethernet adapters on nodes as they are being deployed. ("Additional adapters" means adapters other than the primary adapter that the node is being installed/booted over.) 

The way the configeth postscript decides what IP address to give the secondary adapter is by forming the hostname of the adapter using a convention of &lt;hostname&gt;-&lt;interfacename&gt; and then using name resolution to determine the IP address of that hostname. For example, if the node being installed/booted is sn2 and configeth is trying to configure the eth1 adapter, it will look up the IP address for sn2-eth1 and use that to configure the eth1 NIC. (You can use configeth even if you use a different naming convention, but you will have to modify the postscript more.) 

To use the configeth postscript to define a secondary adapter on one or more nodes, follow these steps: 

** Define Hostnames for the Secondary Adapters **

If you are defining secondary adapters on a whole range of nodes, it can be easier to put a single regular expression in the xCAT **hosts** table that represents the hostnames and IP addresses of the whole range. (It is not required to put this info in the hosts table. The only thing that is really required is that the information gets into the /etc/hosts table and DNS.) If you want to put a regular expression in the xCAT hosts table, here is an example: 
    
    chdef -t group sn ip='|\D+(\d+)$|10.1.1.(0+$1)|' otherinterfaces='|\D+(\d+)$|-eth1:10.2.1.(0+$1)|'

If you have a group called **sn** that includes sn1, sn2, sn3, the above chdef command will give sn1 an IP address of 10.1.1.1 and an otherinterfaces setting of "-eth1:10.2.1.1". It will give sn2 an IP address of 10.1.1.2 and an otherinterfaces setting of "-eth1:10.2.1.2", etc. For a more detailed explanation of regular expressions in xCAT tables, see http://xcat.sf.net/man5/xcatdb.5.html . 

Once you have this entry in the xCAT hosts table, you can run: 
    
    makehosts sn
    

and it will put these entries in the /etc/hosts table: 
    
    10.1.1.1  sn1 sn1.cluster.com
    10.2.1.1  sn1-eth1 sn1-eth1.cluster.com
    10.1.1.2  sn2 sn2.cluster.com
    10.2.1.2  sn2-eth1 sn2-eth1.cluster.com
    10.1.1.3  sn3 sn3.cluster.com
    10.2.1.3  sn3-eth1 sn3-eth1.cluster.com
    

If you don't want to use regular expressions in the xCAT hosts table, you can put the secondary adapter IP addresses and hostnames directly in the /etc/hosts file by hand. 

Assuming you are using DNS for name resolution throughout the cluster (and not just using /etc/hosts), run the following command to copy the hostname/IP pairs from /etc/hosts to DNS: 
    
    makedns
    

Verify that DNS now knows the hostname/IP of the secondary adapters: 
    
    nslookup sn1-eth1
    

If you are not using DNS for name resolution in your cluster, you need to ensure that the updated /etc/hosts file will get to the nodes during node deployment. 

** Modify and Use the configeth Postscript **

Make a copy of the sample configeth postscript so you can customize it for your site: 
    
    cd /install/postscripts
    cp configeth snconfigeth1
    chmod 755 snconfigeth1

Edit snconfigeth1 and set the variables **$nic_num** and **$netmask** appropriately for your site. For example: 
    
    my $nic_num = 1;
    my $netmask = '255.255.0.0';

Put snconfigeth1 in the postscripts table: 
    
    chdef -t group sn -p postscripts=snconfigeth1

If one of your nodes is already installed/booted, you can test your postscript using updatenode: 
    
    updatenode sn1 -V -P snconfigeth1

Once your postscript is working correctly, you can install or diskless boot your nodes and the secondary adapter will get configured automatically. 

Note: Do not forget that the new adapter interface hostnames must be resolvable on the node. To accomplish this on AIX you can use the NIM resolve.conf resource to automatically create a resolv.conf file on the nodes when they are installed/booted. On linux, DHCP will create the resolv.conf file. 

  
If you wish to configure IB interfaces please refer to: [Managing_the_Mellanox_Infiniband_Network] or [Managing the QLogic Infiniband Network](Managing_the_Infiniband_Network). 
