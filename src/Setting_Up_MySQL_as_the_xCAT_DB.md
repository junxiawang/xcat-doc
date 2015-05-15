<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Switch to MySQL or MariaDB on the Management Node](#switch-to-mysql-or-mariadb-on-the-management-node)
  - [Install MySQL or MariaDB](#install-mysql-or-mariadb)
  - [Configure and migrate xCAT to MySQL or MariaDB using mysqlsetup script](#configure-and-migrate-xcat-to-mysql-or-mariadb-using-mysqlsetup-script)
  - [**Configure MySQL manually**](#configure-mysql-manually)
    - [**Granting or Revoking access to the MySQL database to Service Node Clients**](#granting-or-revoking-access-to-the-mysql-database-to-service-node-clients)
    - [Migrate xCAT data to MySQL](#migrate-xcat-data-to-mysql)
  - [**Add ODBC support**](#add-odbc-support)
    - [**Upgrade mysql-connector for LoadLeveler on SLES11 SP3**](#upgrade-mysql-connector-for-loadleveler-on-sles11-sp3)
    - [**Setup the ODBC on the Service Node**](#setup-the-odbc-on-the-service-node)
      - [Test the ODBC connection](#test-the-odbc-connection)
- [Connected!](#connected)
- [Tables in xcatdb](#tables-in-xcatdb)
- [**Removing MySQL xcatd database**](#removing-mysql-xcatd-database)
- [**Rerunning mysqlsetup -i **](#rerunning-mysqlsetup--i-)
- [**Migrate to AIX 7.1**](#migrate-to-aix-71)
- [**Migrate to new level MySQL**](#migrate-to-new-level-mysql)
- [**Diagnostics**](#diagnostics)
- [**Useful MySQL commands**](#useful-mysql-commands)
- [If you lose MySql root password](#if-you-lose-mysql-root-password)
- [Granting root super priviledge](#granting-root-super-priviledge)
- [**References**](#references)
- [Document Test Record](#document-test-record)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Switch to MySQL or MariaDB on the Management Node

MySQL is supported on xCAT 2.1 or later. MariaDB is supported in xCAT 2.8.5 or later on Redhat7 and  xCAT 2.9 or later for SLES12.  This document will talk about MySQL,  but setting up MariaDB is essentially the same.  One reason to migrate from the default SQLite database to MySQL with xCAT is for xCAT hierarchy using Service Nodes. MySQL provides the ability for remote access to the xCAT database on the Management node which is required by Service Nodes. Refer to the xCAT Service Node documentation for more information. Other programs or scenarios within your environment may also benefit from or require MySQL. This document contains steps to install MySQL, configure the server, create a database and populate it with your xCAT data. Before using this document, you should have a general understanding of MySQL. If necessary, review the installation and tutorial sections of the MySQL 5.1 Reference Manual located at:

http://dev.mysql.com/doc/refman/5.1/en/index.html


Although this should be a one time setup, the MySQL documentation should also be reviewed so that you can manage and maintain the MySQL environment.





### Install MySQL or MariaDB

Before you install verify you have enough free space. Increase if needed. On AIX, the /usr file system will be installed with MySQL, which is quite large. Check the size of the rpm ( currently &gt; 500meg). **During the install, you will need at least 1.25 GB free space in the /usr directory.**


On AIX and Linux: the xCAT database will be created in /var/lib/mysql. Make sure /var has free space to do this. An estimate is at least 1 mbyte free,** but leave room for growth as xCAT tables are added and expanded.


**On AIX: **The xCAT RPM called xcat-mysql is provided to help simplify the installation of MySQL on an AIX system. Download the xcat-mysql-2.*.gz. From this website:https://sourceforge.net/projects/xcat/files/

Unzip and untar it in the location of your choice. The xcat-mysql post processing will automatically unwrap MySQL in the /usr/local directory and will create a link for /usr/local/mysql. It will also update the PATH environment variable in the /etc/profile file.

~~~~
    gunzip xcat-mysql-2*.gz
    tar -xvf xcat-mysql-2*.tar
    ./instmysql
~~~~



Note: as of Oct 2010, the AIX deps package will automatically install the perl-DBD-MySQL , and unixODBC-* when installed on the Management or Service Nodes. You may find these already installed.




On Redhat: MySQL comes as part of the OS. Ensure that the following rpms are installed on your Management Node:

~~~~
    perl-DBD-MySQL*
    mysql-server-5.*
    mysql-5.*
    mysql-devel-5.*
    mysql-bench-5.*
    mysql-connector-odbc-*
    unixODBC*

~~~~



The best way to install RedHat5+, Fedora and Centos MySQL is using YUM. If you have YUM setup for your OS install on the MN the run the following:



    yum install mysql-server mysql mysql-bench mysql-devel mysql-connector-odbc

On RHEL7:MariaDB comes as part of the OS.  Ensure that the following rpms are installed on the MN.

~~~~
    mariadb-devel-5.*
    mariadb-libs-5.*
    mariadb-server-5.*
    mariadb-bench-5.*
    mariadb-5.*
    perl-DBD-MySQL*
    mysql-connector-odbc-*
    unixODBC*
~~~~

On SLES12:MariaDB comes as part of the OS.  Ensure that the following rpms are installed on the MN.

~~~~

mariadb-client-10.*
mariadb-10.*
mariadb-errormessages-10.*
libqt4-sql-mysql-*
libmysqlclient18-*
perl-DBD-mysql-*
unixODBC-2.3.1-4.95*

~~~~

**On SLES:** MySQL comes as part of the OS. Ensure that the following rpms are installed on your Management Node:



~~~~
    mysql-client-5*
    libmysqlclient_r15*
    libqt4-sql-mysql-4*
    libmysqlclient15-5*
    perl-DBD-mysql-4*
    mysql-5*
~~~~




**On Ubuntu/Debian:** Can install by "apt-get install mysql-server". Ensure that the following packages are installed:

~~~~
    mysql-server
    mysql-common
    libdbd-mysql-perl
    libmysqlclient18
    mysql-client-5*
    mysql-client-core-5*
    mysql-server-5*
    mysql-server-core-5*
~~~~

**From Ubuntu 14.04.1 LTS:** MariaDB comes as part of the OS.  Ensure that the following packages are installed on the MN:

~~~~
    libmariadbclient18
    mariadb-client
    mariadb-common
    mariadb-server
~~~~
 

### Configure and migrate xCAT to MySQL or MariaDB using mysqlsetup script

As of xCAT 2.3.1, you can use mysqlsetup** xCAT script to perform all the operations in the "Configure MySQL manually" and the "Migrate xCAT data to MySQL" sections of the doc. See the manpage for mysqlsetup. Run:

~~~~
    mysqlsetup -i
~~~~

As or xCAT 2.8.5,  you can use mysqlsetup to setup MariaDB on Redhat 7.  As of xCAT 2.9, you can use mysqlsetup to setup MariaDB on SLES12 and Ubuntu14.04.1 LTS. It will recognize if MySQL or MariaDB is installed. Run:

~~~~
    mysqlsetup -i
~~~~

After you setup MySQL on the Management node, you will need to update the database base to give access to your service nodes when they are defined. You use the **mysqlstup -u -f** command below.

Setup file1 with all the hostnames and/or ip addresses that you wish to access the database on the Management Node, one per line. Wildcards can be used.

~~~~
    mysqlsetup -u -f file1
~~~~


You can setup the hostname access list manually following this process.

[Setting_Up_MySQL_as_the_xCAT_DB#Granting or Revoking access to the MySQL database to Service Node Clients](Setting_Up_MySQL_as_the_xCAT_DB/#granting-or-revoking-access-to-the-mysql-database-to-service-node-clients)


### **Configure MySQL manually**

**Stop: Did you notice as of xCAT 2.3.1, you can use the mysqlsetup script provided by xCAT to automatically accomplish all the following manual steps. If you ran mysqlsetup -i, then you can skip to "Create the lists of hosts that will have permission to access the database." mysqlsetup adds the Management Server to the list, you will need to add any service nodes.**


This section takes you through setting up the the MySQL environment, starting the server and connecting to the interactive program to create server definitions and perform queries.


This example assumes:




  * Management Node: mn20
  * xCAT database name: xcatdb
  * Database user id used by xCAT for access: xcatadmin
  * Database password for xcatadmin: xcat201


Substitute your addresses and desired database administration, password and database name as appropriate.

**All of the following steps should be run logged into the Management Node as root. **




  * On AIX, create the mysql user and groups, that will be used to run mysql:

~~~~
    mkgroup mysql
    mkuser pgrp=mysql mysql
~~~~

  * Additionally on AIX, update the mysql file permissions:

~~~~
    cd /usr/local/mysql
    chown -R mysql .
    chgrp -R mysql .
~~~~

On Linux: The mysql user id and group already exists, and the permissions are already correct when MySQL is installed.

  * Using the mysql userid, execute the script that will create the MySQL data directory and initialize the grant tables.

On AIX:

~~~~
     /usr/local/mysql/scripts/mysql_install_db --user=mysql

~~~~

On Linux:

~~~~
    /usr/bin/mysql_install_db --user=mysql

~~~~






  * For large systems you may need to increase max_connections to the database in the my.cnf file. The default is 100. Add this line to the configuration file:

~~~~
     max_connections=300
~~~~

For additional system variables that can be set go to: http://dev.mysql.com/doc/refman/5.1/en/server-system-variables.html#sysvar_max_connections

  * On AIX, update the data directory ownership permission to mysql. All other mysql install directories should be owned by root.

~~~~
    cd /usr/local/mysql
    chown -R root .
    chown -R mysql data

~~~~

  * On AIX,Check ulimit settings.

~~~~
    ulimit -a
    time(seconds)
    unlimitedfile(blocks) 2097151
    data(kbytes) 131072
    stack(kbytes) 32768
    memory(kbytes) 32768
    coredump(blocks) 2097151
    nofiles(descriptors) 2000
    threads(per process) unlimited
~~~~


If not unlimited, change the ulimit setting on AIX to the following, for this session. coredump is optional.


~~~~

    ulimit -m unlimited
    ulimit -n 102400
    ulimit -d unlimited
    ulimit -f unlimited
    ulimit -s unlimited
    ulimit -t unlimited
~~~~

On AIX, Edit the /etc/security/limits file, to make these limits stay unlimited for root through reboot or the start of the MySQL server may fail.

~~~~
    root:
    fsize = -1
    core = -1
    cpu = -1
    data = -1
    rss = -1
    stack = -1
    nofiles = 102400
~~~~


Note you should not set nofiles to unlimited (-1). This may cause problems for some system applications.

  * **Start the MySQL server**(running as root must use the --user option).

On AIX:

~~~~
    /usr/local/mysql/bin/mysqld_safe --user=mysql &
~~~~

(may need to hit enter to get prompt back)

On Linux:

~~~~
    /usr/bin/mysqld_safe --user=mysql &
~~~~

or

~~~~
    service mysqld start (on sles service mysql start)
~~~~

or 

for Mariadb

if Redhat with Mariadb

~~~~

     service mariadb start
~~~~

if SLES with Mariadb

~~~~

     service mysql start
~~~~

**If you need to stop the MySQL server:**


Note the mysql root id must have been setup, see below.


On AIX:

~~~~
     /usr/local/mysql/bin/mysqladmin -u root -p shutdown
~~~~

On Linux

~~~~
    /usr/bin/mysqladmin -u root -p shutdown
~~~~

or

~~~~
    service mysqld stop for Redhat
    service mysql stop for SLES
~~~~

or for Mariadb

Mariadb on Redhat

~~~~

    service mariadb stop
~~~~

Mariadb on SLES

~~~~
     service mysql stop
~~~~

If command fails,

On AIX, check the /usr/local/mysql/data/mn20.err file.

On Linux, check /var/log/mysqld.log.

  * Setup MySQL to automatically start after a reboot of the Management Node.

On AIX, add the following line before the xcatd line (so that it starts before it) in the /etc/inittab:

~~~~
    mysql:2:once:/usr/local/mysql/bin/mysqld_safe --user=mysql &
~~~~

    On Linux:

~~~~
     chkconfig mysqld on ( on sles chkconfig mysql on)
~~~~


  * Set the MySQL root password in the MySQL database

On AIX:

~~~~

    /usr/local/mysql/bin/mysqladmin -u root password 'new-password'


On Linux:

    /usr/bin/mysqladmin -u root password 'new-password'
~~~~


  * Log into the MySQL interactive program.

On AIX:

~~~~

    /usr/local/mysql/bin/mysql -u root -p
~~~~


On Linux:

~~~~
     /usr/bin/mysql -u root -p
~~~~


  * Create the xcatdb database which will be populated with xCAT data later in this document.

~~~~
    mysql > CREATE DATABASE xcatdb;
~~~~


  * Create the xcatadmin id and password

~~~~

     mysql > CREATE USER xcatadmin IDENTIFIED BY 'xcat201';
~~~~


  * **Create the lists of hosts that will have permission to access the database.**

First add your Management Node (MN), where the database is running. A good name to use for your MN is the name in the master attribute of the site table. Names must be resolvable hostnames or ip addresses. So in our example, if you run host mn20, make sure it returns mn20 is xxx.xx.xx.xx. If it returns a long host name such as mn20.cluster.net is xxx.xx.xx.xx, then put both the long and short hostname in the database. We assume below the short hostname is resolved to the short hostname.

~~~~

    mysql > GRANT ALL on xcatdb.* TO xcatadmin@mn20 IDENTIFIED BY 'xcat201';
~~~~

#### **Granting or Revoking access to the MySQL database to Service Node Clients**

If you have not already done so,

  * Log into the MySQL interactive program.

On AIX:

~~~~
    /usr/local/mysql/bin/mysql -u root -p
~~~~

On Linux:

~~~~
     /usr/bin/mysql -u root -p
~~~~

* **Granting access to the xCAT database**

Next add all other nodes that need access to the database. Service Nodes are required for xCAT hierarchical support. Compute nodes may also need access depending on the application running.

    mysql > GRANT ALL on xcatdb.* TO xcatadmin@<servicenode(s)> IDENTIFIED BY 'xcat201';


**Note: You want to do a GRANT ALL to every ipaddress or nodename that will need to access the database. You can use wildcards as follows:**

     mysql > GRANT ALL on xcatdb.* TO xcatadmin@'%.cluster.net' IDENTIFIED BY 'xcat201';
     mysql > GRANT ALL on xcatdb.* TO xcatadmin@'8.113.33.%' IDENTIFIED BY 'xcat201';


You can also use the following to add these hosts, see man mysqlsetup, where you define the hostnames in the input hostfile.

     mysqlsetup -f <hostfile>


* **To revoke access, run the following**:

    REVOKE ALL on xcatdb.* FROM xcatadmin@'8.113.33.%';





* Verify the user table was populated.*

~~~~
    mysql > SELECT host, user FROM mysql.user;

~~~~



User Table

<!---
begin_xcat_table;
numcols=2;
colwidths=15,15;
-->


|%            | xcatadmin
--------------|---------
| 127.0.0     | root
|%cluster.net | xcatadmin
|localhost    | root
|mn20         | xcatadmin

<!---
end_xcat_table
-->


* Check system variables

~~~~
    mysql > SHOW VARIABLES;
~~~~



* Check the defined databases.

~~~~
     mysql > SHOW DATABASES;
~~~~

<!---
begin_xcat_table;
numcols=1;
colwidths=15;
-->

|Database
|--------
|mysql
|test
|xcatdb

<!---
end_xcat_table
-->



The following shows you how to view the tables. At this point no tables have been defined in the xcatdb yet. Run again after the database is populated.

~~~~

     mysql > use xcatdb;
     mysql > SHOW TABLES;
     mysql > DESCRIBE <tablename>;

~~~~





Exit out of MySQL.

~~~~
    mysql > quit;
~~~~

#### Migrate xCAT data to MySQL
If you are using the mysqlsetup script from xCAT2.3.1 or later, this section will automatically be done for you and you can skip it.  
See [mysqlsetup](http://xcat.sourceforge.net/man1/mysqlsetup.1.html).

You must backup your xCAT data before populating the xcatdb database. 
There are required default entries that were created in the SQLite database when the xCAT RPMs were installed on the Management Node, and they must be migrated to the new MySQL database.

~~~~
    mkdir -p ~/xcat-dbbackdumpxCATdb -p ~/xcat-dbback
~~~~

Note: if you get an error, like "Connection failure: IO::Socket::SSL: connect: Connection refused at....," make sure your xcatd daemon is running.




**Creating the /etc/xcat/cfgloc file** tells xcat what database to use. If the file does not exists, it uses by default SQLite, which is setup during the xCAT install by default. The information you put in the files, corresponds to the information you setup when you configured the database.

Create a file called /etc/xcat/cfgloc and populate it with the following line:

~~~~
    mysql:dbname=xcatdb;host=mn20|xcatadmin|xcat201
~~~~

The dbname is the xcatdb you previously created. The host must match what is in site.master for the Management Node which you entered as a resolvable hostname that could access the database with the "Grant ALL" command. The xcatadmin and password must match what was setup when you setup your xcatadmin and password when you created the xcatadmin and password.

Finally change permissions on the file, so only root can read, to protect the password.

~~~~
    chmod 0600 /etc/xcat/cfgloc
~~~~

  * stop the xcatd daemon

~~~~
    On AIX:
     stopsrc -s xcatd
    On Linux:
     service xcatd stop
~~~~

You must export in to the XCATCFG env variable the contents of your cfgloc file in the next step, so it will restore into the new database.

Restore your database to MySQL. Use bypass mode to run the command without since we have stopped xcatd.

~~~~
     export XCATBYPASS=1

    XCATCFG="mysql:dbname=xcatdb;host=mn20|xcatadmin|xcat201" restorexCATdb -p ~/xcat-dbback
~~~~




Note: If you have errors, you can go back to using SQlite, by moving /etc/xcat/cfgloc to /etc/xcat/cfgloc.save and restarting xcatd.




Start the xcatd daemon using the MySQL database.

On AIX:

~~~~
    xcatstart (xCAT2.4 use restartxcatd)
~~~~

On Linux:

~~~~
    service xcatd restart
~~~~




  Test the database

~~~~
    tabdump site
~~~~

### **Add ODBC support**

**Note: You only need to follow the steps in this section on adding ODBC support, if you plan to develop C, C++ database applications on the database or run such applications (like LoadLeveler). Otherwise skip to the next section.**







  * Install ODBC package and MySQL connector.

On AIX:

You need the unixODBC package included in the dep-aix-xxxx.tar.gz file. As of xCAT2.5 , the unixODBC will automatically be installed. The mysql-connector-odbc package is included in xcat-mysql-xxxx.tar.gz. You will need to install X11.base.lib AIX package as a prerequisite to installing the mysql-connector-odbc* package. Both .gz files were downloaded when xCAT and MySQL were set up the xCAT Management Node, but mysql-connector-odbc* was not automatically installed with the instmysql script provided. To install the packages use the following commands:

~~~~
    rpm -i unixODBC-*rpm -i mysql-connector-odbc-*
~~~~

On Linux:

These packages come as part of the OS. Please make sure the following packages are installed on your management node.

For RedHat and Fedora:

~~~~
     rpm -i unixODBC-*rpm -i mysql-connector-odbc-*
~~~~

For SLES, **if not using LoadLeveler:**

~~~~
     rpm -i unixODBC-*
     rpm -i mysql-client-*
     rpm -i libmysqlclient*
     rpm -i MyODBC-unixODBC-*
~~~~


(Please note that MyODBC-unixODBC rpm can be found in SDK CD 1 for SLES 11)

For SLES 11 SP3 ( MySQL 5.5) , **if using LoadLeveler,** the OS MyODBC-unixODBC must be replaced as indicated in the next section. "Upgrade mysql-connector for LoadLeveler on SLES11 SP1". So first just install these rpms and not the myODBC* rpm.

~~~~
     rpm -i unixODBC-*
     rpm -i mysql-client-*
     rpm -i libmysqlclient*
~~~~




#### **Upgrade mysql-connector for LoadLeveler on SLES11 SP3**

Note: SLES11 SP3 ships a new verson of MySQL ( 5.5). See the following release note for upgrading your current MySQL version, in section "6.2.2 Upgrading MySQL to Version 5.5" in the below link.

**Before upgrading your MySQL level do the following:**

  * backup your database ( use the mysql database backup commands to get the entire database. dumpxCATdb will only backup xCAT tables.
  * service xcatd stop on the Management node and all service nodes

https://www.suse.com/releasenotes/x86_64/SUSE-SLES/11-SP3

IF MyODBC-unixODBC-*.rpm is installed on the system you need to remove it and replace it with the steps below:

~~~~
     rpm -e MyODBC-unixODBC-3.51.26r1127-1.25
~~~~

Note: On SLES11 SP3 **(MySQL 5.5)** If you are using the LoadLeveler product with the MySQL database, you must replace the OS version of mysql-connector-odbc-* with mysql-connector-odbc-5.2.6-1.sles11.

Go to http://dev.mysql.com/downloads/connector/odbc/ Select **SuSE Linux Enterprise Server** and download mysql-connector-odbc-5.2.6-1.sles11.x86_64.rpm and install the rpm:

~~~~
    rpm -ihv mysql-connector-odbc-5.2.6-1.sles11.x86_64.rpm
~~~~

Also, download mysql-connector-odbc-5.2.6-linux-sles11-x86-64bit.tar.gz.


Use the myodbc-installer provided in the extracted tar file's bin directory to add an entry into the odbcinst.ini file

~~~~
    cd  ../mysql-connector-odbc-5.2.6-linux-sles11-x86-64bit/bin
    ./myodbc-installer -d -a -n "MySQL ODBC 5.2 Driver" -t "DRIVER=/usr/lib64/libmyodbc5.so"
~~~~


After that command is invoked, there should be an entry similar to the following in the odbcinst.ini file:

~~~~
    # cat /etc/unixODBC/odbcinst.ini
    [MySQL ODBC 5.2 Driver]
    Driver          = /usr/lib64/libmyodbc5.so
    UsageCount              = 1
~~~~


For the xcatdb stanza in the odbc.ini file, specify the Driver name that was created in the previous step . (MySQL ODBC 5.2 Driver) as the "Driver"

~~~~
    # cat /etc/unixODBC/odbc.ini
    [xcatdb]
    DRIVER    = MySQL ODBC 5.2 Driver    &lt;ip address/hostname&gt;
    PORT      = 3306
    DATABASE  = xcatdb
    USER      = xcatadmin
    PASSWORD  = xcat201
~~~~

Note the USER and PASSWORD are the same that were set when you ran mysqlsetup -i. They are also available in the /etc/xcat/cfgloc file.

**You can use mysqlsetup command in xCAT to perform the setup of the ODBC or use the manual setup below. See manpage for mysqlsetup. Run the following command:**

IF you are not running LoadLeveler on SLES 11, where you setup the ODBC in the previous step, run the following:

~~~~
    mysqlsetup -o
~~~~

or if you use Loadleveler

~~~~
    mysqlsetup -o -L
~~~~

If you are running LoadLeveler on SLES11 and have setup the ODBC in the previous step, run:

~~~~
     mysqlsetup -L
~~~~

Note: the -L option will only work on SLES with MySQL version 5.1.6 or later.** If your MySQL is an earlier version and you are using LoadLeveler, you run as the root database user. See additional setup below in the sections: **"For LoadLeveler on SLES:** If the MySQL version is earlier than version 5.1.6:"**.

If you use the mysqlsetup command above and have setup the ODBC, you can skip to
[Setting_Up_MySQL_as_the_xCAT_DB#Setup the ODBC on the Service Node](Setting_Up_MySQL_as_the_xCAT_DB/#setup-the-odbc-on-the-service-node)


  * For LoadLeveler, need additional MySQL configuration, login interactive pgm:

On AIX:

~~~~

    /usr/local/mysql/bin/mysql -u root -p
~~~~

On Linux:

~~~~
     /usr/bin/mysql -u root -p
~~~~

Then for Linux and AIX:

~~~~
    mysql > SET GLOBAL log_bin_trust_function_creators=1;
    mysql > quit;
~~~~

  * To configure ODBC you need to make changes to the odbcinst.ini and odbc.ini files so that ODBC works with the xCAT database.

    First update the odbcinst.ini file with the correct libmyodbc.so name.


On AIX, RH and Fedora:

First find the ODBC driver. For AIX, RH and Fedora:

~~~~
    rpm -ql mysql-connector-odbc
    vi /etc/odbcinst.ini
    [MySQL]
    Description = ODBC for MySQL
    Driver = /usr/lib/libmyodbc3.so
~~~~

On SLES:

First find the ODBC driver.

~~~~
    rpm -ql MyODBC-unixODBC


    vi /etc/unixODBC/odbcinst.ini
    [MySQL]
    Description = ODBC for MySQL
    Driver = /usr/lib64/unixODBC/libmyodbc3.so
~~~~

Then update the obdc.ini files with the DSN information for ODBC. Use SERVER, and DATABASE name as defined in the /etc/xcat/cfgloc file. DRIVER and PORT are fixed.

On AIX, RH and Fedora:

~~~~
    vi /etc/odbc.ini


    [xCATDB]
    Driver = MySQLSERVER = mn20
    PORT = 3306
    DATABASE = xcatdb
~~~~

On SLES:

~~~~
    vi /etc/unixODBC/odbc.ini


     [xCATDB]
    Driver = MySQL
    SERVER = mn20
    PORT = 3306
    DATABASE = xcatdb
~~~~

On All OS's:

  * Put the xcatadmin id and password for xcatdb database on the root's home directory so that user root will not have to specify them when accessing the database through ODBC. The SERVER, DATABASE, USER and PASSWORD must match was put in the /etc/xcat/cfgloc file.

~~~~
    vi ~/.odbc.ini
    [xCATDB]
    SERVER = mn20
    DATABASE = xcatdb
    USER = xcatadmin
    PASSWORD = xcat20l
~~~~

Update the permissions for root only read of the file.

~~~~
    chmod 0600 ~/.odbc.ini
~~~~

**For LoadLeveler on SLES:** If the MySQL version is earlier than version 5.1.6:****

  * You will need to set up the ~/.odbc.ini file to use the root database user:

~~~~
       vi ~/.odbc.ini
       [xCATDB]
       SERVER = mn20
       DATABASE = xcatdb
       USER = root
       PASSWORD = <root_pw>
~~~~

  * The following grant should also be applied for the root database user:

~~~~
     mysql > GRANT ALL on *.* TO root@mn20 IDENTIFIED BY 'root_pw';
     mysql > flush privileges;
~~~~

#### **Setup the ODBC on the Service Node**

  * Configure the Service Node. **Skip this step if there are no service nodes in the cluster.** If there are service nodes in the cluster you need to install unixODBC and MySQL connector on them and modify the ODBC configuration files just as we did in step 1 and 2. xCAT has utilities to install additional software on the nodes. To install ODBC and MySQL on to the service nodes, refer to the following documents for details:

AIX:[Updating_AIX_Software_on_xCAT_Nodes]

Linux: [Using_Updatenode]


**As of xCAT 2.6, we have provided a post install script (odbcsetup), to automatically configure the ODBC after the Service node is installed. **

Note: if using LoadLeveler and SLES11, you can not use the odbcsetup postscript and must go to the manual setup of the Service Node below: "If you do not use the odbcsetup script"


Add the odbcsetup postbootscript to the service entry in your postscripts table and you can skip the following instructions on syncing the ODBC files to the service nodes.


For example on Linux, in the postscripts table:

~~~~
    #node,postscripts,postbootscripts,comments,disable
    "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,
    "service","servicenode,xcatserver,xcatclient","**odbcsetup**",,
~~~~

As of **xCAT 2.7,** the xcatserver and xcatclient postscripts are no longer needed. Your postscripts table will be

~~~~
    #node,postscripts,postbootscripts,comments,disable
    "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,
    "service","servicenode","**odbcsetup**",,
~~~~





If you use the odbcsetup script, you can skip to  Test the ODBC connection.

If you do not use the odbcsetup script:

Then sync the **.odbc.ini**, odbcinst.ini, and odbc.ini files to the service nodes. The service is the node group name for all the service nodes.

On AIX:

~~~~
    xdcp service -v /etc/odbcinst.ini /etc/odbcinst.ini
    xdcp service -v /etc/odbc.ini /etc/odbc.ini
    xdcp service -v /.odbc.ini /.odbc.ini
~~~~


On RH and Fedora:

~~~~
    xdcp service -v /etc/odbcinst.ini /etc/odbcinst.ini
    xdcp service -v /etc/odbc.ini /etc/odbc.ini
    xdcp service -v /root/.odbc.ini /root/.odbc.ini
~~~~


On SLES

~~~~
    xdcp service -v /etc/unixODBC/odbcinst.ini /etc/unixODBC/odbcinst.ini
    xdcp service -v /etc/unixODBC/odbc.ini /etc/unixODBC/odbc.ini
    xdcp service -v /root/.odbc.ini /root/.odbc.ini ( not there for SLES 11 running LoadLeveler
~~~~

**IF using LoadLeveler on SLES, then you must do the following on each Service Node:**

On SLES, If you are using the LoadLeveler product with the MySQL database, you must replace the OS version of mysql-connector-odbc-* with the mysql-connector-odbc-5.1.8. Go to http://dev.mysql.com/downloads/connector/odbc/#downloads and select "Linux-Generic". Download mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit.tar.gz and untar/unzip:

IF MyODBC-unixODBC-*.rpm is installed on the service node, you need to remove it and replace it using the steps below:

~~~~
   rpm -e MyODBC-unixODBC-3.51.26r1127-1.25

    # tar -xzvf mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit.tar.gz
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/ChangeLog
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/INSTALL
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/LICENSE.gpl
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/README
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/README.debug
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/bin/
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/bin/myodbc-installer
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/libmyodbc5-5.1.8.so
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/libmyodbc5.so
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/libmyodbc5.la
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/libmyodbc3S-5.1.8.so
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/libmyodbc3S.so
    mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/libmyodbc3S.la
~~~~

Copy the libraries under the extracted tar file's lib directory to /usr/lib64

~~~~
     cd mysql-connector-odbc-5.1.8-linux-glibc2.3-x86-64bit/lib/
     cp -d * /usr/lib64/
~~~~

##### Test the ODBC connection

On AIX, as root:

~~~~
    /usr/local/bin/isql -v xcatdb
~~~~

or as non-root user:

~~~~
     /usr/local/bin/isql -v xcatdb xcatadmin xcat201

~~~~

On Linux, as root:

~~~~
    /usr/bin/isql -v xcatdb
~~~~

or as non-root user:

~~~~
    /usr/bin/isql -v xcatdb xcatadmin xcat201
~~~~


Connected!
---------------
sql-statement
help[tablename]
quit


~~~~

SQL> SHOW TABLES;

~~~~


Tables in xcatdb
---------------
...
nodelist
site
...



~~~~

SQL > DESCRIBE site;
~~~~



site table
Field | Type        | Null | Key  |Default  |Extra
key   |varchar(128) |no    |PRI   |         |
value |text         | YES  |      |NULL |
comments |text      |YES   |      |NULL |
disable |text       |YES   |      |NULL |





~~~~

    SQL >  quit;
~~~~

## **Removing MySQL xcatd database**

To remove the database, first run a backup:

~~~~
    mkdir -p ~/xcat-dbback
    dumpxCATdb -p ~/xcat-dbback
~~~~

Stop the xcatd daemon

On AIX:

~~~~
    stopsrc -s xcatd
~~~~

On Linux:

~~~~
    service xcatd stop
~~~~

Now remove the database.

On AIX:

~~~~
     /usr/local/mysql/bin/mysql -u root -p
~~~~

On Linux:

~~~~
    /usr/bin/mysql -u root -p
~~~~

For AIX and Linux:

~~~~
    mysql> drop database xcatdb;
~~~~

Move /etc/xcat/cfgloc file ( points xCAT to MySQL)

~~~~
    mv /etc/xcat/cfgloc /etc/xcat/cfgloc.mysql
~~~~

Install the MySQL database into SQLite

~~~~
    XCATBYPASS=1 restorexCATdb -p ~/xcat-dbback
~~~~

Start xcatd

On AIX:

~~~~
    restartxcatd
~~~~

On Linux:

~~~~
    service xcatd start
~~~~

If you wish to remove all MySQL

  1. Stop the MySQL daemon
  2. use rpm -e to remove the xcat-mysql rpm
  3. Remove the /var/lib/mysql directory

## **Rerunning mysqlsetup -i **

If you wish to run mysqlsetup -i again after following the steps after removing the database ( see above)

  1. Stop the MySQL daemon
  2. Run mysqlsetup -i

## **Migrate to AIX 7.1**

AIX 7.1 uses a new level of Perl ( 5.10.1). A new level for AIX 7.1 of the perl-DBD rpm for MySQL must be installed to replaced the AIX 6.x rpm that was installed previously.


During the OS migration:

the xcatd daemon should be stopped.


After the OS migration:

The new rpm can be obtained from the xcat mysql package on the web:

http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-mysql-201007271215.tar.gz/download




  * Download the xCAT MySQL package
  * rpm -Uvh perl-DBD-mysql-4.007-2.aix7.1.ppc.rpm
  * start the xcatd daemon

## **Migrate to new level MySQL**

When migrating to a new xCAT level of MySQL go through the entire setup again. This is best to stay on your current level, even though a new one has been made available. In the future, we will be changing the install of MySQL to be more automated so this will not be the case. To summarize do the following:




  1. Backup your database. Refer to section 1.3 Migrate xCAT data to MySQL.
  2. Stop xcatd daemon.On AIX: xcatstop '**(xCAT2.4 stopsrc -s xcatd)****On Linux: service xcatd stop**
  3. Stop the MySQL daemon.

On AIX:

~~~~
    /usr/local/mysql/bin/mysqladmin -u root -p shutdown
~~~~

On Linux:

~~~~
    /usr/bin/mysqladmin -u root -p shutdown
    or
    service mysqld stop
~~~~

  1. Unlink the previous version of MySQL cd /usr/localrm mysql
  2. Remove the old xcat database directory

~~~~
    rm -rf /var/lib/mysql/*
~~~~

  1. Download the latest MySQL as indicated section 1.1 Install MySQL.
  2. Follow the entire install process outlined in sections 1.1 Install MySQL and 1.2 Configure MySQL. You do not need to create the mysql id or group on AIX, since they already exist. You will need to create the /etc/my.cnf file.
  3. Restore your database and start xcatd as you did in section 1.3 Migrate xCAT data to MySQL.
  4. You are now running on the new database level. You can remove the old level by going to /usr/local and removing the mysql-5.0.67-aix5.3-powerpc-64bit directory. It takes up a lot of space under /usr/local. Be sure your new level is running and your database is restored.

## **Diagnostics**

  * During restore to the MySQL database, if you see the following error message on the creation of tables:

    1071 - Specified key was too long; max key length is 1000 bytes


Check the Default char set of xcatdb database and change to Latin1, if needed:

~~~~
    Log into the MySQL interactive program
    mysql > use xcatdb;
    mysql > SHOW CREATE DATABASE xcatdb;
    if the default character set is not Latin1, then
    mysql > ALTER DATABASE xcatdb DEFAULT CHARACTER SET latin1;
    mysql > quit
    Restore you xcatdb again, or at least the tables that got errors.
~~~~

  * Running llconfig command get following error:

   ERROR 1227 (42000) at line 4: Access denied; you need the SUPER privilege for this operation
   Go to [Granting_root_super_priviledge](Setting_Up_MySQL_as_the_xCAT_DB/#granting-root-super-priviledge)


## **Useful MySQL commands**

Log into the MySQL interactive program

On AIX:

~~~~

/usr/local/mysql/bin/mysql -u root -p
~~~~

On Linux:

~~~~

/usr/bin/mysql -u root -p


    mysql > show variables;
    mysql > show status;
    mysql > use xcatdb;
    mysql > show create table site;
    mysql > show tables;
    mysql > drop table prescripts;
~~~~

## If you lose MySql root password

This web site gives instructions on how to recover if you forget your MySQL root password. This is different from the OS root password.

~~~~
    http://www.cyberciti.biz/faq/mysql-reset-lost-root-password/
~~~~

Here is another process that seems to work, make sure when you run mysqld stop below, all the mysql processes do stop and if not kill -9 them. Check with ps -ef | grep mysql

~~~~
     /etc/init.d/mysqld stop
     mysqld_safe --skip-grant-tables &
     mysql -u root
     mysql >  use mysql;
     mysql >  update user set password=PASSWORD("newrootpassword") where User='root';
     mysql >  flush privileges;
     mysql >  quit
     /etc/init.d/mysqld stop
     /etc/init.d/mysqld start
~~~~

## Granting root super priviledge

Application, such as Loadleveler which use triggers must have the admin and root have SUPER priviledges to the MySQL database. If you get an error such as the following setting up the LL MySQL database, you will need to grant SUPER user authority.

    ERROR 1227 (42000) at line 4: Access denied; you need the SUPER privilege for this operation


To grant SUPER priviledge authority logon as root in interactive mode on the Management Node (MySQL server)

~~~~
    GRANT ALL PRIVILEGES ON *.* TO 'root' @'localhost' identified by 'root_pw' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'xcatadmin' @'localhost' identified by 'xcatadmin_pw' WITH GRANT OPTION;
    flush privileges;
~~~~

and if the Service Node is accessing the DB as ip 10.5.120.1, and Loadleveler is running on the Service node, then also add

~~~~
    GRANT ALL PRIVILEGES ON *.* to 'root' @'10.5.120.1' identified by 'root_pw' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'xcatadmin' @'10.5.120.1' identified by 'xcatadmin_pw' WITH GRANT OPTION;
    flush privileges;
~~~~

Show results

~~~~
    SHOW GRANTS FOR 'root'@'localhost';
~~~~

## **References**

  * http://www.pantz.org/software/mysql/mysqlcommands.html
  * http://dev.mysql.com/doc/refman/5.0/en/tutorial.html
  * http://dev.mysql.com/doc/refman/5.1/en/server-parameters.html


## Document Test Record
Tested by Ting Ting Li on Aug. 6 2014 against xCAT 2.8.5
