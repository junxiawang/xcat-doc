<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Mellanox Switch Configuration](#mellanox-switch-configuration)
  - [Setup the xCAT Database](#setup-the-xcat-database)
  - [Setup ssh connection to the Mellanox Switch](#setup-ssh-connection-to-the-mellanox-switch)
  - [Setup syslog on the Switch](#setup-syslog-on-the-switch)
  - [Configure xdsh for Mellanox Switch](#configure-xdsh-for-mellanox-switch)
    - [Create IB switch configuration file](#create-ib-switch-configuration-file)
  - [Commands Supported for the Mellanox Switch](#commands-supported-for-the-mellanox-switch)
  - [Send SNMP traps to xCAT Management Node](#send-snmp-traps-to-xcat-management-node)
- [UFM Configuration](#ufm-configuration)
  - [Setup xdsh to UFM and backup](#setup-xdsh-to-ufm-and-backup)
  - [Consolidate syslogs](#consolidate-syslogs)
  - [Send SNMP traps to xCAT Management Node](#send-snmp-traps-to-xcat-management-node-1)
- [Install nodes over IB](#install-nodes-over-ib)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Mellanox Switch Configuration

### Setup the xCAT Database

**The Mellanox Switch is only supported in xCAT Release 2.7 or later.**

  * Define IB switch as a node

~~~~
    chdef -t node -o mswitch groups=all nodetype=switch mgt=switch
~~~~


  * Add the login user name and password to the switches table:

    tabch switch=mswitch switches.sshusername=admin switches.sshpassword=admin switches.switchtype=MellanoxIB


The switches table will look like this:

~~~~
    #switch,snmpversion,username,password,privacy,auth,linkports,sshusername,sshpassword,switchtype,....  
    "mswitch",,,,,,,"admin","admin","MellanoxIB",,
~~~~


If there is only one admin and one password for all the switches then put the entry in the xCAT passwd table for the admin id and password to use to login.

~~~~
    tabch key=mswitch  passwd.username=admin passwd.password=admin
~~~~


The passwd table will look like this:

~~~~
    #key,username,password,cryptmethod,comments,disable
    "mswitch","admin","admin",,,
~~~~


Consolidate syslog to MN/SN

### Setup ssh connection to the Mellanox Switch

To run commands like xdsh and script to the Mellanox Switch, we need to setup ssh to run without prompting for a password to the Mellanox Switch. To do this run the following:

~~~~
    rspconfig mswitch sshcfg=enable
~~~~


### Setup syslog on the Switch

Use the following command to consolidate the syslog to the Management Node or Service Nodes, where ip is the addess of the MN or SN as known by the switch.

~~~~
    rspconfig mswitch logdest=<ip>
~~~~





### Configure xdsh for Mellanox Switch

#### Create IB switch configuration file

To run xdsh commands to the Mellanox Switch, you must use the --devicetype input flag to xdsh. In addition you must add a configuration file for xdsh. See xdsh man page: http://xcat.sourceforge.net/man1/xdsh.1.html




For the Mellanox Switch the --devicetype is "IBSwitch::Mellanox"

~~~~
    mkdir -p /var/opt/xcat/IBSwitch/Mellanox
    cd /var/opt/xcat/IBSwitch/Mellanox
    cp opt/xcat/share/xcat/ib/scripts/Mellanox/config .
~~~~






The file contains the following:

~~~~
    [main]
    [xdsh]
    pre-command=cli
    post-command=NULL

~~~~


Now you can run the switch commands from the mn using xdsh. For example:

~~~~
    xdsh mswitch -l admin --devicetype IBSwitch::Mellanox  'enable;configure terminal;show ssh server host-keys'
~~~~


### Commands Supported for the Mellanox Switch

Setup the snmp alert destination:

~~~~
    rspconfig <switch> snmpdest=<ip> [remove]
~~~~
       where "remove" means to remove this ip from the snmp destination list.


Enable/disable setting the snmp traps.

~~~~
    rspconfig <switch> alert=enable/disable
~~~~


Define the read only community for snmp version 1 and 2.

~~~~
    rspconfig <switch> community=<string>
~~~~


Enable/disable snmp function on the swithc.

~~~~
     rspconfig <switch> snmpcfg=enable/disable
~~~~


Enable/disable ssh-ing to the switch without password.

~~~~
    rspconfig <switch> sshcfg=enable/disable
~~~~


Setup the syslog remove receiver for this switch, and also define the minimum level of severity of the logs that are sent. The valid levels are: emerg, alert, crit, err, warning, notice, info, debug, none, remove. "remove" means to remove the given ip from the receiver list.

~~~~
    rspconfig <switch> logdest=<ip> [<level>]
~~~~


For doing other tasks on the switch, use xdsh. For example:

~~~~
     xdsh mswitch -l admin --devicetype IBSwitch::Mellanox  'show logging'
~~~~


Interactive commands are not supported by xdsh. For interactive commands, use ssh.

### Send SNMP traps to xCAT Management Node

First, get http://www.mellanox.com/related-docs/prod_ib_switch_systems/MELLANOX-MIB.zip, unzip it. Copy the mib file MELLANOX-MIB.txt to /usr/share/snmp/mibs directory on the mn and sn (if the sn is the snmp trap destination.)

Then,

To configure, run:

~~~~
     monadd snmpmon <mswitch>
     moncfg snmpmon <mswitch>

~~~~

To start monitoring, run:

~~~~
     monstart snmpmon <mswitch>
~~~~


To stop monitoring, run:

~~~~
     monstop snmpmon <mswitch>
~~~~


To deconfigure, run:

~~~~
     mondecfg snmpmon <mswitch>
~~~~


See [Monitoring_an_xCAT_Cluster] for more details.

## UFM Configuration

UFM server are just regular Linix boxes with UFM installed. xCAT can help install and configure the UFM servers. The xCAT mn can send remote command to UFM through xdsh. It can also collect SNMP traps and syslogs from the UFM servers.

### Setup xdsh to UFM and backup

Assume we have two hosts with UFM installed, called host1 and host2. First define the two hosts in the xCAT cluster. Usually the network that the UFM hosts are in a different than the compute nodes, make sure to assign correct servicenode and xcatmaster in the noderes table. And also make sure to assign correct os and arch values in the nodetype table for the UFM hosts. For example:

~~~~
     mkdef -t node -o host1,host2 groups=ufm,all os=sles11.1 arch=x86_64 servicenode=10.0.0.1 xcatmaster=10.0.0.1
~~~~


Then exchange the SSH key so that it can run xdsh.

~~~~
     xdsh host1,host2 -K
~~~~


Now we can run xdsh on the UFM hosts.

~~~~
     xdsh ufm date
~~~~





### Consolidate syslogs

Run the following command to make the UFM hosts to send the syslogs to the xCAT mn:

~~~~
     updatenode ufm -P syslog
~~~~


To test, run the following commands on the UFM hosts and see if the xCAT MN receives the new messages in /var/log/messages

~~~~
     logger xCAT "This is a test"
~~~~





### Send SNMP traps to xCAT Management Node

You need to have the Advanced License for UFM in order to send SNMP traps.

1\. Copy the mib file to /usr/share/snmp/mibs directory on the mn.

~~~~
      scp ufmhost:/opt/ufm/files/conf/vol_ufm3_0.mib /usr/share/snmp/mibs
~~~~


where ufmhost is the host where UFM is installed.


2\. On the UFM host, open the /opt/ufm/conf/gv.cfg configuration file. Under the [Notifications] line, set

~~~~
     snmp_listeners = <IP Address 1>[:<port 1>][,<IP Address 2>[:<port 2>].]
~~~~


the default port is 162. For example:

~~~~
       ssh ufmhost
       vi /opt/ufm/conf/gv.cfg

       ....
       [Notifications]
       snmp_listeners = 10.0.0.1
~~~~
     where 10.0.0.1 is the the ip address of the management node.



3\. On the UFM host, restart the ufmd.

~~~~
     service ufmd restart
~~~~



4\. From UFM GUI, click on the "Config" tab; bring up the "Event Management" Policy Table. Then select the SNMP check boxes for the events you are interested in to enable the system to send an SNMP traps for these events. Click "OK".

5\. Make sure snmptrapd is up and running on mn and all monitoring servers.

     It should have the '-m ALL' flag.

~~~~
     ps -ef |grep snmptrapd
     root 31866 1 0 08:44 ? 00:00:00 /usr/sbin/snmptrapd -m ALL
~~~~


     If it is not running, then run the following commands:

~~~~
     monadd snmpmon
     monstart snmpmon
~~~~


## Install nodes over IB



