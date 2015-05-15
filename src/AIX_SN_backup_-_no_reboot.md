<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Service node takeover - no node reboot**](#service-node-takeover---no-node-reboot)
  - [**Set up an external NFS server**](#set-up-an-external-nfs-server)
  - [**Switch to the backup service node**](#switch-to-the-backup-service-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### **Service node takeover - no node reboot**
    
    **TBD - work in progress - not yet fully supported!**
    

By combining an external NFS server with a backup service node it is possible to have more highly available diskless compute nodes. 

With this combination you can switch nodes to a new backup SN without rebooting the nodes. 

The basic idea is that the NIM resources that are needed for the compute nodes are placed on a separate highly available NFS server instead of the service nodes. If the SN goes down the node will continue to run. As soon as the SN failure is detected you can switch to the backup SN. It will not be necessary to reboot the diskless nodes when you switch them to the backup server. 

The xCAT external NFS support is currently limited to the following NIM diskless resources: SPOT, shared_root, root, paging. It does not support other NIM diskless resources, such as dump, shared_home etc. However, if the node availability is a primary concern and you do not need these other resources then you can manage the service node takeover without rebooting the nodes. 

The service node switch is initiated manually using the xCAT **snmove** command. 

A service node takeover should be initiated as soon as possible after the the current service node failure is detected. 

The service node takeover with no node reboot is supported for AIX diskless nodes including stateful, stateless and statelite configurations. 

#### **Set up an external NFS server**

See [External_NFS_Server_Support_With_AIX_Stateless_And_Statelite](External_NFS_Server_Support_With_AIX_Stateless_And_Statelite) for details on using external NFS server with AIX diskless nodes. 

#### **Switch to the backup service node**

As described in a previous section above you can use the xCAT **snmove** command to switch nodes to a backup service node. 

Since the node resources are mounted from the external NFS server it should not be necessary to reboot the nodes. 

For example, if the SN named "SN1P" goes down you could switch all the compute nodes that use it to the backup SN by running a command similar to the following. 
    
    snmove -s SN1P
    
