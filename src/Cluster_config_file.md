<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Intro](#intro)
- [Context](#context)
- [Cluster Config File Contents](#cluster-config-file-contents)
  - [xcat-site](#xcat-site)
  - [xcat-service-lan](#xcat-service-lan)
  - [xcat-hmcs](#xcat-hmcs)
  - [xcat-frames](#xcat-frames)
  - [xcat-cecs](#xcat-cecs)
  - [xcat-building-blocks](#xcat-building-blocks)
  - [xcat-lpars](#xcat-lpars)
  - [ll-config](#ll-config)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## Intro

The cluster config file provides a convenient way for the user to give xcat (and potentially other software) high level info about the cluster. Using the xcatsetup cmd, xcat will read the file and prime the db so that it is ready for the discovery process. The contents of the cluster config file is organized into stanzas. Several of the stanzas contain xcat info (see below), but other stanzas can be added for other cluster software. These stanzas will be ignored by xcat. The other cluster software components should each read this file too and process only the stanzas they recognize. In this way, the user can specify all the high level info about the cluster in a single file, but we don't need one monolithic piece of software to process it all. 

**Note**: for more specific info about the actual implementation, see the [xcatsetup man page](http://xcat.sourceforge.net/man8/xcatsetup.8.html). 

The general format of the config file is: 
    
    xcat-site:
      domain = cluster.com
    
    xcat-service-lan:
      dhcp-dynamic-range = 10.200.100.1-10.200.100.254
      # this is a comment
      hostname-range = service-switch[1-3]
      starting-ip = 10.200.0.1
    ...

The xcat command that will read and process this file for all of the xcat-specific stanzas is: 

**xcatsetup** [**-v**|**\--version**] [**-?**|**-h**|**\--help**] _cluster-config-file_

Other cluster software components should have their own command that the admin can run to have it read the config file. 

For reference for some of the other aspects of cluster set up, see: 

  * [CRHS-like_function_enhancements] 
  * [xCAT2pHWManagement Cookbook](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2pHWManagement.pdf)
  * [xCAT DB](http://xcat.sourceforge.net/man5/ppc.5.html)
  * [xcatsetup command code](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-server/lib/xcat/plugins/setup.pm)

## Context

The overall cluster set up process is: 

  1. Follow chapters 1 &amp; 2 of [xCAT Top Cookbook](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2top.pdf)
  2. Create cluster config file 
  3. Run xcatsetup, passing it the cluster config file 
  4. Put the necessary passwords into the db 
  5. Pick up in chapter 2 of [xCAT2pHWManagement Cookbook](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2pHWManagement.pdf), except that most of the db tables have already been filled in. 
  6. Configure and start the services using makehosts, makedns, makedhcp, mkconserver.cf, etc. 
  7. Run mkvm commands to create the LPARs 
  8. Run commands from other software components to read the cluster config file 
  9. Follow the xCAT IBM HPC stack set up wiki page to load the HPC software and postscripts 
  10. Continue with the platform-specific cookbook to do node deployment 

## Cluster Config File Contents

The config file is organized into stanzas. What follows below is each stanza name, what attributes are specified by the user in that stanza, and what xcatsetup will do with it. 

**Note**: some of these keywords and the resulting actions have changed. See the [xcatsetup man page](http://xcat.sourceforge.net/man8/xcatsetup.8.html) for more accurate info about the keywords supported and the database attributes that are filled in. 

### xcat-site
    
    xcat-site:
     domain = cluster.com

xcatsetup actions: 

  1. write domain in site.domain 
  2. set site.nameservers to the MN IP 

### xcat-service-lan

This section will be implemented in a later phase. 
    
    xcat-service-lan:
     dhcp-dynamic-range = 10.200.100.1-10.200.100.254
     # The rest of the attributes in this stanza are optional.  If you do not
     # specify them, then you must specify the vpd-file attribute in the
     # xcat-frames stanza.
     hostname-range = service-switch[1-3]
     starting-ip = 10.200.0.1
     num-ports-per-switch = 40
     switch-port-prefix = Gi6/
     switch-port-sequence = hmc:*, bpa:*, fsp:*

xcatsetup actions: 

  1. using hostname-range, write: nodelist.node, nodelist.groups, switches.switch 
  2. using hostname-range and starting-ip, write regex for: hosts.node, hosts.ip 
  3. using num-ports-per-switch, switch-port-prefix, switch-port-sequence, write: switch.node, switch.switch, switch.port 
  4. using dhcp-dynamic-range, write: networks.dynamicrange for the service network. 
    * Note: for AIX the permanent IPs for HMCs/FSPs/BPAs (specified in later stanzas) should be within this dynamic range, at the high end. For linux the permanent IPs should be outside this dynamic range. 
    * use the first IP in the specified dynamic range to locate the service network in the networks table 
  5. on aix stop bootp - see section 2.2.1.1 of p hw mgmt doc 
  6. run makedhcp -n 

### xcat-hmcs
    
    xcat-hmcs:
     hostname-range = hmc01-hmc15
     starting-ip = 10.201.0.1

xcatsetup actions: 

  1. using hostname-range, write: nodelist.node, nodelist.groups 
  2. using hostname-range and starting-ip, write regex for: hosts.node, hosts.ip 
  3. using hostname-range, write regex for: ppc.node, nodetype.nodetype 

### xcat-frames
    
    xcat-frames:
     # these are the connections to the BPCs
     hostname-range = bpc01-bpc15
     starting-ip = 10.202.0.1
     num-frames-per-hmc = 3
     # The vpd-file should be in stanza format accepted by the chdef cmd, and contain the following vpd table attributes:
     #   node
     #   serial
     #   mtm
     #   side
     vpd-file = /tmp/frame-vpd-order.stanza

Example vpd-file: 
    
    bpc01:
      objtype=node
      serial=99200G1
      mtm=9A00-100
      side=A
    
    bpc02:
      objtype=node
      serial=99200D1
      mtm=9A00-100
      side=A

xcatsetup actions: 

  1. using hostname-range, write: nodelist.node, nodelist.groups 
  2. using hostname-range and starting-ip, write regex for: hosts.node, hosts.ip 
  3. using hostname-range, num-frames-per-hmc, hmc hostname-range, write regex for: ppc.node, ppc.hcp, ppc.id, nodetype.nodetype, nodehm.mgt 
  4. using vpd-file, write vpd table 

### xcat-cecs
    
    xcat-cecs:
     # these are the connections to the FSPs
     hostname-range = cec01-cec60
     starting-ip = 10.203.0.1
     supernode-list = /tmp/supernodelist.txt

The supernode-list file that can be optionally specified should have the format: 
    
    bpc01: 0, 1, 16
    bpc02: 17, 32
    bpc03: 33, 48, 49
    bpc04: 64 , 65, 80
    bpc05: 81, 96
    bpc06: 97(1), 112(1), 113(1)

xcatsetup actions: 

  1. using hostname-range, write: nodelist.node, nodelist.groups 
  2. using hostname-range and starting-ip, write regex for: hosts.node, hosts.ip 
  3. using hostname-range, write regex for: ppc.node, ppc.hcp??, ppc.id (cage id)??, ppc.parent??, nodetype.nodetype, nodehm.mgt 
  4. using supernode-list, write ppc.supernode 

### xcat-building-blocks
    
    xcat-building-blocks:
     num-frames-per-bb = 3

xcatsetup actions: 

  1. set site.sharedtftp=1 
  2. using num-frames-per-bb, write regex for ppc.parent for bpas 

### xcat-lpars
    
    xcat-lpars:
     # This is for the ethernet NIC on each SN
     service-node-hostname-range-facing-mn = sn01-sn20
     service-node-starting-ip-facing-mn = 10.200.1.1
     service-node-hostname-range-facing-cn = sn[01-20]-hfi
     service-node-starting-ip-facing-cn = 10.201.1.1
     storage-node-hostname-range = stor01-stor40
     storage-node-starting-ip = 10.202.1.1
     # do we need a login-node range???
     # This is the application network.  For each CN, the hostname will be combined with each interface name.
     compute-node-hostname-range = n001-n800
     compute-node-interface-names = hf0, hf1, hf2, hf3, ml0 (or bond0 for linux)
     compute-node-starting-ips = 10.10.1.1, 10.11.1.1, 10.12.1.1, 10.13.1.1, 10.14.1.1
     num-lpars-per-cec = 8
     #todo: do we need any other info to create the lpars, e.g. pprofile?

xcatsetup actions: 

  1. using service-node-hostname-range, write: nodelist.node, nodelist.groups 
  2. using storage-node-hostname-range, write: nodelist.node, nodelist.groups 
  3. using compute-node-hostname-range, write: nodelist.node, nodelist.groups 
  4. using service-node-hostname-range, write regex for: nodetype.nodetype, nodetype.arch, nodehm.mgt, nodehm.cons, noderes.netboot 
  5. using storage-node-hostname-range, write regex for: nodetype.nodetype, nodetype.arch, nodehm.mgt, nodehm.cons, noderes.netboot 
  6. using compute-node-hostname-range, write regex for: nodetype.nodetype, nodetype.arch, nodehm.mgt, nodehm.cons, noderes.netboot 
  7. using service-node-hostname-range, and num-lpars-per-cec, write regex for: ppc.node, ppc.id, ppc.parent, ppc.pprofile? 
  8. using storage-node-hostname-range, and num-lpars-per-cec, write regex for: ppc.node, ppc.id, ppc.parent, ppc.pprofile? 
  9. using compute-node-hostname-range, and num-lpars-per-cec, write regex for: ppc.node, ppc.id, ppc.parent, ppc.pprofile? 
  10. using service-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-hmc, write regex for: ppc.hcp 
  11. using storage-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-hmc, write regex for: ppc.hcp 
  12. using compute-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-hmc, write regex for: ppc.hcp 
  13. using storage-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-bb, service-node-hostname-range, write regex for: noderes.xcatmaster, noderes.servicenode 
  14. using compute-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-bb, service-node-hostname-range, write regex for: noderes.xcatmaster, noderes.servicenode 
  15. using service-node-hostname-range, write regex for: servicenode table 
  16. using service-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-bb, starting-subnet-ip, write regex for: hosts.node, hosts.ip 
  17. using storage-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-bb, starting-subnet-ip, application-nic-hostname-range, application-nic-starting-ip, write regex for: hosts.node, hosts.ip, hosts.otherinterfaces 
  18. using compute-node-hostname-range, num-lpars-per-cec, num-cecs-per-frame, num-frames-per-bb, starting-subnet-ip, application-nic-hostname-range, application-nic-starting-ip, write regex for: hosts.node, hosts.ip, hosts.otherinterfaces 

### ll-config
    
    ll-config:
     central_manager_list = hmc01 hmc02
     resource_mgr_list = hmc01 hmc02
     loadl_admin = loadl root loadladmin
     schedd_list = sn01 sn02 sn03 sn04
     LOG = /tmp/$(HOST)/log
     EXECUTE = /tmp/$(HOST)/execute
     SPOOL = /tmp/$(HOST)/spool

xcatsetup actions: 

  1. xcat will set up the following groups in support of rolling updates: 
    1. nodes in cec (e.g. cec01nodes), nodes in sn (e.g. sn01nodes), storage nodes in bb (e.g. bb01storage), sn in bb (e.g. bb01service) 
  2. xcat will fill in the postscripts table: llserver.sh in service row, llcompute.sh in compute row 

llconfig -i actions: 

  1. The ll-config section of the cluster configuration file will be used as a small LoadL_config file for setting up LoadLeveler configuration. 
