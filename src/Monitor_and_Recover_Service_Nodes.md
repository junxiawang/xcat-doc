<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Monitoring Service Nodes](#monitoring-service-nodes)
  - [**Setup rmcmon**](#setup-rmcmon)
  - [**Pre-shipped Conditions for Service Nodes Monitoring**](#pre-shipped-conditions-for-service-nodes-monitoring)
  - [**Pre-shipped Responses**](#pre-shipped-responses)
  - [**Service Node Liveness Monitoring**](#service-node-liveness-monitoring)
  - [**xCAT Daemon Monitoring on Service Nodes**](#xcat-daemon-monitoring-on-service-nodes)
  - [**Network Services Monitoring on Service Nodes**](#network-services-monitoring-on-service-nodes)
  - [**Service Nodes Health Monitoring**](#service-nodes-health-monitoring)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

Service nodes are very important for the hierarchy clusters, the failure on a single service node may cause problems for hundreds of compute nodes, so the cluster administrator needs to monitor the service nodes closely and recover the failed service nodes as soon as possible. This documentation describes how to monitor the service nodes, and how to recover the service nodes when some specific service node fails.

The examples in this documentation are based on the following cluster environment:


Management Node: aixmn1(9.114.47.103) running AIX 7.1B and DB2 9.7

Service Node: aixsn1(9.114.47.115) running AIX 7.1B and DB2 9.7

Compute Node: aixcn1(9.114.47.116) running diskless AIX 7.1B




## Monitoring Service Nodes

xCAT provies a Monitoring Plug-in infrastructure that can be used to integrate the 3rd-party monitoring software into xCAT cluster. See [Monitoring_an_xCAT_Cluster] for more details on xCAT monitoring infrastructure.

rmcmon is a xCAT built-in plug-in module based on IBM's Resource Monitoring and Control (RMC) subsystem, which is part of IBM's Reliable Scalable Cluster Technology (RSCT). This documentation describes how to use the rmcmon and the xCAT-rmc pre-shipped RSCT conditions and responses to monitor the service nodes.

In this documentation, the xCAT management node is acting as the monitoring server, if you want to use separate monitoring servers, refer to [Define_monitoring_servers](Monitoring_an_xCAT_Cluster/#define-monitoring-servers) for more details.

This documentation describes how to setup monitoring for the following items on the service nodes, you may not want to monitor all of these items in your cluster, for example, the network services provided by the service nodes can be customized through xCAT configuration, some of the network services may not be configured on the service nodes. You can customize the monitoring settings based on your cluster configuration.

    1) Service nodes liveness
    2) xcatd
    3) Network services: named, DHCP, NFS, conserver, tftp, ftp
    4) System health monitoring: memory usage, file system usage


If any of the items listed above fail on any of service node, an action will be trigged by the RMC infrastructure to notify the administrators.

### **Setup rmcmon**

Follow the steps at [RMC_monitoring](Monitoring_an_xCAT_Cluster/#rmc-monitoring) to setup rmcmon plugin, substitute the hostnames in the commands with the service nodes.

### **Pre-shipped Conditions for Service Nodes Monitoring**

The package xCAT-rmc pre-shipps a lot of conditions for monitoring, and here are some specific conditions for service nodes monitoring, the condition name should be able to explain what the condition is for:

~~~~
    CheckTFTPonSN
    CheckxCATonSN
    CheckNAMEDonSN
    CheckFTPonSN
    CheckCONSonSN
    CheckNTPonSN
    CheckNFSonSN
    CheckDHCPonSN
    CheckFTPonSN_AIX
~~~~


You can use lscondition &lt;condition_name&gt; to get more details on the condition definition.

Note: The ftp service is not being used by xCAT for operating system provisioning or any other xCAT features, so monitoring the ftp service is an optional step.

Since we need to monitor the service nodes liveness, so the following condition will also be used:

~~~~
    NodeReachability
~~~~


### **Pre-shipped Responses**

The package xCAT-rmc also ships some event responses that can be linked to any of the conditions, there are no responses designed for service nodes monitoring specifically, but the following responses might be useful for the service nodes monitoring:

~~~~
    BroadcastEventsAnyTime
    LogEventToxCATDatabase
    LogEventToTealEvenetLog
~~~~


BroadcastEventsAnyTime writes a message to all the users logged in on the management node; LogEventToxCATDatabase logs the message to the xCAT eventlog table; LogEventToTealEvenetLog logs the message to the TEAL database.

You can create your own responses to meet your requirements for events notification, here is an example on how to create a response to send an email to my business email address wheneven there is some event occured in the cluster:

~~~~
    mkresponse -n "EmailAdmin" -e b -s "/opt/xcat/sbin/rmcmon/email-hierarchical-event clusteradmin@ibm.com" EmailAdminAnyTime
~~~~


### **Service Node Liveness Monitoring**

The nodes liveness information is already in the nodelist table if you used "monadd rmcmon -n" to configure rmcmon, if you did not specify the "-n" flag with monadd command or you want to be notified for the node liveness status change, you can link one or more responses to the condition "NodeReachability" or "NodeReachability_B", the condition "NodeReachability_B" is a batch condition designed to reduce the network traffic if a lot of events occur at the same time, but the batch condition also implies that there will be some kind of delay between the events and notification, you can select either or them based on your cluster scalability and configuration. Here is an example:

~~~~
    mkcondresp NodeReachability BroadcastEventsAnyTime
    startcondresp NodeReachability BroadcastEventsAnyTime
~~~~


Verify the condition response link is setup correctly, use lscondresp command:

~~~~
    aixmn1:/xcat#lscondresp
    Displaying condition with response information:
    Condition                    Response                 Node     State
    "NodeReachability"           "BroadcastEventsAnyTime" "aixmn1" "Active"


aixmn1:/xcat#
~~~~

When the service node liveness status is changed, you will get a message on the management node console like:

~~~~
    Critical Event occurred for Condition NodeReachability on the resource aixsn1 of the resource class IBM.MngNode at Sunday 01/30/11 02:15:37.  The resource was monitored on aixmn1 and resided on {aixmn1}.
~~~~


### **xCAT Daemon Monitoring on Service Nodes**

xcatd is the most important daemon for xCAT, it needs to be monitored on the service nodes. The condition CheckxCATonSN can be used for monitoring xcatd on the service nodes, here is an example:

~~~~
    mkcondresp CheckxCATonSN BroadcastEventsAnyTime
    startcondresp CheckxCATonSN BroadcastEventsAnyTime
~~~~


When the xcatd is down on the service node, you will get a warning message on the management node console like:

~~~~
    Warning Event occurred for Condition CheckxCATonSN on the resource CheckxCATSensor of the resource class IBM.Sensor at Sunday 01/30/11 02:24:18.  The resource was monitored on aixsn1 and resided on {aixsn1}.
~~~~


When the xcatd is recovered and back up and running again, you will get a rearm message on the management node console like:

~~~~
    Warning Rearm event occurred for Condition CheckxCATonSN on the resource CheckxCATSensor of the resource class IBM.Sensor at Sunday 01/30/11 02:23:18.  The resource was monitored on aixsn1 and resided on {aixsn1}.

~~~~

### **Network Services Monitoring on Service Nodes**

You can determine which network services need to be monitored on the service nodes based on your cluster configuration, here is an example:

~~~~
    mkcondresp CheckNAMEDonSN BroadcastEventsAnyTime
    startcondresp CheckNAMEDonSN BroadcastEventsAnyTime
~~~~


~~~~
    mkcondresp CheckTFTPonSN BroadcastEventsAnyTime
    startcondresp CheckTFTPonSN BroadcastEventsAnyTime
~~~~


~~~~
    mkcondresp CheckNTPonSN BroadcastEventsAnyTime
    startcondresp CheckNTPonSN BroadcastEventsAnyTime
~~~~


~~~~
    mkcondresp CheckNFSonSN BroadcastEventsAnyTime
    startcondresp CheckNFSonSN BroadcastEventsAnyTime
~~~~


~~~~
    mkcondresp CheckFTPonSN_AIX BroadcastEventsAnyTime
    startcondresp CheckFTPonSN_AIX BroadcastEventsAnyTime
~~~~


~~~~
    mkcondresp CheckDHCPonSN BroadcastEventsAnyTime
    startcondresp CheckDHCPonSN BroadcastEventsAnyTime
~~~~


When any of the network service fails on the service node, you will get a warning message on the management node console like:

~~~~
    Warning Event occurred for Condition CheckTFTPonSN on the resource ProgramName == 'tftpd' of the resource class IBM.Program at Friday 01/28/11 00:04:28.  The resource was monitored on aixsn1 and resided on {aixsn1}.

~~~~

When the network service is recovered and back up and running, you will get a rearm message on the management node console like:

~~~~
    Warning Rearm event occurred for Condition CheckTFTPonSN on the resource ProgramName == 'tftpd' of the resource class IBM.Program at Friday 01/28/11 00:04:33.  The resource was monitored on aixsn1 and resided on {aixsn1}.
~~~~


### **Service Nodes Health Monitoring**

Some of the failures on the service nodes may be caused by system health problems such as out of memory or file systems exhausted, xCAT pre-shipps several conditions to monitor the file systems usage and memory usage. You can select which conditions to be monitored based on your cluster configuration, the name of the condition should be able to explain what the conditions is for. Here is an example:

~~~~
    mkcondresp AnyNodeFileSystemSpaceUsed BroadcastEventsAnyTime
    startcondresp AnyNodeFileSystemSpaceUsed BroadcastEventsAnyTime

    mkcondresp AnyNodeVarSpaceUsed BroadcastEventsAnyTime
    startcondresp AnyNodeVarSpaceUsed BroadcastEventsAnyTime

    mkcondresp AnyNodeTmpSpaceUsed BroadcastEventsAnyTime
    startcondresp AnyNodeTmpSpaceUsed BroadcastEventsAnyTime


    mkcondresp AnyNodeRealMemFree BroadcastEventsAnyTime
    startcondrsp AnyNodeRealMemFree BroadcastEventsAnyTime


    mkcondresp AnyNodePagingPercentSpaceFree BroadcastEventsAnyTime
    startcondresp AnyNodePagingPercentSpaceFree BroadcastEventsAnyTime
~~~~


When the file systems usage or memory usage exceeds the warning threshold, you will get warning message on the management node console like:

~~~~
    Critical Event occurred for Condition AnyNodeTmpSpaceUsed on the resource /tmp of the resource class IBM.FileSystem at Sunday 01/30/11 02:48:28.  The resource was monitored on aixsn1 and resided on {aixsn1}.
~~~~


When the file system usage or memory usage falls below the rearm threshold, you will get a rearm message on the management node console like:

~~~~
    Critical Rearm event occurred for Condition AnyNodeTmpSpaceUsed on the resource /tmp of the resource class IBM.FileSystem at Sunday 01/30/11 02:50:28.  The resource was monitored on aixsn1 and resided on {aixsn1}.
~~~~


The lscondition &lt;condition_name&gt; displays the warning threshold and the rearm threshold, for example:

~~~~
    aixmn1:/#lscondition AnyNodeTmpSpaceUsed
    Displaying condition information:

    condition 1:
           Name                        = "AnyNodeTmpSpaceUsed"
           Node                        = "aixmn1"
           MonitorStatus               = "Monitored"
           ResourceClass               = "IBM.FileSystem"
           EventExpression             = "PercentTotUsed&gt;90"
           EventDescription            = "An event will be generated when more than 90 percent of the total space in the /tmp file system is in use."
           RearmExpression             = "PercentTotUsed

~~~~

