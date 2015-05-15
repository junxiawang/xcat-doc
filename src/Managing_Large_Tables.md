<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Managing Large Tables**](#managing-large-tables)
  - [auditlog](#auditlog)
  - [eventlog](#eventlog)
  - [Setting up cron to maintain the tables](#setting-up-cron-to-maintain-the-tables)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## **Managing Large Tables**

Tables in xCAT can become quite large. You should have in place a process for pruning tables such as the auditlog, eventlog. New entries are generated automatically for these tables based on your setup. Before backing up the xCAT tables, you may want to limit the amount of data in these tables. See tabprune below. As of xCAT 2.6 and later releases dumpxCATdb will not dump and restorexCATdb will not restore the auditlog or eventlog table without the -a option. 

  


### auditlog

You can control the amount of auditing with the site.auditskipcmds attribute. This attribute allows you to enter a list of commands that will not be logged, or the variable "ALL" which means log no commands. See the manpage for the site table. 

For maintaining the table use the tabprune command, see man page: http://xcat.sourceforge.net/man8/tabprune.8.html 

### eventlog

If you have monitoring in place, you should put in place a process for deleting entries to the eventlog table which can become quite large. 

For maintaining the table use the tabprune command, see man page: http://xcat.sourceforge.net/man8/tabprune.8.html 

### Setting up cron to maintain the tables

You can setup a cron job to automatically prune the auditlog and eventlog. For example, if you want to prune all data up to 7 days ago, each Sunday night at midnight and 1 a.m, then run: 
    
~~~~
    crontab -e
~~~~    

add these two lines 

~~~~
    
    0 0 * * 0 /opt/xcat/sbin/tabprune auditlog -d 7
    0 1 * * 0 /opt/xcat/sbin/tabprune eventlog -d 7
~~~~    
