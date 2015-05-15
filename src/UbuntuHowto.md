<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [List of OSs that work as MN](#list-of-oss-that-work-as-mn)
  - [List of OSs that work as clients](#list-of-oss-that-work-as-clients)
- [Scope](#scope)
  - [KVM host](#kvm-host)
  - [xCAT management node](#xcat-management-node)
  - [Provisioned nodes](#provisioned-nodes)
  - [Recommended minimum disk requirements](#recommended-minimum-disk-requirements)
  - [Ubuntu ISO media](#ubuntu-iso-media)
- [How to read the instructions](#how-to-read-the-instructions)
- [[Instructions] Build xCAT core and dependency ("dep") debian packages](#instructions-build-xcat-core-and-dependency-dep-debian-packages)
- [[Instructions] Setting up xcat-core and xcat-dep repositories](#instructions-setting-up-xcat-core-and-xcat-dep-repositories)
- [[Instructions] Installing an Ubuntu management node](#instructions-installing-an-ubuntu-management-node)
- [[Instructions] Defining and provisioning stateful compute nodes](#instructions-defining-and-provisioning-stateful-compute-nodes)
  - [Notes](#notes)
- [Known bugs](#known-bugs)
  - [Bug List/Known Issues](#bug-listknown-issues)
  - [Stateless provisioning](#stateless-provisioning)
- [Appendix](#appendix)
  - [Console-related bugs](#console-related-bugs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**This doc is deprecated. See [Ubuntu_Quick_Start].**

Ubuntu support has been enhanced. 


## Overview

The Ubuntu support has been enhanced over that described in the [Ubuntu/Debian Notes](DebianHowto). Debian support may have been enhanced as a side effect, but such was not the goal, nor was it tested. 

The enhancements encompass being able to provision KVM client and typical clients stateful and stateless compute nodes with Ubuntu 10.10, RHEL 6.0, and SLES 11 from a KVM client Ubuntu 10.10 xCAT management node. 

### List of OSs that work as MN

The following OSs have been tested to work as MN, At this moment of time debian 7 (wheezy) and ubuntu 12.04 (precise) are unsupported, due to the incompatibility of some of the perl libraries such as Digest::SHA1 

  * rhel5 
  * ubuntu 9.10 
  * ubuntu 10.10 

### List of OSs that work as clients

The following OSs have been tested. Anything that is not listed may still work, but is untested at the moment. 

  * statefull installs of 
    * ubuntu 9.10 
    * ubuntu 10.04 LTS 
    * ubuntu 10.04.1 LTS 
    * ubuntu 10.10 
  * Stateless installs of 
    * Ubuntu 9.10 (with tweaks) 
    * Ubuntu 10.10 
  * copycds 
    * ubuntu 9.10 
    * ubuntu 10.04 LTS 
    * ubuntu 10.04.1 LTS 
    * ubuntu 10.10 
    * debian 5.0.6 
    * debian 5.0.6 NETINST 

## Scope

### KVM host

  * x86_64 KVM host running RHEL 6.0 or Fedora 14 

### xCAT management node

  * Ubuntu xCAT management node in an x86_64 KVM client 

### Provisioned nodes

  * KVM client nodes to be provisioned with the server edition of Ubuntu 10.10 (Maverick Meerkat) for x86_64 (aka amd64) or x86 

### Recommended minimum disk requirements

  * Ubuntu management node: 4G plus size of anticipated ISO's for provisioning 
  * Ubuntu provisioned node: 2G 
  * RHEL 6.0 provisioned node: 3G 
  * SLES 11 provisioned node: 4G 

### Ubuntu ISO media

Maverick Meerkat Ubuntu is available on this page: 

  * http://releases.ubuntu.com/10.10/ 

Specifically, these links on that page: 

  * http://releases.ubuntu.com/10.10/ubuntu-10.10-server-amd64.iso 
  * http://releases.ubuntu.com/10.10/ubuntu-10.10-server-i386.iso 

## How to read the instructions

All instructions follow a format which uses line prefix characters to indicate how to interpret the information that follows them: 
    
    
    ! - self-explanatory action to take
    # - comments on either a command to run or content to add to a file
    &gt; - command to run
    

All other lines are file content. 

## [Instructions] Build xCAT core and dependency ("dep") debian packages

Download/Checkout the xcat-core trunk development branch: 
    
    
    &gt; mkdir /root/devel/xcat-core
    &gt; cd /root/devel/xcat-core
    &gt; svn co http://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk
    &gt; mkdir /root/devel/xcat-dep
    &gt; cd /root/devel/xcat-dep
    &gt; svn co http://xcat.svn.sourceforge.net/svnroot/xcat/xcat-dep/trunk
    

Install ubuntu dependencies 
    
    
    &gt; apt-get install debhelper devscripts quilt libsoap-lite-perl libdigest-sha1-perl libdbi-perl reprepro
    

Run the build-ubunturepo script to create your local repository. The build-ubunturepo incorporates the build of the repo so that all supported OSs get a repository made, at the moment, **maverick**, **natty**, **oneiric** and **precise** are included. More will be included later, it could be that I can easily add etch, and squeeze to the list as well. 

See the usage of the script: 
    
    
    &gt; ./build-ubunturepo
    
    Eg.
    xcat-core source code: /root/devel/xcat-core/trunk
    xcat-dep source code: /root/devel/xcat-dep/trunk
    repository: /root/repo/ubuntu
    
    &gt; ./build-ubunturepo -c /root/devel/xcat-core/trunk -d /root/devel/xcat-dep/trunk -l /root/repo/ubuntu
    

This script will run "build-debs-all", which will build each individual deb packages for all xcat source tools. 

When the script is done, Run the following commands to add the repository to the apt sources 
    
    
    &gt; cd /root/repo/ubuntu/xcat-core
    &gt; ./mklocalrepo.sh
    &gt; cd /root/repo/ubuntu/xcat-dep
    &gt; ./mklocalrepo.sh
    

## [Instructions] Setting up xcat-core and xcat-dep repositories
    
    
    # for each *.deb file built under xcat-core
    &gt; reprepro -b &lt;XCAT-CORE-REPO-TARGET-PATH&gt; includedeb maverick &lt;PACKAGE&gt;.deb
    &gt; cp -f &lt;XCAT-CORE-PACKAGE-SOURCE-PATH&gt;/&lt;PACKAGE&gt;.deb &lt;XCAT-CORE-REPO-TARGET-PATH&gt;/
    
    # for each *.deb file built under xcat-dep
    &gt; reprepro -b &lt;XCAT-DEP-REPO-TARGET-PATH&gt; includedeb maverick &lt;PACKAGE&gt;.deb
    &gt; cp -f &lt;XCAT-DEP-PACKAGE-SOURCE-PATH&gt;/&lt;PACKAGE&gt;.deb &lt;XCAT-DEP-REPO-TARGET-PATH&gt;/
    

NOTE: a reprepro man page (not necessarily definitive): http://mirrorer.alioth.debian.org/reprepro.1.html 

## [Instructions] Installing an Ubuntu management node

**NOTE: All actions are performed on the management node.**
    
    
    ! login to the administrative account (i.e. name specified when you installed Ubuntu)
    
    # create a root login
    &gt; sudo passwd root
    
    ! logout and login as root
    
    # put the following in /etc/apt/sources.list.d/xcat-repo.list
    
    deb TODO-HTTP-URL-TOP/xcat-core/ maverick main
    deb TODO-HTTP-URL-TOP/xcat-dep/ maverick main
    
    # update apt's view of repositories
    &gt; apt-get update
    
    # install xcat (answer yes to all questions)
    &gt; apt-get install xcat
    
    ! logout and login as root so xcat utilities are in root's PATH
    
    # workaround to create /install/postscripts/hostkeys
    &gt; xcatconfig -s
    
    # put the following in /etc/xinetd.d/tftpd
    service tftp
    {
    	protocol        = udp 
    	port            = 69
    	socket_type     = dgram
    	wait            = yes 
    	user            = nobody
    	server          = /usr/sbin/in.tftpd
    	server_args     = /tftpboot
    	disable         = no
    }
    
    # start tftp
    &gt; /etc/init.d/xinetd restart
    
    # configure vsftpd by altering /etc/vsftpd.conf so that, in addition
    # to other things, it contains these lines (search on the keys listed
    # so see if they already exist and their values change, otherwise add
    # the lines)
    anonymous_enable=YES
    anon_root=/install
    
    # restart vsftpd
    &gt; service vsftpd restart
    
    # restart apache
    &gt; /etc/init.d/apache2 restart
    
    # ALL FOLLOWING STEPS ARE OPTIONAL (configuration so the 'rinstall' command works)
    
    # install openssh-server on the management node
    &gt; apt-get install openssh-server
    
    # [management node] give kvm host the management node's public ssh key
    &gt; ssh-copy-id root@KVM_HOST_IP_ADDRESS
    

## [Instructions] Defining and provisioning stateful compute nodes

### Notes

  * Tokens in UPPERCASE are variables to be replaced. Those tokens not explained are considered self-explanatory. 
  * [kvm host] and [management node] indicate where actions should be performed. 
  * The instructions assume a previously created kvm dhcp-less private network and a kvm guest xcat management node in that network. 
  * Opening a VNC graphics console through Virtual Machine Manager is discouraged because of two bugs. "virsh console VM_NAME" should be used instead. See - "APPENDIX: CONSOLE-RELATED BUGS" below for details. Also, "virsh console VM_NAME" is best run in a plain terminal window (as opposed to, say, a gnu screen terminal), and must be run again every time a node is rebooted. 
    
    
    # [management node] remove any existing node definition
    &gt; rmdef NODE_SHORT_HOSTNAME
    
    # [management node] tell xcat root's password
    &gt; chtab key=system passwd.username=root passwd.password=ROOT_PASSWORD
    
    ! [management node] get ubuntu iso to the management node
    
    # [management node] bring the iso under xcat's control
    &gt; copycds PATH_TO_ISO
    
    # [OPTIONAL] [management node] recover ISO disk space (xcat now has its own copy)
    &gt; rm -f PATH_TO_ISO
    
    ! [kvm host] Create a new kvm guest node named NODE_SHORT_HOSTNAME in the previously
    ! created network, whose boot order is network,hd. If the node automatically starts,
    ! force it off. Boot order can be adjusted through a Virtual Machine Manager console
    ! to the new node via View-&gt;Details-&gt;Boot Options  -OR- (preferred) via
    ! "virsh edit NODE_SHORT_HOSTNAME", and being sure the &lt;os&gt;&lt;/os&gt; stanza contains
    ! boot devices ordered as follows:
    !
    ! &lt;boot dev='network'/&gt;
    ! &lt;boot dev='hd'/&gt;
    
    ! [kvm host] discover the new node's NODE_NETWORK_INTERFACE_MAC_ADDRESS
    ! (examine output of "virsh dumpxml NODE_SHORT_HOSTNAME | grep "mac address"")
    
    ! [kvm host] discover the new node's MEMORY
    ! (examine output of "virsh dumpxml NODE_SHORT_HOSTNAME | grep "currentMemory"")
    ! (value should be in megabytes.. e.g. if the above shows '524288', use '512' for MEMORY)
    
    ! [kvm host] discover the new node's VM_CPUS
    ! (examine output of "virsh dumpxml NODE_SHORT_HOSTNAME | grep "vcpu"")
    
    ! [kvm host] discover the BRIDGE_NIC_ASSOCIATED_WITH_PRIVATE_NETWORK
    ! (examine output of "virsh net-dumpxml NETWORK_NAME | grep "bridge name"")
    ! (name will look like 'virbr*')
    
    # [management node] define the node to xcat
    # DISTRO is the name of a distro subdirectory under /install
    # ARCH is the name of a architecture subdirectory under /install/DISTRO
    # NODE_IP_ADDRESS is the next available ip address after the management node's
    #   (i.e. if management node's is 192.168.200.2, then choose 192.168.200.3)
    
    nodeadd NODE_SHORT_HOSTNAME groups=all,system hosts.ip=NODE_IP_ADDRESS mac.mac=NODE_NETWORK_INTERFACE_MAC_ADDRESS nodehm.mgt=kvm nodehm.power=kvm nodehm.serialport=0 nodehm.serialspeed=115200 noderes.netboot=pxe noderes.tftpserver=MANAGEMENT_NODE_IP_ADDRESS noderes.nfsserver=MANAGEMENT_NODE_IP_ADDRESS noderes.monserver=MANAGEMENT_NODE_IP_ADDRESS noderes.installnic=eth0 noderes.primarynic=eth0 noderes.discoverynics=eth0 noderes.xcatmaster=MANAGEMENT_NODE_IP_ADDRESS nodetype.os=DISTRO nodetype.arch=ARCH nodetype.profile=compute nodetype.provmethod=install nodetype.nodetype=vm vm.cpus=VM_CPUS vm.host=KVM_HOST_IP_ADDRESS vm.memory=MEMORY vm.nics=BRIDGE_NIC_ASSOCIATED_WITH_PRIVATE_NETWORK vm.storage=/var/lib/libvirt/images
    
    # [management node] update /etc/hosts from xcat's view of nodes
    &gt; makehosts
    
    # [management node] update dhcp with xcat's view of nodes
    &gt; makedhcp -n
    
    # [management node] restart dhcp
    &gt; /etc/init.d/dhcp3-server restart
    
    # [management node] prepare xcat to provivision the node
    nodeset NODE_SHORT_HOSTNAME install
    
    ! [kvm host] force the provisionable node off, close any graphical console session
    ! to it (see: "APPENDIX: CONSOLE-RELATED BUGS" for why)
    
    # [kvm host] start the provisionable node
    &gt; virsh start NODE_SHORT_HOSTNAME
    
    # The above should lead to the provisionable node getting its ip address from the
    # management node via dhcp, and being provisioned.
    
    # [OPTIONAL] [kvm host] watch provisioning progress (NOTE: see
    # "APPENDIX: CONSOLE-RELATED BUGS" below for details)
    &gt; virsh console NODE_SHORT_HOSTNAME
    
    # ALL FOLLOWING STEPS ARE OPTIONAL
    
    # After the initial provisioning, one can reprovision with the xcat rinstall command
    
    # [management node] rinstall the provisionable node
    &gt; rinstall NODE_SHORT_HOSTNAME
    
    # [kvm host] watch provisioning progress (NOTE: see
    # "APPENDIX: CONSOLE-RELATED BUGS" below for details)
    &gt; virsh console NODE_SHORT_HOSTNAME
    

## Known bugs

### Bug List/Known Issues

  * Package signing for a release 
  * rpower fails during on|boot|reset on Ubuntu Server 10.10 (KVM guest on rhel6) 
  * soft failure: copycds ubuntu-10.10-server-amd64.iso 
  * Console switch during rinstall operation 
  * Passwordless SSH 
  * VNC password set after CN deploy (using Ubuntu Server image) 
  * rscan doesn't work for kvm nodes 
  * xCAT-UI does not allow login 
  * makedns failing (**add bind user for ubuntu specific, submitted for review**)(11/06/2012) 
  * 'rbootseq' is not supported when ivm is the HCP 
  * xcat "makedns" command broke for ubuntu (**add bind user for ubuntu specific, submitted for review**) 
  * /etc/resolv.conf is overwritten on managed nodes whose IP is configured by DHCP ** Just make sure that the interfaces are not dhcp **
  * Moving mypostscript.post from /tmp to /var/tmp for other distros (**This has already been implemented xCAT team**) 
  * PostScript support for ubuntu 
    * xcatserver 
    * xcatdsklspost 
    * setbootfromdisk 
    * setbootfromnet 
    * setupscratch postscript 
    * otherpkgs 
    * syslog 
  * service.tmpl not defined 
  * /install not visible through apache after xcat install 
  * makeknownhosts.pm doesn't support Ubuntu's known_hosts file format 
  * packaging of 
    * nbroot 
    * nbkernel 
    * yaboot-xcat 
  * Add support for stateless 
    * Old Method 
      * This has now, on some part, been implemented; this now requires extensive testing 
      * This is not supported for maverick, but has been tested on natty as a client. 
    * Dracut method 
      * This is not supported in ubuntu be default, as dracut deb is not available by default 
      * Provision for this although has been made 
      * may require dracut to be part of the xcat-dep package. 
  * Add support for statelite 
  * Testing in several VM architecture 
    * KVM (as per this HowTo 
    * Virtual Box 
    * Xen 
    * VMware 
  * debootstrap in el5 will not work with lucid (10.04 and 10.04.1), but works on el6 

### Stateless provisioning

The stateless provisioning has changed significantly to when first started. The initial genimage that was posted was a copy of the genimaged from the redhat folders, and not much was added. The current release as of Apr 30 in trunk, we have a new genimage that will work which requires busybox-static in ubuntu 10.10 

  * Run copycds &lt;iso image&gt;
  * genimage -o ubuntu10.10 -p compute -i eth0 -n e1000,pcnet32 
  * packimage -p compute -a x86_64 -o ubuntu10.10 
    * Make sure that the MAC address is in the table, and is able to grab the relevant dhcp information of the server 
  * nodech NODE_SHORT_HOSTNAME nodetype.os=ubuntu10.10 nodetype.provmethod=netboot 
  * Reboot the client. 

## Appendix

### Console-related bugs

Both "nodeset" and "rinstall" result in a PXE boot configuration file (per node) which specifies "console=" more than once in the kernel parameters list. This somehow hangs the display of the kernel boot when viewed in a VNC graphics console opened through Virtual Machine Manager. Therefore, one should avoid using that kind of console, and instead watch provisioning progress via the following on the KVM host: 
    
    
    &gt; virsh console VM_NAME
    

(exit the console via Ctrl-]) 

The VNC graphics console can be used as usual after provisioning is complete. 

HOWEVER, an xcat bug sets an encrypted, unknown password on the VNC session. In order to view the VNC graphics console, perform just ONE of the following: 

  * Method 1 
    * virsh edit VM_NAME 
    * find the xml the line beginning with "&lt;graphics type='vnc'" 
    * change the VALUE of passwd='VALUE' on that line 
    * exit normally 
  * Method 2 
    * enter the VNC console for VM_NAME 
    * when prompted for a password (with a "Login" button), go into: View-&gt;Details-&gt;Display VNC-&gt;CHANGE PASSWORD FIELD-&gt;click Apply 
    * ignore the popup about the value possibly not taking effect unto reboot 
    * View-&gt;Console 

THEN enter the password you've supplied, and click the "Login" button 
