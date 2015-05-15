<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Test Environment](#test-environment)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior
  * The xCAT documentation pages have been migrated from the Mediawiki to the sourceforge Allura wiki, see [xCAT main page](Main_Page) and [xCAT documentation page](XCAT_Documentation) for more details.
  * IBM Power 8 servers in PowerVM mode are now supported.
  * rhels7 is supported on ppc64 and x86_64.  
  * For rhels7 on ppc64 xCAT uses grub2 instead of yaboot to deploy ppc64 nodes. yaboot was deprecated in rhels7. 
  * rhels7 by default uses the consistent and predictable network device naming for network interfaces. These features change the name of network interfaces from traditional "eth\[0...9\]" to predictable network device names, for example: enp96s0fx. See [CONSISTENT NETWORK DEVICE NAMING](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/ch-Consistent_Network_Device_Naming.html) for more details. To use the traditional network interfaces naming mechanism, add the "net.ifnames=0" to "addkcmdline" attribute of node or osimage.
  * ubuntu 14.04 is supported on x86_64 with some known problem listed in the "Restrictions and Known Problems" section. 
  * MySQL has been dropped in rhels7. The mysqlscript will install and setup MariaDB on rhels7 if the rpms are installed.
  * Add support in xcatconfig -s,  remoteshell postscript to support the generation and distribution of ssh hostkey "ssh_host_ecdsa_key"  that is now  generated with newer releases of openssh. 
  * Sysclone support update delta changes in sles, partly support in redhat and centos (please refer to Restrictions and Known Problems). 
  * Added postscript configbond which can be used to configure bond device on the compute node.
  * Added the replace operation support in postscript routeop. Changed the postscript setroute which is now using 'roupteop replace' as the default operation. 

## Test Environment

 * xCAT dependency package verified with this xCAT release: 
    * Linux: [xcat-dep-201408200428.tar.bz2](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201408200428.tar.bz2/download)
    * AIX: [dep-aix-201403110451.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/dep-aix-201403110451.tar.gz/download)
    * Ubuntu: [xcat-dep-ubuntu.tar.bz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Ubuntu/xcat-dep-ubuntu.tar.bz/download)
  * DFM package verified with this xCAT release: 
    * Linux: [DFM-2.8.3.71-power-Linux](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Cluster%2Bsoftware&product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&release=All&platform=All&function=all)
  * Hardware server for POWER8 with this release: 
    * [HARDWARESVR-1.2.0.0-power-Linux-RHEL6](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Cluster%2Bsoftware&product=ibm/Other+software/IBM+High+Performance+Computing+(HPC)+Hardware+Server&release=1.2.0&platform=All&function=all)
  * Operating systems verified with this xCAT release: 
    * RHELS 6.5 
    * RHELS 7.0 
    * SLES 11.3 
    * Ubuntu 14.04  [bug  4214](https://sourceforge.net/p/xcat/bugs/4214/). 
    * AIX 7100-03-02
    * AIX 7100-03-03
  * Hw platform verified with this xCAT release(including the HMC versions):  
    * POWER6 (HMC version: V7R7.4.0)
    * POWER7 (HMC version: V7R7.4.0)
    * POWER8 BE (HMC version: V8R8.2.0)
    * dx360m3 
    * dx360m4 
    * x3550m3 
    * x3650m4 
    * Flex systems x240, x440, p260, p460 


## Key Bug fixes

  *   mknb runs twice during installation/upgrade of xCAT [bug 4150](https://sourceforge.net/p/xcat/bugs/4150/)
  * xdsh -K supports vios node [bug 4142](https://sourceforge.net/p/xcat/bugs/4142/)
  * per node consoleondemand support [bug 4136](https://sourceforge.net/p/xcat/bugs/4136/)
  * mkdef/chdef does not handle the nodegroup correctly for nic* attributes [bug 4130](https://sourceforge.net/p/xcat/bugs/4130/)
  * All the 2.8.5 bug fixes [2.8.5 fixes](https://sourceforge.net/p/xcat/bugs/search/?q=_milestone%3A2.8.5)

## Restrictions and Known Problems

  * rhels6.4 NFS based statelite is currently unusable on both ppc64 and x86_64 due to a rhels6.4 kernel bug: [bug 3535](https://sourceforge.net/p/xcat/bugs/3559/). This bug has been fixed in kernel-2.6.32-431.el6.ppc64.rpm shipped in rhels6.5. 
  * renergy does not support Power 8.
  * Sysclone update delta changes has limitation in redhat and centos. when your delta changes related bootloader, it would encounter error. This issue will be fixed in xcat higher version. So up to now, in redhat and centos, this feature just update files not related bootloader.
  * sles11.2 nfs_based statelite on x86 deployment fails. See SF [bug 3038](https://sourceforge.net/p/xcat/bugs/3038/) for workaround. 
  * Perl errors on sles when perl-IO-Socket-INET6 rpm is installed on SLES SP2. See SF defects: [bug 3173](https://sourceforge.net/p/xcat/bugs/3173/). You only see the messages in some commands when not running under the daemon, like xcatconfig and if you export XCATBYPASS=y and run tabdump &lt;tablename&gt;. To get rid of the warnings remove the rpm. 
  * ubuntu 14.04 automatic provision is broken off by some confirmation dialogs, See defect [bug  4214](https://sourceforge.net/p/xcat/bugs/4214/).
  * Due to a Redhat7 kexec-tools bug, kdump on rhels7 might fail with "kdump: wrong kdumpnic: eth2. kdump: get_host_ip exited with non-zero status!",please refer to the defect [bug 4080](https://sourceforge.net/p/xcat/bugs/4080/) for workaround. 
  * kdump on rhels7 statelite is not supported. Refer to the defect [bug 4080](https://sourceforge.net/p/xcat/bugs/4080/) for more details.
  * rhels7.0 service node otherpkgs list, refer to service.rhels6.ppc64.otherpkgs.pkglist
  * syntax error in hardeths - see defect for the fix [4270](https://sourceforge.net/p/xcat/bugs/4270/)
  * failed to run genimage against CentOS and Oracle Linux. Refer to the defect [bug 4279](https://sourceforge.net/p/xcat/bugs/4279/) for work around.
  * multiple xcatd DB Access threads being left around. Refer to the defect [bug 4284](https://sourceforge.net/p/xcat/bugs/4284/)
  * If does not set installnic (it's null) and the real installnic is not eth0, the OS deployment might hang. Refer to the defect [bug 4297](https://sourceforge.net/p/xcat/bugs/4297)
  * The OS deployment will fail if the mac attribute of your target node looks like this: 6c:ae:8b:3c:a8:ca|6c:ae:8b:3c:a8:cb!noip|6c:ae:8b:3c:a8:cc!noip . Refer to the defect [bug 4299](https://sourceforge.net/p/xcat/bugs/4299)