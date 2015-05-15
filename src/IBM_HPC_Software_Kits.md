<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Kit documentation](#kit-documentation)
- [IBM HPC Product Software Kits](#ibm-hpc-product-software-kits)
  - [Obtaining the Kits](#obtaining-the-kits)
  - [General Instructions for all HPC Kits](#general-instructions-for-all-hpc-kits)
    - [Completing the kit build for a partial kit](#completing-the-kit-build-for-a-partial-kit)
      - [Using partial Kits with newer software versions](#using-partial-kits-with-newer-software-versions)
  - [Parallel Environment Runtime Edition (PE RTE)](#parallel-environment-runtime-edition-pe-rte)
    - [Handle the conflict between PE RTE kit and Mellanox OFED driver install script](#handle-the-conflict-between-pe-rte-kit-and-mellanox-ofed-driver-install-script)
    - [Installing multiple versions of PE RTE](#installing-multiple-versions-of-pe-rte)
    - [Starting PE on cluster nodes](#starting-pe-on-cluster-nodes)
    - [POE hostlist files](#poe-hostlist-files)
    - [Known problems with PE RTE](#known-problems-with-pe-rte)
  - [Parallel Environment Developer Edition (PE DE)](#parallel-environment-developer-edition-pe-de)
  - [Engineering and Scientific Subroutine Library (ESSL)](#engineering-and-scientific-subroutine-library-essl)
  - [Parallel Engineering and Scientific Subroutine Library (PESSL)](#parallel-engineering-and-scientific-subroutine-library-pessl)
  - [General Parallel File System (GPFS)](#general-parallel-file-system-gpfs)
  - [IBM Compilers](#ibm-compilers)
  - [Toolkit for Event Analysis and Logging (TEAL)](#toolkit-for-event-analysis-and-logging-teal)
- [Switching from xCAT IBM HPC Integration Support to Using Software Kits](#switching-from-xcat-ibm-hpc-integration-support-to-using-software-kits)
  - [Overview](#overview)
  - [Mapping of HPC Integration Support to Software Kits](#mapping-of-hpc-integration-support-to-software-kits)
  - [Removing IBM HPC Integration Support from an Existing OS Image Definition](#removing-ibm-hpc-integration-support-from-an-existing-os-image-definition)
    - [Removing all IBM HPC Integration Support from an image](#removing-all-ibm-hpc-integration-support-from-an-image)
    - [Removing IBM HPC Integration Support for one or more products from an image](#removing-ibm-hpc-integration-support-for-one-or-more-products-from-an-image)
  - [Switching diskless systems](#switching-diskless-systems)
  - [Switching stateful systems](#switching-stateful-systems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**New in xCAT 2.8. Supported for Linux OS images only.**
**xCAT 2.9 and newer releases also support Software Kits for Ubuntu OS images.**

xCAT Kit support replaces the Linux IBM HPC Integration Support (xCAT-IBMhpc) previously shipped with xCAT 2.7.x and older releases. If you are running on an AIX cluster or are using IBM HPC products in an xCAT 2.7.x or older Linux release, follow the instructions in [IBM_HPC_Stack_in_an_xCAT_Cluster](IBM_HPC_Stack_in_an_xCAT_Cluster).





## Introduction

This document contains specific information for using IBM Product software kits in an xCAT cluster. For general use of software kits with xCAT Linux OS images, see: [Using_Software_Kits_in_OS_Images]

It is important to first understand the concepts, commands, and procedures presented in that document in order to apply the specific details listed here. For most IBM products, you will simply follow the general procedures in working with kits.

IBM product software kits combine the product packages with configuration files, installation scripts, environment variables, exclude lists, and other data that is unique to deploying and running that product in an xCAT cluster. Kit components for different cluster roles such as compute, storage, login, utility, servicenode, and mgtnode are available as supported by the product.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured.
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for node deployment.
  * You should have a Linux OS image created with the base OS installed and verified that this image can be deployed to at least one test node.

### Kit documentation

Introduction to Kits: [Using_Software_Kits_in_OS_Images](Using_Software_Kits_in_OS_Images)

Building a Kit: [Building_Software_Kits](Building_Software_Kits)

Using an HPC software Kit: [IBM_HPC_Software_Kits](IBM_HPC_Software_Kits)

## IBM HPC Product Software Kits

### Obtaining the Kits

Complete kits for some product software is shipped on the product distribution media.  For other software, only partial kits may be available.

The partial product kits are avalable from the [FixCentral](http://www-933.ibm.com/support/fixcentral/) download site. To download a kit from FixCentral:

      http://www-933.ibm.com/support/fixcentral/
      Select the Product Group "Cluster Software"  &lt;continue&gt;
      Select the appropriate product, for example "Parallel Environment Runtime Edition"  &lt;continue&gt;
      Select Installed Version, for example "All"  &lt;continue&gt;
      Select Platform, for example "All"  &lt;continue&gt;
      Identify Fixes, select "Browse for fixes"  &lt;continue&gt;
      Select Fixes, select the product kit that most closely matches the release, version, and architecture for your product.  &lt;continue&gt;
         Note that not every fixpack for a product may have a corresponding new partial kit, so you may need to find the last kit fixpack that was previously released.
      If prompted, sign into FixCentral with your IBM Id and Password  &lt;Sign in&gt;
      Review and accept "Terms and Conditions" popup
      Select the kit tar file to download

For the IBM XLF and XLC Compilers, xCAT ships partial kits on sourceforge:
  https://sourceforge.net/projects/xcat/files/kits/hpckits/2.9/Ubuntu/ppc64_Little_Endian/

A partial kit is a tar file that contains everything except for the actual product packages. Instructions are provided below for how to complete a partial kit by adding all of the product packages and rebuilding the kit tar file. Only complete kits can be added to an xCAT cluster.

See the specific product sections below for detailed information on each supported IBM product.

This document will be updated as more IBM products develop kits for their products and make them available for use in xCAT clusters.

### General Instructions for all HPC Kits

Again, be sure you understand all of the information, concepts, and processes for general use of software kits with xCAT Linux OS images documented in: [Using_Software_Kits_in_OS_Images]

This is a quick overview of the commands you will use to add kits to your xCAT cluster and use them in your Linux OS images. Please read the specific product sections below for any exceptions or additions to this process for a particular product.

  * Obtain your IBM HPC product kits
  * If your kits are partial kits, obtain our IBM HPC product packages and build complete kits by combining the partial kit with the product packages:

[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)



     Note: Before completing the GPFS kit, you will need to first build the GPFS portability layer package on one of your servers. See the special instructions for [IBM_HPC_Software_Kits#General_Parallel_File_System_(GPFS)](IBM_HPC_Software_Kits/#general-parallel-file-system-gpfs) kits below.

  * Make the completed kits locally available on your xCAT management node
  * Add each kit to the xCAT database by running:

~~~~

      addkit <product_kit_tarfile>
~~~~


    This will automatically unpack the tarfile, copy its contents to the correct locations for xCAT, and create the corresponding kit, kitcomponent, and kitrepo objects in the xCAT database.

  * List the product kitcomponents that are available for your OS image:

~~~~

      lsdef -t kitcomponent | grep <product>
~~~~


  * Kit components are typically named based on server role, product version, OS version, and optionally if it is for a minimal image (minimal images exclude documentation, includes, and other optional files to reduce the diskless image size). To list the details of a particular kit component:

~~~~

      lsdef -t kitcomponent -o <kitcomponent name> -l
~~~~


  * Your OS image must be defined with a supported serverrole in order to add a kit component to the image. To query the role assigned to an image:

~~~~

      lsdef -t osimage -o <image> -i serverrole
~~~~


     And to change the serverrole of an image:
~~~~

      chdef -t osimage -o <image> serverrole=<role>
~~~~

  * To add or update a kitcomponent in an osimage, first check if the kitcomponent is compatible with your image:

~~~~
      chkkitcomp -i <image>  <kitcomponent name>
~~~~


     If compatible, add the component to that image:

~~~~

      addkitcomp -i <image>   <kitcomponent name>
~~~~


     This will add various files for otherpkgs, postinstall, and postbootscripts to the OS image definition. To view some of these:

~~~~
      lsdef -t osimage -l <image>
~~~~

  * If this is a diskless stateless or statelite OS image, rebuild, pack, and deploy the image:

~~~~
      genimage <image>
      #
      packimage <image>
      # OR
      liteimg <image>
      #
      nodeset <noderange> osimage=<image>
      #
      rpower <noderange>
~~~~


  * If this is a stateful OS image, the new HPC kitcomponent software may be installed either when you do a new node deployment or by using the **updatenode** command.
See [IBM_HPC_Software_Kits#Switching_stateful_systems](IBM_HPC_Software_Kits/#switching-stateful-systems).

#### Completing the kit build for a partial kit

Typically, a software kit will contain all of the product package files. However, in some instances, software kits may be delivered as _partial or incomplete kits, and will not include all of the product rpms. You will then need to obtain your product packages and license through your reqular distribution channels, download them to a server along with the incomplete kit, and run the **buildkit addpkgs** command to build a complete kit that can be used by xCAT.

**Note**: The software license package will be available from the product media. If you download product software it will not include the license package. When completing a partial KiT you must make sure to include the license package when you "addpkgs" to the partial Kit.

The file name of the kit tarfile will indicate if it is a partial kit. For example, if the name of your product kit tarfile is something like:

    product-version-Linux.NEED_PRODUCT_PKGS.tar.bz2

the string "NEED_PRODUCT_PACKAGES" in the file name indicates that you have a partial kit.

If you received your IBM HPC product software kit as a partial kit, follow these steps to complete the kit build process:

  1. Install the optional **xCAT-buildkit** rpm on your server. This rpm will not automatically install with your other xCAT packages and does not necessarily need to be installed on an xCAT management node. The xCAT-buildkit rpm does not have any dependencies on any other xCAT packages. However, it does require the **rpmbuild** and **createrepo** commands to be available. For RHELS, these commands are provided by the rpm-build and createrepo packages respectively. For SLES, they are provided by the rpm and createrepo packages(note that createrepo is shipped on the SLES SDK iso).
  2. Download the kit tarfile and the product package files and make them locally available on your server.
  3. cd to a work directory
  4. Build the complete kit tarfile:

      buildkit addpkgs &lt;kit.NEED_PRODUCT_PKGS.tar.bz2&gt; --pkgdir &lt;product package directory&gt;


    You may receive warning messages about the current OS/arch not matching the kit repository being built. These can be ignored.

##### Using partial Kits with newer software versions

If your product packages are for a newer version or release than what you see specified in your incomplete kit tar file name, you may still be able to build a complete kit with your packages, assuming that the incomplete kit is compatible with those packages.

**Note**: Basically, the latest partial kit available online will work until there is a newer version available.

To build a complete kit with the new software you can provide the new version and/or release of the software on the **buildkit** command line.

     buildkit addpkgs &lt;kit.NEED_PRODUCT_PKGS.tar.bz2&gt; --pkgdir &lt;product package directory&gt; --kitversion &lt;new version&gt; --kitrelease &lt;new release&gt;


For example, if your partial kit was created for a product version of 1.3.0.2 but you wish to complete a new kit for product version 1.3.0.4 then you would add "-k 1.3.0.4" to the **buildkit** command line.

### Parallel Environment Runtime Edition (PE RTE)

PE RTE software kits are available for Linux PE RTE 1.3 and newer releases on System x.

For Linux PE RTE 1.2 and older releases on System x, and for PE RTE on AIX or on System p, use the xCAT HPC Integration Support: [IBM_HPC_Stack_in_an_xCAT_Cluster]


No special procedures are required for using the PE RTE kit. If you received an incomplete kit, simply follow the previously documented process for adding the product packages and building the complete kit:
[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)


#### Handle the conflict between PE RTE kit and Mellanox OFED driver install script

PPE requires the 32-bit version of libibverbs, but the default mlnxofed_ib_install which provides by xCAT to install Mellanox OFED IB driver will remove all the old ib related packages at first including the 32-bit version of libibverbs. In this case, you need to set the environment variable mlnxofed_options=--force when running the mlnxofed_ib_install. For more details, please check [Managing_the_Mellanox_Infiniband_Network#Script_to_Install_the_IB_Drivers_Only_required_for_both_RHEL_and_SLES](Managing_the_Mellanox_Infiniband_Network/#script-to-install-the-ib-drivers-only-required-for-both-rhel-and-sles)




#### Installing multiple versions of PE RTE

Starting with PE RTE 1.2.0.10, the PE RTE packages are designed so that when you upgrade the product to a newer version or release, the files from the previous version remain in your osimage along with the new version of the product.

Normally, you will only have one version of a kitcomponent present in your xCAT osimage. When you run addkitcomp to add a newer version of the kitcomponent, xCAT will first remove the old version of the kitcomponent before adding the new one. If you are updating a previously built diskless image or an existing diskfull node with a newer version of PE RTE, and you have run addkitcomp to add the new PE RTE kitcomponent,xCAT will replace the previous kitcomponent with the new one. For example, if your current compute osimage has PE RTE 1.3.0.1 and you want to upgrade to PE RTE 1.3.0.2:

~~~~
      lsdef -t osimage -o compute -i kitcomponents
         kitcomponents = pperte_compute-1.3.0.1-0-rhels-6-x86_64
      addkitcomp -i compute pperte_compute-1.3.0.2-0-rhels-6-x86_64
      lsdef -t osimage -o compute -i kitcomponents
         kitcomponents = pperte_compute-1.3.0.2-0-rhels-6-x86_64
~~~~

And, running a new genimage for your previously built compute diskless image will upgrade the pperte-1.3.0.1 rpm to pperte-1.3.0.2, and will install the new ppe_rte_1302 rpm without removing the previous ppe_rte_1301 rpm.

To remove the previous version of the PE RTE product files from the osimage, you will need to manaully remove the rpms. In the example above, this would be something like:

~~~~
      chroot /install/netboot/rhels6/x86_64/compute/rootimg rpm -e ppe_rte_1302

~~~~

If you are building a new diskless image or installing a diskfull node, and need multiple versions of PE RTE present in the image as part of the initial install, you will need to have multiple versions of the corresponding kitcomponent defined in the xCAT osimage definition. To add multiple versions of PE RTE kitcomponents to an xCAT osimage, add the kitcomponent using the full name with separate addkitcomp commands and specifying the -n (--noupgrade) flag. For example, to add PE RTE 1.3.0.1 and PE RTE 1.3.0.2 to your compute osimage definition:
~~~~
      addkitcomp -i compute pperte_compute-1.3.0.1-0-rhels-6-x86_64
      addkitcomp -i compute -n pperte_compute-1.3.0.2-0-rhels-6-x86_64
      lsdef -t osimage -o compute -i kitcomponents
         kitcomponents = pperte_compute-1.3.0.1-0-rhels-6-x86_64,pperte_compute-1.3.0.2-0-rhels-6-x86_64
~~~~

In this example, when building a diskless image for the first time, or when deploying a diskfull node, xCAT will first install PE RTE 1.3.0.1, and then in a separate yum or zypper call, xCAT will install PE RTE 1.3.0.2. The second install will upgrade the pperte-1.3.0.1 rpm to pperte-1.3.0.2, and will install the new ppe_rte_1302 rpm without removing the previous ppe_rte_1301 rpm.

#### Starting PE on cluster nodes

The PNSD daemon is started from xinetd on your compute nodes. This daemon should start automatically at node boot time. Verify that xinetd is running on your nodes and that your PNSD daemon is active.

#### POE hostlist files

If you are using POE to start a parallel job, xCAT can help create your host list file. Simply run the nodels command against the desired noderange and redirect the output to a file. For example:

~~~~
      nodels compute &gt; /tmp/hostlist
      poe -hostfile /tmp/hostlist ....
~~~~

#### Known problems with PE RTE

For PE RTE 1.3.0.1 to 1.3.0.6 on both System X and System P architectures, there is a known issue that when you uninstall or upgrade ppe_rte_man in a diskless image, "genimage &lt;osimage&gt; will fail and stop at the error". To workaround this problem, you will need to rerun "genimage &lt;osimage&gt;" to finish the remaining work. For more details, please check this bug: [3486](https://sourceforge.net/p/xcat/bugs/search/?q=3486)

For PE RTE 1.3.0.7 on both System X and System P architectures, there is a known issue that when you uninstall or upgrade ppe_rte_man in a diskless image, "genimage &lt;osimage&gt;" will output errors. However, the new packages are actually upgraded, so no workaround is required and the error can be ignored with risks. For more details, please check this bug: [3486](https://sourceforge.net/p/xcat/bugs/search/?q=3486)

Starting with PE RTE 1.3.0.7, the src rpm is no longer required. It is not recommended that you build a complete kit for PE RTE 1.3.0.7 or newer using a partial PE RTE 1.3.0.6 or older kit which still require the src rpm. You should download the latest partial kit for PE RTE 1.3.0.7 or newer to build the corresponding PE RTE complete kit.

### Parallel Environment Developer Edition (PE DE)

PE DE software kits are available for Linux PE DE 1.2.0.1 and newer releases on System X. Also PE DE software kits are available for Linux PE DE 1.2.0.3 and newer releases on System P.

For older Linux releases on System x and System P, and for AIX, use the xCAT HPC Integration Support: [IBM_HPC_Stack_in_an_xCAT_Cluster]


No special procedures are required for using the PE DE kit. If you received an incomplete kit, simply follow the previously documented process for adding the product packages and building the complete kit:
[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)

### Engineering and Scientific Subroutine Library (ESSL)

ESSL software kits are available for Linux ESSL 5.2.0.1 and newer releases on System P.

For older Linux releases on System P, and for AIX, use the xCAT HPC Integration Support: [IBM_HPC_Stack_in_an_xCAT_Cluster](IBM_HPC_Stack_in_an_xCAT_Cluster)

No special procedures are required for building the complete PESSL kit. If you received an incomplete kit, simply follow the previously documented process for adding the product packages and building the complete kit:
[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)



When you are building a diskless image or installing a diskfull node, and want ESSL installed with compiler XLC/XLF kits, there is one change when you add a ESSL kitcomponent to an xCAT osimage. To add ESSL kitcomponent to an xCAT osimage, add the kitcomponent using separate addkitcomp command and specifying the -n(--noupgrade) flag. For example, to add ESSL 5.2.0.1 kitcomponent to your compute osimage definition:


~~~~
    addkitcomp -i compute essl_compute-5.2.0.1-rhels-6-ppc64
     lsdef -t osimage -o compute -i kitcomponents
        kitcomponents = essl_compute-5.2.0.1-rhels-6-ppc64
~~~~

After adding the ESSL kitcomponent to xCAT osimage, follow the process in below document to finish OS deployment or package upgrade: [IBM_HPC_Software_Kits#General_Instructions_for_all_HPC_Kits](IBM_HPC_Software_Kits/#general-instructions-for-all-hpc-kits)

### Parallel Engineering and Scientific Subroutine Library (PESSL)

PESSL software kits are available for Linux PESSL 4.2.0.0 and newer releases on System P.

For older Linux releases on System P, and for AIX, use the xCAT HPC Integration Support: [IBM_HPC_Stack_in_an_xCAT_Cluster](IBM_HPC_Stack_in_an_xCAT_Cluster)

No special procedures are required for building the PESSL complete kit. If you received an incomplete kit, simply follow the previously documented process for adding the product packages and building the complete kit:
[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)



When you are building a diskless image or installing a diskfull node, and want PESSL installed with ESSL kits, there is one change when you add a PESSL kitcomponent to an xCAT osimage. To add PESSL kitcomponent to an xCAT osimage, add the kitcomponent using separate addkitcomp command and specifying the -n(--noupgrade) flag. For example, to add PESSL 4.2.0.0 kitcomponent to your compute osimage definition:

~~~~
     addkitcomp -i compute pessl_compute-4.2.0.0-rhels-6-ppc64
     lsdef -t osimage -o compute -i kitcomponents
        kitcomponents = essl_compute-4.2.0.0-rhels-6-ppc64
~~~~

After adding the PESSL kitcomponent to xCAT osimage, follow the process in below document to finish OS deployment or package upgrade:
[IBM_HPC_Software_Kits#General_Instructions_for_all_HPC_Kits](IBM_HPC_Software_Kits/#general-instructions-for-all-hpc-kits)




### General Parallel File System (GPFS)

GPFS software kits are available for Linux GPFS 3.5.0.7 and newer releases on System x.

For Linux GPFS 3.5.0.6 and older releases on System x and for AIX or Linux on System p, use the xCAT HPC Integration Support: [IBM_HPC_Stack_in_an_xCAT_Cluster](IBM_HPC_Stack_in_an_xCAT_Cluster)


The GPFS kit requires the addition of the GPFS portability layer package to be added to it. This rpm must be built at your site on a server that matches the architecture and kernel version of all OS images that will be using this kit.

Follow this procedure before using the GPFS kit that you received:

  * On a server that has the correct architecture and kernel version, manually install the GPFS rpms and build the portability layer according to the instructions documented by GPFS: [General Parallel File System](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.gpfs.doc/gpfsbooks.html)

    After installing the GPFS rpms, you can see:
~~~~
      /usr/lpp/mmfs/src/README
~~~~


     NOTE: Building the portability layer requires that the kernel source rpms are installed on your server. For example, for SLES11, make sure the kernel-source and kernel-ppc64-devel rpms are installed. For rhels6, make sure the cpp.ppc64,gcc.ppc64,gcc-c++.ppc64,kernel-devel.ppc64 and rpm-build.ppc64 are installed.

  * Copy the gpfs.gplbin rpm that you have successfully created to the server that you are using to complete the build of your GPFS kit, placing it in the same directory as your other GPFS rpms.
  * Complete the kit build:

~~~~
      buildkit addpkgs <gpfs-kit-NEED_PRODUCT_PKGS-tarfile> -p <gpfs-rpm-directory>
~~~~

At this point you can now follow the general instructions for working with kits to add the kit to your xCAT database and add the GPFS kitcomponents to your OS images.

### IBM Compilers

XLC and XLF software kits are available for Linux XLC 12.1.0.3 and XLF 14.1.0.3, and newer releases on System P.  

For XLC 13.1.1.0 and XLF 15.1.1.0 and newer releases, xCAT ships partial software kits for Ubuntu on sourceforge:

      https://sourceforge.net/projects/xcat/files/kits/hpckits/2.9/Ubuntu/ppc64_Little_Endian/      

For older Linux releases on System P, and for AIX, use the xCAT HPC Integration Support:
[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)




No special procedures are required for using the XLC/XLF kit. If you received an incomplete kit, simply follow the previously documented process for adding the product packages and building the complete kit:
[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)



### Toolkit for Event Analysis and Logging (TEAL)

Teal software kits are available for Linux Teal 1.2.0.1 and newer releases on System X.

For older Linux releases on System x, and for AIX or System P, use the xCAT HPC Integration Support: [IBM_HPC_Stack_in_an_xCAT_Cluster]


No special procedures are required for using the Teal kit. If you received an incomplete kit, simply follow the previously documented process for adding the product packages and building the complete kit:

[IBM_HPC_Software_Kits#Completing_the_kit_build_for_a_partial_kit](IBM_HPC_Software_Kits/#completing-the-kit-build-for-a-partial-kit)




## Switching from xCAT IBM HPC Integration Support to Using Software Kits

### Overview

If you currently have OS images defined and built using the xCAT IBM HPC Integration Support [IBM_HPC_Stack_in_an_xCAT_Cluster](IBM_HPC_Stack_in_an_xCAT_Cluster), you will need to create completely new OS images to use with IBM HPC Software Kits. xCAT does not provide any upgrade or migration support for replacing the HPC products in your current OS images with the equivalent kits.

Existing xCAT OS images built with xCAT 2.7.x and older releases can continue to be built and deployed on xCAT 2.8+. However, the xCAT IBM HPC Integration Support for Linux will not be updated as new versions of the HPC products become available. To use new versions of the products in your Linux OS images, you will either need to manually update your image customization files and scripts to accommodate any changes to the products, or you will need to switch over to using the new software kits built by the products for use in xCAT HPC clusters.

NOTE: If you choose to manually update your current image customization scripts, you are taking over ownership of the product installation into your OS images and will be responsible for understanding any packaging or customization changes that are required by the product update. This is not an environment that xCAT IBM HPC Integration Support will continue to be tested in or provide updates for.

You can mix HPC Integration Support with HPC kits for different HPC products in the same OS image definition if necessary.




### Mapping of HPC Integration Support to Software Kits

With the previous xCAT IBM HPC Integration Support, xCAT provided various customization files and scripts that you applied to your Linux OS image definition:

  * pkglist files
  * otherpkgs.pkglist files
  * exclude lists
  * genimage postinstall scripts
  * postscripts
  * postbootscripts
  * sample litefile.csv table entries

Different sets of files were available for compute nodes, login nodes, etc., for full-disk, diskless, and minimal images, for different operating systems and architectures, for each product. In order to use these files, you manually changed your OS image definition in xCAT, you editted your custom files and scripts to include the correct files, you copied postscripts to the /install/postscripts directory, and you updated your nodes' postscripts attributes. You also needed to make sure all of your product packages were located in the correct directories in /install/post/otherpkgs, and that you ran the correct createrepo commands to create the repository meta information for the package manager (yum or zypper). Getting all of this correct initially took considerable effort, and then determining which files changed with new versions of the software products, and making the corresponding changes to your OS image definitions could be prone to error, changes being missed, and files getting out of sync.

With HPC software kits, all of these files and functions have been bundled directly into different kitcomponents within a kit. Now, all you need to do is add the product kit to your xCAT management node, add the desired kitcomponent to your OS image definition, and either generate your diskless image or deploy your full-disk node. xCAT handles all the work of ensuring the pkglist files, exclude list files, configuration scripts, postscripts, product package files, etc., are copied to the correct locations, and that all of the attributes in your OS image definition are correctly updated. To update an HPC product to a newer version, you simply add the new kit to the xCAT management node, and add the correct kitcomponent to your OS image definition. xCAT will automatically update all of the correct attributes and files in your OS image definition.

NOTE: xCAT HPC Kit support currently does not provide automated image update support for litefile table entries. If you are adding kitcomponents to a statelite image, you will need to manually update the xCAT litefile table with the correct entries.

If you are interested in digging deeper into exactly where specific function has moved from the xCAT IBM HPC Integration Support for to its corresponding kit for a specific product, here are a few places you can look after you have added a kit to xCAT and a kitcomponent to an OS image definition:

  * Browse the contents of the expanded kit tarfile:
~~~~
      cd /install/kits
      ls
      cd <kitdir>
      ls
~~~~

     You should see files and directories such as:

~~~~
    docs kit.conf other_files plugins repos
~~~~

  * The kit.conf file includes kit configuration information that xCAT uses to add the kit, kitcomponents, and kitrepos to the xCAT database.
  * The other_files directory contains files and scripts for each kitcomponent that xCAT will either use directly or copy to correct locations. These scripts contain much of the function similar to what was shipped in the postinstall scripts, postscripts, and postbootscripts with the previous HPC Integration support. Also included in this directory are files with exclude lists and otherpkgs ENV variables.
  * The repos directory contains separate repositories for each OS/architecture this kit is supported on. The repository contains not only all of the product packages, but also a special kitcomponent "meta" package for each kitcomponent in that kit.

     You can run various rpm query commands against a kitcomponent package to see how other HPC Integration function has been mapped. For general info:
~~~~
      rpm -qip <kitcomp.rpm>
~~~~



    For the list of packages required by the kitcomponent:

~~~~
      rpm -qp --requires <kitcomp.rpm>
~~~~




    This list replaces the previous product.pkglist and product.otherpkgs.pkglist files shipped with HPC Integration. Now, when the kitcomponent is installed into your image, yum or zypper will automatically install the entire product and all of its dependencies.
    Some of the function previously shipped in HPC Integration scripts may have been moved into the %pre and %post sections of the kitcomponent package. To view those:

~~~~
       rpm -qp --scripts <kitcomp.rpm>

~~~~



  * List the details of your OS image definition:

~~~~
      lsdef -t osimage -l <image>
~~~~

     You will see a new kitcomponents attribute that lists all of the kit components assigned to this OS image.
     You will also see that some of the attributes have been updated with KIT* files or references. You can cat these files to see how xCAT has added entries for your kitcomponent to this OS image definition.




  * List the kit postscripts:
~~~~
      ls /install/postscripts/KIT*
~~~~

     You will see where xCAT has copied kit postscripts to this directory. When a kitcomponent is added to an OS image definition, the osimage.postbootscripts attribute is also updated with the names of these scripts. Instead of changing the postbootscripts definition for a node to use these scripts, by assigning your OS image definition to the node (the node **provmethod** attribute), these scripts will be run when that node is booted.




  * List your OS image repositories:

~~~~
      lsdef -t osimage <image> -i otherpkgdir
      ls -ld <otherpkgdir>/*

~~~~

     You will see a subdirectory link for each product that points back to the correct kitrepo directory from the expanded kit tar file. Since that repository was shipped with its own repo metadata, you do not need to do anything special to copy the product packages into place or run the createrepo command for them.

### Removing IBM HPC Integration Support from an Existing OS Image Definition

The previous xCAT IBM HPC Integration Support was provided as a set of sample files to help you install a product into your OS image definition. It was designed to be highly flexible and customizable, allowing you to change any of the support you needed to. Therefore, removing this support from an existing OS image definition will be extremely dependent on your environment, the procedures you used to add the product(s) to your OS image definition, and any customizations you applied after adding the products. The removal process will also become much more complicated if you used the IBM HPC Integration support for all or several IBM HPC products, and only want to remove that support for some of those products while leaving support for others still in the image definition.

Again, we HIGHLY recommend if at all possible that you create brand new OS image definitions to use with the HPC software kits instead of trying to migrate an existing image!




#### Removing all IBM HPC Integration Support from an image

To remove all suport from your image, first find all of the files referenced by the OS image definition:

~~~~
      lsdef -t osimage -o <image> -l

~~~~

  * For every xCAT IBM HPC Integration file referenced (filename starts with /opt/xcat/share/xcat/IBMhpc):



     View the file to see if it references any base xCAT files (referenced filename starts with /opt/xcat/share/xcat/netboot or /opt/xcat/share/xcat/install). You may need to traverse several levels of files to get a complete list. Once you have this list, you have 2 options depending on how long your list is:

  1. For one or two files, simply replace the xCAT IBM HPC Integration filename in the osimage attribute with the list of base xCAT files. As of xCAT 2.8, you may have multiple files listed in most osimage attributes.
  2. For a longer list, create a custom file in /install/custom/..., including all of the base xCAT files in your list, and replace the xCAT IBM HPC Integration filename in the osimage attribute with the full pathname of your new custom file.




  * For every custom file referenced (filename may start with something like /install/custom):



     Determine if this file is one that you created for your own environment or if it is a copy of an xCAT IBM HPC Integration file. This may require some investigation on your part.

  * If it is a copy of an IBM HPC Integration file:



  1. Determine what local changes were made if any, and which of those changes are required specifically for your environment and will need to be kept. Again, you may need to repeat this process traversing several levels of referenced files.
  2. Determine all referenced base xCAT files (see above).
    Once you have the total set of changes that you need to carry forward, create a new custom file with those changes and the referenced base xCAT files. Then replace the custom filename in the osimage attribute with the full pathname of your new custom file.



  * If it is a custom file created to support your unique environment, determine if it references any IBM HPC Integration files or custom copies of those files. Remove or replace any of those references as required, .


Test all of your changes by running a genimage for diskless images, or (if possible) installing a test fulldisk node to ensure the base osimage definition is correct and does not contain errors.

If your test succeeds, you may then follow the procedures for adding HPC software kits and kitcomponents to your OS image definitions.

#### Removing IBM HPC Integration Support for one or more products from an image

To remove IBM HPC Integration for some, but not all, products from your image, first find all of the files referenced by the OS image definition:

~~~~
      lsdef -t osimage -o <image> -l
~~~~

  * For every xCAT IBM HPC Integration file referenced (filename starts with /opt/xcat/share/xcat/IBMhpc):



     View the file to see if it references any files or function associated with the product you wish to remove. You may need to traverse several levels of files to determine where the support has been implemented. If any references were found, you will need to create a custom copy of that file in order to remove the reference. If the reference is in a lower level file, you may need to create custom copies of all intermediate files and ensure the traversal calls are modified accordingly. Once all of these changes have been made, replace the xCAT IBM HPC Integration filename in the osimage attribute with the full pathname of your new custom file.

  * For every custom file referenced (filename may start with something like /install/custom):



     Remove all references to any files or function associated with the product you wish to remove. Again, you may need to repeat this process traversing several levels of referenced files, creating custom copies of any intermediate xCAT files as necessary and ensuring the traversal calls are modified accordingly.

Test all of your changes by running a genimage for diskless images, or (if possible) installing a test fulldisk node to ensure the base osimage definition is correct and does not contain errors.

If your test succeeds, you may then follow the procedures for adding HPC software kits and kitcomponents to your OS image definitions.

### Switching diskless systems

To upgrade a diskless system.

1) Create a new xCAT osimage.

2) Add the kit contents to the osimage using the process described earlier in ths document.[IBM_HPC_Software_Kits#General_Instructions_for_all_HPC_Kits](IBM_HPC_Software_Kits/#general-instructions-for-all-hpc-kits)

3) Add any special customization that you need to the osimage.

4) Modify the node definitions to point to the new osimage by setting the node "provmethod" attribute to the name of the new osimage.

5) Re-boot the node to deploy the new software.

### Switching stateful systems

As mentioned above, you will have to create new osimages and update them with the new HPC kit components.

However, with stateful nodes, it is possible to update the nodes without having to re-deploy them right away.

To upgrade a stateful system without having to do a new node deployment.

1) Create a new xCAT osimage using the same OS distribution as the osimage currently running on the node.

2) Add the kit contents to the osimage using the process described earlier in ths document.
[IBM_HPC_Software_Kits#General_Instructions_for_all_HPC_Kits](IBM_HPC_Software_Kits/#general-instructions-for-all-hpc-kits)





3) Add any special customization that you need to the osimage.

4) Modify the node definitions to point to the new osimage by setting the node "provmethod" attribute to the name of the new osimage.

5) Use the [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html) command to install the new kit product software on the nodes.

~~~~
(ex.updatenode <nodenode>)
~~~~

