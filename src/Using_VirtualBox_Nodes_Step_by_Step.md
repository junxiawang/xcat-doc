<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Cookbook: Using VirtualBox Nodes - Step by Step](#cookbook-using-virtualbox-nodes---step-by-step)
  - [About the VirtualBox Plugin](#about-the-virtualbox-plugin)
  - [1\. Install and Configure VirtualBox](#1%5C-install-and-configure-virtualbox)
    - [Example 1: All nodes running in VMs on one server](#example-1-all-nodes-running-in-vms-on-one-server)
  - [4\. Add each VirtualBox vm as a node:](#4%5C-add-each-virtualbox-vm-as-a-node)
  - [5\. Define the right hardware management method 'vbox' in the nodehm table:](#5%5C-define-the-right-hardware-management-method-vbox-in-the-nodehm-table)
  - [6\. Add each vm host as a node:](#6%5C-add-each-vm-host-as-a-node)
  - [7\. The host machine's node type attribute needs to be set to websrv as well:](#7%5C-the-host-machines-node-type-attribute-needs-to-be-set-to-websrv-as-well)
  - [8\. Start the VirtualBox Web Service Process on the Virtual Host:](#8%5C-start-the-virtualbox-web-service-process-on-the-virtual-host)
  - [9\. You are ready to control your virtual machines with rpower - as you know it.](#9%5C-you-are-ready-to-control-your-virtual-machines-with-rpower---as-you-know-it)
  - [10\. Virtual Machine Console](#10%5C-virtual-machine-console)
  - [11\. rpower Examples](#11%5C-rpower-examples)
- [Tips](#tips)
  - [Serial Console Settings](#serial-console-settings)
  - [Node name does not equal VirtualBox machine name](#node-name-does-not-equal-virtualbox-machine-name)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Cookbook: Using VirtualBox Nodes - Step by Step

{{:Howto Warning}} This document handles the VirtualBox plugin, which is now included in the xCAT 2.2 release. 

  


[Back to the 'Using VirtualBox Nodes' Introduction](Using_VirtualBox_Nodes) 

## About the VirtualBox Plugin

**VirtualBox support was added to the following files to xCAT:**

  * /opt/xcat/lib/perl/xCAT/Schema.pm (including the new 'websrv' table) 
  * /opt/xcat/lib/perl/xCAT/vboxService.pm 
  * /opt/xcat/lib/perl/xCAT_plugin/vbox.pm 

A new table called **websrv** was also added: 
    
    # tabdump websrv
    #node,port,username,password,comments,disable
    "vboxhost","18083","test","test",,

From the existing vm table the attributes 'host' and 'vncport' are used. The host's ip address needs to be specified in the 'hosts' table. 

**The following perl packages have been added to the dependencies of the RPM package:**

  * perl-SOAP-Lite-0.710.08-1.noarch.rpm  

  * perl-version-0.76-1.noarch.rpm 

These packages should be pulled in automatically when yum is used to install xCAT. 

On SLES, the perl-version RPM appears to have a conflict with perl-doc, so you may have to remove perl-doc first. 

## 1\. Install and Configure VirtualBox

VirtualBox must be installed and configured correctly in order for xCAT to work properly. The network configuration of the virtual machines is critical. [VirtualBox has many networking options](http://www.virtualbox.org/manual/ch06.html), and the correct choice depends on how your virtual machines will be configured. 

VirtualBox can be controlled from an HTTP interface using the SOAP protocol. The VirtualBox plugin to xCAT uses this interface to control VMs with the **rpower** command. In order for this to work, the **vboxwebsrv** program must be installed on each host machine. It may be included by default when VirtualBox is installed, or it may require an extra step (for example, on Gentoo or other Portage-based systems the **vboxwebsrv** USE flag must be enabled before VirtualBox is installed.) 

### Example 1: All nodes running in VMs on one server

Mirroring the setup found on many clusters, the VM for the head (management) node has two network adapters. Adapter 1 is attached to NAT so it can access the outside world through the network connection on the host. Adapter 2 is attached to a Host-only Adapter which communicates with the other nodes on VirtualBox's internal network (named vboxnet0 by default). This network is not visible outside of the host machine, and thus does not create any security concerns. 

The VM for each compute node has one network adapter which is connected to a Host-only Adapter and connected to the same virtual network as the head node. 

## 4\. Add each VirtualBox vm as a node:
    
    nodeadd vm01 groups=all,vbox vm.host=vh01
    nodeadd vm02 groups=all,vbox vm.host=vh01

The vm.host attribute is mandatory - if it is not set the following error occurs: "vm01: Missing information: host vncport comments" 

## 5\. Define the right hardware management method 'vbox' in the nodehm table:

Here with help of the 'vbox' group. 
    
    chtab node=vbox nodehm.mgt=vbox nodehm.power=vbox

If the hardware management method is not specified, xCAT will not know which plugin to load. 

## 6\. Add each vm host as a node:
    
    nodeadd vh01 groups=all,websrv websrv.port=18083 websrv.username=test websrv.password=test
    chtab node=vh01 hosts.ip=192.168.1.10

The login data for the VirtualBox host machine's web service needs to be specified in the websrv table. If not specified the following error occurs: "vh01: Missing information: port username password". Its IP address needs to be specified in the hosts table otherwise the following shows up: "vh01: Missing information: ip" For the case in which your xCAT management node is also a virtual machine, the virtual host's IP address may be something like 10.0.2.2. 

## 7\. The host machine's node type attribute needs to be set to websrv as well:

This can be done with help of the websrv group as was done for the vbox hardware management method with the vbox group: 
    
    chtab node=websrv nodetype.nodetype=websrv

## 8\. Start the VirtualBox Web Service Process on the Virtual Host:

Before running the VirtualBox web service, you may switch off security for testing if you want: 
    
    VBoxManage setproperty websrvauthlibrary null     # optional

Now start the web service on the virtual host, in a separate shell (or in the background): 
    
    vboxwebsrv

If the web service is not running or there is an authentication problem, the following error is shown: "vm01: No connection to the web service @ [http://192.168.1.10:18083/](http://192.168.1.10:18083/.)". 

## 9\. You are ready to control your virtual machines with rpower - as you know it.

**NOTE: support for powering on/off VirtualBox nodes appears to be broken according to this [post on the xCAT mailing list](http://www.mail-archive.com/xcat-user@lists.sourceforge.net/msg00660.html).**

Of course you can set more properties in the xCAT tables, like MAC and IP adresses, so xCAT can give IP adresses or perform automatic installations over PXE boot. See the xCAT2top document for the steps involved. When you are ready, run: 
    
    rpower vm01 boot

Notes: 

  * Watch the reaction to your commands, and see the extra information for the state or when the rpower argument "stat" is used. 
  * The plugin tries to use the "Power Button Signal" to shutdown a virtual machine when rpower off is issued. If the machine does not handle that signal (e.g. because no OS is running yet) the machine is forced to power off. 

## 10\. Virtual Machine Console

At the VRDP Port on the host machine, you can establish a Remote Desktop Connection to the virtual machine, which is compatible to the Windows Remote Desktop Connection standard program as well. For Linux, VirtualBox offers a client application: /usr/bin/rdesktop-vrdp. After the virtual machine has been powered on, run the following on the virtual host: 
    
    rdesktop-vrdp -a 16 localhost:3389

This will bring up a graphical console for the virtual machine. 

Note: The vm.vncport attribute from the vm table is used for the VRDP port of VirtualBox virtual machine. If it was not specified in that table, it will be set with the current vrdp port when the vm is started for the first time. If the port was not explicitly set during the creation of the virtual machine it will be the default value 3389. Each vm will have a different port number, when created in VirtualBox. Set these port numbers for each vm in vm.vncport attribute and the plugin will make sure that VirtualBox uses the correct port on each vm start. 

## 11\. rpower Examples

**NOTE: support for powering on/off VirtualBox nodes appears to be broken according to this [post on the xCAT mailing list](http://www.mail-archive.com/xcat-user@lists.sourceforge.net/msg00660.html).**
    
    [root@c01b01-0 /]# rpower vm stat
    vm01: off
    vm02: off
    
    [root@c01b01-0 /]# rpower vm02 on
    vm02: on
    
    [root@c01b01-0 /]# rpower vm02 stat
    vm02: on
    
    [root@c01b01-0 /]# rpower vm02 off
    vm02: off
    
    [root@c01b01-0 /]# rpower vm02 stat
    vm02: off
    
    [root@node1 ~]# tabdump vm
    #node,host,migrationdest,storage,memory,cpus,nics,bootorder,virtflags,vncport,textconsole,beacon,comments,disable
    "vm01","vh01",,,,,,,,"3389",,,,
    [...]

# Tips

## Serial Console Settings

On a physical machine, you may be used to configuring a serial port TTY console interface for each node. Do _not_ do this with a virtual node! Leave the fields **serialport**, **serialspeed**, and **serialflow** blank in the **nodehm** table so that you can watch the boot and installation process in the virtual machine window. 

There may be a way to configure virtual nodes to work with rcons/wcons...if you got this to work, please add it to this document. 

## Node name does not equal VirtualBox machine name

Sometimes the VirtualBox machine name can not equal the xCAT node name, especially in test cases that might occur. There is a feature for this situation: add somewhere in the comment field of the vm table a schema like "vmname:NAME!" and replace NAME by the vm name on the VirtualBox host system. You may insert other comments before and after that schema. For example the xCAT node "vm03" should point to the virtual machine "machine03" on the VirtualBox host "vh01". If it should also use the VRDP port 3400 the vm table should look like this: 
    
    [root@node1 ~]# tabdump vm
    #node,host,migrationdest,storage,memory,cpus,nics,bootorder,virtflags,vncport,textconsole,beacon,comments,disable
    [...]
    "vm03","vh01",,,,,,,,"3400",,,"vmname:machine03!",

  
[Back to the 'Using VirtualBox Nodes' Introduction](Using_VirtualBox_Nodes) 
