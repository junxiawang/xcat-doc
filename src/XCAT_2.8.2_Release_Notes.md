<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)
  - [Upgrade of 2.7 to 2.8 on SLES](#upgrade-of-27-to-28-on-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * [site.precreatemypostscripts](http://xcat.sourceforge.net/man5/site.5.html) attribute is now supported on AIX 
  * xdsh now sets environment variable NODE to the nodename (as known by xCAT in the database) when running the command on the node. This can be useful if the command is a script you wrote that needs to know the nodename of the node it is running on (where the hostname value could have been changed). To see the current exports, run: xdsh &lt;nodename&gt; -T hostname 
  * Performance enhancements in [updatenode -P](http://xcat.sourceforge.net/man1/updatenode.1.html) function. 
  * Node cloning, aka imaged provisioning (and we call it sysclone) is now supported on xRHEL and CentOS. (xCAT uses [SystemImager](http://systemimager.org/) for this support.) See [Installing Stateful Nodes Using Sysclone](XCAT_iDataPlex_Cluster_Quick_Start#Option_2:_Installing_Stateful_Nodes_Using_Sysclone) 
  * xCAT can now be used to quickly deploy an OpenStack cloud. See [Deploying_OpenStack] 
  * Sequential discovery enhancements. See [Sequential_Discovery](XCAT_iDataPlex_Cluster_Quick_Start#Option_1:_Sequential_Discovery) 
    * A new command called [nodediscoverdef](http://xcat.sourceforge.net/man1/nodediscoverdef.1.html) has been added for use during the process of discovering a node manually. It can also be used to clean the discovered nodes from discoverydata table. 
    * The bmc name can now be any string that is set in the [ipmi.bmc](http://xcat.sourceforge.net/man5/ipmi.5.html) attribute. The previously the bmc name had to be &lt;node&gt;-bmc for sequential discovery. 
    * The otherinterface attribute of the node can be used to specify the IP address for the bmc during discovery. 
  * The option to use the node's local disk for non-state data (swap, tmp, trace, etc.) is now supported for stateless nodes. (It was previously only supported for statelite nodes.) See [Using localdisk](XCAT_Linux_Statelite#Enabling_the_localdisk_Option) 
  * Support for managing Intel Xeon phi MIC cards: install necessary software, configure networking, create images for the cards, control the cards (boot up, power off). This support is currently experimental, but should be "hardened" soon. Try it out and give us feedback. See [Managing_MIC_(Intel_Xeon_Phi)_nodes]. Some current limitations: 
    * rcons does not work well 
    * For the nodeset command, the osimage needs be specified explicitly and the IP/hostname entry for MN should be added to /etc/hosts in host nodes 
  * There are a few predefined groups based on hw types in the templates under directory /opt/xcat/share/xcat/templates/e1350 and now in /opt/xcat/share/xcat/templates/power. If you import these tables, and add your nodes to the corresponding groups, they will automatically have some of the necessary attributes defined. 
  * Kits enhancements: 
    * IBM HPC kits for ppc64 (will be available later this summer) 
    * More settings when building kits to be able to control the order in which the rpms are installed. This enables some kitcomponents to be installed without work arounds in more situations. 
    * New buildkit command line option "-l | --kitloc &lt;kit_location&gt;". This allows you to specify a kit directory location other then the current directory. 
    * New kit protocol settings within kits so that when a kit is added to a cluster, the xcat code can tell if the version of xcat this kit was build with is compatible with the version of xcat it is being installed in. 
    * New document giving lots of information about making your own kits: [Building_Software_Kits] 
  * SLES 11 SP3 support on system x and system p 
  * The [rinstall](http://xcat.sourceforge.net/man8/rinstall.8.html) command now supports nodes that are using an [osimage](http://xcat.sourceforge.net/man7/osimage.7.html) definition. 
  * The [Highly_Available_Management_Node] documentation has been reorganized a little to separate the method of sharing data from the method of failing over services. 
  * [Ubuntu support](Ubuntu_Quick_Start) enhancements: 
    * [renergy](http://xcat.sourceforge.net/man1/renergy.1.html) support 
    * xCAT no longer changes /bin/sh to link to /bin/bash (it leaves it as a link to /bin/dash) 
    * [makeroutes](http://xcat.sourceforge.net/man8/makeroutes.8.html) support 
    * Support for the confignics and configeth postscripts and use of the [nics](http://xcat.sourceforge.net/man5/nics.5.html) table 
  * The mkvlan command now works with the [nics](http://xcat.sourceforge.net/man5/nics.5.html) table. The mkvlan command is not available in base xCAT. Currently, it is only available with the PCM-AE product.) 
  * A new flag -q was added to [makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html) to query the node entries from the DHCP server configuration. 

## Key Bug fixes

  * You may use FQDN for your nodes in the database. We do not have known problesm. xCAT recommends using short hostnames in the database and that is how the code is tested. 
  * rinstall now supports provmethod=osimagename [bug 3463](https://sourceforge.net/p/xcat/bugs/3463/). 
  * instoss script on AIX will call updtvpkg internally to avoid missing library error. [bug 3677](https://sourceforge.net/p/xcat/bugs/3677/)
  * Fixed a problem for rhels6.4 MN installing rhels5.9 CN. [bug 3598](https://sourceforge.net/p/xcat/bugs/3598/)
  * makedns now handles the add/remove of the node names defined in the nics table. [bug 3604](https://sourceforge.net/p/xcat/bugs/3604/)
  * The perl-IO-Socket-SSL on sles10 xCAT MN needs be updated to perl-IO-Socket-SSL-1.77 in xcat-dep. [bug 3699](https://sourceforge.net/p/xcat/bugs/3699/)

## Restrictions and Known Problems

  * rmdsklsnode can not remove the NIM machine definition with AIX 7.1.2.0 Update image on xCAT management node or service node. This is actually caused by AIX APAR IV32670. You can get more info from bug [3527](https://sourceforge.net/p/xcat/bugs/3527/)

    the workaround is to force reinstall the bos.sysmgt.nim.master 7.1.2.0 fileset using AIX 7.1 TL02 media. 

  * Uninstalling PE 1.3 PTF1 man page ppe_rte_man-1.3.0.1-*.rpm either directly or indirectly by upgrading to PE 1.3 PTF2 fails during the rpm %preun script processing. This has been fixed in PE 1.3 PTF2 ppe_rte_man-1.3.0.2-*.rpm. 

    To work around this problem, you may need to directly remove the rpm using "rpm -e ". If you are working with a diskless image, the genimage command may fail the first time you try to remove PE 1.3.0.1 or try to upgrade to 1.3.0.2. Simply run your genimage command again, and it should work correctly the second time. 

  * makedhcp -a does not always update the DHCP leases correctly. Workaround is to run makedhcp -n and makedhcp -a. [bug 3535](https://sourceforge.net/p/xcat/bugs/3535/)
  * rhels6.4 NFS based statelite is currently unusable due to a rhels6.4 bug [bug 3535](https://sourceforge.net/p/xcat/bugs/3559/). There is no work around yet. 
  * sysclone only works for system x RHEL 6.x and CentOS 6.x. 
  * rcons might fail when nodehm.mgt=kvm, see [bug 3719](https://sourceforge.net/p/xcat/bugs/3719/). 
  * xlc/essl kit dependency issue. See defect for problem description and patch [bug 3746 ](https://sourceforge.net/p/xcat/bugs/3746/). 

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
