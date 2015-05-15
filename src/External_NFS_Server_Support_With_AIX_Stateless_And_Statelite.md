<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Overview](#overview)
  - [Procedure To Use External NFS Server](#procedure-to-use-external-nfs-server)
    - [**AIX non-shared_root stateless**](#aix-non-shared_root-stateless)
    - [**AIX shared_root stateless**](#aix-shared_root-stateless)
- [rsync -az --delete /install/nim/spot/71Bsharedrootcosi/usr <external_nfs_server>:/install/nim/spot/71Bsharedrootcosi/](#rsync--az---delete-installnimspot71bsharedrootcosiusr-external_nfs_serverinstallnimspot71bsharedrootcosi)
- [rsync -az /install/nim/paging/71Bcosi_paging <external_nfs_server>:/install/nim/paging/](#rsync--az-installnimpaging71bcosi_paging-external_nfs_serverinstallnimpaging)
    - [**AIX statelite**](#aix-statelite)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

xCAT AIX stateless/statelite compute nodes need to mount NFS directories from the service node, each service node can serve hundreds of compute nodes, if the NFS service on the service node or the service node itself runs into problem, all the compute nodes served by this service node will be taken down immediately, so we have to consider providing high availability NFS service for the compute nodes.

This documentation illustrates how to use external high availability NFS server to provide high availability NFS service for the AIX stateless/statelite compute nodes.

The external NFS server is setup with HA capability, for example, SONAS or GPFS CNFS, and the required NFS exports for the stateless/statelite image are also configured on the external NFS server, the stateless/statelite compute nodes will mount the NFS exports from the external NFS server instead of their service nodes, so if any of the service node fails, the compute nodes can keep running for a while with the NFS mounts from the external NFS server and will not be taken down immediately.

The core idea of this external NFS server support is to redirect all the NFS mounts on the stateless/statelite nodes to an external NFS server, the external NFS server can be any configuration as long as it could provide HA NFS capability and the performance is not a problem when thousands of NFS mounts come from all the stateless/statelite nodes.

The external NFS server support will only provide NFS service to the compute nodes, the service nodes will continue to provide the other network services such as TFTP, DHCP to the compute nodes.

When any of the service node fails, the compute nodes served by it will not be affected immediately, the applications can continue run on the compute nodes. But the administrator still needs to recover the failed service nodes very soon, because the service nodes are still providing network services to the compute nodes, for example, the DHCP lease expire before the service node is recovered will cause problem.

## Procedure To Use External NFS Server

The existing node attribute .nfsserver. is used to specify the external nfs server, the procedure needed for external NFS server support includes:

**1\. Set the node attribute .nfsserver. to hostname of the external NFS server before running mkdsklsnode.**

**2\. (Optional) Setup the node prescripts to sync files to the external NFS server**

xCAT prescripts support can be used to sync the operating system image files from the service nodes to the external NFS server automatically at the end of the mkdsklsnode command. You can put the rsync commands listed in the sections below into a prescripts under directory /install/prescripts, for example, the prescripts name can be "syncaixres", then run "chdef -t node -o &lt;node_name&gt; prescripts-end=syncaixres". You can refer the prescripts table manpage for more details about the prescripts usage.

To avoid confusion for both NIM and the users, it is required that the operating system image directories structure should be the same on the service nodes and the external NFS server, for example, the SPOT of an AIX image is under directory /install/nim/spot/aix71/usr on the service nodes, then the SPOT should also be copied to the directory /install/nim/spot/aix71/usr on the external NFS server.

**3\. After the mkdsklsnode command is run:**

       i. (Optional) Copy the required operating system image files from the service nodes to the external NFS server.


This step is required only when the prescripts setup is not being used to sync data to the external NFS server.

When copying the operating system image files, the files modes should be preserved, thus you should specify the .preserve. option with the remote copy or remotesynchronization commands, take rsync as an example, the .-az. should be the correct option. Of course, any backup/restore commands such as tar or zip can be used to copy the operating system image files.

       iii. Setup the NFS exports on the external NFS server.


Please be aware that the NFS export options for the AIX image directories on the external NFS server should be the same with the ones on the service nodes, a simple way is to copy the /etc/exports from the service nodes to the external NFS server.

If the diskless nodes are running AIX and the external NFS server runs Linux, when setting up NFS exports on the external NFS server, the .insecure. exports option is needed to make the AIX be able to mount the Linux NFS exports.

       iv. If any changes are made on the management node or service nodes and the mkdsklsnode command needs to be run again, the operating system image files need to synchronized to the external NFS server.


The operating system image files are different for AIX non-shared_root and shared_root configuration; there are some additional steps with the statelite support, the following sections will cover the procedure for AIX non-shared_root stateless, AIX shared_root statelss and AIX statelite.

### **AIX non-shared_root stateless**

The following operating system image files need to be copied to the external NFS server for the AIX non-shared_root stateless configuration:

**1\. SPOT**

Use lsnim -l &lt;spot_name&gt; to get the location of the SPOT, for example, /install/nim/spot/71Bcosi/usr, copy the whole directory to the external NFS server.

For one AIX stateless image, the SPOT resource is the same across all the service nodes, so only needs to copy the SPOT from one service node to the external NFS server. Here is an example:

On one service node:

~~~~
    #rsync -az --delete /install/nim/spot/71Bcosi/usr <external_nfs_server>:/install/nim/spot/71Bcosi/
~~~~

**2\. ROOT**

Use lsnim -l &lt;root_name&gt; to get the location of the root resource, for example, /install/nim/root/71Bcosi_root.

For the non-shared_root stateless configuration, each node has a separate root resource, all the root resources are under the same directory, you can copy the directory that contains all the root resources to the external NFS server.

Even for the same AIX image, the root resource is different between service nodes, so the root resource directories from all the service nodes are required to be copied to the external NFS server. Here is an example:

On all the service nodes:

~~~~
    #rsync -az --delete /install/nim/root/71Bcosi_root <external_nfs_server>:/install/nim/root/
~~~~

**3.(Optional) Paging Space**

It is not required to put paging space resource on external NFS server, the paging space will not cause system crash in most of the scenarios, but if you want to put paging space resource on external NFS server, the following procedure can be used.

1) copy the paging space files to external NFS server

On all the service nodes:

~~~~
   #rsync -az /install/nim/paging/71Bcosi_paging <external_nfs_server>:/install/nim/paging/
~~~~

Note: if the sparse_paging is used, simply copying the spare_paging files from AIX NIM master to external NFS server will lose the sparse characteristics for the files. To preserve the sparse characteristics for the spare_paging files, you can use either commands backup and restore, or pax. If the external NFS server is running Linux, the AIX restore command can not be run on it, you can mount Linux directories from AIX server, and then run restore on AIX to restore the files into the Linux NFS directory. Here is an example on how to use pax to preserve the sparse characteristics.

    On AIX NIM master:

~~~~
        cd /install/nim/paging/<node_range> -p postscripts=redirectps
~~~~



**4\. Setup NFS on the external NFS server**

Since all the root directories for all the nodes should be exported, so there will be a lot of NFS export entries on the external NFS server, a simple way is to put the content of all the /etc/exports files on all the service nodes into the /etc/exports file on the external NFS server and then run exports -a to export all the required directories.

### **AIX shared_root stateless**

**1\. SPOT**

Use lsnim -l &lt;spot_name&gt; to get the location of the SPOT, for example, /install/nim/spot/71Bcosi/usr, copy the whole directory to the external NFS server. For one AIX stateless image, the SPOT resource is the same across all the service nodes, so only needs to copy the SPOT from one service node to the external NFS server. Here is an example:

On one service node:

#rsync -az --delete /install/nim/spot/71Bsharedrootcosi/usr <external_nfs_server>:/install/nim/spot/71Bsharedrootcosi/

**2\. shared_root**

Use lsnim -l &lt;shared_root_name&gt; to get the location of the root resource, for example, /install/nim/root/71Bcosi_root. For the shared_root stateless configuration, all the nodes share the same shared_root resource, but the shared_root resource will be updated for each node when running mkdsklsnode, all the updates for specific nodes are under the etc/.client_data subdirectory in the shared_root directory, so we can copy the shared_root resource from one service node to the external NFS server, and then copy all the etc/.client_data subdirectories from all the service nodes to the external NFS server. Here is an example:

Here is an example:

On one service node:

~~~~
   #rsync -az --delete /install/nim/shared_root/71Bsharedrootcosi_shared_root <external_nfs_server>:/install/nim/shared_root/
~~~~

On all the service nodes:

~~~~
  # rsync -az --delete /install/nim/shared_root/71Bsharedrootcosi_shared_root/etc/.client_data <external_nfs_server>:/install/nim/shared_root/71Bsharedrootcosi_shared_root/etc/
~~~~

**3.(Optional) Paging Space**

It is not required to put paging space resource on external NFS server, the paging space will not cause system crash in most of the scenarios, but if you want to put paging space resource on external NFS server, the following procedure can be used.

1) copy the paging space files to external NFS server

On all the service nodes:

~~~~
#rsync -az /install/nim/paging/71Bcosi_paging <external_nfs_server>:/install/nim/paging/
~~~~

Note: if the sparse_paging is used, simply copying the spare_paging files from AIX NIM master to external NFS server will lose the sparse characteristics for the files. To preserve the sparse characteristics for the spare_paging files, you can use either commands backup and restore, or pax. If the external NFS server is running Linux, the AIX restore command can not be run on it, you can mount Linux directories from AIX server, and then run restore on AIX to restore the files into the Linux NFS directory. Here is an example on how to use pax to preserve the sparse characteristics.

    On AIX NIM master:

~~~~
        cd /install/nim/paging/<node_range> -p postscripts=redirectps
~~~~


**4\. Setup NFS on the external NFS server**

All the nodes will use the same shared_root directory, so only one NFS exports entry is required for the shared_root configuration, however, the NFS exports options are different on each service node, for example, the .root=. and the .access=. are used to specify the nodes list served by each servicde node, so you still need to put the content of all the /etc/exports files on all the service nodes into the /etc/exports file on the external NFS server and then run exports -a to export all the required directories.

### **AIX statelite**

AIX statelite is actually the shared_root stateless plus .overlay. for specific files or directories through the information in tables **statelite**, **litefile** and **litetree**. So the external NFS support for AIX statelite is similar with the shared_root stateless configuration, except that the considerations for the information in tables **statelite**, **litefile** and **litetree**.


**statelite table**

The .statemnt. column in the statelite table specifies the persistant read/write area where a node's persistent files will be written to, the persistent files are usually critical for applications running on the nodes, so it is recommended to point the .statemnt. to the external NFS server, the variable $noderes.nfsserver can be used in the statelite table to specify that the node's attribute .nfsserver. is the external NFS server. Here is an example of the statelite table:

~~~~
    node,image,statemnt,comments,disable
    "aixcn1",,"$noderes.nfsserver:/stateliteroot",,
~~~~

Make sure you NFS export any directories that are listed in this table with read-write permission on the external NFS server before attempting to boot the nodes.


**litefile table**

The litefile table specifies the directories and files for the statelite setup along with the option to use to do the setup. All the directories specified in the liefile table should also be created and set to correct permission on the external NFS server before attempting to boot the nodes.

**litetree table**

The litetree table controls where the initial content of the files in the litefile table come from, and the long term content of the .ro. files. If any directories in this table point to the external NFS server, make sure you NFS export them on the external NFS server before attempting to boot the nodes.

