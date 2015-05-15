<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Changing the Management Node Hostname/ip/ipalias address](#changing-the-management-node-hostnameipipalias-address)
  - [Backup your xCAT data](#backup-your-xcat-data)
  - [Stop xCAT](#stop-xcat)
  - [Stop the database](#stop-the-database)
  - [Change the Management Host name](#change-the-management-host-name)
- [Changing the Management Node Cluster facing IP address](#changing-the-management-node-cluster-facing-ip-address)
  - [Update Database  files](#update-database--files)
    - [SQLite](#sqlite)
    - [Postgresql](#postgresql)
    - [MySQL](#mysql)
    - [DB2](#db2)
  - [Start the  database](#start-the--database)
  - [Start xCAT](#start-xcat)
  - [Change  the xCAT database](#change--the-xcat-database)
    - [Change the site table master attribute](#change-the-site-table-master-attribute)
    - [Change all occurrences to the new cluster facing ip address](#change-all-occurrences-to-the-new-cluster-facing-ip-address)
    - [Change your networks table](#change-your-networks-table)
  - [Change the Management Node defined in the database](#change-the-management-node-defined-in-the-database)
  - [Generate SSL credentials](#generate-ssl-credentials)
- [External DNS Server Changed](#external-dns-server-changed)
- [Domain Name Changed](#domain-name-changed)
  - [Change xCAT database](#change-xcat-database)
  - [makedns](#makedns)
  - [makedhcp](#makedhcp)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview
This document is intended to describe the steps that must be taken, if you find you need to change your Linux Management Node's  hostname and/or  IP address after the cluster is installed with xCAT and configured.  It will only cover the changes needed for the xCAT tool and not try to cover any other tools you may be using that could be affect by this change.

## Changing the Management Node Hostname/ip/ipalias address

If you need to change the Management Node's Hostname/ip address or the ipalias address,  the following step should be take.

### Backup your xCAT data
It is good to first backup all your xCAT data, for reference and recovery if necessary.
Clean up the database by running the following:

~~~~
 tabprune -a auditlog
 tabprune -a eventlog
~~~~

Now take a snapshot of the Management Node. This will also create a database backup.  You can use this data fro reference if needed after the conversion.

 xcatsnap -d <path to backup directory>

### Stop xCAT
You need to stop the xcat daemon and any other applications that are using the xCAT database on the Management Node and the Service Nodes.  To determine your database, run

~~~~
 lsxcatd -a
~~~~

To stop xCAT:

~~~~

 service xcatd stop

~~~~

### Stop the database
For all databases except SQlite, you should stop the database.
For example  run:

~~~~
 service postgresql stop
 service mysqld stop
~~~~

For DB2:

~~~~
 su - xcatdb
 db2stop
~~~~

### Change the Management Host name
To change the hostname on the Management Node:

 hostname <newMNname>
 Edit /etc/hosts and change the MN hostname/ip address
 Edit /etc/sysconfig/network  and change the HOSTNAME attribute

## Changing the Management Node Cluster facing IP address

If you change the Management Node Cluster-facing IP address, then additional work must be done.  The cluster facing ip address is the one assigned to the site table master attribute.

~~~~
 lsdef -t site -l | grep master
~~~~


### Update Database  files
You  need to update the new MN hostname or ip address in several database configuration files.

#### SQLite
Nothing to do.

#### Postgresql

Do the following on the Management Node and on Service Nodes:

~~~~
 vi /etc/xcat/cfgloc
 Pg:dbname=xcatdb;host=<oldMNip>|xcatadm|xcat20
 becomes
 Pg:dbname=xcatdb;host=<newMNip>|xcatadm|xcat20
~~~~

For Postgresql, you also will have to edit the config file for the database on the Management Node.

~~~~
 vi /var/lib/pgsql/data/pg_hba.conf
 # IPv4 local connections:
 host    all          all        <oldMNip>/32      md5
 becomes
 host    all          all        <newMNip>/32      md5
~~~~

#### MySQL
For MySQL you will have to do the following on the Management Node and the Service Nodes:

~~~~
 vi /etc/xcat/cfgloc
 mysql:dbname=xcatdb;host=<oldMNip>|xcatadmin|xcat20
 becomes
 mysql:dbname=xcatdb;host=<newMNip>|xcatadmin|xcat20
~~~~

The MySQL server will pick up the new hostname, when started. The mysql pid is based on the hostname.

#### DB2
For DB2 you will need to follow this process:

~~~~
[Appendix C: Changing the hostname/ip address of the DB2 Server](Setting_Up_DB2_as_the_xCAT_DB/#appendix-c-changing-the-hostnameip-address-of-the-db2-server-ems).

~~~~

The process above does the following is as follows:
*On the Management Node changes the hostname in the DB2 Database Server
*Logon to each Service Node (DB2 Client) and change the location of the DB2 Server.

### Start the  database

~~~~
 service postgresql start
 service mysqld start
~~~~

For DB2:

~~~~
 su - xcatdb
 db2start
~~~~

### Start xCAT
Run the following to start xCAT.

~~~~
 service xcatd start

~~~~

Verify  your new database setup

~~~~
 lsxcatd -a
 tabdump site

~~~~


### Change  the xCAT database


#### Change the site table master attribute

~~~~
  chdef -t site master=<new cluster facing ip address>

~~~~

#### Change all occurrences to the new cluster facing ip address

You are going to need to change all occurrences  of the old ip address in the xCAT database. One check you can run, is to see what nodes have it defined. For example, if the old address was "10.6.0.1", then run

~~~~
 lsdef -t node -l | grep "10.6.0.1"
    conserver=10.6.0.1
    conserver=10.6.0.1
    conserver=10.6.0.1
    conserver=10.6.0.1
    nfsserver=10.6.0.1
    servicenode=10.6.0.1
    xcatmaster=10.6.0.1
    kcmdline=quiet repo=http://10.6.0.1/install/rhels6/ppc64/ ks=http://10.6.0.1/install/autoinst
    /slessn ksdevice=d6:92:39:bf:71:05
    nfsserver=10.6.0.1
    servicenode=10.6.0.1
    tftpserver=10.6.0.1
    xcatmaster=10.6.0.1
    servicenode=10.6.0.1
    xcatmaster=10.6.0.1

~~~~

You can see the old address shows  up in several attributes, for example conserver.  To find out which nodes have that invalid address, run

~~~~
 lsdef -t node -w conserver="10.6.0.1"
 cn1  (node)
 cn2  (node)
 cn3  (node)
 cn4  (node)


~~~~

So to change the conserver address for cn1,cn2,cn3,cn4 run the following:

~~~~
 chdef -t node cn1-cn4 conserver=<newipaddress>

~~~~

Do the same process for the other attributes you find set incorrectly in the database.


~~~~
You can check that you have successfully changed all occurrences by running:
 dumpxCATdb -P <new database backup path>
 cd <new database backup path>
 fgrep "10.6.0.1" *.csv

~~~~

If any of the table.csv files still have the old address, then you could

~~~~
 vi <table.csv>
 change to lines to the new address
 exit
 tabrestore <table.csv>

~~~~


#### Change your networks table
Inspect your networks table to see if the network definitions are still correct.  If not
edit accordingly.

~~~~
 lsdef -t network -l

~~~~

### Change the Management Node defined in the database

If the Management Node is defined in the xCAT database ( supported in xCAT 2.8 or later) then do the following; otherwise skip to [Changing_the_Management_Node_Hostname_and/or_IP#Generate_SSL_credentials](Changing_the_Management_Node_Hostname_and_or_IP/#generate-ssl-credentials).



You can determine if the Management node is defined in the database, assuming it was done correctly using xcatconfig -m,  by running:

~~~~
 lsdef __mgmtnode

~~~~

If it exists, then use the return name and do the following:

*Remove the MN from DNS configuration

~~~~
 makedns -d <oldMNname>

~~~~

*Remove the MN from the DHCP configuration

~~~~
 makedhcp -d <oldMNname>

~~~~

*Remove the MN from the conserver configuration

~~~~
 makeconservercf -d <oldMNname>*

~~~~

*Change the MN name in the xCAT database

~~~~
  chdef -t node -o <oldMNname> -n <newMNname>

~~~~

*Add the MN to DNS

~~~~
 makedns -n

~~~~

*Add the MN to dhcp

~~~~
 makedhcp -a

~~~~

*Add the MN to conserver

~~~~
 makeconservercf

~~~~

### Generate SSL credentials
Generating the SSL credentials to match the new hostname is optional.  The credentials  generated, when xCAT was installed with the previous MN hostname/ip will work.

If you do not generate new credentials, skip this section.

If you decide generate new credentials, then you will use the following command.

~~~~
 xcatconfig -c

~~~~

If you generate new credentials, you will have to do the following:

*Update the policy table  with new MN name

~~~~
Change
 "1.4","oldMNname",,,,,,"trusted",,

to

 "1.4","newMNname",,,,,,"trusted",,


~~~~

*Distribute the new SSL  credentials to the service nodes and setup up conserver.


~~~~
 updatenode <servicenodes> -k  will distribute the SSL keys to the SN's
 makeconservercf

~~~~

* Generate new credentials for any non-root userids, that we setup before using this process:
[Granting_Users_xCAT_privileges]

##External DNS Server Changed
If the address of the External DNS server changes.

* Update /etc/resolv.conf
Update the nameserver entries in /etc/resolv.conf

* Update site.nameservers in DB
Check the site table nameservers  attribute.

~~~~
 lsdef -t site -o clustersite | grep nameservers

~~~~

If the address is now changed, then update:

~~~~
 chdef -t site -o clustersite nameservers="newipaddress1,newipaddress2"

~~~~


* Update site.forwarders in DB
Check the site table forwarders attrirbute.

~~~~
 lsdef -t site -o clustersite | grep forwarders

~~~~

If the address is now changed, then update:

~~~~
 chdef -t site -o clustersite forwarders="newipaddress1,newipaddress2"

~~~~

* Rerun makedns

~~~~
 makedns -n

~~~~

## Domain Name Changed

If the external domain name changes for the Management Node, then edit /etc/hosts and change the entries.

~~~~
 vi /etc/hosts

~~~~

If the external domain name changed,  then you may need to change the /etc/resolv.conf, and site table forwarders attribute.

~~~~
 lsdef -t site -o clustersite -i forwarders
 chdef -t site -o clustersite forwarders <new list>

~~~~


If the cluster domain name changes then you will edit /etc/hosts and also need change the domain name in the xCAT database site table.


~~~~
 chdef -t site -o clustersite domain=<newdomainname>

~~~~

As of xCAT 2.8,  we support multiple domains in the cluster.  If the cluster domain name(s) change, and using the multiple domain support, you may also need to update your networks table definition.

~~~~
 lsdef -t network -l
 chdef -t network -o <netname> ddnsdomain=<newdomainname1,newdomainname2>

~~~~


###Change xCAT database
If the cluster domain changed, depending on what is configured in your xCAT database, you will have to change all occurrences of the old domain name to the new domain name in all tables.

If you did not use fully-qualified  node names in the xCAT database, then the tables to check are the following:

~~~~
 site
 networks

~~~~

If you did use fully-qualified node names , then you need to follow this procedure to change the node name in the database:

[Changing_the_Service_and_compute_nodes_Hostname_and_or_IP]

### makedns
After changing the domain name you should rerun makedns.

  makedns -n


###makedhcp

After changing the domain name, if you have not already done so,  you should run makedhcp:


~~~~
 makedhcp -n
 makedhcp -a


~~~~

Additional Steps?

This depends on what else you have installed that may be affected by the change.


