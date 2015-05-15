<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
  - [Add Compilers, PE, and ESSL/PESSL to your diskless image](#add-compilers-pe-and-esslpessl-to-your-diskless-image)
  - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
    - [Add Compilers, PE, and ESSL/PESSL to your diskless image](#add-compilers-pe-and-esslpessl-to-your-diskless-image-1)
    - [Network boot the nodes](#network-boot-the-nodes-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview
This document assumes that you have already purchased your ESSL and PESSL products, have the Linux rpms available, and are familiar with the ESSL and PESSL documentation: [http://publib.boulder.ibm.com/infocen.../esslbooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.essl.doc/esslbooks.html)

These instructions are based on ESSL 5.1, PESSL 3.3.3 and PESSL 4.1.0. If you are using a different version of of these products, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a diskless install.
  * You should have a diskless image created with the base OS installed and verified on at least one test node.

ESSL requires that you have the IBM Fortran compiler (xlf) installed before installing the PE rpms. PESSL requires that you have MPI libraries installed, which are shipped with PE. This document contains instructions for installing both IBM vacpp and xlf compilers along with the ESSL, PESSL, and PE packages.


## Linux

Follow these instructions for installing IBM Compilers, PE, and ESSL/PESSL in your Linux xCAT cluster.

### Add Compilers, PE, and ESSL/PESSL to your diskless image

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your managaement node. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

    To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc
~~~~


    To install the rpm in Redhat:

~~~~
      yum install xCAT-IBMhpc
~~~~


  * Copy the ESSL/PESSL, PE, and compiler rpms from your distribution media onto the xCAT management node (MN). Suggested target location to put the rpms on the xCAT MN:

~~~~
      /install/post/otherpkgs/<osver>/<arch>/essl
      /install/post/otherpkgs/<osver>/<arch>/pe
      /install/post/otherpkgs/<osver>/<arch>/compilers
~~~~


Note1: ESSL and PESSL require a special Java rpm to run their license acceptance scripts. The correct version of this rpm is identified in the ESSL product documentation. Ensure the Java rpm is included in the essl otherpkgs directory.
Note2: PE requires the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in the above directory before proceeding.
Note3:You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
     createrepo /install/post/otherpkgs/<osver>/<arch>/pe
     createrepo /install/post/otherpkgs/<osver>/<arch>/compilers
     createrepo /install/post/otherpkgs/<osver>/<arch>/essl
~~~~

Note4: in /install/post/otherpkgs/&lt;osver&gt;/&lt;arch&gt;/pe on the xCAT MN, install the pe-license:

~~~~
       IBM_PPE_RTE_LICENSE_ACCEPT=yes rpm -ivh ppe_rte_license*.rpm
~~~~


If there are some dependent packages of IBM_pe_license*.rpm, please install the dependent packages firstly. For rhels6, make sure the compat-libstdc++-33.ppc64 is installed; If not, please run "yum install compat-libstdc++-33.ppc64" on rhels6 xCAT MN.

  * Add to pkglist: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<osver>.<arch>.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.pkglist#
~~~~


For rhels6 ppc64, edit /install/custom/netboot/rh/compute.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.rhels6.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.pkglist#
~~~~


Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * Add to otherpkgs: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<os>.<arch>.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
~~~~


     For rhels6 ppc64, edit /install/custom/netboot/rh/compute.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.otherpkgs.pkglist#
~~~~


Note: If you are using PE v1.1.0.0, please use /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.otherpkgs.pkglist as otherpkgs list.
If you are using PE 5.2.1 or below, please use /opt/xcat/share/xcat/IBMhpc/pe/pe.otherpkgs.pkglist as otherpkgs list.
Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * If you are building a stateless image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Add to exclude list: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe.exlist#
~~~~


     For rhels6 ppc64, edit /install/custom/netboot/rh/compute.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/essl/essl.exlist#
~~~~


Verify that the above sample exclude list contains the files and directories you want deleted from your diskless image. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.exlist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+directory" syntax) that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.*.exlist. Keeping these files in the diskless image is required for the install and functionality of some of the HPC products.

  * If you are building a statelite image, refer to the xCAT documentation for statelite images for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your ESSL support, no writable or persistent directories/files have been identified by xCAT at this time. For your PE support, add writable and persistent directories/files required by PE to your litefile table in the xCAT database:

~~~~
      tabedit litefile
      In a separate window, cut the contents of /opt/xcat/share/xcat/IBMhpc/pe/litefile.csv
     paste into your tabedit session, modify as needed for your environment, and save
~~~~


When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

  * Add to postinstall scripts:

     Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall(please make sure it has executable permission) and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.<os>.postinstall $1 $2 $3 $4 $5
      installroot=$installroot NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
      installroot=$installroot pedir=/install/post/otherpkgs/<osver>/<arch>/pe NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200
~~~~


    For rhels6 ppc64, edit /install/custom/netboot/rh/compute.postinstall(please make sure it has executable permission) and add:

~~~~
      installroot=$1 NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
      installroot=$1 pedir=/install/post/otherpkgs/rhels6/ppc64/pe NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200
~~~~


Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sample postscript.
Note: If you are using PESSL 3.3.3 or below, you will need to edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall, and add essl_install as postinstall script, for example:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.<os>.postinstall $1 $2 $3 $4 $5
      installroot=$installroot NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
      installroot=$installroot pedir=/install/post/otherpkgs/<osver>/<arch>/pe NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200
      installroot=$1 essldir=/install/post/otherpkgs/rhels6/ppc64/essl NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/essl/essl_install

~~~~

     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. They will be run by genimage after all of your rpms are installed into the image. It will first run the general IBMhpc setup script to create filesystems, turn on services, and set system tunables. Then it will run the next script to accept the compiler licenses. Then the scripts to install the PE, ESSL and PESSL rpms and accept licenses will be run. Verify that these scripts will work correctly for your cluster. If you wish to make changes to any of these scripts, copy it to /install/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.

  * (Optional) Synchronize system configuration files:

     PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.synclist
     add the following line (modify as appropriate for the files you wish to synchronize):
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


    When packimage or litemiage is run, these files will be copied into the image. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes].

  * Run genimage for your image
  * Run packimage or liteimg for your image

### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; netboot" for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the Compiler, PE, and ESSL/PESSL rpms are all correctly installed, and that your licenses have been accepted.

## AIX

As stated at the beginning of this page, these instructions assume that you have already created a diskless image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX diskless nodes [XCAT_AIX_Diskless_Nodes]

xCAT recommends that you use the mknimimage --sharedroot option to use the NIM shared root support for your diskless nodes. Your nodes will be stateless in that they will not maintain persistent files in the / root directory across reboots, but the node NIM initialization process will be much quicker, and the load on your NFS server (NIM master) will be significantly reduced.

#### Add Compilers, PE, and ESSL/PESSL to your diskless image

Include Compilers, PE, and ESSL/PESSL in your diskless image:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

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


  * Add the packages to the lpp_source used to build your diskless image:

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

  * Add the bundle resources to your xCAT diskless image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,compilers,pe,essl"
~~~~


  * Update the image:

     Note: Verify that there are no nodes actively using the current diskless image. NIM will fail if there are any NIM machine definitions that have the SPOT for this image allocated. If there are active nodes accessing the image, you will either need to power them down and run rmdkslsnode for those nodes, or you will need to create a new image and then switch your nodes to that image later. For more information and detailed instructions on these options, see the xCAT document for updating software on AIX nodes: [Updating_AIX_Software_on_xCAT_Nodes].

~~~~
      mknimimage -u <image_name>
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


You can periodically re-sync these files to the nodes as changes occur in your cluster by running 'updatenode &lt;noderange&gt; -F'. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes].

#### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_Diskless_Nodes] to network boot your nodes:

  *     * Run mkdsklsnode for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the complilers, PE, ESSL, and PESSL are correctly installed.



