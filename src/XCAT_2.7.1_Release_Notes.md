<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

  * The -t flag of the [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) command has been deprecated. Use a postinstall script to replace/modify the /etc/fstab files as you like. 
  * Add interactive mode for [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) command, the new flag is --interactive. 
  * HPC integration updates for new HPC product versions &amp; packaging. 
  * SLES 11 SP2 support (experimental) 
  * Linux postscripts logic clean up: 
    * Move the creation of the mypostscript file from /tmp/mypostscript to /xcatpost/mypostscript 
    * Extract the common code for generating the mypostscript file and make it common across all scripts under /opt/xcat/share/xcat/install/scripts 
    * Add timestamps on the running of the postscripts and start and stop headers in /var/log/xcat/xcat.log 
    * Writing xcat.log in stream like mode 
  * xcatchroot command output the messages printed by the command runs in chroot environment. 
  * configiba.* scripts enhancements to determine the number of IB interfaces automatically. 
  * Support for installing/updating SLES SDK packages using updatenode for SLES diskful nodes. 
  * ## Key Bugs Fixed

See the [xCAT 2.7.1 SourceForge bugs](http://sourceforge.net/tracker/?limit=25&func=&group_id=208749&atid=1006945&assignee=&status=1&category=&artgroup=&keyword=&submitter=&artifact_id=0&assignee=&status=&category=&artgroup=2359372&submitter=&keyword=&artifact_id=0&submit=Filter&mass_category=&mass_priority=&mass_resolution=&mass_assignee=&mass_artgroup=&mass_status=&mass_cannedresponse=&_visit_cookie=0621f4901943f3cbebed5dafd22e6053sourceforge.net/tracker/?limit=25&func=&group_id=208749&atid=1006945&assignee=&status=1&category=&artgroup=&keyword=&submitter=&artifact_id=0&assignee=&status=&category=&artgroup=2359372&submitter=&keyword=&artifact_id=0&submit=Filter&mass_category=&mass_priority=&mass_resolution=&mass_assignee=&mass_artgroup=&mass_status=&mass_cannedresponse=&_visit_cookie=0621f4901943f3cbebed5dafd22e6053). 

## Restrictions and Known Problems

  * SLES 11 SP2 support is currently experimental. 
  * The p775 support in this release has not yet been fully tested. 
