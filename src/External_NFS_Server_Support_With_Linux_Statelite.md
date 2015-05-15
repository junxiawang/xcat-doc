<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [How To Use External NFS Server](#how-to-use-external-nfs-server)
  - [**Data synchronization between the management node and the external NFS server**](#data-synchronization-between-the-management-node-and-the-external-nfs-server)
  - [**Setup tables statelite, litefile and litetree**](#setup-tables-statelite-litefile-and-litetree)
    - [statelite table](#statelite-table)
    - [litefile table](#litefile-table)
    - [litetree table](#litetree-table)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

xCAT Linux statelite compute nodes need to mount NFS directories from their service node. Each service node can serve hundreds of compute nodes. If the NFS service on the service node, or the service node itself runs into problem, all the compute nodes served by this service node will be taken down immediately. 

This documentation illustrates how to use an external NFS server to provide high availability NFS service for Linux statelite compute nodes. 

The external NFS server is setup with HA capability. For example, you can use SONAS or GPFS CNFS. The required NFS exports for the statelite image are configured on the external NFS server. The statelite compute nodes will mount the NFS exports from the external NFS server instead of their service nodes. If any of the service node fails, the compute nodes can keep running with the NFS mounts from the external NFS server for a while. 

The idea of this external NFS server support is to redirect all the NFS mounts on the statelite nodes to an external NFS server. The external NFS server can be any configuration as long as it could provide HA NFS capability and the performance is not a problem when thousands of NFS mounts come from all the statelite nodes. 

The external NFS server support will only provide NFS service to the compute nodes. The service nodes will continue to provide the other network services such as TFTP, DHCP. 

When any of the service node fails, the administrator still needs to recover the failed service nodes as soon as possible. The service nodes are still providing network services to the compute nodes. For example, if the DHCP lease expire before the service node is recovered will cause problems. 

## How To Use External NFS Server

Set the node's “nfsserver” attribute in the database to hostname of the external NFS server. The "nfsserver" setting will direct the Linux statelite code to mount the rootimage from the external NFS server instead of the service node. 

### **Data synchronization between the management node and the external NFS server**

The operating system image files and statelite files need to be kept synchronized between the management node and the external NFS server. The synchronization can be done manually by running rsync or any other remote copy commands. It will require the administrator to perform synchronization manually, whenever the operating system image files or statelite files changed on the management node. 

A simple way is to mount the /install directory and all the statelite directories from the external NFS server on the management node even before running copycds. Be aware that the files in /install/postscripts are installed by xCAT package, the directory /install/postscripts should be copied to the external NFS server before mounting /install from the external NFS server. 

In the ramdisk-based statelite hierarchical configuration, the service nodes need to mount the /install directory from the management node, so the management node can not mount /install from the external NFS server in this scenario, the /install directory has to be copied to the external NFS server. 

Here is an example of mounting the /install directory on the MN ( non-ramdisk-based statelite): 

~~~~
root@mn~# mount 

... 
~~~~

nfssvr:/statelite on /statelite type nfs (rw,addr=9.114.47.101) 

nfssvr:/litetree on /litetree type nfs (rw,addr=9.114.47.101) 

nfssvr:/install on /install type nfs (rw,addr=9.114.47.101) 



Where the nfssvr is the hostname of the external NFS server, the /install directory will be used to contain the operating system image files, the /statelite and /litetree directory will be used to contain the statelite files. Be aware that the directories mounted from the external NFS server should be writable. 

  


### **Setup tables statelite, litefile and litetree**

For more details ses: [XCAT_Linux_Statelite/#configuring-statelite](XCAT_Linux_Statelite/#configuring-statelite). 

####statelite table

The “statemnt” column in the statelite table specifies the persistant read/write area where a node's persistent files will be written to, the persistent files are usually critical for applications running on the nodes, so it is recommended to point the “statemnt” to the external NFS server. Here is an example of the statelite table: 

~~~~
tabdump statelite
node,image,statemnt,comments,disable

"aixcn1",,"nfssvr:/statelite",,
~~~~

Make sure you NFS export any directories that are listed in this table with read-write permission on the external NFS server before attempting to boot the nodes. 

  
####litefile table

The litefile table specifies the directories and files for the statelite setup along with the option to use to do the setup. All the directories specified in the litefile table should be created and set to correct permission on the external NFS server before attempting to boot the nodes. 

####litetree table

The litetree table controls where the initial content of the files in the litefile table come from, and the long term content of the “ro” files. If any directories in this table point to the external NFS server, make sure you NFS export them on the external NFS server before attempting to boot the nodes. Here is an example of the litetree table: 

~~~~
 #priority,image,directory,comments,disable

 "1",,"9.114.47.101:/litetree",,
~~~~

## References

  * [XCAT_Linux_Statelite] 
