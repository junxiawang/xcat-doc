<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node)
    - [Install/Build GPFS](#installbuild-gpfs)
    - [Install Your LoadLeveler Central Manager (optional)](#install-your-loadleveler-central-manager-optional)
    - [Add the HPC software to your diskless image](#add-the-hpc-software-to-your-diskless-image)
    - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node-1)
    - [Install GPFS (optional)](#install-gpfs-optional)
    - [Install Your LoadLeveler Central Manager (optional)](#install-your-loadleveler-central-manager-optional-1)
    - [Use LoadLeveler Database Configuration Option](#use-loadleveler-database-configuration-option)
    - [Add the HPC software to your diskless image](#add-the-hpc-software-to-your-diskless-image-1)
    - [Network boot the nodes](#network-boot-the-nodes-1)
- [Build and configure your GPFS cluster](#build-and-configure-your-gpfs-cluster)
- [Starting HPC software on cluster nodes](#starting-hpc-software-on-cluster-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

This document assumes that you have already purchased all of your IBM HPC products, have the product packages available, and are familiar with each product documentation: [http://publib.boulder.ibm.com/infocen.../infocenter.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.infocenter.doc/infocenter.html)

These instructions show you how to combine all of the individual product setup samples to install all the IBM HPC products together into your cluster.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a diskless install.
  * You should have a diskless image created with the base OS installed and verified on at least one test node.

Loadleveler and POE require that userids be common across all nodes in a cluster, and that the user home directories are shared. There are many different ways to handle user management and to set up a cluster-wide shared home directory (for example, using NFS or through a global filesystem such as GPFS). These instructions assume that the shared home directory has already been created and mounted across the cluster and that the xCAT management node and all xCAT service nodes are also using this directory. You may wish to have xCAT invoke your custom postbootscripts on nodes to help set this up.



## Linux

To set up all HPC products in a statelite or stateless cluster, follow these steps:

#### Copy the HPC software to your xCAT management node

Include all of the HPC software in your xCAT management node:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your managaement node. A new copy can be downloaded from: &lt;http://xcat.sourceforge.net/#download&gt;

    To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc
~~~~


    To install the rpm in Redhat:

~~~~
      yum install xCAT-IBMhpc
~~~~


  * Copy all of your IBM HPC product software to the following locations:

~~~~
       /install/post/otherpkgs/<osver>/<arch>/<product>


     where <product> is:

    gpfs
    loadl
    pe
    essl
    compilers
    rsct
~~~~

For rhels6 ppc64, the locations are:

~~~~
       /install/post/otherpkgs/rhels6/ppc64/<product>
~~~~

Note1: Several of the products require the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in one of the above directories before proceeding.
Note2: For GPFS, only the base GPFS rpms can be placed in the above directories. If you have GPFS updates, copy them to the following location:

~~~~
      /install/post/otherpkgs/gpfs_updates
~~~~


Note3: Several products require special Java rpms to run their license acceptance scripts. The correct versions of these rpms are identified in the respective product documentation. Ensure the Java rpms are included in the corresponding product otherpkgs directory.
Note4: You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/&lt;product&gt; directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/gpfs
      createrepo /install/post/otherpkgs/<os>/<arch>/pe
      createrepo /install/post/otherpkgs/<os>/<arch>/compilers
      createrepo /install/post/otherpkgs/<os>/<arch>/essl
      createrepo /install/post/otherpkgs/<os>/<arch>/rsct
~~~~

If the **createrepo** command is not found, you may need to install the createrepo rpm package that is 
    shipped with your Linux OS. For SLES 11, this is found on the SDK media.

#### Install/Build GPFS

Follow the instructions in [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] for installing GPFS on your xCAT management node and building the GPFS portability layer.

#### Install Your LoadLeveler Central Manager (optional)

You may choose to install LoadLeveler on your xCAT management node and set it up as your LL central manager. If so, follow the instructions in [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] for installing LoadLeveler on your xCAT management node and setting it up as your central manager.

#### Add the HPC software to your diskless image

Include all of the HPC software in your diskless image:

  * Add to pkglist:

     Review the following pkglist file and all of the files it includes:

~~~~
     /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist
~~~~

or, if you are building a minimal stateless image that has eliminated much 
of the software not required for runtime compute nodes, use:

~~~~
     /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.pkglist
~~~~


If you do not need to make any changes and are able to use the file as shipped, add an #INCLUDE ...# statement for this file to your custom pkglist:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.pkglist
      Add the following line, substituting <osver> and <arch> with the correct values:
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist#
~~~~




For rhels6 ppc64, please edit the following file:

~~~~
      vi /install/custom/netboot/rh/compute.pkglist
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.pkglist#
~~~~


If you need to make changes to any of the files, you can copy the file to your custom directory

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist \
             /install/custom/netboot/<ostype>/<profile>.pkglist
~~~~


and modify it or you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * Add to otherpkgs:

     Review the following pkglist file and all of the files it includes:

~~~~
     /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.otherpkgs.pkglist
~~~~


or, if you are building a minimal stateless image that has eliminated much of the software not required for
 runtime compute nodes, use:

~~~~
     /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.otherpkgs.pkglist
~~~~


If you do not need to make any changes and are able to use the file as shipped, add an #INCLUDE ...# statement
 for this file to your custom otherpkgs pkglist:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.otherpkgs.pkglist
      Add the following line, substituting <osver> and <arch> with the correct values:
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.otherpkgs.pkglist#
~~~~

If you need to make changes to any of the files, you can copy the file to your custom directory

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.otherpkgs.pkglist \
        /install/custom/netboot/<ostype>/<profile>.otherpkgs.pkglist
~~~~


and modify it or you can copy the contents of the file into your &lt;profile&gt;.pkglist 
      and edit as you wish instead of using the #INCLUDE: ...# entry.

Note: By default, the compute.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist file will install PE 1.2.0.0.
 If you wish to install PE RTE 1.1.0.0, you will need to copy the sample pkglist file and edit it to change
 the include for PE. For example, on RHELS6 ppc64, you would:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist  \
        /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
      vi <profile>.otherpkgs.pkglist
      #### Change the line for PE as indicated:
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1100.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist#
~~~~


If you wish to install PE 5.2.1 or below, you will need to copy the sample pkglist file and edit 
       it to change the include for PE. For example, on RHELS6 ppc64, you would:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist \
        /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
      vi <profile>.otherpkgs.pkglist
      #### Change the line for PE as indicated:
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist#

~~~~

Note: By default, the compute.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist file will install Loadl 5.1.0.3 or upper. If you wish to install Loadl 5.1.0.2 or below, you will need to copy the sample pkglist file and edit it to change the include for Loadl. For example, on RHELS6 ppc64, you would:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist
         /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
      vi <profile>.otherpkgs.pkglist
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl.otherpkgs.pkglist#
~~~~


  * Exclude lists:

If you are building a stateless image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Review the following exclude list file and all of the files it includes and verify that they contain all the files and directories you want deleted from your diskless image:

~~~~
     /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.exlist

~~~~

     or, if you are building a minimal stateless image that has eliminated much of the software not required for runtime compute nodes, use:

~~~~
     /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.exlist
~~~~


Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+directory" syntax) 
that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;
/compute.*.exlist. Keeping these files in the diskless image is required for the install and functionality of 
some of the HPC products.

If you do not need to make any changes and are able to use the file as shipped, add an #INCLUDE ...# statement for this file to your custom exclude list:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.exlist
      Add the following line, substituting <osver> and <arch> with the correct values:
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.exlist#
~~~~

If you need to make changes to any of the files, you can copy the file to your custom directory

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.exlist \
         /install/custom/netboot/<ostype>/<profile>.exlist
~~~~


and modify it or you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * If you are building a statelite image, refer to the xCAT documentation for statelite images for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your IBM HPC support, add writable and persistent directories/files required by all of your products to your litefile table in the xCAT database:

~~~~
      tabedit litefile
      <in a separate window> cut the contents of the following files:
        /opt/xcat/share/xcat/IBMhpc/gpfs/litefile.csv
        /opt/xcat/share/xcat/IBMhpc/loadl/litefile.csv
        /opt/xcat/share/xcat/IBMhpc/pe/litefile.csv
~~~~

Paste into your tabedit session, modify as needed for your environment, and save


This assumes that you have already added the base litefile entries as described in the xCAT statelite documentation. When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

Included in the loadl list is an entry for the /home directory. Depending on how you are managing your shared home directory for the cluster, you may need to implement a postbootscript that mounts the correct shared home directory on the node onto /.statelite/tmpfs/home.

 See the wiki page [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] for more notes on the LoadLeveler litefile entries.

Included in the gpfs list is an entry for the /gpfs directory which is the default mount point for your GPFS filesystems on the node. If you create your GPFS filesystems with a different mount point, you will need to change this entry accordingly.

 See the wiki page [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] for more notes on the GPFS litefile entries.

  * Add to postinstall scripts:

     Copy the following postinstall file:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.postinstall \
       /install/custom/netboot/<ostype>/<profile>.postinstall
~~~~


     or, if you are building a minimal stateless image that has eliminated much of the software not required for runtime compute nodes, use:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.postinstall \
        /install/custom/netboot/<ostype>/compute.<osver>.<arch>.postinstall
~~~~


Review this sample script and all of the scripts it invokes carefully and make any changes required for 
your cluster. Note that some of these scripts may change tuning values and other system settings. These 
scripts will be run by genimage after all of your rpms are installed into the image.

Verify that these scripts will work correctly for your cluster. If you wish to make changes to any of these
 scripts, copy those scripts to either your /install/custom/netboot/&lt;ostype&gt; directory or to /install
/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.

Since these scripts invoke other scripts shipped in the /opt/xcat/share/xcat/IBMhpc directories, if you
 copy ANY of the postinstall scripts to another directory for modification, you will also need to create a 
custom copy of the [min-]compute.&lt;osver&gt;.&lt;arch&gt;.postinstall script and edit the directory location
 to invoke your modified script.

Note: The /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_mmsdrfs script contains image names that will need to be
 changed if you run this script outside of the genimage processing to keep all of your images updated with 
GPFS config file changes; it does not need to be changed if you only call it from postinstall processing with 
genimage.
Note: By default, the compute.&lt;osver&gt;.&lt;arch&gt;.postinstall script will call the install script
 for PE 1.2.0.0 or upper. If you wish to install PE RTE 1.1.0.0, you will need to modify this call. For 
example, on RHELS6 ppc64, you would:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.postinstall \
           /install/custom/netboot/rh/<profile>.postinstall
      vi <profile>.postinstall
      #### Change the line for PE from:
      #installroot=$installroot pedir=$otherpkgs/pe NODESETSTATE=genimage   $hpc/pe/pe_install-1200
      ### to:
      installroot=$installroot pedir=$otherpkgs/pe NODESETSTATE=genimage   $hpc/pe/pe_install-1100
~~~~


If you wish to install PE 5.2.1 or below, you will need to modify this call also. For example, on RHELS6 ppc64, you would:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.postinstall\
         /install/custom/netboot/rh/<profile>.postinstall
      vi <profile>.postinstall
      #### Change the line for PE from:
      #installroot=$installroot pedir=$otherpkgs/pe NODESETSTATE=genimage   $hpc/pe/pe_install-1200
      ### to:
      installroot=$installroot pedir=$otherpkgs/pe NODESETSTATE=genimage   $hpc/pe/pe_install

~~~~

Note: By default, the compute.&lt;osver>.&lt;arch&gt;.postinstall script is assuming to install PESSL 
4.1.0 or upper. If you wish to install PESSL 3.3.3 or below, you will need to add essl_install script to 
compute.&lt;osver&gt;.&lt;arch&gt;.postinstall. For example, on RHELS6 ppc64, you would:


~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.postinstall \
           /install/custom/netboot/rh/<profile>.postinstall
      vi <profile>.postinstall
      #### Add the line for ESSL/PESSL:
      installroot=$installroot essldir=$otherpkgs/essl NODESETSTATE=genimage   $hpc/essl/essl_install
~~~~


Note: By default, the compute.&lt;osver&gt;.&lt;arch&gt;.postinstall script will call the install script 
for Loadl 5.1.0.3 or upper. If you wish to install Loadl 5.1.0.2 or below, you will need to modify this call.
 For example, on RHELS6 ppc64, you would:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.postinstall \
             /install/custom/netboot/rh/<profile>.postinstall
      vi <profile>.postinstall
      #### Change the line for ESSL/PESSL from:
      installroot=$installroot loadldir=$otherpkgs/loadl NODESETSTATE=genimage $hpc/loadl/loadl_install-5103
      ### to:
      installroot=$installroot loadldir=$otherpkgs/loadl NODESETSTATE=genimage $hpc/loadl/loadl_install
~~~~





  * (Optional) Synchronize system configuration files:

LoadLeveler and PE require that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.synclist
     add the following line (modify as appropriate for the files you wish to synchronize):
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


When packimage or litemiage is run, these files will be copied into the image. You can periodically 
re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: 
 [Sync-ing_Config_Files_to_Nodes].

  * (Optional) Use pelinks script to support multiple PE releases:

PE provides a root-owned script, pelinks, which allows installers and system administrators to establish
 symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. Refer to 
[IBM PE Runtime Edition]: Operation and Use for a description of the pelinks script.

If you want to switch among multiple PE releases in a Linux diskless image, you can edit PE postinstall
 script pe_install-1200 to uncomment following lines in script and change to the correct PE version that you
 intend to use.

~~~~
       # pelinks script support, uncomment the following lines and change to the correct pe version that you
       # intend to use.
       #PE_VERSION=1202
       #if [ "$OS" != "AIX" ]; then
       #    if [ $NODESETSTATE == "install" ] || [ $NODESETSTATE == "boot" ]; then
       #        MP_CONFIG=$PE_VERSION /opt/ibmhpc/pe$PE_VERSION/ppe.poe/bin/pelinks
       #    else
       #echo "chroot $installroot MP_CONFIG=$PE_VERSION /opt/ibmhpc/pe$PE_VERSION/ppe.poe/bin/pelinks"
       #        export MP_CONFIG=$PE_VERSION;chroot $installroot /opt/ibmhpc/pe$PE_VERSION/ppe.poe/bin/pelinks
       #    fi
       #fi

~~~~

You can also issue chroot command directly:

~~~~
       export MP_CONFIG=<PE version>; chroot <osimage directory> "/opt/ibmhpc/pe<PE version>/ppe.poe/bin/pelinks"
~~~~


For example, if you want to establish PE links to PE 1.2.0.2 release, run command:

~~~~
       export MP_CONFIG=1202; chroot <osimage directory> "/opt/ibmhpc/pe1202/ppe.poe/bin/pelinks"
~~~~





  * (Optional) Enable checkpoint and restart function in PE:

To enable checkpoint and restart function in PE, several additional steps are required to setup related 
system environment on compute node. Starting from xCAT 2.7.2, there is a script ckpt.sh provided by xCAT to 
config the system environment, including: virtualized pts support, unlinked file support, and read checkpoint 
key from rootfs which generated by xCAT postinstall script. Check PE document fore more checkpointing and 
restarting function details:[http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com
/infocenter/clresctr/vxrx/index.jsp)

Step 1
         Copy the ckpt.sh script from the PE installation directory to the /install/postscripts/ directory.
 Set the file permissions so that the scripts are world readable and executable by root.
Step 2
         Register the scripts in the node definitions in the xCAT database. If an xCAT nodegroup is defined 
for all nodes that will be using these scripts, run the following xCAT command:

~~~~
         chdef -t group -o <compute nodegroup> -p postscripts="ckpt.sh"
~~~~


  * (Optional, Power 775 cluster only) Enable BSR support for PE RTE:

BSR is a Power 775 cluster specific hardware feature. To config it for PE RTE, you will need to install 
BSR package from otherpkg list, edit PE postinstall script pe_install-1200 and uncomment several lines of 
script for BSR configuration. Check PE document for more BSR function details: [http://publib.boulder.ibm.com
/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)

Edit PE otherpkg list to include BSR package in PE otherpkg list.

~~~~
       vi pe-1200.rhels6.ppc64.otherpkgs.pkglist
       uncomment the following red line:
         pe/src
         #pe/libbsr
~~~~

Edit PE postinstall script to config BSR.

~~~~
      vi /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200
      uncomment the following lines:
       ## BSR configuration, uncomment the following lines to enable BSR configuration on Power Linux cluter.
       #if [ "$OS" != "AIX" ]; then
       #    chroot $installroot groupadd bsr
       #    chroot $installroot mkdir -p /var/lib/bsr
       #    chroot $installroot chown root:bsr /var/lib/bsr
       #    chroot $installroot chmod g+sw /var/lib/bsr
       #fi
~~~~


xCAT provides a postscript IBMhpc.post to setup one additional configuration for BSR support after the nodes
 bootup, you will need following steps to enable the configuration:

Step 1
         Copy the IBMhpc.post from IBM HPC installation directory to the /install/postscripts/ directory. Set
 the file permissions so that the scripts are world readable and executable by root:

~~~~
         cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.post /install/postscripts/
~~~~
Step 2
         Uncomment the BSR code in IBMhpc.post:
~~~~
         vi /install/postscripts/IBMhpc.post
         # BSR configuration on Power 775 cluster. More BSR configuration should
         # be done by PE postinstall in genimage or postbootscript in statefull install
         #chown root:bsr /dev/bsr*
~~~~

       Step 3
         Register the script in the node definitions in the xCAT database. If an xCAT nodegroup is defined for
 all nodes that will be using these scripts, run the following xCAT command:

~~~~
         chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.post"
~~~~


  * (Optional, Power 775 cluster only) Enable UPC compiler

UPC compiler is supported on Power 775 cluster, you will want to install UPC compiler RPMs from otherpkg list 
and accept the license by postinstall script if UPC compiler is used. You will need to copy the sample pkglist
 file and sample postinstall script, and add the include for UPC compiler. For example, you could:


~~~~
     ## Add upc.otherpkgs.pkglist to sample otherpkgs list:
     cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist \
        /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
     vi /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/upc.otherpkgs.pkglist#
~~~~

~~~~
     ## Add upc_license postinstall script to sample postinstall scripts:
     cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.postinstall \
            /install/custom/netboot/rh/<profile>.postinstall
     vi <profile>.postinstall
     #### Change the line for UPC compiler from:
     #installroot=$installroot NODESETSTATE=genimage   $hpc/compilers/upc_license
     #### To
     installroot=$installroot NODESETSTATE=genimage   $hpc/compilers/upc_license
~~~~



Note: The xlf, vacpp, and upc compilers all have a dependency on the xlmass-lib rpm. There is a problem 
that the current versions of the compilers require DIFFERENT versions of xlmass. xlf 13.1.0.x and vacpp 
11.1.0.x compilers requires xlmass 6.1 while upc 12.0.0.x compiler requires xlmass 7.1. To workaround it, you
 will need to add additional manual steps in compilers_license to install xlmass 6.1 and 7.1 both for nodes. For example, edit the compilers_license to install xlmass 6.1 manually:

Make sure the following xlmass.lib-6.1.0.x file name is correct and uncomment the red lines:

~~~~
     vi /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
       if [ $NODESETSTATE == "genimage" ]; then
             # Being called from <image>.postinstall script
             # Assume we are on the same machine
          ## Worakround for xlf/vacpp and upc compiler dependceies conflict issue.
          ## Install a low version of xlmass manually
          ## Uncomment the following lines for UPC compiler use
          #cp -p /install/post/otherpkgs/rhels6.2/ppc64/compilers/xlmass.lib-6.1.0*.rpm  $installroot/tmp
          #chroot $installroot rpm -ivh --oldpackage /tmp/xlmass.lib-6.1.0*.rpm
          if [ -n "$vacpp_script" ] ; then
              echo 1 | chroot $installroot /$vacpp_script
       fi
~~~~





* Run genimage for your image using the appropriate options for your OS, architecture, adapters, etc.
* Run packimage or liteimg for your image

#### Network boot the nodes

Network boot your nodes:

  * Run "nodeset &lt;noderange&gt; netboot" for all your nodes
  * Run rnetboot to boot your nodes
  * When the nodes are up, verify that all the HPC rpms are all correctly installed.

GPFS installation instructions advise having all your nodes running and installed with the GPFS rpms before
 creating your GPFS cluster. However, with very large clusters, you may choose to only have your main GPFS
 infrastructure nodes up and running, create your cluster, and then add your compute nodes later. If so, only
 install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS
 filesystems online. You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.

## AIX

As stated at the beginning of this page, these instructions assume that you have already created a diskless
 image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. 

For detailed instructions, see the xCAT document for deploying AIX diskless nodes 
[XCAT_AIX_Diskless_Nodes].


xCAT recommends that you use the mknimimage --sharedroot option to use the NIM shared root support for yourdiskless nodes. Your nodes will be stateless in that they will not maintain persistent files in the / rootdirectory across reboots, but the node NIM initialization process will be much quicker, and the load on our NFS server (NIM master) will be significantly reduced.

#### Copy the HPC software to your xCAT management node

Include the HPC products in your diskless image:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and hould already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when youran the instxcat script. A new copy can be downloaded from: &lt;http://xcat.sourceforge.net/#download&gt;

    To install the rpm:

~~~~
      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm
~~~~


  * Copy all of your IBM HPC product software to the following locations:

~~~~
       /install/post/otherpkgs/aix/ppc64/<product>


     where <product> is:

    gpfs
    loadl
    pe
    essl
    compilers
    rsct
~~~~

The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions
 are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc_all.bnd
~~~~


  * Add the HPC packages to the lpp_source used to build your diskless image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/gpfs
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/gpfs   <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/loadl
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/loadl   <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/pe
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/pe   <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/essl
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/essl   <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/compilers
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/compilers   <lpp_source_name>

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


And to add additional packages to your lpp_source, you can use the nim update command similar to above
 specifying your AIX distribution media and the AIX packages you need.

#### Install GPFS (optional)

Follow the instructions in [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] for optionally installing
 GPFS on your xCAT management node.

#### Install Your LoadLeveler Central Manager (optional)

You may choose to install LoadLeveler on your xCAT management node and set it up as your LL central manager. 
If so, follow the instructions in [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] for installing
 LoadLeveler on your xCAT management node and setting it up as your central manager.

#### Use LoadLeveler Database Configuration Option

LoadLeveler provides the option to use configuration data from files or from a MySQL database. When setting up
 LoadLeveler in an xCAT HPC cluster, it is recommended that you use the database configuration option. Follow 
the instructions in [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] for using xCAT to help set up
 the MySQL ODBC interface to the xCAT database which will also be used as the LoadLeveler configuration 
database.

#### Add the HPC software to your diskless image

Include all of the HPC software in your diskless image:

  * Create NIM bundle resources for base AIX prerequisites and for your HPC packages:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a 
           location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_all.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master \
        -a location=/install/nim/installp_bundle/IBMhpc_all.bnd IBMhpc_all

~~~~

     Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT diskless image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,IBMhpc_all"
~~~~


  * Update the image:

Note: Verify that there are no nodes actively using the current diskless image. NIM will fail if there
 are any NIM machine definitions that have the SPOT for this image allocated. If there are active nodes
 accessing the image, you will either need to power them down and run rmdkslsnode for those nodes, or you will need to create a new image and then switch your nodes to that image later. 

For more information and detailed instructions on these options, see the xCAT document for updating software on AIX nodes:
 [Updating_AIX_Software_on_xCAT_Nodes].


~~~~
      mknimimage -u <image_name>
~~~~


  * Add HPC postscripts

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts=IBMhpc.postbootscript
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of 
these scripts may change tuning values and other system settings. The scripts will be run on the node after it
 has booted as part of the xCAT diskless node postscript processing.

  * Optionally update the GPFS mmsdrfs configuration file in your image.

Once your nodes have been added to the GPFS cluster (see [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]), you can run the following script on the xCAT
 management node to update the GPFS mmsdrfs configuration file in your image.

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_mmsdrfs /install/postscripts
     vi /install/postscripts/gpfs_mmsdrfs
        # Edit script to set GPFS master SOURCE config file, xCAT IMAGE names, and other values
     /install/postscripts/gpfs_mmsdrfs
~~~~


(See [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] for more information).
Note: Including the mmsdrfs file in the image before the node has been added will cause the mmaddnode
 command to fail with an error that GPFS thinks the node already belongs to another GPFS cluster.

  * (Optional) Synchronize system configuration files:

LoadLeveler and PE require that userids be common across the cluster. There are many tools and services 
available to manage userids and passwords across large numbers of nodes. One simple way is to use common 
/etc/password files across your cluster. You can do this using xCAT's syncfiles function.
 Create the following file:

~~~~
      vi /install/custom/netboot/aix/<profile>.synclist
     add the following lines (and modify these entries based on the files you wish to synchronize):
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


You can periodically re-sync these files to the nodes as changes occur in your cluster by running 
'updatenode &lt;noderange&gt; -F'. See the xCAT documentation for more details:
 [Sync-ing_Config_Files_to_Nodes].
 


  * (Optional) Use xCAT prescript when installing multiple PE releases:

PE provides a root-owned script, pelinks, which allows installers and system administrators to establish
 symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. 

Refer to
 [IBM PE Runtime Edition: Operation and Use](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic
/com.ibm.cluster.pe.doc/pebooks.html) for a description of the pelinks script.


If you are installing multiple PE releases on AIX diskless nodes, additional setup is required. After you
 finish the steps listed in [Setting_up_all_IBM_HPC_products_in_a_Statelite_or_Stateless_Cluster/#add-the-hpc-software-to-your-diskless-image](Setting_up_all_IBM_HPC_products_in_a_Statelite_or_Stateless_Cluster/#add-the-hpc-software-to-your-diskless-image), run the command below to establish the PE links correctly:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/<pe release>/ppe.poe/bin/pelinks"
~~~~


     For example, if you want to establish PE links to PE 1.1.0.1 release, run command:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/pe1101/ppe.poe/bin/pelinks"
~~~~


     This can be automated by using xCAT prescripts, refer to the xCAT documentation 
[Postscripts_and_Prescripts] to see more details on how to do it.

#### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_Diskless_Nodes] to network boot your nodes:

  *     * Run mkdsklsnode for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that your HPC products are correctly installed.

GPFS installation documentation advises having all your nodes running and installed with the GPFS lpps before creating your GPFS cluster. However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later. If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online. You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.

## Build and configure your GPFS cluster

Follow the instructions in your GPFS documentation to create your GPFS cluster and filesystems. See the notes in [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] to correctly handle your mmsdrfs configuration file in an xCAT cluster.

## Starting HPC software on cluster nodes

  * Follow the instructions in the GPFS section of this document to start GPFS on your GPFS infrastructure nodes.
  * Once you have verified their correct operation, start GPFS on a small number of test nodes.
  * Once you have verified their correct operation, start PNSD and LoadLeveler on those test nodes.
  * Once you have verified their correct operation, network boot the remaining nodes in the cluster.
  * Add those nodes to GPFS.
  * Once GPFS is running correctly, start PNSD and LoadLeveler on the remaining nodes in the cluster.
  * Modify postscripts or other mechanisms you may be using to start the various HPC daemons on your nodes.
  * As a final test, shutdown and network boot all of the nodes in your cluster, ensuring that the nodes all start correctly and are running the desired software products.

