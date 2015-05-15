<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.3.1 Since 2.3](#new-function-in-231-since-23)
- [Bugs Fixed in 2.3.1](#bugs-fixed-in-231)
- [Restrictions in 2.3.1](#restrictions-in-231)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the 2.3 release. Also see the [XCAT_2.3_Release_Notes]. 

## New Function in 2.3.1 Since 2.3

  * vmware management improvements 
  * New [mysqlsetup](http://xcat.sourceforge.net/man8/mysqlsetup.8.html) command to set up a MySQL database for use by xCAT. 
  * Added support to updatenode for updating software in AIX clusters 
  * Added Windows 7 support to copycds 
  * Many [documentation](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-client/share/doc/index.html) updates 

## Bugs Fixed in 2.3.1

Many bugs were fixed in 2.3.1, for details see http://sourceforge.net/tracker2/?func=browse&amp;group_id=208749&amp;atid=1006945 . 

## Restrictions in 2.3.1

  * If you run the xCAT command mkhwconn for system p servers to create new connections from FSP/BPA nodes to the HMC node, it may fail to make the connections to the HMC for some servers, even if the command returns success. The admin should verify that the proper connections were made between the FSPs/BPAs and the HMC, using the rscan command. If the HMC connection has failed, try resetting the CEC/HMC and execute the mkhwconn command again to resolve the issue. 
  * If you run xCAT command lsslp with flag "-w" to auto discover BPAs/FSPs and create BPA/FSP nodes in the xCAT DB, 

there are some types of BPAs/FSPs that will not respond with the user-defined BPA/FSP system names to xCAT. This causes the default node name created by lsslp to be different from the system name that is known by HMC. This limitation will not block most functions of xCAT. If system admins want to sync the user-defined system names used by the HMC to xCAT DB, please run rscan with -u option to update the FSP/BPA node names in the xCAT database. The rscan -u command should only be executed after the running of the mkhwconn command.  

  * There is a problem with rscan -u command where the updated FSP server node name does not automatically set up the 

proper name resolution. This may cause errors when xCAT rmhwconn command tries to reference the new FSP server node. The admin should manually update the name resolution (/etc/hosts) file for the changed FSP server host name. 

  * There is a problem with xCAT lsslp -w command that may provide an incorrect BPA/FSP/HMC node entry in xCAT DB when working with "/etc/hosts" file for name resolution. There can only be one host name entry allocated for the FSP/BPA/HMC IP address, and it can not contain any blank character at the end of the host name. If you allow lsslp -w to discover and create your BPA/FSP/HMC server node entry in /etc/hosts there are no issues. Here are some 

examples of proper and improper entries working with /etc/hosts file. 
    
    "192.168.200.1  fsp1"     (good)
    "192.168.200.1  fsp1 "    (bad)
    "192.168.200.1  fsp1  fsp1-new"  (bad)
    
