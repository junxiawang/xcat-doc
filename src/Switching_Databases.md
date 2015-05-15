xCAT supports the use of several databases. By default xCAT will initially come up using SQlite. 

However, if you plan to use xCAT service nodes you must switch to a database that supports remote access. XCAT currently supports MySQL, PostgreSQL, and DB2. As a convenience, the xCAT site provides downloads for MySQL and PostreSQL. 

( [xcat-postgresql-snap201007150920.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-postgresql-snap201007150920.tar.gz/download) and [xcat-mysql-201005260807.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-mysql-201005260807.tar.gz/download) ) 

See the following xCAT documents for instructions on how to configure these databases. 

[Setting_Up_MySQL_as_the_xCAT_DB] 

[Setting_Up_PostgreSQL_as_the_xCAT_DB] 

[Setting_Up_DB2_as_the_xCAT_DB] 

When configuring the database you will need to add access for each of your service nodes. The process for this is described in the documentation mentioned above. 

The sample xCAT installp_bundle files mentioned below contain commented-out entries for each of the supported databases. You must edit the bundle file you use to un-comment the appropriate database rpms. If the required database packages are not installed on the service node then the xCAT configuration will fail. 

The database tar files that are available on the xCAT web site may contain multiple versions of RPMs - one for each AIX operating system level. When you are copying required software to your lpp_source resource make sure you copy the rpm that coincides with your OS level. Do not copy multiple versions of the same rpm to the NIM lpp_source directory. 
