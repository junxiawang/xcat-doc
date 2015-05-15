<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [xCAT on Ubuntu Server](#xcat-on-ubuntu-server)
  - [Preparing the Management Node](#preparing-the-management-node)
    - [Install the Operating System](#install-the-operating-system)
    - [Configure the system shell](#configure-the-system-shell)
    - [Configure the network interface](#configure-the-network-interface)
    - [Configure domain name resolution](#configure-domain-name-resolution)
    - [Configure the hosts file](#configure-the-hosts-file)
    - [Disable dnsmasq](#disable-dnsmasq)
  - [Installing xCAT](#installing-xcat)
    - [Obtaining xCAT Software](#obtaining-xcat-software)
      - [Option 1: Configure the xCAT Software Internet-Hosted Repository (Has Internet Access)](#option-1-configure-the-xcat-software-internet-hosted-repository-has-internet-access)
      - [Option 2: Download the xCAT Software (Has not Internet Access on your xCAT Management Node)](#option-2-download-the-xcat-software-has-not-internet-access-on-your-xcat-management-node)
- [ls -1](#ls--1)
    - [Configure the xCAT apt-key](#configure-the-xcat-apt-key)
    - [Configure Ubuntu Package repositories](#configure-ubuntu-package-repositories)
- [install the add-apt-repository command](#install-the-add-apt-repository-command)
- [For x86_64:](#for-x86_64)
- [For ppc64el:](#for-ppc64el)
    - [Install xCAT](#install-xcat)
    - [Verify xCAT installation](#verify-xcat-installation)
- [Add xCAT commands into your path](#add-xcat-commands-into-your-path)
- [display the installed version of xcat](#display-the-installed-version-of-xcat)
- [view the site table contents](#view-the-site-table-contents)
- [key,value,comments,disable](#keyvaluecommentsdisable)
    - [Upgrade xCAT](#upgrade-xcat)
  - [Configure xCAT](#configure-xcat)
    - [networks Table](#networks-table)
    - [passwd Table](#passwd-table)
    - [DHCP](#dhcp)
  - [Deploying Nodes](#deploying-nodes)
    - [Create the Operating System Repository](#create-the-operating-system-repository)
- [run copycds on the image, located in /tmp](#run-copycds-on-the-image-located-in-tmp)
- [list out the osimages created](#list-out-the-osimages-created)
- [lsdef -t osimage](#lsdef--t-osimage)
- [list the detail information of certain osimage](#list-the-detail-information-of-certain-osimage)
- [lsdef -t osimage ubuntu14.04.1-x86_64-install-compute](#lsdef--t-osimage-ubuntu14041-x86_64-install-compute)
    - [Creating node definitions in xCAT](#creating-node-definitions-in-xcat)
      - [Adding nodes](#adding-nodes)
- [See 'noderange' man page for various ways to specify a large set of nodes](#see-noderange-man-page-for-various-ways-to-specify-a-large-set-of-nodes)
- [i.e cn01-c99, cn[001-100], etc](#ie-cn01-c99-cn001-100-etc)
- [Either of the following commands can be used to display defined nodes](#either-of-the-following-commands-can-be-used-to-display-defined-nodes)
      - [Configure DNS](#configure-dns)
      - [Configure DHCP](#configure-dhcp)
- [set primarynic and installnic to use MAC address](#set-primarynic-and-installnic-to-use-mac-address)
- [Run makedhcp to add the nodes to dhcp](#run-makedhcp-to-add-the-nodes-to-dhcp)
    - [Use Ubuntu Local Mirror](#use-ubuntu-local-mirror)
    - [Installing Stateful/Diskful Nodes](#installing-statefuldiskful-nodes)
      - [Begin Installation](#begin-installation)
- [if the mini.iso is stored in /tmp](#if-the-miniiso-is-stored-in-tmp)
- [<ubuntu-version> may be "ubuntu14.04.1"](#ubuntu-version-may-be-ubuntu14041)
- [<arch> may be "ppc64el"](#arch-may-be-ppc64el)
    - [Installing Stateless/Diskless Nodes](#installing-statelessdiskless-nodes)
      - [Prepare Images](#prepare-images)
- [lsdef -t osimage -o ubuntu14.04.1-x86_64-netboot-compute](#lsdef--t-osimage--o-ubuntu14041-x86_64-netboot-compute)
      - [Set up a postinstall script (optional)](#set-up-a-postinstall-script-optional)
      - [Begin Installation](#begin-installation-1)
      - [Update Images](#update-images)
    - [Monitor installation](#monitor-installation)
  - [Advanced Topics](#advanced-topics)
    - [Customizing System Packages](#customizing-system-packages)
    - [Customizing additional packages](#customizing-additional-packages)
- [lsdef -t osimage -o ubuntu14.04.1-x86_64-netboot-compute](#lsdef--t-osimage--o-ubuntu14041-x86_64-netboot-compute-1)
- [find the dependencies for the package <pkg_name>](#find-the-dependencies-for-the-package-pkg_name)
- [download the packages](#download-the-packages)
- [](#)
- [do not modify the following command](#do-not-modify-the-following-command)
- [apt requires the name 'Packages' to be used](#apt-requires-the-name-packages-to-be-used)
    - [Installing other packages with Ubuntu official mirrors](#installing-other-packages-with-ubuntu-official-mirrors)
  - [Known Issues](#known-issues)
    - [P Servers](#p-servers)
    - [X Servers](#x-servers)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



## xCAT on Ubuntu Server

This documentation walk you through a very basic install of xCAT running on Ubuntu Linux.

The following example will configure a single xCAT management node with two compute nodes. 

* mn01 is the xCAT management node
* cn01 is a compute node, installed stateful/diskful
* cn02 is a compute node, installed stateless/diskless

The Operating System used is Ubuntu Server 14.04 LTS (Trusty Tahr).

## Preparing the Management Node

**Pre-install Considerations:** 
_xCAT utilizes the /install directory on the management node to store various configuration files, OS images, post install scripts, etc.  It is recommended to create a separate filesystem, or partition, at least 30GB large for the /install directory._

&nbsp;
### Install the Operating System

Obtain Ubuntu Server ISO from the Ubuntu download page and install onto the management node (mn01). 

It is recommended that the management node have connectivity to the internet in order to access various external repositories for package management.  (Refer to Ubuntu's [Repositories/CommandLine](https://help.ubuntu.com/community/Repositories/CommandLine) page for more information).

&nbsp;

### Configure the system shell

From Ubuntu 6.10 onwards, the default system shell has been changed from /bin/sh to /bin/dash.   (For more information, refer to [DashAsBinSh](https://wiki.ubuntu.com/DashAsBinSh)). xCAT's shell scripts have been tested and developed using bash.  Please switch to /bin/bash using one of the following commands:

~~~~
    cd /bin/ && ln -fs bash sh
~~~~

or

~~~~
    dpkg-reconfigure dash
~~~~

and select no

&nbsp;
### Configure the network interface

In this document, the networking scheme is kept simple and will only consist of a single active network interface.  This interface will be used by xCAT as the provisioning network. Verify that provisioning interface in /etc/network/interfaces is configured with a static IP address.

~~~~   
auto eth0
iface eth0 inet static
    address 192.168.1.1
    netmask 255.255.255.0
~~~~    

&nbsp;
### Configure domain name resolution

The management node is the DNS server for the xCAT managed cluster.  Configure the /etc/resolv.conf file to use the IP address of the management node for the nameserver attribute.  

~~~~    
search cluster.com
nameserver 192.168.1.1
~~~~    

&nbsp;
### Configure the hosts file

The management node performs hostname to IP address resolution.  Add IP address and hostname entries to the /etc/hosts file for all the machines in your xCAT managed cluster. 

~~~~ 
127.0.0.1       localhost.localdomain localhost

192.168.1.1     mn01.cluster.com mn01

192.168.1.10    cn01.cluster.com cn01
192.168.1.11    cn02.cluster.com cn02
~~~~    

### Disable dnsmasq

If the dnsmasq is installed on Ubuntu, it will be started automatically. The dnsmasq conflicts with the DHCP service that xCAT uses, so need to disable dnsmasq to make the DHCP work. The following two commands could be used to disable dnsmasq:

~~~~
  /etc/init.d/dnsmasq stop
  update-rc.d dnsmasq disable
~~~~ 

&nbsp;
## Installing xCAT

### Obtaining xCAT Software

#### Option 1: Configure the xCAT Software Internet-Hosted Repository (Has Internet Access)

xCAT provides internet hosted software repositories for xcat-core and xcat-dep (dependencies) software packages.  

Create the xcat-core.list and xcat-deps.list files in /etc/apt/sources.list.d/ on your management node in the following format:

~~~~

xcat-core.list:

Latest Released (Stable) xCAT:

    deb [arch=<arch>] http://sourceforge.net/projects/xcat/files/ubuntu/<xcat-version>/xcat-core <ubuntu-release-name> main

Or Latest Snapshot Build(snapshot build that has not been tested thoroughly):

    deb [arch=<arch>] http://sourceforge.net/projects/xcat/files/ubuntu/<xcat-version>/core-snap <ubuntu-release-name> main

xcat-dep.list:
    deb [arch=<arch>] http://sourceforge.net/projects/xcat/files/ubuntu/xcat-dep <ubuntu-release-name> main

where: 
    <arch> is "amd64" or "ppc64el"
    <xcat-version> is the xCAT numerical major release version or "devel" for development builds.
    <ubuntu-release-name> is the ubuntu release name  (14.04 LTS would be "trusty"). 
~~~~

&nbsp;
**For Example, Ubuntu Server 14.04 LTS:**

Add the following line into /etc/apt/sources.list.d/xcat-core.list: 

~~~~    
deb [arch=amd64] http://sourceforge.net/projects/xcat/files/ubuntu/devel/core-snap trusty main

~~~~    

&nbsp;
Add the following line into /etc/apt/sources.list.d/xcat-dep.list: 

~~~~    
deb [arch=amd64] http://sourceforge.net/projects/xcat/files/ubuntu/xcat-dep trusty main
~~~~    

&nbsp;
#### Option 2: Download the xCAT Software (Has not Internet Access on your xCAT Management Node)

Download the xCAT core (Linux - Deb Package) and xCAT Dependency package from the [xCAT Download](Download_xCAT) page:

**xCAT core** 

Latest Released (Stable) xCAT:

~~~~

http://sourceforge.net/projects/xcat/files/xcat/<xcat-version>.x_Ubuntu/xcat-core-<xcat-version>.tar.bz2

~~~~

Latest Snapshot Build(snapshot build that has not been tested thoroughly):

~~~~
http://sourceforge.net/projects/xcat/files/ubuntu/<xcat-version>/core-debs-snap.tar.bz2
~~~~

where <xcat-version> is the xCAT numerical major release version or "devel" for development builds.


**xCAT dep**
~~~~
Download the latest package from:

http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Ubuntu
~~~~


~~~~    
mkdir -p /root/xcat2
cd /root/xcat2

# ls -1 
xcat-core-2.8.5.tar.bz2
xcat-dep-ubuntu.tar.bz

tar jxvf xcat-core-*.tar.bz2     # or core-debs-snap.tar.bz2 (devel or snapshot build)
tar jxvf xcat-dep-ubuntu*.tar.bz
~~~~    

&nbsp;
Run the **mklocalrepo.sh** script in EACH of the xcat-core and xcat-dep directories to automatically add configuration files to /etc/apt/sources.list.d/

~~~~    
cd /root/xcat2/xcat-core
./mklocalrepo.sh

cd /root/xcat2/xcat-dep
./mklocalrepo.sh
~~~~    

&nbsp;
### Configure the xCAT apt-key

Regardless of the option chosen above, apt-get is used to easily install xCAT.  The xCAT GPG public key must be added for apt to verify the xCAT packages.  

Without the key, running 'apt-get update' will display the following error message:  *The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 20E475A8DA736C68*

**Has Internet Access**

~~~~    
wget -O - "http://sourceforge.net/projects/xcat/files/ubuntu/apt.key/download" | apt-key add -
~~~~    

**Has NOT Internet Access**

Download the key file from http://sourceforge.net/projects/xcat/files/ubuntu/apt.key/download and copy it to your xCAT MN, then import it with 'apt-key add' command.


&nbsp;
### Configure Ubuntu Package repositories

The xCAT software has dependencies on various Ubuntu operating system packages and using apt-get will automatically pull in those dependencies.  The main and universe repositories must be configured for this to work well.  The following commands will add the necessary apt-repositories to the management node:

**Has Internet Access**

~~~~
# install the add-apt-repository command
apt-get install software-properties-common

# For x86_64:
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates main"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates universe"

# For ppc64el:
add-apt-repository "deb http://ports.ubuntu.com/ubuntu-ports $(lsb_release -sc) main"
add-apt-repository "deb http://ports.ubuntu.com/ubuntu-ports $(lsb_release -sc)-updates main"
add-apt-repository "deb http://ports.ubuntu.com/ubuntu-ports $(lsb_release -sc) universe"
add-apt-repository "deb http://ports.ubuntu.com/ubuntu-ports $(lsb_release -sc)-updates universe"
~~~~

**Has NOT Internet Access**

Refer to the doc [installing-other-packages-with-ubuntu-official-mirrors](https://sourceforge.net/p/xcat/wiki/Installing_other_packages_with_Ubuntu_official_mirror) to set up your local mirror.

&nbsp;
### Install xCAT

Use the following commands to install xCAT.

~~~~    
apt-get clean all
apt-get update
apt-get install xcat
~~~~    

&nbsp;
### Verify xCAT installation

At this point, xCAT should have successfully installed.  Verify the installation by running a few simple commands. 

~~~~
#
# Add xCAT commands into your path 
#
source /etc/profile.d/xcat.sh

#
# display the installed version of xcat 
#
lsxcatd -a 

#
# view the site table contents
#
tabdump site
#key,value,comments,disable
"blademaxp","64",,
"domain","ppd.pok.ibm.com",,
...
...
~~~~    

&nbsp;
### Upgrade xCAT

To upgrade the xCAT software, point the xcat-core and xcat-dep repositories to a later version, then run the following commands:

~~~~    
apt-get update
apt-get upgrade xcat 
~~~~  
 
&nbsp; 
## Configure xCAT

&nbsp;
### networks Table

During xCAT installation, the 'makenetworks' command runs and creates entries into the xCAT networks table for each network that is detected on the management node.  

If there are additional networks that need to be configured, reference the following document: [Appendix_A:_Network_Table_Setup_Example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example)
 
&nbsp;
### passwd Table

The xCAT passwd table needs to contain an entry for the "system" key.  The system key specifies the password that will be used for the root userid on and nodes that is installed by xCAT.  You will also need to add the userid/password for the hardware control being used.  (i.e "hmc" for Power Servers; "ipmi" for X Servers)

~~~~    
tabedit passwd
key,username,password,cryptmethod,comments,disable
"system","root","cluster",,,
"ipmi","USERID","PASSW0RD",,,
~~~~    

&nbsp;
### DHCP

Run **makedhcp -n** to create a new DHCP configuration file and add the network definitions. 

~~~~   
makedhcp -n
~~~~    

&nbsp;
## Deploying Nodes

### Create the Operating System Repository

Download the ISO image for the operating system onto your management node and run copycds.

Copycds will copy the contents of the iso image to /install/<os>/<arch> on the management node.  
In addition, default osimages will be added to the osimage table.  

~~~~
#
# run copycds on the image, located in /tmp
#
/opt/xcat/bin/copycds /tmp/ubuntu-14.04.1-server-amd64.iso

#
# list out the osimages created
#
#lsdef -t osimage 
ubuntu14.04.1-x86_64-install-compute  (osimage)
ubuntu14.04.1-x86_64-install-hpc  (osimage)
ubuntu14.04.1-x86_64-install-kvm  (osimage)
ubuntu14.04.1-x86_64-netboot-compute  (osimage)
ubuntu14.04.1-x86_64-statelite-compute  (osimage)

# list the detail information of certain osimage
#lsdef -t osimage ubuntu14.04.1-x86_64-install-compute
~~~~

Repeat the above for each operating system you want to provision using xCAT.  


&nbsp;
### Creating node definitions in xCAT

&nbsp;
#### Adding nodes

Use the **mkdef** command to create the initial node definition for the two compute nodes. 

~~~~
#
# See 'noderange' man page for various ways to specify a large set of nodes
# i.e cn01-c99, cn[001-100], etc
#
mkdef -t node -o cn01,cn02 groups=compute,all
~~~~    

&nbsp;
To view the nodes defined: 

~~~~
#
# Either of the following commands can be used to display defined nodes    
#
nodels
lsdef -t node 
~~~~    

&nbsp;
To view specific information about the node object:

~~~~    
lsdef -t node -o cn01
~~~~    

&nbsp;
#### Configure DNS

Ensure that ROOTDIR is not set in /etc/bind/named.conf 

Configure the forwarders attribute in the xCAT site table to your site wide DNS servers.  
The management node will forward any request that it cannot answer to these servers.

~~~~    
chdef -t site forwarders=1.2.3.4,1.2.3.5

~~~~    

&nbsp;
Run the makedns command to set up domain name services on the management node.

~~~~    
makedns -n

~~~~    

&nbsp;
#### Configure DHCP

xCAT can use the physical MAC address on the network interface devices to assign IP addresses.  The MAC address can be located either from the back panel of the servers, or from the physical network adapter.  

Locate the MAC addresses and add entries to the compute node definitions.
 
~~~~   

chdef -t node -o cn01 mac="xx:xx:xx:xx:xx:xx"
chdef -t node -o cn02 mac="yy:yy:yy:yy:yy:yy"

#
# set primarynic and installnic to use MAC address
#
chdef -t node -o cn01,cn02 primarynic=mac installnic=mac

#
# Run makedhcp to add the nodes to dhcp 
#
makedhcp cn01,cn02
~~~~

&nbsp;
### Use Ubuntu Local Mirror
For ubuntu, the installation ISO only includes a quite limited subset of the packages in the ubuntu official mirror. To install some essential or latest packages included in the mirrors but not in the ISO during provisioning, you can add certain Internet ubuntu official mirror to the "pkgdir" attribute of osimage.
 
Take ubuntu 14.04.1 LTS for example, this can be done with the following command:

~~~~
 chdef -t osimage -o ubuntu14.04.1-ppc64el-install-compute -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main"
~~~~

As shown above, the installation with ubuntu official mirror requires the internet access. In the environment without internet access, a local mirror can be used instead of the online ubuntu official mirror. 

If you can NOT access Internet and want to use local mirror, refer to the following steps to enable the local mirror repository.

&nbsp;
**Prerequisite**

Set up your local mirror first. Refer to doc **[Installing_other_packages_with_Ubuntu_official_mirror](https://sourceforge.net/p/xcat/wiki/Installing_other_packages_with_Ubuntu_official_mirror/)** for the steps to create local ubuntu official mirror.

xCAT ONLY supports the local mirror to be http format. So you must set up your local mirror in a local http server. 

For example: My local http server is 10.3.5.36, I set up a local mirror with URL 'http://10.3.5.36/install/ubuntu-ports/'.

&nbsp;
**Set local mirror path to osimage.pkgdir**

For the target osimage, you can specify multiple local http mirror to the osimage.pkgdir attribute.

~~~~
  chdef -t osimage -o ubuntu14.04.1-ppc64el-install-compute -p pkgdir='/install/ubuntu14.04.1/ppc64el,http://10.3.5.36/install/ubuntu-ports/ trusty main,http://10.3.5.36/install/ubuntu-ports/ trusty-updates main'
~~~~

&nbsp;
**NOTE for Diskless:** Since we need the **First HTTP Mirror** in osimage.pkgdir to generate Ubuntu osimage bootstraps, the **First HTTP Mirror** must be a full repository instead of a update one like '
trusty-updates'.

&nbsp;
**Install Otherpkgs**

There's doc to describe how to use Internet mirror to install otherpkgs. See [installing-other-packages-with-ubuntu-official-mirrors](https://sourceforge.net/p/xcat/wiki/Installing_other_packages_with_Ubuntu_official_mirror)

You can replace the internet mirror with local http mirror to do the ohter packages install.

&nbsp;
### Installing Stateful/Diskful Nodes


A stateful or diskful node is a node where the operating system is installed onto the physical disk (hard drive).  The state of the operating system is saved onto the disks and will be persistent on subsequent reboots. 

&nbsp;
#### Begin Installation

To install a stateful/diskful install of Ubuntu Server 14.04.1, we will use osimage=*ubuntu14.04.1-x86_64-install-compute*. 

Use the **[rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html)** command to force the compute node to boot from network ("net") on the next reboot. 

~~~~
rsetboot cn01 net
~~~~

&nbsp;
Use the **[nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html)** command to set the next boot state for the node. This tells xCAT what do to on the next boot of the node. 

~~~~   
nodeset cn01 osimage=ubuntu14.04.1-x86_64-install-compute
~~~~

&nbsp;
**Note:** You may encounter an error when running nodeset command where the initrd.gz file is not found for netboot.  This is required for Ubuntu to successfully boot from network.  It's provided by Ubuntu in a mini.iso file at http://cdimage.ubuntu.com/netboot/14.04/  Download and copy the ../install/initrd.gz file to the netboot directory: 

~~~~
#
# if the mini.iso is stored in /tmp 
#
mkdir /tmp/iso
mount -o loop /tmp/mini.iso /tmp/iso

#
# <ubuntu-version> may be "ubuntu14.04.1"
# <arch> may be "ppc64el"
#
mkdir -p /install/<ubuntu-version>/<arch>/install/netboot
cp /tmp/iso/install/initrd.gz /install/<ubuntu-version>/<arch>/install/netboot/
umount /tmp/iso
rmdir /tmp/iso 

~~~~


&nbsp;
Reboot the node to start the install

~~~~
rpower cn01 boot
~~~~    


&nbsp;
### Installing Stateless/Diskless Nodes

A stateless or diskless node is a node where the operating system is installed into memory.  The state of the machine is held in memory (RAM) and will not persist on subsequent reboots of the node.  The state will return to what has been set in the master image. 

&nbsp;
#### Prepare Images

To install a stateless/diskless install of Ubuntu Server 14.04.1, we will use osimage=*ubuntu14.04.1-x86_64-netboot-compute*. 

Take a look at the default osimage created for *netboot-compute*: 

~~~~
# lsdef -t osimage -o ubuntu14.04.1-x86_64-netboot-compute
Object name: ubuntu14.04.1-x86_64-netboot-compute
    exlist=/opt/xcat/share/xcat/netboot/ubuntu/compute.exlist
    imagetype=linux
    osarch=x86_64
    osname=Linux
    osvers=ubuntu14.04.1
    otherpkgdir=/install/post/otherpkgs/ubuntu14.04.1/x86_64
    pkgdir=/install/ubuntu14.04.1/x86_64
    pkglist=/opt/xcat/share/xcat/netboot/ubuntu/compute.ubuntu14.04.pkglist
    profile=compute
    provmethod=netboot
    rootimgdir=/install/netboot/ubuntu14.04.1/x86_64/compute
~~~~

#### Set up a postinstall script (optional)

Postinstall scripts for diskless images are analogous to postscripts for diskful installation. The postinstall script is run by genimage near the end of its processing. You can use it to do anything to your image that you want done every time you generate this kind of image. In the script you can install rpms that need special flags, or tweak the image in some way. There are some examples shipped in /opt/xcat/share/xcat/netboot/<distro>. You could create a postinstall script to be used by genimage, then point to it in your osimage definition.

**Note:** By default, the Ubuntu stateless image does not setup the locales, if the locales settings matters for the applications run on the stateless compute nodes, you could set the postinstall script to setup the locales for the stateless nodes.

~~~~
    chdef -t osimage ubuntu14.04.1-x86_64-netboot-compute postinstall=/opt/xcat/share/xcat/netboot/ubuntu/compute.postinstall
~~~~


&nbsp;
The rootimgdir attribute points to the location on the management node where the stateless image will reside.  The first time you look at this location, it should not exist. 

~~~~
ls /install/netboot/ubuntu14.04.1/x86_64/compute
ls: cannot access /install/netboot/ubuntu14.04.1/x86_64/compute: No such file or directory
~~~~

&nbsp;  
Run **[genimage](http://xcat.sourceforge.net/man1/genimage.1.html)** to generate a stateless image

~~~~    
genimage ubuntu14.04.1-x86_64-netboot-compute
~~~~    

&nbsp;
At this point, you have the opportunity to change any files in the image by modifying the files under the rootimgdir.  It is recommended that any modifications done to your image is via postscripts.  This allows the changes to be automated and repeatable.  See [Generate/Packing Image](https://sourceforge.net/p/xcat/wiki/Using_Provmethod%3Dinstall,netboot_or_statelite/#generatepack-the-image) for more information about customizing the images.  

If no changes are required, continue to the next step. 


Run **[packimgage](http://xcat.sourceforge.net/man1/packimage.1.html)** to pack the stateless image and create the ramdisk.
 
~~~~   
packimage ubuntu14.04.1-x86_64-netboot-compute
~~~~    

&nbsp;
#### Begin Installation

Use the **[rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html)** command to force the compute node to boot from network ("net") on the next reboot. 

~~~~
rsetboot cn02 net
~~~~

&nbsp;
Use the **[nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html)** command to set the next boot state for the node. This tells xCAT what do to on the next boot of the node. 

~~~~   
nodeset cn02 osimage=ubuntu14.04.1-x86_64-netboot-compute
~~~~

&nbsp;
Reboot the node to start the install

~~~~
rpower cn02 boot
~~~~    

&nbsp;
#### Update Images

If you need to make changes and update your stateless images at any time:

* Make the necessary changes to the object definitions and postscripts
* Run genimage to re-generate the image 
* Run packimage to re-pack the image and create the ramdisk
* Run nodeset to tell xCAT to reinstall on next boot
* Reboot the stateless node to pick up the new changes 


&nbsp;
### Monitor installation

Use the **[rcons](http://xcat.sourceforge.net/man1/rcons.1.html)** command to monitor the console and watch the install process. 

~~~~   
rcons cn01
rcons cn02
~~~~

&nbsp;
## Advanced Topics

### Customizing System Packages

Refer to *[Add additional Software (Linux Only)](https://sourceforge.net/p/xcat/wiki/Using_Updatenode/#add-additional-software-linux-only)* for information on installing additional OS system packages using the pkglist files. 

### Customizing additional packages

xCAT provides an **otherpkgs** mechanism that allows you to install additional debian packages (*.deb) that are not provided by the distribution. To use this, you need to create and maintain a local debian package repository. 

Looking at the default osimage created for *netboot-compute*: 

~~~~
# lsdef -t osimage -o ubuntu14.04.1-x86_64-netboot-compute
Object name: ubuntu14.04.1-x86_64-netboot-compute
    exlist=/opt/xcat/share/xcat/netboot/ubuntu/compute.exlist
    imagetype=linux
    osarch=x86_64
    osname=Linux
    osvers=ubuntu14.04.1
    otherpkgdir=/install/post/otherpkgs/ubuntu14.04.1/x86_64
    pkgdir=/install/ubuntu14.04.1/x86_64
    pkglist=/opt/xcat/share/xcat/netboot/ubuntu/compute.ubuntu14.04.pkglist
    profile=compute
    provmethod=netboot
    rootimgdir=/install/netboot/ubuntu14.04.1/x86_64/compute
~~~~

&nbsp;
The otherpkgdir specifies a directory that we can use as a base directory for the package repository.
Create a directory under here to save all the packages in your local repository

~~~~
mkdir -p /install/post/otherpkgs/ubuntu14.04.1/x86_64/<my_custom_dir>
~~~~    

&nbsp;
Install dpkg-dev on to the management node

~~~~    
apt-get install dpkg-dev
~~~~

&nbsp;
Download the debian packages and their dependency packages 
 
~~~~
cd /install/post/otherpkgs/ubuntu14.04.1/x86_64/<my_custom_dir>

#
# find the dependencies for the package <pkg_name>
#
apt-rdepends <pkg_name> | grep -v Depends

#
# download the packages
#
apt-get download -d <pkg_name>
~~~~    

&nbsp;
Run **dpkg-scanpackages** to create the repository for apt 

~~~~    
cd /install/post/otherpkgs/ubuntu14.04.1/x86_64/<my_custom_dir>

# 
# do not modify the following command
# apt requires the name 'Packages' to be used
#
dpkg-scanpackages . > Packages
~~~~    

&nbsp;
Create an otherpkgs package list file and add the <pkg_name> to the list 

~~~~    
vi /install/custom/install/ubuntu14.04.1/compute.otherpkgs.pkglist


<my_custom_dir>/xxx.deb
...
...
~~~~

&nbsp;
Assign the pkglist file to the osimage object definition 

~~~~    
chdef -t osimage  ubuntu14.04.1-x86_64-netboot-compute \
 otherpkgdir="/install/post/otherpkgs/ubuntu14.04.1/x86_64/<my_custom_dir>" \
 otherpkglist="/install/custom/install/ubuntu14.04.1/compute.otherpkgs.pkglist"
~~~~ 

&nbsp;   
### Installing other packages with Ubuntu official mirrors 

See the following for for [Installing other packages with Ubuntu official mirror](Installing_other_packages_with_Ubuntu_official_mirror)

&nbsp;
## Known Issues

### P Servers

Running Ubuntu Server 14.04 (ppc64el) VMs, rcons does not work:

To get around this, open Kimchi at URL https://<PowerKVM_IP>:8001
Under "Actions", click "connect" and input the password you set before running mkvm.  

Then you should be able to get the console.

### X Servers