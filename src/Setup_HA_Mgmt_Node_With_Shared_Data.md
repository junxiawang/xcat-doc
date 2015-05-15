<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [What is Shared Data?](#what-is-shared-data)
- [Configuration Requirements](#configuration-requirements)
- [Configuring Shared Data](#configuring-shared-data)
- [Setup xCAT on the Primary Management Node](#setup-xcat-on-the-primary-management-node)
- [Setup xCAT on the Standby Management Node](#setup-xcat-on-the-standby-management-node)
- [File Synchronization](#file-synchronization)
  - [**SSL Credentials and SSH Keys**](#ssl-credentials-and-ssh-keys)
  - [**Network Services Configuration Files**](#network-services-configuration-files)
  - [**Additional Customization Files and Production files**](#additional-customization-files-and-production-files)
- [Cluster Maintenance Considerations](#cluster-maintenance-considerations)
- [Failover](#failover)
  - [Take down the Current Primary Management Node](#take-down-the-current-primary-management-node)
  - [Bring up the New Primary Management Node](#bring-up-the-new-primary-management-node)
- [Setup the Cluster](#setup-the-cluster)
- [Appendix A Configure Shared Disks](#appendix-a-configure-shared-disks)
  - [Configuring Shared Disks on AIX](#configuring-shared-disks-on-aix)
  - [Configuring Shared Disks on Linux](#configuring-shared-disks-on-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This documentation illustrates how to setup a second management node, or standby management node, in your cluster to provide high availability management capability, using shared data between the two management nodes. 

When the primary xCAT management node fails, the administrator can easily have the standby management node take over role of the management node, and thus avoid long periods of time during which your cluster does not have active cluster management function available. 

The xCAT high availability management node(HAMN) through shared data is not designed for automatic setup or automatic failover, this documentation describes how to use shared data between the primary management node and standby management node, and describes how to perform some manual steps to have the standby management node takeover the management node role when the primary management node fails. However, high availability applications such as IBM Tivoli System Automation(TSA) and Linux Pacemaker could be used to achieve automatic failover, how to configure the high availability applications is beyond the scope of this documentation, you could refer to the applications documentation for instructions. 

The nfs service on the primary management node or the primary management node itself will be shutdown during the failover process, so any NFS mount or other network connections from the compute nodes to the management node should be temporarily disconnected during the failover process. If the network connectivity is required for compute node run-time operations, you should consider some other way to provide high availability for the network services unless the compute nodes can also be taken down during the failover process. This also implies: 

1\. This HAMN approach is primarily intended for clusters in which the management node manages diskful nodes or linux stateless nodes. This also includes hierarchical clusters in which the management node only directly manages the diskful or linux stateless service nodes, and the compute nodes managed by the service nodes can be of any type. 

2\. This documentation is not primarily intended for clusters in which the nodes directly managed by the management node are linux statelite or aix diskless nodes, because the nodes depend on the management node being up to run its operating system over NFS. But if the nodes use only readonly nfs mounts from the MN management node, then you can use this doc as long as you recognize that your nodes will go down while you are failing over to the standby management node. 

## What is Shared Data?

The term 'Shared Data' means that the two management nodes use a single copy of xCAT data, no matter which management node is the primary MN, the cluster management capability is running on top of the single data copy. The acess to the data could be done through various ways like shared storage, NAS, NFS, samba etc. Based on the protocol being used, the data might be accessable only on one management node at a time or be accessable on both management nodes in parellel. If the data could only be accessed from one management node, the failover process need to take care of the data access transition; if the data could be accessed on both management nodes, the failover does not need to consider the data access transition, it usually means the failover process could be faster. 

Warning: Running database through network file system has a lot of potential problems and is not practical, however, most of the database system provides database replication feature that can be used to synronize the database between the two management nodes 

## Configuration Requirements

xCAT HAMN requires that the operating system version, xCAT version and database version be identical on the two management nodes. 

The hardware type/model are not required to be the same on the two management nodes, but it is recommended to have similar hardware capability on the two management nodes to support the same operating system and have similar management capability. 

Since the management node needs to provide IP services through broadcast such as DHCP to the compute nodes, the primary management node and standby management node should be in the same subnet to ensure the network services will work correctly after failover. 

Setting up HAMN can be done at any time during the life of the cluster, in this documentation we assume the HAMN setup is done from the very beginning of the xCAT cluster setup, there will be some minor differences if the HAMN setup is done from the middle of the xCAT cluster setup. 

The examples given in this document are for AIX and RHEL 6. The same approach can be applied to SLES, but the specific commands might be slightly different. The examples in this documentation are based on the following cluster environment: 

Virtual IP Alias Address: 9.114.47.97 

Primary Management Node: aixmn1(9.114.47.103), netmask is 255.255.255.192, hostname is aixmn1. Running AIX AIX 7.1 

Standby Management Node: aixmn2(9.114.47.104)etmask is 255.255.255.192, hostname is aixmn2. Running AIX AIX 7.1 

You need to substitute the hostnames and ip address with your own values when setting up your HAMN environment. 

## Configuring Shared Data

**Note: Shared data itself needs high availability also, the shared data should not become a single point of failure.**

The configuration procedure will be quite different based on the shared data mechanism that will be used. Configuring these shared data mechanisms is beyond the scope of this documentation. The [Setup_HA_Mgmt_Node_With_Shared_Data/#appendix-a-configure-shared-disks](Setup_HA_Mgmt_Node_With_Shared_Data/#appendix-a-configure-shared-disks) gives an example of how to configure shared storage. After the shared data mechanism is configured, the following xCAT directory structure should be on the shared data, if this is done before xCAT is installed, you need to create the directories manually; if this is done after xCAT is installed, the directories need to be copied to the shared data. 

~~~~    
    /etc/xcat
    /install
    ~/.xcat
    /<dbdirectory> (For mysql, the database directory is /var/lib/mysql; for postgresql, the database directory is /var/lib/pgsql; 
    for DB2, the database directory is specified with the site attribute databaseloc; 
    for sqlite, the database directory is /etc/xcat, already listed above. )
~~~~    

Here is an example of how to make directories be shared data through NFS: 

~~~~    
    mount -o rw <nfssvr>:/dir1 /etc/xcat
    mount -o rw <nfssvr>:/dir2 /install
    mount -o rw <nfssvr>:/dir3 ~/.xcat
    mount -o rw <nfssvr>:/dir4 /<dbdirectory>
~~~~    

**Note: if you need to setup high availability for some other applications, like the HPC software stack, between the two xCAT management nodes, the applications data should be on the shared data.**

## Setup xCAT on the Primary Management Node

1\. Make the shared data be available on the primary management node. 

2\. Set up a "Virtual IP address". The xcatd daemon should be addressable with the same Virtual IP address, regardless of which management node it runs on. The same Virtual IP address will be configured as an alias IP address on the management node (primary and standby) that the xcatd runs on. The Virtual IP address can be any unused ip address that all the compute nodes and service nodes could reach. Here is an example on how to configure Virtual IP on AIX and Linux: 


On AIX: 

~~~~    
    ifconfig en0 9.114.47.97 netmask 255.255.255.192 firstalias
~~~~    

On Linux: 

~~~~    
    ifconfig eth0:0 9.114.47.97 netmask 255.255.255.192
~~~~    

The option "firstalias" will configure the Virtual IP ahead of the interface ip address, since ifconfig will not make the ip address configuration be persistent through reboots, so the Virtual IP address needs to be re-configured right after the management node is rebooted. This non-persistent Virtual IP address is designed to avoid ip address conflict when the crashed previous primary management is recovered with the Virtual IP address configured. 

2\. Add the alias ip address into the /etc/resolv.conf as the nameserver. Change the hostname resolution order to be using /etc/hosts before using name server. For AIX, change to "hosts=local,bind" in /etc/netsvc.conf; for Linux change to "hosts: files dns" in /etc/nsswitch.conf. 

3\. Change hostname to the hostname that resolves to the Virtual IP address. This is required for xCAT and database to be setup properly. 

4\. Install xCAT. The procedure described in [XCAT_iDataPlex_Cluster_Quick_Start] could be used for the xCAT setup on the primary management node. 

5\. Check the site table master and nameservers and network tftpserver attribute is the Virtual ip 
  
~~~~  
    lsdef -t site
~~~~    

If not correct: 

~~~~    
    chdef -t site master=9.114.47.97
    chdef -t site nameservers=9.114.47.97
    chdef -t network tftpserver=9.114.47.97
~~~~    

Add the two management nodes into policy table 

~~~~    
    tabdump policy  
    "1.2","aixmn1",,,,,,"trusted",,
    "1.3","aixmn2",,,,,,"trusted",,
~~~~    

6\. (Optional) DB2 only, change the databaseloc in site table 
 
~~~~   
    chdef -t site databaseloc=/dbdirectory
~~~~    

7\. Install and configure database. Refer to the doc [Choosing_the_Database] to configure the database on the xCAT management node. 

Verify xcat is running on correct database by running: 
 
~~~~   
    lsxcatd -a
~~~~    

8\. Backup the xCAT database tables for the current configuration on standby management node, using command dumpxCATdb -p <yourbackupdir>. 

9\. Setup a crontab to backup the database each night by running dumpxCATdb and storing the backup to some filesystem not on the shared data. 

10\. Stop the xcatd daemon and some related network services from starting on reboot: 

On AIX: 
 
~~~~   
      stopsrc -s xcatd
      chitab "xcatd:2:off:/opt/xcat/sbin/restartxcatd &gt; /dev/console 2&gt;&1"
    
    
      stopsrc -s conserver
      chitab "conserver:2:off:/usr/bin/startsrc -s conserver &gt; /dev/console 2&gt;&1"
~~~~    
    

Make sure that in /etc/rc.tcpip,the following lines are commented out. 

~~~~    
    grep named /etc/rc.tcpip
    #start /usr/sbin/named "$src_running"
    
    
    grep dhcpsd /etc/rc.tcpip
    #start /usr/sbin/dhcpsd "$src_running" 
~~~~    

On Linux: 

~~~~    
     service xcatd stop
     chkconfig --level 345 xcatd off  
     service conserver off
     chkconfig --level 2345 conserver off
     service dhcpd stop
     chkconfig --level 2345 dhcpd off
~~~~    

11\. Stop Database and prevent the database from auto starting at boot time 

Use mysql as an example: 

On AIX: 
 
~~~~   
    /usr/local/mysql/bin/mysqladmin -u root -p shutdown
    In /etc/inittab
    mysql:2:off:/usr/local/mysql/bin/mysqld_safe --user=mysql &
~~~~    

On Linux: 

~~~~    
    service mysqld stop
    chkconfig mysqld off
~~~~    

12\. (Optional) If DFM is being used for hardware control capabilities, install DFM package,Setup xCAT to communicate directly to the System P server's service processor. 

~~~~    
     xCAT-dfm RPM 
     ISNM-hdwr_svr RPM (linux) 
     isnm.hdwr_svr installp package (AIX)

~~~~    

13\. If there is any node that is already managed by the Management Node,change the noderes table tftpserver &amp; xcatmaster &amp; nfsserver attributes to the Virtual ip 

14\. Set the hostname back to original non-alias hostname. 

15\. After installing xCAT and database, you could setup service node or compute node. 

## Setup xCAT on the Standby Management Node

1\. Make sure the standby management node is **NOT** using the shared data. 

2\. Add the alias ip address into the /etc/resolv.conf as the nameserver. Change the hostname resolution order to be using /etc/hosts before using name server. For AIX, change to "hosts=local,bind" in /etc/netsvc.conf; for Linux change to "hosts: files dns" in /etc/nsswitch.conf. 

3\. Temporarily change the hostname to the hostname that resolves to the Virtual IP address. This is required for xCAT and database to be setup properly. This only needs to be done one time. 

Also configure the Virtual IP address during this setup. 

On AIX: 
 
~~~~   
    ifconfig en0 9.114.47.97 netmask 255.255.255.192 firstalias
~~~~    

On Linux: 

~~~~    
    ifconfig eth0:0 9.114.47.97 netmask 255.255.255.192
~~~~    

4\. Install xCAT. The procedure described in [XCAT_iDataPlex_Cluster_Quick_Start] can be used for the xCAT setup on the standby management node. The database system on the standby management node must be the same as the one running on the primary management node. 

5\. (Optional) DB2 only, change the databaseloc in site table to be the same as the the primary management node. 
 
~~~~   
    chdef -t site databaseloc=/dbdirectory
~~~~    
    

6\. (Optional) DB2 only, check databaseloc directory 

Without the shared data mounted, the /dbdirectory is a local directory. We need to create a DB2 database instance in this directory before mounting the shared data. This instance will be mounted over with the instance created on the Primary Management Node when the shared data is mounted on the Standby. 

The /dbdirectory must have at least 5Gigbytes for the creation of the DB2 instance. 

7\. (Optional) DB2 only, setup the xcatdb id and group and install database. When setting up database on the Standby, you must make sure that the xcatdb userid groupid and password match what is on the Primary management node. This id is your DB2 database instance and will be mounting the database from the shared data when the Standby takes over. Look up the xcatdb user id number and the xcatdb group id number on the Primary management node. You can use lsuser, lsgroup for AIX , or just look in /etc/passwd and /etc/group. 

On AIX: 
 
~~~~   
    mkgroup -a id=<xcatdb group id number from the Primary management node> xcatdb
    mkuser pgrp='xcatdb' home='<xcatdb home directory from Primary management node>' shell='/bin/ksh' id='<xcatdb user id number from Primary management node>' xcatdb
~~~~    

On Linux: 

~~~~    
    groupadd -g <group id number from the Primary management node>  xcatdb
    useradd -d <xcatdb home directory from the Primary management node>  -g xcatdb -u <uid number from the Primary management node> -m -s /bin/bash xcatdb
~~~~    

Set the xcatdb password 

On AIX (change passwd to match the password on the Primary management node) 

~~~~    
    chpasswd -c
    xcatdb:<passwd>
    ctl-D
~~~~    

On Linux ( change passwd to match the password on the Primary management node) 
    
~~~~ 
   chpasswd
    xcatdb:<passwd>
    ctl-D
~~~~    

Note: we use the chpasswd command so the password will not have to be changed the first time we use the xcatdb userid. 

Install and configure DB2 software on the standby management node using the instructions in [Setting_Up_DB2_as_the_xCAT_DB]. Install DB2 and run db2sqlsetup to setup the xCAT database. 

Verify if xCAT is running correctly with DB2 on the standby management node by running: 

~~~~    
    lsxcatd -a
~~~~    

8\. (Optional) DFM only, Install DFM package 

When installing and configuring DFM on the standby management node,you should follow the document in [XCAT_Power_775_Hardware_Management]. 

~~~~    
    xCAT-dfm RPM 
    ISNM-hdwr_svr RPM (linux) 
    isnm.hdwr_svr installp package (AIX)
~~~~    

9\. Setup hostname resolution between the primary management node and standby management node. Make sure the primary management node can resolve the hostname of the standby management node, and vice versa. 

10\. Setup ssh authentication between the primary management node and standby management node. It should be setup as "passwordless ssh authentication" and it should work in both directions. The summary of this procedure is: 

cat keys from /.ssh/id_rsa.pub on the primary management node and add them to /.ssh/authorized_keys on the standby management node. Remove the standby management node entry from /.ssh/known_hosts on the primary management node prior to issuing ssh to the standby management node. 

cat keys from /.ssh/id_rsa.pub on the standby management node and add them to /.ssh/authorized_keys on the primary management node. Remove the primary management node entry from /.ssh/known_hosts on the standby management node prior to issuing ssh to the primary management node. 

11\. Make sure the time on the primary management node and standby management node is synchronized. Some tips on setting up the timezone and time on AIX: 

Command "echo $TZ" returns the current timezone setting 

Command "date" and "chtz" can be used to adjust the time and timezone. 

To setup ntp on the management nodes on AIX: 

Update the /etc/ntp.conf file with a valid ntp server. 

~~~~    
    stopsrc -s xntpd
    
    
    startsrc -s xntpd
~~~~    

Use ntpq -p to show the peer status of the ntp server, should see * to left of server after successful association with server is established. 

12\. Stop the xcatd daemon and related network services from starting on reboot: 

On AIX: 
 
~~~~   
      stopsrc -s xcatd
      chitab "xcatd:2:off:/opt/xcat/sbin/restartxcatd &gt; /dev/console 2&gt;&1"
    
    
      stopsrc -s conserver
      chitab "conserver:2:off:/usr/bin/startsrc -s conserver &gt; /dev/console 2&gt;&1"
~~~~    
    

Make sure that in /etc/rc.tcpip,the following lines are commented out. 

~~~~    
    grep named /etc/rc.tcpip
    #start /usr/sbin/named "$src_running"
    
    
    grep dhcpsd /etc/rc.tcpip
    #start /usr/sbin/dhcpsd "$src_running" 
~~~~    

On Linux: 

~~~~    
     service xcatd stop
     chkconfig --level 345 xcatd off  
     service conserver off
     chkconfig --level 2345 conserver off
     service dhcpd stop
     chkconfig --level 2345 dhcpd off
~~~~    

13\. Stop Database and prevent the database from auto starting at boot time 

Use mysql as an example: 

On AIX: 

~~~~    
    /usr/local/mysql/bin/mysqladmin -u root -p shutdown
    In /etc/inittab
    mysql:2:off:/usr/local/mysql/bin/mysqld_safe --user=mysql &
~~~~    

On Linux: 
 
~~~~   
    service mysqld stop
    chkconfig mysqld off
~~~~    

14\. Backup the xCAT database tables for the current configuration on standby management node, using command dumpxCATdb -p <yourbackupdir>. 

15\. Change the hostname back to the original hostname. 

16\. Remove the Virtual Alias IP. 

On AIX: 

~~~~    
    ifconfig en0 delete 9.114.47.97
~~~~    

On Linux: 

~~~~    
    ifconfig eth0:0 0.0.0.0 0.0.0.0
~~~~    

  


## File Synchronization

For the files that are changed constantly such as xcat database, /etc/xcat/*, we have to put the files on the shared data; but for the files that are not changed frequently or unlikely to be changed at all, we can simply copy the the files from the primary management node to the standby management node or use crontab and rsync to keep the files synchronized between primary management node and standby management node. Here are some files we recommend to keep synchronization between the primary management node and standby management node: 

### **SSL Credentials and SSH Keys**

To enable both the primary and the standby management nodes to ssh to the service nodes and compute nodes, the ssh keys should be kept synchronized between the primary management node and standby management node. To allow xcatd on both the primary and the standby management nodes to communicate with xcatd on the services nodes, the xCAT SSL credentials should be kept synchronized between the primary management node and standby management node. 

The xCAT SSL credentials reside in the directories /etc/xcat/ca, /etc/xcat/cert and $HOME/.xcat/. The ssh host keys that xCAT generates to be placed on the compute nodes are in the directory /etc/xcat/hostkeys. These directories are on the shared data. 

In addition the ssh root keys in the management node's root home directory (in ~/.ssh) must be kept in sync between the primary management node and standby management node. Only sync the key files and not the authorized_key file. These keys will seldom change, so you can just do it manually when they do, or setup a cron entry like this sample: 

~~~~    
     0 1 * * * /usr/bin/rsync -Lprgotz $HOME/.ssh/id*  aixmn2:$HOME/.ssh/
~~~~    

Now go to the Standby node and add the Primary's id_rsa.pub to the Standby's authorized_keys file. 

### **Network Services Configuration Files**

A lot of network services are configured on the management node, such as DNS, DHCP and HTTP. The network services are mainly controlled by configuration files. However, some of the network services configuration files contain the local hostname/ipaddresses related information, so simply copying these network services configuration files to the standby management node may not work. Generating these network services configuration files is very easy and quick by running xCAT commands such as makedhcp, makedns or nimnodeset, as long as the xCAT database contains the correct information. 

While it is easier to configure the network services on the standby management node by running xCAT commands when failing over to the standby management node, an exception is the /etc/hosts; the /etc/hosts may be modified on your primary management node as ongoing cluster maintenance occurs. Since the /etc/hosts is very important for xCAT commands, the /etc/hosts will be synchronized between the primary management node and standby management node. Here is an example of the crontab entries for synchronizing the /etc/hosts: 

  

~~~~    
    0 2 * * * /usr/bin/rsync -Lprogtz /etc/hosts aixmn2:/etc/
~~~~    

### **Additional Customization Files and Production files**

Besides the files mentioned above, there may be some additional customization files and production files that need to be copied over to the standby management node, depending on your local unique requirements. You should always try to keep the standby management node as an identical clone of the primary management node. Here are some example files that can be considered: 

~~~~    
    /.profile
    /.rhosts
    /etc/auto_master
    /etc/auto/maps/auto.u
    /etc/motd
    /etc/security/limits
    /etc/netscvc.conf
    /etc/ntp.conf
    /etc/inetd.conf
    /etc/passwd
    /etc/security/passwd
    /etc/group
    /etc/security/group
    /etc/exports
    /etc/dhcpsd.cnf
    /etc/services
    /etc/inittab
    (and more)
~~~~   

  
Note: 

  * If the IBM HPC software stack is configured in your environment, please refer to the xCAT wiki page [IBM_HPC_Stack_in_an_xCAT_Cluster] for additional steps required for HAMN setup. 
  * The dhcpsd.cnf should be syncronized between the primary management node and standby management node only when the DHCP configuration on the two management nodes are exactly the same. 

## Cluster Maintenance Considerations

The standby management node should be taken into account when doing any maintenance work in the xCAT cluster with HAMN setup. 

  1. Software Maintenance - Any software updates on the primary management node should also be done on the standby management node. 
  2. File Synchronization - Although we have setup crontab to synchronize the related files between the primary management node and standby management node, the crontab entries are only run in specific time slots. The synchronization delay may cause potential problems with HAMN, so it is recommended to manually synchronize the files mentioned in the section above whenever the files are modified. 
  3. Reboot management nodes - In the primary management node needs to be rebooted, since the daemons are set to not auto start at boot time, and the shared data will not be mounted automatically, you should mount the shared data and start the daemons manually. 

**Note: after software upgrade, some services that were set to not autostart on boot might be started by the software upgrade process, or even set to autostart on boot, the admin should check the services on both primary and standby management node, if any of the services are set to autostart on boot, turn it off; if any of the services are started on the backup management node, stop the service.**

At this point, the HA MN Setup is complete, and customer workloads and system administration can continue on the primary management node until a failure occurs. The xcatdb and files on the standby management node will continue to be synchronized until such a failure occurs. 

## Failover

There are two kinds of failover, planned failover and unplanned failover. The planned failover can be useful for updating the management nodes or any scheduled maintainance activities; the unplanned failover covers the unexpected hardware or software failures. 

In a planned failover, you can do necessary cleanup work on the previous primary management node before failover to the previous standby management node. In a unplanned failover, the previous management node probably is not functioning at all, you can simply shutdown the system. 

### Take down the Current Primary Management Node

Starting with xCAT 2.8.2, xCAT ships a sample script /opt/xcat/share/xcat/hamn/deactivate-mn to make the machine be a standby management node. Before using this script, you need to review the script carefully and make updates accordingly, here is an example of how to use this script: 

~~~~    
     /opt/xcat/share/xcat/hamn/deactivate-mn -i eth1:2 -v 9.114.47.97
~~~~    

**On the current primary management node:**

If the management node is still available and running the cluster, perform the following steps to shutdown. 

**1\. (DFM only) Remove connections from CEC and Frame. **

~~~~    
    rmhwconn cec,frame
    rmhwconn cec,frame -T fnm
~~~~    

**2\. Stop the xCAT daemon.**

Note xCAT must be stopped on all Service Nodes also, and LL if using the database. 

On AIX: 

~~~~    
    stopsrc -s xcatd
    stopsrc -s dhcpsd
    stopsrc -s conserver
    stopsrc -s hdwr_svr
    stopsrc -s named
~~~~    

On Linux: 
    
~~~~
    service xcatd stop
    service dhcpd stop
~~~~    

  
**3\. unexport the xCAT NFS directories**

The exported xCAT NFS directories will prevent the shared data partitions from being unmounted, so the exported xCAT NFS directories should be unmounted before failover. 

~~~~    
    exportfs -ua
~~~~    

**4\. Stop database**

Use mysql as an example: 

~~~~    
    service mysqld stop
~~~~    

**5\. unmount shared data**

All the file systems on the shared data need to be unmounted to make the previous standby management be able to mount the file systems on the shared data. Here is an example: 

~~~~    
    umount /etc/xcat
    umount /install
    umount ~/.xcat
    umount /db2database
~~~~    

When trying to umount the file systems, if there are some processes that are accessing the files and directories on the file systems, you will get "Device busy" error. The following commands can be used to check which progresses are accessing the file systems on AIX: 
 
~~~~   
    fuser -uxc <directory_name>
~~~~    

Then stop or kill all the processes that are accessing the shared data file systems and retry the unmount. 

**6\. (Optional, AIX and shared disk only)varyoff volume group**

~~~~    
    varyoffvg xcatvg
~~~~    

**7\. Unconfigure Virtual IP**

On AIX: 

~~~~    
    ifconfig en0 delete 9.114.47.97
~~~~    

On Linux: 

~~~~    
    ifconfig eth0:0 0.0.0.0 0.0.0.0
~~~~    

If the ifconfig command has been added to rc.local, remove it from rc.local. 

### Bring up the New Primary Management Node

Starting with xCAT 2.8.2, xCAT ships a sample script /opt/xcat/share/xcat/hamn/activate-mn to make the machine be a primary management node. Before using this script, you need to review the script carefully and make updates accordingly, here is an example of how to use this script: 

~~~~    
     /opt/xcat/share/xcat/hamn/activate-mn -i eth1:2 -v 9.114.47.97 -m 255.255.255.0
~~~~    

  
**On the new primary management node:**

**1\. Configure Virtual IP**

On AIX: 
 
~~~~   
    ifconfig en0 9.114.47.97 netmask 255.255.255.192 firstalias
~~~~    

On Linux: 
 
~~~~   
    ifconfig eth0:0 9.114.47.97 netmask 255.255.255.192
~~~~    

You can put the ifconfig command into rc.local to make the Virtual IP be persistent after reboot. 

**2\. (Optional,AIX and shared disk only) varyon volume group**

~~~~    
    varyonvg xcatvg
~~~~    

**3\. Mount shared data**
 
~~~~   
    mount /etc/xcat
    mount /install
    mount /.xcat
    mount /db2database
~~~~    

  


**4\. Start database**

Use mysql as an example: 
 
~~~~   
    service mysql start
~~~~    

**5\. Start the daemons.**

On AIX: 

~~~~    
    startsrc -s dhcpsd
    restartxcatd
    startsrc -s hdwr_svr
    startsrc -s conserver
    startsrc -s named
~~~~    

  
On Linux: 

~~~~    
    service dhcpd start
    service xcatd start
    service hdwr_svr start
    service conserver start
~~~~    

**6\. (DFM only) Setup connection for CEC and Frame**

~~~~  
    
    mkhwconn cec,frame -t
    mkhwconn cec,frame -t -T fnm
    chnwm -a
~~~~    

**7\. Setup network services and conserver**

DNS: run makedns. Verify dns services working for node resolution. Make sure the line "nameserver=&lt;virtual ip&gt;" is in /etc/resolv.conf 

For more information on setting up name resolution in an xCAT Cluster: [Cluster_Name_Resolution] 

DHCP: if the dhcpsd.cnf(AIX) or dhcpd.leases(Linux) is not syncronized between the primary management node and standby management node, run makedhcp -a to setup the DHCP leases. Verify dhcp is operational. 

conserver: run makeconservercf. This will recreate the /etc/conserver.cf config files for all the nodes. 

**9\. (Optional)Setup os deployment environment**

This step is required only when you want to use this new primary management node to perform os deployment tasks. 

[HAMN_OS_Image](HAMN_OS_Image)



**10\. Restart NFS service and re-export the NFS exports**

Because of the Virtual ip configuration and the other network configuration changes on the new primary management node, the NFS service needs to be restarted and the NFS exports need to be re-exported. 

On AIX: 

~~~~    
    exportfs -ua
    stopsrc -g nfs
    startsrc -g nfs
    exportfs -a
~~~~    

On Linux: 
 
~~~~   
    exportfs -ua
    service nfs stop
    service nfs start
    exportfs -a
~~~~    

## Setup the Cluster

At this point you have setup your Primary and Standby management node for HA. You can now continue to setup your cluster. Return to using the Primary management node attached to the shared data. Now setup your Hierarchical cluster using the following documentation, depending on your Hardware,OS and type of install you want to do on the Nodes. The below will cover diskless or statelite nodes. Other docs are available for full disk installs. 

  * [XCAT_System_p_Hardware_Management] 
  * [XCAT_Power_775_Hardware_Management] 
  * [Setting_Up_an_AIX_Hierarchical_Cluster] 
  * [Setting_Up_a_Linux_Hierarchical_Cluster] 
  * [XCAT_AIX_Diskless_Nodes] 
  * [XCAT_pLinux_Clusters] 
  * [XCAT_Linux_Statelite] 

  
For all the xCAT docs: [XCAT_Documentation] 

## Appendix A Configure Shared Disks

The steps to configure shared disks are quite different between AIX and Linux, the following two sections describe how to configure shared disks on AIX and Linux. And the steps do not apply to all shared disks configuration scenarios, you may need to use some slightly different steps according to your shared disks configuration. 

### Configuring Shared Disks on AIX

The operating system is installed on the internal disks. 

**1\. Connect the first shared drawer and verify you can see the disks.**
 
~~~~   
     [aixmn1]/# cfgmgr
    
    
     [aixmn1]/# lspv
     hdisk0          00f604c9b0818d40                    rootvg          active      
     hdisk1          00f604c9b0819a1d                    rootvg          active      
     hdisk2          none                                None                        
     hdisk3          none                                None                        
     hdisk4          none                                None                        
     hdisk5          none                                None                        
     hdisk6          none                                None                        
     hdisk7          none                                None                        
     hdisk8          none                                None                        
     hdisk9          none                                None                        
     hdisk10         none                                None                        
     hdisk11         none                                None                        
     hdisk12         none                                None                        
     hdisk13         none                                None                        
~~~~   

**2\. Configure the disks and create the arrays using diag.**
    
     [aixmn1]/# diag
     
     Task Selection (Diagnostics, Advanced Diagnostics, Service Aids, etc.)
     
     RAID Array Manager
    
    
     IBM SAS Disk Array Manager
     
     Create an Array Candidate pdisk and Format to 528 Byte Sectors
    
    
     Select the correct sas adapter
     
     Select the attached disks. Configuration takes about 40 minutes.

~~~~
     
     hdisk0          00f604c9b0818d40                    rootvg          active      
     hdisk1          00f604c9b0819a1d                    rootvg          active      
     hdisk2          none                                None                        
     hdisk3          none                                None                        
     hdisk4          none                                None                        
     hdisk5          none                                None                        
     hdisk6          none                                None                        
     hdisk7          none                                None                        
     hdisk8          none                                None                        
     hdisk9          none                                None                        
     hdisk10         none                                None                        
     hdisk11         none                                None                        
     hdisk12         none                                None                        
     hdisk13         none                                None                        
~~~~    
    
     Create a SAS Disk Array
    
~~~~    
     sissas1 Available 04-00 PCI Express x8 Ext Dual-x4 3Gb SAS RAID Adapter    
    
     6    
    
     256
~~~~    
    
     Select Disks to Use in the Array                     |
    
~~~~    
     # RAID 6 supports a minimum of 4 and a maximum of 18 disks.
     pdisk12   00040000  Active      Array Candidate        428.4GB Zeroed
     pdisk13   00040100  Active      Array Candidate        428.4GB Zeroed
     pdisk14   00040200  Active      Array Candidate        428.4GB Zeroed
     pdisk15   00040300  Active      Array Candidate        428.4GB Zeroed
     pdisk16   00040400  Active      Array Candidate        428.4GB Zeroed
     pdisk17   00040500  Active      Array Candidate        428.4GB Zeroed
     pdisk18   00040600  Active      Array Candidate        428.4GB Zeroed
     pdisk19   00040700  Active      Array Candidate        428.4GB Zeroed
     pdisk20   00040800  Active      Array Candidate        428.4GB Zeroed
     pdisk21   00040900  Active      Array Candidate        428.4GB Zeroed 
     pdisk22   00040A00  Active      Array Candidate        428.4GB Zeroed
     pdisk23   00040B00  Active      Array Candidate        428.4GB Zeroed
~~~~    

**3\. Exit and now you should see one disk.**

~~~~    
     [aixmn1]/# lspv
     hdisk0          00f604c9b0818d40                    rootvg          active      
     hdisk1          00f604c9b0819a1d                    rootvg          active      
     hdisk2          none                                None                        
~~~~    

**4\. Temporarily disconnect the cables to the first drawer. Connect the second drawer and repeat steps. **

**5\. Connect both servers to both both drawers.**

To verify the shared disks are connected correctly, run the lspv command on both management nodes and look for the same PVID in the output. 

In the following example, hdisk1, hdisk2 and hdisk3 have same PVIDs on both servers. 

On the primary management node: 

~~~~    
     [aixmn1]/# lspv
     hdisk0          00f604c7c3c22499                    rootvg          active
     hdisk1          00f604c7c5b0533a                    rootvg          active
     hdisk2          00f604c945edde6f                    None
     hdisk3          00f604c945ede480                    None
~~~~    

On the standby management node: 

~~~~    
     [aixmn2]/# lspv
     hdisk0          00f604c7c3c22499                    rootvg          active
     hdisk1          00f604c7c5b0533a                    rootvg          active
     hdisk2          00f604c945edde6f                    None
     hdisk3          00f604c945ede480                    None
~~~~    

**6\. Create a volume group and logical volume on the primary management node with no auto varyon during system reboot.**

On the primary management node: 

  

~~~~    
    [aixmn1]/# mkvg -n -f -y xcatvg hdisk2 hdisk3 
    
    0516-1254 mkvg: Changing the PVID in the ODM.
    
    0516-1254 mkvg: Changing the PVID in the ODM.
    
    0516-1254 mkvg: Changing the PVID in the ODM.
    
    xcatvg
    
    [aixmn1]/# mklv -y loglv00 -t jfs2log -u 1 xcatvg 1 hdisk2
    [aixmn1]/# echo y | logform /dev/loglv00
    [aixmn1]/# mklv -y xcatlv -t jfs2 -u 2 xcatvg 200 hdisk2 hdisk3
~~~~    

After the volume group is created, varyon it before creating file systems on it. 

~~~~    
    varyonvg xcatvg
~~~~    

**7\. Create xCAT file systems on the primary management node with no auto mount during system reboot.**

The following xCAT directories should be put on the shared disk for failover. If you have any applications specific data that need to be shared between the two management nodes, you can put the data on the shared disks also. 

~~~~    
    mkdir -p /etc/xcat
    mkdir -p /install
    mkdir -p ~/.xcat
    mkdir -p /db2database
    crfs -v jfs2 -g xcatvg -a size=1G -m /etc/xcat
    crfs -v jfs2 -g xcatvg -a size=50G -m /install
    crfs -v jfs2 -g xcatvg -a size=512M -m ~/.xcat
    crfs -v jfs2 -g xcatvg -a size=100G -m /db2database
    mount /etc/xcat
    mount /install
    mount /.xcat
    mount /db2database
~~~~    

**The given sizes are based on setting up a large Power 775 cluster. They may need to be increased or changed during the life of the cluster.**

To verify the file systems, check the /etc/filesystems: 

~~~~    
    cat /etc/filesystems
    ...
    /etc/xcat:
           dev             = /dev/lv00
           vfs             = jfs
           log             = /dev/loglv00
           mount           = false
           account         = false
    /install:
           dev             = /dev/lv01
           vfs             = jfs
           log             = /dev/loglv00
           mount           = false
           account         = false
    /.xcat:
           dev             = /dev/lv02
           vfs             = jfs
           log             = /dev/loglv00
           mount           = false
           account         = false
    /db2database:
           dev             = /dev/lv03
           vfs             = jfs
           log             = /dev/loglv00
           mount           = false
           account         = false
~~~~    

**8\. Test connectivity from the Standby node. Unmount and Varyoff the volume group on the primary management node.**

On the primary management node, enter: 
 
~~~~   
    mount /etc/xcat
    mount /install
    mount ~/.xcat
    mount /db2database
    varyoffvg xcatvg
~~~~    

**9\. Import the volume group and mount the filesystems on the standby management node. This will import the the volume group and file systems configuration automatically.**

On the standby management node, enter: 

~~~~    
    importvg -y xcatvg hdisk1
    varyonvg xcatvg
    mount /etc/xcat
    mount /install
    mount /.xcat
    mount /db2database
~~~~    

**10\. Then unmount the file systems and varyoff the xcatvg volume group on the standby management node.**
 
   
     umount /etc/xcat
     umount /install
     umount /.xcat
     umount /db2database
     varyoffvg xcatvg
~~~~    

### Configuring Shared Disks on Linux

**1\. Connect the shared disk to both management nodes.**

To verify the shared disks are connected correctly, run the sginfo command on both management nodes and look for the same serial number in the output. Please be aware that the sginfo command may not be installed by default on Linux, the sginfo command is shipped with package sg3_utils, you can manually install the package sg3_utils on both management nodes. 

Once the sginfo command is installed, run sginfo -l command on both management nodes to list all the known SCSI disks, for example, enter: 

~~~~    
    sginfo -l
~~~~    

Output will be similar to: 

~~~~    
    /dev/sdd /dev/sdc /dev/sdb /dev/sda
    /dev/sg0 [=/dev/sda  scsi0 ch=0 id=1 lun=0]
    /dev/sg1 [=/dev/sdb  scsi0 ch=0 id=2 lun=0]
    /dev/sg2 [=/dev/sdc  scsi0 ch=0 id=3 lun=0]
    /dev/sg3 [=/dev/sdd  scsi0 ch=0 id=4 lun=0]
~~~~    

Use the sginfo -s &lt;device_name&gt; to identify disks with the same serial number on both management nodes, for example: 

On the primary management node: 

~~~~    
    [root@primary ~]# sginfo -s /dev/sdb
    Serial Number '1T23043224      '
    
    [root@primary ~]#
~~~~    

On the standby management node: 

~~~~    
    [root@standby~]# sginfo -s /dev/sdb
    Serial Number '1T23043224      '
    
    [root@standby ~]#
~~~~    

We can see that the /dev/sdb is a shared disk on both management nodes. In some cases, as with mirrored disks and when there is no matching of serial numbers between the two management nodes, multiple disks on a single server can have the same serial number, In these cases, format the disks, mount them on both management nodes, and then touch files on the disks to determine if they are shared between the management nodes. 

**2\. Create partitions on shared disks**

After the shared disks are identified, create the partitions on the shared disks using fdisk command on the primary management node. Here is an example: 

~~~~    
     fdisk /dev/sdc
~~~~    

Verify the partitions are created by running fdisk -l. 

**3\. Create file systems on shared disks**

Run the mkfs.ext3 command on the primary management node to create file systems on the shared disk that will contain the xCAT data. For example: 

~~~~    
    mkfs.ext3 -v /dev/sdc1
    mkfs.ext3 -v /dev/sdc2
    mkfs.ext3 -v /dev/sdc3
    mkfs.ext3 -v /dev/sdc4
~~~~    

If you place entries for the disk in /etc/fstab, which is not required, ensure that the entries do not have the system automatically mount the disk. 

  
Note: Since the file systems will not be mounted automatically during system reboot, it implies that you need to manually mount the file systems after the primary management node reboot. Before mounting the file systems, stop xcat daemon first; after the file systems are mounted, start xcat daemon. 

**4\. Verify the file systems on the primary management node.**

Verify the file systems could be mounted and written on the primary management node, here is an example: 

~~~~    
    mount /dev/sdc1 /etc/xcat
    mount /dev/sdc2 /install
    mount /dev/sdc3 ~/.xcat
    mount /dev/sdc4 /db2database
~~~~    

After that, umount the file system on the primary management node: 

~~~~    
    umount /etc/xcat
    umount /install
    umount ~/.xcat 
    umount /db2database
~~~~    

**5\. Verify the file systems on the standby management node** On the standby management node, verify the file systems could be mounted and written. 

~~~~    
    mount /dev/sdc1 /etc/xcat
    mount /dev/sdc2 /install
    mount /dev/sdc3 ~/.xcat
    mount /dev/sdc4 /db2database
~~~~    

You may get errors "mount: you must specify the filesystem type" or "mount: special device /dev/sdb1 does not exist" when trying to mount the file systems on the standby management node, this is caused by the missing devices files on the standby management node, run fidsk /dev/sdx and simply select "w write table to disk and exit" in the fdisk menu, then retry the mount. 

After that, umount the file system on the standby management node: 

~~~~    
    umount /etc/xcat
    umount /install
    umount ~/.xcat
    umount /db2database
~~~~    
