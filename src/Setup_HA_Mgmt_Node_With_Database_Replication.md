<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Configuration Requirements](#configuration-requirements)
- [Setup Database Replication](#setup-database-replication)
  - [**DB2 High Availability Disaster Recovery (HADR) Setup**](#db2-high-availability-disaster-recovery-hadr-setup)
    - [**Disconnect all the DB2 Clients**](#disconnect-all-the-db2-clients)
    - [**Setup configuration parameters for xcatdb**](#setup-configuration-parameters-for-xcatdb)
    - [**Backup xcatdb on Primary Management Node**](#backup-xcatdb-on-primary-management-node)
    - [**Restore xcatdb on Standby Management Node**](#restore-xcatdb-on-standby-management-node)
    - [**Configure HADR services ports**](#configure-hadr-services-ports)
    - [**Configure the HADR Parameters**](#configure-the-hadr-parameters)
    - [**Start HADR**](#start-hadr)
    - [**Verify HADR Status**](#verify-hadr-status)
    - [**Test Database Synchronization**](#test-database-synchronization)
    - [**Some useful HADR commands**](#some-useful-hadr-commands)
  - [**Database Replication for Postgresql**](#database-replication-for-postgresql)
  - [**Database Replication for Other Database Systems**](#database-replication-for-other-database-systems)
- [File Synchronization](#file-synchronization)
  - [**SSL Credentials and SSH Keys**](#ssl-credentials-and-ssh-keys)
- [**Cluster Maintenance Considerations**](#cluster-maintenance-considerations)
- [Failover](#failover)
    - [*Setup the network services and conserver:](#setup-the-network-services-and-conserver)
    - [Setup os deployment environment](#setup-os-deployment-environment)
- [Failback](#failback)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note:**

  * **The procedure in this documentation is not thoroughly tested, use this doc at your own risk.**
  * **This documentation does not work for Power 775 configuration. For Power 775 HA management node, please use [Setup_HA_Mgmt_Node_With_Shared_Disks] instead**

  



## Overview

This documentation illustrates how to setup a second management node, or standby management node, in your cluster to provide high availability management capability when there is no shared disks configured between the two management nodes. If DB2 is used in your cluster, this documentation only applies to xCAT 2.5 or newer releases. 

When the primary xCAT management node fails, the administrator can easily have the standby management node take over role of the management node, and thus avoid long periods of time during which your cluster does not have active cluster management function available. 

The xCAT high availability management node(HAMN) feature is not designed for automatic setup or automatic failover, this documentation will describe how to synchronize various data between the primary management node and standby management node automatically, and describe how to perform some manual steps to have the standby management node takeover the management node role when failures occur on the primary management node. However, high availability applications such as IBM Tivoli System Automation(TSA) can be used to achieve automatic failover, this documentation also describes how to configure HAMN with IBM Tivoli System Automation(TSA) to perform automatic failover. 

The primary management node will be taken down during the failover process, so any NFS mount or other network connections from the compute nodes to the management node should be temporarily disconnected during the failover process. If the network connectivity is required for compute node run-time operations, you should consider some other way to provide high availability for the network services unless the compute nodes can also be taken down during the failover process. This also implies: 

    1\. This HAMN approach is primarily intended for clusters in which the management node manages diskful 
nodes or linux stateless nodes. This also includes hierarchical clusters in which the management node only
 directly manages the diskful or linux stateless service nodes, and the compute nodes managed by the service 
nodes can be of any type. 

    2\. This documentation is **not **primarily intended for clusters in which the nodes directly managed by 
 the management node are linux statelite or aix diskless nodes, because the nodes depend on the management node
 being up to run its operating system over NFS. But if the nodes use only readonly nfs mounts from the MN 
management node, then you can use this doc as long as you recognize that your nodes will go down while you are 
failing over to the standby management node. 

  
**Note: If you are using twin-tailed shared disks between the primary management node and standby management node, the steps below are quite different, please see [Setup_HA_Mgmt_Node_With_Shared_Disks].**

## Configuration Requirements

[HAMN_Configuration_Requirements](HAMN_Configuration_Requirements) 

[HAMN_Setup_MNs](HAMN_Setup_MNs) 

## Setup Database Replication

The most important data that needs to be kept synchronized on the primary management node and standby management node is the xCAT database. Most of the commercial database systems and some free database systems such as Postgresql and MySQL provide a database replication feature. The database replication feature can be used for high availability capability. The configuration for database replication is quite different with various database systems, so this documentation can not cover all of the configuration scenarios. This documentation will focus on database replication configuration for DB2, and will also provide some documentation links for the replication setup for some of the other database systems. You can refer to the "Setup DB2 as the xCAT Database" document link at [Setting_Up_DB2_as_the_xCAT_DB] for more details on how to setup DB2 as the xCAT database. 

### **DB2 High Availability Disaster Recovery (HADR) Setup**

DB2 High Availability Disaster Recovery (HADR) is a database replication feature that provides a high availability solution. HADR transmits the log records from the primary database server to the standby server. The HADR standby replays all the log records to its copy of the database, keeping it synchronized with the primary database server. Applications can only access the primary database and have no access to the standby database. 

HADR communication between the primary and the standby is through TCP/IP, so the primary database server and standby database server do not need to be in the same subnet. 

This documentation will only describe some basic configuration steps for HADR setup. There may be some configuration deviations in different cluster environments, so please refer to the following links for more details: 

  1. Redbook "High Availability and Disaster Recovery Options for DB2 on Linux UNIX and Windows" http://www.redbooks.ibm.com/abstracts/sg247363.html 
  2. DB2 Information Center http://publib.boulder.ibm.com/infocenter/db2luw/v9r5/index.jsp?topic=/com.ibm.db2.luw.admin.ha.doc/doc/c0011748.html 

Please be aware that all the DB2 commands in this section should be run as xcatdb unless otherwise noted. 

#### **Disconnect all the DB2 Clients**

Before proceeding with the DB2 HADR setup, all the DB2 clients should be disconnected from the DB2 database server. For the xCAT environment, the only DB2 clients should be xcatd, so the xcatd on both management node and service nodes need to be stopped using the command stopsrc -s xcatd. If there is any other DB2 client running on the management node, you need to disconnect all the clients. 

One way to ensure that all are disconnectd is on the management node, run the following: 
   
~~~~ 
      su - xcatdb
      > db2 force application all
~~~~    

#### **Setup configuration parameters for xcatdb**

Several configuration parameters need to be updated for HADR on both the primary management node and standby management node. Please be aware that all the DB2 commands in this section should be run as user xcatdb unless otherwise noted. 

~~~~     
    su - xcatdb
    db2 UPDATE DB CFG FOR XCATDB USING LOGRETAIN ON
    db2 UPDATE DB CFG FOR XCATDB USING TRACKMOD ON
    db2 UPDATE DB CFG FOR XCATDB USING LOGINDEXBUILD ON
    db2 UPDATE DB CFG FOR XCATDB USING INDEXREC RESTART
~~~~     

#### **Backup xcatdb on Primary Management Node**

The xcatdb on the primary management node and standby management node should be synchronized before setting up the HADR, otherwise, we will run into errors when trying to start HADR. 

Note: as of xCAT 2.6, the xcatdb instance directory for DB2 can be change by setting the site table databaseloc attribute to the filesystem you would like to use. Our example below uses the default of /var/lib/db2. If you have changed that in the site.databaseloc setting, then use your new directory. For example: if databaseloc is set to the following: 

~~~~     
    "databaseloc","/databaseloc",,
~~~~     

then /var/lib/db2 should be replaced with /databaseloc/db2. 

  
as root 
 
~~~~    
    mkdir /var/lib/db2/backup
    chown xcatdb:xcatdb /var/lib/db2/backup
~~~~     

  
as xcatdb 

~~~~     
    db2 BACKUP DB XCATDB TO /var/lib/db2/backup/
~~~~     

  
The command output will be something like: 

  

    
    Backup successful. The timestamp for this backup image is: 20100805161232
    

  
Record the timestamp for later use, this timestamp is also part of the filename saved in /var/lib/db2/backup 

  
Note: if you get an error, like "SQL1035N The database is currently in use. SQLSTATE=57019'**", make sure your xcatd daemons on the management node and service nodes are not running. Deactivating the xcatdb using command "db2 DEACTIVATE DB XCATDB" may also be helpful.

#### **Restore xcatdb on Standby Management Node**

Copy the xcatdb backup from the primary management node to standby management node: 

~~~~     
    scp -rp /var/lib/db2/backup xcatdb@aixmn2:/var/lib/db2/
~~~~     

  
Restore the xcatdb database: 

~~~~     
    su - xcatdb
    db2 RESTORE DATABASE XCATDB FROM "/var/lib/db2/backup" TAKEN AT 20100805161232 REPLACE HISTORY FILE
~~~~     

  
You will be prompted with the following question:

~~~~  

SQL2539W Warning! Restoring to an existing database that is the same as the 

backup image database. The database files will be deleted. 

Do you want to continue? (y/n)  
    
    Answer: y
~~~~     

#### **Configure HADR services ports**

Add the following lines into /etc/services on both the primary management node and standby management node. You need to run as root to edit /etc/services. 

  

~~~~     
    DB2_HADR_1 55001/tcp
    DB2_HADR_2 55002/tcp
~~~~     

#### **Configure the HADR Parameters**

Use the following commands to configure the HADR parameters. 

Substitute the IP addresses in the example with your addresses. 

  
On primary management node:

~~~~     
    su - xcatdb
    db2 UPDATE ALTERNATE SERVER FOR DATABASE XCATDB USING HOSTNAME 9.114.47.104 PORT 60000
    db2 UPDATE DB CFG FOR XCATDB USING HADR_LOCAL_HOST 9.114.47.103
    db2 UPDATE DB CFG FOR XCATDB USING HADR_LOCAL_SVC DB2_HADR_1
    db2 UPDATE DB CFG FOR XCATDB USING HADR_REMOTE_HOST 9.114.47.104
    db2 UPDATE DB CFG FOR XCATDB USING HADR_REMOTE_SVC DB2_HADR_2
    db2 UPDATE DB CFG FOR XCATDB USING HADR_REMOTE_INST xcatdb
    db2 UPDATE DB CFG FOR XCATDB USING HADR_SYNCMODE NEARSYNC
    db2 UPDATE DB CFG FOR XCATDB USING HADR_TIMEOUT 3
    db2 UPDATE DB CFG FOR XCATDB USING HADR_PEER_WINDOW 120
    db2 CONNECT TO XCATDB
    db2 QUIESCE DATABASE IMMEDIATE FORCE CONNECTIONS
    db2 UNQUIESCE DATABASE
    db2 CONNECT RESET
~~~~     

On Standby management node:

  

~~~~     
    su - xcatdb
    db2 UPDATE ALTERNATE SERVER FOR DATABASE XCATDB USING HOSTNAME 9.114.47.103 PORT 60000
    db2 UPDATE DB CFG FOR XCATDB USING HADR_LOCAL_HOST 9.114.47.104
    db2 UPDATE DB CFG FOR XCATDB USING HADR_LOCAL_SVC DB2_HADR_2
    db2 UPDATE DB CFG FOR XCATDB USING HADR_REMOTE_HOST 9.114.47.103
    db2 UPDATE DB CFG FOR XCATDB USING HADR_REMOTE_SVC DB2_HADR_1
    db2 UPDATE DB CFG FOR XCATDB USING HADR_REMOTE_INST xcatdb
    db2 UPDATE DB CFG FOR XCATDB USING HADR_SYNCMODE NEARSYNC
    db2 UPDATE DB CFG FOR XCATDB USING HADR_TIMEOUT 3
    db2 UPDATE DB CFG FOR XCATDB USING HADR_PEER_WINDOW 120
~~~~     

#### **Start HADR**

On the standby management node, start HADR as the standby database: 

  

~~~~     
    db2 DEACTIVATE DATABASE XCATDB
    db2 START HADR ON DATABASE XCATDB AS STANDBY
~~~~     

  
On the primary management node, start HADR as the primary database: 

~~~~     
    db2 DEACTIVATE DATABASE XCATDB
    db2 START HADR ON DATABASE XCATDB AS PRIMARY
~~~~     

  
If you get any message other than "DB20000I The START HADR ON DATABASE command completed successfully", make sure all the steps described above have been done correctly, or refer to the DB2 information center for troubleshooting. 

#### **Verify HADR Status**

HADR can be in the wrong state even if the "START HADR" command returns successfully. The commands "db2 GET SNAPSHOT FOR DB ON XCATDB" or "db2pd -d xcatdb -hadr" can be used to verify HADR status. The HADR status output is quite similar between these two commands, here is an example: 

  
~~~~ 
    
    **db2 GET SNAPSHOT FOR DB ON XCATDB**
    HADR Status
    Role = Primary
    State = Peer
    Synchronization mode = Nearsync
    Connection status = Connected, 08/05/2010 20:33:00.412948
    Peer window end = 08/05/2010 21:03:07.000000 (1281013387)
    Peer window (seconds) = 120
    Heartbeats missed = 0
    Local host = 9.114.47.103
    Local service = DB2_HADR_1
    Remote host = 9.114.47.104
    Remote service = DB2_HADR_2
    Remote instance = xcatdb
    timeout(seconds) = 3
    Primary log position(file, page, LSN) = S0000002.LOG, 18, 000000000FA18D7C
    Standby log position(file, page, LSN) = S0000002.LOG, 18, 000000000FA18D7C
    Log gap running average(bytes) = 0
~~~~     

  
~~~~ 
    
    **db2pd -d xcatdb -hadr**
    Database Partition 0 -- Database XCATDB -- Active -- Up 0 days 01:17:11
    HADR Information:
     Role State SyncMode HeartBeatsMissed LogGapRunAvg (bytes)
     Primary Peer Nearsync 0 0
     ConnectStatus ConnectTime Timeout
     Connected Thu Aug 5 20:33:00 2010 (1281011580) 3
     PeerWindowEnd PeerWindow
     Thu Aug 5 21:52:07 2010 (1281016327) 120
     LocalHost LocalService
     9.114.47.103 DB2_HADR_1
     RemoteHost RemoteService RemoteInstance
     9.114.47.104 DB2_HADR_2 xcatdb
     PrimaryFile PrimaryPg PrimaryLSN
     S0000002.LOG 66 0x000000000FA4869D
     StandByFile StandByPg StandByLSN
     S0000002.LOG 66 0x000000000FA4869D
~~~~     

  
The attributes "Role", "State" and "ConnectStatus" need to be checked. For an operating HADR environment, the "Role" should be "Primary" or "Standby"; the "State" should be "Peer" and the "ConnectStatus" should be "Connected". If any of the attributes are not correct, you need to go back to check the HADR settings and try to restart the HADR, if the problem persists, refer to DB2 documentation or contact the DB2 service team. 

#### **Test Database Synchronization**

After the HADR setup is done, we should verify the database synchronization between the primary management node and standby management node. Here are the recommended steps: 

On the primary management node: 

  1. start xcatd, for example, using startsrc -s xcatd on AIX 
  2. Add a new testnode 
  3. stop xcatd, for example, using stopsrc -s xcatd on AIX 

On the standby management node: 

  1. Takeover as the HADR primary using command "db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster" 
  2. startxcatd, for example, using startsrc -s xcatd on AIX 
  3. Verify the testnode is in database and the node attributes are correct 
  4. Delete the testnode from database 
  5. stop xcatd, for example, using stopsrc -s xcatd on AIX 

On the primary management node: 

  1. Takeover as the HADR primary using command "db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster" 
  2. start xcatd, for example, using startsrc -s xcatd on AIX 
  3. Verify the testnode is not in the database 

#### **Some useful HADR commands**

Besides the HADR related commands described above, there are other HADR commands that are useful for administration and debugging. When debugging errors, a good resource is the DB2 Information Center at http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp . For example, the message SQL1117N can be found in Database reference &gt; Messages &gt; SQL Messages &gt; SQL1000 - SQL1499 

Stop HADR :

~~~~     
    db2 STOP HADR ON DATABASE XCATDB
~~~~     

Note: On the HADR standby database server, after the HADR is stopped, the database is in "ROLL-FORWARD PENDING" state and the xcatdb can not be activated, this error is returned: "SQL1117N A connection to or activation of database "XCATDB" cannot be made because of ROLL-FORWARD PENDING. SQLSTATE=57019", for the SQLSTATE=57019 , use the command "db2 ROLLFORWARD DATABASE XCATDB TO END OF LOGS AND COMPLETE" to fix this problem. 

Check xcatdb configuration :

~~~~     
    db2 CONNECT TO XCATDB
    db2 GET DB CFG
~~~~     

Takeover HADR role: 

~~~~     
    db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster
~~~~     

OR 

~~~~     
    db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster BY FORCE
~~~~     

The "BY FORCE" option should be used only if the primary database server is not functional. 

### **Database Replication for Postgresql**

Postgresql does provide the feature "Continuous Archiving and Point-In-Time Recovery (PITR)" that can be used to provide high availability cluster configuration. See http://www.postgresql.org/docs/8.4/interactive/warm-standby.html and http://www.postgresql.org/docs/8.4/interactive/continuous-archiving.html for more details. 

However, this feature actually uses the "backup on the primary database server" and "restore on the standby database server". Because PITR is not real-time replication, the backup interval is configured manually in the postgresql.conf file, and the recovery interval is configured in recovery.conf. It will save a lot of database logging files and these logging files take large amounts of disk space (each logging file uses about 16MB disk space). Based on these considerations, using the database backup command pg_dump and restore command pg_restore seems to be a better solution for the xCAT postgresql database replication. 

  
On the primary management node:

add crontab entries to: 

  1. dump the xcatdb into a file 
  2. scp the xcatdb backup file to the standby management node 

Here is an example of the crontab entries for user postgres: 

~~~~     
    0 3 * * * /var/lib/pgsql/bin/pg_dump -f /tmp/xcatdb -F t xcatdb
~~~~     

  
Here is an example of the crontab entries for user root: 

  

~~~~     
    0 4 * * * scp /tmp/xcatdb aixmn2:/tmp/
~~~~     

  
On the standby management node:

stop the xcatd and Postgresql. 

AIX: 

~~~~     
    stopsrc -s xcatd
    su - postgres
    /var/lib/pgsql/bin/pg_ctl -D /var/lib/pgsql/data stop
~~~~     

Linux: 

~~~~     
    service xcatd stop
    su - postgres
    service postgresql stop
~~~~     

  


Add a crontab entry to restore the database, here is an example of the crontab entries for user postgres: 

~~~~     
    0 5 * * * /var/lib/pgsql/bin/pg_restore -d xcatdb -c /tmp/xcatdb
~~~~     

### **Database Replication for Other Database Systems**

This documentation will not cover the details for setting up replication for the database systems other than DB2. Here are some useful links for setting up database replication for various database systems supported by xCAT. 

 
~~~~  
MySQL: http://dev.mysql.com/doc/refman/5.5/en/replication.html 
~~~~ 
  
sqlite: sqlite does not provide replication feature. However, since sqlite is a file-based database, you can use a file copy or synchronization mechanism on Unix/Linux to achieve the database synchronization. Sqlite does not support a hierarchical xCAT cluster. It does not support database clients that are required on the service nodes in a hierarchical cluster. 

## File Synchronization

To make the standby management node be ready for an easy take over, there are a lot files that should be kept synchronized between the primary management node and standby management node. 

A straightforward way to keep files synchronized is to use rsync. rsync is shipped with xCAT as part of the xcat-dep on AIX and also shipped with Linux distribution. You can see more details on the official rsync website http://samba.org/rsync/. You can use crontab to automate the synchronization. This documentation will use rsync and crontab as the file synchronization solution. You can use your own file synchronization solution as long as it keeps the corresponding files synchronized between the primary management node and standby management node. 

### **SSL Credentials and SSH Keys**

The SSL credentials need to be identical on the primary management node and standby management node. The xcatd requests submitted from service nodes and compute nodes depend on the SSL credentials. 

To setup the ssh authentication between the primary management node, standby management node, service nodes and compute nodes, the ssh keys should be kept synchronized between the primary management node and standby management node. 

The SSL credentials reside in the directories /etc/xcat/ca, /etc/xcat/cert and $HOME/.xcat/. The ssh keys are in the directory /etc/xcat/hostkeys. 

  
Here is an example of the crontab entries for synchronizing the SSL credentials and SSH keys: 

~~~~     
    0 1 * * * /usr/bin/rsync -Lprgotz /etc/xcat/ca /etc/xcat/cert /etc/xcat/hostkeys aixmn2:/etc/xcat
    0 1 * * * /usr/bin/rsync -Lprgotz $HOME/.xcat aixmn2:$HOME/
~~~~     

  
Note: You can backup the $HOME/.ssh directory in case some information from the $HOME/.ssh on the primary management node is needed after failover. This is an optional step: 

~~~~     
    0 1 * * * /usr/bin/rsync -Lprgotz $HOME/.ssh aixmn2:$HOME/sshbackup/
~~~~     

  
[HAMN_File_Syncronization](HAMN_File_Syncronization) 

## **Cluster Maintenance Considerations**

[HAMN_Cluster_Maintainance](HAMN_Cluster_Maintainance) 

## Failover

When the primary management node fails for whatever reason, the failover process should be started, there are two methods to perform the failover: manual failover and automatic failover. The administrator can start the manual failover process with some manual steps. The following manual procedure should be followed in the event of a failure on the primary management node. Or, the administrators can configure HAMN with IBM Tivoli System Automation(TSA) to achieve automatic failover, see [Configure_HAMN_with_TSA] for more details. 

  * Failover the database replication 

Use the description in the section "setup database replication" to failover the database replication to the standby management node if necessary. Using the DB2 HADR configuration as an example, there are two scenarios that require different procedures. If the outage is a known outage where the standby management node takes over before the primary management node goes down, the command "db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster" can be used to failover the HADR; if the outage is a unknown outage where the primary management node remains in control until the primary management goes down, the command "db2 TAKEOVER HADR ON DATABASE XCATDB USER xcatdb USING cluster BY FORCE" can be used to failover the HADR. The "BY FORCE" option is required when the DB2 database on the primary management node is not functional. 

  * Shutdown the primary management node 

If the primary management node is not totally dead, shutdown the primary management node. The standby management node cannot take over the management role if the primary management node is still up, since the standby management node will be configured with the hostname and ip address that the primary management was configured with. When the primary management node is shutdown, the service nodes and compute nodes may no longer function, depending on the type of node installation that was used. If xCAT is still active on the primary management node at this time, rpower and xdsh can be used to shutdown the nodes if needed. 

  * Stop the database system on the standby management node 

Using DB2 as an example, the following commands can be used to stop DB2: 

~~~~     
    db2 STOP HADR ON DATABASE XCATDB
~~~~     

Note: If you get error message SQL1769N Stop HADR cannot complete. Reason code = "2", try to run command 

~~~~     
    db2 DEACTIVATE DATABASE XCATDB USER XCATDB USING cluster
~~~~     

and then rerun the 

~~~~     
    db2 STOP HADR ON DATABASE XCATDB 
 
    db2 connect reset
    db2 force applications all
    db2 terminate
    db2stop
~~~~     

  * On the standby management node, change the ip address and hostname configured on cluster-facing adapters to the ones that were configured on the primary management node. Here is an example: 
  
~~~~  
    /usr/sbin/mktcpip -h'aixmn1' -a'9.114.47.103' -m'255.255.255.192' -i'en1' -g'9.114.47.126' -t'N/A'
~~~~    

Note: the mktcpip command will update /etc/hosts also. If this not desired, you can use the chdev command instead. 

It is recommended that you open a console to the standby management node prior to making any ethernet interface changes. Also, keep the console open, to observe any errors while issuing commands in the remainder of this section. 

  * Update the database configuration to use the new ip address and new hostname. For DB2, use the following command: 
    
    re-login as xcatdb

~~~~ 
    db2gcf -u -p 0 -i xcatdb
~~~~     

This command will update the DB2 database configuration file "_/var/lib/db2/sqllib/db2nodes.cfg_" and start DB2. Note the path /var/lib/db2 is the default and may have been changed by setting the site table databaseloc attribute. 

For Postgres, update the line "host all all x.x.x.x/32 md5" in file /var/lib/pgsql/postgresql.conf and update the line "listen_addresses = 'x.x.x.x'" in file /var/lib/pgsql/pg_hba.conf. 

  * Start xcatd on the standby management node. If you get error "SQL1117N A connection to or activation of database "XCATDB" cannot be made because of ROLL-FORWARD PENDING. SQLSTATE=57019", use the following steps to workaround: 
    * Roll forward DB2 database, using: 

~~~~     
    db2 ROLLFORWARD DB XCATDB TO END OF LOG
    db2 ROLLFORWARD DB XCATDB COMPLETE
~~~~     

  
Verify xcatdb is usable, via db2 

~~~~     
    db2 CONNECT TO XCATDB USER XCATDB USING cluster
    db2 LIST TABLES
~~~~     

#### *Setup the network services and conserver:

   * DNS: run makedns. Verify dns services working for node resolution. 
    * DHCP(Linux only): run makedhcp. Verify dhcp operational for hardware management. 
    * conserver: makeconservercf 
    * Verify that bootp is operational for booting the nodes. 

#### Setup os deployment environment

[HAMN_OS_Image](HAMN_OS_Image) 

## Failback

When the previous primary management node is back up and running, you may want to failback to the primary management node. Since the xCAT database and related files were not kept up to date on the previous primary management node while it was down, failing back to the the previous primary management node is not an easy action. You must go through all the steps described in this documentation to setup the previous standby management node as the new primary management node and setup the previous primary management node as the new standby management node, and then do a failover from the new primary management node to the new standby management node. 

  


## References

  * Redbook "High Availability and Disaster Recovery Options for DB2 on Linux UNIX and Windows" http://www.redbooks.ibm.com/abstracts/sg247363.html 
  * DB2 Information Center[http://www.redbooks.ibm.com/redbooks/.../sg247352.pdf](http://www.redbooks.ibm.com/redbooks/pdfs/sg247352.pdf)http://publib.boulder.ibm.com/infocenter/db2luw/v9r5/index.jsp?topic=/com.ibm.db2.luw.admin.ha.doc/doc/c0011748.html 
  * [Setting_Up_DB2_as_the_xCAT_DB]
  * http://www.postgresql.org/docs/8.4/interactive/warm-standby.html 
  * http://wiki.postgresql.org/wiki/Replication,_Clustering,_and_Connection_Pooling 
