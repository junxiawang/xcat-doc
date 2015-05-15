<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Install TSA](#install-tsa)
- [Install TSA License](#install-tsa-license)
- [Create a two node peer domain](#create-a-two-node-peer-domain)
- [Setup a Tie Breaker](#setup-a-tie-breaker)
- [Create xcatd Application Resource](#create-xcatd-application-resource)
- [Create Service IP Resource](#create-service-ip-resource)
- [Create Resource Group](#create-resource-group)
- [Define Relationship Between the Resources](#define-relationship-between-the-resources)
- [Bring the Resource Group Online](#bring-the-resource-group-online)
- [Failover](#failover)
- [Some Useful TSA Commands](#some-useful-tsa-commands)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Disclaimer: xCAT management node can be configured as high availability in various ways by selecting different high availability tools and different xCAT configuration scenarios. This documentation can be treated as a sample example on how to configure a high availability tool with some specific xCAT configuration, it will not work for all xCAT configuration scenarios. You may need to create your own procedure or failover scripts according to your configuration scenario, and you can select different high availability tools other than IBM TSA.**


## Overview

This documentation describes how to configure an HA xCAT management node with IBM Tivoli System Automation(TSA). This document is also meant as an example of the types of steps that would be necessary to configure an HA management node with another HA tool. If manual failover of your management node is sufficient for you situation, see [Setting_Up_an_HA_Mgmt_Node] and [Shared_Disks_HA_Mgmt_Node]. 

The specific package we are using is IBM Tivoli System Automation for Multiplatform(SAM), the terms TSA and SAM are used interchangeably throughout this documentation. For more details about IBM Tivoli System Automation, refer to the IBM Tivoli System Automation homepage [http://www-01.ibm.com/software/tivoli.../sys-auto-multi](http://www-01.ibm.com/software/tivoli/products/sys-auto-multi)

System Automation for Multiplatforms provides a high-availability environment, in which systems are continuously available and whose self-healing infrastructure prevents downtime caused by system problems, it could be used to provide high-availability environment for different applications, in this documentation, we will use TSA to automate the xcatd failover in HAMN environment. 

The structure of the HAMN with TSA is to have two management nodes running simultaneous, there will only be one active xcatd instance on any of the management node using a single IP address(serviceIP) at any given point in time, in case of a failure, the xcatd must be restarted on the same management node or on another management node. 

It is recommended to plan and configure the HAMN from the very beginning of the cluster initial setup, it will reduce the effort on handling some configuration complexities such as xCAT database migration and hostname resolution changes. Since we are not using shared storage to provide data synchronization between the two management nodes, so the database replication and files synchronization steps described in documentation [Setting_Up_an_HA_Mgmt_Node] have to be used together with steps and procedure in this documentation. Generally speaking, all the steps before the **Failover** section in documentation [Setting_Up_an_HA_Mgmt_Node] should be performed before the steps in this documentation. 

This documentation does not cover the shared disks configuration scenario, if you are using shared disks in your cluster, the configuration procedure will be different, you can refer to IBM TSA documentation on how to configure and use shared disk in IBM TSA environment. 

The examples in this documentation are based on the following AIX and DB2 cluster environment, the steps can be applied to None-DB2 and Linux clusters with some modifications. 

_Primary Management Node: aixmn1(9.114.47.103) running AIX 7.1 and DB2 9.7.SP3_

Standby Management Node: aixmn2(9.114.47.104) running AIX 7.1 and DB2 9.7 SP3__

_Service IP address: 9.114.47.97_

You need to substitute the hostnames and ip address with your own values when setting up your HAMN environment. 

## Install TSA

TSA needs to be installed on both managment nodes. To install TSA, you can use the TSA installation script installSAM, the installSAM can be found in either of the product CD or the electronic distribution. TSA also provides a script prereqSAM to check the prerequisite packages, for example, if the packages Java* are not installed, the prereqSAM will returns error message like "_Fileset Java* not installed_". 
    
    aixmn1:/xcat/sam/SAM3210MPAIX#./installSAM
    prereqSAM: All prerequisites for the ITSAMP installation are met on operating system:  AIX 7100-00
    
    SAM is currently not installed.
    
    installSAM: The following package is not installed yet and needs to be installed:  ./AIX/AIX6/sam.core
    
    installSAM: A general License Agreement and License Information specifically for System Automation will be shown.
    
    Scroll down using the Enter key (line by line) or Space bar (page by page).
    
    At the end you will be asked to accept the terms to be allowed to install the product. Select Enter to continue.
    

Press Enter or Space to sroll down to the bottom of the license agreement, you will prompted with the following question: 
    
    installSAM: To accept all terms of the preceding License Agreement and License Information type 'y', anything else to decline.
    Answer: y
    

When the installation is completed successfully, you will see some message like "installSAM: All packages were installed successfully.". 

## Install TSA License

TSA requires that a valid product license is installed on each system it is running on. The license is contained on the installation medium in the 'license' sub directory. The installation of the license is usually performed during the product installation process. In case this did not succeed, issue the following command to install the license: 
    
    samlicm –i license_file
    

In order to display the license, issue: 
    
    samlicm -s
    

If the full product license has been installed successfully, the samlicm -s will display message like: 
    
    Product: IBM Tivoli System Automation for Multiplatforms 3.2
    Product ID: 101
    Creation date: Wed Aug 19 00:00:01 2010
    Expiration date: Thu Dec 31 00:00:01 2038
    

**Note:** In a TSA environment, the environment varilable CT_MANAGEMENT_SCOPE should be set to 2 (peer domain scope) when running any TSA command. 

## Create a two node peer domain

1\. Issue the _preprpnode_ command on both management nodes to allow TSA communication between the two management nodes. 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/preprpnode aixmn1 aixmn2
    aixmn2:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/preprpnode aixmn1 aixmn2
    

2\. You can now run _mkrpdomain_ command on any of the management node to create a two node peer domain. 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/mkrpdomain xcathadomain aixmn1 aixmn2
    

To look up the status of the peer domain, issue the _lsrpdomain_ command, since the peer domain is not started, so the peer domain status is "Offline". 
    
    aixmn1:/#lsrpdomain
    Name         OpState RSCTActiveVersion MixedVersions TSPort GSPort
    xcathadomain Offline 3.1.0.1           No            12347  12348 
    aixmn1:/#
    

3\. Issue the _startrpdomain_ command to bring the peer domain online 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/startrpdomain xcathadomain
    

After a short while, the cluster will be started, so when you issue the lsrpdomain command again, you will see that the cluster is now "Online". 
    
    aixmn1:/#lsrpdomain
    Name         OpState RSCTActiveVersion MixedVersions TSPort GSPort
    xcathadomain Online  3.1.0.1           No            12347  12348 
    aixmn1:/#
    

## Setup a Tie Breaker

The tie breaker is required for a two node peer domain, the tie breaker ensures the situation can be resolved when the peer domain is split. In this documentation, we will use a network tie breaker. The network tie breaker uses an external IP address to resolve the tie status, the external IP address must be reachable from the two management nodes and it responses for ping requests. When selecting the network tie breaker external IP address, you should also make sure that the following situation will NOT occur: both the two management nodes can ping the network tie breaker while they can not communicate with each other. You can choose any ip address which can only be reached via a single path from each management node as the network tie breaker, if the default gateway is not virtualized by the network infrastructure, it will be good network tie breaker. 

Issue command mkrsrc to create the network tie breaker. 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/mkrsrc IBM.TieBreaker Type="EXEC" Name="mynetworktb" DeviceInfo='PATHNAME=/usr/sbin/rsct/bin/samtb_net Address=9.114.47.126 Log=1' PostReserveWaitTime=30
    

Activate the network tie breaker using command chrsrc: 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/chrsrc -c IBM.PeerNode OpQuorumTieBreaker="mynetworktb"
    

## Create xcatd Application Resource

An IBM.Application resource will be created to represents the xcatd daemon. As part of the definition of application resource xcatd, commands or scripts for starting, stopping and querying the xcatd have to be specified. These commands and/or scripts can be different ones, but it is often convenient to gather these functions in a single script, which has a command line parameter to select start/stop/status actions. These scripts will often be user-written. Here is an example of the definition file and *Command script file: 
    
    aixmn1:/xcat/sam#cat xcatd.def
    PersistentResourceAttributes::
           Name="xcatd"
           StartCommand="/xcat/sam/samxcatd --start"
           StartCommandTimeout=1000
           StopCommand="/xcat/sam/samxcatd --stop"
           StopCommandTimeout=120
           MonitorCommand="/xcat/sam/samxcatd --monitor"
           MonitorCommandPeriod=5
           MonitorCommandTimeout=5
           UserName="root"
           NodeNameList={"aixmn1","aixmn2"}
           ResourceType=1
    
    aixmn1:/xcat/sam#
    

You can modify the MonitorCommandTimeout according to your expection on how quick the failover should occur after failure, modify the StartCommandTimeout, StopCommandTimeout and MonitorCommandTimeout based on how long the start, stop and monitor process may take. The unit of the *Timeout attributes is second. The ResourceType=1 is important for the xcatd resource because it indicates that this is a "floating" resource, it means that the resource is not tied to any particilar management node and can be started on any of the management node. 
    
    aixmn1:/xcat/sam#cat samxcatd
    #!/usr/bin/perl
    
    use Getopt::Long;
    
    $Getopt::Long::ignorecase = 0;    #Checks case in GetOptions
    Getopt::Long::Configure("bundling");
    
    if (
                 !GetOptions(
                                   "h"         =&gt; \$::HELP,
                                   "v|V"       =&gt; \$::VERBOSE,
                                   "s|start"   =&gt; \$::START,
                                   "S|stop"    =&gt; \$::STOP,
                                   "m|monitor" =&gt; \$::MONITOR,
                              )
      )
    {
           print "USAGE\n";
           exit 1;
    }
    
    if ($::START)
    {
       # DB2 HADR failover
       my $cmd = "/usr/bin/su - xcatdb \"-c db2pd -d xcatdb -hadr\"";
       my $output = &runcmd($cmd);
       `logger -t xcat "rc = $::RC, output = $output\n\n\n\n"`;
       if ($::RC || ($output =~ /not activated/))
       {
           $cmd = "/usr/bin/su - xcatdb \"-c db2 START HADR ON DATABASE XCATDB AS STANDBY\"";
           $output = &runcmd($cmd);
    
           $cmd = "/usr/bin/su - xcatdb \"-c db2pd -d xcatdb -hadr\"";
           $output = &runcmd($cmd);
       }
       if (!$::RC && ($output =~ /LogGapRunAvg\s+\(bytes\)\nStandby\s+/))
       {
           $cmd = "/usr/bin/su - xcatdb \"-c db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster\"";
           $output = &runcmd($cmd);
           `logger -t xcat "takeover rc is $::RC"`;
           `logger -t xcat "takeover output is $output"`;
           if ($::RC || ($output =~ /cannot complete/))
           {
               $cmd = "/usr/bin/su - xcatdb \"-c db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster BY FORCE\"";
               &runcmd($cmd);
           }
       }
    
       # Setup site table
       $cmd = "XCATBYPASS=1 /opt/xcat/bin/chdef -t site master=9.114.47.97";
       &runcmd($cmd);
    
       # Start xcatd
       $cmd = "/usr/bin/startsrc -s xcatd";
       &runcmd($cmd);
       exit 0;
    }
    elsif ($::STOP)
    {
       my $cmd = "/usr/bin/stopsrc -s xcatd";
       &runcmd($cmd);
       exit 0;
    }
    elsif ($::MONITOR)
    {
       my $output = `/usr/bin/lssrc -s xcatd`;
       if ($output =~ /active/)
       {
          exit 1;
       }
       else
       {
          exit 2;
       }
    }
    
    
    sub runcmd()
    {
       my ($cmd) = @_;
    
    
       my $out = `$cmd 2&gt;&1`;
       $::RC = $?;
       if ($::RC)
       {
           `/usr/bin/logger -t xcat "samxcatd command $cmd failed, output is $out"`;
       }
       else
       {
           `/usr/bin/logger -t xcat "samxcatd command $cmd succeed"`;
       }
    
       return $out;
    }
    
    aixmn1:/xcat/sam#
    

The "start" script will be run when the xcatd is started or failovered to any management node, the "stop" script will be run when the xcatd is stopped or failed on any management node. The "monitor" script will be run periodically to check the xcatd status. The "stop" and "monitor" script is quite easy in this example, it simply run a command to check the xcatd status or stop xcatd. The "start" script is a little bit complex, because it has to handle the DB2 HADR failover and setup the master attribute in site table to the service ip address before trying to start xcatd. You can add any operations before the xcatd is started or stopped, but please be aware that it will cause the failover process to be longer, for example, you can add the xcat commands makedns, makedhcp or makeconservercf in the "start" script. 

The command mkrsrc can be used to create the xcatd application resource: 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 /usr/bin/mkrsrc -f /xcat/sam/xcatd.def IBM.Application
    

## Create Service IP Resource

The xcatd should be addressable with the same IP address, regardless of which management node it runs on. The IP address is called a "Service IP", the serivce IP will be configured as an alias IP address on the management node that the xcatd runs on, the service IP address can be any unused ip address that all the compute nodes and service nodes could reach. In this example, the service IP address is 9.114.47.97, netmask is 255.255.255.192, it can be configured on aixmn1 and aixmn2, the following command will create the service IP resource: 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 mkrsrc IBM.ServiceIP NodeNameList="{'aixmn1','aixmn2'}" Name="xcatip" NetMask=255.255.255.192 IPAddress=9.114.47.97
    

Besides the IP address and subnet, we should also specify the network adapters in the peer domain that could host the service IP address, which is called an equivalency. For example, the en0 on aixmn1 and en1 on aixmn2 can carry the service IP, then the command will be: 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 mkequ netequ IBM.NetworkInterface:en0:aixmn1,en1:aixmn2
    

## Create Resource Group

TSA resources needs to be grouped together before defining relationships between the resources, after the resource group is created, operations can be performed against all the resources in the resource group as a single unit. The resource group is created with the mkrg command. 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 mkrg xcatdrg
    

Both resources "xcatd" and "xcatip", will be added to the resource group "xcatdrg". This is done with the addrgmbr command. 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 addrgmbr -g xcatdrg IBM.Application:xcatd
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 addrgmbr -g xcatdrg IBM.ServiceIP:xcatip
    

## Define Relationship Between the Resources

The resources "xcatd", "xcatip" and "netequ" can not be treated separately, there are some kind of relationships between them. For example, it does not make sense if the xcatd is started on one management node and the service IP is configured on another management node node. We need to define two relationships between "xcatd", "xcatip" and "netequ": 

1\. "xcatd" depends on "xcatip", i.e., the resource "xcatd" and "xcatip" must be started on the same management node. 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 mkrel -p DependsOn -S IBM.Application:xcatd -G IBM.ServiceIP:xcatip xcatd_dependson_xcatip
    

2\. "xcatip" and "netequ" should be tied together, it means that the "xcatip" could only be configured on the network adapters defined in the resource "xcatip". 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 mkrel -p DependsOn -S IBM.ServiceIP:xcatip -G IBM.Equivalency:netequ xcatip_dependson_netequ
    

## Bring the Resource Group Online

When resources are added to resource groups, they become managed resources with a default automation goal of offline. This can be changed at the level of the resource group with the chrg command. To bring resource group xcatdrg online use the command: 
    
    aixmn1:/#CT_MANAGEMENT_SCOPE=2 chrg -o online xcatdrg
    

It may take a short while to take the resources and the resource group online, after the resources and the resource group are online, the lsrg command will display something like: 
    
    aixmn1:/#lsrg -m
    Displaying Member Resource information:
    Class:Resource:Node[ManagedResource] Mandatory MemberOf OpState WinSource Location
    IBM.ServiceIP:xcatip                 True      xcatdrg  Online  Nominal   aixmn1  
    IBM.Application:xcatd                True      xcatdrg  Online  Nominal   aixmn1  
    aixmn1:/#
    

After all the above configuration steps are done, we are ready to go... 

## Failover

There are two kinds of failover, planned failover and unplanned failover. The planned failover can be useful for updating the management nodes or any scheduled maintainance activities; the unplanned failover covers the unexpected hardware or software failures. 

1\. Planned failover 

Planned failover can be done by command rgreq runs on any management node, it will initialize a failover from the current primary management node to the standby management node: 
    
    CT_MANAGEMENT_SCOPE=2 rgreq -o move xcatdrg
    

2\. Unplanned failover 

Unplanned failover is done automatically by TSA. No user interaction is needed. 

No matter the failover is a planned failover or unplanned failover, you will see "Pending online" status, and after the failover is completed, the lsrg command will print something like: 
    
    aixmn1:/#lsrg -m
    Displaying Member Resource information:
    Class:Resource:Node[ManagedResource] Mandatory MemberOf OpState WinSource Location
    IBM.ServiceIP:xcatip                 True      xcatdrg  Online  Nominal   aixmn2  
    IBM.Application:xcatd                True      xcatdrg  Online  Nominal   aixmn2  
    aixmn1:/#
    

From the output above, we can see that the resources "xcatd" and "xcatip" have been moved to the standby management node aixmn2. And you can also check if the xcatd and service IP are running correctly on the new management node. 

## Some Useful TSA Commands

1\. Stop Peer Domain 
    
    CT_MANAGEMENT_SCOPE=2 chrg -o offline xcatdrg
    CT_MANAGEMENT_SCOPE=2 stoprpdomain xcathadomain
    

2\. Remove Peer Domain 
    
    CT_MANAGEMENT_SCOPE=2 rmrpdomain -f xcathadomain
    

3\. Remove Resource Group 
    
    CT_MANAGEMENT_SCOPE=2 /usr/bin/rmrgmbr  -g xcatdrg
    CT_MANAGEMENT_SCOPE=2 /usr/bin/rmrg xcatdrg
    

  


## References

  * IBM Redbook "High Availability and Disaster Recovery Options for DB2 on Linux UNIX and Windows" http://www.redbooks.ibm.com/abstracts/sg247363.html 
  * DB2 Information Center[http://www.redbooks.ibm.com/redbooks/.../sg247352.pdf](http://www.redbooks.ibm.com/redbooks/pdfs/sg247352.pdf)http://publib.boulder.ibm.com/infocenter/db2luw/v9r5/index.jsp?topic=/com.ibm.db2.luw.admin.ha.doc/doc/c0011748.html 
  * [Setup DB2 as the xCAT Database](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2SetupDB2.pdf)
  * Administrator's and User's Guide for System Automation for Multiplatforms Version 3.2 
  * Installation and Configuration Guide for System Automation for Multiplatforms Version 3.2 
  * IBM Redbook: End-to-end Automation with IBM Tivoli System Automation for Multiplatforms http://www.redbooks.ibm.com/abstracts/sg247117.html 
