<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Linux](#linux)
    - [Add RSCT to your stateful image definition](#add-rsct-to-your-stateful-image-definition)
    - [Instructions for adding RSCT Software to existing xCAT nodes](#instructions-for-adding-rsct-software-to-existing-xcat-nodes)
    - [Network boot the nodes](#network-boot-the-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

This document assumes that you have already purchased your RSCT product, have the Linux rpms available, and are familiar with the RSCT documentation: [http://publib.boulder.ibm.com/infocen.../rsctbooks.html](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=/com.ibm.cluster.rsct.doc/rsctbooks.html)


For HPC clusters, RSCT support is optional:

  * LoadLeveler no longer uses RSCT to monitor adapter and node status. However, for AIX, a user may choose to configure LoadLeveler to support the cluster security services component of RSCT. The xCAT Integration for RSCT on AIX will not provide any specific support in configuring RSCT Host Based Authentication or Trusted Host Lists.
  * RSCT can be installed by customers that wish to use the RMC plugin option of the xCAT monitoring support. See the xCAT document for more information: [Monitoring_an_xCAT_Cluster].


These instructions are based on RSCT 2..5.5. If you are using a different version of of this product, you may need to make adjustments to the information provided here.

Before proceeding with these instructions, you should have the following already completed for your xCAT cluster:

  * Your xCAT management node is fully installed and configured,
  * If you are using xCAT hierarchy, your service nodes are installed and running.
  * Your compute nodes are defined to xCAT, and you have verified your hardware control capabilities, gathered MAC addresses, and done all the other necessary preparations for a stateful (full-disk) install.
  * You should have a test node that you have installed with the base OS and xCAT postscripts to verify that the basic network configuration and installation process are correct.



## Linux

Follow these instructions for installing IBM RSCT in your Linux xCAT cluster.

#### Add RSCT to your stateful image definition

Include RSCT in your stateful image definition:

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node and service nodes. This rpm is available with xCAT and should already exist in your zypper or yum repository that you used to install xCAT on your management node. A new copy can be downloaded from:[Download_xCAT].

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


  * Copy the rsct rpm from your distribution media onto the xCAT management node (MN). Suggested target location to put the rpms on the xCAT MN:

~~~~
      /install/post/otherpkgs/<osver>/<arch>/rsct
~~~~


    Note: RSCT requires the System Resource Controller (src) rpm. Please ensure this rpm is included with your other rpms in the above directory before proceeding.&nbsp;:For Redhat6 on PPC64:

~~~~
      /install/post/otherpkgs/rhels6/ppc64/rsct
~~~~


  * Add to pkglist:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.sles11.ppc64.pkglist#
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.pkglist#
~~~~


For Redhat6 ppc64, edit the /install/custom/install/rh/compute.pkglist and add:

     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/IBMhpc.rhels6.ppc64.pkglist#


Verify that the above sample pkglists contain the correct packages. If you need to make changes to any of these pkglists, you can copy the contents of the file into your &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry.
Note: This pkglist support is available with xCAT 2.5 and newer releases. If you are using an older release of xCAT, you will need to add the entries listed in these pkglist files to your Kickstart or AutoYaST install template file.

  * Add to otherpkgs:

Edit your /install/custom/install/&lt;ostype&gt;/&lt;profile&gt;.otherpkgs.pkglist and add:

~~~~
     #INCLUDE:/opt/xcat/share/xcat/IBMhpc/rsct/rsct.otherpkgs.pkglist#
~~~~


Verify that the above sample pkglists contain the correct packages. If you need to make changes, you can copy the contents of the file into your &lt;profile&gt;.otherpkgs.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry. These packages will be installed on the node after the first reboot by the xCAT postbootscript otherpkgs. Note that these pkglists contain the actual RSCT rpms. Due to do not need license acceptance, all product rpms will be installed through pkglists, not through postinstall scripts.
You can find more information on the xCAT otherpkgs package list files and their use in the xCAT documentation [Using_Updatenode].

You should create repodata in your /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/* directory so that yum or zypper can be used to install these packages and automatically resolve dependencies for you:

~~~~
      createrepo /install/post/otherpkgs/<os>/<arch>/rsct
~~~~


    If the createrepo command is not found, you may need to install the createrepo rpm package that is shipped with your Linux OS. For SLES 11, this is found on the SDK media.

  * Add to postscripts:

     Copy the IBMhpc postscript to the xCAT postscripts directory:

~~~~
     cp /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
~~~~


     Review these sample scripts carefully and make any changes required for your cluster. Note that some of these scripts may change tuning values and other system settings. This script will run after all OS rpms are installed on the node

and the xCAT default postscripts have run, but before the node reboots for the first time.

     Add this script to the postscripts list for your node. For example, if all nodes in your compute nodegroup will be using this script:

~~~~
      chdef -t group -o compute -p postscripts=IBMhpc.postscript
~~~~


#### Instructions for adding RSCT Software to existing xCAT nodes

If your nodes are already installed with the correct OS, and you are adding RSCT software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the RSCT software and run the postscripts using the pkglist and otherpkgs.pkglist files created above. Note that support was added to updatenode in xCAT 2.5 to install packages listed in pkglist files (previously, only otherpkgs.pkglist entries were installed). If you are running an older version of xCAT, you may need to add the pkglist entries to your otherpkgs.pkglist file or install those packages in some other way on your existing nodes.

You will want updatenode to run zypper or yum to install all of the packages. Make sure their repositories have access to the base OS rpms:

~~~~
      #SLES:
      xdsh <noderange> zypper repos --details  | xcoll
      #RedHat:
      xdsh <noderange> yum repolist -v  | xcoll
~~~~


If you installed these nodes with xCAT, you probably still have repositories set pointing to your distro directories on the xCAT MN or SNs. If there is no OS repository listed, add appropriate remote repositories using the zypper ar

command or adding entries to /etc/yum/repos.d.

Also, for updatenode to use zypper or yum to install packages from your /install/post/otherpkgs directories, make sure you have run the createrepo command for each of your otherpkgs directories (see instructions in the "Updating xCAT nodes" document [Using_Updatenode].

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

  *     * Run "nodeset <noderange&gt; install" for all your nodes
    * Run rnetboot to boot and install your nodes
    * When the nodes are up, verify that the RSCT rpms are all correctly installed.


