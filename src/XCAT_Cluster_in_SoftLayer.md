<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT in SoftLayer](#xcat-in-softlayer)
  - [Use SoftLayer's Bare Metal OS Provisioning](#use-softlayers-bare-metal-os-provisioning)
  - [Have xCAT Provision the OS](#have-xcat-provision-the-os)
  - [Use xCAT to Provision the OS via the Out-of-Band Network](#use-xcat-to-provision-the-os-via-the-out-of-band-network)
- [Hybrid xCAT SoftLayer Cluster](#hybrid-xcat-softlayer-cluster)
- [Staging](#staging)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

The purpose of this feature is to support xCAT clusters with a SoftLayer cloud. This request is from GTS to provide opensource HPC Cloud offerings to their customers. 

Here are the aspects of the propsal: 

  * Support an xCAT cluster totally resident in a SoftLayer Cloud 
  * Cluster system management will be predominantly driven from the xCAT management node. There may be certain functions that will require direct interaction with the SoftLayer portal. These should be limited as much as possible. 
  * customer uses SoftLayer portal to request nodes, and then xcat discovers/manages those nodes as part of the cluster 
  * consider baremetal nodes 
  * consider virtual machines 
  * xcat uses the SoftLayer APIs to request nodes and automatically adds them to the xCAT cluster 
  * Support a hybrid cluster comprised of an existing customer's on-premise xCAT cluster being extended with nodes from a SoftLayer Cloud 

## xCAT in SoftLayer

The customer uses the SoftLayer portal to request the nodes and other elements of the cloud. 

The customer installs the xCAT management node software on one of those nodes 

A [new xCAT script](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-SoftLayer/bin/getslnodes) calls the SL API to query the information for all the bare metal nodes in that softlayer account, and produces a stanza file that can be piped into mkdef -z. 

     The key attributes this script gets are: ipmi.bmc, ipmi.password, ipmi.username, mac.mac,hosts.ip, and the hostname and root pw (which it puts in nodelist.comment) 

An OS image is deployed to those nodes with the required HPC software stack. Additional software can be installed as needed. This assumes full-disk install on the nodes. We do not see a requirement for diskless node support at this time. 

The end user documentation for using xCAT on SoftLayer is: [Using_xCAT_in_SoftLayer] 

How do we do OS deployment? There are several options discussed in the following sections. 

### Use SoftLayer's Bare Metal OS Provisioning

Through the softlayer portal, you can request that it put one of the following OSes on the nodes: centos/rhel, debian/ubuntu, freebsd, windows. If one of these is that OS you want, you can have SL do that and then just have xCAT manage OS upgrades, additional rpms, and HPC software through updatenode (ospkgs, otherpkgs). The drawback is that this can take SL 2 to 4 hours to complete provision the OS. 

### Have xCAT Provision the OS

If the OS you need is not in the list above (e.g. SLES), then you need xCAT to do the bare metal provisioning of the OS. Using pxe and dhcp is problematic, because the nodes can often be on different vlans, and the delay when bringing nics up will cause it to time out even on the same vlan (see next point). 

SoftLayer has a pretty sophisticated private network that allows them to on-demand configure private vlans that only a single tenant can communicate on. But one of the side effects of this is that when a bare metal svr's nics is brought up on one of the private vlans, it takes about 60 seconds before that nic can successfully send an ip packet. This is much longer than any of the default timeouts used in the network installation process, so we have to insert waits in key points during the process in order for it to succeed. Several things are needed: 

  * instead of pxe booting the node, we take advantage of the fact that SL always puts on OS image on the node (even if it isn't the version we want). So we use a new command called [pushinitrd](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-SoftLayer/bin/pushinitrd) to copy the initrd, kernel, and kernel params to grub on all of the nodes. (This script uses [modifygrub](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-SoftLayer/bin/modifygrub) under the covers.) 
  * to avoid additional dhcp requests, we also use a static ip for the node: 
    * the pushinitrd script above sets the ip/submask/gateway/hostname/dns info as kernel parameters 
    * for scripted install, we provide a new [compute.sles11.softlayer.tmpl](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-SoftLayer/share/xcat/install/sles/compute.sles11.softlayer.tmpl) file that sets the dns info and static nic ip info 
    * for sysclone, genesis is changed to use static ip if appropriate kernel parms are set, and we make sure systemimage (SI) doesn't try to use dhcp or restart the network in the genesis initrd by setting kernel parms like IPADDR, NETMASK, etc. 
  * to deal with delay when the nic is brought up: 
    * for scripted install: 
      * in place of post.sles and post.sles.common, we provide [post.sles.softlayer.common](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-SoftLayer/share/xcat/install/scripts/post.sles.softlayer.common) which avoids (what i think is) an unnecessary reboot and skips some dhcp config 
      * pushinitrd hacks the autoinst file (after nodeset has built it) to insert code that will hack the /etc/init.d/network script on the node so that it will not return until it is able to ping successfully on the install nic to the mn. (There are files/dirs specifically for doing things when the nics are brought up (in sles /etc/sysconfig/network/if-up.d/, in rhel /sbin/ifup-local), but these aren't run by autoyast right after the reboot when it is doing its configuration.) 
      * in the real OS, the nics are always configured in a bond (one for the private network and one for the public network) so that when the system is booted for real (after the autoyast config stage), the nics come up quickly. (This is what SL does when they install an os.) 
    * for sysclone install: 
      * after configuring the install nic with a static ip, genesis pings the mn until it can reach it. 
      * in the real OS, the nics are always configured in a bond (one for the private network and one for the public network) so that when the system is booted for real (after the autoyast config stage), the nics come up quickly. (This is what SL does when they install an os.) 

The main changes/additions needed to support centos/rhel (in addition to the current sles support) are: 

  * for scripted install: 
    * tmpl file: use static ip info instead of dhcp, and set route for private network. See my compute.sles11.softlayer.tmp as an example. 
    * pushinitrd: insert /etc/init.d/network wait hack in different place in autoinst file 
    * modifygrub: change the kernel parameter names to be what kickstart needs to use static ip in its initrd 
  * for sysclone: 
    * 15all.configefi: add code to modify grub the redhat way 
    * 16all.updatenetwork: this has the code for redhat, but needs to be tested 
    * 20all.mkinitrd_for_suse: change the name to more generic and add support for dracut 

### Use xCAT to Provision the OS via the Out-of-Band Network

Investigate whether SuperMicro hardware has support to load the initrd over the out-of-band hdwctrl network, similar to what flexcat does for fsm. SuperMicro's BMC web interface does have an option for remote usb or cd, so this looks promising. (You get to it through the bmc web interface, Remote Contronl, Console Redirection, when the console window comes up, choose the Virtural Media-&gt;Virtual Storage menu.) 

## Hybrid xCAT SoftLayer Cluster

There are many issues with trying to directly extend a customer's local cluster with additional nodes from a SoftLayer cloud. The largest issue is networking. The SL nodes will be on external networks not directly connected to the xCAT management node. 

One thought was to investigate installing a service node in the SL cloud extension to manage those nodes, but the SN would need remote data base access to the xCAT management node, and that most likely will not have adequate performance across a remote network. 

Another consideration is to introduce a new concept of xCAT "remote nodes": 

     \- the customer has an existing xCAT cluster running in their local on-premise environment 
     \- the customer sets up another xCAT cluster in SoftLayer with its own management node as described above 
     \- the customer also adds those SL nodes to the local xCAT management node as "remote nodes", whose service node is defined as the remote SL management node (with a new "remote server" attr set) 
     \- when commands are run on the local MN, they can be run for a mix of local and remote nodes. The "pre-process" function will need to check the new "remote server" attr and not set the "pre-processed" flag in the request. The request will then be sent to the xcatd on the remote server, and processed there, returning data back to the local xcatd. 

     NOTE: This will take more internal design to work through. Concerns of SSL keys, credentials, etc., properly handling the requests in the xcatd daemons, making sure data gets sent back correctly, timeouts on the remote requests, etc. 

## Staging

We should address this work in several stages (each stage building on the previous): 

1\. minimal proof-of concept 

     \- understand SoftLayer, learn how to use SL portal, request machines, experiment with SL API 
     \- manually step through the process of "first implementation" below 

2\. first implementation with limitations and restrictions 

     some possible restrictions may include: 

     \- customer requests all cluster nodes through SoftLayer portal, and uses SL to provision the initial OS. 
     \- xCAT will use SL API to query hardware assigned to customer, add nodes to xCAT database, and apply required HPC software through updatenode 
     \- Customer/GTS provides all opensource HPC software rpms, customization scripts and other setup for applications. 
     \- assumes that xCAT will require minimal additional development work to configure the application networks (if not already done as part of SL OS provisioning) 
     \- since SL is provisioning the base OS, both baremetal and VM nodes should look the same to xCAT for updatenode 
     \- no xCAT service nodes for hierarchy 

3\. second implementation 

     same restrictions as above, except that now: 

     \- xCAT interacts with SL APIs to request the machines 
     \- SL will provision a specific base OS as requested by xCAT 
     \- xCAT will scp a kernel initrd into that SL OS to boot the customer requested OS managed by xCAT (this allows provisioning OS's not available through SL) 

4\. third implementation (not sure if this will be possible) 

     performance enhancements: 

     \- xCAT does not rely on SL OS provisioning, will require investigation into possible ways to do this as out-of-band 

5\. hybrid solution for remote node support 

    

     \- requires architectural changes to xCAT cluster support 

## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Guang Cheng Li 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
