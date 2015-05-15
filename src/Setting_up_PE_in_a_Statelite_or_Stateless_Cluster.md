<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
  - [Add Compilers and PE to your diskless image](#add-compilers-and-pe-to-your-diskless-image)
  - [Network boot the nodes](#network-boot-the-nodes)
  - [Starting PE on cluster nodes](#starting-pe-on-cluster-nodes)
  - [POE hostlist files](#poe-hostlist-files)
- [AIX](#aix)
    - [Add Compilers and PE to your diskless image](#add-compilers-and-pe-to-your-diskless-image-1)
      - [(Optional)Use xCAT prescript when installing multiple PE releases](#optionaluse-xcat-prescript-when-installing-multiple-pe-releases)
    - [Network boot the nodes](#network-boot-the-nodes-1)
    - [Use xCAT prescript](#use-xcat-prescript)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview
This document assumes that you have already purchased your Parallel Environment product, have the Linux rpms available, and are familiar with the PE documentation: [http://publib.boulder.ibm.com/infocen.../pebooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html)

These instructions are based on PE 5.2.1, PE RTE 1.1.0.0 and PE RTE 1.2.0.0. If you are using a different version of ParallelEnvironment, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a diskless install.
  * You should have a diskless image created with the base OS installed and verified on at least one test node.

PE requires that you have a working C compiler installed before installing the PE rpms. This document contains instructions for installing both IBM vacpp and xlf compilers and the PE packages.

POE requires that userids be common across all nodes in a cluster, and that the user home directories are shared. There are many different ways to handle user management and to set up a cluster-wide shared home directory (for example, using NFS or through a global filesystem such as GPFS). These instructions assume that the shared home directory has already been created and mounted across the cluster and that the xCAT management node and all xCAT service nodes are also using this directory. You may wish to have xCAT invoke your custom postbootscripts on nodes to help set this up.



## Linux

Follow these instructions for installing IBM Compilers and PE in your Linux xCAT cluster.

### Add Compilers and PE to your diskless image

Include Compilers and PE in your diskless image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your managaement node. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

To install the rpm in SLES:

~~~~
      zypper refresh
      zypper install xCAT-IBMhpc
~~~~


To install the rpm in Redhat:

~~~~
      yum install xCAT-IBMhpc
~~~~


Copy the PE and compiler rpms from your distribution media onto the xCAT management node (MN). Suggested target location to put the rpms on the xCAT MN:

~~~~
       /install/post/otherpkgs/<osver>/<arch>/pe
       /install/post/otherpkgs/<osver>/<arch>/compilers
~~~~


For rhels6 ppc64, the target locations on the xCAT MN are as following:

~~~~
       /install/post/otherpkgs/rhels6/ppc64/pe/
       /install/post/otherpkgs/rhels6/ppc64/compilers/
~~~~


Note1: PE requires the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in the above directory before proceeding.
Note2: PE requires a special Java rpm to run its license acceptance script. The correct version of this rpm is identified in the PE product documentation. Ensure the Java rpm is included in the pe otherpkgs directory.
Note3: You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
        createrepo /install/post/otherpkgs/<os>/<arch>/pe
        createrepo /install/post/otherpkgs/<os>/<arch>/compilers

~~~~

If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

Note4: If you are using PE below v1.1.0.0 or beyond,install the pe-license:

~~~~
       rpm -ivh  IBM_pe_license*.rpm
       /opt/ibmhpc/install/sbin/accept_ppe_license.sh
~~~~


If there are some dependent packages of IBM_pe_license*.rpm, please install the dependent packages firstly. For rhels6 ppc64, make sure the compat-libstdc++-33.ppc64 is installed; If not, please run "yum install compat-libstdc++-33.ppc64" on rhels6 xCAT MN.

Add to pkglist: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.<ostype>.<arch>.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.rhels6.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.<ostype>.<arch>.pkglist#
~~~~


Fill in &lt;ostype&gt; and &lt;arch&gt; in the above pkglist files according to your cluster configuration, and verify the pkglist files are existing.
For rhels6 ppc64, edit /install/custom/netboot/rh/compute.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.rhels6.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe-1200.rhels6.ppc64.pkglist#
~~~~


Note: If you are using PE v1.1.0.0 or below, please use /opt/xcat/share/xcat/IBMhpc/pe/pe.pkglist as pkglist.
Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

Add to otherpkgs: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

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

If you are building a stateless image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Files will be removed when the xCAT packimage command is run. Add to exclude list: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.<ostype>.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe.exlist#
~~~~


For rhels6 ppc64, edit /install/custom/netboot/rh/compute.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/pe/pe.exlist#
~~~~


Note that PE catalog function needs multiple locale support, but /usr/lib/locale/ has been listed in exlist list and removed from stateless images. So for PE integration, you will want to comment out the line:

~~~~
      vi /install/custom/netboot/<ostype>/<profile>.exclude
      #./usr/share/locale/*
~~~~


Verify that the above sample exclude list contains the files and directories you want deleted from your diskless image. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.exlist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+_directory_" syntax) that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.*.exlist. Keeping these files in the diskless image is required for the install and functionality of some of the HPC products.

If you are building a statelite image, refer to the xCAT documentation for statelite images for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your PE support, add writable and persistent directories/files required by PE to your litefile table in the xCAT database:

~~~~
      tabedit litefile
~~~~

In a separate window, cut the contents of /opt/xcat/share/xcat/IBMhpc/pe/litefile.csv
paste into your tabedit session, modify as needed for your environment, and save


When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

Add to postinstall scripts:

Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.<os>.postinstall $1 $2 $3 $4 $5
      installroot=$installroot NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
      installroot=$installroot pedir=/install/post/otherpkgs/<osver>/<arch>/pe NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200

~~~~

Note: UPC compiler is supported on Power 775 cluster. If UPC compiler is used, you will need to edit the &lt;profile&gt;.postinstall file and add for UPC compiler.

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.<os>.postinstall $1 $2 $3 $4 $5
      installroot=$installroot NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
      installroot=$installroot NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/upc_license
      installroot=$installroot pedir=/install/post/otherpkgs/<osver>/<arch>/pe NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200

~~~~

Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sample postscript.

For rhels6 ppc64, edit /install/custom/netboot/rh/compute.postinstall and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.rhel.postinstall $1 $2 $3 $4 $5
      installroot=$1 NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license
      installroot=$1 pedir=/install/post/otherpkgs/rhels6/ppc64/pe NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200

~~~~

Note: If you are using PE v1.1.0.0, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sameple postscript.
Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. They will be run by genimage after all of your rpms are installed into the image. It will first run the general IBMhpc setup script to create filesystems, turn on services, and set system tunables. Then it will run the next script to accept the compiler licenses. Then the script to install and accept the PE license, install all of the PE rpms, and configure some options for PE will be run. Verify that these scripts will work correctly for your cluster. If you wish to make changes to any of these scripts, copy it to /install/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.

(Optional) Enable checkpoint and restart function in PE:

To enable checkpoint and restart function in PE, several additional steps are required to setup related system environment on compute node. Starting from xCAT 2.7.2, there is a script ckpt.sh provided by xCAT to config the system environment, including: virtualized pts support, unlinked file support, and read checkpoint key from rootfs which generated by xCAT postinstall script. Check PE document for more checkpointing and restarting function: [http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)

Step 1 :
Copy the ckpt.sh script from the PE installation directory to the /install/postscripts/ directory. Set the file permissions so that the scripts are world readable and executable by root.
Step 2 :
Register the scripts in the node definitions in the xCAT database. If an xCAT nodegroup is defined for all nodes that will be using these scripts, run the following xCAT command:

~~~~
        chdef -t group -o <compute nodegroup> -p postscripts="ckpt.sh"
~~~~


(Optional) Use pelinks script to support multiple PE releases:

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





(Optional) Synchronize system configuration files:

PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
     vi /install/custom/netboot/<ostype>/<profile>.synclist
~~~~

     add the following line (modify as appropriate for the files you wish to synchronize):

~~~~
       /etc/hosts /etc/passwd /etc/group /etc/shadow -> /etc/
~~~~


When packimage or litemiage is run, these files will be copied into the image. You can periodically re-sync these files as changes occur in your cluster. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes].

(Optional, Power 775 cluster only) Enable BSR support for PE RTE:

BSR is a Power 775 cluster specific hardware feature. To config it for PE RTE, you will need to install BSR package from otherpkg list, edit PE postinstall script pe_install-1200 and uncomment several lines of script for BSR configuration. Check PE document for more BSR function details: [http://publib.boulder.ibm.com/infocen.../index.jsp](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp)
Edit PE otherpkg list to include BSR package in PE otherpkg list.

~~~~
       vi pe-1200.rhels6.ppc64.otherpkgs.pkglist
~~~~

uncomment the following red line:

~~~~
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

Step 1:
Copy the IBMhpc.post from IBM HPC installation directory to the /install/postscripts/ directory. Set the file permissions so that the scripts are world readable and executable by root:

~~~~
         cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.post /install/postscripts/
~~~~

Step 2:
Uncomment the BSR code in IBMhpc.post:

~~~~
         vi /install/postscripts/IBMhpc.post
         # BSR configuration on Power 775 cluster. More BSR configuration should
         # be done by PE postinstall in genimage or postbootscript in statefull install
         #chown root:bsr /dev/bsr*
~~~~

Step 3:
Register the script in the node definitions in the xCAT database. If an xCAT nodegroup is defined for all nodes that will be using these scripts, run the following xCAT command:

~~~~
         chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.post"
~~~~


(Optional, Power 775 cluster only) Enable UPC compiler.

UPC compiler is supported on Power 775 cluster, you will want to install UPC compiler RPMs from otherpkg list and accept the license by postinstall script if UPC compiler is used. You will need to copy the sample pkglist file and sample postinstall script, and add the include for UPC compiler. For example, you could:

~~~~
     ## Add upc.otherpkgs.pkglist to sample otherpkgs list:
     cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.otherpkgs.pkglist /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
     vi /install/custom/netboot/rh/<profile>.otherpkgs.pkglist
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/gpfs/gpfs.ppc64.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/compilers.otherpkgs.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compilers/upc.otherpkgs.pkglist#

     ## Add upc_license postinstall script to sample postinstall scripts:
     cp /opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.postinstall /install/custom/netboot/rh/<profile>.postinstall
     vi <profile>.postinstall
     #### Change the line for UPC compiler from:
     #installroot=$installroot NODESETSTATE=genimage   $hpc/compilers/upc_license
     #### To
     installroot=$installroot NODESETSTATE=genimage   $hpc/compilers/upc_license

~~~~


Note: The xlf, vacpp, and upc compilers all have a dependency on the xlmass-lib rpm. There is a problem that the current versions of the compilers require DIFFERENT versions of xlmass. xlf 13.1.0.x and vacpp 11.1.0.x compilers requires xlmass 6.1 while upc 12.0.0.x compiler requires xlmass 7.1. To workaround it, you will need to add additional manual steps in compilers_license to install xlmass 6.1 and 7.1 both for nodes. For example, edit the compilers_license to install xlmass 6.1 manually:

~~~~
     #Make sure the following xlmass.lib-6.1.0.x file name is correct and uncomment the red lines:
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


Change otherpkglist and pkglist definition to customized list path in osimage definition;
Run genimage for your image using the appropriate options for your OS, architecture, adapters, etc.
Run packimage or liteimg for your image

### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; netboot" for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the Compiler and PE rpms are all correctly installed, that your compiler licenses have been accepted, and that you can run a sample POE job.




### Starting PE on cluster nodes

The PNSD daemon is started from xinetd on your compute nodes. This daemon should start automatically at node boot time. Verify that xinetd is running on your nodes and that your PNSD daemon is active.

### POE hostlist files

If you are using POE to start a parallel job, xCAT can help create your host list file. Simply run the nodels command against the desired noderange and redirect the output to a file. For example:

~~~~
      nodels compute > /tmp/hostlist
      poe -hostfile /tmp/hostlist ....
~~~~


## AIX

As stated at the beginning of this page, these instructions assume that you have already created a diskless image with a base AIX operating system and tested a network installation of that image to at least one compute node. This will ensure you understand all of the processes, networks are correctly defined, NIM operates well, NFS is correct, xCAT postscripts run, and you can xdsh to the node with proper ssh authorizations. For detailed instructions, see the xCAT document for deploying AIX diskless nodes [XCAT_AIX_Diskless_Nodes].

xCAT recommends that you use the mknimimage --sharedroot option to use the NIM shared root support for your diskless nodes. Your nodes will be stateless in that they will not maintain persistent files in the / root directory across reboots, but the node NIM initialization process will be much quicker, and the load on your NFS server (NIM master) will be significantly reduced.

#### Add Compilers and PE to your diskless image

Include Compilers and PE in your diskless image:

Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT and should already exist in the directory that you downloaded your xCAT rpms to. It did not get installed when you ran the instxcat script. A new copy can be downloaded from: [Download xCAT](Download_xCAT).

To install the rpm:

~~~~
      cd <your xCAT rpm directory>
      rpm -Uvh xCAT-IBMhpc*.rpm

~~~~

Copy the product packages and PTFS from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN:

~~~~
    /install/post/otherpkgs/aix/ppc64/compilers
    /install/post/otherpkgs/aix/ppc64/pe
~~~~


The packages that will be installed by the xCAT HPC Integration support are listed in sample bundle files. Review the following files to verify you have all the product packages you wish to install (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/compilers/compilers.bnd
      /opt/xcat/share/xcat/IBMhpc/pe/pe.bnd
~~~~


Note: If you are using PE v1.1.0.0 or beyond, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe-1100.bnd as the sample bundle file.

Add the packages to the lpp_source used to build your diskless image:

~~~~
     inutoc /install/post/otherpkgs/aix/ppc64/compilers
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/compilers <lpp_source_name>
     inutoc /install/post/otherpkgs/aix/ppc64/pe
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/pe <lpp_source_name>
~~~~


Some of the HPC products require additional AIX packages that may not be part of your default AIX lpp_source. Review the following file to verify all the AIX packages needed by the HPC products are included in your lpp_source (instructions are provided below for copying and editing this file if you choose to use a different list of packages):

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd
~~~~


To list the contents of your lpp_source, you can use:

~~~~
      nim -o showres <lpp_source_name>
~~~~


And to add additional packages to your lpp_source, you can use the nim update command similar to above specifying your AIX distribution media and the AIX packages you need.

Create NIM bundle resources for base AIX prerequisites and for your HPC packages:

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

Add the bundle resources to your xCAT diskless image definition:

~~~~
     chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,compilers,pe"
~~~~


Update the image:

Note: Verify that there are no nodes actively using the current diskless image. NIM will fail if there are any NIM machine definitions that have the SPOT for this image allocated. If there are active nodes accessing the image, you will either need to power them down and run rmdkslsnode for those nodes, or you will need to create a new image and then switch your nodes to that image later. For more information and detailed instructions on these options, see the xCAT document for updating software on AIX nodes: [Updating_AIX_Software_on_xCAT_Nodes]

~~~~
      mknimimage -u <image_name>
~~~~


Add postscripts:

~~~~
     cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
     cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1200 /install/postscripts
     chdef -t group -o <compute nodegroup> -p postscripts="IBMhpc.postscript,pe_install-1200"
~~~~


Note: If you are using PE v1.1.0.0 or beyond, please refer to /opt/xcat/share/xcat/IBMhpc/pe/pe_install-1100 as the sameple postscript.
Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will be run on the node after it has booted as part of the xCAT diskless node postscript processing.

(Optional) Synchronize system configuration files:

PE requires that userids be common across the cluster. There are many tools and services available to manage userids and passwords across large numbers of nodes. One simple way is to use common /etc/password files across your cluster. You can do this using xCAT's syncfiles function. Create the following file:

~~~~
      vi /install/custom/netboot/aix/<profile>.synclist
~~~~

add the following lines (and modify these entries based on the files you wish to synchronize):

~~~~
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


You can periodically re-sync these files to the nodes as changes occur in your cluster by running 'updatenode &lt;noderange&gt; -F'. See the xCAT documentation for more details: [Sync-ing_Config_Files_to_Nodes]

##### (Optional)Use xCAT prescript when installing multiple PE releases

PE provides a root-owned script, pelinks, which allows installers and system administrators to establish symbolic links to the common locations such as /usr/bin and /usr/lib for the production PE version. Refer to [IBM PE Runtime Edition: Operation and Use](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html) for a description of the pelinks script.

If you are installing multiple PE releases on AIX diskless nodes, additional setup is required. After you finish the steps listed in [Setting_up_PE_in_a_Statelite_or_Stateless_Cluster/#add-compilers-and-pe-to-your-diskless-image_1](Setting_up_PE_in_a_Statelite_or_Stateless_Cluster/#add-compilers-and-pe-to-your-diskless-image_1), run the command below to establish the PE links correctly:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/<pe release>/ppe.poe/bin/pelinks"
~~~~


For example, if you want to establish PE links to PE 1.1.0.1 release, run command:

~~~~
     xcatchroot -i <osimage name> "/usr/lpp/bos/inst_root/opt/ibmhpc/pe1101/ppe.poe/bin/pelinks"
~~~~


This can be automated by using xCAT prescripts, refer to the xCAT documentation [Postscripts_and_Prescripts] to see more details on how to do it.

#### Network boot the nodes

Follow the instructions in the xCAT AIX documentation [XCAT_AIX_Diskless_Nodes] to network boot your nodes:

  *     * Run mkdsklsnode for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the compilers, PE are correctly installed.

#### Use xCAT prescript


