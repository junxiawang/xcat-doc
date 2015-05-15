<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Switching to PostgreSQL Database on Management Node](#switching-to-postgresql-database-on-management-node)
  - [Installing PostgreSQL](#installing-postgresql)
    - [**Install Postgresql on Linux**](#install-postgresql-on-linux)
    - [**Install PostgreSQL on AIX MN ( xCAT 2.5 release or later)**](#install-postgresql-on-aix-mn--xcat-25-release-or-later)
  - [Setup PostgreSQL on AIX and Linux](#setup-postgresql-on-aix-and-linux)
    - [Using the pgsqlsetup script (xCAT 2.5 or later)](#using-the-pgsqlsetup-script-xcat-25-or-later)
    - [**Setting up the Service Nodes (Hierarchy)**](#setting-up-the-service-nodes-hierarchy)
    - [**Manually setup PostgreSQL**](#manually-setup-postgresql)
  - [**Migrate your database to PostgreSQL**](#migrate-your-database-to-postgresql)
- [**Using Postgresql ( psql command line interface)**](#using-postgresql--psql-command-line-interface)
- [**Migrate to AIX 7.1**](#migrate-to-aix-71)
- [_Useful Postgresql Commands_](#_useful-postgresql-commands_)
- [Command references:](#command-references)
- [**Setup ODBC**](#setup-odbc)
  - [Automatic setup of ODBC](#automatic-setup-of-odbc)
  - [Manually setup ODBC](#manually-setup-odbc)
    - [Create odbc setup files](#create-odbc-setup-files)
  - [create root role](#create-root-role)
  - [Test ODBC](#test-odbc)
- [Removing  Postgresql  Database](#removing--postgresql--database)
- [Document Test Record](#document-test-record)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Switching to PostgreSQL Database on Management Node

One reason to migrate from the xCAT default SQLite database to PostgreSQL is for xCAT hierarchy using Service Nodes. PostgreSQL provides the ability for remote access to the database on the xCAT Management Node; a requirement for Service Nodes. PostgreSQL also support IPV6. 

**Note: If using postgresql-9.0, the paths have changed from /var/lib/pgsql/... to /var/lib/pgsql/9.0/...  
The postgresql service name has changed to postgresql-9.0 (service postgresql-9.0 stop/start)**


  
This following documentation assumes: 

  * 11.16.0.1 : IP of management node (cluster-facing NIC) 
  * xcatdb    : database name 
  * xcatadm   : database role (aka user) 
  * cluster   : database password 
  * 11.16.1.230 &amp; 11.16.2.230: service nodes (mgmt node facing NIC) 

Substitute your IP addresses, userid, password, and database name as appropriate. 

### Installing PostgreSQL

#### **Install Postgresql on Linux**

The PostgreSQL rpms are part of the base Linux OS. Please verify the following rpms are installed:

~~~~    
    postgresql-libs-*
    postgresql-server-*
    postgresql-*

    perl-DBD-Pg*    
~~~~    

Note: in SLES the Perl-DBD is located in the SDK 

You may also want to install the following:

~~~~    
    postgresql-odbc*
    postgresql-plpython
    postgresql-plperl
~~~~    

On Debian/Ubuntu. Should install following packages: 

~~~~    
    postgresql
    libdbd-pg-perl
~~~~    


#### **Install PostgreSQL on AIX MN ( xCAT 2.5 release or later)**

**Space Required for database install:**

  * PostgreSQL will be installed in /var/lib/pgsql and needs about 24 mgbytes for the code and add the size needed for the xCAT database. You may also need to increase /etc and /usr. 

**As root:**

  * Download PostgreSQL rpms package from the following location: 

http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX 

  * Unzip and untar in the location of your choice. 

~~~~    
    gunzip xcat-postgresql*.gz
    tar -xvf xcat-postgresql*.tar
~~~~    

**Read the README** file for installation instructions, and install the two rpms on the AIX Management Node that are appropriate for your OS level. 

  
**Note: as of Oct 2010, the AIX deps package will automatically install the perl-DBD-Pg , and unixODBC-* when installed on the Management or Service Nodes. You may find these already installed. **

### Setup PostgreSQL on AIX and Linux

#### Using the pgsqlsetup script (xCAT 2.5 or later)

**You should use the pgsqlsetup script to setup xCAT on PostgreSQL instead of following steps under "Manually setup PostgreSQL" section**

  
See the pgsqlsetup man page for more information on the script. The script will complete all actions described in the "Manually setup PostgreSQL" section, including the addition of the Management Nodes IP address in the pg_hba.conf file. 

The script will prompt you for an xCAT admin password for the database.  As of xCAT2.8, you can bypass this prompt by setting XCATPGPW=<password> in the environment.

To setup the PostgreSQL database, run 

~~~~    
     pgsqlsetup -i -V
~~~~    


#### **Setting up the Service Nodes (Hierarchy)**

After the automatic setup is complete, to support Service Nodes you need to 

  * add additional IP addresses to the /var/lib/pgsql/data/pg_hba.conf file for each Service Node.

~~~~
    host    all          all        11.16.1.230/32      md5
    host    all          all        11.16.2.230/32      md5
~~~~ 

  * Stop and start PostgreSQL when you edit those files. 

Look in the "Setup the PostgreSQL configuration files" section for more information in changing the pg_hba.conf and postgresql.conf files. 

  * When the Service Node is installed by xCAT, it will transfer the correct /etc/xcat/cfgloc file and the necessary credentials for the xCAT daemon on the Service Node to access the database on the Management Node. 
  * The PostgreSQL rpms and perl-DBD must be installed on the Service Node. For Linux, this is shipped with the OS distribution. For AIX, you must installed the one provided by xCAT. See Install PostgreSQL on AIX MN (xCAT 2.5 release or later) for the location of the rpms. These should be added to the AIX install_bundle resource for the Service Node. 
  * On AIX, you will need to increase the default install sizes of the filesystems to accommodate installing the PostgreSQL rpms on the Service Nodes when installing. 

~~~~
    * /var - 131072 bytes 
    * / - 2818048 bytes 
    * /opt - 52428 bytes 
~~~~


#### **Manually setup PostgreSQL**

**STOP: If using xCAT 2.5 or later, you can use pgsqlsetup to do this work. See above for instructions.**

  
**As root**: Stop the xcatd daemon during the database migration: 

  
AIX: 

~~~~
stopsrc -s xcatd 
~~~~
  
Linux: 

~~~~

service xcatd stop 
~~~~
  
**On AIX create the needed postgreSQL ids:**

  


  * Create the postgres id that will administer the PostgreSQL server 

~~~~    
    mkgroup postgres
    mkuser pgrp=postgres home=/var/lib/pgsql postgres
    passwd postgres ( assign a password this is optional)
~~~~    

  * Create the xcatadm id that will own the xcatdb in PostgreSQL 
 
~~~~   
    mkuser xcatadm
    passwd xcatadm ( assign temp password with root)
    su - xcatadm
    passwd ( assign permanent password that will be used in the /etc/xcat/cfgloc file)
~~~~    

  * Create the directory for the databases and make postgres the owner 

as root: 
  
~~~~  
    mkdir /var/lib/pgsql/data
    chown postgres /var/lib/pgsql/data
    chgrp postgres /var/lib/pgsql/data
    su - postgres
    pwd ( are you in /var/lib/pgsql)
~~~~    

  


  * Setup .profile 

Add paths needing to run DB commands to the .profile 
 
~~~~   
    MANPATH=/usr/local/pgsql/man:$MANPATH
    export MANPATH
    PATH=/usr/local/pgsql/bin:$PATH
    export PATH
~~~~    

**On AIX as postgres Create a database installation by running the following:**
 
~~~~   
    /var/lib/pgsql/bin/initdb -D /var/lib/pgsql/data
~~~~    

  
You should get the following message "Success. You can now start the database..." 

  
**On Linux as root run the following to create the Database installation:**

  

~~~~
    service postgresql initdb
~~~~    

  
Setup the PostgreSQL configuration files 

On AIX or Linux as root: 


~~~~
    vi /var/lib/pgsql/data/pg_hba.conf
~~~~    

  
Lines should look like this (with your IP addresses substituted). Add all nodes that need to access the database. 
 
~~~~   
    local all all ident sameuser
    # IPv4 local connections:
    host all all 127.0.0.1/32 md5
    host all all 11.16.0.1/32 md5
    host all all 11.16.1.230/32 md5
    host all all 11.16.2.230/32 md5
~~~~    

  
For example, where 11.16.0.1 is the MN and 11.16.1.230 and 11.16.2.230 are service nodes. 

  
~~~~
    
    vi /var/lib/pgsql/data/postgresql.conf
    set listen_addresses = '*' # This allows remote access from all ips
~~~~    

**Note: be sure and un-comment the line.**

The following logging setup is the default on Linux, but should be set on AIX also. 
 
~~~~   
    logging_collector = on
    log_directory = 'pg_log'
    log_filename = 'postgresql-%a.log'
    log_truncate_on_rotation = on
    log_rotation_age = 1d
    log_rotation_size = 0
    log_min_messages = notice
~~~~    

  
If you are working on large systems, you may need to set the max_connections attribute in the file. This is the number of connections that can be make to the database at one time. If you are using service nodes, it is recommended that you 

~~~~    
    set max_connections = 1000
~~~~    

  


Start/Stop the PostgreSQL server 

start the server: 

AIX: 

~~~~    
     su - postgres
     /var/lib/pgsql/bin/pg_ctl -D /var/lib/pgsql/data start
~~~~    

Linux: 

~~~~    
    service postgresql start
~~~~    

If you need to stop the server:

AIX: 

~~~~    
    su - postgres
    /var/lib/pgsql/bin/pg_ctl -D /var/lib/pgsql/data stop
~~~~    

Linux: 

~~~~    
    service postgresql stop
~~~~    

  
Note: you can get the message $ LOG: could not bind IPv6 socket: Address already in use HINT: Is another postmaster already running on port 5432? If not, wait a few seconds and retry after setting listen_addresses = '*' , it can be ignored. 

  


  


**On AIX and Linux:**
 
~~~~   
    su - postgres:
~~~~    

  
Create the xcatadm userid in the database and set to own xcatdb 

AIX: 

~~~~    
    /var/lib/pgsql/bin/createuser -SDRP xcatadm
~~~~    

Linux: 

~~~~    
    /usr/bin/createuser -SDRP xcatadm
~~~~    

  
( Will prompt for a password, use the same one that you input for the AIX xcatadm id. Note: this xcatadm unix id does not have to exist on Linux, only in the database.). 

  
Create the xcatdb database owned by xcatadm 

AIX: 

~~~~    
    /var/lib/pgsql/bin/createdb -O xcatadm xcatdb
~~~~    

Linux: 

~~~~    
    /usr/bin/createdb -O xcatadm xcatdb
~~~~    

  

    
    exit ( back to root)
    

### **Migrate your database to PostgreSQL**

**Note: the pgsqlsetup script will do this for you also, if you choose to use it.**

  
Backup your database to migrate to the new database. (This is required even if you have not added anything to your xCAT database yet. Required default entries were created when the xCAT RPMs were installed on the management node which, and they must be migrated to the new postgresql database.) 
 
~~~~   
    mkdir -p ~/xcat-dbback
    XCATBYPASS=1 dumpxCATdb -p ~/xcat-dbback
~~~~    

  


  * /etc/xcat/cfgloc file should contain the following line, substituting your specific info. This points the xCAT database access code to the new database. 
  
~~~~  
    Pg:dbname=xcatdb;host=11.16.0.1|xcatadm|cluster
~~~~    

  
change to allow only root access: 

~~~~    
    chmod 0600 /etc/xcat/cfgloc
~~~~    

  


  * Restore your database to postgresql (bypass mode runs the command without xcatd): 
 
~~~~   
    XCATBYPASS=1 restorexCATdb -p ~/xcat-dbback
~~~~    

  


  * Start the xcatd daemon using the postgresql database 

AIX: 
 
~~~~   
    startsrc -s xcatd
~~~~    

Linux: 

~~~~    
    service xcatd start
~~~~    

## **Using Postgresql ( psql command line interface)**

If you want to access the database through the Postgresql (psql) command, to check the database, enter the following: 
 
~~~~   
    su - postgres
    psql -h <hostname> -U xcatadm -d xcatdb
~~~~    

( note hostname must match ip in the pg_hba.conf file) and you will be prompted for the password ( cluster). 

  
You can then run sql commands on the database. 

  
~~~~
    
    Run \h for a list of commands
    Run \g so SQL commands can end in ;
~~~~    

Then 
 
~~~~   
    select * from nodelist; to see table entries
    \dt    will list all tables;
    \q to quit
~~~~    

## **Migrate to AIX 7.1**

AIX 7.1 uses a new level of Perl ( 5.10.1). A new level for AIX 7.1 of the perl-DBD rpm and the postgresql rpm must be installed to replaced the AIX 6.x rpms that was installed previously. 

  
During the migration: 

Backup your xcat database ( dumpxCATdb) 

The xcatd daemon should be stopped. 

  
After the OS migration: 

The new rpms can be obtained from the xcat postgresql package on the web: 

  
http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-postgresql-snap201007280900.tar.gz/download 

  


  * Download the xCAT postgresql package 
  * To to the 7.1 subdirectory 
  * rpm -Uvh perl-DBD-Pg-2-17.2.aix7.1.ppc.rpm xcat-postgresql-8.4-4.aix7.1.ppc.rpm 
  * start the xcatd daemon 

## _Useful Postgresql Commands_

  * Show create statement for a table, for example prescripts table. 

~~~~    
    /usr/bin/pg_dump xcatdb -U xcatadm -t prescripts
~~~~    

  * Drop the database 

~~~~    
    su - postgres
    dropdb xcatdb - drops the database
    dropuser xcatadm -  removes the xcatadm database owner
    cd /var/lib/pgsql/data
    rm -rf *    (need to remove the data if you want to recreate)
~~~~    
    

  * List databases 

~~~~    
    su - postgres
    psql -l
~~~~    
    

  * Access database 
  
~~~~  
    su - postgres
    psql xcatdb
    SELECT * FROM "pg_user";    Select all users
    SELECT * FROM "site";   Select the site table
    SELECT MAX(recid) from "auditlog";
    SELECT MIN(recid) from "auditlog";
    drop table zvm;   Removes a table
    \dt    Select all tables
    \?  help
    \q   exit
~~~~    
    
    

You can get a nice list of useful commands from here: 

~~~~
  http://www.linuxweblog.com/postgresql-reference 
~~~~

## Command references:

  * http://www.thegeekstuff.com/2009/04/15-practical-postgresql-database-adminstration-commands/ 
  * http://www.faqs.org/docs/ppbook/c22759.htm 

## **Setup ODBC**

Install: 

~~~~    
    postgresql-odbc-*
    unixODBC-*
~~~~    

On Debian/Ubuntu install: 

~~~~    
    unixodbc
    odbc-postgresql
~~~~    

### Automatic setup of ODBC

As of xCAT 2.8, the pgsqlsetup script will automatically setup the ODBC interface for Linux after xCAT has been setup to use postgreSQL. AIX is not supported. To setup the ODBC on the Management Node, run the following command and then you can skip the "Manually setup ODBC" section. 

~~~~    
    pgsqlsetup -o -V
~~~~    

### Manually setup ODBC

#### Create odbc setup files

~~~~    
    cat /root/.odbc.ini
    [xCATDB]
    SERVER = x.xx.xx.xx
    DATABASE = xcatdb
    USER     = xcatadm
    PASSWORD = xcat20
    
    chmod 0600 /root/.odbc.ini
    
    
    cat /etc/odbc.ini
    [xCATDB]
    Driver   = PostgreSQL
    SERVER   = xx.xx.xx.xx
    PORT     = 3306
    DATABASE = xcatdb
    
    
    cat /etc/odbcinst.ini
    # Driver from the postgresql-odbc package
    # Setup from the unixODBC package
    [PostgreSQL]
    Description     = ODBC for PostgreSQL
    Driver          = /usr/lib/psqlodbc.so
    Setup           = /usr/lib/libodbcpsqlS.so
    Driver64        = /usr/lib64/psqlodbc.so
    Setup64         = /usr/lib64/libodbcpsqlS.so
    FileUsage       = 1
~~~~    

### create root role
    
    su - postgres
    createuser -SDRP root
    Enter password for new role:
    Enter it again:
    

### Test ODBC
    
    isql -v xcatdb


## Removing  Postgresql  Database

To remove the database, first run a backup:

~~~~
    mkdir -p ~/xcat-dbback
    dumpxCATdb -p ~/xcat-dbback
~~~~

Stop the xcatd daemon  on the Management Node.   Note if you are  using Service Nodes, they will no longer work. SQLite does not support Service Node.  You should stop xcatd on the service node.  After you run this process which takes you to SQLite, you will need to pick another database such as MySQL and follow the procedure for setting up MySQL for xCAT. 

On AIX:

~~~~
    stopsrc -s xcatd
~~~~

On Linux:

~~~~
service xcatd stop
~~~~

Now remove the xcatdb database from Postgresql. 

~~~~
    su - postgres
    dropdb xcatdb - drops the database
    dropuser xcatadm -  removes the xcatadm database owner
    cd /var/lib/pgsql/data
    rm -rf *    (need to remove the data if you want to recreate)

~~~~



Move /etc/xcat/cfgloc file (it points xCAT to Postgresql).   Move it on the Management  Node and Service Nodes. Service Nodes will no longer work at this point.  With no /etc/xcat/cfgloc, xcat runs on the default SQLite datbase.  

~~~~
mv /etc/xcat/cfgloc /etc/xcat/cfgloc.pg
~~~~

Restore the Postgresql  database into SQLite. xCAT will run from SQlite database now as the default. 

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


## Document Test Record
Tested by Ting Ting Li on Aug. 6 2014 against xCAT 2.8.5 
