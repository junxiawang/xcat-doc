<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Moab Adaptive Computing Installation](#moab-adaptive-computing-installation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning) 

## Moab Adaptive Computing Installation

1) Introduction  
2) Prerequisites  
3) Install Moab on the management node  
4) Configure Moab using the moab.cfg file  
5) Install Moab Service Manager (MSM) on the management node  
6) Configure MSM using the msm.cfg file  
7) Verify the installation 

  
**1) Introduction**

Moab Adaptive Computing Suite (Moab®) can dynamically provision compute machines to requested operating systems and power off compute machines when not in use. 

**2) Pre-requisites**

Set up and configure xCAT correctly according to documentation (xcat.wiki.sourceforge.net/HowTos). 

Test all nodes that Moab controls via xCAT to verify response to rpower, nodestat, and rinstall xCAT commands for all os/arch/profile combinations that jobs submitted to Moab use. 

Currently known to work with nodes using the xCAT IPMI and ILO hardware management plugins. 

Have a valid Moab license file (moab.lic) with provisioning and green enabled. For information on acquiring an evaluation license please contact [info@clusterresources.com](https://mail.clusterresources.com/zimbra/mail?view=compose&to=info@clusterresources.com). 

**3) Install Moab on the management node**

Moab is the intelligence engine that coordinates the capabilities of xCat and Torque to dynamically provision compute nodes to the requested operating system. Moab also schedules workload on the system and powers off idle nodes. 

Download Moab from the Cluster Resources website: 

http://www.clusterresources.com/product/mwm/index.php 

Install Moab following the installation documentation: 

http://www.clusterresources.com/moabdocs/2.0installation.shtml 

**4) Configure Moab using the moab.cfg file**  
Moab stores its configuration in the moab.cfg file: /opt/moab/moab.cfg. A sample configuration file, set up and optimized for adaptive computing follows: 
    
    # Example moab.cfg
    
    SCHEDCFG[Moab]          SERVER=gpc-sched:42559
    ADMINCFG[1]             USERS=root,egan
    
    LOGLEVEL                7
    
    # How often (in seconds) to refresh information from Torque and MSM
    RMPOLLINTERVAL		 60
    
    RESERVATIONDEPTH        10
    DEFERTIME               0
    
    ###################################################################
    # Location of msm directory                                       #
    # www.clusterresources.com/moabdocs/a.fparameters.shtml#toolsdir  #
    ###################################################################
    
    TOOLSDIR                /opt/moab/tools
    
    
    ###############################################################################
    # TORQUE and MSM configuration                                                #
    # http://www.clusterresources.com/products/mwm/docs/a.fparameters.shtml#rmcfg #
    ###############################################################################
    
    RMCFG[torque]           TYPE=PBS
    
    RMCFG[msm]        TYPE=NATIVE:msm FLAGS=autosync,NOCREATERESOURCE RESOURCETYPE=PROV
    RMCFG[msm]        TIMEOUT=60
    RMCFG[msm]        PROVDURATION=10:00
    
    AGGREGATENODEACTIONS    TRUE
    
    ###############################################################################
    # ON DEMAND PROVISIONING SETUP                                                #
    # www.clusterresources.com/moabdocs/3.5credoverview.shtml#qos                 #
    # www.clusterresources.com/moabdocs/5.2nodeallocation.shtml#PRIORITY          #
    # www.clusterresources.com/moabodcs/a.fparameters.shtml#jobprioaccrualpolicy  #
    ###############################################################################
    
    QOSCFG[od]              QFLAGS=PROVISION
    USERCFG[DEFAULT]        QLIST=od
    
    JOBPRIOACCRUALPOLICY    ACCRUE
    JOBPRIOEXCEPTIONS       BATCHHOLD,SYSTEMHOLD,DEPENDS
    
    NODEALLOCATIONPOLICY    PRIORITY
    NODECFG[DEFAULT]        PRIORITYF=1000*OS+1000*POWER
    
    NODEAVAILABILITYPOLICY  DEDICATED
    
    CLASSCFG[DEFAULT]       DEFAULT.OS=scinetcompute
    
    ###############################################################
    # GREEN POLICIES                                              #
    # www.clusterresources.com/moabdocs/23.0greencomputing.shtml  #
    ###############################################################
    
    NODECFG[DEFAULT]        POWERPOLICY=GREEN
    PARCFG[ALL]             NODEPOWEROFFDURATION=20:00
    
    NODEIDLEPOWERTHRESHOLD  600
    
    # END Example moab.cfg

**5) Install Moab Service Manager (MSM) on the management node**

Configuration in xCAT: 

Create a node group with a name of your choosing (for example, moab) and add all nodes Moab will manage to that group. 

