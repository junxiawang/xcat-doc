<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
  - [Add RSCT to your diskless image](#add-rsct-to-your-diskless-image)
  - [Network boot the nodes](#network-boot-the-nodes)
  - [End](#end)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

This document assumes that you have already purchased your RSCT product, have the Linux rpms available, and are familiar with the RSCT documentation: [http://publib.boulder.ibm.com/infocen.../rsctbooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=/com.ibm.cluster.rsct.doc/rsctbooks.html)


For HPC clusters, RSCT support is optional:

  * LoadLeveler no longer uses RSCT to monitor adapter and node status. However, for AIX, a user may choose to configure LoadLeveler to support the cluster security services component of RSCT. The xCAT Integration for RSCT on AIX will not provide any specific support in configuring RSCT Host Based Authentication or Trusted Host Lists.
  * RSCT can be installed by customers that wish to use the RMC plugin option of the xCAT monitoring support. See the xCAT document for more information: [Monitoring_an_xCAT_Cluster].


These instructions are based on RSCT 2.5.5. If you are using a different version of of this product, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a diskless install.
  * You should have a diskless image created with the base OS installed and verified on at least one test node.




## Linux

Follow these instructions for installing IBM RSCT in your Linux xCAT cluster.

### Add RSCT to your diskless image

Include RSCT in your diskless image:

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


  * Copy the RSCT rpms from your distribution media onto the xCAT management node (MN). Suggested target location to put the rpms on the xCAT MN:

~~~~
       /install/post/otherpkgs/<osver>/<arch>/rsct
~~~~


For Redhat6 ppc64,the target location is:

~~~~
       /install/post/otherpkgs/rhels6/ppc64/rsct
~~~~


Note 1: RSCT requires the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in the above directory before proceeding.
Note 2: You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
       createrepo /install/post/otherpkgs/<os>/<arch>/rsct
~~~~


If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

  * Add to pkglist: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.pkglist#
~~~~


For Redhat6 ppc64, edit the /install/custom/netboot/rh/compute.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.pkglist#
~~~~


Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * If you are using xCAT 2.7 or above, edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.otherpkgs.pkglist#
~~~~


  * For xCAT build below 2.7, even though the file /opt/xcat/share/xcat/IBMhpc/rsct/rsct.otherpkgs.pkglist is shipped with xCAT, this is only intended to be used for stateful installs. For diskless images, genimage will install the RSCT rpms when it calls the rsct_install postinstall script (see below).

Verify that the above sample pkglists contain the correct packages. Note that these pkglists do not contain the actual RSCT rpms. In an xCAT Stateless or Statelite cluster, all RSCT rpms will be installed as part of the postinstall scripts below. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.

  * If you are building a stateless image that will be loaded into the node's memory, you will want to remove all unnecessary files from the image to reduce the image size. Files will be removed when the xCAT packimage command is run. Add to exclude list: Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.exlist#
~~~~


For Redhat6 ppc64, edit the /install/custom/netboot/rh/compute.exlist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.exlist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.exlist#
~~~~


Verify that the above sample exclude list contains the files and directories you want deleted from your diskless image. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.exlist and edit as you wish instead of using the #INCLUDE: ...# entry.

Note: Several of the exclude list files shipped with xCAT-IBMhpc re-include files (with "+directory" syntax) that are normally deleted with the base exclude lists xCAT ships in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.*.exlist. Keeping these files in the diskless image is required for the install and functionality of some of the HPC products.

  * If you are building a statelite image, refer to the xCAT documentation for statelite images for creating persistent files, identifying mount points, and configuring your xCAT cluster for working with statelite images. For your RSCT support, add writable and persistent directories/files required by RSCT to your litefile table in the xCAT database:

~~~~
      tabedit litefile
~~~~

      In a separate window, cut the contents of /opt/xcat/share/xcat/IBMhpc/rsct/litefile.csv
      paste into your tabedit session, modify as needed for your environment, and save


When using persistent files, you should also make sure that you have an entry in your xCAT database statelite table pointing to the location for storing those files for each node.

  * Add to postinstall scripts(Please skip this step if you use xCAT 2.7 or above):

     Edit your /install/custom/netboot/&lt;ostype&gt;/&lt;profile&gt;.postinstall(please make sure it has executable permission) and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.<os>.postinstall $1 $2 $3 $4 $5
      installroot=$1 rsctdir=/install/post/otherpkgs/<osver>/<arch>/rsct NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/rsct/rsct_install
~~~~


For Redhat6 ppc64, edit the /install/custom/netboot/rh/compute.postinstall(please make sure it has executable permission) and add:

~~~~
      /opt/xcat/share/xcat/IBMhpc/IBMhpc.rhel.postinstall $1 $2 $3 $4 $5
      installroot=$1 rsctdir=/install/post/otherpkgs/rhels6/ppc64/rsct NODESETSTATE=genimage   /opt/xcat/share/xcat/IBMhpc/rsct/rsct_install
~~~~


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. They will be run by genimage after all of your rpms are installed into the image. It will first run the general IBMhpc setup script to create filesystems, turn on services, and set system tunables. Then the script to install all of the RSCT rpms will be run. Verify that these scripts will work correctly for your cluster. If you wish to make changes to any of these scripts, copy it to /install/postscripts and adjust the above entry in the postinstall script to invoke your updated copy.

  * Run genimage for your image using the appropriate options for your OS, architecture, adapters, etc.
  * Run packimage or liteimg for your image

### Network boot the nodes

Network boot your nodes:

  *     * Run "nodeset &lt;noderange&gt; netboot" or "nodeset &lt;noderange&gt; statelite"for all your nodes
    * Run rnetboot to boot your nodes
    * When the nodes are up, verify that the RSCT rpms are all correctly installed.

### End



