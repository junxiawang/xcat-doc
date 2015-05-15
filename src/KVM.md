<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [The example that used in this document](#the-example-that-used-in-this-document)
- [Setup the Management Server for kvm](#setup-the-management-server-for-kvm)
  - [**Check the ability of the kvm hypervisor machine**](#check-the-ability-of-the-kvm-hypervisor-machine)
  - [**Setup the kvm storage directory on the management node**](#setup-the-kvm-storage-directory-on-the-management-node)
  - [**Export the storage directory**](#export-the-storage-directory)
  - [**Install the kvm related packages**](#install-the-kvm-related-packages)
- [**Install the kvm hypervisor**](#install-the-kvm-hypervisor)
  - [**Add the kvm related packages**](#add-the-kvm-related-packages)
  - [**Modify the post install scripts**](#modify-the-post-install-scripts)
  - [**Export shared directory (Optional, you can work around it if you create the images your** self)](#export-shared-directory-optional-you-can-work-around-it-if-you-create-the-images-your-self)
  - [Install the kvm hypervisor node](#install-the-kvm-hypervisor-node)
- [Enable the kvm hypervisor on an existed node. (e.g. on redhat 6 node)](#enable-the-kvm-hypervisor-on-an-existed-node-eg-on-redhat-6-node)
  - [**Install the perl-Sys-Virt on the management node mn**1](#install-the-perl-sys-virt-on-the-management-node-mn1)
  - [**Install the libvirt and qemu-kvm on the kvmhost**1](#install-the-libvirt-and-qemu-kvm-on-the-kvmhost1)
  - [**Rerun the postscript mkhyperv to setup the kvm host**](#rerun-the-postscript-mkhyperv-to-setup-the-kvm-host)
- [Create and Install Virtual Machines](#create-and-install-virtual-machines)
  - [**Define virtual machines**](#define-virtual-machines)
  - [**Define the attributes of virtual machine**](#define-the-attributes-of-virtual-machine)
  - [**Define the console attributes for the virtual machine**](#define-the-console-attributes-for-the-virtual-machine)
- [At last, the definition of kvm1 should looks like following](#at-last-the-definition-of-kvm1-should-looks-like-following)
  - [**Create the virtual machine**](#create-the-virtual-machine)
  - [**Try to power on the kvm1**](#try-to-power-on-the-kvm1)
  - [**Remove a virtual machine (Optional)**](#remove-a-virtual-machine-optional)
  - [**You are able to look at the node in rcons/wcons**](#you-are-able-to-look-at-the-node-in-rconswcons)
- [**Installation the virtual machine kvm1**](#installation-the-virtual-machine-kvm1)
- [**Clone a kvm node**](#clone-a-kvm-node)
  - [**In attaching mode**](#in-attaching-mode)
  - [**In detaching mode**](#in-detaching-mode)
- [Possible Errors](#possible-errors)
  - [**libvirtd run into problem**](#libvirtd-run-into-problem)
  - [**Virtual disk has problem**](#virtual-disk-has-problem)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**This page has been replaced by [XCAT_Virtualization_with_KVM].**


## Introduction

The Kernel-based Virtual Machine (KVM) is the way forward for virtualization technology for Enterprise Linux distributions. For this reason we recommend KVM over other open source technologies like Xen (Although there is support for Xen in xCAT)  
KVM is included in RedHat 5 as well as SLES 11 and later version. KVM is included in the Linux kernel as of 2.6.20 . The xCAT based KVM solution offers users the ability to:  
\- provision bare metal hypervisors  
\- provision virtual machines  
\- migrate virtual machines to different hosts  
\- install all versions of Linux supported in the standard xCAT provisioning methods (you can install stateless virtual machines, iSCSI, and even regular virtual machines)  
\- copy on write instances of virtual machines  
\- copy virtual machines  
For best use with xCAT our architecture has the following components:  
1\. A shared file system for hosting virtual machines. This should be the same directory for all nodes. Having this shared file system (which we recommend be on a SAN, NAS or GPFS allows us migrate nodes from ).  
2\. xCAT gPXE boot and KVM that comes packaged in the xCAT-deps distribution. This has updated KVM support that plugs nicely into xCAT  
3\. RedHat or CentOS 5.3 or greater. 

## The example that used in this document
    
    One management node: mn1
    
    One kvm hypervisor machine: kvmhost1

(In this article, the kvm host is equal to kvm hypervisor) 
    
    One virtual machine: kvm1,kvm2 ... 
    
    One virtal machine master: kvmm,kvmmd
    
    Operating System: rh6

(Redhat 6 has a good support on kvm and xCAT has a good support on rh6 for kvm. So the rh6 is recommended as the kvm hypervisor. This article also has some sections to describe how to set up kvm on an older Linux distribution like rh5 or CentOS5.) 

## Setup the Management Server for kvm

### **Check the ability of the kvm hypervisor machine**

To run KVM you need a newer Intel or AMD processor with virtualization technology. (Intel VT or AMD-V).  
Following command can be run to check whether the kvm is supported by a machine. If it has output, that means it has the ability.  

    
    # egrep "flags.*:.*(svm|vmx)" /proc/cpuinfo

### **Setup the kvm storage directory on the management node**

The easiest way to get up and running is to use the /install directory and share it out via NFS to the other hypervisors in the node farm. That is what we'll do in the example.  
Create a directory to store the virtual disk files.  

    
    # mkdir -p /install/vms

### **Export the storage directory**

Note: make sure the root permission should be turn on for the nfs client. Otherwise, the virtual disk file can NOT be used correctly.  

    
    # echo "/install/vms *(rw,no_root_squash,sync)" &gt;&gt;/etc/exports
    # exportfs -r

### **Install the kvm related packages**

Additional packages need to installed on the management node for kvm support:  

    
    # yum -y install iscsi-initiator-utils bridge-utils kvm perl-Sys-Virt

For rh5 and CentOS5, make sure that when you install these packages that the kvm is taken from the xCAT dependencies directory instead of from the operating system directory. Make sure that the kvm RPM is equal or greater than kvm-85-1. 

## **Install the kvm hypervisor**

xCAT distributes some templates for the kvm hypervisor. For Redhat OS, you can get them here: /opt/xcat/share/xcat/install/rh/kvm.* from the management node. 

### **Add the kvm related packages**

xCAT uses the *.pkglist to specify the packages that need to be installed for a new node. The *.pkglist for the rh6 has already been created at /opt/xcat/share/xcat/install/rh/kvm.rhel6.pkglist. That means if you want to install rh6 as the OS for the kvmhost1, ignore this step.  
For a specific OS like CentOS, you can create a new .pkglist for it. 
    
    # mkdir /install/custom/install/centos/ 
    # cp /opt/xcat/share/xcat/install/rh/kvm.pkglist  \
    /install/custom/install/centos/

Add the following packages name in it. 
    
    bridge-utils
    dnsmasq
    iscsi-initiator-utils
    kvm
    perl-Sys-Virt
    libvirt.x86_64
    gpxe-kvm

Note: If some packages need to be installed from the xCAT dependency packages, use the otherpkgs mechanism to install them. Or you can install them manually after the installation.  


### **Modify the post install scripts**

xCAT has a postscript named mkhyperv (MN:/install/postscript/mkhyperv) which can be used to initialize the kvm hypervisor during the installation process. This script will help to create a network bridge on the kvm hypervisor, load the necessary kernel modules, start up the libvirtd daemon.&lt;/br&gt; Add this postscript for your kvm hypervisor node: 
    
    # chdef kvmhost1 -p postscripts.postscripts=mkhyperv

### **Export shared directory (Optional, you can work around it if you create the images your** self)

To run the xCAT commands to create virtual machines, the nodes and the management server require a shared file system viewable in the same directory. An easy way to do this is to create another post install script to mount this directory. We made one and called it mountvms: 
    
    #!/bin/sh
    logger -t xcat "Install: setting vms mount in fstab"
    mkdir -p /install/vms
    echo "$MASTER:/install/vms /install/vms nfs rsize=8192,wsize=8192,timeo=14,intr,nfsvers=2 1 2" &gt;&gt;/etc/fstab

The above script just creates a directory called /install/vms and then mounts this from the management server. If you have a file or another storage device where you want all your virtual machines to go, then you can change the scripts according to your needs. 
    
    # chmod 755 mountvms
    # chdef x01 -p postscripts.postscripts=mountvms

### Install the kvm hypervisor node

Just install it as a common node.  

    
    # rinstall x01 -o &lt;os&gt; -a x86_64 -p kvm

When finished with the node you can ssh to it an verify it was setup correctly by running: 
    
    # brctl show

then you can get the bridge information like following: 
    
    bridge name     bridge id               STP enabled     interfaces
    br0             8000.001a646002a4       no              eth0

  
When you run the ifconfig command you'll have a br0 interface: 
    
    # ifconfig
    br0 Link encap:Ethernet HWaddr 00:14:5E:55:5B:AC
    inet addr:192.168.15.72 Bcast:192.168.15.255 Mask:255.255.255.0
    inet6 addr: fe80::214:5eff:fe55:5bac/64 Scope:Link
    UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
    RX packets:1930 errors:0 dropped:0 overruns:0 frame:0
    TX packets:846 errors:0 dropped:0 overruns:0 carrier:0
    collisions:0 txqueuelen:0
    RX bytes:166778 (162.8 KiB) TX bytes:95512 (93.2 KiB)
    
    eth0 Link encap:Ethernet HWaddr 00:14:5E:55:5B:AC
    inet6 addr: fe80::214:5eff:fe55:5bac/64 Scope:Link
    UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
    RX packets:5072 errors:0 dropped:0 overruns:0 frame:0
    TX packets:1160 errors:0 dropped:0 overruns:0 carrier:0
    collisions:0 txqueuelen:1000
    RX bytes:412342 (402.6 KiB) TX bytes:132939 (129.8 KiB)
    Interrupt:66
    
    lo Link encap:Local Loopback
    inet addr:127.0.0.1 Mask:255.0.0.0
    inet6 addr: ::1/128 Scope:Host
    UP LOOPBACK RUNNING MTU:16436 Metric:1
    RX packets:56 errors:0 dropped:0 overruns:0 frame:0
    TX packets:56 errors:0 dropped:0 overruns:0 carrier:0
    collisions:0 txqueuelen:0
    RX bytes:6151 (6.0 KiB) TX bytes:6151 (6.0 KiB)

If you don't have that, it probably that you didn't use the xCAT post install script. You can hack it together quickly by running: 
    
    IPADDR=172.20.1.19/16
    brctl addif vlan1 eth0
    brctl addbr vlan1
    brctl setfd vlan1 0
    ip addr add dev vlan1 $IPADDR
    brctl addif vlan1 eth0
    ip link set vlan1 up
    ip addr del dev eth0 $IPADDR

You also can try to rerun the postscript mkhyperv by updatenode command to fix the kvm hypervisor setup problem. 
    
    # updatenode kvmhost1 -P mkhyperv

## Enable the kvm hypervisor on an existed node. (e.g. on redhat 6 node)

### **Install the perl-Sys-Virt on the management node mn**1
    
    # yum install perl-Sys-Virt.x86_64

### **Install the libvirt and qemu-kvm on the kvmhost**1
    
    # yum install libvirt.x86_64 qemu-kvm.x86_64

### **Rerun the postscript mkhyperv to setup the kvm host**
    
    # updatenode kvmhost1 -P mkhyperv

## Create and Install Virtual Machines

After the installing and configuring of kvm hypervisor, you can start to create the virtual machine and deploy OS on it. 

### **Define virtual machines**

The virtual machine kvm1 will be defined. First to add following entry in /etc/hosts: 
    
    192.168.0.10 kvm1

Then add it to xCAT under the vm group: 
    
    # nodeadd kvm1 groups=kvm,vm,all

Next, update DNS with this new node: 
    
    # makedns
    # service named restart

### **Define the attributes of virtual machine**

Run the chdef command to change the following attributes for the kvm1: 

  * Define the virtual cpu number 


~~~~    
    # chdef kvm1 vmcpus=2 
~~~~

  * Define the kvm host of the virtual machine kvm1, it should be set to kvmhost1 

~~~~
    
    # chdef kvm1 vmhost=kvmhost1 
~~~~

  * Define the virtual memory size, the unit is Megabit 

Define 1M memory to the kvm1:  

 
~~~~   
    # chdef kvm1 vmmemory=1024 
~~~~

  * Define the virtual network card, it should be set to the bridge br0 which defined above) 
    
~~~~
    # chdef kvm1 vmnics=br0 
~~~~

  * Define the storage for the kvm1 

The default format is 'nfs://&lt;IP&gt;/dir', that means the kvm disk files will be created at 'nfs://&lt;IP&gt;/dir'. 
    
~~~~
    # chdef kvm1 vmstorage=nfs://<IP of MN>/install/vms/ 
~~~~
  
Note: The mac address will be created automatically when running the mkvm if you leave it empty. You also can specify it manually before running the mkvm, and then the specified mac address will be used for the kvm1. 

### **Define the console attributes for the virtual machine**
    
    # chdef kvm1 serialport=0 serialspeed=115200 

## At last, the definition of kvm1 should looks like following
    
    Object name: kvm1
        arch=x86_64
        groups=kvm,vm,all
        mgt=kvm
        netboot=pxe
        os=rhels6
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles,otherpkgs
        primarynic=eth0
        profile=compute
        serialport=0
        serialspeed=115200
        vmcpus=1
        vmhost=kvmhost1
        vmmemory=1024
        vmnics=br0
        vmstorage=nfs://192.168.5.73/install/vms
    

### **Create the virtual machine**

Create the virtual machine kvm1 with 20G hard disk. &lt;/br&gt;
    
    # mkvm kvm1 -s 20G

If the kvm1 was created successfully, a hard disk file named kvm1.hda.qcow2 can be found in nfs://192.168.5.73/install/vms. And you can run the lsdef kvm1 to see whether the mac attribute has been set automatically. 

Run the lsvm command to list the virtual machines on the kvm hypervisor. 
    
    # lsvm kvmhost1
        kvmhost1: kvm1 

### **Try to power on the kvm1**
    
    # rpower kvm1 on

If the kvm1 was powered on successfully, you can get following information when running 'virsh list' on the kvm host kvmhost1. 
    
    # virsh list
     Id Name                 State
    
    
    * * *
    
    
      6 kvm1                 running
    

### **Remove a virtual machine (Optional)**

Remove the kvm1 even when it is in power on status. 
    
    # rmvm kmv1 -f

Remove the definition of kvm and related storage. 
    
    # rmvm kvm1 -p

### **You are able to look at the node in rcons/wcons**
    
    # makeconservercf kvm1
    # wcons kvm1

Now, have a look as it boots up, you'll see it got the xCAT standby kernel! 

  


## **Installation the virtual machine kvm1**

Now, you get a node which is ready to be installed. So, from here you can just install the kvm1 as a normal node. 
    
    # rinstall kvm1

Then the node will automatically reboot and install. You'll have a normal node! 

  


## **Clone a kvm node**

Clone is a concept that create a new node from the old one by reuse most of data that has been installed on the old node. Before creating a new node, a vm (virtual machine) master must be created first. The new node will be created from the vm master. The new node can attach to the vm master or not.   
The node can NOT be run without the vm master if choosing to make the node attach to the vm master. The advantage is that the less disk space is needed.  


### **In attaching mode**

In this mode, all the nodes will be attached to the vm master. Lesser disk space will be used than the general node.  
Create the vm master kvmm from a node (kvm2) and make the original node kvm2 attaches to the new created vm master:  

    
    # clonevm kvm2 -t kvmm
    kvm2: Cloning kvm2.hda.qcow2 (currently is 1050.6640625 MB and has a capacity of 4096MB)
    kvm2: Cloning of kvm2.hda.qcow2 complete (clone uses 1006.74609375 for a disk size of 4096MB)
    kvm2: Rebasing kvm2.hda.qcow2 from master
    kvm2: Rebased kvm2.hda.qcow2 from master

After the performing, you can see the following entry has been added into the vmmaster table. 
    
    #name,os,arch,profile,storage,storagemodel,nics,vintage,originator,comments,disable
    "kvmm","rhels6","x86_64","compute","nfs://192.168.5.73/vms/kvm",,"br0","Tue Nov 23 04:18:17 2010","root",,

Clone a new node kvm4 from vm master kvmm: 
    
    clonevm kvm4 -b kvmm

### **In detaching mode**

Create a vm master that the original node detaches with the created vm master. 
    
    # clonevm kvm2 -t kvmmd -d
    kvm2: Cloning kvm2.hda.qcow2 (currently is 1049.4765625 MB and has a capacity of 4096MB)
    kvm2: Cloning of kvm2.hda.qcow2 complete (clone uses 1042.21875 for a disk size of 4096MB)

Clone the kvm3 from the kvmmd with the detaching mode turn on: 
    
    clonevm kvm3 -b kvmmd -d
    kvm3: Cloning kvmmd.hda.qcow2 (currently is 1042.21875 MB and has a capacity of 4096MB)

  


## Possible Errors

### **libvirtd run into problem**

One error we saw on occasion was the following message: 
    
    # rpower kvm1 on
    kvm1: internal error no supported architecture for os type 'hvm'

This error was fixed by restarting libvirtd on the host machine 
    
    # xdsh kvmhost1 service libvirtd restart

Note: In any case that you find there is libvirtd error message in syslog, you can try to restart the libvirtd. 

### **Virtual disk has problem**

When running command 'rpower kvm1 on', get the following error message: 
    
    kvm1: Error: unable to set user and group to '0:0' on '/var/lib/xcat/pools/27f1df4b-e6cb-5ed2-42f2-9ef7bdd5f00f/kvm1.hda.qcow2': Invalid argument:

Solution: try to figure out the nfs:// server was exported correctly. The nfs client should have root authority. 
