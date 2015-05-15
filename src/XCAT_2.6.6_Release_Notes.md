<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This is the summary of what's new in this release. Or you can go straight to [Download_xCAT]. 

These are the changes since the xCAT 2.6.2 release. Note: for reasons too difficult to explain here, the xCAT version number went straight from 2.6.2 to 2.6.6. There were no releases named 2.6.3, 2.6.4, or 2.6.5. 

## New Function and Changes in Behavior

  * New Commands. See corresponding man pages for details: 
    * [swapnodes](http://xcat.sourceforge.net/man1/swapnodes.1.html) \- for Power 775 Availability Plus support 
  * Enhanced Commands. See corresponding man pages for details: 
    * [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html)
      * "-c" flag to display node information in compressed mode 
      * "--osimage" flag to list the osimage information for the node 
    * [dumpxCATdb](http://xcat.sourceforge.net/man1/dumpxCATdb.1.html) and [restorexCATdb](http://xcat.sourceforge.net/man1/restorexCATdb.1.html) will honor a new [site](http://xcat.sourceforge.net/man5/site.5.html).skiptables attribute to limit the tables that are dumped and restored 
    * [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html) added support to just sync files to the service nodes ( -f flag) 
  * Support for Power 775 Clusters: 
    * Direct FSP Management(DFM) initial release. See [XCAT_Power_775_Hardware_Management#xCAT_Direct_FSP_and_BPA_Management_Capabilities] for more details on its capabilities, and see [XCAT_Power_775_Hardware_Management#Downloading_and_Installing_DFM] for information about installing it. 
      * [rpower](http://xcat.sourceforge.net/man1/rpower.1.html) \- Transition low power states, exit/enter rack standby, on/off/query of power state for CEC and LPAR 
      * [rcons](http://xcat.sourceforge.net/man1/rcons.1.html) \- Remote Console 
      * [rflash](http://xcat.sourceforge.net/man1/rflash.1.html) \- Firmware support for FSP and BPA 
      * [rinv](http://xcat.sourceforge.net/man1/rinv.1.html) \- Get the firmware level of FSP and BPA; get the deconfigured resource of CEC 
      * [rvitals](http://xcat.sourceforge.net/man1/rvitals.1.html) \- Display LCD values; Get the rack environmental information 
      * [getmacs](http://xcat.sourceforge.net/man1/getmacs.1.html) \- HFI MAC Address information collection 
      * [mkhwconn](http://xcat.sourceforge.net/man1/mkhwconn.1.html)/[rmhwconn](http://xcat.sourceforge.net/man1/rmhwconn.1.html) \- Make and remove FSP and BPA hardware connections 
      * [lshwconn](http://xcat.sourceforge.net/man1/lshwconn.1.html) \- List hardware connection status 
      * [rnetboot](http://xcat.sourceforge.net/man1/rnetboot.1.html) \- Remote network boot 
      * [lsvm](http://xcat.sourceforge.net/man1/lsvm.1.html)/[chvm](http://xcat.sourceforge.net/man1/chvm.1.html) \- LPAR list, creation and removal; I/O slot assignment, get and set of LPAR name 
      * [rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html) \- Sets the net or hfi device as the first boot device for the specified PPC LPARs 
      * [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) \- FSP and BPA password support; get and modify the frame number, get and set of frame name 
      * Redundancy FSP/BPA support 
    * Energy management for Power 775 servers. FFO (Fixed Frequency Override) for Power 775 servers that the accurate CPU frequency can be set to the server. See the [renergy](http://xcat.sourceforge.net/man1/renergy.1.html) command. 
    * Boot over HFI for AIX 7.1 and RHEL6 
    * Power 775 HFI mac address failover support 
    * Hardware replacement procedure for Power 775 Availability Plus. See [Power_775_Cluster_Recovery] 
  * DB2 WSE support. See [Setting_Up_DB2_as_the_xCAT_DB] 
  * iSCSI dump on AIX 7.1, kdump on RHEL6 
  * HA MN support(experimental). See [Shared_Disks_HA_Mgmt_Node] 
  * External NFS server support (experimental). See [External_NFS_Server_Support_With_Linux_Statelite] 
  * Service node manual failover (experimental) 
  * Locating all of the node deployment related files using nodetype.provmethod=osimage on Linux. So far, this has only been fully tested for stateless nodes. Statelite is supported per the instructions in the Statelite documentation, [XCAT_Linux_Statelite]. We will test it for full disk install and more statelite testing in the future. See [Using_Provmethod=osimagename] 
  * HPC integration enhancements: 
    * Support for latest IBM HPC software 
    * HPC integration support with AIX statelite. See [IBM_HPC_Stack_in_an_xCAT_Cluster] 
    * Set up of diskless login nodes. See [Setting_Up_IBM_HPC_Products_on_a_Statelite_or_Stateless_Login_Node] 
    * Set up of LoadLeveler central manager on xCAT service node. See [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] and [Setting_up_LoadLeveler_in_a_Stateful_Cluster] 
    * HPC toolkit support 
    * TEAL GPFS monitoring support. See [Setting_up_TEAL_on_xCAT_Management_Node] 
  * Rolling Update support for pLinux clusters and AIX clusters. See [Rolling_Update_Support] 
  * ddns plugin is the default dns handler. See [Cluster_Name_Resolution] 
    * The optional ddns plugin available for dynamic DNS support from xCAT 2.5 is not optional anymore. It is the only one shipped, and supported as of 2.6. The bind.pm plugin has been removed. If you want to keep the existing DNS settings made by xCAT BIND, then you should not run any "makedns" commands. If you want to use the Dynamic DNS feature then you must run "makedns -n" to refresh the DNS settings. 
    * makedns needs the /etc/resolv.conf on management node to have the mn's IP address specified as nameserver (from site.master) and cluster domain ( from site.domain) as a search path. If the compute nodes also needs to have name resolution to hosts outside the cluster, add the external nameservers addresses to the site table forwarders attribute. 
    * A warning will be issued when running makedns, if the nameserver or search paths are not set in /etc/resolv.conf. For AIX, this message is in error and should be checking for **domain site.domain** clause, and not **search site.domain**. It is just a warning and processing will continue. 
    * xCAT sets site.dnshandler to ddns automatically for two scenarios: 
      1. Fresh install for xCAT 2.6 
      2. Update install for xCAT 2.6 from an existing lower level xCAT version. 
    * If you restored xCATdb from a earlier backup(xCAT 2.5.x or earlier) after xCAT 2.6 is installed, it would overwrite or remove site.dnshandler, you need to manually set site.dnshandler=ddns after the restore, otherwise, makedns can not work. 
  * DNS hierarchical support: DNS on the service nodes forward unknown DNS request to management node 
  * Automatic creation of resolv.conf files on AIX nodes when using DNS. 
  * Use /etc/hosts as the name resolution when site.nameservers is blank 
  * New node attribute 'hwtype'. See [node definition](http://xcat.sourceforge.net/man7/node.7.html)
  * Disk mirroring setup in xCAT Linux cluster. [Use_RAID1_In_xCAT_Cluster] 
  * xCAT web interface initial release(experimental). 
  * Soft mount option support for statelite persistent files/directories. 
  * SLES 11 SDK iso image support 
  * Support pattern in genimage and updatenode 
  * genimage generic command (/opt/xcat/bin/genimage) now runs under the xcatd daemon as a plugin. You may notice changes in the interface and output displayed. If there is any prompting, for example acceptance of licenses, during your genimage; you can no longer run the generic genimage command, and must run the specific genimage script from the /opt/xcat/share/xcat/netboot/&lt;os&gt;/genimage directory. 
  * genimage specific commands ( /opt/xcat/share/xcat/netboot/&lt;os&gt;) creates the ifcfg-* file only if the -i flag is used, and has been changed to create with ONBOOT=no 
  * Support for preserving ODM data on diskless-stateless AIX nodes. 
  * Support for the use of dhcp for AIX installs. (Includes makedhcp enhancements.) 
  * A new sample postscript, ("make_sn_fs"), that may be used to create and mount local filesystems on the xCAT service nodes when they are installed. 

## Restrictions and Known Problems

  * genimage generic command (/opt/xcat/bin/genimage) now runs under the xcatd daemon as a plugin. If there is any prompting, for example acceptance of licenses, during your genimage; you can no longer run the generic genimage command, and must run the specific genimage script from the /opt/xcat/share/xcat/netboot/&lt;os&gt;/genimage directory. 
  * DNS fowarders can not work on AIX - [bug 3391271](https://sourceforge.net/tracker/?func=detail&aid=3391271&group_id=208749&atid=1006945|)

     The workaround is to dig the forwarder's dns records into /var/named/db.cache file and restart named service. 
     For example: 
     If your forwarder is 9.114.1.1, then run commands below on your xcat management node: 
     dig @9.114.1.1 . ns &gt;&gt;/var/named/db.cache 
     stopsrc -s named 
     startsrc -s named 

  * Power 775 support - On AIX after reboot of the EMS, the ISNM software will not automatically start and LoadLeveler will fail to start. In fact any 32 bit application that uses the DB2 database will have problems connecting to the database. This is a DB2 APAR, it is referenced in the defect and the problem will be fixed when V9.7.5 fix pack is available and applied. 

     See the following for instructions to restart the HPC stack: 
     [Setting_Up_DB2_as_the_xCAT_DB#Power_775_Special_instructions_for_Reboot_of_EMS_on_AIX] 
     See the following defect for details: [bug 3391193](https://sourceforge.net/tracker/?func=detail&aid=3391193&group_id=208749&atid=1006945|)
