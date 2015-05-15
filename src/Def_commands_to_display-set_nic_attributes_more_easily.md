<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Current nics attribute syntax](#current-nics-attribute-syntax)
- [External Interface](#external-interface)
  - [New support Overview](#new-support-overview)
  - [New extended format for the nics attributes](#new-extended-format-for-the-nics-attributes)
  - [New xCAT stanza file format](#new-xcat-stanza-file-format)
  - [Add new "--nics" flag to the lsdef command](#add-new---nics-flag-to-the-lsdef-command)
- [Implementation Details](#implementation-details)
  - [lsdef](#lsdef)
  - [mkdef](#mkdef)
  - [chdef](#chdef)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

The "nics" table was recently added to satisfy a requirement from PCM development. The nics attributes are included as part of the xCAT "node" object definition, the nic attributes store the nics configuration information for the nodes. 

This support was primarily intended to be used with the PCM product which has tools to automatically fill in these values. 

For non-PCM customers entering these values can be tedious and error prone. 

### Current nics attribute syntax

**nics node attribute descriptions:**

nicips - Comma-separated list of IP addresses per additional interface (NIC). 

nichostnamesuffixes - Comma-separated list of hostname suffixes per NIC. 

nictypes - Comma-separated list of NIC types per NIC. 

niccustomscripts - Comma-separated list of custom configuration scripts per NIC. 

nicnetworks - Comma-separated list of xCAT network definition names corresponding to each NIC. 

nicaliases - Additional aliases to set for each additional NIC. 

**Attribute syntax:**

nicips='eth0!11.10.1.2,eth2!80.0.0.2|fd55::214:5eff:fe15:849b' 

nichostnamesuffixes='eth0!-eth0,eth2!-eth2|-eth2-ipv6' 

nictypes='eth0!ethernet,eth2!ethernet|ethernet' 

niccustomscripts='eth0!cfgeth,eth2!cfgeth|cfgeth' 

nicnetworks='eth0!clstrnet11,eth2!clstrnet80|clstrnet-ipv6' 

nicaliases='eth0!alias1 alias2 alias3,eth2!alias3 alias4|alias5 alias6' 

**Sample table contents:**
    
     [root@ls21n01 ~]# tabdump nics
     #node,nicips,nichostnamesuffixes,nictypes,niccustomscripts,nicnetworks,nicaliases,comments,disable
     "cn1","eth0!10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b,eth1!11.1.89.7|fd57::214:5eff:fe15:849b
     |2001::214:5eff:fe15:849b,eth2!12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b","eth0!|-eth0-ipv6-1
     |-eth0-ipv6-2,eth1!-eth1|-eth1-ipv6-1|-eth1-ipv6-2,eth2!-eth2|-eth2-ipv6-1|-eth2-ipv6-2",
     "eth0!Ethernet,eth1!Ethernet,eth2!Ethernet",,"eth0!10_1_0_0-255_255_0_0|fd56::/64|2000::/64,
     eth1!11_1_0_0-255_255_0_0|fd57::/64|2001::/64,eth2!12_1_0_0-255_255_0_0|fd58::/64|2002::/64",,,
     [root@ls21n01 ~]#
    

The requirement covered by this design is to povide a more user-friendly way to manage the node attributes stored in the nics table. Enhancements will be made to def commands and some other commands to make it easy to display/set nic attributes. 

## External Interface

### New support Overview

  * Do not expose the nics table syntax when customers use the *def commands. (The user may still modify the nics table directly if so desired.) 
  * Use a new extended format for setting and displaying the nics attributes. ( &lt;nic attr name&gt;.&lt;nic name&gt; ) 
  * When using the lsdef command always display the nics attributes in expanded format. 
  * Enhance the xCAT stanza file support to include managing the new extended nics format. (Write the expanded format to the stanza file and read the expanded format from the stanza file.) 
  * Enhance chdef/mkdef to handle nics attributes in the extended format. 

### New extended format for the nics attributes

When using the lsdef, chdef, and mkdef commands the expanded nics format will always be used. 

The expanded format will be the nics attribute name and the nic name, separated by a "." (dot). (ie. &lt;nic attr name&gt;.&lt;nic name&gt; ) 

For example, the expanded format for the "nicips" attribute might be: 
    
     nicips.eth0=10.1.1.6
    

  


### New xCAT stanza file format
    
     compute01:
           objtype=node
           arch=x86_64
           mgt=ipmi
           cons=ipmi
           bmc=10.1.0.12
           nictypes.etn0=ethernet
           nicips.eth0=11.10.1.3
           nichostnamesuffixe.eth0=-eth0
           nicnetworks.eth0=clstrnet1
           nictypes.eth1=ethernet
           nicips.eth1=60.0.0.7|70.0.0.7
           nichostnamesuffixe.eth1=-eth1|-eth1-lab
           nicnetworks.eth1=clstrnet2|clstrnet3
           nicaliases.eth0="alias1 alias2"
           nicaliases.eth1="alias3|alias4"
    

### Add new "--nics" flag to the lsdef command

When the --nics command is specified with lsdef command, it will only show the nic related attributes 

## Implementation Details

### lsdef

1\. lsdef will list the nic attributes in expanded format. 
    
     [root@ls21n01 ~]# lsdef cn1
     Object name: cn1
       arch=x86_64
       ...
       netboot=xnba
       nichostnamesuffixes.eth0=|-eth0-ipv6-1|-eth0-ipv6-2
       nichostnamesuffixes.eth1=-eth1|-eth1-ipv6-1|-eth1-ipv6-2
       nichostnamesuffixes.eth2=-eth2|-eth2-ipv6-1|-eth2-ipv6-2
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
       nictypes.eth0=Ethernet
       nictypes.eth1=Ethernet
       nictypes.eth2=Ethernet
       os=rhels6.3
       ...
      [root@ls21n01 ~]# 
    

2\. A new flag --nics will be added to lsdef command to only show the nics attributes 
    
     [root@ls21n01 ~]# lsdef cn1 --nics
     Object name: cn1
       nichostnamesuffixes.eth0=|-eth0-ipv6-1|-eth0-ipv6-2
       nichostnamesuffixes.eth1=-eth1|-eth1-ipv6-1|-eth1-ipv6-2
       nichostnamesuffixes.eth2=-eth2|-eth2-ipv6-1|-eth2-ipv6-2
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
       nictypes.eth0=Ethernet
       nictypes.eth1=Ethernet
       nictypes.eth2=Ethernet
     [root@ls21n01 ~]# 
    

3\. The lsdef -i flag can specify nics attribute like nicips or the sub attributes like nicips.&lt;nicname&gt;
    
     [root@ls21n01 ~]# lsdef cn1 -i nicips,nicnetworks
     Object name: cn1
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
     [root@ls21n01 ~]# 
    
    
     [root@ls21n01 ~]# lsdef cn1 -i nicips.eth0,nicnetworks.eth1
     Object name: cn1
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
     [root@ls21n01 ~]# 
    

4\. The lsdef -t node -h -i can specify nic attribute like nicips or the sub attributes like nicips.&lt;nicname&gt;. 
    
     [root@ls21n01 ~]# lsdef -t node -h -i nicips,nicnetworks
     
     Attribute          Description
     
     nicips:         Comma-separated list of IP addresses per NIC. To specify one ip address per NIC:
                       &lt;nic1&gt;!&lt;ip1&gt;,&lt;nic2&gt;!&lt;ip2&gt;,..., for example, eth0!10.0.0.100,ib0!11.0.0.100
                   To specify multiple ip addresses per NIC:
                       &lt;nic1&gt;!&lt;ip1&gt;|&lt;ip2&gt;,&lt;nic2&gt;!&lt;ip1&gt;|&lt;ip2&gt;,..., for example, eth0!10.0.0.100|fd55::214:5eff:fe15:849b,ib0!11.0.0.100|2001::214:5eff:fe15:849a. The xCAT object definition commands support to use nicips.&lt;nicname&gt; as the sub attributes.
                   Note: The primary IP address must also be stored in the hosts.ip attribute. The nichostnamesuffixes should specify one hostname suffix for each ip address.
     
     nicnetworks:    Comma-separated list of networks connected to each NIC.
                   If only one ip address is associated with each NIC:
                       &lt;nic1&gt;!&lt;network1&gt;,&lt;nic2&gt;!&lt;network2&gt;, for example, eth0!10_0_0_0-255_255_0_0, ib0!11_0_0_0-255_255_0_0
                   If multiple ip addresses are associated with each NIC:
                       &lt;nic1&gt;!&lt;network1&gt;|&lt;network2&gt;,&lt;nic2&gt;!&lt;network1&gt;|&lt;network2&gt;, for example, eth0!10_0_0_0-255_255_0_0|fd55:faaf:e1ab:336::/64,ib0!11_0_0_0-255_255_0_0|2001:db8:1:0::/64. The xCAT object definition commands support to use nicnetworks.&lt;nicname&gt; as the sub attributes.
     [root@ls21n01 ~]# 
    
    
     [root@ls21n01 ~]# lsdef -t node -h -i nicips.eth0,nicnetworks.eth1
     
     Attribute          Description
     
     nicips:         Comma-separated list of IP addresses per NIC. To specify one ip address per NIC:
                       &lt;nic1&gt;!&lt;ip1&gt;,&lt;nic2&gt;!&lt;ip2&gt;,..., for example, eth0!10.0.0.100,ib0!11.0.0.100
                   To specify multiple ip addresses per NIC:
                       &lt;nic1&gt;!&lt;ip1&gt;|&lt;ip2&gt;,&lt;nic2&gt;!&lt;ip1&gt;|&lt;ip2&gt;,..., for example, eth0!10.0.0.100|fd55::214:5eff:fe15:849b,ib0!11.0.0.100|2001::214:5eff:fe15:849a. The xCAT object definition commands support to use nicips.&lt;nicname&gt; as the sub attributes.
                   Note: The primary IP address must also be stored in the hosts.ip attribute. The nichostnamesuffixes should specify one hostname suffix for each ip address.
     
     nicnetworks:    Comma-separated list of networks connected to each NIC.
                   If only one ip address is associated with each NIC:
                       &lt;nic1&gt;!&lt;network1&gt;,&lt;nic2&gt;!&lt;network2&gt;, for example, eth0!10_0_0_0-255_255_0_0, ib0!11_0_0_0-255_255_0_0
                   If multiple ip addresses are associated with each NIC:
                       &lt;nic1&gt;!&lt;network1&gt;|&lt;network2&gt;,&lt;nic2&gt;!&lt;network1&gt;|&lt;network2&gt;, for example, eth0!10_0_0_0-255_255_0_0|fd55:faaf:e1ab:336::/64,ib0!11_0_0_0-255_255_0_0|2001:db8:1:0::/64. The xCAT object definition commands support to use nicnetworks.&lt;nicname&gt; as the sub attributes.
     [root@ls21n01 ~]#
    

### mkdef

1\. mkdef could recoginize the stanza file with expanded nic attributes. 
    
     [root@ls21n01 ~]# cat testnode
     # &lt;xCAT data object stanza file&gt;
     
     testnode:
       objtype=node
       arch=x86_64
       groups=kvm,vm,all
       nichostnamesuffixes.eth0=|-eth0-ipv6-1|-eth0-ipv6-2
       nichostnamesuffixes.eth1=-eth1|-eth1-ipv6-1|-eth1-ipv6-2
       nichostnamesuffixes.eth2=-eth2|-eth2-ipv6-1|-eth2-ipv6-2
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
       nictypes.eth0=Ethernet
       nictypes.eth1=Ethernet
       nictypes.eth2=Ethernet
     [root@ls21n01 ~]# cat testnode | mkdef -z
     1 object definitions have been created or modified.
     [root@ls21n01 ~]# lsdef testnode
     Object name: testnode
       arch=x86_64
       groups=kvm,vm,all
       nichostnamesuffixes.eth2=-eth2|-eth2-ipv6-1|-eth2-ipv6-2
       nichostnamesuffixes.eth1=-eth1|-eth1-ipv6-1|-eth1-ipv6-2
       nichostnamesuffixes.eth0=|-eth0-ipv6-1|-eth0-ipv6-2
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nictypes.eth2=Ethernet
       nictypes.eth1=Ethernet
       nictypes.eth0=Ethernet
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles
     [root@ls21n01 ~]# 
    

2\. mkdef could accept &lt;nic attr name&gt;.&lt;nic name&gt;=&lt;value&gt; parameters 
    
     [root@ls21n01 ~]# mkdef testnode1 groups=all nicips.eth0="1.1.1.1|1.2.1.1" nicnetworks.eth0="net1|net2" nictypes.eth0="Ethernet"
     1 object definitions have been created or modified.
     [root@ls21n01 ~]# lsdef testnode1
     Object name: testnode1
       groups=all
       nicips.eth0=1.1.1.1|1.2.1.1
       nicnetworks.eth0=net1|net2
       nictypes.eth0=Ethernet
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles
     [root@ls21n01 ~]# 
    

### chdef

1\. chdef could recognize the stanza file with expanded nic attributes == 
    
     [root@ls21n01 ~]# cat testnode
     # &lt;xCAT data object stanza file&gt;
     
     testnode:
       objtype=node
       arch=x86_64
       groups=kvm,vm,all
       nichostnamesuffixes.eth0=|-eth0-ipv6-1|-eth0-ipv6-2
       nichostnamesuffixes.eth1=-eth1|-eth1-ipv6-1|-eth1-ipv6-2
       nichostnamesuffixes.eth2=-eth2|-eth2-ipv6-1|-eth2-ipv6-2
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
       nictypes.eth0=Ethernet
       nictypes.eth1=Ethernet
       nictypes.eth2=Ethernet
     [root@ls21n01 ~]# cat testnode | chdef -z
     1 object definitions have been created or modified.
     New object definitions 'testnode' have been created.
     [root@ls21n01 ~]# lsdef testnode
     Object name: testnode
       arch=x86_64
       groups=kvm,vm,all
       nichostnamesuffixes.eth2=-eth2|-eth2-ipv6-1|-eth2-ipv6-2
       nichostnamesuffixes.eth1=-eth1|-eth1-ipv6-1|-eth1-ipv6-2
       nichostnamesuffixes.eth0=|-eth0-ipv6-1|-eth0-ipv6-2
       nicips.eth2=12.1.89.7|fd58::214:5eff:fe15:849b|2002::214:5eff:fe15:849b
       nicips.eth1=11.1.89.7|fd57::214:5eff:fe15:849b|2001::214:5eff:fe15:849b
       nicips.eth0=10.1.89.7|fd56::214:5eff:fe15:849b|2000::214:5eff:fe15:849b
       nicnetworks.eth2=12_1_0_0-255_255_0_0|fd58::/64|2002::/64
       nicnetworks.eth1=11_1_0_0-255_255_0_0|fd57::/64|2001::/64
       nicnetworks.eth0=10_1_0_0-255_255_0_0|fd56::/64|2000::/64
       nictypes.eth2=Ethernet
       nictypes.eth1=Ethernet
       nictypes.eth0=Ethernet
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles
     [root@ls21n01 ~]# 
    

2\. chdef could change the &lt;nic attr name&gt;.&lt;nic name&gt;
    
     [root@ls21n01 ~]# chdef testnode nicips.eth0="1.1.1.1|2.1.1.1|3.1.1.1"
     1 object definitions have been created or modified.
     [root@ls21n01 ~]# lsdef testnode -i nicips.eth0
     Object name: testnode
         nicips.eth0=1.1.1.1|2.1.1.1|3.1.1.1
     [root@ls21n01 ~]# 
    

3\. chdef does not support to update the nic attributes with -m and -p 

It is very difficult to support this without significant changes with the basic logic of the *def commands, the current code structure only supports to minus or plus values separated by comma ",", however, the values like nicips.eth0 is only part of the nicips attribute. Some code changes were added to check the -m/-p flag work with nic attributes. 
    
     [root@ls21n01 ~]# chdef testnode -m nicips.eth0="1.1.1.1"
     Error: chdef does not support to change the nic related attributes with -m or -p flag.
     [root@ls21n01 ~]# 
    

  


## Other Design Considerations

  * Required approvers: Bruce Potter 
  * Affect on other components: *def commands, makehosts 
  * External interface changes, documentation, and usability issues: 
    * xcatstanzafile man page 
    * chdef, mkdef, and lsdef man pages 
    * Add new support to xCAT name res doc 
    * add new support to 2nd adapter doc? 
  * Packaging, installation, dependencies: N/A 
  * Portability and platforms (HW/SW) supported: N/A 
  * Performance and scaling considerations: N/A 
  * Migration and coexistence: N/A 
  * Serviceability: N/A 
  * Security: N/A 
  * NLS and accessibility: N/A 
  * Invention protection: N/A 
