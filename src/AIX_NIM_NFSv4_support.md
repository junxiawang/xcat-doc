<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Overview](#1%5C-overview)
- [2\. NFSv3 and NFSv4 coexistence?](#2%5C-nfsv3-and-nfsv4-coexistence)
- [3\. External Interface](#3%5C-external-interface)
  - [3.1 Migrate NFSv3 NIM resources to NFSv4](#31-migrate-nfsv3-nim-resources-to-nfsv4)
  - [3.2 Create new NFSv4 NIM resources](#32-create-new-nfsv4-nim-resources)
- [4\. Internal Logic](#4%5C-internal-logic)
  - [4.1 NFSv4 global settings](#41-nfsv4-global-settings)
  - [4.2 Migrate NFSv3 NIM resources to NFSv4](#42-migrate-nfsv3-nim-resources-to-nfsv4)
  - [4.3 Create new NFSv4 NIM resources](#43-create-new-nfsv4-nim-resources)
- [5\. Documentation updates](#5%5C-documentation-updates)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


## 1\. Overview

AIX V6.1 provides NFSv4 support for NIM environments. The AIX NFSv4 implementation introduces various enhancements over NFSv3: 

  * Built-in security features. 
  * Pseudo file system concept. 
  * NFS4 ACL. 
  * Better performance. 
  * Locking mechanisms are now part of the protocol itself. 

From xCAT perspective, NFSv4 support with AIX NIM can also benefit our customers from different aspects like better performance and security, and we have got requirements from our customer about the NFSv4 support with AIX NIM. The NFSv4 support with AIX NIM in xCAT is also a preparation for high availability service nodes with NFSv4 replication support. 

## 2\. NFSv3 and NFSv4 coexistence?

I did not find any formal statements in the AIX docs to indicate if the NFSv3 NIM resources and NFSv4 NIM resources can coexist on the same NIM master, according to the investigation I did, the NFSv3 NIM resources and NFSv4 NIM resources can coexist on the same NIM master. But the NFSv3 and NFSv4 coexistence will make the configuration be much more complex: 

  * No NIM resource can be shared between the NFSv3 clients and NFSv4 clients. 
  * The NFSv3 NIM resources and NFSv4 NIM resources can not be put into the same parent directory like /install/nim/bosinst_data, because this directory needs to be exported either through NFSv3 or through NFSv4. 
  * Considering the shared_root configuration, it will not be possible to share the shared_root between NFSv3 clients and NFSv4 clients. 
  * From xCAT users perspective, there are several xCAT predefined NIM resources bosinst_data, resolve_conf and scripts, these NIM resources will be created, shared and assigned by xCAT internally, should we have the user to specify different NFSv3/NFSv4 resources or have xCAT code handle the NFSv3/NFSv4 resources internally? Either way will make the configuration or code very complicated. 

Think it from another side, is it really necessary to have both NFSv3 and NFSv4 clients in the same cluster? I can not think of any scenario other than AIX 5.3/AIX 6.1/AIX7.1 coexistence, the AIX 5.3 clients do not support NFSv4 mounts, but the AIX 5.3 is fairly old and xCAT does not support it any more, so this is not a problem for xCAT. 

Based on the considerations mentioned above, xCAT will not support the NFSv3 NIM resources and NFSv4 NIM resources coexistence in the same cluster. If the user want to use NFSv4 in his cluster, he will have to update all existing NIM resources to NFSv4 using xCAT commands or NIM commands, or start the NIM NFSv4 setup from scratch. 

  


## 3\. External Interface

There are two major scenarios for NFSv4 NIM resources operation: migrate NFSv3 NIM resources to NFSv4 and create new NFSv4 NIM resources. The user interfaces for these two operations are listed below: 

### 3.1 Migrate NFSv3 NIM resources to NFSv4

xCAT already provided "mknimimage [-V] -u osimage_name [attr=val [attr=val ...]]" to update existing xCAT osimages, but the "-u" flag only works for diskless spot for now, we can expand the scope of "-u" flag to support update the existing osimages to NFSv4 with command "mknimimage [-V] -u osimage_name nfs_vers=4". 
    
     mknimimage [-V] -u osimage_name nfs_vers=4
    
    

  


### 3.2 Create new NFSv4 NIM resources

mknimimage command needs to know which NFS version should be used when creating NIM resources, a new site attribute UseNFSv4onAIX will be added, if the UseNFSv4onAIX is set to "yes" or "1", NFSv4 will be used. The default value of UseNFSv4onAIX is "no". 

When creating new NFSv4 osimage, xCAT will use some predefined resources like bosinst_data, resolve_conf and scripts, if these resources are not NFSv4 capable, print an error message to indicate that these resources should be updated to NFSv4. 
    
     chdef -t site UseNFSv4onAIX=yes
     mknimimage -t &lt;type&gt; -s &lt;source&gt; imagename
    

## 4\. Internal Logic

### 4.1 NFSv4 global settings

Before creating new NFSv4 NIM resources, there are some global NFSv4 settings should be done: 

1\. Change NFSv4 domain name 
    
     chnfsdom &lt;domain_name&gt;
    

2\. Let NIM know the NFSv4 domain name 
    
     nim -o change -a nfs_domain=&lt;domain_name&gt; master
    

### 4.2 Migrate NFSv3 NIM resources to NFSv4

Command "nim -o change -a -a nfs_vers=4 &lt;nim_resource_name&gt;" can be used to update the NIM resource. 

  


### 4.3 Create new NFSv4 NIM resources

Flag "-a nfs_vers=4" can be added to the "nim -o define" commands to define NFSv4 resources. 

## 5\. Documentation updates

We need to update AIX RTE diskful, mksysb diskful, stateless and statelite doc to indicate how to configure NFSv4 support with NIM, and how to migrate existing NIM resources to NFSv4. Probably use a transclude page. 
