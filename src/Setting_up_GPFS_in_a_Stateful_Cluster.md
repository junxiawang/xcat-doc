<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Overview](#overview)
  - [Linux](#linux)
    - [Install/Build GPFS](#installbuild-gpfs)
    - [Add GPFS to your stateful image definition](#add-gpfs-to-your-stateful-image-definition)
    - [Instructions for adding GPFS Software to existing xCAT nodes](#instructions-for-adding-gpfs-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes)
  - [AIX](#aix)
    - [Add GPFS to your stateful image](#add-gpfs-to-your-stateful-image)
    - [Instructions for adding GPFS Software to existing xCAT nodes](#instructions-for-adding-gpfs-software-to-existing-xcat-nodes-1)
    - [Network boot the nodes](#network-boot-the-nodes-1)
- [Build your GPFS cluster](#build-your-gpfs-cluster)
  - [Starting GPFS on cluster nodes](#starting-gpfs-on-cluster-nodes)
      - [Manually start GPFS](#manually-start-gpfs)
      - [GPFS autoload option](#gpfs-autoload-option)
      - [TEAL GPFS Connector Feature (optional)](#teal-gpfs-connector-feature-optional)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



### Overview

This document assumes that you have already purchased your GPFS product, have the Linux rpms or AIX packages available, and are familiar with the GPFS documentation: [GPFS library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.gpfs.doc/gpfsbooks.html)

These instructions are based on GPFS 3.3, GPFS 3.4 and GPFS 3.5. If you are using a different version of GPFS, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful (full-disk) install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.

### Linux

To set up GPFS in a stateful cluster, follow these steps:

#### Install/Build GPFS

  * Copy the GPFS rpms from your distribution media onto the xCAT management node (MN), following the instructions you received and accepting the product licenses as required. Suggested target location to put the rpms on the xCAT MN:

~~~~
     /install/post/otherpkgs/<os>/<arch>/gpfs
~~~~


For example on rhels6 ppc64, the target location might be:

~~~~
     /install/post/otherpkgs/rhels6/ppc64/gpfs/
~~~~


 * Note: (optional) If you want to use the optional TEAL GPFS connector feature, copy the teal-gpfs-sn rpm to /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/gpfs on your xCAT management node. The teal-gpfs-sn rpm is shipped with the TEAL product.

  * (optional) Download GPFS updates following your normal procedures. This may be a useful link: [GPFS Support and Downloads](http://www14.software.ibm.com/webapp/set2/sas/f/gpfs/home.html).

Suggested target location for the update rpms:

~~~~
    /install/post/otherpkgs/gpfs_updates
~~~~


  * Install the GPFS base and update rpms on your xCAT management node following the [GPFS documentation](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=/com.ibm.cluster.gpfs.doc/gpfsbooks.html).
  * (optional) If you want to use the optional TEAL GPFS connector feature, install the teal-base and teal-gpfs rpms onto your xCAT management node. Please refer to [Setting_up_TEAL_on_xCAT_Management_Node] for details.
  * Assuming that the kernel and architecture of your xCAT management node is the same as all your compute nodes, build the GPFS portability layer rpm following the instructions provided by GPFS. See:

~~~~
      /usr/lpp/mmfs/src/README
~~~~


   * NOTE: This requires that the kernel source rpms are installed on your xCAT management node. For example, for SLES11, make sure the kernel-source and kernel-ppc64-devel rpms are installed. For rhels6, make sure the cpp.ppc64,gcc.ppc64,gcc-c++.ppc64,kernel-devel.ppc64 and rpm-build.ppc64 are installed; If not, please run "yum install cpp.ppc64 gcc.ppc64 gcc-c++.ppc64 kernel-devel.ppc64 rpm-build.ppc64" on rhels6 xCAT MN.
     If the kernel of your compute nodes will be different from that of your xCAT management node, you will first need to install one node with all of the GPFS and kernel source rpms, follow these instructions to build the GPFS portability layer rpm there, copy that rpm back to your xCAT management node and then continue with the rest of these procedures to add the rpm to your image and install/configure GPFS.

  * Install the new rpm on your xCAT management node and copy it to your otherpkgs directory in preparation for installing it into your diskless images:

~~~~
     cd /usr/src/packages/RPMS/ppc64
     rpm -Uvh gpfs.gplbin*.rpm
     cp gpfs.gplbin*.rpm /install/post/otherpkgs/<os>/<arch>/gpfs
~~~~

For rhels6 ppc64, please run the following commands:

~~~~
   cd /root/rpmbuild/RPMS/ppc64/
   rpm -Uvh gpfs.gplbin*.rpm
   cp gpfs.gplbin*.rpm /install/post/otherpkgs/rhels6/ppc64/gpfs/
   createrepo /install/post/otherpkgs/rhels6/ppc64/gpfs/
~~~~



Note: If the **createrepo** command is not found, you may need to install the createrepo rpm package that is shipped with your OS distribution.

#### Add GPFS to your stateful image definition

Include GPFS in your stateful image definition:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node and service nodes. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your management node. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

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
       #INCLUDE:/opt/xcat/share/xcat/install/sles/service.<osver>.<arch>.otherpkgs.pkglist#
~~~~
     Either way, add this line:

~~~~
        xcat/xcat-core/xCAT-IBMhpc

~~~~




  * If your service nodes are already installed and running, update the software on your service nodes:

~~~~
      updatenode <service-noderange> -S
~~~~


  * TEAL GPFS Connector Feature (optional)

     If you have a hierarchical cluster with service nodes, and want to use the optional TEAL GPFS connector feature, install teal-gpfs-sn rpm on the GPFS collector service node (and backup GPFS collector service nodes if possible) following the instruction below:



  * Add teal-gpfs-sn to your otherpkgs list:

~~~~
       vi /install/custom/install/<ostype>/<service-profile>.otherpkgs.pkglist
~~~~

     Add two lines:

~~~~
       #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.<arch>.otherpkgs.pkglist#
       #INCLUDE:/opt/xcat/share/xcat/IBMhpc/teal/teal-gpfs-collector.otherpkgs.pkglist#

~~~~




  * If your service nodes are already installed and running, update the software on your service nodes:

~~~~
      updatenode <service-noderange> -S
~~~~


  * Add to pkglist:

   Edit your /install/custom/install/&lt;ostype&gt;/<profile&gt;.pkglist and add the base IBMhpc pkglist: For sles11 ppc64:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
~~~~


For rhels6 ppc64:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
~~~~


Verify that the above sample pkglist contains the correct packages. If you need to make changes, you can copy the contents of the file into your <profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.


Note: This pkglist support is available with xCAT 2.5 and newer releases. If you are using an older release of xCAT, you will need to add the entries listed in these pkglist files to your Kickstart or AutoYaST install template file.

  * Add to otherpkgs:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.<arch>.otherpkgs.pkglist#
~~~~


Verify that the above sample pkglist contains the correct gpfs packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry. These packages will be installed on the node after the first reboot by the xCAT postbootscript otherpkgs.

You can find more information on the xCAT otherpkgs package list files and their use in the xCAT documentation [Using_Updatenode].

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/gpfs
~~~~

If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

  * Add to postscripts:

     Copy the IBMhpc postscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
~~~~


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will run after all OS rpms are installed on the node and the xCAT default postscripts have run, but before the node reboots for the first time.


     Add this script to the postscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script:

~~~~
      chdef -t group -o compute -p postscripts=IBMhpc.postscript
~~~~


  * Add to postbootscripts:

     Copy the GPFS postbootscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
~~~~


     Review and edit this script to meet your needs. This script will run on the node after OS has been installed, the node has rebooted for the first time, and the xCAT default postbootscripts have run.

     NOTE: If you are installing a GPFS I/O node, you MUST make a local copy of the gpfs_updates script and comment out the lines that create a non-functional nsddevices script. You need a working copy of this script for your I/O server so that it can find the disks it needs to build your GPFS filesystems.

     Add this script to the postbootscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script and the nodes' attribute postbootscripts value is otherpkgs:

~~~~
      chdef -t group -o compute -p postbootscripts=gpfs_updates
~~~~


     If you already have unique postbootscripts attribute settings for some of your nodes (i.e. the value contains more than simply "otherpkgs" and that value is not part of the above group definition), you may need to change those node definitions directly:

~~~~
      chdef <noderange> -p postbootscripts=gpfs_updates
~~~~


#### Instructions for adding GPFS Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding GPFS software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to add the GPFS software and run the postscripts using the pkglist and otherpkgs.pkglist files created above. Note that support was added to updatenode in xCAT 2.5 to install packages listed in pkglist files (previously, only otherpkgs.pkglist entries were installed). If you are running an older version of xCAT, you may need to add the pkglist entries to your otherpkgs.pkglist file or install those packages in some other way on your existing nodes.

You will want updatenode to run zypper or yum to install all of the packages. Make sure their repositories have access to the base OS rpms:

      #SLES:

~~~~
      xdsh <noderange> zypper repos --details  | xcoll
~~~~

      #RedHat:

~~~~
      xdsh <noderange> yum repolist -v  | xcoll

~~~~


If you installed these nodes with xCAT, you probably still have repositories set pointing to your distro directories on the xCAT MN or SNs. If there is no OS repository listed, add appropriate remote repositories using the zypper ar command or adding entries to /etc/yum/repos.d.

Also, for updatenode to use zypper or yum to install packages from your /install/post/otherpkgs directories, make sure you have run the createrepo command for each of your otherpkgs directories (see instructions in the document [Using_Updatenode] .

Update the software on your nodes:

~~~~
      updatenode <noderange> -S
~~~~


Run postscripts and postbootscripts on your nodes:

~~~~
      updatenode <noderange> -P
~~~~


#### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; install" for all your nodes
    * Run rnetboot to boot and install your nodes
    * When the nodes are up, verify that the GPFS rpms are all correctly installed.

GPFS installation documentation advises having all your nodes running and installed with the GPFS rpms before creating your GPFS cluster. However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later. If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online. You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.

### AIX

As stated at the beginning of this page, these instructions assume that you have already created a stateful image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX nodes [XCAT_AIX_RTE_Diskfull_Nodes].




#### Add GPFS to your stateful image

Include GPFS in your image:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from [Download xCAT](Download_xCAT).

    To install the rpm:

~~~~
      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm
~~~~


  * TEAL GPFS Connector Feature (optional)



  * If you want to use the optional TEAL GPFS connector feature, install the teal.base and teal.gpfs installp packages onto your xCAT management node, refer to [Setting_up_TEAL_on_xCAT_Management_Node] for details.



  * If you have a hierarchical cluster with service nodes, and want to use the optional TEAL GPFS connector feature, install teal.gpfs-sn installp package on the GPFS collector service node (and backup GPFS collector service nodes if possible) following the instruction below:

~~~~
         cp /opt/xcat/share/xcat/IBMhpc/teal/teal-gpfs-collector.bnd /install/nim/installp_bundle
         nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/teal-gpfs-collector.bnd teal
~~~~

         # Assume you have IBMhpc_base and gpfs NIM installp_bundle defined, if not, follow the instruction below to define them

~~~~
         chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,gpfs,teal"
~~~~


     If your service nodes are already installed and running, update the software on your service nodes:

~~~~
         updatenode <service-noderange> -S
~~~~


  * Copy the GPFS product packages and PTFS from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN:

~~~~
    /install/post/otherpkgs/aix/ppc64/gpfs
~~~~


    Note: (optional) If you want to use the optional TEAL GPFS connector feature, copy teal.gpfs-sn package to /install/post/otherpkgs/aix/ppc64/gpfs on your xCAT management node. The teal.gpfs-sn package is shipped with TEAL product.
     The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd
~~~~


  * Add the GPFS packages to the lpp_source used to build your stateful image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/gpfs
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/gpfs   <lpp_source_name>
~~~~


  * Add additional base AIX packages to your lpp_source:

     Some of the HPC products require additional AIX packages that may not be part of your default AIX lpp_source. Review the following file to verify all the AIX packages needed by the HPC products are included in your lpp_source (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd
~~~~


     To list the contents of your lpp_source, you can use:

~~~~
      nim -o showres <lpp_source_name>
~~~~


     And to add additional packages to your lpp_source, you can use the nim update command similar to above specifying your AIX distribution media and the AIX packages you need.

  * Create NIM bundle resources for base AIX prerequisites and for your GPFS packages:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/gpfs.bnd gpfs
~~~~


     Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,gpfs"
~~~~


  * Add base HPC and GPFS postscripts

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,gpfs_updates"
~~~~


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT diskless node postscript processing.

#### Instructions for adding GPFS Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding GPFS software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to add the GPFS software and run the postscripts. To have updatenode install both the OS prereqs and the base GPFS packages, complete the previous instructions to add GPFS software to your image.

Update the software on your nodes:

~~~~
      updatenode <noderange> -S installp_flags="-agQXY"
~~~~


Run postscripts and postbootscripts on your nodes:

~~~~
      updatenode <noderange> -P
~~~~


#### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_RTE_Diskfull_Nodes] to network boot your nodes:

  *     * If the nodes are not already defined to NIM, run xcat2nim for all your nodes
    * Run nimnodeset for your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that GPFS is correctly installed.

GPFS installation documentation advises having all your nodes running and installed with the GPFS lpps before creating your GPFS cluster. However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later. If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online. You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.

## Build your GPFS cluster

Follow the GPFS documentation to create your GPFS cluster, define manager nodes, quorum nodes, accept licenses, create NSD disk definitions, and create your filesystems. Once you have verified that your GPFS cluster is operational and that the GPFS filesystems are available to the currently active nodes, you can add your remaining compute nodes to the GPFS cluster.

The mmaddnode command will accept a file containing a list of node names as input. xCAT can help you create this file. Simply run the xCAT nodels command against the desired noderange and redirect the output to a file. For example:

~~~~
       nodels compute > /tmp/gpfsnodes
       mmaddnode -N /tmp/gpfsnodes
~~~~





### Starting GPFS on cluster nodes

There are several ways you can start GPFS on your cluster nodes.

##### Manually start GPFS

Use the xCAT xdsh command to run the GPFS mmstartup command individually on all nodes, or use GPFS to distribute the commands by running "mmstartup -a". Note that for very large clusters, running an mmstartup command to all nodes in the cluster at one time can cause a heavy load on your network. Therefore, using xdsh with appropriate fanout values may be a better choice.

##### GPFS autoload option

The mmchconfig command allows you to set a cluster-wide option to automatically start GPFS anytime a node is booted:

~~~~
      mmchconfig autoload=yes
~~~~


The default setting for this option is "autoload=no". When you are first setting up GPFS across your cluster, you will probably choose NOT to turn this on until after you have initially installed all your nodes and done some cluster-wide verification.

##### TEAL GPFS Connector Feature (optional)

If you want to use the optional TEAL GPFS connector feature, after the GPFS cluster is correctly configured, verify that the teal-base and teal-gpfs rpms for Linux or the teal.base and teal.gpfs installps for AIX are correctly installed on your xCAT management node, the teal-gpfs-sn rpm for Linux or the teal.gpfs-sn installp for AIX is correctly installed on your GPFS collector service node(and backup GPFS collector service nodes if possible). Then, you can specify the selected service node as your TEAL GPFS collector node. Run the following command on the xCAT management node:

~~~~
       /opt/teal/bin/tlgpfschnode -C <GPFS cluster name>  -N <node name> -e
~~~~

       For example:

~~~~
       /opt/teal/bin/tlgpfschnode -C gpfscluster.cluster.com  -N myservicenode1 -e
~~~~


