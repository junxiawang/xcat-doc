<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Setting Up Name Resolution](#setting-up-name-resolution)
  - [Populating the /etc/hosts File](#populating-the-etchosts-file)
  - [Add the Cluster Networks to the Networks Table](#add-the-cluster-networks-to-the-networks-table)
  - [Name Resolution Choices](#name-resolution-choices)
  - [Option 1: All Nodes Use Management Node DNS](#option-1-all-nodes-use-management-node-dns)
  - [Option 2: All Nodes Use a DNS Outside of the Cluster](#option-2-all-nodes-use-a-dns-outside-of-the-cluster)
  - [Option 3: In a Hierarchical Cluster, Point All Nodes to Their Service Node](#option-3-in-a-hierarchical-cluster-point-all-nodes-to-their-service-node)
  - [Option 4: Use /etc/hosts, Instead of DNS, Throughout the Cluster](#option-4-use-etchosts-instead-of-dns-throughout-the-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[No_Longer_Used_Warning](No_Longer_Used_Warning) 



### Setting Up Name Resolution

Setting up name resolution and having the nodes resolve to IP addresses is required in xCAT. Please note that documentation only applies to xCAT makedns with ddns.pm, which is the new default dnshandler in 2.6.2 and above. 

Note: The new makedns needs the nameserver in /etc/resolv.conf on management node point to mn's own IP, and if the compute nodes also needs to name resolution to outside hosts, put the external nameservers in site.forwarders. 

xCAT provides several tools to help with this. The first step is to choose the domain for the hostnames of your nodes: 
    
    chdef -t site domain=cluster.com

#### Populating the /etc/hosts File

All of the nodes should be in the /etc/hosts file. You can either edit the /etc/hosts file by hand, or use [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html). If you edit the file by hand, it should look similar to: 
    
    127.0.0.1  localhost localhost.localdomain
    50.1.2.3  mgmtnode-public mgmtnode-public.cluster.com
    10.0.0.100  mgmtnode mgmtnode.cluster.com
    10.0.0.1  node1 node1.cluster.com
    10.0.0.2  node2 node2.cluster.com

If your node names and IP addresses follow a regular pattern, you can easily populate /etc/hosts by putting a regular expression in the xCAT hosts table and then running makehosts. To do this, you need to first create an initial definition of the nodes in the database, if you haven't done that already: 
    
    mkdef node[01-80] groups=compute,all

Next, put a regular expression in the hosts table. The following example will associate IP address 10.0.0.1 with node1, 10.0.0.2 with node2, etc: 
    
    chdef -t group -o compute ip='|node(\d+)|10.0.0.($1+0)|'

Then run 
    
    makehosts compute

and the following entries will be added to /etc/hosts: 
    
    10.0.0.1 node01 node01.cluster.com
    10.0.0.2 node02 node02.cluster.com
    10.0.0.3 node03 node03.cluster.com
    ...

For an explanation of the regular expressions, see the [xCAT database man page](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

Note that it is the normal convention of xCAT that the short hostname is the primary hostname for the node, and the long hostname is an alias. If you really prefer to have the long hostname be the primary hostname, you can use the -l option on the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) command. 

#### Add the Cluster Networks to the Networks Table

The makedns command (used later) will only add nodes into the DNS configuration that are on one of the networks defined in the xCAT [networks table](http://xcat.sourceforge.net/man5/networks.5.html). When you installed xCAT, it populated the networks table with the networks that the management node is connected to (i.e. has NICs configured for). If the cluster-facing NICs were not configured when xCAT was installed, or if there are more cluster networks that are only available via the service nodes, you must add them to the networks table now. 

You can use the xCAT makenetworks command to gather cluster network information and create xCAT network definitions. See the makenetworks man page for details. 

You can also use the xCAT mkdef command to manually define the network. 

Here is an example of adding a network to the networks table: 
    
    mkdef -t network -o clusternet net=10.0.0.0 mask=255.0.0.0 gateway=10.0.0.254

#### Name Resolution Choices

There are many different ways to configure name resolution in your cluster. Some of the common choices are: 

  1. In a basic (non-hierarchical) cluster, point all nodes to a DNS running on the management node. 
  2. In a basic (non-hierarchical) cluster, point all nodes to an external DNS running at your site. 
  3. In a hierarchical cluster, point all compute nodes to their service node 
  4. Use /etc/hosts, instead of DNS, throughout the cluster 

Each of these common choices will be discussed in turn. Hopefully, these examples will also show you how the pieces fit together, in case you want to configure name resolution slightly differently in your cluster. 

#### Option 1: All Nodes Use Management Node DNS

This is the most common set up. In this configuration, a DNS running on the management node handles all name resolution requests for cluster node names. A separate DNS in your site handles requests for non-cluster hostnames. 

Set site.forwarders to DNS servers outside of the cluster that can resolve non-cluster hostnames. The management node DNS will automatically forward requests that it can't handle to these name servers: 
    
    chdef -t site forwarders=50.1.2.254,50.1.3.254

Once /etc/hosts is populated with all of the nodes' hostnames and IP addresses, configure DNS on the management node and start it: 
    
    makedns -n
    chkconfig named on     # linux
    startsrc -s named      # AIX

Set [site](http://xcat.sourceforge.net/man5/site.5.html).nameservers to the cluster facing IP address of the management node so all nodes will use that as their name server: 
    
    chdef -t site nameservers=10.0.0.100

Note: setting site.nameservers or [networks](http://xcat.sourceforge.net/man5/networks.5.html).nameservers causes xCAT to set up an /etc/resolv.conf file for the nodes. 

If you add nodes or change node names or IP addresses later on, rerun makedns(named is restarted by makedns automatically). 

#### Option 2: All Nodes Use a DNS Outside of the Cluster

If you already have a DNS on your site network and you want to use that for your cluster node names too, you can point all of the nodes to it. You must ensure that your nodes have IP connectivity to the DNS, and you must manually configure your DNS with the node hostnames and IP addresses. 
    
    chdef -t site nameservers=50.1.2.254

#### Option 3: In a Hierarchical Cluster, Point All Nodes to Their Service Node

When you have service nodes, the recommended configuration is to run DNS on the management node and all of the service nodes. The DNS on the management node is the only one configured with all of the node hostname/IP address pairs. The DNS servers on the service nodes are simply forwarding/caching servers. 

Set site.forwarders to DNS servers outside of the cluster that can resolve non-cluster hostnames. The management node DNS will automatically forward requests that it can't handle to these name servers: 
    
    chdef -t site forwarders=50.1.2.254,50.1.3.254

Note: only the DNS on the management node will use the forwarders setting. The DNS servers on the service nodes will always forward requests to the management node. 

Once /etc/hosts is populated with all of the nodes' hostnames and IP addresses, configure DNS on the management node and start it: 
    
    makedns -n
    chkconfig named on     # linux
    startsrc -s named     # AIX

Set [site](http://xcat.sourceforge.net/man5/site.5.html).nameservers to "&lt;xcatmaster&gt;" to indicate that each node should use the node that it is managed by (either management node or service node) as its DNS server: 
    
    chdef -t site nameservers='&lt;xcatmaster&gt;'

Note: for Linux, site.namservers needs to be set to "&lt;xcatmaster&gt;" before you run makedhcp. 

Make sure that the DNS service on the service nodes will be set up by xCAT. Assuming you have all of your service nodes in a group called "service": 
    
    chdef -t group service setupnameserver=1
    chdef -t group service setupdhcp=1       #Linux

If you have not yet installed or diskless booted your service nodes, xCAT will take care of configuring and starting DNS on the service nodes at that time. If the service nodes are already running, restarting xcatd on them will cause xCAT to recognize the above setting and configure/start DNS: 
    
    xdsh service 'service xcatd restart'   # linux
    xdsh service 'restartxcatd'            # AIX

If you add nodes or change node names or IP addresses later on, rerun makedns. The DNS on the service nodes will automatically pick up the new information. 

#### Option 4: Use /etc/hosts, Instead of DNS, Throughout the Cluster

Note: currently this option only works easily on AIX. To make it work on linux, you have to also manually change /etc/nsswitch.conf . 

If you choose to use a fully populated /etc/hosts file on every node, you must ensure that the file gets updated throughout the cluster everytime a node is added or and hostname or IP address changes. The easiest way to do this is with xCAT [sync files](Sync-ing_Config_Files_to_Nodes). 

Assuming you want to sync the management node's /etc/hosts file to the compute nodes, create a sync file like: 
    
    /etc/hosts -&gt; /etc/hosts

The file can be put anywhere, but let's assume you name it /install/custom/compute-image/synclist . 

Make sure you have an OS image object in the xCAT database associated with your nodes: 
    
    mkdef -t osimage compute-image synclists=/install/custom/compute-image/synclist
    chdef -t group compute provmethod=compute-image

Each time you install or diskless boot a compute node, xCAT will automatically sync the /etc/hosts file to the node. If you make changes to /etc/hosts while the nodes are running, you must push those changes to the nodes: 
    
    updatenode compute -F

Note: If all of your nodes are statelite nodes, you can accomplish this more easily by adding /etc/hosts to the [litefile](http://xcat.sourceforge.net/man5/litefile.5.html) table with the "ro" option and adding the place it can be mounted from to the [litetree](http://xcat.sourceforge.net/man5/litetree.5.html) table. With this approach, changes to the common hosts file on the management node will automatically be available to the nodes via NFS. See the [statelite doc](XCAT_Linux_Statelite) for details. 

You should also remove the nameservers setting from the site table (and from the networks table if you added that), so that xCAT will not generate an /etc/resolv.conf file for the nodes: 
    
    chdef -t site nameserv