<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New Function and Changes in Behavior

  * pscp, prsync, psh supports new argument -f and env variable to set fanout value. See [man pages](http://xcat.sf.net/man1/xcat.1.html). 
  * SLES 11 SP2 support on system x and system p. The following features have been verified: 
    * Operating system provisioning in flat (non-hierarchical) cluster, including diskful, stateless and statelite 
    * Basic hardware control features 
  * Support for IBM Flex system x compute nodes with RHEL 6.2. 
  * HPC integration support for the latest IBM HPC software stack. 
  * [Deferred firmware update support](XCAT_Power_775_Hardware_Management#Perform_Deferred_Firmware_upgrades_for_frame.2FCEC_on_Power_775) for Power 775 (Experimental). 

## Key Bug fixes

  * rflash commands fails with syntax error in FSPflash.pm. See defect for affected system types. The udpate FSPflash.pm is attached to the defect. https://sourceforge.net/tracker/?func=detail&amp;aid=3530839&amp;group_id=208749&amp;atid=1006945 
  * lsslp occasionally could not discover all objects:https://sourceforge.net/tracker/?func=detail&amp;aid=3529398&amp;group_id=208749&amp;atid=1006945 
  * genimage problem in HPC integration. https://sourceforge.net/tracker/?func=detail&amp;atid=1006945&amp;aid=3529659&amp;group_id=208749 
  * RHEL 6.2 kdump does not work on Power 775.https://sourceforge.net/tracker/?func=detail&amp;aid=3526766&amp;group_id=208749&amp;atid=1006945 
  * mknb problem on system x during xCAT install. https://sourceforge.net/tracker/?func=detail&amp;aid=3532045&amp;group_id=208749&amp;atid=1006945 
  * A couple fixes for highly available service nodes on AIX: 
    * https://sourceforge.net/tracker/?func=detail&amp;aid=3528454&amp;group_id=208749&amp;atid=1006945 
    * https://sourceforge.net/tracker/?func=detail&amp;aid=3526650&amp;group_id=208749&amp;atid=1006945 
  * xdcp not running postscript after rsync. https://sourceforge.net/tracker/?func=detail&amp;aid=3555671&amp;group_id=208749&amp;atid=1006945 
  * For the rest, see the [list of xCAT 2.7.3 fixed bugs](https://sourceforge.net/tracker/?limit=100&func=&group_id=208749&atid=1006945&assignee=&status=&category=&artgroup=&keyword=&submitter=&artifact_id=&assignee=&status=&category=&artgroup=2359374&submitter=&keyword=&artifact_id=&submit=Filter&mass_category=&mass_priority=&mass_resolution=&mass_assignee=&mass_artgroup=&mass_status=&mass_cannedresponse=&_visit_cookie=64635057e44c2c4069df1252302673ee). 

## Restrictions and Known Problems

  * RHEL 6.2 diskless boot on the IBM Flex system p compute nodes might be kernel panic with error "dracut Warning: No root device "1" found". It is caused by the upper case characters in the nodes' mac attribute, we are still working with Linux team to figure out the reason, for now, the Workaround is to change the nodes' mac attribute to be lower case characters. For details see: https://sourceforge.net/tracker/?func=detail&amp;aid=3535481&amp;group_id=208749&amp;atid=1006945 
  * updatenode -k does not work to compute nodes. To update ssh key to compute node, use xdsh -K command. To update hostkeys on the compute nodes, use xdcp or pscp to copy /etc/xcat/hostkeys directory to the /etc/ssh directory on the node. https://sourceforge.net/tracker/?func=detail&amp;aid=3537905&amp;group_id=208749&amp;atid=1006945 
  * xcat upgrade of xcat-rmc rpm fails, if /install directory is local mounted directory or mounted on service node. Workaround is to force install the rpm. See https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3538372&amp;group_id=208749&amp;atid=1006945 
  * intirid fail to mount rootimg on sles11.2 x86. This is a sles11.2 bug and a bugzilla reported opened. Work-around and details of the problem documented in https://sourceforge.net/tracker/?func=detail&amp;aid=3558922&amp;group_id=208749&amp;atid=1006945 
