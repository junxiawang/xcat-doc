<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Prepare for the LoadLeveler Installation](#prepare-for-the-loadleveler-installation)
- [Set up LoadLeveler Central Manager](#set-up-loadleveler-central-manager)
- [Linux](#linux)
  - [Add LoadLeveler to your stateful image definition](#add-loadleveler-to-your-stateful-image-definition)
  - [Instructions for adding LoadLeveler Software to existing xCAT nodes](#instructions-for-adding-loadleveler-software-to-existing-xcat-nodes)
  - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
  - [Add LoadLeveler to your stateful image](#add-loadleveler-to-your-stateful-image)
  - [Instructions for adding LoadLeveler Software to existing xCAT nodes](#instructions-for-adding-loadleveler-software-to-existing-xcat-nodes-1)
  - [Network boot the nodes](#network-boot-the-nodes-1)
- [Starting LoadLeveler on cluster nodes](#starting-loadleveler-on-cluster-nodes)
  - [Manually start LoadLeveler](#manually-start-loadleveler)
  - [Automatic start at node boot](#automatic-start-at-node-boot)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document assumes that you have already purchased your LoadLeveler product, have the Linux rpms available, and are familiar with the LoadLeveler documentation: [Tivoli Workload Scheduler LoadLeveler library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html)

These instructions are based on LoadLeveler 4.1 and LoadLeveler 5.1. If you are using a different version of LoadLeveler, you may need to make adjustments to the information provided here.

When installing LoadLeveler in an xCAT cluster, it is assumed that you will be using the xCAT MySQL or DB2 database to store your LoadLeveler configuration data. Different versions of Loadleveler support different operating systems, hardware architectures, and databases. Refer to the LoadLeveler documentation for the support required for your cluster. For example, Power 775 requires LoadLeveler 5.1 on AIX 7.1 or RedHat ELS 6 with DB2.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured.
  * You are using MySQL or DB2 for your xCAT database.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful (full-disk) install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.

Loadleveler requires that userids be common across all nodes in a LoadLeveler cluster, and that the user home directories are shared. There are many different ways to handle user management and to set up a cluster-wide shared home directory (for example, using NFS or through a global filesystem such as GPFS). These instructions assume that the shared home directory has already been created and mounted across the cluster and that the xCAT management node and all xCAT service nodes are also using this directory. You may wish to have xCAT invoke your custom postbootscripts on nodes to help set this up.

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
      useradd -g loadl loadl
~~~~


On AIX:

~~~~
      mkgroup -a loadl
      mkuser pgrp=loadl groups=loadl home=/<user_home>/loadl loadl
~~~~




Commonly, the &lt;user_home&gt; is the **/home** directory. When creating the loadl group and userid, the administrator can change this location as needed. It is assumed that you have already created a common home directory in the cluster for all users either in NFS, GPFS, or some other shared filesystem. Also, LoadLeveler requires that its administrative userid have either rsh or ssh access across all nodes in the cluster and to the LL central manager. Make sure you have set this up for the loadl userid. For example, to create a .rhosts file (as root):

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




Even though the xdsh command failed, it still created a /&lt;user_home&gt;/&lt;userid&gt;/.ssh directory with ssh keys. Create an authorized_keys file for the user:

~~~~
      cat /<user_home>/<userid>/.ssh/id_rsa.pub >> /<user_home>/<userid>/.ssh/authorized_keys
~~~~




Since the home directory is shared across the cluster, the userid now has non-password prompted ssh access to all nodes and to the xCAT management node.

Sync the loadl group and userid to all nodes in the cluster:

See the step below on "(Optional) Synchronize system configuration files" for more details.

## Set up LoadLeveler Central Manager

[Set_up_LoadlLeveler_DB_access_node_and_Central_Manager](Set_up_LoadlLeveler_DB_access_node_and_Central_Manager)

## Linux

To continue to set up LoadLeveler in a Linux stateful cluster, follow these steps:

### Add LoadLeveler to your stateful image definition

Include LoadLeveler in your stateful image definition:

Install the optional xCAT-IBMhpc rpm on your xCAT management node and service nodes. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your management node. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc

~~~~

To install the rpm in Redhat:

~~~~
      yum install xCAT-IBMhpc
~~~~


  * If you have a hierarchical cluster with service nodes, install the optional xCAT-IBMhpc rpm on all of your xCAT service nodes:
    * Add xCAT-IBMhpc to your otherpkgs list:

~~~~
        vi /install/custom/install/<ostype>/<service-profile>.otherpkgs.pkglist
~~~~

     If this is a new file, add the following to use the service profile shipped with xCAT:

~~~~
       #INCLUDE:/opt/xcat/share/xcat/install/sles/service.<osver>.<arch>.otherpkgs.pkglist
~~~~

Either way, add this line:

~~~~
        xcat/xcat-core/xCAT-IBMhpc
~~~~


  *     * If your service nodes are already installed and running, update the software on your service nodes:

~~~~
      updatenode <service-noderange> -S
~~~~


You should create repodata in your /install/post/otherpkgs/&lt;os>/&lt;arch>/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/loadl
~~~~


If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

Add to postscripts:

Copy the IBMhpc postscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will run after all OS rpms are installed on the node and the xCAT default postscripts have run, but before the node reboots for the first time.
Add this script to the postscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script:

~~~~
      chdef -t group -o compute -p postscripts=IBMhpc.postscript
~~~~


Add to pkglist:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add the base IBMhpc pkglist:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
~~~~


For rhels6 ppc64, edit the /install/custom/install/rh/compute.pkglist,

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
~~~~


Verify that the above sample pkglist contains the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: This pkglist support is available with xCAT 2.5 and newer releases. If you are using an older release of xCAT, you will need to add the entries listed in these pkglist files to your Kickstart or AutoYaST install template file.

Add to otherpkgs:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist#
~~~~


Note: If you are using LoadLeveler 5.1.0.2 or below, please use pkglist /opt/xcat/share/xcat/IBMhpc/loadl/loadl.otherpkgs.pkglist
Verify that the above sample pkglist contains the correct LoadLeveler packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

Add to postbootscripts:

Copy the LoadLeveler postbootscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts
~~~~


Review and edit this script to meet your needs. This script will run on the node after OS has been installed, the node has rebooted for the first time, and the xCAT default postbootscripts have run. Note that this script will only install the Loadl-resmgr-full rpm. You will need to edit this script if you wish to also install the LoadL-scheduler rpm on all of your compute nodes.
Add this script to the postbootscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script and the nodes' attribute postbootscripts value is otherpkgs:

~~~~
      chdef -t group -o compute -p postbootscripts=loadl_install-5103
~~~~


If you already have unique postbootscripts attribute settings for some of your nodes (i.e. the value contains more than simply "otherpkgs" and that value is not part of the above group definition), you may need to change those node definitions directly:

~~~~
      chdef <noderange> -p postbootscripts=loadl_install-5103
~~~~


Note: If you are using LoadLeveler 5.1.0.2 or below, please use postscript loadl_install instead

(Optional) Synchronize system configuration files:

LoadLeveler requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/install/<ostype>/<profile>.synclist
~~~~

     add the following line:

~~~~
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


When the node is installed or 'updatenode &lt;noderange&gt; -F' is run, these files will be copied to your nodes. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes]

### Instructions for adding LoadLeveler Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding LoadLeveler software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to add the LoadLeveler software and run the postscripts using the pkglist and otherpkgs.pkglist files created above. Note that support was added to updatenode in xCAT 2.5 to install packages listed in pkglist files (previously, only otherpkgs.pkglist entries were installed). If you are running an older version of xCAT, you may need to add the pkglist entries to your otherpkgs.pkglist file or install those packages in some other way on your existing nodes.

You will want updatenode to run zypper or yum to install all of the packages. Make sure their repositories have access to the base OS rpms:

SLES:

~~~~
      xdsh <noderange> zypper repos --details  | xcoll
~~~~

RedHat:

~~~~
      xdsh <noderange> yum repolist -v  | xcoll
~~~~


If you installed these nodes with xCAT, you probably still have repositories set pointing to your distro directories on the xCAT MN or SNs. If there is no OS repository listed, add appropriate remote repositories using the zypper ar command or adding entries to /etc/yum/repos.d.

Also, for updatenode to use zypper or yum to install packages from your /install/post/otherpkgs directories, make sure you have run the createrepo command for each of your otherpkgs directories (see instructions in the "Updating xCAT nodes" document [Using_Updatenode]

Synchronize configuration files to your nodes (optional):

~~~~
      updatenode <noderange> -F
~~~~


Update the software on your nodes:

~~~~
      updatenode <noderange> -S
~~~~


Run postscripts and postbootscripts on your nodes:

~~~~
      updatenode <noderange> -P
~~~~





### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; install" for all your nodes
    * Run rnetboot to boot and install your nodes
    * When the nodes are up, verify that the LoadLeveler rpms are all correctly installed, that your LoadLeveler configuration files are all correct, and that you can start the LoadLeveler daemons on all the nodes.

## AIX

To continue to set up LoadLeveler in an AIX stateful cluster, follow these steps:

### Add LoadLeveler to your stateful image

Include LoadLeveler in your stateful image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

To install the rpm:

~~~~

      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm
~~~~


The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/loadl/loadl.bnd
~~~~


Add the LoadLeveler packages to the lpp_source used to build your image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/loadl
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/loadl <lpp_source_name>
~~~~


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

Add the bundle resources to your xCAT image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,loadl"
~~~~


Add base HPC and LoadLeveler postscripts

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,loadl_install-5103"
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT diskless node postscript processing.

(Optional) Synchronize system configuration files:

LoadLeveler requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/install/aix/<profile>.synclist
~~~~

add the following lines:

~~~~
       /etc/hosts /etc/passwd /etc/group -> /etc/
       /etc/security/passwd /etc/security/group /etc/security/limits /etc/security/roles -> /etc/security/
~~~~


Add this syncfile to your image:

~~~~
      chdef -t osimage -o <imagename> synclists=/install/custom/install/aix/<profile>.synclist
~~~~


When the node is installed or 'updatenode &lt;noderange&gt; -F' is run, these files will be copied to the node. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes]

### Instructions for adding LoadLeveler Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding LoadLeveler software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the LoadLeveler software and run the postscripts. To have updatenode install both the OS prereqs and the base LoadLeveler packages, complete the previous instructions to add LoadLeveler software to your image.

Synchronize configuration files to your nodes (optional):

~~~~
      updatenode <noderange> -F
~~~~


Update the software on your nodes:

~~~~
      updatenode <noderange> -S  installp_flags="-agQXY"
~~~~


Run postscripts and postbootscripts on your nodes:

~~~~
      updatenode <noderange> -P
~~~~





### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_RTE_Diskfull_Nodes] to network boot your nodes:

  *     * If the nodes are not already defined to NIM, run xcat2nim for all your nodes
    * Run nimnodeset for your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that LoadLeveler is correctly installed and you can start the LoadLeveler daemons.

## Starting LoadLeveler on cluster nodes

There are several ways you can start LoadLeveler on your cluster nodes.

### Manually start LoadLeveler

Use the xCAT xdsh command to run the LoadLeveler llrctl start command individually on all nodes, or use LoadLeveler to distribute the commands by running "llrctl -g start". Note that for very large clusters, running the llrctl -g command to start the daemons on all the nodes in the cluster can take a long time since this is a serial operation from the LoadLeveler central manager. Therefore, using xdsh with appropriate fanout values may be a better choice.

### Automatic start at node boot

You can set up /etc/inittab or /etc/init.d to automatically start LoadLeveler when your node boots. However, if your shared home directory is in GPFS, and this is a large cluster using a network interface that may take a little extra start time at node boot, this may not be a reliable way to start the daemons.

