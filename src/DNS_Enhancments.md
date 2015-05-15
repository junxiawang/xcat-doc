<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Switch from bind.pm to ddns.pm](#switch-from-bindpm-to-ddnspm)
- [Using DNS in Hierarchy](#using-dns-in-hierarchy)
- [Supporting Mulitple DNS Domains](#supporting-mulitple-dns-domains)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

## Switch from bind.pm to ddns.pm

  * Validate if ddns.pm can work on AIX. (Sun Jing) 
  * Make forwarding work as we did in [bug 2823278](https://sourceforge.net/tracker/?func=detail&aid=2823278&group_id=208749&atid=1006945). (Sun Jing) 
  * Update the man page for makedns - remove all of the options that are in there today (that aren't supported) and add -n (completely rewrite the config files), -d (remove these nodes from the dns), and use the /etc/hosts entries by default if no noderange is specified. (Sun Jing) 
  * build the new perl module Net::DNS on AIX. (Sun Jing) 
  * handle migration issues from bind.pm to ddns.pm (Sun Jing) 

    

  * For xcat 2.6.2 initial install, set site.dnshandler to ddns in xcatconfig, so all the succedent makedns related operations will use the ddns.pm. 
  * For xcat 2.6.2 migrate install, set site.dnshandler to ddns in xcatconfig, while needs to give a warning message to notify the customer - from 2.6.2, xcat starts to use Dynamic DNS instead of BIND. If he wants to keep the existing DNS setting made by xcat BIND, then he should not run any "makedns" command (or set site.dnshandler to bind before running makedns). If he wants to use the Dynamic DNS configuration then he needs to run "makedns -n" to refresh the DNS setting. 

  * add the cacheing/forwarding option to ddns.pm for the dns setup on the SN (jarrod), and call that option from AAsn.pm (lissa) 

## Using DNS in Hierarchy

  * Support setting site.nameservers or networks.nameservers to "&lt;xcatmaster&gt;" to mean set the nameservers to be my SNs in the pool, or MN. (norm on aix, sun jin on linux done in 2.6.6) 
    * Linux already supports setting these attributes to a list of SNs and the MN and will put the appropriate one at the front of the list, but this list will get really long for very large clusters 
    * AIX won't support the list of SNs/MN option until there is a requirement. For now, &lt;xcatmaster&gt; is good enough. 
  * Configure DNS on the SNs to always forward unknown requests to the MN (Sun Jing done 2.6.6) 

     Already implemented. Once xcatd is restarted on SN, it will set up DNS on SN as a forwarding/catching server - create /etc/named.conf with correct options and set "forwarder" to the "nameservers" value in SN's /etc/resolv.conf, since the "nameservers" value in /etc/resolv.conf is set to MN's IP(by dhcp client on Linux; by resolv_conf nim resource on AIX), so the DNS requests on SN will always be forwarded to MN. 

  * xcatconfig should default site.nameservers to the MN and site.forwarders to the nameserver values in MN's resolv.conf (lissa done 2.6 revision 9191) 
  * Improve the relevant db attribute descriptions. (Sun Jing done 2.6.6) Here are suggestions: 
    * site.nameservers - A comma delimited list of DNS servers that each node in the cluster should use. This value will end up in the nameserver settings of the /etc/resolv.conf on each node. It is common (but not required) to set this attribute value to the IP address of the xCAT management node, if you have set up the DNS on the mgmt node by running makedns. In a hierarchical cluster, you can also set this attribute to "&lt;xcatmaster&gt;" to mean the DNS server for each node should be the node that is managing it (either its service node or the mgmt node). 
    * site.forwarders - The DNS servers at your site that can provide names outside of the cluster. The makedns command will configuire the DNS on the management node to forward requests it does not know to these servers. Note that the DNS servers on the service nodes will ignore this value and always be configured to forward requests to the management node. 
    * networks.nameservers - A comma delimited list of DNS servers that each node in this network should use. This value will end up in the nameserver settings of the /etc/resolv.conf on each node in this network. If this attribute value is set to the IP address of an xCAT node, make sure DNS is running on it. In a hierarchical cluster, you can also set this attribute to "&lt;xcatmaster&gt;" to mean the DNS server for each node in this network should be the node that is managing it (either its service node or the mgmt node). 
  * Document how to set up name resolution and put it in a transclude page, so we can include it in both aix and linux MN docs (Bruce, Lissa) 
    * document both /etc/hosts and dns, both hierarchical and non-hierarchical 
    * a draft of a page that can be transcluded into all of the main cookbooks is at [Setting_Up_Name_Resolution] 
  * Create /etc/resolv.conf files on AIX cluster nodes 

     Here is a quick summary of the AIX support. 

    

  * The resolv.conf file will be created by using the NIM resolv_conf resource which supports both diskful and diskless systems. 
  * If the user supplies his own resolv_conf resource then it will be used. 
  * If the user provides the "domain" and "nameservers" attribute in the xCAT "network" or "site" definitions then those values will be used to automatically create a NIM resolv_conf resource. 
  * The values provided in the network definition will take precedence over the values in the site definition. 
  * The network definition that will be checked is the one that corresponds to the xCAT node ip address. 
  * The "&lt;xcatmaster&gt; keyword may be used for the "nameservers" value. 
  * The &lt;xcatmaster&gt; keyword will be interpreted as the value of the "xcatmaster" attribute of the node definition. 
  * If no "nameservers" value is provided in either the site or network definition then no resolv_conf resource will be created 
  * Since the resolv_conf creation now depends on the node definition the resource will be created by the mkdsklsnode and nimnodeset commands instead of the mknimimage command. If a new resolv_conf resource is created it will be added to the osimage definition being specified for the node. 
     This code has been checked in to 2.6.6 and the man pages for mkdsklsnode and nimnodeset have been updated. 

## Supporting Mulitple DNS Domains

  * add new attribute networks.domain to allow a different domain on a network-by-network basis 
  * update dhcp.pm to use the new attribute (and do aix equivalent with the resolv.conf file) 
  * update makehost to use the new attribute to choose the correct domain for each node (based on what network it is on) 
  * update xcatd when receiving requests from the nodes to remove the correct domain 
