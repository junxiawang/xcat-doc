<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Terminology](#terminology)
  - [Windows Deployment process](#windows-deployment-process)
  - [The Supported Windows OS](#the-supported-windows-os)
  - [AIK and ADK](#aik-and-adk)
  - [Example Environment](#example-environment)
- [Setup xCAT Management Node](#setup-xcat-management-node)
  - [Setup Samba on xCAT Management Node](#setup-samba-on-xcat-management-node)
- [Create WinPE](#create-winpe)
  - [Install the Technician Computer](#install-the-technician-computer)
  - [Install AIK (Automated Install Kit)](#install-aik-automated-install-kit)
  - [Install ADK (Microsoft Assessment and Deployment Kit)](#install-adk-microsoft-assessment-and-deployment-kit)
  - [Copy the xCAT Tools to technode](#copy-the-xcat-tools-to-technode)
  - [Add Device Drivers for WinPE](#add-device-drivers-for-winpe)
  - [Create WinPE on technode](#create-winpe-on-technode)
- [Create Windows osimage](#create-windows-osimage)
  - [Download the Installation ISO of Windows Server 2008](#download-the-installation-iso-of-windows-server-2008)
  - [Generate Windows osimage](#generate-windows-osimage)
  - [Install Additional Drivers for Compute Node](#install-additional-drivers-for-compute-node)
- [Run Post and Postboot Scripts after Deployment](#run-post-and-postboot-scripts-after-deployment)
  - [Customize the mypostscript.tmpl (Optional)](#customize-the-mypostscripttmpl-optional)
  - [Create post scripts and post boot scripts](#create-post-scripts-and-post-boot-scripts)
  - [Copy all the scripts to /install/winpostscripts](#copy-all-the-scripts-to-installwinpostscripts)
  - [Set the Scripts for Node or Osimage](#set-the-scripts-for-node-or-osimage)
  - [Enable the precreatemypostscripts](#enable-the-precreatemypostscripts)
- [Support Multiple WinPE (Optional)](#support-multiple-winpe-optional)
  - [Specify WinPE for osimage](#specify-winpe-for-osimage)
  - [Enable the Proxydhcp Service on xCAT MN/SN](#enable-the-proxydhcp-service-on-xcat-mnsn)
  - [Disable the Proxydhcp Support for Specific Node](#disable-the-proxydhcp-support-for-specific-node)
- [Configure Disk Partition (Optional)](#configure-disk-partition-optional)
  - [The format of osimage.partitionfile](#the-format-of-osimagepartitionfile)
  - [Change the setting](#change-the-setting)
- [Configure Secondary Nics (Optional)](#configure-secondary-nics-optional)
  - [Set Installnic](#set-installnic)
  - [Set Gateway Attribute](#set-gateway-attribute)
- [Define and Deploy Windows Compute Node](#define-and-deploy-windows-compute-node)
  - [Define a Windows Compute Node](#define-a-windows-compute-node)
  - [Deploy the Windows Node node1](#deploy-the-windows-node-node1)
- [**Reference**](#reference)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

xCAT supports to deploy Windows Operating System from a Linux xCAT management node. The usage is similar with Linux deployment except the creating of WinPE and BCD need be run on a Windows Technician computer. This document focus on the procedure of setting up Windows deployment environment.

### Terminology

  * WinPE - Windows Preinstallation Environment. Which is the deployment tool to execute the partitioning, deployment and configuration during Windows OS deployment.
  * BCD - Boot Configuration Data. Which is used to specify the location of WinPE files.
  * Technician Computer - It is a computer which is installed Windows OS and is used to create WinPE and BCD.
  * ADK - Microsoft Assessment and Deployment Kit
  * AIK - Windows Automated Installation Kit

### Windows Deployment process

  1. Install AIK or ADK on your Technician Computer for creating WinPE which will be used to perform the deployment process.
  2. Create WinPE and BCD on Technician Computer.
  3. Run copycds command to copy Windows iso to xCAT management node and create Windows osimage.
  4. Configure Windows osimage.
  5. Define node and assign osimage.
  6. Perform the deployment.

### The Supported Windows OS

    Windows 7
    Windows Server 2008
    Windows Server 2008 r2
    Windows 8
    Windows Server 2012
    Windows Server 2012 r2


### AIK and ADK

WinPE is the installer to initiate a Windows deployment. xCAT supports to use genimage.cmd (base on tool ADK) and genimage.bat (base on tool AIK) to create WinPE.

Refer to following list for the relationship between genimage.bat,genimage.cmd and WinPE versions. It's important to choose the correct genimage command base on your target deployment OS.

  * WinPE which created by genimage.bat

    WinPE version: 3.0
    Supported target Windows versions: Windows server 2008 and Windows server 2008r2. The doc mentions it also support Windows 8 and Windows server 2012, but xCAT recommends to use WinPE 4.0 which is generated by genimage.cmd for Windows server 2012 deployment.

  * WinPE which created by genimage.cmd

    WinPE version: 4.0
    Supported target Windows versions: Windows 8 and Windows server 2012.

Reference for the matrix of WinPE and supported Windows verions.

    http://technet.microsoft.com/en-us/library/hh824993


### Example Environment

  * A xCAT Management Node: mn1 (OS: rhels 6.4) - xCAT has been installed and setup correctly. The xCAT 2.8.4 and higher is needed for features: multiple WinPE, disk configuration, nics configuration and running postscripts/postbootscripts.
  * A Technician Computer: technode (OS: Windows Server 2008)
  * A Windows Compute Node: node1 - The target node for deploying windows 2008 server Operating System.
  * Target Windows Operating System: Windows Server 2008

## Setup xCAT Management Node

Assume you are familiar with the setup of xCAT management node and the basic configuration of it has been done correctly.

### Setup Samba on xCAT Management Node

samba server is used to supply network service for Windows node deployment from Linux xCAT management node. It must be set up correctly at very beginning.

  * Install samba rpm package

~~~~
    yum install samba
~~~~


  * Configure samba service

Edit /etc/samba/smb.conf . In the [global] section, change security to:

~~~~
    security = share
~~~~


Export /install directory in samba servcie:

~~~~
    [install]
    path = /install
    public = yes
    writable = yes
~~~~


  * Restart the Samba server to take effect the configuration

~~~~
    chkconfig smb on
    service smb restart
~~~~


  * Create a directory at the /install for file sharing between mn1 and technode.

~~~~
    mkdir -p /install/support
    chmod 777 /install/support
~~~~


## Create WinPE

### Install the Technician Computer

Install the Operating System on the 'technode' first, and install the AIK or ADK base on your target OS for compute node.

    **OS:**       Windows 7, Windows 8, Windows Server 2008 or Windows Server 2012.
    **Hardware:** A common x86_64 server or Lap top.


### Install AIK (Automated Install Kit)

AIK is necessary for the deployment of Windows 7, Windows server 2008 and Windows Server 2008 r2. The AIK must be installed in the default directory.

**Download AIK**

On the management node, download the Automated Install Kit (AIK) ISO: [AIK](http://www.microsoft.com/downloads/en/details.aspx?FamilyID=696DD665-9F76-4177-A811-39C26D3B3B34&displaylang=en). e.g. the downloaded iso name is KB3AIK_EN.iso.

**Copy AIK Installation files to technode**

  * Mount the KB3AIK_EN.iso to a directory:

~~~~
    mount -o loop KB3AIK_EN.iso /mnt
~~~~


  * Copy all the files to the samba sharing directory:

~~~~
    cp -a /mnt/* /install/support
~~~~


  * Map samba sharing directory on technode

~~~~
    Click: start->compute->Map Network Drive to map &#92;&#92;mn1&#92;install to a free partition z:

~~~~

**Install the AIK**

    Run the z:\support\wAIKAMD64 to install the AIK on 'technode'.


### Install ADK (Microsoft Assessment and Deployment Kit)

ADK is necessary for the deployment of Windows 8, Windows server 2012 and Windows Server 2012 r2. The ADK must be installed in the default directory.

The ADK can be downloaded and installed from [ADK](http://www.microsoft.com/en-us/download/details.aspx?id=30652). If your 'technode' cannot access Internet, use any Windows node to download the ADK installation file and copy them to 'technode' and execute the installation.

### Copy the xCAT Tools to technode

On the xCAT management node mn1, copy all files from the directory /opt/xcat/share/xcat/netboot/windows/ to the shared directory /install/support.

~~~~
    cp -a /opt/xcat/share/xcat/netboot/windows/* /install/support/
~~~~


### Add Device Drivers for WinPE

WinPE is a small Windows system which is running in memory to execute the deployment process. It needs to access network and hardware to complete the deployment. The basic drivers for network and hardware need be installed in WinPE. genimage.x command will search the c:&#92;drivers directory to get the additional drivers for WinPE.

Copy the necessary drivers to technode:c:&#92;drivers

~~~~
    log in technode
    create directory c:\drivers
    copy drivers to c:\drivers
~~~~


e.g. Download network drivers for IBM system x server: [network driver](http://www-947.ibm.com/support/entry/portal/docdisplay?brand=5000020&lndocid=MIGR-64537). And run the driver file like brcm_dd_nic_11.7.4_windows_32-64.exe to save the driver to the c:&#92;drivers\\.

### Create WinPE on technode

Log into 'technode' and open a cmd window from start-&gt;run interface. In the cmd window, copy the samba mapping directory z:&#92;support to your local system partition c:&#92;xCAT. Then chdir to the 'c:&#92;xCAT'.

**Run genimage.bat to create WinPE for Windows 7 and Windows Server 2008**

~~~~
    genimage.bat amd64
    Copy all files from technode:c:/WinPE_64/pxe/* to mn1:/tftpboot using samba service.
~~~~


**Run genimage.cmd to create WinPE for Windows 8 and Windows Server 2012**

~~~~
    genimage.cmd amd64
    Copy all files from technode:c:/WinPE_64/media/* to mn1:/tftpboot using samba service.
~~~~


## Create Windows osimage

### Download the Installation ISO of Windows Server 2008

The ISO's for Windows Server 2008 can be downloaded from [iso](http://www.microsoft.com/downloads/details.aspx?FamilyId=13C7300E-935C-415A-A79C-538E933D5424&WT.sp=_technet_,dcsjwb9vb00000c932fd0rjc7_5p3t&displaylang=en).

### Generate Windows osimage

Run the copycds command on the mn1 to copy the files from ISO of windows server 2008 to the xCAT installation directory (default is /install).

~~~~
    copycds Win2k8.iso
~~~~


Then you can get a osimage definition like following:

~~~~
    lsdef -t osimage win2k8-x86_64-install-enterprise
    Object name: win2k8-x86_64-install-enterprise
       imagetype=windows
       osarch=x86_64
       osdistroname=win2k8-x86_64
       osname=Windows
       osvers=win2k8
       profile=enterprise
       provmethod=install
       template=/opt/xcat/share/xcat/install/windows/enterprise.win2k8.x86_64.tmpl
~~~~


### Install Additional Drivers for Compute Node

During the deployment, the additional drivers will be searched from the mn1:/install/drivers/&lt;os&gt;/&lt;arch&gt;/. For osimage win2k8-x86_64-install-enterprise, you can copy the additional drivers to mn1:/install/drivers/win2k8/x86_64/ before the installation.

## Run Post and Postboot Scripts after Deployment

### Customize the mypostscript.tmpl (Optional)

The mypostscript.tmpl is a template which is used to create the mypostscript script which includes environment variables and postscripts to run in compute node. The default path is /opt/xcat/share/xcat/templates/mypostscript/mypostscript.tmpl. If you want to customize it, copy it to /install/postscripts/mypostscript.tmpl and customize it obeys the rules in [how to use mypostscript.tmpl](http://sourceforge.net/apps/mediawiki/xcat/index.php?title=Postscripts_and_Prescripts#Using_the_mypostscript_template).

### Create post scripts and post boot scripts

The scripts can be any file which can be run in Windows OS.

Since Windows OS recognizes the file type by the postfix, all the postscripts which are created for Windows compute node should have correct postfix like .bat, .cmd, .vbs, .ps1

When running of postscripts, the running log will be written to c:&#92;xcatpost&#92;xcat.log. Admin can check the log at anytime for checking and debugging.

### Copy all the scripts to /install/winpostscripts

On the xCAT management node, copy the postscripts/postbootscripts to /install/winpostscripts. If there are files which will be called by your scripts, also copy them to /install/winpostscripts

~~~~
    cp <scripts> /install/winpostscripts
~~~~


### Set the Scripts for Node or Osimage

Set the scripts in postscript and postbootscripts attributes for corresponding nodes or osimage. Note: The scripts which are set by postscripts.xcatdefaults will be ignored.

~~~~
    chdef <node> postscript="xx arg1 arg2,yy" postbootscripts="aa,bb arg1"
~~~~
    chdef -t osoimage <osimage name> postscript=xx,yy postbootscripts=aa,bb


### Enable the precreatemypostscripts

In the first pass support, the **precreatemypostscripts** must be enabled. That means for any changes in postscript/postscripts attributes or mypostscript.tmpl, the nodeset command must be run to refresh the mypostscript.

~~~~
    chdef -t site clustersite precreatemypostscripts=1
~~~~


## Support Multiple WinPE (Optional)

For WinPE to enable the network device and hard driver on a specific node, the drivers of nics and hard disks need be injected to WinPE when creating it. That means it's possible to make multiple WinPEs for different hardware. Plus the restriction that deploying of different Windows versions need different version of WinPE, xCAT offers a mechanism for node/osimage to choose a proper WinPE for Windows deployment.

Choose ADK or AIK base on the target d&#92;ployment Windows version. Copy the specify drivers for the WinPE to c:&#92;drivers and run genimage.cmd or genimage.bat base on the selected ADK or AIK to generate WinPE.

A WinPE name needs be specified to identify the WinPE when running genimage.x

~~~~
    e.g. genimage.cmd amd64 <winpe name>
~~~~


The winpe will be created in c:&#92;WinPE_64&#92;media(or pxe)&#92;winboot/&lt;winpe name&gt;, you need to copy the whole directory **winboot** to /tftpboot/ on xCAT MN.

### Specify WinPE for osimage

The WinPE is bound to osimage. Set the path of WinPE to the target osimage. Note: The value for winpepath attribute must be a relative path to /tftpboot directory. If the real path of winpe is '/tftpboot/winboot/winpe1/', the value for winpepath should be set to 'winboot/winpe1'.

~~~~
    chdef -t osimage win2k8-x86_64-install-enterprise winpepath=winboot/&lt;winpe name>
~~~~


### Enable the Proxydhcp Service on xCAT MN/SN

To support multiple WinPE, the proxydhcp-xcat service must be enabled. You can enable it via setupproxydhcp attribute (this attribute belongs to xCAT management node or service node).

Add the xCAT management node to xCAT database

~~~~
    xcatconfig -m
~~~~


Enable the proxydhcp service in xCAT management node

~~~~
    chdef <xcat MN/SN> setupproxydhcp=1 (or 'yes')
~~~~


Restart the xcatd to make the change take effect

~~~~
    service xcatd restart
~~~~


### Disable the Proxydhcp Support for Specific Node

By default, xCAT considers all nodes are proxydhcp protocol supported. If you have node which does not support proxydhcp protocol, disable the proxydhcp operation for this node.

~~~~
    chdef <node> supportproxydhcp=0 (or 'no')
~~~~


## Configure Disk Partition (Optional)

By default, Windows OS will be installed to the first partition of first disk on the compute node. To support the disk customization, two additional attributes are added in osimage object to specify the disk/partition configuration.

  * osimage.installto - The disk and partition that the Windows will be deployed to. The valid format is &lt;disk&gt;:&lt;partition&gt;. If not set, default value is 0:1 for bios boot mode(legacy) and 0:3 for uefi boot mode; If setting to 1, it means 1:1 for bios boot and 1:3 for uefi boot;
  * osimage.partitionfile - The path of partition configuration file. Since the partition configuration for bios boot mode and uefi boot mode are different, this configuration file should include two parts if customer wants to support both bios and uefi mode. If customer just wants to support one of the modes, specify one of them anyway.

To simplify the setting, the [INSTALLTO] section also can be added in the partitionfile as an alternative setting of osimage.installto. The installto setting in partitionfile has high priority.

### The format of osimage.partitionfile

~~~~
    [INSTALLTO]0:1  (OPTIONAL of osimage.installto)
    [BIOS]
    <Disk>
        <DiskID>0</DiskID>
        <WillWipeDisk>true</WillWipeDisk>
        <CreatePartitions>
               <CreatePartition wcm:action="add">
                      <Order>1</Order>
                      <Type>Primary</Type>
                      <Size>200000</Size>
                  </CreatePartition>
               <CreatePartition wcm:action="add">
                      <Order>2</Order>
                      <Type>Primary</Type>
                      <Size>2000</Size>
                  </CreatePartition>
               <CreatePartition wcm:action="add">
                      <Order>3</Order>
                      <Type>Extended</Type>
                      <Extend>true</Extend>
                  </CreatePartition>
               <CreatePartition wcm:action="add">
                      <Order>4</Order>
                      <Type>Logical</Type>
                      <Size>2000</Size>
                  </CreatePartition>
           </CreatePartitions>
    </Disk>
    [EFI]
    xxxx
~~~~


### Change the setting

~~~~
    chdef -t osimage win2k8r2-x86_64-install-enterprise installto='1:1'
    chdef -t osimage win2k8r2-x86_64-install-enterprise paritionfile=<path of configuration file>
~~~~


## Configure Secondary Nics (Optional)

By default, the installnic will be configured through dhcp. The secondary nics will not be configured. This section describes how to use the nics table to configure the installnic and secondary nics.

The interface name in Windows OS is like 'Local Area Connection' (first interface), 'Local Area Connection 2' (second interface) and 'Local Area Connection x' (next interface).

The IP for nics need be configured in nics table like following. The corresponding entry in networks table must be configured correctly, otherwise the interface will be ignored if cannot find correct netmask for the ip from networks table.

~~~~
    **nics table**
    node,nicips,nichostnamesuffixes,nictypes,niccustomscripts,nicnetworks,nicaliases,comments,disable
    "node1","Local Area Connection 3!192.168.13.250,Local Area Connection 2!192.168.12.250",,,,,,,


    **networks table**
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
    "192_168_13_0-255_255_255_0","192.168.13.0","255.255.255.0",,"192.168.13.254",,,,,,,,"1",,,,,,
~~~~


In this example, the IP of interface 'Local Area Connection 2' will be set to '192.168.12.250'. And IP of interface 'Local Area Connection 3' will be set to '92.168.13.250'. Since no setting for 'Local Area Connection' (first interface) is specified, it will keep to use dhcp to get network configuration(this is the default setting for an active interface).

### Set Installnic

The installnic (The nic which is installed on compute node for OS deployment) will only be set to static if the key site.setinstallnic is set to '1' or 'yes', otherwise the installnic will keep to get IP from dhcp server even if it is set in nics table.

The node.installnic or node.primarynic is used to specify the name of instlalnic. For Windows deployment, it must be specified. Otherwise xCAT will consider all the interfaces in nics table as non-installnic.

~~~~
    chdef -t site clustersite setinstallnic=1
    chdef <node>  installnic='Local Area Connection'
~~~~


### Set Gateway Attribute

Only the gateway from the intallnic network will be set to default gateway for Windows compute node. The gateway which is set in other networks will be ignored.

## Define and Deploy Windows Compute Node

### Define a Windows Compute Node

  * Define the compute node node1 on the management node

~~~~
    mkdef -t node -o node1 groups=win2k8 arch=x86_64 mgt=ipmi netboot=xnba
~~~~


  * Set the IP and Mac address for the node1:

~~~~
    chdef node1 mac=xx:xx:xx:xx:xx:xx
    chdef node1 ip=xxx:xxx:xxx:xxx (Or editing /etc/hosts and add the mapping of IP and node name.)
~~~~


  * Add the default password for the new installed compute node:

~~~~
    tabdump passwd
     key,username,password,cryptmethod,authdomain,comments,disable
     ...
     "system","root","password",,,,
     "system","Administrator","password",,,,
~~~~


  * Add the Windows license key for the node1:

~~~~
    chtab node=node01 prodkey.product=win2k8 prodkey.key=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
~~~~


If you do not specify a license key, the KMS key will be used for deployment.

  * Set the timezone for the Windows compute node:

Windows compute node only can accept the Windows recognized timezone format, set the site.wintimezone to the correct value.

~~~~
    chdef -t site wintimezone="Eastern Standard Time"
~~~~


### Deploy the Windows Node node1

~~~~
    makehosts node1
    makedns node1
    nodeset node1 osimage=win2k8-x86_64-install-enterprise
    rsetboot node1 net
    rpower node1 on  (or manually power on)
~~~~


## **Reference**

You can get more detail description about how to deploy a windows system: http://www-01.ibm.com/support/docview.wss?uid=tss1wp101770

