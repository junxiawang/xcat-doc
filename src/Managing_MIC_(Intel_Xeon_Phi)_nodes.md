<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Build Kit for MPSS](#build-kit-for-mpss)
  - [The Procedure to Build mpss Kit (Run on xCAT Management Node):](#the-procedure-to-build-mpss-kit-run-on-xcat-management-node)
- [Configure Host Node](#configure-host-node)
  - [Install mpss kit on your Host Node](#install-mpss-kit-on-your-host-node)
  - [Update the mpss kit](#update-the-mpss-kit)
  - [Configure Virtual Network Bridge](#configure-virtual-network-bridge)
- [Discover and Define the Mic Node](#discover-and-define-the-mic-node)
  - [Discover MIC Node](#discover-mic-node)
  - [Configure MIC Node](#configure-mic-node)
  - [Set IP for Mic Node](#set-ip-for-mic-node)
  - [Set Bridge for Mic Node](#set-bridge-for-mic-node)
  - [Set Power Management for Mic Node](#set-power-management-for-mic-node)
- [Prepare the Osimage for Mic Node](#prepare-the-osimage-for-mic-node)
  - [Create Osimage Definition](#create-osimage-definition)
  - [Install HPC Software into the Osimage](#install-hpc-software-into-the-osimage)
    - [**Three Formats to Customize Osimage**](#three-formats-to-customize-osimage)
    - [**Directory Tree in Osimage**](#directory-tree-in-osimage)
    - [**Install HPC Software**](#install-hpc-software)
    - [**Add Additional Libraries**](#add-additional-libraries)
    - [**Add a Start Script**](#add-a-start-script)
  - [Generate the Osimage](#generate-the-osimage)
  - [Configure NFS Mount for MIC Node](#configure-nfs-mount-for-mic-node)
  - [Service Node Consideration](#service-node-consideration)
- [Create Ramfs for Mic Node](#create-ramfs-for-mic-node)
- [Hardware Control for Mic Node](#hardware-control-for-mic-node)
- [FAQ](#faq)
  - [The Debug Hints](#the-debug-hints)
  - [The MIC Card Cannot be Enabled or Used](#the-mic-card-cannot-be-enabled-or-used)
  - [Reboot host node to solve any strange issue that MIC Card Cannot be Used](#reboot-host-node-to-solve-any-strange-issue-that-mic-card-cannot-be-used)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview

Xeon Phi is an Intel Coprocessor which is designed with Intel Many Integrated Core (MIC) Architecture. Xeon Phi coprocessor is shipped as a PCIe card which can be installed on Xeon server. Each Xeon server could install one or more (8 or more) Xeon Phi PCIe cards, the Xeon Phi Coprocessor is depending on Xeon Server to function and all the management work for Xeon Phi coprocessor need to be done through the Xeon server. The relationship between 'Xeon Phi coprocessor' and 'Xeon Server' is similar with the relationship between 'Virtual Machine Guest' and 'Hypervisor' in the virtualization industry . In this document, the 'Xeon Server' which has 'Xeon Phi Coprocessor' installed is called 'host node' for 'Xeon Phi Coprocessor' since it's a host of 'Xeon Phi' card. 'Xeon Phi Coprocessor' is called 'mic node' because of its arch is 'Intel Many Integrated Core (MIC) Architecture'.

This document describes how to use xCAT to manage hardware discovery, hardware control and software installation for mic host and mic nodes in a cluster. 'mic node' can run in offload and native mode, this document only focus on the management for native mode that manage each mic card as a 'mic node'.

xCAT supports the 'host node' to be stateful and stateless. The steps which are specific for stateful and stateless will be described separated with the marks **[stateful]** and **[stateless]**.

This document will be organized that follows the procedure that how cluster administrator manages a 'Xeon Phi' cluster. Following is the usual management procedure for Xeon Phi cluster:

  * Build mpss kit for 'MPSS' rpm packages
  * **[stateful]** Install 'MPSS' on 'host node'
  * **[stateless]** Install 'MPSS' in statelss osimage for 'host node'
  * Configure 'virtual bridge' on 'host node'
  * Discover the 'mic node' from 'host node'
  * Define 'mic node' in xCAT database
  * Configure 'mic node'
  * Prepare ramfs image for the 'mic node'
  * Install software (HPC products) into ramfs
  * Boot 'mic node' with corresponding ramfs
  * Use xCAT management tools 'rpower', 'rinv', 'rvitals', 'rscan', 'rflash' to manage the 'mic node'

The example environment will be used in this document:

    **Host Node**:                        michost1
    **MIC Nodes**:                        michost1-mic0, michost1-mic1
    **MPSS Package**:                     mpss-3.1-rhel-6.2.tar
    **kit name for MPSS**:                mpss
    **Partial kit package for MPSS**:     mpss-3.1-0.1.1-x86_64.NEED_PRODUCT_PKGS.tar.bz2
    **MIC osimage Name**:                 mpss3.1
    **Host osimage Name**:                **[stateful]** rhels6.2-x86_64-install-compute/**[stateless]** rhels6.2-x86_64-netboot-compute
    **Virtual Bridge Name on Host Node**: xbr0 (External Bridge)/ micbr0 (Internal Bridge)
    **Network for mic node**              192.168.0.1/24
    **IP of Bridge**                      192.168.0.254
    **IP of mic nodes**                   192.168.0.1 (michost1-mic0); 192.168.0.2 (michost1-mic1)


Note: The Xeon Phi support is available in xCAT 2.8.2 and higher release. In xCAT 2.8.2 release, only MPSS 2.x is supported. In xCAT 2.8.3 and higher release, only MPSS 3.1 and higher version is supported.




## Build Kit for MPSS

The Many Integrated Core (MIC) Platform Software Stack (MPSS) is a collection of software that is used to support all the functionalities of mic nodes. Without MPSS installed on 'host node', 'mic node' cannot be function.

xCAT offers a kit package named 'mpss' to manage the install/update of MPSS rpms. Since MPSS rpms include binaries and drivers for specific kernel version, xCAT offers a 'Partial kit' that user could build complete kit from the 'partial kit' + 'MPSS rpms'.

### The Procedure to Build mpss Kit (Run on xCAT Management Node):

  * Create a temporary directory '/kit' to build mpss kit package

~~~~
    mkdir -p /kit/
    cd /kit/
~~~~


  * Download the mpss partial kit 'mpss-3.1-0.1.1-x86_64.NEED_PRODUCT_PKGS.tar.bz2' to /kit/

    Get in the web site [kit for mpss](https://sourceforge.net/projects/xcat/files/kits/mpss%20for%20Xeon%20Phi/) and download the up to date partial mpss kit.


  * Download the MPSS tar file which shipped by Intel to /kit/ (e.g. the MPSS tar file name is mpss-3.1-rhel-6.2.tar)

    Get in the download path [MPSS for Xeon Phi](http://software.intel.com/en-us/articles/intel-manycore-platform-software-stack-mpss), and select the MPSS package base on the version of Operating System for your 'host node'.


  * Extract the files from MPSS tar file

~~~~
    tar xvf mpss-3.1-rhel-6.2.tar
~~~~


Then you can see a new created directory like 'mpss-3.1' which contains all the MPSS rpm packages. In the /kit/mpss-3.1/, you can see lots of rpms named mpss*.rpm.

  * Build the mpss kit

Build complete kit from partial kit

~~~~
    buildkit addpkgs mpss-3.1-0.1.1-x86_64.NEED_PRODUCT_PKGS.tar.bz2 --pkgdir /kit/mpss-3.1
~~~~


After a successful building, you can see a created complete kit package in /kit/: mpss-3.1-0.1.1-x86_64.tar.bz2

  * Add the mpss kit to your management node

~~~~
    addkit mpss-3.1-0.1.1-x86_64.tar.bz2
~~~~


Then you can run 'lsdef -t kit' and 'lsdef -t kitcomponent' to display the added kit and kit component. In this example, the kit 'mpss-3.1-0.1.1-x86_64' and kit component 'mpss_compute-3.1-0.1.1-rhels-6-x86_64' will be displayed.




## Configure Host Node

Xeon Phi cards are installed on 'host node' and all the management operations are performed on 'host node', therefore the 'host node' needs to be installed and configured before performing any management against the 'mic node'. The Operating System for 'host node' should be a latest RedHat Enterprise Server or SUSE Linux Enterprise Server.

Note: currently, only Redhat Linux is supported for 'host node'.

This document assumes:

  * You are familiar with the os deployment for 'host node' (System x server).
  * The definition for 'host node' has been created correctly.
  * The network connections for 'host node' has been done correctly.
  * You can run os deployment (stateful and stateless) for 'host node' successfully.

### Install mpss kit on your Host Node

**[stateful]** Add the mpss kit component to the osimage of your 'host node'

~~~~
    addkitcomp -a -i rhels6.2-x86_64-install-compute mpss_compute-3.1-0.1.1-rhels-6-x86_64
~~~~


Then the mpss rpms will be installed to your 'host node' during os deployment. Or you could run 'updatenode &lt;host node&gt;' to install mpss rpms for an OS ready 'host node'.

**[stateless]** Add the mpss kit component to the osimage of your 'host node'

~~~~
    addkitcomp -a -i rhels6.2-x86_64-netboot-compute mpss_compute-3.1-0.1.1-rhels-6-x86_64
~~~~


Since configuring mic needs 'perl' pakcage to run on 'host node', you have to add 'perl' to the .pkglist for host node osimage.

    Add 'perl' package to .pkglist of host node osimage


Then you need run 'genimage' command to install mpss rpms into the root image for stateless 'host node'

~~~~
    genimage rhels6.2-x86_64-netboot-compute
~~~~


### Update the mpss kit

Repeat the steps in [Build Kit for MPSS](Managing_MIC_(Intel_Xeon_Phi)_nodes/#build-kit-for-mpss) to build the new version of mpss kit. And repeat the step in [Install mpss kit on your Host Node](Managing_MIC_(Intel_Xeon_Phi)_nodes/#install-mpss-kit-on-your-host-node) to update the MPSS rpms on 'host node'.

In each install or update of mpss by kit, the mpss rpm packages which have been installed will be removed first and then install the new rpms.

If you see the error message like following during install/update, try to reboot host node after install/update to make the new mic driver takes effect. Or you can try to reboot the host node before installing/updating.

    Removing MIC Module: FATAL: Module mic is in use.


### Configure Virtual Network Bridge

The virtual network bridge needs to be created on the 'host node' to enable the 'mic node' communication with other 'mic node', 'host node' and even beyond the 'host' in the cluster.

xCAT supports two types of Bridge on 'host node':

    **External Bridge** \- the bridge needs be bound to a physical Ethernet interface. 'mic node' can use it to communicate outside of 'host node'.
    **Internal Bridge** \- this is an internal bridge for a specific 'host node'. That means the 'mic nodes' only can communicate inside 'host node'. If you want the 'mic node' gets outside of 'host node', a router needs be configured.

  * Configure **External Bridge**

An xCAT postscript 'xHRM' can be used to create virtual bridge on the 'host node' when install/update a 'host node'.

~~~~
    chdef michost1 -p postscripts='xHRM bridgeprereq xbr0'
~~~~


Usage of bridgeprereq option for 'xHRM' postscript

    xHRM bridgeprereq xbr0 - Create a bridge named xbr0 which is attached to the primary interface that used for the 'host node' installing.
    xHRM bridgeprereq eth0:xbr0 - Create a bridge name xbr0 which is attached to the 'eth0' interface on 'host node'.
    xHRM bridgeprereq eth0:xbr0 192.168.0.254 - Create a bridge name xbr0 which is attached to the 'eth0' and assign static IP '192.168.0.254' for the bridge.


You can run updatenode command to create a new bridge in anytime

~~~~
    updatenode michost1
~~~~


  * Configure **Internal Bridge**

The Internal Bridge will be created automatically when you run 'nodeset' against a 'mic node'. But you need assign an IP and bridge type in 'host node' definition first.

Set the IP and Bridge type for Internal Bridge 'micbr0'

~~~~
    chdef michost1 nicips.micbr0=192.168.0.254 nictypes.micbr0=Internal
~~~~





## Discover and Define the Mic Node

### Discover MIC Node

Each Xeon Phi card is defined as an xCAT general node which can be managed individually. **rscan** command can be used to discover the mic node and define them into xCAT database. The default name of mic node will be &lt;host name&gt;-micX, 'X' is the device number of the mic which started from 0 to n.

~~~~
    # rscan michost1
    type    name              id      host
    mic     michost1-mic0     0       michost1
    mic     michost1-mic1     1       michost1
~~~~


  * The major attributes of mic are stored in xCAT **mic** table.
  * You can use 'rscan michost1 -w' to write the discovered mic nodes to xCAT database directly.
  * You can also use 'rscan michost1 -z' to display the discovered mic nodes with stanza format and redirect it to a stanza file, then change the stanza file and use 'mkdef -z' command to define them to xCAT database.

~~~~
    rscan michost1 -z > /tmp/micstanza
    cat /tmp/micstanza | mkdef -z
~~~~


### Configure MIC Node

Except the auto discovered attributes, there are other several attributes need to be set to configure the mic node.

     ip - Set the IP of the mic node so that it could communicate with other mic node.
     micbridge - The bridge which created on host node to offer communication channel for mic node.
     miconboot (Optional) - Set whether auto boot of the mic node when host node boot up. Default is 'yes'.
     micvlog (Optional) - Set whether enable the verbose console log for mic node. Default is 'no'.
     micpowermgt (Optional) - Set the power management for mic node. Default is 'on' for all power management features.

### Set IP for Mic Node

Make sure the IP for 'mic node' is in the same network with 'Bridge IP', otherwise the 'mic node' cannot join to the Bridge.

~~~~
    chdef michost1-mic0 ip=192.168.0.1
    chdef michost1-mic1 ip=192.168.0.2
~~~~


### Set Bridge for Mic Node

The Bridge name must be the one which set by 'xHRM' postscript (External Bridge) or the one which set in nics table (Internal Bridge).

~~~~
    chdef michost1-mic0 micbridge=xbr0    # set the External bridge
    chdef michost1-mic0 micbridge=micbr0  # set the Internal bridge
~~~~


### Set Power Management for Mic Node

You can set the power management state for 'mic node' through 'micpowermgt' attribute. Four sub-attributes are supported for power management: cpufreq, corec6, pc3 and pc6. The valid values are 'on' or 'off'. Refer to doc of MPSS to get more information of 'Power Management'.

    chdef michost1-mic0 micpowermgt='cpufreq=on!corec6=off!pc3=off!pc6=off'


Note: Currently, setting of 'cpufreq' does not work. And set others attributes to 'on' does not work too. This is a bug of Intel.

## Prepare the Osimage for Mic Node

This section uses the terms **osimage** and **ramfs** to source that is used to boot mic node. Following are the concepts of them:

    **osimage** \- A directory which contains files to create ramfs for mic node. It's created by xCAT on xCAT management node and will be mounted to 'host node' so that all the host node could share the same build resource. Part of files which are used to create ramfs come from it.
    **ramfs** \- It is a cpio.gz file which will be loaded to mic node as root image for mic Linux system. The ramfs for each mic node needs to be created base on the osimage, Get generated ramfs will be put in /var/mpss of host node.

### Create Osimage Definition

You can run copycds command to create osimage definition and create a file structure in xCAT repository path /install (refer to the osimage.pkgdir attribute). The argument for copycds command should be the tar file of MPSS which is downloaded from Intel web site.

~~~~
    copycds mpss-3.1-rhel-6.2.tar
~~~~


After the successful running of copycds, the directory '/install/mpss3.1' is created. And a new osimage object named mpss3.1-rhels6.2-compute is created too. You will use this osimage name to run the genimage and nodeset command to configure the osimage.

### Install HPC Software into the Osimage

Mic node only has 8G memory that will be shared by 64 cores. To reduce the memory usage by the Operating System which running on mic node, Intel supplies a reduced Linux kernel and basic file system. For end user, except the basic file system, there are several ways to add additional files or software for the mic file system.

The additional file and software need be installed in the osimage (The directory is /install/&lt;osimage name&gt;) so that all ramfs for mic could get the additions.

#### **Three Formats to Customize Osimage**

xCAT supports three formats to add files or software to osimage:

  * **filelist format** \- It includes a directory which contains all the files and a .filelist configuration file to specify which file should be install to where on mic node. Refer to the mic document to get more detail of filelist format.
  * **rpm format** \- The rpm will be copied to ramfs of mic node, it will be installed just before the running of init during boot of mic Linux system.
  * **simple format** \- A directory is specified that the whole directory will be copied directly to mic ramfs.

#### **Directory Tree in Osimage**

Following is the directory structure in the &lt;pkgdir of osimage&gt;, you can use any of them to add files or software.

~~~~
    --<pkgdir of osimage> e.g. /install/mpss3.1
         --system (files for system boot)
         --common.filelist
         --common
         --overlay
               --rpm
               --simple
                   --s1,s2,...
                   --simple.cfg
               --rootimg (2.8.4 and later) / package (2.8.3)
                    --the base file for fs
                    --opt/mic
                         --yy.filelist
               --xx.filelist
               --xx
~~~~


  * &lt;pkgdir of osimage&gt;/common + common.filelist - Apply filelist format - The added files will be common for all mic node in a host node.
  * &lt;pkgdir of osimage&gt;/overlay/rpm - Apply rpm format - You can put any rpm that you want to install on mic node in this directory. Note: the architecture for rpm must be 'k1om' or 'noarch' so that it can be installed on mic node directly.
  * &lt;pkgdir of osimage&gt;/overlay/simple/s1,s2... + simple.cfg - Apply simple format - You can copy the directories (e.g. s1, s2) which need be copied to mic nodes here. And configure the simple.cfg to specify the destination path of the directories. The simple.cfg must be multiple lines of 's1-&gt;d1' format; 's1' is dir name in simple/, 'd1' is the path on mic for 's1'
  * /&lt;pkgdir of osimage&gt;/overlay/&lt;osimage|package&gt;/ + ./opt/mic/yy.filelist - Apply filelist format - You can install all of your software in &lt;pkgdir of osimage&gt;/overlay/&lt;osimage|package&gt;/ (by chroot) and add yy.filelist for each software in &lt;pkgdir of osimage&gt;/overlay/&lt;package|rootimg&gt;/opt/mic/. 'yy' should be name of software.

Note: In xCAT 2.8.3, the path '/&lt;pkgdir of osimage&gt;/overlay/&lt;package&gt;/' is supported as rootimage directory when installing rpms in the osimage. xCAT released a patch [patch for genimage](https://sourceforge.net/p/xcat/bugs/3917/) which changed osimage root directory to /&lt;pkgdir of osimage&gt;/overlay/&lt;osimage&gt;. All customers who want to use kit or otherpkgs to install software in mic osimage are recommended to apply this patch.

  * &lt;pkgdir of osimage&gt;/overlay/xx + xx.filelist - Apply filelist format - You can add multiple pair of xx + xx.filelist in &lt;pkgdir of osimage&gt;/overlay/ to install any files you want.

#### **Install HPC Software**

For installation of software which contains a lot files, xCAT recommends user to use '&lt;pkgdir of osimage&gt;/overlay/rootimg/ + ./opt/mic/yy.filelist' or '&lt;pkgdir of osimage&gt;/overlay/rpm'

  * If using '&lt;pkgdir of osimage&gt;/overlay/rootimg/ + ./opt/mic/yy.filelist', the software can be packaged as .rpm or .tar. With any format the file /opt/mic/yy.filelist is necessary. If using .tar format, just untar the .tar file to &lt;pkgdir of osimage&gt;/overlay/rootimg/. If using .rpm format, you can using the kit or otherpkgs format to add your rpm for osimage. The architecture for rpm must be 'x86_64' or 'noarch' so that it can be installed to osimage. Refer to the [patch](https://sourceforge.net/p/xcat/bugs/3917/) for 2.8.3.

**Example:** Install a rpm named pe-1.0-1.x86_64.rpm into '&lt;pkgdir of osimage&gt;/overlay/rootimg/' by **otherpkgs** mechanism.

    1. Create rpm pe-1.0-1.x86_64.rpm.
      It includes following files:

~~~~
       /etc/init.d
       /etc/init.d/pe
       /etc/pe.cfg
       /opt/mic
       /opt/mic/pe.filelist
       /opt/pe
       /opt/pe/pe.bin
       /root/pe.run
      /opt/mic/pe.filelist
~~~~

/opt/mic/pe.filelist is a must have configuration file for xCAT to know where to install the files in mic ramfs.  It has the entries like following:

~~~~
         file /etc/init.d/pe etc/init.d/pe 0755 0 0
         file /root/pe.run root/pe.run 0644 0 0
         file /etc/pe.cfg etc/pe.cfg 0644 0 0
         dir /opt 0755 0 0
         dir /opt/pe 0755 0 0
         file /opt/pe/pe.bin opt/pe/pe.bin 0755 0 0

~~~~

    2. Add the rpm in otherpkgs list:

~~~~
       mkdir -p /install/post/otherpkgs/mic3.1/x86_64/test
       cp pe-1.0-1.x86_64.rpm /install/post/otherpkgs/mic3.1/x86_64/test
       Create a test.otherpkglist configuration file with following line
           wxp/pe-1.0-1
       Add path of test.otherpkglist to osimage.otherpkglist
~~~~


    3. Run genimage to install rpm to mic osimage

~~~~
       genimage mpss3.1-rhels6.2-compute
~~~~


  * If using '&lt;pkgdir of osimage&gt;/overlay/rpm', just copy the rpms to '&lt;pkgdir of osimage&gt;/overlay/rpm'. The architecture for rpms must be 'k1om' or 'noarch' to make sure the rpm can be installed successfully on mic node. You can test the install by manually install the rpm in mic node.

#### **Add Additional Libraries**

The base file system for mic node includes some shared libraries for binaries to use. But sometimes you need the libraries which are built by customers themselves or installed from Intel compiler package, following steps can be followed to add additional libraries.

Use '&lt;pkgdir of osimage&gt;/overlay/simple/s1,s2... + simple.cfg' format to add a bunch of libraries to /usr/lib64.

Make a directory '/usr/lib64' at &lt;pkgdir of osimage&gt;/overlay/simple/
Copy all the additional libraries to '&lt;pkgdir of osimage&gt;/overlay/simple/usr/lib64'
Add a simple format configuration file at &lt;pkgdir of osimage&gt;/overlay/simple/usr/lib64/simple.cfg which contains configuration entry:

~~~~
       /usr/lib64->/usr
~~~~

    Run nodeset command against mic node to take effect.


#### **Add a Start Script**

If you want to add a start script that will be run during the boot of mic node, follow these steps:

Add a start script in /etc/init.d/. e.g. /etc/init.d/start
Add a symbol link from /etc/init.d/ to /etc/rc5.d/ e.g. /etc/rc5.d/S50start -&gt; /etc/init.d/start


e.g. Add a start script named 'start' with start order 'S50'

~~~~
    mkdir <pkgdir of osimage>/overlay/st
    vi <pkgdir of osimage>/overlay/st.filelist to add following lines
        file /etc/init.d/start etc/init.d/start 0755 0 0
        slink /etc/rc5.d/S50start ../../etc/init.d/start 0755 0 0
~~~~


### Generate the Osimage

  * To enable the user accounts and ssh connections cross the cluster, the following files will be copied from xCAT management node to osimage by genimage command.

~~~~
     "/etc/hosts",
     "/etc/group",
     "/etc/passwd",
     "/etc/shadow",
     "/etc/resolv.conf",
     "/etc/nsswitch.conf",
     "/etc/ssh/ssh_host_rsa_key",
     "/etc/ssh/ssh_config",
     "/etc/ssh/ssh_host_key",
     "/etc/ssh/sshd_config",
     "/etc/ssh/ssh_host_dsa_key",
     "/etc/ssh/ssh_host_key.pub",
     "/root/.ssh/id_rsa",
     "/root/.ssh/id_rsa.pub",
     "/root/.ssh/authorized_keys",
~~~~


  * If you have added kit components for osimage or added rpms through otherpkgs mechanism, run 'genimage' will install the rpms to &lt;pkgdir of osimage&gt;/overlay/rootimg.

Run genimage command:

~~~~
    genimage mpss3.1-rhels6.2-compute
~~~~


### Configure NFS Mount for MIC Node

xCAT supports to mount certain directories from nfs server to 'mic node' during the booting of 'mic node'.

  * Set the mount source and mount point in litefile table. Each mount request should be an entry in litefile table.

~~~~
     image,file,options,comments,disable
    "mpss3.1-rhels6.2-compute","/nfs/a:/a","micmount",,
    "mpss3.1-rhels6.2-compute","/nfs/b:/b","micmount",,
~~~~


The columns in litefile table:

    image: The name of mpss osimage
    file: To specify the source and destination of mount operation. The format must be: src:dest.
    options: The mic mount flag. Must be set to 'micmount'


  * Set nfs server (Optional)

This step is optional that if not set nfs server in statelite table, the nfs server will be the 'host node' of 'mic node'

Set the nfs server in statelite table:

~~~~
    #node,image,statemnt,mntopts,comments,disable
    "michost1-mic0",,"192.168.0.100:/nfsroot",,,
~~~~


  * In the above example, after booting of mic node, the /a and /b on mic node will be mounted to nfs server. For debugging, you can see the following entry in the &lt;mic host&gt;:/var/mpss/mic0/etc/fstab if the setting is correct.

Without nfs server set in statelite table, the nfs server will be 'host node'.

~~~~
    192.168.0.254:/nfs/a /a  nfs             nolock          1 1
~~~~


With nfs server set in statelite table, the nfs server will get from statelite table.

~~~~
    192.168.0.100:/nfsroot/nfs/a /a  nfs             nolock          1 1
~~~~


Note1: xCAT will not cover the setup of nfs server. User needs make sure the nfs server has been set up correctly before booting of mic node.

Note2: **[Stateless]** The flag 'fsid=0' needs be set for nfs export. e.g. /nfs *(rw,no_root_squash,sync,no_subtree_check,fsid=0)

### Service Node Consideration

The osimage is locate at xCAT Management Node or Service Node, it will be mounted to 'host node' when run the 'nodeset' or 'rflash' commands. So if you have Service Node, the /install directory on Service Node should be synced from xCAT Management Node instead of a mount from Management Node. And after any change in the osimage, the syncing of /install directory to Service Node is necessary to be done again:

~~~~
    cd /
    prsync install <sn>:/
~~~~


## Create Ramfs for Mic Node

When the osimage for mic node is ready, you can create ramfs for each mic node. The osimage is located at xCAT Management Node or Service Node, but ramfs will be created at mic host node (/var/mpss).

nodeset command will generate configuration file for each mic node base on the previous setting, and generate ramfs which 'mic node' boots from for each mic node.

~~~~
    nodeset michost1-mic0 osimage=mpss3.1-rhels6.2-compute
~~~~


If not set miconboot to 'no', after nodeset, the mic node will be on boot status. Then you can log in to the mic node to check the configuration.

**[Stateless]** Note: Since the reboot of 'host node' will lose all the configuration for mic node, you have to rerun 'nodeset' for each mic node after rebooting of 'host node'.




## Hardware Control for Mic Node

  * Remote power control: [stat|state|on|off|reset|boot]

~~~~
    rpower michost1-mic0 stat
    michost1-mic0:  online (mode: linux image: /opt/intel/mic/mnt/lib/firmware/mic/uos.img)
~~~~


  * Get the inventory information for mic node

~~~~
    rinv  michost1-mic0

    michost1-mic0: HOST OS : Linux
    michost1-mic0: OS Version : 2.6.32-220.el6.x86_64
    michost1-mic0: Driver Version : 6720-15
    michost1-mic0: MPSS Version : 2.1.6720-15 michost1-mic0: HOST OS : Linux
    michost1-mic0: OS Version : 2.6.32-220.el6.x86_64
    michost1-mic0: Driver Version : 3.1-0.1.build0
    michost1-mic0: MPSS Version : 3.1
    michost1-mic0: Host Physical Memory : 65902 MB
    michost1-mic0: Flash Version : NotAvailable
    michost1-mic0: SMC Firmware Version : NotAvailable
    michost1-mic0: SMC Boot Loader Version : NotAvailable
    michost1-mic0: uOS Version : NotAvailable
    michost1-mic0: Device Serial Number : NotAvailable
    michost1-mic0: Vendor ID : 0x8086
    michost1-mic0: Device ID : 0x2250
    michost1-mic0: Subsystem ID : 0x2500
    michost1-mic0: Coprocessor Stepping ID : 3
    michost1-mic0: PCIe Width : x16
    michost1-mic0: PCIe Speed : 5 GT/s
    michost1-mic0: PCIe Max payload size : 256 bytes
    michost1-mic0: PCIe Max read req size : 4096 bytes
    michost1-mic0: Coprocessor Model : 0x01
    michost1-mic0: Coprocessor Model Ext : 0x00
    michost1-mic0: Coprocessor Type : 0x00
    michost1-mic0: Coprocessor Family : 0x0b
    michost1-mic0: Coprocessor Family Ext : 0x00
    michost1-mic0: Coprocessor Stepping : B1
    michost1-mic0: Board SKU : B1PRQ-5110P
    michost1-mic0: ECC Mode : NotAvailable
    michost1-mic0: SMC HW Revision : NotAvailable
    michost1-mic0: Total No of Active Cores : 60
    michost1-mic0: Voltage : 0 uV
    michost1-mic0: Frequency : 1052631 kHz
    michost1-mic0: GDDR Vendor : Elpida
    michost1-mic0: GDDR Version : 0x1
    michost1-mic0: GDDR Density : 2048 Mb
    michost1-mic0: GDDR Size : 7936 MB
    michost1-mic0: GDDR Technology : GDDR5
    michost1-mic0: GDDR Speed : 5.000000 GT/s
    michost1-mic0: GDDR Frequency : 2500000 kHz
    michost1-mic0: GDDR Voltage : 0 uV
~~~~


  * Get the remote console for mic node

Before running rcons command against mic node, you need make sure the **screen** rpm package has been installed on 'host node' (for both stateful and stateless host node)

~~~~
    rcons michost1-mic0
~~~~


  * Flash the firmware for mic node

The 'Xeon Phi Card' has 'bootloader' (SMC) and 'firmware' (FLASH) which are used to boot mic node to standby stat. rflash command can be used to update the 'bootloader' and 'firmware' in the flash for the 'mic node'. By default, the up to date firmware will be searched from '/usr/share/mpss/flash' which installed by mpss kit for 'host node'.

~~~~
    rflash michost1-mic0
~~~~


## FAQ

### The Debug Hints

  * After running of nodeset against mic node, you can check following configuration files on host node for debugging purpose.

~~~~
    /etc/mpss/*.conf - the configuration files of mic node
    /var/mpss/ - the source files for ramfs of mic node
    /tmp/mictmp/miccfg.<host node> - the configuration file that is used by xCAT to configure mic node
    /tmp/mictmp/micflash.<host node> - the configuration file that is used by xCAT to flash mic node
    /var/log/xcat/configmic.log - the log file for the steps that how xCAT configures mic node
    /var/log/xcat/flash.log - the log file for the steps that how xCAT flash mic node
~~~~


  * If Overlay configuration for adding files or software to mic node does NOT work, check the /var/mpss/mnt on host node has been mounted to xCAT management node (run mount command on host node).

~~~~
    <xcat management node>:/install/mpss3.1 on /var/mpss/mnt type nfs
~~~~


  * The auto nfs mount was not done correctly on mic node

~~~~
    Check the nfs server has been started correctly.
    Check the /etc/fstab on mic node has correct entries.
    Run 'show mount -e <nfs server>' to check the exported directories on nfs server.
~~~~


### The MIC Card Cannot be Enabled or Used

**Symptom:**

Your mic card cannot be found or used by the micctrl command or mpss failed to start that it complains the mic card is not installed.

In the syslog you can see the error message of kernel like following:

~~~~
    kernel: mic 0000:2a:00.0: device not available because of BAR 0 [0x000000-0x1ffffffff] collisions
    kernel: pci_enable failed board #0
    kernel: mic: probe of 0000:2a:00.0 failed with error -22
~~~~


**Solution:**

  * Generally you need enable the MMIO for larger than 4GB

    Enable large BAR setting: Integrated Devices &gt;&gt; Memory I/O larger than 4GB in Bios Settings &gt;&gt; Enabled


  * If your are using IBM server, try to update the UEFI firmware to the latest version

1\. Download the firmwares from IBM web page

~~~~
    IBM web site -&gt; support -&gt; download fix, driver -&gt; select the machine type you want to update
~~~~


2\. Download the firmwares for uEFI and IMM

    The files has suffix .uxz, .xml need be downloaded


Note: you also could try to download the UpdateXpess service packs which includes all the firmwares for the target nodes. It's a little big. If you don't know which one to update or when you want to update all the firmware, do it this way.

3\. Download the UXSP which will be used to run the update

    Download it from here: [UXSPI](http://www-947.ibm.com/support/entry/portal/docdisplay?lndocid=SERV-XPRESS)


4\. Transport all the firmware files and uxsp(bin file) to the target node, and run following command to do the update

    ./ibm_utl_uxspi_9.41_rhel6_32-64.bin update --local=./ -L -u


5\. Reboot the node for the firmware to take effect.

### Reboot host node to solve any strange issue that MIC Card Cannot be Used

**Symptom:**

For any Xeon Phi card issue that you do NOT know how to handle like following cases:

    1. Xeon Phi card fails to reset: reset failed
    2. mic* command: No devices found : opendir: /sys/class/mic: No such file or directory
    3. service mpss unload: Removing MIC Module: FATAL: Module mic is in use
    4. rflash failed to finish the update for SMC or flash and it causes the mic node does not work.


**Solution:**

Just recycle the host node. The best approach is unplug the power cable and waiting for a while, then plug back the power cable.


