<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [syslog](#syslog)
  - [Override sending logs to the Management node from the servicenodes and nodes](#override-sending-logs-to-the-management-node-from-the-servicenodes-and-nodes)
  - [Leave default syslog configuration on the nodes](#leave-default-syslog-configuration-on-the-nodes)
  - [Extracting xCAT messages](#extracting-xcat-messages)
  - [Tailor your own syslog configuration](#tailor-your-own-syslog-configuration)
  - [important logging for auditing](#important-logging-for-auditing)
  - [Sample xCAT setup](#sample-xcat-setup)
- [auditlog](#auditlog)
  - [Maintaining auditlog](#maintaining-auditlog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## syslog

xCAT automatically sets up syslog during the install on the MN and the nodes. It use local4 to register it syslog entries and it logs to the /var/log/messages file. 

The syslog postscript accomplishes the setup. The syslog script is also called during initial install by xcatconfig on the MN. The xCAT daemon will detect, if the syslog daemon is not running and restart it when it starts. 



### Override sending logs to the Management node from the servicenodes and nodes
The setup defined in the syslog script for the service nodes and compute nodes is to send all syslog messages to the Management Node (MN) to the /var/log/messages file. You can override this by doing the following: 

Set the site table, svloglocal attribute to 1. In a hierarchical cluster, this will stop syslogs from being forwarded from the ServiceNodes to the Management Node. After setting it, run updatenode  to reconfigure. 

~~~~
      chdef -t site -o clustersite svloglocal=1
      updatenode <servicenodes> -P syslog
~~~~
 
### Leave default syslog configuration on the nodes

Take the syslog entry out of the postscripts table. If you do this xcat will not run the syslog postscript on install or when updatenode is run. This will leave the default syslog configuration as setup by the OS. This configuration will leaving logging local on service and compute nodes. If you have already setup syslog using xCAT, you will need to restore the original syslog configuration file on the nodes and restart syslog. You can use xdsh to do this. 

~~~~
  tabedit postscripts
  remove the syslog entry
~~~~  

### Extracting xCAT messages

There are a couple of ways that xCAT messages may be extracted from the syslog. 

xCAT messages all start with xCAT: They can easily be extracted from the messages file by grepping for xCAT: in the /var/log/messages file on the MN. 

### Tailor your own syslog configuration

xCAT messages are all logged to local4. You can add an entry such as the following to the syslog 
configuation file, for example /etc/rsyslog.conf on Redhat. This will log only the local4 messages to the 
xcatmessages file. They will also still go into the messages file. 

~~~~
    
    #XCAT settings
    *.debug  /var/log/messages
    local4.*  /var/log/xcatmessages
~~~~    

The *syslog.conf file has may ways to tailor logging. This website, explains more options 
 
~~~~   
    http://www.rsyslog.com/doc/rsyslog_conf.html
~~~~    

Also check the man page for syslog on the OS you are running. 

### important logging for auditing
The xcatd daemon, logs all commands run, and who runs them. 

A typical entry is as follows: Feb 23 09:27:30 xcat20RRmn xCAT: xCAT: Allowing tabdump for root from localhost.localdomain.
You can grep for the following string in /var/log/messages on the MN, to obtain those entries:

~~~~
 fgrep "xCAT: Allowing" /var/log/messages 
~~~~

You can also grep for all denials of requests: 

~~~~
fgrep "xCAT: Denying" /var/log/messages 
~~~~

This information is also available in the auditlog table. See auditlog below. 

The xcatd daemon, logs startup errors and database access errors in syslog. 
Errors from postscript running on nodes, and service nodes are logged in the syslog on the MN. 

### Sample xCAT setup

On AIX, xCAT uses syslog:

xCAT sets up the log to create up to 5 files of 1meg each and then rotate. See /etc/syslog.conf. 

~~~~
    #xCAT settings     
    *.debug /var/log/messages rotate 1024K files 5
~~~~    

  


**On SLES xCAT uses syslog-ng:**

  
The setup of xCAT used in syslog-ng, is basically the defaults of the syslog-ng software on the MN. 
It only changes to allow syslogs to be forwarded to the MN from the nodes. 

This setup allows local messages for (local1-7) to be logged to /var/log/localmessages and all messages to
 /var/log/messages. In many cases you will find that /var/log/localmessages contain only or primarily xCAT 
messages, so that is the file to check 

  
When syslog-ng is installed, it sets itself up to use logrotate to rotate the generated logs. See man logrotate for more details. 

  
On RedHat xCAT uses rsyslog:

  
xCAT uses basic defaults for rsyslog. See http://linux.die.net/man/8/rsyslogd for more information. 

  
When rsyslog is installed, it sets itself up to use logrotate to rotate the generated logs. See man logrotate for more details. 

  
On a node or service node:

  
By default, xCAT directs syslog to send all syslog messages to the Management Node. 

  
For example on RedHat: 

This entry in /etc/rsyslog.conf, directs syslog to forward all messages to the ip address, which is the ip of
 the MN. The picking of the debug level implies all levels will be sent. See information on configuring the 
syslog.conf file on your OS. 

~~~~
  xCAT settings 
  .debug* @7.113.44.250 
~~~~

## auditlog

As of xCAT 2.4, xCAT will not only log all command the xCAT daemon runs and who runs them to syslog, 
but also to a new auditlog table in the xCAT database. 
See the [manpage for the auditlog table](http://xcat.sourceforge.net/man5/auditlog.5.html). 

### Maintaining auditlog
  
You can control the amount of auditing with the site.auditskipcmds attribute.
 This attribute allows you to enter a list of commands that will not be logged, 
or the variable "ALL" which means log no commands. See the [manpage for the site table](http://xcat.sourceforge.net/man7/site.7.html). 

To maintain the table, use the tabprune command. It is recommended to setup a cron job to tabprune the auditlog weekly. Since it records all xCAT commands run, it can grow quite large and can significantly affect you dumpxCATdb/restorexCATdb. See manpage for tabprune:http://xcat.sourceforge.net/man8/tabprune.8.html 
