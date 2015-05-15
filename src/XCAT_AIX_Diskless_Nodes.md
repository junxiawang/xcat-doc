<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Deploying AIX diskless nodes using xCAT](#deploying-aix-diskless-nodes-using-xcat)
  - [Create a diskless image](#create-a-diskless-image)
  - [Update the image - SPOT](#update-the-image---spot)
  - [Define xCAT networks](#define-xcat-networks)
  - [Define P775 HFI networks](#define-p775-hfi-networks)
  - [Create additional NIM network definitions (optional)](#create-additional-nim-network-definitions-optional)
  - [Define the HMC as an xCAT node for non P775 clusters](#define-the-hmc-as-an-xcat-node-for-non-p775-clusters)
  - [Discover the LPARs managed by the HMC](#discover-the-lpars-managed-by-the-hmc)
  - [Define xCAT cluster nodes](#define-xcat-cluster-nodes)
  - [Define xCAT P775 cluster nodes](#define-xcat-p775-cluster-nodes)
  - [Add IP addresses and hostnames to /etc/hosts](#add-ip-addresses-and-hostnames-to-etchosts)
  - [Create and define additional logical partitions for non P775 cluster (optional)](#create-and-define-additional-logical-partitions-for-non-p775-cluster-optional)
  - [Gather MAC information for the boot adapters](#gather-mac-information-for-the-boot-adapters)
  - [Define xCAT groups (optional)](#define-xcat-groups-optional)
  - [Add customization post boot scripts (optional)](#add-customization-post-boot-scripts-optional)
  - [Add customization prescripts (optional)](#add-customization-prescripts-optional)
  - [Power 775 customization postscripts and prescripts](#power-775-customization-postscripts-and-prescripts)
  - [Verify the node definitions](#verify-the-node-definitions)
  - [Initialize the AIX/NIM diskless nodes](#initialize-the-aixnim-diskless-nodes)
  - [Initialize the AIX/NIM diskless nodes for Power 775](#initialize-the-aixnim-diskless-nodes-for-power-775)
  - [Verifying the node initialization before booting (optional)](#verifying-the-node-initialization-before-booting-optional)
  - [Open a remote console (optional)](#open-a-remote-console-optional)
  - [Initiate a network boot](#initiate-a-network-boot)
  - [Initiate a network boot over HFI on Power 775](#initiate-a-network-boot-over-hfi-on-power-775)
  - [Verify the deployment](#verify-the-deployment)
    - [Retry and troubleshooting tips:](#retry-and-troubleshooting-tips)
- [AIX statelite support](#aix-statelite-support)
  - [Statelite options](#statelite-options)
  - [Statelite database tables](#statelite-database-tables)
  - [Statelite user management](#statelite-user-management)
  - [Examples of how to use the AIX statelite support](#examples-of-how-to-use-the-aix-statelite-support)
    - [Provide a persistent logging directory](#provide-a-persistent-logging-directory)
    - [Provide a read-write configuration file](#provide-a-read-write-configuration-file)
    - [Provide a read-only configuration file](#provide-a-read-only-configuration-file)
    - [Using variables in table entries](#using-variables-in-table-entries)
  - [Preserving AIX ODM configuration data on diskless-stateless nodes.](#preserving-aix-odm-configuration-data-on-diskless-stateless-nodes)
  - [Preserving system log files](#preserving-system-log-files)
  - [Using statelite with backup service nodes.](#using-statelite-with-backup-service-nodes)
- [ISCSI dump support](#iscsi-dump-support)
  - [Prerequisites](#prerequisites)
  - [Configuring diskless dump](#configuring-diskless-dump)
  - [Initiating a diskless dump](#initiating-a-diskless-dump)
  - [NIM snap and showdump operations](#nim-snap-and-showdump-operations)
    - [Snap operation](#snap-operation)
    - [Showdump operation](#showdump-operation)
  - [Reading a system dump file](#reading-a-system-dump-file)
- [Special Cases](#special-cases)
  - [Using other NIM resources](#using-other-nim-resources)
  - [Booting a "dataless" node](#booting-a-dataless-node)
  - [Specifying additional values for the NIM node initialization](#specifying-additional-values-for-the-nim-node-initialization)
- [Cleanup](#cleanup)
  - [Removing NIM machine definitions](#removing-nim-machine-definitions)
  - [Removing NIM resources](#removing-nim-resources)
- [Notes](#notes)
  - [Terminology](#terminology)
  - [NIM diskless resources](#nim-diskless-resources)
  - [**NIM Commands**](#nim-commands)
    - [**COSI commands**](#cosi-commands)
    - [**Thin server commands**](#thin-server-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


### Overview



This "How-To" describes how AIX diskless nodes can be deployed and updated using xCAT and AIX/NIM commands.

NIM (Network Installation Management) is an AIX tool that enables a cluster administrator to centrally manage the installation and configuration of AIX and optional software on machines within a networked environment. This document assumes you are somewhat familiar with NIM. For more information about NIM, see the IBM AIX Installation Guide and Reference. (&lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;)

The process described below is one basic set of steps that may be used to boot AIX diskless nodes and is not meant to be a comprehensive guide of all the available xCAT or NIM options.

Before starting this process it is assumed you have completed the following.

  * An AIX system has been installed to use as an xCAT management node.
  * xCAT and prerequisite software has been installed on the management node.
  * The xCAT management node has been configured.
  * One or more LPARs have already been created using the HMC interfaces.
  * The cluster management network has been set up. (The Ethernet network that will be used to do the network installation of the cluster nodes.)

### Deploying AIX diskless nodes using xCAT

#### Create a diskless image

[Create_an_AIX_Diskless_Image](Create_an_AIX_Diskless_Image)

#### Update the image - SPOT
[Update_the_image_-_SPOT](Update_the_image_-_SPOT)

#### Define xCAT networks

Create a network definition for each network that contains cluster nodes. You will need a name for the network and values for the following attributes.

net - The network address.

mask - The network mask.

gateway - The network gateway.


This "How-To" assumes that all the cluster node management interfaces and the xCAT management node interface are on the same network. You can use the xCAT mkdef command to define the network.


For example:


~~~~

    mkdef -t network -o net1 net=9.114.113.0 mask=255.255.255.224 gateway=9.114.113.254
~~~~



Note: NIM also requires network definitions. When NIM was configured in an earlier step the default NIM master network definition was created. The NIM definition should match the one you create for xCAT. If multiple cluster subnets are needed then you will need an xCAT and NIM network definition for each one. A future xCAT enhancement will simplify this by automatically creating NIM network definitions based on the xCAT definitions.

#### Define P775 HFI networks

Make sure that a HFI network definition has been created for the P775 HFI network that supports the P775 cluster compute nodes. You will need to have all the P775 nodes defined to work in this HFI network. The expectation is that for P775 cluster, you will have multiple xCAT service nodes (SN)being assigned in the HFI cluster. This means that compute nodes may not all be using the same xCAT SN as their xCAT master server. To support this environment xCAT has provided a keyword &lt;xcatmaster&gt; that will be used to reference the appropriate xCAT SN working with gateway and other network attributes.

~~~~
    mkdef -t network -o hfinet net=20.0.0.0 mask=255.0.0.0 gateway="<xcatmaster>"
~~~~


#### Create additional NIM network definitions (optional)

For the processs described in this document we are assuming that the xCAT management node and the LPARs are all on the same network.

However, depending on your specific situation, you may need to create additional NIM network and route definitions.

NIM network definitions represent the networks used in the NIM environment. When you configure NIM, the primary network associated with the NIM master is automatically defined. You need to define additional networks only if there are nodes that reside on other local area networks or subnets. If the physical network is changed in any way, the NIM network definitions need to be modified.

To create the NIM network definitions corresponding to the xCAT network definitions you can use the xCAT xcat2nim command.

For example, to create the NIM definitions corresponding to the xCAT "clstr_net" network you could run the following command.

~~~~
    xcat2nim -V -t network -o clstr_net
~~~~


Manual method

The following is an example of how to define a new NIM network using the NIM command line interface.

Step 1

Create a NIM network definition. Assume the NIM name for the new network is "clstr_net", the network address is "10.0.0.0", the network mask is "255.0.0.0", and the default gateway is "10.0.0.247".

~~~~
    nim -o define -t ent -a net_addr=10.0.0.0 -a snm=255.0.0.0 -a routing1='default 10.0.0.247' clstr_net
~~~~


Step 2

Create a new interface entry for the NIM "master" definition. Assume that the next available interface index is "2" and the hostname of the NIM master is "xcataixmn". This must be the hostname of the management node interface that is connected to the "clstr_net" network.

~~~~
    nim -o change -a if2='clstr_net xcataixmn 0' -a cable_type2=N/A master
~~~~


Step 3 - (optional)

If the new subnet is not directly connected to a NIM master network interface then you should create NIM routing information

The routing information is needed so that NIM knows how to get to the new subnet. Assume the next available routing index is "2", and the IP address of the NIM master on the "master_net" network is "8.124.37.24". Assume the IP address on the NIM master on the "clstr_net" network is " 10.0.0.241". This command will set the route from "master_net" to "clstr_net" to be " 10.0.0.241" and it will set the route from "clstr_net" to "master_net" to be "8.124.37.24".

~~~~
    nim -o change -a routing2='master_net 10.0.0.241 8.124.37.24' clstr_net
~~~~


Step 4

Verify the definitions by running the following commands.

~~~~
    lsnim -l master
    lsnim -l master_net
    lsnim -l clstr_net
~~~~



See the NIM documentation for details on creating additional network and route definitions. (IBM AIX Installation Guide and Reference. &lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;)

#### Define the HMC as an xCAT node for non P775 clusters

The xCAT hardware control support requires that the hardware control point for the nodes also be defined as a cluster node.

The following command will create an xCAT node definition for an HMC with a host name of "hmc01". The groups, nodetype, hwtype, mgt, username, and password attributes must be set.

    mkdef -t node -o hmc01 groups="all" nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=def456


#### Discover the LPARs managed by the HMC

This step assumes that the LPARs were already created using the standard HMC interfaces.

Use the xCAT rscan command to gather the LPAR information. In this example we will use the "-z" option to create a stanza file that contains the information gathered by rscan as well as some default values that could be used for the node definitions.

To write the stanza format output of rscan to a file called "mystanzafile" run the following command.

~~~~
    rscan -z hmc01 > mystanzafile
~~~~


This file can then be checked and modified as needed. For example you may need to add a different name for the node definition or add additional attributes and values etc.

Note: The stanza file will contain stanzas for objects other than the LPARs. This information must also be defined in the xCAT database. It is not necessary to modify the non-LPAR stanzas in any way.

#### Define xCAT cluster nodes

This section is to be used when the HMC is the primary hardware control point (hcp) for non P775 clusters. The information gathered by the rscan command can be used to create xCAT node definitions.


Since we have put all the node information in a stanza file we can now pass the contents of the file to the mkdef command to add the definitions to the database.




~~~~
    cat mystanzafile | mkdef -z
~~~~


You can use the xCAT lsdef command to check the definitions (ex. "lsdef -l node01"). After the node has been defined you can use the chdef command to make any additional updates to the definitions, if needed.




#### Define xCAT P775 cluster nodes

The P775 cluster nodes should have been defined as part of the execution for the P775 Hardware Management guide. Refer to the "System P775 Management Guide", ([XCAT_Power_775_Hardware_Management]) for implementation being used to support the Power 775 clusters.

We expect that all the P775 cluster nodes have the proper attributes assigned for the hardware control environments. Since the P775 clusters require xCAT service nodes, the expectation is that the P775 diskless nodes will need to reference reference the xCAT SN for some of the server attributes. It is important the P775 compute nodes have specified the following server based attributes.

~~~~
     monserver, nfsserver, tftpserver, xcatmaster, servicenode
~~~~


You will want to make sure that all postscripts, postbootscripts, and prescripts have been defined for the P775 compute nodes.

#### Add IP addresses and hostnames to /etc/hosts

Make sure all node hostnames are added to /etc/hosts. Refer to:

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node/#configuring-name-resolution](XCAT_AIX_Cluster_Overview_and_Mgmt_Node/#configuring-name-resolution)




#### Create and define additional logical partitions for non P775 cluster (optional)

You can use the xCAT mkvm command to create additional logical partitions for diskless nodes in some cases.


This command can be used to create new partitions based on an existing partition or it can replicate the partitions from a source CEC to a destination CEC.


The first form of the mkvm command creates new partition(s) with the same profile/resources as the partition specified on the command line. The starting numeric partition number and the noderange for the newly created partitions must also be provided. The LHEA port numbers and the HCA index numbers will be automatically increased if they are defined in the source partition.


The second form of this command duplicates all the partitions from the specified source CEC to the destination CEC. The source and destination CECs can be managed by different HMCs.


The nodes in the noderange must already be defined in the xCAT database. The "mgt" attribute of the node definitions must be set to "hmc".


For example, to create a set of new nodes. (The "groups" attribute is required.)




~~~~
    mkdef -t node -o clstrn04-clstrn10 groups=all,aixnodes mgt=hmc
~~~~



To create several new partitions based on the partition for node clstrn01.




~~~~
    mkvm -V clstn01 -i 4 -n clstrn04-clstrn10
~~~~



See the mkvm man page for more details.

#### Gather MAC information for the boot adapters

[Gather_MAC_information_for_the_node_boot_adapters](Gather_MAC_information_for_the_node_boot_adapters)

#### Define xCAT groups (optional)

XCAT supports both _static and dynamic node groups. See [Node_Group_Support] for details. All nodes must belong to at least one static group.

#### Add customization post boot scripts (optional)

xCAT supports the running of customization scripts on the nodes when they are installed. For diskless nodes these scripts are run when the /etc/inittab file is processed during the node boot up.

This support includes:

  * The running of a set of default customization scripts that are required by xCAT.
You can see what scripts xCAT will run by default by looking at the "xcatdefaults" entry in the xCAT "postscripts" database table. ( I.e. Run "tabdump postscripts".). You can change the default setting by using the xCAT chtab or tabedit command. The scripts are contained in the /install/postscripts directory on the xCAT management node.
  * The optional running of customization scripts provided by xCAT.
There is a set of xCAT customization scripts provided in the /install/postscripts directory that can be used to perform optional tasks such as additional adapter configuration. (See the "configiba" script for example.)
  * The optional running of user-provided customization scripts.

To have your script run on the nodes:

  1. Put a copy of your script in /install/postscripts on the xCAT management node. (Make sure it is executable.)
  2. Set the "postscripts" attribute of the node definition to include the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run. For example, if you want to have your two scripts called "foo" and "bar" run on node "node01" you could use the chdef command as follows.

~~~~
    chdef -t node -o node01 -p postscripts=foo,bar
~~~~


(The "-p" means to add these to whatever is already set.)

Note: The customization scripts are run during the boot process (out of /etc/inittab).

#### Add customization prescripts (optional)

This support will be available in xCAT 2.5 and beyond.


The xCAT prescript support is provided to to run user-provided scripts during the node initialization process. These scripts can be used to help set up specific environments on the servers that handle the cluster node deployment. The scripts will run on the install server for the nodes. (Either the management node or a service node.) A different set of scripts may be specified for each node if desired.


One or more user-provided prescripts may be specified to be run either at the beginning or the end of node initialization. The node initialization on AIX is done either by the nimnodeset command (for diskfull nodes) or the mkdsklsnode command (for diskless nodes.)


For more information about using the xCAT prescript support refer to:[Postscripts_and_Prescripts]




####  Power 775 customization postscripts and prescripts

This support will be available in xCAT 2.6 and beyond. Need help from Norm, Hua Zhong, and Power 775 admins to specify which postscripts and prescripts should be used on diskless client. It will help to identify some helpful debug and P775 cluster input here.

The expectation is that P775 nodes will be working with HPC software which will need to be placed as part of the diskless images. The P775 admin should refereence the xCAT HPC Integration documentation to makes sure the HPC software is available.

  * [Setting_up_all_IBM_HPC_products_in_a_Statelite_or_Stateless_Cluster]

#### Verify the node definitions

Verify that the node definitions include the required information.

To get a listing of the node definitions you can use the lsdef command. For example, to display the definitions of all nodes in the group "aixnodes" you could run the following command.

~~~~
    lsdef -t node -l -o aixnodes
~~~~


The output for one diskless node might look something like the following:

~~~~
    Object name: clstrn02
    cons=hmc
    groups=lpar,all
    hcp=clstrhmc01
    hostnames=clstrn02.mycluster.com
    id=2
    ip=10.1.3.2
    mac=001a64f9bfc9
    mgt=hmc
    nodetype=ppc,osi
    hwtype=lpar
    os=AIX
    parent=clstrf1fsp03-9125-F2A-SN024C352
    pprofile=compute

~~~~

Most of these attributes should have been filled in automatically by xCAT.

Note: The length of a NIM object name must be no longer than 39 characters. Since the xCAT definitions will be used to create the NIM object definitions you should limit your xCAT names accordingly.

Note: xCAT supports many different cluster environments and the attributes that may be required in a node definition will vary. For diskless nodes the node definition should include at least the attributes listed in the above example.

#### Initialize the AIX/NIM diskless nodes

You can set up NIM to support a diskless boot of nodes by using the xCAT mkdsklsnode command. This command uses information from the xCAT database and default values to run the appropriate NIM commands.

If you want to have the compute nodes mount the SPOT and ROOT resources from some external NFS server for high availability or performance considerations, please refer to [External_NFS_Server_Support_With_AIX_Stateless_And_Statelite] for more details.

For example, to set up all the nodes in the group "aixnodes" to boot using the SPOT (COSI) named "61cosi" you could issue the following command.




~~~~
    mkdsklsnode -i 61cosi aixnodes
~~~~



The command will define and initialize the NIM machines. It will also set the "provmethod" attribute in the xCAT node definitions to "61cosi ".

Starting with xCAT version 2.5 you can also to specify the "configdump" attribute to specify the type of system do to configure. See the section called "ISCSI dump support" below for details.

To verify that NIM has allocated the required resources for a node and that the node is ready for a network boot you can run the "lsnim -l" command. For example, to check node "node01" you could run the following command.

~~~~
    lsnim -l node01
~~~~





#### Initialize the AIX/NIM diskless nodes for Power 775

You can set up NIM to support a diskless boot of P775 nodes by using the xCAT mkdsklsnode command. This command uses information from the xCAT database and default values to run the appropriate NIM commands.

These diskless images will be created on both the xCAT EMS, and on the xCAT service nodes. The xCAT EMS will contain information about the supported xCAT images, but most of the installation setup for diskless boot will be contained on the xCAT SN. Make sure that your diskless images have been created working with the mknimimage command in a previous step.

The Power 775 cluster allows remote system dump support for diskless nodes. To set up the diskless dump support you must define the NIM dump resource and allocate the resource to the diskless node. If you already have created a diskless osimage then you can just create the NIM dump resource manually and add the name to the xCAT osimage definition.

To create a NIM dump resource you could run a command similar to the following (or use SMIT):

~~~~
    nim -o define -t dump -a server=master -a location=/install/nim/dump/71BCNdskls_dump
    -a max_dumps=1 71BCNdskls_dump
~~~~


To add this to the 71BCNimage osimage definition you could run the following:

~~~~
    chdef -t osimage -o 71BCNimage dump=71BSNdskls_dump
~~~~



The mkdsklsnode will check the xCAT DB for the "osimage" and the compute node. It will then update the diskless spot images to reference any additional updates found in the xCAT DB. For example, to set up all the nodes in the group "p775nodes" to boot using the SPOT (71BCNimage) named "71BCNimage" you could issue the following command.




~~~~
    mkdsklsnode -i 71BCNimage p775nodes -f
~~~~



Same as no-Power 775 clusters, to verify that NIM has allocated the required resources for a node and that the node is ready for a network boot you can run the "lsnim -l" command. For example, to check node "node01" you could run the following command.

~~~~
    lsnim -l node01
~~~~


#### Verifying the node initialization before booting (optional)

Once the mkdsklsnode command completes you can check several things to see if it has been initialized correctly.

  * The /etc/bootptab and /etc/exports files.
  * The &lt;nodename&gt;.info file in the /tftpboot directory.
  * The NIM node definition for the node. ("lsnim -l node01")

#### Open a remote console (optional)

You can open a remote console to monitor the boot progress using the xCAT rcons command. This command requires that you have conserver installed and configured.

If you wish to monitor a network installation you must run rcons before initiating a network boot.

To configure conserver run:

~~~~
    makeconservercf
~~~~


To start a console:

~~~~
    rcons node01
~~~~


Note: You must always run makeconservercf after you define new cluster nodes.

#### Initiate a network boot

Initiate a remote network boot request using the xCAT rnetboot command. For example, to initiate a network boot of all nodes in the group "aixnodes" you could issue the following command.

~~~~
    rnetboot aixnodes
~~~~


Starting with xCAT version 2.5 you can also specify the "-I" option to specify the iscsi boot option. ("rnetboot -I aixnodes") See the section called "ISCSI dump support" below for details.

Note: If you receive timeout errors from the rnetboot command, you may need to increase the default 60-second timeout to a larger value by setting ppctimeout in the site table:

~~~~
    chdef -t site -o clustersite ppctimeout=180
~~~~


#### Initiate a network boot over HFI on Power 775

Starting from xCAT 2.6 and working in Power 775 cluster, there are two ways to initialize a network boot to the compute nodes: one way is that using xCAT rbootseq command to setup the boot device as network adapter for the compute nodes, and after that, you can issue xCAT rpower command to power on or reset the compute node to boot from network, another way is to use xCAT rnetboot command directly. Comparing these two ways, rbootseq/rpower commands don't require the console support and operate in the console, so it has a better performance. It is recommended to use rbootseq/rpower to setup the boot device to network adapter and initialize the network boot in Power 775 cluster.

~~~~
    rbootseq aixnodes hfi
    rpower aixnodes boot
~~~~


#### Verify the deployment

  * You can use the AIX lsnim command to see the state of the NIM installation for a particular node, by running the following command on the NIM master:


~~~~
lsnim -l <clientname>
~~~~

##### Retry and troubleshooting tips:

  * For p6 lpars, it may be helpful to bring up the HMC web interface in a browser and watch the lpar status and reference codes as the node boots.
  * Verify network connections
  * If the rnetboot returns "unsuccessful" for a node, verify that bootp and tftp is configured and running properly.
  * For bootp, view /etc/bootptab to make sure an entry exists for the node.
  * For dhcp, view /var/lib/dhcp/db/dhcpd.leases to make sure an entry exists for the node.
  * Verify that the information in /tftpboot/&lt;node&gt;.info is correct.
  * Stop and restart inetd:

~~~~
    stopsrc -s inetd
    startsrc -s inetd
~~~~


  * Stop and restart tftp:

~~~~
    stopsrc -s tftp
    startsrc -s tftp
~~~~





  * Verify NFS is running properly and mounts can be performed with this NFS server:
  * View /etc/exports for correct mount information.
  * Run the showmount and exportfs commands.
  * Stop and restart the NFS and related daemons:

~~~~
    stopsrc -g nfs
    startsrc -g nfs
~~~~


  * Attempt to mount a file system from another system on the network.
  * If the rnetboot operation is successful, but lsnim shows that the node is stuck at one of the netboot phases, you may need to redo your NIM definitions.

### AIX statelite support

Note: The xCAT statelite implementation for AIX is not the same as the Linux implementation due to basic differences in the base operating systems and their deployment methods.


The xCAT support for AIX diskless nodes includes options for using either a NIM "root" or a "shared_root" resource. You can choose either one for a diskless node deployment.


If you choose the "root" resource then each node will get it's own unique mounted root file system. If the node is shut down and rebooted it will get the same root filesystem. Anything that the node wrote to it's root file system is preserved. This case is referred to as "stateful".


If you choose a "shared_root" resource then the nodes will share the same root filesystem. When an individual node writes to it's root file system it is actually writing to local memory (using the AIX STNFS support). If the node is shut down and rebooted it will get the same root filesystem it originally started with. In this case anything that the node wrote to it's root file system is lost. Any node-specific information or configuration will have to be redone. This case is referred to as "stateless".


The big advantage for using _stateless_ nodes is that they can all share a common "_shared_root_" resource and that there is very little network traffic since the nodes all write to local memory.


For large scale cluster environments it may be advantageous to use a stateless implementation. However there will very likely be a need to have some subset of files or directories be persistent. There also may be a need to specify unique files or directories for each node.


The xCAT on AIX "statelite" implementation provides this type of support. It basically provides the ability to "overlay" specific files or directories over the standard diskless-stateless support.


The AIX stateless support is only available when using the diskless-stateless deployment method.


The statelite setup on the node occurs early in the boot process. Information that is provided in statelite tables will be used during the boot process.


Note: Statelite support must be used with caution especially when modifying system configurations files that are used early in the boot process. For, example if you try to use the /etc/objrepos as a statelite directory the diskless boot will hang. If you are not sure about how a system configuration file change will affect the system, you should try it on a test system before deploying the cluster nodes.

#### Statelite options

The xCAT for AIX statelite support includes the following three options:




  1. **persistent** \- Provide a mounted file or directory that is copied to the xCAT persistent location and then over-mounted read-write on the local file or directory. Anything written to that file or directory is preserved. For example, this could be used to preserve log or trace files or to provide node configuration data for the next time the node is booted. (Requires the statelite table to be filled out with a location for persistent storage - see below).
  2. **rw** \- Provide a file or directory for a node to use when booting, allow the node to write to the file, but on the next diskless boot the original (or latest) version of the file on the server will be used. ( read-write -non-persistent)
  3. **ro** \- Provide files or directories that can be overmounted read-only on the local files or directories. The directory or file will be mounted on the node while the node is running (not just during the boot process), and overmounted on the local version of the file or directory. Changes made to this file or directory on the server will be immediately seen in this file or directory on the node. This option requires that the file or directory to be mounted must be available in one of the entries in the litetree table

The default option is "**rw**", which means if you leave the option attribute as blank,

then the option will be treated as "rw" when the entry in litefile table is used.


The examples provided below illustrate how to use these options.

#### Statelite database tables

In order to specify the information needed for xCAT to do the statelite setup you must update one or more of the xCAT statelite database tables.

There are three xCAT database tables that may need to be updated to implement the xCAT statelite support.

  * The statelite table contains the location on an NFS server where a nodes persistent files and directories are stored. Any file marked persistent in the litefile table will be stored in the location specified in this table for that node.

    Example:

    Assume that the xCAT node group name is "aixnodes", that the server for the NFS mounted directory will be the management node (xcatmn), and that the persistent directory is /nodedata.

    In this case the table entry would look like the following:

~~~~
    #node,image,statemnt,mntopts,comments,disable
    "aixnodes",,"xcatmn:/nodedata/",,,
~~~~


In NFSv4 environment, the option "vers=4" needs to be defined in statelite.mntopts field.

~~~~
    #node,image,statemnt,mntopts,comments,disable
    "aixnodes",,"xcatmn:/nodedata/","vers=4",,
~~~~


    The "image" value is not currently used in this table.

    In the statelite table, The "node" attribute can be filled in with either a node name or a group name.

    In the "statemnt" value the server should always be the name of the server as it would be know by the node.

    Export any directories that are listed in this table before attempting to boot the nodes. Use the export options appropriate to your environment. Make sure the nodes will be able to read-from and write-to the persistent directory.

    You can specify a comma-separated list of options to use when mounting the persistent directory by adding a value for the "mntopts" attribute. (Ex. 'soft') The default is to do a 'hard' mount, the statelite persistent directories will be mounted with option "llock"(local locking) by default. You can use any values supported by the "-o" option of the mount command.

    Also, consider that the internal xCAT code must be able to create additional files and subdirectories under the statelite directories, so make sure the permissions and ownership options will allow this. (For example, you could set the permissions on the statelite directories to "755" and the ownership to "root system".)

  * The litefile table specifies the directories and files for the statelite setup along with the option to use to do the setup. If no option is provided then the default is "rw".

    Example:

    The "image" value can be either the name of the xCAT osimage definition or "ALL" (which means all osimages.)

~~~~
    #image,file,options,comments,disable
    "ALL","/mydata/","persistent",,
    "61cosi","/lppcfg","rw",,
    "61cosi","/etc/lppcfg","ro",,
~~~~


    Note: A directory name should end with a "/".

    Make sure the file or directory permissions and ownership options are set the way you want them to appear on the nodes and that they are appropriate for the statelite option you are using.

    When filling in the litefile table you may wish to include BOTH a directory and a subdirectory (or file). For example, "/foo/" and "/foo/bar". These are referred to as parent-child entries.

    This is supported, however there are certain limitations based on the options you wish to use.

    If the option for the parent directory is "rw" then a child entry could be "rw", "persistent", or "ro".

    If the option for the parent directory is "persistent" then a child entry could be "rw", or "persistent".

    If the option for the parent directory is "ro" then you cannot have any "child" entries.

  * The litetree table controls where the initial content of the files in the litefile table come from, and the long term content of the "ro" files. The "priority" value indicates the search path to use when looking for a file or directory. If the file cannot be found in any of the litetree entries (or there are no entries), then the default will be to use the file contained in the osimage SPOT resource. If the file does not exist in the SPOT then an empty file or directory will be created.

    The directory value must be the location (hostname:path) of a directory that contains the file or directory exactly as specified in the litefile table. For example, if the litefile entry is "/etc/motd" and the litetree directory entry is "/myfiles" then the assumption is that the file would be located in "/myfiles/etc/motd".

    In the directory value the server should always be the name of the server as it would be know by the node.

    Export any directories that are listed in this table before attempting to boot the nodes. Use the export options appropriate to your environment.

    Example:

~~~~
    #priority,image,directory,mntopts,comments,disable
    "1","61cosi","xcatmn:/clstrnodedata/","vers=4",,
    "2","61cosi","xcatsvr:/mydata/","vers=4",,

~~~~

    To update an xCAT database table you can use the tabedit command. ("tabedit table-name") See the tabedit man page for details.

Also see the examples described below.

#### Statelite user management

If you wish to set up something other than root user access to the statelite files or directories on the nodes you must also set up the new user and group IDs on the nodes. (For example, if you wish to set up a persistent logging directory to be written to by a different userid.)

One way to accomplish this is to create a set of configuration files, that include the user information, and include them in the SPOT resource that will be used to boot the node.

The list of configuration files you will need in order to get the exact same user information on the nodes is:

~~~~
    /etc/passwd
    /etc/group
    /etc/security/passwd
    /etc/security/group
    /etc/security/user
    /etc/security/limits

~~~~

You can create these files on the management nodes and copy them to the SPOT resource being used to boot the nodes. (ex. /install/nim/spot/&lt;spot-name&gt;/usr/lpp/bos/inst_root/etc)

Another option is to use the xCAT synclists support. With this support you can create a "synclists" file containing a list of all the extra configuration files you would like added to the SPOT resource. You can then update the SPOT using the "mknimimage -u ... ". For more information on using the synclists support see the following xCAT document. "How to sync files in xCAT" [Sync-ing_Config_Files_to_Nodes]

#### Examples of how to use the AIX statelite support

Refer to the xCAT documents that describe now to boot diskless AIX nodes (mentioned above) for details on the deployment process. The examples below describe additional steps that are needed to utilize the statelite support.

When the mkdsklsnode command is run during the deployment process it will use the information in the statelite tables to make modifications to the osimage  SPOT resource to prepare for the statelite setup. When the node boot process begins an xCAT setup script is run to do the required statelite setup on the node.

You must add the required information to the statelite tables before you run mkdsklsnode.

The "Result" sections below indicate some of the internal structure that is used in the xCAT for AIX implementation. (This may be useful for debug purposes.)




##### Provide a persistent logging directory

Provide a unique persistent logging directory location for the cluster diskless-stateless nodes. (read-write-persistent directory)

Assume that you have an xCAT node group named "aixstateless", that the server for the NFS mounted directory will be the management node (xcatmn), and that the persistent directory is /nodedata. Also assume the xCAT osimage name is "61dskls" and that the directory to store the logs in should be "/logs".

  * Modify the statelite table. ( using tabedit or chtab)

~~~~
    #node,image,statemnt,comments,disable
    "aixstateless",,"xcatmn:/nodedata",,
~~~~


This says that each node in the "aixstateless" node group will store their persistent data in the /nodedata file system mounted from the management node.

Make sure you export any directories that are listed in this table before attempting to boot the nodes.

  * Modify the litefile table. ( using tabedit or chtab)

~~~~
    #image,file,options,comments,disable
    "61dskls","/logs/","persistent",,
~~~~


This says that any node using the "61dskls" osimage should have a /logs/ directory, and that it should be persistent. Notice that a directory name must end in a "/".

Result:

When the node (say node01) writes to it's local /logs directory it really goes to the over-mounted /.statelite/persistent/node01/logs directory. These directories were created during the statelite setup. The /nodedata directory was then mounted from the management node. So when you write to the local /logs directory you are really writing to the /nodedata/node01/logs directoryon the management node.

##### Provide a read-write configuration file

Provide the current version of a configuration file for the node to use when booting, allow the node to write to the file, but on the next install the latest version of the file on the server should be used. (read-write - non-persistent)

Assume that you want any node that uses the osimage named "61dskls" to boot using the configuration file called "/etc/FScfg". The original version of the file should come from the server named "FSserver.cluster.com".

  * Modify the litefile table. ( using tabedit or chtab)

~~~~
    #image,file,options,comments,disable
    "61dskls","/etc/FScfg","rw",,

~~~~

This says that any node using the "61dskls" osimage should have an /etc/FScfg file, and that it should be read-write.

  * Modify the litetree table. ( using tabedit or chtab)

~~~~
    #priority,image,directory,comments,disable
    "1","61dskls","FSserver.cluster.com:/myfiles",,,
~~~~


This says that the initial version of the file should be taken from **"FSserver.cluster.com:/myfiles"**.

Make sure you export any directories that are listed in this table before attempting to boot the nodes.

Result:

When the node is being booted an xCAT script mounts "/myfiles" from "FSserver" and copies "/myfiles/etc/FScfg" into the local /etc/FScfg.

When the node writes to the file it is actually writing to local memory, (the normal stateless function), and the updates are not preserved for the next deployment. When the node is re-deployed the /etc/FScfg file from FSserver is again used for the initial value.

##### Provide a read-only configuration file

Provide the nodes with a unique configuration files to use when booting. The file should not be modified. ( read-only )

The server for the NFS mounted directory is the management node (xcatmn). The osimage name is be "61dskls" and the configuration file is /etc/lppcfg.

  * Modify the litefile table. ( using tabedit or chtab)

~~~~
    #image,file,options,comments,disable
    "61dskls","/etc/lppcfg","ro",,
~~~~


This says that any node using the "61dskls" osimage should have a /etc/lppcfg file, and that it should be read-only.

  * Modify the litetree table. ( using tabedit or chtab)

~~~~
    #priority,image,directory,comments,disable
    "'1","61dskls", "xcatmn:/statelite/",,,
    "2","61dskls", "xcatmn:/",,,

~~~~

This says that any node using the "61dskls" osimage should look for the litefile names, first in the "xcatmn:/statelite/" directory and, if not found, then look for it in "xcatmn:/" (ie. Take the file from the management node.). If the file is not found in either of these places the default will be to take the one that exists in the SPOT "instroot" location. If that doesn't exist then an empty file is created.

Make sure you export any directories that are listed in this table before attempting to boot the nodes.

Result

When the statelite setup is being done xCAT will find the file using the entries in the litetree table. It will then mount the correct file or directory to the local xCAT statelite directories. Then the xCAT statelite directory is used to overmount the local "/etc/lppcfg" file.

When the node reads the local "/etc/lppcfg " file it is actually reading the file mounted from the server specified in the litetree table. Any change to the file located on the server will be seen immediately on the local node.

##### Using variables in table entries

In the previous examples it would also have been possible to specify unique files or directories for each node or set of nodes. To do this you could use variables from the xCAT database. When the statelite setup information is read, the variables in the table will be substituted with the actual values for that node. This would support having one statement cover multiple different nodes. It will also support having unique servers and locations for each node or group of nodes.

For example, a "directory" entry in the litetree table might look like the following:

~~~~
    $noderes.nfsserver:/mydir/$node
~~~~


This would mean that the NFS server would be the value of "$noderes.nfsserver" for this node definition and the location would be "/mydir/&lt;nodename&gt;".

You could also use the variable support for the "statemnt" attribute of the statelite table. For example,

~~~~
    #node,image,statemnt,comments,disable
    "node01",,"$noderes.xcatmaster:/foo/$nodetype.provmethod",,
~~~~


This would say to use the node's service node as the NFS server and "/foo/&lt;osimagename&gt;" as the persistent directory.

#### Preserving AIX ODM configuration data on diskless-stateless nodes.

The xCAT on AIX statelite support may be used to preserve the ODM database updates that are made on the cluster node. Normally any changes that were made on the node would be lost when the node is rebooted.

When the ODM database is updated on the node a record of the update is saved in the /etc/basecust file. This file can be used to restore the database when the node is rebooted.

To enable this you must use the statelite support to create the /etc/basecust file as a persistent file. If this file is available xCAT code will use it to restore the ODM during the boot process.

Typically, for the initial boot of the node, the /etc/basecust would be empty. When the node is booted, devices may be configured etc. which changes the ODM and updates the /etc/basecust file. On subsequent boots the information in the /etc/basecust file is automatically restored.

To set up the /etc/basecust file just add an entry to the litefile table.

For example:

~~~~
    #image,file,options,comments,disable
    "61dskls","/etc/basecust","persistent",,
~~~~


#### Preserving system log files

It may be useful to preserve certain system logs such as errlog, cfglog etc. to use for debugging purposes. You can use the statelite support to do this but there could be complications depending on what files you wish to preserve. For example, creating a persistent errlog file would not work correctly since the errdemon command will not accept a zero-length file when starting the daemon on the node. If you are not sure if a particular file or directory will work correctly then it would be good to try it on a test system first.

If you wish to preserve the files in the /var/adm/ras directory the current recommendation is to create the whole directory as persistent.

For example, in the litefile table you would add an entry similar to the following.

~~~~
    #image,file,options,comments,disable
    "ALL","/var/adm/ras/","persistent",,
~~~~


When the nodes boot up you will then have to move the conslog file to a location outside of the persistent directory. (We have discovered that leaving the conslog file in a persistent directory can occasionally lead to a deadlock situation.)

This can be done by using the xdsh command to run swcons on the cluster nodes.

~~~~
    xdsh <noderange> "/usr/sbin/swcons -p /tmp/conslog"
~~~~


(The /tmp location is just an example, you could move it to a different place.)

At this point whenever the system updates any of the files in /var/adm/ras it will really be updating the files in the persistent directory you specified in the statelite table - which is mounted on the node.

#### Using statelite with backup service nodes.

You can use the statelite and the service node backup support together in an xCAT AIX cluster.

However, when you try to boot a node using it's backup service node it will need to be able to mount the statelite persistent directory etc. If you specify the primary service node as the server of the persistent directory, and it is down, then you will not be able to boot the node.

When setting up the statelite support in this environment you may need to set up a separate server for the statelite files OR make sure there is an up-to-date copy on the backup service node.

For example if you had a statelite directory (&lt;prinSN&gt;:/nodedata) on the primary service node then you could manually create and update a corresponding directory (&lt;bkSN&gt;:/nodedata) on the backup service node.

In this case you could simplify the switch to the backup service node by using variables in the statelite table entries. For example, if you use "$noderes.xcatmaster" in the statelite table then it will always be evaluated as the "xcatmaster" value of the node. When you run the snmove command to switch service nodes it will set the new "xcatmaster" value. When the node is rebooted it will use the statelite directory on the backup service node.

### ISCSI dump support

Starting with xCAT version 2.5.1 you can configure remote system dump support for diskless nodes. To set up the diskless dump support you must define the NIM dump resource and allocate the resource to the diskless node.

When a dump resource is allocated to a client node, NIM creates a sub-directory identified by the client's name for the client's exclusive use. The client uses this directory to store any dump files it creates. For example, "/install/nim/dump/61dskls_dump/node05".

See the AIX/NIM documentation for more information on the diskless (thin server) dump support.

#### Prerequisites

The xCAT support for diskless system dump has the following prerequisites.

  * xCAT version 2.6 or higher
  * Hardware: POWER6 or later
  * Operating system version:



  * AIX 6.1.6 plus SP2 or above
  * AIX 7.1.0 plus SP2 or above

  * Minimum firmware level:



  * Power6 non-blade hardware, minimum FW level is 350_039
  * Power6 blade hardware, minimum FW level is 350_038
  * Power7 HV16, FW level is 730_035
  * Power775, FW level is 730_042.

  * Software prereqs:



  * devices.tmiscsw (Latest available from the AIX Expansion Pack. Additional updates may be available on SP)
  * bos.sysmgt.nim.spot (version 7.1.0.1 or 6.1.6.1 or later)




#### Configuring diskless dump

The process for configuring xCAT diskless dump support is provided below. These additional steps should be integrated into the AIX diskless deployment process described above.

All the software prerequisites listed above must be installed on the xCAT management node and any service nodes that are being used.

All the software prerequisite EXCEPT devices.tmiscsw must also be installed in the SPOT resource being used for the diskless node.




  * Install prerequisite software on the management node

Use the standard AIX interfaces to install the software on the management node. (SMIT, installp, geninstall)




  * Install prerequisite software on service nodes

For the service nodes you can add the filesets to the service node installp_bundle resource you use to install the service node. (ex. xCATaixSN71.) The filesets can be included when you do the initial installation or they can be installed later with the updatenode command.

IMPORTANT: All the prerequisite software must be copied to the lpp_source resource used for the service nodes before attempting to update the service nodes.




  * Install prerequisite software in the SPOT resource used for the compute nodes

You can install additional software in a SPOT at any time using either the xcatchroot command to run the installp command on the SPOT, or you can use the mknimimage -u command. (See the man pages for the commands for details.)

Note: Run **export INUCLIENTS=1** from within xcatchroot environment before you install or update bos.* AIX filesets or any other filesets or rpms that expect an active operating environment or else installp or rpm command may fail.

~~~~
  xcatchroot -i 61cosi "export INUCLIENTS=1;/usr/sbin/installp  ....."
~~~~


To use the mknimimage command you should first update the NIM installp_bundle resource you are using for your diskless osimage. (ex. xCATaixCN71)

IMPORTANT: All the prerequisite software must be copied to the lpp_source resource used for the compute nodes before attempt to update the SPOT.

To see what software has been installed in the SPOT you can run:

~~~~
    nim -o showres 61spot
~~~~


Once you are done updating the SPOT you must always run the NIM "check" operation.

~~~~
    nim -Fo check 61spot
~~~~


  * Create a NIM dump resource

If you are creating a new diskless osimage then you can have the dump resource created automatically when you run mknimimage. See the mknimimage man page for more details.

For example,

~~~~
    mknimimage -V -r -D -t diskless -s 61rte_lpp_source
    61dskls max_dumps=1
~~~~


The "-D" option specifies that a dump resource should be created.

When creating a dump resource there are several dump-related attributes that may be set.

dumpsize - The maximum size for a single dump image the dump resource will accept. Space is not allocated until a client starts to dump. The default size is 50GB. The dump resource should be large enough to hold the expected AIX dump and snap data.

max_dumps \- The maximum number of dumps that can be collected for a client node. For example, if max_dumps is 2, you can save 2 dumps for the client. If 2 dumps have been saved and a new dump is taken, the oldest one is overwritten. The default is one.

notify \- An administrator supplied script that will be invoked when a new dump is captured, or when a dump error occurs on the client. No default value. (NOTE: The AIX support for the notify option is currently broken.)

snapcollect \- Indicates whether snap data should be included with the dump. The snap data file will be saved in the client's dump resource directory. Values are "yes" or "no". The default is "no".

If you already have created a diskless osimage then you can just create the NIM dump resource manually and add the name to the xCAT osimage definition.

To create a NIM dump resource you could run a command similar to the following (or use SMIT):

~~~~
    nim -o define -t dump -a server=master -a location=/install/nim/61dskls_dump
    -a max_dumps=1 61dskls_dump

~~~~

To add this to the 61dskls osimage definition you could run the following:

~~~~
    chdef -t osimage -o 61dskls dump=61dskls_dump
~~~~





  * Initialize the diskless client node

Use the xCAT mkdsklsnode command to define and initialize a NIM diskless machine.

For example:

~~~~
    mkdsklsnode -V -i 61dskls compute15 configdump=full
~~~~


When initializing a node there are two dump-related attributes that may be set.

dumpiscsi_port \- The tcpip port number to use to communicate dump images from the client to the dump resource server. Normally set by default. This port number is used by a dump resource server.

configdump \- Specifies the type of dump to be collected from the client node. The values are "selective", "full", and "none". If the configdump attribute is set to "full" or "selective" the client will automatically be setup to dump to an iSCSI Target device. The "selective" memory dump will avoid dumping user data. The "full" memory dump will dump all the memory of the client partition. Selective and full memory dumps will be collected in the dump resource allocated to the client. Setting the value to "none" means that the dump configuration will not be done on the node. The default value is "selective".

Warning: Part of the initialization process is to allocate the NIM dump resource to the node. If the node has previously used this dump resource to store any dump files the files will be removed. It is advisable to copy any dump files you want to keep to a different location so they are not accidentally removed.




  * Boot the node

Use the xCAT rnetboot command to boot the diskless node.

~~~~
    rnetboot compute15
~~~~





  * Verify that the dump device has been configured on the node. (optional)

Log on to the node or use xdsh to run the AIX sysdumpdev command.

~~~~
    sysdumpdev
~~~~


The result should be something like the following.

~~~~
    primary /dev/hdisk0
    secondary /dev/sysdumpnull
    copy directory /var/adm/ras
    forced copy flag TRUE
    always allow dump FALSE
    dump compression ON
    type of dump fw-assisted
    full memory dump disallow

~~~~

#### Initiating a diskless dump

System dumps are normally initiated when a fatal system error occurs, however, you can also initiate a system dump using the AIX sysdumpstart command.


For example, to initiate a system dump on a diskless node called "compute15" you could run the following:




~~~~
    xdsh compute15 "sysdumpstart -p"

~~~~


The time for the dump to complete will vary depending on the dump options you specify and your network performance etc., however, it could take 2 or more hours to complete in some cases.


When you initiate a dump with the sysdumpstart command the node will be unavailable for the duration of the dump process. The node will automatically reboot after the dump completes.


If you wish to monitor the dump progress you can open a console for the node using the the rcons command. When you see the node rebooted you know the dump should be done. Once the node is rebooted you could also run the "sysdumpdev -L" command on the node to find out if the dump was successful.


The dump file will be created in the NIM dump resource sub-directory created for the node on it's NIM master. The NIM master for the node will either be the xCAT management node or a service node. If the dump file is on a service node you must either copy it to the management node or log on to the service node to debug it.


If the snapcollect attribute was set to "no" (which is the default) then you should get a dump file with a name something like "dump.&lt;date&gt;.BZ"


For example,

~~~~
    "/install/nim/dump/61dskls_dump/clstrn05/dump.2010.06.15.10:47:34.BZ".
~~~~



If the snapcollect attribute was set to "yes" then you will see a snap file with a name similar to " snap.pax.&lt;date&gt;.Z" In this case you must extract the dump file from the snap file.


Use the following process to extract the dump file.

  * Uncompress the snap file


~~~~
    uncompress snap.pax.2010.11.09.15:53:04.Z
~~~~



  * Get the name of the dump file contained in the snap file




~~~~
     pax -v -f snap.pax.2010.11.09.15:53:04 | grep BZ
~~~~





  * Create a subdirectory to save the dump file (ex. /install/nim/dump/710dskls_dump/compute04/savedump)

~~~~
    mkdir savedump
~~~~





  * Copy the snap file to the subdirectory

~~~~
    cp snap.pax. 2010.11.09.15:53:04 savedump
~~~~





  * Extract the dump file

~~~~
    cd savedump
    pax -rvf snap.pax.2010.11.09.15:53:04 -x pax ./dump/dump.2010.11.09.15:52:25.BZ

~~~~


(ex. /install/nim/dump/710dskls_dump/compute04/savedump/dump/dump.2010.11.09.15:52:25.BZ)


Note: You may need to run "ulimit -f unlimited" command to set the file size limit.


Once you have the dump.&lt;date&gt;.BZ file you can uncompress it using the AIX dmpuncompress command. For example:




~~~~
    dmpuncompress dump.2010.11.09.15:52:25.BZ
~~~~



The AIX dmpuncompress command restores the original dump files that were compressed at dump time. The compressed dump file is removed and replaced by an expanded copy. The expanded file has the same name as the compressed version, but without the .BZ

#### NIM snap and showdump operations

You must run nim commands on the NIM master that is being used for the node. In an xCAT cluster this would either be the management node or an AIX service node. You can use the xCAT xdsh command to run the nim command on the service nodes.


For example, to run the NIM command on the xCAT service node named "SN27".




~~~~
    xdsh SN27 "<nim command>"
~~~~


##### Snap operation

The NIM "snap" operation allows you to gather system configuration data from a node at any time without having to initiate a system dump. ("nim -o snap -a snap_flags=&lt;value&gt; nodename") The default value for "snap_flags" is "-a" which means it gathers all system configuration information. See the AIX documentation for details on the AIX snap command usage and the "nim -o snap" operation.


For example:

~~~~
    nim -o snap compute15
~~~~



The snap file (ex. snap.pax.2010.02.17.11:47:38.Z) will be saved in the dump

resource directory. If the snap operation is run again it will remove the existing snap file.




##### Showdump operation

Use the NIM "showdump" operation to see what dump files are available for a node.


To run the command on the management node.




~~~~
    nim -o showdump compute15
~~~~





#### Reading a system dump file

Use the AIX kdb command to read dump files.


For example, after you have run the dmpuncompress command you could run the following:




~~~~
    kdb ./dump.2010.11.09.15:52:25 ./unix_64
~~~~



The "unix_64" should be the one contained in the corresponding SPOT (ex. "/install/nim/spot/&lt;spotname&gt;/usr/lib/boot/unix_64")


If kdb does not work correctly you should check the build levels of the unix_64 and dump file. If they do not match then kdb will not work.


To check the build levels you could run the following commands.




~~~~
    what unix_64 | grep unix
    what dump.2010.11.09.15:52:25 | grep buildinfo

~~~~


If the levels do not match then you should check to make sure the correct prerequisite software levels have been installed and then try running the "nim -Fo check" operation on the SPOT. You will have to shut the nodes down and run rmdsklsnode before updating the SPOT resource.


See the kdb documentation for more details on how to use kdb with dump files.

### Special Cases

#### Using other NIM resources

When you run the mknimimage command to create a new xCAT osimage definition it will create default NIM resources and add their names to the osimage definition. It is also possible to specify additional or different NIM resources to use for the osimage. To do this you can use the "attr=val [attr=val ...]" option. These "attribute equals value" pairs are used to specify NIM resource types and names to use when creating the the xCAT osimage definition. The "attr" must be a NIM resource type and the "val" must be the name of a previously defined NIM resource of that type, (ie. "&lt;nim_resource_type&gt;=&lt;resource_name&gt;"). For example, to create a diskless image and include tmp and home resources you could issue the command as follows. This assumes that the mytmp and myhome NIM resources have already been created by using NIM commands directly.

~~~~
    mknimimage -t diskless -s /dev/cd0 611cosi tmp=mytmp home=myhome
~~~~


These resources will be added to the xCAT osimage definition. When you initialize a node using this definition the mkdsklsnode command will include all the resources when running the "nim -o dkls_init" operation.

See the NIM documentation for more information on supported diskless resources.

#### Booting a "dataless" node

AIX NIM includes support for "dataless" systems as well as "diskless". NIM defines a dataless machine as one that has some local disk space that could be used for paging space and optionally the /tmp and /home. If you wish to use dataless machines you can create an xCAT osimage definition for them with the mknimimage command. When creating the osimage, use the "-t" option to specify a type of "dataless".


For example, to create an osimage definition for "dataless" nodes you could run the command as follows.




~~~~
     mknimimage -s /dev/cd0 -t dataless 53cosi
~~~~



When the node is initialized to use this image the mkdsklsnode command will run the "nim -o dtls_init .." operation.


See the NIM documentation for more information on the NIM support for dataless systems.

#### Specifying additional values for the NIM node initialization

When you run the mkdsklsnode command to initialize diskless nodes the command will run the required NIM commands using some default values. If you wish to use different values you can specify them on the mkdsklsnode command line using the "attr=val [attr=val ...]" option. See the mkdsklsnode man page for the details of what attributes and values are supported.

For example, when mkdsklsnode defines the diskless node there are default values set for the "speed"(100) and "duplex"(full) network settings. If you wish to specify a different value for "speed" you could run the command as follows.

    mkdsklsnode -i myosimage mynode speed=1000


### Cleanup

The NIM definitions and resources that are created by xCAT commands are not automatically removed. It is therefore up to the system administrator to do some clean up of unused NIM definitions and resources from time to time. (The NIM lpp_source and SPOT resources are quite large.) There are xCAT commands that can be used to assist in this process.

#### Removing NIM machine definitions

Use the xCAT rmdsklsnode command to remove all NIM machine definitions that were created for the specified xCAT nodes. This command will not remove the xCAT node definitions.


For example, to remove the NIM machine definition corresponding to the xCAT node named "node01" you could run the command as follows.




~~~~
    rmdsklsnode node01
~~~~



The previous example assumes that the NIM machine definition is the same name as the xCAT node name. If you had used the "-n" option when you created the NIM machine definitions with mkdsklsnode then the NIM machine names would be a combination of the xCAT node name and the osimage name used to initialize the NIM machine. To remove these definitions you must provide the rmdsklsnode command with the name of the osimage that was used.


For example, to remove the NIM machine definition associated with the xCAT node named "node2" and the osimage named "61spot" you could run the following command.




~~~~
    rmdsklsnode -i 61spot node02
~~~~



If the NIM machine is currently running or the machine definition was left in a bad state you can use the rmdsklsnode "-f" (force) option. This will stop the node and deallocate any resources it is using so the machine definition can be removed.


The rmdsklsnode command is intended to make it easier to clean up NIM machine definitions that were created by xCAT. You can also use the AIX nim command directly. See the AIX/NIM documentation for details.




#### Removing NIM resources

Use the xCAT rmnimimage command to remove all the NIM resources associated with a given xCAT osimage definition. The command will only remove a NIM resource if it is not allocated to a node. You should always clean up the NIM node definitions before attempting to remove the NIM resources. The command will also remove the xCAT osimage definition that is specified on the command line.

For example, to remove the "61spot" osimage definition along with all the associated NIM resources run the following command.

~~~~
    rmnimimage -x 61spot
~~~~


If necessary, you can also remove the NIM definitions directly by using NIM commands. See the AIX/NIM documentation for details.

### Notes

#### Terminology

**image** \- The term "image" is used extensively in this document. The precise meaning of an "image" will vary depending on the context in which the term is being used. In general you can think of an image as the basic operating system image as well as other resources etc. that are needed to boot a node. In most cases in this document we will be referring to an image as either an xCAT osimage definition or an AIX/NIM diskless image (called a SPOT or COSI).


**osimage** \- This is an xCAT object that can be used to describe an operation system image. This definition can contain various types of information depending on what will be installed on the node and how it will be installed. The image definition is not node specific and can be used to deploy multiple nodes. It contains all the information that will be needed by the underlying xCAT and NIM support to deploy the node.


**COSI** \- A Common Operating System Image is the name used by AIX/NIM to refer to a SPOT resource. From the NIM perspective this would be an AIX diskless image.


**diskless node**

The operating system is not stored on local disk. For AIX systems this means the file systems are mounted from a NIM server. NIM also supports the concept of a dataless system which has some limited disk space that can be used for certain file systems. See the "Special Cases" section below for information on using additional NIM features.


**diskful node **

For AIX systems this means that the node has local disk storage that is used for the operating system. Diskfull AIX nodes are typically installed using the NIM **rte** or **mksysb** type install methods.

#### NIM diskless resources

The following list describes the required and optional resources that are managed by NIM to support diskless and dataless clients.


**boot** \- Defined as a network boot image for NIM clients.

    The boot resource is managed automatically by NIM and is never explicitly allocated or deallocated by users.

**SPOT** \- Defined as a directory structure that contains the AIX run-time files common to all machines.

    These files are referred to as the usr parts of the fileset.
    The SPOT resource is mounted as the /usr file system on diskless and dataless clients.

    Contains the root parts of filesets. The root part of a fileset is the set of files that may be used to configure the software for a particular machine. These root files are stored in special directories in the SPOT, and they are used to populate the root directories of diskless and dataless clients during initialization.

    The network boot images used to boot clients are constructed from software installed in the SPOT.

    A SPOT resource is required for both diskless and dataless clients.

**root** \- Defined as a parent directory for client "/" (root) directories.

     The client root directory in the root resource is mounted as the "/" (root) file system on the client.

    When the resources for a client are initialized, the client root directory is populated with configuration files.
    These configuration files are copied from the SPOT resource that has been allocated to the same machine.
    A root resource is required for both diskless and dataless clients.
    This resource is managed automatically by NIM.

**dump** \- Defined as a parent directory for client dump files.

    The client dump file in the dump resource is mounted as the dump device for the client.
    A dump resource is optional for both diskless and dataless clients.
    This resource is managed automatically by NIM.

**paging** \- Defined as a parent directory for client paging files.

    The client paging file in the paging resource is mounted as the paging device for the client.
    A paging resource is required for diskless clients and optional for dataless clients.
    This resource is managed automatically by NIM.

**home** \- Defined as a parent directory for client /home directories.

    The client directory in the home resource is mounted as the /home file system on the client.
    A home resource is optional for both diskless and dataless clients.

**shared_home** \- Defined as a /home directory shared by clients.

    All clients that use a shared_home resource will mount the same directory as the /home file system.
    A shared_home resource is optional for both diskless and dataless clients.

**tmp** \- Defined as a parent directory for client /tmp directories.

    The client directory in the tmp resource is mounted as the /tmp file system on the client.
    A tmp resource is optional for both diskless and dataless clients.

**resolv_conf** \- This resource is a file that contains nameserver IP addresses and a network domain name.

    It is copied to the /etc/resolv.conf file in the client's root directory.
    A resolv_conf resource is optional for both diskless and dataless clients.

The AIX/NIM resources for diskless/dataless machines will remain allocated and the node will remain initialized until they are specifically unallocated and uninitialized.

#### **NIM Commands**

##### **COSI commands**

AIX provides commands that may be used to manage the SPOT (or COSI) resource. Refer to the AIX man pages for further details.

  * **mkcosi **Create a COSI (SPOT) for a thin server (diskless or dataless client) to mount and use.
  * **chcosi **Manages a Common Operating System Image (COSI).
  * **cpcosi **Create a copy of a COSI (SPOT).
  * **lscosi **List the properties of a COSI (SPOT).
  * **rmcosi **Remove a COSI (SPOT) from the NIM environment.

##### **Thin server commands**

AIX provides several commands that can be used to manage diskless (also called thin server) nodes. See the AIX man pages for further details.* **mkts **Create a thin server and all necessary resources.

  * **lsts **List the status and software content of a thin server.
  * **swts **Switch a thin server to a different COSI.
  * **dbts **Perform a debug boot on a thin server.
  * **rmts **Remove a thin server from the NIM environment.

