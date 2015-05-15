<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Test Environment](#test-environment)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)
  - [Upgrade of 2.7 to 2.8 on SLES](#upgrade-of-27-to-28-on-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Overview

This page documents all of the changes and notes for 

     xCAT 2.8.4 

Released on 

     May 23, 2014 

A combined summary of all recent xCAT release notes can be viewed at [XCAT Release Notes]([XCAT_Release_Notes]) 

**Notice: We repackaged xCAT 2.8.4 on May 29, 2014 for [defect 4145](https://sourceforge.net/p/xcat/bugs/4145/). The code is the same. We only added a file /etc/httpd/conf.d/xcat.conf into xCAT-server package. **

## New Function and Changes in Behavior

  * rhels6.5 and rhels5.10 are now supported 
  * AIX 7100-03-02 support 
  * xCAT cluster zones, see documentation for details [Setting_Up_Zones](Setting_Up_Zones).
  * tabprune -a can be used on any xCAT table to remove all entries in the table. 
  * The xCAT version from lsxcatd -v and the other commands now includes the git commit information. For example: Version 2.8.4 (git commit bb06e4479e68e71723c4c4769fb0837304c90a0e, built Wed Apr 2 05:28:30 EDT 2014) 
  * xCAT OpenStack baremetal driver, see documentation for details [Using_xCAT_in_OpenStack_Baremetal_Node_Deployment]
  * makedns master/slave support, see documentation for details [Cluster_Name_Resolution]
  * A new flag '--ignorekernelchk' for commands genimage,geninitrd and nodeset to skip the kernel version checking when injecting drivers from driver rpm to initrd. 
  * Windows support enhancements: 
    * Secondary adapters support 
    * Multiple partitions support 
    * Multiple WinPE 
    * Documentation updates 
    * postscript support 
  * DFM enhancements: 
    * Support VIOS-based partitioning on PowerLinux machines, see documentation for details [XCAT_PowerLinux_Hardware_Management]
    * DFM on system x 
    * Location of DFM packages [[http://www-933.ibm.com/support/fixcen.../IBM+direct+FSP+management+plug-in+for+xCAT&amp;release=All&amp;platform=All&amp;function=all](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Cluster%2Bsoftware&product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&release=All&platform=All&function=all)] 
  * Support static network configuration during node provisioning, can be enabled by setting "site.managedaddressmode=static". Currently, this feature is only available for diskfull installation of redhat and sles. 
  * REST-API restructure(experimental). See documentation for details [WS_API]
  * Ubuntu 14.04 diskful installation support (experimental) 
  * Statelite enhancement that 'persistent' directory will mount to the node specific directory on the nfs server from the compute node so that one node can NOT see the file/dirs of other nodes in the persistent mount directory. 

## Test Environment

The following list summarizes the specific details of the test environments used for this release of xCAT. Although not specifically tested, xCAT will continue to be supported and work correctly for other environments. We just do not have the resources to test all possible operating systems and hardware for each release. 

For a combined summary of all test environments for recent releases of xCAT, see: [XCAT Test environment Summary](XCAT_Test_environment_Summary) 

  


  * xCAT dependency package verified with this xCAT release: 
    * Linux: xcat-dep-201405120531.tar.bz2[http://sourceforge.net/projects/xcat/.../download](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201405120531.tar.bz2/download)
    * AIX: dep-aix-201403110451.tar.gz[http://sourceforge.net/projects/xcat/.../download](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/dep-aix-201403110451.tar.gz/download)
    * Ubuntu:xcat-dep-ubuntu.tar.bz[http://sourceforge.net/projects/xcat/.../download](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Ubuntu/xcat-dep-ubuntu.tar.bz/download)
  * DFM package verified with this xCAT release: 
    * Linux: DFM-2.8.3.71-power-Linux[http://www-933.ibm.com/support/fixcen.../IBM+direct+FSP+management+plug-in+for+xCAT&amp;release=All&amp;platform=All&amp;function=all](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Cluster%2Bsoftware&product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&release=All&platform=All&function=all)
  * Operating systems verified with this xCAT release: 
    * RHELS 6.4 
    * RHELS 6.5 
    * SLES 11.3 
    * RH5.10 (UT cover) 
    * Ubuntu 12.04.01 
    * AIX 7100-03-02 
  * Hw platform verified with this xCAT release: 
    * Power 6 
    * Power 7 
    * dx360m3 
    * dx360m4 
    * x3550m3 
    * x3650m4 
    * Flex systems x240, x440, p260, p460 

## Key Bug fixes

  * xdsh -e -E not working correctly in hierarchical environment. [bug 4112](https://sourceforge.net/p/xcat/bugs/4112/)
  * xdcp rsync issues with (merge,append, execute, executealways) in hierarchical environment. [bug 4061](https://sourceforge.net/p/xcat/bugs/4061/)
  * xcatd restart on service node hits invalid error check when it runs nodeset on the servicenode. [bug 3942](https://sourceforge.net/p/xcat/bugs/3942/)
  * Add vlan support for configeth. [bug 4025](https://sourceforge.net/p/xcat/bugs/4025/)
  * makedhcp -n to add bridges into dhcpd.conf [bug 3902](https://sourceforge.net/p/xcat/bugs/3902/)
  * Sysclone enhancements to support golden client with extended and logical partitions [bug 3940](https://sourceforge.net/p/xcat/bugs/3940)
  * node reinstall loop when site.nodestatus=0 [bug 3997 ](http://sourceforge.net/p/xcat/bugs/3997/)
  * stateless and statelite netboot failed for kvm virtual machine [bug 4096](https://sourceforge.net/p/xcat/bugs/4096/)
  * Additional 2.8.4 fixed defects [2.8.4 bugs](https://sourceforge.net/p/xcat/bugs/search/?q=_milestone%3A2.8.4)

## Restrictions and Known Problems

  * rhels6.4 NFS based statelite is currently unusable on both ppc64 and x86_64 due to a rhels6.4 kernel bug: [bug 3535](https://sourceforge.net/p/xcat/bugs/3559/). This bug has been fixed in kernel-2.6.32-431.el6.ppc64.rpm shipped in rhels6.5. 

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
  * When "site.managedaddressmode=static", sles provisioning on system X might hang, the details and workaround can be found in [bug #4132](https://sourceforge.net/p/xcat/bugs/4132/). 
  * on ubuntu MN, "lsxcatd -v" and "-v" option of other xcat commands failed to get xcat release info. See [bug #4128 ](https://sourceforge.net/p/xcat/bugs/4128/)
