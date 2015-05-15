<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Test Environment](#test-environment)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)
  - [Upgrade of 2.7 to 2.8 on SLES](#upgrade-of-27-to-28-on-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * The [policy table](http://xcat.sourceforge.net/man7/policy.7.html) is now sorted on the priority field before checking it for authorization for a particular command. See [bug 2959](https://sourceforge.net/p/xcat/bugs/2959/). 
  * New support for rebuilding the initrd of an OS image to inject new drivers from rpm packages. See [Using_Linux_Driver_Update_Disk]. 
    * Added a new command '[geninitrd](http://xcat.sourceforge.net/man1/geninitrd.1.html) &lt;osimage&gt;' to rebuild the initrd for both stateful and stateless osimages. 
    * Added a new flag '[nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html) \--noupdateinitrd' to avoid the rebuild of the initrd for a stateful osimage (if you have already done it using geninitrd). 
    * Added the function to search the 'osimage.osupdatename' to get the kernel rpm and extract the new drivers to the initrd from the searched kernel rpm. If the new kernel is included in the 'osimage.osupdatename', it will be used in the os deployment process for this osimage. 
  * Xeon Phi Support Phase 2: See [Managing_MIC_(Intel_Xeon_Phi)_nodes] 
    * Support MPSS 3.1 (Built with Yocto). (The MPSS 2.x support has been dropped from 2.8.3) 
    * Support software installing for mic node. Three types of format are supported for customer to install software on mic node: 
      1. filelist format - All the files will be installed to a chroot directory. A specific .filelist configuration file needs be installed at /opt/mic to indicate which file should be installed to where in mic ramfs. 
      2. rpm format - The rpm will be copied to ramfs of mic node, it will be installed just before the running of init during boot of mic Linux system. 
      3. simple format - A directory is specified that the whole directory will be copied directly to mic ramfs. 
    * Support to use stateless OS on mic host node. The MPSS is installed by kit to the stateless image for mic host. After adding kit to osimage, the MPSS will be installed automatically to chroot directory when running genimage against the stateless image. 
    * Support auto nfs mount during mic booting 
    * Support internal bridge 
  * NeXtScale support: See [XCAT_NeXtScale_Clusters] 
    * Support for discovery of the NeXtScale Fan Power Controllers (FPC) 
    * rpower, rinv, rflash, and rvitals support for the NeXtScale FPC 
    * Support for discovery, deployment, and managment of the IBM NeXtScale nx360 M4 Compute Node. 
  * Deploying OpenStack support on ubuntu 12.04: See [Deploying OpenStack with Chef](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Deploying_OpenStack#Deploying_OpenStack_with_Chef)
    * Update the [clouds](http://xcat.sourceforge.net/man5/clouds.5.html) table 
    * Update the scripts: confignics, config_chef_server, config_chef_workstation and config_chef_client , 
    * Add a new command makeclouddata to generate the environment file 
    * Add new scripts: configbr-ex(using with confignics), mountinstall, loadclouddata, configgw 
  * Remove machine type check for [renergy](http://xcat.sourceforge.net/man1/renergy.1.html) command 
    * Enhance the renergy command for System P that renergy command can be run against any power machine node. 
  * [xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html) now supports the -t flag for timeout when running ssh key updates (-K). See [xdsh man page](http://xcat.sourceforge.net/man1/xdsh.1.html). [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html) also supports the -t flag for the similar (-k) option. 
  * [tabrestore](http://xcat.sourceforge.net/man8/tabrestore.8.html) new flag -a will add the rows from the *.csv file to the table instead of replacing all table contents from the *.csv file. 
  * xCAT flow control - performance improvement for deploying large clusters. See [Using Flow Control](Hints_and_Tips_for_Large_Scale_Clusters#Using_Flow_Control) for more details. 
  * The group ownership of the files in the xcat-core and xcat-dep tarballs was changed from "xcat" to "root". Also, the permissions of the files in the xcat-dep tarball were cleaned up to make them consistent and more appropriate. 
  * Imaged provisioning for sles11, sles10, rhel6, rhel5 on system X. See section [Installing Stateful Nodes Using Sysclone](XCAT_iDataPlex_Cluster_Quick_Start#Option_2:_Installing_Stateful_Nodes_Using_Sysclone). 
  * Confignics enhancements: 
    * supports configuring the install nic 
    * auto searches the [networks](http://xcat.sourceforge.net/man5/networks.5.html) table so you don't have to specify nicnetworks attribute in the [nics](http://xcat.sourceforge.net/man5/nics.5.html) table 
    * configure ip address dynamically 
    * See [Configuring_Secondary_Adapters] 
  * [Sequential discovery](XCAT_iDataPlex_Cluster_Quick_Start#Option_1:_Sequential_Discovery) enhancements 
    * Added a new flag "-n" to [nodediscoverstart](http://xcat.sourceforge.net/man1/nodediscoverstart.1.html), to specify to run makedns &lt;nodename&gt; for any new discovered node 
    * Added a new argument osimage=xxx to nodediscoverstart, to specify the discovered nodes will be associated with the osimage and the os provisioning should be started automatically. 
    * If the bmciprange is specified with nodediscoverstart, it will set up the BMC for any new discovered nodes automatically during the sequential discovery process 
    * A new flag "-s|--skipbmcsetup" is added to skip the bmcsetup even when bmciprange is specified 
  * Support AIX 7.1.3.0 
    * There are two versions of perl-Net_SSLeay.pm rpm listed in the sample bundle files, use perl-Net_SSLeay.pm-1.30-3* for AIX 7.1.2 and older versions, use perl-Net_SSLeay.pm-1.55-3* for AIX 7.1.3 and above, see details in /opt/xcat/share/xcat/installp_bundles/xCATaixCN71.bnd and /opt/xcat/share/xcat/installp_bundles/xCATaixSN71.bnd. 
    * Also see the known problem below about the net-snmp RPMs in bundle files 
  * Enhancements to [Kit support](Using_Software_Kits_in_OS_Images) 
    * Allow multiple package locations as input to the [buildkit](http://xcat.sourceforge.net/man1/buildkit.1.html) addpkgs command. 
    * Support updating packages in a complete Kit. 

## Test Environment

  * Operating systems verified with this xCAT release: 
  *     * AIX: 7.1.2, 7.3.1.0 and 7.3.1.1 ( 71L and 71L sp1) 
  *     * LInux: Rhel5,6 SLES 10,11 

## Key Bug fixes

  * Check for Management node in the database did not work for some MN names. [bug 3778](https://sourceforge.net/p/xcat/bugs/3778/)
  * xdsh commands timeout to BNT switch [bug 3777](https://sourceforge.net/p/xcat/bugs/3777/)
  * Incorrect password chosen for r* command. See [bug 3780](https://sourceforge.net/p/xcat/bugs/3780/)
  * remoteshell postscript can infinite loop on error . See [bug 3781](https://sourceforge.net/p/xcat/bugs/3781/)
  * tabprune -d does not work on eventlog [bug 3823](https://sourceforge.net/p/xcat/bugs/3823/)
  * imgexport 2.7 will not imgimport to 2.8 [bug 3813](https://sourceforge.net/p/xcat/bugs/3813/)
  * packimage (squashfs) option not working [bug 3683](https://sourceforge.net/p/xcat/bugs/3683/)
  * For other closed 2.8.3 defects [2.8.3 defects](https://sourceforge.net/p/xcat/bugs/search/?q=_milestone%3A2.8.3&limit=250/)

## Restrictions and Known Problems

  * If there is more than one nic on the management node or service nodes that is configured with ip addresses in the same subnet, only the first nic in this subnet can be used as the dhcpinterface. The other nics in this subnet will be ignored by xCAT DHCP setup. See SF defect [bug 3792](https://sourceforge.net/p/xcat/bugs/3792/) for more details. 
  * rhels6.4 NFS based statelite is currently unusable due to a rhels6.4 bug: [bug 3559](https://sourceforge.net/p/xcat/bugs/3559/). There is no work around yet. This problem is fixed in rhel 6.5, which will be supported in xCAT 2.8.4. 
  * rhels6.4 statelite will fail if noderes.xcatmaster is set to the hostname of the MN due to [bug 3693](https://sourceforge.net/p/xcat/bugs/3693/). The work around is to set noderes.xcatmaster to the ip address of the MN. 
  * For deploying OpenStack support on ubuntu 12.04, the configbr-ex couldn't work well. You can use the e-fix to replace the file /install/postscripts/configbr-ex. See SF defect [bug 3898](https://sourceforge.net/p/xcat/bugs/3898/) for more details. 
  * For deploying OpenStack support on ubuntu 12.04, if there isn't an ./environments/ in /install/chef-cookbooks, the makeclouddata couldn't work well. See SF defect [bug 3904](https://sourceforge.net/p/xcat/bugs/3904/) for more details. 
  * Uninstalling PE 1.3 PTF6 man page ppe_rte_man-1.3.0.6-*.rpm either directly or indirectly by upgrading to PE 1.3 PTF7 will output RPMTransaction errors during the rpm %preun script processing. The new packages are installed successfully (despite the errors). The errors can be ignored (we think), so no workaround is required. Waiting for a fix from PE RTE. See SF defect [bug 3486](https://sourceforge.net/p/xcat/bugs/3486/) for more details. 
  * On a new installation of xCAT 2.8.3 on an AIX or SLES 11 SP3 ppc64 management node, if you are using [mysqlsetup](http://xcat.sourceforge.net/man1/mysqlsetup.1.html) you may get an error that it can't connect to xcatd. The work around is to simply run mysqlsetup again and it should succeed the second time. See [bug 3906](http://sourceforge.net/p/xcat/bugs/3906/) for details. 
  * If you have AIX 7.1.3 (or above) service nodes, you must update the bundle file that is used to install xCAT to install the later version of of the net-snmp-* RPMs that are now in the xcat-dep tarball. The bundle file that is shipped with xCAT, that can be used as a sample for your service node bundle file, is in /opt/xcat/share/xcat/installp_bundles/xCATaixSN71.bnd on the management node. But for AIX 7.1.3 or above, it should install net-snmp-5.7.2-3, not net-snmp-5.4.2.1-3. See [bug 3912](https://sourceforge.net/p/xcat/bugs/3912/) for details. 
  * Driver update from media fails on SLES 11.3. See [bug 3933](https://sourceforge.net/p/xcat/bugs/3933/). 
  * In the hierarchy cluster, if the node's xcatmaster is set to the service node, _nodeset &lt;noderange&gt; rumcmd=xxx_ and _nodeset &lt;noderange&gt; shell_ will still point the node to use the management node as the xcatmaster. See bug [bug 3932](https://sourceforge.net/p/xcat/bugs/3932/). 
  * Error on service xcatd restart on Service Node "Nodeset was run with a noderange containing both service nodes and compute nodes. This is not valid. You must submit with either compute nodes in the noderange or service nodes. " Fix provide on defect. See [bug 3942](https://sourceforge.net/p/xcat/bugs/3932/). 

### Upgrade of 2.7 to 2.8 on SLES

  * When updating xCAT from 2.7 to 2.8 on a SLES x86_64 MN, using the command **zypper update -t package '*xCAT*' **, zypper will ask the following question: 
    
    
    Problem: xCAT-2.8-snap201302071009.x86_64 requires xCAT-genesis-scripts-x86_64, but this requirement cannot be provided
      uninstallable providers: xCAT-genesis-scripts-x86_64-1:2.8-snap201302071009.noarch[xcat28]
     Solution 1: replacement of xCAT-genesis-x86_64-1:2.7.7-snap201301100842.noarch with xCAT-genesis-scripts-x86_64-1:2.8-snap201302071009.noarch
     Solution 2: do not install xCAT-2.8-snap201302071009.x86_64
     Solution 3: break xCAT by ignoring some of its dependencies
    
    Choose from above solutions by number or cancel [1/2/3/c] (c):
    

    

  * Choose solution # 1. The new xCAT-genesis-scripts-x86_64 rpm replaces the xCAT-genesis-x86_64 rpm. It gets combined with the xCAT-genesis-base-x86_64 rpm from xcat-dep when mknb is run and forms the new genesis boot kernel. 
  * If you have a hierarchical SLES x86_64 cluster, you will hit this same problem when upgrading the services nodes. Since the choice needs to be responded to interactively, you must upgrade xCAT on the SNs manually, instead of having xCAT's otherpkgs support do it for you. 

  * sles11.2 nfs_based statelite on x86 deployment fails. See SF [bug 3038](https://sourceforge.net/p/xcat/bugs/3038/) for workaround. 
  * Perl errors on sles when perl-IO-Socket-INET6 rpm is installed on SLES SP2. See SF defects: [bug 3173](https://sourceforge.net/p/xcat/bugs/3173/). You only see the messages in some commands when not running under the daemon, like xcatconfig and if you export XCATBYPASS=y and run tabdump &lt;tablename&gt;. To get rid of the warnings remove the rpm. Cause of problem under investigation. 
