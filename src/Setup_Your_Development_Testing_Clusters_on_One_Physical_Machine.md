<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Note: This documentation is not tested, use it at your own risk!!!](#note-this-documentation-is-not-tested-use-it-at-your-own-risk)
- [Setup your development/testing clusters on one physical machine](#setup-your-developmenttesting-clusters-on-one-physical-machine)
  - [1\. Find a physical machine with two disks and enough memory, and at least three network adapters. Will use one disk for the virtual machines.](#1%5C-find-a-physical-machine-with-two-disks-and-enough-memory-and-at-least-three-network-adapters-will-use-one-disk-for-the-virtual-machines)
  - [2\. Install the KVM hypervisor from another MN.](#2%5C-install-the-kvm-hypervisor-from-another-mn)
  - [3\. After the KVM hypervisor node is installed successfully](#3%5C-after-the-kvm-hypervisor-node-is-installed-successfully)
  - [4\. Install xCAT on the KVM hypervisor:](#4%5C-install-xcat-on-the-kvm-hypervisor)
  - [5\. Configure NAT on the KVM host:](#5%5C-configure-nat-on-the-kvm-host)
  - [6\. Create disk partitions on /dev/sdb](#6%5C-create-disk-partitions-on-devsdb)
  - [7\. Define the virtual machines:](#7%5C-define-the-virtual-machines)
  - [8\. Configure the password-less ssh for the KVM host to itself](#8%5C-configure-the-password-less-ssh-for-the-kvm-host-to-itself)
  - [9\. Generate the virtual machines:](#9%5C-generate-the-virtual-machines)
  - [10\. Install xCAT on the new MN](#10%5C-install-xcat-on-the-new-mn)
  - [11\. define and manage the vms on the new MN](#11%5C-define-and-manage-the-vms-on-the-new-mn)
  - [12\. To add new machines](#12%5C-to-add-new-machines)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Note: This documentation is not tested, use it at your own risk!!!

## Setup your development/testing clusters on one physical machine

xCAT development/testing team has been using virtualization environment on system x as the development/testing clusters for a while, I summarized the procedure on how to setup your development/testing clusters on one single physical machine, using the virtual machines can bring in several advantages: 

1\. Improve the utilization of the servers, and create many virtual machines as your MNs, SNs and CNs 

2\. The virtual machines could boot up in seconds, comparing with the several or even 10 minutes for each node reboot for booting a physical server. 

3\. These virtual machines are in a pure-private network that will not be affected by any DHCP servers in the development networks. 

4\. These virtual machines could access internet through the NAT on the KVM host. 

5\. Performance of these virtual machines are fairly good. 

The only problem I am seeing with the virtualization environment is that you will not be able to cover the hw ctrl capabilities testing and EFI boot testing. 

Use the following procedure to setup your development/testing clusters, including RedHat/CentOS, SLES and Ubuntu(TBD) on one physical machine, as long as this physical machine has enough resource to run these virtual machines. These virtual machines are in a pure-private network that will not be affected by any DHCP servers in the development networks, these virtual machines could access internet through the NAT on the KVM host,and the performance of these virtual machines are fairly good. 

### 1\. Find a physical machine with two disks and enough memory, and at least three network adapters. Will use one disk for the virtual machines.

If you do not have a machine with two disks, you could use the os disk, before installing the KVM hypervisor, change the partitions settings in the kickstart file like this: 

  1. TODO: ondisk detection, /dev/disk/by-id/edd-int13_dev80 for legacy maybe, and no idea about efi. at least maybe blacklist SAN if mptsas/mpt2sas/megaraid_sas seen... 

echo "part /boot --size 256 --fstype ext3 --ondisk $instdisk" &gt;&gt; /tmp/partitioning 

echo "part swap --size 20480 --ondisk $instdisk" &gt;&gt; /tmp/partitioning 

echo "part / --size 30720 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

echo "part /vm1 --size 20480 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

echo "part /vm2 --size 20480 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

echo "part /vm3 --size 10240 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

echo "part /vm4 --size 10240 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

echo "part /vm5 --size 10240 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

echo "part /vm6 --size 10240 --ondisk $instdisk --fstype $FSTYPE" &gt;&gt; /tmp/partitioning 

  
If you do not have a machine with only one or two network adapters, you could use any network adapter as the bridge, the only difference is that you could not put your virtual machines into a pure-private environment. 

### 2\. Install the KVM hypervisor from another MN.

On the MN: yum -y install iscsi-initiator-utils bridge-utils kvm perl-Sys-Virt 

Define the node: 
    
     [root@ls21n01 ~]# lsdef -z x3250m4n01
     # &lt;xCAT data object stanza file&gt;
     
     x3250m4n01:
       objtype=node
       arch=x86_64
       bmc=10.1.0.137
       bmcpassword=PASSW0RD
       bmcusername=USERID
       cons=ipmi
       groups=ipmi,all
       installnic=mac
       mac=34:40:B5:89:80:2C
       mgt=ipmi
       netboot=xnba
       nodetype=osi
       os=rhels6.3
       postscripts=xHRM bridgeprereq
       primarynic=mac
       profile=kvm
       provmethod=rhels6.3-x86_64-install-kvm
       serialflow=hard
       serialport=0
       serialspeed=115200
     [root@ls21n01 ~]# 
    
    

chdef x3250m4n01 -p postscripts="xHRM bridgeprereq" 

add into /etc/hosts makedns x3250m4n01 makeconservercf x3250m4n01 

nodeset x3250m4n01 osimage=rhels6.3-x86_64-install-kvm 

rsetboot x3250m4n01 net 

rpower x3250m4n01 reset 

### 3\. After the KVM hypervisor node is installed successfully

On the KVM host, change the ip addresses to be static 

\[root@x3250m4n01 network-scripts\]# cat ifcfg-eth5 

DEVICE="eth5" 

BOOTPROTO="static" 

HWADDR="34:40:B5:89:80:2D" 

ONBOOT="yes" 

TYPE="Ethernet" 

UUID="4ce626ef-c78e-424a-bec2-c44978822e0c" 

IPADDR=9.114.34.102 

NETMASK=255.255.255.0 

\[root@x3250m4n01 network-scripts\]# cat ifcfg-default 

DEVICE=default 

TYPE=Bridge 

ONBOOT=yes 

PEERDNS=yes 

DELAY=0 

BOOTPROTO=static 

IPADDR=10.1.0.181 

NETMASK=255.255.0.0 

\[root@x3250m4n01 network-scripts\]# cat ifcfg-eth4 

DEVICE=eth4 

ONBOOT=yes 

BRIDGE=default 

HWADDR=34:40:b5:89:80:2c 

  
Change the default gateway 

\[root@idplex04 network-scripts\]# cat /etc/sysconfig/network 

NETWORKING=yes 

HOSTNAME=idplex04 

GATEWAY=9.114.34.254 

\[root@idplex04 network-scripts\]# 

select one NIC for the private network bridge, it does not matter if the NIC has network connection. 

brctl addbr private brctl addif private eth0 brctl setfd private 0 

\[root@x3750n01 network-scripts\]# cat ifcfg-private 

DEVICE=private 

TYPE=Bridge 

ONBOOT=yes 

PEERDNS=yes 

DELAY=0 

BOOTPROTO=static 

IPADDR=1.1.1.1 

NETMASK=255.255.0.0 

\[root@x3750n01 network-scripts\]# cat ifcfg-eth0 

DEVICE="eth0" 

ONBOOT="yes" 

BRIDGE=private 

\[root@x3750n01 network-scripts\]# 

  
update /etc/hosts 

\[root@x3250m4n01 network-scripts\]# cat /etc/hosts 

127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 

    

    1 localhost localhost.localdomain localhost6 localhost6.localdomain6 

10.1.0.181 x3250m4n01-10.clusters.com x3250m4n01-10 

9.114.34.102 x3250m4n01-pub.clusters.com x3250m4n01-pub 

1.1.1.1 x3250m4n01.clusters.com x3250m4n01 

1.1.1.2 rhmn.clusters.com rhmn 

1.1.1.3 rhcn1.clusters.com rhcn1 

1.1.1.4 slesmn.clusters.com slesmn 

1.1.1.5 slescn1.clusters.com slescn1 

\[root@x3250m4n01 network-scripts\]# 

/etc/init.d/network restart 

Change the nameserver 

Change the syslog redirection Remove the "# xCAT settings" section service rsyslog restart 

(Optional) If the os and virtual machines are using the same disk, you need to make sure the partitions for virtual machines are not mounted. 

\[root@hs23n01 ~\]# for i in `seq -w 1 6`; do umount /vm$i; done 

Remove these partitions from /etc/fstab 

  


### 4\. Install xCAT on the KVM hypervisor:

\[root@idplex04 yum.repos.d\]# cat xCAT-core.repo xCAT-dep.repo 

\[xcat-2-core\] 

name=xCAT 2 Core packages 

baseurl=https://sourceforge.net/projects/xcat/files/yum/devel/core-snap 

enabled=1 

gpgcheck=1 

gpgkey=https://sourceforge.net/projects/xcat/files/yum/devel/core-snap/repodata/repomd.xml.key 

\[xcat-dep\] 

name=xCAT 2 depedencies 

baseurl=https://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64 

enabled=1 

gpgcheck=1 

gpgkey=https://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64/repodata/repomd.xml.key 

\[root@idplex04 yum.repos.d\]# 

\[root@hv16s6ap15 iso\]# cd /iso/ 

\[root@hv16s6ap15 iso\]# mkdir 1 

\[root@hv16s6ap15 iso\]# mount -o loop RHEL6.1-20110510.1-Server-ppc64-DVD1.iso 1 

\[root@hv16s6ap15 yum.repos.d\]# ls 

rhels6.1.repo xCAT-core.repo xCAT-dep.repo 

\[root@hv16s6ap15 yum.repos.d\]# 

yum clean metadata 

  
rpm --import /iso/1/RPM-GPG-KEY-redhat-release 

yum install xCAT 

source /etc/profile.d/xcat.sh tabdump site 

\[root@x3250m4n01 network-scripts\]# tabdump site 

  1. key,value,comments,disable 

"blademaxp","64",, 

"domain","clusters.com",, 

"fsptimeout","0",, 

"installdir","/install",, 

"ipmimaxp","64",, 

"ipmiretries","3",, 

"ipmitimeout","2",, 

"consoleondemand","no",, 

"master","1.1.1.1",, 

"forwarders","9.114.8.1 9.114.1.1",, 

"nameservers","1.1.1.1",, 

"maxssh","8",, 

"ppcmaxp","64",, 

"ppcretry","3",, 

"ppctimeout","0",, 

"powerinterval","0",, 

"syspowerinterval","0",, 

"sharedtftp","1",, 

"SNsyncfiledir","/var/xcat/syncfiles",, 

"nodesyncfiledir","/var/xcat/node/syncfiles",, 

"tftpdir","/tftpboot",, 

"xcatdport","3001",, 

"xcatiport","3002",, 

"xcatconfdir","/etc/xcat",, 

"timezone","New York",, 

"useNmapfromMN","no",, 

"enableASMI","no",, 

"db2installloc","/mntdb2",, 

"databaseloc","/var/lib",, 

"sshbetweennodes","ALLGROUPS",, 

"dnshandler","ddns",, 

"vsftp","n",, 

"cleanupxcatpost","no",, 

"dhcplease","43200",, 

\[root@x3250m4n01 network-scripts\]# 

  
copycds /iso/RHEL6.1-20110510.1-Server-ppc64-DVD1.iso 

Use the local os repo: 

\[root@hv16s6ap15 yum.repos.d\]# cat /etc/yum.repos.d/rhels6.3.repo 

\[rhe-6.3-server\] 

name=RHEL 6.3 SERVER packages 

baseurl=file:///install/rhels6.3/x86_64/Server 

enabled=1 

gpgcheck=1 

\[root@hv16s6ap15 yum.repos.d\]# 

makedns 

### 5\. Configure NAT on the KVM host:

export pubintf=eth5 

export privateintf=private 

iptables -t nat -A POSTROUTING -o $pubintf -j MASQUERADE 

iptables -A FORWARD -i $privateintf -j ACCEPT 

iptables -A FORWARD -i $privateintf -o $pubintf -m state --state RELATED,ESTABLISHED -j ACCEPT 

iptables-save &gt; /etc/sysconfig/iptables 

service iptables restart 

chkconfig iptables on 

### 6\. Create disk partitions on /dev/sdb

parted -s -- /dev/sdb mklabel gpt 

parted -s -- /dev/sdb mkpart logical 0G 40G 

parted -s -- /dev/sdb mkpart logical 40G 60G 

parted -s -- /dev/sdb mkpart logical 60G 100G 

parted -s -- /dev/sdb mkpart logical 100G 120G 

\[root@x3250m4n01 network-scripts\]# parted -s -- /dev/sdb print 

Model: ATA ST9250610NS (scsi) 

Disk /dev/sdb: 250GB 

Sector size (logical/physical): 512B/512B 

Partition Table: gpt 

Number Start End Size File system Name Flags 

1 1049kB 40.0GB 40.0GB logical 

2 40.0GB 60.0GB 20.0GB logical 

3 60.0GB 100GB 40.0GB logical 

4 100GB 120GB 20.0GB logical 

\[root@x3250m4n01 network-scripts\]# 

### 7\. Define the virtual machines:

rhmn: 
    
       objtype=node
       arch=x86_64
       groups=kvm,vm,all
       mgt=kvm
       netboot=xnba
       primarynic=eth0
       profile=compute
       serialport=0
       serialspeed=115200
       vmcpus=2
       vmhost=x3250m4n01
       vmmemory=4096
       vmnics=private,default
       vmstorage=phy:/dev/sdb1
    

rhcn1: 
    
       objtype=node
       arch=x86_64
       groups=kvm,vm,all
       mgt=kvm
       netboot=xnba
       primarynic=eth0
       profile=compute
       serialport=0
       serialspeed=115200
       vmcpus=2
       vmhost=x3250m4n01
       vmmemory=4096
       vmnics=private
       vmstorage=phy:/dev/sdb2
    

slesmn: 
    
       objtype=node
       arch=x86_64
       groups=kvm,vm,all
       mgt=kvm
       netboot=xnba
       primarynic=eth0
       profile=compute
       serialport=0
       serialspeed=115200
       vmcpus=2
       vmhost=x3250m4n01
       vmmemory=4096
       vmnics=private,default
       vmstorage=phy:/dev/sdb3
    

slescn1: 
    
       objtype=node
       arch=x86_64
       groups=kvm,vm,all
       mgt=kvm
       netboot=xnba
       primarynic=eth0
       profile=compute
       serialport=0
       serialspeed=115200
       vmcpus=2
       vmhost=x3250m4n01
       vmmemory=4096
       vmnics=private
       vmstorage=phy:/dev/sdb4
    

### 8\. Configure the password-less ssh for the KVM host to itself

\[root@x3250m4n01 ~\]# cd /root/.ssh 

\[root@x3250m4n01 .ssh\]# rm -f id_rsa* 

\[root@x3250m4n01 .ssh\]# ssh-keygen -t rsa 

\[root@x3250m4n01 .ssh\]# cat id_rsa.pub &gt;&gt; authorized_keys 

### 9\. Generate the virtual machines:

yum -y install iscsi-initiator-utils bridge-utils kvm perl-Sys-Virt 

\[root@x3250m4n01 ~\]# mkvm rhmn,rhcn1,slesmn,slescn1 

\[root@x3250m4n01 ~\]# makeconservercf rhmn,rhcn1,slesmn,slescn1 

tabch key=dhcpinterfaces site.value="x3250m4n01|private,default" 

chtab key=system passwd.username=root passwd.password=cluster 

chtab key=hmc passwd.username=hscroot passwd.password=abc123 

chtab key=blade passwd.username=USERID passwd.password=PASSW0RD 

chtab key=ipmi passwd.username=USERID passwd.password=PASSW0RD 

nodeset rhmn osimage=rhels6.3-x86_64-install-compute 

rpower rhmn on 

### 10\. Install xCAT on the new MN

\[root@rhmn network-scripts\]# cat ifcfg-eth0 

DEVICE="eth0" 

BOOTPROTO="static" 

HWADDR="42:5A:01:01:01:02" 

ONBOOT="yes" 

TYPE="Ethernet" 

UUID="bb6f3500-ee40-4670-bb07-1ed7faad5d5b" 

IPADDR=1.1.1.2 

NETMASK=255.255.0.0 

\[root@rhmn network-scripts\]# cat ifcfg-eth1 

DEVICE="eth1" 

BOOTPROTO="static" 

HWADDR="42:21:01:01:01:02" 

ONBOOT="yes" 

TYPE="Ethernet" 

UUID="b1e1f7fa-ceed-4166-b957-8283d19010ef" 

IPADDR=10.1.99.1 

NETMASK=255.255.0.0 

\[root@rhmn network-scripts\]# cat /etc/sysconfig/network 

NETWORKING=yes 

HOSTNAME=rhmn 

GATEWAY=1.1.1.1 \[root@rhmn network-scripts\]# 

yum -y install iscsi-initiator-utils bridge-utils kvm perl-Sys-Virt 

yum install xCAT 

\[root@rhmn ~\]# tabdump site 

  1. key,value,comments,disable 

"blademaxp","64",, 

"domain","clusters.com",, 

"fsptimeout","0",, 

"installdir","/install",, 

"ipmimaxp","64",, 

"ipmiretries","3",, 

"ipmitimeout","2",, 

"consoleondemand","no",, 

"master","1.1.1.2",, 

"forwarders","1.1.1.1",, 

"nameservers","1.1.1.2",, 

"maxssh","8",, 

"ppcmaxp","64",, 

"ppcretry","3",, 

"ppctimeout","0",, 

"powerinterval","0",, 

"syspowerinterval","0",, 

"sharedtftp","1",, 

"SNsyncfiledir","/var/xcat/syncfiles",, 

"nodesyncfiledir","/var/xcat/node/syncfiles",, 

"tftpdir","/tftpboot",, 

"xcatdport","3001",, 

"xcatiport","3002",, 

"xcatconfdir","/etc/xcat",, 

"timezone","New York",, 

"useNmapfromMN","no",, 

"enableASMI","no",, 

"db2installloc","/mntdb2",, 

"databaseloc","/var/lib",, 

"sshbetweennodes","ALLGROUPS",, 

"dnshandler","ddns",, 

"vsftp","n",, 

"cleanupxcatpost","no",, 

"dhcplease","43200",, 

\[root@rhmn ~\]# 

update /etc/hosts 

makedns 

### 11\. define and manage the vms on the new MN

To use SLES MN manage kvm virtual machines, need to copy the SDK ISO, and install: 

zypper ar file:///install/sles11.2/x86_64/1 sles11.2 

zypper ar file:///install/sles11.2/x86_64/sdk1/ 

zypper install bridge-utils iscsitarget libvirt libvirt-devel kvm libvirt-devel gcc 

Download Sys::Virt from CPAN http://backpan.perl.org/authors/id/D/DA/DANBERR/Sys-Virt-0.9.5.tar.gz 

tar zxvf Sys-Virt-0.9.5.tar.gz 

cd Sys-Virt-0.9.5 

perl Makefile.PL 

make 

sudo make install 

  
Enjoy... 

### 12\. To add new machines

On the KVM host: 

1\. define new hosts in /etc/hosts 

2\. makedns 

3\. create new disk partitions 

4\. define new nodes. 

5\. run mkvm... 

6\. run nodeset 

7\. rpower 
