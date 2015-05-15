<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Hierarchical xCAT Clusters](#hierarchical-xcat-clusters)
  - [Examples of Cluster Sizes](#examples-of-cluster-sizes)
  - [Setting up a Hierarchical xCAT Cluster](#setting-up-a-hierarchical-xcat-cluster)
  - [Distribution of Services](#distribution-of-services)
    - [NFS Servers](#nfs-servers)
    - [Console Servers](#console-servers)
    - [DHCP Servers](#dhcp-servers)
    - [HTTPD Servers](#httpd-servers)
    - [Other Services](#other-services)
- [System Tuning Attributes](#system-tuning-attributes)
  - [Setting Tuning Parameters in a Diskless Image](#setting-tuning-parameters-in-a-diskless-image)
    - [Setting Tuning Parameters in a Linux Diskless Image](#setting-tuning-parameters-in-a-linux-diskless-image)
    - [Setting Tuning Parameters in an AIX Diskless Image](#setting-tuning-parameters-in-an-aix-diskless-image)
  - [System Tuning Settings for Linux](#system-tuning-settings-for-linux)
  - [System Tuning Settings for AIX](#system-tuning-settings-for-aix)
    - [Tuning ARP on AIX](#tuning-arp-on-aix)
    - [Tuning AIX Network Attributes](#tuning-aix-network-attributes)
    - [Tuning AIX ulimits](#tuning-aix-ulimits)
  - [Tuning the MySQL Server](#tuning-the-mysql-server)
  - [Tuning NFS (Network File System)](#tuning-nfs-network-file-system)
    - [Carefully Choose Statelite Persistent Files](#carefully-choose-statelite-persistent-files)
  - [Tuning TCP/IP Buffer Size for RMC on AIX](#tuning-tcpip-buffer-size-for-rmc-on-aix)
  - [Tuning httpd for xCAT node deployments](#tuning-httpd-for-xcat-node-deployments)
    - [Having httpd Cache the Files It Is Serving](#having-httpd-cache-the-files-it-is-serving)
  - [Tuning conserver on AIX management and service nodes](#tuning-conserver-on-aix-management-and-service-nodes)
- [Tuning for HPC Applications](#tuning-for-hpc-applications)
  - [HPC Tuning Guide](#hpc-tuning-guide)
  - [Tuning for GPFS](#tuning-for-gpfs)
  - [Tuning for PE and LAPI](#tuning-for-pe-and-lapi)
    - [Linux](#linux)
    - [AIX](#aix)
- [Using xCAT at Large Scale](#using-xcat-at-large-scale)
  - [Site Table Attributes](#site-table-attributes)
      - [Site Attributes Applicable to All Platforms](#site-attributes-applicable-to-all-platforms)
      - [Site Attributes Specific to IPMI-Controlled x86_64](#site-attributes-specific-to-ipmi-controlled-x86_64)
      - [Site Attributes Specific to IBM Flex](#site-attributes-specific-to-ibm-flex)
      - [Site Attributes Specific to IBM BladeCenter](#site-attributes-specific-to-ibm-bladecenter)
      - [Site Attributes Specific to System p](#site-attributes-specific-to-system-p)
    - [Using Flow Control](#using-flow-control)
  - [Command Flags](#command-flags)
  - [Useful xCAT commands for large clusters](#useful-xcat-commands-for-large-clusters)
  - [Consolidating xCAT Database Entries](#consolidating-xcat-database-entries)
    - [Nodegroup database entries](#nodegroup-database-entries)
    - [Regular expressions in database values](#regular-expressions-in-database-values)
  - [Sync files in a large cluster](#sync-files-in-a-large-cluster)
  - [Other considerations](#other-considerations)
    - [rpower Interval (pSeries)](#rpower-interval-pseries)
    - [Disks mirror on service nodes](#disks-mirror-on-service-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


# Introduction

xCAT supports clusters of all sizes. This document is a collection of hints, tips, and special considerations when working with large clusters, especially clusters with more than 128 nodes.

The information in this document should be viewed as example data only. Many of the suggestions are based on anecdotal experiences and may not apply to your particular environment. Suggestions in different sections of this document may recommend different or conflicting settings since they may have been provided by different people for different cluster environments. Often there is a significant amount of flexiblity in most of these settings -- you will need to resolve these differences in a way that works best for your cluster.


In addition to this document, more recommendations on tuning can be found at https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/Welcome%20to%20High%20Performance%20Computing%20%28HPC%29%20Central/page/System%20X%20Cluster%20Tuning%20Recommendations .

# Hierarchical xCAT Clusters

In an xCAT cluster, the single point of control is the xCAT management node. However, in order to provide sufficient scaling and performance for large clusters, it may also be necessary to have additional servers to help handle the deployment and management of the cluster nodes. In an xCAT cluster these additional servers are referred to as service nodes. xCAT only supports these two levels of management hierarchy: the xCAT management node as the top level, and xCAT service nodes as the second level.

A service node is managed by the xCAT management node. A compute node can be managed by either the xCAT management node or by a service node. All xCAT commands are initiated from the management node. xCAT will then internally distribute any hierarchical commands to the service nodes as required, and gather and consolidate the results.

When does it become important to start thinking about a hierarchical cluster? There are many factors to consider. Most clusters of 128 compute nodes or less can easily be handled by a single xCAT management node. Larger non-hierarchical clusters may be feasible given enough resources on your xCAT management node and cluster management network.

Factors:

  * Operating System: Non-hierarchical Linux clusters can typically be larger than AIX clusters. AIX uses NIM for node deployment, so the largest non-hierarchical AIX cluster will most likely be determined by the number of nodes the NIM master on your xCAT management node can deploy. Each service node in a hierarchical AIX cluster is configured as a NIM master to the compute nodes it manages.
  * Type of compute nodes: Will your compute nodes be stateful with its OS installed on a local disk, Linux stateless with the OS image loaded into memory, or Linux statelite or AIX stateless requiring an NFS server for the OS image? Each of these options places different burdens on the xCAT management node and service nodes.
  * Deployment services: Several services are used during node deployment, depending on the operating system and type of compute nodes: DHCP, TFTP, bootp, HTTP, NFS, conserver, and others. Any one of these services can become a bottleneck when trying to deploy too many nodes from a single server.
  * Management Network bandwidth: The capability of your network fabric may require you to distribute node deployment and management load across multiple subnets.




## Examples of Cluster Sizes

  * For Linux diskless clusters, some customers have been able to manage as many as 1000 diskless compute nodes from a single xCAT management node without introducing hierarchy. However, with such a large non-hierarchical cluster, it will most likely not be possible to simultaneously boot all compute nodes at once due to the strain that would be placed on your network and on the xCAT management node. If your administrative processes allow for incremental node deployment and boot, you can easily manage several hundred diskless or stateful (diskfull) compute nodes from a single xCAT management node.
  * The xCAT development team was able to successfully boot 300 Linux statelite compute nodes from a single xCAT management node.
  * A large Linux customer cluster using xCAT 2.2 was originally able to deploy 540 stateless compute nodes (ramdisk images) per service node. That same cluster was then updated to use a hybrid NFS solution with the diskless images.





## Setting up a Hierarchical xCAT Cluster

For details on setting up a Hierarchical xCAT cluster see:

[Setting_Up_an_AIX_Hierarchical_Cluster]

[Setting_Up_a_Linux_Hierarchical_Cluster]




## Distribution of Services

Many services are used during node deployment, depending on the operating system and type of compute nodes: DHCP, TFTP, bootp, HTTP, NFS, conserver, and others. Any one of these services can become a bottleneck when trying to deploy too many nodes from a single server.

The xCAT hierarchical support provides different options for distributing these services across your service nodes. Adjusting the way these services are distributed may provide increased deployment performance and stability.




### NFS Servers

xCAT uses NFS in hierarchical clusters in various ways:

  * (AIX) Mounting operating system images from service nodes to diskless nodes through NIM
  * (Linux) Mounting operating system images from service nodes to statelite nodes
  * Mounting persistent directories to statelite node
  * (AIX) Installing stateful nodes from service nodes through NIM
  * (Linux) Mounting the /install and /tftpboot directories from the xCAT management node to service nodes for stateless and stateful nodes

Note: For Linux stateful node installs, xCAT typically uses http instead of NFS to deploy operating system packages from the service nodes to the stateful nodes.

By default, xCAT will set up NFS servers on your xCAT management node and all service nodes when needed. However, xCAT does provide the option of using an external NFS server with HA capability using, for example, SONAS or GPFS CNFS. See:

[External_NFS_Server_Support_With_Linux_Statelite]

[External_NFS_Server_Support_With_AIX_Stateless_And_Statelite]

An external NFS server can also be a good solution for service nodes in a hierarchical cluster. You can then have /install on the external server shared by the management server and all service nodes. Any change on /install on the management server is immediately available on the service nodes.




### Console Servers

By default, xCAT runs conserver on the management node for all of your compute nodes. This may be adequate for your cluster, especially if you are able to use the "console on demand" option:

~~~~
      chdef -t site consoleondemand=yes
~~~~


When set to 'yes', xCAT will configure conserver to connect and create the console output for nodes only when the user opens the console. Default is 'no' on Linux and 'yes' on AIX. Using console on demand allows conserver to scale very well for any size cluster. However, you lose the ability to continuously log all console output.

If you would like to have your service nodes run conserver for all of the compute nodes they service, you will need to explicitly specify this to xCAT by turning on the 'setupconserver' attribute for the service nodes and by assigning the correct conserver server to each compute node. For example:

~~~~
      chdef service setupconserver=1
      chdef compute1 conserver=service1
~~~~





### DHCP Servers

By default on Linux clusters, each service node should be configured as a DHCP server for its compute nodes. There are MANY different network configurations that are possible in a hierarchical cluster. Providing the correct network and DHCP interface information to xCAT is important in allowing xCAT to automatically set up your DHCP configurations succinctly and correctly.

First, specify to xCAT that you want your service nodes to run DHCP by turning on the 'setupdhcp' attribute

~~~~
      chdef service setupdhcp=1
~~~~


Set your site table to tell xCAT which adapter interfaces DHCP should listen on:

      chdef -t site dhcpinterfaces='yourMN|nicM0,nicm1;service|nicS'


where nicM1(,nicM2,...) is the interface name(s) on your xCAT management node that is attached to your cluster management network, and where nicS is the interface name on your service nodes that is attached to the management network that its compute nodes are connected to. Setting these values will limit the networks that your DHCP servers will need to respond to.

By default, xCAT will configure the dhcpd.leases file to be identical on every dhcp server in the cluster, such that each leases file will contain an entry for EVERY compute node in your cluster. If your cluster management network is fully disjoint, that is you have a separate subnet for each service node and the compute nodes it manages, you can tell xCAT to only create leases entries for the compute nodes that a service node manages:

~~~~
      chdef -t site disjointdhcps=1
~~~~


When you first installed xCAT, your xCAT networks table was initially populated with information on all of the networks your management node is connected to. Edit your networks table entries include only the management networks in your cluster and that the information is correct. To list the current entries:

~~~~
      lsdef -t network -l
~~~~


and use chdef to modify any entries, and rmdef to remove any network definitions that are not required to manage your cluster.




### HTTPD Servers

Some Linux customers have reduced DHCP timeouts by creating separate subnets/vlans from the service nodes to compute nodes for the DHCP traffic and the HTTP traffic. When simultaneously deploying very large numbers of nodes, this allows DHCP to continue to respond to new node requests while HTTP requests for OS images are served on another subnet.

Author's note: I do not have specific instructions on what needs to be set up in xCAT to make this happen. If you have successfully done this, we would appreciate the input. Please post to the  [xCAT mailing list](http://lists.sourceforge.net/lists/listinfo/xcat-user). I'm guessing that you need to set the correct nfsserver attribute for the node to the service node's interface on the HTTP subnet, and to make sure that the node's interface on that subnet gets configured early enough to be available for the HTTP transfers of the OS images.




### Other Services

There are many other services that xCAT can distribute and automatically configure on your service nodes. To see a complete list:

~~~~
      tabdump -d servicenode
~~~~


Each of these services may require additional configuration in xCAT. You will need to search the xCAT documentation for more information on setting up and distributing a specific service.

# System Tuning Attributes

Adjusting operating system tunables can improve large scale cluster performance, avoid bottlenecks, and prevent failures. The following sections are a collection of suggestions that have been gathered from various large scale HPC clusters. You should investigate and evaluate the validity of each suggestion before applying them to your cluster.




## Setting Tuning Parameters in a Diskless Image

### Setting Tuning Parameters in a Linux Diskless Image

After creating your diskless using [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) (but before packing it using [packimage](http://xcat.sourceforge.net/man1/packimage.1.html)), you can chroot into the image and change any tuning parameters. (The diskless root directory is stored in the rootimgdir attribute of the osimage definition.) For example:

~~~~
    cd /install/netboot/rhels6.3/x86_64/compute
    chroot imgdir
~~~~


After making changes to the root image, you need to run packimage.

### Setting Tuning Parameters in an AIX Diskless Image

For any of the suggestions listed below that you would like to apply to your AIX diskless image, xcat provides the command:

~~~~
[xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html)
~~~~

This command allows you to modify the diskless image so that the tuning parameters are set during your node boot. Changes with **xcatchroot** could include anything that you wish to modify using the AIX **vmo** or **no** commands, system parameters, etc. **xcatchroot** can also be used to check and verify attributes. An important note is that changing some attributes in the diskless image will also require a bosboot to be run against that image. To run the bosboot against the image, you will need to run **nim -o check** image. It is a good idea to run the **nim -o check** of the image once any modifications have been done.

## System Tuning Settings for Linux

The "best practices" tuning settings for large linux clusters are documented in:

[Linux System Tuning Recommendations](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/Welcome%20to%20High%20Performance%20Computing%20%28HPC%29%20Central/page/Linux%20System%20Tuning%20Recommendations)

That web page is based on experience with many large linux clusters. It contains settings for:

  * the ARP cache
  * network settings
  * ulimits

Although there are a few settings in that page that are not needed on some types of nodes (xCAT management/service nodes, GPFS storage nodes, login nodes, or compute nodes), it doesn't hurt to set them on all types of nodes and it is much simpler.

## System Tuning Settings for AIX

### Tuning ARP on AIX

Address Resolution Protocol (ARP) is a network protocol that maps a network layer protocol address to a data link layer hardware address. For example, ARP is used to resolve an IP address to the corresponding Ethernet address.

In very large networks, the ARP table can become overloaded, which can give the appearance that the cluster software is slow.

There are several ARP tuning values that can be set on AIX. Read the discussion on "ARP Cache Tuning" in the ["AIX Performance Guide"](http://publib.boulder.ibm.com/infocenter/aix/v7r1/topic/com.ibm.aix.prftungd/doc/prftungd/prftungd_pdf.pdf)

The following are the default settings for ARP attributes in AIX 7.1:

~~~~
     arpqsize = 12
     arpt_killc = 20
     arptab_bsiz = 7
     arptab_nb = 149
~~~~

With these settings, the ARP table can hold 149 buckets (arptab_nb), with 7 entries per bucket (arptab_bsiz), for a total of 1043 entries. If a server connects to more than 1043 hosts concurrently, the system will purge an entry from the ARP table and replace it with a new request. Up to 12 requests (arpqsize) can be queued while this is processing. Entries will remain in the table for 20 minutes (arpt_killc).

Once you have determined the appropriate values for your cluster, you can change change the attributes by running the **no** command with the new values:

~~~~
     no -r .o arptab_nb=256
     no -r .o arptab_bsiz=8
     no -p -o arpqsize=64
~~~~


You must reboot your server for these changes to take affect.

### Tuning AIX Network Attributes

The following AIX attribute settings are recommended on all servers and compute nodes in large clusters:

~~~~
      no -p -o tcp_recvspace=524288
      no -p -o tcp_sendspace=524288
      no -p -o udp_recvspace=655360
      no -p -o udp_sendspace=65536
      no -p -o rfc1323=1
      no -p -o sb_max=8388608

~~~~

~~~~
      chdev -l sys0 -a maxuproc='8192'
~~~~


### Tuning AIX ulimits

Check ulimit settings:

~~~~
       ulimit -a
       time(seconds)        unlimited
       file(blocks)         unlimited
       data(kbytes)         131072
       stack(kbytes)        32768
       memory(kbytes)       32768
       coredump(blocks)     2097151
       nofiles(descriptors) 2000
       threads(per process) unlimited
       processes(per user)  unlimited
~~~~


If not unlimited, change the ulimit setting to unlimited, for this session. coredump is optional:

~~~~
     ulimit -m unlimited
     ulimit -n 102400
     ulimit -d unlimited
     ulimit -f unlimited
     ulimit -s unlimited
     ulimit -t unlimited
     ulimit -u unlimited
~~~~


Edit the /etc/security/limits file to make the settings permanent on reboot:

~~~~
    root:
           fsize = -1
           core= -1
           cpu= -1
           data= -1
           rss= -1
           stack= -1
           nofiles= 102400
           nproc = -1

~~~~

Note you should not set nofiles to unlimited (-1). This may cause problems for some system applications.

## Tuning the MySQL Server

If you are using MySQL as your xCAT database, you will want to refer to the MySQL documentation for advise on tuning your MySQL server, which is running on your xCAT management node:

[MySQL: Tuning Server Parameters](http://dev.mysql.com/doc/refman/5.1/en/server-parameters.html)

According to this documentation, the two most important variables to configure are key_buffer_size and table_open_cache.




## Tuning NFS (Network File System)

xCAT uses NFS in various ways:



  * (AIX) Mounting operating system images to diskless nodes through NIM
  * (Linux) Mounting operating system images to statelite nodes
  * Mounting persistent directories to statelite nodes
  * (AIX) Installing stateful nodes through NIM
  * (Linux) Mounting the /install and /tftpboot directories from the xCAT management node to service nodes
  * (Linux) xCAT virtualization with KVM

Note: For Linux stateful node installs, xCAT typically uses http instead of NFS to deploy operating system packages to the nodes.

  * By default, xCAT will set up NFS servers on your xCAT management node and all service nodes. However, xCAT does provide the option of using an external NFS server. See:

[External_NFS_Server_Support_With_Linux_Statelite]

[External_NFS_Server_Support_With_AIX_Stateless_And_Statelite]

     When using an external NFS server with HA capability such as SONAS or GPFS CNFS, 
     the suggestions in this section may not be relevant. 
    Refer to that product documentation for tuning recommendations.

  * If you are experiencing NFS performance issues, you should first verify that you do not have any network issues. Networking problems often impact NFS.
  * For NFS servers that are serving the same image to a large number of nodes, ensure that the server has enough memory to hold the entire image in its NFS cache to reduce thrashing.
  * A common problem with NFS is mounting and RPC timeout issues. Do not use an automounter. Instead, put NFS mounts in /etc/fstab.
  * For heavily loaded Linux NFS servers, increasing the NFSD count may help improve performance:

     For SLES, edit /etc/sysconfig/nfs and set **USE_KERNEL_NFSD_NUMBER** to a higher value than the default of 8.
     For RedHat, update /etc/init.d/nfs and change **RPCNFSDCOUNT** to a higher

value than the default value of 8.

     Very large clusters have used NFSD values as high as 64 or 128. Restart your NFS service 
   to ensure that the new value takes effect.




  * Tuning kernel parameters can help improve NFS performance. To permanently change the parameters on Linux,
     add the following to /etc/sysctl.conf and reboot the Linux server. Here are some attributes to consider:

~~~~
     # increase TCP max buffer size
      net.core.rmem_max = 33554432
      net.core.wmem_max = 33554432
      net.core.rmem_default = 65536
      net.core.wmem_default = 65536
      # increase Linux autotuning TCP buffer limits
      # min, default, and max number of bytes to use
      net.ipv4.tcp_rmem = 4096 33554432 33554432
      net.ipv4.tcp_wmem = 4096 33554432 33554432
      net.ipv4.tcp_mem= 33554432 33554432 33554432
      net.ipv4.route.flush=1
      net.core.netdev_max_backlog=1500
~~~~


  * And corresponding client NFS mount options:

~~~~
     rw,rsize=32768,wsize=32768,hard,intr
~~~~


  * For servers that are handling large numbers of NFS operations, especially NFS writes, ensure that your disk subsystem is capable of processing the load. If you are running with a local SCSI drive, if possible you may want to consider moving the filesystem to an attached storage subsystem (RAID, etc.). If that is not option, it may be necessary to add additional local disk drives or create your filesystem so that it spans multiple drives to remove physical bottlenecks in your use of the disk subsystem.

     An example of creating a filesystem spanning multiple local disks on AIX:

~~~~
     # Create a volume group across 8 disks
     mkvg -f -y xcatvg -s 64 hdisk2 hdisk3 hdisk4 hdisk5 hdisk6 hdisk7 hdisk8 hdisk9
     # Create a logical volume for the jfs2log that spans multiple disks
     #   This is important because the jfs2log can become a bottleneck 
     # with many writes to the filesystem    
     mklv -y install_log -t jfs2log -a c -S 4K xcatvg 32  hdisk2 hdisk3
     # Create a logical volume for the NFS filesystem across all the disks
     mklv -y install_lv -t jfs2 -a c -e x xcatvg 1000 hdisk4 hdisk5 hdisk6 hdisk7 hdisk8 hdisk9
     # Create the NFS filesystem
     crfs -v jfs2 -d install_lv -m /install -A yes -p rw -a agblksize=4096 -a isnapshot=no

~~~~

### Carefully Choose Statelite Persistent Files

One special consideration for NFS tuning is statelite persistent files. By default, the management node or service nodes provide the NFS server for the statelite compute nodes. If you define statelite persistent files in the [litefile](http://xcat.sourceforge.net/man5/litefile.5.html) table that the compute nodes will do a lot of writing to, this can cause performance problems on the NFS server side if it is not sized and configured properly for that load. Since many statelite compute nodes are served by a single MN or SN, when the compute nodes all write to a statelite file, the load is multiplied on the MN/SN. For **diskfull** compute nodes, these writes are not an issue, because each compute node handles it own writes. But in a statelite cluster, you must carefully consider which files are defined as statelite persistent files, how often writes are done to them, and how your NFS servers are sized. Examples of files that are typically defined as statelite files that can cause this problem are:

  * GPFS trace files
  * The AIX error log file (/var/adm/ras/errlog). When the default crontab entries run errclear on all of the compute nodes at the same time, this causes a lot of writes to the NFS server. One option for this particular case is to reduce the frequency of the crontab entries.

For MNs and SNs that act as the NFS servers, often the performance bottleneck can be its disk. If the NFS server only has one disk (or 2 mirrored together), the disk often can't keep up with the NFS server daemon for many simultaneous writes. This problem can be addressed by one of the following:

  * Add more internal disks or external disks to the MN/SNs. (You also should monitored the memory, CPU usages, and network I/O to see if any of those are also a bottleneck.)
  * Put the statelite files in GPFS, if possible. (For GPFS log/trace files and files needed very early by the OS, this is not feasible.)
  * For Power 775 LINUX diskless systems do not statelite gpfs log or configuration date. This reduces gpfs startup and and addresses performances issues. Do not put /var/adm/ras into the litefile table. Include /var/mmfs in the litefile table but remove the /var/mmfs/tmp on each node and create a link from /var/mmfs/tmp to /var/gpfs (for example). This link will stay persistent. Then in the image or post install script 'mkdir /var/gpfs' and 'chmod 777 /var/gpfs'

~~~~
         #image,file,options,comments,disable
         "ALL","/var/mmfs/","persistent",,
~~~~


  * Use a separate, external NFS server. (See the document references earlier in this section.)

## Tuning TCP/IP Buffer Size for RMC on AIX

If you are using RMC for cluster monitoring, you may need to increase the TCP/IP buffer sizes on your xCAT management node only to prevent incorrect node status from being returned. If the buffer size is too low for the number of nodes in the cluster, a node could be reported as down even though it can be reached using ping and the RMC subsystem on the node is active.

To temporarily increase the TCP/IP buffer size on AIX, run the following from the command line:

~~~~
     no -o udp_recvspace=262144
~~~~


You must also recycle RMC. Run the following from the command line:

~~~~
     /usr/sbin/rsct/bin/rmcctrl -k
     /usr/sbin/rsct/bin/rmcctrl -s
~~~~


For a permanent change use the no command and the /etc/tunables/nextboot file, as follows:

  * The no -r command sets the value changes to apply after reboot.
  * The no -p command sets the value changes immediately and to apply after reboot.

See the AIX documentation for detailed command usage information. Note: To use larger values on AIX, increase the udp_recvspace value in increments of 262144, not to exceed the sb_max value.

~~~~
     no .L udp_recvspace
     ---------------------------------------------------------------------------------
     NAME CUR DEF BOOT MIN MAX UNIT TYPE DEPENDENCIES
     ---------------------------------------------------------------------------------
     udp_recvspace 262144 262144 262144 4K 2G-1 byte C sb_max
     ---------------------------------------------------------------------------------
     no .L sb_max
     -------------------------------------------------------------------------------
     NAME CUR DEF BOOT MIN MAX UNIT TYPE DEPENDENCIES
     -------------------------------------------------------------------------------
     sb_max 1M 1M 1M 1 2G-1 byte D
     -------------------------------------------------------------------------------
~~~~


## Tuning httpd for xCAT node deployments

For a discussion of apache2 tuning, see the external web page: ["Apache Performance Tuning"](http://httpd.apache.org/docs/2.0/misc/perf-tuning.html)

The default settings for Apache 2 on Red Hat and SLES may not allow enough simultaneous HTTP client connections to support the installation of more than about 50 nodes at a time. To enable greater scaling, the MaxClients and ServerLimit directives need to be increased from 150 to 1000. On Red Hat, change (or add) these directives in

~~~~
     /etc/httpd/conf/httpd.conf
~~~~


On SLES (with Apache2), change (or add) these directives in

~~~~
     /etc/apache2/server-tuning.conf
~~~~


### Having httpd Cache the Files It Is Serving

Note: this information was contributed by Jonathan Dye and is provided here as an example. The details may have to be changed for distro or apache version.

This is simplest if you set noderes.nfsserver to a separate apache server, and then you can configure it to reverse proxy and cache. For some reason mod_mem_cache doesn't seem to behave as expected, so you can use mod_disk_cache to achieve a similar result: make a tmpfs on the apache server and configure its mountpoint to be the directory that CacheRoot points to. Also tell it to ignore /install/autoinst since the caching settings are really aggressive. Do a recursive wget to warm the cache and watch the tmpfs fill up. Then do a bunch of kickstart installs. Before this, the apache server on the xcat management node may have been a bottleneck during kickstart installs. After this change, it no longer should be.

Here's the apache config file:

~~~~
    ProxyRequests Off # don't be a proxy, just allow the reverse proxy

    CacheIgnoreCacheControl On
    CacheStoreNoStore On
    CacheIgnoreNoLastMod On

    CacheRoot /var/cache/apache2/tmpfs
    CacheEnable disk /install
    CacheDisable /install/autoinst
    CacheMaxFileSize 1073741824

    # CacheEnable mem /                   # failed attempt to do in-memory caching
    # MCacheSize 20971520
    # MCacheMaxObjectSize 524288000

    # through ethernet network
    # ProxyPass /install http://172.21.254.201/install

    # through IB network
    ProxyPass /install http://192.168.111.2/install
~~~~

## Tuning conserver on AIX management and service nodes

conserver is an application used on xCAT management and service nodes which allows multiple users to watch serial console at the same time. On AIX large cluster, the default PTY setting prevents conserver forking too many consoles for compute nodes at the same time. It is strongly suggested to tune following PTY setting if there are more than one hundred nodes in the cluster.

The default PTY setting on AIX 71D is:

~~~~
     > lsattr -El pty0
     ATTnum     256       Maximum number of Pseudo-Terminals     True
     BSDnum     16       Maximum number of BSD Pseudo-Terminals True
     autoconfig available STATE to be configured at boot time    True
     csmap      sbcs      N/A
~~~~



The ATTnum is used by pts devices and can be enlarged by:

~~~~
     > chdev -l pty0 -a ATTnum=2048
     pty0 changed
~~~~



After appliy the changes, restart conserver by:

~~~~
     > stopsrc -s conserver
     0513-044 The conserver Subsystem was requested to stop.

     > startsrc -s conserver
     0513-059 The conserver Subsystem has been started. Subsystem PID is 40173700.
~~~~


# Tuning for HPC Applications

## HPC Tuning Guide

See "IBM Tuning Guide for High Performance Computing Applications for IBM Power 6": &lt;http://www.ibm.com/developerworks/wikis/download/attachments/137167333/Power6_optimization.pdf?version=1&gt;

This document contains recommended compiler options, discussion of using SMT (simultaneous multi-threading), running legacy executables, MPI performance optimizations, high performance libraries, and benchmark results.




## Tuning for GPFS

When using GPFS with IP over IB, you may need to address connection backlog issues when a high rate of incoming connection requests result in connection failures.

To temporarily change the somaxconn setting on Linux, run the following from the command line:

~~~~
echo "8124" > /proc/sys/net/core/somaxconn
~~~~

To permanently change this parameter, add the following to /etc/sysctl.conf and reboot the Linux server:

~~~~
net.core.somaxconn=8192
~~~~

## Tuning for PE and LAPI

The Parallel Environment Installation Guide includes information on tuning for network performance. The PE documents are available here: ["Parallel Environment (PE) Library"](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.doc/pebooks.html)

Review these documents for additional settings and detailed explanations:

  * ["Tuning your Linux system for more efficient parallel job performance"](https://publib.boulder.ibm.com/infocenter/clresctr/vxrx/index.jsp?topic=%2Fcom.ibm.cluster.pe.v1r3.pe200.doc%2Fam101_tysfbpjp.htm)
  * ["Running large POE jobs and IP buffer usage (PE for AIX only)"](https://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe.v1r3.pe200.doc/am101_lgpoejobs.htm)
  * ["IBM RSCT: LAPI Programming Guide"](http://publibfp.boulder.ibm.com/epubs/pdf/a2279369.pdf), see "Chapter 13. LAPI performance considerations".

### Linux

To enable more than 8 tasks in shared memory:

~~~~
     echo 268435456 > /proc/sys/kernel/shmmax
~~~~


To avoid socket send and receive buffer overflow:

~~~~
     echo 1048576 > /proc/sys/net/core/wmem_max
     echo 8388608 > /proc/sys/net/core/rmem_max
     # Or, on Power Linux:
     sysctl -w net.core.wmem_max=1048576
     sysctl -w net.core.rmem_max=8388608
~~~~


To avoid datagram reassembly failures when MP_UDP_PACKET_SIZE is greater than the MTU:

~~~~
     echo 1048576 > /proc/sys/net/ipv4/ipfrag_low_thresh
     echo 8388608 > /proc/sys/net/ipv4/ipfrag_high_thresh
~~~~


To enable jumbo frames:

~~~~
     ifconfig eth<x> mtu 9000 up
~~~~


The switch must be configured with jumbo frame enabled.

To turn off interrupt coalescing on device eth0 on Power Linux:

~~~~
     ifdown eth0
     rmmod e1000
     insmod /lib/modules/2.6.5-7.97-pseries64/kernel/drivers/net/e1000/e1000.ko \
          InterruptThrottleRate=0,0,0
     ifconfig eth0
~~~~


The path to e1000.ko may vary with kernel level.

To allow multiple core dumps:

~~~~
      echo 1 > /proc/sys/fs/suid_dumpable
      # Or, on Power Linux:
      /sbin/sysctl -w fs.suid_dumpable=1
~~~~


To obtain more dmesg detail:

~~~~
      echo 1 > /proc/sys/kernel/print-fatal-signals
      # Or, on Power Linux:
      /sbin/sysctl -w kernel.print-fatal-signals=1
~~~~


Verify this check passes for PE.

~~~~
      /opt/ibmhpc/pecurrent/ppe.poe/bin/pe_node_diag
~~~~


### AIX

To avoid socket send and receive buffer overflow:

~~~~
      no -o sb_max=8388608
~~~~



To turn off interrupt coalescing on device ent0 for better latency:

~~~~
      ifconfig ent0 detach
      chdev -l ent0 -a intr_rate= 0
~~~~



If your user applications are using large pages, see The PE 5.2.1 Operation and Use Guide: ["Using POE with AIX Large Pages"](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.pe521j.opuse1.doc/am102_upoetech.html)

On all compute nodes:

~~~~
     vmo -p -o lgpg_regions=64 -o lgpg_size=16777216

~~~~


If your user applications require shared memory segments to be pinned, on all compute nodes:

~~~~
     vmo -p -o v_pinshm=1
~~~~



If you decide you would like full system dumps to aid in problem diagnosis, on all compute nodes:

~~~~
     chdev -l sys0 -a fullcore=true
~~~~



If your user applications perform better with Simultaneous Mult-Threading turned off (this is application dependent), on all compute nodes:

~~~~
      smtctl -m off
~~~~


# Using xCAT at Large Scale

xCAT provides several settings that may affect the management of your large-scale cluster.




## Site Table Attributes

The xCAT site table contains many global settings for your xCAT cluster. To display current values, run the command:

~~~~
      lsdef -t site -l
~~~~


This will only list those attributes that have been explicitly set in your site table. Many other attributes are supported. To list all possible attribute names, a brief description of each, and default values, go to http://xcat.sourceforge.net/man5/site.5.html or run:

~~~~
      lsdef -t site -h
~~~~


For large clusters, you consider changing the default settings for some of these attributes to improve the performance on a large-scale cluster or if you are experiencing timeouts or failures in these areas:

#### Site Attributes Applicable to All Platforms

consoleondemand&nbsp;: When set to 'yes', conserver connects and creates the console output for a node only when the user explicitly opens the console using rcons or wcons. Default is 'no' on Linux, 'yes' on AIX. Setting this to 'yes' can reduce the load conserver places on your xCAT management node. If you need this set to 'no', you may then need to consider setting up multiple servers to run the conserver daemon, and specify the correct server on a per-node basis by setting each node's **conserver** attribute.

nodestatus&nbsp;: If set to 'n', the nodelist.status column will not be updated during the node deployment, node discovery and power operations. Default is 'y', always update nodelist.status. Setting this to 'n' for large clusters can eliminate one node-to-server contact and one xCAT database write operation for each node during node deployment, but you will then need to determine deployment status through some other means.

precreatemypostscripts: (yes/1 or no/0, only for Linux). Default is no. If yes, it will instruct xcat at nodeset and updatenode time to query the database once for all of the nodes passed into the command and create the mypostscript file for each node, and put them in a directory in tftpdir(such as: /tftpboot). This prevents xcatd from having to create the mypostscript files one at a time when each deploying node contacts it, so it will speed up the deployment process. (But it also means that if you change database values for these nodes, you must rerun nodeset.) If precreatemypostscripts is set to no, the mypostscript files will not be generated ahead of time. Instead they will be generated when each node is deployed.

svloglocal&nbsp;: if set to 1, syslog on the service node will not get forwarded to the mgmt node. The default is to forward all syslog messages. The tradeoff on setting this attribute is reducing network traffic and log size versus having local management node access to all system messages from across the cluster.

skiptables&nbsp;: a comma separated list of tables to be skipped by dumpxCATdb. A recommended setting is "auditlog,eventlog" because these tables can grow very large. Default is to skip no tables.

useNmapfromMN&nbsp;: When set to yes, nodestat command should obtain the node status using nmap (if available) from the management node instead of the service node. This will improve the performance in a flat network. Default is 'no'.

disjointdhcps&nbsp;: If set to '1', the .leases file on a service node only contains the nodes it manages. The default value is '0', which means include all the nodes in the service node's subnet. This should be set to '1' when you have many service nodes and compute nodes on a single flat subnet, but you don't want them to behave like a service node pool, instead you want to explicitly assign compute nodes to specific service nodes.

dhcplease&nbsp;: The lease time for the dhcp client. The default value is 43200.

xcatmaxconnections&nbsp;: Number of concurrent xCAT protocol requests before requests begin queueing. This applies to both client command requests and node requests, e.g. to get postscripts. Default is 64.

xcatmaxbatchconnections&nbsp;: (xCAT2.8.3 and later) Number of concurrent xCAT connections allowed from the nodes. Number must be less than xcatmaxconnections. See useflowcontrol attribute.

useflowcontrol&nbsp;: (xCAT 2.8.3 and later) If yes, postscripts use xcatd to control access to the server. If no, postscripts sleep and retry. On a new install, it will be set to yes. Not supported on AIX.

#### Site Attributes Specific to IPMI-Controlled x86_64

ipmidispatch&nbsp;: Whether or not to send ipmi hw control operations to the service node of the target compute nodes. Default is 'y'.

ipmiretries&nbsp;: The # of retries to use when communicating with BMCs. Default is 3.

ipmisdrcache&nbsp;: If set to 'no', then the xCAT IPMI support will not cache locally the target node's SDR cache to improve performance. Default is 'no'. Set to 'yes' to cache the SDR.

syspowerinterval&nbsp;: The number of seconds the rpower command to servers will wait between performing the action for each set of servers. The number of servers in each set is controlled by the 'syspowermaxnodes' setting. This is used for controlling the power on speed in large clusters. Default is 0.

syspowermaxnodes&nbsp;: The number of servers to power on at one time before waiting 'syspowerinterval' seconds to continue on to the next set of nodes. Currently only used for IPMI servers and must be set if 'syspowerinterval' is set.

#### Site Attributes Specific to IBM Flex

hwctrldispatch&nbsp;: Whether or not to send hw control operations to the service node of the target nodes. Default is 'y'.

#### Site Attributes Specific to IBM BladeCenter

blademaxp&nbsp;: The maximum number of concurrent processes for blade hardware control.

#### Site Attributes Specific to System p

powerinterval&nbsp;: The number of seconds that rpower command will wait between performing the action on each LPARs. It is used for controlling the cluster boot up speed in large clusters. LPARs of different HCPs (HMCs or FSPs) are done in parallel. E.g. if there are 8 lpars in each cec, and the powerinterval is set to 30, it will take about 6 minutes. This value is only used for system p servers. If you are having trouble with some LPARs not booting successfully, you might try 30 for this setting. Default is 0;

syspowerinterval&nbsp;: The number of seconds the rpower command to servers will wait between performing the action for each system p CEC. This is used for controlling the power on speed in large clusters. For p775 CECs, the recommended setting is 30. Default is 0.

ppcmaxp&nbsp;: The max # of processes for PPC hw ctrl. Default is 64.
ppcretry&nbsp;: The max # of PPC hw connection attempts to the HMC before failing. It is only used for hardware control commands through the HMC. Default is 3.
ppctimeout&nbsp;: The timeout, in milliseconds, to use when communicating with PPC hardware through the HMC. It only is used for hardware control commands through the HMC. A value of '0' means use the default. Default is 60.

maxssh&nbsp;: The max # of SSH connections at any one time to the hw ctrl point for PPC. Default is 8.
fsptimeout&nbsp;: The timeout, in milliseconds, to use when communicating with FSPs. A value of '0' means use the default. The default value is 30. If you are experiencing connection timeouts on a heavily loaded management network, you may want to experiment with setting this to a larger value.

### Using Flow Control

As of xCAT 2.8.3, there is available the **useflowcontrol** attribute in the site table. When this is set to **yes/1**, it works with the **xcatmaxconnections** and xcatmaxbatchconnects attributes to control requests from the nodes. This affects performance on installs and updatenode running the postscripts.

If xcatmaxconnection = 64 and xcatmaxbatchconnections = 50, then the daemon will only allow 50 concurrent connections from the nodes. This will allow 14 connections still to be available on the management node for xCAT commands (e.g nodels).

These attributes may be changed based on the size of your cluster. When increasing, consider the other tunables that also may need to increase in this document. xcatmaxbatchconnections should always be less than xcatmaxconnections.

On a new install of xCAT 2.8.3 or later release, useflowcontrol will be set to yes. It is not supported on AIX.

## Command Flags

In addition to the site table settings, some xCAT commands provide options for timeouts, retries, and fanouts to help improve the potential for command success under different conditions. If you are experiencing problems running any of these commands, you may wish to experiment with some of these values:

  * [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html)
  * [xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html)
  * [xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html)
  * [rpower](http://xcat.sourceforge.net/man1/rpower.1.html)
  * [rnetboot](http://xcat.sourceforge.net/man1/rnetboot.1.html)




## Useful xCAT commands for large clusters

xCAT provides several commands to make management of large clusters easier. Here are some that you may wish to review and use:

  * [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html): Prime the xCAT database using naming conventions specified in a config file.
  * [noderange](http://xcat.sourceforge.net/man3/noderange.3.html): Syntax for compactly expressing a list of node names used by most xCAT commands
  * [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html): Sets up /etc/hosts from the xCAT hosts table.
  * [rscan](http://xcat.sourceforge.net/man1/rscan.1.html), [lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html), [mkvm](http://xcat.sourceforge.net/man1/mkvm.1.html), [chvm](http://xcat.sourceforge.net/man1/chvm.1.html): Works with partition profile information for HMC- and IVM-managed nodes.
  * [xcoll](http://xcat.sourceforge.net/man1/xcoll.1.html), [xdshcoll](http://xcat.sourceforge.net/man1/xdshcoll.1.html), [xdshbak](http://xcat.sourceforge.net/man1/xdshbak.1.html): Consolidates and formats large amounts of output from xCAT commands.
  * [lsdef -w](http://xcat.sourceforge.net/man1/lsdef.1.html), [nodels](http://xcat.sourceforge.net/man1/nodels.1.html): Supports options to let you specify selection strings to more succinctly request the data you're looking for.
  * [xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html): Use this xCAT command to modify an xCAT AIX diskless operating system image. This is very useful in setting AIX system tuning parameters in a diskless image, including setting parameters using the AIX **no** or **vmo** commands. When changing parameters that require a bosboot, be sure to run **nim -o check** image against the image after making modifications.

## Consolidating xCAT Database Entries

The xCAT database contains over 50 different tables, although for most clusters you only need entries in a small number of commonly used tables. The majority of the tables are keyed by the xCAT node name. For very large clusters, consolidating individual node entries into entries keyed by a nodegroup name can reduce the amount of information stored in the database, and make handling the data more manageable.




### Nodegroup database entries

With the xCAT *def commands (lsdef, mkdef, chdef, rmdef), you can manipulate common attribute values for node groups using "-t group" (object type of 'group'). These will create database entries that are keyed by nodegroup name instead of individual node names.

For example:

~~~~
      chdef -t group -o compute nodetype="osi,ppc" hwtype=lpar os=rhels6 arch=ppc64
~~~~


will set many common attributes in the nodetype table and ppc table for the nodegroup "compute".

See the xCAT documentation [Node_Group_Support] for details on using node groups and nodegroup entries in the xCAT database.

### Regular expressions in database values

Another useful feature to use in conjunction with nodegroup entries, are to have entries that include regular expressions. This is especially useful where you would normally require an individual table entry for each node because of unique data values. When those data values follow an identifiable pattern, specifying the pattern as a regular expression enables you to create a single entry for the nodegroup. See [the xCAT Database manpage](http://xcat.sourceforge.net/man5/xcatdb.5.html) for more details and for examples.

## Sync files in a large cluster

Running the 'syncfiles' postscript during the boot will trigger a sync process for each node, this will cost a long time in a large cluster (6 minutes for 516 nodes/2 service nodes).

An efficient approach is to:

**Remove the 'syncfiles' postscript from the postscripts attribute**

That means the syncfiles process will NOT be run during the boot of node.

~~~~
    chtab node=xcatdefaults  postscripts.postscripts=syslog,remoteshell
~~~~


**Update the sync files after the booting of node**

  * For diskfull nodes:

Run 'updatenode -F' to update the sync files after the installation.

~~~~
    updatenode noderange -F
~~~~


  * For diskless nodes:

Add the synclist configuration file to the osimage so that the sync file process will be performed during the genimage.

Run 'updatenode -F' against the booted node if there's sync file need to be updated to the running node.

~~~~
    updatenode noderange -F
~~~~


Run 'xdcp -i -F' to sync the files to the osimage if there's sync file need to be updated. (Remember to run the 'packimage'/'nodeset' to regenerate the rootimg.gz)

~~~~
    xdcp -i /install/netboot/sles11/x86_64/compute/rootimg -F /tmp/mysynclist
~~~~


## Other considerations

### rpower Interval (pSeries)

The xCAT site table has a powerinterval setting that can be used to specify the number of seconds that the rpower command will wait between performing actions on each target object. You can use this to control the cluster boot up speed in large p-Series clusters. This can help stagger DHCP, tftp, http, and NFS requests to your service nodes when simultaneously booting large numbers of stateless or statelite nodes and may impact how you choose to distribute these services across your cluster. You will need to experiment to find a value that works best for your cluster size and hardware:

~~~~
      chdef -t site powerinterval=2
~~~~


Default is 0.

### Disks mirror on service nodes

If the service nodes are running as diskful systems and there are two or more disks on the service nodes, using disks mirror on the service nodes is an effective way to provide high availability for the service nodes. In case of hard disks faiure, another mirrored disk can take over, after the disk replacement, the mirror can help re-sync the data to the new disk.

On AIX, the commands mirrorvg and unmirrorvg can be used to manage the rootvg mirror with another disk.

On Linux, both the RedHat kickstart and SuSE autoyast provide options to support disk mirror when performing operating system deployment. The kickstart template file /opt/xcat/share/xcat/install/rh/service.raid1.rhel6.ppc64.tmpl and autoyast template file /opt/xcat/share/xcat/install/sles/service.raid1.sles11.tmpl give examples on the disks mirror. The command dmraid can be used to manage the disks mirror on Linux.

