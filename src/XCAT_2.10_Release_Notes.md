<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Test Environment](#test-environment)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

** Note: xCAT 2.10 is not released yet, this release notes page is still under construction**


## New Function and Changes in Behavior

* cuda installation support for ubuntu 14.04.2 on PowerNV
  * diskfull and diskless
  * support 2 kinds of cuda package set, the cudaruntime package set(for compute node only) and cudafull package set.

  
* Support the user specified persistent kernel options for diskful nodes in "addkcmdline" attribute of node and osimage object definition.
  * supported on Ubuntu, Redhat and SLES. 
  * See "set the kernel options which will be persistent the installed system" section of [Installing_Stateful_Linux_Nodes](https://sourceforge.net/p/xcat/wiki/Installing_Stateful_Linux_Nodes/) for Details.

* CentOS 7.1 support on x86_64, the CentOS 7.1 is also named as CentOS-7 (1503).

## Test Environment
     

## Key Bug fixes


## Restrictions and Known Problems