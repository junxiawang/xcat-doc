<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Requirements**](#requirements)
  - [Source of requirements](#source-of-requirements)
- [**Current support**](#current-support)
- [**Documentation Changes**](#documentation-changes)
  - [man pages](#man-pages)
    - [makehosts](#makehosts)
    - [makedhcp](#makedhcp)
    - [mkdsklsnode/nimnodeset](#mkdsklsnodenimnodeset)
  - [xCAT documentation](#xcat-documentation)
    - [Cluster Name Resolution](#cluster-name-resolution)
    - [XCAT AIX Cluster Overview and Mgmt Node](#xcat-aix-cluster-overview-and-mgmt-node)
  - [Release Notes](#release-notes)
  - [Limitations](#limitations)
- [**Required testing**](#required-testing)
  - [Notes](#notes)
    - [resolv.conf req](#resolvconf-req)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## **Requirements**

1) Support a cluster that uses multiple network domain names. 

2) Kusu needs to be able to put external hostnames (with a different domain) in the hosts table, and also otherinterfaces needs to support hostnames in other domains. 

3) makehosts &amp; nics table support 

Bruce: 

In addition to supporting primary node hostnames that are part of a network object that has a different domain, you also need to support makehosts for hostnames of nics. This will be in the new nics table, one row for each node. You use the nichostnamesuffixes attribute to form the base hostname (&lt;nodename&gt;-&lt;nichostnamesuffixes&gt;), parse nicips to get the ip, and use nicnetworks to point to the row in the networks table to get the domain. Of course, for backward compatibility, it still needs to support hosts.otherinterfaces. 

Lei Ai: 

According to data module doc, we should enhance "makehosts" for generating correct hosts records for multi nics of a single host. We wish "makehosts" can deal with following use cases, please help confirm: 

  * \- nodeA's record already exists in /etc/hosts, it has 1 NIC associated with. Then we update nics table to add a new NIC + IP to nodeA. Now nodeA have 2 NICs associated with. At this point, run "makehosts nodeA" directly can update nodeA's records(2 items) in /etc/hosts.(no need to run "makehosts -d" to remove nodeA's record first and then re-generate it by running makehosts again) 
  * \- nodeA's record already exists in /etc/hosts, it has 2 NICs associated with. Then we update nics table to remove a NIC form nodeA. Running "makehosts nodeA" should be able to update nodeA's records directly. 
  * \- nodeA's record already exists in /etc/hosts, it has several NICs associated with. Then we update nics table to update the IP address of a NIC and run "makehosts nodeA", then /etc/hosts can be updated automatically to reflect the new IP address. 

Similiar with other commands: \- makedns: While add/remove/update IPs of a node, will these changes be updated into DNS configuration once after run "makedns &lt;node&gt;"? (without run makedns -d firstly) \- makedhcp, makeknownhosts: While update primary IP of a node, will this change be updated automatically once after run "makedhcp/makeknownhosts" (without run "makedhcp -d" or "makeknownhosts -r" firstly) 

Guang Cheng: 

For the makedhcp, makeknownhosts, I think we probably do not need to worry about the nics table, because the secondary adapters are not designed to get ip addresses through DHCP on MN, and the knownhosts will be updated automatically when accessing the nodes through the secondary adapters. 

4) Support hostname with dots (svn #3204130) &nbsp;????? 

5) xCAT should set up resolv.conf files with "search &lt;domain&gt;" entries for the domains from each xCAT network definition and the site def. Note: to add domains for nodes outside the cluster the user must create an xCAT network definition for the remote network that include the non-xCAT nodes. 

6) The makedhcp command must handle adding multiple domains to the dhcp configuration file, including domains for nodes outside of the cluster. 

### Source of requirements

  1. Several AIX customers. 
  2. PCM dependency 

## **Current support**

xCAT currently requires a single network domain name for the entire cluster. The domain is set by default when xCAT is installed. The **xcatconfig** script uses the primary hostname of the management node to get the domain name and stores it in the "site.domain" attribute in the xCAT database. 
    
    site.domain - The DNS domain name used for the cluster.
    

Althought it is not currently used there is also a "domain" attribute in the xCAT "networks" table. This attribute will be used for the enhanced network domain support. 
    
    networks.domain =&gt; 'The domain name for this network, (ex. cluster.com).
    

== **PCM &lt;nic1&gt;!&lt;ip1&gt;,&lt;nic2&gt;!&lt;ip2&gt;,..., for example, eth0!10.0.0.100,ib0!11.0.0.100**
    
                   To specify multiple ip addresses per NIC:
                       &lt;nic1&gt;!&lt;ip1&gt;|&lt;ip2&gt;,&lt;nic2&gt;!&lt;ip1&gt;|&lt;ip2&gt;,..., for example, eth0 !10.0.0.100|fd55::214:5eff:fe15:849b,ib0!11.0.0.100|2001::214:5eff:fe15:849a
                   Note: The primary IP address must also be stored in the hosts.ip attribute. The nichostnamesuffixes should specify one hostname suffix for each ip address.',
               **nichostnamesuffixes**  =&gt; 'Comma-separated list of hostname suffixes per NIC.
                           If only one ip address is associated with each NIC:
                               &lt;nic1&gt;!&lt;ext1&gt;,&lt;nic2&gt;!&lt;ext2&gt;,..., for example, eth0!-eth0,ib0!-ib0
                           If multiple ip addresses are associcated with each NIC:
                               &lt;nic1&gt;!&lt;ext1&gt;|&lt;ext2&gt;,&lt;nic2&gt;!&lt;ext1&gt;|&lt;ext2&gt;,..., for example,  eth0!-eth0|-eth0-ipv6,ib0!-ib0|-ib0-ipv6.',
               **nictypes** =&gt; 'Comma-separated list of NIC types per NIC. &lt;nic1&gt;!&lt;type1&gt;,&lt;nic2&gt;!&lt;type2&gt;, e.g. eth0!Ethernet,ib0!Infiniband',
               **niccustomscripts** =&gt; 'Comma-separated list of custom scripts per NIC.
     &lt;nic1&gt;!&lt;script1&gt;,&lt;nic2&gt;!&lt;script2&gt;, e.g. eth0!configeth eth0, ib0!configib ib0.',
               **nicnetworks** =&gt; 'Comma-separated list of networks connected to each NIC.
                   If only one ip address is associated with each NIC:
                       &lt;nic1&gt;!&lt;network1&gt;,&lt;nic2&gt;!&lt;network2&gt;, for example, eth0!10_0_0_0-255_255_0_0, ib0!11_0_0_0-255_255_0_0
                   If multiple ip addresses are associated with each NIC:
                       &lt;nic1&gt;!&lt;network1&gt;|&lt;network2&gt;,&lt;nic2&gt;!&lt;network1&gt;|&lt;network2&gt;, for example, eth0!10_0_0_0-255_255_0_0|fd55:faaf:e1ab:336::/64,ib0!11_0_0_0-255_255_0_0|2001:db8:1:0::/64',
               **nicaliases** =&gt; 'Comma-separated list of aliases for each NIC.
                        Format: eth0!&lt;alias&gt;,eth1!&lt;alias1&gt;|&lt;alias2&gt;
                         For example: eth0!moe,eth1!larry|curly',
               **comments** =&gt; 'Any user-written notes.',
               **disable** =&gt; "Set to 'yes' or '1' to comment out this row.",
           },
    },__
    

**3) xcatconfig** (no change needed!!!) 

  * leave the default setting of site.domain 

**4) hosts.pm** (done) 

  * update makehost to use getNodeDomains() 
  * addnode() &amp; delnode() need to find nodes real domain - not just use site table 
  * enhance "makehosts" for generating correct hosts records for multi nics of a single host. (i.e. support the new "nics" table) 
  * NEW - upadates for nics table changes 

**5) aixinstall.pm** (done) 

  * Configure nfs domain for nfs version 4 - ok 
    * continue to use the site.domain value as the nfsv4 domain across the cluster.!!!! 
  * chk_resolv_conf 
    * already handles network vs. site domain values etc. 
    * must create resolv.conf with search entries for each domain specified in network or site object 
    * get all the network defs and add a searh line for each domain - the one for the primary hostname should come first. 
  * make_SN_resource - ok 
    * usees site.domain for nfsv4 domain 
  * NEW - upadates for nics table changes 

**6) xcatd** \- ok - done 

  * update xcatd when receiving requests from the nodes to remove the correct domain 
  * find domain for "peerhost" with getNodeDomains() 

**7) iscsi.pm** \- done 

  * get domain for each node - not site table 
  * getNodeDomain(\@nodes) 
  * Jarrod - no idea how to test 

**8) ontap.pm** \- done 

  * in build_lunmap() call getNodeDomains() to get node domain 
  * Jarrod - no idea how to test 

**9) setup.pm** \- (no change) 

  * uses cluster config file to set DB 

**10) zvm.pm** (2d) 

  * have nodeset() call getNodeDomains() to get node domain 
  * phamt&nbsp;? 

**11) makeknownhosts.pm** done 

  * use getNodeDomains() to get node domain - not get_site_attribute 

**12) ddns.pm (makedns)** \- done 

  * **13) dhcp.pm** \- done 

  * makedhcp 
    * gen_aix_net() - call getNodeDomains()- 
    * make sure dhcp.conf includes search entries for all xCAT netwok domains 

