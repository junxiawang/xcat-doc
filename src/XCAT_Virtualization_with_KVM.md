<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [The Example Used Thoughout This Document](#the-example-used-thoughout-this-document)
- [Set Up the Management Server for KVM](#set-up-the-management-server-for-kvm)
  - [**Check the ability of the kvm hypervisor node**](#check-the-ability-of-the-kvm-hypervisor-node)
  - [**Set Up the kvm storage directory on the management node**](#set-up-the-kvm-storage-directory-on-the-management-node)
  - [**Export the storage directory**](#export-the-storage-directory)
  - [**Install the kvm related packages**](#install-the-kvm-related-packages)
- [**Install the kvm hypervisor**](#install-the-kvm-hypervisor)
  - [**Add the kvm related packages**](#add-the-kvm-related-packages)
  - [**Add a postscript to create network bridge on the kvm host**](#add-a-postscript-to-create-network-bridge-on-the-kvm-host)
  - [**Export shared directory (Optional, you can work around it if you create the images by yourself)**](#export-shared-directory-optional-you-can-work-around-it-if-you-create-the-images-by-yourself)
  - [**Install the kvm hypervisor node**](#install-the-kvm-hypervisor-node)
- [Enable the kvm hypervisor on an existed node. (e.g. on redhat 6 node)](#enable-the-kvm-hypervisor-on-an-existed-node-eg-on-redhat-6-node)
  - [**Install the perl-Sys-Virt on the management node mn**1](#install-the-perl-sys-virt-on-the-management-node-mn1)
  - [**Install the libvirt and qemu-kvm on the target node kvmhost**1](#install-the-libvirt-and-qemu-kvm-on-the-target-node-kvmhost1)
  - [**Rerun the postscript mkhyperv from the management node to setup the kvm host**](#rerun-the-postscript-mkhyperv-from-the-management-node-to-setup-the-kvm-host)
- [Create and Install Virtual Machines](#create-and-install-virtual-machines)
  - [**Define virtual machines**](#define-virtual-machines)
  - [**Define the attributes of virtual machine**](#define-the-attributes-of-virtual-machine)
  - [**Define the console attributes for the virtual machine**](#define-the-console-attributes-for-the-virtual-machine)
- [In the end, the definition of kvm1 should look (more or less) like this](#in-the-end-the-definition-of-kvm1-should-look-more-or-less-like-this)
  - [**Create the virtual machine**](#create-the-virtual-machine)
  - [**Try to power on the kvm1**](#try-to-power-on-the-kvm1)
  - [**Remove a virtual machine (Optional)**](#remove-a-virtual-machine-optional)
  - [**You are able to look at the node in rcons/wcons**](#you-are-able-to-look-at-the-node-in-rconswcons)
- [**Installing the virtual machine kvm1**](#installing-the-virtual-machine-kvm1)
- [**Connecting to the virtual machine's vnc console**](#connecting-to-the-virtual-machines-vnc-console)
- [**Setting up a network bridge**](#setting-up-a-network-bridge)
- [**Clone a kvm node**](#clone-a-kvm-node)
  - [**In attaching mode**](#in-attaching-mode)
  - [**In detaching mode**](#in-detaching-mode)
- [FAQ](#faq)
  - [**libvirtd run into problem**](#libvirtd-run-into-problem)
  - [**Virtual disk has problem**](#virtual-disk-has-problem)
  - [**VNC client complains the credentials are not valid**](#vnc-client-complains-the-credentials-are-not-valid)
  - [**rpower fails with "qemu: could not open disk image /var/lib/xcat/pools/2e66895a-e09a-53d5-74d3-eccdd9746eb5/vmXYZ.hda.qcow2: Permission denied" error message**](#rpower-fails-with-qemu-could-not-open-disk-image-varlibxcatpools2e66895a-e09a-53d5-74d3-eccdd9746eb5vmxyzhdaqcow2-permission-denied-error-message)
  - [** Error: Cannot communicate via libvirt to &lt;host&gt; **](#-error-cannot-communicate-via-libvirt-to-&lthost&gt-)
  - [Cannot ping to the vm after the first boot of stateful install](#cannot-ping-to-the-vm-after-the-first-boot-of-stateful-install)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Introduction

The Kernel-based Virtual Machine (KVM) is the way forward for virtualization technology for Enterprise Linux distributions. For this reason we recommend KVM over other open source technologies like Xen (Although there is support for Xen in xCAT) 

KVM is included in RHEL 6 and SLES 11 (and later versions). **KVM was also available in RHEL 5, but not as stable, so we don't recommend using it in RHEL 5.** KVM is included in the Linux kernel as of 2.6.20 . The xCAT based KVM solution offers users the ability to: 

  * provision the hypervisor on bare metal nodes 
  * provision virtual machines 
  * migrate virtual machines to different hosts 
  * install all versions of Linux supported in the standard xCAT provisioning methods (you can install stateless virtual machines, iSCSI, and scripted install virtual machines) 
  * install copy on write instances of virtual machines 
  * copy virtual machines 

For the best KVM experience with xCAT, use the following components: 

  1. A shared file system for hosting virtual machines. This should be the same directory for all nodes. Having this shared file system (which we recommend be on a SAN, NAS or GPFS) allows xCAT to migrate VMs from one hypervisor to another. 
  2. xnba gPXE bootloader and xnba KVM bootloader that comes packaged in the xcat-dep tarball. This has updated KVM support that plugs nicely into xCAT. 

## The Example Used Thoughout This Document

The following example node names are used in the rest of this document: 

  * One management node: mn1 
  * One kvm hypervisor machine: kvmhost1 (In this document, "kvm host" and "kvm hypervisor" mean the same thing.) 
  * Virtual machines: kvm1, kvm2 ... 
  * Virtual machine master: kvmm, kvmmd 
  * Operating System: rhel 6 (RHEL 6 has good support for kvm and xCAT has good support for rhel 6 for kvm, so if you have flexibility in your distro choice, we recommended using rhel 6 as the kvm hypervisor.) 

## Set Up the Management Server for KVM

### **Check the ability of the kvm hypervisor node**

To run KVM you need a newer Intel or AMD processor with virtualization technology. (Intel VT or AMD-V). Run this command on the node to check whether kvm will be supported by the machine. If it has output, that means it has the capability: 
 
~~~~   
    egrep "flags.*:.*(svm|vmx)" /proc/cpuinfo
~~~~ 

### **Set Up the kvm storage directory on the management node**

The easiest method is to use the /install directory as the kvm storage directory and share it via NFS to the hypervisors. That is what we'll do in this example. 

Create a directory to store the virtual disk files: 
 
~~~~    
    mkdir -p /install/vms
~~~~ 

### **Export the storage directory**

Note: make sure the root permission is turned on for the nfs clients (i.e. use the no_root_squash option). Otherwise, the virtual disk file can **not** be used correctly. The option 'fsid=0' is useful for nfsv4: 

~~~~     
    echo "/install/vms *(rw,no_root_squash,sync,fsid=0)" &gt;&gt;/etc/exports
    exportfs -r
~~~~ 

### **Install the kvm related packages**

Additional packages need to be installed on the management node for kvm support: 

~~~~     
    yum -y install iscsi-initiator-utils bridge-utils kvm perl-Sys-Virt
~~~~ 

For rh5 and CentOS5, make sure that when you install these packages that the kvm is taken from the xCAT dependencies directory instead of from the operating system directory. Make sure that the kvm RPM version is greater than or equal to kvm-85-1. 

## **Install the kvm hypervisor**

xCAT distributes some templates for the kvm hypervisor. For Redhat OS, you can get them here: /opt/xcat/share/xcat/install/rh/kvm.* from the management node. 

### **Add the kvm related packages**

xCAT uses the *.pkglist to specify the packages that need to be installed for a new node. The *.pkglist for the rh6 has already been created at /opt/xcat/share/xcat/install/rh/kvm.rhel6.pkglist. That means if you want to install rh6 as the OS for the kvmhost1, ignore this step.  
For a specific OS like CentOS, you can create a new .pkglist for it. 

~~~~     
    mkdir /install/custom/install/centos/ 
    cp /opt/xcat/share/xcat/install/rh/kvm.pkglist  \
    /install/custom/install/centos/
~~~~ 

Add the following packages name in it. 

~~~~     
    bridge-utils
    dnsmasq
    iscsi-initiator-utils
    kvm
    perl-Sys-Virt
    libvirt.x86_64
    gpxe-kvm
~~~~ 

Note: If some packages need to be installed from the xCAT dependency packages, use the otherpkgs mechanism to install them. Or you can install them manually after the installation.  


### **Add a postscript to create network bridge on the kvm host**

xCAT supplies a postscript named xHRM (MN:/install/postscript/xHRM) to create the network bridge for the kvm host during the installation or netbooting process. There are several parameters can be passed for this postscript to specify the target network device that the bridge created to. 

Add this postscript to your kvm host node: 

  * create a bridge with default name 'default' against the installation network device which was specified by 'installnic' attribute 
 
~~~~    
    chdef kvmhost1 -p postscripts="xHRM bridgeprereq"
~~~~ 

  * create a bridge named 'virbr0' against the installation network device which was specified by 'installnic' attribute 
 
~~~~    
    chdef kvmhost1 -p postscripts="xHRM bridgeprereq virbr0"
~~~~ 

  * create a bridge named 'virbr0' against the network device 'eth0' 

~~~~     
    chdef kvmhost1 -p postscripts="xHRM bridgeprereq eth0:virbr0"
~~~~ 

### **Export shared directory (Optional, you can work around it if you create the images by yourself)**

To run the xCAT commands to create virtual machines, the nodes and the management server require a shared file system viewable in the same directory. An easy way to do this is to create another post install script to mount this directory. We made one and called it mountvms: 
    
~~~~ 
    logger -t xcat "Install: setting vms mount in fstab"
    mkdir -p /install/vms
    echo "$MASTER:/install/vms /install/vms nfs \
      rsize=8192,wsize=8192,timeo=14,intr,nfsvers=2 1 2" >> /etc/fstab

~~~~ 

The above script just creates a directory called /install/vms and then mounts this from the management server. If you have a file or another storage device where you want all your virtual machines to go, then you can change the scripts according to your needs. 
 
~~~~    
    chmod 755 mountvms
    chdef x01 -p postscripts=mountvms
~~~~ 

### **Install the kvm hypervisor node**

Just install it as a common node.  

~~~~     
    nodeset kvmhost1 osimage=rhels6.2-x86_64-install-kvm
    rpower kvmhost1 boot
~~~~ 

When finished with the node you can ssh to it an verify it was setup correctly by running: 
    
    # brctl show

then you can get the bridge information like following: 

~~~~     
    bridge name     bridge id               STP enabled     interfaces
    br0             8000.001a646002a4       no              eth0
~~~~ 
  
When you run the ifconfig command you'll have a br0 interface: 

~~~~     
    ifconfig
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
    inet6 addr: ::1/128 Scope:Host
    UP LOOPBACK RUNNING MTU:16436 Metric:1
    RX packets:56 errors:0 dropped:0 overruns:0 frame:0
    TX packets:56 errors:0 dropped:0 overruns:0 carrier:0
    collisions:0 txqueuelen:0
    RX bytes:6151 (6.0 KiB) TX bytes:6151 (6.0 KiB)
~~~~ 


If you don't have that, it probably that you didn't use the xCAT post install script. You can hack it together quickly by running: 

~~~~     
    IPADDR=172.20.1.19/16
    brctl addif vlan1 eth0
    brctl addbr vlan1
    brctl setfd vlan1 0
    ip addr add dev vlan1 $IPADDR
    brctl addif vlan1 eth0
    ip link set vlan1 up
    ip addr del dev eth0 $IPADDR
~~~~ 

You also can try to rerun the postscript mkhyperv by updatenode command to fix the kvm hypervisor setup problem. 

~~~~     
    updatenode kvmhost1 -P mkhyperv
~~~~ 

## Enable the kvm hypervisor on an existed node. (e.g. on redhat 6 node)

### **Install the perl-Sys-Virt on the management node mn**1

~~~~     
    yum install perl-Sys-Virt.x86_64
~~~~ 

### **Install the libvirt and qemu-kvm on the target node kvmhost**1
 
~~~~    
    yum install libvirt.x86_64 qemu-kvm.x86_64
~~~~ 

### **Rerun the postscript mkhyperv from the management node to setup the kvm host**

~~~~     
    updatenode kvmhost1 -P mkhyperv
~~~~ 

## Create and Install Virtual Machines

After the installing and configuring of kvm hypervisor, you can start to create the virtual machine and deploy OS on it. 

### **Define virtual machines**

The virtual machine kvm1 will be defined. First to add following entry in /etc/hosts: 

~~~~     
    192.168.0.10 kvm1
~~~~ 

Then add it to xCAT under the vm group: 

~~~~     
    nodeadd kvm1 groups=kvm,vm,all
~~~~ 

Next, update DNS with this new node: 

~~~~ 
    
    makedns
    service named restart
~~~~ 
  


### **Define the attributes of virtual machine**

Run the chdef command to change the following attributes for the kvm1: 

  * Define the virtual cpu number 

~~~~     
    chdef kvm1 vmcpus=2 
~~~~ 

  * Define the kvm host of the virtual machine kvm1, it should be set to kvmhost1 

~~~~     
    chdef kvm1 vmhost=kvmhost1 
~~~~ 

  * Define the virtual memory size, the unit is Megabit 

Define 1G memory to the kvm1:  

~~~~ 
    
    chdef kvm1 vmmemory=1024 
~~~~ 

Note: For diskless node, the vmmemory should be set larger than 2048, otherwise the node cannot be booted up. 

  * Define the hardware management module 
 
~~~~   
    chdef kvm1 mgt=kvm 
~~~~

  * Define the virtual network card, it should be set to the bridge br0/virb0/default which defined above. If no bridge was set explicitly, no network device will be created for the node kvm1 

~~~~    
     chdef kvm1 vmnics=br0 
~~~~

  * The vmnicnicmodel attribute is used to set the type and corresponding driver for the nic. If not set, the default value is 'virtio'(xCAT 2.9 and higher) or 'e1000'(Before xCAT 2.9). On certain hypervisors, the default 'e1000' cannot be supported (the network cannot be started during boot) correctly. In this case the 'virtio' is recommended. Since Windows cannot support the driver 'virtio' very well, the 'e1000' is recommended for the vm which the Windows OS will be deployed.
  
~~~~  
     chdef kvm1 vmnicnicmodel=virtio
~~~~

  * Define the storage for the kvm1 

Three formats for the storage source are supported: 

1\. Create storage on a nfs server 

The format is 'nfs://&lt;IP&gt;/dir', that means the kvm disk files will be created at 'nfs://&lt;IP&gt;/dir'. 

~~~~    
     chdef kvm1 vmstorage=nfs://&lt;IP of nfs server&gt;/install/vms/ 
~~~~

2\. Create storage on a device of hypervisor 

The format is 'phy:/dev/sdb1'. 

~~~~    
    chdef kvm1 vmstorage=phy:/dev/sdb1 
~~~~

3\. Create storage on a directory of hypervisor 

The format is 'dir:/install/vms'. 

~~~~    
    chdef kvm1 vmstorage=dir:///install/vms 
~~~~

Note: The attribute vmstorage is only necessary for diskfull node. You can ignore it for diskless node. 

  
Note: The mac address will be created automatically when running the mkvm if you leave it empty. You also can specify it manually before running the mkvm, and then the specified mac address will be used for the kvm1. 

### **Define the console attributes for the virtual machine**

~~~~    
    chdef kvm1 serialport=0 serialspeed=115200 
~~~~

## In the end, the definition of kvm1 should look (more or less) like this

~~~~    
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
~~~~    

Note: depending on your hypervisor type, the nics interface may actually be "virbr0". You can get the interface by connecting to the hypervisor and running "brctl show"! 

### **Create the virtual machine**

Create the virtual machine kvm1 with 20G hard disk. &lt;/br&gt;

~~~~    
    mkvm kvm1 -s 20G
~~~~

If the kvm1 was created successfully, a hard disk file named kvm1.hda.qcow2 can be found in nfs://192.168.5.73/install/vms. And you can run the lsdef kvm1 to see whether the mac attribute has been set automatically. 

### **Try to power on the kvm1**

~~~~    
    rpower kvm1 on
~~~~

If the kvm1 was powered on successfully, you can get following information when running 'virsh list' on the kvm host kvmhost1. 

~~~~    
    virsh list
     Id Name                 State
    --------------------------------   
      6 kvm1                 running
~~~~    

Run the lsvm command to list the virtual machines on the kvm hypervisor. Before running the lsvm for the kvm host, change the hypervisor.type to kvm by command "nodech kvmhost1 hypervisor.type=kvm". 

Note: Only the virtual machine which is in power on state can be listed by lsvm command. 
 
~~~~   
     lsvm kvmhost1
     kvmhost1: kvm1 
~~~~

### **Remove a virtual machine (Optional)**

Remove the kvm1 even when it is in power on status. 

~~~~    
    rmvm kmv1 -f
~~~~

Remove the definition of kvm and related storage. 

~~~~    
    rmvm kvm1 -p
~~~~

### **You are able to look at the node in rcons/wcons**

~~~~    
    makeconservercf kvm1
    wcons kvm1
~~~~

Now, have a look as it boots up, you'll see it got the xCAT standby kernel! 

  


## **Installing the virtual machine kvm1**

Now, you get a node which is ready to be installed. So, from here you can just install the kvm1 as a normal node. 
 
~~~~   
    nodeset kvm1 osimage=rhels6.2-x86_64-install-compute
    rpower kvm1 boot 
~~~~

Then the node will automatically reboot and install. You'll have a normal node! 

## **Connecting to the virtual machine's vnc console**

In order to connect to the virtual machine's console, you need to generate a new set of credentials. You can do it by running: 

~~~~    
    xcatclient getrvidparms kvm1
    kvm1: method: kvm
    kvm1: textconsole: /dev/pts/0
    kvm1: password: JOQTUtn0dUOBv9o3
    kvm1: vidproto: vnc
    kvm1: server: kvmhost1
    kvm1: vidport: 5900
~~~~    

Now just pick your favorite vnc client and connect to the hypervisor, using the password generated by "getrvidparms"! 

Note: If the vnc client complains the password is not valid, it is possible that your hypervisor and headnode clocks are out of sync! You can sync them by running "ntpdate &lt;ntp server&gt;" on both the hypervisor and the headnode. 

## **Setting up a network bridge**

If you followed the above instructions, depending on the hypervisor OS flavor you are using, it is possible that your VM is not correctly binding to the correct interface on the hypervisor (which will cause it not to be able to reach your network). Fortunately, xCAT ships with a script that can be used to set up bridges automatically for us! 

In order to use it, simply copy the "xHRM" script to your netboot images: 
 
~~~~   
    cp /opt/xcat/share/xcat/scripts/xHRM /install/netboot/rhels6/x86_64/compute/rootimg/bin/
~~~~

Repack the new rootimage: 

~~~~    
    packimage rhels6.2-x86_64-netboot-compute 
~~~~

Set the "usexhrm" table field to "1" in your site table: 

~~~~    
    tabdump site | grep usexhrm
    "usexhrm","1",,
~~~~    

Restart xCAT: 

~~~~    
    service xcatd restart
    Restarting xCATd
     Shutting down vsftpd:                                     [  OK  ]
     Starting vsftpd for vsftpd:                               [  OK  ]
~~~~    

And, finally, set your vm.nics to "default"! 

~~~~    
    nodech kvm1 vm.nics=default 
~~~~

Now, next time you restart your hypervisor and your VM, the VM should bridge using the default interface on the hypervisor! 

Note: if you already created the VM, you will have to purge the existing VM (rmvm -p kvm1) and create it again (mkvm kvm1 -s 1). 

## **Clone a kvm node**

Clone is a concept that create a new node from the old one by reuse most of data that has been installed on the old node. Before creating a new node, a vm (virtual machine) master must be created first. The new node will be created from the vm master. The new node can attach to the vm master or not.   
The node can NOT be run without the vm master if choosing to make the node attach to the vm master. The advantage is that the less disk space is needed.  


### **In attaching mode**

In this mode, all the nodes will be attached to the vm master. Lesser disk space will be used than the general node.  
Create the vm master kvmm from a node (kvm2) and make the original node kvm2 attaches to the new created vm master:  

~~~~    
    clonevm kvm2 -t kvmm
    kvm2: Cloning kvm2.hda.qcow2 (currently is 1050.6640625 MB and has a capacity of 4096MB)
    kvm2: Cloning of kvm2.hda.qcow2 complete (clone uses 1006.74609375 for a disk size of 4096MB)
    kvm2: Rebasing kvm2.hda.qcow2 from master
    kvm2: Rebased kvm2.hda.qcow2 from master
~~~~

After the performing, you can see the following entry has been added into the vmmaster table. 

~~~~  
     tabdump vmmaster  
     name,os,arch,profile,storage,storagemodel,nics,vintage,originator,comments,disable
    "kvmm","rhels6","x86_64","compute","nfs://192.168.5.73/vms/kvm",,"br0","Tue Nov 23 04:18:17 2010","root",,
~~~~

Clone a new node kvm4 from vm master kvmm: 

~~~~    
    clonevm kvm4 -b kvmm
~~~~

### **In detaching mode**

Create a vm master that the original node detaches with the created vm master. 
 
~~~~   
    clonevm kvm2 -t kvmmd -d
    kvm2: Cloning kvm2.hda.qcow2 (currently is 1049.4765625 MB and has a capacity of 4096MB)
    kvm2: Cloning of kvm2.hda.qcow2 complete (clone uses 1042.21875 for a disk size of 4096MB)
~~~~

Clone the kvm3 from the kvmmd with the detaching mode turn on: 

~~~~    
    clonevm kvm3 -b kvmmd -d
    kvm3: Cloning kvmmd.hda.qcow2 (currently is 1042.21875 MB and has a capacity of 4096MB)
~~~~
  


## FAQ

### **libvirtd run into problem**

One error we saw on occasion was the following message: 

~~~~    
    rpower kvm1 on
    kvm1: internal error no supported architecture for os type 'hvm'
~~~~

This error was fixed by restarting libvirtd on the host machine 

~~~~    
    xdsh kvmhost1 service libvirtd restart
~~~~

Note: In any case that you find there is libvirtd error message in syslog, you can try to restart the libvirtd. 

### **Virtual disk has problem**

When running command 'rpower kvm1 on', get the following error message: 

~~~~    
    kvm1: Error: unable to set user and group to '0:0'
      on '/var/lib/xcat/pools/27f1df4b-e6cb-5ed2-42f2-9ef7bdd5f00f/kvm1.hda.qcow2': Invalid argument:
~~~~

Solution: try to figure out the nfs:// server was exported correctly. The nfs client should have root authority. 

### **VNC client complains the credentials are not valid**

When connecting to the hypervisor using VNC (to get a VM console), the vnc client complains with "Authentication failed". 

Solution: Check if the clocks on your hypervisor and headnode are in sync! 

### **rpower fails with "qemu: could not open disk image /var/lib/xcat/pools/2e66895a-e09a-53d5-74d3-eccdd9746eb5/vmXYZ.hda.qcow2: Permission denied" error message**

When running rpower on a kvm vm, rpower complains with the following error message: 
    
~~~~    
    rpower vm1 on
    vm1: Error: internal error Process exited while reading console log output: char device redirected to /dev/pts/1
    qemu: could not open disk image /var/lib/xcat/pools/2e66895a-e09a-53d5-74d3-eccdd9746eb5/vm1.hda.qcow2: Permission denied: internal error Process exited while reading console log output: char device redirected to /dev/pts/1
    qemu: could not open disk image /var/lib/xcat/pools/2e66895a-e09a-53d5-74d3-eccdd9746eb5/vm1.hda.qcow2: Permission denied
    [root@xcat xCAT_plugin]#
~~~~    

This might be caused by bad permissions in your NFS server / client (where clients will not mount the share with the correct permissions). 

Solution: 

Systems like CentOS 6 will have NFS v4 support activated by default. This might be causing the above mentioned problems so one solution is to simply disable NFS v4 support in your NFS server by uncommenting the following option in /etc/sysconfig/nfs: 
    
~~~~    
    RPCNFSDARGS="-N 4"
~~~~    

Finish by restarting your NFS services (i.e. service nfsd restart) and try powering on your VM again... 

Note: if you are running a stateless hypervisor, we advise you to purge the VM (rmvm -p vmXYZ), restart the hypervisor and "mkvm vmXYZ -s 4" to recreate the VM as soon as the hypervisor is up and running. 

### ** Error: Cannot communicate via libvirt to &lt;host&gt; **

This error mostly caused by the incorrect setting of the ssh tunnel between xCAT management node and &lt;host&gt;. 

**Solution:**

    Check that xCAT MN could ssh to the &lt;host&gt; without password. 

### Cannot ping to the vm after the first boot of stateful install

The new installed stateful vm node is not pingable after the first boot, you may see the following error message in the console when vm booting: 

~~~~    
    ADDRCONF(NETDEV_UP): eth0 link is not ready.
~~~~    

This issue may be caused by the incorrect driver for vm. You can try to change driver to 'virtio' by following steps: 

~~~~    
    rmvm kvm1
    chdef kvm1 vmnicnicmodel=virtio
    mkvm kvm1
~~~~    
