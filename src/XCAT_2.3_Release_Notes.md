<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2.3 Release Notes](#xcat-23-release-notes)
  - [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
  - [Limitations and Known Issues](#limitations-and-known-issues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# xCAT 2.3 Release Notes

## New Function and Changes in Behavior

  * Support for OS updates: SLES 10 SP3, RHEL 5.4, AIX 5.3.11, AIX 6.1.4 
  * x86 configurations may now try to netboot using 'xNBA', a slightly modified, branded form of gPXE, as well as including a newer version of pxelinux.0 when applicable. This is an experimental feature and is not guaranteed to work in all environments. Choose it by setting noderes.netboot to "xnba". This acheives: 
    * linux kernels and initrds are now transferred using http without pxelinux used (allowing better scaling, significant reduction of likelihood of firmware hangs) 
    * For Linux, Xen, and VMWare stateless images, no extraneous file transfers are requested (i.e. not searching hex-named config files for the 'correct' one, reducing provisioning IO load due to misses and extraneous logging). 
    * For most cases, 'sharedtftp' will be allowed for dynamic service node architectures, improving nodeset time for most environments. PPC and Xen infrastructures may still require discrete tftp space per dynamic service node. 
    * x86 boot configuration files have moved from $tftpdir/pxelinux.cfg to $tftpdir/xcat/xnba/ 
  * Support of FQDN style (long) node names in addition to short names. 
  * Improved DB utilization: 
    * One DB handle per master/service node 
    * Caching of DB data, including noderanges 
  * Pluggable pre-provisioning architecture (prescripts) to allow customized actions to occur before a managed node is reset to fulfill a provisioning action. 
  * osimage support: Default os image definitions are stored in the osimage, linuximage and nimimage tables for provisioning. User can customize the image definitions such as os distro location, diskless image root location, pkglist file location etc. to fit their needs. Then pass the image name to nodeset, genimage or packimage commands. 
  * otherpkgs.pkglist supports subdirectory, file inclusion and '-' for package removal for Linux. 
  * Support for stateful ESX and stateless ESXi hypervisors, as well as management of guests (migration requires vCenter server). 
  * Dynamic groups for noderange expansion (groups based on table values rather than nodelist static listing) 
  * Improve large-scale performance of perl and php implementations of client/server protocol used amongst service nodes, masters, and clients 
  * Table match criteria in noderange, i.e. 'rpower nodetype.os==rhels5.3@rack1 stat' 
  * Noderange performance enhancements 
  * Default value of useSSHonAIX is now "yes". I.e. xCAT will automatically set up and use ssh on AIX clusters, unless you set useSSHonAIX to "no". 
  * xdcp enhancements: 
    * File synchronization support using rsync added to xdcp and the updatenode commands. 
    * Hierarchical supported added to xdcp. 
    * xdcp to update an install image on the Management Node. 
  * ppping enhancements: 
    * Support hierarchy 
    * Support a list of interface names to ping 
  * Automatic deployment retry - monitor if rpower/rnetboot boot succeeded in bringing the node up and redo if necessary. 
  * Setting and querying power levels for system p6 servers. 
  * Ability to reassign system p CECs &amp; BPAs to a different HMC. 
  * Ability to set the frame # in a system p BPA 
  * Improved AIX diskless support - much better performance and scalability 
  * makehosts command now supports additional NICs for each node 
  * Scalability enhancements to rpower, rnetboot, and getmacs on system p 
  * Cluster performance monitoring solution that uses a combination of rmc, rrdtool, and xcat. 
  * Better hierarchy cookbook 
  * New xCAT commands 
    * cfm2xcat - Migrates CFM setup in CSM to the xdcp -F setup in xCAT for file synchronization. 
    * groupfiles4dsh - Helps users with scripts written using AIX dsh 
    * renergy - Remote energy management tool 
    * mkhwconn - Setup connections for FSP and BPA nodes to HMC nodes. 
    * lshwconn - Display the connection status for FSP and BPA nodes. 
    * rmhwconn - Remove connections from FSP and BPA nodes to HMC nodes. 
    * makeknownhosts - build a valid known_hosts file from the xCAT database 
    * nodegrpch - Change parameters explicitly at a static group level rather than a per-node level 

## Limitations and Known Issues

  * When updating system p firmware in parallel within the same release for multiple System p CECs working with HMC release 350(7.3.5.0), rflash may encounter unknown errors for some CECs. For example, HMC version is 7.3.5.0, update system firmware from 340(or earlier) to a Service Pack, rflash may encounter unknown errors for some CECs. This problem will be fixed in HMC V7R3.5.0 Service Pack 1. Until then, a work around is to update one CEC in one rflash invocation or to use HMC GUI or updlic command to update firmware. We noticed that putting the systems in standby or Operating state will reduce the failure possibility. 
  * Energy Management: If your CEC is managed by HMC and the version of HMC is V7R3.5.0, following fix is needed to support the renergy command: MH01197_1027. 
  * AIX61 on JS blade: If you want to use the AIX61 as the Operating System of xCAT management node, following APAR/PTF are recommended to be installed. If you do NOT install these PTF, the broadcast bootp process of node maybe fails. A workaround for this is to set the Client/Server/Gateway IP in the SMS manually for the node to make bootp uses unitcast. 
    
    AIX61H (6.1.4)  APAR IZ61826   PTF U827803
    AIX61F (6.1.3)   APAR IZ63256   PTF  U828739
    AIX61D (6.1.2)  APAR IZ63442   PTF  U828853
    
