<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Configuration Requirements](#configuration-requirements)
- [Setup xCAT on the Primary Management Node](#setup-xcat-on-the-primary-management-node)
- [Setup xCAT on the Standby Management Node](#setup-xcat-on-the-standby-management-node)
- [Additional configuration steps for HAMN](#additional-configuration-steps-for-hamn)
- [Setup PostgreSQL replication between the two management nodes](#setup-postgresql-replication-between-the-two-management-nodes)
  - [On primary management node](#on-primary-management-node)
  - [On the standby management node](#on-the-standby-management-node)
  - [Verify the database replication configuration](#verify-the-database-replication-configuration)
- [File syncoronization](#file-syncoronization)
  - [**SSL Credentials and SSH Keys**](#ssl-credentials-and-ssh-keys)
  - [**Network Services Configuration Files**](#network-services-configuration-files)
  - [**Additional Customization Files and Production files**](#additional-customization-files-and-production-files)
- [**Cluster Maintenance Considerations**](#cluster-maintenance-considerations)
- [Failover](#failover)
  - [Take down the current primary management node](#take-down-the-current-primary-management-node)
  - [Bring up the new primary management node](#bring-up-the-new-primary-management-node)
  - [After the failed management node is back up and running](#after-the-failed-management-node-is-back-up-and-running)
- [Setup the Cluster](#setup-the-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note: The procedure in this documentation is not thoroughly tested, use this doc at your own risk.**

** This documentation only works for Linux configuration working with PostgreSQL. For DB2 configuratin with shared disks, use [Setup_HA_Mgmt_Node_With_Shared_Disks](Setup_HA_Mgmt_Node_With_Shared_Disks) instead. **


## Overview

This documentation illustrates how to setup a second management node, or standby management node, in your cluster to provide high availability management capability when there is no shared disks configured between the two management nodes. If DB2 is used in your cluster, this documentation only applies to xCAT 2.5 or newer releases.

When the primary xCAT management node fails, the administrator can easily have the standby management node take over role of the management node, and thus avoid long periods of time during which your cluster does not have active cluster management function available.

The xCAT high availability management node(HAMN) feature is not designed for automatic setup or automatic failover, this documentation will describe how to synchronize various data between the primary management node and standby management node, and describe how to perform some manual steps to have the standby management node takeover the management node role when failures occur on the primary management node. High availability applications such as pacemaker or IBM Tivoli System Automation(TSA) can be used to achieve automatic failover, configuring these high availability applications is beyond the scope of this documentation.

The virtual ip address will be moved from the primary management node to the standby management node during the failover process, it means that any network connections from the compute nodes to the virtual ip address will temporarily disconnected during the failover process. If the network connectivity is required for compute node run-time operations, you should consider some other way to provide high availability for the network services unless the compute nodes can also be taken down during the failover process. This also implies:

1\. This HAMN approach is primarily intended for clusters in which the management node manages diskful nodes or linux stateless nodes. This also includes hierarchical clusters in which the management node only directly manages the diskful or linux stateless service nodes, and the compute nodes managed by the service nodes can be of any type.

2\. This documentation is not primarily intended for clusters in which the nodes depend on the management node being up to run its operating system over NFS. But if the nodes use only readonly nfs mounts from the MN management node, then you can use this doc as long as you realize that your nodes will go down while you are failing over to the standby management node.

Setting up HAMN can be done at any time during the life of the cluster, in this documentation we assume the HAMN setup is done from the very beginning of the xCAT cluster setup, there will be some minor differences if the HAMN setup is done from the middle of the xCAT cluster setup.

**Note: If you are using twin-tailed shared disks between the primary management node and standby management node, the steps below are quite different, please see [Setup_HA_Mgmt_Node_With_Shared_Disks].**

## Configuration Requirements

xCAT HAMN requires that the operating system version, xCAT version and database version all be identical on the two management nodes.

The hardware type/model are not required to be the same on the two management nodes, but it is recommended to have similar hardware capability on the two management nodes to support the same operating system and have similar management capability.

Since the management node needs to provide IP services through broadcast such as DHCP to the compute nodes, the primary management node and standby management node should be in the same subnet to ensure the network services will work correctly after failover.

The HAMN setup can be performed at any time during the life of the cluster. This documentation assumes the HAMN setup is performed from the very beginning of the cluster setup.

Twin-tailed disks are not required for this support since different methods are used to ensure the data synchronization between the primary management node and standby management node. However, if you have twin-tailed disks in your cluster, then the data synchronization will be easier. You can put the related directories and files listed in section Setup Database Replication and section Files Synchronization onto the twin-tailed disks, re-mount the twin-tailed disks to the standby management node during the failover, and the corresponding steps to keep the data synchronized can be skipped.

The examples in this documentation are based on the following cluster environment:

NAS: hpcnfs(10.1.0.241) Running AIX 5.3 and have DS4800 storage systems connected. /hamninstall directory is exported and can be mounted as the /install on the two management nodes. The entry in /etc/exports looks like:

~~~~
   /hamninstall -vers=3:4,sec=sys:krb5p:krb5i:krb5:dh,rw,root=*
~~~~

Virtual IP address: 10.1.0.223

Primary Management Node: x3550m4n01(10.1.0.221) running RHEL 6.2 and PostgreSQL 9.1.4

Standby Management Node: x3550m4n02(10.1.0.222) running RHEL 6.2 and PostgreSQL 9.1.4

You need to substitute the hostnames and ip address with your own values when setting up your HAMN environment.

## Setup xCAT on the Primary Management Node

1\. Mount the /install directory from NAS, verify the /install directory is writable and owner is root:root

**Note: If the owner of the mounted /install directory is nobody:nobody, xCAT installation will fail.**

~~~~
    [root@barn02 ~]# mount -o nfsvers=3 10.1.0.241:/hamninstall /install

    [root@barn02 ~]# mount

    ...

    10.1.0.241:/hamninstall on /install type nfs (rw,nfsvers=3,addr=10.1.0.241)

    [root@barn02 ~]# ls -l /

    ...

    drwxr-xr-x    4 root root   256 Jun 11  2012 install

    [root@barn02 ~]# cd /install

    [root@barn02 ~]# touch testfile

    [root@barn02 ~]# rm testfile

~~~~


2\. Set up a "Virtual IP address". The xcatd daemon should be addressable with the same Virtual IP address, regardless of which management node it runs on. The same Virtual IP address will be configured as an alias IP address on the management node (primary and standby) that the xcatd runs on. The Virtual IP address can be any unused ip address that all the compute nodes and service nodes could reach. Here is an example on how to configure Virtual IP on Linux:

~~~~
    ifconfig eth1:0 10.1.0.223 netmask 255.255.255.0
~~~~


Since ifconfig will not make the ip address configuration be persistent through reboots, so the Virtual IP address needs to be re-configured right after the management node is rebooted. This non-persistent Virtual IP address is designed to avoid ip address conflict when the crashed previous primary management node is recovered with the Virtual IP address configured.

3\. Add the alias ip address into the /etc/resolv.conf as the nameserver. Change the hostname resolution order to be using /etc/hosts before using name server, change to "hosts: files dns" in /etc/nsswitch.conf.

4\. Install xCAT. The procedure described in [Setting_Up_a_Linux_xCAT_Mgmt_Node] should be used for the xCAT setup on the primary management node.

5\. Change the site table master and nameservers and network tftpserver attribute is the Virtual ip

~~~~
    lsdef site
~~~~


If not correct:

~~~~
    chdef -t site master=10.1.0.223
    chdef -t site nameservers=10.1.0.223
    chdef -t network 10_1_0_0-255_255_255_0 tftpserver=10.1.0.223
~~~~


6\. Install PostgreSQL. PostgreSQL will be used as the xCAT database system, please refer to the doc [Setting_Up_PostgreSQL_as_the_xCAT_DB](Setting_Up_PostgreSQL_as_the_xCAT_DB).

Verify xcat is running on PostgreSQL by running:

~~~~
    lsxcatd -a
~~~~


## Setup xCAT on the Standby Management Node

1\. Mount the /install directory from NAS, verify the /install directory is writable and owner is root:root


2\. Add the alias ip address into the /etc/resolv.conf as the nameserver. Change the hostname resolution order to be using /etc/hosts before using name server, change to "hosts: files dns" in /etc/nsswitch.conf.

3\. Install xCAT. The procedure described in [Setting_Up_a_Linux_xCAT_Mgmt_Node](Setting_Up_a_Linux_xCAT_Mgmt_Node) should be used for the xCAT setup on the primary management node.

4\. Install PostgreSQL. PostgreSQL will be used as the xCAT database system, please refer to the doc [Setting_Up_PostgreSQL_as_the_xCAT_DB](Setting_Up_PostgreSQL_as_the_xCAT_DB).

Verify xcat is running on PostgreSQL by running:

~~~~
    lsxcatd -a
~~~~


## Additional configuration steps for HAMN

1\. Setup hostname resolution between the primary management node and standby management node. Make sure the primary management node can resolve the hostname of the standby management node, and vice versa.

2\. Setup ssh authentication between the primary management node and standby management node. It should be setup as "passwordless ssh authentication" and it should work in both directions. The summary of this procedure is:

cat keys from /.ssh/id_rsa.pub on the primary management node and add them to /.ssh/authorized_keys on the standby management node. Remove the standby management node entry from /.ssh/known_hosts on the primary management node prior to issuing ssh to the standby management node.

cat keys from /.ssh/id_rsa.pub on the standby management node and add them to /.ssh/authorized_keys on the primary management node. Remove the primary management node entry from /.ssh/known_hosts on the standby management node prior to issuing ssh to the primary management node.

3\. Make sure the time on the primary management node and standby management node is synchronized. ntp is good choice of maintaining time synchronization.

## Setup PostgreSQL replication between the two management nodes

Before setting up PostgreSQL replication, stop xcatd and postgresql daemon on both management nodes.

~~~~
    service xcatd stop
    service postgresql-9.1 stop
~~~~


Note: the postgresql daemon name might be slightly different between the postgresql versions.

### On primary management node

1\. Set up connections and authentication so that the standby server can successfully connect to the replication database on the primary server. Grant read/write and replication permission for the primary management node and standby management node through adding the following lines into **/var/lib/pgsql/9.1/data/pg_hba.conf**, replace the ip addresses with the ones in your configuration.

~~~~
    sudo -u postgres vi /var/lib/pgsql/9.1/data/pg_hba.conf


    host    all          all        10.1.0.221/32      md5
    host    all          all        10.1.0.222/32      md5
    host    all          all        10.1.0.223/32      md5
    host  replication  postgres  10.1.0.221/32  trust
    host  replication  postgres  10.1.0.222/32  trust
    host  replication  postgres  10.1.0.223/32  trust
~~~~


2\. Set up the streaming replication related parameters. Adding the following lines into **/var/lib/pgsql/9.1/data/postgresql.conf**

~~~~
    sudo -u postgres vi /var/lib/pgsql/9.1/data/postgresql.conf


    listen_addresses = '*'
    wal_level = hot_standby
    max_wal_senders = 5
    wal_keep_segments = 32
    hot_standby = on
~~~~


3\. Create baseline of master database, replace the ip addresses with the ones in your configuration.

~~~~
    service postgresql-9.1 start
    service xcatd start
    sudo -u postgres psql -c "SELECT pg_start_backup('label', true)"
    rsync -a -v -e ssh /var/lib/pgsql/9.1/data/ 10.1.0.222:/var/lib/pgsql/9.1/data/ --exclude postmaster.pid
    sudo -u postgres psql -c "SELECT pg_stop_backup()"
~~~~


### On the standby management node

1\. Create the recovery command file **/var/lib/pgsql/9.1/data/recovery.conf**, the recovery command file indicates this is the standby database server, the following parameters are required; replace the ip addresses with the ones in your configuration.

~~~~
    sudo -u postgres vi /var/lib/pgsql/9.1/data/recovery.conf

    standby_mode          = 'on'
    primary_conninfo      = 'host=10.1.0.221 port=5432 user=postgres'
    trigger_file = '/tmp/stoppostgresqlreplication'
~~~~


2\. Start postgresql daemon and xcatd

~~~~
    service postgresql-9.1 start
    service xcatd start
~~~~


### Verify the database replication configuration

Before moving forward, verify if the database replication is working correctly.

1\. Create a new test node on the primary management node

~~~~
    mkdef -t node -o testnode groups=all mgt=ipmi cons=ipmi
~~~~


2\. Verify the new test node is also in the nodelist on the standby management node

~~~~
    lsdef -t node -o testnode
~~~~


3\. Remove the test node on the primary management node

~~~~
    rmdef -t node -o testnode
~~~~


4\. Verify the test node is not in the nodelist on the standby management node

~~~~
    lsdef -t node -o testnode
~~~~


** Note: since the database on the standby management node is a readonly copy, so do not try to change the database on the standby management node.**

If the PostgreSQL replication is not working correctly, refer to the PostgreSQL documentaiton at http://www.postgresql.org/docs/ for debugging.

## File syncoronization

To make the standby management node be ready for an easy take over, there are a lot files that should be kept synchronized between the primary management node and standby management node. For the files that are changed constantly, you should consider putting the files on the NAS; but for the files that are not changed frequently or unlikely to be changed at all, you can simply copy the the files from the primary management node to the standby management node or use crontab and rsync to keep the files synchronized between primary management node and standby management node. Here are some files we recommend to keep synchronization between the primary management node and standby management node:

### **SSL Credentials and SSH Keys**

To setup the ssh authentication between the primary management node, standby management node, service nodes and compute nodes, the ssh keys should be kept synchronized between the primary management node and standby management node.

The SSL credentials reside in the directories /etc/xcat/ca, /etc/xcat/cert and $HOME/.xcat/. The ssh keys are in the directory /etc/xcat/hostkeys. In addition we have the ssh keys under root's home directory in the ~/.ssh and that must be kept in sync. We only sync the key files and not the authorized_key file which has been setup so the Primary and Standby management node can ssh without a password prompt.

These keys will seldom change, so you can just do it manually when they do, or setup the below cron entry.

Here is an example of the crontab entries for synchronizing the SSL credentials and SSH keys:




~~~~
     0 1 * * * /usr/bin/rsync -Lprgotz /etc/xcat/ca  10.1.0.222:/etc/xcat/ca
     0 1 * * * /usr/bin/rsync -Lprgotz /etc/xcat/cert  10.1.0.222:/etc/xcat/cert
     0 1 * * * /usr/bin/rsync -Lprgotz /etc/xcat/hostkeys 10.1.0.222:/etc/xcat/hostkeys
     0 1 * * * /usr/bin/rsync -Lprgotz $HOME/.ssh/id*  10.1.0.222:$HOME/.ssh/
~~~~



Now go to the standby manaagement node and add the primary management node's id_rsa.pub to the standby management node's authorized_keys file.

### **Network Services Configuration Files**

A lot of network services are configured on the management node, such as DNS, DHCP and HTTP. The network services are mainly controlled by configuration files. However, some of the network services configuration files contain the local hostname/ipaddresses related information, so simply copying these network services configuration files to the standby management node may not work. Generating these network services configuration files is very easy and quick by running xCAT commands such as makedhcp, makedns or nimnodeset, as long as the xCAT database contains the correct information.

While it is easier to configure the network services on the standby management node by running xCAT commands when failing over to the standby management node, an exception is the /etc/hosts; the /etc/hosts may be modified on your primary management node as ongoing cluster maintenance occurs. Since the /etc/hosts is very important for xCAT commands, the /etc/hosts will be synchronized between the primary management node and standby management node. Here is an example of the crontab entries for synchronizing the /etc/hosts:




~~~~
    0 2 * * * /usr/bin/rsync -Lprogtz /etc/hosts 10.1.0.222:/etc/
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

  * If the IBM HPC software stack is configured in your environment, please refer to the xCAT wiki page [IBM_HPC_Stack_in_an_xCAT_Cluster](IBM_HPC_Stack_in_an_xCAT_Cluster) for additional steps required for HAMN setup.
  * The dhcpsd.cnf should be syncronized between the primary management node and standby management node only when the DHCP configuration on the two management nodes are exactly the same.




## **Cluster Maintenance Considerations**

The standby management node should be taken into account when doing any maintenance work in the xCAT cluster with HAMN setup.

  1. Software Maintenance - Any software updates on the primary management node should also be done on the standby management node.
  2. File Synchronization - Although we have setup crontab to synchronize the related files between the primary management node and standby management node, the crontab entries are only run in specific time slots. The synchronization delay may cause potential problems with HAMN, so it is recommended to manually synchronize the files mentioned in the section above whenever the files are modified.
  3. Reboot management nodes - If the primary management node needs to be rebooted, since the virtual ip address is not persistent through reboots, you need to configure the virtual ip address manually after reboot.

~~~~
     service xcatd stop
     service postgresql-9.1 stop
     ifconfig eth2:0 10.1.0.223 netmask 255.255.255.0
     service postgresql-9.1 start
     service xcatd start
~~~~


At this point, the HA MN Setup is complete, and customer workloads and system administration can continue on the primary management node until a failure occurs. The xcatdb and files on the standby management node will continue to be synchronized until such a failure occurs.

## Failover

There are two kinds of failover, planned failover and unplanned failover. The planned failover can be useful for updating the management nodes or any scheduled maintainance activities; the unplanned failover covers the unexpected hardware or software failures.

In a planned failover, you can do necessary cleanup work on the previous primary management node before failover to the previous standby management node. In a unplanned failover, the previous management node probably is not functioning at all, you can simply shutdown the system.

### Take down the current primary management node

**On the current primary management node:**

If the management node is still available and running the cluster, perform the following steps to shutdown.

**1\. Stop the xCAT and dhcp daemons.**

Note xCAT and dhcpd must be stopped on all Service Nodes also.

~~~~
    service xcatd stop
    service dhcpd stop
~~~~


**2\. Stop database**

~~~~
    service postgresql-9.1 off
~~~~


**3\. Unconfigure Virtual IP**

~~~~
    ifconfig eth2:0 0.0.0.0 0.0.0.0
~~~~


If the ifconfig command has been added to rc.local, remove it from rc.local.

### Bring up the new primary management node

**On the new primary management node:**

**1\. Configure Virtual IP**

~~~~
    ifconfig eth2:0 10.1.0.223 netmask 255.255.255.0
~~~~


You can put the ifconfig command into rc.local to make the Virtual IP be persistent after reboot.

**2\. Make the server be the primary database server**

~~~~
    touch /tmp/stoppostgresqlreplication
~~~~


Note: after the server becomes the primary database server, the file /var/lib/pgsql/9.1/data/recovery.conf will be renamed to /var/lib/pgsql/9.1/data/recovery.done. At this time, remove the file /tmp/stoppostgresqlreplication and /var/lib/pgsql/9.1/data/recovery.done.

**3\. Restart the daemons on the management node. **

~~~~
    service xcatd stop
    service postgresql-9.1 stop
    service postgresql-9.1 start
    service xcatd start
~~~~


**4\. Setup network services and conserver**

DNS: run makedns. Verify dns services working for node resolution. Add "nameserver=Virtual ip" to /etc/resolv.conf

For more information on setting up name resolution in an xCAT Cluster: [Cluster_Name_Resolution]

DHCP: if the dhcpd.leases(Linux) is not syncronized between the primary management node and standby management node, run makedhcp -a to setup the DHCP leases. Verify dhcp operational for hardware management.

conserver: run makeconservercf. This will recreate the /etc/conserver.cf config files adding any newly defined lpars.

After finishing these steps, the standby management node is ready for managing the cluster, and you can run any xCAT commands to manage the cluster. For example, if the diskless nodes need to be rebooted, you can run

~~~~
    rpower <noderange> reset
~~~~


to initialize the network boot.

### After the failed management node is back up and running

After the problem with the failed management node is fixed, you can boot up the management node to act as the standby management node.

1\. Stop xcatd and postgresql daemons

~~~~
    service xcatd stop
    service postgresql-9.1 stop
~~~~


2\. Create the recovery command file **/var/lib/pgsql/9.1/data/recovery.conf**, the recovery command file indicates this is the standby database server, the following parameters are required; replace the ip addresses with the ones in your configuration.

~~~~
    sudo -u postgres vi /var/lib/pgsql/9.1/data/recovery.conf

    standby_mode          = 'on'
    primary_conninfo      = 'host=10.1.0.222 port=5432 user=postgres'
    trigger_file = '/tmp/stoppostgresqlreplication'
~~~~


3\. On the current primary management node, copy master database to the new standby management node, replace the ip addresses with the ones in your configuration.

~~~~
    service postgresql-9.1 start
    service xcatd start
    sudo -u postgres psql -c "SELECT pg_start_backup('label', true)"
    rsync -a -v -e ssh /var/lib/pgsql/9.1/data/ 10.1.0.221:/var/lib/pgsql/9.1/data/ --exclude postmaster.pid
    sudo -u postgres psql -c "SELECT pg_stop_backup()"
~~~~


4\. Start xcatd and postgresql daemons

~~~~
    service postgresql-9.1 start
    service xcatd start
~~~~


## Setup the Cluster

At this point you have setup your primary and standby management node for HA. You can now continue to setup your cluster. Now setup your Hierarchical cluster using the following documentation, depending on your Hardware,OS and type of install you want to do on the Nodes. The below will cover diskless or statelite nodes. Other docs are available for full disk installs.

  * [XCAT_System_p_Hardware_Management](XCAT_System_p_Hardware_Management)
  * [Setting_Up_a_Linux_Hierarchical_Cluster](Setting_Up_a_Linux_Hierarchical_Cluster)
  * [XCAT_pLinux_Clusters](XCAT_pLinux_Clusters)
  * [XCAT_Linux_Statelite](XCAT_Linux_Statelite)

Note: since the /install directory on the primary and standby management nodes is mounted from the NAS through NFS, it means that the /install directory could not be exported through NFS, if you are setting up statelite configuration, you will need to change the nodes' nfsserver attributes to point to the NAS.

For all the xCAT docs: [XCAT_Documentation](XCAT_Documentation)

