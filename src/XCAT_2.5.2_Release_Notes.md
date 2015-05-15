<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.5.2 Since 2.5.1](#new-function-in-252-since-251)
- [Bugs Fixed in 2.5.2](#bugs-fixed-in-252)
- [Known Issues and Work Arounds](#known-issues-and-work-arounds)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.5.1 release. Also see the [XCAT_2.5.1_Release_Notes]. 

## New Function in 2.5.2 Since 2.5.1

  * rinv -t to allow writing data from vSphere to xCAT databases 
  * Support dhcpd having multiple, non-contiguous dynamic ranges 
  * SLES 11 SP1 support for stateless/statelite 
  * Postscripts behavior was enhanced 

## Bugs Fixed in 2.5.2

  * Fix genimage compatibility with older RHEL5 versions 
  * Fix compatibility with older stateless/statelite images 
  * Fix problem where xCAT failed to customize stateless ESXi 4.0 
  * Fix remote video compatibility with newer versions of IBM IMM firmware 
  * Fix reparenting virtual machines when vSphere performs migrations without xCAT involvement 
  * Refrain from configuring dhcpd for dynamic DNS unless the corresponding dnshandler is chosen 
  * Fix multi-mac syntax when VMs are created with multiple addresses 
  * Fix boot nic auto-detection 

Many bugs were fixed in 2.5.2. For details see the [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945), or check the subversion commit history for the 2.5 branch. 

## Known Issues and Work Arounds

  * The AIX support for the "notify" option when defining a NIM dump resource is not currently working. In an xCAT cluster this option would be specified with the mknimimage command. Do not attempt to use this option at this time. 
