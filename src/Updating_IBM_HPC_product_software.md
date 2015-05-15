<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Update Methods](#update-methods)
  - [Updating software using the xCAT updatenode command](#updating-software-using-the-xcat-updatenode-command)
  - [Updating software in an existing diskless image](#updating-software-in-an-existing-diskless-image)
  - [Create a new diskless image with the software updates](#create-a-new-diskless-image-with-the-software-updates)
  - [Workaround for Known Problem with LoadLeveler PTF Updates](#workaround-for-known-problem-with-loadleveler-ptf-updates)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Overview

If you have used the xCAT IBM HPC Integration support to initially install HPC software on your cluster nodes, you can apply product updates to your cluster in several different ways. The method you choose will depend upon many factors: 

  * the type of cluster you are running: stateless, statelite, or stateful, and also Linux or AIX 
  * the extent of the software updates and your confidence in the stability of those updates 
  * whether the updates can be applied to a running cluster 
  * whether node reboots are required after applying the software 
  * whether you need to preserve the existing compute node image and be able to revert back to that image if you encounter problems with the updates 

### Update Methods

Some of the ways you can apply software updates to your cluster using xCAT are: 

  * For minor patches that can be applied to a running stateless (Linux only) or stateful (Linux or AIX) cluster, use the xCAT updatenode command to update software packages, syncronize files, and run postscripts. Remember to apply the same updates to the stateless compute node image on the management node and service nodes so that if a stateless node is rebooted, it will be running with the correct software. 
  * For minor patches that can be applied to a stateless or statelite cluster in a maintenance window, shut down all of the cluster nodes, apply the updates to the compute node image, and reboot the nodes with the updated image. 
  * For more extensive updates to a stateless or statelite cluster, create a new OS image for your compute nodes,install the HPC product software and updates in the image, and reboot your compute nodes switching to this new image. You also have the possibility of switching back to the original image if you encounter problems. 

  
In all cases, you will need to start by downloading the product updates to your xCAT management node and putting them into the same directories you placed the original product software: 
   
~~~~ 
       /install/post/otherpkgs/<osver>/<arch>/<product>
~~~~

where <product> is: 

~~~~
    gpfs 
    loadl 
    pe 
    essl 
    compilers 
    rsct 
~~~~

Note: For GPFS on Linux, only the base GPFS rpms can be placed in the above directories. If you have GPFS update rpms, copy them to the following location: 
  
~~~~  
      /install/post/otherpkgs/gpfs_updates
~~~~    

And for AIX, you will also need to add the updates to your NIM lpp_source. For each &lt;product&gt; that you have updates for: 
 
~~~~   
     inutoc /install/post/otherpkgs/aix/ppc64/<product>
     nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/<product>  <lpp_source_name>
    
~~~~
  
As with all product updates, you will need to be aware of any new operating system dependencies, any changes required to the product configuration, or any changes to operational procedures for administering or using the product. The default sample xCAT HPC Integration files may not support all the product updates as soon as they are available. Be sure to review all package lists, bundle files, scripts, and other files that you are using to ensure they will work correctly for the product updates you are installing. 

  
Note: For Linux statelite clusters, a problem exists when updating the LoadLeveler rpms(e.g. PTF6 to PTF7). Currently, a new license rpm is shipped and must be installed and accepted before the other LL rpms will install correctly. This will be fixed in future LL PTFs, so that customers will only need to accept the license when installing the base LL rpms. For LL updates, no LL license rpm will be updated and customers will not need to accept the license a second time. Currently, the xCAT HPC integration does not support LoadLeveler upgrades until a fix becomes available. 



### Updating software using the xCAT updatenode command

Use this method for updating your HPC software if you are confident that you are applying stable, minor updates that will not impact an active cluster. You can use updatenode to apply software to Linux stateless nodes that have the operating system fully loaded into memory, and for all stateful nodes that have the operating system installed on a writeable disk. This method will not work if the products are currently installed in read-only directories in statelite or AIX diskless clusters. 

  * Stop any services running on your cluster nodes that may be impacted by the software update. 
  * If you are using xCAT service nodes with local /install directories, synchronize all /install changes from the xCAT management node to the service nodes. 
  * Run the updatenode command for your nodes: 
 
~~~~   
      updatenode <noderange>
~~~~    

     This will run all three options for updating software, running postscripts, and synchronizing files (in that order). If you only wish to do one or two of those options, or run the operations in a different order, specify the correct flags to the updatenode command. See the [updatenode man page](http://xcat.sourceforge.net/man1/updatenode.1.html) for more details. 

  


### Updating software in an existing diskless image

Use this method for updating your HPC software if you are confident that you are applying stable updates that you wish to commit to your existing compute node image and you have a scheduled maintenance window for your cluster. You can use this approach for all diskless nodes, either stateless or statelite, Linux or AIX. 

  * Stop all services running on your cluster nodes and use the OS shutdown command to halt the operating system. 
  * Update the existing diskless image and reboot your nodes. 

     For Linux: 

  *     * Run genimage for your image using the appropriate options for your OS, architecture, adapters, etc. 
    * Run packimage or liteimg for your image 
    * Run "nodeset &lt;noderange&gt; ..." with the appropriate boot option for all your nodes 
    * Run rnetboot to boot your nodes 

  


For AIX, follow the detailed documentation provided in [Updating_AIX_Software_on_xCAT_Nodes]. 

  *     * Update the image: mknimimage -u &lt;image_name&gt;
    * Run mkdsklsnode for all your nodes (you may need to use the "--force" flag to correctly recreate the NIM resources) 
    * Run rnetboot to boot your nodes to the updated image 

  


     When the nodes are up, verify that all the HPC software updates are correctly installed. 

### Create a new diskless image with the software updates

Use this method for updating your HPC software when there are extensive changes, you wish to test the changes on a small number of nodes first, you have a limited maintenance window or can do a rolling upgrade, or if you need to keep a copy of your existing image to revert back to if the updates fail. You can use this approach for all diskless nodes, either stateless or statelite, Linux or AIX. 

  


For Linux: 

  * Create copies of all of the following files you are currently using, assigning a new profile name: 
   
~~~~ 
      /install/custom/netboot/<ostype>/<profile>.pkglist
      /install/custom/netboot/<ostype>/<profile>.otherpkgs.pkglist
      /install/custom/netboot/<ostype>/<profile>.exlist
      /install/custom/netboot/<ostype>/<profile>.postinstall
      /install/custom/netboot/<ostype>/<profile>.synclist
~~~~   
 
Review and edit these files, making changes as required for your new image. 

  * If this is a statelite cluster, review the statelite, litefile, and litetree tables in the xCAT database, making changes as required for your new image. 
  * Create a new image running the genimage and packimage/liteimg commands using this new profile name and the appropriate options for your OS, architecture, adapters, etc. 
  * If you are using xCAT service nodes with local /install directories, synchronize all /install changes from the xCAT management node to the service nodes. 
  * Change your xCAT node definitions to reference the new profile: 
    
~~~~
      chdef <noderange> profile=<new-profile>
~~~~    

  * Run "nodeset &lt;noderange&gt; ..." with the appropriate boot option for all your nodes 
  * Stop all services running on your cluster nodes and use the OS shutdown command to halt the operating system. 
  * Run rnetboot to boot your nodes to the new image 

  


For AIX, follow the detailed documentation provided in: [Updating_AIX_software_in_xCAT_nodes]

     When the nodes are up, verify that all the HPC software updates are correctly installed. 

  


### Workaround for Known Problem with LoadLeveler PTF Updates

For Linux statelite or stateless clusters, a problem exists when updating the LoadLeveler rpms(e.g. PTF6 to PTF7). Currently, a new license rpm is shipped and must be installed and accepted before the other LL rpms will install correctly. This will be fixed in future LL PTFs, so that customers will only need to accept the license when installing the base LL rpms. Once fixed, when LL is updated, no LL license rpm will be updated and customers will not need to accept the license a second time. 

Until a fix is available, please follow this procedure for updating LoadLeveler: 

  * Move your current LoadLeveler rpms to another directory. For example: 
 
~~~~   
      mv /install/post/otherpkgs/<OSVER>/<ARCH>/loadl  /install/post/otherpkgs/<OSVER>/<ARCH>/loadl_base
~~~~   

  * Copy your LoadLeveler update rpms to the loadl directory: 

~~~~    
     /install/post/otherpkgs/<OSVER>/<ARCH>/loadl
~~~~    

  * Remove the license rpm that was shipped with the updates: 

~~~~    
     rm /install/post/otherpkgs/<OSVER>/<ARCH>/loadl/LoadL-full-license-*
~~~~    

  * Create a new image running the genimage command using the appropriate options for your profile, OS, architecture, adapters, etc. When genimage runs, it will issue a zypper or yum update command to update all existing rpms. At that point, you should see the update for the LoadLeveler resmgr rpm (and scheduler rpm if also installed in your image). After that, genimage will run the loadl_install postscript. You will see errors from this script when it runs /opt/ibmll/LoadL/sbin/install_ll that it cannot find the correct rpms to install. You can ignore these errors since the rpms have already been installed into the image. 
  * Continue with the procedures outlined above for running packimage/liteimg, rnetboot, etc. 
