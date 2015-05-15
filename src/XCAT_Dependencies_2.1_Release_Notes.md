<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT Dependencies 2.1 Release Notes](#xcat-dependencies-21-release-notes)
    - [Additional Changes:](#additional-changes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# xCAT Dependencies 2.1 Release Notes

Contains other open source packages that xCAT uses/requires. 

Note: this version of the xcat-dep package supports both xCAT 2.0.x and 2.1.x 

This release enables x336/x346 SOL and support for a few more network devices in the nbfs. It also patches a problem in atftp daemon with multicast. It also defaults to disabling multicast, but is configurable in /etc/sysconfig/atftpd. 

### Additional Changes:

  * Add Sys::Virt rpm for supporting Xen feature 
  * Add gPXE to enable iSCSI support on non-iSCSI servers 
  * Add stgt to provide a more reliable software iSCSI target than comes with RHEL5.2 
  * Add IO::Stty to some missing platforms 
  * Update to ipmitool 1.8.10 with isol support 
  * Add igb driver to the nbfs kernel 
  * Multicast patch to atftp 
