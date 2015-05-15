<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Updating software for AIX diskless nodes](#updating-software-for-aix-diskless-nodes)
  - [**Create a new image**](#create-a-new-image)
    - [**Create a new image from different source**](#create-a-new-image-from-different-source)
    - [**Copy an existing image**](#copy-an-existing-image)
  - [**Update the image - SPOT**](#update-the-image---spot)
    - [**Add or update software**](#add-or-update-software)
    - [**Update system configuration files**](#update-system-configuration-files)
      - [**Manually**](#manually)
      - [**Using mknimimage**](#using-mknimimage)
    - [**Run commands in the SPOT using xcatchroot**](#run-commands-in-the-spot-using-xcatchroot)
  - [**Verify the new image (optional)**](#verify-the-new-image-optional)
  - [**Re-initialize the NIM diskless nodes**](#re-initialize-the-nim-diskless-nodes)
    - [Re-initializing a diskless node](#re-initializing-a-diskless-node)
    - [Re-initializing a diskless node with minimal downtime](#re-initializing-a-diskless-node-with-minimal-downtime)
      - [Creating alternate NIM machine definitions](#creating-alternate-nim-machine-definitions)
      - [Cleaning up old NIM definitions and resources](#cleaning-up-old-nim-definitions-and-resources)
  - [**Verify node readiness (optional)**](#verify-node-readiness-optional)
  - [**Initiate a network boot**](#initiate-a-network-boot)
  - [**Node OS update and backout with minimal downtime**](#node-os-update-and-backout-with-minimal-downtime)
    - [**Update nodes with a new OS image**](#update-nodes-with-a-new-os-image)
    - [**To back out the new image**](#to-back-out-the-new-image)
    - [**Recover the new osimage**](#recover-the-new-osimage)
    - [**Cleanup**](#cleanup)
- [Synchronizing configuration files](#synchronizing-configuration-files)
  - [**Create the synclist file**](#create-the-synclist-file)
  - [**Indicate the location of the synclist file**](#indicate-the-location-of-the-synclist-file)
  - [**Run updatenode to synchronize the files**](#run-updatenode-to-synchronize-the-files)
- [Running customization scripts](#running-customization-scripts)
- [Updating software on AIX standalone (diskfull) nodes](#updating-software-on-aix-standalone-diskfull-nodes)
  - [**Using the updatenode command**](#using-the-updatenode-command)
    - [**Copy software to the appropriate directories**](#copy-software-to-the-appropriate-directories)
    - [**Specify the names of the software to update**](#specify-the-names-of-the-software-to-update)
    - [**Run the updatenode command**](#run-the-updatenode-command)
  - [**Using the xdsh method**](#using-the-xdsh-method)
- [Getting software and firmware levels](#getting-software-and-firmware-levels)
  - [**Using the sinv command**](#using-the-sinv-command)
- [Creating a NIM installp_bundle resource](#creating-a-nim-installp_bundle-resource)
- [Using the rolling update support](#using-the-rolling-update-support)
- [**Upgrading xCAT on the management node**](#upgrading-xcat-on-the-management-node)
  - [**Download and install the prerequisite Open Source Software (OSS)**](#download-and-install-the-prerequisite-open-source-software-oss)
  - [Download and install the xCAT software](#download-and-install-the-xcat-software)
  - [**Verify the xCAT installation**](#verify-the-xcat-installation)
- [Upgrading xCAT on service nodes](#upgrading-xcat-on-service-nodes)
  - [**Define an xCAT software bundle.**](#define-an-xcat-software-bundle)
  - [**Download the new software**](#download-the-new-software)
  - [**Copy the new rpms to the NIM lpp_source directories**](#copy-the-new-rpms-to-the-nim-lpp_source-directories)
  - [**Remove the old xCAT rpms from the lpp_source location**](#remove-the-old-xcat-rpms-from-the-lpp_source-location)
  - [**Run the updatenode command to install the software**](#run-the-updatenode-command-to-install-the-software)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)




## Overview

There are various techniques that can be used to update the nodes of an xCAT cluster. This document describes some of the basic support that is provided for AIX nodes.

XCAT provides support for distributing configuration files, updating software and running customization scripts on the cluster nodes.

These will be described in separate sections although, in some cases, you could do all three by running one command (**updatenode**).

See the **updatenode** man page for for details and examples.


## Updating software for AIX diskless nodes

<u>To update an AIX diskless node with new or additional software you must modify the NIM SPOT resource (operating system image) that the node is using and then reboot the node with the new SPOT. You cannot install software on a running diskless node directly.</u>

This section describes how AIX diskless nodes can be updated using xCAT and AIX/NIM commands. It covers both the switching of the node to a completely different image or updated the current image. It is not meant to be an exhaustive presentation of all options that are available to xCAT/AIX system administrators.

Since you cannot modify a SPOT while a node is using it, you have basically two options. You can either stop all the nodes and then update the existing OS image, or, you can create a new updated image to use to boot the nodes.

Stopping the nodes to do the updates means the nodes will be unusable for some period of time and there will be no easy way to return to the previous image if necessary. For these reasons the procedure described in this "How-To" will focus on creating a new image and rebooting the nodes with that image. The new image could be a completely new operating system image or it could be a copy of the the existing image that you can update as needed.

### **Create a new image**

#### **Create a new image from different source**

In this case we create a new xCAT osimage definition with a new set of resources by running the xCAT **mknimimage** command with the source for the new resources. This is the same way you created the original xCAT osimage definition for the node.

When you run the command you must provide a source for the installable images. This can be the location of the source code or the name of another NIM lpp_source resource. You must also provide a name for the image you wish to create. This name will be used for the NIM SPOT resource definition as well as the xCAT osimage definition.

By default the NIM resources will be created in a subdirectory of /install/nim. You can use the "-l" option to specify a different location.

For example, to create a diskless image called "61dskls", using the AIX installation images in the /my-install-images directory as the source, you could issue the following command.

~~~~
  mknimimage -t diskless -s /my-install-images 61dskls
~~~~

(This operation could take a while to complete!)

The command will create new NIM lpp_source and SPOT resources. It will also create dump, paging, and root resources if needed. A new xCAT osimage definition will also be created, (called "61dskls"), which will contain the names of these resources.

You could also use the name of an existing NIM lpp_source resource as the source of a new osimage definition. For example, you could use a resource created for a previous osimage called 61dskls_lpp to create a whole new osimage called 61dskls_updt as follows.

~~~~
  mknimimage -t diskless -s 61dskls_lpp 61dskls_updt
~~~~

The **mknimimage** command will display the contents of the new xCAT osimage definition when it completes.

This new image can now be updated and used to boot the node.


#### **Copy an existing image**

You can use the **mknimimage** command to create a copy of an image. For example, if the name of the currently running image is 61dskls and you want make a copy of it to update, you could run the following command.

~~~~
  mknimimage -t diskless -i 61dskls 61dskls_updt
~~~~

If an "-i " value is provided then all the resources from the xCAT osimage definition (61dskls) will be used in the new osimage definition except the SPOT resource. The new SPOT resource will be copied from the one specified in the original definition and renamed using the new osimage name provided (61dskls_updt). A new xCAT osimage definition will also be created, called "61dskls_updt", which will contain the names of these resources.

This new image can now be updated and used to boot the node.


### **Update the image - SPOT**

<u>You must install any additional software you need, and make any required customizations to the image before you boot the nodes.</u>

You should not attempt to update a SPOT resource that is currently allocated to a node. If you need to update an allocated SPOT either you can shut down the nodes and deallocate the SPOT resource first or you can make a copy of the SPOT and update that. To check to see if the SPOT is allocated you could run the following command.

~~~~
  lsnim -l <spot_name>
~~~~

To shut down the nodes you can use **xdsh** to run "shutdown -F &amp;" on the nodes. You can use the xCAT **rmdsklsnode** command to deallocate the nodes resources and remove the node from the NIM database. This command will not remove the node from the xCAT database.

There are basically three types of updates you can do to a SPOT.

  1. Add or update software
  2. Modify system files.
  3. Run commands in the SPOT using **xcatchroot**.

#### **Add or update software**

You can use the xCAT "**mknimimage -u**" command to install **installp** filesets, **rpm** packages and **epkg** (the interim fix packages) in a SPOT resource.

Before running the **mknimimage **command you must add the new filesets and/or RPMs and/or epkg files to the lpp_source resource used to create the SPOT. If we assume the lpp_source location for 61dskls is /install/nim/lpp_source/61dskls_lpp_source.  The **installp** packages would go in: /install/nim/lpp_source/61dskls_lpp_source/installp/ppc, the RPM packages would go in: /install/nim/lpp_source/61dskls_lpp_source/RPMS/ppc, the epkg files will go in: /install/nim/lpp_source/61dskls_lpp_source_/emgr/ppc.

The easiest way to copy the software to the correct locations is to use the "**nim -o update** .." command. Just provide the directory that contains your software and the NIM lpp_source resource name. (ie. "61dskls_lpp_source").

If your new packages are in /tmp/myimages then you could run:

~~~~
  nim -o update -a packages=all -a source=/tmp/myimages 61dskls_lpp_source
~~~~

**Note:** If you do not use this command to update the lpp_source then make sure you update the .toc file by running "inutoc .".

Once the lpp_source has been updated you can use the **mknimimage** command to install the updates in the SPOT resource for this xCAT osimage.

There are two methods that may be used to specify the software to update.

The first is to set the "installp_bundle" and/or the "otherpkgs" attributes of the xCAT osimage definition you are using for the node.

The second is to specify one or both of these attribute values on the **mknimimage** command line.

Using the first method provides a record of what was updated which is stored in the xCAT database. This can be useful when managing a large cluster environment. The second method is more "ad hoc" but also can be more flexible.

The **mknimimage** command will either use the information in the database or the information on the command line - BUT NOT BOTH. If you specify information on the command line it will use that, otherwise it will use what is in the database.

The "installp_bundle" value can be a comma separated list of (previously defined) NIM installp_bundle resource names. The "otherpkgs" value can be a comma separated list of **installp** filesets and/or **rpm** package names and/or **epkg** file names. The packages must have prefixes of 'I:', 'R:', or 'E:', respectively. The "synclists" value is described below.

<u>If using the first method</u> you would add these values to an xCAT osimage using the xCAT **chdef** command. For example, to update the xCAT osimage definition called "my61dskls" you could run a command similar to the following:

~~~~
  chdef -t osimage -o my61dskls installp_bundle="mybndlres1,mybndlres2"
      otherpkgs="I:openssh.base,R:popt-1.7-2.aix5.1.ppc.rpm"
~~~~

Once the osimage definition is updated you can use the **mknimimage** command to apply those updates to the SPOT associated with that osimage.

~~~~
  mknimimage -u my61dskls
~~~~


If using the second method you would simply add the information to the mknimimage command line. If you provide one or more of the "installp_bundle", "otherpkgs", or "synclists" values on the command line then the **mknimimage** command will use those values ONLY. The xCAT osimage definition will not be used or updated in this case.

In this case you would run the **mknimimage** command similar to the following.

~~~~
  mknimimage -u my61dskls installp_bundle="mybndlres1,mybndlres2"
     otherpkgs="I:openssh.base,R:popt-1.7-2.aix5.1.ppc.rpm,E:IZ38930TL0.120304.epkg.Z"
~~~~


The difference here is that the information the osimage definition is not used and this information is not saved.

Any additional software that is needed can be installed in a similar manner.

**Note**: When installing software into a SPOT the pre and post install scripts for a particular software package will not run any code that will impact your running system, (like restarting daemons etc.). The script will check to see if it's installing into a SPOT and it will not run that code.

You can also specify **installp** flags on the **mknimimage** command line by setting the "installp_flags" attribute to the value you want to be used. The default flags, if not specified, are "-abgQXY".

**Note**: During SPOT software updates, "**-b**" is used as the default installp flag, it indicates xCAT prevents the system from performing a bosboot. Also, xCAT sets environment variable **INUCLIENTS** to 1 for installp command, so checks for running daemons(such as SRC) are skipped.

You can also specify **rpm** flags on the **mknimimage** command line by setting the "rpm_flags" attribute to the value you want to be used. **The default flags, if not specified, are "-Uvh ".**

The mknimimage command will check each rpm to see if it is installed. It will not be reinstalled unless you specify the appropriate rpm option, such as '--replacepkgs'.

Note: The "-Uvh" default and the checking of the rpms is new function available in xCAT 2.6.11 and beyond. The previous default was "-Uvh --replacepkgs".

**WARNING:** Installing random RPM packages in a SPOT may have unpredictable consequences. The SPOT is a very restricted environment and some RPM packages may corrupt the SPOT or even hang your management system. Try to be very careful about the packages you install. When installing RPMs, if the mknimimage command hangs or if there are file systems left mounted after the command completes you may need to reboot your management node to recover. This is a limitation of the current AIX support for diskless systems.

You can also specify **emgr** flags on the **mknimimage** command line by setting the "emgr_flags" attribute to the value you want to be used. There is no default flags for the emgr command.

For example, to specify different flags you could run the command as follows.

~~~~
  mknimimage -u my61dskls installp_flags="-agcQX" rpm_flags="-i --nodeps"
~~~~

If you have multiple sets of software that require different flags you can run the **mknimimage** command multiple times.


#### **Update system configuration files**

You can <u>update files</u> in the SPOT manually or by using the xCAT **mknimimage** command.

##### **Manually**

The root file system for a diskless node will be created by copying the "inst_root" directory contained in the SPOT. In the SPOT we created for this example the "inst_root" directory would be:

~~~~
  /install/nim/spot/61dskls/usr/lpp/bos/inst_root/
~~~~

If you need to update the /etc/inittab file in the SPOT that will be used on the diskless nodes you could edit:

~~~~
  /install/nim/spot/61dskls/usr/lpp/bos/inst_root/etc/inittab
~~~~


You can also copy specific files into the inst_root directory so they will be available when the nodes boot. For example, you could copy a script called myscript to /install/nim/spot/61cosi/usr/lpp/bos/inst_root/opt/foo/myscript and then add an entry to /etc/inittab so that it would be run when the node boots.

All the diskless nodes that are booted using this SPOT will get a copy of inst_root as the initial root directory.

##### **Using mknimimage**

XCAT supports the concept of a synclists file. This is a file that can be used to specify what configuration files need to be updated (synchronized). In the synclists file, each line is an entry which describes the location of the source files and the destination location for the files.

For more information on using the synchronization file function see the document: [Sync-ing Config Files to Nodes](Sync-ing_Config_Files_to_Nodes)

To use the **mknimimage** command to update files in the SPOT you must create a synclists file and pass the full path name to the command. One advantage of using the synclists file is that you have a record of what was done for a particular osimage and the update can be repeated easily if needed.

Once the synclists file is create you can either add it to the xCAT osimage definition or specify it on the **mknimimage** command line.

To add it to an osimage definition you could run a command similar to:

~~~~
  chdef -t osimage -o 61dskls synclists="/full-path/mysyncfile"
~~~~

You could then run mknimimage as follows:

~~~~
  mknimimage -u 61dskls
~~~~

(Do not specify "installp_bundle", "otherpkgs", or "synclists" on the command line.)

Or, you could do a one time update by specifying the synclists file on the command line as follows:

~~~~
  mknimimage -u 61dskls synclists="/full-path/mysyncfile"
~~~~


#### **Run commands in the SPOT using xcatchroot**

Starting with xCAT 2.5 and AIX 6.1.6 the **xcatchroot** command can be used to modify the SPOT using the **chroot** command.

The **xcatchroot** command will take care of any of the required setup so that the command you provide will be able to run in the spot chroot environment. It will also mount the lpp_source resource listed in the osimage definition so that you can access additional software that you may wish to install.

For example, to set the root password to "cluster" in the spot so that when the diskless node boots it will have a root password set you could run a command similar to the following.

~~~~
  xcatchroot -i 61cosi "/usr/bin/echo root:cluster | /usr/bin/chpasswd -c"
~~~~

See the **xcatchroot** man page for more details. [xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html)

Note: Run **export INUCLIENTS=1** from within xcatchroot environment before you install or update bos.* AIX filesets or any other filesets or rpms that expect an active operating environment or else installp or rpm command may fail.

~~~~
  xcatchroot -i 61cosi "export INUCLIENTS=1;/usr/sbin/installp  ....."
~~~~


**Caution: **
> Be very careful when using **chroot** on a SPOT. It is easy to get the SPOT into an unusable state! It may be advisable to make a copy of the SPOT before you try to run any commands that have an uncertain outcome.


When you are done updating a NIM spot resource you should always run the NIM check operation on the spot.

~~~~
  nim -Fo check 61cosi
~~~~


### **Verify the new image (optional)**

To display the xCAT image definition run the xCAT **lsdef** command.

~~~~
  lsdef -t osimage -l -o 61dskls
~~~~

To get details for the NIM resource definitions use the AIX **lsnim** command. For example, if the name of your SPOT resource is "61dskls" then you could get the details by running:

~~~~
  lsnim -l 61dskls
~~~~

To see the actual contents of a resource use "nim -o showres <resource name>".

For example, to get a list of the software installed in your SPOT you could run:

~~~~
  nim -o showres 61dskls
~~~~~

<u>To avoid potential problems when installing a node it is advisable to verify that all the software that you wish to install has been copied to the appropriate NIM lpp_source directory.</u>

<u>Any software that is specified in the "otherpkgs" or the "installp_bundle" attributes of the osimage definition must be available in the lpp_source directories.</u>

To find the location of the lpp_source directories run the "lsnim -l &lt;lpp_source_name&gt;" command.

~~~~
  lsnim -l 61dskls_lpp_source
~~~~

If the location of your lpp_source resource is "/install/nim/lpp_source/61dskls_lpp_source/" then you would find rpm packages in "/install/nim/lpp_source/61dskls_lpp_source/RPMS/ppc" and you would find your installp and emgr packages in "/install/nim/lpp_source/61dskls_lpp_source/installp/ppc".

To find the location of the installp_bundle resource files you can use the NIM "lsnim -l" command. For example,

~~~~
  lsnim -l xCATaixSSH
~~~~

Starting with xCAT version 2.4.3 you can use the xCAT **chkosimage** command to do this checking. For example:

~~~~
  chkosimage -V 61cosi
~~~~

See the **chkosimage** man page for more details.


### **Re-initialize the NIM diskless nodes**

You can re-initialize your diskless nodes to boot with the new or updated SPOT by running the **mkdsklsnode** command.

You have two basic options.

  1. Shut down, uninitialize, and then re-initialize the diskless nodes.
  2. Re-initialize while the node is running and then reboot the node using the new image.

#### Re-initializing a diskless node

In the first situation you want to switch the nodes to use a new or updated image. If the diskless node is currently running you can either shut down the node and run rmdsklsnode to uninitialize the node or you can use the "-f" (force) option of the **mkdsklsnode** command. With the "-f" option the **mkdsklsnode** command will stop the running node, deallocate the resources and do the NIM re-initialization with the new image.

<u>In this case the node would be unavailable during the initialization as well as the time for the node reboot</u>

**Note: **The NIM support for re-initialization take 3-4 minutes and is done sequentially.

For example, to switch the node named "node29" to a new image named "611spot" you could run the following command.

~~~~
  mkdsklsnode -f -i 611spot node29
~~~~

The name of the image ("611spot") is the xCAT osimage name which is also the name of the SPOT resource that was created for this osimage definition.


#### Re-initializing a diskless node with minimal downtime

In the second scenario we want to do the initialization step while the node is running to reduce the amount of time that the node is unavailable.

The problem with trying to do this is that NIM will not allow you to initialize a client machine while it is currently running, and has resources allocated to it. However, there is a way to work around this limitation.

It turns out that NIM actually allows you to create multiple machine definitions for one actual system. We can use this feature to create an alternate machine definition to do the initialization. This can be done while the node is running. When the initialization has completed we can simply reboot the node.

Since all the NIM initialization of the alternate machine definition can be done while the node is running, the <u>downtime for the node is reduced to the time it takes to reboot</u>.

The xCAT [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html) and [rmdsklsnode](http://xcat.sourceforge.net/man1/rmdsklsnode.1.html) commands have been enhanced to help implement this work around.

##### Creating alternate NIM machine definitions

Normally when you run **mkdsklsnode** it will create a NIM machine definition using the xCAT node name (short hostname). However, if you use the "-n" option it will create an alternate name for the NIM client machine definition.

The naming convention for the new NIM machine name is "&lt;xcat_node_name&gt;\_&lt;image_name&gt;", (Ex."_node42_61dskls").

**Note**: You could create alternate NIM machine definitions for each new image you wish to use for the node.

For example, to initialize the xCAT node named "node42" to use the xCAT osimage named "61dskls" you could run the following command.

~~~~
  mkdsklsnode -n -i 61dskls node42
~~~~

Once the **mkdsklsnode** command completes you can reboot the nodes. <u>The last NIM machine name that is initialized will determine what the node will use for the next boot.</u>

**Debug tip**: If you have forgotten which machine name you last initialized with NIM, and want to verify which image will actually be loaded on the next boot, you can look at the /tftpboot/&lt;hostname&gt;.info file that contains mount information for the SPOT and other resources. You can check what will be mounted for the next boot of the node.


##### Cleaning up old NIM definitions and resources

Over time using the "-n" option could leave you with multiple alternate NIM machine definitions for the same node.

Before you can remove the resources (using the **rmnimimage** command) you need to clean up the old alternate NIM client definitions.

To remove the old alternate NIM client definitions you can use the **rmdsklsnode** command.  See the man page: [rmdsklsnode](http://xcat.sourceforge.net/man1/rmdsklsnode.1.html)

You must either use the "-f" or the "-r" options when removing alternate client definitions. The "-f" option will attempt to <u>shut down the node</u> before removing the NIM client definition. If you don't want the nodes shut down then use the "-r" option.

**Important Note**: If you have allocated dump resources to your nodes be aware that after the alternate client definition is removed you will no longer be able gather a system dump from the node. This is a current limitation in the NIM support for alternate client definitions.

<u>The recommended way to clean up old alternate NIM client definitions and resources is to wait for a system maintenance window. Right before you do the updates use **rmdsklsnode -r** and **rmnimimage** to clean up the old NIM objects. After the cleanup you then run **mkdsklsnode** for your update. All these commands can be completed while the nodes are still running. When these commands have completed then your only downtime will be the time it takes to reboot the nodes. This also means that you'll have a very short time when you will not be able to gather system dumps.</u>

Example:

To remove the NIM alternate client definition for xCAT node "node02" and the osimage "61aix". (i.e. NIM machine name "node02_61aix".)

~~~~
  rmdsklsnode -r -i 61aix node02
~~~~

**Note:** If you wish to do go back to the "normal" naming convention, ( using the xCAT node name as the NIM client machine name), you could run the **mkdsklsnode **command for the same node without the "-n" option. For example, in the previous example you got a NIM client definition called "node42_61dskls". If you wish to switch back to a NIM machine name of "node42" for the next update you could run **mkdsklsnode** as follows. (You may need the "-f" (force) option if the "node42" definition already exists. )

~~~~
  mkdsklsnode -f -i 611dskls node42
~~~~

Once you have removed your old client definitions you can remove the old NIM resources. You can do this using the xCAT **rmnimimage** command. (Or by running local "nim -o remove .." commands directly.) See the man page for details. [rmnimimage](http://xcat.sourceforge.net/man1/rmnimimage.1.html)

Example:

To remove all the NIM resources listed in the xCAT osimage named "aixdskls" on all the service nodes in the cluster.

~~~~
  rmnimimage -s service aixdskls
~~~~

Be careful not to remove any NIM resources that will still be needed.


### **Verify node readiness (optional)**

To verify that NIM has allocated the required resources for a node and that the node is ready for a network boot you can run the "**lsnim -l**" command. For example, to check node "node01" you could run the following command.

~~~~
  lsnim -l node01
~~~~

In preparation for the network boot the NIM "dkls_init" operation configures bootp/dhcp. At this point you can verify that the /etc/bootptab file for **bootp**, (or /etc/dhcpsd.cnf file for **dhcp**), has an entry for each node you wish to boot. Also, it is recommended that you stop and restart the **inetd** service to ensure the new bootp/dhcp configuration is loaded:

~~~~
  stopsrc -s inetd
  startsrc -s inetd
~~~~


### **Initiate a network boot**

Initiate a remote network boot request using the xCAT **rnetboot** command. For example, to initiate a network boot of all nodes in the group "aixnodes" you could issue the following command.

~~~~
  rnetboot aixnodes
~~~~

**NOTE:** If you receive timeout errors from the **rnetboot** command, you may need to increase the default 60-second timeout to a larger value by setting ppctimeout in the site table:

~~~~
  chdef -t site -o clustersite ppctimeout=180
~~~~


### **Node OS update and backout with minimal downtime**

This is a process that may be used to update the cluster nodes with a new OS image and then back it out if needed. Most of these steps can be done while the nodes are currently running and therefore the process can be completed with a minimal of total downtime for the system.

#### **Update nodes with a new OS image**

Assume the nodes are currently running and have been booted using an osimage called "71dsklsA".

1) Create a new osimage (called "71dsklsB").

~~~~
  mknimimage -r -t diskless -s 71dskls_lpp_source 71dsklsB
~~~~

2) Copy the node /tftpboot files to a backup directory.

These files will be used if you need to back out the new osimage quickly. (This example assumes you are using xCAT service nodes.)

~~~~
  xdsh service "mkdir -p  /tftpboot/tftpbak"

  xdsh service "cp  /tftpboot/*   /tftpboot/tftpbak"
~~~~

3) Initialize the nodes using the new image.

~~~~
  mkdsklsnode -n -i 71dsklsB  compute
~~~~

Using the "-n" option will create and initialize alternate NIM client definitions for each node in the group "compute". The compute nodes will continue to run while this operation is completing.

4) Reboot the nodes

~~~~
  rpower compute reset
~~~~

The nodes will boot with 71dsklsB.

Your system downtime is essentially the time it takes for the nodes to reboot.


#### **To back out the new image**

1) Restore the tftpboot files.

Copy back the /tftpboot files that were saved in an earlier step.

~~~~
  xdsh service  "cp /tftpboot/tftpbak/*   /tftpboot "
~~~~

(Since the original NIM client definitions and resource definitions are still available you can just switch back the old /tftpboot files in order to point to the old resources. When the nodes reboot they will pick up the old NIM resources.)

2) Reboot the nodes

~~~~
  rpower compute reset
~~~~

The nodes boot with the old 71dsklsA OS image.

3) Update the xCAT database

By copying back the old /tftpboot files you are actually switch back to the old osimage so you should update the node definitions in the xCAT database to indicate the correct osimage.

~~~~
  chdef  compute  provemethed=71dsklsA
~~~~

Once you decide the osimage must be backed out you can do it in the time it takes to copy the /tftpboot files and reboot the nodes.



#### **Recover the new osimage**

1) Repair the xCAT osimage

Fix whatever problems you were having with the new osimage that you backed out.

This might involve updating the SPOT or making changes to other NIM resources.

You could use the existing osimage definition or create a new one.

In this example the original osimage is copied to create the "71dsklsBupdt" which could then be updated and used to boot the nodes.

~~~~
  mknimimage -t diskless -r -i 71dsklsB  71dsklsBupdt
~~~~

2) initialize the nodes using the new image.

~~~~
  mkdsklsnode -n  -i 71dsklsBupdt  compute
~~~~

3) Reboot the nodes
~~~~
  rpower compute reset
~~~~

Again, the only downtime for the nodes would be the time it takes to reboot them.


#### **Cleanup**

Over time using the "-n" option could leave you with multiple alternate NIM machine definitions for the same node.

Also, you may want to remove old nim resources that are just taking up space.

Before you can remove the resources (using the **rmnimimage** command) you need to clean up the old alternate NIM client definitions.

To remove the old alternate NIM client definitions you can use the **rmdsklsnode** command. See the man page: [rmdsklsnode](http://xcat.sourceforge.net/man1/rmdsklsnode.1.html)

You must either use the "-f" or the "-r" options when removing alternate client definitions. The "-f" option will attempt to <u>shut down the node</u> before removing the NIM client definition. If you don't want the nodes shut down then use the "-r" option.

**Important Note**: If you have allocated dump resources to your nodes be aware that after the alternate client definition is removed you will no longer be able gather a system dump from the node. This is a current limitation in the NIM support for alternate client definitions.

<u>The recommended way to clean up old alternate NIM client definitions and resources is to wait for a system maintenance window. Right before you do the updates use **rmdsklsnode -r** and **rmnimimage** to clean up the old NIM objects. After the cleanup you then run **mkdsklsnode** for your update. All these commands can be completed while the nodes are still running. When these commands have completed then your only downtime will be the time it takes to reboot the nodes. This also means that you'll have a very short time when you will not be able to gather system dumps.</u>

Example:

To remove the NIM alternate client definition for xCAT node "node02" and the osimage "61aix". (i.e. NIM machine name "node02_61aix".)

~~~~
  rmdsklsnode -r -i 61aix node02
~~~~

**Note:** If you wish to do go back to the "normal" naming convention, ( using the xCAT node name as the NIM client machine name), you could run the **mkdsklsnode **command for the same node without the "-n" option. For example, in the previous example you got a NIM client definition called "node42_61dskls". If you wish to switch back to a NIM machine name of "node42" for the next update you could run **mkdsklsnode** as follows. (You may need the "-f" (force) option if the "node42" definition already exists. )

~~~~
  mkdsklsnode -f -i 611dskls node42
~~~~

Once you have removed your old client definitions you can remove the old NIM resources. You can do this using the xCAT **rmnimimage** command. (Or by running local "nim -o remove .." commands directly.) See the man page for details. [rmnimimage](http://xcat.sourceforge.net/man1/rmnimimage.1.html)

Example:

To remove all the NIM resources listed in the xCAT osimage named "aixdskls" on all the service nodes in the cluster.

~~~~
  rmnimimage -s service aixdskls
~~~~

Be careful not to remove any NIM resources that will still be needed.


## Synchronizing configuration files

The xCAT **updatenode** command can be used to distribute and synchronize files on the cluster nodes.

The basic process for distributing and synchronizing nodes is:

  * Create a synclist file. (File containing a list of files to sysnchronize.)
  * Indicate the location of the synclist file.
  * Run the updatenode command to update the nodes.

Files may be distributed and synchronized for both diskless and diskfull nodes. However, since some filesystems are mounted read-only on AIX diskless nodes it may not be possible to update all files on AIX systems. For example, any files under /usr on AIX diskless nodes cannot be updated.


### **Create the synclist file**

The synclist file contains the configuration entries that specify where the files should be synced to. In the synclist file, each line is an entry which describes the location of the source files and the destination location for the files on the target node.

See the following documentation for setting up your synclist file: [Sync-ing Config Files to Nodes]([Sync-ing_Config_Files_to_Nodes)


### **Indicate the location of the synclist file**

For AIX nodes, add a full path of the synclist file to the "synclists" attribute of the xCAT osimage used by the node. The name of the osimage used by the node is specified by the "provmethod" attribute of the node definition.

You can use the **lsdef** command to get the value of "provmethod" for a node. For example.

~~~~
  lsdef -t node -o node321 -i provmethod
~~~~

Once you have the name of the xCAT osimage definition then you can update it using the **chdef** command.

~~~~
  chdef -t osimage -o myosimage synclists=/mydir/syncfile1
~~~~


### **Run updatenode to synchronize the files**

Run the updatenode command to synchronize the files specified in the synclists file.

~~~~
  updatenode node321 -F
~~~~


## Running customization scripts

You can use the **updatenode** command to run customization scripts on the cluster nodes.

<u>Any scripts that you wish to have run must be copied to the /install/postscripts directory</u> on the xCAT management node. (Make sure they are executable.)

<u>To run scripts on a node you must either specify them on the command line or you must add them to the "postbootscripts" attribute for the node.</u>

To set the "postbootscripts" attribute of the node (or group) definition you can use the xCAT **chdef** command. Set the value to be a comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run. You could also set the "postbootscripts" value by directly editing the xCAT "postscripts" database table using the xCAT **tabedit** command.

Scripts may be run on both diskless and diskfull nodes.

<u>Use the **updatenode** command to run the customization scripts on the nodes.</u>

Examples:

  * To run all the customization scripts that have been designated for the nodes, (in the "postbootscripts" attribute), type:

~~~~
  updatenode node01,node02 -P
~~~~

  * To run the "syslog" script for the nodes, type:

~~~~
  updatenode node01 -P syslog
~~~~

  * To run a list of scripts on all the nodes in the group "aixnodes", type:

~~~~
  updatenode aixnodes -P script1,script2
~~~~


## Updating software on AIX standalone (diskfull) nodes

**Note**: The **updatenode** command cannot be used to apply software updates to diskless nodes. See the section below on how to update diskless nodes.

It is also possible to use the **xdsh** command to update software on diskfull cluster nodes. See the section below that describes this procedure.

### **Using the updatenode command**

The xCAT **updatenode** command can be used to perform software maintenance operations on AIX/NIM standalone machines. This command uses underlying AIX commands to perform the remote customization of AIX diskfull (standalone) nodes. It supports the AIX **installp**, **rpm**, and **emgr** software packaging formats.

#### **Copy software to the appropriate directories**

The xCAT support for maintaining software on cluster nodes encourages a structured approach that will make it easier to manage software levels in large cluster environments.

As part of this approach the recommended process is to <u>copy the software packages and/or updates that you wish to install on the nodes to the appropriate directory locations in the NIM lpp_source resource that you are using for the nodes.</u>

(This step is needed to ensure that the software updates will be available in a known location when doing subsequent installations and/or updates etc.)

Note: If you wish to use some other directory to store your software you can use the updatenode command with the "-d &lt;dirname&gt;" to specify an alternate source location. Make sure the alternate directory is mountable and that the files are readable. See the updatenode man page for details.

<u>A simple way to copy software to the lpp_source locations is to use the "nim -o update" command.</u>  With this NIM command you simply need to provide the name of the NIM lpp_source resource and it will automatically copy your files to the correct locations.

For example, assume all your software has been saved in the temporary location /tmp/images.

To add all the packages to the lpp_source resource named "61image_lpp_source" you could run the following command:

~~~~
  nim -o update -a packages=all -a source=/tmp/images 610image_lpp_source
~~~~

The NIM command will find the correct directories and update the lpp_source resource.

<u>To find the correct lpp_source for the node</u> you must first get the name of the xCAT osimage definition from the "provmethod" attribute of the xCAT node definition and then get the name of the lpp_source_ resource from the osimage definition. You can use the xCAT **lsdef** command to display the node and osimage definitions.

For example.

~~~~
  lsdef -l clstrn01
~~~~

This would display the node definition which will contain an entry for "provmethod". If the value is "61image" then you would run:

~~~~
  lsdef -t osimage -o 61image -l
~~~~

which gives you the osimage definition. The name of the NIM lpp_source resource is provided by the "lpp_source" attribute value.

If you wish to copy the files manually you must first find the location of the lpp_source directories. Do this by running the "lsnim -l &lt;lpp_source_name&gt;" command.

~~~~
  lsnim -l 61image_lpp_source
~~~~

If the location of your lpp_source resource is "/install/nim/lpp_source/61image_lpp_source/" then you would copy **rpm** packages to "/install/nim/lpp_source/61image_lpp_source/RPMS/ppc" and you would copy your **installp** and **emgr** packages to "/install/nim/lpp_source/61image_lpp_source/installp/ppc".


#### **Specify the names of the software to update**

There are two methods that may be used to specify the software to update.

The first is to set the "installp_bundle" and/or the "otherpkgs" attributes of the xCAT _osimage definition you are using for the node.

The second is to specify one or both of these attribute values on the **updatenode** command line.

Using the first method provides a record of what was updated which is stored in the xCAT database. This can be useful when managing a large cluster environment. The second method is more "ad hoc" but also can be more flexible.

The **updatenode** command will either use the information in the database or the information on the command line - BUT NOT BOTH. If you specify information on the command line it will use that, otherwise it will use what is in the database.

When specifying the information on the command line you must use the "attr=val" format. You may include one or more "attr=val" pairs at the end of the command line. They must be separated by a space. ( i.e. `[attr=val [attr=val ...]]` )

The "installp_bundle" attribute value may be set to a comma separated list of one or more NIM installp_bundle resource names. These NIM resources must be created using standard NIM interfaces. See the section titled "Creating a NIM installp_bundle resource" later in this document for details.

The "otherpkgs" attribute value may be set to a comma separated list of **installp**, **emgr** or **rpm** packages.

<u>When specifying RPM names you must use a prefix of "R:"</u>. (ex. "R:foo.rpm").

It is also possible to specify that ALL software in the specified location be installed. To do this use the "-A" option with **updatenode**. In this case any **installp**, **rpm** or **emgr** packages will be installed.


#### **Run the updatenode command**

When you run the **updatenode** command the default behavior is to get the name of the osimage defined for each node and use that to determine the location of the software and the names of the software to install. It will use the location of the lpp_resource to determine where to find any **rpm**, **installp**, or **emgr** packages that are defined.


Note: if you are migrating your NFSv3 cluster to be NFSv4, for the standalone nodes, you should login the nodes and change the nfs domain before running updatenode:

~~~~
  xdsh cn "chnfsdom <nfsv4_domain_name>"
~~~~

As mentioned above, if you specify software names or a different location on the command line then that information will be used instead of what is saved in the xCAT node and osimage definitions.

You may also specify alternative **installp, emgr** and **rpm** flags for updatenode to use when calling the underlying AIX commands. Use the "installp_flags", "emgr_flags", and "rpm_flags" attributes to provide this information. Make sure you specify the exact string you want used in quotes. For example: installp_flags="-apXY" rpm_flags="-i -nodeps".

The default value for installp_flags is "-agQX" and the default value for rpm_flags is "-Uvh -replacepkgs". No flags are used by default in the call to **emgr**.

When doing software maintenance on AIX nodes you may also find the "-c" flag useful. When you specify this flag on the **updatenode** command line the command will know to use the command line information ONLY, even if there is no software specified (i.e. It won't go look in the database.). This option would be needed when using **installp, emgr **or **rpm** options that do not require a list of software.

If you wish to see the output from the **installp, emgr** or **rpm** commands that are run then you must specifiy "-V" on the **updatenode** command line.

When working in a hierarchical xCAT cluster the **updatenode** command will automatically take care of distributing the software to the appropriate service nodes.

<u>Examples</u>:

(1) To update the AIX node named "xcatn11" using the "installp_bundle" and/or "otherpkgs" attribute values stored in the xCAT database. Use the default installp ("-agQX") and rpm ("-Uvh -replacepkgs") flags.

~~~~
  updatenode xcatn11 -S
~~~~

Note: The xCAT "xcatn11" node definition points to an xCAT osimage definition which contains the "installpbundle" and "otherpkgs" attributes.

(2) To update the AIX node "xcatn11" by installing the "bos.cpr" fileset using the "-agQXY" **installp** flags. Also display the output of the **installp** command.

~~~~
  updatenode xcatn11 -V -S otherpkgs="I:bos.cpr" installp_flags="-agQXY"
~~~~

(3) To uninstall the "bos.cpr" fileset that was installed in the previous example.

~~~~
  updatenode xcatn11 -V -S otherpkgs="I:bos.cpr" installp_flags="-u"
~~~~

(4) To update the AIX nodes "xcatn11" and "xcatn12" with the "I:gpfs.base" fileset and the "rsync" rpm using the installp flags "-agQXY" and the rpm flags "-i --nodeps".

~~~~
  updatenode xcatn11,xcatn12 -V -S otherpkgs="I:gpfs.base,R:rsync-2.6.2-1.aix5.1.ppc.rpm"
    installp_flags="-agQXY" rpm_flags="-i --nodeps"
~~~~

Note: Using the "-V" flag with multiple nodes may result in a large amount of output.

(5) To uninstall the **rsync** rpm that was installed in the previous example.

~~~~
updatenode xcatn11 -V -S otherpkgs="R:rsync-2.6.2-1" rpm_flags="-e"
~~~~

(6) Update the AIX node "node01" using the software specified in the NIM "sslbnd" and "sshbnd" installp_bundle resources and the "-agQXY" installp flags.


~~~~
  updatenode node01 -V -S installp_bundle="sslbnd,sshbnd"
      installp_flags="-agQXY"
~~~~

(7) To get a preview of what would happen if you tried to install the "rsct.base" fileset on AIX node "node42". (You must use the "-V" option to get the full output from the **installp** command.)

~~~~
  updatenode node42 -V -S otherpkgs="I:rsct.base" installp_flags="-apXY"
~~~~

(8) To check what rpm packages are installed on the AIX node "node09". (You must use the "-c" flag so updatenode does not get a list of packages from the database.)

~~~~
  updatenode node09 -V -c -S rpm_flags="-qa"
~~~~

(9) To install all software updates contained in the /images directory.

~~~~
  updatenode node27 -V -S -A -d /images
~~~~

Note: Make sure the directory is exportable and that the permissions are set correctly for all the files. (Including the .toc file in the case of **installp** filesets.)

(10) Install the interim fix package located in the /efixes directory.

~~~~
  updatenode node29 -V -S -d /efixes otherpkgs=E:IZ38930TL0.120304.epkg.Z
~~~~

(11)To uninstall the interim fix that was installed in the previous example.

~~~~
  updatenode xcatsn11 -V -S -c emgr_flags="-r -L IZ38930TL0"
~~~~


### **Using the xdsh method**

Another method for updating a diskfull node would be to mount a directory containing the updates on the node and use the **xdsh** command to run the appropriate **installp, emgr **or **rpm** command (or **geninstall**).

**Note**: Using this method in a large cluster environment could quickly lead to a chaotic state in that it will be difficult to keep track of what software has been installed on what nodes. It also does not make use of the xCAT hierarchical support that is provided for large cluster environments. There could be scaling issues if updating a large number of nodes.

For example:

To mount a directory you could run something like-

~~~~
  xdsh <nodename> "mount <servername>:/my-inst-images /mnt"
~~~~

To install an **installp** fileset-

~~~~
  xdsh <nodename> "installp -agQX -d /mnt <fileset name>"
~~~~

To unmount the directory-

~~~~
  xdsh <nodename> "umount /mnt"
~~~~


## Getting software and firmware levels

### **Using the sinv command**

The sinv command is designed to check the configuration of the nodes in a cluster. The command takes as input command line flags, and one or more templates which will be compared against the output of the xdsh command, designated to be run by the -c or -f flag, on the nodes in the noderange.


The nodes will then be grouped according to the template they match and a report returned to the administrator in the output file designated by the -o flag, or to stdout.


**sinv** supports checking the output from the rinv or xdsh command.


See the man pages for sinv &amp; rinv for more details.

Also see the following doc: [Parallel Commands and Inventory](Parallel_Commands_and_Inventory)


## Creating a NIM installp_bundle resource

To define a NIM installp_bundle resource you must create a bundle file in an exportable directory and then create the NIM definition.


In an xCAT cluster the default location for NIM resources is "/install/nim" and typically the installp_bundle files are in "/install/nim/installp_bundle".


A bundle file contains a list **installp** filesets and/or **rpm** package names. The RPMs must have a prefix of "R:" and the installp packages must have a prefix of "I:". For example, the contents of a simple bundle file might look like the following.

~~~~
    # RPM
    R:expect-5.42.1-3.aix5.1.ppc.rpm
    R:ping-2.4b2_to-1.aix5.3.ppc.rpm
    #installp
    I:openssh.base
    I:openssh.license
~~~~

To create a NIM installp_bundle definition you can use the "nim -o define" operation. For example, to create a definition called "mypkgs" for a bundle file located at "/install/nim/mypkgs.bnd" you could issue the following command.


~~~~
    nim -o define -t installp_bundle -a server=master -a location=/install/nim/mypkgs.bnd mypkgs
~~~~

See the AIX documentation for more information on using NIM installp_bundle resources.


## Using the rolling update support

The **rollupdate** command creates and submits scheduler jobs that will notify xCAT to shutdown a group of nodes, run optional out-of-band commands from the xCAT management node, and reboot the nodes. Currently, only LoadLeveler is supported as a job scheduler with **rollupdate**.


Input to the **rollupdate** command is passed in as stanza data through STDIN. Information such as the sets of nodes that will be updated, the name of the job scheduler, a template for generating job command files, and other control data are required. See /opt/xcat/share/xcat/rollupdate/rollupdate.input.sample for stanza keywords, usage, and examples.


The **rollupdate** command will use the input data to determine each set of nodes that will be managed together as an update group. For each update group, a job scheduler command file is created and submitted. When the group of nodes becomes available and the scheduler runs the job, the job will send a message to the xCAT daemon on the management node to begin the update process for all the nodes in the update group. The nodes will be stopped by the job scheduler (for LoadLeveler, the nodes are drained), an operating system shutdown command will be sent to each node, out-of-band operations can be run on the management node, and the nodes are powered back on.


The **rollupdate** command assumes that, if the update is to include rebooting stateless nodes to a new operating system image, the image has been created and tested, and that all relevant xCAT commands have been run for the nodes such that the new image will be loaded when xCAT reboots the nodes.

See the following doc for complete details on setting up to use rollupdate: [Rolling_Update_Support].


## **Upgrading xCAT on the management node**

### **Download and install the prerequisite Open Source Software (OSS)**

Check if the latest version of the dep-aix-*.tar.gz tar file is newer than what you have installed. If it is then download it and install it on your management node.


* Download the latest dep-aix-*.tar.gz tar file from http://xcat.sourceforge.net/#download and copy it to a convenient location on your xCAT management node.

* Unwrap the tar file. For example:

~~~~
    gunzip dep-aix-2.3.tar.gz
    tar -xvf dep-aix-2.3.tar
~~~~

* Read the README file

* Run the **instoss** script (contained in the tar file) to install the OSS packages. Please make sure the /opt and the other file systems have enough disk space to install these OSS packages before running the **instoss **script.

* <u>Make sure you update your NIM lpp_source resources</u>! Copy the new dependencies to your lpp_source resource directories as needed.

**Note:** In the more recent tarballs the packages will be in subdirectories corresponding to AIX OS version. (ie. 53., 6.1 etc.) When you copy rpms to your lpp_source diresctories be sure to pick the rpms in the subdirectory that corresponds to your OS version.


### Download and install the xCAT software

* Download the latest xCAT for AIX tar file from http://xcat.sourceforge.net/#downloadand copy it to a convenient location on your xCAT management node.

* Unwrap the xCAT tar file. For example,

~~~~
    gunzip core-aix-2.3.tar.gz
    tar -xvf core-aix-2.3.tar
~~~~

* Run the **instxcat** script (contained in the tar file) to install the xCAT software. (The **instxcat** script and all the RPMs are located in the xcat-core subdirectory.)

**This script should only be used on the Management Node , not on Service Nodes which installs diffent software.** For Service Node upgrade see:
[Updating_AIX_Software_on_xCAT_Nodes/#upgrading-xcat-on-service-nodes](Updating_AIX_Software_on_xCAT_Nodes/#upgrading-xcat-on-service-nodes)

* <u>Make sure you update your NIM lpp_source and installp_bundle resources</u>! Copy the new xCAT RPMs to your lpp_source directories. Also make sure the NIM installp_bundle resources are updated with any changes that were included in the new installp_bundle files shipped with xCAT. (They are either in the new tarball or installed in /opt/xcat/share/xcat/installp_bundles)


### **Verify the xCAT installation**

* Run the "lsxcatd -a" to check if the xCAT daemon is working. (If you get a correct response then you should be Ok. )



## Upgrading xCAT on service nodes

### **Define an xCAT software bundle.**

Copy the sample service node bundle to a SN_updatexCAT.bnd file in the installp_bundle directory. The sample bundle files shipped with xCAT contain the names of rpm packages using a wildcard (*) instead of specific versions.

~~~~
  cp /opt/xcat/share/xcat/installp_bundles/xCATaixSN71.bnd /install/nim/installp_bundle/SN_updatexCAT.bnd
  nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/SN_updatexCAT.bnd SN_updatexCAT
~~~~

Remove filesets so that only xCAT core and dep RPMs remain. Comment out the ODBC RPMs. We do not want to re-install these during an xCAT SN update.

~~~~
    cat SN_updatexCAT.bnd
    # Software needed for xCAT on AIX Service Nodes
    # RPMs
    # using Perl 5.10.1
    R:popt*
    R:rsync*
    R:bash*
    R:conserver*
    R:curl*
    R:expat*
    R:fping*
    R:libxml2*
    R:net-snmp-5.4.2.1-3*
    R:net-snmp-devel*
    R:net-snmp-perl*
    R:openslp-xcat*
    R:perl-Crypt-SSLeay*
    R:perl-DBD-SQLite*
    R:perl-DBI*
    R:perl-Digest-HMAC*
    R:perl-Digest-MD5*
    R:perl-Digest-SHA-5*
    R:perl-Digest-SHA1*
    R:perl-Expect*
    R:perl-IO-Stty*
    R:perl-IO-Tty*
    R:perl-Net-DNS*
    R:perl-Net-IP*
    R:perl-Net-Telnet*
    R:perl-version-0.82-2*
    R:perl-Net_SSLeay.pm-1.30-3*
    R:perl-IO-Socket-SSL*

    #R:unixODBC*
    R:perl-DBD-DB2*
    R:perl-DBD-Pg*
    R:perl-DBD-mysql*

    # optional - needed if using mysql ODBC support (e.g. with LoadLeveler)
    #I:X11.base.lib
    #R:mysql-connector-odbc*

    # optional - needed if using Postgresql
    #R:xcat-postgresql*

    R:perl-xCAT*
    R:xCAT-client*
    R:xCAT-server*
    R:xCAT-rmc*
    R:xCATsn*
~~~~


### **Download the new software**

Download the latest xCAT dep-aix-*.tar.gz and core-aix-*.tar.gz tar files as mentioned in the previous section.

CAUTION: The xCAT management node and the xCAT service nodes are installed with different xCAT packages. Refer to the installp_bundle file mentioned below for a list of the software required for service nodes.

### **Copy the new rpms to the NIM lpp_source directories**

If the only RPMs located under /install/nim/lpp_source/&lt;image&gt;/RPMS/ppc are xCAT related, go there and remove all of them. If there are xCAT and non-xCAT RPMs use the 'nim -o update' to copy over the new RPMs. Duplicates will be removed in the next step. Provide the name of the NIM lpp_source resource and the source location of the RPMs like /tmp/xcat-core and /tmp/xcat-dep/6.1 for example.

~~~~
    nim -o update -a packages=all -a source=/tmp/xcat-core 610image_lpp_source
    nim -o update -a packages=all -a source=/tmp/xcat-dep/6.1 610image_lpp_source
~~~~


### **Remove the old xCAT rpms from the lpp_source location**

If any old xCAT RPMS are left in the directory use chkosimage command to find duplicates and remove them. If multiple versions of the same rpm exist NIM will produce an error when trying to install them.

~~~~
  chkosimage GOLD_71DSN
  Found multiple matches for perl-xCAT: (perl-xCAT-2.6.11-snap201202201419.aix6.1.ppc.rpm perl-xCAT-2.6.11-snap201203081609.aix6.1.ppc.rpm )
  Found multiple matches for xCAT-client: (xCAT-client-2.6.11-snap201202201420.aix6.1.ppc.rpm xCAT-client-2.6.11-snap201203081610.aix6.1.ppc.rpm )
  Found multiple matches for xCAT-server: (xCAT-server-2.6.11-snap201202191535.aix6.1.ppc.rpm xCAT-server-2.6.11-snap201203081610.aix6.1.ppc.rpm )
  All the software packages were found in the lpp_source 'GOLD_71DSN_lpp_source'
  Error: Found multiple matches for one or more rpm packages. This will cause installation errors. Remove the unwanted rpm packages from the lpp_source directory /install/nim/lpp_source/GOLD_71DSN_lpp_source/RPMS/ppc.
  (Use the chkosimage -c option to remove all but the most recently added rpm.)
  Error: Return=1.


  chkosimage GOLD_71DSN -c
  Removed the following duplicate rpms:
  perl-xCAT-2.6.11-snap201203081609.aix6.1.ppc.rpm
  xCAT-client-2.6.11-snap201203081610.aix6.1.ppc.rpm
  xCAT-server-2.6.11-snap201203081610.aix6.1.ppc.rpm
  All the software packages were found in the lpp_source 'GOLD_71DSN_lpp_source'
~~~~


Double check the directory /install/nim/lpp_source/&lt;image&gt;/PRMS/ppc and ensure there are no longer any duplicates.

### **Run the updatenode command to install the software**

Use updatenode to update the xCAT RPMs. This will use the bundle file and replace all listed and available RPMs.

~~~~
  updatenode service -V -S installp_bundle=SN_updatexCAT rpm_flags="-Uvh --replacepkgs --nodeps"
~~~~

Verify the xCAT code has been updated on the service nodes.

~~~~
  xdsh service -v "/opt/xcat/bin/lsxcatd -v"
~~~~


Verify that ODBC configuration has not been impacted. The file sizes should not be equal to '0'. If '0' then rerun 'updatenode service odbcsetup'.

~~~~
  xdsh service -v "ls -l /etc/odbc*"
~~~~