**14) Template.pm** (no change???) 

  * uses domain table????? 
  * uses site.domain to get realm???? (seeJarrod&nbsp;?) 

**15) ProfiledNodeUtils.pm** \- done 

  * NEW - upadtes for nics table changes 

## **Documentation Changes**

### man pages

#### makehosts

  * add nics info 

#### makedhcp

  * add "option domain-search" entries to dhcp config files 

#### mkdsklsnode/nimnodeset

  * add note about content of resolv.conf created 

### xCAT documentation

#### Cluster Name Resolution

  * add using multi-domains 
  * add using nics table 
    * update using "tabedit nics" or chdef to modify node def 
    * required attrs - node, nicip, suffix, network def &nbsp;? 
  * misc updates 

#### XCAT AIX Cluster Overview and Mgmt Node

  * remove single domain limitation starting in xCAT 2.8. 

### Release Notes

  * can specify multi-domains 
  * can specify additional nics in nics table 
  * limited support for user application networks 

### Limitations

  * no support for multiple domains if using activedirectory support. 
  * no support for multiple domaind per subnet 

## **Required testing**

**Test resources**

The multi-domain and nics table support will be provided for both AIX and Linux, and will include hierarchical as well as non-hierarchical clusters. 

However, the primary focus should be a non-hierarchical linux cluster (for PCM support). 

  * need 2-3 management network subnets 
    * create network defs with diff domains 
  * need one user application subnet 

