<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Terminology](#terminology)
- [Overview](#overview)
  - [Hardware roles](#hardware-roles)
  - [Ethernet Network Switch](#ethernet-network-switch)
  - [EMS](#ems)
  - [HMCs](#hmcs)
  - [SN](#sn)
  - [IO node](#io-node)
- [Start-up Assumptions](#start-up-assumptions)
- [Dependencies](#dependencies)
- [Start-up Procedure](#start-up-procedure)
- [Optional - Power on Hardware](#optional---power-on-hardware)
- [Power on external disks attached to the EMS](#power-on-external-disks-attached-to-the-ems)
- [Power on the EMS and HMCs](#power-on-the-ems-and-hmcs)
- [Primary EMS start-up process](#primary-ems-start-up-process)
- [HMC verification](#hmc-verification)
- [Power on Frames](#power-on-frames)
- [Power on the CEC FSPs](#power-on-the-cec-fsps)
- [CEC power on to standby](#cec-power-on-to-standby)
- [CEC power on monitoring and verification](#cec-power-on-monitoring-and-verification)
- [Power on Service Nodes](#power-on-service-nodes)
- [Power on storage nodes](#power-on-storage-nodes)
- [Optional - Utility node startup](#optional---utility-node-startup)
- [Compute Node power on](#compute-node-power-on)
- [Start LoadLeveler](#start-loadleveler)
- [Verify P775 hardware stability](#verify-p775-hardware-stability)
- [Optional site specific steps](#optional-site-specific-steps)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

This cookbook will provide information about starting the xCAT HPC system **Power 775** hardware and software along with verification steps as the system is being started. **Everything described in this document is only supported in xCAT 2.6.6 and above.** If you have other system p hardware, see
[XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems] or [
[xCAT_System_p_Hardware_Management_for_DFM_Managed_Systems].

The commands shown in this document are for a Linux environment. All examples assume that the administrator has root authority on the EMS.

**This document is intended only as a post-installation start-up procedure. Initial installation and configuration is not addressed in this document.**

More information about the Power 775 related software can be found at:

  * https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+Overview
  * https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+-+Cluster+Guide

## Terminology

The following terms will be used in this document:

**xCAT DFM**: Direct FSP Management is the name that we will use to describe the ability for xCAT software to communicate directly to the System p server's service processor without the use of the HMC for management.

**Frame node**: A node with hwtype set to _frame_ represents a high end System P server 24 inch frame.

**CEC node**: A node with attribute hwtype set to _cec_ which represents a System P CEC (i.e. one physical server).

**BPA node**: is node with a hwtype set to _bpa_ and it represents one port on one bpa (each BPA has two ports). For xCAT's purposes, the BPA is the service processor that controls the frame. The relationship between Frame node and BPA node from system admin's perspective is that the admin should always use the Frame node definition for the xCAT hardware control commands and xCAT will figure out which BPA nodes and their ip addresses to use for hardware service processor connections.

**FSP node**: FSP node is a node with the hwtype set to _fsp_ and represents one port on the FSP. In one CEC with redundant FSPs, there will be two FSPs and each FSP has two ports. There will be four FSP nodes defined by xCAT per server with redundant FSPs. Similar to the relationship between Frame node and BPA node, system admins will always use the CEC node for the hardware control commands. xCAT will automatically use the four FSP node definitions and their attributes for hardware connections.

**Service node**: This is an LPAR which assists in the hierarchical management of xCAT by exending the capabilities of the EMS. SN have a full disk image and are used to serve the diskless OS images for the nodes that it manages.

**IO node**: This is an LPAR which has attached disk storage and provides access to the disk for applications. In 775 clusters the IO node will be running GPFS and will be managing the attached storage as part of the GPFS storage.

**Compute node**: This is a node which is used for customer applications. Compute nodes in a 775 cluster have no local disks or ethernet adapters. They are diskless nodes.

**Utility node**: This is a general term which refers to a non-compute node/LPAR and a non-IO node/LPAR. Examples of LPARs in a Utility node are the Service Node, Login Node, and local customer nodes for backup of data, or other site-specific functions.

**Login node**: This is an LPAR defined to allow the users to login and submit the jobs in the cluster. The login node will most likely have an ethernet adapter connecting it to the customer VLAN for access.

## Overview

In a 775 cluster there are interrelationships and dependencies in the hardware and software architecture which require the startup to be performed in an orderly fashion. This document will explain these relationships and dependencies and describe in detail how to properly bring the system up to an HPC running state where users may login and start to submit jobs.

### Hardware roles

Each set of hardware has a designated role in the cluster. This section will describe each part of the hardware and its role.

### Ethernet Network Switch

The Ethernet switch hardware is key to any computer complex and provides the networking layer for IP communication. In 775 cluster, the switch hardware is used to support the Cluster Management LAN which is used by xCAT for OS distribution from the EMS to SN as well as administrations from the EMS to the SN. This hardware is also used to support the Cluster Service LAN which connects the EMSs, SNs, HMCs, FSPs, and BPAs together to provide access to the service processors within each Frame nad

To begin understanding of the flow of the start-up process lets first distinguish the different hardware responsibilities in the order in which each set of hardware becomes involved in the bring up process.

### EMS

The xCAT Executive management Server is the central point of control for administration of the cluster. The EMS contains the xCAT DB as well as the Central Network Manager and its DB, and TEAL and its DB.

### HMCs

The HMCs are used for Service Focal Point and Repair and Verify procedures. During the initial installation and configuration the HMCs were assigned the frames and CECs which they will monitor for any hardware failures.

### SN

The Service nodes will be an LPAR within a building block which consists of a full disk image and will serve the diskless OS images for the nodes which it manages. All diskless nodes will require that the SN supporting them is up and running prior to being able to successfully boot. Some administrative operations in xCAT issued on the EMS are pushed out to the SN to perform the operations in a hierarchical manner which is needed for system administration performance.

### IO node

The IO node is the LPAR with attached storage. It contains the GPFS software which manages the global filesystem for the cluster. All compute nodes are dependent on the IO nodes to be operational before they can mount the global filesystem.

## Start-up Assumptions

There are some areas which are outside of the scope of this process. In order to draw a boundary on what hardware is part of the start up process and what is considered a prerequisite we will list some assumptions. It is assumed that the site has power and that everything is in place to begin the start up process. This would include the site cooling is up and operational and all power to the devices(switch, EMS, HMC, frames, etc) is ready to be applied.

The network switch hardware is a gray area in this process as some network switch hardware is part of the HPC cluster and others may be outside the cluster. For this discussion, we will make the assumption that all network switches that are customer site specific and not HPC cluster specific are up and operational.

There are some manual tasks involved in this process which require a person to manually start equipment. There should be people available to perform these tasks and they should be very familiar with the power on controls needed for each task they are too perform. Examples include powering on the Ethernet network switches, shared disk for dual EMS, EMS, HMC, frames, etc. These are all manual tasks which will need to be performed by a person when its time to do that step.

This process also assumes that all initial cabling and configuration, both hardware and software, has been done prior to this process and that the entire system has gone through booting and testing to eliminate any hardware or software problems prior to performing this procedure.

## Dependencies

As the cluster is started, it is critical that hardware or software dependencies are up and operational prior to the successful completion of a hardware or software item which has the dependency. Lets take a high level view of the dependencies to help outline the flow of the startup process. This section is intended to give a rough idea of dependencies and it will not go into any detail as to how to accomplish the task or verify its completion.

Ethernet Switches - At the top of the dependencies is the HPC cluster ethernet switch hardware as well as any customer ethernet switch hardware. These will be the first items that need to be started.

EMS and HMCs - The next level of dependency is the EMS and HMCs. These can both be started at the same time once the network switches have been started.

Frames - Once the EMS and HMCs are started then we can begin to start the 775 hardware by powering on all of the frames. The frames are dependent on both the Switches and the EMS in order to come up properly.

CECs - Once the frame is powered on the CECs can be powered on. The CECs depend on the switches, EMS, and frames. Applying power to the CECs brings up the HFI network hardware, which is critical to distributing the operating system to diskless nodes, as well as for application communication.

SN - The SN can be started once the CECs are powered on and is dependent on the switches, EMS, frame, CEC.

IO node - The IO node can be started once the SN is operational. The IO node is dependent on the switches, EMS, frame, CEC, and SN.

Compute nodes - Last in the list is the starting of the compute nodes. The compute nodes can be done once the SN and IO nodes are up and operational. The login and compute node require the SN to be operational for the OS images loading. Compute nodes depend on Ethernet switches, EMS, frame, CEC, SN, and IO nodes.

Once the compute nodes have started it is the end of the hardware start-up process and the admin can begin to evaluate the HPC cluster state by checking the various components of the cluster. Once the HPC stack has been verified the cluster start-up is complete.

There may be other node types that each customer define to meet their own specific needs. Some examples are nodes responsible for areas like login, data backup, etc. These nodes should be brought up last to allow the rest of the cluster to be up and running. Since these nodes are outside the HPC cluster support and software and the nature of their start-up is an unknown factor they are outside the scope of this document and not part of any timing of the cluster start-up process.

## Start-up Procedure

This section will document the start-up procedure. Each section below will discuss the prerequisites, the process for this step, and the verification for completion. As we mentioned previously there are some assumptions on the current site state which must be met prior to starting this process; these include cooling and power and initial configuration and verification of the cluster performed during installation.

Before we begin with the start-up procedure, we should discuss the benefit of using xCAT group names. xCAT supports the use of group names and which allow the grouping of devices/nodes in a logical fashion to support a given types of nodes. We recommend that the following node groups be in place prior to performing this procedure: frame, cec, bpa, fsp, service, storage, and compute. Other node groups may be used to serve site specific purposes.

Creating node groups will significantly enhance the capability to start a given group of nodes at the same time. Without these definitions, an administrator would have to issue many separate commands when a single command could be used.

It is also key to manage any node failures in the start-up process and continue when possible. There may be an issue with some part of the cluster starting up which does not affect other parts of the cluster. When this occurs you should continue with the boot process for all areas that are successful while retrying or diagnosing the section with the failure. This will allow the rest of the cluster to continue to start which will be more efficient than holding up the entire cluster start-up. Notes on specific areas where this could happen and how to address failures will be added where appropriate. It is not possible to identify every possible error and documenting all failures and concerns would make this document very difficult to read. We will focus these types of notes on the most critical areas or areas where it may be more common to see an issue during start-up.

## Optional - Power on Hardware

During the cluster shutdown process there is an optional tasks for disconnecting power. If you turned off breakers or disconnected power to the management rack or the 775 frames during the cluster shutdown process, then you need to continue with this step of connecting power.

If you have not turned off any breakers or disconnected power previously then you do not need to perform this step.

Turn on breakers or connect power to the management rack.

Turn on breakers or connect power to the 775 frames.

## Power on external disks attached to the EMS

Power-on any external disks used for dual-EMS support. This is required prior to starting the primary EMS.

## Power on the EMS and HMCs

Once the EMS shared disk drives are up, it is time to power on the primary EMS and the HMCs.

The backup EMS will be started after the cold start is complete and the cluster is operational. It is not needed for the cluster start-up and spending time to start it would take away from the limited time for the entire cluster start-up process.

Starting the primary EMS and the HMCs is a manual steps which require the administrator to push the power button on each of these systems in order to start the boot process. They can be started at the same time as they do not have a dependency on each other.

## Primary EMS start-up process

The admin will need to execute multiple tasks working with the primary xCAT EMS. Makes sure that all local and external attached disks have been started and are available to the xCAT EMS.

Note: Do not start up the backup EMS or perform any steps on a back-up EMS at this time. The backup EMS should be started after the P775 Cluster start-up process has completed working with the primary xCAT EMS.

The admin should have a EMS console attached so they can monitor the boot process and await a login prompt. Once the OS has completed booting the administrator can login as root, and begin to execute commands and validate the state of xCAT EMS.

Optional Alias - If you are using aliases to allow for more transparent IP takeover then setup the alias now. Note: The IP addresses and netmasks are examples and should be change to the ones used on your EMS.

~~~~
    $ ifconfig eth4:0 10.1.0.3 netmask 255.255.0.0
    $ ifconfig eth6:0 10.2.0.3 netmask 255.255.0.0
~~~~

The admin should make sure all the files systems are mounted properly including file systems on external shared disks. The expectation is that some directory names below may vary depending on the site.

~~~~
    $ mount /dev/sdc1 /etc/xcat
    $ mount /dev/sdc2 /install
    $ mount /dev/sdc3 ~/.xcat
    $ mount /dev/sdc4 /databaseloc</pre>
~~~~


The admin should make sure that DB2 environment is enabled on the xCAT EMS . This includes validating the DB2 Monitoring daemon is running, and that the xCAT DB instance is setup.

~~~~
    $ /opt/ibm/db2/V9.7/bin/db2fmcd &    (this will startup DB2 daemon)
~~~~


DB2 commands to start the xcatdb instance:

~~~~
    $ su - xcatdb
    $ db2start
~~~~


Verify database is running

~~~~
    $ db2 connect to xcatdb  ( will be prompted for xcatdb password)
~~~~


Then return to root

~~~~
    $ exit
~~~~


The admin will check that multiple daemons (xcatd, dhcpd, hdwr_svr, cnmd, teal) are properly started on the xCAT EMS. For the xCAT Linux EMS will will execute the Linux "service" command with start attribute to start each of the daemons.

~~~~
    $ service xcatd start     (start xCAT daemon)
~~~~


Wait a few minutes and then run:

~~~~
    $ tabdump site      (to make sure xcatd is running on DB2)
    $ lsxcatd -d         ( will also show you are runing on DB2)
~~~~


Then Start the other daemons:

~~~~
    $ service dhcpd start     (start dhcpd daemon)
    $ service hdwr_svr start  (start hdwr_svr daemon)
    $ service teal start      (start teal daemon)
    $ service cnmd start      (start cnmd daemon)
    $ service conserver start      (start conserver daemon)
~~~~


The admin can use the "ps -ef | grep xxx " command to validate that the daemons are running after they are started. The admin can also verify that the daemons are running using the Linux service command working with status attribute.

~~~~
    $ lsxcatd -a              (verify xCAT deamon is runnnig and can access xCAT database)
    $ service dhcpd status    (verify  dhcpd is running)
    $ service conserver status (verify conserver  is running)
    $ service hdwr_svr status  (verify hardware server is running)
    $ service cnmd status      (verify cnmd is running)
    $ service teal status      (verify teal.py  pid 24189 is running)
~~~~


## HMC verification

Using xCAT EMS verify that each HMC is up and running.

~~~~
    $ xdsh <hmc hostname> -l hscroot date
~~~~

## Power on Frames

The powering on of the frame is a manual process which requires the administrator to walk around and **turn on the frame red EPO switch** on the front of the frame. This will apply power to just the frame's bulk power unit. The frame BPAs take about 3 minutes to boot once power is applied, and the BPAs will stop at a "rack standby" state.

The admin can execute hardware discovery command "lsslp -m -s FRAME" to keep track of all the Frame BPA IPs. The admin executes command "lshwconn frame" to make sure there are hardware connections between xCAT EMS and Frame BPAs . The admin executes the "rpower frame state" to make sure the frame status is set as "Both BPAs at rack standby".

  * Issue the following commands to verify that the frame BPAs are properly set in the rack standby state.

~~~~
    $ lsslp -m -s FRAME
    $ lshwconn frame
    $ rpower frame state
~~~~


## Power on the CEC FSPs

**This step can take from 10 to 15 minutes for the BPAs and FSPs to finish stating.**

To apply power to all of the CEC FSPs for each frame, we will need to exit rack standby mode by issuing the command "rpower frame exit_rackstandby". This execution to exit rack standby will take approximately 5 minutes for the frame BPAs to be placed in the "standby" state. The admin executes the "rpower frame state" to make sure the frame status is set as "Both BPAs at standby". The admin may want to check the frame environmental status using the "rvitals frame all" command

  * Issue the following commands to verify that the frame BPAs are properly set in the standby state.

~~~~
    $ rpower frame exit_rackstandby
~~~~


Wait for 5 minutes for BPAs to start

~~~~
    $ rpower frame state

    $ rvitals frame all
~~~~


As part of the exit rack standby, each frame BPA applies power to all the FSPs in its frame which will then cause the CEC FSPs to IPL. The expectation is that it may take as much as 10 minutes for all the CEC FSPs to be enabled in the Frame after exiting rack standby. The admin can execute hardware discovery command "lsslp -m -s CEC" to keep track of all the CEC FSP IPs. The admin executes command "lshwconn frame" to make sure there are hardware connections between xCAT EMS and CEC FSPs. The admin executes the "rpower cec state" to make sure the CECs are placed in a "power off" state.

  * Issue the following command to verify that the CEC FSPs have IPLed and are in a "power off" state .

~~~~
    $ lsslp -m -s CEC
    $ lshwconn cec
    $ rpower cec state
~~~~


Once the IPL of the CEC FSPs is complete they will be in a "power off" state.

The admin also needs to validate that CNM has proper access to the CEC FSPs and Frame BPAs from the xCAT EMS. Verify that there are proper Hardware Server connections by issuing the lshwconn command using the "fnm" tool type. Make sure that every Frame BPA and CEC FSP is listed in the command output. Note: If you have a dual cluster service VLAN then you may see errors from the second VLAN.

~~~~
    $ lshwconn frame -T fnm
    $ lshwconn cec .T fnm
~~~~


Another CNM activity is to make sure the HFI master ISR identifier is properly loaded on the CEC FSPs. This is accomplished using CNM commands "lsnwloc" and "lsnwcomponents" to show the CNM HFI drawer status information.

~~~~
    $ lsnwloc
    $ lsnwcomponents
~~~~


## CEC power on to standby

Once the Frames BPAs and the CECs FSPs are booted we can bring the CEC to onstandby state. This will power on the CECs, but will not autostart the power on of the lpars. This is required since we need to coordinate the power on of selected xCAT service nodes, and GPFS I/O server nodes prior to the power on the compute nodes. To power on the CECs to onstandby state issue:

~~~~
    $ rpower cec onstandby
~~~~

## CEC power on monitoring and verification

**The CEC power on is one of the largest time consuming steps in the start-up process because each CEC is performing all of the hardware verification of the server during this process. The current timings that we have seen is that it will take about 45-70 minutes for the CEC to be available **

There are multiple tasks that can be monitored by the administrator at this time. This includes checking the CEC LCDs using the "rvitals" command, and tracking the CEC status with the "rpower" command. It is also a good time for the admin to validate the CNM ISR network environment with CNM commands lsnwloc and lsnwcomponents during the power on of CECs.

The CEC IPL process can be monitored by using the xCAT rvitals and rpower commands.

~~~~
    $ rvitals cec lcds
    $ rpower cec state
~~~~


While the CECs are powering on verify CNM can manage the ISR network with following CNM commands.

~~~~
    $ lsnwcomponents          (provides CEC drawer configuration information)
    $ lsnwloc | grep -v EXCLUDED | wc -l    (match the number of CEC drawers in the cluster)
    $ lsnwloc | grep EXCLUDED     (issues that cause a CEC drawer to be excluded by CNM)
~~~~


If any CEC drawers are excluded (STANDBY_CNM_EXCLUDED or RUNTIME_CNM_EXCLUDED), reference the "High Performance Clustering using the 9125-F2C Management Guide" https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+-+Cluster+Guide for more detail about CNM commands, implementation, and debug prior to powering the CECs on to standby.

## Power on Service Nodes

At this stage we have power on to the frame and all the CECs where we are ready to boot the xCAT service nodes (SN). The xCAT SNs are the first nodes to boot within the P775s since they supply the OS diskless images for the remaining nodes.

The admin can check to see if the service nodes are on:

~~~~
    $ rpower service on
~~~~

If they are not on the admin can execute rpower command using the service node group to power on all of the xCAT service nodes.

~~~~
    $ rpower service on
~~~~

The verification process for the Service Node includes validating OS boot, critical daemons and services started, as well as the proper communication to the xCAT EMS and other xCAT SNs. **The following are xCAT commands that are issued from the EMS** to all of the service nodes to same time. Note - This process is assuming that service node is already properly configured to not start GPFS and LL. GPFS is not available until the GPFS I/O storage nodes are booted after this step and the Loadleveler requires GPFS.

~~~~
    $ rpower service state   (verify the Service Node state indicates Success)
    $ nodestat service       (verify network communication to service nodes)
    $ xdsh service -v lsxcatd -a  (verify that xCAT daemon, xcatd, is running on the service nodes)
    $ xdsh service -v ping <service node1 hf0 IP> -c 5</pre> (verify HFI connectivity between the service nodes)
~~~~


It is important that the xCAT SN has the proper diskless installation environment to install the GPFS I/O storage nodes. We also should validate that the diskless images are also set for the login and compute nodes using the nodeset command.

  * Run nodeset on all diskless groups to prepare them for booting working with the xCAT SNs.

~~~~
    $ nodeset storage osimage=redhat6storageimg   (setup install/boot for storage nodes)
    $ nodeset compute osimage=redhat6computeimg   (setup install/boot for compute nodes)
    $ nodeset login osimage=redhat6loginimg       (setup install/boot for login nodes)
~~~~


Note: the osimage name should be the image name that you are using for that node type.

## Power on storage nodes

The disk enclosures received power when the frame in which they are enclosed exited rack_standby mode. This will power up the disk enclosures so they will be operational when the GPFS storage nodes to which they are attached are started.

At this point the frames, CECs, and xCAT SN are powered up and are now active. We have also validated that the xCAT SN has properly enabled the CNM HFI network, and that diskless installation environment has been setup. The admin can now boot the GPFS I/O storage nodes, and begin to configure GPFS on each of storage nodes using the rpower command working with the storage node group.

~~~~
    $ rpower storage on
~~~~


To verify the storage node OS has booted up properly, the admin can check to see if the required services are active. This includes checking the status of the service nodes using the rpower command.

~~~~
    $ rpower storage state        (verify the storage node state is Succesfull)
~~~~


Note: Due to the significant number of disk drives there can be a delay in the total time it takes for a storage node OS to complete the boot process.

The admin will need to reference the GPFS documentation to properly validate that the disks are properly configured. http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=/com.ibm.cluster.gpfs.doc/gpfsbooks.html. Once the GPFS storage nodes OS has completed the boot, and the disks are configured, we can start GPFS on each storage node. Here are the GPFS commands that the admin should execute from the xCAT EMS.

~~~~
    $ xdsh storage -v mmstartup                 (startup GPFS environment on storage nodes)
    $ xdsh storage -v mmgetstate                (verify that GPFS is running and operational)
~~~~


Optional - Check the status of the disks

~~~~
    $ xdsh storage -v mmlsdisk all --not -ok        (list all disks on storage nodes which are not "ok")
    $ xdsh storage -v mmlspdisk all --not -ok       (list all physical disks which are not "ok" on storage nodes)
~~~~


## Optional - Utility node startup

As was discussed in the overview, many sites will include additional utility node types like login nodes or nodes responsible for backup. Once the xCAT service nodes have been setup the diskless environment, and the GPFS I/O storage nodes are configured, the admin can power up any site specific utility nodes. The admin can execute the rpower command working with the "login" node group.

~~~~
    $ rpower login on
    $ rpower login stat   (verify that the login node state is Succesful)
~~~~


The admin may want to execute other commands to the utility login nodes to makes sure the application environment is setup.

## Compute Node power on

At this point all critical parts of the P775 cluster infrastructure are operational. This includes all the frames, CECs, and diisk enclosures are powered up and running. The admin should make sure the xCAT SN has setup the diskless installation environment for the compute nodes, and that GPFS has properly been enabled on the storage and the xCAT SN. The admin can now boot up and start all the compute nodes using the rpower command working with the compute node group.

~~~~
    $ rpower compute on
~~~~


Note: This can be a resource intensive task on the service nodes and the network while all of the compute nodes are booting. Care needs to be taken to verify the successful boot of all of the service nodes. The admin may want to boot up the compute nodes working with a smaller number of compute nodes by setting up different types of node groups.

To verify that all the compute nodes successfully power on you need to validate that the OS booted properly and check to see if GPFS is available on all compute nodes. The compute nodes are typically more numerous and there are suggestions below on how to get a summary of the different states to simplify the viewing of the this large a set of nodes. The following are some xCAT commands that can be executed from the xCAT EMS to track the status of the compute nodes.

~~~~
    $ rpower cec state | xcoll                  (list the return status of the compute nodes based on return value)
    $ rpower compute state | grep -ic running   (list the running compute nodes)
    $ xdsh compute -v ls -l /gpfs/some/dir      (check connectivity and that a valid GPFS filesystem is mounted)

~~~~

## Start LoadLeveler

This section will enable the LoadLeveler configuration on the P775 cluster. This requires that the xCAT service nodes, login nodes, and most of compute nodes are up and running. The admin will want to make sure that GPFS has been configured on the P775 cluster since LoadLeveler requires GPFS as part of it's start up. The LoadLeveler configuration must first be started on xCAT service nodes, and then setup on the compute nodes. Please reference LoadLeveler documentation to gain more knowledge and detail about the LoadL commands and procedures. [Tivoli Workload Scheduler LoadLeveler library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html) Here are the xCAT and LoadL based commands that can be executed from the xCAT EMS.

~~~~
    $ xdsh service -l loadl llctl start     (Start LoadLeveler on service nodes)
~~~~


To monitor the status of the LoadLeveler issue llstatus to one of the service nodes. in this example a service node called f01sv01 is being used:

~~~~
    $ xdsh f01sv01 llstatus    (Verify that LoadLeveler is up on the service nodes)
~~~~


It is very important that LoadLeveler is started and running on the service nodes prior to starting LoadLeveler on the compute nodes. Once this is verified start LoadLeveler on the compute nodes.

~~~~
    $ xdsh compute -l loadl llrctl start    (Start LoadLeveler on compute nodes)
~~~~


To monitor the LoadLeveler status after starting it on the compute nodes issue llstatus to one of the service nodes. in this example a service node called f01sv01 is being used:

    $ xdsh f01sv01 llstatus    (Verify that LoadLeveler is up on the everywhere)


## Verify P775 hardware stability

The admin may want to check that the P775 cluster is working properly. There is the xCAT command "rinv &lt;node&gt; deconfig" that can check if there is any P775 resources that have been deconfigured during the boot up.

~~~~
    $ rinv cec deconfig    (verify P775 hardware has not been garded before the startup)
~~~~


The Toolkit for Event Analysis and Logging (TEAL) product will monitor events and log failures using the Service Focal Point (SFP) through the HMC, and Integrated Switch Network Manager (ISNM) on the xCAT EMS with TEAL listeners. It will log all hardware failures and events in TEAL tables that are located in the xCAT data base on the xCAT EMS. The xCAT administrator can use TEAL commands to reference the different events and alerts found in the P775 cluster. The admin should reference the TEAL and the ISNM documentation that is provided in the "High Performance clustering using the 9125-F2C" Cluster guide for more information.

The admin can work with TEAL environment to check if there are any P775 hardware and CNM events or alerts. If TEAL is configured for monitoring, check TEAL for any alerts that came in since the start-up. If there are any new alerts, details can be obtained using the "-f text" parameter.

~~~~
    $ tllsalert -q "creation_time>2011-09-26-20:00:00" | more       (assuming the Teal  startup began on 9/26/2011 at 20:00:00)
~~~~


## Optional site specific steps

Each site may have some specific additional step which is needed prior to the cluster being fully operational. This is when those steps can be taken.

Below is an example of a step that could be needed for a site using ypbind.

Since ypbind may be managed on the login node and there could be an interdendence between the login node and the service node which requires the ypbind to be restarted on the service node to be fully operational.

~~~~
    $ xdsh service service ypbind restart
~~~~

Optionally restart NTP daemon:

    $ xdsh compute,login,storage service ntpd restart

If your site is using NFS mounted file systems on the login nodes.

~~~~
    $ xdsh login service autofs stop

    $ xdsh login service autofs start
~~~~


