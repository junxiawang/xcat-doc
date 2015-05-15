<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Install AIX on alternate disk/disks](#install-aix-on-alternate-diskdisks)
  - [Install the prerequisites on NIM client](#install-the-prerequisites-on-nim-client)
  - [Install AIX using NIM alternate disk installation](#install-aix-using-nim-alternate-disk-installation)
    - [**Install AIX mksysb image on alternate disk**](#install-aix-mksysb-image-on-alternate-disk)
    - [**Clone the current disk onto alternate disks and apply updates**](#clone-the-current-disk-onto-alternate-disks-and-apply-updates)
    - [**Alternate disk migration via nimadm command**](#alternate-disk-migration-via-nimadm-command)
      - [**nimadm migration operation**](#nimadm-migration-operation)
      - [**nimadm cleanup operation**](#nimadm-cleanup-operation)
      - [**nimadm wake-up and sleep**](#nimadm-wake-up-and-sleep)
- [**Reboot the NIM client**](#reboot-the-nim-client)
- [**Important Notice**](#important-notice)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This .How-To. illustrates how to use NIM alternate disk installation feature in xCAT cluster.

NIM is an AIX tool that enables a cluster administrator to centrally manage the installation and configuration of AIX and optional software on machines within a networked environment. NIM allows you to install an AIX Operating System on a NIM client's alternate disk for system update, migration or maintenance. Because the client system is running during installation, less time is required than for a normal installation.

For example, in xCAT cluster, if you want to do software maintenance or AIX OS migration for service nodes or compute nodes, to reduce the maintenance window, you can use the AIX alternate disk installation/migration feature.

This document assumes you are somewhat familiar with NIM. For more information about NIM, see the IBM AIX Installation Guide and Reference. (http://www-03.ibm.com/servers/aix/library/index.html)

Before starting this process it is assumed you have completed the following.

  * An AIX system has been installed to use as an xCAT management node.
  * The cluster network is configured. (The Ethernet network that will be used to perform the network boot of the nodes.)
  * xCAT and prerequisite software has been installed and configured on the management node.
  * The NIM master must be configured.
  * The NIM client must already exist in the NIM environment and must be running. To install a NIM client using xCAT, please see [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]
  * The client must have a disk (or disks) large enough to store the new system. The total amount of required space will depend on original system configuration and migration customization.

## Install AIX on alternate disk/disks

### Install the prerequisites on NIM client

To support NIM alternate disk installation feature, you need to install **bos.alt_disk_install** fileset on the target NIM client first. This fileset can either be installed during the initial installation of the NIM client via specified in the installp_bundle file, or be installed via **updatenode** command if the OS is ready installed.

For example:

If you want to install **bos.alt_disk_install** fileset via **updatenode** command. You can add **bos.alt_disk_install** fileset name in your installlp_bundle file, and make sure this installp_bundle is specified in the xCAT osimage definition which is used by your target node. Then run **updatenode** for your target node. For more information about **updatenode** command, please see the man page of **updatenode**.

### Install AIX using NIM alternate disk installation

We support 3 scenarios for the alternate disk installation.

  * To install a mksysb image (mksysb resource, AIX versions supported by xCAT) on a NIM client's alternate disk.
  * To clone a NIM client's current disk onto an alternate disk and apply updates.
  * To install alternate disk migration via nimadm (Network Install Manager Alternate Disk Migration)

#### **Install AIX mksysb image on alternate disk**

To install the mksysb image onto the NIM client.s alternate disks, you need to create the mksysb image first. xCAT **mknimimage** command can help you to achieve it.

For example:

To create a new mksysb osimage definition via **mknimimage** command, you must specify either the "**-n**" or the "**-b**" option. The "**-n**" option can be used to create a mksysb image from an existing NIM client machine. The "**-b**" option can be used to specify an existing mksysb backup file.

~~~~
    mknimimage -m mksysb -n node1 newsysb spot=myspot bosinst_data=mybdata
~~~~


This command will use node1 to create a mksysb backup image and use that to define a NIM mksysb resource newsysb. The osimage definition will contain the name of the mksysb resource as well as the spot and bosinst_data resource.

OR

~~~~
    mknimimage -m mksysb -b /tmp/backups/mysysbimage newsysb spot=myspot bosinst_data=mybdata
~~~~


This command defines a NIM mksysb resource using the existing mksysbimage.

After the new mksysb image is created, you can use the NIM **alt_disk_install** feature to install this mksysb image into the alternate disks.

The command line syntax for the **alt_disk_install mksysb** operation is as follows:

~~~~
    nim -o alt_disk_install -a source=mksysb -a mksysb=mksysb_resource  -a disk=target_disk(s) -a attribute=Value.... TargetName |TargetNames
~~~~


For example:

~~~~
    nim -o alt_disk_install -a source=mksysb -a mksysb=newsysb -a disk=hdisk2 -a set_bootlist=yes node1
~~~~


This command creates **altinst_rootvg** based on hard disk hdisk2, using mksysb image newsysb, and set the bootlist to hdisk2 automatically.

**Note:** if the NIM master is configured on the xCAT Service Nodes, you can use xCAT xdsh to execute nim commands.

**Note:** The target of an **alt_disk_install** operation can be a standalone NIM client or a group of standalone NIM clients. You can use xCAT **xcat2nim** command to create the corresponding NIM groups which can be used in the NIM commands above.

For more information about the NIM **alt_disk_install** usage, please see AIX documentation - [Using the NIM alt_disk_install operation](http://publib.boulder.ibm.com/infocenter/pseries/v5r3/topic/com.ibm.aix.install/doc/insgdrf/nim_op_alt_disk_install.htm?resultof=%22%61%6c%74%5f%64%69%73%6b%22%20).

#### **Clone the current disk onto alternate disks and apply updates**

NIM supports cloning the **rootvg** to a NIM client's alternate disks and applying updates if needed. So before the **rootvg alt_disk_install**, you need to add additional installation resources (filesets, rpms, efixes) to the lpp_source used by the NIM client.

The command line syntax for the **alt_disk_install rootvg** clone operation is as follows:

    nim -o alt_disk_install -a source=rootvg -a disk=target_disk(s)  -a attribute=Value.... TargetName |TargetNames


The optional attributes that can be specified only for the **alt_disk_install rootvg** clone operation are **exclude_files, filesets, fixes, fix_bundle, installp_bundle, installp_flags**. For more information about the NIM **alt_disk_install** usage, please see AIX documentation - [Using the NIM alt_disk_install operation](http://publib.boulder.ibm.com/infocenter/pseries/v5r3/topic/com.ibm.aix.install/doc/insgdrf/nim_op_alt_disk_install.htm?resultof=%22%61%6c%74%5f%64%69%73%6b%22%20).

For example:

To clone the **rootvg** to the alternate disk hdisk2 on node1 and update the filesets listed in the installpbundle mybundle1, you can use the command below:

~~~~
    nim -o alt_disk_install -a source=rootvg -a disk=hdisk2 node1
~~~~


If you want to keep a record in xCAT DB for the **alt_disk_install** **rootvg** operation, we recommend you create a copy of the current osimage on the management node, add the updates to the lpp_srouce and create the installp_bundles etc. This way you can have an osimage that corresponds to the one on the alternate disk.

You can display the alternate disk installation status while the installation is progressing, enter the following command on the master:

~~~~
    lsnim -a info -a Cstate <ClientName>
~~~~


OR

~~~~
    lsnim -l <ClientName>
~~~~


OR

    Check the log file **/var/adm/ras/alt_disk_inst.log** on target NIM client.


#### **Alternate disk migration via nimadm command**

The **nimadm** (Network Install Manager Alternate Disk Migration) command is a utility that allows the system administrator to do the following:

  * Create a copy of rootvg to a free disk (or disks) and simultaneously migrate it to a new version or release level of AIX.
  * Using a copy of rootvg, create a new NIM mksysb resource that has been migrated to a new version or release level of AIX.
  * Using a NIM mksysb resource, create a new NIM mksysb resource that has been migrated to a new version or release level of AIX.
  * Using a NIM mksysb resource, restore to a free disk (or disks) and simultaneously migrate to a new version or release level of AIX.

The **nimadm** command uses NIM resources to perform these functions. Compared with the **mksysb alt_disk_install** operation and the **rootvg alt_dsik_install** operation, the alternate disk migration installation has some specific requirements.

  1. Configured NIM master running AIXÂ® 5.1 or later with AIX recommended maintenance level 5100-03 or later.
  2. The NIM master must have **bos.alt_disk_install.rte** installed in its **rootvg** and the **SPOT** which will be used.
  3. The level of the fileset, which includes the **bos.alt_disk_install.rte** file and **bos.alt_disk_install.boot_images** file, on the NIM master **rootvg**, **lpp_source**, and **SPOT** must be at the same level.
  4. The client (the system to be migrated) must be at AIX 4.3.2 or later.
  5. The client must have a disk (or disks) large enough to clone the **rootvg** and an additional 500 MB (approximately) of free space for the migration. The total amount of required space will depend on original system configuration and migration customization.
  6. The client must be a registered NIM client to the master.
  7. The nim master must be able to execute remote commands on the client using the rshd protocol.
  8. The client must have a minimum of 256.512 MBs of memory.
  9. A reliable network, which can facilitate large amounts of NFS traffic, must exist between the NIM master and the client.
  10. The client's hardware should support the level it is migrating to and meet all other conventional migration requirements.

For information on the conventional migration installation method, see AIX documentation - [Migrating AIX](http://publib.boulder.ibm.com/infocenter/pseries/v5r3/index.jsp?topic=/com.ibm.aix.install/doc/insgdrf/bos_migration_installation.htm).

Before performing an alternate disk migration installation, you are required to agree to all software license agreements for software to be installed. You can do this by specifying the **-Y** flag as an argument to the alternate disk migration command or setting the **ADM_ACCEPT_LICENSES** environment variable to **yes**.

Please note that in this documentation, we only give an example of how to use nimadm to create a copy of rootvg to a free disk (or disks) and simultaneously migrate it to a new version or release level of AIX. For complete coverage of **nimadm** command, please refer to AIX documentation - [Commands Reference](http://publib.boulder.ibm.com/infocenter/pseries/v5r3/topic/com.ibm.aix.cmds/doc/aixcmds4/nimadm.htm?resultof=%22%6e%69%6d%61%64%6d%22%20)

##### **nimadm migration operation**

To execute **nimadm** migration to the target NIM client, you must create the NIM resources needed by this migration first. For example, if you want to do migration from AIX 6.1 to AIX 7.1, you need to create the **lpp_source** and **SPOT** for AIX 7.1. xCAT **mknimimage** command can help you to achieve this.

~~~~
    mknimimage -s /AIX/instimages 71image
~~~~


After the **lpp_source** and **SPOT** are available, to do alternate disk migration to the target NIM client aix1, using NIM **SPOT** resource 71spot1, NIM lpp_source resource 71lpp1, and target disks hdisk1 &amp; hdisk2. Note that the **-Y** flag agrees to all required software license agreements for software to be installed, type the following:

~~~~
    nimadm -c aix1 -s 71image -l 71image_lpp_source -d "hdisk1 hdisk2" .Y
~~~~


**Note:** There are some optional flags for **nimadm** command to customarize the migration installation, such as [ -a PreMigrationScript ], [ -b installp_bundle], [ -z PostMigrationScript], [ -e exclude_files], etc. Please refer to the man page of **nimadm** for details.

##### **nimadm cleanup operation**

This operation, indicated with the "**-C**" flag, is designed to clean up after a failed migration that for some reason did not perform a cleanup it self. It can also be used to clear a previous migration in order to perform a new migration.

For example:

To execute nimadm cleanup on client aix1, using NIM **SPOT** resource spot1, type the following:

~~~~
    nimadm -C -c aix1 -s spot1
~~~~


##### **nimadm wake-up and sleep**

After a migration completes, the **nimadm** command can be used to "wake-up" the migrated **altinst_rootvg** or the **original rootvg** (if booted from the migrated disk). The nimadm wake-up (**-W** flag) performs an **alt_disk_install** wake-up, NFS exports the /alt_inst file systems, and mounts them on the NIM master. The nimadm sleep function (**-S** flag) reverses the wake-up by unmounting the NIM master mounts, unexporting the /alt_inst file systems, and executing the **alt_disk_install** sleep function on the client.

## **Reboot the NIM client**

After the **alt_disk_install** is completed, you can choose to boot the target NIM client with the alternate disk or the original disk.

By default, the attribute of .**set_bootlist**. is set to **yes**, this means it will boot from the newly installed alternate disk after the target NIM client is rebooted, so if you want to keep the original bootlist setting, you can:

    Specify the attribute of .**set_bootlist**. to **no** in .nim .o alt_disk_install. command


OR

~~~~
    xdsh <ClientName> "bootlist -m normal hdisk0"
~~~~


To reboot the target NIM client:

~~~~
    xdsh <ClientName> "shutdown .Fr &"
~~~~


**Note:** After you rebooted the client with the alternate disk, we recommend you to update xCAT node definition for "provmethod" and "profile" attribute, so that you can know which osimage is running on your nodes from xCAT perspective. For example, if 71image is the new AIX image installed on your alternate disk of node1, after you rebooted the node with the alternate disk, you are recommended to update the node definition as below:

~~~~
    chdef -t node node1 profile=71image provmethod=71image
~~~~


## **Important Notice**

The alternate disk installation/migration operation itself documented in this documentation is the feature of AIX NIM, not xCAT. The AIX OS installed on the alternate disk (or disks) might not be managed by the xCAT DB, so we recommend you to update the .**usercomment**. attribute for the target node once it.s using the alternate disk (or disks) to keep a record of any changes that were made. For example, to record which osimage is on which disks, or any other changes that can not be covered by xCAT osimage or node definition.

For the latest information about AIX support, please visit [AIX Information Center](http://publib16.boulder.ibm.com/pseries/index.htm)



