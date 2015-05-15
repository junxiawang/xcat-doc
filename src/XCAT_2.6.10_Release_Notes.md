<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bugs Fixed](#key-bugs-fixed)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

## New Function and Changes in Behavior

  * Support for mkdsklsnode -n in AIX clusters to more quickly switch nodes to a new image 
  * Huge page support in p775 clusters 
  * Add site table syspowerinterval attribute for booting p775 CECs. 
  * More performance improvements for DFM in p775 clusters 
  * Redundant service network support for p775 clusters 
    * Requires the HPC hardware server version 1.1.0.2 or higher for AIX and 1.1.0.1 or higher for Linux 
    * On AIX, this feature has been FVT'd (Functional Verification Test), but has not yet been System Tested. 
    * On Linux, this feature has been FVT'd and scale tested. 
  * snmove can now copy statelite persistent files to the backup service node 
  * RHEL 6.1 support for non-p775 clusters 
  * RHEL 6.1 support for p775 clusters(experimental) 
  * RHEL 6.2 early support on system p 
  * Added binary backup option to [dumpxCATdb](http://xcat.sourceforge.net/man1/dumpxCATdb.1.html) for DB2 to do database backups more efficient for large databases. 

## Key Bugs Fixed

  * [When running DB2, updatenode -k function removed cfgloc file on the Service Node](https://sourceforge.net/tracker/?func=detail&aid=3448413&group_id=208749&atid=1006945)
  * If xcatd loses connection to the database, it automatically reconnects. Before this fix, it had to be stopped and started manually. 
  * updatenode -k changes the permission of the /install/postscripts directory files to 0700 when the /install directory is mounted on the Service nodes. This makes them unable to run. This is fixed. 
  * [mkdsklsnode -n fixes](https://sourceforge.net/tracker/?func=detail&aid=3431252&group_id=208749&atid=1006945)
  * [confighfi cannot reset the running hfx interfaces](https://sourceforge.net/tracker/?func=detail&aid=3469422&group_id=208749&atid=1006945)
  * [/install/postscripts/* changed to 700 permission](https://sourceforge.net/tracker/?func=detail&aid=3460126&group_id=208749&atid=1006945)
  * [After HA EMS testing xcatd hang on service nodes](https://sourceforge.net/tracker/?func=detail&aid=3459192&group_id=208749&atid=1006945)
  * [ssh/xdsh running commands like tabdump from Management Nodes on Service nodes hanging](https://sourceforge.net/tracker/?func=detail&aid=3458311&group_id=208749&atid=1006945)
  * Regular expressions created in tables by xcatsetup were not handled correctly by the rest of the xCAT code. 
  * [PMR66218 rpower command hung](https://sourceforge.net/tracker/?func=detail&aid=3448211&group_id=208749&atid=1006945)
  * [PMR66023 Core Dump fsp-api](https://sourceforge.net/tracker/?func=detail&aid=3439004&group_id=208749&atid=1006945)
  * [PMR93423 mkhwconn causes long failover time HAEMS](https://sourceforge.net/tracker/?func=detail&aid=3466886&group_id=208749&atid=1006945)

For additional bugs fixed, see [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945)

## Restrictions and Known Problems

  * For AIX diskless nodes, if you define /var/adm/ras/errlog as a statelite persistent file in the litefile table, default entries in crontab like the following may cause significant slow downs on the service nodes for a few minutes when those entries run (due to high disk usage on the SNs): 
    
    0 11 * * * /usr/bin/errclear -d S,O 30
    0 12 * * * /usr/bin/errclear -d H 90

     You may want to reduce the frequency that these commands are run. 

  * When powering on multiple p775 CECs or powering on LPARs of multiple p775 CECs via rpower, set site.powerinterval to 30 before running rpower. See https://sourceforge.net/tracker/?func=detail&amp;aid=3426911&amp;group_id=208749&amp;atid=1006945 for details. 
  * The rnetboot command for p775 LPARs won't correctly set the default bootlist in AIX diskless nodes so the LPAR can be rpower'd next time. Also, the default bootlist can sometimes change after the user sets it. The workaround for now is to always run rbootseq before running rpower on for p775 LPARs. See https://sourceforge.net/tracker/index.php?func=detail&amp;aid=3435969&amp;group_id=208749&amp;atid=1006945 for details. 
  * Lose DB2 root setup on Linux when updating xCAT rpms on MS and SN's. See defect 3474407 for manual fix. https://sourceforge.net/tracker/?func=detail&amp;aid=3474407&amp;group_id=208749&amp;atid=1006945 
  * SF defect 3477804. This defect affects you, if you are running DB2 and LoadLeveler using DB2 on the service nodes. If you run updatenode &lt;servicenodes&gt; -S on Linux or AIX, and you find that the /etc/odbc.ini and odbcinst.ini have been reinitialized back to defaults, then you will need to xdsh &lt;servicenodes&gt; /opt/xcat/bin db2sqlsetup -C -o, to set these files back up for LoadLeveler to be able to access the database. 
