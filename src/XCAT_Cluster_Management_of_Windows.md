<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Example environment](#example-environment)
- [Setup the management node](#setup-the-management-node)
  - [Setup Samba on the management node](#setup-samba-on-the-management-node)
  - [Make a samba directory](#make-a-samba-directory)
  - [Get the installation ISO for Windows Server 2008](#get-the-installation-iso-for-windows-server-2008)
  - [Copy the installation files to management node](#copy-the-installation-files-to-management-node)
- [Create the windows boot image](#create-the-windows-boot-image)
  - [Install the windows PE node w1](#install-the-windows-pe-node-w1)
  - [Download the Automated Install Kit (AIK)](#download-the-automated-install-kit-aik)
  - [Install the AIK](#install-the-aik)
  - [Copy the xCAT tools to PE node](#copy-the-xcat-tools-to-pe-node)
  - [Add the additional device drivers on w1](#add-the-additional-device-drivers-on-w1)
  - [Generate the PE image on the PE node w1](#generate-the-pe-image-on-the-pe-node-w1)
  - [Define the compute node](#define-the-compute-node)
  - [Install the Windows Node](#install-the-windows-node)
  - [Reference](#reference)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**This page has be replaced by [XCAT_Windows].**


# Overview

This page contains directions for installing a Windows 2008 Server Enterprise (x86 / x86_64) node with xCAT.  


# Requirements

The xCAT 2.1 and later need to be installed and setup on the management node.  


# Example environment

A management node: mn1 (xCAT has been installed and setup correctly)  
A compute node: node1 (The target node for deploying windows 2008 server Operating System.)  
A Windows PE node w1 (A node to install the Windows Server 2008 manually - the architecture must be the same with the compute node: node1.) This node will be used to generate the PE image for the windows installation. 

# Setup the management node

## Setup Samba on the management node

The samba must be installed and setup on the mn1. During the installation, the compute node will use samba to connect to the mn1:/install/autoinst directory to get the installation configuration file (&lt;IP&gt;.cmd).  
Make sure that a samba service is installed. To install samba, run the command: 
    
    yum install samba

Edit /etc/samba/smb.conf  
In the [global] section, change security to: 
    
    security = share

Paste the following lines under Share Definitions 
    
    [install]
    path = /install
    public = yes
    writable = yes

Restart the Samba server. 
    
    service smb restart

## Make a samba directory

Create a directory at the /install for transporting the files between the mn1 and w1. 
    
    # mkdir -p /install/support

  


## Get the installation ISO for Windows Server 2008

The ISO's for Windows Server 2008 can be downloaded from here [http://www.microsoft.com/downloads/details.aspx?FamilyId=13C7300E-935C-...](http://www.microsoft.com/downloads/details.aspx?FamilyId=13C7300E-935C-415A-A79C-538E933D5424&WT.sp=_technet_,dcsjwb9vb00000c932fd0rjc7_5p3t&displaylang=en). But they won't be much use without a valid product key. 

## Copy the installation files to management node

Run the copycds command on the mn1 to copy the files from ISO of windows server 2008 to the xCAT installation directory (default is /install). 
    
    # copycds Win2k8.iso -n win2k8 -a x86_64

# Create the windows boot image

## Install the windows PE node w1

A boot image is needed to be created on a windows node which has the same architecture and Operating System version with the target compute node. So a windows node is needed to be installed manually first. The ISO file should use the one that downloaded in preceding step. 

## Download the Automated Install Kit (AIK)

On the management node, download the Automated Install Kit (AIK) ISO from here: [http://www.microsoft.com/downloads/en/details.aspx?FamilyID=696DD665-9F76-...](http://www.microsoft.com/downloads/en/details.aspx?FamilyID=696DD665-9F76-4177-A811-39C26D3B3B34&displaylang=en)  
For example, the downloaded iso name is KB3AIK_EN.iso.  
Since there is a samba service bas been setup on the management node mn1, copy all files from the AIK iso to a samba directory, then copy them to the windows PE node w1.  
Mount the KB3AIK_EN.iso to a directory: 
    
    # mount -o loop KB3AIK_EN.iso /mnt

Copy all the files to the samba directory: 
    
    # cp -a /mnt/* /install/support

## Install the AIK

On the Windows image node w1, following the steps: start-&gt;compute-&gt;’Map Network Drive’ to make the samba mn1:/install to be a partition (for example: d:/) of the w1.  
Get into the new partition and find the file named waik&lt;arch&gt; base on your architecture, and then run it to install the AIK on the w1. 

## Copy the xCAT tools to PE node

On the management node, copy all files from the directory /opt/xcat/share/xcat/netboot/windows/ to the exported directory /install/support. (genimage.bat and startnet.cmd) 
    
    # cp -a /opt/xcat/share/xcat/netboot/windows/* /install/support/

## Add the additional device drivers on w1

xCAT supports to add the additional device drivers to the PE image, you can download them and copy them to the c:\drivers at the w1.  
For IBM system x server, the driver of network card (Broadcom) can be downloaded here: [http://www-947.ibm.com/support/entry/.../docdisplay?brand=5000020&amp;lndocid=MIGR-64537](http://www-947.ibm.com/support/entry/portal/docdisplay?brand=5000020&lndocid=MIGR-64537).   


Create a new directory c:/drivers at the PE node w1.  
Then run the downloaded driver file like brcm_dd_nic_11.7.4_windows_32-64.exe, and save the driver to the c:\drivers\\. 

## Generate the PE image on the PE node w1

On the w1, copy files out from d:\support\ to the desktop.&lt;bk&gt; Open a command line window and change directory to the desktop, run following command to generate the PE image. 
    
    # genimage.bat amd64

Then you can find a directory was created at c:/WinPE_64/pxe, you need to copy all the directories/files in the c:/WinPE_64/pxe to the mn1:/tftpboot. Since you already has a samba directory exported out, it can be used to transport files back to management node. 

## Define the compute node

Define the compute node node1 on the management node.  
Define the OS type and architecture for the node1: 
    
    # chdef node1 os=win2k8 arch=x86_64

Add the default password for the new installed compute node: 
    
    # chtab key=system passwd.username=Administrator passwd.password=(password)

Add the Windows license key for the node1: 
    
    # chtab node=node01 prodkey.product=win2k8 prodkey.key=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

## Install the Windows Node
    
    rinstall node01

## Reference

You can get more detail description about how to deploy a windows system: http://www-03.ibm.com/support/techdocs/atsmastr.nsf/WebIndex/W 
