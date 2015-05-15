<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Set up stateful login node](#set-up-stateful-login-node)
  - [Linux](#linux)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node)
    - [Add IBM HPC products to your stateful image definition](#add-ibm-hpc-products-to-your-stateful-image-definition)
    - [Instructions for adding IBM HPC products to existing xCAT nodes](#instructions-for-adding-ibm-hpc-products-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes)
  - [AIX](#aix)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node-1)
    - [Add IBM HPC products to your stateful image definition](#add-ibm-hpc-products-to-your-stateful-image-definition-1)
    - [Instructions for adding IBM HPC products to existing xCAT nodes](#instructions-for-adding-ibm-hpc-products-to-existing-xcat-nodes-1)
    - [Network boot the nodes](#network-boot-the-nodes-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

The xCAT IBM HPC Integration function also provides instructions and sample files for setting up a "login" node in your xCAT cluster. In an HPC cluster, login nodes play a different role from compute nodes. Login nodes provide users access to the cluster and a system from which to compile and submit jobs, and to use development toolkits, etc. Login nodes typically have full product software packages, samples, and documentation installed, along with a variety of additional software support products to aid in application development, as compared to compute nodes which focus on a minimal runtime environment in order to maximize resources for running applications. Login nodes are usually stateful (full-disk install) nodes that have unique setup requirements.

These instructions address how to set up all IBM HPC products on a stateful login node. It is assumed that you have a basic knowledge of working with the IBM HPC products, have already purchased all of the IBM HPC products, have the product packages available, and are familiar with the sample files mentioned in xCAT documentation [IBM_HPC_Stack_in_an_xCAT_Cluster] and each product's documentation [IBM Cluster Information Center](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.infocenter.doc/infocenter.html).

These login node setup instructions include the following products:

  * GPFS
  * LoadLeveler (submit only)
  * Parallel Environment (PE), including:
    * Parallel Operating Environment (POE)
    * Low-Level Application Programming Interface (LAPI)
    * Protocol Network Services Daemon (PNSD)
    * Parallel Debugger (PDB)
    * PE HPC toolkit
  * ESSL and PESSL
  * IBM full compilers and debuggers

These instructions are based on GPFS 3.4.5, LoadLeveler 5.1, PE 5.3, ESSL 5.1 and PESSL 4.1. If you are using a different version of these products, you may need to make adjustments to the information provided here.

This support will use xCAT to do basic product installation and configuration into stateful login nodes. The support is provided as sample files only. Before using this support, you should review all files first and modify them to conform to your environment.

## Set up stateful login node

Before proceeding with these instructions, you should have the following already completed for your xCAT clusters:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your login node is defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful (full-disk) install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.

### Linux

Follow the instructions below to set up your Linux stateful login node in xCAT cluster.

#### Copy the HPC software to your xCAT management node

[Copy_the_HPC_software_to_your_xCAT_management_node](Copy_the_HPC_software_to_your_xCAT_management_node)

#### Add IBM HPC products to your stateful image definition

     Include IBM HPC products in your stateful image definition:

  * Add to pkglist:

[Add_to_pkglist](Add_to_pkglist)

  * Add to otherpkgs:

Edit your /install/custom/install/<ostype>/<profile>.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/login.<osver>.<arch>.otherpkgs.pkglist#
~~~~

Verify that the above sample pkglist contains the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry. These packages will be installed on the node after the first reboot by the xCAT postbootscript otherpkgs.

You can find more information on the xCAT otherpkgs package list files and their use in the xCAT documentation 
  [Using_Updatenode] .

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/&lt;product&gt; directory for each product, so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
     createrepo /install/post/otherpkgs/<os>/<arch>/<product>
~~~~


     If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

  * Add to postscripts:

     Copy the IBMhpc postscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will run after all OS rpms are installed on the node and the xCAT default postscripts have run, but before the node reboots for the first time.

     Add this script to the postscripts list for your node. For example, if all nodes in your login nodegroup will be using this script:

~~~~
     chdef -t group -o login -p postscripts=IBMhpc.postscript
~~~~


  * Add to postbootscripts:

     Copy the all of HPC postbootscripts to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/essl/essl_install /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe_install /install/postscripts
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. These scripts will run on the node after the OS has been installed, the node has rebooted for the first time, and the xCAT default postbootscripts have run.

Add the IBMhpc.postbootscript script to the postbootscripts list for your node -- it will invoke all of the other scripts in the correct order. For example, if all nodes in your login nodegroup will be using these scripts and the nodes' attribute postbootscripts value is otherpkg:

~~~~
     chdef -t group -o login -p postbootscripts=IBMhpc.postbootscript
~~~~


If you already have unique postbootscripts attribute settings for some of your nodes (i.e. the value contains more than simply "otherpkgs" and that value is not part of the above group definition), you may need to change those node definitions directly:

~~~~
      chdef <noderange> -p postbootscripts=IBMhpc.postbootscript
~~~~


  * (Optional) Synchronize system configuration files:

[Synchronize_system_configuration_files](Synchronize_system_configuration_files)

#### Instructions for adding IBM HPC products to existing xCAT nodes

[Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_Linux](Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_Linux)

#### Network boot the nodes

[Network_boot_the_nodes_Linux](Network_boot_the_nodes_Linux)

### AIX

As stated at the beginning of this page, these instructions assume that you have already created a stateful image with a base AIX operating system and tested a network installation of that image to at least one target node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX nodes [XCAT_AIX_RTE_Diskfull_Nodes] .

Follow the instructions below to set up your AIX stateful login node in an xCAT cluster.

#### Copy the HPC software to your xCAT management node

     Include the HPC products in your image:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node

[Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node](Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node)

  * Copy all of your IBM HPC product software:

Copy all of your IBM HPC product software to the following locations:

~~~~
      /install/post/otherpkgs/aix/ppc64/<product>
~~~~


where <product> is:



~~~~
     gpfs
     loadl
     pe
     essl
     compilers
~~~~

The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
     /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd
     /opt/xcat/share/xcat/IBMhpc/loadl/login-loadl.bnd
     /opt/xcat/share/xcat/IBMhpc/pe/pe.bnd
     /opt/xcat/share/xcat/IBMhpc/essl/essl.bnd
     /opt/xcat/share/xcat/IBMhpc/compilers/login-compilers.bnd
~~~~


You can also combine these bundle files into one, for example login-all.bnd. While xCAT provides them individually in case you need to just install one or some of them.

  * Add the HPC packages to the lpp_source used to build your image

[Add_the_HPC_packages_to_the_lpp_source_used_to_build_your_image](Add_the_HPC_packages_to_the_lpp_source_used_to_build_your_image)

  * Add additional base AIX packages to your lpp_source

[Add_additional_base_AIX_packages_to_your_lpp_source](Add_additional_base_AIX_packages_to_your_lpp_source)

#### Add IBM HPC products to your stateful image definition

Include all of the HPC software in your stateful image:

  * Create NIM bundle resources for base AIX prerequisites and for your HPC packages

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/gpfs.bnd gpfs
     cp /opt/xcat/share/xcat/IBMhpc/loadl/login-loadl.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/login-loadl.bnd login-loadl
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/pe-1200.bnd pe
     cp /opt/xcat/share/xcat/IBMhpc/essl/essl.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/essl.bnd essl
     cp /opt/xcat/share/xcat/IBMhpc/compilers/login-compilers.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/login-compilers.bnd login-compilers

~~~~

     Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT image definition

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,gpfs,login-loadl,pe,essl,login-compilers"
~~~~


  * Add HPC postscripts

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install-5103 /install/postscripts
     chdef -t group -o <login nodegroup> -p postscripts=IBMhpc.postbootscript

~~~~

     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT node postscript processing.

  * (Optional) Synchronize system configuration files

[Synchronize_system_configuration_files_AIX](Synchronize_system_configuration_files_AIX)

  * (Optional) Use xCAT prescript when installing multiple PE releases:

     PE provides a root-owned script, pelinks, which allows installers and system administrators to establish symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. Refer to [IBM PE Runtime Edition: Operation and Use](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html) for a description of the pelinks script.

     If you are installing multiple PE releases on AIX diskless nodes, additional setup is required. After you finish the steps listed in [Setting_Up_IBM_HPC_Products_on_a_Stateful_Login_Node/#add-ibm-hpc-products-to-your-stateful-image-definition_1](Setting_Up_IBM_HPC_Products_on_a_Stateful_Login_Node/#add-ibm-hpc-products-to-your-stateful-image-definition_1), run the command below to establish the PE links correctly:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/<pe release>/ppe.poe/bin/pelinks"
~~~~


For example, if you want to establish PE links to PE 1.1.0.1 release, run command:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/pe1101/ppe.poe/bin/pelinks"
~~~~


     This can be automated by using xCAT prescripts, refer to the xCAT documentation [Postscripts_and_Prescripts] to see more details on how to do it.

#### Instructions for adding IBM HPC products to existing xCAT nodes

[Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_AIX](Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_AIX)

#### Network boot the nodes

[Network_boot_the_nodes_AIX](Network_boot_the_nodes_AIX)



