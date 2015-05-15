<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Setup xCAT on the Primary Management Node](#setup-xcat-on-the-primary-management-node)
- [Setup xCAT on the Standby Management Node](#setup-xcat-on-the-standby-management-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Setup xCAT on the Primary Management Node

The procedure described in [Setting_Up_a_Linux_xCAT_Mgmt_Node] or [XCAT_AIX_Cluster_Overview_and_Mgmt_Node] can be used for the xCAT setup on the primary management node. If DB2 will be used as the xCAT database system, please refer to the doc [Setting_Up_DB2_as_the_xCAT_DB]. 

## Setup xCAT on the Standby Management Node

The procedure described in [Setting_Up_a_Linux_xCAT_Mgmt_Node] or [XCAT_AIX_Cluster_Overview_and_Mgmt_Node] can also be used for the xCAT setup on the standby management node. The database system on the standby management node should be the same as the one running on the primary management node. 

If shared disks are used between the two management nodes, when setting up the standby management node, the shared disks should not be mounted on the standby management node. Make sure the xcatd can be up and running with whatever database is used as part of the xCAT setup verification on the standby management node. 

When installing and configuring DB2 software on the standby management node, you should follow the instructions in [Setting_Up_DB2_as_the_xCAT_DB]. Install DB2 and run db2sqlsetup to setup the xCAT database. 

After the xCAT setup is done on the standby management node, perform the following additional configuration steps: 

  * Make sure the primary management node can resolve the hostname of the standby management node, and vice versa. 
  * Setup ssh authentication between the primary management node and standby management node. It should be setup as "passwordless ssh authentication" and it should work in both directions. The summary of this procedure is: 
    * cat keys from /.ssh/id_rsa.pub on the primary management node and add them to /.ssh/authorized_keys on the standby management node. Remove the standby management node entry from /.ssh/known_hosts on the primary management node prior to issuing ssh to the standby management node. 
    * cat keys from /.ssh/id_rsa.pub on the standby management node and add them to /.ssh/authorized_keys on the primary management node. Remove the primary management node entry from /.ssh/known_hosts on the standby management node prior to issuing ssh to the primary management node. 
  * Make sure the time on the primary management node and standby management node is synchronized. Some tips on setting up the timezone and time: 
    * Command echo $TZ returns the current timezone setting 
    * Command date and chtz can be used to adjust the time and timezone. 
    * To setup ntp on the management nodes on AIX: 
      * Update the /etc/ntp.conf file with a valid ntp server. 
      * stopsrc -s xntpd 
      * startsrc -s xntpd 
      * Use ntpq -p to show the peer status of the ntp server, should see * to left of server after successful association with server is established 
  * Stop the xcatd daemon and DHCP service, for example, using commands stopsrc -s xcatd and stoprsc -s dhcpsd on AIX. You also need to modify the system configuration to prevent the xcatd and DHCP from being started automatically after reboots. For example, use chkconfig command on Linux and use rmssys command on AIX: 

On AIX: 
 
~~~~   
       stopsrc -s xcatd
       rmssys -s xcatd
~~~~     

On Linux: 

~~~~     
       service xcatd stop
       chkconfig --level 345 xcatd off
       service dhcpd stop
       chkconfig --level 2345 dhcpd off
~~~~     

  


  * Stop the HPC software daemons like TEAL, CNM, LL and GPFS and modify system configuration to prevent them from being started automatically. 
  * (Optional) Backup the xCAT database tables for the current configuration on primary management node, using command dumpxCATdb -p &lt;backupdir&gt;
