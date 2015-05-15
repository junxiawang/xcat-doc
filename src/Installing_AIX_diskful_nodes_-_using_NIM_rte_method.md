<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Installing AIX diskful/diskless nodes (using NIM rte method)](#installing-aix-diskfuldiskless-nodes-using-nim-rte-method)
  - [Create an operating system image](#create-an-operating-system-image)
  - [Add additional software](#add-additional-software)
    - [Create NIM installp_bundle resources](#create-nim-installp_bundle-resources)
    - [Copy the software to the lpp_source resource](#copy-the-software-to-the-lpp_source-resource)
    - [Check the osimage](#check-the-osimage)
  - [Create an image_data resource (optional)](#create-an-image_data-resource-optional)
  - [Set up customization scripts (optional)](#set-up-customization-scripts-optional)
    - [Add NTP setup script](#add-ntp-setup-script)
    - [Add secondary adapter configuration script (optional)](#add-secondary-adapter-configuration-script-optional)
    - [Configure NIM to use nimsh and SSL.](#configure-nim-to-use-nimsh-and-ssl)
  - [Create prescripts (optional)](#create-prescripts-optional)
  - [Create NIM client, network, &amp; group definitions](#create-nim-client-network-&amp-group-definitions)
    - [Define NIM standalone clients](#define-nim-standalone-clients)
    - [Define NIM machine groups (optional)](#define-nim-machine-groups-optional)
    - [Define NIM networks](#define-nim-networks)
  - [Initialize the AIX/NIM nodes](#initialize-the-aixnim-nodes)
    - [Verifying the node initialization before booting (optional)](#verifying-the-node-initialization-before-booting-optional)
  - [Initiate a network boot](#initiate-a-network-boot)
  - [Verify the deployment](#verify-the-deployment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Installing AIX diskful/diskless nodes (using NIM rte method)

This section provides the procedure of setting up the AIX Flex compute blades for an NIM RTE diskful installation from the xCAT MN. You should follow the steps below to setup the base xCAT NIM environment for the RTE node installation.

If you plan to implement the diskfull "mksysb" installation method to your flex blades, you first need to create a NIM AIX mksysb image created from your target flex blade node, and place that on the xCAT MN (NIM master). You then need to create the NIM mksysb object and environment to work with the NIM "mksysb". installation to your AIX flex blades. You can reference the "Create an operating system image" section in our xCAT AIX mksysb Diskful Nodes document:

   [XCAT_AIX_mksysb_Diskfull_Nodes]

If you wish to use the AIX diskless type installation, please refer to our xCAT AIX Diskless Nodes document:

   [XCAT_AIX_Diskless_Nodes]

### Create an operating system image

You will have to create one or more operating system images to be used to install the nodes of the cluster.

xCAT uses an "osimage" object definition to keep track of the unique NIM resources and additional software needed for each operating system inmage used in the cluster.

You can use the xCAT mknimimage command to create an xCAT osimage definition as well as the required NIM installation resources. (For "mknimimage" details see: http://xcat.sourceforge.net/man1/mknimimage.1.html )

The mknimimage command may only be run on the xCAT management node.

By default, the mknimimage command will create the NIM resources in subdirectories of /install. Some of the NIM resources are quite large (1-2G) so it may be necessary to increase the files size limit.

For example, to set the file size limit to "unlimited" for the user "root" you could run the following command.

~~~~
    /usr/bin/chuser fsize=-1 root
~~~~


When you run the mknimimage command you must provide a source for the installable images. This could be the AIX product media, a directory containing the AIX images, or the name of an existing NIM lpp_source resource. You must also provide a name for the osimage you wish to create. This name will be used for the NIM SPOT resource that is created as well as the name of the xCAT osimage definition. The naming convention for the other NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " aix71_lpp_source").

For example, to create an xCAT osimage definition named "710image" using the software contained in the /myimages directory you could run the following command.

~~~~
    mknimimage -s /myimages 710image
~~~~


This will create resources for installing a NIM "standalone" type machine using the NIM "rte" install method. This is the default type created with mknimimage command. This type and others can be specified explicitly via flags on the command line.

Note: This command takes a while to complete.

By default the command will create NIM lppsource, spot, and bosinst_data resources. You can specify alternate or additional resources using the "attr=value" option, ("&lt;nim resource type&gt;=&lt;resource name&gt;"). Additional resources will have to be created in advance via NIM commands.

For example, you could create a NIM "resolv_conf" resource called "710image_resolv_conf" and then use it in the mknimimage command as follows:

~~~~
    mknimimage -s /myimages 710image resolv_conf=710image_resolv_conf
~~~~


Note: To populate the /myimages directory you could copy the software from the AIX product media using the AIX gencopy command. For example you could run "gencopy -U -X -d /dev/cd0 -t /myimages all".

When you initialize and install the nodes, xCAT will use whatever resources are specified in the osimage definition.

When the command completes it will display the osimage definition which will contain the names of all the NIM resources that were created. The naming convention for the NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 710image_lpp_source"), except for the SPOT name. The default name for the SPOT resource will be the same as the osimage name.

For example:

~~~~
    lsdef -t osimage -l 710image
    Object name: 710image
    bosinst_data=710image_bosinst_data
    imagetype=NIM
    lpp_source=710image_lpp_source
    nimmethod=rte
    nimtype=standalone
    osname=AIX
    resolv_conf=710image_resolv_conf
    spot= 710image
~~~~



Once the initial osimage definition is created you can change it by using the chdef command. For example, you may need to create additional NIM resources to use when installing the nodes, such as script or installp_bundle resources.

The xCAT osimage definition can be listed using the lsdef command (http://xcat.sourceforge.net/man1/lsdef.1.html) and removed using the rmnimimage command (http://xcat.sourceforge.net/man1/rmnimimage.1.html).

In some cases you may also want to modify the contents of the NIM resources. For example, you may want to change the bosinst_data file or add to the resolv_conf file etc. For details concerning the NIM resources refer to the NIM documentation. You can list NIM resource definitions using the AIX lsnim command. For example, if the name of your SPOT resource is "710image" then you could get the details by running:

~~~~
    lsnim -l 710image
~~~~


To see the actual contents of a NIM resource use "nim -o showres &lt;resource name&gt;". For example, to get a list of the software installed in your SPOT you could run:

~~~~
    nim -o showres 710image
~~~~


### Add additional software

The additional software that must be installed on the cluster nodes may differ slightly depending on the AIX version. The software you need for a particular release is is listed in a sample installp_bundle file that is shipped with xCAT.

The sample installp_bundle files are in:

~~~~
    /opt/xcat/share/xcat/installp_bundles
~~~~


There is a version corresponding to the different AIX OS levels. (xCATaixCN71.bnd, xCATaixCN61.bnd etc.) Just use the one that corresponds to the version of AIX you are running. (You want one that contains "CN" - Compute Node.)

The openssl and openssh should be available from the AIX product media. The prerequisite rpms are available in the dep-aix-&lt;version&gt;.tar.gz tar file that you downloaded from the xCAT download page..

#### Create NIM installp_bundle resources

To facilitate this you can copy the a sample bundle file provided by xCAT to /install/nim/intallp_bundles. This will tell NIM to include it in the installation. Starting with xCAT 2.4.3 there are two sets of sample bundle files provided. One set can be used when installing a service node and one set is used when install a compute node. For each set there is a version number in the name corresponding to the different AIX OS levels. (xCATaixCN61.bnd, xCATaixCN71.bnd etc.) Use the one that corresponds to the version of AIX you are running. These sample files are installed in "/opt/xcat/share/xcat/installp_bundles".

Note: There are two versions of perl-Net_SSLeay.pm rpm listed in the sample bundle files, use perl-Net_SSLeay.pm-1.30-3* for AIX 7.1.2 and older version, use perl-Net_SSLeay.pm-1.55-3* for AIX 7.1.3 and above, see details in xCATaixCN71.bnd and xCATaixSN71.bnd.

Define the bundle file(s) as NIM resources and add them to the xCAT osimage definition.

~~~~
    nim -o define -t installp_bundle -a \
     server=master -a location=/install/nim/installp_bundle/xCATaixCN71.bnd xCATaixCN71

~~~~

Verify the bundle resource was created.

~~~~
    lsnim -l xCATaixCN71
~~~~


Add the bundle resources to your xCAT osimage definition.

~~~~
    chdef -t osimage -o 710image installp_bundle=xCATaixCN71
~~~~


#### Copy the software to the lpp_source resource

The software listed in the bundle_file must copied to the NIM lpp_source that is being used for this OS image.

In this example the xCAT dependency rpms were under /install/xCAT/xcat-dep/7.1. The required installp filesets from the AIX media were copied to /install/post/otherpkgs/aix/ppc64/base. Additional user specified filesets were under /install/post/otherpkgs/aix/ppc64/other. Add them to the lpp_source.

~~~~
    nim -o update -a packages=all -a source=/install/xCAT/xcat-dep/7.1 710image_lpp_source
    nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/base 710image_lpp_source
    nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/other 710image_lpp_source
~~~~


Note: In newer versions of the dep-aix-&lt;version&gt;.tar.gz tar file the packges are found in subdirectories corresponding to the AIX OS version (ex. 6.1, 7.1, etc).

#### Check the osimage

To avoid potential problems when installing a node you should verify that all of the software was copied to the appropriate NIM lpp_source directory.

Also, if your bundle files include rpm entries that use a wildcard (*) you must make sure the lpp_source directory does not contain multiple packages that will match that entry. (NIM will attempt to install multiple version of the same package and produce an error!)

To find the location of the lpp_source directories run the "lsnim -l &lt;lpp_source_name&gt;" command. For example:

~~~~
lsnim -l 710image_lpp_source
~~~~

If the location of your lpp_source resource is "/install/nim/lpp_source/710image_lpp_source/" then you would find rpm packages in "/install/nim/lpp_source/710image_lpp_source/RPMS/ppc" and you would find your installp packages in "/install/nim/lpp_source/710image_lpp_source/installp/ppc".

Starting with xCAT version 2.4.3 you can use the xCAT chkosimage command to do this checking.

For example, to check the lpp_source included in the "710image" osimage definition you could run the following command.

~~~~
    chkosimage -V 710image
~~~~


See the chkosimage man page for details (http://xcat.sourceforge.net/man1/chkosimage.1.html ).

### Create an image_data resource (optional)

Starting with xCAT 2.5 support has been added for NIM image_data resources. A NIM image_data resource is a file that contains stanzas of information that is used when creating file systems on the node. To use this support you must create the file , define it as a NIM resource, and add it to the xCAT osimage definition. To help simplify this process xCAT ships a sample image_data file called /opt/xcat/share/xcat/image_data/xCATsnData. This file assumes you will have at least 70G of disk space available. It also sets the physical partition size to 128M.

This sample image_data file is intended to be used when installing xCAT service nodes but it may also be used for basic standalone compute nodes. If you need to change any of these be aware that you must change two stanzas for each file system. One is the fs_data and the other is the corresponding lv_data. These are the default values.

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

Copy it to /install/nim/image_data/myimage_data and modify it. Then define this resource using nim.

    nim -o define -t image_data -a server=master -a location= /install/nim/image_data/myimage_data myimage_data


Add this resources to your xCAT osimage definition run:

~~~~
    chdef -t osimage -o 610SNimage image_data=myimage_data
~~~~


For more information on using the image_data resource refer the the AIX/NIM documentation.

### Set up customization scripts (optional)

xCAT supports the running of customization scripts on the nodes when they are installed.

This support includes:

  * The running of a set of default customization scripts that are required by xCAT.
You can see what scripts xCAT will run by default by looking at the "xcatdefaults" entry in the xCAT "postscripts" database table. ( I.e. Run "tabdump postscripts".). You can change the default setting by using the xCAT chtab or tabedit command. The scripts are contained in the /install/postscripts directory on the xCAT management node.
  * The optional running of customization scripts provided by xCAT.
There is a set of xCAT customization scripts provided in the /install/postscripts directory that can be used to perform optional tasks such as additional adapter configuration.
  * The optional running of user-provided customization scripts.

To have your script run on the nodes:

  1. Put a copy of your script in /install/postscripts on the xCAT management node. (Make sure it is executable.)
  2. Set the "postscripts" attribute of the node definition to include the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run. For example, if you want to have your two scripts called "foo" and "bar" run on node "node01" you could use the chdef command as follows.

~~~~
    chdef -t node -o node01 -p postscripts=foo,bar
~~~~


(The "-p" means to add these to whatever is already set.)

Note: The customization scripts are run during the boot process (out of /etc/inittab).

#### Add NTP setup script

To have xCAT automatically set up ntp on the cluster nodes you must add the setupntp script to the list of postscripts that are run on the nodes.

To do this you can either modify the "postscripts" attribute for each node individually or you can just modify the definition of a group that all the nodes belong to.

For example, if all your nodes belong to the group "compute" then you could add setupntp to the group definition by running the following command.

~~~~
    chdef -p -t group -o compute postscripts=setupntp
~~~~


#### Add secondary adapter configuration script (optional)

If you need to configure IB Mellanox adapters, please reference this  document:
[Managing_the_Mellanox_Infiniband_Network](Managing_the_Mellanox_Infiniband_Network)


See [Configuring_Secondary_Adapters].

#### Configure NIM to use nimsh and SSL.

The NIM service handler (nimsh), is provided as an optional feature of NIM to be used in cluster environments where the standard rsh protocols are not secure enough.

Although nimsh eliminates the need for rsh, in the default configuration it does not provide trusted authentication based on key encryption. To use cryptographic authentication with NIMSH, you can configure NIMSH to use OpenSSL in the NIM environment. When you install OpenSSL on a NIM client, SSL socket connections are established during NIMSH service authentication. Enabling OpenSSL provides SSL key generation and includes all cipher suites supported in SSL version 3.

In order to facilitate the setup of nimsh, xCAT provides a sample customization called "confignimsh" that can be used to configure nimsh on the cluster nodes.

This script will also configure nimsh to use SSL and will remove the /.rhosts file from the node. If you do not wish to have the .rhosts file removed from the node you must remove those lines from the confignimsh script before using it.

This script should only be run on AIX standalone (diskfull) cluster compute nodes. It should NOT be run on the xCAT management node, service nodes or diskless nodes.

The basic processes is:

  * Make sure the AIX openssl fileset gets installed on the management node and all the other cluster nodes. (Which should be done in any case.)
  * On the xCAT management node run the following command.nimconfig -c

You must also run this command on any service nodes that are being used.

  * Add "confignimsh" to the list of scripts you want run on the nodes

For example, if all your nodes belong to the group "compute" then you could add confignimsh to the group definition by running the following command.

~~~~
    chdef -p -t group -o compute postscripts=confignimsh
~~~~


After the nodes boot up you can verify that nimsh was set up correctly by running a NIM command such as: "nim -o lslpp &lt;nodename&gt;".

To be sure that nimsh is actually using SSL you can run the command:

~~~~
    nimquery -a host=<nodename>
~~~~


Example:

~~~~
     nimquery -a host=xcatn11
    host:xcatn11.cluster.com:addr:10.2.0.104:mask:255.255.0.0:gtwy:
    10.2.0.200:_pif:en0:_ssl:yes:_psh:no:_res:no:asyn:no:mac:163D0DDAE202:_sslver:OpenSSL 0.9.8k 25 Mar 2009:

~~~~

The "_ssl:yes" indicates that nimsh is using SSL.

Note: You could also set up nimsh at any time using the xCAT updatenode command to run the confignimsh script on the nodes.

### Create prescripts (optional)

Starting with xCAT 2.5, prescript support is provided to run user-provided scripts during the node initialization process. These scripts can be used to help set up specific environments on the servers that handle the cluster node deployment. The scripts will run on the install server for the nodes. (Either the management node or a service node.) A different set of scripts may be specified for each node if desired.

One or more user-provided prescripts may be specified to be run either at the beginning or the end of node initialization. The node initialization on AIX is done either by the nimnodeset command (for diskfull nodes) or the mkdsklsnode command (for diskless nodes.)

You can specify a script to be run at the beginning of the nimnodeset or mkdsklsnode command by setting the prescripts-begin node attribute.

You can specify a script to be run at the end of the commands using the prescripts-end node attribute.

The format of the entry is:

~~~~
    [action1]:s1,s2...[|action2:s3,s4,s5...]...


where:

    action* is either "standalone" or "diskless"
    s1,s2..are the prescripts to run for this action

~~~~

The attributes may be set using the chdef command.

For example, if you wish to run the foo and bar prescripts at the beginning of the nimnodeset command you would run a command similar to the following.

~~~~
    chdef -t node -o node01 prescripts-begin="standalone:foo,bar"

~~~~

When you run the nimnodeset command it will start by checking each node definition and will run any scripts that are specified by the prescripts-begin attributes.

Similarly, the last thing the command will do is run any scripts that were specified by the prescripts-end attributes.

For more information about using the xCAT prescript support refer to the following documentation: [Postscripts_and_Prescripts]

### Create NIM client, network, &amp; group definitions

All xCAT network and node definitions must be previously defined in the xCAT database.

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

### Initialize the AIX/NIM nodes

You can use the xCAT nimnodeset command to initialize the AIX standalone nodes. This command uses information from the xCAT osimage definition and default values to run the appropriate NIM commands. (For details see: http://xcat.sourceforge.net/man1/nimnodeset.1.html )

For example, to set up all the nodes in the group "aixnodes" to install using the osimage named "610image" you could issue the following command.

~~~~
    nimnodeset -i 710image aixnodes
~~~~


To verify that you have allocated all the NIM resources that you need you can run the "lsnim -l" command. For example, to check node "node01" you could run the following command.

~~~~
    lsnim -l node01
~~~~


The nimnodeset command will also set the "provmethod" attribute in the xCAT node definitions to "71image ". Once this attribute is set you can run the nimnodeset command without the "-i" option.

#### Verifying the node initialization before booting (optional)

Once the nimnodeset command completes you can verify that it has been configured correctly. If you are using service nodes you will have to log on to the service node to do the verification.

The things to check include the following:

  * See if the NIM resources and client definitions have been created. ("lsnim -l")
  * If using dhcp check /etc/dhcpsd.cnf for the correct node entries.
  * If using bootp check /etc/bootptab for the correct node entries.
  * Check /etc/exports to see if the resource directories have been added.
  * Check /tftpboot/&lt;nodename&gt;.info to see if the entries are correct.
  * List the NIM node definitions to see if they are correct and if the correct resources have been allocated. ("lsnim -l &lt;nodename&gt;")

### Initiate a network boot

The specific steps to initiate a network boot varies slightly depending on the hardware platform being used.

Please refer to the section later in this document that describes how to network boot your hardware type.

### Verify the deployment

  * You can use the AIX lsnim command to see the state of the NIM installation for a particular node, by running the following command on the NIM master:

~~~~
     lsnim -l <clientname>
~~~~


  * Retry and troubleshooting tips:
  * Verify network connections
  * For bootp, view /etc/bootptab to make sure an entry exists for the node.
For dhcp, view /etc/dhcpsd.cnf to make sure an entry exists for the node.
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


Now attempt to mount a filesystem from another system on the network.


