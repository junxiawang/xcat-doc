<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview of the xCAT Support](#overview-of-the-xcat-support)
- [Installing all IBM HPC products](#installing-all-ibm-hpc-products)
- [Product-Specific Information](#product-specific-information)
- [Updating IBM HPC product software](#updating-ibm-hpc-product-software)
- [Updating xCAT software](#updating-xcat-software)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

_**For all xCAT AIX Releases and for xCAT 2.7.x and older Linux Releases**_

For xCAT 2.8 and newer releases on Linux clusters, use the xCAT Software Kit Support for the IBM HPC Products: [IBM_HPC_Software_Kits] 


## Overview of the xCAT Support

xCAT provides basic integration support for the IBM HPC Software Stack consisting of the following products: 

  * GPFS 
  * LoadLeveler 
  * Parallel Environment (PE), including: 
    * Parallel Operating Environment (POE) 
    * Low-Level Application Programming Interface (LAPI) 
    * Protocol Network Services Daemon (PNSD) 
    * Parallel Debugger (PDB) 
  * ESSL and PESSL 
  * IBM vacpp and xlf compilers 
  * RSCT 

  
xCAT integration support for these products includes the following sample files: 

  * AIX NIM Bundle files and Linux xCAT package list files 
  * Linux exclude list files to help reduce the memory footprint of stateless images 
  * Linux statelite xCAT litefile table entries 
  * Postscripts to customize the HPC product in a diskless image or on a running node 

This support will use xCAT to do basic product installation and configuration into stateless or statelite diskless images or into statefull nodes. The support is provided as sample files only. Before using this support, you should review all files first and modify them to conform to your environment. 

It is the intention of this implementation to only provide compute node runtime environments for the HPC products. Full compilers, development environment toolkits, and LoadLeveler scheduler software are typically not installed on compute nodes to reduce image sizes. If you require any additional software on your compute nodes, copy the sample files provided and add the desired software packages, configuration scripts, or whatever else you may need. 

In addition to compute nodes, clusters normally also require other "infrastructure" nodes such as xCAT service nodes, GPFS I/O servers, LoadLeveler central manager, resource managers, region managers, and scheduler nodes, login nodes for users to access the cluster, compile jobs, and use development toolkits, and other nodes that may play unique roles in your environment. Each of these types of nodes will have its own unique software, configuration, and tuning requirements, which may not all be currently addressed by the instructions provided in this documentation. You can use the procedures outlined here and sample files provided with xCAT to create and modify additional install images, software package lists, customization scripts, etc., to build custom installations for each of these different types of nodes in your cluster. 

These instructions do NOT include information on installing and configuring support for Infiniband or any other network products. For using IB in your xCAT cluster, see the xCAT documentation: [Managing_the_Infiniband_Network] 

Note: With xCAT 2.6, the filenames for all Redhat support files shipped in the xCAT-IBMhpc rpm were changed from *.rhel6.* to *.rhels6.* to correspond with the rest of xCAT Redhat support. This documentation uses the *.rhels6.* names in all examples. 

## Installing all IBM HPC products

xCAT provides a set of sample files that combine all of the individual HPC product files to allow you to more easily install the entire software stack in an xCAT cluster. Before using these combined packages, it will be helpful for you to review the details of each specific product as outlined below. 

  * [Setting_up_all_IBM_HPC_products_in_a_Statelite_or_Stateless_Cluster] 
  * [Setting_up_all_IBM_HPC_products_in_a_Stateful_Cluster] 
  * [Additional_steps_for_Setting_up_all_IBM_HPC_products_in_a_HA_MN_environment] 
  * [Setting_up_IBM_HPC_Products_on_an_IO_node] 

  


  * [Setting_Up_IBM_HPC_Products_on_a_Statelite_or_Stateless_Login_Node] 
  * [Setting_Up_IBM_HPC_Products_on_a_Stateful_Login_Node] 

## Product-Specific Information

  * [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] 
  * [Setting_up_GPFS_in_a_Stateful_Cluster] 

  


  * [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] 
  * [Setting_up_LoadLeveler_in_a_Stateful_Cluster] 

  


  * [Setting_up_PE_in_a_Statelite_or_Stateless_Cluster] 
  * [Setting_up_PE_in_a_Stateful_Cluster] 

  


  * [Setting_up_ESSL_and_PESSL_in_a_Statelite_or_Stateless_Cluster] 
  * [Setting_up_ESSL_and_PESSL_in_a_Stateful_Cluster] 

  


  * [Setting_up_RSCT_in_a_Statelite_or_Stateless_Cluster] 
  * [Setting_up_RSCT_in_a_Stateful_Cluster] 

  


  * [Setting_up_TEAL_on_xCAT_Management_Node] 

## Updating IBM HPC product software

If you have used the xCAT IBM HPC Integration support to initially install HPC software on your cluster nodes, you can apply product updates to the cluster: 

  * [Updating_IBM_HPC_product_software] 

  


## Updating xCAT software

If you are updating the xCAT software on your xCAT management node and service nodes, you will need to remember to also update the xCAT-IBMhpc rpm. Depending on the process you use to update the xCAT rpms, this rpm may not automatically get updated. 

Also, if you have copied any files (e.g. postscripts, pkglists, bundle files, etc.) from /opt/xcat/share/xcat/IBMhpc to other locations, you may need to update those copied files when installing a new version of xCAT. 
