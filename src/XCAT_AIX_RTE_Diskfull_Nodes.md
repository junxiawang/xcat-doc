<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Installing AIX nodes (using standard NIM rte method)](#installing-aix-nodes-using-standard-nim-rte-method)
  - [**Create an operating system image**](#create-an-operating-system-image)
  - [**Create an image_data resource (optional)**](#create-an-image_data-resource-optional)
  - [**Add additional software**](#add-additional-software)
    - [**Create NIM installp_bundle resources**](#create-nim-installp_bundle-resources)
    - [**Copy the software to the lpp_source resource**](#copy-the-software-to-the-lpp_source-resource)
    - [**Check the osimage**](#check-the-osimage)
  - [**Define xCAT networks**](#define-xcat-networks)
  - [**Create additional NIM network definitions (optional)**](#create-additional-nim-network-definitions-optional)
  - [**Define the HMC as an xCAT node**](#define-the-hmc-as-an-xcat-node)
  - [**Discover the LPARs managed by the HMC**](#discover-the-lpars-managed-by-the-hmc)
  - [**Define xCAT cluster nodes**](#define-xcat-cluster-nodes)
  - [**Add IP addresses and hostnames to /etc/hosts**](#add-ip-addresses-and-hostnames-to-etchosts)
  - [**Define xCAT groups (optional)**](#define-xcat-groups-optional)
  - [**Set up customization scripts (optional)**](#set-up-customization-scripts-optional)
    - [**Add NTP setup script**](#add-ntp-setup-script)
    - [**Add secondary adapter configuration script**](#add-secondary-adapter-configuration-script)
    - [**Configure NIM to use nimsh and SSL.**](#configure-nim-to-use-nimsh-and-ssl)
  - [**Create prescripts (optional)**](#create-prescripts-optional)
  - [**Gather MAC information for the install adapters.**](#gather-mac-information-for-the-install-adapters)
  - [**Create NIM client &amp; group definitions**](#create-nim-client-&amp-group-definitions)
  - [**Initialize the AIX/NIM nodes**](#initialize-the-aixnim-nodes)
  - [**Open a remote console (optional)**](#open-a-remote-console-optional)
  - [**Initiate a network boot**](#initiate-a-network-boot)
  - [**Verify the deployment**](#verify-the-deployment)
- [Cleanup](#cleanup)
  - [**Removing NIM machine definitions**](#removing-nim-machine-definitions)
  - [**Removing NIM resources**](#removing-nim-resources)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

The process uses xCAT features to automatically run the necessary NIM commands.

NIM is an AIX tool that enables a cluster administrator to centrally manage the installation and configuration of AIX and optional software on machines within a networked environment. This document assumes you are familiar with NIM. For more information about NIM, see the IBM AIX Installation Guide and Reference. (&lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;)

The process described below is one basic set of steps that may be used to install an AIX standalone node using the NIM "rte" installation method and is not meant to be a comprehensive guide of all the available NIM options.

Before starting this process it is assumed you have completed the following.

  * An AIX system has been installed to use as an xCAT management node.
  * The cluster network is configured. (The Ethernet network that will be used to perform the network boot of the nodes.)
  * xCAT and prerequisite software has been installed and configured on the management node.
  * Any logical partitions that will be used have already been created using the HMC interfaces.

## Installing AIX nodes (using standard NIM rte method)

### **Create an operating system image**

Use the xCAT **mknimimage** command to create an xCAT osimage definition as well as the required NIM installation resources. An xCAT osimage definition is used to keep track of a unique operating system image and how it will be deployed. In order to use NIM to perform a remote network boot of a cluster node the NIM software must be installed, NIM must be configured, and some basic NIM resources must be created. Install the bos.sysmgt.nim.spot and bos.sysmgt.nim.master filesets. Then initialize the NIM master. The **mknimimage** comnand will handle all the NIM setup as well as the creation of the xCAT osimage definition. It will not attempt to reinstall or reconfigure NIM if that process has already been completed. See the **mknimimage man** page for additional details.

**Note:** If you wish to install and configure NIM manually you can run the AIX **nim_master_setup** command (Ex. "nim_master_setup -a mk_resource=no -a device=&lt;source directory&gt;").

**Note:** For various reasons it is recommended that you make sure that the primary hostname of the management node is the interface that you will be using to install the nodes. If you do this before you configure NIM then NIM will automatically use it to define the NIM primary network. This will mean that you will not have to create any additional NIM network definitions and could avoid additional complications.

By default, the **mknimimage** command will create the NIM resources in subdirectories of /install. Some of the NIM resources are quite large (1-2G) so it may be necessary to increase the files size limit. For example, to set the file size limit to "unlimited" for the user "root" you could run the following command.

~~~~
    /usr/bin/chuser fsize=-1 root
~~~~


When you run the command you must provide a source for the installable images. This could be the AIX product media, a directory containing the AIX images, or the name of an existing NIM lpp_source resource. You must also provide a name for the osimage you wish to create. This name will be used for the NIM SPOT resource that is created as well as the name of the xCAT osimage definition. The naming convention for the other NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 61cosi_lpp_source").

For example, to create an osimage named "610image" using the images contained in the /myimages directory you could run the following command. This will create resources for installing a NIM "standalone" type machine using the NIM "rte" install method. This is the default type created with **mknimimage** command. This type and others can be specified explicitly via flags on the command line. See the **mknimimage** manpage for more details. This command takes a while to complete.

By default the command will create NIM lpp_source, spot, and bosinst_data resources. You can specify alternate or additional resources using the "attr=value" option, ("&lt;nim resource type&gt;=&lt;resource name&gt;"). Additional resources will need to be created in advance via nim and created under /install/nim. An example would be /install/nim/resolv_conf/610image_resolv_conf/resolv.conf.

For example:

~~~~
    mknimimage -s /myimages 610image resolv_conf=610image_resolv_conf
~~~~


**Note**: To populate the /myimages directory you could copy the software from the AIX product media using the AIX gencopy command. For example you could run "gencopy -U -X -d /dev/cd0 -t /myimages all".

**Note**: Another alternative is to run **mknimimage** without the additional resources and then simply add them to the xCAT osimage definition later. You can add or change the osimage definition at any time. When you initialize and install the nodes xCAT will use whatever resources are specified in the osimage definition.

When the command completes it will display the osimage definition which will contain the names of all the NIM resources that were created. The naming convention for the NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 610image_lpp_source"), except for the SPOT name. The default name for the SPOT resource will be the same as the osimage name.

For example:

~~~~
    lsdef -t osimage -l 610image

    Object name: 610image
    bosinst_data=610image_bosinst_data
    imagetype=NIM
    lpp_source=610image_lpp_source
    nimmethod=rte
    nimtype=standalone
    osname=AIX
    resolv_conf=610image_resolv_conf
    spot= 610image
~~~~



Once the initial osimage definition is created you can change it by using the **chdef** command. For example, you may need to create additional NIM resources to use when installing the nodes, such as script or installp_bundle resources.

The xCAT osimage definition can be listed using the **lsdef** command and removed using the **rmnimimage** command. See the man pages for details. In some cases you may also want to modify the contents of the NIM resources. For example, you may want to change the bosinst_data file or add to the resolv_conf file etc. For details concerning the NIM resources refer to the NIM documentation. You can list NIM resource definitions using the AIX **lsnim** command. For example, if the name of your SPOT resource is "610image" then you could get the details by running:

~~~~
    lsnim -l 610image
~~~~


To see the actual contents of a NIM resource use "nim -o showres &lt;resource name&gt;". For example, to get a list of the software installed in your SPOT you could run:

~~~~
    nim -o showres 610image
~~~~


**Note**: The **mknimimage** command will take care of the NIM master installation and configuration automatically, however, you can also do this using the standard AIX support. See the AIX documentation for details on using the **nim_master_setup** command or the SMIT "eznim" interface.

### **Create an image_data resource (optional)**

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

~~~~
    nim -o define -t image_data -a server=master -a location= /install/nim/image_data/myimage_data myimage_data
~~~~


Add this resources to your xCAT osimage definition run:

~~~~
    chdef -t osimage -o 610SNimage image_data=myimage_data
~~~~


For more information on using the image_data resource refer the the AIX/NIM documentation.

### **Add additional software**

On xCAT cluster nodes the a xCATaixCN61.bnd bundle file specifies software that is required for the install. The openssl and openssh should be available from the AIX product media. The prerequisite rpms are available in the dep-aix-&lt;version&gt;.tar.gz tar file that you downloaded from the xCAT download page.. Add these to the NIM lpp_source that is being used for this OS image. This process can be used to add any additional software that may be needed.

#### **Create NIM installp_bundle resources**

To facilitate this you can copy the a sample bundle file provided by xCAT to /install/nim/installp_bundles. This will tell NIM to install to include it in the installation. Starting with xCAT 2.4.3 there are two sets of sample bundle files provided. One set can be used when installing a service node and one set is used when install a compute node. For each set there is a version number in the name corresponding to the different AIX OS levels. (xCATaixCN53.bnd, xCATaixCN61.bnd etc.) Use the one that corresponds to the version of AIX you are running. These sample files are installed in "/opt/xcat/share/xcat/installpbundles_".

Note: If you are using an older version of xCAT you can find sample bundle files included in the core-aix-&lt;version&gt;.tar.gz tar file.

Note: There are two versions of perl-Net_SSLeay.pm rpm listed in the sample bundle files, use perl-Net_SSLeay.pm-1.30-3* for AIX 7.1.2 and older version, use perl-Net_SSLeay.pm-1.55-3* for AIX 7.1.3 and above, see details in xCATaixCN71.bnd and xCATaixSN71.bnd.

Define the bundle file(s) as NIM resources and add them to the xCAT osimage definition.

~~~~
    nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/xCATaixCN61.bnd xCATaixCN61
~~~~


Verify the bundle resource was created.

~~~~
    lsnim -l xCATaixCN61
~~~~


Add the bundle resources to your xCAT osimage definition.

~~~~
    chdef -t osimage -o 610image installp_bundle=xCATaixCN61
~~~~


#### **Copy the software to the lpp_source resource**

The software listed in the bundle_file must copied to the NIM lpp_source that is being used for this OS image.

In this example the xCAT dependency rpms were under /install/xCAT/xcat-dep/6.1. The required installp filesets from the AIX media were copied to /install/post/otherpkgs/aix/ppc64/base. Additional user specified filesets were under /install/post/otherpkgs/aix/ppc64/other. Add them to the lpp_source.

~~~~
    nim -o update -a packages=all -a source=/install/xCAT/xcat-dep/6.1 610imagelpp-source_
    nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/base 610image_lpp_source
    nim -o update -a packages=all -a source=/install/post/otherpkgs/aix/ppc64/other 610image_lpp_source
~~~~


**Note:** In newer versions of the dep-aix-&lt;version&gt;.tar.gz tar file the packges are found in subdirectories corresponding to the AIX OS version (ex. 6.1, 71. etc).

#### **Check the osimage**

To avoid potential problems when installing a node verify that all of the software was copied to the appropriate NIM lpp_source directory.

~~~~
    lsnim -l 610image_lpp_source
~~~~


If your bundle files include rpm entries that use a wildcard (*) you must make sure the lpp_source directory does not contain multiple packages that will match that entry. (NIM will attempt to install multiple version of the same package and produce an error!) To find the location of the lpp_source directories run the "lsnim -l &lt;lpp_source_name&gt;" command. For example:

If the location of your lpp_source resource is "/install/nim/lpp_source/610image_lpp_source/" then you would find rpm packages in "/install/nim/lpp_source/610image_lpp_source/RPMS/ppc" and you would find your installp and emgr packages in "/install/nim/lpp_source/610image_lpp_source/installp/ppc".

Starting with xCAT version 2.4.3 you can use the xCAT **chkosimage** command to do this checking. For example:

~~~~
    chkosimage -V 610image
~~~~


See the **chkosimage** man page for details.

### **Define xCAT networks**

Create an xCAT network definition for each network that contains cluster nodes. You will need a name for the network and values for the following attributes.

    **net** The network address.
    **mask** The network mask.
    **gateway** The network gateway.



You can use the xCAT **makenetworks** command to gather cluster network information and create xCAT network definitions. See the **makenetworks** man page for details.


In our example we will assume that all the cluster node management interfaces and the xCAT management node interface are on the same network. You can use the xCAT **mkdef** command to define the network.


For example:




~~~~
    mkdef -t network -o net1 net=9.114.113.224 mask=255.255.255.224 gateway=9.114.113.254
~~~~





  * **Note**: The xCAT definition should correspond to the NIM network definition. If multiple cluster subnets are needed then you will need an xCAT and NIM network definition for each one.

### **Create additional NIM network definitions (optional)**

For the processs described in this document we are assuming that the xCAT management node and the LPARs are all on the same network.

However, depending on your specific situation, you may need to create additional NIM network and route definitions.

NIM network definitions represent the networks used in the NIM environment. When you configure NIM, the primary network associated with the NIM master is automatically defined. You need to define additional networks only if there are nodes that reside on other local area networks or subnets. If the physical network is changed in any way, the NIM network definitions need to be modified.

To create the NIM network definitions corresponding to the xCAT network definitions you can use the xCAT **xcat2nim** command.

For example, to create the NIM definitions corresponding to the xCAT "clstr_net" network you could run the following command.

~~~~
    xcat2nim -V -t network -o clstr_net
~~~~



**Manual method**

The following is an example of how to define a new NIM network using the NIM command line interface.

**Step 1**

Create a NIM network definition. Assume the NIM name for the new network is "clstr_net", the network address is "10.0.0.0", the network mask is "255.0.0.0", and the default gateway is "10.0.0.247".

~~~~
nim -o define -t ent -a net_addr=10.0.0.0 -a snm=255.0.0.0 -a routing1='default 10.0.0.247' clstr_net
~~~~

**Step 2**

Create a new interface entry for the NIM "master" definition. Assume that the next available interface index is "2" and the hostname of the NIM master is "xcataixmn". This must be the hostname of the management node interface that is connected to the "clstr_net" network.

~~~~
    nim -o change -a if2='clstr_net xcataixmn 0' -a cable_type2=N/A master
~~~~


**Step 3 - (optional)**

If the new subnet is not directly connected to a NIM master network interface then you should create NIM routing information

The routing information is needed so that NIM knows how to get to the new subnet. Assume the next available routing index is "2", and the IP address of the NIM master on the "master_net" network is "8.124.37.24". Assume the IP address on the NIM master on the "clstr_net" network is " 10.0.0.241". This command will set the route from "master_net" to "clstr_net" to be " 10.0.0.241" and it will set the route from "clstr_net" to "master_net" to be "8.124.37.24".

~~~~
    nim -o change -a routing2='master_net 10.0.0.241 8.124.37.24' clstr_net
~~~~


**Step 4**

Verify the definitions by running the following commands.

~~~~
    lsnim -l master
    lsnim -l master_net
    lsnim -l clstr_net
~~~~



See the NIM documentation for details on creating additional network and route definitions. (IBM AIX Installation Guide and Reference. &lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;)

### **Define the HMC as an xCAT node**

The xCAT hardware control support requires that the hardware control point for the nodes also be defined as a cluster node.

The following command will create an xCAT node definition for an HMC with a host name of "hmc01". The groups, nodetype, hwtype, mgt, username, and password attributes must be set.

~~~~
    mkdef -t node -o hmc01 groups="hmc,all" nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc123
~~~~



If xCAT Management Node is in the same service network with HMC, you will be able to discover the HMC and create an xCAT node definition for the HMC automatically.

~~~~
    lsslp -w -s HMC
~~~~


The above xCAT command lsslp discovers and writes the HMCs into xCAT database, but we still need to set HMCs' username and password.

~~~~
    chdef -t node -o hmc01 username=hscroot password=abc123
~~~~


For more details with hardware discovery feature in xCAT, please refer to document:

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node]

[XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems]

### **Discover the LPARs managed by the HMC**

This step assumes that the partitions are already created using the standard HMC interfaces.

Use the **rscan** command to gather the LPAR information. This command can be used to display the LPAR information in several formats and can also write the LPAR information directly to the xCAT database. In this example we will use the "-z" option to create a stanza file that contains the information gathered by **rscan** as well as some default values that could be used for the node definitions.

To write the stanza format output of **rscan** to a file called "mystanzafile" run the following command.

~~~~
    rscan -z hmc01 > mystanzafile
~~~~


This file can then be checked and modified as needed. For example you may need to add a different name for the node definition or add additional attributes and values.

**Note**: The stanza file will contain stanzas for things other than the LPARs. This information must also be defined in the xCAT database. It is not necessary to modify the non-LPAR stanzas in any way.

The updated stanza file might look something like the following.

~~~~
    Server-9117-MMA-SN10F6F3D:
    objtype=node
    nodetype=ppc
    hwtype=fsp
    id=5
    model=9118-575
    serial=02013EB
    hcp=hmc01
    pprofile=
    parent=Server-9458-10099201WM_A
    groups=fsp,all
    mgt=hmc
    node01:
    objtype=node
    nodetype=ppc,osi
    hwtype=lpar
    id=9
    hcp=hmc01
    pprofile=lpar9
    parent=Server-9117-MMA-SN10F6F3D
    groups=lpar,all
    mgt=hmc
    node02:
    objtype=node
    nodetype=ppc,osi
    hwtype=lpar
    id=7
    hcp=hmc01
    pprofile=lpar6
    parent=Server-9117-MMA-SN10F6F3D
    groups=lpar,all
    mgt=hmc

~~~~


**Note**: The **rscan** command supports an option to automatically create node definitions in the xCAT database. To do this the LPAR name gathered by **rscan** is used as the node name and the command sets several default values. If you use the "-w" option make sure the LPAR name you defined will be the name you want used as your node name.

### **Define xCAT cluster nodes**

The information gathered by the **rscan **command can be used to create xCAT node definitions.


Since we have put all the node information in a stanza file we can now pass the contents of the file to the **mkdef** command to add the definitions to the database.




~~~~
    cat mystanzafile | mkdef -z
~~~~


You can use the xCAT **lsdef** command to check the definitions (ex. "lsdef -l node01"). After the node has been defined, you can use the **chdef** command to make any additional updates to the definitions, if needed.

### **Add IP addresses and hostnames to /etc/hosts**

Make sure all node hostnames are added to /etc/hosts. See the following doc:

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node/#populate-the-etchosts-file](XCAT_AIX_Cluster_Overview_and_Mgmt_Node/#populate-the-etchosts-file)

### **Define xCAT groups (optional)**

XCAT supports both static and dynamic node groups. See the following doc for using node groups.

[Node_Group_Support]

### **Set up customization scripts (optional)**

xCAT supports the running of customization scripts on the nodes when they are installed.

This support includes:

  * The running of a set of default customization scripts that are required by xCAT.
You can see what scripts xCAT will run by default by looking at the "xcatdefaults" entry in the xCAT "postscripts" database table. ( I.e. Run "tabdump postscripts".). You can change the default setting by using the xCAT **chtab** or **tabedit** command. The scripts are contained in the /install/postscripts directory on the xCAT management node.
  * The optional running of customization scripts provided by xCAT.
There is a set of xCAT customization scripts provided in the /install/postscripts directory that can be used to perform optional tasks such as additional adapter configuration.
  * The optional running of user-provided customization scripts.

To have your script run on the nodes:

  1. Put a copy of your script in /install/postscripts on the xCAT management node. (Make sure it is executable.)
  2. Set the "postscripts" attribute of the node definition to include the comma separated list of the scripts that you want to be executed on the nodes. The order of the scripts in the list determines the order in which they will be run. For example, if you want to have your two scripts called "foo" and "bar" run on node "node01" you could use the **chdef** command as follows.

~~~~
    chdef -t node -o node01 -p postscripts=foo,bar
~~~~


(The "-p" means to add these to whatever is already set.)

**Note: **The customization scripts are run during the boot process (out of /etc/inittab).

#### **Add NTP setup script**

To have xCAT automatically set up ntp on the cluster nodes you must add the **setupntp** script to the list of postscripts that are run on the nodes.

To do this you can either modify the "postscripts" attribute for each node individually or you can just modify the definition of a group that all the nodes belong to.

For example, if all your nodes belong to the group "compute" then you could add **setupntp** to the group definition by running the following command.

~~~~
    chdef -p -t group -o compute postscripts=setupntp
~~~~





#### **Add secondary adapter configuration script**

To configure secondary adapters, see [Configuring_Secondary_Adapters].

#### **Configure NIM to use nimsh and SSL.**

The NIM service handler (**nimsh**), is provided as an optional feature of NIM to be used in cluster environments where the standard **rsh** protocols are not secure enough.


Although **nimsh** eliminates the need for **rsh**, in the default configuration it does not provide trusted authentication based on key encryption. To use cryptographic authentication with NIMSH, you can configure NIMSH to use OpenSSL in the NIM environment. When you install OpenSSL on a NIM client, SSL socket connections are established during NIMSH service authentication. Enabling OpenSSL provides SSL key generation and includes all cipher suites supported in SSL version 3.


In order to facilitate the setup of **nimsh**, xCAT provides a sample customization called "confignimsh" that can be used to configure **nimsh** on the cluster nodes.


This script will also configure **nimsh** to use SSL and will remove the /.rhosts file from the node. If you do not wish to have the .rhosts file removed from the node you must remove those lines from the **confignimsh** script before using it.


This script should only be run on AIX standalone (diskfull) cluster compute nodes. It should NOT be run on the xCAT management node, service nodes or diskless nodes.


The basic processes is:

  * Make sure the AIX openssl fileset gets installed on the management node and all the other cluster nodes. (Which should be done in any case.)
  * On the xCAT management node run the following command.nimconfig -c


You must also run this command on any service nodes that are being used.

  * Add "confignimsh" to the list of scripts you want run on the nodes


For example, if all your nodes belong to the group "compute" then you could add **confignimsh** to the group definition by running the following command.

~~~~
    chdef -p -t group -o compute postscripts=confignimsh
~~~~



After the nodes boot up you can verify that **nimsh** was set up correctly by running a NIM command such as: "nim -o lslpp &lt;nodename&gt;".


To be sure that nimsh is actually using SSL you can run the command:

~~~~
    "nimquery -a host=<nodename>".
~~~~



Example:




~~~~
    > nimquery -a host=xcatn11
    host:xcatn11.cluster.com:addr:10.2.0.104:mask:255.255.0.0:gtwy:
    10.2.0.200:pif:en0:_ssl:yes:_psh:no:_res:no:asyn:no:mac:163D0DDAE202:_sslver:OpenSSL 0.9.8k 25 Mar 2009:
~~~~



The "ssl:yes" indicates that **nimsh** is using SSL.


Note: You could also set up **nimsh** at any time using the xCAT **updatenode** command to run the **confignimsh** script on the nodes.

### **Create prescripts (optional)**

Starting with xCAT 2.5, prescript support is provided to run user-provided scripts during the node initialization process. These scripts can be used to help set up specific environments on the servers that handle the cluster node deployment. The scripts will run on the install server for the nodes. (Either the management node or a service node.) A different set of scripts may be specified for each node if desired.


One or more user-provided prescripts may be specified to be run either at the beginning or the end of node initialization. The node initialization on AIX is done either by the **nimnodeset** command (for diskfull nodes) or the **mkdsklsnode** command (for diskless nodes.)


You can specify a script to be run at the beginning of the **nimnodeset** or **mkdsklsnode** command by setting the prescripts-begin node attribute.


You can specify a script to be run at the end of the commands using the prescripts-end node attribute.


The format of the entry is:

    **[action1]:s1,s2...[|action2:s3,s4,s5...]...**


where:

    **action*** is either "standalone" or "diskless"
    **s1,s2..**are the prescripts to run for this action



The attributes may be set using the **chdef** command.


For example, if you wish to run the foo and bar prescripts at the beginning of the **nimnodeset** command you would run a command similar to the following.




~~~~
    chdef -t node -o node01 prescripts-begin="standalone:foo,bar"
~~~~


When you run the **nimnodeset** command it will start by checking each node definition and will run any scripts that are specified by the prescripts-begin attributes.


Similarly, the last thing the command will do is run any scripts that were specified by the prescripts-end attributes.


For more information about using the xCAT prescript support refer to the following documentation: [Postscripts_and_Prescripts]

### **Gather MAC information for the install adapters.**

[Gather_MAC_information_for_the_node_boot_adapters](Gather_MAC_information_for_the_node_boot_adapters)

### **Create NIM client &amp; group definitions**

You can use the xCAT **xcat2nim** command to automatically create NIM machine and group definitions based on the information contained in the xCAT database. By doing this you synchronize the NIM and xCAT names so that you can use the same target names when running either an xCAT or NIM command.


To create NIM machine definitions you could run the following command.




~~~~
     xcat2nim -t node aixnodes
~~~~



To create a NIM group definition called "aixgrp" you could run the following command.

~~~~
    xcat2nim -t group -o aixgrp
~~~~



To check the NIM definitions you could use the NIM **lsnim** command or the xCAT **xcat2nim** command. For example, the following command will display the NIM definitions of the nodes: node01, node02, and node03 (from data stored in the NIM database).




~~~~
    xcat2nim -t node -l -o node01-node03
~~~~


### **Initialize the AIX/NIM nodes**

You can use the xCAT **nimnodeset** command to initialize the AIX standalone nodes. This command uses information from the xCAT osimage definition and default values to run the appropriate NIM commands.


For example, to set up all the nodes in the group "aixnodes" to install using the osimage named "610image" you could issue the following command.




~~~~
    nimnodeset -V -i 610image aixnodes
~~~~


To verify that you have allocated all the NIM resources that you need you can run the "**lsnim -l**" command. For example, to check node "node01" you could run the following command.




~~~~
    lsnim -l node01
~~~~


The **nimnodeset** command will also set the "profile" attribute in the xCAT node definitions to "610image ". Once this attribute is set you can run the nimnodeset command without the "-i" option.

### **Open a remote console (optional)**

You can open a remote console to monitor the boot progress using the xCAT **rcons** command. This command requires that you have **conserver** installed and configured.

**If you wish to monitor a network installation you must run rcons before initiating a network boot.**

To configure conserver run:

~~~~
    makeconservercf
~~~~


To start a console:

~~~~
    rcons node01
~~~~


**Note: You must always run makeconservercf after you define new cluster nodes.**

### **Initiate a network boot**

Initiate a remote network boot request using the xCAT **rnetboot** command. For example, to initiate a network boot of all nodes in the group "aixnodes" you could issue the following command.

~~~~
    rnetboot aixnodes
~~~~


**Note**: If you receive timeout errors from the **rnetboot** command, you may need to increase the default 60-second timeout to a larger value by setting ppctimeout in the site table:

~~~~
    chdef -t site -o clustersite ppctimeout=180
~~~~


### **Verify the deployment**

  * You can use the AIX **lsnim** command to see the state of the NIM installation for a particular node, by running the following command on the NIM master:

~~~~
     lsnim -l <clientname>
~~~~


  * Retry and troubleshooting tips:
  * For p6 lpars, it may be helpful to bring up the HMC web interface in a browser and watch the lpar status and reference codes as the node boots.
  * Verify network connections
  * If the **rnetboot** returns "unsuccessful" for a node, verify that bootp/dhcp and tftp is configured and running properly.
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


  * Attempt to mount a filesystem from another system on the network.

## Cleanup

The NIM definitions and resources that are created by xCAT commands are not automatically removed. It is therefore up to the system administrator to do some clean up of unused NIM definitions and resources from time to time. (The NIM lpp_source and SPOT resources are quite large.) There are xCAT commands that can be used to assist in this process.




### **Removing NIM machine definitions**

Use the xCAT **xcat2nim** command to remove all NIM machine definitions that were created for the specified xCAT nodes. This command will not remove the xCAT node definitions.


For example, to remove the NIM machine definition corresponding to the xCAT node named "node01" you could run the command as follows.




~~~~
    xcat2nim -t node -r node01
~~~~



The **xcat2nim** command is intended to make it easier to clean up NIM machine definitions that were created by xCAT. You can also use the AIX **nim** command directly. See the AIX/NIM documentation for details.

### **Removing NIM resources**

Use the xCAT **rmnimimage** command to remove all the NIM resources associated with a given xCAT osimage definition. The command will only remove a NIM resource if it is not allocated to a node. You should always clean up the NIM node definitions before attempting to remove the NIM resources. The command will also remove the xCAT osimage definition that is specified on the command line.

For example, to remove the "610image" osimage definition along with all the associated NIM resources run the following command.

~~~~
    rmnimimage -x 610image
~~~~


If necessary, you can also remove the NIM definitions directly by using NIM commands. See the AIX/NIM documentation for details.

