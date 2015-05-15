<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bugs Fixed](#key-bugs-fixed)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

  * Support for IBM Flex and system p compute nodes. 
  * The "-t FNM" flag of rpower to boot p775 CECs from the xCAT management node, even when hierarchical DFM hardware control is configured. 
  * Support for real-time service node fail over on AIX(experimental) 
  * New check for xCAT ifixes. Every xCAT ifix must be removed prior to any upgrades to the xCAT packages. 
  * kdump support on SLES 11 
  * lsslp.pm plugin is rewritten. lsslp now uses the new SLP.pm module and does not depend on openslp. 
  * HPC integration updates to install HPC software stack from otherpkg list. 
  * Not display the passwords in the command output and log files 
  * Scaling and performance improvements for Power 775 servers 
  * Performance improvements in running postscripts, converting noderange, running synclists to large number of nodes 
  * Redhat 6.2 is supported on x-series, IBM Flex System P260/P460 
  * AIX 7.1 Pl1/SP3 is supported 

## Key Bugs Fixed

See the [xCAT 2.7.2 SourceForge bugs](https://sourceforge.net/tracker/?limit=25&func=&group_id=208749&atid=1006945&assignee=&status=1&category=&artgroup=&keyword=&submitter=&artifact_id=0&assignee=&status=&category=&artgroup=2359373&submitter=&keyword=&artifact_id=0&submit=Filter&mass_category=&mass_priority=&mass_resolution=&mass_assignee=&mass_artgroup=&mass_status=&mass_cannedresponse=&_visit_cookie=03524f22b4a66df32ca92cfa49d76029). 

  * xcatconfig caused long delay during install of xCAT, if postscripts table had many entries. https://sourceforge.net/tracker/?func=detail&amp;aid=3527641&amp;group_id=208749&amp;atid=1006945 
  * xcatd error with large XML transfer. https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3526893&amp;group_id=208749&amp;atid=1006945 
  * sinv returns error when no error. https://sourceforge.net/tracker/?func=detail&amp;aid=3524781&amp;group_id=208749&amp;atid=1006945 
  * xcatd does not clean up processes when ctrl-C run when xCAT command running: https://sourceforge.net/tracker/?func=detail&amp;aid=3516818&amp;group_id=208749&amp;atid=1006945 
  * In hierarchy, updatenode -f does not work to diskless nodes when tftpboot directory not mounted on the service nodes. https://sourceforge.net/tracker/?func=detail&amp;aid=3527599&amp;group_id=208749&amp;atid=1006945 

## Restrictions and Known Problems

  * rflash commands fails with syntax error in FSPflash.pm. See defect for affected system types. The udpate FSPflash.pm is attached to the defect. https://sourceforge.net/tracker/?func=detail&amp;aid=3530839&amp;group_id=208749&amp;atid=1006945 This defect is fixed in PMR 19420. For xCAT AIX adminstrators looking for the official AIX ifix, contact IBM customer service for this PMR in the zaix,13a queue. The ifix can be downloaded from the ftp testcase.software.ibm.com download site. Note that the ifix it only remains on this download site for 5-7 days. 
  * RHEL 6.2 kdump does not work on Power 775. The efix is available in this [bug description](https://sourceforge.net/tracker/?func=detail&aid=3526766&group_id=208749&atid=1006945). 
  * lsslp multicast on AIX usage restriction. If you want to use lsslp on AIX and the nodes need to be discovered through multicast,the work around is: 
    1. add multicast route first, for example: route add 239.255.255.253 40.0.0.96, 
    2. use lsslp -i, for example, lsslp -i 40.0.0.96 
    3. delete the route: route delete 239.255.255.253 40.0.0.96 
    * If you have several vlans and need to do discovery through several network interfaces, you need to repeat the steps above. 
  * lsslp occasionally could not discover all objects: the efix has been attached on the bug https://sourceforge.net/tracker/?func=detail&amp;aid=3529398&amp;group_id=208749&amp;atid=1006945 
  * When installing(not updating) xCAT on system x management node, you will get some error like "Command failed: XCATBYPASS=Y /opt/xcat/sbin/mknb x86_64 2&gt;&amp;1\. Error message: Error: Unable to find directory /opt/xcat/share/xcat/netboot/x86_64", this will cause issues with the hardware discovery for system x servers. To workaround this problem, you can either install xCATnbkernel,xCAT-nbroot* manually or make the directory /opt/xcat/share/xcat/netboot/x86_64 manually before running yum or zypper command to install xCAT. 
  * genimage problem in HPC integration. There are two known problems about HPC integration. Bug: https://sourceforge.net/tracker/?func=detail&amp;atid=1006945&amp;aid=3529659&amp;group_id=208749 

    

  * 1) loadl-5103.otherpkgs.pkglist is not putting Loadleveler rpms in a subdirectory. Fix: putting the package names in loadl-5103.otherpkgs.pkglist to loadl subdirectory as: 
    
          loadl/LoadL-full-license*
          loadl/LoadL-scheduler-full*
          loadl/LoadL-resmgr-full*
    

    

  * 2) GPFS otherpkgs list includes a comma in comment which is not allowed. Fix: remove the comma in GPFS otherpkgs list. For example: 
    
          -# List additinal package names in comments to reduce image size, uncomment them if they are necessary for you.
          +# List additinal package names in comments to reduce image size
          +# uncomment them if they are necessary for you
    

  * mknb problem on system x during xCAT install, workaround provided on defect. https://sourceforge.net/tracker/?func=detail&amp;aid=3532045&amp;group_id=208749&amp;atid=1006945 
