<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)
  - [Upgrade of 2.7 to 2.8 on SLES](#upgrade-of-27-to-28-on-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * Release 2.8.1 is now available for AIX. 
  * ** xCAT 2.8.1 deprecating support of rsh/rcp for remote commands xdsh/xdcp.**
  * Linux x86_64 RHEL 5 users need to apply the [latest deps package](https://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/) and then can use 2.8.1. 
  * Support multiple paths with the osimage attribute pkgdir, see [Install_OS_Updates] 
  * Added image name and timestamp to file /opt/xcat/xcatinfo in diskless images 
  * Energy management support for Flex nodes 
  * Sequential discovery support, see [XCAT_iDataPlex_Cluster_Quick_Start#Sequential_Discovery] 
  * Updates for system x Flex management process, see [XCAT_system_x_support_for_IBM_Flex] 
  * Enhancements to xCAT Software Kit support: 
    * release attribute for kits 
    * default kit tarfile names include kit architecture 
    * buildkit addpkgs allows changing kit version and/or release 
    * addkitcomp --noupgrade option to allow multiple releases of a kitcomponent to exist in one osimage 
    * new lskit, lskitcomp, lskitdeploymentparams commands 
    * various buildkit, addkit, addkitcomp defect fixes 
  * Statefull images creation for management node 
  * Kits installation on management node 
  * Procedure on how to convert non-osimage based system to osimage based system, see [Convert_Non-osimage_Based_System_To_Osimage_Based_System] 
  * A new flag -s to reventlog command to sort the output. 
  * RHEL 6.4 support on system x and system p 
  * RHEL5.9 support on system x and system p 
  * IPv6 support enhancements on Linux, see [Configuring_IPv6_in_Cluster] 
    * confignics support to configure IPv6 addresses on Ethernet and Infiniband interfaces 
    * makeroutes support for IPv6 routes 
    * makehosts and makedns support IPv6 hosts 
  * lsdef,chdef,mkdef to support display/set nic attributes more easily 
  * Ubuntu support enhancements 
    * hardware discovery 
    * mysql and postgresql support 
    * makeknownhosts -r support 
    * kit support 
  * Support for Management Node in the servicenode table to setup attributes. See [Managing_the_Management_Node] 
  * Install and config chef/puppet for OpenStack deployment(experimental). See [Adding_Chef_in_xCAT_cluster] and [Adding_Puppet_in_xCAT_cluster] 
  * nicaliases support in the nics table 
  * xdsh -E works in a hierarchical cluster 
  * xdcp ( scp and rsync ) support sudo. updatenode -F supports sudo. Hierarchical custers are also supported. See [Granting_Users_xCAT_privileges]. 
  * Energy management support for Flex system (renergy command) 
  * Sequential discovery support (nodediscoverstart, nodediscoverstop, nodediscoverls, nodediscoverstatus). The simplest method to discovery new hardwares for a physical location unaware cluster. [[Node Discovery](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=XCAT_iDataPlex_Cluster_Quick_Start#Node_Discovery)] 
  * To migration from xCAT 2.7.x or earier to xCAT 2.8.1 or later, there are some additional steps need to considered: 
    * Switching from xCAT IBM HPC Integration Support to Using Software Kits. See [Switching_from_xCAT_IBM_HPC_Integration_Support_to_Using_Software_Kits](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=IBM_HPC_Software_Kits#Switching_from_xCAT_IBM_HPC_Integration_Support_to_Using_Software_Kits) for details. 
    * (Optional) Use nic attibutes to replace the otherinterface to configure secondary adapters. See [otherinterfaces vs nic attributes](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Cluster_Name_Resolution#.22otherinterfaces.22_vs._nic.2A_attributes) for details. 
    * Convert non-osimage based system to osimage based system. See [Convert non-osimage based system to osimage based system](http://sourceforge.net/apps/mediawiki/xcat/index.php?title=Convert_Non-osimage_Based_System_To_Osimage_Based_System) for details. 

## Key Bug fixes

  * You can install xCAT 2.8.1 on RHEL 5 (ppc64 and x86_64), AIX 6.1, SLES 10. The following releases: SLES10 x86_64 or ppc64 and Redhat5 ppc64 no longer supports genesis discovery. [[defect 3426](https://sourceforge.net/p/xcat/bugs/3426/)]. Need to install latest xCAT deps package. 
  * Errors returned from xdsh/xdcp now have Error:&lt;nodename&gt;: on the front instead of just &lt;nodename&gt;:. This will break the use of xdshbak or xcoll to sort. [defect 3380](https://sourceforge.net/p/xcat/bugs/3380/). 
  * The [ppping](http://xcat.sourceforge.net/man1/ppping.1.html) command will return a usage error if you use the -i flag. For now, use the --interface flag instead. See bug [3386](http://sourceforge.net/p/xcat/bugs/3386/). 
  * The genimage -l flag does not work correctly to limit the root filesystem on RHEL 6. See bug [2972](https://sourceforge.net/p/xcat/bugs/2972/). 
  * The xdsh -E flag does not work in a hierarchical cluster (i.e. one with service nodes). See bug [3052](https://sourceforge.net/p/xcat/bugs/3052/). 
  * The python RPM is also needed as a prereq for the Mellanox IB driver on SLES 11.2. Use the updated ib.sles11.2.x86_64.pkglist in bug [3350](https://sourceforge.net/p/xcat/bugs/3350/). 
  * If you have Linux nodes with FQDN hostname, you will find that the running of postscripts (e.g. updatenode -P) will fail. [[3398](https://sourceforge.net/p/xcat/bugs/3398/)] 
  * imgcapture fixed [[3436](https://sourceforge.net/p/xcat/bugs/3436/)]. 
  * Incorrect postscript/postbootscript list generated for a node. [3412](https://sourceforge.net/p/xcat/bugs/3412/)
  * sles11.2 nfs_based statelite on x86 deployment now works. See SF [bug 3038](https://sourceforge.net/p/xcat/bugs/3038/). 
  * The rcons command works for a node whose noderes.conserver attribute is explicitly set to the management node, see [3159](https://sourceforge.net/p/xcat/bugs/3159/)
  * genimage -l works with RHEL6, see see [2972](https://sourceforge.net/p/xcat/bugs/2972/)
  * New xCAT SSL certificates not working for hierarchical commands - [3507](https://sourceforge.net/p/xcat/bugs/3507/)

## Restrictions and Known Problems

  * Cannot use fully qualified hostnames in the xCAT database. 
  * Perl errors on sles when perl-IO-Socket-INET6 rpm is installed on SLES11 SP2. See SF defects: [bug 3173](https://sourceforge.net/p/xcat/bugs/3173/). You only see the messages in some commands when not running under the daemon, like xcatconfig and if you export XCATBYPASS=y and run tabdump &lt;tablename&gt;. To get rid of the warnings remove the rpm. Cause of problem under investigation. 
  * Uninstalling PE 1.3 PTF1 man page ppe_rte_man-1.3.0.1-*.rpm either directly or indirectly by upgrading to PE 1.3 PTF2 fails during the rpm %preun script processing. This has been fixed in PE 1.3 PTF2 ppe_rte_man-1.3.0.2-*.rpm. 

    To work around this problem, you may need to directly remove the rpm using "rpm -e ". If you are working with a diskless image, the genimage command may fail the first time you try to remove PE 1.3.0.1 or try to upgrade to 1.3.0.2. Simply run your genimage command again, and it should work correctly the second time. 

  * makedhcp -a does not always update the DHCP leases correctly. Workaround is to run makedhcp -n and makedhcp -a. [bug 3535](https://sourceforge.net/p/xcat/bugs/3535/)
  * rinstall does not support provmethod=osimagename [bug 3463](https://sourceforge.net/p/xcat/bugs/3463/). 
  * List of defects to be fixed in 2.8.2 [defects](https://sourceforge.net/p/xcat/bugs/milestone/2.8.2)
  * The policy table does not have an entry for remoteimmsetup, if xCAT is upgraded from a previous version to 2.8.x. Adding the following line in the policy table addresses this: "2.1",,,"remoteimmsetup",,,,"allow",, [[bug 3554](https://sourceforge.net/p/xcat/bugs/3554/)]. 
  * Certain NodeRanges do not expand correctly, see [[bug 3429](https://sourceforge.net/p/xcat/bugs/3429/)]. 
  * The linuximage table entries, when created automatically by xCAT, may contain the wrong template information, as the matches to the existing template files aren't done specifically enough. 
  * The rspconfig &lt;noderange&gt; textid command can return "No name" if a blade or ITE is defined with a slot in the mp table in which there is no IMM connection to the AMM or CMM. In this case, even if the blade or ITE takes up more than one bay (e.g., a Flex x440, or a blade with a BGE), the mp table entry for that blade or ITE should list only one slot. The case where two slots would be defined is a double-wide HX5 blade, where there is an IMM connected in each slot. 
  * For Redhat 6.4 NFS based statelite, the tmpfs files defined in litefile table are still readonly, See [[bug 3559](https://sourceforge.net/p/xcat/bugs/3559/)]. 
  * Cannot install xCAT 2.8 on any version before rhel5 and sles10. You can install rhels5 (x86_64), if the latest xCAT deps package is installed. New node discovery on X-series will not work for SLES 10 or earlier releases of SLES . See [[bug 3426](https://sourceforge.net/p/xcat/bugs/3426/)]. 
  * servicenode table entry, with no service nodes defined causes problems in xCAT commands. [[bug 3580](https://sourceforge.net/p/xcat/bugs/3580/)] 
  * xcat client could not connect to xcatd through IPv6 link local address. [[bug 3581](https://sourceforge.net/p/xcat/bugs/3581/)] 

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
