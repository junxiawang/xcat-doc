<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Node status](#1%5C-node-status)
- [2\. Application status](#2%5C-application-status)
- [3\. nodestate](#3%5C-nodestate)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

xCAT nodelist table holds node reachability status (status) and application status (appstatus). To turn on the status monitoring, run the following commands: 
    
      **monadd xcatmon -n -s [ping-interval=5]**     (The default ping-interval is 3 minutes).
      **monstart xcatmon**
    

To turn off the status monitoring, run: 
    
      **monstop xcatmon**
    

  


## 1\. Node status

xCAT is now using fping to get the node status. We will switch to use nmap (to query ssh port) on Linux for performance reason. 

  


## 2\. Application status

Format: **app1=status1,app2=status2....** Example: ssh="up",ll="down",gpfs="not working at all" 

  
The basic idea is to use nmap to query the ports for application deamons. If the ports is open then the application is healthy. However, some application may need further checking even though the port is open. For such applications, user can surpply a command (scripts) that checks the status. The input to the command is a comma separated list of node names, the output is the application status on each given node. The output format is: 

**node1:status**

**node2:status**

**...**

  


It can be a local command, or a command that will be run remotely on the nodes. 

  
Settings: 

Table monsetting: 

name key value 

xcatmon apps ssh,ll,gpfs,someapp 

xcatmon gpfs cmd=/tmp/mycmd,group=compute,group=service 

xcarmon ll port=5001,group=compute 

xcatmon someapp rmccondname=xxxx,group=all 

  


Keywords: 

**apps** \--- a list of comma separated application names whose status will be queried. For how to get the status of each app, look for app name in the key filed in a different row. 

**port ** \--- the application port number, if not specified, use internal list, then /etc/services. If there is no key specified for an app, assume"port" and "group=all". 

**group** \-- the name of a node group that needs to get the application status from. If not specified, assume all the nodes in the nodelist table. 

**cmd ** \---- the command will be run locally on mn or sn. 

**dcmd** \---- the command will be run distributed on the nodes (xdsh &lt;nodes&gt; ...). 

**rmccondname** \--- the RMC condition name. xCAT needs to associate the condition with LogEventToxCATDatabase response first. Then goto eventlog table, get the events since last observation. (This has not implemented yet.) 

## 3\. nodestate

A new flag for nodestat command: 

**nodestat &lt;nodelist&gt; -u|--updatedb -m|--usemon**

It displays the node status and application status, it also writes the status on the nodelist table. 

By default, it works as before, that is: 

1\. gets the ssh,pbs,xend port status; 

2\. if none of them are open, it gets the fping status; 

3\. for pingable nodes that are in the middle of deployment, it gets the deployment status; 

4\. for non-pingable nodes, it shows 'no ping'. 

  
But when -m is specified and there are settings in the monsetting table, it displays the status of the applications specified in the monsetting table. When -u is spcified it saves the status info into the xCAT database. Node's pingable status and deployment status is saved in the nodelist.status column. Node's application status is saved in the nodelist.appstatus column. 
