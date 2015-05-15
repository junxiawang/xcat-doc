<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Features in xCAT 2.2.2](#new-features-in-xcat-222)
- [Key Bugs Fixed in xCAT 2.2.2](#key-bugs-fixed-in-xcat-222)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New Features in xCAT 2.2.2

  * RHEL 5.4 support 
  * Support fully qualified hostnames and otherinterfaces in makehosts 

## Key Bugs Fixed in xCAT 2.2.2

  * The IB tool getGuids did not work correctly on SLES 11. See https://sourceforge.net/tracker/?func=detail&amp;aid=2826390&amp;group_id=208749&amp;atid=1006945 
  * Several bugs fixed in the IB adapter configuration sample postscript (configiba.1port) 
  * Fixed output of IB healthCheck and getGuids sample scripts 
  * Sort output of rscan 
  * Updated AIX service node NIM bundles 
  * Fixed several bugs when DB tables did not exist 
  * Improved xdsh/xdcp performance by reducing the amount off name resolution 
  * Switch to using the more reliable xcatd port 3001 for AIX postscripts 
  * Fixed several bugs to rflash on system p 
  * Remove xcataixpost from inittab file for duskfull AIX nodes. 
  * Enable mknimimage to read multiple CDs. 
  * Added fail-retry to lpar_netboot (used in rnetboot and getmacs on system p) 
  * Added retry loop layer to bmcsetup 
  * Many documentation updates 

  
For the full list of current bugs, see https://sourceforge.net/tracker/?func=browse&amp;group_id=208749&amp;atid=1006945 
