<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Test Environment](#test-environment)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior
  * RHEL 7.1 support on x86_64, ppc64 and ppc64le platforms
    * Diskful and diskless
    * Running xCAT management node on RHEL 7.1
  * Ubuntu 14.04.02 support on x86_64 and ppc64le platforms
    * Diskful and diskless
    * Running xCAT management node on Ubuntu 14.04.02
    * Nvidia GPU configuration on IBM Power 8 servers is not support
  * Support Local Mirror for Ubuntu diskfull and diskless OS deployment. This is useful in the case your xCAT MN cannot access internet or the network bandwidth is not good.
  * Ubuntu hierarchy
    * MariaDB is the only supported database for Ubuntu hierarchy
  * SLES 12 diskless support
  * Energy management for IBM Power 8 servers
    * Power consumption information
    * Hardware vitals: temperature, fanspeed, CPU speed, etc.
    * Power saving
    * The energy management for IBM Power 8 servers uses a new mechanism, it does not depends on xCAT Energy Management Plug-in xCAT-pEnergy any more.
    * The setting operation for IBM Power 8 server is only supported for the server which is running in PowerVM mode, Do NOT run the setting for the server which is running in OPAL mode.
  * RHEL 7.1 LE -> RHEL 7.1 BE mixed cluster support
    * Manage and deploy RHEL 7.1 BE compute nodes from RHEL 7.1 LE management node
    * RHEL 7.1 BE -> RHEL 7.1 LE mixed configuration should also work, but was not formally tested
  * Node attribute primarynic is deprecated, installnic could be used to specify the installation nic, if it is blank, the installnic will be default to the nic associates with the mac address specified by the mac attribute.
  * New column nicextraparams is added to the nics table, which could be used to specify arbitrary nic configuration parameters work with confignics postscript. 
  * Docker support in xCAT(experimental)
    * See the doc [xCAT Docker Image](https://sourceforge.net/p/xcat/wiki/xCAT%20Docker%20Image/)
  * Using confluent to replace conserver(experimental). A document was added to describe how to setup xCAT-confluent as xCAT console server.
  * To avoid the Poodle Attack, set TLSv1 as default SSL version for all the SSL connection in xCAT.
  * The GPG key for xCAT pkgs has been changed to 'xCAT Security Key'.
  * Enhance the command restartxcatd to support the 'fast restart xcatd' for systemd enabled system.
  * Support two new netboot methods: grub2-tftp and grub2-http. They can be used to control the communication protocol for grub2.
  * Add the rh7.0 directory in the xCAT dependency tar file. To install xCAT, if the OS of xCAT management node is rh7.0, use the rh7.0 directory in dependency tar file. And use the rh7 directory if the xCAT MN is rh7.1 and higher.
## Test Environment
 
  * xCAT dependency package verified with this xCAT release: 
     * Linux:[xcat-dep-201503171610.tar.bz2](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201503171610.tar.bz2/download)
     * AIX:[dep-aix-201403110451.tar.gz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/dep-aix-201403110451.tar.gz/download)
     * Ubuntu:[xcat-dep-ubuntu-snap20150323.tar.bz](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Ubuntu/xcat-dep-ubuntu-snap20150323.tar.bz/download)  
  * DFM package verified with this xCAT release:
    * Linux:[xCAT-dfm-2.9.1-7.ppc64le](http://www-933.ibm.com/support/fixcentral/swg/doSelectFixes?options.selectedFixes=DFM-2.9.1.7-powerLE-Linux&continue=1)
  * Hardware server for POWER8 with this release: 
    * [HARDWARESVR-1.2.0.0-powerLE-Linux](http://www-933.ibm.com/support/fixcentral/swg/doSelectFixes?options.selectedFixes=HARDWARESVR-1.2.0.0-powerLE-Linux&continue=1)
  * Operating systems verified with this xCAT release:
    * RHELS 6.6 
    * RHELS 7.0
    * RHELS 7.1
    * SLES 11.3 
    * SLES 12
    * Ubuntu 14.04.01  
    * Ubuntu 14.04.02
    * AIX 7100-03-15
  * Hw platform verified with this xCAT release(including the HMC versions):  
    * POWER7 (HMC version: V7R7.4.0)
    * POWER8 BE (HMC version: V8R8.2.0)
    * POWER8 LE  
    * dx360m4 
    

## Key Bug fixes

Get all the bugs which were fixed in 2.9.1 release from [2.9.1 defects](https://sourceforge.net/p/xcat/bugs/search/?q=_milestone%3A2.9.1+%26%26+status%3Aclosed).

## Restrictions and Known Problems

  * "syncfiles" postscript does not work for file syncing during rh7 installation, but it works fine in updatenode process. The workaround is to prefix the "/mnt/sysimage" to the destination directory. See [defect 4579](https://sourceforge.net/p/xcat/bugs/4579/) for details.
  * For some P8LE bare metal machine, when using "rsetboot <node> net" to start network install, the installing will hang at petitboot screen after installation. The workaround is to reboot the node with command "rsetboot <node> hd" and "rpower <node> reset". See [defect 4611](https://sourceforge.net/p/xcat/bugs/4611/) for details.  
  * Postscript 'confignics -s' does not work for sles12. See [defect 4565](https://sourceforge.net/p/xcat/bugs/4565/) for details.  
  * For Redhat7.0 provisioning, there might be some warnings on deprecated kernel/anaconda options. See [defect 4613](https://sourceforge.net/p/xcat/bugs/4613/) for details.
  * Sles12 xCAT management node does not enable the UDP port to receive syslog request from compute node, so the syslog on compute node can NOT be pushed to xCAT MN. The workaournd is to enable the following two lines in /etc/rsyslog.d/remote.conf on xCAT sles12 MN. See [defect 4478](https://sourceforge.net/p/xcat/bugs/4478/).
    $ModLoad imudp.so
    $UDPServerRun 514
  * If the /install on the management node is a nfs mounted directory, genimage for the RHEL 7.x diskless image may fail with error "cpio: cap_set_file failed - Operation not supported", see [bug 4654](https://sourceforge.net/p/xcat/bugs/4654/) for more details. The workaround is to change the osimage attribute rootimgdir to local file system, run genimage, and then tar up the genimage and copy the tar file back to the nfs mounted directory, and then change the osimage attribute rootimgdir back to the nfs mounted directory.