<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Limitations and Known Issues](#limitations-and-known-issues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New Function and Changes in Behavior

  * New OS support: 
    * RHEL6 beta support 
    * Scientific Linux 5 support 
    * Fedora 12/13 support 
    * Support for AIX 7.1 and AIX 6.1.6. AIX 5.3 is no longer officially supported with xCAT 2.5 and above. 
  * New commands. See the corresponding man pages for details. 
    * [lsflexnod](http://xcat.sourceforge.net/man1/lsflexnode.1.html)/[mkflexnod](http://xcat.sourceforge.net/man1/mkflexnode.1.html)/[rmflexnode](http://xcat.sourceforge.net/man1/rmflexnode.1.html) \- manage flexible nodes that contain more than one physical server. 
    * [makeroutes](http://xcat.sourceforge.net/man8/makeroutes.8.html) \- add routes to connect the MN to the nodes via the service nodes. 
    * [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) \- move nodes from one service node to another 
    * [lslite](http://xcat.sourceforge.net/man1/lslite.1.html) \- Display a summary of the xCAT statelite information stored in the xCAT database. 
    * [chkosimage](http://xcat.sourceforge.net/man1/chkosimage.1.html) \- For AIX osimages verify if the NIM lpp_source directories contain the required software. 
    * [xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html) \- Use this xCAT command to modify an xCAT AIX diskless operating system image. (Simplifies the use of the AIX chroot command.) 
    * [rmimage](http://xcat.sourceforge.net/man1/rmimage.1.html) \- Removes the Linux stateless or statelite image from the file system. 
  * New optional ddns plugin: 
    * ddns plugin available for dynamic dns support 
    * Enhanced Active Directory integration (requires use of ddns plugin) 
    * No longer absolutely need a static ip address assigned ahead of time, nodes may live entirely in dynamic scope. (Requires use of ddns plugin and xnba netboot method) 
  * VMWare support enhancements: 
    * vSphere 4.1 support 
    * Improved ESXi 4.1 stateless images (fixup authorized_keys, etc) 
  * KVM plugin enhancements 
    * nfs:// uri syntax supported for vm.storage, will appear on hypervisor as /var/lib/xcat/pools/&lt;uuid&gt;
    * chvm allows online modification of virtio storage (add/delete) and offline modification of IDE drives 
    * BIOS bootorder of disks in a vm is now better preserved on power off in complicated virtual disk configurations 
    * rinv command for listing information about a VM 
    * lsvm on KVM hypervisors to list all VMs, regardless of whether xCAT manages them or not 
    * rmvm -p to purge all storage associated with a VM 
    * Compatibility with RHEL6 virtualization stack 
    * Present a consistent UUID to guest OSes across reboots 
    * Default to 'vga' adapter where available for enhanced guest video capability. 
  * vm.storagemodel and vm.nicmodel available to specify default model of respective virtualized devices. The =model syntax is still supported. (VMWare and KVM) 
  * clonevm command to create masters from VMs and instantiate VMs from masters (VMware and KVM) 
  * Expanded support for provisioning, managing, and monitoring of Linux on s390x: 
    * Control the power of virtual servers 
    * Create, edit, and delete virtual servers 
    * Clone Linux virtual servers 
    * Provision Linux based on a autoyast or kickstart template 
    * Collect software and hardware inventories of virtual servers 
    * Compare software inventory 
    * Monitor Linux virtual servers using Ganglia 
    * Create diskfull or diskless (Statelite) virtual servers 
    * Run commands in parallel 
    * Check out what xCAT can do on [youtube](http://www.youtube.com/user/xcatuser)
  * AIX enhancements: 
    * The mknimimage command has been enhanced to: 
      * improve support for updating AIX diskless images, (You can now specify options to use when installing rpm and emgr packages.) 
      * improve support for copying AIX diskless images. 
    * Added statelite support for AIX diskless-stateless deployments. This provides the ability to “overlay” specific persistent files or directories over the standard stateless support. (This support is included as "beta" support in this release.) 
    * Provide a sample AIX postscript(createFS) that may be used to create additional local file systems on the nodes. 
    * Added prescripts support for AIX. 
  * Statelite and stateless enhancements: 
    * Statelite: the options for the entries in litefile table are up-to-date, please refer to the manpage of litefile table. 
    * genimage wrapper takes image definition from the osimage table. 
    * Enhancements to image import/export to support postscripts, profiles, copying image etc. 
  * Enhanced xdcp and updatenode rsync file syntax support. Allow wild cards, entire directory transfers. See man page for xdcp and updatenode and the document [Sync-ing_Config_Files_to_Nodes].
  * SNMP monitoring enhancements: supports running different cmds for different traps, supports "contains" for trap filter. 
  * makedhcp takes site.disjointdhcps, if it is set, the .leases files on the sn will only contain the nodes that are managed by the sn. 
  * Many DHCPv6 client behaviors changed to use UUID for DUID (ESXi/Windows/...) 
  * updatenode command on Linux supports installing additional rpms or updating rpms on the node that are from the OS distro. 
  * noderes.primarynic/noderes.installnic may be left blank for autodetection based on boot interface (RH/SLES/ESXi) 
  * DB2 9.7 support on AIX 6.1 and Redhat 5, and DB2 9.7.0.3 support on AIX 7.1. 
  * Enhanced interface for user tables. See  [Granting_Users_xCAT_privileges]
  * renergy command supports the energy management for blade server 
  * chdef command supports to change the object name 
  * Added the new feature of supporting Driver Update Disk for Linux deployment. The Driver Update Disk can be loaded automatically during the diskfull installation and diskless netboot 
  * Documentation on how to setup management node high availability. See [Highly_Available_Management_Node].
  * Enhancement to rpower command to perform coordinated cluster bringup and shutdown, using the information in the deps table 

## Limitations and Known Issues

  * The lsslp command in xCAT 2.5 on AIX runs more slowly than in xCAT 2.4. We are still investigating the cause. See [the Tracker bug](https://sourceforge.net/tracker/?func=detail&aid=3035938&group_id=208749&atid=1006945) for details. 
  * If the "all" group is not defined, mkdsklsnode on AIX will fail. See [the Tracker bug](https://sourceforge.net/tracker/?func=detail&aid=3091461&group_id=208749&atid=1006945) for details. 

For additional issues, see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945) . 