**Setup**

  * create network defs ( with diff domains) 
    * include network def for user app network 
  * create node defs - add ip and macs 
  * create nics table entries for nodes 
    * for each node include nicips, nichostnamesuffixes, nictypes, nicnetworks, nicaliases ( this would normally be done by PCM code - but we'll have to do it manually - ugh!) 

**Basic testing required**

1) The original requirement for this line item was to provide support for the use of multiple network domain names in an xCAT cluster. Most of this code has been in place for quite a while and has been verified to some extent by simply running xCAT 2.8 clusters. At this point we can be fairly confident that the new code did not break the existing support for a single domain. 

What remains to be verified is to actually define a cluster with multiple domains and see if anything breaks. 

Background: When a node domain value is required the code will now first check the corresponding network definition for the node and, if not set, then check the value in the site table. So, for example, the xCAT daemon now calls a new routine to find the node domain instead of just checking the site attrribute. 

2) check specific commands that use the node domain values and or the nics table attributes 

  * **mkdsklsnode/nimnodeset**
    * check resolv.conf created to see if all network domains have been added 
  * **makehosts**
    * add domains to network defs 
    * add additional nics to node defs (nics table) 
      * what attrs required - node, nicip, suffix, network def 
    * run makehosts 
      * make sure all the nics and aliases etc. are added to the /etc/hosts file 
      * check the domain values in the /etc/hosts file (should be from network def corresponding to node ip) 
      * check for entries in the /etc/hosts file from the additional nics values 
      * set values forthe existing "otherinterfaces" support and make sure it still works 
      * check update and delete /etc/hosts entries based on changes to the nics table and network domain changes 
  * **makedhcp**
    * make sure xCAT network defs are created and that the node nics information is set correctly 
    * For AIX 
      * Run makedhcp -n 
        * check configuration file /etc/dhcpsd.cnf for the network entries 
      * Run makedhcp &lt;noderange&gt;
        * make sure compute node entriesare not added (this will be done by NIM) 
    * For Linux 
      * Run makedhcp -n 
        * check configuration file /etc/dhcp/dhcpd.conf for the network entries 
      * Run makedhcp &lt;noderange&gt;
        * make sure the nodes are added to the dhcp config file and lease file (/var/lib/dhcpd/dhcpd.leases) 
        * make sure the "domain-search" field is added 
  * **makedns**
    * make sure you have valid network defs (include domains values), /etc/hosts file, resolv.conf file, site (domain, nameservers, &amp; forwarders) defined, 
    * &nbsp;??????????????? will makedns work without site nameservers and forwarders&nbsp;???????? TBD 
    * run makedns commands and make sure nslookup produces the correct info.( ex. "makedns -n", "nslookup node01") 
    * name res should also work for any additional nics specified in the nics table. (since they wound up in /etc/hosts when you ran makehosts. 

4) check the limited support for user application networks 

  * add app interface as nic for node (must include suffix for default node name) 
  * run makehosts and check /etc/hosts 
  * user app network domain should be added to the dhcp config file 

  


