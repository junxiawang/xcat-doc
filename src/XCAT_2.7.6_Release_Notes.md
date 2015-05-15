<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Tested OS](#tested-os)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * HPC integration support for latest IBM HPC software stack 
  * Support for SLES 10 SP4 

## Tested OS

  * AIX 6.1.8 and 7.1.2 
  * Rhel5,6 SLES 10,11 

## Key Bug fixes

  * A couple IPMI bugs existed in 2.7.5: 
    * In an initial install of 2.7.5 on new hardware, rvitals and rinv would not work. 
    * For cmds like rvitals for a lot of nodes would give errors like: node1: Error: 1 code on opening RMCP+ session 

     Both of the problems are fixed in this release, see [bug 3156](https://sourceforge.net/p/xcat/bugs/3156/). 

## Restrictions and Known Problems

  * On Linux, if after upgrade and you run lsxcatd -a, it does not show you are running Version 2.7.6, then you will need to do the following: 
    * service xcatd stop 
    * ps -ef | grep xcatd, kill -9 any processes 
    * service xcatd start 
    * lsxcatd -a to check 
    * This will be fixed in 2.7.7 with the following defect: [bug 2359](https://sourceforge.net/p/xcat/bugs/2359/)
  * rbeacon is not supported for Flex system, it will be supported in 2.7.7. 
  * updatenode with ospkgs doesn't work in xCAT 2.7.6 . It has been fixed. You can get more information and e-fix from [bug 3229](https://sourceforge.net/p/xcat/bugs/3229/)
  * On AIX IB configuration, there is a known AIX IB node description issue that is fixed with AIX IFIX IV36529. xCAT has also made updates to our configiba post scripts which will be fixed in xCAT 2.7.7. You can get more information and e-fix from [bug 3338](https://sourceforge.net/p/xcat/bugs/3338/)
  * If you create your own osimage names, that is do not use the generated defaults, then the postscripts and postbootscripts attribute is not honored in your osimage. This is fixed in 2.7.7. 
