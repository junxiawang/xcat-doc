<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT &amp; Xen](#xcat-&amp-xen)
  - [Requirements](#requirements)
  - [Terms used](#terms-used)
  - [Notes](#notes)
- [Installation](#installation)
  - [Install Xen support **on the Headnode**](#install-xen-support-on-the-headnode)
  - [**Install Xen Hypervisor nodes**](#install-xen-hypervisor-nodes)
  - [Create Xen Guests](#create-xen-guests)
- [Advanced options](#advanced-options)
  - [Create a Hypervisor Image](#create-a-hypervisor-image)
  - [Setup Live migration](#setup-live-migration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


# xCAT &amp; Xen

xCAT can be configured to work with the Xen hypervisor to install and manage virtual compute nodes. 

## Requirements

OS for Headnode/Compute nodes: Verified to work with: Centos 5.2 64-bit  
OS for Xen guests: Verified to work with Centos 5.2 32/64-bit, Windows server 2008 32/64-bit  
xCAT: Version 2.1 - Snapshot from Sept. 4th 2008 or later  
Headnode: CPU Virtualization technology is not required  
Compute nodes: CPU Virtualization technology is required  
Guest storage: This can be a file on the hypervisor, an nfs mounted file, iSCSI drive or similar. 

## Terms used

headnode - the xCAT headnode  
node01 - a compute node  
xen1 - the name of a Xen guest  
xen_disk - A Xen virtual hard disk file  
10.10.10.1 - xCAT server IP address 

## Notes

Be careful when restating Xen. If you have any Xen nodes running, you will zombie the nodes if you do not pause them before restarting the Xen service. To avoid zombies, pause the nodes, restart Xen, and then resume the nodes: 
    
    service xendomains stop
    service xend restart
    service xendomains start

# Installation

Start with a standard install of the latest 2.1 snapshot 

  


## Install Xen support **on the Headnode**

  * Install the xen-devel, libvirt, libvirt-devel and gcc packages, then install the perl module Sys::Virt 
    
    yum install xen-devel libvirt libvirt-devel gcc
    cpan install Sys::Virt

  * _NOTE: To install Sys::Virt, the PKG_CONFIG_PATH environment variable may need to be exported because libvirt.pc may not be in a standard location. (Example: export PKG_CONFIG_PATH=/usr/lib64/pkgconfig)_

## **Install Xen Hypervisor nodes**

Each compute node can be used as a hypervisor node, and may be individually installed or installed from an image. The Xen guests are installed with the rinstall command. If configured for live migration, the guests can be migrated from one compute node to another without being powered down. This section covers the basic task of modifying an already installed compute node to be a hypervisor. To create a hypervisor image, see the "Create a Hypervisor Image" section 

**To modify an existing compute node:**

  * rinstall the compute node 
  * On the node, install kernel-xen, xen, and uucp 
  * Edit "/boot/grub/menu.lst" so that the Xen kernel will boot by default - usually this means changing the default boot image to 0 
  * You may want to add an option to specify how much memory the dom0 (compute node) uses for itself. This is an option you can specify in the bootloader with the dom0_mem option. For example, to set the dom0 to use 512 MB of RAM, edit the kernel line to look like this: 
    
    kernel /boot/xen.gz-2.6.18-92.el5 dom0_mem=512M

  * If you don't need live migration, create the directory to store the VM disk files: /vms. Otherwise see the section on Live migration for NFS and iSCSI instructions. 
    
    mkdir /vms

  * Create a 4GB file for the Xen Guest for each virtual hard drive 
    
    dd if=/dev/zero of=/vms/vm_disk bs=1M count=1 seek=4095

  * Reboot the compute node 

## Create Xen Guests

On the Headnode: 

  * Add a Xen guest to the xCAT tables by running a command similar to the following: 
    * _NOTE: The serialport and serialspeed options will redirect console output to the Xen serial terminal. To use vnc to view the console, leave these options out._
    
    nodeadd xen1 groups=compute,all vm.host=node01 vm.storage=/vms/vm_disk nodehm.mgt=xen nodehm.power=xen nodehm.serialport=0 nodehm.serialspeed=115200  nodetype.os=centos5.2 nodetype.arch=x86 nodetype.profile=compute noderes.netboot=pxe noderes.nfsserver=10.10.10.1 noderes.primarynic=eth0

  * add the IP address of the Xen guest to /etc/hosts 
  * Power the Xen guest on and off to create it's config file and MAC address. Then create a DHCP entry for it: 
    
    rpower xen1 on
    rpower xen1 off
    makedhcp xen1
    service dhcpd restart

  * Do an rinstall to install the OS on guest: 
    
    rinstall xen1

**Optional:**

  * To watch the install console by either using makeconservercf xen1 and running "rcons xen1" or directly running: /opt/xcat/share/xcat/cons/xen xen1 
    * _NOTE: To exit the console, type ~~. (plus however many ~'s you need for each ssh session you are currently using)_
  * To view the Console with vnc: 
    * Modify Xen to allow vnc connections from anywhere, then restart Xen: 
    
    vi /etc/xen/xend-config-config.sxp
    (vnc-listen '0.0.0.0')
    service xend restart

List the Xen guests: 
    
    ssh node01 xm list
    Name          ID Mem(MiB) VCPUs State   Time(s)
    Domain-0      0     2439     4 r-----   2772.6
    xen1           3      519     1 -b----     33.4
    xen2           7      519     1 -b----     27.0

ssh to the Headnode with X forwarding, and run vncviewer on the ID listed for the guest 
    
    ssh headnode -Y
    vncviewer node01:3

# Advanced options

These sections give instructions for settting up the more advanced options of Xen + xCAT such as live migration, and creating a hypervisor image. 

## Create a Hypervisor Image

  * Create the hypervisor template: 
    
    cd /opt/xcat/share/xcat/install/centos/
    cp compute.tmpl hyper.tmpl
    vi hyper.tmpl

  * At the end of the file, modify the name of the post install script - change it from post.rh to post.hyper.rh 
  * add these lines at the bottom of the document, just before %pre 
    
    kernel-xen
    xen
    uucp

  * Modify the post-install script 
    
    cd ../scripts
    cp post.rh post.hyper.rh
    vi post.hyper.rh

  * Add these lines to the bottom of the file (before the exit 0) 
  * To modify to bootloader to load the xen kernel by default: 
    
    sed -i 's/default=[1-9]\+/default=0/' /boot/grub/menu.lst

  * To specify the amount of memory the dom0 (compute node) has available, use this line: 
    
    sed -i 's/\(kernel.*$\)/\1 dom0_mem=512M/' /boot/grub/menu.lst

  * To setup VNC to listen from anywhere, add these lines: 
    
    XENDCONFIGFILE=/etc/xen/xend-config.sxp
    HOSTNAME=#TABLE:nodelist:THISNODE:node#
    sed -e "s/vnc-listen '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+'/vnc-listen 0.0.0.0/" -i $XENDCONFIGFILE
    sed -e "s/\#[ ]*(vnc-listen/(vnc-listen/" -i $XENDCONFIGFILE

  * To enable migration, add these lines: 
    
    XENDCONFIGFILE=/etc/xen/xend-config.sxp
    sed -e "s/(xend-relocation-hosts-allow '\^/\#(xend-relocation-hosts-allow '\^/" -i $XENDCONFIGFILE
    sed -e "s/\#[ ]*(xend-relocation-server no/(xend-relocation-server yes/" -i $XENDCONFIGFILE
    sed -e "s/\#[ ]*(xend-relocation-port 8002)/(xend-relocation-port 8002)/" -i $XENDCONFIGFILE
    sed -e "s/\#[ ]*(xend-relocation-hosts-allow _/(xend-relocation-hosts-allow _/" -i $XENDCONFIGFILE

  * To have the node create it's own virtual disks, add these lines: 
    
    mkdir /vms
    HOSTNAME=#TABLE:nodelist:THISNODE:node#
    dd if=/dev/zero of=/vms/$HOSTNAME-x1 bs=1M count=1 seek=4095
    dd if=/dev/zero of=/vms/$HOSTNAME-x2 bs=1M count=1 seek=4095
    dd if=/dev/zero of=/vms/$HOSTNAME-x3 bs=1M count=1 seek=4095
    dd if=/dev/zero of=/vms/$HOSTNAME-x4 bs=1M count=1 seek=4095

  * Or, to have the node mount the /vms directory on the head node, add these lines: 
    
    mkdir /vms
    echo "headnode:/vms  /vms    nfs   defaults 0 0" &gt;&gt;/etc/fstab

  * Set the profile to hyper in the nodetype tab 
    
    chdef -t group -o node1 profile=hyper

  * Install the compute node 
    
    rinstall node01

## Setup Live migration

To use migration for Xen guests, the virtual hard drives must be available on a network share (i.e. nfs or iSCSI). All of these steps can be done manually, or put into the postscripts for the hypervisor image.  
**To setup NFS:**

  * On the Headnode, edit /etc/exports, and add the following line: 
    
    /vms *(rw,no_root_squash,sync)

  * Restart the nfs service 
  * Create a virtual hard drive for each Xen guest: 
    
    mkdir /vms
    dd if=/dev/zero of=/vms/xen_disk1 bs=1M count=1 seek=4095
    dd if=/dev/zero of=/vms/xen_disk2 bs=1M count=1 seek=4095
    ...

**To setup software iSCSI:**  
Setup iscsi targets (server) 

  * This can be done by xCAT, Jarrod Johnson please document 
  * openfiler is another option 

Setup iscsi initiators (clients) 

  * install iscsi-initator-utils 
  * configure the /etc/iscsi/iscsid.conf file 
  * service iscsi start 
  * iscsiadm -m discovery -t st -p (storage server) 
  * iscsiadm -m node -T (drive name) --login 

Set the vms to use the iSCSI storage devices 

  * In the storage column of the vm table use the /dev/disk/by-path/(disk) address 
  * Setup the iSCSI targets on each node that a vm could be migrated to. 

Setup the hypervisor nodes:  
These steps must be run on each compute node, or be installed to the hypervisor image. 

  * Create the /vms folder, and configure fstab to automount it: 
    
    mkdir /vms
    echo "headnode:/vms  /vms    nfs   defaults 0 0" &gt;&gt;/etc/fstab

Configure xen to support migration. On all compute nodes, make the following edits to /etc/xen/xend-config.sxp: 

  * uncomment '#(xend-relocation-server no)' and change no to yes 
  * uncomment the line: #(xend-relocation-port 8002) 
  * uncomment the line: #(xend-relocation-hosts-allow '') 
  * comment out the line: (xend-relocation-hosts-allow '^localhost$ ^localhost\\\\.localdomain$') 
  * It may also be helpful to change the vnc-listen parameter to '0.0.0.0'. This options tells vnc to listen on all interfaces, instead of just localhost. It also allows for the same config file to be copied to all nodes. 
  * save changes, and restart the xend service 

Once the compute(guest) nodes are created, you can migrate a node from one hypervisor to another with the rmigrate command: rmigrate (guest) (destination) 
    
    rmigrate xen1 node02

Another useful command that utilized the features of rmigrate is revacuate. This command will automatically rmigrate all xen guests off of hypervisor: revacuate (hypervisor) 
    
    revacuate node01
