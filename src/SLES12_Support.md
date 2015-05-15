<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Lists to be verified and updated](#lists-to-be-verified-and-updated)
- [tested on X86 KVM system](#tested-on-x86-kvm-system)
- [Bug lists for SLES12 support](#bug-lists-for-sles12-support)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note: this is an xCAT , not an xCAT user document. If you are an xCAT user, you are welcome to glean information from this design, but be aware that it may not have complete or up to date procedures.**


This is a general guideline to support SLES12 release in XCAT.  Based on SUSE Release Notes, we created a list XCAT needs to be verified and updated to better support SLES12. We tested SLES12 support on the X86 KVM system, and also listed BUG# we found on the testing.

Lists to be verified and updated
----------------------------------
1) Support for the 64 bit Little-Endian variant of IBM's Power architecture, in addition to continued support for the Intel 64/AMD64 and IBM System Z architectures.  So, for the power system, XCAT will support SLES12 on the ppc64le system.
2) Btrfs has become the default file system for the root partitions.
3) syslog and syslog-ng have been replaced by rsyslog
4) MariaDB is now shipped as the relational database instead of MySQL
5) /var/run is mounted as tmpfs and thus not persistent across reboots.  Anything stored in this directory will be removed when the machine is shut down.
6) The traditional method for setting up the network with ifconfig has been replaced by wicked. A lot of networking commands are deprecated and have been replaced by newer commands (ip in most cases).
        arp:      ip neighbor
        ifconfig: ip addr, ip link
        iptunnel: ip tunnel
        iwconfig: iw
        nameif:   ip link, ifrename
        netstat:  ss, ip route, ip -s link, ip maddr
        route:    ip route
7) service command is no longer support in the SLES12
8) /run/media/<user_name> replaces /media
9) systemd cleans tmp directory daily and does not honor sysconfig settings in /etc/sysconfig/cron, and migrated into systemd configuration(/etc/tmpfiles.d/tmp.conf)
10) Use /etc/os-release instead of /etc/SuSE-release (still available on SLES12, will be deprecated on SLES12 SP1)


tested on X86 KVM system
--------------------------
1) set up SLES12 xCAT management node on X86 KVM system.
2) installed the xCAT core packages with xCAT dependency packages and OS shipped packages
3) Configured xCAT management node and started xCAT service
4) Defined two diskfull Compute node (two VMs).
5) provisioned compute nodes with SLES12 compute OS images

Bug lists for SLES12 support
----------------------------
4312  Created new xcat-depts and repo for SLES12
4311  Changes to syslog postscripts and ships rsyslog8.4.X with sles12
4316  Fixed the systemimager-server dependency problem and installed syscolne packages
4317  Failed to run copycds
4331  Failed to run makedns (need perl-Net-DNS-0.80-1...rpm)
4332  Failed to run httpd (need new level of apache2.4)
4337  rcons does not work for SLES12 KVM. 
4343  The mariaDB service on SLES12 is called mysql instead of mariadb
4364  Change KVM nicmodel default to virtio
4345  Utils->osver routine does not support Redhat7 or SLES12


Other Design Considerations
• Required reviewers: xCAT ALL
• Required approvers: Li Guang Cheng
• Database schema changes: N/A
• Affect on other components: N/A
• External interface changes, documentation, and usability issues: Yes
• Packaging, installation, dependencies: Yes
• Portability and platforms (HW/SW) supported: SLES12
• Performance and scaling considerations: N/A
• Migration and coexistence: Yes
• Serviceability: N/A
• Security: N/A
• NLS and accessibility: N/A
• Invention protection: N/A

    