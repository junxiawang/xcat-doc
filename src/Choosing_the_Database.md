<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT Databases](#xcat-databases)
  - [SQLite](#sqlite)
  - [PostgreSQL](#postgresql)
  - [MySQL](#mysql)
  - [DB2](#db2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## xCAT Databases



xCAT supports a pluggable interface which allows you to choose the relational database you wish to use. The following are the currently supported databases, with SQLite being the default when xCAT is installed on the Management Node for the first time. 

### SQLite

XCAT will automatically perform the initial setup of an SQLite Database when the Management Node is first installed. SQLite is a small, light, daemon-less database that requires no configuration or maintenance. This database is sufficient for small to moderate size systems ( less than 1000 nodes for Linux, 300 for AIX) , if you are not using hierarchy (service nodes). SQLite cannot be used for hierarchy, because the service nodes require access to the database from the service node and this SQLite does not support remote access to the database. For hierarchy, you need to setup PostgreSQL, MySQL, or DB2. 

xCAT provides database setup scripts to automatically setup the chosen database for you. 

### PostgreSQL

PostgreSQL is an open source database. It also supports IPv6. Instructions for setting up a PostgreSQL database on Linux or AIX: 

[Setting_Up_PostgreSQL_as_the_xCAT_DB](Setting_Up_PostgreSQL_as_the_xCAT_DB)

### MySQL

MySQL is an open source database. Instructions for setting up a MySQL data base for xCAT on AIX or Linux, or MariaDB on Linux: 


[Setting_Up_MySQL_as_the_xCAT_DB](Setting_Up_MySQL_as_the_xCAT_DB)

### DB2

DB2 is a database from IBM. It is only supported with xCAT on p775 clusters. Instructions for setting up a DB2 database for xCAT on AIX or Linux Power systems: 

[Setting_Up_DB2_as_the_xCAT_DB](Setting_Up_DB2_as_the_xCAT_DB)
