<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Overview](#1%5C-overview)
- [2\. Documentation](#2%5C-documentation)
- [3\. Design](#3%5C-design)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

## 1\. Overview

xCAT must provide an automatic install and setup process for bringing up DB2 on the Linux and AIX Service Nodes (SN) during the service node install, so that it is configured to access the DB2 database running on the Management Node when the SN installation is complete. 

## 2\. Documentation

The following documentation will be modified to describe this process: 

[Setting_Up_DB2_as_the_xCAT_DB]
  

## 3\. Design

To setup DB2 on the Service Nodes: 

1\. The DB2 code must be installed from the db2 tarball 

2\. The perl-DBD-DB2 rpm must be installed from the xCAT deps package. Should be automatic. 

3\. The Service Node must be setup as a DB2 Client, using the db2sqlsetup script 

  
To do this the following process will be followed: 

The DB2 tarball will be extracted into a read/mountable directory on either the Management Node or some server that can be mounted by the Service Node after it is installed. The location will be put in a new site attribute called db2installloc. For example, 

site.db2installloc = /mntdb2 , if on the Management Node 

site.db2installloc = servername:/mntdb2 , if on some other server 

In ether case, the db2 code will be extracted and placed in /mntdb2 

The /mntdb2 directory will look something like this, where ese is the directory containing all the db2 install code. 

ls /mntdb2 

ese 

For Linux, the appropriate vaccpp rte rpm tarball must be installed on the SN as it was done on the MN. This can either be done by adding to the image (diskless) or into the otherpkgs setup for the service node install. 

http://www-01.ibm.com/support/docview.wss?uid=swg24023990 

vacpp.rte.90.rhel5.jun2009.update.tar.gz 

Finally, a new db2install postscript is to be written, and must be added to the postscripts table, before the servicenode postscript. Also an odbcsetup postscript can be added to set up the ODBC for DB2 applications accessing DB2 using C or C++ like LoadLeveler. It is not required for xCAT which only uses the Perl interface. 

  
tabdump postscripts 

node,postscripts,postbootscripts,comments,disable 

"xcatdefaults","syslog,aixremoteshell,syncfiles",,, 

"service","db2install,servicenode,odbcsetup",,, 
