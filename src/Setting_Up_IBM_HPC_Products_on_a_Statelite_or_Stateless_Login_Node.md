<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Set up stateless/statelite login node](#set-up-statelessstatelite-login-node)
  - [Linux](#linux)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node)
    - [Add IBM HPC products to your stateless/statelite image](#add-ibm-hpc-products-to-your-statelessstatelite-image)
    - [Network boot the login node](#network-boot-the-login-node)
- [AIX](#aix)
    - [Copy the HPC software to your xCAT management node](#copy-the-hpc-software-to-your-xcat-management-node-1)
    - [Add IBM HPC products to your stateless/statelite image](#add-ibm-hpc-products-to-your-statelessstatelite-image-1)
    - [Network boot the node](#network-boot-the-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

The xCAT IBM HPC Integration function also provides instructions and sample files for setting up a "login" node in your xCAT cluster. In an HPC cluster, login nodes play a different role from compute nodes. Login nodes provide users access to the cluster and a system from which to compile and submit jobs, and to use development toolkits, etc. Login nodes typically have full product software packages, samples, and documentation installed, along with a variety of additional software support products to aid in application development, as compared to compute nodes which focus on a minimal runtime environment in order to maximize resources for running applications.

These instructions address how to set up all IBM HPC products on a stateless/statelite login node. It is assumed that you have a basic knowledge of working with the IBM HPC products, have already purchased all of the IBM HPC products, have the product packages available, and are familiar with the sample files mentioned in xCAT documentation [IBM_HPC_Stack_in_an_xCAT_Cluster], each product's documentation [IBM Cluster Information Center](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.infocenter.doc/infocenter.html), and xCAT stateless/statelite documentations [XCAT_pLinux_Clusters] and [XCAT_AIX_Diskless_Nodes].

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

This support will use xCAT to do basic product installation and configuration into stateless/statelite login nodes. The support is provided as sample files only. Before using this support, you should review all files first and modify them to conform to your environment.

## Set up stateless/statelite login node

Before proceeding with these instructions, you should have the following already completed for your xCAT clusters:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your login node is defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateless/statelite install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.

### Linux

Follow the instructions below to set up your Linux stateless/statelite login node in xCAT cluster.

#### Copy the HPC software to your xCAT management node

[Copy_the_HPC_software_to_your_xCAT_management_node](Copy_the_HPC_software_to_your_xCAT_management_node)

#### Add IBM HPC products to your stateless/statelite image

Include IBM HPC products in your stateless/statelite image:

  * Add to pkglist:

Review the following pkglist file and all of the files it includes:

~~~~
     /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist
~~~~


or, if you are building a minimal stateless image that has eliminated much of the software not required for runtime compute nodes, use:

~~~~
     /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.pkglist
~~~~


Note: The login nodes install the same base OS packages that are installed on compute nodes. References to compute.*.pkglist in this step are correct.
If you do not need to make any changes and are able to use the file as shipped, add an #INCLUDE ...# statement for this file to your custom pkglist:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.pkglist
      Add the following line, substituting <osver> and <arch> with the correct values:
      #INCLUDE /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist#
~~~~




    For rhels6 ppc64, please edit the following file:

~~~~
      vi /install/custom/netboot/rh/compute.pkglist
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.pkglist#
~~~~


If you need to make changes to any of the files, you can copy the file to your custom directory

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist /install/custom/netboot/<ostype>/<profile>.pkglist
~~~~


and modify it or you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: This pkglist support is available with xCAT 2.5 and newer releases. If you are using an older release of xCAT, you will need to add the entries listed in these pkglist files to your Kickstart or AutoYaST install template file.

  * Add to otherpkgs:

Review the following pkglist file and all of the files it includes:

~~~~
     /opt/xcat/share/xcat/IBMhpc/login.<osver>.<arch>.otherpkgs.pkglist
~~~~


Edit your /install/custom/netboot/<ostype>/<profile>.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/login.<osver>.<arch>.otherpkgs.pkglist#
~~~~


Note: If you are using PE v1.1.0.0 or beyond, please modify the contents of login.&lt;osver&gt;.&lt;arch&gt;.otherpkgs.pkglist, and use /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.otherpkgs.pkglist as otherpkgs list.

Verify that the above sample pkglist contains the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

You can find more information on the xCAT otherpkgs package list files and their use in the xCAT documentation [Using_Updatenode] .

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/&lt;product&gt; directory for each product, so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
     createrepo /install/post/otherpkgs/<os>/<arch>/<product>
~~~~


If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

  * Exclude lists:

If you are building a stateless/statelite image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Review the following exclude list file and all of the files it includes and verify that they contain all the files and directories you want deleted from your diskless image:

~~~~
     /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.exlist
~~~~


or, if you are building a minimal stateless image that has eliminated much of the software not required for runtime compute nodes, use:

~~~~
     /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.exlist
~~~~


Note: The login nodes use the same exclude lists as the compute nodes. References to compute.*.exlist in this step are correct.
Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+directory" syntax) that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.*.exlist. Keeping these files in the stateless/statelite image is required for the install and functionality of some of the HPC products.

If you do not need to make any changes and are able to use the file as shipped, add an #INCLUDE ...# statement for this file to your custom exclude list:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.exlist
      Add the following line, substituting <osver> and <arch> with the correct values:
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.exlist#

~~~~

If you need to make changes to any of the files, you can copy the file to your custom directory

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.exlist /install/custom/netboot/<ostype>/<profile>.exlist
~~~~


and modify it or you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * If you are building a statelite image, refer to the xCAT documentation [XCAT_Linux_Statelite] for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your HPC support, add writable and persistent directories/files required by HPC products to your litefile table in the xCAT database:

~~~~
         tabedit litefile  <in a separate window> cut the contents of /opt/xcat/share/xcat/IBMhpc/*/litefile.csv
~~~~

paste into your tabedit session, modify as needed for your environment, and save


This assumes that you have already added the base litefile entries as described in the xCAT statelite documentation. When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

Included in the loadl list is an entry for the /home directory. Depending on how you are managing your shared home directory for the cluster, you may need to implement a postbootscript that mounts the correct shared home directory on the node onto /.statelite/tmpfs/home. See the wiki page [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] for more notes on the LoadLeveler litefile entries.

Included in the gpfs list is an entry for the /gpfs directory which is the default mount point for your GPFS filesystems on the node. If you create your GPFS filesystems with a different mount point, you will need to change this entry accordingly. See the wiki page [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] for more notes on the GPFS litefile entries.
     Note: To know the litefile setting details for each HPC products, refer to [IBM_HPC_Stack_in_an_xCAT_Cluster/#product-specific_information](IBM_HPC_Stack_in_an_xCAT_Cluster/#product-specific_information).

  * Add to postinstall scripts:

Copy the following postinstall file:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.postinstall /install/custom/netboot/<ostype>/<profile>.postinstall
~~~~


or, if you are building a minimal stateless image that has eliminated much of the software not required for runtime compute nodes, use:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/min-compute.<osver>.<arch>.postinstall /install/custom/netboot/<ostype>/compute.<osver>.<arch>.postinstall
~~~~


Note: The login nodes use the same postinstall scripts as the compute nodes. References to compute.*.postinstall in this step are correct.

Review this sample script and all of the scripts it invokes carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. These scripts will be run by genimage after all of your rpms are installed into the image. Verify that these scripts will work correctly for your cluster. If you wish to make changes to any of these scripts, copy those scripts to either your /install/custom/netboot/&lt;ostype&gt; directory or to /install/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.

Since these scripts invoke other scripts shipped in the /opt/xcat/share/xcat/IBMhpc directories, if you copy ANY of the postinstall scripts to another directory for modification, you will also need to create a custom copy of the [min-]compute.&lt;osver&gt;.&lt;arch&gt;.postinstall script and edit the directory location to invoke your modified script.

Note: The /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_mmsdrfs script contains image names that will need to be changed if you run this script outside of the genimage processing to keep all of your images updated with GPFS config file changes; it does not need to be changed if you only call it from postinstall processing with genimage.

  * (Optional) Synchronize system configuration files:

LoadLeveler and PE require that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.synclist
     add the following line (modify as appropriate for the files you wish to synchronize):
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


When packimage or litemiage is run, these files will be copied into the image. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: 
  [Sync-ing_Config_Files_to_Nodes].

  * Run genimage for your image using the appropriate options for your OS, architecture, adapters, etc.
  * Run packimage or liteimg for your image.

#### Network boot the login node

Network boot your login node:

  *     * Run nodeset for your login node
    * Run rnetboot to your login node
    * When the login node is up, verify that the HPC rpms are all correctly installed.

## AIX

As stated at the beginning of this page, these instructions assume that you have already created a stateless/statelite image with a base AIX operating system and tested a network installation of that image to at least one target node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX nodes [XCAT_AIX_Diskless_Nodes].

If you want to install your login node as stateless, xCAT recommends that you use the mknimimage --sharedroot option to use the NIM shared root support for your stateless node. Your node will be stateless in that they will not maintain persistent files in the / root directory across reboots, but the node NIM initialization process will be much quicker, and the load on your NFS server (NIM master) will be significantly reduced.

If you want to install your login node as statelite, you must use the mknimimage --sharedroot option where the xCAT AIX statelite support based on, refer to [XCAT_AIX_Diskless_Nodes/#aix_statelite_support](XCAT_AIX_Diskless_Nodes/#aix_statelite_support) for the details.

Follow the instructions below to set up your AIX stateless/statelite login node in an xCAT cluster.

#### Copy the HPC software to your xCAT management node

Include the HPC products in your image:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node

[Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node](Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node)

  * Copy all of your IBM HPC product software:

Copy all of your IBM HPC product software to the following locations:

~~~~
      /install/post/otherpkgs/aix/ppc64/<product>

     where <product> is:

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

[[include ref_Add_the_HPC_packages_to_the_lpp_source_used_to_build_your_image]]

  * Add additional base AIX packages to your lpp_source

[Add_additional_base_AIX_packages_to_your_lpp_source](Add_additional_base_AIX_packages_to_your_lpp_source)

#### Add IBM HPC products to your stateless/statelite image

Include all of the HPC software in your stateful image:

  * Create NIM bundle resources for base AIX prerequisites and for your HPC packages

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.bnd gpfs
     cp /opt/xcat/share/xcat/IBMhpc/loadl/login-loadl.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/opt/xcat/share/xcat/IBMhpc/loadl/login-loadl.bnd login-loadl
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.bnd pe
     cp /opt/xcat/share/xcat/IBMhpc/essl/essl.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/opt/xcat/share/xcat/IBMhpc/essl/essl.bnd essl
     cp /opt/xcat/share/xcat/IBMhpc/compilers/login-compilers.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/opt/xcat/share/xcat/IBMhpc/compilers/login-compilers.bnd login-compilers

~~~~

Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT image definition

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,gpfs,login-loadl,pe,essl,login-compilers"
~~~~


  * Update the image:

Note: Verify that there are no nodes actively using the current diskless image. NIM will fail if there are any NIM machine definitions that have the SPOT for this image allocated. If there are active nodes accessing the image, you will either need to power them down and run rmdkslsnode for those nodes, or you will need to create a new image and then switch your nodes to that image later. For more information and detailed instructions on these options, see the xCAT document for updating software on AIX nodes [Updating_AIX_Software_on_xCAT_Nodes].

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
     chdef -t group -o <login nodegroup> -p postscripts=IBMhpc.postbootscript
~~~~


Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. The scripts will be run on the node after it has booted as part of the xCAT node postscript processing.

  * If you are building a statelite image, refer to the xCAT documentation [XCAT_AIX_Diskless_Nodes/#aix_statelite_support](XCAT_AIX_Diskless_Nodes/#aix_statelite_support) for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your HPC support, add writable and persistent directories/files required by HPC products to your litefile table in the xCAT database:

~~~~
         tabedit litefile  <in a separate window> cut the contents of /opt/xcat/share/xcat/IBMhpc/*/litefile.csv
~~~~

paste into your tabedit session, modify as needed for your environment, and save


When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

Included in the loadl list is an entry for the /home directory. Depending on how you are managing your shared home directory for the cluster, you may need to implement a postbootscript that mounts the correct shared home directory on the node onto /.statelite/tmpfs/home. See the wiki page [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] for more notes on the LoadLeveler litefile entries.

Included in the gpfs list is an entry for the /gpfs directory which is the default mount point for your GPFS filesystems on the node. If you create your GPFS filesystems with a different mount point, you will need to change this entry accordingly. See the wiki page [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] for more notes on the GPFS litefile entries.

Note: To know the litefile setting details for each HPC products, refer to [IBM_HPC_Stack_in_an_xCAT_Cluster/#product-specific_information](IBM_HPC_Stack_in_an_xCAT_Cluster/#product-specific_information).

  * (Optional) Synchronize system configuration files

LoadLeveler and PE require that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

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


  * (Optional) Use xCAT prescript when installing multiple PE releases:

PE provides a root-owned script, pelinks, which allows installers and system administrators to establish symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. Refer to [IBM PE Runtime Edition: Operation and Use](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html) for a description of the pelinks script.

If you are installing multiple PE releases on AIX diskless nodes, additional setup is required. After you finish the steps listed in [Setting_Up_IBM_HPC_Products_on_a_Statelite_or_Stateless_Login_Node/#add-ibm-hpc-products-to-your-statelessstatelite-image_1](Setting_Up_IBM_HPC_Products_on_a_Statelite_or_Stateless_Login_Node/#add-ibm-hpc-products-to-your-statelessstatelite-image_1), run the command below to establish the PE links correctly:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/<pe release>/ppe.poe/bin/pelinks"
~~~~


For example, if you want to establish PE links to PE 1.1.0.1 release, run command:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/pe1101/ppe.poe/bin/pelinks"
~~~~


This can be automated by using xCAT prescripts, refer to the xCAT documentation [Postscripts_and_Prescripts] to see more details on how to do it.

#### Network boot the node

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_Diskless_Nodes] to network boot your node:



  * Run mkdsklsnode for your login node
  * Run rnetboot to boot your login node
  * When the node is up, verify that your HPC products are correctly installed.


