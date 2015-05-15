<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Using AIX Service Nodes](#using-aix-service-nodes)
- [Update node definitions](#update-node-definitions)
  - [Specify the services provided by the service nodes](#specify-the-services-provided-by-the-service-nodes)
  - [Create a Service Node operating system image](#create-a-service-node-operating-system-image)
  - [Create an image_data resource (optional)](#create-an-image_data-resource-optional)
  - [Add required service node software](#add-required-service-node-software)
    - [XCAT and prerequisite software](#xcat-and-prerequisite-software)
    - [Using NIM installp_bundle resources](#using-nim-installp_bundle-resources)
    - [Check the osimage (optional)](#check-the-osimage-optional)
  - [Define an xCAT "service" group](#define-an-xcat-service-group)
  - [Set Server Attributes (optional)](#set-server-attributes-optional)
  - [Include customization scripts](#include-customization-scripts)
    - [Add "servicenode" script for service nodes](#add-servicenode-script-for-service-nodes)
    - [Add NTP setup script (optional)](#add-ntp-setup-script-optional)
    - [Add additional adapters configuration script (optional)](#add-additional-adapters-configuration-script-optional)
        - [Configuring Secondary Adapter](#configuring-secondary-adapter)
    - [Add disk mirroring script (optional)](#add-disk-mirroring-script-optional)
  - [Create NIM client, network, &amp; group definitions](#create-nim-client-network-&amp-group-definitions)
    - [Define NIM standalone clients](#define-nim-standalone-clients)
    - [Define NIM machine groups (optional)](#define-nim-machine-groups-optional)
    - [Define NIM networks](#define-nim-networks)
  - [Create prescripts (optional)](#create-prescripts-optional)
  - [Initialize the AIX/NIM nodes](#initialize-the-aixnim-nodes)
  - [Initiate a network boot](#initiate-a-network-boot)
  - [Verify the deployment](#verify-the-deployment)
    - [Retry and troubleshooting tips](#retry-and-troubleshooting-tips)
  - [Configure additional adapters on the service nodes (optional)](#configure-additional-adapters-on-the-service-nodes-optional)
  - [Verify Service Node configuration](#verify-service-node-configuration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Using AIX Service Nodes

If you wish to use xCAT service nodes in your cluster environment you must follow the process described in this section to properly install and configure the service nodes.

If you are not using service nodes you can skip this section.*

An xCAT service node must be installed with xCAT software as well as additional prerequisite software.

AIX service nodes must be diskful (NIM standalone) systems.

In the process described below the service nodes will be deployed using a standard AIX/NIM "rte" network installation. If you are using multiple service nodes you may want to consider creating a "golden" mksysb image that you can use as a common image for all the service nodes. See the xCAT document named "Cloning AIX nodes (using an AIX mksysb image)" for more information on using mksysb images. See [XCAT_AIX_mksysb_Diskfull_Nodes].

## Update node definitions

Modify the xCAT node definitions to indicate if the node is a service node, and if not, indicate the server for the node.

(For chdef details see: http://xcat.sourceforge.net/man1/chdef.1.html )

For service nodes:

  * Add "service" to the "groups" attribute of all the service nodes.
  * Specify the services that the service nodes will be providing. At a minimum, the "setupnameserver" attribute of the service nodes must be explicitly set to "yes" or "no". (Ex. "setupnameserver=no")

~~~~
    chdef cl2sn01 -p groups=service setupnameserver=no
~~~~


For non-service nodes:

  * Add the name of the service node to the node definition. (Ex. "servicenode=xcatSN01") This is the name of the service node as it is known by the management node.
  * Set the "xcatmaster" attribute. This must be the name of the service node as it is known by the node. This may or may not be the same value as the "servicenode " attribute.

~~~~
    chdef cl2cn27 servicenode=cl2sn01 xcatmaster=cl2sn01-en0
~~~~


Note: if the "servicenode" and "xcatmaster" values are not set then xCAT will default to use the value of the "master" attribute in the xCAT "site" definition.

### Specify the services provided by the service nodes

Distributing services to your service nodes will help alleviate the load on your management node and prevent potential bottlenecks from occurring in your cluster.

You choose the services that you would like started on your service node by setting the attributes in the servicenode table. When the xcatd daemon is started or restarted on the service node, a check will be made by the xCAT code that the services from this table are configured on the service node and running, and will stop and start the service as appropriate.

This check will be done each time the xcatd is restarted on the service node. If you do not wish this check to be done, and the service not to be restarted, use the reload option when starting the daemon on the service node:

~~~~
    xcatd -r
~~~~


For example, the following command will setup the service node group to start the named (DNS),conserver, NFS and ipforwarding automatically on the service nodes. You may want to setup other services such as the monitoring server on the service node.

For a description of the services and what is setup see:

~~~~
    tabdump -d servicenode
~~~~


or the "servicenode" table manpage:

http://xcat.sourceforge.net/man5/servicenode.5.html

~~~~
    chdef -t group -o service setupnameserver=1 setupnfs=1 setupconserver=1 setupipforward=1
~~~~


For Power775 clusters, as a you should set the following:

~~~~
    chdef -t group -o service   setupipforward=1
~~~~


Note: When using the chdef commands, the attributes names for setting these server values do not match the actual names in the "servicenode" table. This is to avoid conflicts with corresponding attribute names in the "nodere" table. To see the correct attribute names to use with chdef:

~~~~
    chdef -h -t node
~~~~


and search for attributes that begin with "setup".

If you do not want any service started on the service nodes, then run the following command to define the service nodes but start no services:

~~~~
    chdef -t group -o service setupnameserver=0
~~~~


### Create a Service Node operating system image

Reminder: If you wish to create separate file systems for your NIM resources you should do that before continuing. For example, you might want to create a separate file system for /install and one for any dump resources you may need. This is described in:

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node]

Use the xCAT mknimimage command to create an xCAT osimage definition as well as the required NIM installation resources. (For details see: http://xcat.sourceforge.net/man1/mknimimage.1.html )

An xCAT osimage definition is used to keep track of a unique operating system image and how it will be deployed.

In order to use NIM to perform a remote network boot of a cluster node the NIM software must be installed, NIM must be configured, and some basic NIM resources must be created.

The mknimimage will handle all the NIM setup as well as the creation of the xCAT osimage definition. It will not attempt to reinstall or reconfigure NIM if that process has already been completed. See the mknimimage manpage for additional details.

Note: If you wish to install and configure NIM manually you can run the AIX nim_master_setup command (Ex. "nim_master_setup -a mk_resource=no -a device=&lt;source directory&gt;") or use other NIM commands such as nimconfig.

By default, the mknimimage command will create the NIM resources in sub-directories of /install. Some of the NIM resources are quite large (1-2G) so it may be necessary to increase the file size limit.

For example, to set the file size limit to "unlimited" for the user "root" you could run the following command.

~~~~
     /usr/bin/chuser fsize=-1 root
~~~~


When you run the command you must provide a source for the installable images. This could be the AIX product media, a directory containing the AIX images, or the name of an existing NIM lpp_source resource. You must also provide a name for the osimageyou wish to create. This name will be used for the NIM SPOT resource that is created as well as the name of the xCAT osimage definition. The naming convention for the other NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 71GA_lpp_source").

In this example we need resources for installing a NIM "standalone" type machine using the NIM "rte" install method. (This type and method are the defaults for the mknimimage command but you can specify values on the command line if needed.)

For example, to create an osimage named "71SNimage" using the images contained in the /myimages directory you could issue the following command.

~~~~
     mknimimage -s /myimages 71SNimage
~~~~


(Creating the NIM resources could take a while!)

Note: To populate the /myimages directory you could copy the software from the AIX product media using the AIX gencopy command. For example you could run "gencopy -U -X -d /dev/cd0 -t /myimages all".

By default the command will create NIM lppsource, spot, and bosinst_data resources. You can also specify alternate or additional resources on the command line using the "attr=value" option, ("&lt;nim resource type&gt;=&lt;resource name&gt;").

For example:

~~~~
     mknimimage -s /myimages 71SNimage resolv_conf=my_resolv_conf
~~~~


Any additional NIM resources specified on the command line must be previously created using NIM interfaces. (Which means NIM must already have been configured. )

Note: Another alternative is to run mknimimage without the additional resources and then simply add them to the xCAT osimage definition later. You can add or change the osimage definition at any time. When you initialize and install the nodes xCAT will use whatever resources are specified in the osimage definition.

When the command completes it will display the osimage definition which will contain the names of all the NIM resources that were created. The naming convention for the NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 71SNimage_lpp_source"), except for the SPOT name. The default name for the SPOT resource will be the same as the osimage name.

The xCAT osimage definition can be listed using the lsdef command, modified using the chdef command and removed using the rmnimimage command. See the man pages for details.

In some cases you may also want to modify the contents of the NIM resources. For example, you may want to change the bosinst_data file or add to the resolv_conf file etc. For details concerning the NIM resources refer to the NIM documentation.

You can list NIM resource definitions using the AIX lsnim command. For example, if the name of your SPOT resource is "71SNimage" then you could get the details by running:

~~~~
    lsnim -l 71SNimage
~~~~


To see the actual contents of a NIM resource use

~~~~
    nim -o showres <resource name>
~~~~


For example, to get a list of the software installed in your SPOT you could run:

~~~~
    nim -o showres 71SNimage
~~~~


### Create an image_data resource (optional)

If you are using PostgreSQL you must make sure the node starts out with enough file system space to install the database software. This can be done using the NIM image_data resource.

A NIM image_data resource is a file that contains stanzas of information that is used when creating file systems on the node. To use this support you must create the file, define it as a NIM resource, and add it to the xCAT osimage definition.

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
    nim -o define -t image_data -a server=master \
       -a location=/install/nim/image_data/myimage_data myimage_data

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


NOTE: The latest xCAT dep-aix package actually includes multiple sub-directories corresponding to different versions of AIX. Be sure to copy the correct versions of the rpms to your lpp_source directory.

The required software must be copied to the NIM lpp_source that is being used for the service node image. The easiest way to do this is to use the "nim -o update" command.

For example, assume all the required xCAT rpm software has been copied and unwrapped in the /tmp/images directory.

Assuming you are using AIX 7.1 you could copy all the appropriate rpms to your lpp_source resource (ex. 71SNimage_lpp_source) using the following commands:

~~~~
    nim -o update -a packages=all -a source=/tmp/images/xcat-dep/7.1 71SNimage_lppsource
    nim -o update -a packages=all -a source=/tmp/images/xcat-core/  71SNimage_lpp_source

~~~~

The NIM command will find the correct directories and update the appropriate lpp_source resource directories.

#### Using NIM installp_bundle resources

To get all this additional software installed we need a way to tell NIM to include it in the installation. To facilitate this, xCAT provides sample NIM installp bundle files. (Always make sure that the contents of the bundle files you use are the packages you want to install and that they are all in the appropriate lpp_source directory.)

xCAT ships a set of bundle files to use for installing a service node. They are in:

~~~~
    /opt/xcat/share/xcat/installp_bundles
~~~~


There is a version corresponding to the different AIX OS levels. (xCATaixSN71.bnd, xCATaixSN61.bnd etc.) Just use the one that corresponds to the version of AIX you are running.

To use the bundle file you need to define it as a NIM resource and add it to the xCAT osimage definition.

Copy the bundle file ( say xCATaixSN71.bnd ) to a location where it can be defined as a NIM resource, for example "/install/nim/installp_bundle".

To define the NIM resource you can run the following command.

~~~~
    nim -o define -t installp_bundle -a server=master \
      -a location=/install/nim/installp_bundle/xCATaixSN71.bnd xCATaixSN71
~~~~

To add this bundle resources to your xCAT osimage definition run:

~~~~
    chdef -t osimage -o 71SNimage installp_bundle="xCATaixSN71"
~~~~


Important Note: The sample xCAT bundle files mentioned above contain commented-out entries for each of the supported databases. You must edit the bundle file you use to uncomment the appropriate database rpms. If the required database packages are not installed on the service node then the xCAT configuration will fail.

#### Check the osimage (optional)

To avoid potential problems when installing a node it is adviseable to verify that all the additional software that you wish to install has been copied to the appropriate NIM lpp_source directory.

Any software that is specified in the "otherpkgs" or the "installp_bundle" attributes of the xCAT osimage definition must be available in the lpp_source directories.

To find the location of the lpp_source directories run the "lsnim -l <lpp_source_name>" command:

~~~~
    lsnim -l 71SNimage_lpp_source
~~~~


If the location of your lpp_source resource is "/install/nim/lpp_source/71SNimage_lpp_source/" then you would find rpm packages in "/install/nim/lpp_source/71SNimage_lpp_source/RPMS/ppc" and you would find your installp packages in "/install/nim/lpp_source/71SNimage_lpp_source/installp/ppc".

To find the location of the installp_bundle resource files you can use the NIM "lsnim -l" command. For example,

~~~~
    lsnim -l xCATaixSN71
~~~~


To simplify this process you can use the xCAT chkosimage command to do this checking. For example, you could run the following command to automatically check the lpp_source resource included in the "71SNimage" definition.

~~~~
    chkosimage -V 71SNimage
~~~~


In addition to letting you know what software is missing from your lpp_source the chkosimage command will also indicate if there are multiple files that match the entries in your bundle file. This can happen when you use wild cards in the packages names added to the bundle file. In this case you must remove any old packages so that there is only one rpm selected for each entry in the bundle file.

To automate this process you may be able to use the "-c" (clean) option of the chkosimage command. This option will keep the rpm that was most recently written to the directory and remove the others. (Be careful when using this option!)

For example,

    chkosimage -V -c 71SNimage


(For details see: http://xcat.sourceforge.net/man1/chkosimage.1.html )

### Define an xCAT "service" group

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

### Set Server Attributes (optional)

In some cases it may be necessary to set server-related attributes for the service nodes.

This includes the nfserver, tftpserver, monserver, xcatmaster, and servicenode attributes.

The default values for these attributes is the IP address of the management node.

For example, you might want to boot the service node from some other service node rather than the management. Or you might want your nfs server to be something other than the management node. Etc.

You can use the chdef command to set these attributes.

For example, to set the nfserver attribute of the service node named sn42 you could run the following command.

~~~~
    chdef sn42 nfserver=10.0.0.214
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

~~~~
    chdef -p -t group service postbootscripts="make_sn_fs,servicenode"
~~~~


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

To configure secondary adapters, see [Configuring_Secondary_Adapters].

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




### Create NIM client, network, &amp; group definitions

All xCAT network, group, and node definitions must be previously defined in the xCAT database.

You can use the xCAT xcat2nim command to automatically create NIM client, network, and group definitions based on the information contained in the xCAT database. (For details see: http://xcat.sourceforge.net/man1/xcat2nim.1.html )

To check the NIM definitions you could use the NIM lsnim command or the xCAT xcat2nim command. For example, the following command will display the NIM definitions of the nodes contained in the xCAT group called "service", (from data stored in the NIM database).

~~~~
    xcat2nim -t node -l service
~~~~


#### Define NIM standalone clients

Use the xcat2nim command to define NIM client definitions corresponding to the xCAT node definitions.

To create NIM machine definitions for your diskful (standalone) nodes you should run a command similar to the following.

~~~~
    xcat2nim -t node clstrnode01
~~~~


#### Define NIM machine groups (optional)

To create NIM group definition for the xCAT group "mynodes" you could run the following command.

~~~~
    xcat2nim -t group -o mynodes
~~~~


#### Define NIM networks

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

You can use the xCAT nimnodeset command to initialize the AIX standalone nodes. This command uses information from the xCAT osimage definition and default values to run the appropriate NIM commands. (For details see: http://xcat.sourceforge.net/man1/nimnodeset.1.html )

For example, to set up all the nodes in the group "service" to install using the osimage named "71SNimage" you could issue the following command.

~~~~
    nimnodeset -i 71SNimage service
~~~~


To verify that you have allocated all the NIM resources that you need you can run the "lsnim -l" command. For example, to check the node "clstrn01" you could run the following command.

~~~~
    lsnim -l clstrn01
~~~~


The command will also set the "profile" attribute in the xCAT node definitions to "71SNimage ". Once this attribute is set you can run the nimnodeset command without the "-i" option.

### Initiate a network boot

The specific steps to initiate a network boot varies slightly depending on the hardware platform being used.

Please refer to the section later in this document that describes how to network boot your hardware type.

### Verify the deployment

  * If you opened a remote console using rcons you can watch the progress of the installation.
  * You can use the AIX lsnim command to see the state of the NIM installation for a particular node, by running the following command on the NIM master:

~~~~
    lsnim -l <clientname>
~~~~


  * When the node is booted you can log in and check if it is configured properly. For example, is the password set?, is the timezone set?, can you xdsh to the node etc.

#### Retry and troubleshooting tips

If a node did not boot up:

  * Verify the network connections.
  * For dhcp, check /etc/dhcpsd.cnf to make sure an entry exists for the node
  * Stop and restart tftp:

~~~~
    stopsrc -s tftpd
    startsrc -s tftpd
~~~~


Verify NFS is running properly and mounts can be performed with this NFS server:

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



If the node booted but one or more customization scripts did not run correctly:

  * You can check the /var/log/messages file on the management node and the /var/log/xcat/xcat.log file on the node (if it is up) to see if any error messages were produced during the installation.
  * Restart the xcatd daemon (xcatstop &amp; xcatstart (xCAT2.4 restartxcatd)) and then re-run the customization scripts either manually or by using the updatenode command.

### Configure additional adapters on the service nodes (optional)

If additional adapter configuration is required on the service nodes you could either use the xdsh command to run the appropriate AIX commands on the nodes or you may want to use the updatenode command to run a configuration script on the nodes. (For details see: http://xcat.sourceforge.net/man1/updatenode.1.html )


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


