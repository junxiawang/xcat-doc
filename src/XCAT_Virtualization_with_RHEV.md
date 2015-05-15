<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [When to Use This Document](#when-to-use-this-document)
- [Install RHEV Manager](#install-rhev-manager)
  - [Install rhevm From RHN](#install-rhevm-from-rhn)
  - [Install rhevm From Local Media](#install-rhevm-from-local-media)
  - [Install rhevm](#install-rhevm)
  - [Setup rhevm](#setup-rhevm)
  - [How to Access rhevm Through the Web Interface](#how-to-access-rhevm-through-the-web-interface)
  - [How to Access rhevm Through the REST API](#how-to-access-rhevm-through-the-rest-api)
- [Configure Virtual Environment](#configure-virtual-environment)
  - [Setup password for rhev](#setup-password-for-rhev)
  - [Display rhev Objects](#display-rhev-objects)
  - [Setup the Data Center and Cluster for rhev](#setup-the-data-center-and-cluster-for-rhev)
  - [Setup Logical Networks](#setup-logical-networks)
  - [Example of Displaying the Virtual Environment](#example-of-displaying-the-virtual-environment)
- [Install rhev Hypervisor](#install-rhev-hypervisor)
  - [Generate the Installation Repository](#generate-the-installation-repository)
  - [Enable Installation Status Update for rhev-h](#enable-installation-status-update-for-rhev-h)
  - [Define the rhev-h Node](#define-the-rhev-h-node)
  - [Install the rhev-h Host Using xCAT](#install-the-rhev-h-host-using-xcat)
- [Configure rhev Hypervisor](#configure-rhev-hypervisor)
  - [Configure rhev-h attributes](#configure-rhev-h-attributes)
  - [Approve the rhev-h Node](#approve-the-rhev-h-node)
  - [Configure the Network Interfaces](#configure-the-network-interfaces)
  - [Configure Power Management for the rhev-h Host](#configure-power-management-for-the-rhev-h-host)
  - [If You Need to Remove a rhev Hypervisor](#if-you-need-to-remove-a-rhev-hypervisor)
- [Setup a Storage Domain for rhev Environment](#setup-a-storage-domain-for-rhev-environment)
  - [Other Storage Domain Operations](#other-storage-domain-operations)
- [Define the Virtual Machines](#define-the-virtual-machines)
  - [Defining Many Virtual Machines](#defining-many-virtual-machines)
- [Deploy and Manage the Virtual Machines](#deploy-and-manage-the-virtual-machines)
- [Cloning and Migrating Virtual Machines](#cloning-and-migrating-virtual-machines)
- [Debugging RHEV](#debugging-rhev)
  - [Get the Details of the REST API](#get-the-details-of-the-rest-api)
  - [Storage Domain can NOT be Accessed](#storage-domain-can-not-be-accessed)
  - [Encountered Error: 'Cannot connect server to Storage' for a nfs Type of Storage Domain](#encountered-error-cannot-connect-server-to-storage-for-a-nfs-type-of-storage-domain)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

RHEV stands for 'Red Hat Enterprise Virtualization' which is a virtualization solution produced by Red Hat. The RHEV solution is based on KVM technology with an optimized KVM virtual host and a powerful management portal. With RHEV, the virtualization infrastructure is managed easily and efficiently.

RHEV consists of two parts:

  * **rhev-m** \- The RHEV manager which can be installed on a rhels6.2 (or above) system to manage a bunch of physical hosts and virtual machines.
  * **rhev-h** \- A hypervisor of KVM. It's a minimal Redhat Enterprise Linux image with the KVM functions enabled. It can be installed on a bare-metal machine directly.

A RHEV environment consists of the following components:

  * RHEV manager: It is the centralized virtualization system manager which controlls the running of the whole environment. It offers a web interface that user can use to control the whole virtual environment. It also offers a REST API that it can be used by third party software to access and control the virtual environment. xCAT is using the REST API of rhev-m to manage the RHEV environment.
  * Datacenter: A logic container for all the components which are needed for a virtualization environment to run. RHEV supports having multiple datacenters. Current only the default datacenter named 'Default' is supported in xCAT.
  * Cluster: A set of physical hosts and the virtual machines which run on the hosts. The virtual machines located within a cluster can be migrated between the hosts. Generally the default cluster 'Default' is used.
  * Host: A physical server which hosts virtual machines. The host could be running rhev-h (RHEV hypervisor) or rhels (RH enterprise Linux server with kvm enabled).
  * Storage domain: A storage domain (or pool) belongs to a datacenter that VMs (virtual machines) in the datacenter can use to create disks in. A RHEV environment can have multiple storage domains. Current only the 'nfs' type of storage domain is supported in xCAT.
  * Logical network: The network that the NICs of a host or vm can be added to. There's a default management network 'rhevm'. For hosts, the nic which is used to communicate with rhev-m will be added to the 'rhevm' network automatically.

The basic process to setup a datacenter:

  * [Optional] Create a data center and a cluster (A default data center and cluster named "Default" have been created during initialization of rhevm.)
  * Create storage domains for virtual machines to create disks in.
  * Create logic networks for hosts and vms.
  * Install the host with rhev-h. Set the 'hostname' and access password of rhev-m in rhev-h, so that after host installation the host will automatically register itself to the rhev-m server.
  * Approve the rhev-h host from the rhev-m server, and configure the network interface for the host.
  * Create/Clone/Migrate the virtual machines.

### When to Use This Document

Perform the steps outlined in this document after setting up your xCAT management node and defining nodes in your cluster using [XCAT_iDataPlex_Cluster_Quick_Start].

## Install RHEV Manager

The rhev-m server can be installed on rhels6.2 or above. There are 286 packages that need to be installed. (Including dependencies, it takes about 600MB.). Two approaches can be used to install the rhev-m server:

  1. through RHN if the target server has access to the internet or a RHN satelite
  2. or install rhev-m on the server from local media.

Rhevm can be installed on the xCAT management node or on a separate server.

### Install rhevm From RHN

If the target server can access RHN (or an RHN satelite), installing rhevm using RHN is recommended. Register the rehvm server with RHN and add following channels for the repositories that are needed for rhev-m.

~~~~
    rhn_register
    rhn-channel --add --channel=rhel-x86_64-server-6-rhevm-3
    rhn-channel --add --channel=jbappplatform-5-x86_64-server-6-rpm
    rhn-channel --add --channel=rhel-x86_64-server-supplementary-6
~~~~


### Install rhevm From Local Media

If you plan to install rhevm from local media, the following repositories need to be created manually on the target server: (All the packages can be downloaded from RH)

  * rhels6.2
  * Supplementary iso for rhels6.2
  * rhevm
  * Jboss

### Install rhevm

Remove the classpathx-jaf package which may conflict with rhev-m.

~~~~
    yum remove classpathx-jaf
~~~~


Install rhevm package and all dependencies.

~~~~
    yum install rhevm
~~~~


### Setup rhevm

After successful installation, rhevm needs to be configured and initialized. The configuration can be done through a configuration answer file.

Create the answer file answerrhevm:

~~~~
    rhevm-setup --gen-answer-file=answerrhevm
~~~~


The created answer file answerrhevm has content like this:

~~~~
    [general]
    OVERRIDE_IPTABLES=no
    HTTP_PORT=8080
    HTTPS_PORT=8443
    MAC_RANGE=xx:xx:xx:xx:xx:xx-xx:xx:xx:xx:xx:xx (The customized mac range can be specified.
      But the system generated range is recommended, otherwise it may cause the rhevm can NOT recognize the range.)
    HOST_FQDN=hostname of rhevm server (The hostname must be FQDN. This is very important for rhevm to generate the certificates.)
    AUTH_PASS=xxxx (The password of 'admin' that can be used to access the rhevm through web or REST api)
    DB_PASS=xxxx (The password for rhevm to access the database)
    ORG_NAME=xxx (The name of orgnization)
    DC_TYPE=NFS (The storage type for default datacenter)
    CONFIG_NFS=no
~~~~


Change the answer file with proper values and setup the rhevm:

~~~~
    rhevm-setup --answer-file=answerrhevm
~~~~


### How to Access rhevm Through the Web Interface

rhev-m ONLY can be accessed via the web GUI from a client which running Windows OS with IE. The root certificate of CA needs to be installed first to start the connection.

    Open the IE web browser and enter the web url: http://&lt;FQDN of rhev manager&gt;:8080/RHEVManager
      Install the 'certificate' first and then click 'admin' to get into the admin management portal with following account:
    User name: admin
    Password: &lt;what you set for 'AUTH_PASS' attribute in the answer file 'answerrhevm' when running rhevm-setup&gt;


### How to Access rhevm Through the REST API

For debugging when the web access is not available, you can access rhevm through REST API. See the [REST API specification](https://access.redhat.com/knowledge/docs/en-US/Red_Hat_Enterprise_Virtualization/3.0/html-single/REST_API_Guide/index.html).

  * First, you need to get the certificate from the CA:

~~~~
    wget http://<hostname of rhevm>:8080/ca.crt
~~~~


  * Use REST API to display the functions list:

~~~~
    curl -X GET -H "Accept: application/xml" -u admin@internal:<password> --cacert </path/ca.crt> https://<rhevm>:8443/api
~~~~


  * List all the vms:

~~~~
    curl -X GET -H "Accept: application/xml" -u admin@internal:<password> --cacert </path/ca.crt> https://<rhevm>:8443/api/vms
~~~~


## Configure Virtual Environment

### Setup password for rhev

There are two passwords need to be set for rhev: one is for rhev-m and the other for host (rhev-h).

  * Set the password for rhev-m

This password is used for xcat to access the rhevm. Currently, only the 'admin' is supported as user.

~~~~
    chtab key=rhevm passwd.username=admin passwd.password=<password>
~~~~


  * Set the password for thev-h

These passwords are used for 'root' and 'admin' accounts that will be configured to rhev-h during the installing. Customer can access the rhev-h through these passwords.

~~~~
    chtab key=rhevh,username=root passwd.password=<password>
    chtab key=rhevh,username=admin passwd.password=<password>
~~~~


### Display rhev Objects

Use the [lsve](http://xcat.sourceforge.net/man1/lsve.1.html) command to display the datacenter and cluster in the environment:

~~~~
    lsve -t dc -m <rhevm> -o Default
    lsve -t cl -m <rhevm> -o Default
~~~~


Notes:

  * &lt;rhevm&gt; is the FQDN (Fully Qualified Domain Name) for the rhevm server.
  * for the lsve command, if no '-o' flag is specified, all the objects of the specified 'type' will be displayed.

The Data Center contains: Cluster and Storage Domain. The Cluster contains: host and vm. By default, the following are automatically created for you:

  * a Datacenter call 'Default' that contains:
    * a Storage Domain of type 'nfs'
    * a Cluster called 'Default'

If you want to change these objects, or create additional ones, see examples below.

### Setup the Data Center and Cluster for rhev

Note: The storage domain must have the same storage type (nfs or localfs) with the data center it is part of. The storage type for the default data center 'Default' is 'nfs'. If you want to use a 'localfs' storage domain, a new data center with 'localfs' storage type needs to be created first.

  * Create a data center with 'nfs' type of storage domain

~~~~
    cfgve -t dc -m <rhevm> -o <datacenter name> -k nfs -c
~~~~


  * Create a data center with 'localfs' type of storage domain

~~~~
    cfgve -t dc -m <rhevm> -o <datacenter name> -k localfs -c
~~~~


  * Create a cluster, attaching it to data center "mydc"

~~~~
    cfgve -t cl -m <rhevm> -o <cluster name> -d mydc -c
~~~~


  * List the data center and cluster

~~~~
    lsve -t dc -m <rhevm> -o <data center name>
    lsve -t cl -m <rhevm> -o <cluster name>
~~~~


  * Remove a data center or cluster

~~~~
    cfgve -t dc -m <rhevm> -o <datacenter name> -r
    cfgve -t cl -m <rhevm> -o <cluster name> -r
~~~~


### Setup Logical Networks

Through the RHEV manager you can create logical networks that allow RHEV hypervisors and virtual machines to communicate with each other. For each logical network, the hypervisors are connected to it and they bridge to all the VMs that are part of that logical network. For example, in the diagram below there are 2 logical networks: rhev and rhev1. Each of the hypervisors (rhevh1 and rhevh2) are physically connected to each logical network. The hypervisors provide virtual networks for the VMs, and those virtual networks are bridged to the corresponding physical networks.

[[img src=Rhev-network.png]]


The default management network 'rhevm' is created automatically during the setup of rhev-m. If you need another network for storage, data, or communication, create a new one using the examples below.

  * Create a new network for rhev

If '-d' is not specified, the network will be attached to the 'Default' datacenter.

~~~~
    cfgve -t nw -m <rhevm> -o <network name> -d <datacenter> -c
~~~~


If you are trying to add the network to a specific vlan, use the flag '-n'. Then all the nics which are added to this network will be assigned to this vlan:

~~~~
    cfgve -t nw -m <rhevm> -o <network name> -d <datacenter> -n 2 -c
~~~~


  * Attach the network to the correct cluster

The network must be attached to a cluster so that the nics of the hosts and vms in the cluster can be added to it.

~~~~
    cfgve -m <rhevm> -t nw -o <network name> -l <cluster> -a
~~~~


  * Run lsve to show the result:

~~~~
    lsve -t nw -m <rhevm> -o <network name>
~~~~


  * Remove the logical network

~~~~
    cfgve -t nw -m <rhevm> -o <nework name> -r
~~~~


### Example of Displaying the Virtual Environment

Display the datacenter called 'Default'

~~~~
    #lsve -t dc -m <rhevm> -o Default
    datacenters: [Default]
     description: The default Data Center
     state: up
     storageformat: v1
     storagetype: nfs
       clusters: [Default]
         cpu: Intel Westmere Family
         description: The default server cluster
         memory_hugepage: true
         memory_overcommit: 100
       networks: [rhevm2]
         description:
         state: operational
         stp: false
       networks: [rhevm]
         description: Management Network
         state: operational
         stp: false
~~~~


## Install rhev Hypervisor

### Generate the Installation Repository

Download the iso of rhev-h and copy it to the xCAT management node. Run copycds to generate the installation directory:

~~~~
    copycds rhevh-6.2-xxx.iso -n rhevh6.2 -a x86_64
~~~~


Note: the flags -n and -a must be specified so that xCAT knows the type of the iso. The distro name specified by '-n' must be prefixed with 'rhev'.

### Enable Installation Status Update for rhev-h

When the rhev-h installation is finished, xCAT needs to update the installation status of the node by a command named 'rhevhupdateflag'. You need to add the following entry to policy table to enable the running of this command. For security consideration, you can remove this entry after installing (although you will need it again if you redeploy rhev-h on nodes).

~~~~
    mkdef -t policy 7 commands=rhevhupdateflag rule=allow
~~~~


### Define the rhev-h Node

The definition of a rhev-h node is the same as a normal node, except for the addition of the host* attributes. Follow [XCAT_iDataPlex_Cluster_Quick_Start] to create your nodes, and then add the host* attributes using [chdef](http://xcat.sourceforge.net/man1/chdef.1.html). An example lsdef output of a rhev-h node is:

~~~~
    Object name: <rhev-h node name>
       objtype=node
       arch=x86_64
       bmc=<x.x.x.x>
       cons=ipmi
       groups=ipmi,all
       installnic=mac
       mac=<xx:xx:xx:xx:xx:xx>
       mgt=ipmi
       netboot=xnba
       os=rhevh6.2
       profile=compute
       xcatmaster=<x.x.x.x>
       nfsserver=<x.x.x.x>
       ...
~~~~


### Install the rhev-h Host Using xCAT

Provision the host as a common system x node.

~~~~
    nodeset <host> install
    rsetboot <host> net
    rpower <host> boot
~~~~


After installing, the status of &lt;rhev-h&gt; should turn to 'booted'.

~~~~
    lsdef <host> -i status
~~~~


## Configure rhev Hypervisor

### Configure rhev-h attributes

Configure attributes which will be used to configure the rhev-h in xCAT definition.

~~~~
    chdef <rhev-h> hostcluster=mycluster hostinterface=mynet:eth1:static:IP:255.255.255.0
    chdef <rhev-h> hostmanager=<rhevm server> hosttype=rhevh

    Object name: <rhev-h node name>
       hostcluster=mycluster
       hostinterface=mynet:eth1:static:IP:255.255.255.0
       hostmanager=<rhevm server>
       hosttype=rhevh
~~~~


Here's an explanation of the host* attributes. For details see the [node object definition](http://xcat.sourceforge.net/man7/node.7.html). (The specific attribute name within the hypervisor table is given in parentheses.)

  * hostcluster (hypervisor.cluster) - The rhevm cluster that the host will be added to. The default is 'Default' cluster, if not specified.
  * hostinterface (hypervisor.interface) - The configuration for the nics. Refer to [/XCAT_Virtualization_with_RHEV/#configure-rhev-hypervisor](/XCAT_Virtualization_with_RHEV/#configure-rhev-hypervisor) for details.
  * hostmanager (hypervisor.mgr) - The rhev manager (The FQDN of the rhev-m server) for this host.
  * hosttype (hypervisor.type) - Must be set to 'rhevh'.

### Approve the rhev-h Node

After installing a rhev-h node, if the settings for rhev-m (address and password) for the rhev-h host are correct, the rhev-h host will register to the rhev-m automatically. Check the status of rhev-h:

~~~~
    lsvm <host>
      state: pending_approval
~~~~


The status of the registered host should be 'pending_approval', which means rhevm needs to be told to approve it to make it part of the datacenter:

~~~~
    chhypervisor <host> -a
~~~~


### Configure the Network Interfaces

Configure the network interfaces for rhev-h based on the attribute hostinterface. The management network 'rhevm' has been created by default. And the nic that rhev-h is installed over will be automatically configured by dhcp on this network. If you need to configure **additional** nics in the rhev-h node, set the hostinterface attribute with the nic information. The format of the hostinterface attribute is multiple sections of network:interfacename:protocol:IP:netmask:gateway . The sections are separated with '|'. For example:

~~~~
    chdef <rhevh-node> hostinterface='rhevm1:eth1:static:10.1.0.236:255.255.255.0:0.0.0.0|rhevm2:eth2:static:10.2.0.236:255.255.255.0:0.0.0.0'
~~~~


  * network - The logical network which has been created by '[cfgve](http://xcat.sourceforge.net/man1/cfgve.1.html) -t nw' or the default management network 'rhevm'.
  * interfacename - Physical NIC name, for example 'eth0'.
  * protocol - The boot protocol to use to configure the interface: dhcp or static. If setting the protocol to 'dhcp', IP, netmask, and gateway are not needed.
  * IP - The IP address for the interface.
  * netmask - The network mask for the interface.
  * gateway - The gateway for the interface. Note: This field only can be set when the interface is added to the 'rhevm' network.

Once the hostinterface attribute is set correctly, you can push that configuration to the rhev-h node. (You need to do this even if the hostinterface attribute was set at the time of the rhev-h node installation, because the configuration of secondary interfaces doesn't happen during rhev-h node installation.)

~~~~
    chhypervisor <host> -d       # must deactivate the host into maintenance status first
    chhypervisor <host> -n       # configure the nics
    chhypervisor <host> -e       # re-activate the host
~~~~


### Configure Power Management for the rhev-h Host

The power management must be configured for the rhev-h host to make rhev-m monitor the power status of the host. This enables rhev-m to detect failed hosts and to fail over certain roles, like SPM, to another active host.

For IPMI-controlled hosts, the BMC IP, userid, and password are needed by rhevm for power management. xCAT will use the node's attributes 'bmc', 'bmcusername' and 'bmcpassword' to configure the power management. rhev-m will then the IPMI protocol to get the power status of the host.

You can check the 'storage_manager' attribute of a host to know whether it takes the 'SPM' role. If the host which takes the 'SPM' role encounters a problem, power down the host using 'rpower &lt;host&gt; off', then rhevm will move the 'SPM' role to another host automatically.

To display the storage manager role of a host:

~~~~
    #lsvm <host>
      storage_manager: true
~~~~


To configure the power management (based on the bmc, bmcusername, and bmcpassword attributes):

~~~~
    chhypervisor <host> -p
~~~~


### If You Need to Remove a rhev Hypervisor

~~~~
    rmhypervisor <host> -f
~~~~


The flag '-f' means to deactivate the host to 'maintenance' mode before the removing.

Note: if there's only one host in the data center, you have to remove the data center first:

~~~~
    cfgve  -m <rhevm> -t dc -o <mydc> -r
    rmhypervisor <host> -r -f
~~~~


## Setup a Storage Domain for rhev Environment

A storage domain needs a host as its SPM (Storage Pool Manager) to be initiated and needs a data center to be connected to. So before creating of a storage domain, the data center, cluster and 'SPM' host must be created first. The SPM host can be any host which has been added to the cluster.

A data center only can handle one type of storage domain, that means the SD must have the same storage type with Data Center (nfs or localfs).

xCAT supports two types of storage domain:

      nfs: The storage will be created on the nfs server.
      localfs: The storage will be created on the local disk of a host.

  * Set up the DB attributes for a storage domain

The entries for storage domains have to be added to the [virtsd](http://xcat.sourceforge.net/man5/virtsd.5.html) table to specify the attributes before creating them using cfgve. For example:

~~~~
    tabch node=sd virtsd.sdtype=data virtsd.stype=nfs virtsd.location=<nfsserver>:<nfs path> virtsd.host=<SPM-host>
    tabch node=localsd virtsd.sdtype=data virtsd.stype=localfs virtsd.host=<host-for-localfs> virtsd.datacenter=mydc

~~~~



  * virtsd.node - The name of the storage domain.
  * virtsd.sdtype - The type of the storage domain. Valid value: data, iso, export. Default value is 'data'.
  * virtsd.stype - The storage type: 'nfs' or 'localfs'.
  * virtsd.location - The location of the storage. Format: nfsserver:nfspath. The NFS export directory must be configured for read write access and must be owned by vdsm:kvm. 'localfs' ignores this parameter.
  * virtsd.host - A host must be specified for a storage doamin as its SPM (Storage Pool Manager) when initializing the storage domain. The role of SPM may be migrated to another host by rhev-m during the running of the datacenter (for example, when the current SPM encounters an issue or goes to maintenance status).
  * virtsd.datacenter - The datacenter the storage will be attached to. 'Default' datacenter is the default value.

  * Check the data center and host before creating a storage domain:

~~~~
    lsve -t dc -m <rhevm> -o <datacenter name>
    lsvm <host>     # make sure host is in up state
~~~~


  * Run cfgve to create the storage domain, attach it to the datacenter, then activate it:

~~~~
    cfgve -t sd -m <rhevm> -o <storage-domain> -c
~~~~


  * Run lsve to check the result

     Display the storage domain individually:

~~~~
    lsve -t sd -m <rhevm> -o <storage-domain>
~~~~


     The status of the storage domain only can be queried from the data center object:

~~~~
    lsve -t dc -m <rhevm> -o <datacenter name>
~~~~


### Other Storage Domain Operations

  * Remove storage domain

     Remove the storage domain:

~~~~
    cfgve -t sd -m <rhevm> -o <storage-domain> -r
~~~~


     Remove the storage domain by force. It will try to deactivate SD first and detach SD from data center:

~~~~
    cfgve -t sd -m <rhevm> -o <storage-domain> -r -f
~~~~


  * Attach or Detach the storage domain from data center:

~~~~
    cfgve -t sd -m <rhevm> -o <storage-domain> {-a|-b}
~~~~


  * Activate or Deactivate the storage domain when needed:

~~~~
    cfgve -t sd -m <rhevm> -o <storage-domain> {-g|-s}
~~~~


  * Display the datacenter called 'Default'

~~~~
    lsve -t dc -m <rhevm> -o Default
    datacenters: [Default]
     description: The default Data Center
     state: up
     storageformat: v1
     storagetype: nfs
       clusters: [Default]
         cpu: Intel Westmere Family
         description: The default server cluster
         memory_hugepage: true
         memory_overcommit: 100
       storagedomains: [image]
         available: 59055800320
         committed: 0
         ismaster: true
         storage_add: ip9-114-34-211.ppd.pok.ibm.com
         storage_format: v1
         storage_path: /vfsimg
         storage_type: nfs
         type: data
         used: 6442450944
       storagedomains: [sd1]
         available: 5368709120
         committed: 5368709120
         ismaster: false
         storage_add: 9.114.34.226
         storage_format: v1
         storage_path: /wxp/vfs
         storage_type: nfs
         type: data
         used: 47244640256
       networks: [rhevm2]
         description:
         state: operational
         stp: false
       networks: [rhevm]
         description: Management Network
         state: operational
         stp: false
~~~~

  Display the storage domain called 'image':

~~~~
    lsve -t sd -m <rhevm> -o image
    storagedomains: [image]
     available: 59055800320
     committed: 0
     ismaster: true
     storage_add: ip9-114-34-211.ppd.pok.ibm.com
     storage_format: v1
     storage_path: /vfsimg
     storage_type: nfs
     type: data
     used: 6442450944
~~~~

## Define the Virtual Machines

To create your first vm, it is probably easiest to create a [stanza file](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html) with the attributes. For example:

~~~~
    kvm1:
       objtype=node
       arch=x86_64
       groups=vm,all
       installnic=mac
       ip=10.1.0.1
       mgt=rhevm
       netboot=xnba
       os=rhels6.1
       primarynic=mac
       profile=compute
       vmbootorder=network
       vmcluster=mycluster
       vmcpus=2:2
       vmhost=rhevh1
       vmmanager=rhevm
       vmmemory=2G
       vmnicnicmodel=virtio
       vmnics=rhevm:eth0:yes|rhevm2:eth1
       vmstorage=image:10G:system|image:20G:data
       vmstoragemodel=virtio:cow
       vmmaster=Blank
       vmvirtflags=placement_affinity=migratable
~~~~


  * mgt - The management method. Should be set to 'rhevm'.
  * vmhost - The host that the vm will be on. RHEV supports automatically choosing an available host for a vm if the 'vmhost' attribute is not set.
  * vmmanager - The rhev manager for the vm. (The FQDN of rhev-m server.)
  * vmmaster - The template for creating the vm. The default value is 'Blank'. Refer to the clone vm section if you want to create a vm based on a template.
  * vmbootorder - A list of boot devices separated with ','. Valid boot devices: network, hd. If you try to install a vm, just set 'vmbootorder' to 'network' instead of 'network,hd'. (rhev has a bug here). Default value is 'network'.
  * vmcpus - The configuration for CPU. Valid format is: Socket_number:Core_number. Default value is '1:1'.
  * vmmemory - The memory size for the vm. The unit 'g/G' and 'm/M' are supported. The default value is '2G.
  * vmnics - The network interfaces for vm. Valid format is: [network:interfacename:installnic]|[...]. The default value is: rhevm:eth0:yes. That means to add eth0 to rhevm (management network) and set it as install nic.



  * network - The name of logical network for the datacenter;
  * interfacename - The name of network interface for the vm like: eth0, eth1;
  * installnic - To specify whether this nic is the install nic. If it has any value, it means 'yes', otherwise 'no'. Only one nic can be set as the install nic.

  * vmnicnicmodel - The network interface type. Valid values: virtio, e1000, rtl8139, or rtl8139_virtio. Default value is: virtio.
  * vmstorage - Configure the disk for the vm. Valid format: [name_of_storage_domain:size_of_disk:disk_type]|[...].



  * name_of_storage_domain - The name of storage domain.
  * size_of_disk - The size for the new created disk. (The unit 'g/G' and 'm/M' are supported). Larger than 10G is recommended. Otherwise it may run out of space during installation of the OS.
  * disk_type - The disk type. Valid values: system and data. The default type is 'system'. Only one disk can be set to 'system' type. And if the disk is set to 'system' type, this disk is also set to bootable.

  * vmstoragemodel - The type and format of disk interface. Valid format: disk_interface_type:disk_format.



  * disk_interface_type - Valid values: ide, virtio. Default value is 'virtio'.
  * disk_format - Valid value: cow (thin-provisioned, Copy-On-Write), raw (pre-allocated). Default value is 'cow'. Cow allows snapshots, with a small performance overhead. Raw does not allow snapshots, but offers improved performance.

  * vmvirtflags - To set the affinity of the vm to determine whether can be migrated or not. Valid format: [placement_affinity=xxx]. Valid values for 'xxx': migratable, user_migratable, pinned. Default value is 'migratable'.



  * migratable - Can be migrated by rhevm automatically.
  * user_migratable - Only can be migrated by user.
  * pinned - Cannot be migrated.

Note: If you try to deploy a sles virtual machine, use the 'e1000' as the network driver

~~~~
    chdef <virtual machine> vmnicnicmodel=e1000
~~~~


Note: Don't set the console attributes for the vm, since the text console is **not** supported at this time.

~~~~
    chdef kvm2 serialspeed= serialport= serialflow=
~~~~


### Defining Many Virtual Machines

Once you have successfully created and booted a single virtual machine, you'll likely want to define many virtual machines. This is made easier by defining at a group level all of the attributes that are the same for all of your VMs:

~~~~
    chdef -t group vm arch=x86_64 installnic=mac mgt=rhevm netboot=xnba os=rhels6.1 primarynic=mac profile=compute vmbootorder=network vmcluster=mycluster vmmanager=rhevm vmnicnicmodel=virtio vmnics='rhevm:eth0:yes|rhevm2:eth1' vmstoragemodel=virtio:cow vmvirtflags=placement_affinity=migratable
~~~~


The for individual VMs, you only have to set a few attributes. For example:

~~~~
    mkdef kvm2 groups=vm,all ip=10.1.0.2 vmcpus=2:2 vmhost=rhevh1 vmmemory=2G vmstorage='image:10G:system|image:20G:data' vmmaster=Blank
~~~~


## Deploy and Manage the Virtual Machines

  * Define name resolution for the vm:

~~~~
    makehosts hkvm1
    makedns hkvm1
~~~~


  * Create vm, using the attributes in the database. Note: mkvm get the mac used to deploy this vm from the first nic listed in vmnics, or from the nic that was specified as the install nic with something like "rhevm:eth0:yes". It will put this mac in mac.mac.

~~~~
    mkvm hkvm1
~~~~


  * Display the vm:

Display the attributes and status for vms.

~~~~
    lsvm hkvm1
~~~~


  * Change the vm:

Run the chvm command to modify the configuration of virtual machines. Change the node attributes through 'chdef' first and then run 'chvm'. Note: The virtual machine needs to be shutdown before modifying some attributes like: CPU.

~~~~
    chvm hkvm1
~~~~


  * If you need to remove the vm:

~~~~
    rmvm hkvm1
~~~~


  * Deploy the vm:

Note: there's a bug in rhev that has a problem with the order: network,hd. We recommend just setting the boot order to 'network':

~~~~
    rsetboot hkvm1 network


    nodeset hkvm1 osimage=rhels6.1-x86_64-install-compute
    rpower hkvm1 boot
~~~~


  * Display the remote console for a vm

A RHEV vm does not support a text console (rcons), so you must use the graphic console via wvid. This requires the **tigervnc** rpm to be installed first if using the 'vnc' protocol. (And you probaly also want the tigervnc-server rpm installed so you can view the MN desktop if you are not sitting in front of it.)

~~~~
    wvid hkvm1
~~~~


  * If you want to suspend a vm. The suspend action needs a while to finish. Run 'rpower hkvm1 stat' to show the stat. And run 'rpower hkvm1 on' to wake up from suspend.

~~~~
    rpower hkvm1 suspend
~~~~


## Cloning and Migrating Virtual Machines

To clone a vm, you first need to make a vm template (master) from an existing vm. Then you can clone a new vm from this template.

  * Create a template 'tpl01' which can be used to clone vms. The source vm must be turned off before cloning it.

~~~~
    ssh hkvm1 shutdown -P now
    clonevm hkvm1 -t tpl01
~~~~


  * Display a template

During the creating of template, the status of template is 'locked'. You need to wait for the template to be 'ok' before using it.

~~~~
    lsve -t tpl -m <rhevm> -o tpl01
~~~~


  * Clone a vm from a template. That means creating a vm based on the template.

All the attributes will be inherited from template. If you'd like to have specific settings for some attributes, change the setting in the node definition, before running mkvm. For example, if you want to give the new vm an additional disk:

~~~~
    chdef hkvm2 vmstorage=image:10G:data
~~~~


When cloning, the 'vmcluster' attribute will **not** be inherited from the template. You should specify the vmcluster for the node, otherwise the new vm will be added to the 'Default' cluster:

~~~~
    chdef hkvm2 vmcluster=mycluster

    chdef hkvm2 vmmaster=tpl01
    mkvm hkvm2
~~~~


  * If you want to migrate a vm to another rhev-h host:

~~~~
    rmigrate hkvm2 <newhost>
~~~~


## Debugging RHEV

xCAT is using the REST api interface to manage the rhev data center. But the REST api does not implement the full set of functions of RHEV. We recommend that you setup a Windows system with IE which can access the rhev-m through its web interface. It will help you to debug problems you encounter.

### Get the Details of the REST API

For all RHEV related commands, you can run them with '-V' to display the communication details of the REST api.

~~~~
    lsvm hkvm1 -V
~~~~


### Storage Domain can NOT be Accessed

Mostly, this is caused by the SPM host encountering an issue. Use lsvm to show whether a host is acting as the SPM:

~~~~
    lsvm host1
     storage_manager: true  (true => yes; false => no;)
~~~~


If (storage_manager => true), but this host encountered an issue, you have to deactivate this host to maintenance mode before powering it off.

~~~~
    chhypervisor host1 -d
~~~~


If the power management for the host has been set correctly (by 'chhypervisor host -p'), when rhev-m detected the SPM is off, rhev-m will try to transfer the SPM role to another host. It needs at least 2 hosts to enable this function.

If you cannot switch off the SPM from the failed host, try to power off the host first and login to the rhev-m through the web interface, find the host and click the right button and choose 'Confirm 'Host has been rebooted_ to force the switching of the SPM role._

### Encountered Error: 'Cannot connect server to Storage' for a nfs Type of Storage Domain

This issue mostly caused by the incorrect ownership of a directory which is in the nfs path. The owner must be set to 'vdsm:kvm'

~~~~
    chown vdsm:kvm <nfs path>
~~~~

