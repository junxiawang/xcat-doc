<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Test Environment](#test-environment)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior
  * Ubuntu 14.04 and 14.04.01 support on x86_64 and ppc64le platforms
    * diskful and diskless
    * kit support
    * Statelite is not support
    * Hierarchy is not support
  * Ubuntu 14.10 support(experimental)
  * SLES 12 support on x86_64 and ppc64le platforms
    * SLES 12 diskful provisioning
    * Running xCAT management node on SLES 12
    * SLES 12 ppc64le could only run on PowerKVM virtual machines
    * Diskless is not supported
    * Hierarchy is not supported
  * RHEL 6.6 support on x86_64 and ppc64
  * AIX 7.1.3.15 and AIX 7.1.3.30 support
    * Diskful rte installation
    * Hierarchy configuration
    * No diskless support
    * No DFM support for Power 8 servers
  * Power 8 LE support
    * Hardware discovery for Power 8 LE CECs
    * Hardware control for the Power 8 LE CEC through ipmi
    * Firmware update support
    * Ubuntu 14.04 and Ubuntu 14.04.01 PowerNV support
    * Infiniband FDR support with Ubuntu PowerNV
    * Running xCAT management node on Ubuntu ppc64le
    * PowerKVM hypervisor provisioning
    * PowerKVM virtual machines management
      * create, modify, list, delete
      * Virtual machines hardware management through libvirt
      * Deploy Ubuntu ppc64le and SLES 12 ppc64le onto PowerKVM virtual machines
  * sysclone enhancements
    * ppc64 RHEL 6.x and ppc64 RHEL 7 support
    * ppc64 SLES 11 SPx support
    * x86_64 RHEL 7 support
    * LVM support on RHEL
  * A new site attribute auditnosyslog is added to control if the commands written to auditlog  will also be written to syslog. This attribute in combination with auditskipcmds="ALL" can turn off all logging of commands.
  * A new site attribute nmapoptions is added to specify additional options for the nmap command used in pping, nodestat, xdsh -v and updatenode commands. See the "tabdump -d site" for more details.
  * Putting the user customized postscripts into subdirectories under /install/postscripts/ is supported, see the doc [Adding your own postscripts](Postscripts_and_Prescripts/#adding-your-own-postscripts) for more details.
  * The following features are dropped and no longer supported in xCAT 2.9:
    * RHEL 5.x and CentOS 5.x support
    * The whole Fedora support is dropped
    * SLES 10 SPx support
    * Ubuntu 12.04, 12.10, 13.04, 13.10 support
    * AIX diskless deployment is only supported on Power 775 clusters. 
    * vSphere 4.1 support
    * z/VM 5.1, 6.1 support
    * IBM Bladecenter support
    * xCAT web interface(xCAT-UI)
    * Monitoring through IBM Resource Monitoring Control(xCAT-rmc)
    * xCAT OpenStack support (xCAT-OpenStack and xCAT-OpenStack-baremetal)
    * xCAT IBM HPC integration is done through kits, drop the package xCAT-IBMhpc
    

## Test Environment

  * xCAT dependency package verified with this xCAT release: 
     * Linux:[xcat-dep-201412080156.tar.bz2](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201412080156.tar.bz2/download)
     * AIX:[dep-aix-201403110451.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/dep-aix-201403110451.tar.gz/download)
     * Ubuntu:[xcat-dep-ubuntu-snap20141127.tar.bz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Ubuntu/xcat-dep-ubuntu-snap20141127.tar.bz/download)
  * DFM package verified with this xCAT release:
    * Linux:[xCAT-dfm-2.8.3-71.ppc64](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Cluster%2Bsoftware&product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&release=All&platform=All&function=all)
  * Hardware server for POWER8 with this release: 
    * [HARDWARESVR-1.2.0.0-power-Linux-RHEL6](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Cluster%2Bsoftware&product=ibm/Other+software/IBM+High+Performance+Computing+(HPC)+Hardware+Server&release=1.2.0&platform=All&function=all)
  * Operating systems verified with this xCAT release:
    * RHELS 6.5 
    * RHELS 6.6 
    * RHELS 7.0 
    * SLES 11.3 
    * SLES 12
    * Ubuntu 14.04  
    * Ubuntu 14.04.01
    * Ubuntu 14.10 
    * AIX 7100-03-03
    * AIX 7100-03-04 
  * Hw platform verified with this xCAT release(including the HMC versions):  
    * POWER7 (HMC version: V7R7.4.0)
    * POWER8 BE (HMC version: V8R8.2.0)
    * POWER8 LE 
    * dx360m3 
    * dx360m4 
    * x3550m3 
    * x3650m4 
    * Flex systems x240, x440, p260, p460 

## Key Bug fixes


## Restrictions and Known Problems
  * The perl-Net-DNS-0.73-1.28 shipped with SLES 12 has one [bug](https://rt.cpan.org/Public/Bug/Display.html?id=91241) that causes makedns could not work, see xCAT bug [4331](https://sourceforge.net/p/xcat/bugs/4331/) for more details. We are working with SuSE to update the perl-Net-DNS package in SLES, as a temporary solution, xCAT compiled and shipped an updated version of perl-Net-DNS that fixed the known problem in xcat-dep, the Perl-Net-DNS package shipped with xcat-dep is perl-Net-DNS-0.80-1, you need to update the perl-Net-DNS to the version shipped with xcat-dep manually, if the update was not done.
  * On stateless x86_64 Ubuntu 14.04.01 compute nodes, "cat /etc/\*release\*" lists Ubuntu 14.04, the workaround is to check the kernel version to verify if the statless node is Ubuntu 14.04 or 14.04.01.
  * DFM on AIX does not support IBM Power 8 machines.
  * In DFM configuration, the following rspconfig options are not working when site.enableASMI is set to yes: memdecfg decfg procdecfg iocap time date autopower sysdump spdump network dev celogin1. These options need to go through ASMI web interface, there are some major problems in the code logic to support the ASMI web interface. 
  * If there are x86_64 KVM or PowerKVM guests in the xCAT cluster, the perl-Sys-Virt is required to be installed manually on the management node to enable hardware control capabilities against the virtual machines. See bug [4344](https://sourceforge.net/p/xcat/bugs/4334/) for more details.
  * kdump on rhels7 ramdisk-based statelite is not supported
  * For Ubuntu 14.04 and 14.10, the diskful provisioning and diskless genimage will need internet connections to download additional packages from internet Ubuntu repo, this is definite requirement for now, we will investigate if it is possible to eliminate this requirement in some later release.
  * Redhat 7 deployment on Power 7 platform sometimes fail with "error: connection timeout.", the workaround is to change the linux kernel and initrd download method from "http" to "tftp" in grub2. See [4406](https://sourceforge.net/p/xcat/bugs/4406/) for more details. 
  * If there are quite a few(e.g. 12) network adapters on the SLES compute nodes, the os provisioning might hang because that the kernel would timeout waiting for the network driver to initialize. The symptom is the compute node could not find os provisioning repository, the error message is "Please make sure your installation medium is available. Retry?". See bug [4462](https://sourceforge.net/p/xcat/bugs/4462/) for more details.

  To avoid this problem, you could specify the kernel parameter "netwait" to have the kernel wait the network adapters initialization. On a node with 12 network adapters, the netwait=60 did the trick.

    chdef <nodename> -p addkcmdline="netwait=60"
  
  * The xCAT postscripts may not be able to run when provisioning SLES 12 on x86_64 platform, the symptom is that after the os provisioning is done, the node status is still "booting", and the node could not be logged in through ssh. The workaround is to login the node through console and run "service sshd start", and then run xdsh <nodename> -K", and then "updatenode <nodename> -P". See bug [4463](https://sourceforge.net/p/xcat/bugs/4463/) for more details.

  * On Ubuntu 14.x, the command 'lsdef <node> -i status' sometimes can NOT return the correct value for the status attribute. This issue also impacts the attributes which are stored in the nodelist table. Refer to the bug [4468](https://sourceforge.net/p/xcat/bugs/4468/) for more details.

  * The Postscripts otherpkgs didn't support on sles12.  Refer to the bug [4482](https://sourceforge.net/p/xcat/bugs/4482/) for more details.