Compile a list of combinations of OS, architecture, profile (as defined in the xCAT setup) plus node features that will be used. Generate a text file that contains these combinations in the format that follows (later refferred to as _IMAGESFNAME). 
    
    # Example image definition file
    #
    # image_name =&gt; arbitrary name, specified by jobs at submission time
    # arch       =&gt; arch as used by xCAT for provisioning a node
    # os         =&gt; os as used by xCAT for provisioning a node
    # profile    =&gt; profile as used by xCAT for provisioning a node
    # nodeset    =&gt; netboot|install - is the image stateless or statefull
    # feature    =&gt; arbitrary feature names, used to identify features of a node
    #
    
    # image_name     arch    os          profile    nodeset   features
    
    # physics group
    phys_a           x86     centos5.2   gaussian   netboot   infiniband,bigmem
    phys_b           x86_64  centos5.2   gaussian   netboot   infiniband,bigmem
    phys_c           x86     centos5.1   gaussian   netboot   infiniband
    phys_d           x86_64  centos5.1   gaussian   netboot   infiniband,bigmem
    phys_e           x86_64  sles11      vasp       netboot   storage,video
    
    # biology group
    bio_a           x86     centos5.2    dft        netboot   infiniband,bigmem
    bio_b           x86_64  centos5.2    dft        netboot   infiniband,bigmem
    bio_c           x86     centos5.1    dft
    bio_d           x86_64  centos5.1    dft        netboot   infiniband,bigmem
    bio_e           x86_64  sles11       dft        netboot   storage,video
    
    # END Example image definition file

Installing/Configuring MSM: 

Ensure the following Perl modules are available:  
DBD::SQLite  
Proc::Daemon  
XML::Simple 

Create an MSM directory (/opt/moab/tools/msm).  
Extract msm.tgz to /opt/moab/tools/msm. 

**6) Configure MSM using the msm.cfg file**

Create an MSM configuration (/opt/moab/tools/msm/msm.cfg) as follows: 
    
    # Example msm.cfg
    
    RMCFG[msm]        PORT=24603
    RMCFG[msm]        POLLINTERVAL=10
    RMCFG[msm]        LOGFILE=/opt/moab/log/msm.log
    RMCFG[msm]        LOGLEVEL=8
    RMCFG[msm]        DEFAULTNODEAPP=xcat
    
    APPCFG[xcat]      DESCRIPTION="xCAT plugin"
    APPCFG[xcat]      MODULE=Moab::MSM::App::xCAT
    APPCFG[xcat]      REPORTSTATE=FALSE
    APPCFG[xcat]      LOGLEVEL=8
    
    # this is where your xCAT group name for all nodes moab will be managing goes
    APPCFG[xcat]       _NODERANGE=moab
    
    # This value should be greater than the amount of time it
    # takes
    # 'nodestat moab_group_name' + 'rpower moab_group_name' to complete
    # on your cluster (seconds).
    APPCFG[xcat]       POLLINTERVAL=30
    
    # Timeout for nodestat + rpower commands, assumed to have failed if not done
    # in this much time (seconds).
    APPCFG[xcat]       _TIMEOUT=300
    
    # Your xCAT feature group names
    APPCFG[xcat]       _FEATUREGROUPS=infiniband,bigmem,video
    
    # Full path to your image definition file, make sure it is readable
    # by the effective UID moab will be running as.
    APPCFG[xcat]       _IMAGESFNAME=/opt/moab/tools/msm/images.txt
    
    # Use this configuration parameter to have MSM perform nodestat/rpower
    # operations in small groups that are executed in parallel.  This is useful
    # if nodestat or rpower commands take considerable time on your cluster.
    APPCFG[xcat]       _MAXRANGECOUNT=10
    
    # Use this configuration parameter to tell MSM not to start new cluster query operations while a previous one is executing.
    APPCFG[xcat]       _LIMITCLUSTERQUERY=1
    
    
    # END Example msm.cfg

**7) Verify the installation**

When Moab starts it immediately communicates with its configured resource managers. In this case Moab communicates with Torque to get compute node and job queue information. It then communicates with MSM to determine the state of the nodes according to xCAT. It aggregates this information and processes the jobs discovered from Torque. 

When a job is submitted, Moab determines whether nodes need to be provisioned to a particular operating system to satisfy the requirements of the job. If any nodes need to be provisioned Moab performs this action by creating a provisioning system job (a job that is internal to Moab). This system job communicates with xCAT to provision the nodes and remain active while the nodes are provisioning. Once the system job has provisioned the nodes it informs the user’s job that the nodes are ready at which time the user’s job starts running on the newly provisioned nodes. 

When a node has been idle for NODEIDLEPOWERTHRESHOLD Moab will create a power-off system job. This job communicates with xCAT to power off the nodes and remain active in the job queue until the nodes have powered off. Then the system job informs Moab that the nodes are powered off but are still available to run jobs. The power off system job then exits. 

