[Design_Warning](Design_Warning)

==Overview==
Current code in xCAT only supports to create one partition (UEFI mode will create 3 partitions) on first disk for Windows deployment. This design is used to describe how to support multiple disks and partitions configuration during Windows deployment.

==Interface==
Two attributes are added in osimage object to specify the partition configuration and the target disk/partition for deployment.

osimage.installto -  The disk and partition that the Windows will be deployed to. The valid format is <disk>:<partition>. If not set, default value is 0:1 for bios boot mode(legacy) and 0:3 for uefi boot mode; If setting to 1, it means 1:1 for bios boot and 1:3 for uefi boot;

osimage.partitionfile - The path of partition configuration file. Since the partition configuration for bios boot mode and uefi boot mode are different, this configuration file should include two parts if customer wants to support both bios and uefi mode. If customer just wants to support one of the modes, specify one of them anyway.

To simplify the setting, the [INSTALLTO] section also can be added in the partitionfile as an alternative setting of osimage.installto. The installto setting in partitionfile has high priority.

===The format of osimage.partitionfile===

[INSTALLTO]0:1  (OPTIONAL of osimage.installto)

[BIOS]
<CreatePartitions><CreatePartition><Order>1</Order><Type>Primary</Type><Size>30000</Size></CreatePartition><CreatePartition><Order>2</Order><Type>Primary</Type><Size>200</Size></CreatePartition><CreatePartition><Order>3</Order><Type>Extended</Type><Size>300</Size></CreatePartition><CreatePartition><Order>4</Order><Type>Logical</Type><Size>40</Size></CreatePartition><CreatePartition><Order>5</Order><Type>Logical</Type><Size>50</Size></CreatePartition></CreatePartitions>

[EFI]
xxxx

===Change the setting===
 chdef -t osimage win2k8r2-x86_64-install-enterprise installto='1:1'
 chdef -t osimage win2k8r2-x86_64-install-enterprise paritionfile=<path of configuration file>

Run nodeset command will make the setting take effect.
 nodeset <node> osimage=win2k8r2-x86_64-install-enterprise

Note: Refer to the design of 'Multiple WinPEs support' to get information of how to install in UEFI mode.

==Implementation==
When running nodeset, the variables of installto and partition configuration file will be added in /install/autoinst/<node>.cmd. Them will be exported out in WinPE running environment so that fixupunattend.vbs (It's a tool of xCAT that is used to update unattend.xml) could use the variables to update unattend.xml.

In current code logic, we have following section in windows template file. fixupunattend.vbs will replace keyword ==BOOTPARTITIONS== base on the boot mode (bios mode or uefi mode) during deployment.

                <Disk>
                    <DiskID>==INSTALLTODISK==</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    ==BOOTPARTITIONS==
                </Disk>

In this feature, the above part will be changed to a new keyword '==DISKCONFIG==' in template files. 

The fixupunattend.vbs tool will be changed that can run to replace the keyword '==DISKCONFIG==' to the disk/partition configuration which is set in winimage.parititionfile.

It's same for handling the 'installto' variable that update the deployment target '<disk> and <partition>' in unattend.xml by fixupunattend.vbs.

==Example ==
Following is an example of content in partitionfile which can be used to create 2 primary partitions, 1 extended partition and 1 logic partition on disk 0, and create 2 primary partitions on disk 1. 

Note: It only includes the configuration for BIOS mode.

Refer to http://technet.microsoft.com/en-us/library/ff715671.aspx for the format of unattend.xml.


Partitionfile: 
 [INSTALLTO]1:2

 [BIOS]
 <Disk>
 <DiskID>0</DiskID><WillWipeDisk>true</WillWipeDisk>
    <CreatePartitions>
      <!-- System partition -->
      <CreatePartition wcm:action="add">
        <Order>1</Order>
        <Type>Primary</Type>
        <Size>200000</Size>
      </CreatePartition>
      <!-- Windows partition -->
      <CreatePartition wcm:action="add">
        <Order>2</Order>
        <Type>Primary</Type>
        <Size>2000</Size>
      </CreatePartition>
      <!-- Windows partition -->
      <CreatePartition wcm:action="add">
        <Order>3</Order>
        <Type>Extended</Type>
        <Extend>true</Extend>
      </CreatePartition>
      <!-- Windows partition -->
      <CreatePartition wcm:action="add">
        <Order>4</Order>
        <Type>Logical</Type>
        <Size>2000</Size>
      </CreatePartition>
    </CreatePartitions>
 </Disk>
 
 <Disk>
 <DiskID>1</DiskID><WillWipeDisk>true</WillWipeDisk>
    <CreatePartitions>
      <!-- System partition -->
      <CreatePartition wcm:action="add">
        <Order>1</Order>
        <Type>Primary</Type>
        <Size>200000</Size>
      </CreatePartition>
      <!-- Windows partition -->
      <CreatePartition wcm:action="add">
        <Order>2</Order>
        <Type>Primary</Type>
        <Extend>true</Extend>
      </CreatePartition>
    </CreatePartitions>
 </Disk>


== Other Design Considerations ==

* '''Required reviewers''':  
* '''Required approvers''':  Bruce Potter, William, Jarrod
* '''Database schema changes''':  N/A
* '''Affect on other components''':  N/A
* '''External interface changes, documentation, and usability issues''':  N/A
* '''Packaging, installation, dependencies''':  N/A
* '''Portability and platforms (HW/SW) supported''':  N/A
* '''Performance and scaling considerations''':  N/A
* '''Migration and coexistence''':  N/A
* '''Serviceability''':  N/A
* '''Security''':  N/A
* '''NLS and accessibility''':  N/A
* '''Invention protection''':  N/A