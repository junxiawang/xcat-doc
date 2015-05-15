<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT Roadmap](#xcat-roadmap)
- [Candidates for xCAT 2.10](#candidates-for-xcat-210)
  - [Priority 1](#priority-1)
  - [Priority 2](#priority-2)
  - [Priority 3](#priority-3)
- [Candidates for xCAT 2.10 or Later](#candidates-for-xcat-210-or-later)
- [Someday...](#someday)
    - [Jarrod Johnson:](#jarrod-johnson)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## xCAT Roadmap

This page represents the roadmap for xCAT as far as we know it at this point in time. The xCAT development plan is flexible and is often reprioritized based on user requirements. This is good because it means xCAT focusses on what users want, but it also means we can't guarantee that the roadmap won't change. 

We want to hear your requirements and input on the roadmap. New features can be requested by opening a [Tracker feature](https://sourceforge.net/tracker/?group_id=208749&atid=1006948) or by posting them to the [xCAT mailing list](https://lists.sourceforge.net/lists/listinfo/xcat-user). 


## Candidates for xCAT 2.10

**Note: The xCAT 2.10 wishlist is still under construction...**

### Priority 1
  * Build Sys::Virt xcat dependency package for SLES 11. - Yang Song.
  * Latest Linux/AIX updates support 
  * Latest system p, system x and Flex models support
  * enhance the xCAT postscript framework: 
    * The postscript should not hang, no matter what the configuration error is. 
    * The node should not be in an infinite provisioning loop, no matter what the configuration error is. 
    * Provide more useful messages or other effective ways for debugging 
    * Make the deployment process less dependent on name resolution, and review where the error msgs go when things go wrong. 
    * Use a shell subroutine library to avoid duplicate code in different postscripts 
    * We need to figure out a way in xCAT to make our default postscripts smarter so that we don't try to run the otherpkgs and some other postscripts on every boot of a diskless node, yet still allow explicit use of it when the admin does want to run it on an exception basis. 
  * Set up dual boot of windows/linux for diskfull install 
  * REST API improvments - either use reverse proxy, or fastcgi. Talk to jarrod. The idea of fastcgi is to use apache's fastcgi capability. With this, instead of forking a cgi script for every http request (which is what currently happens for our rest api), apache connects to a persistent cgi process and sends it multiple http requests. In our case, the persistent process would be xcatd. This would mean xcatd needs to accept a socket connection from apache and fork a long running process to handle it. And it means that the process would have to get the request from the fastcgi protocol and translate that into function calls or plugin calls (via runxcmd), and then return the results. So the logic in our current xcatws.cgi would have to be reworked, because there are more efficient ways for it to get the data, since it is already inside xcatd. And since this process is persistent, it would take advantage of all the db caching we do. See http://en.wikipedia.org/wiki/FastCGI 
  * Provide a way to disable the auditlog in syslog to keep the syslog clean (but keep "auditlog" table logging enabled). For 3 reasons: 
    * The auditlogs are already logged to "auditlog" table. So, you wouldn't lose any auditlog info if you disabled them in syslog. 
    * In a typical cluster, the majority of xCAT messages in syslog are auditlogs. We find that they had a lot of noise to syslog. Removing them would make it easier for PCM users to locate the relevant xCAT logs during troubleshooting. 
    * Disabling the auditlogs reduces the amount of logs generated, which prevents essential log msgs from getting rotated out of the logs. 
  * Provide a way to make the xCAT offline trouble shooting be easier, two options: 
    * Add site option to tell xcatd to capture the output of each xcat cmd in a separate file under /var/log/xcat/commands. The file name should have the cmd name in it and something else to make it unique (pid or time of day). This way admins could refer back to any cmd they've run. The dir could be pruned the way /tmp is. 
    * Add more information in the xCAT syslog, for example, it would be helpful to know which cmd generated a syslog msg. I can then match these logs to specific cmdlines in the auditlog table. 
  * [Management_Node_Pool] (multiple active MNs) for easier HA 
  * sysclone enhancements 
    * sysclone support on plinux (for pcm and for PowerLinux boxes deployment) 
    * sysclone support bit torrent and multicast 
  * makedns message enhancement in verbose/non-verbose mode (sun jing) 
    * in verbose mode, output each lines for "Handling xxx" and "Ignoring xxx". 
    * in non-verbose mode, output a line like "Defining nodes from /etc/hosts in the DNS (&lt;dns-ip-addr&gt;)..." and then output another dot for every 10 nodes (or whatever is a reasonable number that typically takes about 5 seconds). Putting all of the ignore msgs at the end.
  * PowerKVM support enhancements:
    * New PowerKVM versions support
    * KVM hosting on Ubuntu, RHEL and RHEV
    * cloning for LE Linux distributions
    * More kvm features support: lsvm, rscan 

### Priority 2

  * Command to get the nodeset stat, see bug [4427](https://sourceforge.net/p/xcat/bugs/4427/)
  * gpfs-lite nodes: [GPFS_statelite_nodes] 
  * remote media boot on flex via xnba - jarrod already implemented this for the agusta team 
  * Additional kit enhancements 
    * chkosimage support for linux 
  * configuring the services on the node (like ntp and dns) to point to more than 1 SN in case one of the SNs goes down (this is included in the MN pools design) 
  * lsslp supports unicast. It should first use nmap looking for port 427 (the slp port) to narrow down which ip addresses are alive and will likely respond to an slp request. Then lsslp can do unicast slp to each of those machines. nmap will much more efficiently find the live ip addresses. (This is already done by yin le on 2.7.x, 2.8.x, and 2.9.) 
  * use confluent as a replacement for conserver (jarrod may do this) 
  * make the LPAR management user interface be consistent between HMC-managed systems and DFM-managed systems 
  * a new non-sql db option, e.g. redis (jarrod may do this) 
  * NTP setup enhancement. Draft design is ready [Enhance_NTP_setup_support] (Sun Jing) 
  * Automated inventory. Have the hardware discovery process get more hardware inventory information and update the hardware inventory information into xCAT table. (Ling is already doing this as part of the xcat nova bare metal driver work.) 
  * [xcat MN export/import](Xcatexport_and_xcatimport_commands) 
    * Be able to take a picture/snapshot of an xcat mgmt node (everything but the base distro) and put it on a usb stick (or dvd, or directory) and be able to restore it to another machine with a single cmd. One use for this is if manufacturing set up a customer cluster config (to configure and test all of the hw), then before breaking it down and sending to the customer, they could do xcatexport to a usb stick. The at the customer site, they physically hook up the hw, install the distro on the mn, put the usb stick in and run xcatimport, and then rpower the nodes. There have been some schemes in the past that people have tried that included the whole os in the snapshot, but this gets into legal problems we don't want to deal with. 
    * This would also be useful for the many solutions that will be using xcat. And could even be useful if you just want to replace the hw of your mn. And when we get the active/active ha mn support done, a variation of this could be used to get the 2nd (and subsequent) mns set up. 
  * Change ifconfig to "ip" on Linux, the ifconfig command is obsolete on Linux, need to change all the ifconfig instances to "ip" command. Some configuration scenarios like IB has started complaining for any ifconfig command invocation. 
  * confignics supports bridge and bonding interfaces, have confignics to create/destroy the bridge and bonding interfaces. 
  * Add a couple health check scripts for xcat, in the form that hcrun can use. 
    * Checking the attrs for the node and image it is using 
    * The node status check, like nodestat, rpower, pping.. 
  * Add an argument to syslog postscript to specify keep the local copy of the syslog messages, these local copy could be useful for debugging application problems on specific compute nodes.

### Priority 3

  * lsdef to list the node attributes postscripts and postbotootscripts should include the postscripts and postbootscripts defined in the osimage also, with the correct order of execution. 
  * More work on a minimal compute image? 
    * review the pkg list and exclude list for current distro levels 
    * make sure hpc kits are excluding as much as possible 
  * PCM - support customized database service port number, perl DBI does support to specify port number, dbi:DriverName:database=database_name;host=hostname;port=port
  * clean up all/most the places we check /etc/redhat-release or /etc/suse-release or for debian/ubuntu: Proposed to collect most distribution-related things into one perl module. One of the functions in there should be able to return various attributes of the system (e.g. the path of the dhcp conf file. - Yang Song 
  * CA integration: 
    * currently we have a pretty automated CA facility that only ever establishes trust relationships within 'xCAT' workflows and only uses our CA. Put more stuff in such that more stuff that would otherwise use self-signed, would be xCAT CA signed. Also, add support for blessing and submitting a CSR to another CA. Examples: 
      * ESXi web services are x509 secured and standard practice is to ignore validation. If we do a tiny effort and then doc adding our CA to vcenter server, then the validation can be enabled and will succeed at whatever security level the admin deemed appropriate (privport attested, switch attested, imm attested) 
      * Puppet does a similar scheme. We can have puppet trust our CA, but on list someone suggested they would prefer xCAT pass along the CSR to an external CA. 
    * So in general, and probably as a first pass, the default behavior would be to issue the cert ourselves with an option to punt any non-xCAT related certs. Unfortunately, there is no standard to describe this sort of relay, so we'd just have to say 'provide custom command to invoke with the csr file and must output a valid cert in some format' 
  * Better install progress reporting. I want to agree on the table and column names to hold the additional data: 
    * 'updatemynodestat' updates nodelist.status, but desire is there for more specific sub-enumeration (e.g. 'failure' in nodelist.status and 'storage_failure' in some other field), as well as potentially a field for free form 'diagnostic' string. 
    * nodestat showing error messages in event of install failure (comprised of the same content as above, but queried direct to node rather than via table) 
  * Complete removal of '3002' port usage for modern OSes (RHELS6.x+, SLES11+, Windows, ESXi). It already can be disabled, but most of our stock templates would break if user elected to do that. 
  * Consolidate various 'port based auth' schemes into a single one to request an x509 certificate, switch it to have three selectable mechanisms 'privport','switch_imm' for authentication)_
  * Require x509 node certificate for all node-requested requests except the above request 
  * LLDP lookup of public key data to authenticate discovery and certificate requests (optional requirement user can enable) 
  * IMM datastore lookup of public key to authenticate certificate requests as alternative to switch based mechanism above. 
  * storage.osvolume support for describing acceptable targets for install. 'localdisk' means explicitly SAN devices are forbidden, 'usbdisk' means usb-storage only, and 'wwn=0x&lt;hex&gt;' means only install to target with matching wwn value. Default behavior is to be 'prefer localdisk, then usbdisk, then any other block device including SAN' 
  * Move windows to using 'z:' instead of 'i:' for mounting install resources, preserving support for WIM files currently hardcoded to I: to the extent possible 
  * Add site value to control acceptable SSL ciphers 
  * Add site value to control kvm guest persistence (persistkvmguests) 
  * Add support for vmware's proprietary linux guest addition 'clonevm --specialize' 
  * Full fledged Windows postscript system 
  * Other thoughts I think may be worthwhile: 
    * RDOC alternative to 'xnba' plugin. Requires IMM with remote media key, gets around DHCP requirement and offers another secure channel for credential exchange. Requires a little work on xNBA and system x tools team to deliver a scriptable RDOC management facility. 
    * UDP protocol based transaction throttling scheme. A cooperative traffic control scheme to throttle clients in a fairly extensible way. Can be used to throttle xCAT client connections but also to track other arbitrary throttle requirements like gpfs startup. Requests would have a 'acquire' and 'release' with server generated tokens and an expiry that can be shortened by client on their request. Requests may be signed in a manner similar to how discovery requests are signed, but validation of the signature might be an optional behavior in the interest of performance. 
    * Convert conserver startup throttling to use the above, more capable facility 
    * Investigate Conman/homegrown conserver alternatives (eye toward better auth integration with xCAT policy table and console logging IO optimization) 
    * Alternative data serialization/deserialization between client and server. Perl client would tend to enable frozen perl hashes, current xml supported, option to add JSON if requested 
    * Client side request aggregator. If the same user launches many instances of the same command and have an environment variable set to indicate acceleration, apply an aggregation technique to reduce requests to xCAT. 
    * IPMI.pm SOL support and IPMI session manager to share control and console traffic over same channel, deprecate ipmitool-xcat prereq. 
  * Secure passwords in xcat - Sun Jing 
    * Do not show passwords in the commands messages, verbose mode output or trace/log files - Done 
    * Do not show passwords with table manipulation commands like tabdump, nodels, tabedit, def commands, etc. - 2.9 
    * Encrypt passwords in xCAT tables - 2.9 
  * DFM FSP CIM interface investigation: As FSPs become assimilated into Director there may be more CIM enhancements made in the FSP support which we would be able to make use of in our xCAT management. This is to track some investigation of the FSP CIM interface enhancements. (John) 
  * Code refinement for some xCAT plugins. Some of the xCAT plugins are getting hard to maintain, because: 1) the code logic is very complex. 2) the subroutines in the plugins are getting too long. 3) Too many global variables. For example, the DBobjUtils.pm, DBobjectdefs.pm, aixinstall.pm and updatenode.pm. We need to reorg these files, at least split the subroutines into smaller ones and reduce the numbers of global variables.(Guang Cheng, Norm, Yang Song) 
  * xcat discovery option to randomly/sequentially assign node names if switch info is not defined. Also may want to watch syslog for dhcprequests? (Jarrod, Bruce) 
  * TEAL integration with the view monitoring framework (Yang Song) 
  * Support system p live lpar migration in rmigrate cmd. (Director already supports this in VMControl. HMC/phype provides the support.) This is a requirement for system p cloud management and for the IBM events infrastructure. I think this is only needed for HMC environments (i.e. not DFM and not bladecenter). (Er Tao) 
  * Add support for automatically configuring dhcp on xCAT MN and SNs. (Norm) 
  * Add flocks to plugins to prevent multiple cmds running at the same time that can't be 
  * Document at the top of each postscript, usage information and what it does. In the Postscripts/prescripts doc, indicate they should read the postscript file for this information. At least try and get our default ones and servicenode,xcatserver,xcatclient done. 
  * DFM IPv6 support (Jie Hua, Bill) 
  * Have statelite booting nodes download rc.statelite (probably via ftp), instead of having it bundled in the boot image to enable backward compatibility more easily. (Hua Zhong) 
  * When postage builds the list postscripts and postbootscripts to run on the nodes, remove any duplications so they will not run twice. Customers have often not realized that their postscipts table and now the addition of postscripts and postbootscripts in the osimage table result in the postscripts being added to the list mulitiple times. Maybe we could somehow put out a warning also?(Hua Zhong) 
  * Support option to create /install on the node's local disk of service node (using site.installloc, already have postscript make_sn_fs for AIX) (Lissa) 
  * Support long hostname as the xCAT node name, bug https://sourceforge.net/tracker/?func=detail&amp;aid=3323391&amp;group_id=208749&amp;atid=1006945 
  * Validate that bootp broadcast works with several non-authoritative dhcp/bootp servers, only one of which is configured for that node (both linux and aix) (Hua Zhong) 
  * Add audit logging of commands like chtab that do not go through the daemon and XCATBYPASS mode ( Lissa) 
  * New boot kernel using dracut and centos 6. Explore the possiblity of using dracut for initrd create on all Linux distributions, it will make the genimage code logic be consistent for all the Linux distributions, we have seen a number of problems with the xCAT customized ramdisk. For now, dracut is shipped with RHEL6, we are seeing some discussion context of porting dracut to other distributions.(Hua Zhong) 
  * xCAT commands should clean up processes on SN and CN when ctrl-c(bug 2805644 https://sourceforge.net/tracker/?func=detail&amp;aid=2805644&amp;group_id=208749&amp;atid=1006945). Not only updatenode command has this problem, maybe we should come up with a general solution for all xCAT commands. 
  * Finish up support for all documented options in the policy table, or restrict the options. (Lissa)**is Chris working on this?**
  * AIX osimage replication: support imgexport/imgimport for AIX (or just doc manual process to create an osimage on a different MN or SN.&nbsp;?) 
  * System p energy mgmt update, including exploitation of public CIM interface on HV (not supported on IH) (Xiao Peng) 
  * IPv6 support on AIX, black box mode -- Guang Cheng 
  * Complete Ubuntu support - Xu Qing 
    * monitoring 
    * Infiniband support(?) 
    * HPC integration with kits (?) 
    * IPv6 support 
    * High availability 
    * hierachy support 
  * When 2.9 is released, remove pkgs from xcat-dep (that are not needed in 2.8 or above): 
    * fping, yaboot-xcat 
  * support for intel MIC accelerator cards 
  * Modify boot order via rbootseq and IMM and UEFI 
  * LDAP support: configure LDAP, manage LDAP users 
  * Boot over Infiniband 
  * Support rolling updates with LSF 
  * Add to prescripts to use the new semaphore to have a global throttle for each prescript 
  * statelite: con type should include image .default entries.(bug 3176516 https://sourceforge.net/tracker/?func=detail&amp;aid=3176516&amp;group_id=208749&amp;atid=1006945) 
  * support user-provided diskless image update script on AIX, similar to postinstall scripts run by genimage for Linux 
  * Support noderes.servicenode being set to sn01,mn01 
  * Web GUI testing (Cao Li) 
  * xCAT enhancements for the HPC Cloud Suite: OVF image support(Ling, CDL) 
  * Manage IB switches? (create vlans, etc) (Jie Hua) 
  * Application performance monitoring (Torque, LL) (from Egan) 
  * refine lsvm, chvm, rspconfig, etc 
  * Support role definitions. The specific scenario is that users of the xcat web portal interface are regular users, not admins, and need to be able to do a few xcat commands (with specific flags), but shouldn't be allowed to do them all. For these users, we could put many lines in the policy table, but it would be much cleaner to have a separate table called roles in which a role could be named and all the cmds/flags that are allowed for that role. Then the policy table could support that role name in the command column. 
  * Add xCAT support for the new AIX/NIM NAS appliance feature. (The NAS feature will have the capability of hosting file-type resources (such as mksysb, savevg, resolv_conf, bosinst_data, script) and can be used for install purposes without the need to alter any .info files on the spot server.) Required xCAT support TBD. At minimum there would be some documentation updates.(Norm) 
  * Merge OpenSLP 1.2.1 patches into OpenSLP 2.0 
  * monitor framework honor noderange(Bug 2952099 https://sourceforge.net/tracker/?func=detail&amp;aid=2952099&amp;group_id=208749&amp;atid=1006945) 
  * Add additional noderes attributes for where to get the boot kernel and initrd, separate from the tftpserver attribute. (Jarrod) 
  * Provide an easy way to config/start the recommended/default monitoring 
  * Change xcatmon to use nmap instead of fping, build nmap for AIX, &amp; take fping out of the Requires.(Xu Qing) 
  * Automatically set up logrotate of console files on sn &amp; mn (Ling) 
  * Change rmnimimage to remove the xCAT osimage definition by default.(Norm) 
  * Add NIM maint_boot support to nimnodeset command. (Norm) 
  * Add xCAT on AIX support for postscripts (pre-boot customization scripts)(Norm) 
  * Support the follow on to the HMC.(HMC is planning to implement some improvements to support multiple targets/objects in one command invocation for some of the HMC commands, xCAT should be able to leverage the changes to improve the xCAT efficiency for the HMC managed nodes control. I am not sure what time frame these HMC improvements will be available in)(Yin Le) 
  * Add support to nodeset to automatically stage synclist files to service node (if osimage.synclists is set and node has a servicenode). Use xdcp -s. Print status msg if need to sync files because this can take some time if there are many files and this is the first time syncing. 
  * Investigate use of otherpkgs postbootscript default for diskless nodes. Since our best practice is that users should build all software into their diskless images during genimage, there is alot of overhead in every diskless node boot by having otherpkgs as a default postbootscript. 
  * Support new versions of RHEV 
  * Add csmstat-like reporting capability to xcat, see https://sourceforge.net/p/xcat/feature-requests/162/ for more details. 
  * provide xcat command to snapshot a vmware VM, see https://sourceforge.net/p/xcat/feature-requests/160/ for more details. 
  * In addition to the mkdef/chdef -p and -m flags, support the ",=" , "^=", "@=" syntax like nodech does for consistency. See https://sourceforge.net/p/xcat/feature-requests/132/ for more details. 
  * Add support for lxc/openvz, see https://sourceforge.net/p/xcat/feature-requests/158/ for more details. 
  * vmware vm - failed boot recovery toggle. See https://sourceforge.net/p/xcat/feature-requests/155/ fore more details. 
  * Add a rpower option to dump a system p node, just like what the HMC CLI chsysstat -o dumprestart does. See https://sourceforge.net/p/xcat/feature-requests/151/ for more details. 
  * Add a new node attribute lparname for system p nodes. See https://sourceforge.net/p/xcat/feature-requests/149/ for more details. 
  * Add a lock attribute to nodes. When it is set, don't allow any cmds that will change the node (rpower off, nodeset, etc.), or even change its db attributes (except unsetting lock). Query cmds will still be allowed when the node is locked. This has been requested by pcm and by https://sourceforge.net/p/xcat/feature-requests/145/ . 
  * DFM enhancement - get more information about the PCI adapters, like the ports number and speed of the network cards. 
  * Full support for non-default http port.  We have site.httpport attribute, and nodeset uses this for setting /tftpboot and bootparams, but it is not used anywhere else in the xCAT code.  Some places that will need to be addressed:  full-disk install templates, postscripts, and anywhere else we do wget or other httpd access.

## Candidates for xCAT 2.10 or Later

## Someday...
  * Support the configuration that the xCAT node name and the KVM guest name could be different, just like what we did for PowerVM LPARs. See [bug 4544](https://sourceforge.net/p/xcat/bugs/4544/)
  * The code to substitute table attributes in install templates to handle complex attributes such as nicips.ib0, see bug https://sourceforge.net/p/xcat/bugs/4200/
  * Code restrucutre for blade.pm, the blade.pm gets confusing after the Flex support 
  * Simplify the code of xdsh/xdcp 
  * makedhcp and makedns are both confusing. John has been going thru makedhcp and commenting the code, and in 2.9 could restructure it some. It would be good to have someone do that for makedns 
  * system p hw ctrl - there are a lot of perl modules involved, and it is not clear at all how the logic flows thru them all. It could use some restructuring, and some high level info about how all of the parts fit together. 
  * Move node-specific info from /install to /tftpboot (Jarrod) 
  * Do a survey of existing monitoring GUI frontends to determine the best (most common) one to provide a bridge between ELA data and it 
  * Make all MN config info be in the db or generated from info in db. (So that a db backup/restore will put all config info back on the MN.) Or provide an xcatbackup/restore cmd to capture all files (e.g. /include/custom) and the db. 
  * Ability to run replaycons from management node instead of sn (Ling) 
  * Have notification architecture handle hierarchy (Ling or CDL) 
  * Fix Table.pm code on how it handles where-clauses for tables that have regular expressions in them? 
  * Add overall cluster health summary (how many down, up, etc.) into DB 
  * Modify client/svr communication to allow client cmds to prompt user (needed for copycds, xdsh -K, and genimage) 
  * Investigate using MonAMI (http://monami.sourceforge.net/) to abstract different monitoring tools 
  * Support multiple levels of dependencies and hierarchy in dep table (CDL) 
  * Add WOL (perl -MNet::Wake -e "Net::Wake::by_udp(undef,'$MAC')") 
  * Add help (list of cmds) &amp; version cmds to the client/svr protocol for CRI and others 
  * Implement cluster user mgmt for Argonne: Add a local (cluster-only) user, Deactivate a local user, Activate an LDAP user (grant existing LDAP user access to cluster), Deactivate an LDAP user. 
  * IPv6: 
    * Include AIX perl IPv6 routines 
    * IPMI is IPv4 only as of 2.0. Until that specification is revised, service processors implementing IPMI must be managed through IPv4. 
    * IPv6 support in the distributions is there, but in RHEL5 and SLES10, the support could be characterized as interim. RHEL6 and SLES11 would migrate to ISC DHCPD 4, which has built-in IPV6, rather than use a separate daemon for each. 
    * Remove some of the IPv6 restrictions (e.g. hierarchical) 
  * Rolling update plugin support to allow 3rd party schedulers (other than LoadLeveler) to schedule nodes for updates 

#### Jarrod Johnson:

  * Data management process. To limit number of SQL connections concurrently per xcatd instance, improve bug 1875930). This could also host cross-process caches to reduce frequency of requests as well as concurrency). 
  * Virtualization/container assistance/framework (libvirt managed ones and VMWare?) (feature 1905355) 
  * Replace port 3001 on installing nodes/stage with ssh (or somehow otherwise authenticate using private/public key, encryption not a must?). bmcsetup is encrypted in 2.x and in 2.1 forward is authenticated through privileged port usage. 
  * setupxcat if failing to detect sufficient site configuration to act as it usually does, enters an interactive mode to prompt with common defaults for them 
