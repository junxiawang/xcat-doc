<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Migrating CSM to xCAT](#migrating-csm-to-xcat)
  - [**Installing the xCAT 2 Management Node**](#installing-the-xcat-2-management-node)
  - [**Overview: Transition CSM Management Server to the xCAT Management Node**](#overview-transition-csm-management-server-to-the-xcat-management-node)
  - [**Set up Remote Shell on xCAT MN**](#set-up-remote-shell-on-xcat-mn)
  - [**Stop CSM Services**](#stop-csm-services)
  - [**CSM dsh to xCAT xdsh Migration**](#csm-dsh-to-xcat-xdsh-migration)
  - [**Setting up Users and Groups**](#setting-up-users-and-groups)
  - [**Migrating the CSM database to the xCAT database**](#migrating-the-csm-database-to-the-xcat-database)
    - [**Setting up the passwd and ppchcp table**](#setting-up-the-passwd-and-ppchcp-table)
    - [**Setting up ssh keys to your AMMs and HMCs**](#setting-up-ssh-keys-to-your-amms-and-hmcs)
  - [**Setting up Name Resolution to the xCAT Cluster**](#setting-up-name-resolution-to-the-xcat-cluster)
  - [**Uninstalling CSM from your Cluster Nodes**](#uninstalling-csm-from-your-cluster-nodes)
  - [**Verify Hardware Control**](#verify-hardware-control)
  - [**Additional xCAT setup for Cluster Install on AIX**](#additional-xcat-setup-for-cluster-install-on-aix)
  - [**Additional xCAT setup for Cluster Install on Linux**](#additional-xcat-setup-for-cluster-install-on-linux)
  - [**Migrating your CFM setup to xCAT**](#migrating-your-cfm-setup-to-xcat)
  - [**Migrating the CSM Monitoring setup to xCAT**](#migrating-the-csm-monitoring-setup-to-xcat)
  - [**Testing your xCAT Cluster**](#testing-your-xcat-cluster)
  - [**Uninstalling CSM from your Management Serve**r](#uninstalling-csm-from-your-management-server)
- [References](#references)
- [Appendix A: xCAT Migration Tools](#appendix-a-xcat-migration-tools)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Migrating CSM to xCAT

This document provides instructions to migrate from IBM Cluster System Management (CSM) to xCAT2. For the migration, you should have a second machine to be used as the xCAT2 Management Node (MN), not the machine that is your CSM Management Server (MS). Your CSM MS should not be defined as a node in the xCAT cluster. In xCAT (2.8 or later), you will be able to define the MN in the cluster after the migration. Since xCAT requires no xCAT code on the cluster nodes, the migration is only the migration from the CSM Management Server to the xCAT management Node. 

  
Become familiar with xCAT, there are many documents linked from the [xCAT website](http://xcat.sourceforge.net/). A good place to start is in the xCAT Doc Repository: 
    
[xCAT Documentation](XCAT_Documentation)
    
    
    From the website:   http://xcat.sourceforge.net/
    

You can&nbsp;: (1) Join the mailing list. Many xCAT developers were formerly CSM developers and can answer your questions. (2)You can hire support from IBM. The support team for xCAT was also a support team for CSM, so they can be a great help. 

Check the supported Operating Systems and Hardware in [xCAT Features](XCAT_Features) to make sure xcat supports your hardware and OS. If your current CSM cluster is using the High Performance Switch (HPS) then this will need to be replaced with another type of high-speed interconnect, because there is no support for the HPS on xCAT 2. 

  


  
**Finally, think positive, the transition is not that bad.**

  


The entire CSM cluster should be ready to be moved to xCAT. CSM activity should have been stopped. With two Management nodes, one running CSM and one running xCAT, it is still recommended to transition all your nodes to the new xCAT MN at the same time. 

  
We are not addressing the move of a CSM hierarchical cluster to an xCAT hierarchical cluster, that is CSM install nodes to xCAT service nodes. 

  
Since we are documenting only one scenario, you will have to extrapolate to your specific situation, read the xCAT docs, and post to the mailing list specific questions. 

  
There are two RedBooks that discuss CSM to xCAT Migration as part of their general information comparing CSM to xCAT for the CSM admin. There are also good discussions about the difference that the admin may expect moving from CSM to xCAT. **Please note, these books are very old, so any specific information about the xCAT product, is probably out of date.**

  * [The xCAT2 Guide for the System Administrator](http://www.redbooks.ibm.com/redpapers/pdfs/redp4437.pdf)

The csm2xcatdb routine should not be used. Use the csm2xcat routine shipped with xCAT. 

  * [Configuring and Managing AIX Clusters Using xCAT2 ](http://www.redbooks.ibm.com/redbooks/pdfs/sg247766.pdf)

  


  


### **Installing the xCAT 2 Management Node**

The [XCAT_iDataPlex_Cluster_Quick_Start](XCAT_iDataPlex_Cluster_Quick_Start) gives you instructions for installing and setting up the xCAT Linux Management Node, for most x-series hardware. 

The [XCAT_Power_QuickStart](XCAT_Power_QuickStart) gives you instructions for installing and setting up the xCAT Linux Management Node, for most x-series hardware. 

For installing an AIX Management Node, use [XCAT_AIX_Cluster_Overview_and_Mgmt_Node](XCAT_AIX_Cluster_Overview_and_Mgmt_Node) . Reference these documents to setup your Management Node, stopping at the point where you would normally start adding nodes to the database. We will provide you tools in the following sections to aid in moving your node definitions from CSM to xCAT. 

At this time you should setup your cluster network for the xCAT MN to access the cluster nodes, switches, HMCs,AMM, etc before the install. xCAT will initialize an xCAT networks table for you during the install of the Management Node on Linux. It will also initialize the networks table on AIX, if you install xCAT2.4 or later. Do not detach the cluster from the CSM MN, you will still need to access the nodes from the CSM MS to run some of the migration tools. 

xCAT defaults to use the ssh remote shell for both AIX and Linux. If you are using rsh, it is recommended that you move to ssh, although rsh is supported by xCAT on AIX. xCAT will automatically perform all the ssh setup (key generation and exchange) needed on your xCAT Management Node, and compute nodes for system administration using ssh. 

### **Overview: Transition CSM Management Server to the xCAT Management Node**

The following steps outline the process to take during this migration. First you should prepare your CSM cluster for the transition. A good check list is outlined in chapter 4.2.1 whether you are migrating from AIX or Linux in [Configuring and Managing AIX Clusters Using xCAT2](http://www.redbooks.ibm.com/redbooks/pdfs/sg247766.pdf).

  


  1. Ensure your CSM cluster is stable. Have all the nodes in the cluster that you are planning to migrate defined, powered up an accessible by ssh/dsh. 
  2. See CSM dsh to xCAT xdsh Migration. See instructions in [CSM dsh to xCAT xdsh Migration](http://www.redbooks.ibm.com/redbooks/pdfs/sg247766.pdf).
  3. Migrate your users to the xCAT MN. See instructions in [Set up user and group on the new xCAT MN](http://www.redbooks.ibm.com/redbooks/pdfs/sg247766.pdf). 
  4. On the CSM Management Node backup CSM using csmbackup. You may want to run csmsnap, just to have a snapshot of what the CSM cluster contained. This is good to do even though you have a new node as the xCAT MN. It could provide you information in the future for reference. 
  5. On the CSM MS, run csm2xcat, to capture the CSM database to be input into the xCAT database. See instructions in [Migrating the CSM database to the xCAT database](#migrating-the-csm-database-to-the-xcat-database). 
  6. On the CSM MS, run cfm2xcat, to capture the CFM database information to be copied to the xCAT MN. See instructions in [Migrating your CFM setup to xCAT](#migrating-your-cfm-setup-to-xcat). 
  7. On the CSM MS, capture your RMC monitoring Conditions, EventResponses and Sensors to be copied to the xCAT MN. See [Migrating the CSM Monitoring setup to xCAT](#migrating-the-csm-monitoring-setup-to-xcat).  

  8. Perform the necessary network connectivity for the new xCAT2 MN to be able to access the nodes in the cluster. 
  9. On the xCAT MN, Setup Name resolution for the cluster. See [Setting up Name Resolution to the xCAT Cluster](#setting-up-name-resolution-to-the-xcat-cluster). 
  10. Verify you have name resolution and network connectivity and remote shell setup to all your cluster nodes,devices,AMM,HMC,etc. 
  11. You can use xdsh or psh to the cluster nodes, AMMs and HMCs , should not prompt for a password, if ssh keys are correctly established. 
  12. On the CSM MS, you should remove CSM from the cluster nodes before migrating them to the xCAT MN. See [Uninstalling CSM from your Cluster Nodes](#uninstalling-csm-from-your-cluster-nodes).  

  13. Test Hardware Control to the Cluster Nodes from the xCAT MN. See [Verify Hardware Control](#verify-hardware-control).  

  14. Perform the necessary remaining setup of the xCAT Management Node for install. See instructions for an AIX MN in [Additional xCAT setup for Cluster Install on AIX](#additional-xcat-setup-for-cluster-install-on-aix). Instructions for a Linux MN in [Additional xCAT setup for Cluster Install on Linux](#additional-xcat-setup-for-cluster-install-on-linux).  

  15. When you are satisfied that your migration is complete, you can uninstall CSM from the CSM Management Server. See [Uninstalling CSM from your Management Server](#uninstalling-csm-from-your-management-server). 

### **Set up Remote Shell on xCAT MN**

If your ssh keys for root are already set up on your CSM MS, you can copy those keys to root on the xCAT MN and replace those generated during the xCAT install. The advantage of this is that you will still be set up to ssh to your HMCs, MMs, Switches, and cluster nodes as you did from your CSM MN. 

If you want to use the new root ssh keys generated by xCAT, then the xCAT software will automatically setup your cluster nodes with the keys during node installation. Additionally, at any time you can run xdsh &lt;noderange&gt; -K to set up the keys to the cluster nodes or to other device-types such as the IB switch. To set up the ssh keys on the HMC(s) or the AMM (s), you can use the xCAT rspconfig command. See [Setting up ssh keys to your AMMs and HMCs](#setting-up-ssh-keys-to-your-amms-and-hmcs). 

The known_hosts file from the CSM MS will work initially, but as xCAT installs nodes a new host key will be generated and your entries will have to be replaced with the new node ssh hostkeys. If you install all the nodes, this can be done one time after the installation by running the makeknownhosts &lt;all&gt;, where all is a group of all cluster nodes to create a new known_hosts file for root. 

xCAT sets up Linux and AIX to use OpenSSH by default for remote shell access. 

### **Stop CSM Services**

To allow the xCAT MN to take over managing your cluster, you should now stop the dhcpd daemon on the Linux CSM MN and start it on the xCAT MN. On AIX, you will need to stop the bootp daemon, and start it on the xCAT MN. 

  


### **CSM dsh to xCAT xdsh Migration**

Although you will find the xdsh/xdcp commands similar to the dsh/dcp command in CSM, they do not support all the function that the CSM command supported and they support some function that the CSM commands did not support. 

  * xdsh/xdcp no longer supports the following: 
  * Contexts, the only context is the default xCAT 
  * Interactive input 
  * -a,-A option, you can define a group "all" in xCAT 
  * Syntax has changed, see xdsh/xdcp man page 
  * -n, -N, -d , -D flags are no longer used 
  * Many input environment variables have been dropped. If you use them in xdsh/xdcp you will get a warning. You can compare the xdsh/xdcp manpage to the dsh/dcp manpage. 
  * xdsh/xdcp new support includes the following: 
  * You can xdcp/xdcp hierarchically via service nodes to cluster nodes. The cluster nodes do not have to be directly attached to the xCAT MN. 
  * You can use xdcp to rsync your files locally and hierarchically to service nodes and cluster nodes. 
  * You can use xdcp and xdsh to update and run commands on install images on your xCAT MN. 
  * You can use xdsh to set up ssh keys to cluster nodes for root and userids and set up ssh keys to IB Switch. 
  * You can use sudo with xdsh/xdcp 

  
On AIX, to aid in the migration of your scripts that have dsh or dcp calls, we have provided a tool [groupfiles4dsh ](http://xcat.sourceforge.net/man1/groupfiles4dsh.1.html)that will set up group definitions (including -a ) from the xCAT database that you can use run dsh or dcp shipped with AIX , until you are able to convert to the xCAT xdsh/xdcp. 

### **Setting up Users and Groups**

Copy the following files from the CSM MS to the xCAT2 MN to replicate your user definitions on the new xCAT2 MN. 

Note: although this is an easy way to have the xCAT MN have the same users as the CSM MS, there are some problems with copying the entire user setup from one system to the other. For example, if you did not have ssh installed on the CSM MS and do on the xCAT MN, it will wipe out the sshd id in /etc/passwd and ssh on the xCAT MN. At that point ssh will no longer work, unless you reinstall to recreate the sshd id. Also, any user ids that were common between the two management nodes that may have had different UID's assigned will result in not being able to access their files because ownership of files and directories are assigned by UID. 

The safest solution here is probably only to copy ids from the CSM MS to the xCAT MN that do not currently exist on the xCAT MN. 

  
For AIX, 

  

    
     /etc/passwd
     /etc/group
     /etc/security/passwd
     /etc/security/group
     /etc/security/user
     /etc/security/limits
    

For Linux, 

  

    
    /etc/passwd
     /etc/group
     /etc/shadow
     /etc/gshadow
     /etc/default/useradd
     /etc/skel
     /etc/login.defs
    

  


### **Migrating the CSM database to the xCAT database**

xCAT2 has provided a tool to help migrate the database on your CSM cluster to the xCAT database. The tool [csm2xcat](http://xcat.sourceforge.net/man1/csm2xcat.1.html) is in your xCAT install in the /opt/xcat/share/xcat/tools directory. This tool should be copied to your CSM Management Server (MS) and run. 

  
On the CSM MS: 

~~~~

   /.../csm2xcat --dir <path to directory to store the data>

~~~~
  
For example: csm2xcat --dir /tmp/mydir 

  
The tool creates two stanza files: 

  


  1. node.stanza - stanza info to update node info in the the xCAT database. 
  2. device.stanza - device info to update node info in the xCAT database. 

  
Check the two stanza files and edit out any information you do not want put in the xCAT database. Then copy them to some directory on the xCAT MN. 

  
On the xCAT MN run the following: 
    
    cat node.stanza | chdef -z to update the xCAT database with node info.
    cat device.stanza | chdef -z to update the xCAT database with device info.
    

  
At this point, you will have primed the xCAT database with the CSM database information. This is just a starting point for populating the needed xCAT tables to run hardware control and install. 

  
You can inspect the tables that have been updated from CSM. Whether these tables contain information depends on your hardware and OS. 

  * tabdump will give you a list of all the tables 
  * tabdump -d &lt;tablename&gt; will give you the definition of the attributes in the table 

Specific of tables of interest are the following: 

  * tabdump nodelist 
  * tabdump noderes 
  * tabdump mac 
  * tabdump nodehm 
  * tabdump nodetype 
  * tabdump nodegroup 
  * tabdump ppc 
  * tabdump mp 
  * tabdump mpa 
  * tabdump ipmi 

You can dump the entire xCAT database to readable files by running: 

~~~~
    
    dumpxCATdb -p /tmp/<your dir>
~~~~   

  
You can then edit the files. This is a good backup procedure, if you want to start removing things but have a way to return to the original setup. 

To restore run: 

~~~~
    
    restorexCATdb -p /tmp/<your dir>
~~~~    

  
You can check your node definitions in the database, to see what has been set up for you. 
 
~~~~   
    lsdef -l <node1>
~~~~
    

  
There are several commands for editing and listing the xCAT database table information. For editing, you can use the tabedit, nodech, chdef. xCAT has provide several commands depending on what level you would like to access the database tables. The tab* and node* command require you to have more knowledge of the xCAT database schema. The *def command, are more abstract and allow you to not to input actual table names. Similarly, we have the tabdump, nodels, lsdef command for listing out the database information. Review the manpages for these commands. 

  
On p-series there are serveral attributes that must be setup, that cannot be migrated from CSM. These are the id, pprofile and parent attributes. To update these attributes, run the xCAT rscan update function. It will update your created node definitions with these attributes. Reference man rscan. For example to update all nodes managed by hmc03, run the following: 
    
~~~~
    rscan -w hmc03
~~~~    

  


#### **Setting up the passwd and ppchcp table**

You will need to set up the passwords and userids needed in the system, in the xCAT passwd and the ppchcp table. 

Run tabdump -d passwd on the xCAT MN for information on the contents of the passwd table. 

  
Some of the common passwd table entries are&nbsp;: 

  * system - assigned to the root id when a node is installed 
  * blade - the MM userid and password 
  * ipmi - the BMC userid and password 
  * hmc - the hmc userid and password 

So you can define the system default root password as follows: 
    
~~~~
    chtab key=system passwd.username=root passwd.password=cluster
~~~~    

  
And your hmc default id and password as follows: 
  
~~~~  
    chdef -t node -o hmc1 username=hscroot password=abc1234
~~~~    

  
Another option is to put your HMC and IVM userids in the ppchcp table, instead of the passwd table. If you have HMC's run tabdump -d ppchcp on xCAT MN for information. 

  
You can check the definition of your HMC or AMM in the xCAT database: 
   
~~~~ 
    lsdef hmc01
    Object name: hmc01
    groups=hmc,all
    mgt=hmc
    nodetype=ppc
    hwtype=hmc
    password=abc123
    username=hscroot
    status=defined
    lsdef bca01
    Object name: bca01
    groups=mm
    mgt=blade
    mpa=bca01
    postscripts=syslog,remoteshell
    status=defined
~~~~    

#### **Setting up ssh keys to your AMMs and HMCs**

If you have new root ssh keys on your xCAT MN, not copied from the CSM MN, then you will have to set up the new keys on the AMMs or HMCS. The xCAT rspconfig command will do this for you. 

Note: the passwd table must be set up with the AMMs and HMCs userids and passwords. See [Setting up the passwd and ppchcp table](#setting-up-the-passwd-and-ppchcp-table). 

For example to set up the HMC: 
  
~~~~  
    rspconfig hmc01 sshcfg=enable
~~~~    

  
to set up the AMM: 
  
~~~~  
    rspconfig bca01 snmpcfg=enable sshcfg=enable
    rspconfig bca01 pd1=redwoperf pd2=redwoperf
    rpower bca01 reset
~~~~    

  
Test the ssh set up on the AMM with: 
    
    psh -l USERID bca01 info -T mm[1]
    

### **Setting up Name Resolution to the xCAT Cluster**

The nodes, devices, MM, switches,etc that are being migrated to the new xCAT Management Node, need to be added to /etc/hosts on the xCAT MN. If they are defined in the /etc/hosts on the CSM MS, then just copy those entries into the /etc/hosts on the xCAT MN. If a DNS server is used, then set up the new xCAT MN to resolve hostnames using the same DNS server as was set up on the CSM MN by putting the nameservers in /etc/resolv.conf on the MN and setting site.nameservers to the list of nameservers 

  


### **Uninstalling CSM from your Cluster Nodes**

Uninstall CSM from your managed nodes before starting to manage them with xCAT. CSM provides the rmnode script to cleanup CSM on the nodes. The rmnode function runs on the CSM MS, and removes the node definitions from the CSM database. The -a flag will remove all nodes, and the -u flag will additionally go out to the nodes and cleanup CSM from the nodes. See manpage for rmnode. 
    
~~~~
    rmnode -a -u
~~~~    

  


### **Verify Hardware Control**

Adding th CSM data to the xCAT database, setting up ssh and adding passwords to the passwd and/or ppchcp table; should have defined enough information for you to run hardware control to the cluster nodes. Now is time to test, if you can run hardware control commands, to the nodes. 

On the xCAT MN: 
 
~~~~   
    rpower <nodename> stat
    rpower <nodename> off
    rpower <nodename> on
~~~~    

### **Additional xCAT setup for Cluster Install on AIX**

With Hardware Control established, it is time to now set up the xCAT MN to install your AIX cluster. In this document, you will have done some of the setup by migrating from CSM. It is good to review the entire document listed below to make sure the transition did not miss some of the required setup. 

  * [XCAT_AIX_Cluster_Overview_and_Mgmt_Node](XCAT_AIX_Cluster_Overview_and_Mgmt_Node) 

### **Additional xCAT setup for Cluster Install on Linux**

With Hardware Control established, it is now time to set up the xCAT MN to install your Linux cluster. There are several documents available, depending on the Linux OS and the hardware type. In these documents, you will have done some of the setup by migrating from CSM. It is good to review the entire install document you use to make sure the transition did not miss some of the required setup. 

  * [XCAT_iDataPlex_Cluster_Quick_Start](XCAT_iDataPlex_Cluster_Quick_Start) - for Linux on xSeries. 
  * [XCAT_Power_QuickStart](XCAT_Power_QuickStart) - for Linux on pSeries 

### **Migrating your CFM setup to xCAT**

xCAT2 has a different implementation of file synchronization than the CFM function available in CSM. To migrate your CFM setup, to the new sync file function in xCAT, we have provided the [cfm2xcat](http://xcat.sourceforge.net/man1/cfm2xcat.1.html) in the /opt/xcat/share/xcat/tools directory. 

Copy cfm2xcat to your CSM Management Server. Build the sync files for xCAT by running: 
   
~~~~ 
    cfm2xcat -i /tmp/cfm/cfmdistfiles -o /tmp/cfm/rsyncfiles
~~~~    

In the /tmp/cfm directory will be a file containing the noderange (rsyncfiles.nr) and the matching synclist file (rsyncfiles) to be used with the xdcp command to perform the equivalent sync operation in xCAT. For example: 
   
~~~~ 
     rsyncfiles.nr rsyncfiles
     rsyncfiles.nr1 rsyncfiles1
     rsyncfiles.nr2 rsyncfiles2
~~~~             .
             .
             .
    

Copy the /tmp/cfm directory to your xCAT Management Node. You can use this directory of files with the xdcp -F command to perform the CFM function in xCAT. To use these files, run the following command for each noderange/synclist pair. 
    
~~~~
     xdcp ^rsyncfiles.nr -F rsyncfiles
     xdcp ^rsyncfiles.nr1 -F rsyncfiles1
     xdcp ^rsyncfiles.nr2 -F rsyncfiles2
             .
             .
             .
    
~~~~
  
For example rsyncfile.nr contains: 
    
~~~~
     c704f5sq04,c704f5sq02,c704f5sq01
~~~~    

And it's matching synclist in rsyncfile: 
   
~~~~ 
    /etc/group._AIXNodes -> /etc/group
    /.ssh/backups/id_rsa -> /.ssh/backups/id_rsa
    /etc/testfile-node -> /etc/testfile-node
    /etc/security/passwd._AIXNodes -> /etc/security/passwd
    /etc/security/group._AIXNodes -> /etc/security/group
    /etc/auto_master -> /etc/auto_master
    /etc/netsvc.conf -> /etc/netsvc.conf
    /home/dstadmin/test -> /home/dstadmin/test
    /etc/file4 -> /etc/file4
    /etc/passwd._AIXNodes -> /etc/passwd
    /.ssh/backups/id_dsa.pub -> /.ssh/backups/id_dsa.pub
    /usr/local/kroger/scripts/syscleanup.sh -> /usr/local/kroger/scripts/syscleanup.sh
    /.ssh/id_rsa -> /.ssh/id_rsa
    /hello -> /hello
    /etc/yamo -> /etc/yamo
    /etc/testfile-node\:node -> /etc/testfile-node\:node
    /.ssh/backups/id_rsa.pub -> /.ssh/backups/id_rsa.pub
    /.ssh/identity -> /.ssh/identity
    /usr/u/roottest/test -> /usr/u/roottest/test
    /yamo -> /yamo
    /etc/testfile -> /etc/testfile
    /etc/auto.master -> /etc/auto.master
~~~~    

  


  


The ways you can set up to synchronize files from the Management Node to the nodes in xCAT are explained in the following [Sync-ing_Config_Files_to_Nodes](Sync-ing_Config_Files_to_Nodes) documentation. 

### **Migrating the CSM Monitoring setup to xCAT**

Check to see what Monitoring has been configured in the CSM cluster. To check the current monitoring configuration, run **lscondresp **and **lssensor **on the CSM MS and the nodes. This will display the current conditions and responses that are associated and whether they are Active or Not active. 

You can create a copy of your defined Sensor, Conditions and Responses by running the following RSCT command on your CSM MS which creates a file that can be used to make the Sensor, Condition and Response on you new xCAT AIX Management Node. 

  

~~~~
    
    lsrsrc -i IBM.Sensor | grep -v NodeNameList &gt; /tmp/xcat/IBM.Sensor.rdef
    lsrsrc -i IBM.Condition | grep -v NodeNameList &gt; /tmp/xcat/IBM.Condition.rdef
    lsrsrc -i IBM.EventResponse | grep -v NodeNameList &gt; /tmp/xcat/IBM.EventResponse.rdef
~~~~    

  
Since you will be moving this Monitoring to a xCAT MN where CSM is not install, you need to check to each file see which rely on CSM scripts or your scripts that you have written and installed on the CSM MS. If you want to port them to xCAT, then you will also have to port the scripts to xCAT. If you do not want to port them to xCAT, then they should be edited out of the file. If you remove Sensors, you will also need to update the IBM.Condition.rdef file for entries that use the removed sensor. 

For example, in the IBM.Sensor.rdef file generated above you will see that the ErrorLogSensor in the IBM.Sensor.rdef file requires the "/opt/csm/csmbin/monerrorlog" script which will not be available on the xCAT MN. 

  
xCAT has predefined Sensors, Conditions and Response, some of which are common with CSM. For a full list of all the RMC Sensors, Conditions and Response defined in xCAT, go to the /opt/xcat/lib/perl/xCAT_monitoring/rmc/resources directory on your xCAT MN and look in the subdirectories. There is no need to migrate the CSM version of these resources, so they should be edited out of the migration files. 

The current predefined Sensors in xCAT common with CSM , at the writing of the document, are the following: 

  * ErrorLogSensor 

The current predefined Conditions in xCAT common with CSM , at the writing of the document, are the following: 

  * AIXNodeCoreDump 
  * AllServiceableEvents 
  * AnyNodeAnyLoggedError 
  * AnyNodeFileSystemInodesUsed 
  * AnyNodeFileSystemSpaceUsed 
  * AnyNodeNetworkInterfaceStatus 
  * AnyNodePagingPercentSpaceFree 
  * AnyNodeProcessorsIdleTime 
  * AnyNodeTmpSpaceUsed 
  * AnyNodeVarSpaceUsed 
  * NodeReachability 

The current predefined EventResponses in xCAT common with CSM , at the writing of the document, are the following: 

  * BroadcastEventsAnyTime 
  * LogOnlyToAuditLogAnyTime 
  * EmailRootAnyTime 

  
Set up RMC monitoring on your xCAT MN. Use steps outlined in either of the following two references. 

  * [Configuring and Managing AIX Clusters Using xCAT2 ](http://www.redbooks.ibm.com/redbooks/pdfs/sg247766.pdf)[(chap2 "Monitoring Infrastructure " and chap 4 "Configure RMC Monitoring")](http://www.redbooks.ibm.com/redbooks/pdfs/sg247766.pdf)
  * [Monitoring_an_xCAT_Cluster](Monitoring_an_xCAT_Cluster) 

Copy the /tmp/xcat directory of files to your AIX xCAT MN, and run the following RSCT commands, to recreate the Sensors, Conditions and Responses: 

  

 
~~~~   
    mkrsrc -f /tmp/xcat/IBM.Sensor.rdef IBM.Sensor
    mkrsrc -f /tmp/xcat/IBM.Condition.rdef IBM.Condition
    mkrsrc -f /tmp/xcat/IBM.EventResponse.rdef IBM.EventResponse
~~~~    

  
The associations (which conditions are active and associated with what responses) must be added manually on the xCAT MN using the startcondresp command 

### **Testing your xCAT Cluster**

Once you cluster is setup, you should test to see that it can perform the functions you need before shutting down your CSM MS. 

  * Make sure the remote commands xdsh, xdcp,psh,etc work to the cluster nodes. 
  * Make sure your hardware control commands rpower, rinv, etc work to the cluster nodes. 
  * Make sure you can install your nodes. 
  * Run updatenode to the nodes, to update software,run postscripts and sync files. 

### **Uninstalling CSM from your Management Serve**r

Uninstall CSM from the CSM Management Server, when you have finished your migration, using the uninstallms command, which will remove CSM from the MS, its cluster definitions,log files, predefined conditions and responses. See man uninstallms for details. 

uninstallms 

## References

  * [xCAT Documentation](xCAT Documentation)
  * [XCAT_iDataPlex_Cluster_Quick_Start](XCAT_iDataPlex_Cluster_Quick_Start) - installing a Linux MN and pointer to additional xCAT documentation. 
  * [XCAT_AIX_Cluster_Overview_and_Mgmt_Node](vXCAT_AIX_Cluster_Overview_and_Mgmt_Node) - installing an AIX MN and pointer to additional AIX xCAT docs. 
  * [XCAT_Power_QuickStart](XCAT_Power_QuickStart) - setting up P-series Linux xCAT 

## Appendix A: xCAT Migration Tools

These tools can aid in your migration from CSM to xCAT2. 

  * [csm2xcat](http://xcat.sourceforge.net/man1/csm2xcat.1.html) \- Migrates a CSM database to a xCAT database. 
  * [cfm2xcat](http://xcat.sourceforge.net/man1/cfm2xcat.1.html) \- Migrates a CSM CFM setup to the syncfile function in xCAT. 
  * [groupfiles4dsh](http://xcat.sourceforge.net/man1/groupfiles4dsh.1.html) \- Creates a directory of nodegroup files to be used with AIX dsh. This will allow your scripts to continue to run dsh/dcp shipped with AIX, while you convert them to use the new xdsh/xdcp. 
