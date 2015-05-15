<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Installing xCAT and prerequisite Software](#installing-xcat-and-prerequisite-software)
  - [Set up an AIX system to use as an xCAT Management Node](#set-up-an-aix-system-to-use-as-an-xcat-management-node)
  - [Install AIX prerequisite software](#install-aix-prerequisite-software)
    - [openssl and openssh](#openssl-and-openssh)
    - [expect, tk, and tcl](#expect-tk-and-tcl)
    - [devices.tmiscw (Optional)](#devicestmiscw-optional)
  - [Create a new volume group for your /install directory (optional)](#create-a-new-volume-group-for-your-install-directory-optional)
  - [Create a new volume group for your NIM dump resource directory (optional)](#create-a-new-volume-group-for-your-nim-dump-resource-directory-optional)
  - [Download and install the prerequisite Open Source Software (OSS)](#download-and-install-the-prerequisite-open-source-software-oss)
  - [Download and install the xCAT software.](#download-and-install-the-xcat-software)
  - [Verify the xCAT installation.](#verify-the-xcat-installation)
- [Additional configuration of the management node](#additional-configuration-of-the-management-node)
  - [Cluster network configuration notes](#cluster-network-configuration-notes)
  - [Additional requirements for Power 775 support (optional)](#additional-requirements-for-power-775-support-optional)
  - [Choose the shell to use in the cluster (optional)](#choose-the-shell-to-use-in-the-cluster-optional)
  - [Configuring name resolution](#configuring-name-resolution)
  - [DHCP configuration(Optional)](#dhcp-configurationoptional)
  - [Syslog setup](#syslog-setup)
  - [Set cluster root password](#set-cluster-root-password)
  - [Set up NTP (optional)](#set-up-ntp-optional)
  - [Increase file size limit](#increase-file-size-limit)
  - [Check the policy definitions.](#check-the-policy-definitions)
  - [Check system services](#check-system-services)
  - [NIM NFSv4 support (optional)](#nim-nfsv4-support-optional)
- [Managing Large Table](#managing-large-table)
- [Terminology](#terminology)
- [Next Steps](#next-steps)
  - [Installing AIX standalone nodes (using NIM rte method)](#installing-aix-standalone-nodes-using-nim-rte-method)
  - [Installing AIX diskless nodes (using stateless,statelite,stateful methods)](#installing-aix-diskless-nodes-using-statelessstatelitestateful-methods)
  - [Setting up an AIX Hierarchical Cluster](#setting-up-an-aix-hierarchical-cluster)
  - [Cloning AIX nodes (install using AIX mksysb image)](#cloning-aix-nodes-install-using-aix-mksysb-image)
  - [Updating AIX cluster nodes](#updating-aix-cluster-nodes)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Installing xCAT and prerequisite Software

### Set up an AIX system to use as an xCAT Management Node

  * xCAT can be installed on any system that is running a supported version of AIX. Release 2.5 and 2.6 of xCAT supports AIX version 6 and 7.
  * xCAT supports IBM Power 6 and Power 7 hardware.
  * The amount of memory, disk space, network adapters etc. you need will depend on the specific requirements of the cluster you will be creating.
  * Follow AIX documentation and procedures to install and configure the base AIX operating system. (Typically by using the product media.)
  * Make sure the OS version installed on the management node is greater than or equal to the OS versions you wish to install on the cluster nodes.

### Install AIX prerequisite software

To install the additional AIX software you have a choice of several different interfaces provided by AIX. Perhaps the easiest method is to use the SMIT (or "smitty") interface but you could also use the AIX geninstall, installp, or rpm commands if you like. Refer to the AIX documentation if you are not familiar with this support. (http://www-03.ibm.com/servers/aix/library/index.html)


Important Note

After installing installp file sets you should run /usr/sbin/updtvpkg to make sure that the RPM reflection of what was installed by installp is updated. This makes it possible for RPM packages with a dependencies to recognize that the dependency is satisfied.

~~~~
    updtvpkg
~~~~


#### openssl and openssh

The openssl and openssh installp filesets are now available on AIX product media. (Starting in AIX 6.1.3.)


You can check to see if these are installed by running the "lslpp" command. For example:




~~~~
    lslpp -l | grep open
~~~~



If they are not installed then use the AIX product media and standard AIX tools to install them.

#### expect, tk, and tcl

This software is now shipped with AIX product media. (Starting in AIX 6.1.2.)

They are normally installed with AIX but in some cases you will have to install them manually from the AIX media.

Check if they are installed and install them if needed.

If they are not available on the AIX media then you can get them from the "AIX Toolbox for Linux Applications" (http://www-03.ibm.com/systems/power/software/aix/linux/toolbox/alpha.html)

#### devices.tmiscw (Optional)

If you plan to be using AIX diskless nodes and you wish to set up system dump support for those nodes then you will need the devices.tmiscw software installed on your management node. This software is available on the AIX Expansion Pack.

Install the software using standard AIX interfaces.

Note: The xCAT diskless dump support is available in xCAT version 2.5 and beyond. You will also need AIX 6.1.6 or greater for full support. The devices.tmiscw fileset has prerequisite on AIX package devices.common.IBM.iscsi.rte .

### Create a new volume group for your /install directory (optional)

By default xCAT uses the /install directory to store various xCAT and NIM resources. XCAT will create /install as a subdirectory of the / (root) file system. In some cases /install may not contain enough space for your intended use.

To avoid this problem you could create a separate file system called /install on the management server to store the files that are to be used with xCAT and NIM. The size of this file system depends on your particular cluster.

The largest files that will be stored in /install subdirectories will be the NIM resources required for installing AIX nodes. The space required for a unique set of AIX operating system installation resources is approximately 2.0 GB. If you will need to manage several levels of OS images you should plan on at least 2G for each.

You can create the /install file system as part of the rootvg or in its own volume group. The following examples illustrate how to create the /install file system using the root volume group. To create a 5 GB file system called /install you could issue the AIX crfs command:

~~~~
    crfs -v jfs2 -g rootvg -m /install -a size=5G -A yes
~~~~


After you have created /install, you must mount it, as follows:

~~~~
    mount /install
~~~~


Note: You can use the AIX SMIT interfaces to create new volume groups and file systems etc. For example, to create a new file system you could use the SMIT fastpath ("crfs") to go directly to the correct SMIT panel. (Just type "smit crfs".)




### Create a new volume group for your NIM dump resource directory (optional)

If you will be using NIM diskless dump resources you want to also consider creating a separate dump file system to store any system dumps that are initiated on the nodes. This will prevent the /install filesystem from running out of space. When you define your NIM dump resource you can use the new dump filesystem as the location.

You can use the AIX SMIT (or smitty) interfaces to create new volume groups and file systems etc. See the AIX documentation for details.

### Download and install the prerequisite Open Source Software (OSS)

(Don't forget to run updtvpkg before installing rpms!)

  * Download the latest dep-aix-*.tar.gz tar file from http://xcat.sourceforge.net/#downloadand and copy it to a convenient location on your xCAT management node.
  * Unwrap the tar file. For example:

~~~~
    gunzip dep-aix-*.tar.gz
    tar -xvf dep-aix-*.tar
~~~~


  * Read the README file. Please note that there are separate AIX dependency directories for AIX53, AIX61, and AIX71
  * Run the instoss script (contained in the tar file) to install the OSS packages. Please make sure the /opt and the other file systems have enough disk space to install these OSS packages before running the instoss script.

~~~~
       ./instoss
~~~~


Note: The expect, tk and tcl rpms are no longer shipped by xCAT. They are now shipped with AIX and should have been installed automatically. If they are not then install them from the AIX media.

Note #2: For easier downloading without a web browser, you may want to download and install the wget tool from the AIX Toolkit for Linux.

### Download and install the xCAT software.

Note:For various reasons it is recommended that you set the primary hostname of the management node to the interface that you will be using to install the nodes. If you do this before you install xCAT then xCAT will be able to set some cluster site default values automatically. It will also make it easier when configuring NIM. When setting the primary host name make sure the domain is included.

  * Download the latest xCAT for AIX tar file from http://xcat.sourceforge.net/#downloadand copy it to a convenient location on your xCAT management node.
  * Unwrap the xCAT tar file. For example,

~~~~
    gunzip core-aix-*.tar.gz
    tar -xvf core-aix-*.tar
~~~~


  * Run the instxcat script (contained in the tar file) to install the xCAT software on the Management Node. This script should only be used on the Management Node, not on the Service Nodes which installs different software. The post processing provided by the xCAT packages will perform some basic xCAT configuration. (This includes initializing the SQLite database and starting xcatd daemon processes.) Note: xCAT software packages will install about 200MB files into /opt directory, make sure the /opt directory has enough disk space before running instxcat script.

~~~~
       ./instxcat
~~~~


  * (Optional) Update the PATH environment variable in the /etc/profile. AIX 7.1.1.0 introduces a new command /usr/sbin/chdef, which conflicts with the xCAT command /opt/xcat/bin/chdef, the /usr/sbin/chdef will be called before the /opt/xcat/bin/chdef command by default, xCAT 2.6.9 or newer builds will update the PATH environment variable in /etc/profile to put the xCAT commands directories before the operating system commands directories in the fresh new installation scenarios on AIX. If you are updating the xCAT on the management node installed with AIX 7.1.1.0 or higher AIX levels, you can manually update the PATH environment variable in /etc/profile. Here is an example:

~~~~
    PATH=$XCATROOT/bin:$XCATROOT/sbin:$PATH
~~~~


  * Execute the system profile file to set the xCAT paths. This file was updated during the xCAT post install processing. (". /etc/profile"). ( Note: Make sure you don't have a .profile file that overwrites the "PATH" environment variables.)

~~~~
       . /etc/profile
~~~~


### Verify the xCAT installation.

  * Run the "lsdef -h" command to check if the xCAT daemon is working. (If you get a correct response then you should be OK. )
  * Check to see if the initial xCAT definitions have been created. For example, you can run:

~~~~
    lsdef -t site -l
~~~~


to get a listing of the default site definition. You should see output similar to the following.


~~~~
     Object name: clustersite
     domain=abc.foo.com
     installdir=/install
     tftpdir=/tftpboot
     master=7.104.46.27
     useSSHonAIX=yes
     xcatdport=3001
     xcatiport=3002
~~~~


    Important: The "domain" and "master" values are set automatically by xCAT when it is installed. To do this xCAT looks at the primary hostname of the management node.

    For the "domain" attribute, if the management node hostname was set to a short hostname then the domain attribute would not be set by default. It is also possible that the domain would be set to a value other than the domain that is used for the cluster nodes. In either case you must manually set the domain value to the network domain that will be used for the cluster nodes.You can use the xCAT chdef command to modify the domain attribute of the cluster site definition.

    For example:

~~~~
    chdef -t site domain=mycluster.com
~~~~


    The "master" attribute must be set to the hostname of the xCAT management node, as known by the nodes.

    For example:

~~~~
    chdef -t site master=xcatmn
~~~~


## Additional configuration of the management node

### Cluster network configuration notes

  * The cluster network topology, naming conventions etc. should be carefully planned before beginning the cluster node deployment.
  * XCAT requires an Ethernet network for installing and managing cluster nodes.
  * Cluster nodes may be on different subnets.
  * The cluster nodes must all have unique short host names to use in the xCAT node definitions.
  * All cluster nodes must use the same domain name. The domain attribute must be set in the cluster site definition.

NOTE: Starting with xCAT version 2.8 you will be able to specify multiple cluster network domains by adding a unique domain value to the xCAT network definitions.

  * The management node interfaces that will be used to manage the nodes should be configured before starting the xCAT deployment process.
  * XCAT network definitions will have to be created for each unique subnet used in the cluster. (This will be described in one of the install documents listed below.)
  * If you will be using the xCAT management node or a service node as a gateway remember to set "ipforwarding" to "1".

### Additional requirements for Power 775 support (optional)

Note: This support will be available in xCAT 2.6.6 and beyond.

The following is a list of the required software to support the HFI. This software is currently made available in the Pok CMVC build environment. The packages will be made available externally and this section will be updated at that time.


~~~~
    devices.chrp.IBM.HFI
    devices.common.IBM.hfi
    devices.common.IBM.ml
    devices.msg_en_US.chrp.IBM.HFI.rte
    devices.msg_en_US.common.IBM.hfi
    devices.msg.en_US.common.IBM.ml
~~~~


### Choose the shell to use in the cluster (optional)

By default the xCAT support will automatically set up ssh on all AIX cluster nodes. If you wish to use rsh you should modify the cluster site definition. To use rsh you would have to set the "useSSHonAIX=no".

You will also have to make sure that the openssl and openssh software is installed on your nodes. This is covered in the cluster node installation documents listed below.

To change the shell you must change the value of the useSSHonAIX attribute in the cluster site definition. For example:

~~~~
    chdef -t site useSSHonAIX=no

~~~~

Note: If, at some future point, you wish to check which shell is being used you can run xdsh to a node with the "-T" (trace) option. For example:

~~~~
    xdsh node01 -v -T date
~~~~


Note: The default shell for xCAT 2.3 and beyond is ssh. In earlier versions of xCAT the default was rsh.

### Configuring name resolution

For more information on Cluster Name Resolution, read this doc
[Cluster_Name_Resolution](Cluster_Name_Resolution)


### DHCP configuration(Optional)

For AIX clusters, there is a bootp service daemon on the xCAT management node that is used to respond to boot requests from AIX nodes. It is possible to use the AIX DHCP service instead of bootp when installing AIX nodes. To do this you must first stop the bootpd daemon and then enable dhcpsd. If you are using the xCAT hardware discovery support, you should review the System P Hardware Management Guide, or if you are supporting a P775 cluster you should review the xCAT Power 775 Hardware Management guide before configuring the DHCP environment on the xCAT management node.

    Stop bootpd from starting on reboot or restart of inetd by commenting out the bootps line in /etc/inetd.conf file:



~~~~
    #bootps dgram udp wait root /usr/sbin/bootpd bootpd /etc/bootptab
~~~~

    Restart inetd and kill bootp just to make sure:



~~~~
    refresh -s inetd                            # restart the inetd subsystem

    kill `ps -ef | grep bootp | grep -v grep | awk '{print $2}' `    # stop the bootp daemon
~~~~

    Uncomment this line in /etc/rc.tcpip so that dhcpsd will start after a reboot.


~~~~

    start /usr/sbin/dhcpsd "$src_running"             # start up the DHCP Server
~~~~

Have xCAT configure the network stanzas for DHCP and then start the dhcpsd daemon. See the makedhcp man page for details.



~~~~
    makedhcp -n
    startsrc -s dhcpsd
~~~~

To check the status of dhcpsd you could run the following command.



~~~~
    lssrc -ls dhcpsd | more
~~~~

Look at the DHCP configuration file on the xCAT management node to ensure that it contains only the networks you want:



~~~~
    cat /etc/dhcpsd.cnf
~~~~

If you need to make updates to the DHCP configuration file, you should stop the DHCP daemon, edit the DHCP configuration file, and then restart the DHCP daemon on your xCAT management node.

Note: When using DHCP on AIX systems the node entries in the dhcpsd.cnf file will be handled by NIM. The xCAT makedhcp command will not add any nodes that have a "nodetype" of "osi". You can use the AIX "bootptodhcp" command to remove the NIM entries from the dhcpsd.cnf file.

### Syslog setup

xCAT will automatically set up syslog on the management node and the cluster nodes when they are deployed (installed or booted). When syslog is set up on the nodes it will be configured to forward the logs to the management node.

If you do not wish to have syslog set up on the nodes you must remove the "syslog" script from the "xcatdefaults" entry in the xCAT "postscripts" table. You can change the "xcatdefaults" setting by using the xCAT chtab or tabedit command.

For more information on Syslog see: [Syslog_and_auditlog]

### Set cluster root password

You can have xCAT create an initial root password for the cluster nodes when they are deployed. To set the password you must modify the xCAT "passwd" table.

If you do not do this, the node will come up with a default password of "xcatroot".

You will need an entry with a "key" set to "system", a "username" set to "root" and the "password" attribute set to whatever string you want.

For example:

~~~~
    chtab key=system passwd.username=root passwd.password=cluster
~~~~


In xCAT version 2.5 and beyond you may add an encrypted password to the table. If the password is encrypted you must also set the "cryptmethod" attribute so that the password can be set correctly on the nodes.

The encrypted password must be a value encrypted with the "crypt" algorithm.

For example, to get an encrypted value for the password "cluster" you could run the following command.

~~~~
     openssl passwd -crypt cluster
~~~~


The result would be a value similar to the following.

~~~~
     xxj31ZMTZzkVA
~~~~


To set the entry in the xCAT passwd table you could run the following:

~~~~
      chtab key=system passwd.username=root passwd.password=xxj31ZMTZzkVA  passwd.cryptmethod=crypt
~~~~


See the AIX passwd and chpasswd man pages for more information.

You can change the passwords on the nodes at any time using xdsh and the AIX chpasswd command.

For example:

~~~~
    xdsh node01 'echo "root:mypw" | chpasswd -c'
~~~~


### Set up NTP (optional)

To enable the NTP services on the cluster, first configure NTP on the management node and start ntpd.

Next set the "ntpservers" attribute in the site table. Whatever time servers are listed in this attribute will be used by all the nodes that boot directly from the management node.

If your nodes have access to the internet you can use the global servers:

~~~~
    chdef -t site ntpservers="0.north-america.pool.ntp.org,1.northamerica.pool.ntp.org,2.north-america.pool.ntp.org,3.northamerica.pool.ntp.org"
~~~~


If the nodes do not have a connection to the internet (or you just want them to get their time from the management node for another reason), you can use your management node as the NTP server. For example, if the name of you management node is "myMN" then you could run the following command.

~~~~
    chdef -t site ntpservers=myMN
~~~~


### Increase file size limit

Some of the AIX/NIM resources that are used to install nodes are quite large (1-2G) so it may be necessary to increase the file size limit.

For example, to set the file size limit to "unlimited" for the user "root" you could run the following command.

~~~~
    /usr/bin/chuser fsize=-1 root
~~~~


### Check the policy definitions.

When the xCAT software is installed it creates several policy definitions. To list the definitions you can run:

~~~~
    lsdef -t policy -l
~~~~


Most of the required policy definitions are created by default however, in some cases, you may need to create new definitions.

For example, you will need a policy for the primary hostname that was used when xCAT was installed. To find out what this was you can run:

~~~~
    openssl x509 -text -in /etc/xcat/cert/server-cert.pem -noout|grep Subject:
~~~~


The output would be somethng similar to the following:

~~~~
    Subject: CN=myMN.foo.bar"
~~~~


If "myMN.foo.bar" does not already exist in the policy table, then you can create a policy definition with the following command. (The policy names are numbers, just pick a number that is not yet used.)

~~~~
    mkdef -t policy -o 8 name= myMN.foo.bar rule=trusted
~~~~


### Check system services

  * inetd

inetd includes services such as telnet, ftp, tftp, bootp/dhcp, and others. Edit the /etc/inetd.conf file to turn on all services that are needed. FTP and bootp/dhcp are required for System p node installations. Stop and restart the inetd service after any changes:

~~~~
    stopsrc -s inetd
    startsrc -s inetd
~~~~


  * NFS

NFS is required for all NIM installs. Ensure the NFS daemons are running:

~~~~
    lssrc -g nfs
~~~~


If any NFS services are inoperative, you can stop and restart the entire group of services:

~~~~
    stopsrc -g nfs
    startsrc -g nfs
~~~~


There are other system services that NFS depends on such as inetd, portmap, biod, and others.

  * TFTP

To check if the TFTP daemon is running.

~~~~
    lssrc -a | grep tftpd
~~~~


To stop and start tftp daeon.

~~~~
    stopsrc -s tftpd
    startsrc -s tftpd
~~~~


### NIM NFSv4 support (optional)

By default, NIM uses NFSv3 for all diskful and diskless clients provision, start from AIX 6.1, NIM provides support for NFSv4. If you want to use NFSv4 with NIM in xCAT clusters, set the site.useNFSv4onAIX to yes before NIM master setup.

~~~~
     chdef -t site useNFSv4onAIX=yes
~~~~


If the NIM master has already been configured with NFSv3 and AIX images have already been defined as NFSv3 resources, use the command mknimimage -u to setup NIM master with NFSv4 and update the existing AIX images to NFSv4.

~~~~
     mknimimage -u image_name nfs_vers=4
~~~~


The nfs service needs to be restarted after the NFSv4 changes:

~~~~
     stopsrc -g nfs
     startsrc -g nfs
     exportfs -ua
     exportfs -a
~~~~


After that, rerun nimnodeset or mkdsklsnode to reinitialize the NIM clients.

Note: If you are using /etc/basecust as a statelite persistent file to preserve the ODM data for the nodes, you need to remove the $SPOTDIR/usr/lib/boot/network/rc.dd_boot and rerun mkdsklsnode, there are some NFSv3 related settings in the rc.dd_boot that needs to be updated to NFSv4 settings.

## Managing Large Table

For information on managing your large table read:

[Managing_Large_Tables](Managing_Large_Tables)



## Terminology

Some basic terminology.

  * standalone - An AIX node that has it's operating system installed on a local disk.
  * rte install - A network installation method supported by NIM that uses a NIM lpp_source resource to install a standalone node.
  * mksysb install - A network installation method supported by NIM that uses a system backup of one node (mksysb image) to install other standalone cluster nodes.
  * diskful \- For AIX systems this means that the node has local disk storage that is used for the operating system. (A standalone node.) Diskfull AIX nodes are typically installed using the NIM rte or mksysb install methods.
  * diskless \- The operating system is not stored on local disk. For AIX systems this means the file systems are mounted from a NIM server.
  * stateful \- A node that maintains its "state" after it has been shut down and rebooted. The node state is basically any node-specific information that has been configured on the node. For AIX diskless nodes this means that each node has its own NIM "root" resource that it can use to store node-specific information. Each node mounts its own root directory.
  * stateless -A node that does NOT maintain its state after it has been shut down and rebooted. For AIX diskless nodes this means that the nodes all use the same NIM "shared_root" resource. Each node mounts the same root directory. Anything that is written to the local root directory is redirected to memory and is lost when the node is shut down. Node-specific information must be re-established when the node is booted.
  * statelite \- An AIX diskless stateless node that also has a small amount of persistent files and/or directories. The persistent files and/or directories are mounted on the nodes. This support is available for AIX nodes in xCAT version 2.5 and beyond.

## Next Steps

Once the xCAT management node is configured you can proceed to any of the following documents.

If you are using Power 775 hardware you should use the hierarchical document listed below.

### Installing AIX standalone nodes (using NIM rte method)

Refer to the documentation on AIX RTE Diskfull install: [XCAT_AIX_RTE_Diskfull_Nodes]

### Installing AIX diskless nodes (using stateless,statelite,stateful methods)

Refer to the documentation on AIX Diskless Nodes: [XCAT_AIX_Diskless_Nodes]

### Setting up an AIX Hierarchical Cluster

Refer to the documentation on Setting up an AIX Hierarchical Cluster: [Setting_Up_an_AIX_Hierarchical_Cluster]

NOTE: If you are using Power 775 hardware you must set up a hierarchical cluster.

### Cloning AIX nodes (install using AIX mksysb image)

Refer to the documentation on AIX mksysb install: [XCAT_AIX_mksysb_Diskfull_Nodes]

### Updating AIX cluster nodes

Refer to the documenation on updating the AIX cluster nodes: [Updating_AIX_Software_on_xCAT_Nodes]

## References

  * xCAT Docs: [XCAT_Documentation]
  * xCAT Commands: [XCAT_Commands]
  * xCAT DB table descriptions: http://xcat.sf.net/man5/xcatdb.5.html
  * xCAT mailing list: http://xcat.org/mailman/listinfo/xcat-user
  * xCAT bugs: https://sourceforge.net/tracker/?group_id=208749&amp;atid=1006945
  * xCAT feature requests: https://sourceforge.net/tracker/?group_id=208749&amp;atid=1006948
  * xCAT wiki: http://xcat.wiki.sourceforge.net/

