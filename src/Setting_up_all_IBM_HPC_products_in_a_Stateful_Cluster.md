<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node)
    - [Install/Build GPFS](#installbuild-gpfs)
    - [Install Your LoadLeveler Central Manager(optional)](#install-your-loadleveler-central-manageroptional)
    - [Add the HPC software to your stateful image definition](#add-the-hpc-software-to-your-stateful-image-definition)
      - [Add to pkglist:](#add-to-pkglist)
      - [Add to otherpkgs:](#add-to-otherpkgs)
      - [Add to postscripts:](#add-to-postscripts)
      - [Add to postbootscripts:](#add-to-postbootscripts)
      - [(Optional) Enable checkpoint and restart function in PE:](#optional-enable-checkpoint-and-restart-function-in-pe)
      - [(Optional) Synchronize system configuration files:](#optional-synchronize-system-configuration-files)
      - [(Optional) Use pelinks script to support multiple PE releases:](#optional-use-pelinks-script-to-support-multiple-pe-releases)
      - [(Optional, Power 775 cluster only) Enable BSR support for PE RTE:](#optional-power-775-cluster-only-enable-bsr-support-for-pe-rte)
      - [(Optional, Power 775 cluster only) Enable UPC compiler](#optional-power-775-cluster-only-enable-upc-compiler)
    - [Instructions for adding HPC Software to existing xCAT nodes](#instructions-for-adding-hpc-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node-1)
      - [Install the optional xCAT-IBMhpc rpm on your xCAT management node](#install-the-optional-xcat-ibmhpc-rpm-on-your-xcat-management-node)
      - [Copy all of your IBM HPC product software](#copy-all-of-your-ibm-hpc-product-software)
      - [Add the HPC packages to the lpp_source used to build your image:](#add-the-hpc-packages-to-the-lpp_source-used-to-build-your-image)
      - [Add additional base AIX packages to your lpp_source:](#add-additional-base-aix-packages-to-your-lpp_source)
    - [Install GPFS (optional)](#install-gpfs-optional)
    - [Install Your LoadLeveler Central Manager (optional)](#install-your-loadleveler-central-manager-optional)
    - [Use LoadLeveler Database Configuration Option](#use-loadleveler-database-configuration-option)
    - [Add the HPC software to your stateful image](#add-the-hpc-software-to-your-stateful-image)
    - [Instructions for adding HPC Software to existing xCAT nodes](#instructions-for-adding-hpc-software-to-existing-xcat-nodes-1)
    - [Network boot the nodes](#network-boot-the-nodes-1)
- [Build and configure your GPFS cluster](#build-and-configure-your-gpfs-cluster)
- [Starting HPC software on cluster nodes](#starting-hpc-software-on-cluster-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document assumes that you have already purchased all of your IBM HPC products, have the product packages available, and are familiar with each product documentation: [IBM Cluster Information Center](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.infocenter.doc/infocenter.html)

These instructions show you how to combine all of the individual product setup samples to install all the IBM HPC products together into your cluster.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.




## Linux

To set up all HPC products in a stateful cluster, follow these steps:

#### Copy the HPC software to your xCAT management node

[Copy_the_HPC_software_to_your_xCAT_management_node](Copy_the_HPC_software_to_your_xCAT_management_node)

#### Install/Build GPFS

Follow the instructions in [Setting_up_GPFS_in_a_Stateful_Cluster] for installing GPFS on your xCAT management node and building the GPFS portability layer.

#### Install Your LoadLeveler Central Manager(optional)

You may choose to install LoadLeveler on your xCAT management node and set it up as your LL central manager. If so, follow the instructions in [Setting_up_LoadLeveler_in_a_Stateful_Cluster] for installing LoadLeveler on your xCAT management node and setting it up as your central manager.

#### Add the HPC software to your stateful image definition

Include all of the HPC software in your stateful image definition:

##### Add to pkglist:

[Add_to_pkglist](Add_to_pkglist)

##### Add to otherpkgs:
Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~

     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.otherpkgs.pkglist#
~~~~

Verify that the above sample pkglists contains the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry. These packages will be installed on the node after the first reboot by the xCAT postbootscript otherpkgs.

Note: You need to explicitly include the rsct.otherpkgs.pkglist file here. The /opt/xcat/share/xcat/IBMhpc/compute.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist file shipped with xCAT does not include the RSCT pkglist file because it is not used for stateless/statelite installs. You must explicitly include it for stateful installs.

Note: By default, the compute.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist file will install PE 1.2.0.0 or upper. If you wish to install PE RTE 1.1.0.0, you will need to copy the sample pkglist file and edit it to change the include for PE. For example, on RHELS6 ppc64, you would:

~~~~

    cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist /install/custom/install/rh/<profile>.otherpkgs.pkglist
    vi <profile>.otherpkgs.pkglist
     #### Change the line for pe as indicated:
     #INCLUDE:/opt  /xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1100.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist#

~~~~


If you wish to install PE 5.2.1 or below, you will need to copy the sample pkglist file and edit it to change the include for PE. For example, on RHELS6 ppc64, you would:


~~~~
    cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist /install/custom/install/rh/<profile>.otherpkgs.pkglist
    vi <profile>.otherpkgs.pkglist
     #### Change the line for pe as indicated:
     #INCLUDE:/opt  /xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist#

~~~~


Note: By default, the compute.<osver&gt;.<arch&gt;.otherpkgs.pkglist file will install Loadl 5.1.0.3 or upper. If you wish to install Loadl 5.1.0.2 or below, you will need to copy the sample pkglist file and edit it to change the include for LoadLeveler. For example, on RHELS6 ppc64, you would:


~~~~
    cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist /install/custom/install/rh/<profile>.otherpkgs.pkglist
    vi <profile>.otherpkgs.pkglist
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/loadl/loadl.otherpkgs.pkglist#

~~~~





You can find more information on the xCAT otherpkgs package list files and their use in the xCAT documentation [Using_Updatenode]

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/&lt;product&gt; directory for each product, so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:


~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/<product>
~~~~


If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

##### Add to postscripts:

     Copy the IBMhpc postscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will run after all OS rpms are installed on the node and the xCAT default postscripts have run, but before the node reboots for the first time.

Add this script to the postscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script:

~~~~
      chdef -t group -o compute -p postscripts=IBMhpc.postscript
~~~~


##### Add to postbootscripts:

     Copy the all of HPC postbootscripts to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.post /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103 /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. These scripts will run on the node after OS has been installed, the node has rebooted for the first time, and the xCAT default postbootscripts have run.

Note: By default, the IBMhpc.postbootscript will call the install script for Loadleveler 5.1.0.3 or upper. If you wish to install Loadleveler 5.1.0.2 or below, you will need to copy the correct PE script and modify this call:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts
      vi /install/postscripts/IBMhpc.postbootscript
      #### Change the line for PE from:
      $ps_dir/loadl_install-5103
      ### to:
      $ps_dir/loadl_install
~~~~


Note: By default, the IBMhpc.postbootscript will call the install script for PE RTE 1.2.0.0 or upper. If you wish to install PE RTE 1.1.0.0, you will need to copy the correct PE script and modify this call:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 /install/postscripts
      vi /install/postscripts/IBMhpc.postbootscript
      #### Change the line for PE from:
      $ps_dir/pe_install-1200
      ### to:
      $ps_dir/pe_install-1100
~~~~

If you wish to install PE 5.2.1 or below, you will need to copy the correct PE script and modify this call:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 /install/postscripts
      vi /install/postscripts/IBMhpc.postbootscript
      #### Change the line for PE from:
      $ps_dir/pe_install-1200
      ### to:
      $ps_dir/pe_install
~~~~


Note: By default, the IBMhpc.postbootscript is assuming to install PESSL 4.1.0 or upper. If you wish to install ESSL 5.1/PESSL 3.3.3 or below , you will need to copy the correct ESSL/PESSL script and modify this call:

~~~~
      cp /opt/xcat/share/xcat/IBMhpc/essl/essl_install /install/postscripts
      vi /install/postscripts/IBMhpc.postbootscript
      #### Add the line for ESSL/PESSL:
      $ps_dir/essl_install
~~~~





Add the IBMhpc.postbootscript script to the postbootscripts list for your node -- it will invoke all of the other scripts in the correct order. For example, if all nodes in your compute nodegroup will be using these scripts and the nodes' attribute postbootscripts value is otherpkg:

~~~~
      chdef -t group -o compute -p postbootscripts=IBMhpc.postbootscript
~~~~


If you already have unique postbootscripts attribute settings for some of your nodes (i.e. the value contains more than simply "otherpkgs" and that value is not part of the above group definition), you may need to change those node definitions directly:

~~~~
      chdef <noderange> -p postbootscripts=IBMhpc.postbootscript
~~~~


##### (Optional) Enable checkpoint and restart function in PE:

To enable checkpoint and restart function in PE, several additional steps are required to setup related system environment on compute node. Starting from xCAT 2.7.2, there is a script ckpt.sh provided by xCAT to config the system environment, including: virtualized pts support, unlinked file support, and read checkpoint key from rootfs which generated by xCAT postinstall script. Check PE document for more checkpointing and restarting details: [http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)

Step 1
    Copy the ckpt.sh script from the PE installation directory to the /install/postscripts/ directory. Set the file permissions so that the scripts are world readable and executable by root.
Step 2
    Register the scripts in the node definitions in the xCAT database. If an xCAT nodegroup is defined for all nodes that will be using these scripts, run the following xCAT command:


~~~~
         chdef -t group -o <compute nodegroup> -p postbootscripts="ckpt.sh"
~~~~


##### (Optional) Synchronize system configuration files:

[Synchronize_system_configuration_files](Synchronize_system_configuration_files)

##### (Optional) Use pelinks script to support multiple PE releases:

PE provides a root-owned script, pelinks, which allows installers and system administrators to establish symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. Refer to [IBM PE Runtime Edition]: Operation and Use for a description of the pelinks script.
If you want to switch among multiple PE releases in a Linux diskless image, you can edit PE postinstall script pe_install-1200 to uncomment following lines in script and change to the correct PE version that you intend to use.

~~~~
       # pelinks script support, uncomment the following lines and change to the correct pe version that you intend to use.
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


##### (Optional, Power 775 cluster only) Enable BSR support for PE RTE:

BSR is a Power 775 cluster specific hardware feature. To config it for PE RTE, you will need to install BSR package from otherpkg list, edit PE postscript pe_install-1200 and uncomment several lines of script for BSR configuration. Check PE document for more BSR function details: [http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)
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
~~~~

uncomment the following lines:

~~~~
        # BSR configuration, uncomment the following lines to enable BSR configuration on Power Linux cluter.
        #if [ "$OS" != "AIX" ]; then
        #    chroot $installroot groupadd bsr
        #    chroot $installroot mkdir -p /var/lib/bsr
        #    chroot $installroot chown root:bsr /var/lib/bsr
        #    chroot $installroot chmod g+sw /var/lib/bsr
        #fi
~~~~


xCAT provides a postscript IBMhpc.post to setup one additional configuration for BSR support after the nodes bootup, you will need following steps to enable the configuration:

Step 1
         Copy the IBMhpc.post from IBM HPC installation directory to the /install/postscripts/ directory. Set the file permissions so that the scripts are world readable and executable by root:

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


##### (Optional, Power 775 cluster only) Enable UPC compiler

UPC compiler is supported on Power 775 cluster, you will want to install UPC compiler RPMs from otherpkg list and accept the license by postbootscript if UPC compiler is used. You will need to copy the sample pkglist file and sample postbootscript, and add the include for UPC compiler. For example, you could:

~~~~
     ##Add upc.otherpkgs.pkglist to sample otherpkgs list:
     cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist /install/custom/install/rh/<profile>.otherpkgs.pkglist
     vi <profile>.otherpkgs.pkglist
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/upc.otherpkgs.pkglist#

~~~~

~~~~
     ## Copy upc_license postbootscript to postscripts directory and add it in sample postbootscripts:
     cp /opt/xcat/share/xcat/IBMhpc/compilers/upc_license /install/postscripts
     vi /install/postscripts/IBMhpc.postbootscript
     #### Change the line for UPC compiler from:
     #$ps_dir/upc_license
     #### To
     $ps_dir/upc_license
~~~~


Note: The xlf, vacpp, and upc compilers all have a dependency on the xlmass-lib rpm. There is a problem that the current versions of the compilers require DIFFERENT versions of xlmass. xlf 13.1.0.x and vacpp 11.1.0.x compilers requires xlmass 6.1 while upc 12.0.0.x compiler requires xlmass 7.1. To workaround it, you will need to add additional manual steps in compilers_license to install xlmass 6.1 and 7.1 both for nodes. For example, edit the compilers_license to install xlmass 6.1 manually:

~~~~
     #Make sure the following xlmass.lib-6.1.0.x file name is correct and uncomment the red lines.
     #Note that there is one line in the following code different from code in compilers_license, showing with blue.  You will need to update it manually:
     vi /install/postscripts/compilers_license
     if [ $NODESETSTATE == "install" ] || [ $NODESETSTATE == "boot" ]; then
       ## Workaround for xlf/vacpp and upc compiler dependceies conflict issue.
       ## Install a low version of xlmass manually
       ## Uncomment the following lines for UPC compiler use
       #INSTALL_DIR='/install'
       #COMPILERS_DIR='post/otherpkgs/rhels6.2/ppc64/compilers'
       #mkdir -p /tmp/compilers/
       #rm -f -R /tmp/compilers/*
       #cd /tmp/compilers/
       #wget -l inf -nH -N -r --waitretry=10 --random-wait -T 60 -nH --cut-dirs=6 --reject "index.html*" --no-parent http://$SITEMASTER$INSTALL_DIR/$COMPILERS_DIR/ 2> /tmp/wget.log
       #if [ -n "`ls xlmass.lib-6.1.0*.rpm 2> /dev/null`" ] ; then
       #         rpm -ivh --oldpackage xlmass.lib-6.1.0*.rpm
       #fi
       #cd $installroot/
       #rm -f -R /tmp/compilers/
       #  Being run from a stateful install postscript
~~~~


#### Instructions for adding HPC Software to existing xCAT nodes

[Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_Linux](Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_Linux)

#### Network boot the nodes

[Network_boot_the_nodes_Linux](Network_boot_the_nodes_Linux)

## AIX

As stated at the beginning of this page, these instructions assume that you have already created a stateful image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX nodes ["xCAT 2 on AIX: Installing AIX standalone nodes - RTE"](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2onAIXinstall.pdf).

#### Copy the HPC software to your xCAT management node

Include the HPC products in your image:

##### Install the optional xCAT-IBMhpc rpm on your xCAT management node

[Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node](Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node)

##### Copy all of your IBM HPC product software

Copy all of your IBM HPC product software to the following locations:

       /install/post/otherpkgs/aix/ppc64/<product>


     where <product> is:

    gpfs
    loadl
    pe
    essl
    compilers
     The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

      /opt/xcat/share/xcat/IBMhpc/IBMhpc_all.bnd


##### Add the HPC packages to the lpp_source used to build your image:

[Add_the_HPC_packages_to_the_lpp_source_used_to_build_your_image](Add_the_HPC_packages_to_the_lpp_source_used_to_build_your_image)

##### Add additional base AIX packages to your lpp_source:

[Add_additional_base_AIX_packages_to_your_lpp_source](Add_additional_base_AIX_packages_to_your_lpp_source)

#### Install GPFS (optional)

Follow the instructions in [Setting_up_GPFS_in_a_Stateful] for optionally installing GPFS on your xCAT management node.

#### Install Your LoadLeveler Central Manager (optional)

You may choose to install LoadLeveler on your xCAT management node and set it up as your LL central manager. If so, follow the instructions in [Setting_up_LoadLeveler_in_a_Stateful_Cluster] for installing LoadLeveler on your xCAT management node and setting it up as your central manager.

#### Use LoadLeveler Database Configuration Option

LoadLeveler provides the option to use configuration data from files or from a MySQL database. When setting up LoadLeveler in an xCAT HPC cluster, it is recommended that you use the database configuration option. Follow the instructions in [Setting_up_LoadLeveler_in_a_Stateful] for using xCAT to help set up the MySQL ODBC interface to the xCAT database which will also be used as the LoadLeveler configuration database.

#### Add the HPC software to your stateful image

Include all of the HPC software in your stateful image:

  * Create NIM bundle resources for base AIX prerequisites and for your HPC packages:

     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_all.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_all.bnd IBMhpc_all


     Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT image definition:

     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,IBMhpc_all"


  * Add HPC postscripts

     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts=IBMhpc.postbootscript


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT node postscript processing.

  * (Optional) Synchronize system configuration files:

{{:Synchronize system configuration files/AIX}}

  * (Optional) Use xCAT prescript when installing multiple PE releases:

     PE provides a root-owned script, pelinks, which allows installers and system administrators to establish symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. Refer to [IBM PE Runtime Edition: Operation and Use](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html) for a description of the pelinks script.

     If you are installing multiple PE releases on AIX diskless nodes, additional setup is required. After you finish the steps listed in [Setting_up_all_IBM_HPC_products_in_a_Stateful_Cluster#Add_the_HPC_software_to_your_stateful_image], run the command below to establish the PE links correctly:

     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/<pe release>/ppe.poe/bin/pelinks"


     For example, if you want to establish PE links to PE 1.1.0.1 release, run command:

     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/pe1101/ppe.poe/bin/pelinks"


     This can be automated by using xCAT prescripts, refer to the xCAT documentation [Postscripts_and_Prescripts] to see more details on how to do it.

#### Instructions for adding HPC Software to existing xCAT nodes

[Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_AIX](Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_AIX)

#### Network boot the nodes

[Network_boot_the_nodes_AIX](Network_boot_the_nodes_AIX)

## Build and configure your GPFS cluster

Follow the instructions in the GPFS section of this document to create your GPFS cluster.

## Starting HPC software on cluster nodes

  * Follow the instructions in the GPFS section of this document to start GPFS on your GPFS infrastructure nodes.
  * Once you have verified their correct operation, start GPFS on a small number of test nodes.
  * Once you have verified their correct operation, start PNSD and LoadLeveler on those test nodes.
  * Once you have verified their correct operation, network boot the remaining nodes in the cluster.
  * Add those nodes to GPFS.
  * Once GPFS is running correctly, start PNSD and LoadLeveler on the remaining nodes in the cluster.
  * Modify postscripts or other mechanisms you may be using to start the various HPC daemons on your nodes.
  * As a final test, shutdown and network boot all of the nodes in your cluster, ensuring that the nodes all start correctly and are running the desired software products.

