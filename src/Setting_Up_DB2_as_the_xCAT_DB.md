<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview Setup DB2 on the Management Node](#overview-setup-db2-on-the-management-node)
- [Install DB2 on the Management Node](#install-db2-on-the-management-node)
  - [DB2 Server Host Name Resolutions](#db2-server-host-name-resolutions)
  - [Power 775 Clusters (installing the DB2 Code and License)](#power-775-clusters-installing-the-db2-code-and-license)
  - [Obtaining your own DB2 code and license](#obtaining-your-own-db2-code-and-license)
  - [Disk space needed to install DB2](#disk-space-needed-to-install-db2)
- [Installation Steps](#installation-steps)
  - [**Install DB2 on AIX or Linux MN**](#install-db2-on-aix-or-linux-mn)
  - [**Installing the DB2 License**](#installing-the-db2-license)
    - [Power 775 Clusters](#power-775-clusters)
    - [For all installations](#for-all-installations)
- [Installation and Setup of DBD::DB2 Perl modules](#installation-and-setup-of-dbddb2-perl-modules)
  - [**perl-DBI**](#perl-dbi)
  - [**Install the Perl DBD::DB2 code**](#install-the-perl-dbddb2-code)
- [**Setting up the DB2 Server Instance**](#setting-up-the-db2-server-instance)
  - [**Automatic Setup**](#automatic-setup)
    - [**DB2 Database Backup/Restore**](#db2-database-backuprestore)
  - [Manual setup](#manual-setup)
    - [Start the DB2 Server](#start-the-db2-server)
    - [**Increasing processor entitlement**](#increasing-processor-entitlement)
    - [Setup Database Manager](#setup-database-manager)
    - [Create the xCAT Database](#create-the-xcat-database)
    - [**Restart the Instance to Apply the Changes**](#restart-the-instance-to-apply-the-changes)
    - [**Restart the Instance on Reboot of the Server**](#restart-the-instance-on-reboot-of-the-server)
      - [**Special instructions for Reboot of EMS on AIX **](#special-instructions-for-reboot-of-ems-on-aix-)
    - [Work around for Linux non-support of /etc/inittab](#work-around-for-linux-non-support-of-etcinittab)
    - [**Manually restart DB2 after reboot**](#manually-restart-db2-after-reboot)
    - [Migrate xCAT data to DB2](#migrate-xcat-data-to-db2)
    - [Setup reorg DB2 Tables cron job (xCAT 2.6.6)](#setup-reorg-db2-tables-cron-job-xcat-266)
- [Setting up the DB2 Client on the Service Nodes](#setting-up-the-db2-client-on-the-service-nodes)
  - [**Installing the DB2 Client software on the SN**](#installing-the-db2-client-software-on-the-sn)
  - [**Automatic install of DB2 and Client setup on SN **](#automatic-install-of-db2-and-client-setup-on-sn-)
    - [**Give access to the DB2 code to the Service Node during install or update**](#give-access-to-the-db2-code-to-the-service-node-during-install-or-update)
  - [**Automatic Install of DB2 and Client setup on an installed Service Node**](#automatic-install-of-db2-and-client-setup-on-an-installed-service-node)
  - [**Manual install of DB2 and Client setup on the SN**](#manual-install-of-db2-and-client-setup-on-the-sn)
    - [**Creating the Client Instance on the Service Node**](#creating-the-client-instance-on-the-service-node)
  - [**Test the Database Connection**](#test-the-database-connection)
  - [Start the xCAT daemon](#start-the-xcat-daemon)
- [**Adding ODBC support**](#adding-odbc-support)
  - [Setup the ODBC on the Management Node (DB2 Server)](#setup-the-odbc-on-the-management-node-db2-server)
    - [**Using db2sqlsetup to setup the ODBC**](#using-db2sqlsetup-to-setup-the-odbc)
    - [**Setup the ODBC manually**](#setup-the-odbc-manually)
      - [**Update the odbcinst.ini file**](#update-the-odbcinstini-file)
      - [**Update the odbc.ini file**](#update-the-odbcini-file)
      - [**Update the db2cli.ini file**](#update-the-db2cliini-file)
  - [**Setup ODBC on the Service Nodes**](#setup-odbc-on-the-service-nodes)
    - [**Setting up the ODBC on the Service Nodes Automatically**](#setting-up-the-odbc-on-the-service-nodes-automatically)
    - [**Setting up the ODBC on the Service Nodes Manually**](#setting-up-the-odbc-on-the-service-nodes-manually)
  - [**Add DB2 code paths for Root**](#add-db2-code-paths-for-root)
- [**Verify DB2 setup**](#verify-db2-setup)
  - [**Verify the ODBC setup.**](#verify-the-odbc-setup)
- [Additional DB2 Setup](#additional-db2-setup)
  - [DB2 Diagnostic Logs](#db2-diagnostic-logs)
- [Useful DB2 Commands](#useful-db2-commands)
  - [DB2 Admin Commands ( run as root)](#db2-admin-commands--run-as-root)
- [Migrating to AIX 7.1](#migrating-to-aix-71)
- [Removing xCAT from DB2 and the xCAT DB2 database](#removing-xcat-from-db2-and-the-xcat-db2-database)
- [Removing DB2 from MN and SN](#removing-db2-from-mn-and-sn)
  - [**Remove DB2 from the Service Nodes **](#remove-db2-from-the-service-nodes-)
  - [**Remove DB2 from the Management Node **](#remove-db2-from-the-management-node-)
- [References](#references)
  - [General](#general)
  - [Performance References](#performance-references)
  - [DB2 Product Comparison](#db2-product-comparison)
  - [DB2 Logs](#db2-logs)
  - [Trouble Shooting](#trouble-shooting)
  - [Useful Table Information](#useful-table-information)
- [Diagnostics](#diagnostics)
  - [db2start SQL1042C An unexpected system error occurred. SQLSTATE=58004](#db2start-sql1042c-an-unexpected-system-error-occurred-sqlstate58004)
  - [**LoadLeveler unable to connect to DB2 server as Load**L](#loadleveler-unable-to-connect-to-db2-server-as-loadl)
  - [**ODBC setup failure**](#odbc-setup-failure)
  - [** Hung DB2**](#-hung-db2)
  - [The database manager resources are in an inconsistent state on db2stop](#the-database-manager-resources-are-in-an-inconsistent-state-on-db2stop)
  - [**SQL6048N**](#sql6048n)
  - [**The 32 bit library file libstdc++.so.6 is not found on the system**](#the-32-bit-library-file-libstdcso6-is-not-found-on-the-system)
  - [**Total Environment Allocation Failure**](#total-environment-allocation-failure)
  - [**drop xcatdb instance fails**](#drop-xcatdb-instance-fails)
  - [**db2start failure**](#db2start-failure)
  - [**db2stop failure**](#db2stop-failure)
  - [**Set diagnostics level in database**](#set-diagnostics-level-in-database)
  - [**Failure to create the xcatdb instance**](#failure-to-create-the-xcatdb-instance)
  - [**Service Node not accessing DB2 server**](#service-node-not-accessing-db2-server)
  - [**DB2 Instance directories with incorrect permissions**](#db2-instance-directories-with-incorrect-permissions)
  - [The number of background tasks has reached the limit of xxx, will try again later](#the-number-of-background-tasks-has-reached-the-limit-of-xxx-will-try-again-later)
  - [ADM1823E The active log is full and is held by application handle "14188..".](#adm1823e-the-active-log-is-full-and-is-held-by-application-handle-14188)
  - [./installFixPack upgrade fails](#installfixpack-upgrade-fails)
  - [The number of background tasks has reached the limit of X, will try again later](#the-number-of-background-tasks-has-reached-the-limit-of-x-will-try-again-later)
  - [SQL5043N Support for one or more communication protocol failed](#sql5043n-support-for-one-or-more-communication-protocol-failed)
  - [xcatd fails to start after reboot](#xcatd-fails-to-start-after-reboot)
  - [ADM7519W DB2 could not allocate an agent. The SQLCODE is "-1225"](#adm7519w-db2-could-not-allocate-an-agent-the-sqlcode-is--1225)
- [Appendix A:Building Perl DBD::DB2 code](#appendix-abuilding-perl-dbddb2-code)
- [Appendix B:Installing DB2 fix packs](#appendix-binstalling-db2-fix-packs)
  - [**Installing Latest Fix Packs on Management Node**](#installing-latest-fix-packs-on-management-node)
  - [**Installing Latest Fix Packs on Service Nodes**](#installing-latest-fix-packs-on-service-nodes)
      - [**Using xdsh**](#using-xdsh)
      - [**Manual update**](#manual-update)
- [Appendix C: Changing the hostname/ip address of the DB2 Server (EMS)](#appendix-c-changing-the-hostnameip-address-of-the-db2-server-ems)
- [Appendix D: Moving Service Node DB2 client to another DB2 Server](#appendix-d-moving-service-node-db2-client-to-another-db2-server)
- [Appendix E: Changing xcatd DB2 instance Password](#appendix-e-changing-xcatd-db2-instance-password)
- [Appendix F: DB2 Administration](#appendix-f-db2-administration)
  - [**Backup/Restore the database with DB2 Commands**](#backuprestore-the-database-with-db2-commands)
  - [Stopping the DB2 Server](#stopping-the-db2-server)
  - [Starting the DB2 Server](#starting-the-db2-server)
  - [Looking at DB2 logs](#looking-at-db2-logs)
  - [db2top](#db2top)
- [Appendix G: Additional ISNM Setup Information](#appendix-g-additional-isnm-setup-information)
  - [Restoring CNM database views](#restoring-cnm-database-views)
  - [Stopping ISNM Performance Counter Collection](#stopping-isnm-performance-counter-collection)
- [Appendix H: Setting up DB2 Data Server Client](#appendix-h-setting-up-db2-data-server-client)
  - [Download the DB2 Data Server Client Code](#download-the-db2-data-server-client-code)
  - [Install and Setup DB2 Data Server Client Platform](#install-and-setup-db2-data-server-client-platform)
  - [Configure DB2 Data Server Client](#configure-db2-data-server-client)
    - [**db2dsdriver.cfg**](#db2dsdrivercfg)
    - [**db2cli.ini**](#db2cliini)
    - [**Using unixODBC**](#using-unixodbc)
  - [perl DBD-DB2Lite rpms](#perl-dbd-db2lite-rpms)
  - [**DB2 Data Server Client References**](#db2-data-server-client-references)
- [** Appendix I:TEAL Database Table Commands**](#-appendix-iteal-database-table-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview Setup DB2 on the Management Node

The IBM DB2 Database Product is supported with the xCAT 2.4 release or later.

One reason to migrate from the default SQLite database to DB2 with xCAT is for xCAT hierarchy using Service Nodes. DB2 provides the ability for remote access to the xCAT database on the Management node which is required by Service Nodes. SQLite does not support remote access to the database. MySQL, Postgresql and DB2 do provide this service. Refer to the xCAT Service Node documentation for more information.

DB2 is a product of IBM. To use it with xCAT, you will need access to a licensed version of the product, our document is for the DB2 Enterprise Server Edition (ESE) Version 9.7.4 or the DB2 Work Group Server Edition (WSE) 9.7.4 or later. We support it on AIX61 TL5 or later and Linux p-series. Note for Rehat 6.1 (rhels6.1), DB2 9.7.5 or later is required.

xCAT 2.6 or later and latest dependency packages should already be installed on the Management Node following the xCAT documentations.

The trial download of DB2 will not work with xCAT, because it does not support client accesses which is a requirement for service nodes.

In this scenario, you will install the OS on your Management node, service node(s), setup the DB2 Client and then update the service node with the xCAT software. For DB2, Service Nodes must have been installed diskfull. Diskless or Statelite Service Nodes running the DB2 client code are not supported.


Note: xCAT supports open source databases MySQL and Postgresql on Linux and AIX. Postgresql on AIX is xCAT 2.6 or later. There are setup docs for each of these databases on the xCAT web, and an automated setup script for MySQL (xCAT 2.3.3 or later) and Postgresql ( xCAT 2.6 or later) . **DB2 is the only database supported by xCAT on Power 775 hardware for AIX or Linux.**







Other programs within your environment may also benefit from or require DB2. This document contains steps to install DB2, configure the server and client, create a database and populate it with your xCAT data.

Before using this document, you should have a general understanding of DB2. If necessary, review the installation and tutorial sections of the [DB2 Product documentation.](http://www-01.ibm.com/support/docview.wss?uid=swg27009474)







There are many [DB2 products](http://www-01.ibm.com/software/data/db2/), our documents will cover the install and setup of xCAT on [DB2 Enterprise Server Edition ](http://www-01.ibm.com/software/data/db2/linux-unix-windows/edition-enterprise.html) or [DB2 WorkGroup Server Edition](http://www-01.ibm.com/software/data/db2/linux-unix-windows/edition-workgroup.html). This product supports the full range of function needed by xCAT on AIX and Linux. You will need to purchase this production from IBM. This document will cover the setup of DB2 on SLES 11 SP3, Redhat 5 or 6 or AIX 6.1 or 7.1, or later releases of those products on p-Series hardware.

For more references: see the References section.




'Note: with all the DB2 commands run below, be patient. Some take several minutes to complete , and some take several seconds to return the prompt, even '**after they say they have completed. Never kill a command while running. It can cost you hours of recovery work. ( Been there, done that).**

## Install DB2 on the Management Node

xCAT has been tested on AIX 7.1 and Redhat6.0 6.1 and 6.2 (ppc64) with DB2 Version 9.7.4 and 9.7.5. To get the AIX and Linux DB2 code download from the following website the code:

    https://www-304.ibm.com/support/docview.wss?uid=swg24029745
    If you are using Power 775 clusters, obtain the IBM HPC WSER DVD which is required for Power 775 clusters.
    See Power 775 clusters below.


**If you plan to use Redhat6.1 (rhels6.1) or 6.2 you must install or upgrade to DB2 Version 9.7.5**.

If you already have DB2 installed you can skip to the section Installation and Setup of DBD::DB2 Perl modules.

### DB2 Server Host Name Resolutions

It is important to have your hostname established on the Management Node. Once DB2 is installed and configured, the hostname is stored in the DB2 repository and files. If you simply change the hostname after that, you can break DB2. If you have to change host name, you need to follow the process for reconfiguing DB2. See Diagnostics section.

In addition see the following link for information on DB2 Server Host Name resolution when accessing the DB2 xcatdb database:

http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=
    /com.ibm.db2.luw.qb.server.doc/doc/r0006351.html








### Power 775 Clusters (installing the DB2 Code and License)

For Power 775 clusters, you will receive a DVD containing DB2 WorkGroup Edition code and the HPC restricted license for it. This DVD is to be used to install your DB2 code and restricted license installation on Power 775. **You will not need to download any other DB2 code or updates.** The following commands will accept the license and install the DB2 WorkGroup Edition key. After you have accepted the HPC license, you can continue with these instructions, using the DB2 code shipped on the DVD.


~~~~

     export IBM_DB2_HPC_LICENSE_ACCEPT=yes
~~~~


Put the DVD in the drive, then type the following commands. These instructons assumes a mount point of /mnt/cdrom.

~~~~
     mkdir -p /mnt/cdrom
     mount /dev/cdrom /mnt/cdrom
~~~~


Install all the rpms

For rhel6:

~~~~
     rpm -ihv /mnt/cdrom/rhel6/*.rpm
~~~~



For aix7.1:

~~~~
     rpm -ihv /mnt/cdrom/aix71/*.rpm
~~~~


The DB2 key is installed at /opt/hpc/db2/key

~~~~
      ls -ltr /opt/hpc/db2/key/
      -rwx------. 1 root root 1012 May 21  2010 db2wse_os.lic
~~~~


If you install this license after you have created the xCAT DB2 database, you will need to stop and start the database, follwing this process:

[Stopping_the_DB2_Server](Setting_Up_DB2_as_the_xCAT_DB/#stopping-the-db2-server)

[Starting_the_DB2_Server](Setting_Up_DB2_as_the_xCAT_DB/#starting-the-db2-server)

### Obtaining your own DB2 code and license

You will need to download the DB2 Server Fix Pack for PTF4 (DB2-aix64-server-9.7.0.4-FP004 or DB2-linuxppc64-server-9.7.0.4-FP004) which contains DB2 Enterprise Server Edition or DB2 WorkGroup Edition.




~~~~
    v9.7fp4_aix64_server.tar.gz
    or
    v9.7fp4_linuxppc64_server.tar.gz

~~~~


Save the download for the install of the Client on the Service Nodes later. Most of these directions come from the [Installing Enterprise DB2](http://publib.boulder.ibm.com/infocenter/sametime/v8r0/index.jsp?topic=/com.ibm.help.sametime.801.doc/Gateway/i_rtc_t_install_installingdb2_other_ops.html)[http://publib.boulder.ibm.com/infocen.../i_rtc_t_install_installingdb2_other_ops.html](http://publib.boulder.ibm.com/infocenter/sametime/v8r0/index.jsp?topic=/com.ibm.help.sametime.801.doc/Gateway/i_rtc_t_install_installingdb2_other_ops.html)at the Product Information Center and the _Configuring and Managing BlueGene [DB2 Setup Sections._"&gt;_DB2 Setup Sections.](http://www.redbooks.ibm.com/redbooks/pdfs/sg247352.pdf) We will be using a Command Line (manual) installation method, not the Web interface.

All of the following steps must be run logged into the Management Node (xcatmn) as **root.**

Note: You must also obtain your HPC license agreement and key for DB2, which you activate after installing the DB2 server.


**Note: Setup of DB2 on AIX assumes that root is running ksh and on Linux bash. **

### Disk space needed to install DB2

DB2 will need 4 gigabytes of disk space to download and untar the tarball and then build the product for the Server and Client code on the MN. This does not include the size of the database.

The default directory for the DB2 database instance is /var/lib/db2, but as of release 2.6 you can define your own directory by setting the site.databaseloc attribute. **Do not define the databaseloc directory under the directory in the site.installloc attribute ( usually /install) which is also the same as the site.installdir attribute.** For example, if you plan to have a large system, and in particular if you are setting up a P7IH system, you may want to allocate a separate filesystem for the xcatdb instance which contains the xCAT DB2 database called /db2database. This will allow you to have a database with plenty of space. You would then set:

~~~~
    chdef -t site -o clustersite databaseloc="/db2database"
~~~~


When the DB2 instance directory is created, instead of the default /var/lib/db2, xCAT will setup /db2database/db2 as the directory.

Because the DB2 source tarball is so large, you may want to untar it on a Server and have that NFS mounted to the Management Node and install it from the mount. It will install more slowly, but you will save disk space on your MN and you do not need it on the MN after the install. Keep the source around though, because you are also going to have to install all your service nodes. The DB2 tarball contains both the Server and Client code as you will see in the instructions below. See&nbsp;:[Setting_Up_DB2_as_the_xCAT_DB#Automatic_install_of_DB2_and_Client_setup_on_SN](Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn).

  * To copy the tarball and unzip and untar -- at least 4 gigabytes
  * To install DB2 server code on the Management Node in /opt -- at least 1.5 gigabytes
  * To install DB2 client code on the Service Node in /opt -- at least .5 gigabytes
  * To create xcatdb database and instance on MN in /var or where you defined the database in the site table, databaseloc attribute, you should have a minimum of 4 gigabyte free space. To create the xcatdb instance on service nodes, you should have a minimum of .5 gigabyte free space. On the Management Node the size of /var space needed by DB2 will depend on your database size, and thus the size of your cluster. Setting up monitoring of /var size is recommended.

*** For Power 775 clusters, you should have a minimum of 100 gigabyte of free space for the database to hold the performance and monitoring data reported by TEAL, and ISNM.**

  * On the Management node and Service Nodes, to install DB2 Server or the DB2 Client on the Service Nodes, you should set /tmp with 1G of space.

As of xCAT2.6 you do not have to use the default /var/lib/db2 for your xcatdb instance directory. You can set the site.databaseloc attribute to a file system and that will become the location where the db2sqlsetup script will create the db2 instance directory. See man db2sqlsetup and more information on automatic setup of db2 on the MN and SN below. For example:

~~~~
    chdef -t site -o clustersite databaseloc="/db2database"
~~~~


Then the xcatdb instance directory will be /db2database/db2

For more DB2 installation requirements check the DB2 documentation at&nbsp;:


http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.qb.server.doc/doc/r0025127.html

## Installation Steps

To uncompress the image, copy the tar file or files to a temporary file system containing at least 2 gigabytes of free space, here we used **/db2source.** We will use the default install path /opt/ibm/db2/V9.7 (linux) or /opt/IBM/db2/V9.7 (AIX) for the database, which also must contain 2 gigabytes of free space. In our example here our downloaded DB2 package names are for Linux, DB2_ESE_97_Linux_ipSeries.tar.gz; and for AIX,DB2_ESE_97_AIX.tar.gz. This will change over time. If you are using WorkGroup Edition or WorkGroup Resticted Edition the names of the tarballs will be different.


Untar the download package:

~~~~
    cd /db2source
~~~~


On Linux:

~~~~
    zcat DB2_ESE_97_Linux_ipSeries.tar.gz | tar -xvf-
~~~~


or

On AIX:

~~~~
    gunzip DB2_ESE_97_AIX.tar.gz
    tar -xvf DB2_ESE_97_AIX.tar
~~~~





**Additional software required:**

On Linux, make sure you have the libstdc++ and compat-libstdc++ libraries installed for **64 and 32** bit applications. If it is not installed you will get a warning on the DB2 install. Normally, it is installed with the OS, but we have notice in Redhat6 the 32 bit library may not be installed by default. Verify that the libraries are installed:

~~~~
    rpm -qa | grep libstdc  and rpm -qa | grep compat-libstdc
    libstdc++-4.4.4-13.el6.ppc64
    libstdc++-devel-4.4.4-13.el6.ppc64
    compat-libstdc++-33-3.2.3-69.el6.ppc
    compat-libstdc++-33-3.2.3-69.el6.ppc64
~~~~



If not installed, use your existing RedHat yum repository to install it:

~~~~
     yum install libstdc++.ppc
     yum install compat-libstdc++.ppc
~~~~





Linux IBM VAC compiler Runtime Environment

**If on Linux**,

you are going to need to install [IBM XL C/C++ Advanced Edition V9.0 for Linux Runtime Environment Component ](http://www-01.ibm.com/support/docview.wss?uid=swg24023990)for the Linux Distro, you are using. Note: the Redhat download can be used for Redhat ELS 5 or 6, the SLES download can be used for SLES 10 or 11. Save this download for the install on the Service Nodes later.

  * For Redhat5/6 ppc system, download the following:

~~~~
    vacpp.rte.90.rhel5.jun2009.update.tar into /db2source/vac9.0.
~~~~


  * We unzip and untar the software: zcat vacpp.rte.90.rhel5.*.update.tar.gz | tar -xvf-
  * Apply the updates, this installs the runtime libraries consisting of three RPMs - vacpp.rte, xlsmp.rte,and xlsmp.msg.rte.

~~~~
    cd /db2source/vac9.0
    rpm -Uvh *.rpm
~~~~





  * For our SLES 10/11 ppc system, download the following:

~~~~
    vacpp.rte.90.sles10.*.update.tar.gz into /db2source/vac9.0.
~~~~


  * We unzip and untar the software: zcat vacpp.rte.90.sles10.*.update.tar.gz | tar -xvf-
  * Apply the updates, this installs the runtime libraries consisting of three RPMs - vacpp.rte, xlsmp.rte,and xlsmp.msg.rte.

~~~~
    cd /db2source/vac9.0
    rpm -Uvh *.rpm
~~~~



**If on AIX**,


There are a few lpps that are needed for DB2 that may not normally be installed.

Base AIX LPPs bos.adt ( need bos.adt.libm, bos.adt.debug, bos.adt.prof,bos.adt.syscalls) bos.loc.com.utf, bos.loc.iso - (bos.loc.iso.en_US), bos.loc.utf.EN_US


AIX 6.1 TL4:

Minimum C++ runtime level requires the xlC.rte 9.0.0.8 and xlC.aix61.rte 9.0.0.8 (or later) filesets. These filesets are included in the June 2008 IBMÂ® C++ Runtime Environment Components for AIX package.


AIX 7.1

Minimum C++ runtime level requires the xlC.rte 11.1.0.0 and

xlC.aix61.rte 11.1.0.0 (or later) filesets.

These filesets are included in the

April 2010 IBM C++ Runtime Environment Componets for AIXV11.1 package.




### **Install DB2 on AIX or Linux MN**

~~~~
    cd /db2source/wse /db2source/ese /db2source/wser or /db2source/server  ( depends on the DB2 package)
    ./db2_install
~~~~


**You will be prompted with the following questions:**




    Default directory for installation of products - /opt/ibm/db2/V9.7
    Do you want to choose a different directory to install [yes/no] ?


    **Answer: no**





Specify one of the following keywords to install DB2 products.

    ESE   or  WSE       (Based on DB2 license)
    CLIENT
    RTCL


    **Answer: ESE**   (or **WSE** for WorkGroup Edition)



**Note: you may get a warnings about "SA MP Base Component cannot be installed or updated." As long as you get no more than a warning at the end such as the following: WARNING: A minor error occurred while installing "DB2 Enterprise Server Edition" on this computer. Some features may not function correctly, followed by post setup instructions, it is ok. **

**Another common minor error that you can ignore:**

A minor error occurred while installing "DB2 Workgroup Server Edition " on this computer. Some features may not function correctly.

For more information see the DB2 installation log at "/tmp/db2_install.log.13191".

In the log you will see the following: ****

    TSAMP_VERSION=3.2.1.1
    DBI1130E  The IBM Tivoli System Automation for Multiplatforms (SA MP)
         could not be installed or updated because system prerequisites
         were not met. See the log file /tmp/prereqSAM.log.8071 for details.****


### **Installing the DB2 License**

The DB2 license file can be found in the db2/license directory on the installation CD or inside the installation directory. If it is not there you have a trial copy and need to be provided a new license to use the product in production. Depending on the product you have, the file is named db2ese.lic (Enterprise Server Edition). After installing the license, the system is ready to start the database. If you loaded a trial copy, you will be able to use it for 90 days without a license. The license will not be present in the install.

Note: if the database is already running, after installing the license you will need to stop and start the database. See these two sections:

[Stopping_the_DB2_Server](Setting_Up_DB2_as_the_xCAT_DB/#stopping-the-db2-server)
[Starting_the_DB2_Server](Setting_Up_DB2_as_the_xCAT_DB/#starting-the-db2-server)

#### Power 775 Clusters

For Power 775 clusters, you will receive a DVD containing DB2 WorkGroup Edition database and restricted license for it. This should be used as your database. You will not need to download any other DB2 code. The following commands will accept the license and install the DB2 WorkGroup Edition key. After you have accepted the HPC license, you can continue with these instructions, using the DB2 code shipped on the DVD.




~~~~
     export IBM_DB2_HPC_LICENSE_ACCEPT=yes
~~~~


Put the DVD in the drive, then type the following commands. These instructions assumes a mount point of /mnt/cdrom.

~~~~
     mkdir -p /mnt/cdrom
     mount /dev/cdrom /mnt/cdrom
~~~~


Install all the rpms


For rhel6:

~~~~
    rpm -ihv /mnt/cdrom/rhel6//tmp/db2hpc/*.rpm
~~~~


For AIX7.1:

~~~~
    rpm -ihv /mnt/cdrom/aix71/*.rpm
~~~~


The DB2 key is installed at /opt/hpc/db2/key

~~~~
     ls -ltr /opt/hpc/db2/key/
     -rwx------. 1 root root 1012 May 21  2010 db2wse_os.lic
~~~~


#### For all installations

To install the DB2 key run the following command:


On Linux:

~~~~
    /opt/ibm/db2/V9.7/adm/db2licm -a <path to license key>
~~~~


On AIX:

~~~~
    /opt/IBM/db2/V9.7/adm/db2licm -a <path to license key>
~~~~


You should get:

~~~~
    DBI1402I License added successfully.
~~~~


You can check the license by running:

~~~~
    db2licm -l
~~~~


## Installation and Setup of DBD::DB2 Perl modules

### **perl-DBI**

DBI (DataBase Interface) module and DBD::DB2 (DataBase Driver) are required on the Management Node and Service Nodes for the xCAT code to interface with DB2. We will deal with the Service Nodes below.


Make sure perl-DBI is installed from the OS. Check by running:

~~~~
    rpm -qa | grep perl-DBI
~~~~


### **Install the Perl DBD::DB2 code**

The xCAT code uses the Perl DBD interface support for DB2.

If you are using the DB2 9.7.3 or later database on AIX 6.1 L or later, or Redhat 5 or Redhat 6. **You can obtain the perl-DBD-DB2 rpm supplied by xCAT from either the AIX xCAT deps package or the Linux xCAT deps package.** **Note: as of Oct 2010, the AIX deps package for xCAT will automatically install the perl-DBD-DB2 , and unixODBC-* when installed on the Management or Service Node.** Check if they have already been installed by xCAT.

~~~~
    rpm -qa | grep perl-DBD-DB2
~~~~






**For Linux, you should add the perl-DBD-DB2 rpm to otherpkgs from the Linux deps package, when installing the service node. Also add the IBM vac runtime environment rpm, see '**Linux IBM VAC compiler Runtime Environment'**. The unixODBC should be installed from the Linux OS rpm.**


If you can use the xCAT perl-DBD-DB2 rpms then install them. Otherwise, follow the instructions in Building Perl DBD::DB2 code and then go to Setting up the DB2 Server Instance.





For Redhat 6 after installing the perl-DBD-DB2 rpm do the following. If you plan to use the db2sqlsetup script, skip the next steps and go to [Setting_up_the_DB2_Server_Instance](Setting_Up_DB2_as_the_xCAT_DB/#setting-up-the-db2-server-instance). I highly recommend using the db2sqlsetup script, as documented in the next section.




~~~~
    vi /etc/ld.so.conf
~~~~


add the following line

~~~~
    /opt/ibm/db2/V9.7/lib64
~~~~


and run

~~~~
    ldconfig
~~~~


You will get the following warnings and can ignore them.

~~~~
    ldconfig: /opt/ibm/db2/V9.7/lib64/libdb2sqqg_wc.so is not an ELF file - it has the wrong magic bytes at the start.
    ldconfig: /opt/ibm/db2/V9.7/lib64/libdb2qgwcf.so is not an ELF file - it has the wrong magic bytes at the start.
    ldconfig: File /opt/ibm/db2/V9.7/lib64/libdb2lstcc.so is empty, not checked.
~~~~


## **Setting up the DB2 Server Instance**

### **Automatic Setup**

**It is highly recommended that you use the db2sqlsetup script, instead of following the manual process below, It is available in the xCAT 2.6 release and later. See man db2sqlsetup. The setup script will cover all the necessary steps for completing the process of setting up the Server and creating the xCAT database that are in the manual process below. **


To use the db2sqlsetup script to setup the Server Instance and bring up xCAT running on DB2, run the following command. You will be prompted for the instance password.

You must be in a writeable directory to run the command, because it will need to create a file to the current directory.



~~~~

    db2sqlsetup -i -S -V

~~~~


**in addition, if you have c,C++ applications such as LoadLeveler then setup the ODBC by running **




~~~~
    db2sqlsetup -o -S
~~~~


**Verify ODBC setup by running the following:**

On AIX, as root:

~~~~
    /usr/local/bin/isql -v xcatdb
~~~~


On Linux, as root:

~~~~
    /usr/bin/isql -v xcatdb
~~~~


#### **DB2 Database Backup/Restore**

At this point you should setup for DB2 backup and restore of the database. Go to the following section and follow the instructions and then return to this point to continue your setup. [Restore_the_database_with_DB2_Commands](Setting_Up_DB2_as_the_xCAT_DB/#backuprestore-the-database-with-db2-commands).

If you use db2sqlsetup, then at this point you can go to [Setting_up_the_DB2_Client_on_the_Service_Nodes](Setting_Up_DB2_as_the_xCAT_DB/#setting-up-the-db2-client-on-the-service-nodes).


On the DB2 Server, the Management Node&nbsp;:This section takes you through the creation of the the DB2 Server Instance. The Server Instance will be called xcatdb. For more information on what is an Instance and what part it plays in DB2, read the following [DB2 information](http://www.linuxdocs.org/HOWTOs/DB2-HOWTO/db2instance.html).

All of the following steps must be run logged into the Management Node as root.

### Manual setup

Stop if you used db2sqlsetup then you can go to [Setting_up_the_DB2_Client_on_the_Service_Nodes](Setting_Up_DB2_as_the_xCAT_DB/#setting-up-the-db2-client-on-the-service-nodes).




  * **Create the xCAT Instance ID**

On AIX:

~~~~
    mkgroup xcatdb
    mkuser pgrp='xcatdb' home='/var/lib/db2' shell='/bin/ksh' xcatdb
~~~~





On Linux:

~~~~
    groupadd xcatdb
    useradd -d /var/lib/db2 -g xcatdb -m -s /bin/bash xcatdb
~~~~


  * **Set the xcatdb password**

On AIX

~~~~
    chpasswd -c
    xcatdb:<passwd>
    ctl-D
~~~~


On Linux

~~~~
    chpasswd
    xcatdb:<passwd>
    ctl-D
~~~~


Note: we use the chpasswd command so the password will not have to be changed the first time we use the xcatdb userid.

  * **Add the following entry into /etc/services**

Edit the /etc/services file and add the following (suggestion: insert above the references section)




~~~~
    DB2_xcatdb 60000/tcp
    DB2_xcatdb_1 60001/tcp
    DB2_xcatdb_2 60002/tcp
    DB2_xcatdb_END 60003/tcp
    db2c_xcatdb 50001/tcp # Port for server connection
~~~~





  * **Create the DB2 Server Instance**

Note: you will need available space in /var/lib/db2 is 465348KB, for this to complete.

To create the xCAT DB2 Server Instance run the following as root:


on Linux

~~~~
    /opt/ibm/db2/V9.7/instance/db2icrt -a server -p db2c_xcatdb  -u xcatdb xcatdb
~~~~


on AIX




~~~~
    /opt/IBM/db2/V9.7/instance/db2icrt **-a server -p**db2c_xcatdb ** -u** xcatdb xcatdb
~~~~


  * **Modify the DB2 Server Instance**

As root:

~~~~
    cd /opt/ibm/db2/V9.7/instance on Linux


    cd /opt/IBM/db2/V9.7/instance on AIX
~~~~


~~~~
    ./db2iset -g DB2_PARALLEL_IO=*
    ./db2iset -g DB2AUTOSTART=yes
    ./db2iset -g DB2_STRIPED_CONTAINERS=ON
~~~~





~~~~
    su - xcatdb
    export EXTSHM=ON
    db2set DB2ENVLIST=EXTSHM


     db2set -all
    [e] DB2LIBPATH=/var/lib/db2/sqllib/java/jdk64/jre/lib/ppc64
    [i] DB2ENVLIST=EXTSHM
    [i] DB2COMM=tcpip
    [i] DB2AUTOSTART=YES
    [g] DB2FCMCOMM=TCPIP4
    [g] DB2_STRIPED_CONTAINERS=ON
    [g] DB2SYSTEM=c68m4mn11.ppd.pok.ibm.com
    [g] DB2INSTDEF=xcatdb
    [g] DB2_PARALLEL_IO=*
    [g] DB2AUTOSTART=yes

~~~~




  * **Extend the number of shared memory segments allowed.**

Add the following line to /var/lib/db2/sqllib/db2profile. Note this is the default directory for the xcatdb instance, you may have changed that with site.databaseloc. Note: you will need to add this export for all ID's that access the database.

~~~~
    EXTSHM=ON
    export EXTSHM
~~~~


  * **Set the db2 environment variables for root**

For AIX as root:

~~~~
    vi /etc/profile
~~~~


add the following lines:

~~~~
    export DB2INSTANCE=xcatdb
    export EXTSHM=ON
~~~~





**Note: Be sure you have done the following from above:**

~~~~
    su - xcatdb


    export EXTSHM=ON
    db2set DB2ENVLIST=EXTSHM

~~~~


For Linux as root:

~~~~
    cd /etc/profile.d
    vi xcatdb2.sh
~~~~


add the following line:

~~~~
    export DB2INSTANCE=xcatdb
    export EXTSHM=ON
~~~~


then

~~~~
    chmod 0755 xcatdb2.sh

~~~~




~~~~
    vi xcatdb2.csh
~~~~


add the following line:

~~~~
    setenv DB2INSTANCE "xcatdb"
    setenv EXTSHM "ON"
~~~~


then chmod 0755 xcatdb2.csh




Note: either logout and back in or set the environment variable manually for root:

~~~~
    export DB2INSTANCE=xcatdb
~~~~


#### Start the DB2 Server

To start the server, you must logon as the xcatd instance id, create previously.




~~~~
    su - xcatdb


    xcatdb@c76a3l4vp01:~> db2start
    01/27/2010 19:48:08 0 0 SQL1063N DB2START processing was successful.
    SQL1063N DB2START processing was successful.
~~~~



If you need to stop the database, use

~~~~
    xcatdb@c76a3l4vp01:~> db2stop

~~~~

or

~~~~
    xcatdb@c76a3l4vp01:~> db2stop force

~~~~




#### **Increasing processor entitlement**

After the database is started, you might want to increase the processor

entitlement for DB2. Check the section [Increasing processor entitlement](http://www.redbooks.ibm.com/redbooks/pdfs/sg247352.pdf) for information on customizing your system.

#### Setup Database Manager

We will update the DBM (Database Manager) with our configuration parameters




~~~~
    su - xcatdb

~~~~


In your xCAT install /opt/xcat/share/xcat/tools/updateDBM.sql , is a script that you can run to set the needed parmeters. Run the following:




~~~~
    db2 -tvf'/opt/xcat/share/xcat/tools/updateDBM.sql'

~~~~

Note: as of xCAT 2.8 or later it is

~~~~
    db2 -tvf'/opt/xcat/share/xcat/scripts/updateDBM.sql'
~~~~


#### Create the xCAT Database

We will create one database xcatdb, it will be store in the xcatdb Instance home directory which is /var/lib/db2.

~~~~
    su - xcatdb
~~~~


In your xCAT install /opt/xcat/share/xcat/tools/createdb.sql, is a script that you can run to create the xcatdb database. Run the following:

**Note: if you are not using the default /var/lib/db2 path for you database instance, you will have to edit the createdb.sql script and change that path to the path you have for site.databaseloc before running the script below.**

~~~~
    db2 -tvf'/opt/xcat/share/xcat/tools/createdb.sql'
~~~~


Note as of xCAT 2.8 or later:

~~~~
    db2 -tvf'/opt/xcat/share/xcat/scripts/createdb.sql'
~~~~


Note: be patient, it takes a while. You may also investigate the default attributes of the database that we chose in this setup scripts and change according to your system needs.

#### **Restart the Instance to Apply the Changes**

~~~~
    su - xcatdb ( if not already there)
    db2 connect reset
    db2 force applications all; db2 terminate;
    db2stop or db2stop force
    db2start
    db2iauto -on xcatdb
    exit
~~~~


#### **Restart the Instance on Reboot of the Server**

As Root:

On AIX:

~~~~
    /opt/IBM/db2/V9.7/bin/db2iauto -on xcatdb
~~~~


On Linux:

~~~~
    /opt/ibm/db2/V9.7/bin/db2iauto -on xcatdb
~~~~


##### **Special instructions for Reboot of EMS on AIX **

**On AIX** after reboot of the EMS, the ISNM, TEAL software will not automatically start, and LoadLeveler will fail to start when initiated. In fact, any 32 bit application that uses the DB2 database will have problems connecting to the database. This is a DB2 APAR, and the problem will be fixed when V9.7.5 fix pack is available and applied. To restart the ISNM, Loadleveler.TEAL software after reboot, you must first:

stop the xcatd daemon

~~~~
    stopsrc -s xcatd
~~~~


If Loadleveler is running, stop the daemon

~~~~
    llctl stop
~~~~


If ISNM is running, stop the daemon

~~~~
    chnwm -d
~~~~


If TEAL is running, stop the daemon:

~~~~
    stopsrc -s teal
~~~~


Stop and start the database

~~~~
    su -xcatdb
    db2stop force
    db2start
    exit
~~~~


As root, start the daemons:

Start xcat:

~~~~
    startsrc -s xcatd
~~~~


Start Loadleveler

~~~~
    llctl start
~~~~


Start ISNM

~~~~
    chnwm -a
~~~~


Start TEAL:

~~~~
    startsrc -s teal
~~~~


#### Work around for Linux non-support of /etc/inittab

Later releases of Linux (e.g. Redhat 6) no longer support the use of /etc/inittab for bringing up processes on reboot. The xCAT 2.6 db2sqlsetup script has been modified to work-around this DB2 problem until DB2 supplies a 9.7 PTF that fixes the problem. The current 9.7.0.4 release of DB2 support Redhat6 does not fix the problem.

To manually fix the problem, if you are running xCAT 2.6 do the following:

On the Management Server

~~~~
    cp /opt/xcat/share/xcat/tools/xcatfmcd.conf  /etc/init/xcatfmcd.conf
~~~~


Note as of xCAT 2.8 or later:

~~~~
    cp /opt/xcat/share/xcat/scripts/xcatfmcd.conf  /etc/init/xcatfmcd.conf
~~~~



Then, add the lines to sysctl.conf

~~~~
    vi /etc/sysctl.conf


    # added for by xCAT
    kernel.shmmax = 268435456
~~~~


~~~~
    vi /etc/inittab
~~~~


remove the following line:

~~~~
    fmc:2345:respawn:/opt/ibm/db2/V9.7/bin/db2fmcd #DB2 Fault Monitor Coordinator
~~~~


#### **Manually restart DB2 after reboot**

If the DB2 database instance xcatdb does not automatically restart after reboot, you will find that the xcatd daemon is not running and cannot be started without getting database access errors. To manually restart the DB2 instance and xcatd, do the following:

~~~~
    ps -ef | grep db2fmcd
~~~~


If it is not running then, start the DB2 Monitoring daemon:

~~~~
    /opt/ibm/db2/V9.7/bin/db2fmcd &
~~~~


Next start the xcatdb instance:

~~~~
    su - xcatdb
    db2start xcatdb
~~~~


Next start the xcatd daemon

On AIX:

~~~~
    restartxcatd
~~~~


On Linux

~~~~
    service xcatd restart
~~~~


#### Migrate xCAT data to DB2

**If you are using the db2sqlsetup script , this section will automatically be done for you. See man db2sqlsetup. And you can go to Test the database.** ****

You must backup your xCAT data before populating the DB2 database. There are required default entries that were created in the SQLite database when the xCAT RPMs were installed on the Management Node, and they must be migrated to the new DB2 database.

~~~~
    mkdir -p ~/xcat-dbback
    dumpxCATdb -p ~/xcat-dbback
~~~~


Note: if you get an error, like Connection failure: IO::Socket::SSL: connect:

Connection refused at...., make sure your xcatd daemon is running.


**Creating the /etc/xcat/cfgloc file** tells xcat what database to use. If the file does not exists, it uses by default SQLite, which is setup during the xCAT install by default. The information you put in the files, corresponds to the information you setup when you configured the database.

Create a file called /etc/xcat/cfgloc and populate it with the following line:

~~~~
    DB2:xcatdb|xcatdb|ppslab09
~~~~


where the format is:

~~~~
    DB2:<databasename>|<instancename>|<instancepassword>
~~~~



The first variable is the database name xcatdb that was setup. The second variable is the name of the Instance. The password must match the password of your DB2 Instance xcatdb userid.


Finally change permissions on the file, so only root can read, to protect the password.

~~~~
    chmod 0600 /etc/xcat/cfgloc
~~~~



Stop the xcatd daemon, so no database actions will occur while you are migrating the data to DB2.

On AIX:

~~~~
    stopsrc -s xcatd
~~~~


On Linux:

~~~~
    service xcatd stop
~~~~


Restore your database to DB2. Use bypass mode to run the command because the daemon is no longer running. This can take a while.

~~~~
    XCATBYPASS=1 restorexCATdb -p ~/xcat-dbback
~~~~


Note: If you still have errors that you can not resolve, you can go back to using SQlite, by moving /etc/xcat/cfgloc to /etc/xcat/cfgloc.save and restarting xcatd.


Start the xcatd daemon using the DB2 database.

On AIX:

~~~~
    startsrc -s xcatd
~~~~


On Linux:

~~~~
    service xcatd restart
~~~~



**Test the database**

~~~~
    tabdump site
~~~~


#### Setup reorg DB2 Tables cron job (xCAT 2.6.6)

On the Management Node:

~~~~
    crontab -e


Add this line

    0 0 * * 0 /opt/xcat/share/xcat/tools/reorgtbls

~~~~

## Setting up the DB2 Client on the Service Nodes

### **Installing the DB2 Client software on the SN**

Now that the DB2 database is setup on the Management node , if you have not done so, install xCAT on the Service Node.

Use the following references for setting up to install xCAT on your Service Nodes:

  * [Setting_Up_a_Linux_Hierarchical_Cluster]
  * [Setting_Up_an_AIX_Hierarchical_Cluster]

### **Automatic install of DB2 and Client setup on SN **

The automatic install and setup of DB2 on the service nodes is available in xCAT 2.6 or later.

As of xCAT Release 2.6, the unixODBC and perl-DBD-DB2 rpm will be automatically installed with the AIX xCAT deps package on the Service Node when you installed xCAT. For AIX, you must ensure during install the file systems are allocated enough space to install the DB2 Client on the Service Node. See the following documentation: [Setting_Up_an_AIX_Hierarchical_Cluster/#create-an-image_data-resource-optional](Setting_Up_an_AIX_Hierarchical_Cluster/#create-an-image_data-resource-optional).

For Linux, you should add the perl-DBD-DB2 rpm to otherpkgs from the Linux deps package, when installing the service node. Also add the IBM vac runtime environment rpm, see Linux IBM VAC compiler Runtime Environment. The unixODBC should be installed from the Linux OS rpm. For example for Redhat , your /install/post/otherpkgs/rhels6/ppc64/rpms.list file for otherpkgs should contain:

~~~~
    linuxextras/perl-DBD-DB2-1-1.ppc64.rpm
    linuxextras/vacpp.rte-9.0.0-6.ppc64.rpm
    linuxextras/xlsmp.msg.rte-1.7.0-6.ppc64.rpm
    linuxextras/xlsmp.rte-1.7.0-6.ppc64.rpm
~~~~


where the rpms are in the /install/post/otherpkgs/rhels6/ppc64/linuxextras directory

The /install/custom/install/rh/service.rhels6.ppc64.otherpkgs.pkglist file should have the rpms added to the list, for example:

~~~~
    xcat/xcat-core/xCATsn
    xcat/xcat-dep/rh6/ppc64/conserver
    xcat/xcat-dep/rh6/ppc64/perl-Net-Telnet
    xcat/xcat-dep/rh6/ppc64/perl-Expect
    xcat/xcat-dep/rh6/ppc64/atftp-xcat
    vacpp.rte
    xlsmp.rte
    xlsmp.msg.rte
    perl-DBD-DB2
    pam-1.1.1-4.el6.ppc64
    pam-1.1.1-4.el6.ppc
    unixODBC-2.2.14-11.el6.ppc64
    unixODBC-2.2.14-11.el6.ppc
    openssl-1.0.0-4.el6.ppc64
    openssl-1.0.0-4.el6.ppc
~~~~


For detailed description of setting up otherpkgs, refer to: [Using_Updatenode].


As of xCAT2.6 , we have additionally added the automatic install and configuration of the DB2 client and ODBC on the service nodes following this process:

#### **Give access to the DB2 code to the Service Node during install or update**

The site.db2installloc attribute must point to a directory that can be mounted by the ServiceNode that contains the DB2 ESE 9.7.0.x code extracted.

The DB2 tarball should be extracted into a read/mountable directory on either the Management Node or some server that can be mounted by the Service Node after it is installed when running the post install scripts. The location will be put in a site attribute called db2installloc. For example,

~~~~
    site.db2installloc = /mntdb2 , if on the Management Node
~~~~


~~~~
    site.db2installloc = servername:/mntdb2 , if on some other server
~~~~


In either case, the db2 code will be extracted and placed in /mntdb2

The /mntdb2 directory will look something like this, where ese or server is the top directory containing all the db2 install code.

~~~~
    ls /mntdb2
~~~~

    ese or server or wser



Add this directory to /etc/exports and run exportfs -a.

~~~~
     /mntdb2 -vers=3,sec=sys:krb5p:krb5i:krb5:dh,rw
~~~~


If site.useNFSv4onAIX is to yes in your AIX cluster, it means that NFSv4 is being used for AIX nodes provisioning, you should export the /mntdb2 as NFSv4:

~~~~
     /mntdb2 -vers=4,sec=sys:krb5p:krb5i:krb5:dh,rw
~~~~


**In xCAT 2.6**, To automatically install DB2, Configure the Client and setup the ODBC, modify your postscripts table servicenode entry as follows to run the db2install and odbcsetup scripts. **Note: the install and setup of DB2 takes several minutes. You may be able to ssh to the service node before the setup is complete. Give it at least 10 minutes after the service node install complete before trying to use the database from the service node.** ****


On Linux, the scripts are postbootscripts:

~~~~
    node,postscripts,postbootscripts,comments,disable
    "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,
    "service","servicenode,xcatserver,xcatclient","db2install,odbcsetup",,
~~~~


As of xCAT 2.7, only the servicenode is needed for Linux in the postscripts table. xcatserver and xcatclient are called by servicenode. So your table would look like the following:

node,postscripts,postbootscripts,comments,disable

~~~~
    "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,
    "service","servicenode","db2install,odbcsetup",,
~~~~



On AIX, the scripts must be added before and after the servicenode script. Note: on older installs this script (servicenode) may be a postscript, on newer installs it is a postbootscript. Here it is a postbootscript. Either will work because currently AIX treats postscripts and postbootscripts the same. Note: As of xCAT 2.8, the aixremoteshell postscript will be the remoteshell postscript for both AIX and Linux. The remoteshell postscript will call the aixremoteshell on AIX nodes.

~~~~
    node,postscripts,postbootscripts,comments,disable
    "xcatdefaults","syslog,aixremoteshell,syncfiles",,,
    "service",,"**db2install**,servicenode,**odbcsetup**",,,
~~~~


### **Automatic Install of DB2 and Client setup on an installed Service Node**

If your service node is already installed, then to install the DB2 code and setup the DB2 client, you need to first follow the instructions as if installing the SN, in the section [Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn](Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn).

Then run the following command from the Management Node

~~~~
     updatenode <servicenode> -P
~~~~


### **Manual install of DB2 and Client setup on the SN**

If you did not use the automatic setup process detailed in [Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn](Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn),

you need to install the DB2 client manually. Otherwise, just go to [Test_the_Database_Connection](Setting_Up_DB2_as_the_xCAT_DB/#test-the-database-connection).

Follow the instructions in Install DB2 on the Management Node, to install the DB2 code on your Service Node ( SN). Follow the below instructions for running the db2_install command. You are only going to install the Client on the SN. Note you probably do not have to download the DB2 code again, if you have saved the downloads from the Server install.


Note: the disk space needed as documented in 4Disk space needed to install DB2 .




Install DB2:

~~~~
    cd /db2source/ese  or /db2source/server  or /db2source/wse or /db2source/wser ( depending on your DB2 package)
    ./db2_install
~~~~



**You will be prompted with the following questions:**


Default directory for installation of products - /opt/ibm/db2/V9.7


Do you want to choose a different directory to install [yes/no] ?

    **Answer: no**





Specify one of the following keywords to install DB2 products.

    ESE or  WSE       (Based on DB2 license)
    CLIENT
    RTCL





    **Answer: CLIENT**






Manual Installation and Setup of DBD::DB2 Perl modules on the SN


If you are using the Database level that is documented here on AIX 6.1 L or later, Redhat 5 or Redhat 6. **You can obtain the perl-DBD-DB2 rpm supplied by xCAT from either the AIX xCAT deps package or the Linux xCAT deps package** and skip this section and go to Manually creating the Client Instance on the Service Node.

**Note: xCAT 2.6 , the deps package for xCAT will automatically install the perl-DBD-DB2 , and unixODBC-* when installed on the Management or Service Nodes. You may find these already installed. **

**You can check if they are installed, by running rpm -qa | grep DB2.**


As you did on the Management Node (MN), the Perl DB2 DBD will have to be installed on all Service nodes. If your Service Nodes are at the same OS level as your Management node, you can mount the directory from the MN to the Service Node and just run the install. Note: extra instructions for updating /etc/ld.so.conf for Redhat 6 in Installation and Setup of DBD::DB2 Perl modules.


For installing the DBD:DB2 DBI from a mount:

On the MN:

~~~~
    export ~/DBD read-only
~~~~


On the SN:

~~~~
    mkdir /mnt2
    mount xx.xxx.xxx.xxx:~/DBD /mnt2
    cd /mnt2/DBD-DB2-1.78
    make test ( if no errors continue with the make install)
    make install
    unmount or umount /mn2
~~~~


For installing the DBD:DB2 DBI from the source code:

Follow the instructions in Installation and Setup of DBD::DB2 Perl modules.




#### **Creating the Client Instance on the Service Node**

**You can choose to use the db2sqlsetup script, instead of following the below manual process. It is available in the xCAT 2.6 release. See man db2sqlsetup. It will automatically setup the client. **


To use the db2sqlsetup command to create the client instance. First if you have changed the default xcatdb instance path from /var/lib/db2, to another files system by changing the site.databaseloc attribute, then

~~~~
    export DATABASELOC=<site.databaseloc>  where  DATABASELOC is exported to the value in
    the site table databaseloc attribute.
~~~~


Then run

~~~~
    db2sqlsetup -i -C -V
~~~~


You will be prompted for the instance password and address of the DB2 server that this node can access. The instance password must match what was assigned on the DB2 server to the instance. Normally, the address is the value in site.master on the Management Node, if you DB2 server is on the Management Node.


After you finish running the script to setup the client, you can proceed to [Test_the_Database_Connection_](Setting_Up_DB2_as_the_xCAT_DB/#test-the-database-connection).


**If you do not use the db2sqlsetup script:** **** This section takes you through the creation of the the DB2 Client Instance on the Service Node. The Client Instance will be called xcatdb.

For more information on what is an Instance and what part it plays in DB2, read the following [DB2 information](http://www.linuxdocs.org/HOWTOs/DB2-HOWTO/db2instance.html).




All of the following steps must be run logged into the Service Node as root.


Create a xcatdb user id and group for the DB2 client instance. In our example, the home directory for the instance will be the default /var/lib/db2.

As of xCAT 2.6 you could have changed that default using by setting the site.databaseloc attribute. I you have done that in the example below /var/lib/db2 should be changed to the value of site.databaseloc/db2. For example if site.databaseloc is /db2database then /var/lib/db2 should be changed to /db2database/db2.


On AIX:

~~~~
    mkgroup xcatdb
    mkuser pgrp='xcatdb' home='/var/lib/db2' shell='/bin/ksh' xcatdb
~~~~


On Linux:

~~~~
    groupadd xcatdb
    useradd -d /var/lib/db2 -g xcatdb -m -s /bin/bash xcatdb
~~~~


Set the xcatdb password

On AIX

~~~~
    chpasswd -c
    xcatdb:<passwd>
    ctl-D

~~~~

On Linux

~~~~
    chpasswd
    xcatdb:<passwd>
    ctl-D
~~~~


Note: we use the chpasswd command so the password will not have to be changed the first time we use the xcatdb userid.

    **Add the following entry into /etc/services on the Service Node**


Edit the /etc/services file and add the following (suggestion: insert above the references section)

note this must match what is in /etc/services on the Management/DB2 Server. Again make sure matching port is not used on both machines.




~~~~
    db2c_xcatdb 50001/tcp # Port for DB2 Server Connect
~~~~





Create the DB2 Client Instance

To create the xCAT DB2 Client Instance run the following:


**On Linux:**

~~~~
    /opt/ibm/db2/V9.7/instance/db2icrt -s client xcatdb
~~~~


**On AIX:**

~~~~
    /opt/IBM/db2/V9.7/instance/db2icrt -s client xcatdb
~~~~


Update the Client Instance

~~~~
    su - xcatdb
    export EXTSHM=ON
    db2set DB2ENVLIST=EXTSHM
~~~~



Extend the number of shared memory segments allowed.

Add the following line to /var/lib/db2/sqllib/db2profile Note: you will need to add this export for all ID's that access the database.

~~~~
    EXTSHM=ON
    export EXTSHM
~~~~


Set the db2 environment variables for root

For AIX as root:

~~~~
    vi /etc/profile
~~~~


add the following lines:

~~~~
    export DB2INSTANCE=xcatdb
    export EXTSHM=ON
~~~~





For Linux as root:

~~~~
    cd /etc/profile.d
    vi xcat.sh

~~~~

add the following line:

~~~~
    export DB2INSTANCE=xcatdb
    export EXTSHM=ON
~~~~





~~~~
    vi xcat.csh
~~~~


add the following line:

~~~~
    setenv DB2INSTANCE "xcatdb"
    setenv EXTSHM "ON"
~~~~



Note: either logout and back in or set the environment variable manually for root:

~~~~
    export DB2INSTANCE=xcatdb; export EXTSHM=ON
~~~~



Manually creating the catalog of the DB2 Server Node on the Service Node


Now we will setup the Client on the Service Node to access the database on the Management Node (mn) using xcatdb instance on the Service Node:







~~~~
    su - xcatdb

    db2 catalog tcpip node mn remote 9.114.113.203 server db2c_xcatdb
~~~~


note: port must match what is in /etc/services

~~~~
    db2 terminate ( refreshes cache)
~~~~



to check run db2 list node directory:




~~~~
    db2 list node directory

    Node Directory
    Number of entries in the directory = 1
    Node 1 entry:
    Node name = MN
    Comment =
    Directory entry type = LOCAL
    Protocol = TCPIP
    Hostname = 9.114.113.203
    Service name = db2c_xcatdb
~~~~






**Note: 9.114.113.203 must be an address or resolvable hostname that the Service Node can access the Management Node. **





Manually Catalog the Server Instance Database on the Service Node

Next on the Service Node, we will catalog the xcatdb database and it's location on the mn.







~~~~
    su - xcatdb ( if not already there)
    db2 catalog db xcatdb as xcatdb at node mn
    db2 terminate ( refreshes cache)
~~~~



For more information: See http://publib.boulder.ibm.com/infocenter/db2luw/v8/index.jsp?topic=/com.ibm.db2.udb.doc/core/r0001944.htm

### **Test the Database Connection**

~~~~
    su - xcatdb (if not already there)
    db2 connect to xcatdb user xcatdb
~~~~



You will be prompted for xcatdb's password. After entering it you should see something similar to this:




~~~~
    Database Connection Information Database server = DB2/LINUXPPC64 9.7.1
    SQL authorization ID = XCATDB
    Local database alias = XCATDB
~~~~


Close the connection with:

~~~~
    db2 connect reset
    exit
~~~~


### Start the xCAT daemon

If the service node has xCAT installed, you can not start the xcatd daemon

On AIX:

~~~~
    restartxcatd
~~~~


On Linux:

~~~~
    service xcatd start
~~~~


## **Adding ODBC support**

You only need to follow the steps in this section on adding ODBCsupport, if you plan to develop C, C++ database applications on the database or run such applications (like LoadLeveler) using the Database. Otherwise skip this section.




More information about the IBM DB2 Driver for ODBC and CLI is found in

http://publib.boulder.ibm.com/infocenter/db2luw/v9/index.jsp?topic=/com.ibm.db2.udb.apdv.cli.doc/doc/c0023378.htm

### Setup the ODBC on the Management Node (DB2 Server)

**On AIX**: You need the unixODBC rpm  that is

included in the dep-aix-xxxx.tar.gz file. The dep-aix-xxx.tar.gz file was download when the xCAT Management Node was installed with xCAT. If the rpm is not already installed then, go to the directory where the gz file was untared and use the following command:




~~~~
    rpm -i unixODBC-*
~~~~


**On Linux**: The unixODBC package comes as part of the OS and should already be installed.

    Note:For RHEL 6 (ppc64):  You will need to install both the pam-1.1.1-4.el6.ppc64 and the
    pam-1.1.1-4.el6.ppc  packages.  You will then need to install both
    unixODBC-2.2.14-11.el6.ppc64 and unixODBC-2.2.14-11.el6.ppc rpms, in that order.
    Some files such as isql, odbc_config, and odbcinst, will be overwritten by the second install.
    You will also need  openssl-1.0.0-4.el6.ppc (32-bit) and openssl-1.0.0-4.el6.ppc64 (64-bit) .



#### **Using db2sqlsetup to setup the ODBC**

**As of xCAT 2.6 or later, you can use db2sqlsetup command in xCAT to perform the ODBC setup operations below. See manpage for db2sqlsetup. **


To setup the ODBC on the MN using db2sqlsetup, run the following command. You must be in a writeable directory to run the command, because it will need to create a file to the current directory.

~~~~
    db2sqlsetup -o -S -V
~~~~



After using the db2sqlsetup script you can move on to Setup ODBC on the Service Nodes. Go to [Setup_ODBC_on_the_Service_Nodes](Setting_Up_DB2_as_the_xCAT_DB/#setup-odbc-on-the-service-nodes).

#### **Setup the ODBC manually**

To configure ODBC, you need to make changes to the **odbcinst.ini**, **odbc.ini**, and **db2cli.ini** files, so that ODBC works with the xCAT database.

**On AIX**:

When a new a new DB2 instance is created on AIX, DB2 places a copy of the ODBC DB2 driver into the database instance directory: &lt;DB2INSTANCE_HOME&gt;/sqllib/lib/libdb2.a, where in our process &lt;DB2INSTANCE_HOME&gt; is /var/lib/db2.

The unixODBC Driver Manager loads the DB2 Driver dynamically so the shared object must be extracted from the driver. To do this use the following commands:

~~~~
    cd /var/lib/db2/sqllib/lib
    ar -x libdb2.a
~~~~



This produces a shr.o. Rename this file to libdb2.so.

~~~~
    mv shr.o libdb2.so
~~~~





**On Linux**: The unixODBC package come as part of the distro. Make sure it is installed with the OS.

~~~~
    rpm -i unixODBC-*
~~~~


For RHEL 6 (ppc64): You need to install both unixODBC-2.2.14-11.el6.ppc64 and unixODBC-2.2.14-11.el6.ppc rpms, in that order. Some files such as isql, odbc_config, and odbcinst, will be overwritten by the second install.

##### **Update the odbcinst.ini file**

As of 2.6, the below directory to the xcatd instance of /var/lib/db2 can be configured by setting the site.databaseloc attribute. This example assumes the default of /var/lib/db2. If you have changed the path, for example site.databaseloc is /db2database, the you should substitute /db2database/db2 for /var/lib/db2 in the example below.

First update the odbcinst.ini file with the correct driver name.


**On AIX:**


For the Driver, enter the path name of the shared object you created:



~~~~

    vi /etc/odbcinst.ini


    [DB2]
    Description = DB2 Driver
    Driver = /var/lib/db2/sqllib/lib/libdb2.so
    FileUsage = 1
    DontDLClose = 1
    Threading = 0

~~~~


**On RHEL:** ****

For the Driver, enter the path name of the shared object from the OS:




~~~~
    vi /etc/odbcinst.ini


    [DB2]
    Description = DB2 Driver
    Driver = /var/lib/db2/sqllib/lib32/libdb2.so
    Driver64 = /var/lib/db2/sqllib/lib/libdb2o.so
    FileUsage = 1
    DontDLClose = 1
    Threading = 0

~~~~


**On SLES:** (TBD, if supported)




~~~~
    vi /etc/unixODBC/odbcinst.ini


    [DB2]
    Description = DB2 Driver
    Driver = /var/lib/db2/sqllib/lib32/libdb2.so
    Driver64 = /var/lib/db2/sqllib/lib/libdb2o.so
    FileUsage = 1
    DontDLClose = 1
    Threading = 0

~~~~

##### **Update the odbc.ini file**

Then update the obdc.ini files with the DSN information for ODBC. Use

DATABASE instance name and database as defined in the /etc/xcat/cfgloc file. In our process they are the same.




**On AIX and Redhat**:

~~~~
    vi /etc/odbc.ini


    [xcatdb]
    Driver = DB2
    DATABASE = xcatdb
~~~~



**On SLES** ( If supported)

~~~~
    vi /etc/unixODBC/odbc.ini


    [xcatdb]
    Driver = DB2
    DATABASE = xcatdb

~~~~

##### **Update the db2cli.ini file**

~~~~
    su - xcatdb
    db2 update cli cfg for section xcatdb using uid xcatdb
    DB20000I  The UPDATE CLI CONFIGURATION command completed successfully.
    db2 update cli cfg for section xcatdb using pwd ppslab09
    DB20000I  The UPDATE CLI CONFIGURATION command completed successfully.
    exit

~~~~


As root:

~~~~
    chmod 0600 /var/lib/db2/sqllib/cfg/db2cli.ini
    cp /var/lib/db2/sqllib/cfg/db2cli.ini ~root/db2cli.ini
~~~~


### **Setup ODBC on the Service Nodes**

**Skip this step, if there are no service nodes in the cluster.**

Now that the DB2 database is setup, if you have not done so, install xCAT on the Service Node. As of xCAT release 2.6 you can also automatically install and setup DB2 on your service nodes during the xCAT Service Node install process by adding two postscripts (db2install and odbcsetup) to you service node postscript list.

Use the following references for setting up your Service Nodes:

  * [Setting up Hierarchy in xCAT ](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2SetupHierarchy.pdf)
  * [Setting up an AIX Hierarchical Cluster](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2onAIXServiceNodes.pdf)

#### **Setting up the ODBC on the Service Nodes Automatically**

**In xCAT 2.6**, you can automatically setup the ODBC on the servicenodes during the install by following the instructions in the following section: [Automatic_install_of_DB2_and_Client_setup_on_SN](Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-an-installed-service-node).

#### **Setting up the ODBC on the Service Nodes Manually**

**If you are not at 2.6, then you will need to manually setup the DB2 client and ODBC on the Service Nodes, following these instructions:**

**You may need to manually install the **unixODBC and the perl-DBD-DB2 driver on the Service nodes and modify the ODBC configuration files just as we did during the Management Node setup . To do this, you should have already installed and setup the DB2 Client code on the Service Nodes as documented in Setting up the DB2 Client on the Service Nodes.

Install the DB2 driver into the same directory as on the management node, so the odbcinst.ini file can be the same on the management and service nodes..


xCAT has utilities to install additional software on the nodes. To install ODBC on to the service nodes, refer to the following documents for details:


AIX: [Updating_AIX_Software_on_xCAT_Nodes]


Linux: [Using_Updatenode]

If the Service Node (SN) is already installed with xCAT 2.6+, you can use the db2sqlsetup script to setup your service nodes , instead of the following manual steps below to copy the ODBC configuration files from the Management Node. ****

To setup the ODBC on the SN using db2sqlsetup, run the following command. You must be in a writeable directory to run the command, because it will need to create a file to the current directory.

As of xCAT2.6 you do not have to use the default /var/lib/db2 for your xcatdb instance directory. You can set the site.databaseloc attribute to a file system and that will become the location where the db2sqlsetup script will create the db2 instance directory. If you have done this, then if the value in site.databaseloc is /db2database:

~~~~
    export DATABASELOC="/db2database/db2"
~~~~


~~~~
    db2sqlsetup -o -C -V
~~~~



If you use the db2sqlsetup routine on the Service Node, you can go to [Setting_Up_DB2_as_the_xCAT_DB/#Verify_DB2_setup](Setting_Up_DB2_as_the_xCAT_DB/#Verify_DB2_setup)

To setup the ODBC configuration files manually on the Service Nodes, just sync the files from the Management Node to the service nodes from the ones previously setup on the Management Node.

The **service** in the following command is the node group name for all the service nodes.

From the MN:

On AIX:

~~~~
    xdcp service -v /etc/odbcinst.ini /etc/odbcinst.ini
    xdcp service -v /etc/odbc.ini /etc/odbc.ini
~~~~



On RH and Fedora:

~~~~
    xdcp service -v /etc/odbcinst.ini /etc/odbcinst.ini
    xdcp service -v /etc/odbc.ini /etc/odbc.ini
~~~~



On SLES ( not yet supported)

~~~~
    xdcp service -v /etc/unixODBC/odbcinst.ini /etc/odbcinst.ini
    xdcp service -v /etc/unixODBC/odbc.ini /etc/odbc.ini
~~~~




You will have to setup one additional file on the Service Node(client) to setup&nbsp;:

Note: whether the path is /var/lib/db2 depends if you have set the site.databaseloc attribute.

If /var/lib/db2/sqllib/cfg/db2cli.ini exists then

~~~~
    cp /var/lib/db2/sqllib/cfg/db2cli.ini /var/lib/db2/sqllib/cfg/db2cli.ini.org
~~~~



then whether it exists or not

**From the MN:**

~~~~
    xdcp service -v /var/lib/db2/sqllib/cfg/db2cli.ini /var/lib/db2/sqllib/cfg/db2cli.ini
    xdcp service -v /var/lib/db2/sqllib/cfg/db2cli.ini ~root/db2cli.ini
~~~~


**Then on the SN:**

~~~~
    chown xcatdb /var/lib/db2/sqllib/cfg/db2cli.ini
    chmod 0600 /var/lib/db2/sqllib/cfg/db2cli.ini
    chmod 0600 ~root/db2cli.ini

~~~~




**Test the ODBC connection.**

On AIX, as root:

~~~~
    /usr/local/bin/isql -v xcatdb
~~~~


or as non-root user:

~~~~
    /usr/local/bin/isql -v xcatdb xcatdb <passwd>
~~~~


On Linux, as root:

~~~~
    /usr/bin/isql -v xcatdb
~~~~


or as non-root user:

~~~~
    /usr/bin/isql -v xcatdb xcatadmin xcat201
~~~~




The output looks as the following:

~~~~
    /usr/local/bin/isql -v xcatdb


+--------------------+
| Connected! |
| -----------|
| sql-statement |
| help[tablename] |
| quit |
+--------------------+

    SQL> help site;





    SQL > quit;

~~~~


### **Add DB2 code paths for Root**

If you are running programs like LoadLeveler that need to access the DB2 commands as root, you should add the DB2 paths for root on the Management Node and Service Nodes. The most efficient way is to add the following to the setup of root on logon:

~~~~
     .  /var/lib/db2/sqllib/db2profile
~~~~


Note: the db2sqlsetup script will do this for you and the path is the default /var/lib/db2 but this may have changed with the site.databaseloc attribute.

## **Verify DB2 setup**

To verify you are runnning against the DB2 database on the Management or Service Nodes:

run the lsxcatd command to check the xCAT database configuration.

~~~~
    > lsxcatd -d

    cfgloc=DB2:xcatdb|xcatdb
    dbengine=DB2
    dbinstance=xcatdb
    dbname=xcatdb
~~~~


Note: When migrating from MySQL or PostgreSQL to DB2, sometime the stop of the daemon does not clean up all the links to the previous database. If lsxcatd -d is still pointing to one of those databases and not DB2, then do the following:

~~~~
    service xcatd stop or stopsrc -s xcatd
    ps -ef | grep xcatd
~~~~


if any xcatd daemons still running kill -9 them

~~~~
    server xcatd start or startsrc -s xcatd
    lsxcatd -d
~~~~



You should also stop MySQL or Postgresql, if you are no longer using it.

### **Verify the ODBC setup.**

To verify that the ODBC for DB2 has been setup correctly on the Management or Service Nodes:

Check the /root/db2cli.ini file.

~~~~
    > cat /root/db2cli.ini
    [xcatdb]
    pwd=db2root
    uid=xcatdb
~~~~




~~~~

    > cat       /var/lib/db2/sqllib/cfg/db2cli.ini
    [xcatdb]
    pwd=db2root
    uid=xcatdb

~~~~

    > /usr/local/bin/isql       -v xcatdb
    +-------------------------------------+
    | Connected!                          |
    | sql-statement                       |
    | help [tablename]                    |
    | quit                                |
    +-------------------------------------+
    SQL>


## Additional DB2 Setup

### DB2 Diagnostic Logs

By default, xCAT sets up a single diagnostic log file named /var/lib/db2/sqllib/dump/db2diag.log to rotate using

~~~~
    update dbm cfg using DIAGSIZE 1024;
~~~~



You can change this default by following these instructions: http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.admin.trb.doc/doc/c0054462.html

You can also delete this log at anytime, unless you want to keep it.

## Useful DB2 Commands

Note: path IBM for AIX, ibm for Linux

These commands, you run as root:




  * Remove an instance:/opt/ibm/db2/V9.7/instance/db2idrop xcatdb
  * If you have problems removing an instance use:

~~~~
/opt/ibm/db2/V9.7/instance/db2iset -d xcatdb
~~~~

  * Show all instances:/opt/ibm/db2/V9.7/instance/db2ilist

These command, you run as xcatdb:




  * db2 connect to xcatdb ( connect to database from Server
  * db2 connect to xcatdb user xcatdb (connect from Client)
  * db2 GET HEALTH SNAPSHOT FOR DATABASE ON xcatdb
  * db2 get database configuration for xcatdb
  * db2 get dbm cfg
  * db2top -d xcatdb (diagnostic tool)
  * db2 drop database xcatdb ( drop the database)
  * db2 list tables
  * db2 select \\* from site
  * db2 select max \\(\"recid\"\\) from auditlog
  * db2 select min \\(\"recid\"\\) from auditlog
  * db2 select \\* from monsetting WHERE \\(\"name\" like \'rcmon\'\\) and \\(**\"disable\" is NULL \\)**
  * db2 select \"node\" from nodelist **WHERE \"disable\" is NULL OR \"disable\" LIKE \'0\' OR \"disable\" LIKE \'no\' OR \"disable\" LIKE \'NO\' OR \"disable\" LIKE \'nO\'**
  * db2 describe table site
  * db2 list tablespaces
  * db2 list tablespaces show detail
  * db2 select TABSCHEMA, TABNAME, TBSPACEID, TBSPACE from syscat.tables
  * db2 select TABNAME,NPAGES from syscat.tables
  * db2 select TABNAME,CARD from syscat.tables
  * db2 select TABNAME,COMPRESSION from syscat.tables
  * db2 drop table site
  * db2stop
  * db2stop force
  * db2start
  * db2licm -l
  * db2level ( show current release/ptf level)
  * db2look - extracts database
  * db2 ( enter interactive admin session)
  * db2 -t ( enter interactive admin session where sql must end in&nbsp;;)
  * db2 get db cfg ( get database configuration)
  * db2 update dbm cfg using MON_HEAP_SZ AUTOMATIC
  * db2 list node directory
  * quit ( quit out of interactive admin session)
  * db2 list applications
  * db2 list applications show detail | grep db2fw
  * remove application limit: db2set DB2_PMODEL_SETTINGS=MAX_BACKGROUND_SYSAPPS:500
  * list all tables in xcatdb and their size

~~~~
     db2 "SELECT SUBSTR(TABSCHEMA,1,18) TABSCHEMA,SUBSTR(TABNAME,1,30) \
    TABNAME,SUM(DATA_OBJECT_P_SIZE) DATA_OBJECT_P_SIZE,SUM(INDEX_OBJECT_P_SIZE) \
    INDEX_OBJECT_P_SIZE,SUM(LONG_OBJECT_P_SIZE) \
    LONG_OBJECT_P_SIZE,SUM(LOB_OBJECT_P_SIZE) \
    LOB_OBJECT_P_SIZE,SUM(XML_OBJECT_P_SIZE) XML_OBJECT_P_SIZE FROM \
    SYSIBMADM.ADMINTABINFO WHERE TABSCHEMA NOT LIKE 'SYS%' GROUP BY TABSCHEMA, \
    TABNAME"
~~~~


For a nicer format use the following:

~~~~
    db2 "SELECT SUBSTR(TABSCHEMA,1,10) AS SCHEMA,SUBSTR(TABNAME,1,15) AS TABNAME, \
    INT(DATA_OBJECT_P_SIZE) AS OBJ_SZ_KB, INT(INDEX_OBJECT_P_SIZE) AS INX_SZ_KB, \
    INT(XML_OBJECT_P_SIZE) AS XML_SZ_KB  FROM SYSIBMADM.ADMINTABINFO \
    WHERE TABSCHEMA='XCATDB' ORDER BY 3 DESC"
~~~~


Sum all the tables by schema:

~~~~
    db2 "SELECT SUBSTR(TABSCHEMA,1,10) AS SCHEMA,\
    SUM(DATA_OBJECT_P_SIZE) AS OBJ_SZ_KB, \
    SUM(INDEX_OBJECT_P_SIZE) AS INX_SZ_KB, \
    SUM(XML_OBJECT_P_SIZE) AS XML_SZ_KB \
    FROM SYSIBMADM.ADMINTABINFO \
    GROUP BY TABSCHEMA \
    ORDER BY 2 DESC"
~~~~


Show table size:

~~~~
    db2 "select substr(t.tabschema,1,10)||'.'||substr(t.tabname,1,  20) as table  \
    ,char(date(t.stats_time)) as statsdate ,char(time(t.stats_time)) as statstime ,T.CARD as \
    rows_per_tbl, decimal(float(t.npages)/(1024/(ts.pagesize/1024)),9,2) as used_mb \
    ,decimal(float(t.fpages)/(1024/(ts.pagesize/1024)),9,2) as allocated_mb from SYSCAT.TABLES T \
    ,SYSCAT.TABLESPACES TS where t.tbspace=ts.tbspace and T.tabname='table name here' and T.TYPE='T'"
~~~~


Get Tablename and id

~~~~
    db2 SELECT "TABNAME,TABLEID"  FROM SYSCAT.TABLES
~~~~


### DB2 Admin Commands ( run as root)

  * As root, to re-setup **/etc/inittab entry for DB2**, run /opt/IBM/db2/V9.7/bin/db2fmcu -u -p /opt/IBM/db2/V9.7/bin/db2fmcd
  * Remove from /etc/inittab: /opt/IBM/db2/V9.7/bin/db2fmcu -d
  * Add back to /etc/inittab: /opt/IBM/db2/V9.7/bin/db2fmcu -u -p /opt/IBM/db2/V9.7/bin/db2fmcd

## Migrating to AIX 7.1

AIX 7.1 uses a new level of Perl ( 5.10.1). A new level for AIX 7.1 of the perl-DBD rpm for DB2 must be installed to replaced the AIX 6.x rpm that was installed previously.


During the migration:

the xcatd daemon should be stopped.


After the OS migration:

The new perl-DBD rpm can be obtained from the xcat deps package on the web:







  * Download the latest xCAT AIX deps package package, go to the 7.1 subdirectory
  * rpm -Uvh perl-DBD-DB2-1-2.aix7.1.ppc.rpm
  * start the xcatd daemon

## Removing xCAT from DB2 and the xCAT DB2 database

This procedure is to remove xCAT from using DB2, but leave DB2 installed on the MN. If you are going to change your DB2 configuration, such as you DB2 server hostname or ip address, or the location of your DB2 database, then go [Setting_Up_DB2_as_the_xCAT_DB/#removing-db2-from-mn-and-sn](Setting_Up_DB2_as_the_xCAT_DB/#removing-db2-from-mn-and-sn).

To remove the database, first back it up. It might be better not to use ~/xcat-dbback, which the setup script uses, especially if you are going to setup again.

~~~~
    mkdir -p /mydir/xcat-dbback
    dumpxCATdb -p /mydir/xcat-dbback
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


Remove the DB2 database.

~~~~
    su - xcatdb
    db2 force application all
    db2iauto -off xcatdb
    db2 drop database xcatdb
    db2stop
~~~~


Remove /etc/xcat/cfgloc file ( points xCAT to DB2)

~~~~
    rm /etc/xcat/cfgloc
~~~~


The /etc/xcat/cfgloc file tells xcat what database to use. If the file does not exists, it uses by default SQLite, which is setup during the xCAT install by default. After you remove this file, you can start xcatd and it will ge running on SQLite database.

If you were running a DB2 database, you may want to restore the data save from that database into your SQLite database by running the following:

Install the DB2 database into SQLite

~~~~
    XCATBYPASS=1 restorexCATdb -p <mydir>/xcat-dbback
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


## Removing DB2 from MN and SN

To remove DB2 from your MN and Service Node after removing xCAT from the DB, do the following: (note path is IBM for AIX, ibm for Linux)




### **Remove DB2 from the Service Nodes **

On the Service Node as root:

  * Stop the xcatd daemon

    On AIX:

~~~~
    stopsrc -s xcatd
    On Linux:
    service xcatd stop
~~~~


If Loadleveler is running, stop LL:

~~~~
    llctl stop
~~~~



Remove /etc/xcat/cfgloc file ( points xCAT to DB2)

~~~~
    rm /etc/xcat/cfgloc
~~~~


  * Remove the instance: ( if will not remove, su - xcatdb on the MN and db2stop, then try again).

    On AIX:
~~~~
    /opt/IBM/db2/V9.7/instance/db2idrop xcatdb
~~~~
    On Linux:
~~~~
    /opt/ibm/db2/V9.7/instance/db2idrop xcatdb
~~~~


  * Check to see if no instance:

    On AIX:
~~~~
    /opt/IBM/db2/V9.7/instance/db2ilist
~~~~
    On Linux:
~~~~
    /opt/ibm/db2/V9.7/instance/db2ilist
~~~~


  * Remove DB2 ( this takes a while and removes the db2 installed):

    On AIX:
~~~~
    /opt/IBM/db2/V9.7/install/db2_deinstall -a
~~~~
    On Linux:
~~~~
    /opt/ibm/db2/V9.7/install/db2_deinstall -a
~~~~


  * Make sure /opt/IBM/db2/V9.7 is empty if you want to install db2 again
  * remove instance port from /etc/services

~~~~
    vi /etc/services
~~~~


delete entry:

~~~~
    db2c_xcatdb1 50001/tcp # Port for server connection
~~~~


  * remove xcatdb user and xcatdb group

    On AIX:
~~~~
    rmuser xcatdb
    rmgroup xcatdb
~~~~
    On Linux:
~~~~
    userdel xcatdb
    groupdel xcatdb
~~~~


  * remove the database location as defined in site.databaseloc. For example the default of /var/lib/db2:

~~~~
    rm -rf /var/lib/db2/*
    rm -rf /var/lib/db2/.*
    rmdir /var/lib/db2
~~~~





  * Cleanup /etc/profile and /.profile on AIX or etc/profile.d/xcat.sh or xcat.csh on Linux

~~~~
    remove export DB2INSTANCE=xcatdb
    remove export EXTSHM=ON
    remove # xCAT DB2 setup
    PATH=$PATH:/var/lib/db2/sqllib/bin:/var/lib/db2/sqllib/adm:/var/lib/db2
    /sqllib/misc:/var/lib/db2/sqllib/db2tss/bin
    export PATH
~~~~


  * Remove the ODBC setup files

~~~~
    rm /etc/odbc.ini
    rm /etc/odbcinst.ini
    rm $ROOTHOME/db2cli.ini
~~~~


### **Remove DB2 from the Management Node **

On the Management Node as root:

  * stop the xcatd daemon

    On AIX:
~~~~
    stopsrc -s xcatd
~~~~
    On Linux:
~~~~
    service xcatd stop
~~~~


If ISNM is runing, stop the daemon

    On AIX:
~~~~
    chnwm -d
~~~~
    On Linux:
~~~~
    service cnmd stop
~~~~


If TEAL is running, stop the daemon:

    On AIX:
~~~~
    stopsrc -s teal
~~~~
    On Linux:
~~~~
    service teal stop
~~~~



Remove /etc/xcat/cfgloc file ( points xCAT to DB2)

~~~~
    mv /etc/xcat/cfgloc   /etc/xcat/cfgloc.save
~~~~


Remove the crontab entry for reorgtbls

~~~~
    crontab -e
~~~~


delete this line

~~~~
    0 0 * * 0 /opt/xcat/share/xcat/tools/reorgtbls
~~~~





  * remove the database

~~~~
    su - xcatdb
    db2 force applications all; db2 terminate;
    db2 drop database xcatdb
~~~~


  * stop db2

~~~~
    db2stop or db2stop force
~~~~


  * **as root perform the remainder of these steps ( example AIX path)**
  * Remove xcatdb instance

    On AIX:
~~~~
    /opt/IBM/db2/V9.7/instance/db2idrop xcatdb
~~~~
    On Linux:
~~~~
    /opt/ibm/db2/V9.7/instance/db2idrop xcatdb
~~~~








  * Check to see if no xcatdb instance


On AIX:

~~~~
    /opt/IBM/db2/V9.7/instance/db2ilist
~~~~


On Linux:

~~~~
    /opt/ibm/db2/V9.7/instance/db2ilist
~~~~


  * Remove DB2 , if you want to deinstall DB2 ( this takes a while, this removes the DB2 install). **Only deinstall DB2 if you do not plan to use it again. **

**** On AIX:

~~~~
    /opt/IBM/db2/V9.7/install/db2_deinstall -a
~~~~


On Linux:

~~~~
    /opt/ibm/db2/V9.7/install/db2_deinstall -a
~~~~


On Linux Redhat6:

~~~~
     rm   /etc/init/xcatfmcd.conf
~~~~





  * Make sure /opt/IBM/db2/V9.7 directory is empty, or you will not be able to install DB2 there again.
  * Remove the following xcat entries in /etc/services:

~~~~
    #xcatdb db2 entries
    DB2_xcatdb_END 60003/tcp
    db2c_xcatdb 50001/tcp # Port for server connection
~~~~





  * remove xcatdb user and xcatdb group

On AIX:

~~~~
    rmuser xcatdb
    rmgroup xcatdb
~~~~


On Linux:

~~~~
    userdel xcatdb
    groupdel xcatdb
~~~~


  * remove the database location as defined in site.databaseloc. For example the default of /var/lib/db2:

~~~~
    rm -rf /var/lib/db2/*
    rm -rf /var/lib/db2/.*
    rmdir /var/lib/db2
~~~~





  * Cleanup /etc/profile and /.profile on AIX or etc/profile.d/xcat.sh or xcat.csh on Linux

~~~~
    remove export DB2INSTANCE=xcatdb
    remove export EXTSHM=ON
    remove # xCAT DB2 setup
    PATH=$PATH:/var/lib/db2/sqllib/bin:/var/lib/db2/sqllib/adm:/var/lib/db2
    /sqllib/misc:/var/lib/db2/sqllib/db2tss/bin
    export PATH

~~~~

  * Remove the ODBC setup files

~~~~
    rm /etc/odbc.ini
    rm /etc/odbcinst.ini
    rm $ROOTHOME/db2cli.ini
    rm /etc/rc.db2 (if it exists)

~~~~

## References

### General

  * Configuring and Managing BlueGene [DB2 Setup Sections](http://www.redbooks.ibm.com/redbooks/pdfs/sg247352.pdf)
  * [MySQL to DB2 migration](http://www.ibm.com/developerworks/data/library/techarticle/dm-0606khatri/%20)
  * [Setting up the DB2 Client](http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.qb.server.doc/doc/t0007067.html)
  * [DB2 Survival Guide](http://www.michael-thomas.com/tech/db2/db2survival_guide.htm)_
  * [DBD:DB2 pod](http://search.cpan.org/~ibmtordb2/DBD-DB2-1.74/DB2.pod)
  * [DB2 Deployment Guide](http://www.redbooks.ibm.com/redbooks/pdfs/sg247653.pdf)
  * [DB2 Perl Database Interface ](http://www-01.ibm.com/support/docview.wss?rs=71&uid=swg21297335)
  * [DBI mail archives](http://www.mail-archive.com/dbi-users@perl.org/)
  * [Perl Progamming with DB2 ](http://www.ibm.com/developerworks/data/library/techarticle/dm-0512greenstein/)
  * [Quick Beginnings for DB2 ](ftp://ftp.software.ibm.com/ps/products/db2/info/vr8/pdf/letter/db2ise80.pdf)
  * [DB2SQL Cookbook](http://mysite.verizon.net/Graeme_Birchall/id1.html)
  * [IBM DB2 Manuals](https://www-304.ibm.com/support/docview.wss?rs=71&uid=swg27015148)
  * [DB2 Admin Guide](ftp://ftp.software.ibm.com/ps/products/db2/info/vr97/pdf/en_US/DB2AdminConfig-db2dae970.pdf)
  * [Syscat.tables](http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.sql.ref.doc/doc/r0001063.html)

### Performance References

  * [DB2 UDP Memory Module](http://www.ibm.com/developerworks/data/library/techarticle/dm-0406qi/index.html)
  * [DB2 Linux Performance ](http://publib.boulder.ibm.com/infocenter/db2luw/v9/topic/com.ibm.db2.udb.uprun.doc/doc/t0008238.htm)
  * [Table Spaces and Buffer Pools](http://www.ibm.com/developerworks/data/library/techarticle/0212wieser/index.html)
  * [DB2 Table Limits](http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.sql.ref.doc/doc/r0001029.html)
  * [DB2 Product Comparison](http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.licensing.doc/doc/r0053238.html)
  * [Automatic Table Maintenance for DB2](http://www.ibm.com/developerworks/data/library/techarticle/dm-0707tang/index.html)
  * [Data Compression](http://www.ibm.com/developerworks/data/library/techarticle/dm-0605ahuja/index.html)
  * [Table Partitioning](http://www.ibm.com/developerworks/data/library/techarticle/dm-0605ahuja2/index.html)
  * [Automatic Configuration](http://www.ibm.com/developerworks/data/library/techarticle/dm-0606ahuja2/index.html)
  * [DB2 Configuration Advisor](http://www.ibm.com/developerworks/data/library/techarticle/dm-0605shastry/)
  * [Configure Auto Maintenace without db2cc](http://www.ibm.com/developerworks/data/library/techarticle/dm-0801ganesan/index.html)
  * [Self Tuning Memory](http://www.ibm.com/developerworks/data/library/techarticle/dm-0606ahuja/index.html)
  * [runstats command](http://www.ibm.com/developerworks/data/library/techarticle/dm-0412pay/)
  * [Table Compression](http://www.ibm.com/developerworks/data/library/techarticle/dm-0806seifert/index.html)
  * [General Compression in DB2](http://www.ibm.com/developerworks/data/library/techarticle/dm-0605ahuja/index.html)
  * [DB2 Tuning](http://www.performancewiki.com/db2-tuning.html)

### DB2 Product Comparison

  * [DB2 Family of Products Comparison](http://www.ibm.com/developerworks/data/library/techarticle/0301zikopoulos/0301zikopoulos1.html)
  * [html DB2 Product Table Comparison](http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=/com.ibm.db2.luw.licensing.doc/doc/r0053238.)

### DB2 Logs

  * [DB2 Log Setup](http://www.sdn.sap.com/irj/scn/go/portal/prtroot/docs/library/uuid/40436717-7a52-2c10-07b2-dcb348e5b0e3?QuickLink=index&overridelayout=true)

### Trouble Shooting

***[DB2 Trouble Shooting](http://publib.boulder.ibm.com/infocenter/db2luw/v9/index.jsp?topic=%2Fcom.ibm.db2.udb.pd.doc%2Fdoc%2Fc0022318.htm)**

### Useful Table Information

***[Useful Table Info](http://it.toolbox.com/blogs/db2luw/sql-to-view-useful-table-information-13831)**

## Diagnostics

### db2start SQL1042C An unexpected system error occurred. SQLSTATE=58004

Check the status of the database

~~~~
    su - xcatdb
    db2dart xcatdb
~~~~


### **LoadLeveler unable to connect to DB2 server as Load**L

The following setting needs to be added to the DB2 DBM configuration to support LL accessing the DB2 server from the service nodes.

~~~~
    su - xcatdb
    db2 update dbm cfg using authentication client immediate
    exit
~~~~


### **ODBC setup failure**

If you get the following error, /usr/bin/isql -v xcatdb [01000][unixODBC][Driver Manager]Can't open lib '/var/lib/db2/sqllib/lib32/libdb2.so'&nbsp;: file not found [ISQL]ERROR: Could not SQLConnect

If that is not missing, run

~~~~
    ldd /var/lib/db2/sqllib/lib32/libdb2.so
~~~~


to determine what is missing. Look for xxxx=&gt; not found. .


Make sure you have both the 32 and 64 bit rpms installed for the following in this order:

~~~~
    pam-1.1.1-4.el6.ppc64
    pam-1.1.1-4.el6.ppc
    unixODBC-2.2.14-11.el6.ppc64
    unixODBC-2.2.14-11.el6.ppc
    openssl-1.0.0-4.el6.ppc64
    openssl-1.0.0-4.el6.ppc
~~~~


### ** Hung DB2**

One command that can cleanup zombie DB2 processes if db2stop force hangs, is

~~~~
    db2_kill
~~~~


### The database manager resources are in an inconsistent state on db2stop

If you are unable to db2stop and get the message, the resources are in an inconsistent state, you can follow this process. Run the following commands

~~~~
     db2_ps
~~~~


This will give a list of processes. Then kill each process id.

~~~~
     kill -9 <pid>
~~~~


Check to make sure all process have cleared database access

~~~~
     ipcs | grep xcatdb
~~~~


If any returned, then remove them using the ipcrm command. See ipcrm -h.

You should be able to db2stop or db2stop force.

~~~~
    su - xcatdb
    db2stop or db2stop force
~~~~




http://publib.boulder.ibm.com/infocenter/db2luw/v9r5/index.jsp?topic=%2Fcom.ibm.db2.luw.messages.sql.doc%2Fdoc%2Fmsql01072c.html

### **SQL6048N**

  * **SQL6048N A communication error occurred during START or STOP DATABASE MANAGER processing**

Name resolution for your DB2 server is not working, see https://www-304.ibm.com/support/docview.wss?uid=swg21223118

### **The 32 bit library file libstdc++.so.6 is not found on the system**

During the db2 install you may receive this warning. For OS such as Redhat6, they may not default to installing the 32 bit version of the standard C libraries. This link provides information for finding and installing the needed 32 bit version: http://publib.boulder.ibm.com/infocenter/wasinfo/v6r0/index.jsp?topic=/com.ibm.websphere.express.doc/info/exp/ae/tins_rhel_packages.html




### **Total Environment Allocation Failure**

    when running xCAT command to


the database, such as tabdump.

~~~~
    echo $DB2INSTANCE should be xcatdb
    Usually loss of critical DB2 Env Var settings for the following:
    DB2INSTANCE=xcatdb ( most important)
    CUR_INSTHOME=/var/lib/db2
    DB2DIR=/opt/ibm/db2/V9.7
    INSTHOME=/var/lib/db2
~~~~


See:http://www.perlmonks.org/?node_id=682626

See: Set the db2 environment variables for root




### **drop xcatdb instance fails**

If the drop of the instance fails (db2idrop xcatdb) or the command succeeds and db2ilist still shows xcatd, then run the following the command to show it is still in the db2 registry:

~~~~
    /opt/IBM/db2/V9.7/bin/db2greg -dump | grep "^I"
~~~~


run this command to force remove it

~~~~
    /opt/IBM/db2/V9.7/bin/db2greg -delinstrec instancename=xcatdb
~~~~


You can also try and recreate the instance and then remove it.

~~~~
    /opt/IBM/db2/V9.7/instance/db2icrt -a server -pdb2c_xcatdb  -u xcatdb xcatdb
    /opt/IBM/db2/V9.7/instance/db2idrop xcatdb
~~~~





### **db2start failure**

You may get db2start failures for many reasons, but one common problem is the hostname of the server was changed after DB2 was installed. The hostname is kept in /var/lib/db2/sqllib/db2nodes.cfg file and must match the hostname of the system. Follow these instructions if you must change the hostname:http://www-01.ibm.com/support/docview.wss?uid=swg21258834

Another way to fix the problem, if you have your database backed up, is the remove the xcatdb instance and recreate it.

### **db2stop failure**

http://publib.boulder.ibm.com/infocenter/db2luw/v9r5/index.jsp?topic=/com.ibm.db2.luw.messages.sql.doc/doc/msql01072c.html




### **Set diagnostics level in database**

You can up the diagnotics level and watch for database errors in the ~/sqllib/db2dump/db2diag.log and xcatdb.nfy under the xcatdb instance home directory on the DB2 Server.

Run the following to increase the diagnostics level. Note: this should be set back to level 3 after diagnosing the problem, because it affects DB performance.


On the MN:

~~~~
    stop the xcat daemon (stopsrc -s xcatd, or service xcatd stop)


    su - xcatdb
    db2 update dbm cfg using diaglevel 4
    db2stop
    db2start
~~~~


### **Failure to create the xcatdb instance**

One critical failure during the setup is when the xcatdb instance has an error during the creation, runing the **db2icrt** command. If the instance creation fails there is no reason to continue with the setup. One of the main reasons is if your hostname on the Management node is not a resolvable address. Fix this problem by adding it to DNS or /etc/hosts. To fix the broken instance. First run:

~~~~
    /opt/IBM/db2/V9.7/instance/db2ilist
~~~~


If the broken instance is there, it returns xcatd, we must get rid of it.

Assuming you have fixed the error that was reported when the db2icrt command ran then do the following ( this example is for AIX and on the MN (db2 server)):

~~~~
    rm /var/lib/db2/sqllib  directory
    /opt/ibm/db2/V9.7/instance/db2icrt -a server -pdb2c_xcatdb  -u xcatdb xcatdb
    restartxcatd
    db2sqlsetup -i -S

~~~~

If the instance is not there then just run:

~~~~
    restartxcatd
    db2sqlsetup -i -S
~~~~


### **Service Node not accessing DB2 server**

If after installing and runing the setup of DB2 on the Service Node as describe above, your xcatd cannot access the DB2 database on the Management Server, then here are some things you can use to debug.

On the Service Node:

~~~~
    su - xcatdb
    db2connect to xcatdb user xcatdb  ( you will be prompted for the passwd)
~~~~


If this connect succeeds then you DB2 client is setup successfully. If not need to review the section&nbsp;: [Setting_Up_DB2_as_the_xCAT_DB#Setting_up_the_DB2_Client_on_the_Service_Nodes]

On the SN:

~~~~
    cat /etc/xcat/cfgloc on the SN, does it match the MN?
    export XCATBYPASS=y tabdump site  ( can you access the database without the daemon)
~~~~


Check /var/log/messages on the MN while running the tabdump with the xcatd and check for errors.

~~~~
    tabdump site on the SN ( using the daemon)
~~~~



Start daemon in foreground and check for errors:

~~~~
    /opt/xcat/sbin/xcatd -f
~~~~


If any SSL error, resetup SSL certificates by using updatenode -k: From the MN,

~~~~
    updatenode <servicenode> -k
~~~~


Check that the xCAT rpms on the SN are identical to the xCAT rpms on the MN.

### **DB2 Instance directories with incorrect permissions**

A particular directory to check is $DB2InstanceHOME/sqllib/adm. In particular if you get this error starting the daemon, check this directory against a working system.

    DBI connect('xcatdb','xcatdb',...) failed: [IBM][CLI Driver] SQL30082N  Security processing failed with reason "42" ("ROOT CAPABILITY REQUIRED").  SQLSTATE=08001


### The number of background tasks has reached the limit of xxx, will try again later

Check this web site for details: https://www-304.ibm.com/support/docview.wss?uid=swg21499618

Basically you can up the limit by running:

~~~~
    su - xcatdb
    $ db2set DB2_PMODEL_SETTINGS=MAX_BACKGROUND_SYSAPPS:500
~~~~


### ADM1823E The active log is full and is held by application handle "14188..".

~~~~
    su - xcatdn
    db2 get snapshot for applications on xcatdb > /tmp/output
~~~~


Look in /tmp/output for the number 14188 to find out who it is.

### ./installFixPack upgrade fails

See SF defect 3429204 /installFixPack -b /opt/ibm/db2/V9.7 " or /installFixPack -b /opt/ibm/db2/V9.7 -f db2lib" fails with messages Back up the file "/opt/ibm/db2/V9.7/lib64/libdb2sqqg_wc.so" failed since it does not exist.

To fix

~~~~
     touch /opt/ibm/db2/V9.7/lib64/libdb2sqqg_wc.so
     touch /opt/ibm/db2/V9.7/lib64/libdb2qgwcf.so
     touch /opt/ibm/db2/V9.7/lib64/libdb2lstcc.so
~~~~


and run the ./installFixPack again.

### The number of background tasks has reached the limit of X, will try again later

See problem description at https://www-304.ibm.com/support/docview.wss?uid=swg21499618

Run

~~~~
     su - xcatdb
     db2set DB2_PMODEL_SETTINGS=MAX_BACKGROUND_SYSAPPS:100
~~~~


If 100 is not enough, increase.

### SQL5043N Support for one or more communication protocol failed

If you get the error SQL15043N when running db2start, then something is tying up the port 50001 configured from db2 in /etc/services.

http://www.dba-db2.com/2011/07/sql5043n-support-for-one-or-more-communications-protocols-failed-to-start-successfully.html

Another cause of this error , is when the DB2 Service hostname is not resolvable to an ip address and was not resolvable during the install of DB2 and setup of DB2 on the MN (EMS). If this is the case, we have found you have to basically cleanup and start over. When DB2 is installed, hostname of the MN (DB2 server) should be resolved in /etc/hosts and site.master attribute should be set to that ip address.

### xcatd fails to start after reboot

On reboot of the EMS, when running in a non-HAEMS environment, the xcatd daemon may fail to restart if the DB2 database does not become active within 200 seconds. If this happens you will see messages like the following running xcat commands:

~~~~
    Unable to open socket connection to xcatd daemon on localhost:3001.
    Verify that the xcatd daemon is running and that your SSL setup is correct.
    Connection failure: IO::Socket::SSL: connect: Connection refused at
    /opt/xcat/lib/perl   /xCAT/Client.pm line 183.
~~~~


To fix, start xcatd:

    On Linux:
~~~~
    service xcatd start
~~~~
    On AIX:
~~~~
    restartxcatd
~~~~


### ADM7519W DB2 could not allocate an agent. The SQLCODE is "-1225"

ADM7009E An error was encountered in the "TCPIP" protocol support. A possible cause is that the maximum number of agents has been exceeded.

Check license for memory allocation

~~~~
 db2licm -l
~~~~

http://www-01.ibm.com/support/docview.wss?uid=swg21431456

## Appendix A:Building Perl DBD::DB2 code

If you cannot use the **perl-DBD-DB2 rpm **supplied by xCAT and must build your own, that is you are using a different version of DB2 or not Redhat 5 or 6 Linux, then you must build your own perl DBD::DB2 code .


The level we have tested with is 1.78. If you have an older version, upgrade to 1.78. Some of the older versions do not support the function needed by xCAT. If you have 1.78 installed you can move on to Setting up the DB2 Server Instance.

For the build and installation of the Perl DBD::DB2 module follow the instructions below. You can read information about the Perl interface to DB2 at this site.


http://www-01.ibm.com/support/docview.wss?rs=71&amp;uid=swg21297335

or

http://www-01.ibm.com/support/docview.wss?rs=71&amp;uid=swg21297335


You will download the latest DBD:DB2 source code [from CPAN.](http://search.cpan.org/~ibmtordb2/)


[Note on AIX: you must install the VAC C/C++ compiler, on Linux gcc compiler](http://search.cpan.org/~ibmtordb2/)




We will then compile and install it on your machine with the DB2 database you have installed.




~~~~
    mkdir ~/DBD
    cd ~/DBD
~~~~


download the current DBD source into ~/DBD

~~~~
wget http://search.cpan.org/CPAN/authors/id/I/IB/IBMTORDB2/DBD-DB2-1.78.tar.gz
~~~~




If wget is not available, ftp the file to the directory.

~~~~
    zcat DBD-DB2-1.78.tar.gz | tar -xvf-
    cd ~/DBD/DBD-DB2-1.78
~~~~





Build and install the Perl DBD:


**On Linux:**

**on Redhat5**

~~~~
    DB2_HOME=/opt/ibm/db2/V9.7 DB2LIB=/opt/ibm/db2/V9.7/lib32 perl Makefile.PL
~~~~



**on Redhat6**

~~~~
    DB2_HOME=/opt/ibm/db2/V9.7 DB2LIB=/opt/ibm/db2/V9.7/lib64 perl Makefile.PL
~~~~


~~~~
vi /etc/ld.so.conf
~~~~

add the following line

~~~~
    /opt/ibm/db2/V9.7/lib64
~~~~


and run

~~~~
    ldconfig
~~~~





**on SLES**

~~~~
    DB2_HOME=/opt/ibm/db2/V9.7 DB2LIB=/opt/ibm/db2/V9.7/lib64 perl Makefile.PL
~~~~



**On AIX:**

~~~~
    DB2_HOME=/opt/IBM/db2/V9.7 perl Makefile.PL
~~~~



**For both AIX and Linux:**




~~~~
    make ( on Linux you will get warnings)
    make test
    make install (if the tests look okay)
~~~~



Note: if you are using perl 5.8.8 on AIX ( AIX61J - AIX61 TL5 (AIX 6.1.5.0)

~~~~
    /usr/bin/perl -> /usr/opt/perl5/bin/perl5.8.8
~~~~



The **make **may fail. Contact the xCAT development team. There is most likely a different Config.pm file needed in /usr/opt/perl5/lib/5.8.8/aix-thread-multi/ to produce the correct Makefile when running perl Makefile.PL.


The generated Makefile that is correct has the following line in it:

~~~~
    CDLFLAGS = -bE:/usr/opt/perl5/lib/5.8.8/aix-thread-multi/CORE/perl.exp -bE:/usr
    /opt/perl5/lib/5.8.8/aix-thread-multi/CORE/perl.exp -bE:/usr/opt/perl5/lib/5.8.8
    /aix-thread-multi/CORE/perl.exp -bE:/usr/opt/perl5/lib/5.8.8/aix-thread-multi/CORE/perl.exp
~~~~





**If the make does not fail and the Makefile looks correct, **continue using the 5.8.8 Makefile.

## Appendix B:Installing DB2 fix packs

### **Installing Latest Fix Packs on Management Node**

For the latest Fix Packs use the HPC DVD shipped to you.


Note for AIX 7.1, you will need Release 9.7.0.3 or later. For Linux Redhat 6.3 or later, you will need Release 9.7.0.5 or later.

In a nutshell, to upgrade to a newer FixPack level:

**To install a FixPack during the process there will be two copies of the DB2 code in /opt so additional space is required:** To update DB2 server code on the Management Node in /opt -- at least 3.5 gigabytes****

If you have Clients (Service Nodes) running, you will have to stop xcatd and stop the xcatdb instance on each Service Node, as you are doing for the Management Node below, before you start the server migration.

Follow the instructions in the following section for stopping all the applications accessing the database from the Service Nodes and the EMS and stop the xcatdb database.

[Stopping_the_DB2_Server](Setting_Up_DB2_as_the_xCAT_DB/#stopping-the-db2-server)


**Change directory to the location of the FixPack code which you extracted.**


**In the FixPack code directory, as root run:**

For AIX:

~~~~
    ./installFixPack -b /opt/IBM/db2/V9.7
~~~~


For Linux:

~~~~
    ./installFixPack -b /opt/ibm/db2/V9.7
~~~~



If get an error, read the error log. May suggest you use

For AIX:

~~~~
    ./installFixPack -b /opt/IBM/db2/V9.7 -f db2lib
~~~~


For Linux:

~~~~
    ./installFixPack -b /opt/ibm/db2/V9.7 -f db2lib
~~~~



The restart the database and all the daemons on the Service Nodes and the EMS following this process:

[#Starting_the_DB2_Server]

### **Installing Latest Fix Packs on Service Nodes**

The Service Nodes should be kept at the same DB2 level as the Management Node. After upgrading your Management Node to a new DB2 Service Pack you should upgrade your Service Nodes. During the upgrade two copies of DB2 are in the install diretory (/opt), so you will need additional space. To upgrade DB2 client code on the Service Node in /opt -- at least 1.5 gigabytes.

If you don't mind reinstalling your service node then, follow the instructions for Automatically installing the Service Node with DB2. Place the latest Fix pack in the directory that will be used to install DB2 on the SN. See the instructions in the following section: [Setting_Up_DB2_as_the_xCAT_DB#Automatic_install_of_DB2_and_Client_setup_on_SN](Setting_Up_DB2_as_the_xCAT_DB/#automatic-install-of-db2-and-client-setup-on-sn).

If you only want to install the Fix Pack for DB2, then Place the latest Fix pack in the directory that you used to install DB2 on the SN previously. This is a mountable directory from the SN and should have been defined in the site table db2installloc attribute. If you want to retain the previous version of DB2, then define a new mountable directory and update the site table db2installoc attribute to that new directory. Expand the new version of DB2 in that directory on the Management Server. Export it such that it can be mounted on the service nodes.

##### **Using xdsh**

You can use xdsh to your service nodes to update all or some of the service nodes at the same time from the Management Node:

As root on the MN, stop the xcatd on the service nodes using the service group:

On AIX:

~~~~

    xdsh service "stopsrc -s xcatd"
~~~~


On Linux:

~~~~
    xdsh service "service xcatd stop"
~~~~



Mount the directory from the MN on the SN that contains the DB2 Fix pack.




~~~~
    xdsh service mkdir /mntdb2
    xdsh service "mount mn:/mntdb2   /mntdb2"
~~~~








For AIX:

~~~~
    xdsh service "/mntdb2/wser/installFixPack -b /opt/IBM/db2/V9.7"
~~~~


For Linux:

~~~~
    xdsh service "/mntdb2/wser/installFixPack -b /opt/ibm/db2/V9.7"
~~~~



If get an error, read the error log. May suggest you use

For AIX:

~~~~
    xdsh service "/mntdb2/wser/installFixPack -b /opt/IBM/db2/V9.7 -f db2lib"
~~~~


For Linux:

~~~~
    xdsh service "/mntdb2/wser/installFixPack -b /opt/ibm/db2/V9.7 -f db2lib"
~~~~


For AIX:

~~~~
    xdsh service "unmount /mntdb2"
~~~~


For Linux:

~~~~
    xdsh service "umount /mntdb2"
~~~~








On AIX:

~~~~
    xdsh service restartxcatd
~~~~


On Linux:

~~~~
    xdsh service "service xcatd start"
~~~~


##### **Manual update**

If you want to manually update the Service Node, then logon the Service node as root:





stop the xcat daemon

On AIX:

~~~~
    stopsrc -s xcatd
~~~~


On Linux:

~~~~
    service xcatd stop
~~~~


Mount the directory from the MN on the SN that contains the DB2 Fix pack.

~~~~
    mkdir /mntdb2
    mount mn:/mntdb2   /mntdb2
~~~~


cd to the location of the PTF fix code

~~~~
    cd /mntdb2/ese
~~~~



In that directory as root run:

For AIX:

~~~~
    ./installFixPack -b /opt/IBM/db2/V9.7
~~~~


For Linux:

~~~~
    ./installFixPack -b /opt/ibm/db2/V9.7
~~~~



If get an error, read the error log. May suggest you use

For AIX:

~~~~
    ./installFixPack -b /opt/IBM/db2/V9.7 -f db2lib
~~~~


For Linux:

~~~~
    ./installFixPack -b /opt/ibm/db2/V9.7 -f db2lib
~~~~


For AIX:

~~~~
    unmount /mntdb2
~~~~


For Linux:

~~~~
    umount /mntdb2
~~~~





As root:

On AIX:

~~~~
    restartxcatd
~~~~


On Linux:

~~~~
    service xcatd start
~~~~





## Appendix C: Changing the hostname/ip address of the DB2 Server (EMS)

If you change the hostname/ip address of the EMS and it is the DB2 Server, then you need to follow these process: http://www-01.ibm.com/support/docview.wss?uid=swg21268757




The above link tells you to do this: You should as root, run this command

~~~~
    /databaseloc/db2/sqllib/adm/db2set -g DB2SYSTEM=<new hostname>
~~~~


To verify

~~~~
    databaseloc/db2/sqllib/adm/db2set -all
~~~~



After doing this follow the instructions in "Moving Service Node DB2 client to another DB2 Server" below to fix the Service nodes to point to the new address. [Setting_Up_DB2_as_the_xCAT_DB#Appendix_D:_Moving_Service_Node_DB2_client_to_another_DB2_Server]

## Appendix D: Moving Service Node DB2 client to another DB2 Server

If you need to move your Service Node to another Management Node DB2 Server, then you will need to follow these steps:

  * First change the database server as defined in DB2 by doing the following:

On the Service Node(s):

Stop xcatdb and anything else that might be trying to get to the database (LL for example). Then:

~~~~
    su - xcatdb
    db2 UNCATALOG DATABASE xcatdb
    db2 UNCATALOG NODE mn
    db2 catalog tcpip node mn remote xxx.xxx.xxx.xxx server db2c_xcatdb
~~~~


Substitute your new ip address in for the x's. It must be the address the Service Nodes as known the Management node by (should be master attribute in the site table).

~~~~
    db2 terminate
~~~~


Check to see if it is pointing to the right server by running:

~~~~
    db2 list node directory

    Node Directory
    Number of entries in the directory = 1
    Node 1 entry:
    Node name = MN
    Comment =
    Directory entry type = LOCAL
    Protocol = TCPIP
    Hostname = xxx.xxx.xxx.xxx
    Service name = db2c_xcatdb
~~~~

If it is correct, then run:

~~~~
    db2 catalog db xcatdb as xcatdb at node mn
    db2 terminate
~~~~


If all ok then run to test:

~~~~
    db2 connect to xcatdb user xcatdb ( you will be prompted for the pwd from cfgloc)
~~~~


If good then:

~~~~
    db2 connect reset
    exit   # the xcatdb su
~~~~


  * From the EMS: Make sure your Service Node can access the new Management Node by running from the following commands:

~~~~
    updatenode <servicenode> -k ( you will be prompted for root password on the SN)
    updatenode <servicenode> -P -V
    xdsh <servicenode> service xcatd restart (may be running after updatenode)
    xdsh <servicenode> lsxcatd -a
~~~~


## Appendix E: Changing xcatd DB2 instance Password

If you want to change the xcatd DB2 instance password on the Management node and all service nodes, use the db2sqlsetup . See man page for db2sqlsetup ( -p ) options. If you want to change the db2 instance password on the Management Node, run the following. You will be prompted for the new password.

~~~~
       db2sqlsetup -p -S
~~~~


If you change the db2 instance password on the Management Node, you must change the password on the service nodes to the same password, run the following. You will be prompted for the password.

~~~~
       db2sqlsetup -p -C
~~~~


## Appendix F: DB2 Administration

### **Backup/Restore the database with DB2 Commands**

I quick efficient way to backup you DB2 database is using the **db2 backup** command. the xCAT backup and restore commands dumpxCATdb/restorexCATdb are still very useful for an easy way to port the database to other systems and other databases, but it does not dump the ISNM, TEAL or LoadLeveler tables. It also does not preserve system tables, only the xCAT tables. The db2 backup command will dump the entire xcatdb database in a binary format, which is also much more space efficient. It is also really quick.

You will be able to schedule online backs, for example with a cron job. First you have to take one offline backup. This is the process:

Stop all daemons accessing the database (xCAT, LL, TEAL).

~~~~
    su - xcatdb
    db2 update db cfg for xcatdb using logretain RECOVERY
    db2stop force
    db2start
~~~~


Take one offline backup (no daemons running, accessing the database), **give yourself at least 50gig of space** in the directory and the directory must have xcatdb as its owner and group. You need the space to keep multiple backups around. Of course the space you need depends on the size of your DB2 database.

~~~~
    chown xcatdb <your backup directory>
    chgrp xcatdb <your backup directory>
    db2 backup db xcatdb user xcatdb using <your xcatdb password> to  <your backup directory>
~~~~


As root, restart the applications xcatd, TEAL, ISNM, LoadLeveler. From then on you can use ONLINE backup:

~~~~
    su - xcatdb
    db2 backup db xcatdb user xcatdb using <your directory>
~~~~


Your backup file will look something like this:

~~~~
    XCATDB.0.xcatdb.NODE0000.CATN0000.20111130130239.001
~~~~


The **20111130130239 is the timestamp** and you will need that for the restore. You may have many backups and you will pick the time/date backup with which you want to restore the database.




IF you need to restore the database:

Stop all applications accessing the database, then

~~~~
    su - xcatdb
    db2 restore db xcatdb user xcatdb using <your xcatdb password>  from <your backup directory> \
    taken at <timestamp>

~~~~

You will see the following, answer y:

~~~~
    SQL2539W  Warning!  Restoring to an existing database that is the same as the
    backup image database.  The database files will be deleted.
    Do you want to continue? (y/n) y
~~~~


Then run:

~~~~
    db2 rollforward database xcatdb to end of logs and complete
~~~~


Check database is accessible as xcatdb

~~~~
    db2 connect to xcatdb
~~~~



Then start all the applications.

With release of **xCAT 2.6.10**, you can use the dumpxCATdb and restorexCATdb commands to take **ONLINE** backup and restores, instead of running the db2 commands yourself. The initial setup and offline backup will still have to be done as documented above. After that to take an ONLINE backup run:

~~~~
    dumpxCATdb -b -p <your DB2 backup directory where you placed the initial offline backup>
~~~~


Stop all applications accessing the database, then:

~~~~
    retorexCATdb -b -t <timestamp> -p <your DB2 backup directory>
~~~~





### Stopping the DB2 Server

If you need to stop the DB2 server on the Management Node (EMS), you should first stop all applications that are accessing the database on the Service Nodes and the EMS.

**First go to the Service Nodes or use xdsh from the EMS.**

Stop the xcatd daemon

On AIX:

~~~~
    stopsrc -s xcatd
~~~~


On Linux:

~~~~
    service xcatd stop
~~~~


If Loadleveler is running, stop LL:

~~~~
    llctl stop
~~~~


**Then on the EMS:**

stop the xcatd daemon

On AIX:

~~~~
    stopsrc -s xcatd
~~~~


On Linux:

~~~~
    service xcatd stop
~~~~


If ISNM is runing, stop the daemon

On AIX:

~~~~
    chnwm -d
~~~~


On Linux:

~~~~
    service cnmd stop
~~~~


If TEAL is running, stop the daemon:

On AIX:

~~~~
    stopsrc -s teal
~~~~


On Linux:

~~~~
    service teal stop
~~~~


Now stop DB2 server:

~~~~
    su - xcatdb
    db2 force applications all; db2 terminate;
    db2stop or db2stop force

~~~~

### Starting the DB2 Server

On the EMS (MN):

Start the DB2 Server:

~~~~
    su - xcatdb
    db2start
~~~~


Start the xcatd daemon

On AIX:

~~~~
    restartxcatd
~~~~


On Linux:

~~~~
    service xcatd start
~~~~


If using ISNM:

On AIX:

~~~~
    chnwm -a
~~~~


On Linux:

~~~~
    service cnmd start
~~~~


If using TEAL:

On AIX:

~~~~
    startsrc -s teal
~~~~


On Linux:

~~~~
    service teal start
~~~~


On the Service Nodes, start the xcatd daemon

On AIX:

~~~~
    xdsh <servicenodes> "/opt/xcat/sbin/restartxcatd"
~~~~


On Linux:

~~~~
    xdsh <servicenodes> "service xcatd restart"
~~~~


### Looking at DB2 logs

~~~~
    su - xcatdb
    cd sqllib/db2dump
    vi  xcatdb.0.nfy
    run db2diag
~~~~


Check for errors

### db2top

You can use the db2top program to monitor the database much as you use top or topas to monitor the system. Check the internet for details. To run

~~~~
    su - xcatdb
    db2top -d xcatdb
~~~~


## Appendix G: Additional ISNM Setup Information

### Restoring CNM database views

If for some reason you lose your xcatdb database, or you must drop it, to fully restore CNM tables you must do the following. When xCAT daemon (xcatd) starts it will create the ISNM tables, but not the required ( views) of the tables. To resetup those views, do the following: Stop CNM

~~~~
    chnwm -d
~~~~


Add CNM DB view by running the following script

~~~~
    /opt/isnm/cnm/bin/configure_db_cnm.ksh
~~~~


Start CNM

~~~~
    chnwm -a
~~~~


### Stopping ISNM Performance Counter Collection

To stop the collection of performance counter data in ISNM, on the EMS run the following command.

~~~~
    chnwconfig -p PERF_DATA_INTERVAL -v 0
~~~~


Check the Performance Data Interval is now 0 which means no data collection.

~~~~
    lsnwconfig
    ISNM Configuration parameter values from Cluster Database
    CNM Expired Records Timer Check: 3600 seconds
    RMC Monitoring Support: ON (1)
    No.of Previous Performance Summary Data: 1
    **Performance Data Interval: 0 seconds**
    Performance Data collection Save Period: 168 hours
    CNM Recovery Consolidation timer: 300 seconds
    CNM Summary Data Timer: 43200 seconds
~~~~





To cleanup the performance counter tables, run the following drop table command. Note if your isnm_perf table is quite large this command can take many minutes to complete and accesses to the database will slow down dramatically. Stop ISNM

AIX:

~~~~
       chnwm -d
~~~~


Linux:

~~~~
     service cnmd stop
~~~~


Drop the tables:

~~~~
     su - xcatdb
     db2 connect to xcatdb
     db2 drop table isnm_perf
     db2 drop table isnm_perf_sum

~~~~




Then restart xcatd and restart cnmd, this will recreate the tables empty.

AIX:

~~~~
     restartxcatd
     chnwm -a
~~~~


Linux:

~~~~
     service xcatd restart
     service cnmd start
~~~~






At this point, you should see empty tables

~~~~
    tabdump isnm_perf
    tabdump isnm_perf_sum
~~~~


After you do this, you can get the database space back by running:

~~~~
    /opt/xcat/share/xcat/tools/reorgtbls
~~~~


This will also take several minutes and will slow down access to the database.

If you want to turn back on the original data gathering defaults, then run

~~~~
     chnwconfig -p PERF_DATA_INTERVAL -v 300  -p PERF_DATA_SAVE_PERIOD -v 168
~~~~


## Appendix H: Setting up DB2 Data Server Client

There can be conditions where you do not want to configure the full DB2 Client Instance provided with WorkGroup Edition on Service Nodes, Compute Nodes, Login Nodes. T One reason is you wanted to run the DB2 Client on a diskless node. The "IBM Data Server Driver Client " offers a lightweight client, that will allow applications to access the DB2 Server using the ODBC or Perl interface at about 1/10 the size.


**Note: you cannot use the DB2 Data Server Client on any node where LoadLeveler is running and using the DB2 database. The DB2 Data Server Client should not be installed on the EMS (Management Node) which is the DB2 Server and run WorkGroup Edition Server instance.** ****

### Download the DB2 Data Server Client Code

You will need to download the software, you will need V9.7 fix pack 5 or later for AIX or Linux ppc64.

9.7 Data Server Driver Package

http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm/Information+Management&amp;product=ibm/Information+Management/IBM+Data+Server+Client+Packages&amp;release=9.7.*&amp;platform=All&amp;function=fixId&amp;fixids=*-dsdriver-*FP005&amp;includeSupersedes=0

The following two software packages were tested:

~~~~
    v9.7fp5_aix64_dsdriver.tar.gz
    v9.7fp5_linuxppc64_dsdriver.tar.gz
~~~~


We will install into /db2client directory. The examples and the perl-DBD-DB2lite rpm is based on this location. We will work with an AIX example. Linux is similar.

~~~~
    mkdir /db2client
    download v9.7fp5_aix64_dsdriver.tar.gz into /db2client directory
~~~~


### Install and Setup DB2 Data Server Client Platform

I am installing the Data Server Client in the /db2client directory on the machine. Note this **should not** be used on the EMS (Management Server). Although where you put it is optional, xCAT provides a perl-DBD-DB2Lite rpm for both Linux and AIX. This rpm is built with DB2_HOME set to find the Data Server Client Code in the /db2client directory. Installing it somewhere else would require a rebuild of the rpms. All configuration examples below are based on that install directory and this is an AIX example, but should be almost the same for Linux.

*** Get unzip and install unzip, if not already available.**

Note the Data Server Client code requires unzip. Make sure it is available before continuing:

~~~~
    AIX:
     Get unzip from Linux Toolbox
     rpm -i unzip-5.51-1.aix5.1.ppc.rpm for diskfull.   For AIX diskless need to add to statelite image.
    Linux:
     Get from OS distro
~~~~


*** Extract the Data Server Client Code** You should have downloaded the db2 client tarball into /db2client directory for the steps abloe.




~~~~
     cd /db2client
     gunzip v9.7fp5_aix64_dsdriver.tar.gz
     tar -xvf v9.7fp5_aix64_dsdriver.tar
     export PATH=/db2client/dsdriver/bin:$PATH
     export LIBPATH=/db2client/dsdriver/lib:$LIBPATH


~~~~







  * **Setup Data Server Client**

Set the path to the Data Server Client code. You should add these to your .profile on AIX. (Linux TBD).

~~~~
    export PATH=/db2client/dsdriver/bin:$PATH
    export LIBPATH=/db2client/dsdriver/lib:$LIBPATH
~~~~


*** Install the Driver** This script will only automatically setup the 64 bit driver. We must manually extract the 32 bit driver.

~~~~
    cd /db2client/dsdriver
    ./installDSdriver
    cd  odbc_cli_driver
    cd *32
    uncompress *.tar.Z
    tar -xvf *.tar
~~~~


  * **Fix directory and files owner/group**

Note: the package I downloaded had sub-directories not defined with the bin owner/ bin group. To be sure, do the following:

~~~~
     cd /db2client
     chown -R bin *
     chgrp -R bin *
~~~~


***Create shared lib on 32 bit path (AIX)**

~~~~
    cd /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/lib
    ar -x libdb2.a
    mv shr.o libdb2.so
~~~~


### Configure DB2 Data Server Client

The DB2 Data Server Client has several configuration files that must be setup.

#### **db2dsdriver.cfg**

The db2dsdriver.cfg configuration file contains database directory information and client configuration parameters in a human-readable format.

The db2dsdriver.cfg configuration file is a XML file that is based on the db2dsdriver.xsd schema definition file. The db2dsdriver.cfg configuration file contains various keywords and values that can be used to enable various features to a supported database through ODBC, CLI, .NET, OLE DB, PHP, or Ruby applications. The keywords can be associated globally for all database connections, or they can be associated with specific database source name (DSN) or database connection.

~~~~
    cd /db2client/dsdriver/cfg
    cp db2dsdriver.cfg.sample  db2dsdriver.cfg
    chmod 755 db2dsdriver.cfg
    vi db2dsdriver.cfg

~~~~


Here is a sample setup for a node accessing the xcatdb database on the Management Node p7saixmn1.p7sim.com

~~~~
    <configuration>
      <dsncollection>
        <dsn alias="xcatdb" name="xcatdb" host="p7saixmn1.p7sim.com" port="50001"/>
      </dsncollection>
      <databases>
         <database name="xcatdb" host="p7saixmn1.p7sim.com" port="50001">
         </database>
      </databases>
    </configuration>
~~~~


#### **db2cli.ini**

The CLI/ODBC initialization file (db2cli.ini) contains various keywords and values that can be used to configure the behavior of CLI and the applications using it.

The keywords are associated with the database alias name, and affect all CLI and ODBC applications that access the database.

~~~~
    cd /db2client.save/dsdriver/cfg
    cp db2cli.ini.sample db2cli.ini
    chmod 0600 db2cli.ini

~~~~

Here is a sample db2cli.in file containing information needed to access the xcatdb database, using instance xcatdb and password cluster. Note this file should only be readable by root.

~~~~
    [xcatdb]
    uid=xcatdb
    pwd=cluster
~~~~





For 32 bit, copy the /db2client/dsdriver/cfg files to /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/cfg

~~~~
    cd /db2client/dsdriver/cfg
    cp db2cli.ini /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/cfg
    cp db2dsdriver.cfg /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/cfg
~~~~






#### **Using unixODBC**

The unixODBC files are still needed. The following are sample configurations:

~~~~
    cat /etc/odbc.ini
    [xcatdb]
    Driver   = DB2
    DATABASE = xcatdb
~~~~


~~~~
    cat /etc/odbcinst.ini
    [DB2]
    Description =  DB2 Driver
    Driver   = /db2client/dsdriver/odbc_cli_driver/aix32/clidriver/lib/libdb2.so
    FileUsage = 1
    DontDLClose = 1
    Threading = 0

~~~~

**Question? Does db2cli.ini have to be in root home also?**

~~~~
chmod 0644 /etc/odbc.ini chmod 0644 /etc/odbcinst.ini
~~~~

### perl DBD-DB2Lite rpms

xCAT provides the perl-DBD-DB2Lite rpms for RHELS6 on ppc64 and AIX. These rpms can be used with the DB2 Data Server Client code on the xCAT Service Node. Note LoadLeveler can not be running on that Service Node using the Database, because it does not support the DB2 Server Client, it requires the Full Client from the WSE install.

### **DB2 Data Server Client References**

  * http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=%2Fcom.ibm.swg.im.dbclient.install.doc%2Fdoc%2Fr0058814.html
  * http://publib.boulder.ibm.com/infocenter/db2luw/v9r7/index.jsp?topic=%2Fcom.ibm.swg.im.dbclient.config.doc%2Fdoc%2Fc0054555.html

## ** Appendix I:TEAL Database Table Commands**

https://sourceforge.net/apps/mediawiki/pyteal/index.php?title=Command_Reference

