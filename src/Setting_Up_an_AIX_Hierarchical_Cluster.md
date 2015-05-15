<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Switch to a relational database](#switch-to-a-relational-database)
- [Setup for Power 775 Cluster](#setup-for-power-775-cluster)
- [Defining Cluster Nodes](#defining-cluster-nodes)
- [Install the Service Nodes](#install-the-service-nodes)
  - [Assign the nodes to their Service Nodes](#assign-the-nodes-to-their-service-nodes)
  - [Specify the services provided by the service nodes](#specify-the-services-provided-by-the-service-nodes)
    - [Add NTP setup script (optional)](#add-ntp-setup-script-optional)
  - [Add IP addresses and hostnames to /etc/hosts](#add-ip-addresses-and-hostnames-to-etchosts)
  - [Create a Service Node operating system image](#create-a-service-node-operating-system-image)
  - [Create an image_data resource (optional)](#create-an-image_data-resource-optional)
  - [Add required service node software](#add-required-service-node-software)
    - [XCAT and prerequisite software](#xcat-and-prerequisite-software)
    - [Additional diskless dump software (optional)](#additional-diskless-dump-software-optional)
    - [Additional Power 775 software (optional)](#additional-power-775-software-optional)
    - [Include additional files for Power 775 support](#include-additional-files-for-power-775-support)
    - [Using NIM installp_bundle resources](#using-nim-installp_bundle-resources)
    - [Check the osimage (optional)](#check-the-osimage-optional)
  - [Define xCAT networks](#define-xcat-networks)
  - [Create additional NIM network definitions (optional)](#create-additional-nim-network-definitions-optional)
  - [Define an xCAT service group](#define-an-xcat-service-group)
  - [Set Service Node Attributes (optional)](#set-service-node-attributes-optional)
  - [Include customization scripts](#include-customization-scripts)
    - [Add "servicenode" script for service nodes](#add-servicenode-script-for-service-nodes)
    - [Add NTP setup script (optional)](#add-ntp-setup-script-optional-1)
    - [Add additional adapters configuration script (optional)](#add-additional-adapters-configuration-script-optional)
        - [Configuring Secondary Adapter](#configuring-secondary-adapter)
        - [Configuring xCAT SN Hierarchy Ethernet Adapters(Power 775 DFM Only)](#configuring-xcat-sn-hierarchy-ethernet-adapterspower-775-dfm-only)
    - [Power 775 configuration scripts](#power-775-configuration-scripts)
    - [Add disk mirroring script (optional)](#add-disk-mirroring-script-optional)
  - [Create the connections between hdwr_svr and sn-CEC(Power 775 DFM only)](#create-the-connections-between-hdwr_svr-and-sn-cecpower-775-dfm-only)
  - [Gather MAC information for the install adapters](#gather-mac-information-for-the-install-adapters)
  - [Create NIM client &amp; group definitions](#create-nim-client-&amp-group-definitions)
  - [P775 and HPC Integration](#p775-and-hpc-integration)
  - [Create prescripts (optional)](#create-prescripts-optional)
  - [Initialize the AIX/NIM nodes](#initialize-the-aixnim-nodes)
  - [Open a remote console (optional)](#open-a-remote-console-optional)
  - [Initiate a network boot](#initiate-a-network-boot)
    - [Network boot for Power 775](#network-boot-for-power-775)
  - [Verify the deployment](#verify-the-deployment)
    - [Retry and troubleshooting tips](#retry-and-troubleshooting-tips)
  - [Configure additional adapters on the service nodes (optional)](#configure-additional-adapters-on-the-service-nodes-optional)
  - [Verify Service Node configuration](#verify-service-node-configuration)
- [Setup of GPFS I/O Server nodes](#setup-of-gpfs-io-server-nodes)
- [Install the cluster nodes](#install-the-cluster-nodes)
  - [Planning for external NFS server(optional)](#planning-for-external-nfs-serveroptional)
  - [Create a diskless image](#create-a-diskless-image)
  - [Update the image - SPOT](#update-the-image---spot)
  - [Set up statelite support (for diskless-stateless nodes only)](#set-up-statelite-support-for-diskless-stateless-nodes-only)
  - [Define xCAT networks](#define-xcat-networks-1)
  - [Set conserver and monserver](#set-conserver-and-monserver)
  - [Create the connections between hdwr_svr and non-sn-CEC(Power 775 DFM only)](#create-the-connections-between-hdwr_svr-and-non-sn-cecpower-775-dfm-only)
  - [Gather MAC information for the node boot adapters](#gather-mac-information-for-the-node-boot-adapters)
  - [Define xCAT groups (optional)](#define-xcat-groups-optional)
  - [Add IP addresses and hostnames to /etc/hosts](#add-ip-addresses-and-hostnames-to-etchosts-1)
  - [Verify the node definitions](#verify-the-node-definitions)
  - [Verify the node definitions for boot over HFI on Power 775](#verify-the-node-definitions-for-boot-over-hfi-on-power-775)
  - [Set up post boot scripts (optional)](#set-up-post-boot-scripts-optional)
  - [Power 775 configuration scripts (optional)](#power-775-configuration-scripts-optional)
  - [Set up prescripts (optional)](#set-up-prescripts-optional)
  - [Initialize the AIX/NIM diskless nodes](#initialize-the-aixnim-diskless-nodes)
    - [Verifying the node initialization before booting (optional)](#verifying-the-node-initialization-before-booting-optional)
  - [Open a remote console (optional)](#open-a-remote-console-optional-1)
  - [Initiate a network boot](#initiate-a-network-boot-1)
  - [Initiate a network boot for Power 775 support](#initiate-a-network-boot-for-power-775-support)
  - [Verify the deployment](#verify-the-deployment-1)
- [Switching to a backup service node](#switching-to-a-backup-service-node)
  - [Initial deployment](#initial-deployment)
  - [Synchronizing statelite persistent files](#synchronizing-statelite-persistent-files)
  - [Monitoring the service nodes](#monitoring-the-service-nodes)
  - [Switch to a backup SN](#switch-to-a-backup-sn)
    - [Move the nodes to the new service nodes](#move-the-nodes-to-the-new-service-nodes)
    - [Statelite migration](#statelite-migration)
    - [Initialize the nodes on the new SN (optional)](#initialize-the-nodes-on-the-new-sn-optional)
    - [Shut down the node](#shut-down-the-node)
    - [Reboot the diskless nodes](#reboot-the-diskless-nodes)
  - [Switching back](#switching-back)
- [Cleanup](#cleanup)
  - [Removing NIM machine definitions](#removing-nim-machine-definitions)
  - [Removing NIM resources](#removing-nim-resources)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

In an xCAT cluster the single point of control is the xCAT management node. However, in order to provide sufficient scaling and performance for large clusters, it may also be necessary to have additional servers to help handle the deployment and management of the cluster nodes. In an xCAT cluster these additional servers are referred to as service nodes.

For an xCAT on AIX cluster there is a primary NIM master which is on the xCAT management node(MN). The service nodes(SN) are configured as additional NIM masters. All commands are run on the management node. The xCAT support automatically handles the NIM setup on the low level service nodes and the distribution of the NIM resources. All installation resources for the cluster are managed from the primary NIM master. The NIM resources are automatically replicated on the low level masters when they are needed.

Important All xCAT service nodes must be at the same release/ version as the xCAT Management Node. This version can be checked by running nodels -v.

    nodels -v
    Version 2.3 (svn r4039, built Mon Aug 24 13:51:18 EDT 2009)


You can set up one or more service nodes in an xCAT cluster. The number you need will depend on many factors including the number of nodes in the cluster, the type of node deployment, the type of network etc.

A service node may also be used to run user applications in most cases.

For reliability, availability, and serviceability purposes users may wish to configure backup service nodes in hierarchical cluster environments.

The backup service node will be configured to be able to quickly take over from the original service node if a problem occurs.

This is not an automatic failover feature. You will have to initiate the switch from the primary service node to the backup manually. The xCAT support will handle most of the setup and transfer of the nodes to the new service node.

See Section 5, "Using a backup service node", later in this document for details on how to set this up.

An xCAT service node must be installed with xCAT software as well as additional prerequisite software.

AIX service nodes must be diskfull (NIM standalone) systems. Diskless xCAT service nodes are not currently supported for AIX.

In the process described below the service nodes will be deployed using a standard AIX/NIM "rte" network installation. If you are using multiple service nodes you may want to consider creating a "golden" mksysb image that you can use as a common image for all the service nodes. See the xCAT document named "Cloning AIX nodes (using an AIX mksysb image)" for more information on using mksysb images. See [XCAT_AIX_mksysb_Diskfull_Nodes].

In this document it is assumed that the cluster nodes will be diskless. The cluster nodes will be deployed using a common diskless image. It is also possible to deploy the cluster nodes using "rte" or "mksysb" type installs.

By default NIM uses bootp to install remote systems. However, you can switch to using dhcp if needed. See the description of how to do this in [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]. If you are managing a Power 775 cluster you will have to set up dhcp on your management node to do hardware discovery. The current recommendation is to also use dhcp to install the service nodes. The service nodes can be left to use th default bootp when installing the compute nodes over HFI.

The hardware management steps included in this document all refer to the Power 775 hardware. I you are using another hardware platform refer to [XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems] for hardware management details.

Before starting this process it is assumed you have configured an xCAT management node by following the process described in the AIX overview document. [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]

## Switch to a relational database

When using service nodes you must switch to a database that supports remote access. XCAT currently supports MySQL, PostgreSQL, and DB2. As a convenience, the xCAT site provides downloads for MySQL and PostreSQL. The default SQlite database cannot be used.

( [xcat-postgresql-snap201007150920.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-postgresql-snap201007150920.tar.gz/download) and [xcat-mysql-201007271215.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/xcat-mysql-201007271215.tar.gz/download) )

If you are using Power 775 hardware in your cluster you must use DB2.

See the following xCAT documents for instructions on how to configure these databases.

[Setting_Up_MySQL_as_the_xCAT_DB]

[Setting_Up_PostgreSQL_as_the_xCAT_DB]

[Setting_Up_DB2_as_the_xCAT_DB]

When configuring the database you will need to add access for each of your service nodes. The process for this is described in the documentation mentioned above.

The sample xCAT installp_bundle files mentioned below contain commented-out entries for each of the supported databases. You must edit the bundle file you use to un-comment the appropriate database rpms. If the required database packages are not installed on the service node then the xCAT configuration will fail.

The database tar files that are available on the xCAT web site may contain multiple versions of RPMs - one for each AIX operating system level. When you are copying required software to your lpp_source resource make sure you copy the rpm that coincides with your OS level. Do not copy multiple versions of the same rpm to the NIM lpp_source directory.

## Setup for Power 775 Cluster

    NOTE: This support will be available in xCAT 2.6 and beyond.


[Power_775_Cluster_on_MN](Power_775_Cluster_on_MN)

## Defining Cluster Nodes

Note: At this point your hardware components should be defined in the xCAT database.

The steps for defining nodes in a Power 775 cluster are discussed in [XCAT_Power_775_Hardware_Management]. See the section named "Define the LPAR Nodes and Create the Service/Utility LPARS".

For more information on methods you can use to define xCAT nodes refer to the following document. ([Defining_cluster_nodes_on_System_P] )

## Install the Service Nodes

Modify the xCAT node definitions to indicate if the node is a service node, and if not, indicate the server for the node.

For service nodes:

  * Add "service" to the "groups" attribute of all the service nodes.
  * Specify the services that the service nodes will be providing. At a minimum, the "setupnameserver" attribute of the service nodes must be explicitly set to "yes" or "no". (Ex. "setupnameserver=no")

~~~~
    chdef cl2sn01 -p groups=service setupnameserver=no
~~~~


### Assign the nodes to their Service Nodes

For non-service nodes:

  * Add the name of the service node to the node definition. (Ex. "servicenode=xcatSN01") This is the name of the service node as it is known by the management node.
  * Set the "xcatmaster" attribute. This must be the name of the service node as it is known by the node. This may or may not be the same value as the "servicenode " attribute.

~~~~
    chdef cl2cn27 servicenode=cl2sn01 xcatmaster=cl2sn01-hfi
~~~~


Note: if the "servicenode" and "xcatmaster" values are not set then xCAT will default to use the value of the "master" attribute in the xCAT "site" definition.

Other part of the service node definition and configuration , refer to the following documentation. It is the
same for Linux or AIX.

[Setting_Up_a_Linux_Hierarchical_Cluster/#define-the-service-nodes-in-the-database](Setting_Up_a_Linux_Hierarchical_Cluster/#define-the-service-nodes-in-the-database)



### Specify the services provided by the service nodes

Distributing services to your service nodes will help alleviate the load on your management node and prevent potential bottlenecks from occurring in your cluster. You choose the services that you would like started on your service node by setting the attributes in the servicenode table. When the xcatd daemon is started or restarted on the service node, a check will be made by the xCAT code that the services from this table are configured on the service node and running, and will stop and start the service as appropriate.

This check will be done each time the xcatd is restarted on the service node. If you do not wish this check to be done, and the service not to be restarted, use the reload option when starting the daemon on the service node:

~~~~
     xcatd -r
~~~~


For example, the following command will setup the service node group to start the named (DNS),conserver, NFS and ipforwarding automatically on the service nodes. You may want to setup other services such as the monitoring server on the service node. For a description of the services and what is setup see:

~~~~
    tabdump -d servicenode
~~~~


or the servicenode table manpage:

http://xcat.sourceforge.net/man5/servicenode.5.html

~~~~
     chdef -t group -o service setupnameserver=1 setupnfs=1 setupconserver=1 setupipforward=1
~~~~


For Power775 clusters, as a you should set the following:

~~~~
    chdef -t group -o service   setupipforward=1
~~~~


Note: When using the chdef commands, the attributes names for setting these server values do not match the actual names in the servicenode table. This is to avoid conflicts with corresponding attribute names in the noderes table. To see the correct attribute names to use with chdef:

~~~~
    chdef -h -t node
~~~~


and search for attributes that begin with "setup".

If you do not want any service started on the service nodes, then run the following command to define the service nodes but start no services:

~~~~
     chdef -t group -o service setupnameserver=0
~~~~


#### Add NTP setup script (optional)

Note the setupntp attribute in the servicenode table is not use. You must use the setupntp postscripts and add it to the postscripts to be run on the service nodes and cluster nodes. For example:

To have xCAT automatically set up ntp on the cluster nodes or servicenodes you must add the setupntp script to the list of postscripts that are run on the nodes. What this does is points to the nodes master as it's ntp server. For the service nodes it would be the Management Node, for the compute node it would be it's service node.

To do this you can either modify the "postscripts" attribute for each node individually or you can just modify the definition of a group that all the nodes belong to.

For example, if all your nodes belong to the group "compute" then you could add setupntp to the group definition by running the following command.

~~~~
    chdef -p -t group -o compute postscripts=setupntp
~~~~


If all your service nodes belong to the group "service" then run the following command.

~~~~
    chdef -p -t group -o service postscripts=setupntp
~~~~


Note:In hierarchy cluster, the ntpserver for the compute nodes will be pointed to the their service nodes,
 so if you want to set up ntp on the compute nodes, make sure the ntp server is set up correctly on the service nodes, the setupntp postscript can set up both the ntp client and the ntp server.

### Add IP addresses and hostnames to /etc/hosts

Make sure all node hostnames are added to /etc/hosts. Refer to the section titled "Add cluster nodes to the /etc/hosts file" in the following document for details:

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node]

If you are working on a Power 775 cluster, to bring up all the HFI interfaces on service nodes, make sure IP/hostnames for all the HFI interfaces on service nodes have been added to /etc/hosts.

### Create a Service Node operating system image

Reminder: If you wish to create separate file systems for your NIM resources you should do that before continuing. For example, you might want to create a separate file system for /install and one for any dump resources you may need. This is described in [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]

Install the bos.sysmgt.nim.spot and bos.sysmgt.nim.master filesets.

Use the xCAT mknimimage command to create an xCAT osimage definition as well as the required NIM installation resources.

An xCAT osimage definition is used to keep track of a unique operating system image and how it will be deployed.

In order to use NIM to perform a remote network boot of a cluster node the NIM software must be installed, NIM must be configured, and some basic NIM resources must be created.

The mknimimage will handle all the NIM setup as well as the creation of the xCAT osimage definition. It will not attempt to reinstall or reconfigure NIM if that process has already been completed. See the mknimimage man page for additional details.

Note: If you wish to install and configure NIM manually you can run the AIX nim_master_setup command (Ex. "nim_master_setup -a mk_resource=no -a device=&lt;source directory&gt;") or use other NIM commands such as nimconfig.

By default, the mknimimage command will create the NIM resources in sub-directories of /install. Some of the NIM resources are quite large (1-2G) so it may be necessary to increase the file size limit.

For example, to set the file size limit to "unlimited" for the user "root" you could run the following command.

~~~~
     /usr/bin/chuser fsize=-1 root
~~~~


When you run the command you must provide a source for the installable images. This could be the AIX product media, a directory containing the AIX images, or the name of an existing NIM lpp_source resource. You must also provide a name for the osimage you wish to create. This name will be used for the NIM SPOT resource that is created as well as the name of the xCAT osimage definition. The naming convention for the other NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 61cosi_lpp_source").

In this example we need resources for installing a NIM "standalone" type machine using the NIM "rte" install method. (This type and method are the defaults for the mknimimage command but you can specify other values on the command line.)

For example, to create an osimage named "610SNimage" using the images contained in the /myimages directory you could issue the following command.

~~~~
     mknimimage -s /myimages 610SNimage
~~~~


(Creating the NIM resources could take a while!)

Note: To populate the /myimages directory you could copy the software from the AIX product media using the AIX gencopy command. For example you could run "gencopy -U -X -d /dev/cd0 -t /myimages all".

By default the command will create NIM lpp_source, spot, and bosinst_data resources. You can also specify alternate or additional resources on the command line using the "attr=value" option, ("&lt;nim resource type&gt;=&lt;resource name&gt;").

For example:

~~~~
     mknimimage -s /myimages 610SNimage resolv_conf=my_resolv_conf

~~~~

Any additional NIM resources specified on the command line must be previously created using NIM interfaces. (Which means NIM must already have been configured. )

Note: Another alternative is to run mknimimage without the additional resources and then simply add them to the xCAT osimage definition later. You can add or change the osimage definition at any time. When you initialize and install the nodes xCAT will use whatever resources are specified in the osimage definition.

When the command completes it will display the osimage definition which will contain the names of all the NIM resources that were created. The naming convention for the NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 610SNimage_lpp_source"), except for the SPOT name. The default name for the SPOT resource will be the same as the osimage name.

The xCAT osimage definition can be listed using the lsdef command, modified using the chdef command and removed using the rmnimimage command. See the man pages for details.

In some cases you may also want to modify the contents of the NIM resources. For example, you may want to change the bosinst_data file or add to the resolv_conf file etc. For details concerning the NIM resources refer to the NIM documentation.

You can list NIM resource definitions using the AIX lsnim command. For example, if the name of your SPOT resource is "610SNimage" then you could get the details by running:

~~~~
    lsnim -l 610SNimage
~~~~


To see the actual contents of a NIM resource use

~~~~
    nim -o showres <resource name>
~~~~


For example, to get a list of the software installed in your SPOT you could run:

~~~~
    nim -o showres 610SNimage
~~~~


### Create an image_data resource (optional)

If you are using PostgreSQL or DB2 you must make sure the node starts out with enough file system space to install the database software. This can be done using the NIM image_data resource.


A NIM image_data resource is a file that contains stanzas of information that is used when creating file systems on the node. To use this support you must create the file , define it as a NIM resource, and add it to the xCAT osimage definition.


To help simplify this process xCAT ships a sample image_data file called

~~~~
    /opt/xcat/share/xcat/image_data/xCATsnData
~~~~


This file assumes you will have at least 70G of disk space available. It also sets the physical partition size to 128M.


It sets the following default file system sizes.

~~~~
    /var -> 5G
    /opt -> 10G
    / -> 30G
    /usr -> 4G
    /tmp -> 3G
    /home -> 0.12G
    /admin -> 0.12 G
    /livedump -> 0.25G

~~~~


If you need to change any of these be aware that you must change two stanzas for each file system. One is the fs_data and the other is the corresponding lv_data.


Once you have settled on a final version of the image_data file you can copy it to the location that will be used when defining NIM resources.

    (ex. /install/nim/image_data/myimage_data)



To define the NIM resource you could use the SMIT interfaces or run a command similer to the following.




~~~~
    nim -o define -t image_data -a server=master -a location=/install/nim/image_data/myimage_data myimage_data

~~~~


To add these bundle resources to your xCAT osimage definition run:

~~~~
    chdef -t osimage -o 610SNimage image_data=myimage_data
~~~~


### Add required service node software

#### XCAT and prerequisite software

An xCAT AIX service node must also be installed with additional xCAT and prerequisite software.

The required software is specified in the sample bundle files discussed below.

To simplify this process xCAT includes all required xCAT and open source dependent software in the following files:

~~~~
    core-aix-<version>.tar.gz
    dep-aix-<version>.tar.gz tar
~~~~


The required software must be copied to the NIM lpp_source that is being used for the service node image. The easiest way to do this is to use the following command:

~~~~
    nim -o update
~~~~


NOTE: The latest xCAT dep-aix package actually includes multiple sub-directories corresponding to different versions of AIX. Be sure to copy the correct versions of the rpms to your lpp_source directory.

For example, assume all the required xCAT rpm software has been copied and unwrapped in the /tmp/images directory.

Assuming you are using AIX 6.1 you could copy all the appropriate rpms to your lpp_source resource (ex. 610SNimage_lpp_source) using the following commands:

~~~~
    nim -o update -a packages=all -a source=/tmp/images/xcat-dep/6.1 610SNimage_lpp_source
    nim -o update -a packages=all -a source=/tmp/images/xcat-core/  610SNimage_lpp_source
~~~~


For Power 775 Clusters, you should add the DFM and hdwr_svr into the list of packages to be installed on the SN:

~~~~
  mkdir -p /install/post/otherpkgs/aix/ppc64/dfm
~~~~
Copy the DFM and hdwr_svr the packages to the suggested target location on the xCAT MN:

~~~~

 /install/post/otherpkgs/aix/ppc64/dfm

~~~~

Edit the bundle for AIX Service Node. Assuming you are using AIX 71, you should edit the file:

~~~~

 /opt/xcat/share/xcat/installp_bundles/xCATaixSN71.bnd
~~~~

And add the following into the bundle file:

~~~~

 I:isnm.hdwr_svr
 R:xCAT-dfm*
~~~~

The required software must be copied to the NIM lpp_source that is being used for the service node image. Assuming you are using AIX 7.1 you could copy all the appropriate rpms to your lpp_source resource (ex. 710SNimage_lpp_source) using the following commands:

~~~~
 nim -o update packages=all -a source=/install/post/otherpkgs/aix/ppc64/dfm 710SNimage_lpp_source
~~~~

The NIM command will find the correct directories and update the appropriate lpp_source resource directories.

After Initiate a network boot in [Setting_Up_an_AIX_Hierarchical_Cluster] or Initiate a network boot for Power 775 support in [Setting_Up_an_AIX_Hierarchical_Cluster], the DFM and hdwr_svr will be installed on the AIX SN automatically. 


 


The NIM command will find the correct directories and update the appropriate lpp_source resource directories.

#### Additional diskless dump software (optional)

The AIX ISCSI dump support requires the devices.tmiscw fileset. This is currently available from the AIX Expansion Pack.

If you plan to create dump resources for your diskless nodes you must have this software installed on you management node and service nodes.

You can use standard AIX support to install this on the management node.

For the service nodes you should copy this fileset to your lpp_source resources (as mentioned above) and then include it in the installp_bundle file (described below).

#### Additional Power 775 software (optional)

The Power 775 cluster requires additional software to support HFI. These additional installp file sets must also be copied to the NIM lpp_source resource you are using. This includes HFI and related ML0 device drivers.

The following is a list of the required software.


~~~~
    devices.chrp.IBM.HFI
    devices.common.IBM.hfi
    devices.common.IBM.ml
    devices.msg.en_US.chrp.IBM.HFI
    devices.msg.en_US.common.IBM.hfi
    devices.msg.en_US.common.IBM.ml

~~~~


Note: This software is not yet generally available. It can be provided on request.

Copy the filesets to your lpp_source resource directory.

You could do this by placing the required packages into a directory (ex. /hfi) and then execute the "nim -o update" command to copy images to lpp_source directory.

For example:

~~~~
    nim -o update -a packages=all -a source=/hfi/ 71BSNimage_lpp_source



~~~~

Create an installp_bundle containing the require HFI filesets.

For example you could create the bundle file xCATaixHFIdd.bnd in the /install/nim/installp_bundle directory. The contents would be something like the following:


~~~~
    # HFI and ML installp packages
    I:devices.chrp.IBM.HFI.rte
    I:devices.common.IBM.hfi.rte
    I:devices.common.IBM.ml
    I:devices.msg.en_US.chrp.IBM.HFI.rte
    I:devices.msg.en_US.common.IBM.hfi.rte
    I:devices.msg.en_US.common.IBM.ml

~~~~

Define the NIM isntallp_bundle resource using the "nim -o define" command.

    nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/xCATaixHFIdd.bnd xCATaixHFIdd


Add the name of the HFI installp_bundle resource to the osimage definition that is being used for the service nodes.

~~~~
    chdef -t osimage -o 71BSNimage installp_bundle=xCATaixHFIdd

~~~~

#### Include additional files for Power 775 support

The xCAT administrator may want to include additional files that they want to be synchronized on the Power 775 service nodes. These additional files and postscripts can be included in the /install/postscripts/synclist file.

To include the synclist file to the xCAT osimage used for the service nodes, you can run a command similar to the following.

~~~~
    chdef -t osimage -o 610SNimage synclists=/install/postscripts/synclist
~~~~


#### Using NIM installp_bundle resources

To get all this additional software installed we need a way to tell NIM to include it in the installation. To facilitate this, xCAT provides sample NIM installp bundle files. (Always make sure that the contents of the bundle files you use are the packages you want to install and that they are all in the appropriate lpp_source directory.)

Starting with xCAT version 2.4.3 there will be a set of bundle files to use for installing a service node. They will be in:

~~~~
    /opt/xcat/share/xcat/installp_bundles
~~~~


There is a version corresponding to the different AIX OS levels. (xCATaixSN71.bnd, xCATaixSN61.bnd etc.) Just use the one that corresponds to the version of AIX you are running.

Note: For earlier version of xCAT the sample bundle files are shipped as part of the xCAT tarball file.

To use the bundle file you need to define it as a NIM resource and add it to the xCAT osimage definition.

Copy the bundle file ( say xCATaixSN61.bnd ) to a location where it can be defined as a NIM resource, for example "/install/nim/installp_bundle".

To define the NIM resource you can run the following command.

    nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/xCATaixSN61.bnd xCATaixSN61


To add this bundle resources to your xCAT osimage definition run:

~~~~
    chdef -t osimage -o 610SNimage installp_bundle="xCATaixSN61"
~~~~


Important Note: The sample xCAT bundle files mentioned above contain commented-out entries for each of the supported databases. You must edit the bundle file you use to uncomment the appropriate database rpms. If the required database packages are not installed on the service node then the xCAT configuration will fail.

#### Check the osimage (optional)

To avoid potential problems when installing a node it is adviseable to verify that all the additional software that you wish to install has been copied to the appropriate NIM lpp_source directory.

Any software that is specified in the "otherpkgs" or the "installp_bundle" attributes of the xCAT osimage definition must be available in the lpp_source directories.

To find the location of the lpp_source directories run the "lsnim -l &lt;lpp_source_name&gt;" command:

~~~~
    lsnim -l 610SNimage_lpp_source
~~~~


If the location of your lpp_source resource is "/install/nim/lpp_source/610SNimage_lpp_source/" then you would find rpm packages in "/install/nim/lpp_source/610SNimage_lpp_source/RPMS/ppc" and you would find your installp and emgr packages in "/install/nim/lpp_source/610SNimage_lpp_source/installp/ppc".

To find the location of the installp_bundle resource files you can use the NIM "lsnim -l" command. For example,

~~~~
    lsnim -l xCATaixSN61
~~~~


Starting with xCAT version 2.4.3 you can use the xCAT chkosimage command to do this checking. For example:

~~~~
    chkosimage -V 610SNimage
~~~~


In addition to letting you know what software is missing from your lpp_source the chkosimage command will also indicate if there are multiple files that match the entries in your bundle file. This can happen when you use wild cards in the packages names added to the bundle file. In this case you must remove any old packages so that there is only one rpm selected for each entry in the bundle file.

To automate this process you may be able to use the "-c" (clean) option of the chkosimage command. This option will keep the rpm that was most recently written to the directory and remove the others. (Be careful when using this option!)

For example,

~~~~
    chkosimage -V -c 610SNimage

~~~~

### Define xCAT networks

Create an xCAT network definition for each Ethernet or HFI network that contains cluster nodes. You will need a name for the network and values for the following attributes.

net The network address.

mask The network mask.

gateway The network gateway.

You can use the xCAT mkdef command to define the network.

For example, to define an ethernet network called net1:

~~~~
    mkdef -t network -o net1 net=9.114.0.0 mask=255.255.255.224 gateway=9.114.113.254
~~~~


To create an HFI network definition called "hfinet" you could run a command similar to the following.

~~~~
    mkdef -t network -o hfinet net=20.0.0.0  mask=255.0.0.0 gateway=20.7.4.5
~~~~


### Create additional NIM network definitions (optional)

Depending on your specific cluster setup, you may need to create additional NIM network and route definitions.

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
    nim -o change -a routing2='masternet 10.0.0.241 8.124.37.24' clstrnet_
~~~~


Step 4

Verify the definitions by running the following commands.

~~~~
    lsnim -l master
    lsnim -l master_net
    lsnim -l clstr_net
~~~~



See the NIM documentation for details on creating additional network and route definitions. (_IBM AIX Installation Guide and Reference_. &lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;)

### Define an xCAT service group

If you did not already create the xCAT "service" group when you defined your nodes then you can do it now using the mkdef or chdef command.

There are two basic ways to create xCAT node groups. You can either set the "groups" attribute of the node definition or you can create a group directly. You can set the "groups" attribute of the node definition when you are defining the node with the mkdef command or you can modify the attribute later using the chdef command. For example, if you want to create the group called "service" with the members sn01 and sn02 you could run chdef as follows.

~~~~
    chdef -t node -p -o sn01,sn02 groups=service
~~~~


The "-p" option specifies that "service" be added to any existing value for the "groups" attribute.

The second option would be to create a new group definition directly using the mkdef command as follows.

~~~~
    mkdef -t group -o service members="sn01,sn02"
~~~~


These two options will result in exactly the same definitions and attribute values being created.

### Set Service Node Attributes (optional)

In some cases it may be necessary to set server-related attributes for the service nodes.

This includes the nfserver, tftpserver, monserver, xcatmaster, and servicenode attributes.

The default values for these attributes is the IP address of the management node.

For example, you might want to boot the service node from some other service node rather than the management. Or you might want your nfs server to be something other than the management node. Etc.

You can use the chdef command to set these attributes.

For example, to set the xcatmaster and servicenode attributes of the service node named sn42 you could run the following command.

~~~~
    chdef sn42  servicenode=10.0.0.214 xcatmaster=10.0.0.214
~~~~


There are additional service node attributes that can be set to automatically start and setup services on the service nodes.

~~~~
    tabdump -d servicenode
~~~~


to see AIX supported attributes.

### Include customization scripts

xCAT supports the running of customization scripts on the nodes when they are installed.

This support includes:

  * The running of a set of default customization scripts that are required by xCAT.
You can see what scripts xCAT will run by default by looking at the "xcatdefaults" entry in the xCAT "postscripts" database table. ( I.e. Run "tabdump postscripts".). You can change the default setting by using the xCAT chtab or tabedit command. The scripts are contained in the /install/postscripts directory on the xCAT management node.
  * The optional running of customization scripts provided by xCAT.
There is a set of xCAT customization scripts provided in the /install/postscripts directory that can be used to perform optional tasks such as additional adapter configuration.
  * The optional running of user-provided customization scripts.

To have your script run on the nodes:

  1. Put a copy of your script in /install/postscripts on the xCAT management node. (Make sure it is executable.)
  2. When using service nodes make sure the postscripts are copied to the /install/postscripts directories on each service node.
  3. Set the "postscripts" attribute of the node definition to include the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run. For example, if you want to have your two scripts called "foo" and "bar" run on node "node01" you could use the chdef command as follows.

~~~~
    chdef -t node -o node01 -p postbootscripts=foo,bar
~~~~


(The "-p" means to add these to whatever is already set.)

The customization scripts are run during the post boot process ( during the processing of /etc/inittab).

Note: For diskfull installs if you wish to have a script run after the install but before the first reboot of the node you can create a NIM script resource and add it to your osimage definition.

#### Add "servicenode" script for service nodes

You must add the "servicenode" script to the postbootscripts attribute of all the service node definitions. To do this you could modify each node definition individually or you could simply modify the definition of the "service" group.

For example, to have the "servicenode" postscript run on all nodes in the group called "service" you could run the following command.

~~~~
    chdef -p -t group service postbootscripts=servicenode
~~~~


Note: There is a sample postscript called "make_sn_fs" in /install/postscripts that may be used to automatically create file systems when installing a service node. If you wish to use this script, (or a modified version), you should make sure this script is run before the "servicenode" script. You could do this by setting the "postbootscripts" attribute of the service node definitions as follows:

    chdef -p -t group service postbootscripts="make_sn_fs,servicenode"


#### Add NTP setup script (optional)

To have xCAT automatically set up ntp on the cluster nodes you must add the setupntp script to the list of postscripts that are run on the nodes.

To do this you can either modify the "postscripts" attribute for each node individually or you can just modify the definition of a group that all the nodes belong to.

For example, if all your nodes belong to the group "compute" then you could add setupntp to the group definition by running the following command.

~~~~
    chdef -p -t group -o compute postscripts=setupntp
~~~~


Note: In hierarchy cluster, the ntpserver for the compute nodes will be pointed to the their service nodes, so if you want to set up ntp on the compute nodes, make sure the ntp server is set up correctly on the service nodes, the setupntp postscript can set up both the ntp client and the ntp server.

#### Add additional adapters configuration script (optional)

It is possible to have additional adapter interfaces automatically configured when the nodes are booted. XCAT provides sample configuration scripts for both Ethernet and IB adapters. These scripts can be used as-is or they can be modified to suit you particular environment. The Ethernet sample is /install/postscript/configeth. When you have the configuration script that you want you can add it to the "postscripts" attribute as mentioned above. Make sure your script is in the /install/postscripts directory and that it is executable.

Note: If you plan to support DFM hardware control working through the xCAT SN, it is important that the xCAT SN has the proper ethernet network adapters configured working with the xCAT HW service VLAN. The admin can automatically configure these network adapters as part of the secondary adapter configuration script.

Note: AIX user in xCAT 2.8.3 or later should use postscript configeth_aix instead of configeth.




###### Configuring Secondary Adapter

To configure secondary adapters, see [Configuring_Secondary_Adapters](Configuring_Secondary_Adapters).

###### Configuring xCAT SN Hierarchy Ethernet Adapters(Power 775 DFM Only)

See the following documentation [Configuring_xCAT_SN_Hierarchy_Ethernet_Adapter_DFM_Only](Configuring_xCAT_SN_Hierarchy_Ethernet_Adapter_DFM_Only).

####  Power 775 configuration scripts

There are several post scripts required for the Power 775 cluster that are used to update the xCAT service nodes. They are used to configure NIM, HFI interfaces, and setup the xCAT DB2 client environment.

The following postscripts should be available in the /install/postscripts/ directory on the management node.

~~~~
    confighfi
    db2install
    odbcsetup
~~~~



The names of the scripts listed above must be added to the "postbootscripts" attribute of the the service node (or service group) definitions.

The order of the scripts is important.

The "db2install" script must come before the "servicenode" script and the "odbcsetup" script must come after.

To set the postscripts attribute you can run a command similar to the following.

~~~~
    chdef -t group service postbootscripts=confighfi,db2install,servicenode,odbcsetup
~~~~


Verify the "postbootscripts" setting by listing the service node definitions.

~~~~
    lsdef service
~~~~


Make sure the scripts are all listed and in the correct order.

Some scripts are included by default or by setting other attributes. It may be useful to check the xCAT "postscripts" table if you are having difficulty getting the list of postscripts correct.

~~~~
    tabedit postscripts
~~~~


The Power 775 service node requires additional files. These are all specified in the /install/postscripts/synclist file.

To include them in the xCAT osimage used for the xCAT service nodes you can run a command similar to the following.

~~~~
    chdef -t osimage -o 71BSNimage synclists=/install/postscripts/synclist
~~~~





    Note: Currently the xCAT for AIX support does not distinguish between the "postscripts" and "postbootscripts" attributes.    Both are treated as post boot scripts and are run after the initial boot of the node.


#### Add disk mirroring script (optional)

To automatically set up disk mirroring on the service nodes when they are installed you can use the "aixvgsetup" sample script provided by xCAT.

This script is available in the /install/postscripts directory on the management node. It can be copied and modified to include the the disks you wish to include in the rootvg volume group.

You must add the aixvgsetup script to the list of postscripts that are run on the nodes.

To do this you can either modify the "postscripts" attribute for each service node individually or you can just modify the definition of a group that all the service nodes belong to.

For example, if all your service nodes belong to the group "service" then you could add aixvgsetup to the group definition by running the following command.

~~~~
    chdef -p -t group -o service postscripts=aixvgsetup
~~~~


This script assumes that the disk(s) is available and usable as a boot disk.

It will run the AIX extendvg, mirrorvg, bosboot, and bootlist commands.

### Create the connections between hdwr_svr and sn-CEC(Power 775 DFM only)

[Configuring_xCAT_SN_Hierarchy_Ethernet_Adapter_DFM_Only](Configuring_xCAT_SN_Hierarchy_Ethernet_Adapter_DFM_Only)


### Gather MAC information for the install adapters

[NOTE] you should get the MAC information for the service node firstly. After finishing the OS provision for service node, and create the connections between the hdwr_svr on the service node and the non-sn-CEC, you can get the MAC information for the compute node.

[Gather_MAC_information_for_the_node_boot_adapters](Gather_MAC_information_for_the_node_boot_adapters)

### Create NIM client &amp; group definitions

You can use the xCAT xcat2nim command to automatically create NIM machine and group definitions based on the information contained in the xCAT database. By doing this you synchronize the NIM and xCAT names so that you can use the same target names when running either an xCAT or NIM command.


To create NIM machine definitions for your service nodes you could run the following command.




~~~~
    xcat2nim -t node service
~~~~



To create NIM group definition for the group "service" you could run the following command.

~~~~
    xcat2nim -t group -o service
~~~~



To check the NIM definitions you could use the NIM lsnim command or the xCAT xcat2nim command. For example, the following command will display the NIM definitions of the nodes contained in the xCAT group called "service", (from data stored in the NIM database).




~~~~
    xcat2nim -t node -l service
~~~~


### P775 and HPC Integration

If you are working with High Performance Computing (HPC) or with the P775 cluster, you will need to execute additional setup procedures where you need to specify additional post scripts for the xCAT SN. At this time time you should reference the HPC Integration documentation, and pay close attention to the HPC LPPs that need to be configured on the xCAT SN.

  * [Setting_up_all_IBM_HPC_products_in_a_Stateful_Cluster]

The expectation is that xCAT software will automatically setup the xCAT DB2 client environment on the P775 xCAT SN. It is important that you setup the proper DB2 environment to be exported from the xCAT EMS. Please reference the xCAT DB2 documentation where you should focus on the requirements needed for the xCAT SN.

  * [Setting_Up_DB2_as_the_xCAT_DB]

### Create prescripts (optional)

The xCAT prescript support is provided to to run user-provided scripts during the node initialization process. These scripts can be used to help set up specific environments on the servers that handle the cluster node deployment. The scripts will run on the install server for the nodes. (Either the management node or a service node.) A different set of scripts may be specified for each node if desired.

One or more user-provided prescripts may be specified to be run either at the beginning or the end of node initialization. The node initialization on AIX is done either by the nimnodeset command (for diskfull nodes) or the mkdsklsnode command (for diskless nodes.)


You can specify a script to be run at the beginning of the nimnodeset or mkdsklsnode command by setting the prescripts-begin node attribute.


You can specify a script to be run at the end of the commands using the prescripts-end node attribute.

See the following for the format of the prescript table: [Postscripts_and_Prescripts]







The attributes may be set using the chdef command.


For example, if you wish to run the foo and bar prescripts at the beginning of the nimnodeset command you would run a command similar to the following.




~~~~
    chdef -t node -o node01 prescripts-begin="standalone:foo,bar"
~~~~


When you run the nimnodeset command it will start by checking each node definition and will run any scripts that are specified by the prescripts-begin attributes.


Similarly, the last thing the command will do is run any scripts that were specified by the prescripts-end attributes.

### Initialize the AIX/NIM nodes

You can use the xCAT nimnodeset command to initialize the AIX standalone nodes. This command uses information from the xCAT osimage definition and default values to run the appropriate NIM commands.


For example, to set up all the nodes in the group "service" to install using the osimage named "610SNimage" you could issue the following command.




~~~~
    nimnodeset -i 610SNimage service
~~~~


To verify that you have allocated all the NIM resources that you need you can run the "lsnim -l" command. For example, to check the node "clstrn01" you could run the following command.




~~~~
    lsnim -l clstrn01

~~~~

The command will also set the "profile" attribute in the xCAT node definitions to "610SNimage ". Once this attribute is set you can run the nimnodeset command without the "-i" option.

### Open a remote console (optional)

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

### Initiate a network boot

Initiate a remote network boot request using the xCAT rnetboot command. For example, to initiate a network boot of all nodes in the group "service" you could issue the following command.

~~~~
    rnetboot service
~~~~


Note: If you receive timeout errors from the rnetboot command, you may need to increase the default 60-second timeout to a larger value by setting ppctimeout in the site table:

~~~~
    chdef -t site -o clustersite ppctimeout=180
~~~~


#### Network boot for Power 775

This xCAT support is available starting with xCAT 2.6.

With the Power 775 support xCAT includes an additional method for performing a network boot of the nodes.

For p775 systems you can run the xCAT rbootseq command to set the boot device, and then run xCAT rpower command to power on or reset the nodes to boot from the HFI network.

The rbootseq/rpower command sequence actually provides better performance and is recommended for p775 systems booting of nodes over the HFI network.

To initiate a network boot of the service nodes you could run the following commands.

~~~~
    rbootseq aixnodes net
    rpower aixnodes boot
~~~~


### Verify the deployment

  * If you opened a remote console using rcons you can watch the progress of the installation.
  * For p6 lpars, it may be helpful to bring up the HMC web interface in a browser and watch the lpar status and reference codes as the node boots.
  * You can use the AIX lsnim command to see the state of the NIM installation for a particular node, by running the following command on the NIM master:

~~~~
    lsnim -l <clientname>
~~~~


  * When the node is booted you can log in and check if it is configured properly. For example, is the password set?, is the timezone set?, can you xdsh to the node etc.

#### Retry and troubleshooting tips

  * If a node did not boot up:
  * Verify network connections.
  * For dhcp, check /etc/dhcpsd.cnf to make sure an entry exists for the node
  * Stop and restart tftp:

~~~~
    stopsrc -s tftpd
    startsrc -s tftpd
~~~~


  * Verify NFS is running properly and mounts can be performed with this NFS server:
  * View /etc/exports for correct mount information.
  * Run the showmount and exportfs commands.
  * Stop and restart the NFS and related daemons:

~~~~
    stopsrc -g nfs
    startsrc -g nfs

~~~~

  * Attempt to mount a filesystem from another system on the network.
  * You may need to reset the NIM client definition and start over.

~~~~
    nim -Fo reset node01
    nim -o deallocate -a subclass=all node01
~~~~





  * If the node booted but one or more customization scripts did not run correctly:
  * You can check the /var/log/messages file on the management node and the var/log/xcat/xcat.log file on the node (if it is up) to see if any error messages were produced during the installation.
  * Restart the xcatd daemon (xcatstop &amp; xcatstart (xCAT2.4 restartxcatd)) and then re-run the customization scripts either manually or by using updatenode.

### Configure additional adapters on the service nodes (optional)

If additional adapter configuration is required on the service nodes you could either use the xdsh command to run the appropriate AIX commands on the nodes or you may want to use the updatenode command to run a configuration script on the nodes.


XCAT provides sample adapter interface configuration scripts for Ethernet and IB. The Ethernet sample is /install/postscripts/configeth. It illustrate how to use a specific naming convention to automatically configure interfaces on the node. You can modify this script for your environment and then run it on the node using updatenode. First copy your script to the /install/postscripts directory and make sure it is executable. Then run a command similar to the following.




~~~~
    updatenode clstrn01 myconfigeth
~~~~



If you wish to configure IB interfaces please refer to: [Managing_the_Infiniband_Network]

Note: AIX user in xCAT 2.8.3 or later should use postscript configeth_aix instead of configeth.

### Verify Service Node configuration

During the node boot up there are several xCAT post scripts that are run that will configure the node as an xCAT service node. It is advisable to check the service nodes to make sure they are configured correctly before proceeding.


There are several things that can be done to verify that the service nodes have been configured correctly.




  1. Check if NIM has been installed and configured by running "lsnim" or some other basic NIM command on the service node.
  2. Check to see if all the additional software has been installed. For example, Run "rpm -qa" to see if the xCAT and dependency software is installed.
  3. Try running some xCAT commands such as "lsdef -a"to see if the xcatd daemon is running and if data can be retrieved from the xCAT database on the management node.
  4. If using SSH for your remote shell try to ssh to the service nodes from the management node.
  5. Check the system services, as mentioned earlier in this document, to make sure the service node can respond to a network boot request.

## Setup of GPFS I/O Server nodes

    TBD - This is pointer to the GPFS documentation to setup GPFS I/O servers on the Power 775 cluster.


## Install the cluster nodes

### Planning for external NFS server(optional)

xCAT AIX stateless/statelite compute nodes need to mount NFS directories from the service node, the failure on the service node will immediately bring down all the compute nodes served by the service node, external NFS server can be used to provide high availability NFS service for the AIX stateless/statelite compute nodes to avoid single point of failure by the service node. Refer to [External_NFS_Server_Support_With_AIX_Stateless_And_Statelite] for more details.

### Create a diskless image

[Create_an_AIX_Diskless_Image](Create_an_AIX_Diskless_Image)

### Update the image - SPOT

[Update_the_image_-_SPOT](Update_the_image_-_SPOT)




### Set up statelite support (for diskless-stateless nodes only)

This support is available in xCAT version 2.5 and beyond.

The xCAT statelite support for AIX provides the ability to "overlay" specific files or directories over the standard diskless-stateless support.

There is a complete description of the statelite support in&nbsp;: [XCAT_AIX_Diskless_Nodes#AIX_statelite_support](XCAT_AIX_Diskless_Nodes/#aix_statelite_support).

To set up the statelite support you must:

  1. fill in one or more to the statelite tables in the xCAT database.
  2. Run the "mknimimage -u" command which will use that information to modify the SPOT resource.

Note: You could also fill in the statelite tables before initially running the mknimimage to create the osimage. (Rather than doing the setup later with the "-u" option.)

### Define xCAT networks

Create a network definition for each network that contains cluster nodes. You will need a name for the network and values for the following attributes.

net The network address.

mask The network mask.

gateway The network gateway.


This "How-To" assumes that all the cluster node management interfaces and the xCAT management node interface are on the same network. You can use the xCAT mkdef command to define the network.

For example:

~~~~
    mkdef -t network -o net1 net=9.114.113.224 mask=255.255.255.224 gateway=9.114.113.254
~~~~


If you want to set the nodes' xcatmaster as the default gateway for the nodes, the gateway can be set to keyword "&lt;xcatmaster&gt;", xCAT code will automatically interpret the keyword to corresponding ip address or hostname. Here is an example:

~~~~
    mkdef -t network -o net1 net=9.114.113.224 mask=255.255.255.224 gateway=<xcatmaster>
~~~~


Please be aware that the ipforwarding should be enabled on all the xcatmaster nodes that will be acting as default gateway, you can set the ipforward to 1 in the servicenode table or run AIX command "no -o ipforwarding=1" manually to enable the ipforwarding.

Note: If the cluster node management interfaces and the xCAT management node interface are on the different networks, you need to define the cluster network manually on the service nodes.

For example: Assume the NIM name for the cluster network is "clstr_net", the network address is "10.0.0.0", the network mask is "255.0.0.0", and the default gateway is "10.0.0.247".

~~~~
     nim -o define -t ent -a net_addr=10.0.0.0 -a snm=255.0.0.0 -a routing1='default 10.0.0.247' clstr_net
~~~~


### Set conserver and monserver

If the service nodes will be running the conserver or monserver daemons for the compute nodes instead of the xCAT managment node running the daemons for all of the nodes, set these attributes to the node's service node:

~~~~
     chdef compute1 conserver=sn1 monserver=sn1
     chdef compute2 conserver=sn2 monserver=sn2

~~~~

### Create the connections between hdwr_svr and non-sn-CEC(Power 775 DFM only)

In Power 775 DFM environment, all the hardware control commands are sent to the CEC through hdwr_svr. So before running hardware control commands, you should create the connections between the hdwr_svr and the CEC. In hierarchical cluster, you should create the connections between the hdwr_svr and sn-CEC, and after the service node has been installed, and then create the connections between the hdwr_svr and non-sn-CEC. Please refer to&nbsp;:

[Configuring_xCAT_SN_Hierarchy_Ethernet_Adapter_DFM_Only]


### Gather MAC information for the node boot adapters

[Gather_MAC_information_for_the_node_boot_adapters](Gather_MAC_information_for_the_node_boot_adapters)

### Define xCAT groups (optional)

XCAT supports both static and dynamic node groups. See the section titled "xCAT node group support" in the "xCAT2 Top Doc" document for details on using xCAT groups.

See the following doc for nodegroup support: [Node_Group_Support]

### Add IP addresses and hostnames to /etc/hosts

Make sure all node hostnames are added to /etc/hosts. Refer to the section titled "Add cluster nodes to the /etc/hosts file" in the following document for details: [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]

If you are working on a Power 775 cluster, to bring up all the HFI interfaces on service nodes, make sure IP/hostnames for all the HFI interfaces on service nodes have been updated in /etc/hosts.

### Verify the node definitions

Verify that the node definitions include the required information.

To get a listing of the node definition you can use the lsdef command. For example to display the definitions of all nodes in the group "aixnodes" you could run the following command.

~~~~
    lsdef -t node -l -o aixnodes
~~~~


The output for one diskless node might look something like the following:

~~~~
    Object name: clstrn02
    cons=hmc
    groups=lpar,all
    servicenode=clstrSN1
    xcamaster=clstrSN1-en1
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

Note: xCAT supports many different cluster environments and the attributes that may be required in a node definition will vary. For diskless nodes using a servicenode, the node definition should include at least the attributes listed in the above example.

Make sure "servicenode" is set to the name of the service node as known by the management node and "xcatmaster" is set to the name of the service node as known by the node.

To modify the node definitions you can use the chdef command.

For example to set the xcatmaster attribute for node "clstrn01" you could run the following.

~~~~
    chdef -t node -o clstrn01 xcatmaster=clstrSN1-en1
~~~~


### Verify the node definitions for boot over HFI on Power 775

Most of the node attributes to boot over HFI are the same as boot over ethernet above. Following is an example as an output of lsdef command.

~~~~
    lsdef -t node -l -o aixnodes


    Object name: clstrn02
    arch=ppc64
    cons=fsp
    groups=lpar,all
    hcp=Server-9125-F2C-SNP7IH019-A
    id=9
    ip=20.4.32.224
    mac=020004030004
    mgt=fsp
    nodetype=ppc,osi
    hwtype=lpar
    os=AIX
    parent=Server-9458-100-SNBPCF007-A
    pprofile=compute
    servicenode=clstrSN1
    xcatmaster=clstrSN1-hf0

~~~~

Note: xcatmaster attribute is setting to the hostname which is a HFI interface hostname on services, it should has been updated in /etc/hosts and synchronized to service node already.

Note: mac attribute is an HFI MAC address that got from compute node.

Note: ip attribute is setting to the HFI IP address that works on compute node.

### Set up post boot scripts (optional)

xCAT supports the running of customization scripts on the nodes when they are installed. For diskless nodes these scripts are run when the /etc/inittab file is processed during the node boot up.

This support includes:

  * The running of a set of default customization scripts that are required by xCAT.
You can see what scripts xCAT will run by default by looking at the "xcatdefaults" entry in the xCAT "postscripts" database table. ( I.e. Run "tabdump postscripts".). You can change the default setting by using the xCAT chtab or tabedit command. The scripts are contained in the /install/postscripts directory on the xCAT management node.
  * The optional running of customization scripts provided by xCAT.
There is a set of xCAT customization scripts provided in the /install/postscripts directory that can be used to perform optional tasks such as additional adapter configuration. (See the "configiba" script for example.)
  * The optional running of user-provided customization scripts.

To have your script run on the nodes:

  1. Put a copy of your script in /install/postscripts on the xCAT management node. (Make sure it is executable.)
  2. When using service nodes make sure the postscripts are copied to the /install/postscripts directories on each service node.
  3. Set the "postscripts" attribute of the node definition to include the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run. For example, if you want to have your two scripts called "foo" and "bar" run on node "node01" you could use the chdef command as follows.

~~~~
    chdef -t node -o node01 -p postscripts=foo,bar
~~~~


(The "-p" means to add these to whatever is already set.)

Note: The customization scripts are run during the boot process (out of /etc/inittab).

### Power 775 configuration scripts (optional)

Thee are additional post scripts required to configure HFI interfaces when working with Power 775 configuration. You will need to make sure that the xCAT HFI scripts confighfi is properly copied into the /install/postscript/ directory. You will then need to allocate the postscripts to the proper xCAT OS images being used with installation for xCAT SN and xCAT CN.

~~~~
    chdef clstrn02 postscripts=confighfi
~~~~


Note: There is a design limitation in AIX HFI driver implementation that hf0 is always left in "Defined" state on diskless compute nodes. xCAT provides a workaround as following in confighfi postscript to configure interface hf0 to be "Available" state:

Change line 126 in confighfi from:

~~~~
     for i in 1 2 3
~~~~


To:

~~~~
     for i in 0 1 2 3
~~~~


### Set up prescripts (optional)

The xCAT prescript support is provided to to run user-provided scripts during the node initialization process. These scripts can be used to help set up specific environments on the servers that handle the cluster node deployment. The scripts will run on the install server for the nodes. (Either the management node or a service node.) A different set of scripts may be specified for each node if desired.


One or more user-provided prescripts may be specified to be run either at the beginning or the end of node initialization. The node initialization on AIX is done either by the nimnodeset command (for diskfull nodes) or the mkdsklsnode command (for diskless nodes.)


For more information about using the xCAT prescript support refer: [Postscripts_and_Prescripts](Postscripts_and_Prescripts).

### Initialize the AIX/NIM diskless nodes

You can set up NIM to support a diskless boot of nodes by using the xCAT [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html) command. This command uses information from the xCAT database and default values to run the appropriate NIM commands.

When using xCAT service nodes the mkdsklsnode command will also take care of the NIM configuration on those systems. It will set up NIM, replicate the NIM resources that are needed, define the NIM clients etc. It will also copy over any additional postscripts that may be needed.

Note: After running mkdsklsnode, if you change a postscript or some other file that must be updated on the service nodes you must manually copy them to the service nodes. To do this you could use the xCAT [prsync](http://xcat.sourceforge.net/man1/prsync.1.html) command.

For example, to set up all the nodes in the group "aixnodes" to boot using the SPOT named "61cosi" you could issue the following command.

~~~~
    mkdsklsnode -i 61cosi aixnodes
~~~~


The command will define and initialize the NIM machines. It will also set the "provmethod" attribute in the xCAT node definitions to "61cosi ".

To verify that NIM has allocated the required resources for a node and that the node is ready for a network boot you can run the "lsnim -l" command. For example, to check node "node01" you could run the following command.

~~~~
    lsnim -l node01
~~~~


Note:

The NIM initialization of multiple nodes is done sequentially and takes approximately three minutes per node to complete. If you are planning to initialize multiple nodes you should plan accordingly.

#### Verifying the node initialization before booting (optional)

Once the mkdsklsnode command completes you can log on to the service node and verify that it has been configured correctly.

The things to check include the following:

  * See if the NIM resources and client definitions have been created. ("lsnim -l")
  * If using dhcp check /etc/dhcpsd.cnf for the correct node entries.
  * If using bootp check /etc/bootptab for the correct node entries.
  * Check /etc/exports to see if the resource directories have been added.
  * Check /tftpboot/&lt;nodename&gt;.info to see if the entries are correct.
  * List the NIM node definitions to see if they are correct and if the correct resources have been allocated. ("lsnim -l &lt;nodename&gt;")

### Open a remote console (optional)

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

### Initiate a network boot

Initiate a remote network boot request using the xCAT rnetboot command. For example, to initiate a network boot of all nodes in the group "aixnodes" you could issue the following command.

~~~~
    rnetboot aixnodes
~~~~


Note: If you receive timeout errors from the rnetboot command, you may need to increase the default 60-second timeout to a larger value by setting ppctimeout in the site table:

~~~~
    chdef -t site -o clustersite ppctimeout=180
~~~~


### Initiate a network boot for Power 775 support

Starting from xCAT 2.6 and working in Power 775 cluster, there are two ways to initialize a network boot to the compute nodes: one way is that using xCAT rbootseq command to setup the boot device as network adapter for the compute nodes, and after that, you can issue xCAT rpower command to power on or reset the compute node to boot from network, another way is to use xCAT rnetboot command directly. Comparing these two ways, rbootseq/rpower commands don't require the console support and operate in the console, so it has a better performance. It is recommended to use rbootseq/rpower to setup the boot device to network adapter and initialize the network boot in Power 775 cluster.

~~~~
    rbootseq aixnodes hfi
    rpower aixnodes boot
~~~~


### Verify the deployment

  * Retry and troubleshooting tips:
  * Verify network connections
  * For dhcp, view /etc/dhcpsd.cnf to make sure an entry exists for the node.
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
  * If that doesn't work, you may need to re-initialize the diskless node and start over. You can use the rmdsklsnode command to uninitialize an AIX diskless node. This will deallocate and remove the NIM definition but it will not remove the xCAT node definition.

## Switching to a backup service node

For reliability, availability, and serviceability purposes you may wish to use backup service nodes in your hierarchical cluster.

The backup service node will be set up to quickly take over from the original service node if a problem occurs.

This is not an automatic fail over feature. You will have to initiate the switch from the primary service node to the backup manually. The xCAT support will handle most of the setup and transfer of the nodes to the new service node.

Note: This procedure could also be used to simply switch the cluster diskless compute nodes to a new service node.

Abbreviations used below:



MN&nbsp;: - management node.
SN&nbsp;: - service node.
CN&nbsp;: - compute node.

### Initial deployment

Integrate the following steps into the hierarchical deployment process described above.

  1. Make sure both the primary and backup service nodes are installed, configured, and can access the MN database.
  2. When defining the CNs add the necessary service node values to the "servicenode" and "xcatmaster" attributes of the node definitions.
  3. (Optional) Create an xCAT group for the nodes that are assigned to each SN. This will be useful when setting node attributes as well as providing an easy way to switch a set of nodes back to their original server.

Note-



xcatmaster:&nbsp;: The hostname of the xCAT service node as known by the node.
servicenode:&nbsp;: The hostname of the xCAT service node as known by the management node.

To specify a backup service node you must specify a comma-separated list of two service nodes for the "servicenode" value. The first one will be the primary and the second will be the backup (or new SN) for that node.

For the "xcatmaster" value you should only include the primary name of the service node as known by the node.

In the simplest case the management node, service nodes, and compute nodes are all on the same network and the interface name of the service nodes will be same for either the management node or the compute node.

For this case you could set the attributes as follows:

~~~~
    chdef <noderange>  servicenode="xcatsn1,xcatsn2" xcatmaster="xcatsn1"
~~~~


However, in some network environments the name of the SN as known by the MN may be different than the name as known by the CN. (If they are on different networks.)

In the following example assume the SN interface to the MN is on the "a" network and the interface to the CN is on the "b" network. To set the attributes you would run a command similar to the following.

~~~~
    chdef <noderange>  servicenode="xcatsn1a,xcatsn2a" xcatmaster="xcatsn1b"

~~~~

The process can be simplified by creating xCAT node groups to use as the <noderange&gt; in the chdef command.

To create an xCAT node group containing all the nodes that have the service node "SN27" you could run a command similar to the following.

~~~~
    mkdef -t group -o SN27group -w  servicenode=SN27

~~~~

Note: When using backup service nodes you should consider splitting the CNs between the two service nodes. This way if one fails you only need to move half your nodes to the other service node.

When you run themkdsklsnode command to define and initialize the CNs, it will automatically replicate the required NIM resources on the SN used by the CN. If you have a backup SN specified then the replications and NIM definition will also be done on the backup SN. This will make it possible to do a quick takeover without having to wait for replication when you need to switch.

In some cases the commands will also create unique NIM resolv_conf resources on the primary and backup service nodes. For more information on setting up cluster name resolution see: [Cluster_Name_Resolution]

The [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html), and [rmdsklsnode](http://xcat.sourceforge.net/man1/rmdsklsnode.1.html) commands also support the "-p|--primarySN" and "- b|--backupSN" options. You can use these options to target either the primary or backup service nodes in case you do not wish to update both. These option could be used to initialize the primary service node first, to get the nodes booted and running, and then initialized the backup SN later while the nodes are running.

### Synchronizing statelite persistent files

If you are using the xCAT AIX "statelite" support you may need to replicate your statelite files to the backup (or new) service node.

This would be the case if you are using the service node as the server for the statelite persistent directory.

In this case you need to copy your statelite files and directories to the backup service node and keep them synchronized over time.

An easy and efficient way to do this would be to use the xCAT [prsync](http://xcat.sourceforge.net/man1/prsync.1.html) command.

For example, to copy and/or update the /nodedata directory on the backup service node "SN28" you could run the following command.

~~~~
    prsync -o "rlHpEAogDz" /nodedata SN28:/
~~~~


The xCAT [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) command may also be used to synchronize files from the primary service node to the backup service node.

This option for the snmove command is available in xCAT 2.6.10 and beyond.

If you run this command with the "-l" option it will attempt to use prsync to update the statelite persistent directory on the backup service node. This will only be done if the server specified in the "statelite" table is the primary service node.

For example, to synchronize any AIX statelite files from the primary server for compute03 to the backup server you could run the following command.

~~~~
    snmove compute03 -V -l
~~~~


See [XCAT_AIX_Diskless_Nodes#AIX_statelite_support](XCAT_AIX_Diskless_Nodes/#aix-statelite-support) for details on using the xCAT statelite support.

### Monitoring the service nodes

In most cluster environments it is very important to monitor the state of the service nodes. If a SN fails for some reason you should switch nodes to the backup service node as soon as possible.

See [Monitor_and_Recover_Service_Nodes#Monitoring_Service_Nodes] for details on monitoring your service nodes.

### Switch to a backup SN

#### Move the nodes to the new service nodes

Use the xCAT [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) to make the database updates necessary to move a set of nodes from one service node to another.

In some cases this command will also synchronize statelite persistent directories and make configuration modifications to the nodes.

For example, if you want to switch all the compute nodes that use service node "SN27" to the backup SN you could run the following command.

~~~~
    snmove -s SN27
~~~~


Modified database attributes

The snmove command will check and set several node attribute values.



servicenode:&nbsp;: This will be set to either the second server name in the servicenode attribute list or the value provided on the command line.
xcatmaster:&nbsp;: Set with either the value provided on the command line or it will be automatically determined from the servicenode attribute.
nfsserver:&nbsp;: If the value is set with the source service node then it will be set to the destination service node.
tftpserver:&nbsp;: If the value is set with the source service node then it will be reset to the destination service node.
monserver:&nbsp;: If set to the source service node then reset it to the destination servicenode and xcatmaster values.
conserver:&nbsp;: If set to the source service node then reset it to the destination servicenode and run makeconservercf.

Synchronize statelite persistent directories

In some cases, if you are using the xCAT AIX statelite support, the snmove command will synchronize the persistent statelite directories from the nodes primary service node to it's backup service node. This will only be done if the server specified in the "statelite" table is the primary service node.

This feature for the snmove command is available in xCAT 2.6.10 and beyond.

Run postscripts on the nodes

If the node is up at the time the snmove command is run then it will run postscripts on the node. The "syslog" postscript is always run. The "mkresolvconf" and "setupntp" scripts will be run IF they were included in the nodes postscript list.

You can also specify an additional list of postscripts to run.

Modify system configuration on the nodes

If the node is up the snmove command will also perform some configuration on the node such as setting the default gateway and modifying some configuration files used by xCAT.

#### Statelite migration

If you are using the xCAT statelite support you may need to modify the statelite and litetree tables.

This would be necessary if any of the entries in the tables include the name of the primary service node as the server for the file or directory. In this case you would have to change those entries to the name of the backup service node.

The snmove command mentioned above will check the "statelite" table and make any necessary changes.

This option for the snmove command is available in xCAT 2.6.10 and beyond. If you are using an earlier version of xCAT you will have to make these changes manually.

If you are using the "litetree" table you will have to make any required changes manually and also make sure any files that are available on the primary service node are also available on the backup service node.

For example, if you specify the service node in a "litetree" entry as follows:

~~~~
    #priority,image,directory,comments,disable
    "1","71Bdskls","SNprimary:/statelite/",,
~~~~


you would have to change the entry to point to the backup service node.

~~~~
    #priority,image,directory,comments,disable
    "1","71Bdskls","SNbackup:/statelite/",,
~~~~


Note that these table changes could have been avoided by using variables in the table entries.

For example, if you use "$noderes.xcatmaster" in the statelite table then it will always be evaluated as the "xcatmaster" value of the node. (Which is the name of the SN as known by the node.)

#### Initialize the nodes on the new SN (optional)

If the NIM replication hasn't been run on the new SN, or you had to do statelite migration then you must run the xCAT commands to get the new SN configured properly.  For diskless nodes you must run mkdsklsnode. For diskful nodes you must run xcat2nim and nimnodeset. (See the man pages for details.)

For example, if you wish to initialize the diskless compute node named "compute02" on its new service node you could run a command similar to the following. (Note that the primary service node was set when the snmove command was run in a previous step.)

~~~~
    mkdsklsnode -p -i 710dskls compute02
~~~~


The mkdsklsnode may be run while the node is currently running to reduce node downtime.

#### Shut down the node

To shut down the nodes you can use xdsh to run the shutdown command on the nodes.

~~~~
    xdsh SN27group "shutdown -F &"
~~~~


If the node is down or not responding you can use the rpower  command to shut the nodes down.

    shutdown SN27group off


#### Reboot the diskless nodes

Diskless CNs will have to be re-booted to have them switch to the new SN. You can use the xCAT rnetboot command to boot the nodes from the backup SN.

The rnetboot command will get the new SN information from the xCAT database and perform a directed boot request from the node to the new SN. When the node boots up it will be configured as a client of the NIM master on the new SN. For example, to reboot all the nodes that are in the xCAT group "SN27group" you could run the following command.

~~~~
    rnetboot SN27group
~~~~


You could also use the combination of the rbootseq and rpower commands to reboot the nodes if you are using P775 hardware.

However, DO NOT try to use the rpower command alone to reboot the nodes. This would cause the node to try to reboot from the old SN.

### Switching back

The process for switching nodes back will depend on what must be done to recover the original service node. Essentially the SN must have all the NIM resources and definitions restored and operations completed before you can use it.

If you are using the xCAT statelite support then you must make sure you have the latest files and directories copied over and that you make any necessary changes to the statelite and/or litetree tables.

If all the configuration is still intact you can simply use the snmove command to switch the nodes back.

If the configuration must be restored then you will have to run the mkdsklsnode (diskless) command. This command will re-configure the SN using the common osimages defined on the xCAT management node.

For example:

~~~~
    mkdsklsnode SN27group
~~~~


This command will check each node definition to get the osimage it is using. It will then check for the primary and backup service nodes and do the required configuration for the one that needs to be configured.

Once the SN is ready you can run the snmove command to switch the node definitions to point to it. For example, if you assume the nodes are currently managed by the "SN28" service node then could could switch them back to the "SN27" SN with the following command.

~~~~
    svmove SN27group -d SN27
~~~~


If your compute nodes are diskless and you are NOT using an external NFS server then they must be rebooted using the rnetboot command in order to switch to the other service node.

## Cleanup

The NIM definitions and resources that are created by xCAT commands are not automatically removed. It is therefore up to the system administrator to do some clean up of unused NIM definitions and resources from time to time. (The NIM lpp_source and SPOT resources are quite large.) There are xCAT commands that can be used to assist in this process.

### Removing NIM machine definitions

Use the xCAT rmdsklsnode command to remove all the NIM diskless machine definitions that were created for the specified xCAT nodes. This command will not remove the xCAT node definitions.

For example, to remove the NIM machine definition corresponding to the xCAT diskless node named "node01" you could run the command as follows.

~~~~
    rmdsklsnode node01
~~~~


Use the xCAT xcat2nim command to remove all the NIM standalone machine definitions that were created for the specified xCAT nodes. This command will not remove the xCAT node definitions.

For example, to remove the NIM machine definition corresponding to the xCAT node named "node01" you could run the command as follows.

~~~~
    xcat2nim -t node -r node01
~~~~


The xcat2nim and rmdsklsnode command are intended to make it easier to clean up NIM machine definitions that were created by xCAT. You can also use the AIX nim command directly. See the AIX/NIM documentation for details.

### Removing NIM resources

Use the xCAT rmnimimage command to remove all the NIM resources associated with a given xCAT osimage definition. The command will only remove a NIM resource if it is not allocated to a node. You should always clean up the NIM node definitions before attempting to remove the NIM resources. The command will also remove the xCAT osimage definition that is specified on the command line.

For example, to remove the "610image" osimage definition along with all the associated NIM resources run the following command.

~~~~
    rmnimimage 610image
~~~~


If necessary, you can also remove the NIM definitions directly by using NIM commands. See the AIX/NIM documentation for details.
