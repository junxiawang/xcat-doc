The standby management node should be taken into account when doing any maintenance work in the xCAT cluster with HAMN setup. 

  1. Software Maintenance - Any software updates on the primary management node should also be done on the standby management node. 
  2. File Synchronization - Although we have setup crontab to synchronize the related files between the primary management node and standby management node, the crontab entries are only run in specific time slots. The synchronization delay may cause potential problems with HAMN, so it is recommended to manually synchronize the files mentioned in the section above whenever the files are modified. 
  3. Reboot management nodes - In case the primary management node needs to be rebooted, the HADR will failover to the standby management node. To avoid unnecessary failovers, it is recommended that you power off the standby management node before rebooting the primary management node. Rebooting the standby management node does not require additional steps. 

At this point, the HA MN Setup is complete, and customer workloads and system administration can continue on the primary management node until a failure occurs. The xcatdb and files on the standby management node will continue to be synchronized until such a failure occurs. 