### Notes

#### resolv.conf req

) For the 1st part (other domains within the cluster) that is exactly what we are planning on doing - use networks.domain. 

For the non-cluster nodes, here's the idea: need to give a little background first: for the 1st part above, when multiple domains are set (in site.domain and networks.domain), they all need to be listed in the domain search on the compute nodes. Because, even though the compute node's own hostname is in a single domain (probably the one specified in networks.domain), it needs to be able to resolve hostnames of any nodes in the cluster. Plus, it could have multiple nics, each in a different domain. So when makedhcp -n builds the "shared-network" stanza for each nic it is listening on, it needs to list all domains defined (in site.domain and all networks.domain) in the "option domain-search" line. Assuming this is what we do, then a user can easily specify an additional domain they want (for resolving non-cluster node hostnames) by adding another network into the networks table with networks.domain specified. There will never be any nodes defined that are on that network, but our new makedhcp -n logic will put that networks.domain on the "option domain-search" line. 

) currently our /etc/resolve.conf (SL6.3) looks like this: &gt; &gt;&nbsp;; generated by /sbin/dhclient-script &gt; search cluster &gt; nameserver 10.255.3.206 &gt; nameserver 131.246.9.116 &gt; nameserver 131.246.1.116 &gt; &gt; Now I would like to add to the search option another domain name: &gt; &gt;&nbsp;; generated by /sbin/dhclient-script &gt; search cluster other.domain.name &gt; nameserver 10.255.3.206 &gt; nameserver 131.246.9.116 &gt; nameserver 131.246.1.116 &gt; &gt; Does xCAT support this or do I have to write a syncfile? 

) Turns out this guy's other domain is for non-cluster nodes, but it made me wonder if in your multiple domain support you recently checked in also sets all the domain names in the domain-name option in the dhcp conf (so that it gets into resolv.conf on the nodes)? Also, how would you handle this guy's request (just wants his nodes to be able to resolve hostnames from another domain)? Thx 

) I googled it and it looks like to support multiple domain names in the dhcpd.conf file we will have to switch from "option domain-name" to "option domain-search". See http://linux.die.net/man/5/dhcp-options. I only looked quickly, so do a little more research to verify this. 

) More specifically, whenever you run makedhcp -n on the mgmt node (which only has to be run if you change your networks table), you should edit your dhcpd.conf file on the mgmt node (and service nodes if you have them) and replace the line: 

option domain-name "&lt;domain1&gt;" 

with 

option domain-search "&lt;domain1&gt;", "&lt;domain2&gt;" 

and restart dhcpd. 

This should cause dhcp to put both of these domains in the computes nodes' /etc/resolv.conf file every time it gets a dhcp lease. If you just sync /etc/resolv.conf from the mgmt node to the compute nodes, it will be overridden each time the dhcp client renews its lease, unless you set PEERDNS=no in the relevant /etc/sysconfig/network-scripts/ifcfg-* file. 

) 
