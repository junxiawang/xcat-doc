<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Concepts](#concepts)
  - [rhevh](#rhevh)
  - [rhevm](#rhevm)
- [Installing of rhevh](#installing-of-rhevh)
- [Installing of rhevm](#installing-of-rhevm)
- [The process to setup a datacenter](#the-process-to-setup-a-datacenter)
- [The steps that manage the vm through Web GUI](#the-steps-that-manage-the-vm-through-web-gui)
- [Example that using the Rest API to control the virtual machine](#example-that-using-the-rest-api-to-control-the-virtual-machine)
- [The arguments that support to use the rhevm instead of direct communicate with rhevh for the vm management](#the-arguments-that-support-to-use-the-rhevm-instead-of-direct-communicate-with-rhevh-for-the-vm-management)
- [How to update the node status after the installing of rhev-h](#how-to-update-the-node-status-after-the-installing-of-rhev-h)
- [The functions that will be supported for rhev](#the-functions-that-will-be-supported-for-rhev)
- [Implementation](#implementation)
  - [Definition of host and vm](#definition-of-host-and-vm)
  - [Hardware control process](#hardware-control-process)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Concepts

### rhevh

It's the hypervisor of KVM. It's a minimal Redhat Enterprise Linux with the KVM functions enabled. The installation source included in a 130M image. As a product, it's the competitor of Vmware esxi. From the web page of redhat, rhevh is NOT free. 

For the virtual machine management, rhevh is using the VDSM (Virtual Desktop and Server Management) as the outside interface. The rhevm should communicate with the VDSM daemon which running on the rhevh to do the rhevh and virtual machine management. 

### rhevm

rhevm is a management center for bunch of physical hosts and virtual machines. There are 4 levels for the resource management: datacenter ,cluster, host and vm. The storage and logic network belong to the datacenter that they can be assigned to each virtual machine inside the datacenter. 

Except the web GUI, rhevm also supplies a REST API for 3rd party software to control the RHEV system. The REST api offers the abundant interface that very similar to the web gui to control the RHEV. 

## Installing of rhevh

The rhevh installation resource is a .iso image which including the kernel and initrd to initiate the installation. For the PXE installation, the installation process can be done through appending the .iso to the initrd and use a kernel parameter to specify the root resource for the installation. The installation program cannot accept the kickstart configuration file, all the parameters have to be passed through the kernel parameters. 

I created a new rhevm.pm plugin module for xCAT to handle the copycds, mkinstall of rhevh and mkvm,chvm,rmvm,rpower... Now the installation of rhevh can be finished though xCAT process. But the one problem is the installation process cannot trigger the running of postscript, I need to figure it out. 

## Installing of rhevm

The rhevm can be installed on rhels6.2 and above. There are 286 packages (about 600M) need to be installed for the rhevm and following installation repositories need to be created for the installation of rhevm: 
    
    rhels6.2 
    Supplementary iso for rhels6.2 
    rhevm
    Jboss
    

After installation, 'rhevm-setup' needs to be run to setup the rhevm. An auto answer file can be created first to make the setup finished in non-interactive. After the setup, you need a system running Windows OS and run the IE to access the web GUI of rhevm. The root certificate of CA needs to be installed first to start the connection. 

## The process to setup a datacenter

  * Create datacenter and cluster (there's a default one) 
  * Add the rhevh to the rhevm. The rhevh will register to rhevm automatically if configuring the rhevm information correct during install of rhevh. 
  * Create the storage and logic network 
  * Create the virtual machine 
  * Provision the virtual machine 

Note: The kvm host which installed through a completed rhels also can be managed by rhevm. 

## The steps that manage the vm through Web GUI

  * Managing the rhevh based hypervisor and virtual machines: 
  * Manually setup the test environment: 
  * Install a rhels6.2 x86_64 system; 
  * Install the rhevm packages on the rhels6.2 
  * Get a Windows system and access the rhevm through IE 
  * Add the rhevh host which installed previously to the cluster; Select the network interface that will be used for the virtual machines. 
  * Create the datacenter and cluster in the rhevm from Web GUI; 
  * Create the storage and network for the datacenter; 
  * Create the virtual machines and do the provision through xCAT. I tested the provisioning of rh6.2 (use dhcp to set IP during the installation, I set the IP manually to finish the installation) and sles11.1 (only support the storage in IDE interface) through xCAT. 

## Example that using the Rest API to control the virtual machine

Get the list of virtual machines: 
    
    curl -X GET -H "Accept: application/xml" -u admin@internal:cluster --cacert /wxp/keys/ca.crt https://ip9-114-34-211.ppd.pok.ibm.com:8443/api/vms
    

Start a virtual machine: 
    
    curl -X POST -H "Accept: application/xml" -H "Content-Type: application/xml" -u admin@internal:cluster --cacert /wxp/keys/ca.crt -d "&lt;action&gt;&lt;vm&gt;&lt;os&gt;&lt;/os&gt;&lt;/vm&gt;&lt;/action&gt;" https://ip9-114-34-211.ppd.pok.ibm.com:8443/api/vms/990419db-73d6-42da-b2b2-c74745559b30/start
    

## The arguments that support to use the rhevm instead of direct communicate with rhevh for the vm management

  * BOA requires to use the rhevm; 
  * The rhev-m has been tested that could support 200 rhev-h. And if need to support a cluster that with more than 200 rhev-h, multiple rhev-m nodse could be installed and each one handle part of hosts in the cluster. 
  * rhev-m keeps the status of the cluster,hosts/vms and virtual network/storage, it's a huge workload that implement the similar functions of rhev-m through the 'libvirt' or 'VDSM' interface. 
  * For 'VDSM' interface, from the 'oVirt' guy, the stable API is under planning and looks like need a long time to release. Currently, rhev-m is using the 'xmlrpm' interface to communicate with the 'VDSM', but this interface is tightly-coupled with the rhev-m and will be replaced by the developing 'stable API'. 
  * For 'libvirt' interface, since rhev-h has the 'VDSM' layer above the 'libvirt', 'VDSM' prefers that 'libVirt' only managed by 'VDSM', otherwise the state of the 'VDSM' will be in a mess. 

**So the conclusion was to use the REST API to communicate with rehvm to manage the vms**

## How to update the node status after the installing of rhev-h

After the installing or booting of a node, the status of the node needs to be updated to 'booted' and the bootloader configuration file should be updated to force the node to boot to local disk. For example that installing of rh, generally, the update process will be performed by the updateflag.awk script which initiated through the kickstart post script. But for the rhev-h, there's no mechanism for customer to introduce a script to implement customized function. I talked with the people of rh that there's only a kernel parameter 'local_boot_trigger=url' which can be used to trigger an action after the installing. 

The format of the 'local_boot_trigger' parameter is 'local_boot_trigger=URL'. What rhev-h do is to wget the URL at end of the installing. Does NOT run the script which get from the url. 

Then xCAT has to figure out a mechanism to trigger a update status operation for rhev-h when rhev-h run the 'wget url'. 

Add a perl cgi 'xcatrhevh.cgi' on the MN or SN for http to handle the http request when some one wget the URL like 'http://192.168.5.84/xcatrhevh/rhevh_finish_install/@HOSTNAME@'. 

Inside the xcatrhevh.cgi, it will check the matching of the request IP to a xcat node. And send a request with 'rhevhupdateflag' command to the xcatd. 

Add a new command 'rhevhupdateflag' which will invoke two commands: 
    
    nodeset &lt;node&gt; next
    updatenodestat &lt;node&gt; booted
    

Note: following entry should be added to the policy table to permit the execute this command from http server 
    
    "5",,,"rhevhupdateflag",,,,"allow",,
    

## The functions that will be supported for rhev

  * Copycds for rhevh 
  * Install rhevh through xCAT 
  * Add hosts to the rhevm 
  * Add storage to the rhevm 
  * Add logic network to the rhevm 
  * Create/Change virtual machines 
  * Remove virtual machines 
  * Display virtual machines 
  * Migrate virtual machines 
  * Clone virtual machines 

Note: Will add doc for how to install the rhevm 

## Implementation

### Definition of host and vm

For host: hypervisor.node, hypervisor.type, hypervisor.mgr. And will add hypervisor.user and hypervisor.password which is needed for rhevm to connect to the rhevh 

For vm: vm.host, vm.host. And will add vm.mgr to store the rhevm information since rhev support that vm does not bind to a specific host. 

### Hardware control process

  * Get the host/node definition from the vm and hypervisor table 
  * Structure the data to hash with rhevm as the key 
  * Make connection to each rhevm 
  * Generate the url and data for the Rest API to do the *vm command and rpower, rmigrate 

I'll update more detail logic for implementation. 
