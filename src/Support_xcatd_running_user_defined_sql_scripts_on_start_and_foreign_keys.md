<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Overview](#1%5C-overview)
- [2\. Adding Tables, SQL script to xCAT](#2%5C-adding-tables-sql-script-to-xcat)
- [2.1 runsqlcmd](#21-runsqlcmd)
- [3\. Support for Foreign Keys](#3%5C-support-for-foreign-keys)
- [4\. Change to update schema design](#4%5C-change-to-update-schema-design)
- [5\. Support for MySQL engines](#5%5C-support-for-mysql-engines)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

**Support running Customer Defined sql scripts and foreign_keys**


## 1\. Overview

xCAT currently support having the Customer defining their own table schema and having xCAT automatically add the tables to the xCAT Schema. See [XCAT_Developer_Guide] for information. 

A Customer may want to run sql scripts after the database tables are created for additional setup such as adding "views", "stored procedures", alter the table to add foreign keys, etc. xCAT needs to provide a way for those sql script to be run against the current database. 

  
Because the databases that xCAT support (SQlite,MySQL,PostgreSQL,DB2) are not consistent with the SQL and datatypes they support, we need to be able to support the Table Schema and SQL scripts created for a particular database. 

## 2\. Adding Tables, SQL script to xCAT

The Table schema, and SQL scripts are added to the /opt/xcat/lib/perl/xCAT_schema directory by the Customer. xCAT will read all the *.pm files first and create the tables and then read all the *.sql files. The following naming conventions will be followed for both the *.pm and *.sql files. 

  
1\. &lt;name&gt;_&lt;database&gt;.pm for Table Schema 

2\. &lt;name&gt;_&lt;database&gt;.sql for all SQL script (create stored procedure, views,alter table, etc) For runsqlcmd, see below. 

where &lt;database&gt; is 

~~~~
    
         "mysql"  for mysql       (foo_mysql.pm)
         "pgsql"  for postgresql (foo_pgsql.pm)
         "db2" for db2           (foo_db2.pm)
         "sqlite" for sqlite      (foo_sqlite.pm)
         do not put in the database, if the file will work for all databases.  (foo.pm)
~~~~    

Files should be created owned by root with permission 0755. 

Each time the xcatd daemon is started on the Management Node, it will read all the *.pm files for the database it is currently using and all the *.pm files that work for all databases and create the tables in the database. It will then run the runsqlcmd script to add database updates. 

xCAT is providing a script runsqlcmd (/opt/xcat/sbin) that will read all the *.sql files for the database it is currently using and all the *.sql files that work for all the databases and run the sql scripts. This script can be run from an rpm post process, or on the command line. 

The Customer *.pm and *.sql files should have no order dependency. If an order is needed, then you can use the &lt;name&gt; of the file to determine the order as it will appear in a listed directory. For example you could name them (CNM1.sql , CNM2.sql) then when the directory is listed CNM1.pm would get processed before CNM2. The Customer should code the *.sql files such that they can be run multiple times without error. 

To have the database setup at the end of the Customers application install, the post processing of the rpm should reload xcatd. 
   
~~~~ 
    On AIX: restartxcatd -r
    On Linux: service xcatd reload
~~~~    

## 2.1 runsqlcmd

runsqlcmd will by default run all *.sql files, appropriate for the database, from the /opt/xcat/lib/perl/xCAT_schema directory. The SQLite database is not supported. DB2, MySQL and PostgreSQL are supported on AIX and Linux. As an option, you can input the directory you want to use, or the list of filenames that you want to run. runsqlcmd will check that the filenames are appropriate for the database. Wild cards may be used for filenames, CNM* for example. The file names must follow the same naming convention as defined above, except sqlite is not supported. 
  
 
See man page for  runsqlcmd.  http://xcat.sourceforge.net/man8/runsqlcmd.8.html
   

## 3\. Support for Foreign Keys

xCAT needs to support Foreign Keys. All tables need to be created first, since Foreign keys create a relationship between a table with the Foreign key, and the table(s) that are pointed to by the Foreign Key(s). Those tables must already exist for the key to be created. 

This relationship can be hierarchical, a table with a Foreign Key can point to a table with a Foreign keys. Also tables can have multiple Foreign keys pointing to multiple tables. 

Because of the potential complexity of the Foreign Key setup, it was decided that the Foreign Keys should not be created and updated at Table Create time. They should be created after all the Tables exist, using an SQL script, as supported above, and the Alter Table command. Another factor is each database has its own rules on how to add, update and remove Foreign key, do it is best to put that control in the hands of the developer who is maintaining their tables. 

  


xCAT will use the db2 -tvf command to run the file as the xcatd instance. 

The SQL would look something like this in the file: CNMalttable.db2.sql 
    
      alter table isnm_perf_lllink add foreign key ("perfID") REFERENCES isnm_perf  ("perfID") ON DELETE CASCADE;
    

## 4\. Change to update schema design

Currently, checks are done on the Schema.pm file (updateschema) to see if any updates need to be done in the database (attribute added to tables, new keys) when a connect to a Table is done ( Table-&gt;new function). This causes the check to be done many times more than is necessary, since schemas are not updated that often. 

The update schema function will be moved to run when xcatd is restarted, after we run the function to add any Customer defined tables. There will be a separate update schema function for DB2 database, since the process for updating is very different than the other databases. 

## 5\. Support for MySQL engines

MySQL will only support Foreign Keys, if the database engine used to create the table is InnoDB. The current xCAT default for Table creation in Mysql is MyISAM. We will add support for a **engine** keyword in the schema to define what Engine you want to create the table with for MySQL. 

The schema line should look like this 

~~~~
%tabspec = ( 
    
       x_lljob => {      #your table name should start with "x_".
           cols => [qw(jobid status comments disable)],
           keys => [qw(jobid)],
           keys => [qw(jobid)],
           required => [qw(jobid)],
           types => {
               jobid => 'INTEGER',
           },
           **engine => 'InnoDB',**
           table_desc => 'Stores jobs.',
~~~~    
