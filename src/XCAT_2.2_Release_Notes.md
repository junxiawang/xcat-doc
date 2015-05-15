<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2.2 Enhancements (compared to xCAT 2.1)](#xcat-22-enhancements-compared-to-xcat-21)
- [Known Problems](#known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# xCAT 2.2 Enhancements (compared to xCAT 2.1)

  * New OS support: SLES11, AIX 5.3.10, 6.1.3 
  * Utilities to help manage IB networks (mostly on system p) 
  * Firmware upgrades for system p 
  * AIX hierarchical support 
  * Better support for dynamic service node pools 
  * User-defined db tables 
  * csm-&gt;xcat db migration tool 
  * enhance xdsh/xdcp support for non-root users 
  * system p hw ctrl enhancements: mkvm/chvm ehancements, getmacs/rnetboot/rpower performance improvements 
  * developers guide and updated documentation 
  * RMC monitoring enhancement to support event batching and IB monitoring. 
  * Plugin for [Virtual Clusters using VirtualBox Virtual Machines](Using_VirtualBox_Nodes) 
  * KVM virtualization support. 
  * Improved pping/nodestat performance for many environments 
  * xcoll now attempts to abbreviate noderanges using member groups 
  * Improved conserver startup scaling/tolerance of downed consoles 
  * Support for IBM x3550 M2/x3650 M2/HS-22/dx-360 M2 
  * Performance enhancements in xCAT server startup 
  * Implement support for proxied DHCP networks 
  * Add support for rpower on with one-off ISO image (only supported for KVM guests at the moment) 
  * Support for rinv to IPMI nodes presenting DIMM/Power Supply/etc information as available 
  * Fix Xen/KVM rcons support hangs in hypervisors 
  * Support Xen stateless hypervisors via PXE 
  * wvid support for IBM Bladecenter, IBM servers using IMM with installed remote presence key, Xen, and KVM guests. 
  * Support for AIX on js21/22 blades 

# Known Problems

For the current list of known problems in xCAT 2.2, see the [open Tracker bugs](https://sourceforge.net/tracker/?func=browse&group_id=208749&atid=1006945). 
