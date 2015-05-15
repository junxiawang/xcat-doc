<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function, Changes in Behavior, and Bugs Fixed in 2.6.2 Since 2.6.1](#new-function-changes-in-behavior-and-bugs-fixed-in-262-since-261)
- [Known Issues and Work Arounds](#known-issues-and-work-arounds)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the [2.6.1 release](XCAT_2.6.1_Release_Notes). 

## New Function, Changes in Behavior, and Bugs Fixed in 2.6.2 Since 2.6.1

  * A new [xCAT Linux deps tarball](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201107291350.tar.bz2/download) was built to fix the plugin load errors on Centos6/Redhat6 x86* - bug [3380912](https://sourceforge.net/tracker/?func=detail&aid=3380912&group_id=208749&atid=1006945)
  * makedns needs the /etc/resolv.conf on management node has the mn's IP address specified as nameserver (from site.master) and cluster domain ( from site.domain) as a search path. If the compute nodes also needs to have name resolution to hosts outside the cluster, add the external nameservers addresses to the site table forwarders attribute. 

## Known Issues and Work Arounds

  * "makedhcp -n" reports error 'Can't call method "brsft" ...' - [bug 3323752](https://sourceforge.net/tracker/?func=detail&aid=3323752&group_id=208749&atid=1006945)
  * makedns can not work on SLES - [bug 3365678](https://sourceforge.net/tracker/?func=detail&aid=3365678&group_id=208749&atid=1006945) \- [SuSE bugzilla 73119](https://bugzilla.linux.ibm.com/show_bug.cgi?id=73119)

     workaround - run "chown root:name /var/lib/named" on management node. Fixed in xCAT svn truck revision 10094. 

  * makedns can currently only handle domain names with at least one "dot" in them. For example a doman of cluster.net is valid, but a domain of just cluster is not. Defect 

3384808 is opened to fix. 
