<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
    - [Add Compilers, PE, and ESSL/PESSL to your stateful image definition](#add-compilers-pe-and-esslpessl-to-your-stateful-image-definition)
    - [Instructions for adding Compilers,PE, and ESSL/PESSL Software to existing xCAT nodes](#instructions-for-adding-compilerspe-and-esslpessl-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
    - [Add Compilers,PE, and ESSL/PESSL to your stateful image](#add-compilerspe-and-esslpessl-to-your-stateful-image)
    - [Instructions for adding Compilers,PE, ESSL, and PESSL Software to existing xCAT nodes](#instructions-for-adding-compilerspe-essl-and-pessl-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

This document assumes that you have already purchased your ESSL and PESSL products, have the Linux rpms available, and are familiar with the ESSL and PESSL documentation: [http://publib.boulder.ibm.com/infocen.../esslbooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.essl.doc/esslbooks.html)

These instructions are based on ESSL 5.1, PESSL 3.3.3 and PESSL 4.1.0. If you are using a different version of of these products, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful (full-disk) install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.

ESSL requires that you have the IBM Fortran compiler (xlf) installed before installing the PE rpms. PESSL requires that you have MPI libraries installed, which are shipped with PE. This document contains instructions for installing both IBM vacpp and xlf compilers along with the ESSL, PESSL, and PE packages.



## Linux

Follow these instructions for installing IBM Compilers, PE, and ESSL/PESSL in your Linux xCAT cluster.

#### Add Compilers, PE, and ESSL/PESSL to your stateful image definition

Include Compilers and ESSL/PESSL in your stateful image definition:

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


  * Copy the ESSL/PESSL, PE, and compiler rpms from your distribution media onto the xCAT management node (MN). Suggested target location to put the rpms on the xCAT MN:

~~~~
      /install/post/otherpkgs/<osver>/<arch>/essl
      /install/post/otherpkgs/<osver>/<arch>/pe
      /install/post/otherpkgs/<osver>/<arch>/compilers
~~~~


    Note1: ESSL and PESSL require a special Java rpm to run their license acceptance scripts. The correct version of this rpm is identified in the ESSL product documentation. Ensure the Java rpm is included in the essl otherpkgs directory.
    Note2: PE requires the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in the above directory before proceeding.

  * Add to pkglist:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<osver>.<arch>.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.pkglist#
~~~~


For rhels6 ppc64, edit /install/custom/install/rh/compute.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.rhels6.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.pkglist#
~~~~


Note: If you are using PE v1.1.0.0 or below, please use /opt/xcat/share/xcat/IBMhpc/pe/pe.pkglist as pkglist.
Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: This pkglist support is available with xCAT 2.5 and newer releases. If you are using an older release of xCAT, you will need to add the entries listed in these pkglist files to your Kickstart or AutoYaST install template file.

  * Add to otherpkgs:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<os>.<arch>.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
~~~~


Note: If you are using PE 1.1.0.0, please use /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.otherpkgs.pkglist as otherpkgs list.
If you are using PE 5.2.1 or below, please use /opt/xcat/share/xcat/IBMhpc/pe/pe.otherpkgs.pkglist as otherpkgs list.
Verify that the above sample pkglists contain the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry. These packages will be installed on the node after the first reboot by the xCAT postbootscript otherpkgs. Note that these pkglists do not contain the actual ESSL/PESSL or PE rpms. Due to license acceptance, all product rpms will be installed as part of the postinstall scripts below.
You can find more information on the xCAT otherpkgs package list files and their use in the xCAT documentation [Using_Updatenode].

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/pe
      createrepo /install/post/otherpkgs/<os>/<arch>/compilers
      createrepo /install/post/otherpkgs/<os>/<arch>/essl
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

     Copy the Compiler and ESSL/PESSL postbootscripts to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
~~~~


    Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sample postscript.
    Note: If you are using PESSL 3.3.3 or below, you will need to copy essl/essl_install postbootscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/essl/essl_install /install/postscripts
~~~~


     Review and edit these scripts to meet your needs. These scripts will run on the node after the OS has been installed, the node has rebooted for the first time, and the xCAT default postbootscripts have run.
     Add these scripts to the postbootscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script and the nodes' attribute postbootscripts value is:

~~~~
      chdef -t group -o compute -p postbootscripts="compilers_license,pe_install-1200"
~~~~


     If you already have unique postbootscripts attribute settings for some of your nodes (i.e. the value contains more than simply "otherpkgs" and that value is not part of the above group definition), you may need to change those node definitions directly:

~~~~
      chdef <noderange> -p postbootscripts="compilers_license,pe_install-1200"
~~~~


    Note: If you are using PESSL 3.3.3 or below, you will need to add essl_install to the nodes' attribute postbootscripts. For example:

~~~~
      chdef <noderange> -p postbootscripts="compilers_license,pe_install-1100,essl_install"
~~~~


  * (Optional) Synchronize system configuration files:

     PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/install/<ostype>/<profile>.synclist
~~~~

     add the following line:

~~~~
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


When the node is installed or 'updatenode &lt;noderange&gt; -F' is run, these files will be copied to your nodes. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes].

#### Instructions for adding Compilers,PE, and ESSL/PESSL Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding Compilers, PE, and ESSL/PESSL software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the Compilers, PE, and ESSL/PESSL software and run the postscripts using the pkglist and otherpkgs.pkglist files created above. Note that support was added to updatenode in xCAT 2.5 to install packages listed in pkglist files (previously, only otherpkgs.pkglist entries were installed). If you are running an older version of xCAT, you may need to add the pkglist entries to your otherpkgs.pkglist file or install those packages in some other way on your existing nodes.

You will want updatenode to run zypper or yum to install all of the packages. Make sure their repositories have access to the base OS rpms:

~~~~
      #SLES:
      xdsh <noderange> zypper repos --details  | xcoll
      #RedHat:
      xdsh <noderange> yum repolist -v  | xcoll
~~~~


If you installed these nodes with xCAT, you probably still have repositories set pointing to your distro directories on the xCAT MN or SNs. If there is no OS repository listed, add appropriate remote repositories using the zypper ar command or adding entries to /etc/yum/repos.d.

Also, for updatenode to use zypper or yum to install packages from your /install/post/otherpkgs directories, make sure you have run the createrepo command for each of your otherpkgs directories (see instructions in the "Updating xCAT nodes" document [Using_Updatenode] .

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


#### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; install" for all your nodes
    * Run rnetboot to boot and install your nodes
    * When the nodes are up, verify that the Compiler, PE, and ESSL/PESSL rpms are all correctly installed, and that your licenses have been accepted.

## AIX

As stated at the beginning of this page, these instructions assume that you have already created a stateful image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX nodes [XCAT_AIX_RTE_Diskfull_Nodes].

#### Add Compilers,PE, and ESSL/PESSL to your stateful image

Include Compilers, PE, and ESSL/PESSL in your stateful image:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from: [Download xCAT](Download_xCAT)

    To install the rpm:

~~~~
      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm
~~~~


  * Copy the product packages and PTFS from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN:

~~~~
    /install/post/otherpkgs/aix/ppc64/compilers
    /install/post/otherpkgs/aix/ppc64/pe
    /install/post/otherpkgs/aix/ppc64/essl
~~~~


     The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/compilers/compilers.bnd
      /opt/xcat/share/xcat/IBMhpc/pe/pe-1200.bnd
      /opt/xcat/share/xcat/IBMhpc/essl/essl.bnd
~~~~


  * Add the packages to the lpp_source used to build your image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/compilers
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/compilers <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/pe
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/pe <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/essl
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/essl <lpp_source_name>

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

  * Create NIM bundle resources for base AIX prerequisites and for your HPC packages:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
     cp /opt/xcat/share/xcat/IBMhpc/compilers/compilers.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/compilers.bnd compilers
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe-1200.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/pe-1200.bnd pe
     cp /opt/xcat/share/xcat/IBMhpc/essl/essl.bnd /install/nim/installp_bundle
     nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/essl.bnd essl
~~~~


     Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,compilers,pe,essl"
~~~~


  * Add base HPC postscript:

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,pe_install-1200"
~~~~


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will be run on the node after it has booted as part of the xCAT diskless node postscript processing.
    Note: If you are using PE v1.1.0.0 or beyond, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sameple postscript.

  * (Optional) Synchronize system configuration files:

     PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

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


When the node is installed or 'updatenode &lt;noderange&gt; -F' is run, these files will be copied to the node. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes].

#### Instructions for adding Compilers,PE, ESSL, and PESSL Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding Compilers, ESSL, and PESSL software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the Compilers, PE, ESSL, and PESSL software and run the postscripts. To have updatenode install both the OS prereqs and the base Compilers, PE, ESSL, and PESSL packages, complete the previous instructions to add Compilers, PE, ESSL, and PESSL software to your image.

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





#### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_RTE_Diskfull_Nodes] to network boot your nodes:

  *     * If the nodes are not already defined to NIM, run xcat2nim for all your nodes
    * Run nimnodeset for your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the complilers, PE, ESSL, and PESSL are correctly installed.

**NOTE** The ppe.pdb 5.2 lpp will fail during an AIX stateful install when it is installed from a bundle file. The lpp postscript tries to start the scidv1 daemon using SRC, but the System Resource Controller is not active at the time the lpp is installed. This is a known problem and will be fixed in the next release of ppe.pdb.

As a workaround, after your nodes have been installed and rebooted, use xCAT to update the software on your nodes:

~~~~
         updatenode <noderange> -S  installp_flags="-agQXY"
~~~~


This will correctly install the failed packages since SRC should now be active on your nodes.

