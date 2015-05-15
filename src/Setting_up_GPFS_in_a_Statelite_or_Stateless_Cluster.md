<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Linux](#linux)
    - [Install/Build GPFS](#installbuild-gpfs)
    - [Add GPFS to your diskless image](#add-gpfs-to-your-diskless-image)
    - [Network boot the nodes](#network-boot-the-nodes)
  - [AIX](#aix)
    - [Add GPFS to your diskless image](#add-gpfs-to-your-diskless-image-1)
    - [Network boot the nodes](#network-boot-the-nodes-1)
  - [Build your GPFS cluster](#build-your-gpfs-cluster)
    - [GPFS cluster definition file mmsdrfs](#gpfs-cluster-definition-file-mmsdrfs)
    - [Starting GPFS on cluster nodes](#starting-gpfs-on-cluster-nodes)
      - [Manually start GPFS](#manually-start-gpfs)
      - [GPFS autoload option](#gpfs-autoload-option)
      - [TEAL GPFS Connector Feature (optional)](#teal-gpfs-connector-feature-optional)
      - [Use an xCAT postscript](#use-an-xcat-postscript)
    - [Previous xCAT autogpfs support](#previous-xcat-autogpfs-support)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document assumes that you have already purchased your GPFS product, have the Linux rpms available, and are familiar with the GPFS documentation: [GPFS Library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.gpfs.doc/gpfsbooks.html)

These instructions are based on GPFS 3.3. GPFS 3.4 and GPFS 3.5. If you are using a different version of GPFS, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a diskless install.
  * You should have a diskless image created with the base OS installed and verified on at least one test node.

### Linux

To set up GPFS in a statelite or stateless cluster, follow these steps:

#### Install/Build GPFS

Copy the GPFS rpms from your distribution media onto the xCAT management node (MN), following the instructions you received and accepting the product licenses as required. Suggested target location to put the rpms on the xCAT MN:

~~~~

    /install/post/otherpkgs/<os>/<arch>/gpfs
~~~~


For rhels6 ppc64, the target location is:

~~~~
    /install/post/otherpkgs/rhels6/ppc64/gpfs
~~~~


Note: (optional) If you want to use the optional TEAL GPFS connector feature, copy the teal-gpfs-sn rpm to /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/gpfs on your xCAT management node. The teal-gpfs-sn rpm is shipped with the TEAL product.

(optional) Download GPFS updates following your normal procedures. This may be a useful link: [GPFS Support and Downloads](http://www14.software.ibm.com/webapp/set2/sas/f/gpfs/home.html). Suggested target location for the update rpms:

~~~~
    /install/post/otherpkgs/gpfs_updates
~~~~


Install the GPFS base and update rpms on your xCAT management node following the [GPFS documentation](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=/com.ibm.cluster.gpfs.doc/gpfsbooks.html).
(optional) If you want to use the optional TEAL GPFS connector feature, install the teal-base and teal-gpfs rpms onto your xCAT management node. Refer to [Setting_up_TEAL_on_xCAT_Management_Node] for details.
Assuming that the kernel and architecture of your xCAT management node is the same as all your compute nodes, build the GPFS portability layer rpm following the instructions provided by GPFS. See:

~~~~
      /usr/lpp/mmfs/src/README
~~~~


NOTE: This requires that the kernel source rpms are installed on your xCAT management node. For example, for SLES11, make sure the kernel-source and kernel-ppc64-devel rpms are installed. For rhels6, make sure the cpp.ppc64,gcc.ppc64,gcc-c++.ppc64,kernel-devel.ppc64 and rpm-build.ppc64 are installed; If not, please run "yum install cpp.ppc64 gcc.ppc64 gcc-c++.ppc64 kernel-devel.ppc64 rpm-build.ppc64 compat-libstdc++-33.ppc64 rsh.ppc64" on rhels6 xCAT MN.
If the kernel of your compute nodes will be different from that of your xCAT management node, you will first need to install one node with all of the GPFS and kernel source rpms, follow these instructions to build the GPFS portability layer rpm there, copy that rpm back to your xCAT management node and then continue with the rest of these procedures to add the rpm to your image and install/configure GPFS.

Install the new rpm on your xCAT management node and copy it to your otherpkgs directory in preparation for installing it into your diskless images:

For sles11 ppc64, please run the following commands:

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


If the **createrepo** command is not found, you may need to install the createrepo rpm package that is shipped with your OS distribution.

#### Add GPFS to your diskless image

Include GPFS in your diskless image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your managaement node. A new copy can be downloaded from [Download xCAT](Download_xCAT).

To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc

~~~~

    To install the rpm in Redhat:

~~~~
      yum install xCAT-IBMhpc

~~~~

TEAL GPFS Connector Feature (optional):

If you have a hierarchical cluster with service nodes, and want to use the optional TEAL GPFS connector feature, please install teal-gpfs-sn rpm on the GPFS collector service node (and backup GPFS collector service nodes if possible) following the instruction below:



Add teal-gpfs-sn to your otherpkgs list:

~~~~
      vi /install/custom/install/<ostype>/<service-profile>.otherpkgs.pkglist
~~~~
    Add two lines:

~~~~
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/teal/teal-gpfs-collector.otherpkgs.pkglist#

~~~~



If your service nodes are already installed and running, update the software on your service nodes:

~~~~
      updatenode <service-noderange> -S

~~~~

Add to pkglist: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add the base IBMhpc pkglist:

For sles11 ppc64:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
~~~~


For rhels6 ppc64:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
~~~~


Verify that the above sample pkglist contains the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

Add to otherpkgs: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.<arch>.otherpkgs.pkglist#
~~~~


Verify that the above sample pkglist contains the correct gpfs packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

If you are building a stateless image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Add to exclude list: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.<osver>.<arch>.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.exlist#
~~~~


Verify that the above sample exclude lists contain the files and directories you want deleted from your diskless image. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.exlist and edit as you wish instead of using the #INCLUDE: ...# entry.
     Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+_directory_" syntax) that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.*.exlist. Keeping these files in the diskless image is required for the install and functionality of some of the HPC products.

If you are building a statelite image, refer to the xCAT documentation for statelite images for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your GPFS support, add writable and persistent directories/files required by GPFS to your litefile table in the xCAT database:

~~~~
      tabedit litefile
~~~~

In a separate window cut the contents of /opt/xcat/share/xcat/IBMhpc/gpfs/litefile.csv
paste into your tabedit session, modify as needed for your environment, and save


When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.
Note: The sample litefile.csv contains an entry for the /gpfs directory which is the default mount point for your GPFS filesystems on the node. If you create your GPFS filesystems with a different mount point, you will need to change this entry accordingly.

Add to postinstall scripts:

Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall(please make sure it has executable permission) and add:

~~~~
     /opt/xcat/share/xcat/IBMhpc/IBMhpc.<os>.postinstall $1 $2 $3 $4 $5
     NODESETSTATE=genimage installroot=$installroot /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates
~~~~


For rhels6 ppc64, edit the /install/custom/netboot/rh/compute.postinstall(please make sure it has executable permission) and add:

~~~~
     /opt/xcat/share/xcat/IBMhpc/IBMhpc.rhel.postinstall $1 $2 $3 $4 $5
     NODESETSTATE=genimage installroot=$1 /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. They will be run by genimage after all of your rpms are installed into the image. First the basic IBMhpc script will be run to create filesystems, turn on services, and set some tunables. Then the script to install the gpfs update rpms into the image will be run, and the script will also do some additional configuration work such as creating a non-functional nsddevices script and adding GPFS paths to the default profile. Verify that these scripts will work correctly for your cluster. If you wish to make changes to any of these scripts, copy it to /install/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.
NOTE: If you are creating an image that will be used for GPFS I/O nodes, you MUST make a local copy of the gpfs_updates script and comment out the lines that create a non-functional nsddevices script. You need a working copy of this script for your I/O server so that it can find the disks it needs to build your GPFS filesystems.

Once your nodes have been added to the GPFS cluster (see below), you can add the following after the previous entry:

~~~~
     installroot=$installroot /install/postscripts/gpfs_mmsdrfs
~~~~


For rhels6 ppc64, the entry should be:

~~~~
     installroot=$1 /install/postscripts/gpfs_mmsdrfs
~~~~


You need to copy this script from the /opt/xcat/share/xcat/IBMhpc/gpfs directory to /install/postscripts and edit it to provide the correct location of your master mmsdrfs file (see section below for more information).
     Including the mmsdrfs file in the image before the node has been added will cause the mmaddnode command to fail with an error that GPFS thinks the node already belongs to another GPFS cluster.

  * Run genimage for your image
  * Run packimage or liteimg for your image

#### Network boot the nodes

Network boot your nodes:

~~~~
   nodeset <noderange> netboot for all your nodes
   rnetboot (noderange> to boot your nodes
~~~~

When the nodes are up, verify that the GPFS rpms are all correctly installed.

GPFS installation documentation advises having all your nodes running and installed with the GPFS rpms before creating your GPFS cluster. However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later. If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online. You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.




### AIX

As stated at the beginning of this page, these instructions assume that you have already created a diskless image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX diskless nodes [XCAT_AIX_Diskless_Nodes].

xCAT recommends that you use the mknimimage --sharedroot option to use the NIM shared root support for your diskless nodes. Your nodes will be stateless in that they will not maintain persistent files in the / root directory across reboots, but the node NIM initialization process will be much quicker, and the load on your NFS server (NIM master) will be significantly reduced.

#### Add GPFS to your diskless image

Include GPFS in your diskless image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from [Download xCAT](Download_xCAT).

    To install the rpm:

~~~~
      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm

~~~~
TEAL GPFS Connector Feature (optional):



If you want to use the optional TEAL GPFS connector feature, install the teal.base and teal.gpfs installp packages onto your xCAT management node, refer to [Setting_up_TEAL_on_xCAT_Management_Node] for details.
If you have a hierarchical cluster with service nodes, and want to use the optional TEAL GPFS connector feature, install the teal.gpfs-sn installp package on the GPFS collector service node (and backup GPFS collector service nodes if possible) following the instruction below:

~~~~
       cp /opt/xcat/share/xcat/IBMhpc/teal/teal-gpfs-collector.bnd /install/nim/installp_bundle
       nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/teal-gpfs-collector.bnd teal
~~~~

Assume you have IBMhpc_base and gpfs NIM installp_bundle defined, if not, follow the instruction below to define them

~~~~
       chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,gpfs,teal"
~~~~


     If your service nodes are already installed and running, update the software on your service nodes:

~~~~
       updatenode <service-noderange> -S
~~~~


Copy the GPFS product packages and PTFS from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN:

~~~~
    /install/post/otherpkgs/aix/ppc64/gpfs
~~~~


Note: (optional) If you want to use the optional TEAL GPFS connector feature, copy teal.gpfs-sn package to /install/post/otherpkgs/aix/ppc64/gpfs on your xCAT management node. The teal.gpfs-sn package is shipped with the TEAL product.
The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd
~~~~


Add the GPFS packages to the lpp_source used to build your diskless image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/gpfs
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/gpfs   <lpp_source_name>
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

Create NIM bundle resources for base AIX prerequisites and for GPFS packages:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/gpfs.bnd gpfs
~~~~


Review these sample bundle files and make any changes as desired.

Add the bundle resource to your xCAT diskless image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,gpfs"
~~~~


Update the image:

Note: Verify that there are no nodes actively using the current diskless image. NIM will fail if there are any NIM machine definitions that have the SPOT for this image allocated. If there are active nodes accessing the image, you will either need to power them down and run rmdkslsnode for those nodes, or you will need to create a new image and then switch your nodes to that image later. For more information and detailed instructions on these options, see the xCAT document for updating software on AIX nodes: [Updating_AIX_Software_on_xCAT_Nodes].

~~~~
      mknimimage -u <image_name>
~~~~


Add base HPC and GPFS postscripts

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,gpfs_updates"
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT diskless node postscript processing.

Optionally update the GPFS mmsdrfs configuration file in your image.

Once your nodes have been added to the GPFS cluster See [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster/#build-your-gpfs-cluster](Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster/#build-your-gpfs-cluster) below, you can run the following script on the xCAT management node to update the GPFS mmsdrfs configuration file in your image.

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_mmsdrfs /install/postscripts
     vi /install/postscripts/gpfs_mmsdrfs
        # Edit script to set GPFS master SOURCE config file, xCAT IMAGE names, and other values
     /install/postscripts/gpfs_mmsdrfs
~~~~


See section [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster/#gpfs-cluster-definition-file-mmsdrfs](Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster/#gpfs-cluster-definition-file-mmsdrfs) below for more information.
     Note: Including the mmsdrfs file in the image before the node has been added will cause the mmaddnode command to fail with an error that GPFS thinks the node already belongs to another GPFS cluster.

#### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_Diskless_Nodes] to network boot your nodes:


  *     * Run mkdsklsnode for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that GPFS is correctly installed.

GPFS installation documentation advises having all your nodes running and installed with the GPFS lpps before creating your GPFS cluster. However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later. If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online. You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.

### Build your GPFS cluster

Follow the GPFS documentation to create your GPFS cluster, define manager nodes, quorum nodes, accept licenses, create NSD disk definitions, and create your filesystems. Once you have verified that your GPFS cluster is operational and that the GPFS filesystems are available to the currently active nodes, you can add your remaining compute nodes to the GPFS cluster.

The mmaddnode command will accept a file containing a list of node names as input. xCAT can help you create this file. Simply run the xCAT nodels command against the desired noderange and redirect the output to a file. This file can then be used as input to GPFS commands. For example:

~~~~
       nodels compute > /tmp/gpfsnodes
       mmaddnode -N /tmp/gpfsnodes
~~~~


#### GPFS cluster definition file mmsdrfs

GPFS stores its cluster definition in the file /var/mmfs/gen/mmsdrfs. When changes are made to the GPFS cluster, GPFS contacts all active nodes and updates the copy of this file on those nodes. With diskless images, this file may not be persistent across reboots of the node. Therefore, it is important to keep an updated copy in each diskless image to ensure the node can correctly rejoin the GPFS cluster if it is rebooted. xCAT provides the following sample script to help you with this:

~~~~
      /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_mmsdrfs

~~~~

This script uses rsync to keep the mmsdrfs file updated in your images. You will need to copy this script to your /install/postscripts directory and edit it to identify the correct SOURCE location of your master mmsdrfs file, the target IMAGEs to be updated, and if using xCAT hierarchy with local disks on the service node, the noderange of the SERVICE nodes to be kept current. When you invoke the script, you can specify if you also want to run packimage or liteimg for each of your Linux images, and if you want to sync your /install/netboot directory to your service nodes if updates have been made:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_mmsdrfs /install/postscripts
      vi /install/postscripts/gpfs_mmsdrfs
      /install/postscripts/gpfs_mmsdrfs packimage syncinstall
~~~~


(specify "packimage" or "liteimg" only for your Linux diskless or stateless images respectively. "syncinstall" is required for AIX as the first option).

If you will be making limited changes to your GPFS cluster configuration, you may choose to run this script manually after each set of changes. However, if you are making frequent changes, or if you may forget to update the images after making changes to the GPFS cluster, you may choose to run this script periodically as a cron job. For example, add the following to your crontab to check every 10 minutes:

      */10 * * * * /install/postscripts/gpfs_mmsdrfs packimage syncinstall 2&gt;&1 &gt;&gt; /tmp/gpfs_mmsdrfs.log


(specify "packimage" or "liteimg" only for your Linux diskless or stateless images respectively. "syncinstall" is required for AIX as the first option).

For Linux, you should also update your image postinstall scripts in /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall to run this script from genimage to place a current copy of the mmsdrfs file into your image each time genimage is run. When doing so, make sure to invoke this script with the $installroot environment variable set to ignore your IMAGE settings in the script and only update the image that genimage is being run for.

Note: If you have a copy of the mmsdrfs file in an image that is booted on a node that has NOT been added to the GPFS cluster yet, the mmaddnode command will fail with an error that GPFS thinks the node is already part of another cluster. You will need to remove the runtime copy of the /var/mmfs/gen/mmsdrfs file on the node before running mmaddnode:

~~~~
      xdsh <noderange> rm /var/mmfs/gen/mmsdrfs
~~~~


#### Starting GPFS on cluster nodes

There are several ways you can start GPFS on your cluster nodes.

##### Manually start GPFS

Use the xCAT xdsh command to run the GPFS mmstartup command individually on all nodes, or use GPFS to distribute the commands by running "mmstartup -a". Note that for very large clusters, running an mmstartup command to all nodes in the cluster at one time can cause a heavy load on your network. Therefore, using xdsh with appropriate fanout values may be a better choice.

##### GPFS autoload option

The mmchconfig command allows you to set a cluster-wide option to automatically start GPFS anytime a node is booted:

~~~~
      mmchconfig autoload=yes
~~~~


The default setting for this option is "autoload=no". When you are first setting up GPFS across your cluster, you will probably choose NOT to turn this on until after you have initially installed all your nodes and done some cluster-wide verification.

When changing this setting for your GPFS cluster, be sure to update the mmsdrfs file in all of your diskless images as described above to ensure the correct value is available when the node reboots.

##### TEAL GPFS Connector Feature (optional)

If you want to use the optional TEAL GPFS connector feature, after the GPFS cluster is correctly configured, verify that the teal-base and teal-gpfs rpms for Linux and teal.base and teal.gpfs installps for AIX are correctly installed on your xCAT management node, the teal-gpfs-sn rpm for Linux and teal.gpfs-sn installp for AIX is correctly installed on your GPFS collector service node(and backup GPFS collector service nodes if possible). Then, you can specify the selected service node as your TEAL GPFS collector node. Run the following command on the xCAT management node:

~~~~
       /opt/teal/bin/tlgpfschnode -C <GPFS cluster name>  -N <node name> -e
~~~~

       For example:

~~~~
       /opt/teal/bin/tlgpfschnode -C gpfscluster.cluster.com  -N myservicenode1 -e

~~~~

##### Use an xCAT postscript

You can create your own postscript in /install/postscripts and add an entry to the xCAT postscripts table for your nodes. The postscript can be as simple as:

~~~~
      /usr/lpp/mmfs/bin/mmsdrrestore
      /usr/lpp/mmfs/bin/mmstartup
~~~~


If GPFS is using a network interface that is not immediately available at node boot time (e.g. an IB interface that needs to be configured from an xCAT postscript and may take a little extra time becoming stable), you may wish to add some network health checks to your script before starting GPFS.

#### Previous xCAT autogpfs support

xCAT previously shipped support for using GPFS in stateless Linux clusters in

~~~~
      /opt/xcat/share/xcat/netboot/add-on/autogpfs
~~~~


Note:This support (autogpfs) is no longer being maintained, although it may still work for you if you choose to use it. The methodologies outlined in this document are the preferred usage.


