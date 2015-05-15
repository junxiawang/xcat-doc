<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Customizing Your Nodes Using Post*scripts](#customizing-your-nodes-using-postscripts)
    - [Types of Post*scripts](#types-of-postscripts)
    - [Adding your own postscripts](#adding-your-own-postscripts)
- [!/bin/bash](#binbash)
      - [Recommended Postscript design](#recommended-postscript-design)
    - [Post*Script execution](#postscript-execution)
    - [Using the mypostscript template](#using-the-mypostscript-template)
  - [Prescripts](#prescripts)
    - [Format for naming prescripts:](#format-for-naming-prescripts)
    - [Exit values for prescripts](#exit-values-for-prescripts)
  - [Suggestions for writing scripts](#suggestions-for-writing-scripts)
  - [Using Hierarchical Clusters](#using-hierarchical-clusters)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Customizing Your Nodes Using Post*scripts

xCAT automatically runs a few postscripts and postbootscripts that are delivered with xCAT to set up the nodes. You can also add your own scripts to further customize the nodes. This explains the xCAT support to do this. 

  


### Types of Post*scripts

There are two types of *scripts in the postscripts table ( postscripts and postbootscripts).  The types are based on when in the install process they will be executed. Run the following for more information: 
 
~~~~   
    man postscripts
    
~~~~  
  


  * **postscripts attribute** \- List of scripts that should be run on this node after diskfull installation or diskless boot. 
    * For installation of RedHat, CentOS, Fedora, the scripts will be run before the reboot. 
    * For installation of SLES, the scripts will be run after the reboot but before the init.d process. For Linux diskless deployment, the scripts will be run at the init.d time, and xCAT will automatically add the list of scripts from the postbootscripts attribute to run after postscripts list. 
    * For AIX, the scripts will run after reboot, just as the postbootscripts attribute. This will change in the future to support running before boot, so currently for AIX you should use the postbootscripts attribute for your scripts. 
  * **postbootscripts attribute** \- list of scripts that should be run on this Linux node at the init.d time after diskfull installation reboot or diskless boot. 
    * For AIX, the scripts run after reboot. 
  * xCAT, by default, for diskful installs only runs the postbootscripts on the install and not on reboot. In xCAT 2.8 a site table attribute runbootscripts is available to change this default behavior. If set to yes, then the postbootscripts will be run on install and on reboot. 

**xCAT automatically adds the postscripts from the xcatdefaults.postscripts attribute of the table to run first on the nodes after install or diskless boot.** ****

### Adding your own postscripts

To add your own *script, place it in /install/postscripts on the management node. Make sure it is executable and world readable. Then add it to the postscripts table for the group of nodes you want it to be run on (or the "all" group if you want it run on all nodes in the appropriate attribute, according to when you want it to run. 

To check what scripts will be run on your node during installation: 

~~~~      
    lsdef node1 | grep scripts
    postbootscripts=otherpkgs 
    postscripts=syslog,remoteshell,syncfiles
~~~~
    

You can pass parameters to the postscripts. For example: 

~~~~  
  script1 p1 p2,script2,....
~~~~  

p1 p2 are the parameters to script1. 

Starting from xCAT 2.9, the postscripts could be placed in the subdirectories in /install/postscripts on management node, and specify "subdir/postscriptname" in the postscripts table to run the postscripts in the subdirectories. This feature could be used to categorize the postscripts for different purposes. Here is an example:

~~~~
    mkdir -p /install/postscripts/subdir1
    mkdir -p /install/postscripts/subdir2
    cp postscript1 /install/postscripts/subdir1/
    cp postscript2 /install/postscripts/subdir2/
    chdef node1 -p postscripts=subdir1/postscript1,subdir2/postscript2
    updatenode node1 -P
~~~~

If some of your postscripts will affect the network communication between the management node and compute node, like restarting network or configuring bond, the postscripts execution might not be able to be finished successfully because of the network connection problems, even if we put this postscript be the last postscript in the list, xCAT still may not be able to update the node status to be "booted". The recommendation is to use the Linux "at" mechanism to schedule this network-killing postscript to be run at a later time. Here is an example:

The user needs to add a postscript to customize the nics bonding setup, the nics bonding setup will break the network between the management node and compute node, then we could use "at" to run this nic bonding postscripts after all the postscripts processes have been finished.

We could write a script, say, /install/postscripts/nicbondscript, the nicbondscript simply calls the confignicsbond using "at":

~~~~
[root@xcatmn ~]#cat /install/postscripts/nicbondscript

#!/bin/bash

at -f ./confignicsbond now + 1 minute

[root@xcatmn ~]#

~~~~

Then 

~~~~
chdef <nodename> -p postbootscripts=nicbondscript
~~~~
  
#### Recommended Postscript design

  * Postscripts that you want to run anywhere, AIX, Linux, should be written in shell. This should be available on all OS's. If only on AIX, they can be written in Perl. If only on the service nodes, you can use Perl whether AIX or Linux. 
  * Postscripts should log errors using the following command **local4** is the default xCAT syslog class. **logger -t xCAT -p local4.info "your info message"**. 
  * Postscripts should have good and error exit codes (i.e 0 and 1). 
  * Postscripts should be well documented. At the top of the script, the first few lines should describe the function and inputs and output. You should have comments throughout the script. This is especially important if using regx. 

### Post*Script execution

When your script is executed on the node, all the attributes in the site table are exported as variables for your scripts to use. You can add extra attributes for yourself. See the sample mypostscript file below. 

To run the postscripts, a script is built, so the above exported variables can be input. You can usually find that script in /tmp on the node and for example in the Linux case it is call mypostscript. A good way to debug problems it to go to the node and just run mypostscript and see errors. You can also check the syslog on the Management Node for errors. 

When writing you postscripts, it is good to follow the example of the current postscripts and write errors to syslog and in shell. See Suggestions for writing scripts. 

All attributes in the site table are exported and available to the post*script during execution. See the mypostscript file, which is generated and executed on the nodes to run the postscripts. 

  
Example of mypostscript (prior to xCat 2.8) 
 
~~~~     
    #subroutine used to run postscripts
    run_ps () {
    logdir="/var/log/xcat"
    mkdir -p $logdir
    logfile="/var/log/xcat/xcat.log"
    if [_-f_$1_]; then
     echo "Running postscript: $@" | tee -a $logfile
     ./$@ 2>&1 | tee -a $logfile
    else
     echo "Postscript $1 does NOT exist." | tee -a $logfile
    fi
    }
    # subroutine end
    AUDITSKIPCMDS='tabdump,nodels'
    export AUDITSKIPCMDS
    TEST='test'
    export TEST
    NAMESERVERS='7.114.8.1'
    export NAMESERVERS
    NTPSERVERS='7.113.47.250'
    export NTPSERVERS
    INSTALLLOC='/install'
    export INSTALLLOC
    DEFSERIALPORT='0'
    export DEFSERIALPORT
    DEFSERIALSPEED='19200'
    export DEFSERIALSPEED
    DHCPINTERFACES="'xcat20RRmn|eth0;rra000-m|eth1'"
    export DHCPINTERFACES
    FORWARDERS='7.113.8.1,7.114.8.2'
    export FORWARDERS
    NAMESERVER='7.113.8.1,7.114.47.250'
    export NAMESERVER
    DB='postg'
    export DB
    BLADEMAXP='64'
    export BLADEMAXP
    FSPTIMEOUT='0'
    export FSPTIMEOUT
    INSTALLDIR='/install'
    export INSTALLDIR
    IPMIMAXP='64'
    export IPMIMAXP
    IPMIRETRIES='3'
    export IPMIRETRIES
    IPMITIMEOUT='2'
    export IPMITIMEOUT
    CONSOLEONDEMAND='no'
    export CONSOLEONDEMAND
    SITEMASTER=7.113.47.250
    export SITEMASTER
    MASTER=7.113.47.250
    export MASTER
    MAXSSH='8'
    export MAXSSH
    PPCMAXP='64'
    export PPCMAXP
    PPCRETRY='3'
    export PPCRETRY
    PPCTIMEOUT='0'
    export PPCTIMEOUT
    SHAREDTFTP='1'
    export SHAREDTFTP
    SNSYNCFILEDIR='/var/xcat/syncfiles'
    export SNSYNCFILEDIR
    TFTPDIR='/tftpboot'
    export TFTPDIR
    XCATDPORT='3001'
    export XCATDPORT
    XCATIPORT='3002'
    export XCATIPORT
    XCATCONFDIR='/etc/xcat'
    export XCATCONFDIR
    TIMEZONE='America/New_York'
    export TIMEZONE
    USENMAPFROMMN='no'
    export USENMAPFROMMN
    DOMAIN='cluster.net'
    export DOMAIN
    USESSHONAIX='no'
    export USESSHONAIX
    NODE=rra000-m
    export NODE
    NFSSERVER=7.113.47.250
    export NFSSERVER
    INSTALLNIC=eth0
    export INSTALLNIC
    PRIMARYNIC=eth1
    OSVER=fedora9
    export OSVER
    ARCH=x86_64
    export ARCH
    PROFILE=service
    export PROFILE
    PATH=`dirname $0`:$PATH
    export PATH
    NODESETSTATE='netboot'
    export NODESETSTATE
    UPDATENODE=1
    export UPDATENODE
    NTYPE=service
    export NTYPE
    MACADDRESS='00:14:5E:5B:51:FA'
    export MACADDRESS
    MONSERVER=7.113.47.250
    export MONSERVER
    MONMASTER=7.113.47.250
    export MONMASTER
    OSPKGS=bash,openssl,dhclient,kernel,openssh-server,openssh-clients,busybox-anaconda,vim-
    minimal,rpm,bind,bind-utils,ksh,nfs-utils,dhcp,bzip2,rootfiles,vixie-cron,wget,vsftpd,ntp,rsync
    OTHERPKGS1=xCATsn,xCAT-rmc,rsct/rsct.core,rsct/rsct.core.utils,rsct/src,yaboot-xcat
    export OTHERPKGS1
    OTHERPKGS_INDEX=1
    export OTHERPKGS_INDEX
    export NOSYNCFILES
    # postscripts-start-here\n
    run_ps ospkgs
    run_ps script1 p1 p2
    run_ps script2
    # postscripts-end-here\n
~~~~      

As of xCAT 2.8, the mypostscript file is generated according to the mypostscript.tmpl file. 

### Using the mypostscript template

[Template_of_mypostscript](Template_of_mypostscript) 

## Prescripts

The prescript table will allow you to run scripts before the install process. This can be helpful for performing advanced actions such as manipulating system services or configurations before beginning to install a node, or to prepare application servers for the addition of new nodes. Check the man page for more information. 

~~~~  
  man prescripts
~~~~

  
The scripts will be run as root on the MASTER for the node. If there is a service node for the node, then the scripts will be run on the service node. 

  
Identify the scripts to be run for each node by adding entries to the prescripts table: 
  
~~~~    
    tabedit prescripts
    Or:
    chdef -t node -o <noderange> prescripts-begin=<beginscripts> prescripts-end=<endscripts>
    Or:
    chdef -t group -o <nodegroup> prescripts-begin=<beginscripts> prescripts-end=<endscripts>
    
  
    tabdump prescripts
    #node,begin,end,comments,disable
~~~~      

  * begin or prescripts-begin - This attribute lists the scripts to be run at the beginning of the nodeset(Linux), nimnodeset(AIX), mkdsklsnode(AIX), or rmdsklsnode(AIX) command. 
  * end or prescripts-end - This attribute lists the scripts to be run at the end of the nodeset(Linux), nimnodeset(AIX), mkdsklsnode(AIX), or rmdksklsnode(AIX) command. 

### Format for naming prescripts:

The general format for the prescripts-begin or prescripts-end attribute is: 

~~~~
[action1:]s1,s2...[|action2:s3,s4,s5...] 

where: 

- action1 and action2 are the nodeset actions ( 'install', 'netboot',etc) specified in the command for Linux. 

- action1 and action2_ can be 'diskless' for mkdsklsnode command, 'standalone' for nimnodeset command, or 'remove' for rmdsklsnoe command for AIX. 

- s1 and s2 are the scripts to run for _action1_ in order. 

- s3, s4, and s5 are the scripts to run for action2. 

~~~~

If actions are omitted, the scripts apply to all actions. 

Examples: 

  * myscript1,myscript2 - run scripts for all supported commands ( command depends on whether AIX or Linux) 
  * diskless:myscript1,myscript2 (AIX) - run scripts 1,2 for the mkdsklsnode command 
  * install:myscript1,myscript2|netboot:myscript3 

(Linux) run scripts 1,2 for nodeset(install), runs script3 for nodeset(netboot). 

  
All the scripts should be copied to /install/prescripts directory and made executable for root and world readable for mounting. If you have service nodes in your cluster with a local /install directory (i.e. /install is not mounted from the xCAT management node to the service nodes), you will need to synchronize your /install/prescripts directory to your service node anytime you create new scripts or make changes to existing scripts. 

The following two environment variables will be passed to each script: 

  * NODES - a comma separated list of node names on which to run the script 
  * ACTION - current nodeset action. 

By default, the script will be invoked once for all nodes. However, if '**#xCAT setting:MAX_INSTANCE=number'** is specified in the script, the script will be invoked for each node in parallel, but no more than number of instances specified in **number **will be invoked at at a time. 

### Exit values for prescripts

If there is no error, a prescript should return with 0. If an error occurs, it should put the error message on the stdout and exit with 1 or any non zero values. The command (nodeset for example) that runs prescripts can be divided into 3 sections. 

  1. run begin prescripts 
  2. run other code 
  3. run end prescripts 

If one of the prescripts returns 1, the command will finish the rest of the prescripts in that section and then exit out with value 1. For example, a node has three begin prescripts s1,s2 and s3, three end prescripts s4,s5,s6. If s2 returns 1, the prescript s3 will be executed, but other code and the end prescripts will not be executed by the command. 

If one of the prescripts returns 2 or greater, then the command will exit out immediately. This only applies to the scripts that do not have '**#xCAT setting:MAX_INSTANCE=number'**. 

## Suggestions for writing scripts

  * Some compute node profiles exclude perl to keep the image as small as possible. If this is your case, your postscripts should obviously be written in another shell language, e.g. bash, ksh. 
  * If a postscript is specific for an os, name your postscript mypostscript.osname, e.g setupssh.aix. 
  * Add logger statements to send errors back to the Management Node. By default, xCAT configures the syslog service on compute nodes to forward all syslog messages to the Management Node. This will help debug. 

## Using Hierarchical Clusters

If you are running a hierarchical cluster, one with Service Nodes. If your /install/postscripts directory is not mounted on the Service Node. You are going to need to sync or copy the postscripts that you added or changed in the /install/postscripts on the MN to the SN, before running them on the compute nodes. To do this easily, use the xdcp command and just copy the entire /install/postscripts directory to the servicenodes ( usually in /xcatpost ). 
 
~~~~   
     xdcp service -R /install/postscripts/* /xcatpost
~~~~    

or 
  
~~~~  
     prsync /install/postscripts service:/xcatpost
~~~~    
    

If your /install/postscripts is not mounted on the Service Node, you should also: 
  
~~~~  
     xdcp service -R /install/postscripts/* /install
~~~~    

or 
 
~~~~   
     prsync /install/postscripts service:/install
~~~~    
