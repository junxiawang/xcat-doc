<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Basics](#basics)
- [Variations/Enhancements/Other notes](#variationsenhancementsother-notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

This design summarizes new function for xCAT to provide an infrastructure for running “health-check” scripts for cluster nodes. 

NOTE: This is just a quick capture of design thoughts which may not be consistent or even possible to implement as written. Everything here is subject to change and redesign. 

## Basics

  * Create a directory for sample health-check scripts shipped with xCAT: 

     /opt/xcat/share/xcat/checkscripts 

  * Have a master script that will run a list of scripts for a noderange: 

     nodecheck &lt;noderange&gt; &lt;scriptlist&gt; [-V|--verbose] 

  * Flatten noderange to a comma-delimited list of node names. Will this exceed cmd line length on very large clusters? Could pass in noderange (e.g. group), but that will be difficult when reducing the list (see below). Maybe handling hierarchy will help (see below). 
  * Call each script in order, passing in nodelist (print out fully qualified script name before executing to show progress?) and optional verbose flag. 
  * If a script prints failure for a node, that node is removed from the list for the next script. 
  * The nodecheck command will NOT run hierarchy. If a script needs hierarchy, it can run its own xdsh, xdsh -e, ppping, etc., which each handle hierarchy internally. This also allows for non-hierarchy checks (e.g. contacting an application server for status on the full list of nodes). 

  * It is the responsibility of each checkscript to print out any error or informational messages and return an appropriate exit code 
  * If scriptname is not fully qualified, search /install/checkscripts:/opt/xcat/share/xcat/checkscripts 
  * checkscript input/output conventions: 
    * Input to script: comma-delimited list of node names 

    

    

     optional verbose flag: -V | --verbose 

  * Output from script: 2 lines: 

    

     SUCCESS: comma-delimited list of node names (only show this line if verbose?) 
     FAILED: comma-delimited list of node names 

  * The complexity barrier for writing health check scripts should be as low as possible. They should be able to be written in any language (not just perl), so shouldn't require using any functions from our perl modules. To this end, should the node list be space delimited? 

## Variations/Enhancements/Other notes

  * Create new checkscripts table in xCAT database: 

    

     #node,scriptlist,comments,disable 

  * If no scriptlist provide on command line, get list for each node in &lt;noderange&gt;. Group all nodes with identical scriptlist and pass corresponding nodelist into each checkscript in list. 
  * Run scripts for different sets of nodes in parallel? 

  


  * Provide syntax to allow a script to be run: always, or if some reg expression is true. (where $? means last return code value). Maybe something like a scriptlist value of: 

    

     &lt;script1&gt;,&lt;expression&gt;:&lt;script2&gt;,&lt;expression&gt;:&lt;script3&gt;,&lt;script4&gt;

     e.g.: 

     is_node_alive,'$?=0':check_IB,'$?=0':check_gpfs 

  


  * Example scripts: 

     is_node_alive: 

  * nodestat check; (pSeries) Rvitals lcds for any not 'sshd' 
  * rsh check (inetd) 
  * xdsh 
  * name resolution 
  * IB_check: 

     ppping -i ib0,ib1 
     for any failed nodes: netstat -ni, (SLES) service openibd status, ibv_devices, ibv_devinfo; (AIX) ibstat -v 

     GPFS_check: 

  * xdsh &lt;noderange&gt; -v -t 10 cksum /gpfs/home/00PRESENT00 

     from MN if it has access to GPFS, otherwise from one node in GPFS cluster, or one GPFS I/O node: 

     /usr/lpp/mmfs/bin/mmgetstate -aLs 

     LL_check: 

  * SLES: /opt/ibmll/LoadL/full/bin/llstatus 

     AIX: /usr/lpp/LoadL/full/bin/llstatus 

  * llstatus -a 

     servicenode: all xcatd daemons running, dhcpd, tftpd, atftpd, bootp, dhcp, inetd, syslogd, DNS 

     managementnode: same as servicenode script? 
