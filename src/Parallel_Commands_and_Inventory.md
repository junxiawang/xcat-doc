<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Parallel Commands](#parallel-commands)
- [Software and Firmware Inventory](#software-and-firmware-inventory)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Parallel Commands

xCAT delivers a set of commands that can be run remote commands (ssh, scp,rsh,rcp,rsync,ping,cons) in parallel on multiple nodes. In addition the command have the capability of formatting the output from the commands, so the results are easier to process. These commands will make it much easier to administer your large cluster. 

  
For a list of the Parallel Commands and their man pages: 

[parallel-commands](XCAT_Commands/#parallel-commands) 

## Software and Firmware Inventory 

xCAT provides a command '**sinv'** that checks the software and firmware configuration in this cluster. 

The command creates an inventory of the input software/firmware check, comparing to other machines in the cluster and produces an output of node that are installed the same and those that are not. 

This command uses the xdsh parallel command, so it is in itself a parallel command, and thus can be run on multiple cluster nodes at one time and is hierarchical. 

The sinv command is designed to check the configuration of the nodes in a cluster. The command takes as input command line flags, and one or more templates which will be compared against the output of the xdsh command, designated to be run on the nodes in the noderange. 

The nodes will then be grouped according to the template they match and a report returned to the administrator in the output file designated or to stdout. 

sinv supports checking the output from the rinv or xdsh command. 

For example, if you wanted to check the ssh level on all the nodes and make sure they were the same as on the service node, you would first generate a template from the "good" service node (sn1) by running the following: 
 
~~~~   
    xdsh sn1 "rpm -qa | grep ssh " | xdshcoll > /tmp/sinv/sinv.template
~~~~      

To execute sinv using the sinv.template generated above on the nodegroup, testnodes ,writing output report to /tmp/sinv.output, enter: 
 
~~~~     
    sinv  -c "xdsh testnodes rpm -qa | grep ssh" -p /tmp/sinv/sinv.template -o /tmp/sinv.output
~~~~      

The report will look something like this, if every node matches: 

~~~~      
    Command started with following input.
    xdsh cmd:xdsh testnodes rpm -qa | grep ssh.
    Template path:/tmp/sinv/sinv.template.
    Template cnt:0.
    Remove template:NO.
    Output file:/tmp/sinv/sinv.output.
    Exactmatch:NO.
    Ignorefirst:NO.
    Seed node:None.
    file:None.
    The following nodes match /tmp/lissav/sinv.template:
    testnodes
~~~~      

There are many options for matching and reporting supported by the sinv command, including support to run rinv and generate reports on firmware inventory. 

See the [sinv ](http://xcat.sourceforge.net/man1/sinv.1.html) command for more information. 
