<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)
  - [Upgrade of 2.7 to 2.8 on SLES](#upgrade-of-27-to-28-on-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * **AIX users should wait for xCAT 2.8.1 before upgrading to this release.**
  * **Linux Redhat el5 users must wait for xCAT 2.8.1 before upgrading.**
  * On Linux, after the upgrade to 2.8, you may find the xcatd daemon did not stop and restart successfully. A command like xdsh &lt;node&gt; date will return an error like the following: 
    
    Can't locate object method "determinehostname" via package "xCAT::NetworkUtils" at /opt/xcat/lib/perl/xCAT_plugin/xdsh.pm line 121.

     If this occurs, run **service xcatd stop** and check to make sure all xcatd processes are gone. If not kill them and then run **service xcatd start**. This issue has been fixed in 2.8, so updates after this should not have the error. 

  * Use of **kits** to package software so it can easily be installed in a cluster. See [Using_Software_Kits_in_OS_Images] and [IBM_HPC_Software_Kits]. Kits for IBM HPC software will be available starting in March. 
  * The options "install", "netboot", and "statelite" with [nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) command are deprecated, the osimage provisioning option should be used instead. In xCAT 2.8, nodeset &lt;noderange&gt; install/netboot/statelite will continue to work with some warning messages, but in a future release, the nodeset &lt;noderange&gt; install/netboot/statelite might not work any more. For os provisioning for ESX/ESXi, RHEV-H, Windows and zVM nodes, the nodeset &lt;noderange&gt; install/netboot/statelite should still be used. See [Convert_Non-osimage_Based_System_To_Osimage_Based_System] for more details on how to convert non-osimage based system to osimage based system. 
  * The use of **bind** as dns handler in the site table dnshandler attribute is deprecated. Only **ddns** handler has been tested. ddns has been the default in xCAT since 2.6.x. See [site](http://xcat.sourceforge.net/man5/site.5.html) dnshandler attribute. 
  * Added the ability to make use of a local scratch disk on statelite nodes. See [XCAT_Linux_Statelite#To_enable_the_localdisk_option]. 
  * Added a new [osimage](http://xcat.sourceforge.net/man7/osimage.7.html) attribute called **groups** that can be used in the [litefile](http://xcat.sourceforge.net/man5/litefile.5.html) and [litetree](http://xcat.sourceforge.net/man5/litetree.5.html) tables instead of a single osimage name. 
  * The aixremoteshell postscript will no longer appear in the postscripts default list. It is replaced by remoteshell which will be used on AIX and Linux. The remoteshell postscript will call aixremoteshell on AIX nodes. When you install or upgrade to 2.8, your postscript list will be automatically fixed. 
  * The Management node can be a managed node in the database. Check this document for more details [Managing the Management Node](Managing_the_Management_Node)]. 
  * Removed support for updatenode &lt;switch&gt; -k --userid --devicetype. The function currently supported by xdsh is sufficient. See the [xdsh man page](http://xcat.sourceforge.net/man1/xdsh.1.html). 
  * Added a new attribute to the [site](http://xcat.sourceforge.net/man5/site.5.html) table: **auditskipcmds**. It specifies with commands or client requests should not be logged to the audit log. 
  * Enhancements to running postscripts both during install and from updatenode: 
    * Setting the new site table attribute **precreatemypostscripts** can make postscripts run faster and put less load on xcatd in large deployments (Linux only) 
    * You can now have xCAT provide additional database attributes to your postscripts by modifying the mypostscript template 
    * For details on both of these enhancements, see [Postscripts_and_Prescripts]  Section  on Using_the_mypostscript_template. 
  * New function to allow you to customize information passed to postscript and postbootscript. See the following documentation, "Using the mypostscript template": [Postscripts_and_Prescripts] 
  * A new command called [pasu](http://xcat.sourceforge.net/man1/pasu.1.html) to query or set ASU (uEFI) settings on many x86_64 nodes in parallel. See also: [XCAT_iDataPlex_Advanced_Setup] . 
  * New [site](http://xcat.sourceforge.net/man5/site.5.html) table **runbootscripts** attribute will cause postbootscripts to run on reboot of stateful (diskful ) nodes. 
  * The instxcat script on AIX no longer install the xCAT-rmc-* rpm by default. This rpm has not changed in 2.8 except the version number, so if you have one installed you can continue to use it. 
  * There are new node status attributes: **updatestatus** and **updatestatustime**. When updatenode is run, updatestatus will be set to "synced" or "out-of-sync" based on the success of the updatenode operation. The time of the update is recorded in updatestatustime. 
  * [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html) -S is now supported to diskless nodes. 
  * [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html) -l and [xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html) \--sudo options are added to allow you to run operations on the nodes as a non-root userid using sudo. (Currently, this is only supported in a non-hierarchical cluster.) For details, see the [updatenode man page](http://xcat.sourceforge.net/man1/updatenode.1.html), the [xdsh man page](http://xcat.sourceforge.net/man1/xdsh.1.html), and the setup sudo section in [Granting_Users_xCAT_privileges]. 
  * The default profiles for RedHat 6.x and SuSE Linux Enterprise Server 11.x now make some attempt to avoid accidental SAN install. 
  * When an os image name is not specified in the command "nodeset &lt;noderange&gt; osimage", the os image names for the nodes will be taken from the [node](http://xcat.sourceforge.net/man7/node.7.html) provmethod attribute. 
  * Additional xdsh support for ethernet switches. See the [xdsh man page](http://xcat.sourceforge.net/man1/xdsh.1.html) for setup details. 
  * Added support to inventory switches in [sinv](http://xcat.sourceforge.net/man1/sinv.1.html). 
  * xCAT now supports the use of multiple hostname domains within an xCAT cluster. See [Cluster Name Resolution](Cluster_Name_Resolution) for more details. 
  * Enhanced support for specifying additional network interfaces for cluster nodes, and having xCAT automatically configure them when deploying the nodes. See [Cluster Name Resolution](Cluster_Name_Resolution) for more details. 
  * Support x86 IBM Flex systems using 'runcmd=bmcsetup' to set up the IMMs. 
  * Added the node status update when the OS deployment performed through chain mechanism. See Automatically deploying nodes after discover in [XCAT_iDataPlex_Advanced_Setup] 
  * Supported to extract drivers from specified rpm packages for the diskfull and diskless deployment. See Driver RPM Package in [Using_Linux_Driver_Update_Disk] 
  * Changed the deployment resource from /tftpboot/xcat/netboot(install)/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt; to /tftpboot/xcat/osimage/&lt;osimage name&gt;. 
  * No longer require 'ipmi' credentials to be specified for Flex, ipmi plugin now understands to use 'blade' credentials when communicating with a Flex system if ipmi not provided. 
  * HA MN documentation updates 
    * HA MN configuration options overview page. See [Highly Available Management Node](Highly_Available_Management_Node) for more details. 
    * Configuring HA MN with DRBD, Pacemaker and Corosync. See [Setup HA Mgmt Node With DRBD Pacemaker](Setup_HA_Mgmt_Node_With_DRBD_Pacemaker_Corosync) for more details. 
    * Configuring HA MN with NAS and database replication. See [Setup HA Mgmt Node With NAS and Database Replication](Setup_HA_Mgmt_Node_With_NAS_and_Database_Replication) for more details. Please be aware that the procedure in this documentation is not thoroughly tested, use this doc at your own risk. 
  * New support for ubuntu 12.04. The xCAT mgmt node can be run on ubuntu and both stateful and stateless ubuntu nodes can be deployed. See [Ubuntu_Quick_Start] for details. Since this is the first release of ubuntu support, you should try it in a test cluster before using it in production. Any feedback is welcome on the mailing list. Ubuntu 12.10 will be supported soon. 
  * Windows Support Improvements: 
    * Deprecate need for 'wintimezone' site value, the Microsoft time zone is now looked up from the POSIX value in 'timezone' 
    * It is strongly suggested that genimage.cmd be used to generate a new Windows PE image. 
    * New invocations of genimage.cmd with Windows ADK will add powershell to the Windows PE image. 
    * Add support for Windows Server 2012, Windows 8, and Hyper-V 
    * Unified template for installation with or without Active Directory 
    * Support automatic fill-in of product key for retail or MAK keys changing to KMS key if no key specified. 
    * Option to allow user to decline xCAT capability to pre-join domain, reducing AD requirements. However, unless very special conditions are met, administrator credentials are put at significant risk. This is controlled by the site attribute **prejoinactivedirectory**. 
  * KVM Virtualization 
    * Modify default caching scheme to be 'none' unless the storage is a cow clone of another storage device 
    * Support LVM storage pools for virtual machines 
  * z/VM Virtualization 
    * Live migration support in z/VM 6.2 using [rmigrate](http://xcat.sourceforge.net/man1/rmigrate.1.html). 
    * Improved security with no-root login in environments where root login is not allowed. 
    * Added support for native [SCSI/FCP devices](XCAT_zVM). You can now define nodes using native SCSI/FCP devices and manage an internal storage pool for native SCSI/FCP devices. 
    * Moved options for gathering storage and network configuration (e.g. diskpool, zfcppool, and network) into [rinv](http://xcat.sourceforge.net/man1/rinv.1.html). 
    * You can now collect the inventory (e.g. number of CPUs, memory size, etc.) of any z/VM hypervisor. 
    * New options are added to create networks (vSwitches and VLANs) and connect existing storage devices to the z/VM system. See [chhypervisor](http://xcat.sourceforge.net/man1/chhypervisor.1.html) for more info. 
    * Updated zHCP (version 2.0) to support new SMAPI commands in z/VM 6.2. You can invoke any SMAPI command on the zHCP using smcli. 
  * RHEV Virtualization 
    * Supported the virtualization environment base on the RHEV. See [XCAT_Virtualization_with_RHEV] 

## Key Bug fixes

  * xdcp was not handling servicenode pools correctly, see SF defect 3267:https://sourceforge.net/p/xcat/bugs/3267/ 
  * xcatd not stopping successfully due to pid being stored in /tmp/ and getting deleted. Changed this design and fix with defect 2966:https://sourceforge.net/p/xcat/bugs/2966/ 
  * updatenode -k to nodes serviced by a service node was not behaving properly. https://sourceforge.net/p/xcat/bugs/2950/ 
  * Use of '/' delimited regular expressions no longer produces incorrect values for unrelated fields 
  * KVM directory storage URIs no longer fail with a trailing '/' character 
  * KVM no longer attempts to delete .iso files backing a virtual optical drive when purging disks for rmvm -p 

## Restrictions and Known Problems

Most of these bugs will be fixed in 2.8.1. 

  * Cannot install xCAT 2.8 on any version before rhel5. Cannot install rhels5 (ppc64). You can install rhels5 (x86_64), if the latest xCAT deps package is installed. Cannot install 2.8 on AIX 6.1 or SLES 10 or earlier releases of SLES . See [[defect 3426](https://sourceforge.net/p/xcat/bugs/3426/)] 
  * Cannot use fully qualified hostnames in the xCAT database. 
  * The new xCAT support for multiple network domains does not include multiple domains within a specific network. It is restricted to one domain per network. 
  * Errors returned from xdsh/xdcp now have Error:&lt;nodename&gt;: on the front instead of just &lt;nodename&gt;:. This will break the use of xdshbak or xcoll to sort. [defect 3380](https://sourceforge.net/p/xcat/bugs/3380/). 
  * The [ppping](http://xcat.sourceforge.net/man1/ppping.1.html) command will return a usage error if you use the -i flag. For now, use the --interface flag instead. See bug [3386](http://sourceforge.net/p/xcat/bugs/3386/). 
  * The genimage -l flag does not work correctly to limit the root filesystem on RHEL 6. See bug [2972](https://sourceforge.net/p/xcat/bugs/2972/). 
  * The xdsh -E flag does not work in a hierarchical cluster (i.e. one with service nodes). See bug [3052](https://sourceforge.net/p/xcat/bugs/3052/). 
  * The rcons command will not work for a node whose noderes.conserver attribute is explicitly set to the management node. As a work around, leave the noderes.conserver attribute blank. See bug [3159](https://sourceforge.net/p/xcat/bugs/3159/). 
  * The python RPM is also needed as a prereq for the Mellanox IB driver on SLES 11.2. Use the updated ib.sles11.2.x86_64.pkglist in bug [3350](https://sourceforge.net/p/xcat/bugs/3350/). 
  * If you have Linux nodes with FQDN hostname, you will find that the running of postscripts (e.g. updatenode -P) to these nodes will fail. You will need the fix provide attached to [[3398](https://sourceforge.net/p/xcat/bugs/3398/)] 
  * imgcapture is broken. Patch available on the defect. [[3436](https://sourceforge.net/p/xcat/bugs/3436/)]. 

### Upgrade of 2.7 to 2.8 on SLES

  * When updating xCAT from 2.7 to 2.8 on a SLES x86_64 MN, using the command **zypper update -t package '*xCAT*' **, zypper will ask the following question: 
    
    
    Problem: xCAT-2.8-snap201302071009.x86_64 requires xCAT-genesis-scripts-x86_64, but this requirement cannot be provided
      uninstallable providers: xCAT-genesis-scripts-x86_64-1:2.8-snap201302071009.noarch[xcat28]
     Solution 1: replacement of xCAT-genesis-x86_64-1:2.7.7-snap201301100842.noarch with xCAT-genesis-scripts-x86_64-1:2.8-snap201302071009.noarch
     Solution 2: do not install xCAT-2.8-snap201302071009.x86_64
     Solution 3: break xCAT by ignoring some of its dependencies
    
    Choose from above solutions by number or cancel [1/2/3/c] (c):
    

    

  * Choose solution # 1. The new xCAT-genesis-scripts-x86_64 rpm replaces the xCAT-genesis-x86_64 rpm. It gets combined with the xCAT-genesis-base-x86_64 rpm from xcat-dep when mknb is run and forms the new genesis boot kernel. 
  * If you have a hierarchical SLES x86_64 cluster, you will hit this same problem when upgrading the services nodes. Since the choice needs to be responded to interactively, you must upgrade xCAT on the SNs manually, instead of having xCAT's otherpkgs support do it for you. 

  * sles11.2 nfs_based statelite on x86 deployment fails. See SF [bug 3038](https://sourceforge.net/p/xcat/bugs/3038/) for workaround. 
  * Perl errors on sles when perl-IO-Socket-INET6 rpm is installed on SLES SP2. See SF defects: [bug 3173](https://sourceforge.net/p/xcat/bugs/3173/). You only see the messages in some commands when not running under the daemon, like xcatconfig and if you export XCATBYPASS=y and run tabdump &lt;tablename&gt;. To get rid of the warnings remove the rpm. Cause of problem under investigation. 