To verify correct communication between Moab and MSM run the mdiag -R –v msm command. 
    
    $ mdiag -R -v msm
    diagnosing resource managers
    
    RM[msm]       State: Active  Type: NATIVE:MSM  ResourceType: PROV
      Timeout:            30000.00 ms
      Cluster Query URL:  $HOME/tools/msm/contrib/cluster.query.xcat.pl
      Workload Query URL: exec://$TOOLSDIR/msm/contrib/workload.query.pl
      Job Start URL:      exec://$TOOLSDIR/msm/contrib/job.start.pl
      Job Cancel URL:     exec://$TOOLSDIR/msm/contrib/job.modify.pl
      Job Migrate URL:    exec://$TOOLSDIR/msm/contrib/job.migrate.pl
      Job Submit URL:     exec://$TOOLSDIR/msm/contrib/job.submit.pl
      Node Modify URL:    exec://$TOOLSDIR/msm/contrib/node.modify.pl
      Node Power URL:     exec://$TOOLSDIR/msm/contrib/node.power.pl
      RM Start URL:       exec://$TOOLSDIR/msm/bin/msmd
      RM Stop URL:        exec://$TOOLSDIR/msm/bin/msmctl?-k
      System Modify URL:  exec://$TOOLSDIR/msm/contrib/node.modify.pl
      Environment:        MSMHOMEDIR=/home/wightman/test/scinet/tools//msm;MSMLIBDIR=/home/wightman/test/scinet/tools//msm
      Objects Reported:   Nodes=10 (0 procs)  Jobs=0
      Flags:              autosync
      Partition:          SHARED
      Event Management:   (event interface disabled)
      RM Performance:     AvgTime=0.10s  MaxTime=0.25s  (38 samples)
      RM Languages:       NATIVE
      RM Sub-Languages:   -

To verify nodes are configured to provision use the checknode -v &lt;nodeid&gt; command. Each node will have a list of available operating systems. 
    
    $ checknode n01
    node n01
    
    State:      Idle  (in current state for 00:00:00)
    Configured Resources: PROCS: 4  MEM: 1024G  SWAP: 4096M  DISK: 1024G
    Utilized   Resources: ---
    Dedicated  Resources: ---
    Generic Metrics:    watts=25.00,temp=40.00
    Power Policy:       Green (global policy)   Selected Power State: Off
    Power State:   Off
    Power:      Off
      MTBF(longterm):   INFINITY  MTBF(24h):   INFINITY
    Opsys:      compute   Arch:      ---
      OS Option: compute
      OS Option: computea
      OS Option: gpfscompute
      OS Option: gpfscomputea
    Speed:      1.00      CPULoad:   0.000
    Flags:      rmdetected
    RM[msm]:    TYPE=NATIVE:MSM  ATTRO=POWER
    EffNodeAccessPolicy: SINGLEJOB
    
    Total Time: 00:02:30  Up: 00:02:19 (92.67%)  Active: 00:00:11 (7.33%)

To verify nodes are configured for Green power management, run the mdiag –G command. Each node will show its power state. 
    
    $ mdiag -G
    NOTE:  power management enabled for all nodes
    Partition ALL:  power management enabled
      Partition NodeList:
    Partition local:  power management enabled
      Partition NodeList:
      node n01 is in state Idle, power state On (green powerpolicy enabled)
      node n02 is in state Idle, power state On (green powerpolicy enabled)
      node n03 is in state Idle, power state On (green powerpolicy enabled)
      node n04 is in state Idle, power state On (green powerpolicy enabled)
      node n05 is in state Idle, power state On (green powerpolicy enabled)
      node n06 is in state Idle, power state On (green powerpolicy enabled)
      node n07 is in state Idle, power state On (green powerpolicy enabled)
      node n08 is in state Idle, power state On (green powerpolicy enabled)
      node n09 is in state Idle, power state On (green powerpolicy enabled)
      node n10 is in state Idle, power state On (green powerpolicy enabled)
    Partition SHARED:  power management enabled

To submit a job that dynamically provisions compute nodes, run the msub –l os=&lt;image&gt; command. 
    
    $ msub -l os=computea job.sh
    
    yuby.3
    $ showq
    
    active jobs------------------------
    JOBID              USERNAME      STATE PROCS   REMAINING            STARTTIME
    
    provision-4            root    Running     8    00:01:00  Fri Jun 19 09:12:56
    
    1 active job               8 of 40 processors in use by local jobs (20.00%)
                               2 of 10 nodes active      (20.00%)
    
    eligible jobs----------------------
    JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME
    
    yuby.3             wightman       Idle     8    00:10:00  Fri Jun 19 09:12:55
    
    1 eligible job
    
    blocked jobs-----------------------
    JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME
    
    
    0 blocked jobs
    
    Total jobs:  2

Notice that Moab created a provisioning system job named provision-4 to provision the nodes. When provision-4 detects that the nodes are correctly provisioned to the requested OS, the submitted job yuby.3 runs: 
    
    $ showq
    
    active jobs------------------------
    JOBID              USERNAME      STATE PROCS   REMAINING            STARTTIME
    
    yuby.3             wightman    Running     8    00:08:49  Fri Jun 19 09:13:29
    
    1 active job               8 of 40 processors in use by local jobs (20.00%)
                               2 of 10 nodes active      (20.00%)
    
    eligible jobs----------------------
    JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME
    
    
    0 eligible jobs
    
    blocked jobs-----------------------
    JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME
    
    
    0 blocked jobs
    
    Total job:  1

The **checkjob** command shows information about the provisioning job as well as the submitted job. If any errors occur, run the **checkjob –v &lt;jobid&gt;** command to diagnose failures. 

© 2009 Cluster Resources, Incorporated 
