<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Prepare for the LoadLeveler Installation](#prepare-for-the-loadleveler-installation)
- [Set up Loadleveler Central Manager,](#set-up-loadleveler-central-manager)
- [Linux](#linux)
  - [Add LoadLeveler to your diskless image](#add-loadleveler-to-your-diskless-image)
  - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
  - [Add LoadLeveler to your diskless image](#add-loadleveler-to-your-diskless-image-1)
  - [Network boot the nodes](#network-boot-the-nodes-1)
- [Starting LoadLeveler on cluster nodes](#starting-loadleveler-on-cluster-nodes)
      - [Manually start LoadLeveler](#manually-start-loadleveler)
      - [Automatic start at node boot](#automatic-start-at-node-boot)
      - [Use an xCAT postscript](#use-an-xcat-postscript)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document assumes that you have already purchased your LoadLeveler product, have the install packages available, and are familiar with the LoadLeveler documentation: [Tivoli Workload Scheduler LoadLeveler library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html)

These instructions are based on LoadLeveler 4.1 and 5.1. If you are using a different version of LoadLeveler, you may need to make adjustments to the information provided here.

When installing LoadLeveler in an xCAT cluster, it is assumed that you will be using the xCAT MySQL or DB2 database to store your LoadLeveler configuration data. Different versions of Loadleveler support different operating systems, hardware architectures, and databases. Refer to the LoadLeveler documentation for the support required for your cluster. For example, Power 775 requires LoadLeveler 5.1 on AIX 7.1 or RedHat ELS 6 with DB2.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * You are using MySQL or DB2 for your xCAT database.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a diskless install.
  * You should have a diskless image created with the base OS installed and verified on at least one test node.

Loadleveler requires that userids be common across all nodes in a LoadLeveler cluster, and that the user home directories are shared. There are many different ways to handle user management and to set up a cluster-wide shared home directory (for example, using NFS or through a global filesystem such as GPFS). These instructions assume that the shared home directory has already been created and mounted across the cluster and that the xCAT management node and all xCAT service nodes are also using this directory. You may wish to have xCAT invoke your custom postbootscripts on nodes to help set this up.

Note: For Linux statelite or stateless clusters, a problem exists when updating the LoadLeveler 4.1 rpms(e.g. PTF6 to PTF7). Currently, a new license rpm is shipped and must be installed and accepted before the other LL rpms will install correctly. This will be fixed in future LL PTFs, so that customers will only need to accept the license when installing the base LL rpms. Once fixed, when LL is updated, no LL license rpm will be updated and customers will not need to accept the license a second time. Until a fix is available, a workaround has been posted to [Updating_IBM_HPC_product_software].

## Prepare for the LoadLeveler Installation

Copy the LoadLeveler packages from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN:

~~~~
    /install/post/otherpkgs/<os>/<arch>/loadl
~~~~


For rhels6 ppc64 , the target location is:

~~~~
    /install/post/otherpkgs/rhels6/ppc64/loadl
~~~~


Note: LoadLeveler 4.1.1 on Linux requires a special Java rpm to run its license acceptance script. This is not required for LoadLeveler 5.1. The correct version of this rpm is identified in the LoadLeveler product documentation (at the time of this writing, the rpm was IBMJava2-142-ppc64-JRE-1.4.2-5.0.ppc64.rpm, but please verify with the LL documentation). Ensure the Java rpm is included in the loadl otherpkgs directory.

For Linux, you should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/loadl
~~~~

If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.


Following the LoadLeveler Installation Guide, create the loadl group and userid:

On Linux:

~~~~
      groupadd loadl
      useradd -G loadl loadl
~~~~


For rhels6 ppc64 .

~~~~
      groupadd loadl
      useradd -g loadl loadl
~~~~


On AIX:

~~~~
      mkgroup -a loadl
      mkuser pgrp=loadl groups=loadl home=/<user_home>/loadl loadl
~~~~




Commonly, the &lt;use_home&gt; is "home" directory. When creating the loadl group and userid, the administrator can change it as needed. It is assumed that you have already created a common home directory in the cluster for all users either in NFS, GPFS, or some other shared filesystem. LoadLeveler requires that its administrative userid have either rsh or ssh access across all nodes in the cluster and to the LL central manager. Make sure you have set this up for the loadl userid. For example, to create a .rhosts file (as root):

~~~~
        nodels compute > /<user_home>/loadl/.rhosts
        echo "<MN hostname>" >> /<user_home>/loadl/.rhosts
        chown loadl:loadl /<user_home>/loadl/.rhosts
~~~~




Or, if you are using ssh for LoadLeveler communications, follow your ssh documentation to set up .ssh keys for the userid.

Note: xCAT does not provide any general function for just setting up a user's ssh keys. However, if the user will also be running xCAT xdsh and other commands, the xCAT wiki page on [Granting_Users_xCAT_privileges] includes instructions on how to provide the user with this access, including automatically setting up ssh keys for that user.
    If the user will not be authorized to run xCAT commands, you can still "cheat" and take advantage of a side-effect of the xdsh command to set up your ssh keys:

~~~~
      su - <userid>
      /opt/xcat/bin/xdsh xxx -K        ## "xxx" can be any string

      xdsh will prompt you for the user's password.  Enter the correct password, and then xdsh will fail with:
      Error: Permission denied for request

~~~~



Even though the xdsh command failed, it still created a /u/&lt;userid&gt;/.ssh directory with ssh keys. Create an authorized_keys file for the user:

~~~~
      cat /<user_home>/<userid>/.ssh/id_rsa.pub >> /<user_home>/<userid>/.ssh/authorized_keys
~~~~




Since the home directory is shared across the cluster, the userid now has non-password prompted ssh access to all nodes and to the xCAT management node.

Sync the loadl group and userid to all nodes in the cluster:



See the step below on "(Optional) Synchronize system configuration files" for more details.

## Set up Loadleveler Central Manager,

[Set_up_LoadlLeveler_DB_access_node_and_Central_Manager](Set_up_LoadlLeveler_DB_access_node_and_Central_Manager)

## Linux

To continue to set up LoadLeveler in a Linux statelite or stateless cluster, follow these steps:

### Add LoadLeveler to your diskless image

Include LoadLeveler in your diskless image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your managaement node. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc
~~~~


To install the rpm in Redhat:

~~~~
      yum install xCAT-IBMhpc
~~~~


Add to pkglist: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add the base IBMhpc pkglist:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
~~~~


For rhels6 ppc64, edit the /install/custom/netboot/rh/compute.pkglist,

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
~~~~


Verify that the above sample pkglist contains the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * Add to otherpkgs: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist#
~~~~


Note: If you are using LoadLeveler 5.1.0.2 or below, please use pkglist /opt/xcat/share/xcat/IBMhpc/loadl/loadl.otherpkgs.pkglist
Verify that the above sample pkglist contains the correct LoadLeveler packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * If you are building a stateless image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Add to exclude list: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.<osver>.<arch>.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl.exlist#
~~~~


For rhels6 ppc64, edit the /install/custom/netboot/rh/compute.exlist

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl.exlist#
~~~~


Verify that the above sample exclude lists contain the files and directories you want deleted from your diskless image. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.exlist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+_directory_" syntax) that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.*.exlist. Keeping these files in the diskless image is required for the install and functionality of some of the HPC products.

If you are building a statelite image, refer to the xCAT documentation for statelite images for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your LoadLeveler support, add writable and persistent directories/files required by LoadLeveler to your litefile table in the xCAT database:

~~~~
      tabedit litefile

~~~~
      &lt;in a separate window&gt; cut the contents of /opt/xcat/share/xcat/IBMhpc/loadl/litefile.csv

~~~~
      paste into your tabedit session, modify as needed for your environment, and save
~~~~


When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

LoadLeveler requires that directories specified in the LOG, EXECUTE and SPOOL configuration keywords be writable and persistent. If you are using GPFS filesystems, the preferred location is to put these directories in a GPFS filesystem using $(host). For instance, the LOG directory can be specified as LOG = /LL/$(host)/log". 
If you are not using GPFS filesystems, you will need to mount an NFS writeable directory for each node or include these directories in your litefile table to have xCAT manage the persistence. For detailed information about these LoadLeveler configuration keywords see TWS LoadLeveler: Using and Administering.

Included in this list is an entry for /var/loadl which is the default location for the LoadLeveler log files. This directory is also referenced by the /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install script. If you change this location, make sure to change it both in the litefile table and in the loadl_install script.

Included in this list is an entry for the /home directory. Depending on how you are managing your shared home directory for the cluster, you may need to implement a postbootscript that mounts the correct shared home directory on the node onto /.statelite/tmpfs/home.

Add to postinstall scripts:

Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall(please make sure it has executable permission) and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.sles.postinstall $1 $2 $3 $4 $5
      installroot=$installroot loadldir=/install/post/otherpkgs/$osver/$arch/loadl NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103

~~~~

For rhels6 ppc64, edit the /install/custom/netboot/rh/compute.postinstall(please make sure it has executable permission) and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.rhel.postinstall $1 $2 $3 $4 $5
      installroot=$1 loadldir=/install/post/otherpkgs/rhels6/ppc64/loadl NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103

~~~~

Note: If you are using LoadLeveler 5.1.0.2 or below, please instead use postinstall script /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install
Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. They will be run by genimage after all of your rpms are installed into the image. First the basic IBMhpc script will be run to create filesystems, turn on services, and set some tunables. Then the script to accept the LoadLeveler license and install only the LoadL-resmgr-full rpm will be run. This script will also perform some configuration for using LoadLeveler in your xCAT cluster such as creating LoadLeveler directories in your diskless image and adding LoadLeveler paths to the default profile. Verify that these scripts will work correctly for your cluster. If you wish to make changes to one of these scripts, copy it to /install/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.

(Optional) Synchronize system configuration files:

LoadLeveler requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.synclist
     add the following line (modify as appropriate for the files you wish to synchronize):
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/

~~~~

When packimage or litemiage is run, these files will be copied into the image. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes]

  * Run genimage for your image using the appropriate options for your OS, architecture, adapters, etc.
  * Run packimage or liteimg for your image

### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; netboot" for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the LoadLeveler rpms are all correctly installed, that your LoadLeveler configuration files are all correct, and that you can start the LoadLeveler daemons on all the nodes.

## AIX

To continue to set up LoadLeveler in an AIX diskless, follow these steps:

### Add LoadLeveler to your diskless image

Include LoadLeveler in your diskless image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

    To install the rpm:

~~~~
      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm
~~~~


If you skipped the previous optional step of installing LoadLeveler on your management node, copy the LoadLeveler product packages and PTFS from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN:

~~~~
    /install/post/otherpkgs/aix/ppc64/loadl
~~~~


The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/loadl/loadl.bnd
~~~~


Add the LoadLeveler packages to the lpp_source used to build your diskless image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/loadl
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/loadl <lpp_source_name>
~~~~


Add additional base AIX packages to your lpp_source:

Some of the HPC products require additional AIX packages that may not be part of your default AIX lpp_source. Review the following file to verify all the AIX packages needed by the HPC products are included in your lpp_source (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd
~~~~


To list the contents of your lpp_source, you can use:

~~~~
      nim -o showres <lpp_source_name>
~~~~


And to add additional packages to your lpp_source, you can use the nim update command similar to above specifying your AIX distribution media and the AIX packages you need.

Create NIM bundle resources for base AIX prerequisites and for your LoadLeveler packages:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/loadl/loadl.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/loadl.bnd loadl
~~~~


Review these sample bundle files and make any changes as desired. Note that the loadl.bnd file will only install the LoadL.resmgr lpp. If you wish to install the full LoadLeveler product on all of your compute nodes, edit this bundle file, and make corresponding changes to the loadl_install postscript below.

  * Add the bundle resource to your xCAT diskless image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,loadl"
~~~~


  * Update the image:

Note: Verify that there are no nodes actively using the current diskless image. NIM will fail if there are any NIM machine definitions that have the SPOT for this image allocated. If there are active nodes accessing the image, you will either need to power them down and run rmdkslsnode for those nodes, or you will need to create a new image and then switch your nodes to that image later. For more information and detailed instructions on these options, see the xCAT document for updating software on AIX nodes: [Updating_AIX_Software_on_xCAT_Nodes]

~~~~
      mknimimage -u <image_name>
~~~~


  * Add base HPC and LoadLeveler postscripts

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,loadl_install-5103"
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT diskless node postscript processing.

(Optional) Synchronize system configuration files:

LoadLeveler requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/netboot/aix/<profile>.synclist
~~~~

     add the following lines (and modify these entries based on the files you wish to synchronize):

~~~~
       /etc/hosts /etc/passwd /etc/group -> /etc/
       /etc/security/passwd /etc/security/group /etc/security/limits /etc/security/roles -> /etc/security/
~~~~


     Add this syncfile to your image:

~~~~
      chdef -t osimage -o <imagename> synclists=/install/custom/netboot/aix/<profile>.synclist
~~~~


     Update the image:

~~~~
      mknimimage -u <imagename>
~~~~


You can periodically re-sync these files to the nodes as changes occur in your cluster by running 'updatenode &lt;noderange&gt; -F'. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes]

### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_Diskless_Nodes] to network boot your nodes:

  *     * Run mkdsklsnode for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that LoadLeveler is correctly installed and you can start the LoadLeveler daemons.

## Starting LoadLeveler on cluster nodes

Note:Before start LoadLeveler on your cluster nodes, the HPC admin should need to validate that LoadL configuration files are properly setup.Please refer to the Installation Guide on the page link[http://publib.boulder.ibm.com/infocen.../llbooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html) . Please choose the correct Installation Guide version for Different OS.

There are several ways you can start LoadLeveler on your cluster nodes.

##### Manually start LoadLeveler

Use the xCAT xdsh command to run the LoadLeveler llrctl start command individually on all nodes, or use LoadLeveler to distribute the commands by running "llrctl -g start". Note that for very large clusters, running the llrctl -g command to start the daemons on all the nodes in the cluster can take a long time since this is a serial operation from the LoadLeveler central manager. Therefore, using xdsh with appropriate fanout values may be a better choice.

##### Automatic start at node boot

You can set up /etc/inittab or /etc/init.d to automatically start LoadLeveler when your node boots. However, if your shared home directory is in GPFS, and this is a large cluster using a network interface that may take a little extra start time at node boot, this may not be a reliable way to start the daemons.

##### Use an xCAT postscript

You can create your own postscript in /install/postscripts and add an entry to the xCAT postscripts table for your nodes. The postscript can be as simple as:

~~~~
      /opt/ibmll/LoadL/resmgr/full/bin/llrctl start
~~~~


If your home directory is stored in GPFS, you may want to add a verification to this script first checking that GPFS is running and your /u/loadl home directory is available before starting the LoadLeveler daemon.



