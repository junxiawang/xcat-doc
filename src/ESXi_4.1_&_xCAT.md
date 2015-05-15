<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Background](#1%5C-background)
- [2\. Install the vmware sdk](#2%5C-install-the-vmware-sdk)
  - [2.1. Download the vmware sdk](#21-download-the-vmware-sdk)
  - [2.2. Uncompress the vmware sdk tar ball](#22-uncompress-the-vmware-sdk-tar-ball)
  - [2.3. Install the vmware sdk](#23-install-the-vmware-sdk)
  - [2.4. Check the installation](#24-check-the-installation)
- [3\. Install the ESXi](#3%5C-install-the-esxi)
  - [3.1. Download the ESXi iso from vmware web site. (In this document, the ESXi4.1 will be used as an example)](#31-download-the-esxi-iso-from-vmware-web-site-in-this-document-the-esxi41-will-be-used-as-an-example)
  - [3.2. Run copycds command to copy the ESXi files into the xCAT installation directory](#32-run-copycds-command-to-copy-the-esxi-files-into-the-xcat-installation-directory)
  - [3.3. Define the node as ESXi host (The node name is esxihost)](#33-define-the-node-as-esxi-host-the-node-name-is-esxihost)
  - [3.4. Add the vmware entry in the passwd table](#34-add-the-vmware-entry-in-the-passwd-table)
  - [3.5. Run xCAT command to prepare and install the esxihost node](#35-run-xcat-command-to-prepare-and-install-the-esxihost-node)
  - [3.6. Check the installation result](#36-check-the-installation-result)
- [4\. Define the virtual machines base on the ESXi host](#4%5C-define-the-virtual-machines-base-on-the-esxi-host)
  - [4.1. Define a virtual machine node (The node name is vm1)](#41-define-a-virtual-machine-node-the-node-name-is-vm1)
  - [4.2. Define the vmstorage attribute for the virtual machine node](#42-define-the-vmstorage-attribute-for-the-virtual-machine-node)
    - [4.2.1. Use the NFS type of storage](#421-use-the-nfs-type-of-storage)
    - [4.2.2. Use the VMFS type of storage](#422-use-the-vmfs-type-of-storage)
  - [4.3. Define the vmnics attribute for a virtual machine node](#43-define-the-vmnics-attribute-for-a-virtual-machine-node)
  - [4.4. An example of virtual machine node which has been defined correctly](#44-an-example-of-virtual-machine-node-which-has-been-defined-correctly)
- [5\. Create a virtual machine node](#5%5C-create-a-virtual-machine-node)
- [6\. Change the definition of a virtual machine node](#6%5C-change-the-definition-of-a-virtual-machine-node)
  - [6.1. Add another hard disk with 2G size. After the running of chvm, you can find two new .vmdk files were created for the new hard disk.](#61-add-another-hard-disk-with-2g-size-after-the-running-of-chvm-you-can-find-two-new-vmdk-files-were-created-for-the-new-hard-disk)
  - [6.2. Use the rinv command to display the hard disk that created for a virtual machine node:](#62-use-the-rinv-command-to-display-the-hard-disk-that-created-for-a-virtual-machine-node)
  - [6.3. Remove a hard disk from a virtual machine node but keep the storage files.](#63-remove-a-hard-disk-from-a-virtual-machine-node-but-keep-the-storage-files)
  - [6.4. Remove a hard disk permanently from a virtual machine node](#64-remove-a-hard-disk-permanently-from-a-virtual-machine-node)
  - [6.5. Change the memory size to 1024M for the virtual machine node (The default unit is M)](#65-change-the-memory-size-to-1024m-for-the-virtual-machine-node-the-default-unit-is-m)
  - [6.6. Change the cpu number to 2 for a virtual machine node](#66-change-the-cpu-number-to-2-for-a-virtual-machine-node)
- [7\. Remove a virtual machine node](#7%5C-remove-a-virtual-machine-node)
  - [7.1. Remove the virtual machine vm1 but keep the related files of the vm1](#71-remove-the-virtual-machine-vm1-but-keep-the-related-files-of-the-vm1)
  - [7.2 Remove a virtual machine node and related files permanently](#72-remove-a-virtual-machine-node-and-related-files-permanently)
- [8\. Clone a virtual machine node](#8%5C-clone-a-virtual-machine-node)
  - [8.1 Create a vmmaster](#81-create-a-vmmaster)
  - [8.2 Clone two new virtual machine nodes from vmmaster vmm1](#82-clone-two-new-virtual-machine-nodes-from-vmmaster-vmm1)
- [9\. Install a virtual machine node](#9%5C-install-a-virtual-machine-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**This page has been replaced by [XCAT_Virtualization_with_VMWare].**


## 1\. Background

ESXi is a “bare-metal” hypervisor architecture which can be used to create and manage the virtual machines. A “bare-metal” server which installed ESXi will be a host machine of virtual machines. A host machine can be used to create, remove and modify the virtual machine. For xCAT to manage the ESXi virtual machine, the ESXi has to be installed on a server first, and then use the ESXi to create the virtual machines. Base on the virtual machine, the Operating System can be deployed on the virtual machine. 

## 2\. Install the vmware sdk

xCAT manages the vmware virtual machines through the vmware sdk, so the vmware sdk must be installed first before running the virtual machines management commands. 

### 2.1. Download the vmware sdk

The vmware sdk can be downloaded from following page: http://communities.vmware.com/community/developer/forums/vsphere_sdk_perl For Linux, the name of vmware sdk tar ball looks like:VMware-vSphere-Perl-SDK-4.1.0-254719.x86_64.tar.gz 

### 2.2. Uncompress the vmware sdk tar ball
    
    	gunzip VMware-vSphere-Perl-SDK-4.1.0-254719.x86_64.tar.gz
    

tar xvf VMware-vSphere-Perl-SDK-4.1.0-254719.x86_64.tar 

### 2.3. Install the vmware sdk

cd vmware-vsphere-cli-distrib/ ./vmware-install.pl 

### 2.4. Check the installation

After the installation, you can find more tools and perl modules in the directory /usr/lib/vmware-vcli. 

## 3\. Install the ESXi

Note: There are some hardware that are NOT supported by ESXi. For these kinds of hardware, the installation process will hang at loading install.vgz. The error message is “module install.vgz: MBI-0x00010018, entry=0x004024a”. 

### 3.1. Download the ESXi iso from vmware web site. (In this document, the ESXi4.1 will be used as an example)

For evaluation, a no cost version of ESXi can be downloaded from the vmware web site: https://www.vmware.com/tryvmware/index.php?p=free-esxi&amp;lp=1 

### 3.2. Run copycds command to copy the ESXi files into the xCAT installation directory

copycds VMware-VMvisor-Installer-4.1.0-260247.x86_64.iso Then the ESXi (esxi4.1) directory will be created in the installation directory (default is /install). 

### 3.3. Define the node as ESXi host (The node name is esxihost)

Define the node as a common xCAT node. Following two attributes need to be set correctly: chdef esxihost os=esxi4.1 chdef esxihost profile=base 

### 3.4. Add the vmware entry in the passwd table

chtab key=vmware passwd.username="root" passwd.password="cluster" 

### 3.5. Run xCAT command to prepare and install the esxihost node

makedhcp esxihost makedns esxihost nodeset esxihost install rpower esxihost reset 

### 3.6. Check the installation result

After the installation, the ssh connection can be used to login the esxihost. From the web browser, you can use the https://esxihost/mob to login the host machine. (The user and password are root:cluster) 

## 4\. Define the virtual machines base on the ESXi host

### 4.1. Define a virtual machine node (The node name is vm1)

The virtual machine can be defined as a common xCAT node. The ‘mgt’ attribute should be set to ‘esx’: chdef vm1 mgt=esx The ‘vmhost’ attribute should be set to the host machine - esxihost which was installed earlier. chdef vm1 vmhost=esxihost 

### 4.2. Define the vmstorage attribute for the virtual machine node

There are two storage types can be supported by the svmstorage attribute: the NFS storage and VMFS storage. For each storage type, the storage model can be set by vmstoragemodel attribute. The storage model can be "ide" or "scsi". The "ide" is the default model. 

#### 4.2.1. Use the NFS type of storage

For example: the nfs server is 192.168.0.1, and the storage directory is /vms/vmware. Then the format of svmstorage value is “nfs://192.168.0.1/vms/vmware”. The storage directory “/vms/vmware” also should be added into the /etc/exports so that the nfs service can be ready after the reboot. chdef vm1 vmstorage=nfs://192.168.0.1/vms/vmware 

#### 4.2.2. Use the VMFS type of storage

A default data storage named datastore1 will be created for a ESXi host machine automatically. The datastore1 located at /vmfs/volumes/datastore1 on the host node (esxihost). The format of svmstorage value is “vmfs://datastore1” chdef vm1 vmstorage=vmfs://datastore1 

### 4.3. Define the vmnics attribute for a virtual machine node

The vmnics (The network of virtual machine) for a virtual machine must be set, so that the virtual switch and vlan can be created for the network and then the mac address will be created for the virtual machine. The value of vmnics attribute can be a common string, or it can be the "trunk", "vlanxx" (xx is the vlan number) to specify the vlan information for the network. The multiple networks can be set in the vmnics with comma split. The type of vmnics also can be set by the vmnicnicmodel attribute. The supported type includes: vmxnet3, e1000, pcnet32, vmxnet2, vmxnet. 

There are several ways to generate the mac address for a virtual machine. a. If mac attribute for the virtual machine node was not set and genmacprefix attribute in the site table was not set. Then a local mac address will be generated by random. b. If the mac address was set manually in the mac attribute for a virtual machine node. (The value of mac attribute can have multiple mac addresses with ‘|’ split) Then xCAT will get the mac address for each network card from the mac attribute for the virtual machine node when creating the virtual machine. c. Set the genmacprefix attribute in the site table as the prefix to generate the mac address. This prefix should have three bytes, the left three bytes of mac address will be generated by random. If the prefix is set to "00:50:56", then a vmware reversed mac address will be generated 

### 4.4. An example of virtual machine node which has been defined correctly

  1. lsdef vm1 

Object name: vm1 
    
       arch=x86_64
       groups=vmware,vm,all
       mac=1a:b5:c0:a8:05:ca
       mgt=esx
       netboot=pxe
       os=fedora13
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles,otherpkgs
       primarynic=eth0
       profile=compute
       serialport=0
       serialspeed=115200
       vmhost=esxihost
       vmnics=vmn0
       vmstorage=vmfs://datastore1
    

## 5\. Create a virtual machine node

The mkvm command can be used to create a virtual machine. There is a option ‘-s’ can be used to specify the disk size for the new created virtual machine. mkvm vm1 -s 4G 

When the vm1 is created successfully, the files of virtual machine can be found in the data storage location. If the storage type is NFS, the files for virtual machine vm1 can be found in the nfs://192.168.0.1/vms/vmware/vm1. If the storage type if VMFS, the files of virtual machine vm1 can be found in the exsihost: /vmfs/volumes/datastore1/vm1 

The lsvm command can be used to display the virtual machines which created in the vmware host machine. Display the virtual machine nodes which created on esxihost: lsvm esxihost 

## 6\. Change the definition of a virtual machine node

As default, the mkvm will create a virtual machine which has 1 cpu, 1 harddisk and 512M memory. The chvm command can be used to change the definition of the virtual machine after the virual machine has been created by the mkvm command. Note: Use the chvm command to change the "ide" modle of hard disk can only be run when the virtual machine node is in power off state. 

### 6.1. Add another hard disk with 2G size. After the running of chvm, you can find two new .vmdk files were created for the new hard disk.

chvm vm1 -a 2 

### 6.2. Use the rinv command to display the hard disk that created for a virtual machine node:

rinv vm1 The output has following two lines: (The first hard disk was created when running the mkvm; The second hard disk was created by the chvm command) vm3: Hard disk 1 (d200:0): 4096 MB @ [datastore1] vm3/vm3.vmdk vm3: Hard disk 2 (d200:1): 2048 MB @ [datastore1] vm3/vm3_1.vmdk 

### 6.3. Remove a hard disk from a virtual machine node but keep the storage files.

The output from rinv command for hard disk can be used to specify the hard disk path for chvm command. For example, the output of rinv is “vm3: Hard disk 2 (d200:1): 2048 MB @ [datastore1] vm3/vm3_1.vmdk”, then the “Hard disk 2” or “d200:1” can be used as the hard disk path. chvm vm1 -d "Hard disk 2" 

### 6.4. Remove a hard disk permanently from a virtual machine node

chvm vm1 -p "Hard disk 2" 

### 6.5. Change the memory size to 1024M for the virtual machine node (The default unit is M)

chvm vm1 --mem 1024 

### 6.6. Change the cpu number to 2 for a virtual machine node

chvm vm3 --cpus 2 

## 7\. Remove a virtual machine node

The rmvm command can be used to remove a virtual machine from the vmware host machine. 

### 7.1. Remove the virtual machine vm1 but keep the related files of the vm1

rmvm vm1 This action just deregister the virtual machine from the host machine, when you try to recreate this virtual machine, the old virtual machine files will be reused. If you want to reset some attribute of a virtual machine and try to recreate, the ‘rmvm vm1 -p’ should be used. 

### 7.2 Remove a virtual machine node and related files permanently

rmvm vm1 -p 

## 8\. Clone a virtual machine node

The clonevm command can be used to create a vmmaster from a virtual machine or clone new virtual machines from a vmmaster. (vmmaster means virtual machine master, which is a special virtual machine that can be a model for new virtual machine to clone from) Note: Presently, only the NFS type of storage can be used for the vmmaster or new cloned virtual machines. 

### 8.1 Create a vmmaster

If you have a virtual machine vm1 which has been deployed Operating System and application has been install and configured, then it's time to create a vmmaster to keep the vm1 in current state to be a model for new virtual machine creating. If you want to create a vmmaster named vmm at nfs://192.168.0.1/vms/vmware/, the target parameter should be nfs://192.168.0.1/vms/vmware/vmm. Note: Only one vmmaster can be created in one clonevm command. clonevm vm1 -t nfs://192.168.0.1/vms/vmware/vmm 

### 8.2 Clone two new virtual machine nodes from vmmaster vmm1

If there is a vmmaster named vmm, then multiple virtual machine nodes can be created from it. clonevm -b vmm vm2,vm3 

  


## 9\. Install a virtual machine node

By default, the network is the first boot order for a virtual machine. You also can use the rsetboot command to change the boot order. Note: The stat action is not supported for rsetboot. rsetboot vm1 net,hd 

Prepare and install the virtual machine node vm1. makedhcp vm1 (If vm1 has IP defined in /etc/hosts. Otherwise, set a dynamicrange IP in the dhcp configuration of management node for the virtual machines) nodeset vm1 install (For diskfull installation) nodeset vm1 netboot (For diskless netboot) rpower vm1 reset 
