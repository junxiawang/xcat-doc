<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Using NTP](#using-ntp)
  - [Using xCAT management node as the NTP server](#using-xcat-management-node-as-the-ntp-server)
  - [Using the NTP server outside of xCAT cluster](#using-the-ntp-server-outside-of-xcat-cluster)
- [Implementation hints](#implementation-hints)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Overview

The Network Time Protocol (**NTP**) is widely used to synchronize a computer to Internet time servers or other sources, it's very useful in the cluster environment to keep all the cluster nodes with time synchronization. This documentation addresses how to set up NTP in xCAT cluster, for more information about NTP visit [Home of the Network Time protocol](http://www.ntp.org/). 

**Note** the setupntp attribute in the servicenode table is not used. You must use the setupntp postscripts to set up NTP on the service nodes and cluster nodes. 

**Note** before using setupntp postscript, make sure the NTP server is configured and started correctly on the management node manually. It may take about 5 minutes for the NTP server to synchronize time to local clock or other sources. 

Here is the simple samples for /etc/ntp.conf, you may adjust the options based on your specific requirement. 

On AIX: 

    /etc/ntp.conf: 

~~~~    
    driftfile /etc/ntp.drift
    tracefile /etc/ntp.trace
    disable auth
    broadcastclient
    restrict 127.0.0.1
    server  127.127.1.0     # local clock
    fudge   127.127.1.0 stratum 10
~~~~    

    restart service: 
~~~~    
    stopsrc -s xntpd
    startsrc -s xntpd
~~~~    

On Linux: 

    /etc/ntp.conf 

~~~~    
    driftfile /var/lib/ntp/drift
    disable auth
    restrict 127.0.0.1
    server  127.127.1.0     # local clock
    fudge   127.127.1.0 stratum 10
~~~~    

    restart service: 

~~~~    
    service ntpd restart   # RedHat
    service ntp restart    # SLES
~~~~    

## Using NTP

There are many different ways to configure NTP in your cluster. Two of the common choices are: 

### Using xCAT management node as the NTP server

This is the xCAT default support, site.ntpservers/networks.ntpservers is blank by default, this means pointing the node's NTP server to the node's xcatmaster. For the service nodes it would be the management node, for the compute nodes it would be the service node who is managing it. 

**Note** normally networks.ntpservers only used when you want to use the different NTP servers for a certain network than the site.ntpservers. If you are using the same NTP servers for the whole cluster, just use site.ntpservers. 

To configure it: 

    

  * keep site.ntpservers/networks.ntpservers as blank or set to &lt;xcatmaster&gt;. 
    **Note** if you want to set site.ntpservers/networks.ntpservers to &lt;xcatmaster&gt;,
     for Linux, ensure set it before you run makedhcp. 

    

  * add setupntp to the node's "postscripts" list. 
    To do this you can either modify the "postscripts" attribute for each node individually or you can just modify the definition of a group that all the nodes belong to. 

    For example: 

    If all your nodes belong to the group "compute" then you can add setupntp to the group definition by running the following command. 

~~~~    
        chdef -p -t group -o compute postscripts=setupntp
~~~~       
    

    

    If all your service nodes belong to the group "service" then run the following command. 

~~~~    
        chdef -p -t group -o service postscripts=setupntp
~~~~    

### Using the NTP server outside of xCAT cluster

If you already have a NTP server up and running on your site network and you want to use that for your xCAT
 cluster, you can point all of the nodes to it. Note you must ensure that your nodes have IP connectivity to
 this outside NTP server. 

To configure it: 

    

  * set site.ntpservers/networks.ntpservers to the outside NTP server. 

~~~~    
        chdef -t site ntpservers=9.114.113.251
~~~~    

Note for Linux, site.ntpservers/networks.ntpservers needs to be set before you run makedhcp. 

    

  * add setupntp to the node's "postscripts" list. 
    To do this you can either modify the "postscripts" attribute for each node individually or you can just
    modify the definition of a group that all the nodes belong to. 

    For example: 

    If all your nodes belong to the group "compute" then you can add setupntp to the group definition by 
     running the following command. 
 
~~~~   
        chdef -p -t group -o compute postscripts=setupntp
~~~~       
    

    

    If all your service nodes belong to the group "service" then run the following command. 

~~~~    
        chdef -p -t group -o service postscripts=setupntp
~~~~    

## Implementation hints

  For AIX: 
  1. not using makedhcp for the compute nodes, the NTP service setup totally relies on setupntp postscript. 
  2. only support site.ntpservers, networks.ntpservers not applicable for AIX. 

  For Linux: 
  1. using makedhcp for the compute nodes, so the NTP settings are included in the DHCP server configuration.
     When the compute nodes are installed, the DHCP client will populate the /etc/ntp.conf automatically based
     on the DHCP server configuration. setupntp postscript only needs to call ntpdate/ntpd to sync the date 
     and time. 
  2. support both site.ntpservers and the networks.ntpservers. 
