<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
    - [Add Compilers and PE to your stateful image definition](#add-compilers-and-pe-to-your-stateful-image-definition)
    - [Instructions for adding Compiler and PE Software to existing xCAT nodes](#instructions-for-adding-compiler-and-pe-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes)
- [AIX](#aix)
    - [Add Compilers and PE to your stateful image](#add-compilers-and-pe-to-your-stateful-image)
    - [Instructions for adding PE Software to existing xCAT nodes](#instructions-for-adding-pe-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes-1)
- [Starting PE on cluster nodes](#starting-pe-on-cluster-nodes)
- [POE hostlist files](#poe-hostlist-files)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)




##Overview

This document assumes that you have already purchased your Parallel Environment product, have the Linux rpms available, and are familiar with the PE documentation: [http://publib.boulder.ibm.com/infocen.../pebooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html)

These instructions are based on PE 5.2.1, PE 1.1.0.0 and PE RTE 1.2.0.0. If you are using a different version of ParallelEnvironment, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful (full-disk) install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.

PE requires that you have a working C compiler installed before installing the PE rpms. This document contains instructions for installing both IBM vacpp and xlf compilers and the PE packages.

## Linux

To set up IBM Compilers and PE in a stateful cluster, follow these steps:




#### Add Compilers and PE to your stateful image definition

Include Compilers and PE in your stateful image definition:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node and service nodes. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your management node. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

    To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc
      zypper refresh
~~~~


    To install the rpm in Redhat:

~~~~
      zypper refresh
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


  * Copy the PE and compiler rpms from your distribution media onto the xCAT management node (MN). Suggested target location to put the rpms on the xCAT MN:

~~~~
       /install/post/otherpkgs/<osver>/<arch>/pe
       /install/post/otherpkgs/<osver>/<arch>/compilers
~~~~


     Note1: PE requires the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in the above directory before proceeding.
    Note2: PE requires a special Java rpm to run its license acceptance script. The correct version of this rpm is identified in the PE product documentation. Ensure the Java rpm is included in the pe otherpkgs directory.

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<osver>/<arch>/pe
      createrepo /install/post/otherpkgs/<osver>/<arch>/compilers
~~~~


    If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

  * Add to pkglist:

Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.<ostype>.<arch>.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<ostype>.<arch>.pkglist#
~~~~


Fill in &lt;ostype&gt; and &lt;arch&gt; in the above pkglist files according to your cluster configuration, and verify the pkglist files are existing.
     For rhels6 ppc64, edit /install/custom/netboot/rh/compute.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.rhels6.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.pkglist#
~~~~


Note: If you are using PE v1.1.0.0, please use /opt/xcat/share/xcat/IBMhpc/pe/pe.pkglist as pkglist.
Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.
     Note: This pkglist support is available with xCAT 2.5 and newer releases. If you are using an older release of xCAT, you will need to add the entries listed in these pkglist files to your Kickstart or AutoYaST install template file.

  * Add to otherpkgs:

Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<ostype>.<arch>.otherpkgs.pkglist#
~~~~


    For rhels6 ppc64, edit /install/custom/netboot/rh/compute.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.otherpkgs.pkglist#
~~~~

Note: If you are using PE v1.1.0.0, please use /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.otherpkgs.pkglist as otherpkgs list.
Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * Add to postscripts:

     Copy the IBMhpc postscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.post /install/postscripts
~~~~


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will run after all OS rpms are installed on the node and the xCAT default postscripts have run, but before the node reboots for the first time.
     Add this script to the postscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script:

~~~~
      chdef -t group -o compute -p postscripts=IBMhpc.postscript
~~~~


  * Add to postbootscripts:

     Copy the Compiler and PE postbootscripts to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
     cp /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
~~~~


     Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sameple postscript.
     Review and edit these scripts to meet your needs. These scripts will run on the node after the OS has been installed, the node has rebooted for the first time, and the xCAT default postbootscripts have run.
     Add these scripts to the postbootscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script and the nodes' attribute postbootscripts value is otherpkgs:

~~~~
      chdef -t group -o compute -p postbootscripts="compilers_license,pe_install-1200"
~~~~


     Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sample postscript.
     If you already have unique postbootscripts attribute settings for some of your nodes (i.e. the value contains more than simply "otherpkgs" and that value is not part of the above group definition), you may need to change those node definitions directly:

~~~~
      chdef <noderange> -p postbootscripts="compilers_license,pe_install-1200"
~~~~


     Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sameple postscript.

  * (Optional) Synchronize system configuration files:

     PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/install/<ostype>/<profile>.synclist
~~~~

     add the following line:

~~~~
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


When the node is installed or 'updatenode &lt;noderange&gt; -F' is run, these files will be copied to your nodes. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes]

  * (Optional) Enable checkpoint and restart function in PE:

     To enable checkpoint and restart function in PE, several additional steps are required to setup related system environment on compute node. Starting from xCAT 2.7.2, there is a script ckpt.sh provided by xCAT to config the system environment, including: virtualized pts support, unlinked file support, and read checkpoint key from rootfs which generated by xCAT postinstall script. Refer to PE document for checkpointing and restarting function: [http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)

     Step 1
       Copy the ckpt.sh script from the PE installation directory to the /install/postscripts/ directory. Set the file permissions so that the scripts are world readable and executable by root.
     Step 2
       Register the scripts in the node definitions in the xCAT database. If an xCAT nodegroup is defined for all nodes that will be using these scripts, run the following xCAT command:

~~~~
       chdef -t group -o <compute nodegroup> -p postbootscripts="ckpt.sh"
~~~~


  * (Optional, Power 775 cluster only) Enable BSR support for PE RTE:

     BSR is a Power 775 cluster specific hardware feature. To config it for PE RTE, you will need to install BSR package from otherpkg list, edit PE postinstall script pe_install-1200 and uncomment several lines of script for BSR configuration. Check PE document for more BSR function details: [http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)
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

~~~~
         Uncomment the BSR code in IBMhpc.post:
         vi /install/postscripts/IBMhpc.post
         # BSR configuration on Power 775 cluster. More BSR configuration should
         # be done by PE postinstall in genimage or postbootscript in statefull install
         #chown root:bsr /dev/bsr*
~~~~

       Step 2
         Register the script in the node definitions in the xCAT database. If an xCAT nodegroup is defined for all nodes that will be using these scripts, run the following xCAT command:

~~~~
         chdef -t group -o <compute nodegroup> -p postbootscripts="IBMhpc.post"
~~~~


  * (Optional, Power 775 cluster only) Enable UPC compiler

UPC compiler is supported on Power 775 cluster, you will want to install UPC compiler RPMs from otherpkg list and accept the license by postbootscript if UPC compiler is used. You will need to copy the sample pkglist file and sample postbootscript, and add the include for UPC compiler. For example, you could:

     Add upc.otherpkgs.pkglist to sample otherpkgs list:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist /install/custom/install/rh/<profile>.otherpkgs.pkglist
     vi /install/custom/install/rh/<profile>.otherpkgs.pkglist
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/upc.otherpkgs.pkglist#
~~~~


     Copy UPC compiler postbootscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/compilers/upc_license /install/postscripts
~~~~


     Add UPC compiler postbootscript as the nodes' attribute postbootscripts:

~~~~
     chdef -t group -o compute -p postbootscripts="upc_license"
~~~~


     Note: The xlf, vacpp, and upc compilers all have a dependency on the xlmass-lib rpm. There is a problem that the current versions of the compilers require DIFFERENT versions of xlmass. xlf 13.1.0.x and vacpp 11.1.0.x compilers requires xlmass 6.1 while upc 12.0.0.x compiler requires xlmass 7.1. To workaround it, you will need to add additional manual steps in compilers_license to install xlmass 6.1 and 7.1 both for nodes. For example, edit the compilers_license to install xlmass 6.1 manually:

~~~~
     #Make sure the following xlmass.lib-6.1.0.x file name is correct and uncomment the following lines.
     #Note that there is one line in the following code different from code in compilers_license, showing with blue:
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




  * (Optional)Use xCAT prescript when installing multiple PE releases

PE provides a root-owned script, pelinks, which allows installers and system administrators to establish symbolic links to the common locations

such as /usr/bin and /usr/lib for the production PE version. Refer to IBM PE Runtime Edition: Operation and Use at http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html for a description of the pelinks script.

If you are installing multiple PE releases on AIX diskless nodes, additional setup is required. After you finish the steps listed in. [Setting_up_PE_in_a_Statelite_or_Stateless_Cluster#Add_Compilers_and_PE_to_your_diskless_image_2], run the command below to establish the PE links correctly:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/<pe release>/ppe.poe/bin/pelinks"
~~~~


     For example, if you want to establish PE links to PE 1.1.0.1 release, run command:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/pe1101/ppe.poe/bin/pelinks"
~~~~


     This can be automated by using xCAT prescripts, refer to the xCAT documentation [Postscripts_and_Prescripts] to see more details on how to do it.

#### Instructions for adding Compiler and PE Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding Compiler and PE software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the Compiler and PE software and run the postscripts using the pkglist and otherpkgs.pkglist files created above. Note that support was added to updatenode in xCAT 2.5 to install packages listed in pkglist files (previously, only otherpkgs.pkglist entries were installed). If you are running an older version of xCAT, you may need to add the pkglist entries to your otherpkgs.pkglist file or install those packages in some other way on your existing nodes.

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

  *     * Make sure otherpkglist and pkglist definition to customized list path in osimage definition;
    * Run "nodeset &lt;noderange&gt; install" for all your nodes
    * Run rnetboot to boot and install your nodes
    * When the nodes are up, verify that the compiler and PE rpms are all correctly installed, that licenses have been accepted, and that you can run a sample POE job.

## AIX

As stated at the beginning of this page, these instructions assume that you have already created a stateful image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX nodes [XCAT_AIX_RTE_Diskfull_Nodes].

#### Add Compilers and PE to your stateful image

Include Compilers and PE in your stateful image:

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
~~~~


     The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following file to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/compilers/compilers.bnd
      /opt/xcat/share/xcat/IBMhpc/pe/pe-1200.bnd
~~~~


     Note: If you are using PE v1.1.0.0 or beyond, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.bnd as the sample bundle file.

  * Add the packages to the lpp_source used to build your image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/compilers
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/compilers <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/pe
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/pe <lpp_source_name>
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

~~~~

     Note: If you are using PE v1.1.0.0 or beyond, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.bnd as the sample bundle file.
     Review these sample bundle files and make any changes as desired.

  * Add the bundle resources to your xCAT image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,compilers,pe"
~~~~


  * Add postscripts:

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,pe_install-1200"
~~~~


     Note: If you are using PE v1.1.0.0 or beyond, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sameple postscript.
     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will be run on the node after it has booted as part of the xCAT diskless node postscript processing.

  * (Optional) Enlarge the size of /opt:

     If you are using PE v1.1.0.0 or beyond, you may need to enlarge the size of /opt for your compute nodes to make the install of PE packages success. One way is to define the image_data NIM resource, enlarge the size of /opt in it, and specify the image_data to your osimage.

  * (Optional) Synchronize system configuration files:

     PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/install/aix/<profile>.synclist
     add the following lines:
       /etc/hosts /etc/passwd /etc/group -> /etc/
       /etc/security/passwd /etc/security/group /etc/security/limits /etc/security/roles -> /etc/security/
~~~~


     Add this syncfile to your image:

~~~~
      chdef -t osimage -o <imagename> synclists=/install/custom/install/aix/<profile>.synclist
~~~~


When the node is installed or 'updatenode &lt;noderange&gt; -F' is run, these files will be copied to the node. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes].

#### Instructions for adding PE Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding PE software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the PE software and run the postscripts. To have updatenode install both the OS prereqs and the base PE packages, complete the previous instructions to add PE software to your image.

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
    * When the nodes are up, verify that the compilers and PE are correctly installed.

**NOTE** The ppe.pdb 5.2 lpp will fail during an AIX stateful install when it is installed from a bundle file. The lpp postscript tries to start the scidv1 daemon using SRC, but the System Resource Controller is not active at the time the lpp is installed. This is a known problem and will be fixed in the next release of ppe.pdb.

As a workaround, after your nodes have been installed and rebooted, use xCAT to update the software on your nodes:

~~~~
         updatenode <noderange> -S  installp_flags="-agQXY"
~~~~


This will correctly install the failed packages since SRC should now be active on your nodes.

## Starting PE on cluster nodes

The PNSD daemon is started from xinetd on your compute nodes. This daemon should start automatically at node boot time. Verify that xinetd is running on your nodes and that your PNSD daemon is active.

## POE hostlist files

If you are using POE to start a parallel job, xCAT can help create your host list file. Simply run the nodels command against the desired noderange and redirect the output to a file. For example:

~~~~
      nodels compute > /tmp/hostlist
      poe -hostfile /tmp/hostlist ....
~~~~



