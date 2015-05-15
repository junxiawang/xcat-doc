<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [P775 Cluster Overview](#p775-cluster-overview)
- [IBM Power 775 Availability Plus (P775A+, FIP)](#ibm-power-775-availability-plus-p775a-fip)
  - [P775 Octant Failures](#p775-octant-failures)
  - [Recovery Commands and Tasks](#recovery-commands-and-tasks)
  - [P775A+ (FIP) xCAT Administrator Scenarios](#p775a-fip-xcat-administrator-scenarios)
  - [P775A+ (FIP) Compute Node Implementation](#p775a-fip-compute-node-implementation)
    - [P775A+ Hot Swap Compute Node Scenario](#p775a-hot-swap-compute-node-scenario)
    - [P775A+ Warm Swap Compute Node Scenario](#p775a-warm-swap-compute-node-scenario)
    - [P775A+ Cold Swap Compute Node Scenario](#p775a-cold-swap-compute-node-scenario)
  - [P775A+ (FIP) Login Node Implementation](#p775a-fip-login-node-implementation)
    - [Login node Replace Ethernet/HFI Scenario](#login-node-replace-ethernethfi-scenario)
  - [P775A+ (FIP) xCAT Service Node Implementation](#p775a-fip-xcat-service-node-implementation)
    - [xCAT Service Node Ethernet/HFI scenario in same CEC](#xcat-service-node-ethernethfi-scenario-in-same-cec)
    - [xCAT Service Node Disk Replacement scenario on a Different CEC](#xcat-service-node-disk-replacement-scenario-on-a-different-cec)
  - [P775A+ GPFS I/O Node Implementation](#p775a-gpfs-io-node-implementation)
    - [GPFS I/O Node Replacement scenario in the same CEC](#gpfs-io-node-replacement-scenario-in-the-same-cec)
    - [GPFS I/O Node replacement scenario on a different CEC](#gpfs-io-node-replacement-scenario-on-a-different-cec)
  - [Updating and Recovery of BPA/FSP Firmware](#updating-and-recovery-of-bpafsp-firmware)
    - [BPC and GFW Update Scenario](#bpc-and-gfw-update-scenario)
    - [BPC and GFW Recovery Scenario](#bpc-and-gfw-recovery-scenario)
  - [Replace hdisk configuration for GPFS nodes](#replace-hdisk-configuration-for-gpfs-nodes)
- [Hardware Service Support Activities](#hardware-service-support-activities)
- [Preparation Procedures](#preparation-procedures)
  - [CEC Down Preparation](#cec-down-preparation)
  - [Compromised SuperNode Preparation](#compromised-supernode-preparation)
  - [Frame Down Preparation ( Non Concurrency )](#frame-down-preparation--non-concurrency-)
  - [Frame Down Preparation ( Concurrency )](#frame-down-preparation--concurrency-)
  - [Frame Low Power Preparation](#frame-low-power-preparation)
  - [Filesystem Down Preparation](#filesystem-down-preparation)
  - [PCI Resource Preparation](#pci-resource-preparation)
  - [Compute Node Preparation](#compute-node-preparation)
  - [Service Node Preparation](#service-node-preparation)
  - [Storage Node Preparation](#storage-node-preparation)
  - [Login Node Preparation](#login-node-preparation)
  - [Other Node Preparation](#other-node-preparation)
  - [Verify backup DE STOR connectivity is available](#verify-backup-de-stor-connectivity-is-available)
- [Recovery Procedures](#recovery-procedures)
  - [Recover from A+ QCM failure](#recover-from-a-qcm-failure)
    - [Compute Node Scenario](#compute-node-scenario)
    - [Login node scenario](#login-node-scenario)
    - [Service node scenario](#service-node-scenario)
    - [GPFS I/O node scenario](#gpfs-io-node-scenario)
  - [Recover from A+ HFI Hub failure](#recover-from-a-hfi-hub-failure)
    - [Compute node scenario](#compute-node-scenario)
    - [Login node scenario](#login-node-scenario-1)
    - [Service node scenario](#service-node-scenario-1)
    - [GPFS I/O node scenario](#gpfs-io-node-scenario-1)
  - [Frame Down Recovery Procedure ( Non Concurrency )](#frame-down-recovery-procedure--non-concurrency-)
  - [BPA Down Recovery Procedure](#bpa-down-recovery-procedure)
  - [Frame Low Power Recovery Procedure](#frame-low-power-recovery-procedure)
  - [CEC Recovery Procedure](#cec-recovery-procedure)
  - [PCI Resource Recovery](#pci-resource-recovery)
  - [Compute Node Recovery Procedure](#compute-node-recovery-procedure)
  - [Service Node Recovery Procedure](#service-node-recovery-procedure)
  - [Storage Node Recovery Procedure](#storage-node-recovery-procedure)
  - [Login Node Recovery Procedure](#login-node-recovery-procedure)
  - [Other Node Type Recovery Procedure](#other-node-type-recovery-procedure)
  - [Swapping node images](#swapping-node-images)
  - [VPD card replacement recovery procedure](#vpd-card-replacement-recovery-procedure)
  - [System VPD Recovery procedure](#system-vpd-recovery-procedure)
  - [Verifying Processor Speeds](#verifying-processor-speeds)
  - [Verify D-link Repair](#verify-d-link-repair)
  - [Verify LR-link Repair](#verify-lr-link-repair)
  - [Check for hardware problems](#check-for-hardware-problems)
  - [Verify File System](#verify-file-system)
  - [Verify Disk Enclosure](#verify-disk-enclosure)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This xCAT section provides information about xCAT cluster recovery. It will introduce xCAT commands and procedures that will be used by the xCAT admin to manage the cluster for serviceability. The initial work for this document will focus on our xCAT support for P775 cluster, but we will include recovery scenarios for other xCAT clusters in the future.

### P775 Cluster Overview

The P775 cluster has a unique cluster service support environment that requires special setup and recovery. We advise that the xCAT administrator to reference "High Performance clustering using the 9125-F2C" Cluster guide to gain more detail about the P775 hardware and service capabilities. This section will introduce xCAT information about P775 Fail In Place (FIP) support. It also provide a sections about different serviceability scenarios that the xCAT administrator may perform when trying to recover from hardware failures.

There is a separate P775 HW/SW Hardware Service Procedures document which is being used to track various service recovery procedures that will be executed on the P775 cluster. This document will be used by the IBM Service teams to walk through the proper recovery procedures by Hardware teams. Some of these activities will require some execution by the xCAT administrator. We will try and provide step by step procedures for some of the critical xCAT administrator work activities related to hardware recovery.

## IBM Power 775 Availability Plus (P775A+, FIP)

The IBM Power 775 Availability Plus (P775A+) also known as "Fail In Place" (FIP) is a policy with P775 hardware that allows to keep selected failed hardware resources in place on the overall P775 cluster for the duration of the maintenance contract in a given customer deployment. In a large cluster, when a hardware failure occurs in the system, a recovery action of some type takes place to allow the system to continue to function without the failing hardware. The principle behind P775A+ is for key components, or resources, to provide spares at the time of deployment of a cluster rather obtaining replacement parts for each instance of failure. As resources fail, spare will be consumed and the failed resources will not be repaired until absolutely necessary. The intention is to provide enough spares at time of deployment to never have to repair these key components.

The Toolkit for Event Analysis and Logging (TEAL) product will monitor events and log failures using the Service Focal Point (SFP) through the HMC, and Integrated Switch Network Manager (ISNM) on the xCAT EMS with TEAL listeners. It will log all hardware failures and events in TEAL tables that are located in the xCAT data base on the xCAT EMS. The xCAT administrator can use TEAL commands to reference the different events and alerts found in the P775 cluster. The admin should reference the TEAL and the ISNM documentation that is provided in the "High Performance clustering using the 9125-F2C" Cluster guide for more information.

The Product Engineer (PE) is the IBM Hardware Service representative for the P775 cluster, and there is the IBM service support team (SWAT) that will help evaluate whether the current P775A+ information has reached the P775 cluster threshold. They will analyze hardware failures and the current status for the P775 Frame, CECs, and Octants. They will work with the P775 customer,and xCAT administrator to provide the proper service plan to replace or move P775 CEC and Octant P775A+ resources.

Note: There was a P775 product naming change from P775 Fail In Place (FIP) to IBM Power 775 Availability Plus (P775A+) very late in the release schedule, so you may see P775A+ referenced as FIP iterated through this document.

### P775 Octant Failures

The P775A+ environment is specified as the FIP Swap policy as hot, warm, and cold. The "hot" swap policy is where they can use the extra nodes as part compute processing, which provides additional processing power for production or non production activities. The "warm" policy is specified where the P775A+ nodes are powered up and made available to the P775 cluster, but they are not used with any production work load. The "cold" swap policy is where the P775A+ node resources are physically powered down and are brought online when required. The xCAT administrator with help of IBM service will need to make a decision on how they want to enable the resources, where they may be able to allocate some P775A+ resources into all three swap policies. The xCAT admin needs to keep track of the P775A+ resources. It would be get to place these available octants in a xCAT node groups such as fip_available. then place any P775 failed octants in a FIP defective node group such as fip_defective.

The administrator needs to understand the type of P775 octant (node), and the type of failure found. There are different recovery procedures identified based on which P775 resource has failed, and the type of P775 octant is affected. The type of P775 octants are known as compute, login, xCAT Server Node (SN), and GPFS I/O Server nodes.

The P775 cluster is mostly populated with compute octants, where the LPARs are diskless and contain system resources for HFI, memory and CPUs. There are certain rules that xCAT administrator will follow to specify when the compute node octant should be considered as failed. For the compute node octant failures, the LoadLeveler (LoadL) product will check the state of the compute node failures, and will remove the failed nodes from the LoadL resource group. These failed octants will not scheduled any LoadL jobs to failed octants. The xCAT administrator will power off the failed LPAR node, and place the octant in FIP failed "fip_defective" node group.

The login node allows customers to have access into the P775 cluster. This login node contains HFI, memory, CPUs, but will also contain an ethernet I/O interface for the outside login capability. These login nodes are not listed in the LoadL resource compute group, but do have connectivity to LoadL to schedule and monitor LoadL jobs.

The xCAT Service Node (SN) nodes are very important in the P775 cluster, since they contain the most I/O resources. They are used to install and manage the diskless compute nodes, and they actively communicate back to the xCAT EMS. The xCAT SN node contains HFI, memory, CPUs, and most of the I/O resources (ethernet, disks) on the P775 CEC. Each xCAT SN should have a backup xCAT SN that can be used if there are software or hardware resource failures that make the xCAT SN unresponsive. The xCAT administrator will follow a xCAT SN failover procedure so the P775 compute nodes can continue to work from the xCAT SN backup node. The xCAT administrator needs to actively debug the xCAT SN failure, and try to get it working as soon as possible. If the xCAT SN has failures that make the octant be listed as P775A+ failed node, they will need to allocate the required I/O resources to a different FIP octant in the P775 cluster. We will provide selected xCAT SN fail over and FIP based procedures later in this document.

The GPFS I/O Server node is predominantly used to connect the Disk Extension Controller resources in the P775 cluster to a GPFS cluster. The P775 GPFS I/O Server node contains the HFI, memory, CPU, and selected SAS/FC I/O resources that provide connectivity to the Disk Extension drawers and GPFS storage. There are TEAL GPFS collectors that keep track of the disk I/O events provided by the GPFS subsystems.

For non compute octant failures with xCAT SN and GPFS I/O server nodes, the administrators may need to move PCI cards to a different P775 octant based on the type of octant failure. If the current P775 CEC does not contain a functional P775A+ octant in the same P775 CEC, the IBM PE service rep may need to move PCI cards to a P775A+ node in a different P775 CEC. This will require the xCAT administrator to logically swap the LPAR node of the failed octant to now take over the P775 octant location information of the FIP octant in the xCAT DB. The first attempt should be to swap a bad octant to a FIP octant in the same P775 CEC since the xCAT administrator only needs to power down one P775 CEC for its recovery. If that's not possible, and we need to use a different P775 CEC, the xCAT administrator will need to power down both P775 CECs as part of the recovery.

There are 2 phases of P775 Availability Plus (P775A+) support. The first phase requires the administrator to do most of the recovery operations using TEAL, LoadL, GPFS and xCAT commands working through step by step procedures. The second phase of P775 Availability Plus support in future P775 releases will provide more automatic recovery activities, based on P775 octant failures.

### Recovery Commands and Tasks

The xCAT administrator will execute commands for LoadL, Teal, GPFS, and xCAT. It is important the admin reference the man pages for each of the commands being used with FIP tasks. We have provided an overview of the xCAT commands that will be used with P775 recovery environment here.

  * [swapnodes](http://xcat.sourceforge.net/man1/swapnodes.1.html) \- swap the I/O and location information in the xCAT db between two nodes. This command will assign the IO adapters from the bad octant over to the specified good FIP octant, where the current LPAR node name is not changed. This would mean that any pertinent I/O assignments is still contained in the current node object, but the octant LPAR id, and possibly MTMS information is swapped. The failed octant is then listed as a bad FIP node and should not be referenced until it is repaired. The swapnodes command will make updates for the ppc and nodepos table attributes. It is very important that the PE rep communicates what the real physical octant location when I/O resources are moved to the new FIP location.
  * [chvm](http://xcat.sourceforge.net/man1/chvm.1.html)/[lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html) \- For Power 775, chvm is used to change the octant configuration values for the I/O slots assignment to LPARs within the same CEC. The administrator should use lsvm to get the profile content as a file, edit the content file, and node name with ":" manually before the I/O information which will be assigned to each node. The profile content can be piped into the chvm command, or modified with the chvm -p flag.
  * [rinv](http://xcat.sourceforge.net/man1/rinv.1.html) \- retrieves hardware configuration information for firmware and deconfigured resources from the Service Processor for P775 CECs. The administrator needs to check for any deconfigured resources (deconfig) for each P7 CEC node objects. The admin will use the rinv to check the current power code (BPA)and firmware FSP) levels and setings using the "firm" option.
  * [rvitals](http://xcat.sourceforge.net/man1/rvitals.1.html) \- retrieves hardware configuration and environmental information for Frame, CEC and LPARs from the Service Processor for P775 CECs. It provides rack status environmental data working with Frame. It provide the power status, system state, and LCD status when working with Frame, CEC, and LPARs.
  * gatherfip - script used by xCAT admin gather P775A+ (FIP) data and service events from TEAL. This script places service events for ISNM, SFP, and deconfigured resources to files and a tar package in /var/log directory which is sent to IBM service team.




Writing CNM Alerts in TEAL to  file /var/log/gatherfip.CNM.Events
Writing CNM Link Down information to /var/log/gatherfip.CNM.links.down
Writing deconfigred resource information to /var/log/gatherfip.guarded.resources
Writing Hardware service events information to /var/log/gatherfip.hardware.service.events
Created compressed tar FIP based file /var/log/&lt;xCAT EMS&gt;.gatherfip.&lt;date_time&gt;.tar.gz

  * [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) \- the lsdef command is used the list attributes for xCAT table definitions. For P775A+ and service recovery, it is important to know the VPD information that is listed for the Frame and CECs in the P775 cluster. The important attributes for vpd are hcp (hardware control point), id (frame id # or cage id #), mtm (model type, machine) serial (serial #). The lsdef command is also used to validate the P775 LPAR or octant information. The important attributes listed with LPARs are cons (console), hcp (hardware control point), id (LPAR/octant id #), mac (Ethernet or HFI MAC address), parent (CEC object), os (operating system), xcatmaster (installation server xCAT SN or xCAT EMS).

To gather information about Frame objects:

~~~~
      lsdef frame -i hcp,id,mtm,serial
      Object name: frame17
       hcp=frame17
       id=17
       mtm=9458-100
       serial=BPCF017
~~~~


To gather information about CEC objects:

~~~~
      lsdef f17c04  -i hcp,id,mtm,serial
      Object name: f17c04
       hcp=f17c04
       id=6
       mtm=9125-F2C
       serial=02D8B55
~~~~


To gather information about LPARs (octants), you need to reference different attributes:

~~~~
      lsdef c250f03c01ap01-hf0 -i cons,hcp,id,mac,os,parent,xcatmaster
      Object name: c250f03c01ap01-hf0
       cons=fsp
       hcp=cec01
       id=1
       mac=020000000004
       os=AIX
       parent=cec01
       xcatmaster=c250f03c10ap01-hf0
~~~~


  * [rflash](http://xcat.sourceforge.net/man1/rflash.1.html) \- this command is used to update and recover the License Internal Code (LIC) firmware for CEC (fsp), and power code for frame (bpa). It uses the activate option to load new firmware levels. There are other options to commit firmware, and execute recovery which may be needed if the BPA or FSP has booting issues.
  * [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) \- this command is used at times to logically power off/on LPARs (octants), CEC (fsp), and frame (bpa). It has different attributes based on the hardware type of the node object being targeted:

      For Frame objects: rpower noderange [rackstandby|exit_rackstandby|stat|state]
      For CEC objects:  rpower noderange [on|off|stat|state|lowpower]
      For LPAR objects: rpower noderange [on|off|stat|state|reset|boot|of|sms]



  * [mkhwconn](http://xcat.sourceforge.net/man1/mkhwconn.1.html)/[rmhwconn](http://xcat.sourceforge.net/man1/rmhwconn.1.html) \- these commands create and removes hardware connections for FSP and BPA nodes to HMC nodes or hardware server from the xCAT EMS. As part of service recovery, you may need to remove and recreate HW connections to if there were changes being made to a BPA or FSP.
  * [rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html) \- This command sets the network or hfi device as the first boot device for the specified PPC LPARs. The boot order may change after IO re-assignment, so the administrators need to run rbootseq to set the boot string for the current_node.

### P775A+ (FIP) xCAT Administrator Scenarios

This section provides the expected xCAT administrator tasks that is required for P775A+ activities. The expectation is that this section will continue to be updated with additional scenarios when more service and recovery information is known from our P775A+ and service activities.


The xCAT administrator should keep a close watch in regard to P775 cluster activities. These include keeping track of any P775 cluster resources and understanding if there are any hardware, network, and software issues found. It is important that the P775 admin read through the "High Performance Clustering using the 9125-F2C" (P775 Cluster) guide , and gain a good understanding the TEAL and ISNM infrastructure and commands executed to track the P775 hardware and HPC software events. These include P775 hardware events from the Service Focal Point (SFP) that are created on the Hardware Management Console (HMC), and then placed in the Teal tables in the xCAT DB on the xCAT EMS. The P775 admin should also understand the ISNM commands used to manage the HFI switch environment, where there are ISNM tables in the xCAT DB, and configuration files placed on the xCAT EMS that will track the P775 HFI configuration and link errors.

The administrator should setup xCAT "FIP" node groups that should be used working with P775A+ environment. There should be one xCAT node group called "fip_defective" for any found P775 defective nodes or octants. There should be a second xCAT node group "fip_available" that should list the P775A+ available nodes or octants. You can use the xCAT mkdef command to create the node groups, and then use the chdef command to associate any P775 nodes (octants) to the proper node group.

~~~~
    mkdef -t group -o fip_defective  (create a fip_defective group that should be empty)
    mkdef -t group -o fip_available members="node1,node2,node3" (create a fip_available group with nodes node1,node2,node3)

~~~~



There is an xCAT script called "gatherfip" that is installed on the xCAT EMS that will track many of the P775 hardware and ISNM events. This script is available to the xCAT administrator to execute on the xCAT EMS where it will create files for ISNM, SFP, and deconfigured resources into files and a tar package in /var/log directory which can sent to IBM service team.

~~~~
     # gatherfip
     Writing CNM Alerts in TEAL to  file /var/log/gatherfip.CNM.Events
     Writing CNM Link Down information to /var/log/gatherfip.CNM.links.down
     Writing deconfigred resource information to /var/log/gatherfip.guarded.resources
     Writing Hardware service events information to /var/log/gatherfip.hardware.service.events
     Created compressed tar FIP based file /var/log/<xCAT EMS>.gatherfip.<date_time>.tar.gz
~~~~


The xCAT administrator may want to check the current state of P775 frame, cecs, and lpars (octants). There are xCAT commands that can be used to track hardware configuration information. Here is some information for important xCAT commands rinv, rpower, lsdef, and lsvm that will provide current status of P775 cluster.

The rinv command retrieves hardware configuration information for powercode (frame) and firmware (cec) levels using "firm" attribute. It also specifies any deconfigured resources with "deconfig" attributes from the FSP for the P775 CECs.

~~~~
     #rinv frame03 firm        (P775  frame)
      frame03: Release Level  : 02AP730
      frame03: Active Level   : 033
      frame03: Installed Level: 033
      frame03: Accepted Level : 032
      frame03: Release Level A: 02AP730
      frame03: Level A        : 033
      frame03: Current Power on side A: temp
      frame03: Release Level B: 02AP730
      frame03: Level B        : 033
      frame03: Current Power on side B: temp
     # rinv cec01 firm        (P775 CEC)
     cec01: Release Level  : 01AS730
     cec01: Active Level   : 035
     cec01: Installed Level: 035
     cec01: Accepted Level : 034
     cec01: Release Level Primary: 01AS730
     cec01: Level Primary  : 035
     cec01: Current Power on side Primary: temp
     cec01: Release Level Secondary: 01AS730
     cec01: Level Secondary: 035
     cec01: Current Power on side Secondary: temp
     # rinv cec01 deconfig   (P775 CEC)
     cec01: Deconfigured resources
     cec01: Location_code                RID   Call_Out_Method    Call_Out_Hardware_State    TYPE
     cec01: U78A9.001.1147006-P1         800
~~~~


The rpower command is used to logically power off/on and track the state of P775 LPARs (octants), CEC (fsp), and frame (bpa). It has different attributes based on the hardware type of the node object(s) being targeted.

~~~~
     For Frame objects: rpower noderange [rackstandby|exit_rackstandby|stat|state]
     For CEC objects:  rpower noderange [on|off|stat|state|lowpower]
     For LPAR objects: rpower noderange [on|off|stat|state|reset|boot|of|sms]

     # rpower frame03 state    (P775 Frame)
     frame03: BPA state - Both BPAs at standby
     # rpower cec01  state     (P775 CEC)
     cec01: operating
     # rpower c250f03c01ap01-hf0 state   (P775 LPAR)
     c250f03c01ap01-hf0: Running
~~~~


The lsdef command is used the list attributes for xCAT table definitions. For P775A+ and service recovery, it is important to know the VPD information that is listed for the Frame and CECs in the P775 cluster. The important attributes for P775 vpd are hcp (hardware control point), parent, id (frame id/cage id), mtm (model type machine) and serial number.

To gather hcp and vpd information about Frame objects

~~~~
     # lsdef frame03 -i hcp,id,mtm,serial,parent   (P775 Frame)
     Object name: frame03
       hcp=frame03
       id=3
       mtm=78AC-100
       parent=
       serial=BD50095
~~~~


To gather hcp and vpd information about CEC objects

~~~~
     # lsdef cec01 -i hcp,id,mtm,serial,parent  (P775 CEC)
     Object name: cec01
       hcp=cec01
       id=3
       mtm=9125-F2C
       parent=frame03
       serial=02A5CE6
~~~~


For xCAT LPARs(octants), it is important to reference a different set of attributes. The important xCAT attributes are hcp, cons, lpar/octant id, MAC address, OS, parent, and xcatmaster (install server). To gather vpd information about LPARs (octants) you need to reference the CEC node object listed as the parent.

~~~~
     # lsdef c250f03c01ap01-hf0 -i cons,hcp,id,mac,os,parent,xcatmaster  (P775 diskless LPAR)
     Object name: c250f03c01ap01-hf0
       cons=fsp
       hcp=cec01
       id=1
       mac=020000000004
       os=AIX
       parent=cec01
       xcatmaster=c250f03c10ap01-hf0
~~~~



The lsvm command is used to list the octant configuration and I/O slots assignment for P775 CECs and LPARs. The administrator should use lsvm to get the profile content information to help track any I/O assignment changes being made to LPAR or CEC. This is very important to track the octant information for the xCAT SN when there are changes required with P775 nodes.

~~~~
     # lsvm cec10  (P775 CEC with I/O resources)
       1: 569/U78A9.001.114M005-P1-C1/0x21010239/2/1
       1: 568/U78A9.001.114M005-P1-C2/0x21010238/2/1
       1: 561/U78A9.001.114M005-P1-C3/0x21010231/2/1
       1: 560/U78A9.001.114M005-P1-C4/0x21010230/2/1
       1: 553/U78A9.001.114M005-P1-C5/0x21010229/2/1
       1: 552/U78A9.001.114M005-P1-C6/0x21010228/2/1
       1: 545/U78A9.001.114M005-P1-C7/0x21010221/2/1
       1: 544/U78A9.001.114M005-P1-C8/0x21010220/2/1
       1: 537/U78A9.001.114M005-P1-C9/0x21010219/2/1
       1: 536/U78A9.001.114M005-P1-C10/0x21010218/2/1
       1: 529/U78A9.001.114M005-P1-C11/0x21010211/2/1
       1: 528/U78A9.001.114M005-P1-C12/0x21010210/2/1
       1: 521/U78A9.001.114M005-P1-C13/0x21010209/2/1
       1: 520/U78A9.001.114M005-P1-C14/0x21010208/2/1
       1: 514/U78A9.001.114M005-P1-C17/0x21010202/2/1
       1: 513/U78A9.001.114M005-P1-C15/0x21010201/2/1
       1: 512/U78A9.001.114M005-P1-C16/0x21010200/2/1
       cec10: PendingPumpMode=1,CurrentPumpMode=1,OctantCount=8:
       OctantID=0,PendingOctCfg=2,CurrentOctCfg=2,PendingMemoryInterleaveMode=2,CurrentMemoryInterleaveMode=2;
       OctantID=1,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
       OctantID=2,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
       OctantID=3,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
       OctantID=4,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
       OctantID=5,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
       OctantID=6,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
       OctantID=7,PendingOctCfg=1,CurrentOctCfg=1,PendingMemoryInterleaveMode=0,CurrentMemoryInterleaveMode=0;
     # lsvm c250f03c10ap01  (P775 xCAT SN LPAR)
       1: 569/U78A9.001.114M005-P1-C1/0x21010239/2/1
       1: 568/U78A9.001.114M005-P1-C2/0x21010238/2/1
       1: 561/U78A9.001.114M005-P1-C3/0x21010231/2/1
       1: 560/U78A9.001.114M005-P1-C4/0x21010230/2/1
       1: 553/U78A9.001.114M005-P1-C5/0x21010229/2/1
       1: 552/U78A9.001.114M005-P1-C6/0x21010228/2/1
       1: 545/U78A9.001.114M005-P1-C7/0x21010221/2/1
       1: 544/U78A9.001.114M005-P1-C8/0x21010220/2/1
       1: 537/U78A9.001.114M005-P1-C9/0x21010219/2/1
       1: 536/U78A9.001.114M005-P1-C10/0x21010218/2/1
       1: 529/U78A9.001.114M005-P1-C11/0x21010211/2/1
       1: 528/U78A9.001.114M005-P1-C12/0x21010210/2/1
       1: 521/U78A9.001.114M005-P1-C13/0x21010209/2/1
       1: 520/U78A9.001.114M005-P1-C14/0x21010208/2/1
       1: 514/U78A9.001.114M005-P1-C17/0x21010202/2/1
       1: 513/U78A9.001.114M005-P1-C15/0x21010201/2/1
       1: 512/U78A9.001.114M005-P1-C16/0x21010200/2/1
~~~~


### P775A+ (FIP) Compute Node Implementation

The P775A+ activity with compute nodes/octants is to keep track of the different hardware issues found with compute nodes. IBM will provide the customer more P775 compute nodes than they paid for as part of P775A+, and has choices in regard to how they use the P775A+ (FIP) nodes. The P775A+ environment is specified by using a P775A+ Swap policy as hot, warm, and cold. The "hot" swap policy is where they can use the extra P775A+ nodes as part compute processing, which provides additional processing power for production or non production activities. The "warm" policy is specified where the P775A+ nodes are powered up and made available to the P775 cluster, but they are not used with any production work load. The "cold" swap policy is where the P775A+ node resources are physically powered down and are brought online when required. The xCAT administrator with help of IBM service will need to make a decision on how they want to enable the P775A+ resources. They may be able to allocate P775A+ (FIP) resources into all three swap policies. They will need to manually keep track on how the P775A+ resources are being allocated for their application workloads.

When the compute node has lost CPU/memory resources or HFI link connections where the node is no longer appropriate to be used as a compute node with LoadLeveler application activity, then the xCAT administrator will need to remove the bad octant (node) from the LoadL resource pool so the node is no longer scheduled for any applications. Depending on the swap policy, the admin will decide which action is required.

  * hot swap policy - the administrator just removes the bad node from the LoadL resource pool and places the bad octant/node in the P775A+ (FIP) failed node group fip_defective.
  * warm swap policy - the administrator removes the bad node from the LoadL resource pool, places the bad octant/node in the P775A+ (FIP) failed node group fip_defective. They may then set up an additional FIP available compute node to be included in the LoadL resource pool.
  * cold swap policy - the administrator removes the bad node from the LoadL resource pool, places the bad octant/node in the P775A+ (FIP) failed node group fip_defective. Then they may need to power up the CEC that the FIP available node is in (if it is not already on), power on the octant to diskless boot the compute node, and then place the compute nodes in LoadL resource pool.

The P775 admin needs to understand how the application environment is configured by LoadLeveler product. They require all the LoadL packages to be installed, and the configuration working appropriately for the P775 cluster. Please reference LoadLeveler documentation to gain more knowledge and detail about the LoadL commands and procedures used with P775A+ (FIP). [Tivoli Workload Scheduler LoadLeveler library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html) The P775 admin may also want to reference the xCAT/HPC Integration document on how to setup LoadL on your P775 cluster:

[Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster](Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster)

#### P775A+ Hot Swap Compute Node Scenario

The P775A+ activity with P775 CN nodes/octants is to make sure that we have a selection of P775A+ nodes available in the current LoadL application workload resource configuration. This means that the hot or warm P775A+ nodes have been installed with the proper diskless images so they are ready to handle execution of applications working with LoadL configurations.

The understanding is that the customer should keep the LoadL workload resources under the maximum threshold specified by P775A+ process. The customer may want to denote LoadL "features" resource pool configurations that can be used by the P775A+ available octants, and note selected features for partially restricted P775 octants where certain memory or CPU resources are tainted. The P775 admin needs to make sure all P775A+ FIP defective octants are no longer being allocated with active LoadL resources. If bad P775 octants get fixed by IBM service in the P775 cluster, they can be added back into LoadL configuration.

    *  Admin has noted a failure with compute node (f1c1lp25) with bad octant (25) in cec1 where resources (HFI, memory, CPU)
       have made the octant no longer is usable with the LoadL cluster. The P775 admin can note issues with resources through
       deconfigured resources found in the specified P775 cecs.
         rinv cec1 deconfig
    (1) The P775 admin should first "drain" the compute node octant f1c1lp25 from LoadL on cec1 if node is still active on a job,
        and then shutdown the bad octant. In most cases the LoadL environment may automatically execute this activity. The admin
        should then vacate "flush" this bad octant so it does not try to restart on the LoadL queue
         llctl -h  f1c1lp25 drain     (drain CN from LoadL)
         rpower f1c1lp25  off         (shutdown CN)
         llctl -h  f1c1lp25 flush     (flush CN from LoadL)
    (2) The admin will then want to remove the bad compute node octant f1c1lp25 from the LoadL "feature" configuration file.
        The admin may want to modify the feature configuration working with generated string, and then make sure the LoadL
        service and compute nodes pickup the new feature configuration file missing the bad octant.

~~~~
         llconfig -N -h f1c1lp25  -d feature
         llconfig -N-h f1c1lp25  -c feature="feature list"
         xdsh llservice llctl reconfig
         xdsh llcompute llrctl reconfig
~~~~

    (3) The admin can now place this bad CN octant in the fip_defective node group where it no longer is referenced until
        the resources are fixed by IBM service team.

~~~~
         chdef -p -t node -o f1c1lp25 groups="fip_defective"
~~~~


#### P775A+ Warm Swap Compute Node Scenario

The P775A+ activity with P775 CN nodes/octants for the P775A+ warm compute node scenario is to make sure that we have a selection of P775A+ nodes are made available in the P775 cluster.
Warm spares, consume less power and cooling energy because they are booted to partition standby and therefore are not used by applications. They come to full partition boot much more quickly than spare nodes that are powered off. 
They also do not require a reIPL of their drawer to deploy them. The understanding is that the customer should keep the LoadL workload resources under the maximum threshold specified by P775A+ process. The customer may want to denote LoadL "features" resource pool configurations that can be used by the P775A+ available octants, and note selected features for partially restricted P775 octants where certain memory or CPU resources are tainted. 
The P775 admin needs to make sure all P775A+ FIP defective octants are no longer being allocated with active LoadL resources. If bad P775 octants get fixed by IBM service in the P775 cluster, they can be added back into LoadL configuration.
*  Admin has noted a failure with compute node (f1c1lp25) with bad octant (25) in cec1 where resources (HFI, memory, CPU) have made the octant no longer is usable with the LoadL cluster. The P775 admin can note issues with resources through deconfigured resources found in the specified P775 cecs.

~~~~
  rinv cec1 deconfig
~~~~

Since the warm node is of standby state, the admin will need to power up the P775 cec12, install the new octants and allocate these new octant resources to be available into the LoadL resource configurations. We also need to execute through the same  hot process specified above.
(1) The P775 admin should first "drain" the compute node octant f1c1lp25 from LoadL on cec1 if node is still active on a job,  and then shutdown the bad octant. In most cases the LoadL environment may automatically execute this activity. The admin  should then vacate "flush" this bad octant so it does not try to restart on the LoadL queue

~~~~
        llctl -h  f1c1lp25 drain     (drain CN from LoadL)
        rpower f1c1lp25  off         (shutdown CN)
        llctl -h  f1c1lp25 flush     (flush CN from LoadL)
~~~~

(2) The admin need to bring the spare resource on-line from the partition standby state. The admin needs to power up the  P775A+ FIP available "cec12", and validate that all expected resources are avaialble.

~~~~
          rpower  cec12 on
          lsvm    cec12
~~~~

(3) The admin needs to update all the cec12 node definitions  making sure they have the appropriate node attributes defined  for hardware control, xCAT MN/SN, and installation. The admin then needs setup the proper diskless installation environment on the xCAT EMS and target xCAT SN, where all the compute nodes are installed to appropriate levels for HPC applications. The admin should reference the installation setup and execution specified in the xCAT Hierarchical Cluster documentation  in sections where they describe "Define and Install cluster Nodes".

[Setting_Up_an_AIX_Hierarchical_Cluster]
[Setting_Up_a_Linux_Hierarchical_Cluster]

(4) The admin can now update the LoadL resource configurations to add the new cec12 nodes, and remove bad CN octant f1c1lp25 to selected LoadL feature configuration files and resource pools. Please reference LoadL documentation for details.

The admin will then want to remove the bad compute node octant f1c1lp25 from the LoadL "feature" configuration file.
The admin may want to modify the feature configuration working with generated string, and then make sure the LoadL service and compute nodes pickup the new feature configuration file for cec12 nodes and remove the bad octant.

~~~~
        llconfig -N -h f1c1lp25  -d feature
        llconfig -N -h f1c1lp25  -c feature="feature list"
        llconfig -N -h c12nodes  -c feature="feature list"
        xdsh llservice llctl reconfig
        xdsh llcompute llrctl reconfig
~~~~

(5) The admin can now place this bad CN octant in the fip_defective node group where it no longer is referenced until  the resources are fixed by IBM service team.

~~~~
        chdef -p -t node -o f1c1lp25 groups="fip_defective"
~~~~

#### P775A+ Cold Swap Compute Node Scenario

The P775A+ activity with P775 CN nodes/octants for the P775A+ cold compute node scenario is to make sure that we have a selection of P775A+ nodes are made available in the P775 cluster. These P775A+ nodes were initially validated at P775 system bring up, but are not currently active in the P775 cluster including LoadL application workload resource configuration. 
This means that the cold P775A+ nodes need to be installed with proper diskless images so they can handle execution of applications working with LoadL configurations. 
This scenario will require the P775 admin to activate these new P775A+ FIP available octants to be included as "hot" or warm compute node P775A+ resources being available for LoadL configuration.

The understanding is that the customer should keep the LoadL workload resources under the maximum threshold specified by P775A+ process. 
The customer may want to denote LoadL "features" resource pool configurations that can be used by the P775A+ available octants, and note selected features for partially restricted P775 octants where certain memory or CPU resources are tainted. 
The P775 admin needs to make sure all P775A+ FIP defective octants are no longer being allocated with active LoadL resources. If bad P775 octants get fixed by IBM service in the P775 cluster, they can be added back into LoadL configuration.

*  Admin has noted a failure with compute node (f1c1lp25) with bad octant (25) in cec1 where resources (HFI, memory, CPU)  have made the octant no longer is usable with the LoadL cluster. The P775 admin can note issues with resources through  deconfigured resources found in the specified P775 cecs.

~~~~
         rinv cec1 deconfig
~~~~

Since there are only P775A+ FIP cold nodes available, the admin will need to power up the P775 cec12, install the new octants  and allocate these new octant resources to be available into the LoadL resource configurations. We also need to execute through the same hot/warm process specified above.
(1) The P775 admin should first "drain" the compute node octant f1c1lp25 from LoadL on cec1 if node is still active on a job,  and then shutdown the bad octant. In most cases the LoadL environment may automatically execute this activity. The admin  should then vacate "flush" this bad octant so it does not try to restart on the LoadL queue

~~~~
         llctl -h  f1c1lp25 drain     (drain CN from LoadL)
         rpower f1c1lp25  off         (shutdown CN)
         llctl -h  f1c1lp25 flush     (flush CN from LoadL)
~~~~

(2) The admin need to Re-IPL the drawer with xCAT.s rpower command. The admin needs to power up the P775A+ FIP
available "cec12", and validate that all expected resources are avaialble.

~~~~
         rpower cec12 off
         rpower cec12 on
         lsvm   cec12
~~~~

(3) The admin needs to update all the cec12 node definitions  making sure they have the appropriate node attributes defined  for hardware control, xCAT MN/SN, and installation. The admin then needs setup the proper diskless installation environment  on the xCAT EMS and target xCAT SN, where all the compute nodes are installed to appropriate levels for HPC applications.
The admin should reference the installation setup and execution specified in the   xCAT Hierarchical Cluster documentation in sections where they describe "Define and Install cluster Nodes".

[Setting_Up_an_AIX_Hierarchical_Cluster]
[Setting_Up_a_Linux_Hierarchical_Cluster]

(4) The admin can now update the LoadL resource configurations to add the new cec12 nodes, and remove bad CN octant f1c1lp25 to selected LoadL feature configuration files and resource pools. Please reference LoadL documentation for details. The admin will then want to remove the bad compute node octant f1c1lp25 from the LoadL "feature" configuration file.  The admin may want to modify the feature configuration working with generated string, and then make sure the LoadL service and compute nodes pickup the new feature configuration file for cec12 nodes and remove the bad octant.

~~~~
         llconfig -N -h f1c1lp25  -d feature
         llconfig -N -h f1c1lp25  -c feature="feature list"
         llconfig -N -h c12nodes  -c feature="feature list"
         xdsh llservice llctl reconfig
         xdsh llcompute llrctl reconfig
~~~~

(5) The admin can now place this bad CN octant in the fip_defective node group where it no longer is referenced until  the resources are fixed by IBM service team.

~~~~
         chdef -p -t node -o f1c1lp25 groups="fip_defective"

~~~~


### P775A+ (FIP) Login Node Implementation

The P775A+ activity with P775 Login nodes/octants is to make sure that we have proper P775A+ nodes available in the P775 CEC that contains an available ethernet adapter, and is available to the same xCAT SN. As with compute nodes, the login nodes are diskless, so they contain octant resources of HFI, CPU and memory. But they do need to have and ethernet I/O resource be included in the octant configuration. There are multiple P775 login nodes in the cluster, so the plan is that the P775 administrator will instruct the users to use one the other login nodes, while they rebuild a new login node from an available P775A+ resource. Based on the login node failure, the admin will need to locate an P775A+ octant, and working with PE support move the proper I/O ethernet adapter resource to a P775+ octant. The admin executes xCAT "chvm" to logically allocate I/O resources to new designated P775A+ node. They will execute xCAT swapnodes command where you place the bad octant into fip_defective node group, and allocate new octant as the new login node definition if they are in the different CEC. The admin will need to see if the new login node requires a new ethernet "MAC" address to be used, and will install the new P775 login node from the appropriate xCAT SN with same OS diskless image that was used with the previous login node.

#### Login node Replace Ethernet/HFI Scenario

This P775+ scenario specifies the xCAT admin activity required to move or replace a bad octant being supported as a P775 working in the same P775 CEC. The expectation is that the xCAT admin has noted that there is a failure with both an ethernet adapter and that the octant (LPAR id 1) with P775 login node "logincec3n1". The P775 admin has identified an available P775A+ FIP octant 1 (LPAR id 5) xCAT node "cec3n5" in the same CEC "cec3" can be used to setup

    *  Admin has noted a failure with cec3 octant0 where communication is lost to HFI and ethernet on P775 login node "logincec3n1.
       It was found that node logincec3n1 seeing decongifured resources in octant 0 for cec3.

~~~~
        rinv cec1 deconfig

~~~~
    (1) Admin has notified cluster users that P775 login node is down and users should be using another available login node.
    (2) Admin contacts IBM Service indicating that there is a bad login node octant where a PE person will be available to
        physically move the I/O resources from octant 0 (LPARid 1) to octant 1 (LPARid 5) in cec3.
    (3) Admin will then power off cec3 if IBM service needs to replace the adapter and allocate to another octant.
        rpower cec3  off
    (4) PE Rep will do physical update to cec3 where the ethernet adapter is replaced and, I/O resources allocated to octant 1
       (LPARid 5). The IBM PE service team needs to note which I/O slots resources have been moved.
    (5) Admin executes the xCAT commands swapnode command to have login node logincec3n1 to now use FIP node fipcec3n5
        octant 1 (lpar id 5) resources in xCAT DB. The P775A+ FIP node fipcec3n5 will now take ownership of the bad octant 0.
        It is also a good time to make updates to the FIP node groups fip_defective and fip_available for node "fipcec3n5"

~~~~
          rpower cec3 on
          rpower logincec3n1 off
          rpower cec305 off
          swapnodes -c logincec3n1 -f fipcec3n5
          chdef -p -t node -o fipcec3n5 groups="fip_defective"
          chdef -m -t node -o fipcec3n5 groups="fip_available"
~~~~

    (6) Admin executes lsvm cec3 to note octant resources. If changes
        are needed, admin executes lsvm on xCAT SN to produce output file, then updates file to represent proper I/O setting.
        Admin then executed inputs the file working with chvm command.

~~~~
         lsvm    cec3
         lsvm    logincec3n1
         The steps below(lsvm, chvm) are only needed if the two nodes are in different CEC.
         lsvm   logincec3n1 >/tmp/logincec3n1.info
         edit /tmp/logincec3n1.info .. Make updates for octant information, and save file
         cat  /tmp/logincec3n1.info | chvm  logincec3n1.info
         lsvm  logincec3n1
~~~~

    (7) Admin executes "getmacs"  command to retrieve the new HFI MAC address of the new HFI adapter. Make sure this MAC address
        is placed in the logincec3n1 node object. The admin will want to double check all the installation settings are properly
        set, and then recreate logincec3n1 on the xCAT SN to reflect new HFI MAC and ethernet for the node installation.

~~~~
          getmacs  logincec3n1
          lsdef logincec3n1
          mkdsklsnode -f logincec3n1  (For AIX)
          nodeset logincec3n1 netboot (For Linux)
~~~~

    (8) The admin should execute diskless node install for the P775 login node using the new octant. Make sure the login node
        environments (ssh, HPC) are working properly.

~~~~
           rnetboot logincec3n1
           ssh root@logincec3n1   (try to login and validate OS and xCAT command)
~~~~

    (9) Once the admin has validated that the P775 login node is running properly, they can schedule the appropriate time to have
        the users start using the login node.


### P775A+ (FIP) xCAT Service Node Implementation

The P775A+ activity with P775 xCAT SN nodes/octants is to make sure that we have proper P775A+ nodes available in the P775 CEC that contains an available I/O resources including an ethernet adapter, and SAS disk adapters. Since the xCAT SN is very prominent in the P775 cluster, the administrator needs to actively recover the xCAT SN very quickly. It would be advantageous to have the available P775A+ resources made available in the same P775 CEC as the current xCAT SNs. This will help the recovery where only one P775 cec will need to be brought down when looking to reorganize the I/O resources to a new P775A+ available resource. Since the xCAT SN CEC has most of the I/O resources, the complexity of the xCAT SN failure will require additional debug activity, and additional xCAT administrator tasks to recover the xCAT SN.

The first task is to make sure that the current backup xCAT SN is working in the P775 cluster, and admin will execute the xCAT SN failover tasks, where the xCAT compute nodes are allocated over to the xCAT SN backup node. After you accomplish the recovery of the failed xCAT SN, you then want to reallocate the xCAT compute nodes back to their primary xCAT SN. This xCAT SN failover scenario is documented in the appropriate xCAT AIX/Linux Hierarchical Cluster documents.
[Setting_Up_a_Linux_Hierarchical_Cluster]
[Setting_Up_an_AIX_Hierarchical_Cluster]


The recovery flow of the xCAT SN, is to first debug the issue of the xCAT SN, where it is best to recover the xCAT SN without walking through the P775A+ process. But if there is an issue with the P775 xCAT SN octant, the admin will need to work closely with the IBM PE service representative to understand the xCAT SN hardware failure. The P775 recovery is to power down the P775 CECs for both the failed xCAT SN and for the P775 CEC where the P775A+ available octant is located. The IBM PE then makes sure the appropriate physical I/O ethernet and disk resources are moved to the new P775A+ (FIP) available octant. The xCAT admin will execute the xCAT "chvm" command to allocate the I/O ethernet adapter and the SAS disk I/O resources to a new designated P775A+ node octant. The admin will execute xCAT "swapnodes" command where you place the bad octant into fip_defective node group, and allocate new P775A+ octant as the new xCAT SN node definition. Based on the xCAT SN hardware failure, the admin may need to do multiple tasks.

For a new ethernet adapter, they will need to retrieve new ethernet MAC address for the xCAT SN. For a new replaced SAS disk, the xCAT admin will reinstall the xCAT SN using the same xCAT OS disk full image used by the previous xCAT SN octant. If the xCAT SN needs to be moved to a different P775 CEC, than the admin needs to make sure the VPD and the remote power attributes are reflected in the xCAT SN object. Once the new xCAT SN is properly up and running to the satisfaction of the xCAT administrator they can plan to execute the xCAT SN fail over tasks to move the xCAT compute nodes back to the rebuilt primary xCAT SN.




#### xCAT Service Node Ethernet/HFI scenario in same CEC

This P775A+ scenario specifies the xCAT admin activity required to move or replace a bad octant being supported as an xCAT SN working in the same P775 CEC. The expectation is that the xCAT admin has noted that there is a failure with both an ethernet adapter and that the octant 0 (LPAR id 1) with xCAT SN "xcatsn1" is not working. The P775 admin has identified an available P775A+ octant 1 (LPAR id 5) xCAT node "cec1n5" in the same CEC "cec1" can be used to setup

*  Admin has noted a failure with cec1 octant0 where communication is lost to HFI and ethernet on xCAT SN "xcatsn1".
It was found that xcatsn1 is seeing decongifured resources in octant 0 for cec1.

~~~~
        rinv cec1 deconfig 
~~~~

(1)Admin has executed manual xCAT SN fail over using multiple xCAT commands including "snmove" to have compute nodes use the  backup xCAT SN. These tasks are defined in the Hierarchical Cluster documentation in section "Using a backup service node".

[Setting_Up_an_AIX_Hierarchical_Cluster]
[Setting_Up_a_Linux_Hierarchical_Cluster]

(2) Admin contacts IBM Service indicating that there is a bad xCAT SN octant where a PE person will be available to    physically move the I/O resources from octant 0 (LPARid 1) to octant 1 (LPARid 5) in cec1.
(3) Admin will execute a LoadL drain any compute notes found on cec1 and temporarily make them unavailable to LoadL resources.  If the xcat SN is also the LoadL manager server, make sure that LoadL is properly working on the LoadL backup server.
The admin will then shutdown the cec1 lpars "cec1nodes" and xCAT SN "xcatsn1", and then power off cec1.

~~~~
         llctl -h  cec1nodes drain     (drain CNs from LoadL)
         rpower cec1nodes  off         (shutdown CNs)
         rpower xcatsn1 off
         rpower cec1  off
~~~~

(4) PE Rep will do physical update to cec1 where the ethernet adapter is replaced and, I/O resources allocated to octant 1 (LPARid 5). The IBM PE service team needs to note which I/O slots resources have been moved.
(5) Admin executes the xCAT swapnodes command to have xCAT SN xcatsn1 to now use P775A+ (FIP) node fipcec1n5
 octant 1 (lpar id 5) resources in xCAT DB. The P775A+ FIP node fipcec1n5 will now take ownership of the bad octant 0.  It is also a good time to make updates to the P775A+ FIP node groups fip_defective and fip_available for node "fipcec1n5"

~~~~
          rpower cec1 on
          swapnodes -c xcatsn1 -f fipcec1n5
          chdef -p -t node -o fipcec1n5 groups="fip_defective"
          chdef -m -t node -o fipcec1n5 groups="fip_available"
~~~~

(6) Admin powers up cec1 to standby so resources can be seen. He executes lsvm cec1 to note octant resources. If changes are needed, admin executes lsvm on xCAT SN to produce output file, then updates file to represent proper I/O setting.  Admin then executed inputs the file working with chvm command.

~~~~
         rpower  cec1 onstandby
         lsvm    cec1
         The steps below(lsvm, chvm) are only needed if the two nodes are in different CEC.
         lsvm   xcatsn1 >/tmp/xcatsn1.info
         edit /tmp/xcatsn1.info .. Make updates for octant information, and save file
         cat  /tmp/xcatsn1.info | chvm  xcatsn
         lsvm  xcatsn1
~~~~

(7) Admin executes "getmacs"  command to retrieve the new MAC address of the new ethernet adapter. Make sure this MAC address  is placed in the xcatsn1 node object. The admin will want to recreate xcatsn1 nim object to reflect new MAC interface if  working with AIX cluster.

~~~~

          getmacs  xcatsn1 -D
          lsdef xcatsn1 -i mac
          xcat2nim xcatsn1 -f  (AIX only)
~~~~

(8) Since the disk subsystem was not affected, there is a good chance that you should be able to power up the xCAT SN and other   compute  node octants located on the cec1. The admin should do a thorough checkout making sure all xCAT xCAT SN   environments (ssh, DB2, and installation) are working properly.  It is a good test to execute xCAT updatenode command   against the xCAT SN.  If the xCAT SN is not working properly, the admin may want to do a reinstall on the xCAT SN.

~~~~
           rpower xcatsn1  on
           ssh root@xcatsn1   (try to login and validate OS and xCAT commands)
           updatenode  xcatsn1
~~~~

(9) Once the admin has validated that the xCAT SN xcatsn1 is running properly, they can schedule the appropriate time to execute  manual xCAT SN fail over task to have the selected compute nodes move from the backup xCAT SN.  If the xCAT SN was also a   LoadL manager server, make sure that LoadL is properly working on the new xCAT SN. The admin should plan to reinstall the  diskless compute nodes working with the rebuilt "xcatsn1". The P775 admin should check that bad FIP node "fipcec1n5" used for xCAT SN  and now defected is not referenced in "cec1nodes" xCAT node group, and in the LoadL configuration. The admin can then reinstate all the good compute nodes in cec1 into the LL configuration as good resources.

~~~~
          mkdsklsnode cec1nodes
          rnetboot  cec1nodes
          llctl -h  cec1nodes resume
~~~~

(10) xCAT SN need to setup hardware server manually for the hardware management
 Refer the document to download and install hardware server
           [XCAT_Power_775_Hardware_Management]
After installing, start the hardware server manually if it doesn't start:

~~~~
          service hdwr_svr start (on Linux)
          startsrc -s hdwr_svr (on AIX)

~~~~


#### xCAT Service Node Disk Replacement scenario on a Different CEC

This P775A+ scenario specifies the xCAT admin activity required to move or replace a bad octant being supported as an xCAT SN working in a different P775 CEC. The expectation is that the xCAT admin has noted that there is a failure with both a disk,and that the octant 0 (LPAR id 1) with xCAT SN "xcatsn1" is not working in "cec1". The P775 admin identified an available P775A+ FIP octant 0 (LPAR id 1) with xCAT node "fipcec2n1" which is in a different CEC "cec2" that can be used to setup the xCAT SN.

    *  Admin has noted a failure with cec1 octant0 where communication is lost to HFI and the disk is bad on xCAT SN "xcatsn1".
        It was found that xCAT SN xcatsn1 is seeing deconfigured resources in octant 0 for cec1.
        rinv cec1 deconfig
    (1)Admin has executed manual xCAT SN fail over using multiple xCAT commands including "snmove" to have compute nodes use the
       backup xCAT SN. These tasks are defined in the Hierarchical Cluster documentation in section "Using a backup service node".
[Setting_Up_an_AIX_Hierarchical_Cluster]
[Setting_Up_a_Linux_Hierarchical_Cluster]
    (2) Admin contacts IBM Service indicating that there is a bad xCAT SN octant where a PE person will be available to
        physically move the I/O resources from octant 0 (LPARid 1) to octant 1 (LPARid 5) in cec1.
    (3) Since the admin needs to use the P775A+ available node on a different CEC, we need to drain any compute nodes on cec1
        and cec2, and temporarily disable them from the LoadL resources. If the xcat SN is also the LoadL manager server, make
        sure that LoadL is properly working on the LoadL backup server. The admin needs to shutdown all the affected
        compute nodes, xCAT SN, and then power off cec1 and cec2.
          llctl -h  cec1nodes,cec2nodes drain     (drain cec1and cec2 CNs from LoadL)
          rpower cec1nodes,cec2nodes  off         (shutdown CNs)
          rpower xcatsn1 off
          rpower cec1,cec2  off
    (4) PE Rep will do physical update to cec1 where the disk is replaced, and xCAT SN required I/O resources ethernet and disk
        adapters are physically installed and  allocated to octant 0 in cec2. We will use the HFI interfaces in octant 0 in cec2.
        The IBM PE service team needs to note which I/O slots resources have been moved.
    (5) Admin executes the xCAT commands swapnode command to have xCAT SN xcatsn1 to now use P775A+ node fipcec2n1 settings with cec2
        octant 0 (lpar id 1) resources in xCAT DB. This will indicate that xCAT SN xcatsn1 will have a new VPD and MTMS attributes.
        The FIP node fipcec2n1 will now take ownership of the bad octant 0 in cec1.
        It is also a good time to make updates to the P775A+ FIP node groups fip_defective and fip_available for node "fipcec2n1"

~~~~
          swapnodes -c xcatsn1 -f fipcec1n5
          chdef -p -t node -o fipcec1n5 groups="fip_defective"
          chdef -m -t node -o fipcec1n5 groups="fip_available"
~~~~

    (6) Admin powers up cec1 and cec2 so resources can be seen. He executes lsvm cec2 to note octant resources. If changes
        are needed, admin executes lsvm on xCAT SN to produce output file, then updates file to represent proper I/O setting.
        Admin then executed inputs the file working with chvm command.

~~~~
         rpower  cec1,cec2 on
         lsvm    cec2
         lsvm   xcatsn1 >/tmp/xcatsn1.info
         edit /tmp/xcatsn1.info .. Make updates for octant information, and save file
         cat  /tmp/xcatsn1.info | chvm  xcatsn
         lsvm  xcatsn1
~~~~

    (7) Admin executes "getmacs"  command to validate that proper MAC address of the ethernet adapter is found. Make sure this
        MAC address is placed in the xcatsn1 node object. The admin will want to recreate xcatsn1 nim object to reflect new MAC
        interface if working with AIX cluster.

~~~~
          getmacs  xcatsn1 -D
          lsdef xcatsn1 -i mac
          xcat2nim xcatsn1 -f  (AIX only)
~~~~

    (8) Since the disk subsystem was affected, we will need to reinstall the xCAT SN xcatsn1 on the new disk. The admin will
        need to validate all of the service node and installation attributes are properly defined. The admin executes
        a diskful installation on the xCAT SN. Please reference the proper xCAT SN Hierarchical Cluster documentation.
        The admin should do a thorough checkout making sure all xCAT xCAT SN environments (ssh, DB2, and installation) are working
        properly after the xCAT SN installation.

~~~~
          lsdef xcatsn1       (check all install and SN  attributes)
          rnetboot xcatsn1    (execute network boot to reinstall xcatsn1 on cec2)
          ssh root@xcatsn1   (try to login and validate OS and xCAT commands)
~~~~

    (9) Once the admin has validated that the xCAT SN xcatsn1 is running properly, they can schedule the appropriate time to execute
        manual xCAT SN fail over task to have the selected compute nodes move from the backup xCAT SN. If the xCAT SN was also a
        LoadL manager server, make sure that LoadL is properly working on the new xCAT SN. The admin should plan to reinstall the
        diskless compute nodes working with the rebuilt xcatsn1. The P775 admin should check that bad FIP node "fipcec2n1" used for
        xCAT SN  and now defected is not referenced "cec2nodes" node group, and in the LoadL configuration. The admin can then
        reinstate all the good compute nodes in cec1 and cec2 into the LL configuration as good resources .

~~~~
          mkdsklsnode cec1nodes,cec2nodes
          rnetboot  cec1nodes,cec2nodes
          llctl -h  cec1nodes,cec2nodes resume

~~~~


### P775A+ GPFS I/O Node Implementation

The P775A+ support for the P775 GPFS I/O server nodes and the P775 Disk Enclosure is executed directly by the IBM Service team working with GPFS service documentation. http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf

The P775 admin should reference GPFS documentation on how to implement the installation and configuration of the GPFS I/O node and assorted disk configurations being used with the P775 cluster. Here is the location of GPFS Documentation. http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=/com.ibm.cluster.gpfs.doc/gpfsbooks.html

The P775 administrator may reference our xCAT integration with GPFS documentation below for guidance, but will need to work directly with the GPFS documentation working in the P775 cluster. [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]

If an IO node fails, it will be redeployed where a Compute node was originally deployed, and the Compute node will be redeployed in the failing node position. In other words, the IO node and Compute node functions are swapped between physical hardware. If an IO node experiences a failure in a processor, it can be swapped with up to 7 Compute nodes in the same drawer before it needs to be redeployed outside of that drawer. In that case, the adapter cards and cables will also have to be redeployed. If there is an adapter card failure, the adapter card is serviced in the typical manner and does not fall within the domain of the FIP policy. If an adapter slot fails and there are no spares in the drawer, or there is no more Compute resource within the drawer to be swapped wit the IO node, the IO node, adapter cards and cables can be redeployed to the backup drawer. While disk failures fall into the category of Fail in place, they are managed in a different manner. Recovery is done in the software RAID function in GPFS. Once the number of failures reaches the Refresh Threshold, GPFS reports the problem as a serviceable event and IBM service can then be dispatched to repair the failures.

#### GPFS I/O Node Replacement scenario in the same CEC

This P775+ scenario specifies the xCAT admin activity required to replace the bad I/O octant being supported as a P775 working in the same P775 CEC. Octant 0 along with PCI slots containing SAS adapters defines an LPAR that run the GPFS VDisk code. Octant 1 can be defined as a backup for GPFS.The expectation is that the xCAT admin has noted that there is a failure with the octant 0 (LPAR id 1) with P775 Vdisk node "Iocec9n1". The P775 admin has identified an available P775A+ FIP octant 1 (LPAR id 5) xCAT node "cec9n5" in the same CEC "cec9" can be used to setup.

    *  Admin has noted a failure with cec9 octant0 on P775 I/O node " Iocec9n1. with bad octant in cec9 where resources (HFI, memory, CPU) have made the octant no
    longer is usable. The P775 admin can note issues with resources through deconfigured resources found in the specified P775 cecs.
      rinv cec9 deconfig .
    (1) Admin has notified cluster users that P775 I/O node is down.
       Reference the GPFS document:http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp
    (2) Admin contacts IBM Service indicating that there is a bad I/O node octant where a PE person will be available to physically move the I/O resources from
    octant 0 (LPARid 1) to octant 1 (LPARid 5) in cec9.
    (3) Admin will then power off cec9 if IBM service needs to replace the adapter and allocate to another octant.
       rpower cec9 off
    (4) PE Rep will do physical update to cec9 where the adapter cards and cables is redeployed from the octant 0 to the octant 1 (LPARid 5).
    (5) Admin executes the xCAT commands swapnode command to have I/O node Iocec9n1 to now use FIP node octant 1 (lpar id 5) resources in xCAT DB. The P775A+
    FIP node fipcec9n5 will now take ownership of the bad octant 0.
       It is also a good time to make updates to the FIP node groups fip_defective and fip_available for node "fipcec9n5"

~~~~
         rpower  cec9 on
         swapnodes -c Iocec9n1 -f fipcec9n5
         chdef -p -t node -o fipcec9n5 groups="fip_defective"
         chdef -m -t node -o fipcec9n5 groups="fip_available"
~~~~

    (6) Admin executes lsvm cec9 to note octant resources.
        lsvm    cec9
    (7) Admin setup a new GPFS I/O node in the new GPFS I/O node Iocec9n1 follow the document
[Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]


#### GPFS I/O Node replacement scenario on a different CEC

This P775+ scenario specifies the xCAT admin activity required to replace the bad I/O octant being supported as a P775 working on a different P775 CEC. If there is adapter card failure and made the octant no longer is usable. And there are no spares in the drawer, or there is no more compute resource within the drawer to be swapped wit the IO node, the admin should consider to redeploye the IO node, adapter cards and cables to the backup drawer.

    *  Admin has noted a failure with cec9 octant0 on P775 I/O node "Iocec9n1. with adapter card failure. The P775 admin can note issues with resources
    through deconfigured resources found in the specified P775 cecs.
       rinv cec9 deconfig .
    (1) Admin has notified cluster users that P775 I/O node is down.
       Reference GPFS document http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf
    (2) Admin contacts IBM Service indicating that there is a bad I/O node octant where a PE person will be available to physically move the I/O resources
    from octant 0 (LPARid 1) to another octant 0 (LPARid 1) in cec10.
    (3) Admin will then power off cec9 if IBM service needs to replace the adapter and allocate to another octant.

~~~~
       rpower cec9  off
       rpower cec10 off
~~~~

    (4) PE Rep will do physical update to cec9 where the adapter cards and cables is redeployed from the cec9 ocatnt 0 to the cec10 ocatnt 0.
    (5) Admin executes the xCAT commands swapnode command to have I/O node Iocec9n1 to now use FIP node octant 0 of cec10 resources in xCAT DB. The P775A+
    FIP node fipcec10n1 will now take ownership of the bad octant 0.
    It is also a good time to make updates to the FIP node groups fip_defective and fip_available for node "fipcec10n0"

~~~~
         rpower cec9 on
         rpower Iocec9n1 off
         rpower cec10 on
         rpower fipcec10n0 off
         swapnodes -c Iocec9n1 -f fipcec9n5
         chdef -p -t node -o fipcec10n0 groups="fip_defective"
         chdef -m -t node -o fipcec10n0 groups="fip_available"
~~~~

    (6) Admin executes lsvm cec9 and cec10 to note octant resources.

~~~~
         rpower Iocec9n1 on
         rpower fipcec10n0 on
         lsvm    cec9
         lsvm    cec10
~~~~

    (7) Admin setup a new GPFS I/O node in the new GPFS I/O node Iocec9n1 follow the document
[Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]


### Updating and Recovery of BPA/FSP Firmware

The admin should plan to upgrade the firmware for both the Bulk Power Code (BPC), and the CEC firmware. This is accomplished by using the "rflash" xCAT command from the xCAT EMS. The admin should download the supported GFW from the IBM Fix central website, and place it in a directory that is available to be read by the xCAT EMS. The admin will use the "rinv" command to list the current firmware levels and location of the frames and CECs:

#### BPC and GFW Update Scenario

The admin needs to update the BPC and GFW at different times during the life of the P775 cluster. The support of power code and CEC GFW are required when mandatory updates are required to work with the P775 frames. The P775 power code update will usually be a disruptive activity, so the xCAT admin should plan this activity when the cluster can be taken down for maintenance. The support of GFW installation on the P775 CEC may be disruptive during the early stages of the P775 hardware support. It is good practice to check the state of the frame power code and the CEC firmware by executing the rinv command prior to and after the rflash command that executes the BPC and GFW updates to the P775 frame and cecs.

    The admin checks the current levels of the power code being used for the target P775 frame.
    The information provided back for the BPC will contain the following BPC power code data.

~~~~
     rinv frame17 firm
     frame17: Release Level  : 02AP730
     frame17: Active Level   : 042
     frame17: Installed Level: 042
     frame17: Accepted Level : 037
     frame17: Release Level A: 02AP730
     frame17: Level A        : 042
     frame17: Current Power on side A: temp
     frame17: Release Level B: 02AP730
     frame17: Level B        : 042
     frame17: Current Power on side B: temp
    >
    The admin now checks the current levels of the GFW being used for the target P775 CECs.
    The information provided back for the CEC will contain the following GFW firmware data.
     rinv f17c02  firm
     f17c02: Release Level  : 01ZS730
     f17c02: Active Level   : 042
     f17c02: Installed Level: 042
     f17c02: Accepted Level : 036
     f17c02: Release Level Primary: 01ZS730
     f17c02: Level Primary  : 042
     f17c02: Current Power on side Primary: temp
     f17c02: Release Level Secondary: 01ZS730
     f17c02: Level Secondary: 042
     f17c02: Current Power on side Secondary: temp

~~~~


The admin checks in with the IBM service to see if they need to upgrade the P775 BPC power code or CEC GFW. If it is mandated the admin should schedule maintenance time on the P775 cluster to update firmware levels for the frame and cecs. The admin will download the latest supported release power code and GFW available from IBM Fix central. It is important that the admin read the "Release note" information provided with the power code and GFW releases. On occasion there may be a requirement to have a selected power code level that needs to be synchronized when doing an update for CEC firmware level. The admin places the new power code and GFW versions into a selected directory that is located on the xCAT EMS. The admin should power off all of the P775 cecs located on the P775 frame if they plan to upgrade the frame power code. The admin first executes the rflash command to upgrade the frame BPC power code (estimated 45-50 minutes)to completion. The admin now upgrades the GFW firmware level on the target P775 cecs (estimated 75-85 minutes) to completion. If there are issues during the firmware upgrades for power code and firmware, there is a recovery support in rflash that can be used to place the firmware to a previous level documented below.

    (1) rinv  command  was executed above
    (2) Admin creates a /tmp/fw directory on the xCAT EMS, where they can place GFW updateimages.
        Admin downloads the latest P775 power code and GFW from IBM Fix Central http://www-933.ibm.com/support/fixcentral/
        Microcode update package and associated XML files from the IBM Web site:
         Product Group = Power
         Product = Firmware, SDMC, and HMC
         Machine type-model = 9125-F2C
    (3) Admin schedules the appropriate down time for the LPARs, CECs, on the target P775 frames. They shutdown the applications
        and then power off the LPARs and CECs on the cecs for the target frame.

~~~~
         rpower f17lpars off
         rpower f17cecs  off
~~~~

    (4) Admin executes the rflash command with the --activate flag to update the frame power code updates.

~~~~
         rflash frame17 -p /tmp/fw --activate disruptive    (updates frame17 BPC aproximatley 45 mins)
         rinv   frame17 firm                   (Validate BPC power code got updated)
~~~~

    (5) Admin executes the rflash command with the --activate flag to update the CEC GFW updates.

~~~~
         rflash f17cecs -p /tmp/fw --activate disruptive    (updates cecs on frame17 aproximatley 75 mins)
         rinv   f17cecs firm                   (Validate GFW firmware got updated on the cecs)
~~~~

    ** If there are errors during the rflash execution, the admin needs to recover the GFW working with rflash recovery procedure.
    ** The process of recover the BPC power code is similar.


#### BPC and GFW Recovery Scenario

The admin executes firmware updates for BPC and GFW at different times during the life of the P775 cluster. At some point the admin may run into a firmware upgrade failure during the "rflash --activate disruptive" execution. When this happens the xCAT admin needs to run through a procedure to recover from this firmware failure. We anticipate that this flashing firmware failure will happen mostly with P775 cecs, so we have documented the GFW recovery procedure used to recover the P775 system when the firmware is referenced from the permanent side(P-side) instead of the expected temporary side (T-side) "Current Boot Side P/P" which is the expected behavior from the rflash firmware update.

    (1) Admin checks if the current power on side is permanent (P-side) with the rinv command:

~~~~

         rinv cec01 firm   (cec  indicate GFW is using P-side  and not T-side)
~~~~

    (2) Admin executed rspconfig command to first check, and then update to make sure the pending power is on T-side:

~~~~

         rspconfig cec01 pending_power_on_side    (indicates pending_power_on_side=perm)
         rspconfig cec01 pending_power_on_side=temp

~~~~

    (3) Admin needs to remove, then recreate the DFM hardware connection to cec.

~~~~

         rmhwconn cec01
         mkhwconn cec01 -t  (It may take several minutes to complete the CEC HW connection)

~~~~

    (4) Admin validates that the DFM hardware connections indicates a LINE UP state:

~~~~

         lshwconn cec01     (Validate there is a "LINE UP" for cec )

~~~~

    (5) Admin executes the rflash command to recover the P775 cec to be set back to the T-side

~~~~

         rflash  cec01  --recover

~~~~

    (6) Admin checks if the current power on side is now temporary (T-side)

~~~~

         rinv cec01 firm

~~~~

    **  The admin now has the capability to execute the "rflash" command to load in the new GFW update on the P775 cec


### Replace hdisk configuration for GPFS nodes

The P775 admin should reference the GPFS service documentation to replace or change GPFS disk I/O environment.

## Hardware Service Support Activities

In HPC clusters in general, and those specifically using p775 systems, there are certain configuration characteristics that must be maintained in order to maintain customer use of the cluster. These characteristics require you to assess the impact of a service action on running cluster, and determine any preparations required during the service action, and any recovery actions at the cluster level that must be performed after the service action is performed. Hardware service actions may require preparation and recovery procedures that are performed by the system administrator in support of the System Service Representative (SSR). There are several sections below that cover preparation and recovery procedures. The SSR should inform the system administrator regarding the action that he is performing so that the appropriate procedures may be run. The administrator will then go to the appropriate section and review the required preparation procedures and recovery procedures to support the hardware service action.

Preparation actions and procedures are performed before a hardware service action is performed by an SSR.

Recovery actions and procedures are performed after a hardware service action is performed by an SSR.

## Preparation Procedures

The IBM Power 775 preparation procedures of hardware replacement will describe the procedures the admin need to implement ahead of the P775 hardware failures. It will provide procedures for preparation before hardware failures and hardware service actions. In a large cluster, when a hardware failure occurs in the system, the preparation action of some type takes place to make the system possible to recovery from the failing hardware. The expectation is that this section will continue to be updated with additional scenarios when more service and preparation information is known from our P775A+ and service activities. When a service action is performed, you must first consider if it will impact any nodes' function or performance. If it is determined that it will affect the function or performance, there may be a procedure that must be run to first prepare for the impact. Consideration is given on whether the node's function will be taken away during the service action. The following sub-sections describe what must be considered for each node type with respect to functional impacts.

### CEC Down Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of CEC down activities. The admin should first determine the types of nodes in the CEC. Then dump the processor speeds for each node in the CEC drawer and store them. The preparation procedures are different with the different types of node. For a compute node you want to preparation, the procedure is easy, and the steps only contained draining the jobs LoadLeveler and move the compute nodes from LoadL resource pool to make it can be used by LoadL again. But for an non-compute node, the procedure is a little bit complex. See the specified types of node preparation in the below sections.

    (1) Admin checks processor speeds for each node in the CEC drawer and store them

~~~~

         renergy cec1nodes  CPUspeed       (provide CPU speed data for each node in CEC1)

~~~~

    (2) Admin executed xCAT command to determine the node type for each node

~~~~

         lsdef cec1nodes -i groups         (determine the node type from its group)

~~~~



### Compromised SuperNode Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of compromised superNode activities. When a superNode is going to be down, it is important to decide how to handle each node type in the superNode's CECs and act appropriately. Generally, a superNode is down because of an HFI network issue and not because of something that causes all of the CEC drawers associated with the superNode to go down. The admin should first determine the types of nodes in the CEC. The preparation procedures are different with the different types of node.

  * For a compute node you want to preparation, the procedure is easy, and the steps only contained draining the LoadLeveler jobs and move the compute nodes from LoadL resource pool

to make it can be used by LoadL again.

  * For a service node, admin should determine if it is necessary to remove it from operation. Quite often this is not the case, simply because of the reduction of HFI network operation.

If it is the case, reference the section of Service Node Preparation below.

  * For a storage node, because of the impact to HFI network performance, admin should implement the procedure described in the section of the I/O node Preparation below.
  * For a login node, it generally do not require full HFI network performance, no preparation should be necessary, unless the CEC drawer for the login must come down, in which case,

reference the section of Login Node Preparation below.

### Frame Down Preparation ( Non Concurrency )

This section provides the expected xCAT administrator tasks that is required for preparation of frame down activities. These activities are taken when both BPAs are having an issue where the connection of frames are lost.When a full frame of CEC drawers must come down, it is important to determine the types of nodes in the CEC. The preparation procedures are different with the different types of node.

For each CEC drawer perform CEC Down Preparation by reference the section CEC Down Preparation. The admin may wish to perform the referenced node preparation steps for each node type rather than breaking it down by CEC drawer.

    Admin executed xCAT command to determine the node type for each node

~~~~

         lsdef frame1nodes -i groups         (determine the node type from its group)

~~~~



### Frame Down Preparation ( Concurrency )

This section provides the expected xCAT administrator tasks that is required for preparation of frame down activities.These activities are taken when only one BPA need to be replaced. During the replacement of a BPCH, the IBM service representative will prompt the xCAT administrator to perform tasks so the new BPCH becomes managed.

    (1) Archive the xCAT database

~~~~

           /opt/xcat/sbin/dumpxCATdb -p <directory>

~~~~

    (2) Save the current dhcp address assignments (only for AIX):

~~~~

           dadmin -s > /tmp/dhcpsd.out.b4

~~~~

    (3) If possible, record the MAC address from the new BPCH
       You will need to know the xcat node Object Name for the frame where the BPCH is being replaced.
       If the error presented has the serial number, you can obtain the frame name from the query.
       For example,the BPCH MTMS 78AC-100/9920062

~~~~

           lsdef frame -w serial=9920062 | grep Object
        Object name: frame53

~~~~



### Frame Low Power Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of frame low power activities. Frame low power should only have a serious impact on the compute nodes or special utility nodes that require full processor speed. Storage nodes and other types of nodes should be able to absorb the impacts caused by lower power. However, if the frame has a customized node type that is susceptible to issues when the processor speed is less than maximum, it should be treated as a compute node.

Admin should store some important data for later use.


~~~~

     rvitals frame1 all > /tmp/rvresult.txt    (provides rack data for admin and IBM PE)
     renergy f1cecs CPUspeed  > /tmp/speed.txt   (provided CPU speed data for each cec in frame 1)

~~~~



Admin should consider if the the CECs are need to be turn off to save power during the operation.

For all compute nodes in the frame, admin should follow the procedure that Compute Node Preparation procedure.

### Filesystem Down Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of filesystem down activities. If the filesystem is coming down, Toolkit for Event Analysis and Logging (TEAL) product which monitor events and log failures using the Service Focal Point (SFP) through the HMC will alter the admin. Admin should use LoadLeveler to drain all jobs in the cluster, and use GPFS procedures for quiescing the filesystem.

    (1) The P775 admin should first "drain" the compute node octants f1c1ln from LoadL on cec1 if node is still active on a job,
       and then shutdown the bad octant. In most cases the LoadL environment may automatically execute this activity. The admin
       should then vacate "flush" this bad octant so it does not try to restart on the LoadL queue

~~~~

        llctl -h  f1c1ln drain     (drain CN from LoadL)
        llctl -h  f1c1ln flush     (flush CN from LoadL)

~~~~

    (2) The admin should use use GPFS procedures for quiescing the filesystem.
        Reference the GPFS service document http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf


### PCI Resource Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of PCI Resource activities. When a PCI resource (card, cable, interposer) is to be replaced, admin should consider the function it provides and the impact to the cluster of the loss of that function. The activities are different with the hardware types that connected to the PCI adapter.

If the PCI resource is used to connect to a p775 disk enclosure, admin should go back to the hardware service table and look for that resource among the DE FRU Types and follow that procedure. Reference the GPFS service document http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf

If an Ethernet card or SAS card attached to a disk enclosure is used by a Service Node, you must prepare for that service node to go down. Admin should take activities reference the section of Service Node Preparation.

If this PCI resource is an Ethernet card used by a login node, the login node will no longer be accessible. Admin should take activities reference the section of Login Node Preparation.

If the PCI resource is used to connect to a disk enclosure other than a p775 disk enclosure and it is required by the filesystem, follow similar procedures as for the p775 disk enclosure. Typically these will be SAS or Fibre Channel cards. Go back to the hardware service table and look for that resource among the DE FRU Types and follow that procedure. Reference the GPFS service document http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf

### Compute Node Preparation

This section provides the expected xCAT administrator tasks that is required for compute node preparation activities. Before a service action that will impact a compute node, admin should use LoadLeveler to Drain jobs from compute nodes in that frame. If low power mode is entered before the nodes are drained, the administrator may wish to vacate the running jobs. Depending on the checkpoint policy, the jobs may have to restart from the beginning or after the most recent checkpoint.

    (1) The P775 admin should first "drain" the compute node octant f1c1lp25 from LoadL on cec1 if node is still active on a job. In most cases the LoadL environment may automatically execute this
    activity. The admin should then vacate "flush" this bad octant so it does not try to restart on the LoadL queue

~~~~

        llctl -h  f1c1lp25 drain     (drain CN from LoadL)
        llctl -h  f1c1lp25 flush     (flush CN from LoadL)

~~~~

    (2) The admin will then want to remove the bad compute node octant f1c1lp25 from the LoadL "feature" configuration file.
       The admin may want to modify the feature configuration working with generated string, and then make sure the LoadL
       service and compute nodes pickup the new feature configuration file missing the bad octant.

~~~~

        llconfig -N -h f1c1lp25  -d feature
        llconfig -N-h f1c1lp25  -c feature="feature list"
        xdsh llservice llctl reconfig
        xdsh llcompute llrctl reconfig

~~~~

    (3) Admin should store some important data for later use.

~~~~

        rvitals frame1 all > /tmp/rvresult.txt    (provides rack data for admin and IBM PE)
        renergy f1cecs CPUspeed  > /tmp/speed.txt   (provided CPU speed data for each cec in frame 1)

~~~~



### Service Node Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of service node activities. Since the xCAT SN has most of the I/O resources and the complexity software configuration, xCAT admin should take more attention to the SN hardware failure. If there is a PCI adapter failure, admin should consider to move the SN to the backup compute node in the same CEC with other good PCI resource. If there is a harddisk failure, admin may consider to move the SN to to the backup CEC. Admin should run xCAT command snmove to have the compute nodes use the backup xCAT SN.


~~~~

    snmove will change the compute nodes serviced by xcatsn01(with nic eth1) to xcatsn02(with nic eth2)
    snmove -s xcatsn01 -S xcatsn01-eth1 -d xcatsn02 -D xcatsn02-eth1

~~~~



### Storage Node Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of storage node activities. Before a service action that will impact a storage node for GPFS, admin should assure that there is a backup node for that GPFS function that will provide access to the filesystem. If there is not, consider repairing the down backup node first. If there is no alternative to repairing this node, the filesystem will be coming down, admin should take the activities described in the section Filesystem Down Preparation.

    For setting up a GPFS I/O node, reference the document:
[Setting_up_GPFS_in_a_Stateful_Cluster]
[Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]


### Login Node Preparation

This section provides the expected xCAT administrator tasks that is required for preparation of login node activities. Before a service action that will impact a login node, admin should assure that there is a backup login node for users. If the backup, or other login node is down, consider repairing that node first. If it is not possible to repair the other login node(s) first, the cluster will become unavailable to users. Users should be informed, and jobs should be drained.

    For setting up a login node, refer xCAT document:
[Setting_Up_IBM_HPC_Products_on_a_Statelite_or_Stateless_Login_Node]
[Setting_Up_IBM_HPC_Products_on_a_Stateful_Login_Node]


### Other Node Preparation

xCAT only support the node types that are mentioned before, if there is another node type outside of the base node types, correlate it as best the admin can to one of the base types and perform similar actions. Otherwise, admin must develop your own procedure to protect the function of that node type during the service operation.

### Verify backup DE STOR connectivity is available

## Recovery Procedures

The IBM Power 775 recovery procedures of hardware replacement will describe the procedures of the P775 hardware recovered from hardware failures. It will provide procedures for recovery from hardware failures and hardware service actions. In a large cluster, when a hardware failure occurs in the system, a recovery action of some type takes place to allow the system to continue to function without the failing hardware. Although the intention is to provide enough spares at time of deployment to never have to repair these key components, the hardware replacement and repair are unavoidable. The principle of the recovery procedure of hardware replacement is that there is no need for the admin to rebuild the whole procedure of setting up a cluster after the hardware replacement, but only need to take necessary steps to recover back to the status before the hardware failure. The expectation is that this section will continue to be updated with additional scenarios when more service and recovery information is known from our P775A+ and service activities.

### Recover from A+ QCM failure

This section provides the expected xCAT administrator tasks that is required for recovery from A+ QCM failure activities. The admin should first make the processors from deconfiguration status to the configuration status. This can be done with the ASMI (Advanced System Management Interface). This will make the hardware be awared by the firmware. Re-IPL cec is necessary to make this change active. The admin can use xCAT rpower command, and then the node whose QCM is replaced can be recovered. The recovery procedures are different with the different types of node. For a compute node you want to recovery, the procedure is easy, and the steps only contained booting the node and put it into LoadL resource pool to make it can be used by LoadL again. But for an non-compute node, the procedure is a little bit complex. The administrator should also move the nodes recovered from the xCAT node group called "fip_defective". You can use the xCAT chdef command to associate the nodes from the group.

    Aadmin should make the hardware which is replaced be known to the firmware.There are two ways to make the hardware configuration, first is
    use ASMI, the second is use xCAT command "rspconfig procdecfg=configure:processingunit:id". The steps below describes how to set the QCM
    "configuration" through ASMI.
     1.The HMC can be accessed via the keyboard/display that resides in the management rack or by plugging a laptop into the BPCH of the rack
     where the service will be performed. If you chose to plug a laptop into the BPCH refer to "Connecting Laptop to BPCH to access HMC."
     2.Select System Management:
     3.The sub-window will be presented.
      1)Select 'Server', all the servers will be presented
      2)Select the Server (CEC Drawer) whose FRU is being serviced.
      3)Select "Tasks"
      4)Select "Operations"
      5)Select "Launch Advanced System Management (ASM)"
     4.The window shows the IP address will be presented select "OK".
     5.The ASM login window will be presented
      1)Enter User ID. Consult with the system administrator for User ID and password
      2)Enter password
      3)Press "Log in"
     6.Select the + of "System Configuration"
     7.Select "Hardware Deconfiguration"
     8.select " Deconfiguration Policies","Processor Deconfiguration", then configurate the deconfiguration resource.
    The admin needs to Re-IPL the CEC, and make sure that all expected resources are avaialble.

~~~~

      rpower cec1 off
      rpower cec1 on
      lsvm cec1

~~~~

    Then the admin need to determine node type by excuting the xCAT command to require the type of the node whose QCM has been recovered.

~~~~

      lsdef nodename -i groups


~~~~


#### Compute Node Scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with QCM failure. The expectation is that the xCAT admin has noted that the failure of the octant's QCM failure has been recovered. Administrator need to consider to rebuild a new computer node following the steps below.

    (1) If the node is a compute node, you need to boot the node first.

~~~~

     rpower cn1 on

~~~~

    (2) And the admin can use lsvm to check the hardware resource of the compute node, use chdef to remove the node from the group "fip_defective".

~~~~

     lsvm cn1

~~~~

    (3) Then the admin could make compute node to be included in the LoadL resource pool. So that the node can be assigned LoadL job again.

~~~~

     llctl -h  cec1nodes resume

~~~~



#### Login node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with QCM failure. The expectation is that the xCAT admin has noted that the failure of the octant's QCM failure has been recovered. Administrator need to consider to rebuild a new login node following the steps below.

    (1) The admin can use lsvm to check the hardware resource of the compute node, assign the IO to the login node, and use chdef to remove the node from the group "fip_defective".
       Note that when running xCAT "chvm", you should make sure that the node is in "power off" status. You can use "rpower node1 state" to check the node status.

~~~~

       lsvm   logincec3n1 >/tmp/logincec3n1.info
       edit /tmp/logincec3n1.info .. Make updates for octant information, and save file
       cat  /tmp/logincec3n1.info | chvm  logincec3n1.info
       lsvm  logincec3n1

~~~~

    (2) Boot the node. Make sure the login node environments (ssh, HPC) are working properly.

~~~~

       rnetboot logincec3n1
       ssh root@logincec3n1

~~~~

    (3) Once the admin has validated that the P775 login node is running properly, they can schedule the appropriate time to have the users start using the login node.


#### Service node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with QCM failure. The expectation is that the xCAT admin has noted that the failure of the octant's QCM failure has been recovered. Administrator need to consider to rebuild a new service node following the steps below.

    (1) The admin can use lsvm to check the hardware resource of the compute node, assign the IO to the service node, and use chdef to remove the node from the group "fip_defective".
       Note that when running xCAT "chvm", you should make sure that the node is in "power off" status. You can use "rpower node1 state" to check the node status.

~~~~

       lsvm   xcatsn1 >/tmp/xcatsn1.info
       edit /tmp/xcatsn1.info .. Make updates for octant information, and save file
       cat  /tmp/xcatsn1.info | chvm  xcatsn
       lsvm  xcatsn1

~~~~

    (2) Boot the node, make sure the service node environments (ssh, HPC) are working properly.

~~~~

       lsdef xcatsn1       (check all install and SN  attributes)
       rnetboot xcatsn1    (execute network boot to reinstall xcatsn1 on cec2)
       ssh root@xcatsn1   (try to login and validate OS and xCAT commands)

~~~~

    (3) Once the admin has validated that the xCAT SN xcatsn1 is running properly, they can schedule the appropriate time to have the selected compute nodes move from the backup xCAT SN. If the xCAT SN was also
    a LoadL manager server, make sure that LoadL is properly working on the new xCAT SN. The admin should plan to reinstall the diskless compute nodes working with the rebuilt xcatsn1. The P775 admin should
    check that bad FIP node "fipcec2n1" used for xCAT SN  and now defected is not referenced "cec2nodes" node group, and in the LoadL configuration. The admin can then reinstate all the good compute nodes in
    cec1 and cec2 into the LL configuration as good resources .

~~~~

       mkdsklsnode cec1nodes,cec2nodes
       rnetboot  cec1nodes,cec2nodes
       llctl -h  cec1nodes,cec2nodes resume

~~~~



#### GPFS I/O node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with QCM failure. The expectation is that the xCAT admin has noted that the failure of the octant's QCM failure has been recovered. Administrator need to consider to rebuild a new GPFS I/O node following the steps below.

    (1) If the node is a GPFS I/O node, you need to boot the node first.

~~~~

        rpower cn1 on

~~~~

    (2) And the admin can use lsvm to check the hardware resource of the GPFS I/O node, use chdef to remove the node from the group "fip_defective".

~~~~

        lsvm cn1

~~~~

    (3) Admin setup a new GPFS I/O node in the new GPFS I/O node Iocec9n1 follow the document
[Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]





### Recover from A+ HFI Hub failure

This section provides the expected xCAT administrator tasks that is required for recovery from A+ HFI Hub failure activities. The HFI Hub includes switching function and the optical modules. The admin should only consider to rebuild the node. The recovery procedures are different with the different types of node. For a compute node you want to recovery, the procedure is easy, and the steps only contained booting the node and put it into LoadL resource pool to make it can be used by LoadL again. But for an non-compute node, the procedure is a little bit complex. The administrator should also move the nodes recovered from the xCAT node group called "fip_defective". You can use the xCAT chdef command to associate the nodes from the group.

#### Compute node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with HFI Hub failure. The expectation is that the xCAT admin has noted that the failure of the octant's HFI Hub failure has been recovered. Administrator need to consider to rebuild a new computer node following the steps below.

    (1) If the node is a compute node, you need to boot the node first.

~~~~

      rpower cn1 on

~~~~

    (2) And the admin can use lsvm to check the hardware resource of the compute node, use chdef to remove the node from the group "fip_defective".

~~~~

      lsvm cn1

~~~~

    (3) Then the admin could make compute node to be included in the LoadL resource pool. So that the node can be assigned LoadL job again.


#### Login node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with HFI Hub failure. The expectation is that the xCAT admin has noted that the failure of the octant's HFI Hub failure has been recovered. Administrator need to consider to rebuild a new login node following the steps below.

    (1) The admin can use lsvm to check the hardware resource of the compute node, assign the IO to the login node, and use chdef to remove the node from the group "fip_defective".
      Note that when running xCAT "chvm", you should make sure that the node is in "power off" status. You can use "rpower node1 state" to check the node status.

~~~~

      lsvm   logincec3n1 >/tmp/logincec3n1.info
      edit /tmp/logincec3n1.info .. Make updates for octant information, and save file
      cat  /tmp/logincec3n1.info | chvm  logincec3n1.info
      lsvm  logincec3n1

~~~~

    (2) Boot the node. Make sure the login node environments (ssh, HPC) are working properly.

~~~~

      rnetboot logincec3n1
      ssh root@logincec3n1

~~~~

    (3) Once the admin has validated that the P775 login node is running properly, they can schedule the appropriate time to have the users start using the login node.


#### Service node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with HFI Hub failure. The expectation is that the xCAT admin has noted that the failure of the octant's HFI Hub failure has been recovered. Administrator need to consider to rebuild a new service node following the steps below.

    (1) The admin can use lsvm to check the hardware resource of the compute node, assign the IO to the service node, and use chdef to remove the node from the group "fip_defective".
      Note that when running xCAT "chvm", you should make sure that the node is in "power off" status. You can use "rpower node1 state" to check the node status.

~~~~

      lsvm   xcatsn1 >/tmp/xcatsn1.info
      edit /tmp/xcatsn1.info .. Make updates for octant information, and save file
      cat  /tmp/xcatsn1.info | chvm  xcatsn
      lsvm  xcatsn1

~~~~

    (2) Boot the node, make sure the service node environments (ssh, HPC) are working properly.

~~~~

      lsdef xcatsn1       (check all install and SN  attributes)
      rnetboot xcatsn1    (execute network boot to reinstall xcatsn1 on cec2)
      ssh root@xcatsn1   (try to login and validate OS and xCAT commands)

~~~~

    (3) Once the admin has validated that the xCAT SN xcatsn1 is running properly, they can schedule the appropriate time to have the selected compute nodes move from the backup xCAT SN. If the xCAT SN
    was also a LoadL manager server, make sure that LoadL is properly working on the new xCAT SN. The admin should plan to reinstall the diskless compute nodes working with the rebuilt xcatsn1. The P775
    admin should check that bad FIP node "fipcec2n1" used for xCAT SN  and now defected is not referenced "cec2nodes" node group, and in the LoadL configuration. The admin can then reinstate all the
    good compute nodes in cec1 and cec2 into the LL configuration as good resources .

~~~~

      mkdsklsnode cec1nodes,cec2nodes
      rnetboot  cec1nodes,cec2nodes
      llctl -h  cec1nodes,cec2nodes resume

~~~~



#### GPFS I/O node scenario

This P775+ scenario specifies the xCAT admin activity required recover a bad octant with HFI Hub failure. The expectation is that the xCAT admin has noted that the failure of the octant's HFI Hub failure has been recovered. Administrator need to consider to rebuild a new GPFS I/O node following the steps below.

    (1) If the node is a GPFS I/O node, you need to boot the node first.

~~~~

        rpower cn1 on

~~~~

    (2) And the admin can use lsvm to check the hardware resource of the GPFS I/O node, use chdef to remove the node from the group "fip_defective".

~~~~

        lsvm cn1

~~~~

    (3) Admin setup a new GPFS I/O node in the new GPFS I/O node Iocec9n1 follow the document
[Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]


### Frame Down Recovery Procedure ( Non Concurrency )

This section provides the expected xCAT administrator tasks that is required for Frame and BPA recovery activities. The instructions provided below will try to correspond to selected IBM Frame/BPA HW service activities. The expectation is that this section will continue to be updated with additional scenarios when more service and recovery information is known from our service activities.

The xCAT administrator should keep a close watch in regard to P775 Frame activities. It is important that the P775 admin read through the "High Performance Clustering using the 9125-F2C" (P775 Cluster) guide for more detailed Frame/BPA hardware knowledge. The P775 admin will reference P775 hardware events from the Service Focal Point (SFP) that are created on the Hardware Management Console (HMC), and then placed in the Teal tables in the xCAT DB on the xCAT EMS.

The P775 admin activity will be based on the type of P775 Frame/BPA hardware failure. If the Frame needs to be powered down for the service event, this should be a scheduled event working with the IBM Service PE team. The xCAT admin needs to make sure that the P775 nodes located this frame are brought down in an orderly fashion.

    If the P775 frame brought down supports an xCAT service node (SN), you need to bring down the compute nodes being
    served by the xCAT SN. The admin can reference the xCAT SN recovery scenario that is listed in this document if they
    want to execute a fail over the backup xCAT SN.

    If the P775 frame brought down supports a GPFS I/O server node, the P775 admin should reference the GPFS service manuals
    to properly fail over the GPFS environment.


    If the P775 frame brought down only supports compute nodes, the P775 admin can make a decision to temporarily remove
    the compute nodes from the LoadLeveler resource group and run applications without the compute nodes brought down.


Once the Frame has been brought down for service, IBM Service makes the proper hardware updates. The xCAT admin will need to understand what Frame/BPA parts were replaced, to understand if any updates are needed to the xCAT data base. The admin checks the Frame rack status with "rpower frame1 state", and checks if there were changes made BPA ethernet environment or VPD (serial information) working with "lsslp frame1 -m -z". If there are updates found, the admin should execute the "chdef" command to update the Frame and BPA node attributes. The frame in most cases will be powered up to a reduced low power state where the rpower status indicates "Both BPAs at rack standby". There may be additional admin tasks to update BPA information related to the VPD and network communication based on the type of BPC failure. The admin will exit rack standby using "rpower" command, and the expected output for a functional P775 frame should indicate "Both BPAs at standby" The admin should check the current power code level using "rinv" and execute "rflash" command if the frame requires any power code updates. The P775 admin should execute the xCAT "rvitals frame1 rackenv" command to validate frame environment (power, water, temp) is working properly.

When the frame is in a clean state, the admin should make sure that the hardware connections are properly made available for the P775 CECs with mkhwconn/lshwconn for both the lpar/fnm tool type on the frame. The admin should execute xCAT command "lsslp" to see if there are any updates for the the CECs that are located in the frame, and use "chdef" to update any attributes. The P775 admin may need to execute command "chnwsvrconfig" to make sure CNM data is properly loaded in the P775 CEC. The P775 admin may also want to check to see if the P775 CEC requires new GFW firmware loaded while the CECs are powered off. The P775 admin can now power up the P775 CECs and then bring up the xCAT SN, GPFS I/O Server, and all the remaining compute LPARs on the frame. The admin can now allocate all the compute LPARs back into the LoadL environment.

    (1) Admin notices that only one BPA is currently active on frame1 and contacts IBM Service indicating that there is an issue
        with BPCH. IBM service checks SFP failures on HMC, and it indicates that BPA Side B is failing and needs to be replaced.
        The admin schedules the down time with IBM service and cluster users.
    (2) Admin schedules the down time for all LPARs on the frame. This requires all compute node LPARs to be drained from LoadL,
        and any compute nodes in the bad frame can not be scheduled for applications.
        If there is a GPFS I/O server node affected, the admin will want to shutdown all xCAT CNs served by GPFS I/O server, OR
        reference the GPFS documentation to allow a different GPFS server support the compute nodes.
        If there is an xCAT SN affected on the failed frame, the admin will want to shutdown all xCAT CNs served by xCAT SN, OR
        execute a manual xCAT SN fail over using xCAT commands "snmove" to have compute nodes use the backup xCAT SN. These tasks
        are defined in the Hierarchical Cluster documentation in section "Using a backup service node".
[Setting_Up_an_AIX_Hierarchical_Cluster]
[Setting_Up_a_Linux_Hierarchical_Cluster]
    (3) Drain any compute notes found on frame1 and remove compute nodes from the LL resource group. Admin shuts down all LPARs
        using rpower with node group "f1nodes", with other I/O server nodes,then power off all CECs in frame1 node group "f1cecs".

~~~~

        ll command to drain compute nodes
        rpower f1nodes off
        rpower xcatsn1 off
        rpower f1cecs  off

~~~~

    (4) PE Rep will do red switch to frame1 where the BPCH BPA side B is replaced and validates new BPA part is working in frame1.
        The IBM PE service team specifies any new parts that were replaced to the P775 admin.
    (5) The admin checks the current state of frame1 running rpower and lsslp commands. The rpower should note that frame1
        is now in rack_standby which means it is in a low power state where no CECs are powered on. The lsslp command provides
        hardware discovery information about VPD, and network information. Since the BPA was replaced, it will contain a new
        etherent MAC address for BPCH side B BPAs. You should also note that the BPA IPs is now referencing a new dynamic IP.

~~~~

        rpower frame1 state   (will  note "Both BPAs at rack standby"
        lsslp frame1 -m -z    (will proved stanza output for frame1 and related BPAs)

~~~~

        ** Compare lsslp output to the current frame1 BPA node objects, and note any differences **
    (6) Since the BPA  has a different MAC and dynamic IPs, we need to update frame BPA side B node objects attributes "mac" and
        "otherinterfaces" in the xCAT DB. We then need to update the DHCP server on the xCAT EMS to reference the new MAC address
        working with updated BPA node objects. After DHCP is updated, we now can execute an update to the replaced BPA using the
        "rspconfig" command to contain the same "permanent" BPA IPs, and update related passwords used by frame1.

~~~~

         chdef  f1BPAB0 mac=<new lsslp mac> otherinterfaces=<lsslp dynamic IP>  ** keep the ip attribute as permanent BPA IP)


         chdef  f1BPAB1 mac=<new lsslp mac> otherinterfaces=<lsslp dynamic IP>
         makedhcp  frame1    (this will update the DHCP server for changed BPA IPs)
         rspconfig frame1 --resetnet  (this will update BPA IPs to reference BPA permanent IPs)

~~~~

    (7) The admin should check that there were no other updates to the Frame and BPA VPD information. If you note differences,
        make sure that you update the frame1 or BPA node object using the "chdef" command. This will update changes to the "ppc"
        table in the xCAT data base. The admin should execute the "rspconfig" command check that the frame number is correct.
        If it is not, then  rspconfig  can be used to update the frame number. The rspconfig command is also used to update
        the passwords used for FSP  userids HMC, admin, and general.

~~~~

          rspconfig frame1  frame    (provides the listed frame number for BPAs)
          rspconfig frame1  frame=1  (changes the frame number of frame1 to be 1)

~~~~

    (8) The admin should validate the Power code levels of the Frame  with the "rinv" command. This is a good opputunity to update
        new firmware levels for the frame1 using the "rflash" command.

~~~~

         rinv  frame1  firm
         rflash frame1 -p  <GFW location on EMS>  -activate disruptive

~~~~

    (9) The admin now can bring the frame out of rack standby (low power) state by using the "rpower" command. The admin should sync
        in with the IBM Service PE, to check out the rack environmental settings working with "rvitals" command. The IBM PE may need
        to validate that the frame1 is in a good working state.

~~~~

         rpower frame1 exit_rackstandby  (reboots the BPA which may lose connection temporarily,and brings out of low power)
         rpower frame1 state         (after a few minutes, look for BPA state  "Both BPAs at standby"
         rvitals  frame1 all       (provide rack data for admin and IBM PE)

~~~~

         **  we should leave the frame 1 cecs in a power off state at this time  **
    (10)The admin will now make the proper HW connections from the xCAT EMS  and the frame1 BPAs and CECs (FSPs) by executing
        the "mkhwconn" command for both the lpar (default) and fnm tool types. You validate that the HW connection by using the

~~~~

        "lshwconn" which will indicate "Line UP" if the connections are good.
         mkhwconn frame1  -t        (make connections to frame1 BPAs and CECs for xCAT EMS)
         mkhwconn frame1  -t -T fnm   (make connections to frame1 BPAs and CECs from xCAT EMS for CNM)
         lshwconn frame1           (validates line up or errors for xCAT lpar tool type)
         lshwconn frame1  -T fnm   (validates line up or error for CNM fnm tool type)

~~~~

    (11)As we did with the frame, the admin should validate the LIC firmware levels for the frame 1 CECs. The admin may want to
        update new firmware levels for the frame1 CECs using the "rflash" command with cec node group "f1cecs".

~~~~

         rinv  f1cecs  firm
         rflash f1cecs -p  <GFW location on EMS>  -activate disruptive

~~~~

    (12)The admin should check and see if the CNM environment is properly set on the frame and CECs. If not, then admin needs to
        execute the CNM "chnwsvrconfig" command to make sure CNM Master ID data is loaded in the P775 CECs.
         /opt/isnm/cnm/bin/lsnwloc                 (checks for all active CNM connections)
         /opt/isnm/cnm/bin/chnwsvrconfig -f 1 -c 3   (configures cec 1 in frame 1 with Master ID data)
         ** You should execute load or Master ID  for cages 3-14 (CECs 1-12) in frame
    (13)The admin should now power up  all the frame1 CECs, then we need to activate the xCAT SN LPAR to be in a working state.
        The admin may also need to bring up the GPFS I/O server node referencing the GPFS documentation.

~~~~

         rpower f1cecs  onstandby
         rpower xcatsn1 on

~~~~

         ** Admin should check to make sure that xCAT SN is in a good working state.
    (14)The admin can then bring up the xCAT compute nodes after the xCAT SN and GPFS I/O servers are in a working state.
         After the nodes are up in a working state, you may now be able to schedule these nodes to LoadL pool.

~~~~

         rbootseq f1nodes hfi
         ll commands to setup compute nodes in LoadL pools

~~~~



### BPA Down Recovery Procedure

This section provides the expected xCAT administrator tasks that is required for Frame and BPA recovery activities. These activities are taken when only one BPA need to be replaced. If both BPAs are having an issue where the connection of frames are lost please refer to the section Frame Down Recovery Procedure( Non Concurrency ). The instructions provided below will try to correspond to selected IBM Frame/BPA HW service activities. The expectation is that this section will continue to be updated with additional scenarios when more service and recovery information is known from our service activities.

Before replacing the BPCH, admin should first determine the IP address of the defective BPCH, then release the IP address (DHCP lease) of the BPCH and verify the IP address has been released.

     During the process of replacing a defective BPC-H on a P775 frame,
     the IBM Service Representative will ask the xCAT administrator
     to run commands on the EMS to maintain management of the frame
     and its hardware components.

     If you have not recently archived your xcat database, do so now:

~~~~

     /opt/xcat/sbin/dumpxCATdb  -p <archive directory>

~~~~


    (1) Determine the frame name and side where the IBM Service Representative
     will be replacing the BPC-H. In this example, we are replacing the B-side
     BPCH for frame62.

     If there is redundant connectivity, there will be four BPA connections which
     can be view in the xcat database with the command:


~~~~

     /tmp/BPCH>  lsdef -z -S bpa -w parent=frame62

~~~~


     You will notice either two objects with side attributes, A-0 and B-0
     or four objects with side attributes A-0, A-1, B-0 and B-1.

     Save the current IP information for the frame and side for reference later.


~~~~

     /tmp/BPCH>  lsdef -z -S bpa -w parent=frame62 -w side=B-0 > frame62.B-0.bpa
     /tmp/BPCH> cat frame62.B-0.bpa
     # <xCAT data object stanza file>

     40.62.0.2:
         objtype=node
         groups=bpa,all
         hcp=40.62.0.2
         hidden=1
         hwtype=bpa
         id=62
         ip=40.62.0.2
         mac=00:1a:64:54:ef:1a
         mgt=bpa
         mtm=78AC-100
         nodetype=ppc
         otherinterfaces=40.62.0.2
         parent=frame62
         serial=992005X
         side=B-0

~~~~


     If there is redundant connections to your frames, there will also be a B-1 side:


~~~~

     /tmp/BPCH> lsdef -z -S bpa -w parent=frame62 -w side=B-1 > B1.out
     /tmp/BPCH> cat B1.out
     # <xCAT data object stanza file>

     41.62.0.2:
         objtype=node
         groups=bpa,all
         hcp=41.62.0.2
         hidden=1
         hwtype=bpa
         id=62
         ip=41.62.0.2
         mac=00:1a:64:54:ef:1b
         mgt=bpa
         mtm=78AC-100
         nodetype=ppc
         otherinterfaces=41.62.0.2
         parent=frame62
         serial=992005X
         side=B-1

~~~~


     (2)After the power is removed to the BPC-H, the xCAT administrator will be asked to release the IP address for both sides:

     Release the DHCP allocated IP address on Linux or AIX:

~~~~

       /tmp/BPCH> makedhcp -d <bpa ip address side B-0>
       /tmp/BPCH> makedhcp -d <bpa ip address side B-1>

~~~~


     Verify release of IP address on Linux:

~~~~

       /tmp/BPCH> service dhcpd restart

~~~~

     Verify the IP addresses are released, grep for each IP address in /var/lib/dhcpd/dhcpd.leases
     and verify there are no entries for the IP addresses in the lease file.


       Verify release of IP address on AIX:
       Check to see it the addresses have been freed:

~~~~

         dadmin -s | grep <bpa ip address>

        40.62.0.2     Free
       /tmp/BPCH> dadmin -s | grep 41.62.0.2
        41.62.0.2     Free

       /tmp/BPCH> dadmin -s | grep 40.62.0.2

~~~~




      At this point power is removed and the IP address is released.

      (3) Verify the state of the frame only shows the active side.

~~~~

       /tmp/BPCH>  lsslp frame62 -s FRAME -m
       device  type-model  serial-number  side  ip-addresses  hostname
       BPA     78AC-100    992005X        A-0   40.62.0.1     40.62.0.1
       BPA     78AC-100    992005X        A-1   41.62.0.1     41.62.0.1
       FRAME   78AC-100    992005X                            frame62

~~~~


     Indicate to the IBM Service Representative the IP address is released
     and the procedure can continue.

     **AFTER POWER IS RESTORED, ENTER THE NEW FRU MAC ADDRESS INTO THE DATABASE ON THE EMS**

     After IBM representative restores power to the BPR, there will be
     a prompt to update the MAC address into the database on the EMS.


     (4) It will take several minutes for the new BPC-H to request an
     IP address. Run the following command until you see information
     on the side that was replaced:


~~~~

     [root@c250mgrs35 B-side]# lsslp frame62 -s FRAME -m
     device  type-model  serial-number  side  ip-addresses  hostname
     BPA     78AC-100    992005X        A-0   40.62.0.1     40.62.0.1
     BPA     78AC-100    992005X        B-0   40.1.0.2      40.62.0.2
     BPA     78AC-100    992005X        A-1   41.62.0.1     41.62.0.1
     BPA     78AC-100    992005X        B-1   41.1.0.2      41.62.0.2
     FRAME   78AC-100    992005X                            frame62

~~~~


     You can either update your exising "bpa" stanzas, or create new
     stanza's for the entire frame.

     If you are unsure what course to take, compare the following
     information.

     Gather the actual frame information:

~~~~

     lsslp frame62 -s FRAME -m -z > /tmp/lsslp.frame62.z

~~~~


     Dump the xcat database information:

~~~~

     > lsdef -S bpa -w parent=parent62 -z > /tmp/lsdef.frame62.z

~~~~


     Compare stanzas, for instance:

~~~~

     # <xCAT data object stanza file>

     40.62.0.2:
         objtype=node
         groups=bpa,all
         hcp=40.62.0.2
         hidden=1
         hwtype=bpa
         id=62
         ip=40.62.0.2
         mac=00:1a:64:54:ef:1a
         mgt=bpa
         mtm=78AC-100
         nodetype=ppc
         otherinterfaces=40.62.0.2
         parent=frame62
         serial=992005X
         side=B-0

     40.62.0.2:
             objtype=node
             hcp=40.62.0.2
             nodetype=ppc
             mtm=78AC-100
             serial=992005X
             side=B-0
             ip=40.1.0.2
             groups=bpa,all
             mgt=bpa
             id=0
             parent=frame62
             mac=00:1a:64:54:ef:1a
             hidden=1
             otherinterfaces=40.1.0.2
             hwtype=bpa

~~~~



     It is easier if you can use the actual information to update xcat.
     This can simply be done by running:

~~~~

      > lsslp frame62 -s FRAME -m -z -w

~~~~


     (5)If the xCAT information is customized, you will need to
     update the "mac" and "otherinterfaces" attributes. This is
     done by taking the actual attributes from lsslp and updating
     them in the xCAT database:

~~~~

      /tmp/BPCH> chdef 40.62.0.2 mac=00:1a:64:54:ef:1a otherinterfaces=40.1.0.2
      /tmp/BPCH> chdef 41.62.0.2 mac=00:1a:64:54:ef:1b otherinterfaces=41.1.0.2

~~~~



     (6) Remake the DHCP entries for the frame with the mac address:

~~~~

          makedhcp frame62

~~~~



     (7) Reset the BPA IP information to the desired settings:

~~~~

     /tmp/BPCH> rspconfig 41.62.0.2,40.62.0.2 --resetnet

~~~~


     Start to reset network..

     Reset network failed nodes:

     Reset network succeed nodes:
     41.62.0.2,40.62.0.2

     Reset network finished.

     This will take several minutes to complete. You can verify
     the update has completed by pinging the new IP addresses.


~~~~


     /tmp/BPCH> lsslp frame62 -s FRAME -m
     device  type-model  serial-number  side  ip-addresses  hostname
     BPA     78AC-100    992005X        A-0   40.62.0.1     40.62.0.1
     BPA     78AC-100    992005X        B-0   40.62.0.2     40.62.0.2
     BPA     78AC-100    992005X        A-1   41.62.0.1     41.62.0.1
     BPA     78AC-100    992005X        B-1   41.62.0.2     41.62.0.2
     FRAME   78AC-100    992005X                            frame62

     (8) Verify the hardware connections are up:
     [root@c250mgrs35 B-side]# lshwconn frame62
     frame62: side=a,ipadd=40.62.0.1,alt_ipadd=41.62.0.1,state=LINE UP
     frame62: side=b,ipadd=40.62.0.2,alt_ipadd=41.62.0.2,state=LINE UP

~~~~


     (9) At this point inform the IBM Service representative to continue
     the replace procedure.

     (10) When the IBM Service Representative has completed the procedure,
     verify the firmware on both sides is the same.

~~~~

     rinv frame62 firm
     frame62: Release Level  : 02AP730
     frame62: Active Level   : 065
     frame62: Installed Level: 065
     frame62: Accepted Level : 054
     frame62: Release Level A: 02AP730
     frame62: Level A        : 065
     frame62: Current Power on side A: temp
     frame62: Release Level B: 02AP730
     frame62: Level B        : 065
     frame62: Current Power on side B: temp

~~~~

     If there is a difference between the firmware level on each side, follow the procedure for updating the frame firmware.


### Frame Low Power Recovery Procedure

The xCAT administrator should keep a close watch in regard to P775 Frame activities. The P775 admin will reference P775 hardware events from the Service Focal Point (SFP) that are created on the Hardware Management Console (HMC), and then placed in the Teal tables in the xCAT DB on the xCAT EMS. 

There are conditions with the BPC where there is a bad line connection that has placed P775 frame in to a "Frame Low Power State". This low power state may limit the CPU processing available to the P775 CECS, so the P775 admin needs to make a decision if the CECs can perform for properly for applications while the IBM PE fixes the BPC issue while the Frame and cecs continue to run. The admin should execute the xCAT rvitals and rpower commands to the frame to see if the power status and the rack environmental data looks appropriate.
The P775 admin executes the "renergy" command to gain the environmental data for all the CECs located in the frame.

The admin should synchronize with the IBM Service PE, to check out the rack environmental settings working with "rvitals" command to validate that the frame1 is in a good working state. The admin can execute rpower  to gain the status that both BPAs  are available at standby state. The P775 admin can also execute the "renergy" command to gain the environmental  data for all the CECs located in the frame.

~~~~

   rpower frame1 state         (Look for BPA state  "Both BPAs at standby")
    rvitals  frame1 all       (provides rack data for admin and IBM PE)
    renergy f1cecs  CPUspeed       (provided CPU speed data for each cec in frame 1)

~~~~



### CEC Recovery Procedure

This section provides the expected xCAT administrator tasks that is required for CEC/FSP recovery activities. The instructions provided below will try to correspond to selected IBM CEC/FSP HW service activities. The expectation is that this section will continue to be updated with additional scenarios when more service and recovery information is known from our service activities. The xCAT administrator should keep a close watch in regard to P775 Frame and CEC activities. It is important that the P775 admin read through the "High Performance Clustering using the 9125-F2C" (P775 Cluster) guide for more detailed CEC/FSP hardware knowledge. The P775 admin will reference P775 hardware events from the Service Focal Point (SFP) that are created on the Hardware Management Console (HMC), and then placed in the Teal tables in the xCAT DB on the xCAT EMS.

The P775 admin activity will be based on the type of P775 CEC/FSP hardware failure. If the CEC needs to be powered down for the service event, this should be a scheduled event working with the IBM Service PE team. The xCAT admin needs to make sure that the P775 nodes located this CEC are brought down in an orderly fashion.

    If the P775 CEC brought down supports an xCAT service node (SN), you need to bring down the compute nodes being served
    by the xCAT SN. The admin can reference the xCAT SN recovery scenario that is listed in this document if they want to
    execute a xCAT SN fail over to the backup xCAT SN.


    If the P775 CEC brought down supports a GPFS I/O server node, the P775 admin should reference the GPFS service manuals
    to properly fail over the GPFS environment.


    If the P775 CEC brought down only supports compute nodes, the P775 admin can make a decision to temporarily remove the
    compute nodes from the LoadLeveler resource group and run applications without the compute nodes brought down.


Once the CEC has been brought down for service, IBM Service makes the proper hardware updates. The xCAT admin will need to know what CEC/FSP parts were replaced, to better understand if any updates are needed to the xCAT data base. The admin checks the CEC status with "rpower cec1 state", and checks if there were changes made FSP ethernet environment or VPD (serial information) working with "lsslp cec1 -m -z". There may be additional admin tasks to update CEC/FSP information related to the VPD and network communication. The admin should check the current LIC firmware level using "rinv" and execute "rflash" command if the frame requires any firmware updates.

When the cec is in a clean state, the admin should make sure that the hardware connections are properly made available for the P775 CEC with mkhwconn/lshwconn for the lpar/fnm tool type. The P775 admin may need to execute command "chnwsvrconfig" to make sure CNM data is properly loaded in the CEC. The admin should execute the "renergy" command to the cec, and make sure the CEC environmental data is set properly. The admin should validate the CEC assigned I/O resources working with "lsvm" and if changes are required work with "chvm" command. The P775 admin can now power up the P775 CEC, and then bring up the xCAT SN, GPFS I/O Server, and compute LPARs on the cec. The admin can now allocate all the compute LPARs back into the LoadL environment.




    (1) Admin notices that only one FSP is currently active on cec1 and contacts IBM Service indicating that there is an issue
        with FSP2. IBM service checks SFP failures on HMC, and it indicates that a FSP2 is failing and needs to be replaced.
        The admin schedules the down time with IBM service and cluster users.
    (2) Admin schedules the down time for all LPARs on the cec1. This requires all compute node LPARs to be drained from LoadL,
        and any compute nodes in the bad cec can not be scheduled for applications.
        If there is a GPFS I/O server node affected, the admin will want to shutdown all xCAT CNs served by GPFS I/O server, OR
        reference the GPFS documentation to allow a different GPFS server support the compute nodes.
        If there is an xCAT SN affected on the failed cec, the admin will want to shutdown all xCAT CNs served by xCAT SN, OR
        execute a manual xCAT SN fail over using xCAT commands "snmove" to have compute nodes use the backup xCAT SN. These tasks
        are defined in the Hierarchical Cluster documentation in section "Using a backup service node".
[Setting_Up_an_AIX_Hierarchical_Cluster]
[Setting_Up_a_Linux_Hierarchical_Cluster]
    (3) Drain any compute notes found on cec1 and remove compute nodes from the LL resource group. Admin shuts down all LPARs
        using rpower with node group "cec1nodes", then take down other I/O server nodes,then power off all cec1.

~~~~

        llctl -h cec1nodes drain
        rpower cec1nodes off
        rpower xcatsn1 off
        rpower cec1  off

~~~~

    (4) PE Rep will execute debug where it is noted that the FSP is replaced and validates new FSP part is working in cec1.
        The IBM PE service team specifies any new parts that were replaced to the P775 admin.
    (5) The admin checks the current state of cec1 running rpower and lsslp commands. The rpower should note that cec1
        is now in power off state. If replacing the FSP on the cec, the admin should remove the hardware connection to the cec
        from the xCAT EMS. The lsslp command provides hardware discovery information about VPD, and network information.
        Since the FSP was replaced, it will contain a new ethernet MAC address for FSPs. You should also note that the FSP IPs
        is now referencing a new dynamic IP.

~~~~

        rpower cec1 state   (will note power off)
        rmhwconn cec1       (remove HW connection for cec1)
        lsslp cec1 -m -z    (will proved stanza output for cec1 and related FSP)

~~~~

        ** Compare lsslp output to the current cec1 FSP node objects, and note any differences **
    (6) Since the FSP has a different MAC and dynamic IPs, we need to update cec1 FSP node objects attributes "mac" and
        "otherinterfaces" in the xCAT DB. We then need to update the DHCP server on the xCAT EMS to reference the new MAC address
        working with updated FSP node objects. After DHCP is updated, we now can execute an update to the replaced FSP using the
        "rspconfig" command to contain the same "permanent" FSP IPs, and update related passwords used by cec1.

~~~~

         chdef  f1c1fsp2a mac=<new lsslp mac> otherinterfaces=<lsslp dynamic IP>  ** keep the ip attribute as permanent FSP IP)

~~~~


~~~~

         chdef  f1c1fsp2b mac=<new lsslp mac> otherinterfaces=<lsslp dynamic IP>
         makedhcp  cec1    (this will update the DHCP server for changed FSP IPs)
         rspconfig cec1 --resetnet  (this will update FSP IPs to reference FSP permanent IPs)
         lsslp cec1  -m     (keep checking with lsslp to see when permanent IPs are active on the FSP)
         rspconfig cec1  <id>_passwd=,<your pw>  (update passwords for  HMC, admin, general)

~~~~

    (7) The admin should check that there were no other updates to the CEC VPD information. If you note differences,
        make sure that you update the cec1 or FSP node object using the "chdef" command. This will update changes to the "ppc"
        table in the xCAT data base.
    (8) The admin will now make the proper HW connections from the xCAT EMS to the cec1 FSPs by executing
        the "mkhwconn" command for both the lpar (default) and fnm tool types. You validate that the HW connection by using the

~~~~

        "lshwconn" which will indicate "Line UP" if the connections are good.
         mkhwconn cec1  -t        (make connections to CECs for xCAT EMS)
         mkhwconn cec1  -t -T fnm   (make connections to CECs from xCAT EMS for CNM)
         lshwconn cec1           (validates line up or errors for xCAT lpar tool type)
         lshwconn cec1  -T fnm   (validates line up or error for CNM fnm tool type)

~~~~

(9) The admin should validate the lic firmware levels of the cec with the "rinv" command. If the admin needs to update   new firmware levels for the cec1 using the "rflash" command.

~~~~
         rinv  cec1  firm
         rflash cec1 -p  <GFW location on EMS>  -activate disruptive
~~~~

(10)The admin should check and see if the CNM environment is properly set on the cec1. If not, then admin needs to  execute the CNM "chnwsvrconfig" command to make sure CNM Master ID data is loaded in the cec1.

~~~~
         /opt/isnm/cnm/bin/lsnwloc                 (checks for all active CNM connections)
         /opt/isnm/cnm/bin/chnwsvrconfig -f 1 -c 3   (configures cec1 in frame 1 with Master ID data)
~~~~

(11)The admin powers up cec1 to standby so resources can be seen. He executes lsvm cec1 to note octant resources. If changes  are needed, admin executes lsvm on selected node (xcatsn1) to produce an output file, then updates file to represent proper  I/O setting. Admin then executed inputs the file working with chvm command.

~~~~

         rpower  cec1 onstandby
         lsvm    cec1
         lsvm   xcatsn1 >/tmp/xcatsn1.info
         edit /tmp/xcatsn1.info .. Make updates for octant information, and save file
         cat  /tmp/xcatsn1.info | chvm  xcatsn
         lsvm  xcatsn1

~~~~

    (12)The admin should power the CEC on and execute the renergy command to list and change the cec1 environmental values.

~~~~

         rpower cec1 on
         renergy  cec1 all    (this will list various CEC power and CPU settings)

~~~~

    (13)The admin should now activate the xCAT SN LPAR to be in a working state.
        The admin may also need to bring up the GPFS I/O server node referencing the GPFS documentation.
         rpower xcatsn1 on
         ** Admin should check to make sure that xCAT SN is in a good working state.
    (14)The admin can then bring up the xCAT compute nodes after the xCAT SN and GPFS I/O servers are in a working state.
         After the nodes are up in a working state, you may now be able to schedule these nodes to LoadL pool.

~~~~

         rbootseq cec1nodes hfi
         ll commands to setup compute nodes in LoadL pools


~~~~





### PCI Resource Recovery

This section provides the expected xCAT administrator tasks that is required for recovery from replacing a PCI resource. Admin should consider the function it provides and the impact to the cluster of the loss of that function, and how to recover the function after it has been repaired.

  * If the PCI resource is used to connect to a p775 disk enclosure, admin should go back to the hardware service table and look for that resource

among the DE FRU Types and follow that procedure. Reference GPFS document http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf

  * If an Ethernet card or SAS card attached to a disk enclosure is used by a Service Node, admin need to recover service node using service node recovery procedure. Admin should take activities reference the section of Service Node recovering.
  * If this PCI resource is an Ethernet card used by a login node, the login node will no longer be accessible. Admin should take activities reference the section of Login Node Recovery Procedure.
  * If the PCI resource is used to connect to a disk enclosure other than a p775 disk enclosure and it is required by the filesystem, follow similar procedures as for the p775 disk enclosure. Typically these will be SAS or Fibre Channel cards. Go back to the hardware service table and look for

that resource among the DE FRU Types and follow that procedure. Reference GPFS document http://publib.boulder.ibm.com/epubs/pdf/a7604134.pdf

  * If this is some other sort of PCI resource, consider the following:

o How do you test to be sure that the resource is visible to the operating system instance (LPAR) that needs it? o How do you test to be sure that the resource is fully functional and providing the intended function? o How is function restored to this resource if there was a failover to a redundant resource during the preparations or the service action? Is it automatic? Is it manual? o Consider looking over some of the procedures for other PCI resources for example recovery procedures.

### Compute Node Recovery Procedure

This section provides the expected xCAT administrator tasks that is required for recovery from hardware failure activities after the service activities. Admin should deploy OS to the node and issue LoadLeveler command to resume use of the compute nodes for jobs.

    (1) If the node is a compute node, you need to boot the node first.

~~~~

         rpower cn1 on

~~~~

    (2) And the admin can use lsvm to check the hardware resource of the compute node, use chdef to remove the node from the group "fip_defective".

~~~~

         lsvm cn1

~~~~

    (3) Then the admin could make compute node to be included in the LoadL resource pool. So that the node can be assigned LoadL job again.

~~~~

         llctl -h  cec1nodes resume

~~~~



### Service Node Recovery Procedure

This section provides the expected xCAT administrator tasks that is required for recovery service node from hardware failure activities. After a service action that impacts an xCAT service node, the admin should consider if the service node's Ethernet card or CEC drawer's DCCA was replaced, and consider to use the CEC Config Recovery Procedure. If the service node.s disk was replaced, admin should rebuild the service node image.
*  If the hardware failure is about ethernet or DCCA, admin should implement the procedure of CEC Config Recovery Procedure. The service node can be rebuild in the same CEC by following the steps below:
(1) Admin powers up cec1 to standby so resources can be seen. He executes lsvm cec1 to note octant resources. If changes are needed, admin executes lsvm on xCAT SN to produce output file, then updates file to represent proper I/O setting.
Admin then executed inputs the file working with chvm command.

~~~~

  rpower  cec1 onstandby
  lsvm    cec1
  The steps below(lsvm, chvm) are only needed if the two nodes are in different CEC.
  lsvm  xcatsn1

~~~~

(2) Admin executes "getmacs"  command to retrieve the new MAC address of the new ethernet adapter. Make sure this MAC address  is placed in the xcatsn1 node object. The admin will want to recreate xcatsn1 nim object to reflect new MAC interface if
       working with AIX cluster.

~~~~
  getmacs  xcatsn1 -D
  lsdef xcatsn1 -i mac
  xcat2nim xcatsn1 -f  (AIX only)

~~~~

(3) Since the disk subsystem was not affected, there is a good chance that you should be able to power up the xCAT SN and other  compute  node octants located on the cec1. The admin should do a thorough checkout making sure all xCAT xCAT SN  environments (ssh, DB2, and installation) are working properly.  It is a good test to execute xCAT updatenode command against the xCAT SN.  If the xCAT SN is not working properly, the admin may want to do a reinstall on the xCAT SN.

~~~~
   rpower xcatsn1  on
   ssh root@xcatsn1   (try to login and validate OS and xCAT commands)
   updatenode  xcatsn1

~~~~

(4) Once the admin has validated that the xCAT SN xcatsn1 is running properly, they can schedule the appropriate time to execute
       manual xCAT SN fail over task to have the selected compute nodes move from the backup xCAT SN.  If the xCAT SN was also a
       LoadL manager server, make sure that LoadL is properly working on the new xCAT SN. The admin should plan to reinstall the
       diskless compute nodes working with the rebuilt "xcatsn1". The P775 admin should check that bad FIP node "fipcec1n5" used f
       or xCAT SN  and now defected is not referenced in "cec1nodes" xCAT node group, and in the LoadL configuration.
       The admin can then reinstate all the good compute nodes in cec1 into the LL configuration as good resources.

~~~~

         mkdsklsnode cec1nodes
         rnetboot  cec1nodes
         llctl -h  cec1nodes resume


~~~~


    *  If the hardware failure is about  disk action, , admin should implement the procedure of CEC Config Recovery Procedure. The service node can be rebuild in the backup CEC by following the steps
    below with the rebuild of the service node image:
(1) Admin powers up cec1 and cec2 so resources can be seen. He executes lsvm cec2 to note octant resources. If changes
       are needed, admin executes lsvm on xCAT SN to produce output file, then updates file to represent proper I/O setting.
       Admin then executed inputs the file working with chvm command.

~~~~

        rpower  cec1,cec2 on
        lsvm    cec2
        lsvm   xcatsn1 >/tmp/xcatsn1.info
        edit /tmp/xcatsn1.info .. Make updates for octant information, and save file
        cat  /tmp/xcatsn1.info | chvm  xcatsn
        lsvm  xcatsn1

~~~~

(2) Admin executes "getmacs"  command to validate that proper MAC address of the ethernet adapter is found. Make sure this  MAC address is placed in the xcatsn1 node object. The admin will want to recreate xcatsn1 nim object to reflect new MAC  interface if working with AIX cluster.

~~~~

         getmacs  xcatsn1 -D
         lsdef xcatsn1 -i mac
         xcat2nim xcatsn1 -f  (AIX only)

~~~~

(3) Since the disk subsystem was affected, we will need to reinstall the xCAT SN xcatsn1 on the new disk. The admin will need to validate all of the service node and installation attributes are properly defined. The admin executes a diskful installation on the xCAT SN. Please reference the proper xCAT SN Hierarchical Cluster documentation.The admin should do a thorough checkout making sure all xCAT xCAT SN environments (ssh, DB2, and installation) are working properly after the xCAT SN installation.

~~~~

   lsdef xcatsn1       (check all install and SN  attributes)
   rnetboot xcatsn1    (execute network boot to reinstall xcatsn1 on cec2)
   ssh root@xcatsn1   (try to login and validate OS and xCAT commands)

~~~~

(4) Once the admin has validated that the xCAT SN xcatsn1 is running properly, they can schedule the appropriate time to execute manual xCAT SN fail over task to have the selected compute nodes move from the backup xCAT SN. If the xCAT SN was also a LoadL manager server, make sure that LoadL is properly working on the new xCAT SN. The admin should plan to reinstall the diskless compute nodes working with the rebuilt xcatsn1. The P775 admin should check that bad FIP node "fipcec2n1" used for xCAT SN  and now defected is not referenced "cec2nodes" node group, and in the LoadL configuration. The admin can then reinstate all the good compute nodes in cec1 and cec2 into the LL configuration as good resources .

~~~~

         mkdsklsnode cec1nodes,cec2nodes
         rnetboot  cec1nodes,cec2nodes
         llctl -h  cec1nodes,cec2nodes resume

~~~~



### Storage Node Recovery Procedure

This section provides the expected xCAT administrator tasks that is required for recovery GPFS I/O node from hardware failure activities. After a service action that impacts an xCAT storage node, the admin should consider to use GPFS to check accessibility to all disks to which the storage node is connected.

    *  For rebuilding a new GPFS I/O node, admin should use xCAT command rpower on. Then use command lsvm to check the hardware information.
    (1) Admin executes deploy the OS for the note octant first.

~~~~

        rpower Iocec9n1 on

~~~~

    (2) Admin executes lsvm Iocec9n1 to note octant resources.

~~~~

       lsvm    Iocec9n1

~~~~

    (3) Admin setup a new GPFS I/O node in the new GPFS I/O node Iocec9n1 follow the document
[Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]
[Setting_up_GPFS_in_a_Stateful_Cluster]


### Login Node Recovery Procedure

This section provides the expected xCAT administrator tasks that is required for recovery login node from hardware failure activities. After a service action that impacts an xCAT login node, the admin should log into the login node and determine if users operations can be performed properly.

    *  For rebuilding a new login node, admin should use xCAT command rpower on. Then use command lsvm to check the hardware information.
    (1) Admin executes deploy the OS for the note octant first.

~~~~

         rpower logincec3n1 on

~~~~

    (2) Admin executes lsvm cec3 to note octant resources. If changes are needed, admin executes lsvm on xCAT SN to produce output file, then updates file to represent proper I/O setting.
       Admin then executed inputs the file working with chvm command.

~~~~

        lsvm    cec3
        lsvm    logincec3n1
        The steps below(lsvm, chvm) are only needed if the two nodes are in different CEC.
        lsvm   logincec3n1 >/tmp/logincec3n1.info
        edit /tmp/logincec3n1.info .. Make updates for octant information, and save file
        cat  /tmp/logincec3n1.info | chvm  logincec3n1.info
        lsvm  logincec3n1

~~~~

    (3) Admin executes "getmacs"  command to retrieve the new HFI MAC address of the new HFI adapter. Make sure this MAC address is placed in the logincec3n1 node object. The admin will want to double
    check   all the installation settings are properly set, and then recreate logincec3n1 on the xCAT SN to reflect new HFI MAC and ethernet for the node installation.

~~~~

         getmacs  logincec3n1
         lsdef logincec3n1
         mkdsklsnode -f logincec3n1  (For AIX)
         nodeset logincec3n1 netboot (For Linux)

~~~~

    (4) The admin should execute diskless node install for the P775 login node using the new octant. Make sure the login node environments (ssh, HPC) are working properly.

~~~~

          rnetboot logincec3n1
          ssh root@logincec3n1   (try to login and validate OS and xCAT command)

~~~~

    (5) Once the admin has validated that the P775 login node is running properly, they can schedule the appropriate time to have the users start using the login node.


### Other Node Type Recovery Procedure

xCAT only support the node types that are mentioned before, if there is another node type outside of the base node types, correlate it as best the admin can to one of the base types and perform similar actions. Otherwise, admin must develop your own procedure to protect the function of that node type during the service operation.

### Swapping node images

This section provides the expected xCAT administrator tasks that is required for swapping node images.In the EMS, xCAT admin can define several images, and deploy the image the one he prefer to the specified nodes. If he want to swap the image for a specified node, he can use xCAT command nimnodeset(for AIX) or nodeset(for Linux) to do it. After specifying the node image, the node need to be reinstall to use the new image.

    (1) Admin use xCAT command to specify the image to the node node1.
        For Linux, admin should excute nodeset

~~~~

          nodeset node1 install

~~~~

        For AIX, admin should excute nimnodeset to swap the node image to a existed image:Imagename.

~~~~

          nimnodeset -i Imagename node1

~~~~

    (2) Admin use xCAT command to reinstall node1.

~~~~

          rpower node1 off
          rpower onde1 on

~~~~



### VPD card replacement recovery procedure

This section provides the expected xCAT administrator tasks that is required for recovery activities after replacing VPD card.

The VPD card is not concurrently maintainable within the CEC drawer. The CEC drawer in which the VPD card is being replaced must be powered down completely and 350 volts must be off.

All other CEC drawers in the system can remain powered on. After a service action, the admin should use xCAT command to RE-IPL the CEC.

Admin should follow the procedure of CEC Recovery Procedure.

### System VPD Recovery procedure

This section provides the expected xCAT administrator tasks that is required for System VPD Recovery procedure activities. After the System VPD anchor card is replaced, and the original System VPD is restored, admin need to restart ISNM to assure that the correct VPD information is in the CNM database.

    On AIX, admin executes chnwm to restart the ISNM:

~~~~

     chnwm -d
     chnwm -a

~~~~



    On Linux, admin should excute:

~~~~

     service cnmd restart

~~~~



### Verifying Processor Speeds

This section provides the expected xCAT administrator tasks that is required for verifying processor speeds. After performing a service action that may impact processor speeds, admin should dump the processor speeds for each impacted node in the CEC drawer and compare them to values that you should have been instructed to store before the service action was performed. If the admin did not store the processor speeds before the service action, verify that they are set to the correct value. If the admin are not using energy management, this should be the maximum processor frequency.

    Admin checks processor speeds for each node in the CEC drawer and store them

~~~~

        renergy cec1nodes  CPUspeed       (provide CPU speed data for each node in CEC1)

~~~~



### Verify D-link Repair

This section provides the expected xCAT administrator tasks that is required for verifying D-link Repair. After a service action on a D-link, admin should perform these steps:

  * If the service action required a repair in a CEC drawer, first perform CEC Recovery Procedure.
  * Grep on the repaired D-link. Be sure that it is UP_OPERATIONAL.
  * Assure that there are no miswires.
  * Verify that no D-links attached to that CEC drawer or neighboring CEC drawers were accidently brought down.

    (1) Admin executes lsnwlinkinfo to grep on the state of the repaired D-link.

~~~~

        $ ./lsnwlinkinfo -s 0 -d 0 -t 0
        FR001-CG01-SN000-DR0-HB0-LL0 Status: DOWN_POWEROFF
        ExpNbr: FR001-CG01-SN000-DR0-HB3-LL0 ActualNbr: FR001-CG01-
        SN000- DR0-HB3-LL0
        FR001-CG01-SN000-DR0-HB0-LL1 Status: DOWN_POWEROFF
        ExpNbr: FR001-CG01-SN000-DR0-HB5-LL0 ActualNbr: FR001-CG01-
        SN000- DR0-HB5-LL0
        FR001-CG01-SN000-DR0-HB0-LL2 Status: DOWN_POWEROFF
        ExpNbr: FR001-CG01-SN000-DR0-HB3-LL2 ActualNbr: FR001-CG01-
        SN000- DR0-HB3-LL2
        FR001-CG01-SN000-DR0-HB0-LL3 Status: DOWN_POWEROFF
        ExpNbr: FR001-CG01-SN000-DR0-HB4-LL0 ActualNbr: FR001-CG01-
        SN000- DR0-HB4-LL0
        :
        .
        FR001-CG01-SN000-DR0-HB0-LR1 Status: DOWN_POWEROFF
        ExpNbr: : FR001-CG02-SN000-DR1-HB1-LR0 ActualNbr: FR001-CG02-
        SN000- DR1-HB1-LR0
        FR001-CG01-SN000-DR0-HB0-LR2 Status: DOWN_POWEROFF
        ExpNbr: : FR001-CG03-SN000-DR2-HB1-LR0 ActualNbr: FR001-CG03-
        SN000- DR2-HB1-LR0

~~~~

    (2) Admin executes lsnwmiswire to assure that there are no miswires

~~~~

        $ ./lsnwmiswire -s 0
        Loc: FR001-CG01-SN000-DR0-HB0-LR00 ExpNbr: FR001-CG02-SN000-DR1-
        HB0- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB0-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR01 ExpNbr: FR001-CG02-SN000-DR1-
        HB1- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB1-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR02 ExpNbr: FR001-CG02-SN000-DR1-
        HB2- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB2-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR03 ExpNbr: FR001-CG02-SN000-DR1-
        HB3- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB3-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR04 ExpNbr: FR001-CG02-SN000-DR1-
        HB4- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB4-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR05 ExpNbr: FR001-CG02-SN000-DR1-
        HB5- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB5-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR06 ExpNbr: FR001-CG02-SN000-DR1-
        HB6- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB6-LR00
        Loc: FR001-CG01-SN000-DR0-HB0-LR07 ExpNbr: FR001-CG02-SN000-DR1-
        HB7- LR00 ActualNbr: FR001-CG02-SN001-DR1-HB7-LR00
        :

~~~~

    (3) Admin executes lsnwdownhw and verify that no D-links attached to that CEC drawer or neighboring CEC drawers were accidently brought down.

~~~~

        lsnwdownhw -L -s 1 -d 2

~~~~



### Verify LR-link Repair

This section provides the expected xCAT administrator tasks that is required for verifying LR-link Repair. After a service action on a LR-link, admin should perform these steps:

    * If the service action required a repair in a CEC drawer, first perform CEC Recovery Procedure.

    * Grep on the superNode that contains the repaired LR-link. Be sure that all LR-links in that superNode are UP_OPERATIONAL. If you use lsnwdownhw to look for problems, then you should also use lsnwlinkinfo to count the number of LR-links in the superNode.


     Admin executes lsnwlinkinfo to grep on the state of the repaired D-link.

~~~~

       lsnwlinkinfo -s [supernode number] | grep LR | wc -l

~~~~

    ** Note:  The result should equal 768 for 4 drawer supernodes, because there are 192 LR-link ports per drawer


### Check for hardware problems

This section provides the expected xCAT administrator tasks that is required for checking hardware problems activities. The xCAT command rinv retrieves hardware configuration information for firmware and deconfigured resources from the Service Processor for P775 CECs. The administrator can use it to check for any deconfigured resources (deconfig) for each P7 CEC node objects.

    Admin use rinv to see the deconfiguration hardware. With the flag -x the admin could get the html format result.

~~~~

     rinv cec01 deconfig
     cec01: IH U78A9.001.0123456-P1 800 rinv node1 deconfig


~~~~


TEAL will monitor events and log failures using the Service Focal Point (SFP) through the HMC, and Integrated Switch Network Manager (ISNM) on the xCAT EMS with TEAL listeners. It will log all hardware failures and events in TEAL tables that are located in the xCAT data base on the xCAT EMS. The xCAT administrator can use TEAL commands to reference the different events and alerts found in the P775 cluster. When using TEAL, admin should wait 10 minutes for things to flush through the management subsystem. There are some sections admin could reference the TEAL and the ISNM documentation that is provided in the "High Performance clustering using the 9125-F2C" Cluster guide for more information.

### Verify File System

This section provides the expected administrator tasks that is required for verifying file system. Admin can use GPFS commands to verify if the file system is in good state after the service activities implemented on the hardware failure. The GPFS command mmlsfs will display the current file system attributes. Depending on the configuration, additional information which is set by GPFS may be displayed.


~~~~

    Admin excute GPFS command mmlsfs to verify the file system
    #mmlsfs all -A
       File system attributes for /dev/fs1:
       ====================================
       flag value          description
       ---- -------------- ----------------------
        -A  yes            Automatic mount option


       File system attributes for /dev/fs2:
       ====================================
       flag value          description
       ---- -------------- ----------------------
        -A  yes            Automatic mount option


       File system attributes for /dev/fs3:
       ====================================
       flag value          description
       ---- -------------- ----------------------
        -A  no             Automatic mount option


~~~~


### Verify Disk Enclosure

This section provides the expected administrator tasks that is required for verifying disk enclosure. Admin can use GPFS commands to verify if the disk enclosure is in good state after the service activities implemented on the hardware failure. The GPFS command below will display the information of the disk enclosure.


~~~~

    Admin can use the command to list the disk enclosure state:
    gpfsDiskName
       is used to get the disk name.
    gpfsDiskFSName
       is used to get the name of is used to get the file system to which is used to get the disk belongs.
    gpfsDiskStgPoolName
       is used to get the name of is used to get the storage pool to which is used to get the disk belongs.
    gpfsDiskStatus
       is used to get the status of a disk (values: NotInUse, InUse, Suspended, BeingFormatted, BeingAdded, BeingEmptied, BeingDeleted, BeingDeleted-p, ReferencesBeingRemoved, BeingReplaced or Replacement).
    gpfsDiskAvailability
       is used to get the availability of is used to get the disk (Unchanged, OK, Unavailable, Recovering).
    gpfsDiskTotalSpaceL
       is used to get the total disk space in kilobytes (low 32 bits).
    gpfsDiskTotalSpaceH
       is used to get the total disk space in kilobytes (high 32 bits).
    gpfsDiskFullBlockFreeSpaceL
       is used to get the full block (unfragmented) free space in kilobytes (low 32 bits).
    gpfsDiskFullBlockFreeSpaceH
       is used to get the full block (unfragmented) free space in kilobytes (high 32 bits).
    gpfsDiskSubBlockFreeSpaceL
       is used to get the sub-block (fragmented) free space in kilobytes (low 32 bits).
    gpfsDiskSubBlockFreeSpaceH
       is used to get the sub-block (fragmented) free space in kilobytes (high 32 bits).



~~~~


