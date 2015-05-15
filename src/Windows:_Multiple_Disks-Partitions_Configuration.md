<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Interface](#interface)
  - [The format of osimage.partitionfile](#the-format-of-osimagepartitionfile)
  - [Change the setting](#change-the-setting)
- [Implementation](#implementation)
- [Example](#example)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

Current code in xCAT only supports to create one partition (UEFI mode will create 3 partitions) on first disk for Windows deployment. This design is used to describe how to support multiple disks and partitions configuration during Windows deployment. 

## Interface

Two attributes are added in osimage object to specify the partition configuration and the target disk/partition for deployment. 

osimage.installto - The disk and partition that the Windows will be deployed to. The valid format is &lt;disk&gt;:&lt;partition&gt;. If not set, default value is 0:1 for bios boot mode(legacy) and 0:3 for uefi boot mode; If setting to 1, it means 1:1 for bios boot and 1:3 for uefi boot; 

osimage.partitionfile - The path of partition configuration file. Since the partition configuration for bios boot mode and uefi boot mode are different, this configuration file should include two parts if customer wants to support both bios and uefi mode. If customer just wants to support one of the modes, specify one of them anyway. 

To simplify the setting, the [INSTALLTO] section also can be added in the partitionfile as an alternative setting of osimage.installto. The installto setting in partitionfile has high priority. 

### The format of osimage.partitionfile

[INSTALLTO]0:1 (OPTIONAL of osimage.installto) 

[BIOS] &lt;CreatePartitions&gt;&lt;CreatePartition&gt;&lt;Order&gt;1&lt;/Order&gt;&lt;Type&gt;Primary&lt;/Type&gt;&lt;Size&gt;30000&lt;/Size&gt;&lt;/CreatePartition&gt;&lt;CreatePartition&gt;&lt;Order&gt;2&lt;/Order&gt;&lt;Type&gt;Primary&lt;/Type&gt;&lt;Size&gt;200&lt;/Size&gt;&lt;/CreatePartition&gt;&lt;CreatePartition&gt;&lt;Order&gt;3&lt;/Order&gt;&lt;Type&gt;Extended&lt;/Type&gt;&lt;Size&gt;300&lt;/Size&gt;&lt;/CreatePartition&gt;&lt;CreatePartition&gt;&lt;Order&gt;4&lt;/Order&gt;&lt;Type&gt;Logical&lt;/Type&gt;&lt;Size&gt;40&lt;/Size&gt;&lt;/CreatePartition&gt;&lt;CreatePartition&gt;&lt;Order&gt;5&lt;/Order&gt;&lt;Type&gt;Logical&lt;/Type&gt;&lt;Size&gt;50&lt;/Size&gt;&lt;/CreatePartition&gt;&lt;/CreatePartitions&gt;

[EFI] xxxx 

### Change the setting
    
    chdef -t osimage win2k8r2-x86_64-install-enterprise installto='1:1'
    chdef -t osimage win2k8r2-x86_64-install-enterprise paritionfile=&lt;path of configuration file&gt;
    

Run nodeset command will make the setting take effect. 
    
    nodeset &lt;node&gt; osimage=win2k8r2-x86_64-install-enterprise
    

Note: Refer to the design of 'Multiple WinPEs support' to get information of how to install in UEFI mode. 

## Implementation

When running nodeset, the variables of installto and partition configuration file will be added in /install/autoinst/&lt;node&gt;.cmd. Them will be exported out in WinPE running environment so that fixupunattend.vbs (It's a tool of xCAT that is used to update unattend.xml) could use the variables to update unattend.xml. 

In current code logic, we have following section in windows template file. fixupunattend.vbs will replace keyword ==BOOTPARTITIONS== base on the boot mode (bios mode or uefi mode) during deployment. 
    
                   &lt;Disk&gt;
                       &lt;DiskID&gt;==INSTALLTODISK==&lt;/DiskID&gt;
                       &lt;WillWipeDisk&gt;true&lt;/WillWipeDisk&gt;
                       ==BOOTPARTITIONS==
                   &lt;/Disk&gt;
    

In this feature, the above part will be changed to a new keyword '==DISKCONFIG==' in template files. 

The fixupunattend.vbs tool will be changed that can run to replace the keyword '==DISKCONFIG==' to the disk/partition configuration which is set in winimage.parititionfile. 

It's same for handling the 'installto' variable that update the deployment target '&lt;disk&gt; and &lt;partition&gt;' in unattend.xml by fixupunattend.vbs. 

## Example

Following is an example of content in partitionfile which can be used to create 2 primary partitions, 1 extended partition and 1 logic partition on disk 0, and create 2 primary partitions on disk 1. 

Note: It only includes the configuration for BIOS mode. 

Refer to http://technet.microsoft.com/en-us/library/ff715671.aspx for the format of unattend.xml. 

  
Partitionfile: 
    
    [INSTALLTO]1:2
    
    
    [BIOS]
    &lt;Disk&gt;
    &lt;DiskID&gt;0&lt;/DiskID&gt;&lt;WillWipeDisk&gt;true&lt;/WillWipeDisk&gt;
       &lt;CreatePartitions&gt;
         &lt;CreatePartition wcm:action="add"&gt;
           &lt;Order&gt;1&lt;/Order&gt;
           &lt;Type&gt;Primary&lt;/Type&gt;
           &lt;Size&gt;200000&lt;/Size&gt;
         &lt;/CreatePartition&gt;
         &lt;CreatePartition wcm:action="add"&gt;
           &lt;Order&gt;2&lt;/Order&gt;
           &lt;Type&gt;Primary&lt;/Type&gt;
           &lt;Size&gt;2000&lt;/Size&gt;
         &lt;/CreatePartition&gt;
         &lt;CreatePartition wcm:action="add"&gt;
           &lt;Order&gt;3&lt;/Order&gt;
           &lt;Type&gt;Extended&lt;/Type&gt;
           &lt;Extend&gt;true&lt;/Extend&gt;
         &lt;/CreatePartition&gt;
         &lt;CreatePartition wcm:action="add"&gt;
           &lt;Order&gt;4&lt;/Order&gt;
           &lt;Type&gt;Logical&lt;/Type&gt;
           &lt;Size&gt;2000&lt;/Size&gt;
         &lt;/CreatePartition&gt;
       &lt;/CreatePartitions&gt;
    &lt;/Disk&gt;
    
    &lt;Disk&gt;
    &lt;DiskID&gt;1&lt;/DiskID&gt;&lt;WillWipeDisk&gt;true&lt;/WillWipeDisk&gt;
       &lt;CreatePartitions&gt;
         &lt;CreatePartition wcm:action="add"&gt;
           &lt;Order&gt;1&lt;/Order&gt;
           &lt;Type&gt;Primary&lt;/Type&gt;
           &lt;Size&gt;200000&lt;/Size&gt;
         &lt;/CreatePartition&gt;
         &lt;CreatePartition wcm:action="add"&gt;
           &lt;Order&gt;2&lt;/Order&gt;
           &lt;Type&gt;Primary&lt;/Type&gt;
           &lt;Extend&gt;true&lt;/Extend&gt;
         &lt;/CreatePartition&gt;
       &lt;/CreatePartitions&gt;
    &lt;/Disk&gt;
    

  


## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Bruce Potter, William, Jarrod 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
