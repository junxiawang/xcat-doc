<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Back up the NIM and xCAT databases](#back-up-the-nim-and-xcat-databases)
  - [**NIM**](#nim)
  - [**XCAT**](#xcat)
- [Shut down any diskless nodes that are being served by the management node](#shut-down-any-diskless-nodes-that-are-being-served-by-the-management-node)
- [Upgrade xCAT](#upgrade-xcat)
  - [**Upgrade xCAT on the management node**](#upgrade-xcat-on-the-management-node)
    - [**Shut down xCAT**](#shut-down-xcat)
    - [**Download and install the latest xCAT dependency software**](#download-and-install-the-latest-xcat-dependency-software)
    - [**Download and install the latest xCAT database software**](#download-and-install-the-latest-xcat-database-software)
    - [**Install the latest xCAT packages**](#install-the-latest-xcat-packages)
    - [**Restart and verify xCAT**](#restart-and-verify-xcat)
  - [**Upgrade xCAT on service nodes**](#upgrade-xcat-on-service-nodes)
    - [**Copy the new rpms to the NIM lpp_source directories**](#copy-the-new-rpms-to-the-nim-lpp_source-directories)
    - [**Update the NIM installp_bundle resources**](#update-the-nim-installp_bundle-resources)
    - [**Check the osimage (optional)**](#check-the-osimage-optional)
    - [**Run the updatenode command to install the softwar**e](#run-the-updatenode-command-to-install-the-software)
    - [**Verify xCAT on the service nodes**](#verify-xcat-on-the-service-nodes)
- [Migrate the management node to a new version of AIX](#migrate-the-management-node-to-a-new-version-of-aix)
  - [**Verify xCAT and NIM on the management node**](#verify-xcat-and-nim-on-the-management-node)
- [Upgrade the xCAT service nodes to the new OS version](#upgrade-the-xcat-service-nodes-to-the-new-os-version)
  - [**Create a new xCAT osimage for the service nodes**](#create-a-new-xcat-osimage-for-the-service-nodes)
  - [**Modify the bosinst_data resource to do a migration instal**l](#modify-the-bosinst_data-resource-to-do-a-migration-install)
  - [**Copy new rpms to the NIM lpp_source**](#copy-new-rpms-to-the-nim-lpp_source)
  - [**Update the service node bundles**](#update-the-service-node-bundles)
  - [**Verify the osimage**](#verify-the-osimage)
  - [**Shut down the diskless clients of the service nodes**](#shut-down-the-diskless-clients-of-the-service-nodes)
  - [**Initialize the service nodes**](#initialize-the-service-nodes)
  - [**Initiate a network install**](#initiate-a-network-install)
  - [**Verify the service node**](#verify-the-service-node)
- [Phase two of xCAT upgrade](#phase-two-of-xcat-upgrade)
- [Upgrade the xCAT compute nodes](#upgrade-the-xcat-compute-nodes)
  - [**Installing AIX standalone nodes (using NIM rte method)**](#installing-aix-standalone-nodes-using-nim-rte-method)
  - [**Booting AIX diskless nodes (using stateless method)**](#booting-aix-diskless-nodes-using-stateless-method)
  - [**Cloning AIX nodes ( using AIX mksysb images**)](#cloning-aix-nodes--using-aix-mksysb-images)
  - [**Using xCAT Service Nodes with AIX**](#using-xcat-service-nodes-with-aix)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document describes a recommended process to follow when you wish to upgrade the versions of AIX and xCAT that you are using in your xCAT cluster.


**Note:** The AIX OS level is indicated by a "Version.Release.Modification.Fix" number. (ex. VRMF). For example, an AIX operating system version upgrade would be moving from AIX 5.3.0.0 to AIX 6.1.0.0.


If you only want to update your OS release, modification, or fix level you can simple apply the software updates to the management node using the standard AIX tools. (Ex. AIX 6.1.0.0 to 6.1.5.0 etc.) A re-install or a migration install would not be needed.


To upgrade the management node you have the option of doing a complete new overwrite install or doing a migration installation.


The advantage of an operating system migration installation compared to a new and complete overwrite is that most filesets are preserved. This includes almost all directories, such as /home, /var, /usr, the root volume group, logical volumes, system configurations and previously installed software. The only file system that will be new after the migration is /tmp. You can easily avoid loosing information you
have stored in this directory by copying the important information to another
directory before the migration and move it back afterwards. Additionally, after the
migration, you can import your user volume groups. It is probably the easiest way
to upgrade your system while maintaining all customized information and configuration. Another advantage, especially if you need to minimize the downtime of your system, is that there are fewer reconfigurations tasks to do after the migration.


During a migration, the installation process determines which optional software products are installed on the existing version of the operating system. Any software that was previously installed that has new versions available will be updated.


Before you perform a migration installation, ensure you have reliable backups of your data and any customized applications or volume groups. In particular, on an xCAT management node you should back up your xCAT and NIM databases.


The process described below assumes you are familiar with AIX systems administration and NIM.

## Back up the NIM and xCAT databases

When doing a migration of the operating system the NIM and xCAT databases would normally be preserved. HOWEVER, as a precaution it would be good to back them up and save them on some other system - just in case.

### **NIM**

Using the SMIT interface:




~~~~
    smit nim_backup_db
~~~~



Using the command line interface:


(Assuming the data is saved in /tmp/mynim.backup.)




~~~~
    /usr/lpp/bos.sysmgt/nim/methods/m_backup_db /tmp/mynim.backup
~~~~



The files that are backed up include:

~~~~
    ./etc/objrepos/nim_attr
    ./etc/objrepos/nim_attr.vc
    ./etc/objrepos/nim_object
    ./etc/objrepos/nim_object.vc
    ./etc/NIM.level
    ./etc/niminfo
~~~~



To restore the database you can use:




~~~~
    smit nim_restore_db
~~~~



or




~~~~
    /usr/lpp/bos.sysmgt/nim/methods/m_restore_db /tmp/mynim.backup
~~~~


### **XCAT**

The **dumpxCATdb** command creates .csv (comma separated value) files for all xCAT database tables and puts them in the directory given by the -p flag. These files can be used by the **restorexCATdb** command to restore the database.




~~~~
    dumpxCATdb -p /tmp/db
~~~~


## Shut down any diskless nodes that are being served by the management node

Any diskless nodes that are clients of the management node will not be able to continue running when the management node is not available.


It is better to shut down the diskless nodes while the management node is being updated.


For example, asuming all your diskless nodes are in the xCAT group called "dsklsnodes" then you could shut them all down by running the following command.




~~~~
    xdsh dsklsnodes "shutdown -F &"
~~~~



Any standalone nodes that are clients of the management node can be left running.

## Upgrade xCAT

You may or may not need to upgrade xCAT as part of an OS migration.


The one requirement is that the version of xCAT you use must support BOTH the current OS version and the version you wish to migrate to.


In some cases you may need to upgrade xCAT in two phases. The first upgrade may be needed to migrate to a newer OS version using an xCAT version that supports both. The second phase would be to upgrade xCAT to the latest version.


Whether you need to upgrade xCAT or not, you must upgrade the versions of the xCAT dependency and database rpms to the versions that were built for the new AIX level.


The xCAT dependency and database tarballs contain versions of the rpm packages built for the different levels of AIX. So, for example, if you migrate your OS to AIX 7.1 then you must also update your dependency rpms to the versions built for AIX 7.1. The xCAT dependency and database packages contain subdirectories corresponding to the different AIX versions.


**Note: **If you upgrade the xCAT version on the xCAT management node you must also upgrade the xCAT version on any service nodes that are being used!




### **Upgrade xCAT on the management node**

#### **Shut down xCAT**

xCAT should be shut down before trying to do any upgrades.

~~~~
     stopsrc -s xcatd
~~~~


#### **Download and install the latest xCAT dependency software**

Download the latest dep-aix-*.tar.gz tar file from http://xcat.sourceforge.net/#download and copy it to a convenient location on your xCAT management node.


Unwrap the tar file. For example:

~~~~
    gunzip dep-aix-2.5.tar.gz
    tar -xvf dep-aix-2.5.tar
~~~~


Run the **instoss **script (contained in the tar file) to install the OSS

packages. Please make sure the /opt and the other file systems have

enough disk space to install these OSS packages before running the instoss script.





#### **Download and install the latest xCAT database software**

Some of the optional databases that you may be using with xCAT will require upgrades to the dependency software.


XCAT currently supports SQLite, MySQL, PostgreSQL, and DB2. As a convenience, the xCAT site provides downloads for MySQL and PostreSQL software.

( [xcat-postgresql-snap201007150920.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-postgresql-snap201007150920.tar.gz/download) and [xcat-mysql-201005260807.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-mysql-201005260807.tar.gz/download) )


See the following xCAT documents for instructions on how to upgrade these databases.

[Setting_Up_MySQL_as_the_xCAT_DB]

[Setting_Up_PostgreSQL_as_the_xCAT_DB]

[Setting_Up_DB2_as_the_xCAT_DB]


The database tar files that are available on the xCAT web site may contain multiple versions of RPMs - one for each AIX operating system level. You must install the versions of the rpms that correspond to your OS version.




#### **Install the latest xCAT packages**

Download the latest xCAT for AIX tar file from

http://xcat.sourceforge.net/#download and copy it to a convenient location on your xCAT management node.


Unwrap the xCAT tar file. For example,

~~~~
    gunzip core-aix-2.5.tar.gz
    tar -xvf core-aix-2.5.tar
~~~~


Run the **instxcat **script (contained in the tar file) to install the xCAT

software. (The **instxcat **script and all the RPMs are located in the xcatcore

subdirectory.) The instxcat script should only be used on the Management Server, not on Service Nodes.

#### **Restart and verify xCAT**

To restart xCAT run the following command.

~~~~
    restartxcatd
~~~~



To verify xCAT function try running some basic xCAT commands.




  * Run "rpm -qa" to see if the latest xCAT and dependency software is upgraded.
  * Run the "lsdef -h" to check if the xCAT daemon is working. (If you get a correct response then you should be Ok. )
  * Check the xCAT database.
  * Try running some commands such as: "**lsdef -t site -l**"
  * If necessary you can restore the database you saved earlier by running the **restorexCATdb** command.

### **Upgrade xCAT on service nodes**

#### **Copy the new rpms to the NIM lpp_source directories**

To update the versions of xCAT and the dependency packages on the service nodes you must first copy all the new rpms to the lpp__source resource that is being used for the service nodes. This includes the new xCAT, dependency, and database rpms. These are all available in the xCAT tarballs that you download from the xCAT web site.

A simple way to copy software to the lpp_source locations is to use the "nim -o update" command. With this NIM command you simply need to provide the name of the NIM lpp_source resource and it will automatically copy your files to the correct locations.

For example, assume all your dependency software has been downloaded and unwrapped in the temporary location /tmp/images. (The rpms you need are in subdirectories corresponding to the OS version you are running.)

To add all the deps packages to the lpp_source resource named "61image_lpp_source" you could run the following command:

~~~~
     nim -o update -a packages=all -a source=/tmp/images/xcat-dep/6.1
     610imagelpp_source_**
~~~~


The NIM command will find the correct directories and update the lpp_source resource.

#### **Update the NIM installp_bundle resources**

Make sure that any NIM _installp_bundle resources you are using are updated to contain the new xCAT, dependency and database packages.


If you have an xCAT osimage defined for the service nodes it will include an installp_bundle file that contains a list of all the additional software that is needed on the service nodes. You must check this file to make sure it includes the new rpms that you just copied to your lpp_source.


The new sample xCAT bundle files are located either in the new tarball or installed in /opt/xcat/share/xcat/installp_bundles.




#### **Check the osimage (optional)**

To avoid potential problems when installing additional software it is adviseable to verify that all the software that you wish to install has been copied to the appropriate NIM lpp_source directory and that there are no duplicate packages.

Any software that is specified in the "otherpkgs" or the "installp_bundle" attributes of the osimage definition must be available in the corresponding lpp_source directories.

Also, since the sample bundle files now include wildcards (*) instead of specific versions you must make sure there are not multiple version of the same rpm in the lpp_source directories. If there are mutliple version of the same rpm in the lpp_source directory then NIM will produce an error when trying to install them.


The older versions of the rpms must be removed from the lpp_source directory.


This can be done manually by going to the lpp_source location and then to the "RPMS/ppc" subdirectory and then removing the rpms.


However, starting in xCAT 2.4.3 you can use the **chkosimage** command to check the lpp_source directories and remove the older versions.


To check an osimage called 610image:

~~~~
    chkosimage -V 610image
~~~~


To check an osimage and remove duplicate rpms:




~~~~
    chkosimage -V -c 610image
~~~~



See the **chkosimage** man page for details.




#### **Run the updatenode command to install the softwar**e

You can update the versions of the xCAT, dependency, and database software on the service nodes by using the **updatenode** command.


By default the command will use the "installp_bundle" and "otherpkgs" attributes of the osimage definition for the node.


In the following example assume that all the service nodes have been added to the xCAT group called "service" and that the specified flags should be used when installing the packages.




~~~~
    updatenode service -V -S rpm_flags="-Uvh --replacepkgs -nodeps" installp_flags="-agQXY"
~~~~





#### **Verify xCAT on the service nodes**

  1. Run "rpm -qa" on service node to see if the xCAT and dependency software is upgraded.
  2. Try running some xCAT commands such as "lsdef -a" to see if the xcatd daemon is running and if data from xCAT database is set properly.
  3. Check the NIM configuration on the service nodes
  4. Run xdsh to the service nodes (ex. "xdsh service date")

## Migrate the management node to a new version of AIX

There are several techniques provided by AIX that can be used to migrate a standalone system. They are described in the AIX documentation listsed below and will not be repeated here.


Listing of AIX documents.

~~~~
 http://publib.boulder.ibm.com/infocenter/aix/v7r1/index.jsp
~~~~


AIX "Installation and Migration Guide":

~~~~
 http://publib.boulder.ibm.com/infocenter/aix/v7r1/topic/com.ibm.aix.install/doc/insgdrf/insgdrf_pdf.pdf
~~~~




### **Verify xCAT and NIM on the management node**

Check that xCAT is still functioning properly on the management node. (ex. run some xCAT commands, check the database etc.)


If xCAT isn't running or some dependency packages may not be functioning.

Run the **instoss **script (contained in the tar file) to re-install the OSS

packages corresponding to the OS version you are running, or run "rpm -Uvh" or "rpm -Uvh --force" to upgrade the single package.


Run 'restartxcatd' to restart xCAT


Depending on the method you used to do the AIX migration, the NIM master on the xCAT management node may or may not be functioning.


If it is not:

  * Check that the master fileset is installed and that it has been updated to the latest level. ( bos.sysmgt.nim.master ). This should have been in your lpp_source directory and also in the service node bundle file.

  * Save the current /etc/niminfo file


~~~~
    mv /etc/niminfo /etc/niminfo.orig
~~~~



  * Reconfigure NIM.You could use the SMIT interface or the **nimconfig** command to re-configure NIM. (Note: Make sure you specify the appropriate interface to use as the NIM primary interface. Typically the interface that will be used to install the nodes is used as the primary interface.) The **nimconfig** command would be similar to the following:


~~~~
    nimconfig -a pif_name=en1 -a netname=clstr_net -r
~~~~



  * It should not be required, but you can restore the previously saved NIM database backup by using SMIT:





~~~~
    smit nim_restore_db
~~~~



or by using the following NIM method.




~~~~
    /usr/lpp/bos.sysmgt/nim/methods/m_restore_db /tmp/mynim.backup
~~~~


  * Validate existing NIM resources.
  * Make sure the NIM definitions are correct, that the files and directories all exist etc.
  * Run the "nim -o check ..." operation on NIM SPOT and lpp_source resources.

## Upgrade the xCAT service nodes to the new OS version

If you migrate your xCAT management node to a new OS version then any service nodes you are using should also be upgraded.


Since the AIX service nodes are standalone systems they can remain running while you update the management node. However if you leave the service nodes at back levels it could cause problems with the xCAT support.


For more details on installing a service node refer to the following xCAT document.


[Setting_Up_an_AIX_Hierarchical_Cluster]




### **Create a new xCAT osimage for the service nodes**

Use the xCAT **mknimimage** command to create a new osimage definition using the new AIX OS version.


For example, assuming all the AIX software has been copied to **/**aix61source you could run:




~~~~
    mknimimage -s /aix61source AIX61image
~~~~



This will create the required NIM resources as well as the new xCAT osimage definition.


Make sure you update your osimage definition with any other resources or attributes you wish to include. (Such as the service node installp_bundle resource etc.) Refer to the "xCAT2onAIXServiceNodes" document mentioned above for further details.

### **Modify the bosinst_data resource to do a migration instal**l

By doing a migration install, among other things, you will preserve the NIM database and NIM resources that were created on the service nodes.


A default NIM bosinst_data resource was created automatically when you created the new osimage.


A **bosinst_data** resource represents a file that contains information for the BOS installation program. The resource is typically created by starting with the template that is shipped with AIX. See the /usr/lpp/bosinst/bosinst.template.README file for more information on bosinst_data file contents.


To perform a migration install you must make one change to the file.


You must change the "INSTALL_METHOD" value to "migrate".


This can be changed in the file either before or after you define the resource but it must be done before initiating a network boot of the system.

### **Copy new rpms to the NIM lpp_source**

There are new versions of the xCAT, dependency , and database rpms that must be copied to the new lpp_source resource created in the previous step.


These rpms were all contained in the xCAT tarballs you downloaded when you upgraded the management node.


A simple way to copy software to the lpp_source locations is to use the "nim -o update" command. With this NIM command you simply need to provide the name of the NIM lpp_source resource and it will automatically copy your files to the correct locations.

For example, assume all your dependency software has been downloaded and unwrapped in the temporary location /tmp/images. (The rpms you need are in subdirectories corresponding to the OS version you are running.)

To add all the deps packages to the lpp_source resource named "610new_lpp_source" you could run the following command:

To copy the rpms to the correct location in the lpp_source you can use the " **nim -o update .." **command.


For example:




~~~~
    nim -o update -a packages=all -a source=/tmp/images/xcat-dep/6.1 610new_lpp_source
~~~~



The NIM command will find the correct directories and update the lpp_source resource.

### **Update the service node bundles**

XCAT ships sample NIM installp_bundle files. (See /opt/xcat/share/xcat/installp_bundles) There are bundle files to use for the service nodes and bundle files to use for the compute nodes. When you switch to a new OS version you must use the corresponding version of the bundle files.


For example, if you are now using AIX 6.1 then you need to use the xCATaixSN61.bnd file when installing the service node.


Copy the bundle file to an exportable location (ex. /install/nim/installp_bundle) and define the NIM installp_bundle resource using SMIT or the "nim -o define ..." command.


Once the resource is defined you must add it to the osimage definition.




~~~~
    chdef -t osimage -o AIX61image installp_bundle=xCATaixSN61
~~~~



Check the contents of the bundle file to make sure it includes all the software you will need. There are some commented-out entries that are optional that you may need. For example, the additional rpms needed for the different databases that you may be using.

### **Verify the osimage**

You can use the xCAT **chkosimage** command to check that all the software called out in the bundles files are included in the lpp_source resource.




~~~~
    chkosimage AIX61image
~~~~


### **Shut down the diskless clients of the service nodes**

It is recommended that you shut down all diskless clients of the service nodes before upgrading them. Any standalone clients may be left running.


For example, to shut down the diskless compute node named "compute02" you could run the following command.




~~~~
    xdsh compute02 "shutdown -F &"
~~~~


### **Initialize the service nodes**

You can use the xCAT **nimnodeset** command to initialize the AIX standalone service nodes. This command uses information from the xCAT osimage definition and default values to run the appropriate NIM commands.


For example, to set up all the nodes in the group "service" to install using the osimage named "610SNimage" you could issue the following command.




~~~~
    nimnodeset -i 610SNimage service
~~~~


### **Initiate a network install**

Initiate a remote network boot request using the xCAT **rnetboot** command. For example, to initiate a network boot of all nodes in the group "service" you could issue the following command.

~~~~
rnetboot service
~~~~

**Result:**

The service node will be installed with the new OS and new rpms specified in the bundle files. The xCAT posts scripts will do the xCAT setup and configure the system as a service node.




### **Verify the service node**

  1. Run "rpm -qa" on service node to see if the dependency software is upgraded.
  2. Try running some xCAT commands to see if xcatd daemon is running.
  3. Run xdsh to the service nodes (ex. "xdsh service date")
  4. Check the NIM configuration on the service nodes

## Phase two of xCAT upgrade

If you had to use a back-level version of xCAT to do your OS migration you can now upgrade xCAT to the most recent level. (For example, if you had to use xCAT 2.4 to handle the OS migration but now you wish to upgrade to xCAT 2.5.)


Use the same proceedure mentioned in the "Update xCAT" section above.

## Upgrade the xCAT compute nodes

The details for upgrading compute nodes is covered in several other xCAT documents.


If you have a large number of compute node to upgrade you may wish to use the xCAT rolling update support. See the **rollupdate** man page for usage details. Also available is the rollupdate doc: [Rolling_Update_Support].




### **Installing AIX standalone nodes (using NIM rte method)**

[XCAT_AIX_RTE_Diskfull_Nodes]

### **Booting AIX diskless nodes (using stateless method)**

[XCAT_AIX_Diskless_Nodes]

### **Cloning AIX nodes ( using AIX mksysb images**)

[XCAT_AIX_mksysb_Diskfull_Nodes]

### **Using xCAT Service Nodes with AIX**

[Setting_Up_an_AIX_Hierarchical_Cluster]


