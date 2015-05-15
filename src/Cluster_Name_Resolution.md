<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Cluster Name Resolution](#cluster-name-resolution)
  - [**Set the site domain Attribute**](#set-the-site-domain-attribute)
  - [**Create xCAT Network Definitions**](#create-xcat-network-definitions)
  - [**Populate the /etc/hosts File**](#populate-the-etchosts-file)
  - [**Preparing for Using a DNS**](#preparing-for-using-a-dns)
  - [**Option #1: Running DNS on Your Management Node**](#option-#1-running-dns-on-your-management-node)
  - [**Option #2: Use a DNS That is Outside of the Cluster**](#option-#2-use-a-dns-that-is-outside-of-the-cluster)
  - [**Option #3: Run DNS on Management Node and Service Nodes**](#option-#3-run-dns-on-management-node-and-service-nodes)
  - [**Creating node resolv.conf files on AIX - Overview**](#creating-node-resolvconf-files-on-aix---overview)
    - [**Providing "domain" and "nameservers" values - AIX**](#providing-domain-and-nameservers-values---aix)
  - [**Option #4: Using /etc/hosts Throughout the Cluster**](#option-#4-using-etchosts-throughout-the-cluster)
- [Specifying additional network interfaces for cluster nodes](#specifying-additional-network-interfaces-for-cluster-nodes)
  - [**Managing additional interface information using the xCAT *defs commands**](#managing-additional-interface-information-using-the-xcat-defs-commands)
    - [**Expanded format for nic* attributes**](#expanded-format-for-nic-attributes)
    - [**Setting individual nic attribute values**](#setting-individual-nic-attribute-values)
    - [Add additional NIC information for a single cluster node](#add-additional-nic-information-for-a-single-cluster-node)
    - [Add additional NIC information for a group of nodes](#add-additional-nic-information-for-a-group-of-nodes)
    - [**Using expanded stanza file format**](#using-expanded-stanza-file-format)
    - [**Using lsdef to display nic* attributes**](#using-lsdef-to-display-nic-attributes)
  - [**"otherinterfaces" vs. nic* attributes**](#otherinterfaces-vs-nic-attributes)
  - [**Setting addition interface information using the xCAT tabedit command.**](#setting-addition-interface-information-using-the-xcat-tabedit-command)
- [Limited support for user application networks](#limited-support-for-user-application-networks)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


### Cluster Name Resolution

Setting up name resolution and having the nodes resolve to IP addresses is required in xCAT clusters.

There are many different ways to configure name resolution in your cluster. Four of the common choices will be described in this section (look for **Option #:** headings):

  1. In a basic (non-hierarchical) cluster, point all nodes to a DNS running on the management node. This is the most common setup.
  2. In a basic (non-hierarchical) cluster, point all nodes to an external DNS running at your site. This requires that all of your nodes have network connectivity to your site.
  3. In a hierarchical cluster, point all compute nodes to their service node. This is the common setup for hierarchical clusters.
  4. Don't use DNS, just distribute the /etc/hosts file to every node. If you choose this you will have to distribute new versions of the /etc/hosts file to all the cluster nodes whenever you add new nodes to the cluster, and you will have to specify site.master and all other server attributes in the database as IP addresses.

But before any of those options are chosen, there some things that must be done for all of the options...

#### **Set the site domain Attribute**

First set the domain attribute in the xCAT site table to the hostname domain you want to use for your cluster nodes:

~~~~
    chdef -t site domain=mycluster.com
~~~~

#### **Create xCAT Network Definitions**

When you installed xCAT, it ran [makenetworks](http://xcat.sourceforge.net/man8/makenetworks.8.html) to create network definitions for the networks that the management node is connected to (i.e. has NICs configured for). If the cluster-facing NICs were not configured when xCAT was installed, or if there are more networks in the cluster that are only available via the service nodes or compute nodes, create the new network definitions now.

Use the mkdef command to add additional networks to the xCAT database. (See the [network](http://xcat.sourceforge.net/man7/network.7.html) for information about each attribute.) For example:

~~~~
    mkdef -t network clusternet net=11.0.0.0 mask=255.255.0.0 gateway=11.0.0.254 domain=app.cluster.com
~~~~

**Note**: The **makedns** command (mentioned below) will only add nodes into the DNS configuration if the network for the node is defined.

If you want to use a different hostname domain or a different set of nameservers for nodes that are on a particular network, set those attributes in the corresponding network object:

~~~~
    mkdef -t network clusternet domain=app.cluster.com nameservers=1.2.3.4
~~~~

**Note:** the domain setting specific to a network is only supported in xCAT 2.8 and above.

#### **Populate the /etc/hosts File**

All of the management node interfaces and all of the nodes need to be added to the /etc/hosts file on the xCAT management node (whether you are using the DNS option or not). You can either edit the /etc/hosts file by hand, or use [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html).

If you edit the file by hand, it should look similar to:

~~~~
    127.0.0.1  localhost localhost.localdomain
    50.1.2.3  mgmtnode-public mgmtnode-public.cluster.com
    10.0.0.100  mgmtnode mgmtnode.cluster.com
    10.0.0.1  node1 node1.cluster.com
    10.0.0.2  node2 node2.cluster.com
~~~~

Support for multiple network domain names is available starting in the xCAT 2.8 release.

Verify that your /etc/hosts file contains entries for all of your management node interfaces. Manually add any that are missing.

If your node names and IP addresses follow a regular pattern, you can easily populate /etc/hosts by putting a regular expression in the xCAT hosts table and then running **makehosts**. To do this, you need to first create an initial definition of the nodes in the database, if you haven't done that already:

~~~~
    mkdef node[01-80] groups=compute,all
~~~~

Next, put a regular expression in the hosts table. The following example will associate IP address 10.0.0.1 with node1, 10.0.0.2 with node2, etc:

~~~~
    chdef -t group compute ip='|node(\d+)|10.0.0.($1+0)|'
~~~~

(For an explanation of the regular expressions, see the [xcatdb](http://xcat.sourceforge.net/man5/xcatdb.5.html) man page.) Then run:

~~~~
    makehosts compute
~~~~

and the following entries will be added to /etc/hosts:

~~~~
    10.0.0.1 node01 node01.cluster.com
    10.0.0.2 node02 node02.cluster.com
    10.0.0.3 node03 node03.cluster.com
~~~~

Starting with xCAT release 2.8 you may also specify additional network interface information in the xCAT node or group definitions.

This information is used by the **makehosts** command to add the additional interface hostnames etc. to the /etc/hosts file. It is also used by xCAT adapter configuration postscripts to automatically configure the additional network interfaces on the node. See the section [Cluster_Name_Resolution/#specifying-additional-network-interfaces-for-cluster-nodes](Cluster_Name_Resolution/#specifying-additional-network-interfaces-for-cluster-nodes) for more information.

Note that it is a convention of xCAT that for Linux systems the short hostname is the primary hostname for the node, and the long hostname is an alias. On AIX the order is typically reversed. To have the long hostname be the primary hostname, you can use the -l option on the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) command.

#### **Preparing for Using a DNS**

If you are choosing any of the options for using DNS, follow these steps:

**NOTE**: This documentation only applies to the xCAT **makedns** command using the ddns.pm plugin, which is the new default dnshandler in xCAT 2.6.2 and above. The ddns.pm plugin is based on named9/bind9, and can not support named8/bind8 due to syntax difference. For example, if you are using AIX 6.1, named points to named8 by default, so you need to link named to named9 before makedns is issued.

  * Set the "nameservers" and "forwarders" attributes in the xCAT [site](http://xcat.sourceforge.net/man5/site.5.html) table. The nameservers attribute identifies the DNS's that the nodes to point to in their /etc/resolv.conf files. The forwarders attribute are the DNS's that can resolve external hostnames. If you are running a DNS on the xCAT MN, it will use the forwarders DNS's to resolve any hostnames it can't.

For example:

~~~~
    chdef -t site nameservers=10.0.0.100 forwarders=9.14.8.1,9.14.8.2
~~~~

  * Create an /etc/resolv.conf file on the management node

Edit "/etc/resolv.conf" to contain the cluster domain value you set in the site table above, and to point to the same DNS you will be using for your nodes (if you are using DNS). Although using the same DNS on your management node and compute nodes is not strictly required in xCAT 2.7 and above, it is a good idea, because you find name resolution problems more quickly.

#### **Option #1: Running DNS on Your Management Node**

This is the most common set up. In this configuration, a DNS running on the management node handles all name resolution requests for cluster node names. A separate DNS in your site handles requests for non-cluster hostnames.

There are several bits of information that must be included in the xCAT database before running the [makedns](http://xcat.sourceforge.net/man8/makedns.8.html) command.

You must set the "forwarders" attribute in the xCAT cluster "site" definition. The "forwarders" value should be set to the IP address of one or more nameservers at your site that can resolve names outside of your cluster. With this set up, all nodes ask the local nameserver to resolve names, and if it is a name that the management node DNS does not know about, it will try the forwarder names.

An xCAT "network" definition must be defined for each management network used in the cluster. The "net" and "mask" attributes will be used by the **makedns** command.

A network "domain" and "nameservers" value must be provided either in the network definiton corresponding to the nodes or in the site definition.

For example, if the cluster domain is "mycluster.com", the IP address of the management node, (as known by the cluster nodes), is "100.0.0.41" and the site DNS servers are "50.1.2.254,50.1.3.254" then you would run the following command.

~~~~
    chdef -t site domain=mycluster.com nameservers=100.0.0.41 forwarders=50.1.2.254,50.1.3.254
~~~~

Once /etc/hosts is populated with all of the nodes' hostnames and IP addresses, configure DNS on the 
 management node and start it:

~~~~
    makedns -n
    chkconfig named on     # linux
    startsrc -s named      # AIX
~~~~

The resolv.conf files for the compute nodes will be created automatically using the "domain" and "nameservers" values set in the xCAT "network" or "site" definition.

If you add nodes or change node names or IP addresses later on, rerun **makedns** which will automatically restart **named**.

To verify the DNS service on management node is working or not:

~~~~
    nslookup <host> <mn's ip>
~~~~

For example:

~~~~
    nslookup node1 100.0.0.41
~~~~

#### **Option #2: Use a DNS That is Outside of the Cluster**

If you already have a DNS on your site network and you want to use it to solve the node name in your cluster, follow the steps in this section to configure your external dns (against your local dns on xCAT MN/SN).

  * Set the site "nameservers" value to the IP address of the external name server.

~~~~
    chdef -t site nameservers=<external dns IP>
~~~~

  * Set the correct information of external dns into the /etc/resolv.conf on your xCAT MN.

The "domain" and "nameservers" values must be set correctly in /etc/resolv.conf. Which should have the same values with the ones your set in the site table.

  * Manually set up your external dns server with correct named.conf and correct zone files
  * Add the TSIG to the named.conf of your external dns for makedns command to update external dns

~~~~
    tabdump -w key==omapi passwd
      get the key like "omapi","xcat_key","MFRCeHJybnJxeVBNaE1YT1BFTFJzN2JuREFMeEMwU0U=",,,,
    Add it to your named.conf
      key xcat_key {
           algorithm hmac-md5;
           secret "MFRCeHJybnJxeVBNaE1YT1BFTFJzN2JuREFMeEMwU0U=";
      };
    Then change each zone to make your zones to allow this key to update.
      zone "1.168.192.IN-ADDR.ARPA." in {
           type master;
           allow-update {
                   key xcat_key;
           };
           file "db.192.168.1";
      };
~~~~


  * To update the name resolution entries from /etc/hosts or hosts table of xCAT MN to external dns

~~~~
    makedns -e
~~~~

    Alternatively, you can set site.externaldns=1 and run 'makedns'


#### **Option #3: Run DNS on Management Node and Service Nodes**

When you have service nodes, the recommended configuration is to run DNS on the management node and all of the service nodes. Two choices are available:

**Option #3.1**: Using the management node as DNS server, the service nodes as forwarding/caching servers.

This means the DNS server on the management node is the only one configured with all of the node 
hostname/IP address pairs. The DNS servers on the service nodes are simply forwarding/caching the
 DNS requests to the management node.

**Option #3.2**: Using the management node as DNS master, the service nodes as DNS slaves.(available in xCAT 2.8.4 and above)

This means the DNS server on the management node is configured with all of the node hostname/IP address 
pairs, and allowed to transfer DNS zones to the service nodes. The DNS servers on the service nodes are DNS 
slaves, so that if the management node goes down for some reason, then you still have the service nodes to be
 able to do name resolution.

The configurations are described below for the two options, note the differences marked as **Option #3.x**.

Set site "forwarders" value to DNS servers outside of the cluster that can resolve non-cluster hostnames. The in-cluster DNS will automatically forward requests that it can't handle to these name servers:

~~~~
    chdef -t site forwarders=50.1.2.254,50.1.3.254
~~~~

Note: for **Option #3.1**, only the DNS on the management node will use the "forwarders" setting. The DNS servers on the service nodes will always forward requests to the management node.
Note: for Option #3.2, make sure servicenode.nameserver=2 before you run 'makedns -n'.

Once /etc/hosts is populated with all of the nodes' hostnames and IP addresses, configure DNS on the management node and start it:

~~~~
   
    makedns -n       
    chkconfig named on     # linux
    startsrc -s named      # AIX
~~~~

When the /etc/resolv.conf files for the compute nodes are created the value of the "nameserver" is gotten from site.nameservers or networks.nameservers if it's specified.

For example:

~~~~
    chdef -t site nameservers="<xcatmaster>"       # for Option #3.1
    OR
    chdef -t network <my_network> nameservers="<xcatmaster>"   # for Option #3.1


    chdef -t site nameservers="<xcatmaster>, MN_IP"       # for Option #3.2
    OR
    chdef -t network <my_network> nameservers="<xcatmaster>, MN_IP"   # for Option #3.2
~~~~

The &lt;xcatmaster&gt; keyword will be interpreted as the value of the &lt;xcatmaster&gt; attribute of the node definition. The &lt;xcatmaster&gt; value for a node is the name of it's server as known by the node. This would be either the cluster-facing name of the service node or the cluster-facing name of the management node.

**Note**: for Linux, the site "nameservers" value must be set to &lt;xcatmaster&gt; before you run **makedhcp**.

Make sure that the DNS service on the service nodes will be set up by xCAT.

Assuming you have all of your service nodes in a group called "service" you could run a command similar to the following.

~~~~
    chdef -t group service setupnameserver=1       # for Option #3.1
    chdef -t group service setupnameserver=2       # for Option #3.2
~~~~

For Linux systems, make sure DHCP is set up on the service nodes.

~~~~
    chdef -t group service setupdhcp=1
~~~~

If you have not yet installed or diskless booted your service nodes, xCAT will take care of configuring and starting DNS on the service nodes at that time. If the service nodes are already running, restarting xcatd on them will cause xCAT to recognize the above setting and configure/start DNS:

~~~~
    xdsh service 'service xcatd restart'   # linux

    xdsh service 'restartxcatd'            # AIX
~~~~

If you add nodes or change node names or IP addresses later on, rerun **makedns**. The DNS on the service nodes will automatically pick up the new information.

#### **Creating node resolv.conf files on AIX - Overview**

The resolv.conf files could be created manually or you could use the xCAT support to automate the creation of the files when the nodes are installed.

This section provides an overview of the various ways you can set up resolv.conf files in an AIX cluster.

##### **Providing "domain" and "nameservers" values - AIX**

The resolv.conf file requires a "domain" value and a "nameservers" value. When using xCAT on AIX you must provide this information in one of three ways:

1) Create a NIM resolv_conf resource and include it in your xCAT osimage definition. To do this you must create a NIM reolv_conf resource on the xCAT management node and include it in the xCAT osimage definition you will use to install the cluster nodes.

2) Add values for the "domain" and "nameservers" attributes to the xCAT "site" definition. When setting up a cluster the xCAT "site" definition is used to save some basic cluster-wide information. You can add the "domain" and "nameservers" values to the "site" definition using the xCAT **chdef** command. For example:

~~~~
    chdef -t site domain=mycluster.com nameservers=30.1.0.102
~~~~

3) Add values for the "domain" and "nameservers" attributes to the xCAT "network" definitions. An xCAT "network" definition must be created for each network that is used for cluster management. You can add the "domain" and "nameservers" values to the network definitions using the **chdef** command. For example:

~~~~
     chdef -t network -o cluster_net domain=mycluster.com nameservers=30.1.0.102
~~~~

When xCAT on AIX is determining the resolv.conf file for a node it will use the following priority order:

  1. The user provided resolv_conf resource is used if provided.
  2. If there is no resolv_conf resource then the information from the network definition, that corresponds to the node, will be used. (I.e. If the node is located on the "cluster_net" network then the "domain" and "nameservers" values from that network definition will be used.
  3. If there is no resolv_conf resource AND the network definition does not contain the "domain" and "nameservers" values then the "site" definition will be used.
  4. If the "domain" and "nameservers" values are not provided in any of the above then no resolv.conf file will be created on the nodes.

When setting the value for the "nameservers" attribute you may either use a comma-separated list of server IP addresses OR the keyword "<xcatmaster>". The "<xcatmaster>" keyword will be interpreted as the value of the "xcatmaster" attribute of the node definition. The "xcatmaster" value for a node is the name of it's server as known by the node. This would be either the name of the service node or the name of the management node.

#### **Option #4: Using /etc/hosts Throughout the Cluster**

**Note**: currently this option only works easily on AIX. To make it work on linux, you have to also manually change /etc/nsswitch.conf .

If you choose to use a fully populated /etc/hosts file on every node, you must ensure that the file gets updated throughout the cluster every time a node is added or a hostname or IP address changes.

**NOTE:** You should also remove the "nameservers" setting from the site definition and from any
    "network" definiton so that xCAT will not generate an /etc/resolv.conf file for the nodes. For example:


~~~~

    chdef -t site nameservers=""
~~~~

There are several methods you can use to update the /etc/hosts files on the nodes.

1) Use the xCAT **xdcp** command to copy the new files to the nodes.

     See [xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html) for details.

In this case the new /etc/hosts file **would not be** available during the boot of the node.

2) Use the xCAT [Sync-ing_Config_Files_to_Nodes] support.

     For example, you could create a synclist file containing the following entry:

~~~~
    /etc/hosts -> /etc/hosts
~~~~

     The file can be put anywhere, but let's assume you name it /install/custom/compute-image/synclist .
     Make sure you have an OS image object in the xCAT database associated with your nodes:


~~~~
    mkdef -t osimage compute-image synclists=/install/custom/compute-image/synclist
~~~~

~~~~
    chdef -t group compute provmethod=compute-image
~~~~

     Each time you install or diskless boot a compute node, xCAT will automatically sync the /etc/hosts file 
to the node. If you make changes to /etc/hosts while the nodes are running, you must push those changes to the
 nodes:


~~~~
    updatenode compute -F
~~~~

In this case the new /etc/hosts file **would not be** available during the boot of the node.

3) Use the xCAT statelite support for diskless nodes.

     If all of your nodes are statelite nodes you can add /etc/hosts to the [litefile]
(http://xcat.sourceforge.net/man5/litefile.5.html) table with the "ro" option and add the place it can be 
mounted from to the [litetree](http://xcat.sourceforge.net/man5/litetree.5.html) table.

     For Linux systems see [Linux statelite doc](XCAT_Linux_Statelite) for details on using the statelite support.

     For AIX systems refer to the documentation on AIX Diskless Nodes:

[XCAT_AIX_Diskless_Nodes] for details on using the statelite support. See the section titled "Provide a read-only configuration file" for an example of how you could set up the /etc/hosts file.

In this case the new /etc/hosts file **will** be available during the boot of the node.

### Specifying additional network interfaces for cluster nodes

**Note**: This support is available starting with the xCAT 2.8.1 release.

You can specify additional interface information as part of an xCAT node definition. This information is used 
by xCAT to populate the /etc/hosts file with the extra interfaces (using the **makehosts** command) and 
providing xCAT adapter configuration scripts with the information required to automatically configure the 
additional interfaces on the nodes.

To use this support you must set one or more of the following node definition attributes.

   * nicips - IP addresses for additional interfaces (NIC). (Required)
    nichostnamesuffixes - Hostname suffixes per NIC. This is a suffix to add to the node name to use for the hostname of the additional interface. (Optional)
   * nictypes - NIC types per NIC. The valid "nictypes" values are: "ethernet", "infiniband", and "bmc". (Optional)
   * niccustomscripts - The name of an adapter configuration postscript to be used to configure the interface. (Optional)
   * nicnetworks - xCAT network definition names corresponding to each NIC.  (ie. the network that the nic ip resides on.) (Optional)
   * nicaliases -  Additional aliases to set for each additional NIC. 
        (These are added to the /etc/hosts file when using **makehosts**).(Optional)


The additional NIC information may be set by directly editing the xCAT "nics" table or by using the xCAT *defs commands to modify the node definitions.

The details for how to add the additional information is described below. As you will see, entering this 
information manually can be tedious and error prone. **This support is primarily targetted to be used in 
conjunction with other IBM products that have tools to fill in this information in an automated way.**





#### **Managing additional interface information using the xCAT *defs commands**

The xCAT *defs commands ([mkdef](http://xcat.sourceforge.net/man1/mkdef.1.html), [chdef](http://xcat.sourceforge.net/man1/chdef.1.html), and [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html)) may be used to manage the additional NIC information in the xCAT database.

When using the these commands the expanded nic* attribute format will always be used.




##### **Expanded format for nic* attributes**

The expanded format will be the nics attribute name and the nic name, separated by a "." (dot).(ie. <nic attr name>.<nic name> )

For example, the expanded format for the "nicips" and "nichostnamesuffixes" attributes for a nic named "eth1" might be:

~~~~
     nicips.eth1=10.1.1.6
     nichostnamesuffixes.eth1=-eth1
~~~~

If we assume that your xCAT node name is "compute02" then this would mean that you have an additonal interface ("eth1") and that the hostname and IP address are "compute02-eth1" and "10.1.1.6".

A "|" delimiter is used to specify multiple values for an interface. For example:

~~~~
    nicips.eth2=60.0.0.7|70.0.0.7
    nichostnamesuffixes.eth2='-eth2|-eth2-lab'
~~~~

This indicates that "eth2" gets two hostnames and two IP addresses. ( compute02-eth2 gets 60.0.0.7 and compute02-eth2-lab" gets "70.0.0.7".)

For the "nicaliases" attribute a list of additional aliases may be provided.

~~~~
    nicaliases.eth1='alias1 alias2'
    nicaliases.eth2='alias3|alias4'
~~~~

This indicates that the "compute02-eth1" hostname would get the additional two aliases, alias1 alias2", included in the /etc/hosts file, (when using the **makehosts** command).

The second line indicates that "compute02-eth2" would get the additonal alias "alias3" and that "compute02-eth-lab" would get "alias4"




##### **Setting individual nic attribute values**

The nic attribute values may be set using the **chdef** or **mkdef** commands. You can specify the nic* values
 when creating an xCAT node definition with **mkdef** or you can update an existing node definition using **chdef**.

**Note**: **chdef** does not support using the "-m" and "-p" options to modify the nic* attributes.


**nicips** example:

~~~~
    chdef -t node -o compute02 nicips.eth1=11.10.1.2 nicips.eth2='80.0.0.2|70.0.0.2'
~~~~

**NOTE**: The management interface (eth0), that the "compute02" IP is configured on, is not included in the list of additional nics. Although adding it to the list of nics would do no harm.

This "nicips" value indicates that there are two additional interfaces to be configured on node compute02, 
eth1 and eth2. The "eth1" interface will get the IP address "11.10.1.2". The "eth2" interface will get two IP 
addresses, "80.0.0.2" and "70.0.0.2".

**nichostnamesuffixes** example:

~~~~
    chdef -t node -o compute02 nichostnamesuffixes.eth1=-eth1 nichostnamesuffixes.eth2='-eth2|-eth2-lab'
~~~~

This value indicates that the hostname for "eth1" should be "compute02-eth1". For "eth2" we had two IP 
addresses so now we need two suffixes. The hostnames for "eth2" will be "compute02-eth2" and "compute02-
eth2-lab". The IP for "compute02-eth2" will be "80.0.0.2" and the IP for "compute02-eth2-lab" will be 
"70.0.0.2".

The suffixes provided may be any string that will conform to the DNS naming rules.

**Important Note**: According to DNS rules a hostname must be a text string up to 24 characters drawn from the
 alphabet (A-Z), digits (0-9), minus sign (-), and period (.). When you are specifying "nichostnamesuffixes" 
or "nicaliases" make sure the resulting hostnames will conform to this naming convention.

**nictypes** example:

~~~~
    chdef -t node -o compute02 nictypes.eth1=ethernet nictypes.eth2='ethernet|ethernet'
~~~~

This value indicates that all the nics are ethernet. The valid "nictypes" values are: "ethernet", "infiniband", and "bmc".

**niccustomscripts** example:

~~~~
    chdef -t node -o compute02 niccustomscripts.eth1=cfgeth niccustomscripts.eth2='cfgeth|cfgeth'
~~~~

In this example "cfgeth" is the name of an adapter configuration postscript to be used to configure the interface.

**nicnetworks** example:

~~~~
    chdef -t node -o compute02 nicnetworks.eth1=clstrnet11 nicnetworks.eth2='clstrnet80|clstrnet-lab'
~~~~

In this example we are saying that the IP address of "eth0" (ie. compute02-eth1 -> 11.10.1.2) is part of the
 xCAT network named "clstrnet11". "compute02-eth2" is in network "clstrnet80" and "compute02-eth2-lab" is in
 "clstrnet-lab".

By default the xCAT code will attempt to match the interface IP to one of the xCAT network definitions.

**An xCAT network definition must be created for all networks being used in the xCAT cluster environment.**

**nicaliases** example:

~~~~
    chdef -t node -o compute02 nicaliases.eth1="moe larry"
~~~~

In this example it specifies that, (when running **makehosts**), the "compute02-eth1" entry in the /etc/hosts file should get the additional aliases "moe" and "larry".

##### Add additional NIC information for a single cluster node

In this example we assume that we have already designated that node "compute01" get IP address "60.0.0.1" 
which will be configured on interface "eth0". This will be the xCAT management interface for the node. In 
addition to the management interface we also wish to include information for the "eth1" interface on node 
"compute01". To do this we must set the additional nic information for this node. For example:

~~~~
    chdef -t node -o compute01 nicips.eth1='80.0.0.1' nichostnamesuffixes.eth1='-eth1' nictypes.eth1='ethernet' nicnetworks.eth1='clstrnet80'
~~~~

This information will be used to configure the "eth1" interface, (in addition to the management interface (eth0)), during the boot of the node.

Also, if you were to run "makehosts compute01" at this point you would see something like the following entries added to the /etc/hosts" file.

~~~~
    60.0.0.1 compute01 compute01.cluster60.com
    80.0.0.1 compute01-eth1 compute01-eth1.cluster80.com
~~~~

The domain names are found by checking the xCAT network definitions to see which one would include the IP address. The domain for the matching network is then used for the long name in the /etc/hosts file.

**NOTE**: If you specify the same IP address for a nic as you did for the management interface then the nic 
hostname will be considered an alias of the xCAT node hostname. For example, if you specified "60.0.0.1" for 
the eth1 "nicips" value then the /etc/hosts entry would be:

~~~~
    60.0.0.1 compute01 compute01.cluster60.com compute01-eth1
~~~~




##### Add additional NIC information for a group of nodes

In this example we'd like to configure additional "eth1" interfaces for a group of cluster nodes.

The basic approach will be to create an xCAT node group containing all the nodes and then use a regular 
expression to determine the actual "nicips" to use for each node.

For this technique to work you must set up the hostnames and IP address to a have a regular pattern. For more 
information on using regular expressions in the xCAT database see the [xcatdb](http://xcat.sourceforge.net/man5/xcatdb.5.html) man page.

In the following example, the xCAT node group "compute" was defined to include all the computational nodes:
 compute01, compute02, compute03 etc. (These hostnames/IPs will be mapped to the "eth0" interfaces.)

For the "eth1" interfaces on these nodes we'd like to have "compute01-eth1" map to "80.0.0.1", and "compute02-eth1" to map to "80.0.0.2" etc.

To do this we could define the "compute" group attributes as follows:

~~~~
    chdef -t group -o compute nicips='|\D+(\d+)|eth1!80.0.0.($1+0)|' nichostnamesuffixes='eth1!-eth1' nictypes='eth1!ethernet'
~~~~

These values will be applied to each node in the "compute" group. So, for example, if I list the attributes of
 "compute08" I'd see the following nic* attribute values set.

~~~~
    lsdef compute08
    Object name: compute08
         . . . .
         nicips.eth1=80.0.0.8
         nichostnamesuffixes.eth1=-eth1
         nictypes.eth1=ethernet
         . . . .
~~~~

Here is a second example of using regular expressions to define multiple nodes:

~~~~
    chdef -t group -o nictest nicips='|\D+(\d+)|ib0!10.4.102.($1*1)|' nichostnamesuffixes='ib0!-ib' nictypes='ib0!Infiniband' nicnetworks='ib0!barcoo_infiniband'


     lsdef nictest
       Object name: node01
       groups=nictest
       nichostnamesuffixes.ib0=-ib
       nicips.ib0=10.4.102.1
       nicnetworks.ib0=barcoo_infiniband
       nictypes.ib0=Infiniband
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell
~~~~

As of release 2.8.1, you can use a **simplified regular expression** leaving off the evaluation of the node name and xCAT will automatically do that for you and get the same result.

~~~~
     chdef -t group -o nictest nicips='**|ib0!10.4.102.($1*1)|'** nichostnamesuffixes='ib0!-ib'  nictypes='ib0!Infiniband' nicnetworks='ib0!barcoo_infiniband'


     lsdef nictest
       Object name: node01
       groups=nictest
       nichostnamesuffixes.ib0=-ib
       nicips.ib0=10.4.102.1
       nicnetworks.ib0=barcoo_infiniband
       nictypes.ib0=Infiniband
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell

~~~~






**NOTE**: Make sure you haven't already set nic* values in the individual node definitions since they would take precedence over the group value.

##### **Using expanded stanza file format**

The xCAT stanza file supports the expanded nic* attribute format.

It will contain the nic* attributes as described above.

Example:

~~~~
     compute01:
           objtype=node
           arch=x86_64
           mgt=ipmi
           cons=ipmi
           bmc=10.1.0.12
           nictypes.etn0=ethernet
           nicips.eth0=11.10.1.3
           nichostnamesuffixes.eth0=-eth0
           nicnetworks.eth0=clstrnet1
           nictypes.eth1=ethernet
           nicips.eth1=60.0.0.7|70.0.0.7
           nichostnamesuffixes.eth1=-eth1|-eth1-lab
           nicnetworks.eth1=clstrnet2|clstrnet3
           nicaliases.eth0="alias1 alias2"
           nicaliases.eth1="alias3|alias4"
~~~~

The **lsdef** command may be used to create a stanza file in this format and the **chdef/mkdef** commands will read a stanza file in this format.




##### **Using lsdef to display nic* attributes**

If a node has any nic* attributes set they will be displayed along with the node definition. The nic* attribute values are displayed in the expanded format.

~~~~
    lsdef compute02
~~~~

If you would only like to see the nic* attributes for the node you can specify the "--nics" option on the command line.

~~~~
    lsdef compute02 --nics
~~~~

If you would like to display individual nic* attribute values you can use the "-i" option.

You can either specify the base nic* attribute name or the expanded name for a specific NIC.

~~~~
    lsdef compute05 -i nicips,nichostnamesuffixes
     Object name: compute05
       nicips.eth1=11.1.89.7
       nicips.eth2=12.1.89.7
       nichostnamesuffixes.eth1=-lab
       nichostnamesuffixes.eth2=-app
~~~~

~~~~
     lsdef compute05 -i nicips.eth1,nichostnamesuffixes.eth1
      Object name: compute05
       nicips.eth1=11.1.89.7
       nichostnamesuffixes.eth1=-lab
~~~~

#### **"otherinterfaces" vs. nic* attributes**

The nic* attribute support will be replacing the support for the "otherinterfaces" node attribute in the xCAT 2.8.1 release.
For now the "otherinterfaces" attribute will still be supported but it may be dropped in future releases.
Any new network interface information should be provided using the new nic* attributes.

If you are currently using the "otherinterfaces" node attribute you do not have to move it to the nic* attributes at this time. However, be careful to avoid any overlap or conflict with the information provided for each.

If you are using "otherinterfaces" and add additional interfaces using the nic* attributes the [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) command will add both to the /etc/hosts table.

When both the "otherinterfaces" and nic* attributes are used the "otherinterfaces" attribute is processed before the nic* attributes.

#### **Setting addition interface information using the xCAT tabedit command.**

Another option for setting the nic* attribute values is to use the [tabedit](http://xcat.sourceforge.net
/man8/tabedit.8.html) command. All the nic* attributes for a node or group are stored in the xCAT database 
table named "nics". You can edit the table directly using the xCAT **tabedit** command.

Example:

~~~~
     tabedit nics
~~~~

For a description of the nic* table attributes see the [nics](http://xcat.sourceforge.net/man5/nics.5.html) table man page.

**Sample table contents:**

~~~~
    #node,nicips,nichostnamesuffixes,nictypes,niccustomscripts,nicnetworks,nicaliases,comments,disable
    "compute03","eth0!11.10.1.3,eth1!60.0.0.7","eth0!-eth0,eth1!-eth1","eth0!ethernet,eth1!ethernet",,
    "eth0!clstrnet11,eth1!clstrnet60",eth0!moe,,
    .   .   .   .   .
~~~~

### Limited support for user application networks

**Note**: This support is available starting with the xCAT 2.8 release.
In some cases you may have additional user application networks in your site that are not specifically used for cluster management.

If desired you can create xCAT network definitions for these networks.
This not only provides a convenient way to keep track of the network details but the information can also be used to help set up name resolution for these networks on the cluster nodes.
When you add a network definition that includes a "domain" value then that domain is automatically included the xCAT name resolution set up. This will enable the nodes to be able to resolve hostnames from the other domains.

For example, when you run [makedhcp -n](http://xcat.sourceforge.net/man8/makedhcp.8.html) it will list all 
domains defined in the xCAT "site" definition and xCAT "network" definitions in the "option domain-search" 
entry of the shared-network stanza in the dhcp configuration file. This will cause **dhcp** to put these 
domains in the compute nodes' /etc/resolv.conf file every time it gets a dhcp lease.

Also, on AIX systems, when the default NIM "resolv_conf" resource is created it will include all the "site" 
and "network" domains in the "search" entry of the /etc/resolv.conf file.


