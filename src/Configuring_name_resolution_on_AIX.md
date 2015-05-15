<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Configuring name resolution on AIX**](#configuring-name-resolution-on-aix)
  - [**Add cluster nodes to the /etc/hosts file**](#add-cluster-nodes-to-the-etchosts-file)
  - [**Set up a DNS nameserver**](#set-up-a-dns-nameserver)
    - [**Creating node resolv.conf files**](#creating-node-resolvconf-files)
      - [**Providing "domain" and "nameservers" values**](#providing-domain-and-nameservers-values)
      - [**Description of basic options**](#description-of-basic-options)
  - [Use /etc/hosts, instead of DNS, throughout the cluster](#use-etchosts-instead-of-dns-throughout-the-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[No_Longer_Used_Warning](No_Longer_Used_Warning) 



### **Configuring name resolution on AIX**

Name resolution is required by xCAT. You can use a simple /etc/hosts mechanism or you can optionally set up a DNS name server. In either case you must start by setting up the /etc/hosts file. 

**NOTE: If you do not set up DNS you may need to distribute new versions of the /etc/hosts file to all the cluster nodes whenever you add new nodes to the cluster.**

#### **Add cluster nodes to the /etc/hosts file**

There are several ways to get entries for all the cluster nodes in the /etc/hosts file. 

These include: 

  * Manually adding the entries. 
  * Running a custom script that uses some cluster naming convention to automate the adding of the node entries. (User-provided.) 
  * Using the xCAT **makehosts** command after the XCAT node definitions have been created. 

If you are dealing with a large number of nodes this task can be quite tedious. The xCAT **makehosts** option may be useful in some cases. This process uses a regular expression to automatically determine the IP addresses and hostnames for a set of nodes. To use this method you must decide on appropriate naming conventions and IP address ranges for your nodes. This process may seem a bit complicated but once you get things set up it can save time and add structure to your cluster. 

For an explanation of the regular expressions, see the [xCAT database man page](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

If you choose to use this process you will have to come back to this section after you have created the xCAT node definitions later in this process. You should read through this now and decide on naming conventions etc. for when you create your xCAT node definitions. 

The basic process is: 

  * Decide on a node naming convention such that the node IP &amp; long hostname can be determined from the node name. 
  * Include all the nodes in a node "group" definition. 
  * Set the group "ip" and "hostnames" attribute to a regular expression that can be used to derive the node IP and hostname. 
  * Run the **makehosts** command to add all the node information to the /etc/hosts file. See the man page for makehosts . 

As an example, suppose we decide on a node naming convention that includes the hardware frame number, the CEC number and the partition number. (Say "clstrf01c01p01" etc.) Also, lets say that the IP addresses would look something like "100.1.1.1" where the second number is the frame number, the third is the CEC number and the forth is the partition number. 

With this example we can define a regular expression that, given a node name, could be used to derive a corresponding IP address and long hostname. 

To do this, you need to first create an initial definition of the nodes in the database, if you haven't done that already. For example: 
    
    mkdef node[01-80] groups=compute,all

To have this regular expression applied to each node you can make use of the xCAT node group support. Let's say that all your cluster nodes belong to the group "compute". I can add the following values to the "compute" group definition. 
    
    _**chdef -t group -o compute ip='|clstrf(\d+)c(\d+)p(\d+)|10.($1+0).($2+0).($3+0)|'**_
    hostnames='|(.*)|($1).cluster.com|'_****_
    

This basically says that for any node in the "compute" group the "ip" can be derived by the regular expression '_|clstrf(\d+)c(\d+)p(\d+)|10.($1+0).($2+0).($3+0)|' _, and the hostname can be derived from the expression _|(.*)|($1).mycluster.com|'._

Now you could display the node definition as follows: 
    
    _lsdef -l clstrf01c02p03_
    

Since this node belongs to the "compute" group, when I display the definition it will use the regular expressions to derive the "ip" and "hostnames" values. 

The output might look something like the following: 
    
    _Object name: clstrf01c02p03_
    _cons=hmc_
    _groups=lpar,all,compute_
    _hcp=clstrhmc01_
    _hostnames=clstrf01c02p03.mycluster.com_
    _id=1_
    _ip=10.1.2.3_
    _mac=001a64f9c009_
    _mgt=hmc_
    _nodetype=ppc,osi_
    _hwtype=lpar_
    _os=AIX_
    _parent=clstrf1fsp01-9125-F2A-SN024C332_
    _postscripts=myscript_
    _profile=MYimg_
    

Now that all the nodes have an "ip" and "hostnames" value you can run the xCAT **makehosts** command to update /etc/hosts. 
    
    _**makehosts compute -l**_
    

For details on using the **makehosts** coomand see: [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html). 

#### **Set up a DNS nameserver**

To set up the management node as the DNS name server you must set the "domain", "nameservers" and "forwarders" attributes in the xCAT "site" definition. 

For example, if the cluster domain is "mycluster.com", the IP address of the management node is "_100.0.0.41_" and the site DNS servers are "9.14.8.1,9.14.8.2" then you would run the following command. 
    
    _**chdef -t site domain= mycluster.com nameservers= 100.0.0.41 forwarders= 9.14.8.1,9.14.8.2**_
    

Edit "/etc/resolv.conf" to contain the cluster domain and nameserver. For example: 
    
    _search mycluster.com_
    _nameserver 100.0.0.41_
    

_Create xCAT network definitions for each of the cluster networks._ (Your network and mask value need to be defined for **makedns** to be able to set up the correct ip range for the management node to serve.) 

You will need a name for the network and values for the following attributes. 
    
    **net** The network address.
    **mask** The network mask.
    **gateway** The network gateway.
    

You can use the xCAT **makenetworks** command to gather cluster network information and create xCAT network definitions. See http://xcat.sourceforge.net/man8/makenetworks.8.html makenetworks] for details. (This feature is available in xCAT 2.3 and beyond.) 

You can also use the xCAT **mkdef** command to define the network. 

For example: 
    
    _**mkdef -t network -o net1 net=9.114.113.224 mask=255.255.255.224 gateway=9.114.113.254**_
    

Run **makedns** to create the /etc/named.conf file and populate the /var/named directory with resolution files. 
    
    _**makedns**_
    

Start DNS: 
    
    _**startsrc -s named**_
    

##### **Creating node resolv.conf files**

The resolv.conf files could be created manually or you could use the xCAT support to automate the creation of the files when the nodes are installed. 

This section provides an overview of the various ways you can set up resolv.conf files in the cluster using xCAT. Additional details will be covered in the xCAT installation documentation. 

###### **Providing "domain" and "nameservers" values**

The resolv.conf file requires a "domain" value and a "nameservers" value. When using xCAT on AIX you must provide this information in one of three ways: 

1) _Create a NIM resolv_conf resource and include it in your xCAT osimage definition._ To do this you must create a NIM reolv_conf resource on the xCAT management node and include it in the xCAT osimage definition you will use to install the cluster nodes. 

2) _Add values for the "domain" and "nameservers" attributes to the xCAT "site" definition._ When setting up a cluster the xCAT "site" definition is used to save some basic cluster-wide information. You can add the "domain" and "nameservers" values to the "site" definition using the xCAT **chdef** command. For example: 
    
    _chdef -t site domain=mycluster.com nameservers=30.1.0.102_
    

3) _Add values for the "domain" and "nameservers" attributes to the xCAT "network" definitions._ An xCAT "network" definition must be created for each network that is used for cluster management. You can add the "domain" and "nameservers" values to the network definitions using the **chdef** command. For example: 
    
     _chdef -t network -o cluster_net domain=mycluster.com nameservers=30.1.0.102_
    

When xCAT is determining the resolv.conf file for a node it will use the following priority order: 

  1. The user provided resolv_conf resource is used if provided. 
  2. If there is no resolv_conf resource then the information from the network definition, that corresponds to the node, will be used. (I.e. If the node is located on the "cluster_net" network then the "domain" and "nameservers" values from that network definition will be used. 
  3. If there is no resolv_conf resource AND the network definition does not contain the "domain" and "nameservers" values then the "site" definition will be used. 
  4. If the "domain" and "nameservers" values are not provided in any of the above then no resolv.conf file will be created on the nodes. 

_When setting the value for the "nameservers" attribute you may either use a comma-separated list of server IP addresses OR the keyword "&lt;xcatmaster&gt;"._ The "&lt;xcatmaster&gt;" keyword will be interpreted as the value of the "xcatmaster" attribute of the node definition. The "xcatmaster" value for a node is the name of it's server as known by the node. This would be either the name of the service node or the name of the management node. 

###### **Description of basic options**

Use the following descriptions to help determine how you would like to have your resolv.conf files created in the cluster. 

**Options**: 

1) _Osimage oriented_. 

     If you include a NIM resolv_conf resource in an osimage definition then all nodes that are installed with that osimage will get the same resolv.conf file. 

2) _Service node oriented_. 

     In this case you would set the "domain" and "nameservers" attributes in the site definition but not the network definitions. The "namesevers" attribute would be set to "&lt;xcatmaster&gt;". 

     The result would be that each node would get a resolv.conf file that contained the "domain" value from the site definition. The "nameservers" value would be the name of the nodes server as known by the node. (I.e. The server interface that is on the same network.) 

     This is the setup used in Power 775 clusters. 

3) _Cluster oriented_. 

     In this case you would set the "domain" and "nameservers" attributes in the site definition but not the network definitions. The "namesevers" attribute would be set to one or more comma-separated server names (IP addresses). 

     The result would be that each node would get a resolv.conf file that contained the "domain" and "nameservers" values from the site definition. 

4) _Service node/network oriented_. 

     In this case you would set the "domain" and "nameservers" attributes in the xCAT network definitions. The "namesevers" attribute would be set to "&lt;xcatmaster&gt;". 

     The result would be that each node would get a resolv.conf file that contained the "domain" from the network definition. 

**Note**: The correct network definition is determined by calculating which network the IP address of the node is part of. 

     The "nameservers" value would be the name of the nodes server as known by the node. (The server interface that is on the same network.) 

  
5) _Network oriented_. 

     In this case you would set the "domain" and "nameservers" attributes in the xCAT network definitions. The "namesevers" attribute would be set to one or more comma-separated server names (IP addresses). 

     The result would be that each node would get a resolv.conf file that contained the "domain" and "namservers" value from the network definition. 

#### Use /etc/hosts, instead of DNS, throughout the cluster

If you choose to use a fully populated /etc/hosts file on every node, you must ensure that the file gets updated throughout the cluster every time a node is added or a hostname or IP address changes. 

     **NOTE:** You should also remove the "nameservers" setting from the site definition and from any "network" definiton so that xCAT will not generate an /etc/resolv.conf file for the nodes. For example: 

    
    
    chdef -t site nameservers=

There are several methods you can use to update the /etc/hosts files on the nodes. 

1) Use the xCAT **xdcp** command to copy the new files to the nodes. 

     See [xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html) for details. 

2) Use the xCAT xCAT [sync files](Sync-ing_Config_Files_to_Nodes) support. 

     For example, you could create a synclist file containing the following entry: 

    
    
    /etc/hosts -&gt; /etc/hosts

     The file can be put anywhere, but let's assume you name it /install/custom/compute-image/synclist . 

     Make sure you have an OS image object in the xCAT database associated with your nodes: 

    
    
    mkdef -t osimage compute-image synclists=/install/custom/compute-image/synclist
    

     chdef -t group compute provmethod=compute-image 

     Each time you install or diskless boot a compute node, xCAT will automatically sync the /etc/hosts file to the node. If you make changes to /etc/hosts while the nodes are running, you must push those changes to the nodes: 

    
    
    updatenode compute -F

3) Use the xCAT statelite support for diskless AIX nodes. 

     If all of your nodes are statelite nodes you can add /etc/hosts to the [litefile](http://xcat.sourceforge.net/man5/litefile.5.html) table with the "ro" option and add the place it can be mounted from to the [litetree](http://xcat.sourceforge.net/man5/litetree.5.html) table. 

     With this approach, changes to the common hosts file on the management node will automatically be available to the nodes via NFS. See the [statelite doc](XCAT_Linux_Statelite) for details. 
