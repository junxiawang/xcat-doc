<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Terminology](#terminology)
- [Cluster Shutdown Assumptions](#cluster-shutdown-assumptions)
- [Cluster Shutdown Process](#cluster-shutdown-process)
- [User access](#user-access)
- [Site utility functions](#site-utility-functions)
- [Preparing to stop Loadleveler](#preparing-to-stop-loadleveler)
  - [Method 1 - Draining LoadLeveler jobs](#method-1---draining-loadleveler-jobs)
  - [Method 2 - Stopping LoadLeveler jobs](#method-2---stopping-loadleveler-jobs)
- [Stopping LoadLeveler](#stopping-loadleveler)
- [Stop GFPS and unmount the filesystem](#stop-gfps-and-unmount-the-filesystem)
- [Optional - Capture the HFI link status](#optional---capture-the-hfi-link-status)
- [Shutdown Compute nodes](#shutdown-compute-nodes)
- [Other Utility nodes](#other-utility-nodes)
- [Shutdown the storage nodes](#shutdown-the-storage-nodes)
- [Shutdown the service nodes](#shutdown-the-service-nodes)
- [Power off the CECs](#power-off-the-cecs)
- [Place the frames in rack standby mode](#place-the-frames-in-rack-standby-mode)
- [Turn off the frames](#turn-off-the-frames)
- [Shutdown EMS and HMCs](#shutdown-ems-and-hmcs)
- [Turn off the external disks attached to the EMS](#turn-off-the-external-disks-attached-to-the-ems)
- [Optional - Turn off breakers or disconnect power](#optional---turn-off-breakers-or-disconnect-power)
- [Cluster Shutdown Process is now complete](#cluster-shutdown-process-is-now-complete)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Introduction

This cookbook will provide information about shutting down the xCAT HPC system Power 775 hardware and software along with verification steps as the system is being shutdown. 

Please refer to the start-up process to review the Overview and Dependencies sections as they describe the general hardware roles and inter dependencies which affect starting and shutting down the cluster. 

[XCAT_775_Startup_Procedure]

The examples in this document are for a Linux environment. All commands assume root access on the EMS. 

Everything described in this document is only supported in xCAT 2.6.6 and above. If you have other system p hardware, see XCAT System p Hardware Management . 

Furthermore, this is intended only as a post-installation procedure. 

More information about the Power 775 related software can be found at: 

https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+Overview https://www.ibm.com/developerworks/wikis/display/hpccentral/IBM+HPC+Clustering+with+Power+775+-+Cluster+Guide 

## Terminology

To make this document consistent with the cluster start-up process the terminology section will be shared and can be found at: 

[XCAT_775_Startup_Procedure/#terminology](XCAT_775_Startup_Procedure/#terminology)

## Cluster Shutdown Assumptions

This section will document the assumptions that are being made regarding the state of the cluster prior to shutting it down. 

Shutting down an HPC cluster is a task which requires planning and preparation. Care must be taken to inform users that this cluster shutdown operation is going to take place. Removing user access to the cluster and stopping the jobs in the LoadLeveler queue are critical first steps in the shutdown of the cluster. 

Note: When timing the shutdown process for any shutdown benchmarking the draining of running jobs should not be considered part of the IBM HPC cluster shutdown process. This is excluded because it is totally dependent on how long a user job runs to completion and therefore could not be considered part of the actual shutdown. Once all jobs have been stopped then the official timing of the IBM HPC cluster shutdown process can begin. For a complete site shutdown process the time it takes to drain the jobs could be included, but will vary depending on where each job is in its execution. 

## Cluster Shutdown Process

The sections below will describe the steps necessary to shutdown the cluster. Each step will outline the process and verifications steps needed to complete the step prior to moving to the next step. 

The cluster shutdown process is generally faster than the start-up process. During the start-up process it is necessary to manually start some daemons and the hardware verification during start-up is a longer process then shutting down the system. 

## User access

Care must be taken to make sure that any users of the cluster are logged off and that their access has been stopped during this process. 

## Site utility functions

Any site specific utility nodes which are used to login, or backup or restore user data or other function related to the cluster should be disabled or stopped. 

If login nodes are being used then any new users should be prevented from being logged in to the cluster. 
 
~~~~   
     $ xdsh login -v 'echo cluster down 4 power cycle > /etc/nologin'
~~~~

## Preparing to stop Loadleveler

In order to shutdown the cluster it is key that all user jobs are drained or cancelled. This document is assuming that the administrator has a thorough understanding of job management and scheduling in order to drain or cancel all jobs. There are two methods to accomplish this task, draining the jobs and cancelling the jobs. 

Environmental site conditions affect whether to drain or cancel the jobs. If the shutdown is a scheduled shutdown with sufficient time for the jobs to complete then draining the jobs is the best practice. A shutdown which does not allow for all of the jobs to complete will require the jobs to be cancelled. 

Shutdown scheduling and preparation for this task in advance is needed especially when draining jobs to allow sufficient time for them to complete. 

### Method 1 - Draining LoadLeveler jobs

Draining the jobs is the preferred method but is only attainable when there is time to allow the jobs to complete before the cluster needs to be shutdown. To drain all jobs in the cluster perform the following steps: 

To begin draining the jobs on compute and service nodes: 

~~~~    
    $ xdsh compute -v -f 999 -l loadl llrctl drain
~~~~

To monitor the status of the jobs issue llstatus to one of the service nodes. in this example a service node called f01sv01 is being used: 

~~~~    
    $ xdsh f01sv01-v llstatus
~~~~

Note: Since the draining process is allowing the jobs to complete this step will continue as long as it takes for the longest running job to complete. A knowledge of the jobs and how long they run will help determine the length of this task. 

### Method 2 - Stopping LoadLeveler jobs

To keep any new jobs from starting in Loadleveler: 

~~~~    
    $ xdsh compute -v-f 999 -l loadl llrctl drain
    
    $ xdsh service -v llctl drain
~~~~

Wait for running jobs to complete, or alternately, if the jobs can be terminated and restarted, flush the jobs on the compute nodes by entering: 

~~~~    
    $ xdsh compute -v llrctl flush
~~~~

Note: In the job command file, 'restart=yes' has to be specified. Otherwise, it will be similar to llcancel. The jobs running on a node will be gone forever after you flush that node. 

To monitor the status of the jobs issue llstatus to one of the service nodes. in this example a service node called f01sv01 is being used: 

~~~~    
    $ xdsh f01sv01-v llstatus
~~~~

## Stopping LoadLeveler

Shutting down LoadLeveler early in the process reduces any chances of jobs being submitted and also eliminates any LoadLeveler dependencies on the cluster. 

As was discussed in the Cluster Shutdown Assumptions section it is necessary to drain or cancel all jobs and removed users from the system. This section is assuming that all jobs have been either drained or canceled using the steps described earlier. Since there are no jobs active in the system this step will describe shutting LoadLeveler down. 

LoadLeveler needs to be stopped on all compute node and service node. 

~~~~    
    $ xdsh compute -v -f 999 -l loadl llrctl stop
    

    $ xdsh service -v -l loadl llctl stop
~~~~

## Stop GFPS and unmount the filesystem

Once Loadleveler has been stopped GPFS can also be stopped. **It is important to make sure that all applications that need to access files within GPFS are stopped prior to performing this step.** A single command can be run on any storage node to complete this step. For this example we will use a storage node called f01st01 (for frame one storage node one): 

~~~~    
    $ xdsh f01st01 -v mmshutdown -a

or GFPS can also be stopped by shutting it down on login and compute nodes first and then the storage nodes. 
    
    $ xdsh compute,login -f 999 -v mmshutdown
  

    $ xdsh storage -v mmshutdown
~~~~

Note: This will shutdown gpfs everywhere it is running on the cluster. Once it completes GPFS is down and no longer available. 

## Optional - Capture the HFI link status

Prior to shutting down the compute lpars it may be useful to get a state of the HFI link status. This is useful if there are any HFI errors prior to shutting down so that they are understood when starting the cluster back up. This can be done by listing the connection state for the BPAs and FSPs as well as listing the CEC link status. 

Verify CNM has successfully contacted all BPAs and FSPs by issuing the following command. 

~~~~    
    $ lsnwcomponents

~~~~

The following should match the number of CEC drawers that are in the cluster. 

~~~~    
    $ lsnwloc | grep -v EXCLUDED | wc -l
~~~~ 

If the number is incorrect then check for any issues that cause a CEC drawer to be excluded by CNM. 

~~~~     
    $ lsnwloc | grep EXCLUDED 
~~~~ 

## Shutdown Compute nodes

WIth both LoadLeveler and GPFS stopped the next step is to shutdown the compute nodes. The compute nodes are shutdown first because other nodes within the cluster do not depend on the compute nodes. 
 
~~~~    
    $ xdsh compute -v -f 999 shutdown -h now 
~~~~ 

To verify that the compute nodes have been shutdown: 

~~~~     
    $ rpower compute state
~~~~ 

## Other Utility nodes

This is the step where any utility nodes (login, backup, etc...) are shutdown. This example shuts down the login nodes. 

~~~~     
    $ xdsh login -v shutdown -h now 
~~~~ 

Verify that the login nodes have stopped. 

~~~~     
    $ rpower login state
~~~~ 

## Shutdown the storage nodes

At this point Loadleveler, GPFS, and the compute nodes are down. This means that all dependencies on the storage nodes have been stopped and the storage nodes can be shutdown. 

~~~~     
    $ xdsh storage -v shutdown -h now
~~~~ 

To verify that the storage nodes have shutdown: 

~~~~     
    $ rpower storage state
~~~~ 

## Shutdown the service nodes

With the compute and storage nodes are down there are no more dependencies on the service nodes and the service nodes can be shutdown. 

~~~~     
    $ xdsh service -v shutdown -h now 
~~~~ 

To verify that the service nodes have been shutdown: 

~~~~     
    $ rpower service state
~~~~ 

## Power off the CECs

This section will describe the process for shutting the CECs down. 

Once the compute, utility nodes (if any), storage, and service nodes are shutdown the cecs can be powered off. 

~~~~     
    $ rpower cec off
~~~~ 

To verify that the cec are off: 

~~~~     
    $ rpower cec state
~~~~ 

## Place the frames in rack standby mode

Once all of the CECs are powered off and the Central Network Manager is off the frames can be placed in rack standby mode. 

~~~~     
    $ rpower frame rackstandby
~~~~ 

To validate the frames are in rack standby issue: 

~~~~     
    $ rpower frame state 
~~~~ 

## Turn off the frames

Once the frames have entered rack standby they are ready for power off. 

Manually turn of the red switch for each frame 

## Shutdown EMS and HMCs

Once the all nodes and cecs are down and the frames are in rack standby the EMS and HMCs can be shutdown. Depending on the goal for this shutdown process this step may be skipped. 

If the goal was to shutdown only the 775 servers and attached storage, then those steps are complete and you can stop here. 

If the goal is to completely restart the entire cluster, including the EMS and HMCs, then you should continue with the shutting down of the HMCs and the EMS. 

Log onto the HMC and issues this command to shutdown the HMCs: 
 
~~~~    
    $ hmcshutdown -t now
~~~~ 

If SSH is configured this can be accomplished with: 

~~~~     
    $ ssh -l hscroot &lt;hmchostname&gt; hmcshutdown -t now
~~~~ 
  
Now shutdown both the primary and backup EMS servers. 

Start with the backup EMS by issuing shutdown 
 
~~~~    
    $ shutdown -h now
~~~~ 

On the primary EMS shutdown the following deamons in order: 

Stop Teal 

~~~~     
    $ service teal stop
~~~~ 

Stop xcatd 
 
~~~~    
    $ service xcatd stop
~~~~ 

Stop dhcp 
 
~~~~    
    $ service dhcpd stop
~~~~ 

Stop named 

~~~~     
    $ service named stop
~~~~ 

Stop the xcat db 
    
~~~~     
    $ su - xcatdb
    $ db2stop
    $ exit
~~~~      

If the stop is not successful, use force. 
    
~~~~     
    $ su - xcatdb
    $db2stop force
    $ exit
~~~~      

unmount the shared filesystems 

Note: Your site directory names may vary from this sample 
    
~~~~     
    $ umount /dev/sdc1 /etc/xcat
    $ umount /dev/sdc2 /install
    $ umount /dev/sdc3 ~/.xcat
    $ umount /dev/sdc4 /databaseloc 
~~~~ 

Now shutdown the primary EMS 

~~~~     
    $ shutdown -h now 
~~~~ 

Once the primary is shutdown, the backup can be shutdown. Login on to the backup EMS and issue: 

~~~~     
    $ shutdown -h now 
~~~~ 

## Turn off the external disks attached to the EMS

Once the primary and backup EMS are shutdown you can turn of the external disk drives. 

## Optional - Turn off breakers or disconnect power

Now that all of the cluster related hardware is turned off and the EMS and HMCs are down the power for the management rack and the 775 frames can be turned off. If you have breaker switches, these could be used. If not the power can be disconneted from the management rack and the frames. 

Note: care must be taken when handling power to the hardware. 

Disconnect power cords on 775 rack Disconnect power on management rack... 

## Cluster Shutdown Process is now complete

All software and hardware for the cluster has been stopped at this point and the process is complete. 
