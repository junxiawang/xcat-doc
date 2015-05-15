<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New Function and Changes in Behavior

  * SLES 11 SP2 support on System x and System p servers 
  * Firmware assisted dump support for Power 775 servers 
  * Support for IBM Flex system x compute nodes 
  * Improved IPMI reliability and performance for large systems (~5,000 servers in 30 seconds) 
  * The statelite "litetree" table now supports a mount options attribute. 

## Key Bug fixes

  * updatenode -F and xdcp -F could not handle hierarchical running synclists when the nodes on the Service Node did not have the same synclist. https://sourceforge.net/tracker/?func=detail&amp;aid=3552171&amp;group_id=208749&amp;atid=1006945 
  * Document procedure for changing HMC password. https://sourceforge.net/tracker/?func=detail&amp;aid=3549975&amp;group_id=208749&amp;atid=1006945 
  * xdcp entire directory copy in a hierarchical environment did not work. https://sourceforge.net/tracker/?func=detail&amp;aid=3538653&amp;group_id=208749&amp;atid=1006945 
  * Support multiple commands in the commands attribute of the policy table. https://sourceforge.net/tracker/?func=detail&amp;aid=3530574&amp;group_id=208749&amp;atid=1006945 
  * Should not set conserver to start on reboot during upgrade of xCAT. This should be done only once during install. https://sourceforge.net/tracker/?func=detail&amp;aid=3510989&amp;group_id=208749&amp;atid=1006945 
  * PMR 29187,066,866: lsslp wrong output. https://sourceforge.net/tracker/?func=detail&amp;aid=3554903&amp;group_id=208749&amp;atid=1006945 
  * For the rest of the bug fixes in 2.7.4, see the [list of 2.7.4 bugs fixed](https://sourceforge.net/tracker/?limit=100&func=&group_id=208749&atid=1006945&assignee=&status=&category=&artgroup=2955289&keyword=&submitter=&artifact_id=0&assignee=&status=&category=&artgroup=2955289&submitter=&keyword=&artifact_id=0&submit=Filter&mass_category=&mass_priority=&mass_resolution=&mass_assignee=&mass_artgroup=&mass_status=&mass_cannedresponse=&_visit_cookie=1c48c54524376afa1c40112d3d4960ea). 

## Restrictions and Known Problems

  * After you reset, restart a CMM or update CMM firmware, you shall run the command "rspconfig cmm sshcfg=enable snmpcfg=enable" to avoid the 'Unsupported security level' issue. 
  * Issue with nfs-based statelite on x86_64 SLES 11 SP2, the statelite nodes could not boot up, with error "mount.nfs: Protocol not supported". See https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3558922&amp;group_id=208749&amp;atid=1006945 for more details and the workaroud. 
  * The installation of the xCAT-IBMhpc-2.7.4-snap201208232241.noarch rpm will fail on Linux unless you have ksh installed. See defect https://sourceforge.net/tracker/?func=detail&amp;aid=3563735&amp;group_id=208749&amp;atid=1006945 
