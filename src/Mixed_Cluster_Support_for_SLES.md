<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Install the Linux Management Node](#install-the-linux-management-node)
  - [IBM POWER MN deploying a System x CN](#ibm-power-mn-deploying-a-system-x-cn)
  - [System x MN deploying a POWER CN](#system-x-mn-deploying-a-power-cn)
- [Define Compute Node](#define-compute-node)
- [Diskful installation](#diskful-installation)
- [image preparation for stateless and statelite deployment](#image-preparation-for-stateless-and-statelite-deployment)
  - [Generate image from the "MN_same_arch"](#generate-image-from-the-mn_same_arch)
  - [imgexport on the "MN_same_arch"](#imgexport-on-the-mn_same_arch)
  - [copy the image tgz to the MN](#copy-the-image-tgz-to-the-mn)
  - [imgimport on the MN](#imgimport-on-the-mn)
- [stateless/statelite deployment](#statelessstatelite-deployment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)
 


## Overview

  * Note: This function is experimental and not fully tested until xCAT 2.6.9. 

This document illustrates how to deploy linux diskful and diskless compute nodes using a linux management node in a System x and POWER mixed cluster. A cluster with both Linux nodes and AIX nodes or both System x and POWER is called a “mixed cluster”. More scenarios will be supported in the future. 

The process to set up a mixed cluster is quite similar with the process to set up a normal xCAT cluster, except there are a few special steps. This document will only cover the special steps required. Links to the documents covering the normal xCAT cluster setup are given when necessary. 

This document assumes you are somewhat familiar with xCAT basic installation. Before starting this process it is assumed you have completed the following: 

  * The xCAT management node has been installed with SLES. 
  * The cluster network is configured. (The Ethernet network that will be used to perform the network boot of the nodes.) 
  * The service network is configured. (This is used to connect to the service processors or HMCs.) 

This document covers the following two scenarios: 

  * An IBM POWER MN (management node) to deploy one System x CN (compute node) 
  * A System x MN to deploy one POWER CN 

## Install the Linux Management Node

Refer to [Setting_Up_a_Linux_xCAT_Mgmt_Node] for the steps to set up a management node for an unmixed cluster. 

### IBM POWER MN deploying a System x CN

The following rpms should be installed on the POWER MN to manage the System x CN. These rpms are found in the xcat-core and xcat-dep tarballs. 

  * xCAT-nbroot-oss 
  * xCAT-nbroot-core 
  * xCAT-nbkernel-ppc64 
  * syslinux-xcat 
  * xnba-undi 

### System x MN deploying a POWER CN

When the Linux management node is running on a System x server, the perl-IO-Stty rpm needs to be installed on the management node to perform hardware control operations on the the POWER service nodes and compute nodes. 

## Define Compute Node

For the System x CN, please refer to [XCAT_iDataPlex_Cluster_Quick_Start] 

For the POWER CN, please refer to [XCAT_pLinux_Clusters] 

## Diskful installation

The diskful installation is as the normal installation steps. Refer to the following documents for details on how to install a diskful CN: 

  * [XCAT_iDataPlex_Cluster_Quick_Start] 
  * [XCAT_pLinux_Clusters] 

## image preparation for stateless and statelite deployment

For mixed cluster statelite deployment, some additional steps are needed before deployment of the image. For this process, you need another MN that is the same architecture as the CN. 

### Generate image from the "MN_same_arch"

  * On System x MN: 
    
    /opt/xcat/share/xcat/netboot/sles/genimage -n igb -o sles11.1 -p compute
    

  * On POWER MN: 
    
    /opt/xcat/share/xcat/netboot/sles/genimage -n ibmveth -o sles11.1 -p compute
    

### imgexport on the "MN_same_arch"

Run imgexport osimage_name. For example: 
    
    idplex03:/img # imgexport sles11.1-x86_64-netboot-compute
    Exporting sles11.1-x86_64-netboot-compute to /img...
    /install/netboot/sles11.1/x86_64/compute/kernel
    /install/netboot/sles11.1/x86_64/compute/initrd-stateless.gz
    /install/netboot/sles11.1/x86_64/compute/rootimg.gz
    /opt/xcat/share/xcat/netboot/sles/compute.sles11.pkglist
    /opt/xcat/share/xcat/netboot/sles/compute.sles11.postinstall
    Inside /img/imgexport.9379.bkfmf6.
    Compressing sles11.1-x86_64-netboot-compute bundle.  Please be patient.
    Done!
    
    

### copy the image tgz to the MN

For example: 
    
    scp  sles11.1-x86_64-netboot-compute.tgz *:/img
    

### imgimport on the MN

For example: 
    
    imgimport sles11.1-x86_64-netboot-compute.tgz
    imgimport sles11.1-x86_64-netboot-compute.tgz
    Unbundling image...
    /install/netboot/sles11.1/x86_64/compute/kernel
    /install/netboot/sles11.1/x86_64/compute/initrd-stateless.gz
    /install/netboot/sles11.1/x86_64/compute/rootimg.gz
    /opt/xcat/share/xcat/netboot/sles/compute.sles11.pkglist
      Moving old /opt/xcat/share/xcat/netboot/sles/compute.sles11.pkglist to /opt/xcat/share/xcat/netboot/sles/compute.sles11.pkglist.ORIG.
    /opt/xcat/share/xcat/netboot/sles/compute.sles11.postinstall
      Moving old /opt/xcat/share/xcat/netboot/sles/compute.sles11.postinstall to /opt/xcat/share/xcat/netboot/sles/compute.sles11.postinstall.ORIG.
    Successfully imported the image.
    
    

## stateless/statelite deployment

After the OS images are made available on the MN, all the subsequent steps are exactly the same as the homogeneous cluster. Refer to the following documents for details on how to deploy diskless compute nodes: 

  * Stateless system x nodes: [Deploying Stateless Nodes X](XCAT_iDataPlex_Cluster_Quick_Start/#deploying-stateless-nodes).
  * Stateless POWER nodes: [Deploying Stateless Nodes P](XCAT_pLinux_Clusters/#stateless-node-deployment). 
  * Statelite nodes: [XCAT_Linux_Statelite] 
