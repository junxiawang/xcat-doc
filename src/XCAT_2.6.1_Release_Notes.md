<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior in 2.6.1 Since 2.6](#new-function-and-changes-in-behavior-in-261-since-26)
- [Known Issues and Work Arounds](#known-issues-and-work-arounds)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the [2.6 release](XCAT_2.6_Release_Notes). 

## New Function and Changes in Behavior in 2.6.1 Since 2.6

  * Improved support for installing new kernels in stateless image. See [XCAT_pLinux_Clusters#Installing_a_new_Kernel_in_the_stateless_image]. 
  * ddns plugin is the default dns handler. 

     The optional ddns plugin available for dynamic DNS support from xCAT 2.5 is not optional anymore. It is the only one shipped, and supported as of 2.6. The bind.pm plugin has been removed. A new option makedns -n has been added, see man makedns. If you want to use the Dynamic DNS feature then you must run "makedns -n" to refresh the DNS settings. 

  * xCAT sets site.dnshandler to ddns automatically for two scenarios: 

     1\. Fresh install for xCAT 2.6 
     2\. Update install for xCAT 2.6 from an existing lower level xCAT version. 

  * If you restored xCATdb from a earlier backup(xCAT 2.5.x or earlier) after xCAT 2.6 is installed, it would overwrite or remove site.dnshandler, you need to manually set site.dnshandler=ddns after the restore, otherwise, makedns can not work. 
  * makedns needs the /etc/resolv.conf on management node has the mn's IP address specified as nameserver and cluster domain as search path. If the compute nodes also needs to have name resolution to hosts outside the cluster, add the external nameservers addresses to the site table forwarders attribute. 

  * A new [site attribute](http://xcat.sourceforge.net/man5/site.5.html) "vsftp" to control if the vsftpd daemon will be started automatically when xcatd is started. (The default is 1.) 
  * A new postscript "setupscratch" to setup a scratch area on local disk for stateless nodes 
  * Implement -t argument for blade plugin to update vpd table with mtm/serial/uuid 

## Known Issues and Work Arounds

  * "makedhcp -n" reports error 'Can't call method "brsft" ...' - [bug 3323752](https://sourceforge.net/tracker/?func=detail&aid=3323752&group_id=208749&atid=1006945)
  * makedns can not work on SLES - [bug 3365678](https://sourceforge.net/tracker/?func=detail&aid=3365678&group_id=208749&atid=1006945) \- [SuSE bugzilla 73119](https://bugzilla.linux.ibm.com/show_bug.cgi?id=73119)

     workaround - run "chown root:name /var/lib/named" on management node. Fixed in xCAT svn truck revision 10094. 

  * makedns hangs a while and reports "Unable to find zone to hold xxx". - [bug 3369831](https://sourceforge.net/tracker/?func=detail&aid=3369831&group_id=208749&atid=1006945)

     workaround - define a corresponding network entry in xcat networks table for the reported hosts. Fixed in xCAT 2.6.2. 

  * makedns with no flag does not work - [bug 3379381](https://sourceforge.net/tracker/?func=detail&aid=3379381&group_id=208749&atid=1006945)

     workaround - use "makedns -n". Fixed in xcat 2.6.2. 

  * For x86/x86_64 xCAT management node, some Perl modules (bpa.pm fsp.pm hmc.pm ivm.pm) cannot be loaded when starting the xcatd. [bug 1006945](https://sourceforge.net/tracker/?func=detail&aid=3380912&group_id=208749&atid=1006945)

     workaround - Just ignore it as warning message. Or download the latest dependency package and reinstall the perl-IO-Tty-1.07-1 package. 
