<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Overview**](#overview)
- [Mellanox Switch SSH, syslog and SNMP Configuration](#mellanox-switch-ssh-syslog-and-snmp-configuration)
  - [Define Mellanox Switch in Database](#define-mellanox-switch-in-database)
    - [switches Table](#switches-table)
    - [nodehm table](#nodehm-table)
    - [nodetype table](#nodetype-table)
    - [passwd table](#passwd-table)
  - [** setup ssh keys **](#-setup-ssh-keys-)
  - [xdsh and the Mellanox Switch](#xdsh-and-the-mellanox-switch)
    - [xdsh Mellanox config file](#xdsh-mellanox-config-file)
    - [Return codes from Mellanox](#return-codes-from-mellanox)
  - [Consolidate syslog to MN/SN](#consolidate-syslog-to-mnsn)
  - [Trap SNMP alerts on MN/SN](#trap-snmp-alerts-on-mnsn)
  - [Commands Supported](#commands-supported)
- [UFM xdsh, syslog and SNMP Configuration](#ufm-xdsh-syslog-and-snmp-configuration)
  - [set up xdsh to UFM and backup](#set-up-xdsh-to-ufm-and-backup)
  - [consolidate syslogs](#consolidate-syslogs)
  - [get SNMP traps to xCAT mn](#get-snmp-traps-to-xcat-mn)
  - [consolidate all UFM logs](#consolidate-all-ufm-logs)
  - [feed node names to UFM](#feed-node-names-to-ufm)
- [Docs](#docs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


## **Overview**

This design is for a xCAT configuration and support of the Mellanox Switch, UFM, and Mellanox adapters. The function planned is: 

  * Mellanox switches: 
    * set up ssh 
    * use the ssh capability to query and set settings via rspconfig or straight thru xdsh 
    * trap snmp alerts on the MN/SN 
    * channel snmp alerts into TEAL for analysis (TEAL team will work on this) 
    * consolidate syslog to MN/SN 
    * channel syslog entries into TEAL for analysis (TEAL team will work on this)&nbsp;?? 
    * a TEAL analyzer that will do the following for the snmp alerts and syslog entries: (NM team will work on this??) 
      * associate the IB info with the correct node 
      * associate link errors with benign events like powering off nodes 
      * apply thresholds to link errors and create a TEAL alert when a threshold has been exceeded 
  * UFM 
    * set up xdsh to UFM and backup 
    * list settings for UFM and backup to help admin make sure they are in sync 
    * give UFM the xcat node names so the UFM error events will have that info in it (dependent on Mellanox providing a way to give them the node names) 
    * get SNMP alerts - documentation only, no need to automate 
    * channel snmp alerts into TEAL for analysis (TEAL team will work on this) 
    * a TEAL analyzer that will do the same things mentioned for the switch events above&nbsp;?? 
    * consolidate syslog to MN/SN 
    * investigate consolidating UFM-specific log files to MN/SN&nbsp;?? 
  * Mellanox IB Adapters: 
    * install libraries in the node OS image 
    * configure adapters at node boot time 

## Mellanox Switch SSH, syslog and SNMP Configuration

### Define Mellanox Switch in Database

Use the following chdef command to define the mellanox switch ( for example mswitch). 
    
     chdef -t node -o mswitch groups=all nodetype=switch mgt=switch
    

Add the ssh user name and password to the **switches** table: 
    
     tabch switch=mswitch switches.sshusername=admin switches.sshpassword=admin switches.switchtype=MellanoxIB
    

The switches table will look like this: 
    
    #switch,snmpversion,username,password,privacy,auth,linkports,sshusername,sshpassword,switchtype,comments,disable
     "mswitch",,,,,,,"admin","admin","MellanoxIB",,
    

If there is one admin and one password for all the switches then put an entry in the xCAT passwd table for the admin id and password to use to login. This is need to setup the ssh keys, so then the Mellanox commands can be run from the Management Node using xdsh. 
    
    #key,username,password,cryptmethod,comments,disable
    "switch","admin","admin",,,
    

  


#### switches Table

Three new attributes will be added to the switches table: 

sshuserid -- ssh user name. 

sshpassword -- ssh password. 

switchtype -- the type of the switch. The valid value is: MellanxIB. 

#### nodehm table

Attribute mgt would be set to "switch". 

#### nodetype table

Attribute nodetype would be set to "switch". 

#### passwd table

Use "switch" as the key for he default username and password for all the switches. 

  


### ** setup ssh keys **

**rspconfig** will be used to setup the ssh keys to the switch for passwordless ssh access. 
    
    rspconfig mswitch sshcfg=enable/disable
    

### xdsh and the Mellanox Switch

xdsh must create a special ssh command for the switch. 

The syntax of a working command to the switch is the following: 
    
    ssh admin@9.114.54.129 'cli "enable" "configure terminal" "show ssh server host-keys"'
    

The input to xdsh will be the following: 
    
    xdsh mswitch -l admin --devicetype IBSwitch::Mellanox  'enable;configure terminal;show ssh server host-keys'
    

Then xdsh should be able to construct the correct syntax of the command. Note" cli is required on all commands, so xdsh should add it. For example, xdsh will send: 
    
    ssh admin@mswitch cli "enable" "configure terminal" "show ssh server host-keys" 
    

#### xdsh Mellanox config file

xdsh will have a config file for the Mellanox switch. The file name will be: /var/opt/xcat/IBSwitch/Mellanox/config. The contents are: 
    
    [main]
    [xdsh]
    pre-command=cli
    post-command=NULL
    

A sample is shipped in /opt/xcat/share/xcat/ib/scripts/Mellanox/config. 

We can add the return code command to the post-command if available. 

  


#### Return codes from Mellanox

Right now all commands good and bad return only the good return from ssh. Need to work with them to get a command like we have for QLogic "showLastRetcode". 

### Consolidate syslog to MN/SN

Use the following command to consolidate the syslog to the MN or the SN: 
    
     rspconfig mswitch logdest=&lt;ip&gt;
    

### Trap SNMP alerts on MN/SN

This will be done through the monitoring plugin called snmpmon. New code will be added to support Mellanox IB swith. The code will use rspconfig under the cover. Supported rspconfig commands are described in next section. 

First, get http://www.mellanox.com/related-docs/prod_ib_switch_systems/MELLANOX-MIB.zip, unzip it. Copy the mib file MELLANOX-MIB.txt to /usr/share/snmp/mibs directory on the mn and sn (if the sn is the snmp trap destination.) 

Then, 

To configure, run: 
    
     monadd snmpmon &lt;mswitch&gt;
     moncfg snmpmon &lt;mswitch&gt;
    

To start monitoring, run: 
    
     monstart snmpmon &lt;mswitch&gt;
    

To stop monitoring, run: 
    
     monstop snmpmon &lt;mswitch&gt;
    

To deconfigure, run: 
    
     mondecfg snmpmon &lt;mswitch&gt;
    

### Commands Supported

Setup the snmp alert destination: 
    
    rspconfig &lt;switch&gt; snmpdest=&lt;ip&gt; [remove]
       where "remove" means to remove this ip from the snmp destination list.
    

Enable/disable setting the snmp traps. 
    
    rspconfig &lt;switch&gt; alert=enable/disable
    

Define the read only community for snmp version 1 and 2. 
    
    rspconfig &lt;switch&gt; community=&lt;string&gt;
    

Enable/disable snmp function on the swithc. 
    
     rspconfig &lt;switch&gt; snmpcfg=enable/disable
    

Enable/disable ssh-ing to the switch without password. 
    
    rspconfig &lt;switch&gt; sshcfg=enable/disable
    

Setup the syslog remove receiver for this switch, and also define the minimum level of severity of the logs that are sent. The valid levels are: emerg, alert, crit, err, warning, notice, info, debug, none, remove. "remove" means to remove the given ip from the receiver list. 
    
    rspconfig &lt;switch&gt; logdest=&lt;ip&gt; [&lt;level&gt;]
    

For doing other tasks on the switch, use xdsh. For example: 
    
     xdsh mswitch -l admin --devicetype IBSwitch::Mellanox  'show logging'
    

## UFM xdsh, syslog and SNMP Configuration

UFM server are just regular Linix boxes with UFM installed. xCAT can help install and configure the UFM servers. The xCAT mn can send remote command to UFM through xdsh. It can also collect SNMP traps and syslogs from the UFM servers. 

### set up xdsh to UFM and backup

Assume we have two hosts with UFM installed, called host1 and host2. First define the two hosts in the xCAT cluster. Usually the network that the UFM hosts are in a different than the compute nodes, make sure to assign correct servicenode and xcatmaster in the noderes table. And also make sure to assign correct os and arch values in the nodetype table for the UFM hosts. For example: 
    
     mkdef -t node -o host1,host2 groups=ufm,all os=sles11.1 arch=x86_64 servicenode=10.0.0.1 xcatmaster=10.0.0.1
    

Then exchange the SSH key so that it can run xdsh. 
    
     xdsh host1,host2 -K
    

Now we can run xdsh on the UFM hosts. 
    
     xdsh ufm date
    

  


### consolidate syslogs

Run the following command to make the UFM hosts to send the syslogs to the xCAT mn: 
    
     updatenode ufm -P syslog
    

To test, runt the following commands on the UFM hosts and see if the xCAT mn receives the new messages in /var/log/messages 
    
     logger xCAT "This is a test"
    

  


### get SNMP traps to xCAT mn

You need to have the Advanced License for UFM in order to send SNMP traps. 

1\. Copy the mib file to /usr/share/snmp/mibs directory on the mn. 
    
      scp ufmhost:/opt/ufm/files/conf/vol_ufm3_0.mib /usr/share/snmp/mibs
    

where ufmhost is the host where UFM is installed. 

  
2\. On the UFM host, open the /opt/ufm/conf/gv.cfg configuration file. Under the [Notifications] line, set 
    
     snmp_listeners = &lt;IP Address 1&gt;[:&lt;port 1&gt;][,&lt;IP Address 2&gt;[:&lt;port 2&gt;]…]
    

the default port is 162. For example: 
    
       ssh ufmhost
       vi /opt/ufm/conf/gv.cfg
    
       ....
       [Notifications]
       snmp_listeners = 10.0.0.1
     where 10.0.0.1 is the the ip address of the management node.
    

  
3\. On the UFM host, restart the ufmd. 
    
     service ufmd restart
    

  
4\. From UFM GUI, click on the "Config" tab; bring up the "Event Management" Policy Table. Then select the SNMP check boxes for the events you are interested in to enable the system to send an SNMP traps for these events. Click "OK". 

### consolidate all UFM logs

There are different logs on a UFM hosts besides syslogs. It's better to consolidate them to the xCAT mn. This item has low priority for now. It will be implemented later. 

### feed node names to UFM

UFM will use the REST API(v2) for xCAT functions. It will get the node info and incorporate these info into the events. The REST APIs can be found here: 

[REST_API_v2]

## Docs

  * Managing Mellonox switch. (new) 
  * xCAT Monitoring (update) 
