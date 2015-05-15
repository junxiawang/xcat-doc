<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Tested OS's](#tested-oss)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * Add support for devices ( switches) in sinv. See man sinv: [sinv](http://xcat.sourceforge.net/man1/sinv.1.html)
  * rbeacon is supported for Flex system 
  * Energy management support for Flex System (renergy command) 
  * RHEL 6.4 support on system x and system p 

## Tested OS's

RH6.3, RH6.4 and AIX71H 

## Key Bug fixes

  * When upgrading the xcatd did not restart properly: [2359](https://sourceforge.net/p/xcat/bugs/2359/)
  * updatenode with ospkgs failure: [3229](https://sourceforge.net/p/xcat/bugs/3229/)
  * LCDs were not displayed properly by the rvitals command for Flex Power 7 blades: [3382](http://sourceforge.net/p/xcat/bugs/3382/)
  * In the ospkgs postscript (used by updatenode -S), the baseurl was set incorrectly in the zypper repo on SLES: [3381](https://sourceforge.net/p/xcat/bugs/3381/)
  * Incorrect postscript/postbootscript list generated for a node. [3412](https://sourceforge.net/p/xcat/bugs/3412/)
  * mlnxofed_ib_install need to support hierarchical environment.[3513](https://sourceforge.net/p/xcat/bugs/3513/)
  * Certain NodeRanges do not expand correctly, see [[bug 3429](https://sourceforge.net/p/xcat/bugs/3429/)]. 

  


## Restrictions and Known Problems

  * rmdsklsnode can not remove the NIM machine definition with AIX 7.1.2.0 Update image on xCAT management node or service node. This is actually caused by AIX APAR IV32670. You can get more info from bug [3527](https://sourceforge.net/p/xcat/bugs/3527/)

    the workaround is to force reinstall the bos.sysmgt.nim.master 7.1.2.0 fileset using AIX 7.1 TL02 media. 

  * updatenode -k does not work to compute nodes in a hierarchical environment; that is when the compute node is accessed via a service code. Running this command to the compute node results in an infinite loop which consumes memory. For a work around to exchange ssh keys use xdsh -K to the compute node. [3652](https://sourceforge.net/p/xcat/bugs/3652/)
  * In HAMN environments, credential validation can fail. [3704](https://sourceforge.net/p/xcat/bugs/3704/)
