<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Hardware features required**](#hardware-features-required)
  - [**[SLES] Setup Zypper**](#sles-setup-zypper)
- [**Prepare For the Download and Install of xCAT For an MN That Does _Not Have_ Direct Internet Access**](#prepare-for-the-download-and-install-of-xcat-for-an-mn-that-does-_not-have_-direct-internet-access)
  - [Download and Unpack the Tarballs](#download-and-unpack-the-tarballs)
  - [Setup YUM or zypper repositories for xCAT and Dependencies](#setup-yum-or-zypper-repositories-for-xcat-and-dependencies)
- [**Get the Requisite Packages From the Distro**](#get-the-requisite-packages-from-the-distro)
- [**Install xCAT and Dependencies on the MN (yum/zypper)**](#install-xcat-and-dependencies-on-the-mn-yumzypper)
  - [**Additional Steps**](#additional-steps)
- [**Install xCAT and Deps on the MN ( without yum/zypper)**](#install-xcat-and-deps-on-the-mn--without-yumzypper)
- [**Test xCAT Installation**](#test-xcat-installation)
- [**Update xCAT Software at a Later Time**](#update-xcat-software-at-a-later-time)
  - [Without Yum/Zypper](#without-yumzypper)
  - [With Yum/Zypper](#with-yumzypper)
- [**Appendix A: Network Table Setup Example**](#appendix-a-network-table-setup-example)
- [**Appendix B: Migrate your Management Node to a new Service Pack of Linux**](#appendix-b-migrate-your-management-node-to-a-new-service-pack-of-linux)
- [**Appendix C: Install your Management Node to a new Release of Linux**](#appendix-c-install-your-management-node-to-a-new-release-of-linux)
- [**Appendix D: Upgrade your Management Node to a new Service Pack of Linux**](#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux)
  - [**D.1. Prior to the upgrade**](#d1-prior-to-the-upgrade)
  - [**D.2 Upgrade from DVD**](#d2-upgrade-from-dvd)
  - [**D.3 Upgrade using installer (good only for minor upgrade)**](#d3-upgrade-using-installer-good-only-for-minor-upgrade)
  - [**D.4 After the upgrade**](#d4-after-the-upgrade)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**Note: this document is no longer maintained, the same information is available in the [XCAT_iDataPlex_Cluster_Quick_Start] and the [XCAT_iDataPlex_Advanced_Setup] documents. They can be used to setup the Linux Management node, even if your cluster is not iDataPlex.**

**If you are using Flex servers follow [XCAT_system_x_support_for_IBM_Flex] or [XCAT_system_p_support_for_IBM_Flex] to set up the management node.**

  



## **Hardware features required**

Hardware requirements for your xCAT management node are dependent on your cluster size and configuration. A minimum requirement for an xCAT Management Node or Service Node that is dedicated to running xCAT to install a small cluster ( &lt;release&gt;/&lt;arch&gt;/xCAT-dep.repo . For example: 
  
~~~~  
    wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/ppc64/xCAT-dep.repo
~~~~ 
    

### **[SLES] Setup Zypper**

**[SLES11]:**
 
~~~~   
    zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/stable/xcat-core xCAT-core
    
    
    zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/xcat-dep/<release>/<arch> xCAT-dep
    
~~~~
  


**[SLES10.2+]:**

~~~~
    
    zypper sa -t rpm-md http://sourceforge.net/projects/xcat/files/yum/stable/xcat-core xCAT-core 
    
    
    zypper sa -t rpm-md http://sourceforge.net/projects/xcat/files/yum/xcat-dep/<release>/<arch> xCAT-dep
~~~~    

## **Prepare For the Download and Install of xCAT For an MN That Does _Not Have_ Direct Internet Access**

### Download and Unpack the Tarballs

Go to the [Download_xCAT] site and download the level of xCAT tarball you want. Go to the [xCAT Dependencies Download](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux) page and download the latest xCAT dependency tarball. 

Copy the xCAT tarball files to the Management Node (MN) and untar them: 
   
~~~~ 
    mkdir /root/xcat2
    cd /root/xcat2
    tar jxvf xcat-dep-*.tar.bz2
    tar jxvf xcat-core-2.*.tar.bz2
           OR
    tar jxvf core-rpms-snap.tar.bz2
~~~~    

### Setup YUM or zypper repositories for xCAT and Dependencies

Point yum/zypper to the local repositories for xCAT and its dependencies: 

**[RH]**

~~~~
    
    cd /root/xcat2/xcat-dep/&lt;release&gt;/&lt;arch&gt;
    ./mklocalrepo.sh
    cd /root/xcat2/xcat-core
    ./mklocalrepo.sh
~~~~    

  
**[SLES 11]:**

~~~~
    
     zypper ar file:///root/xcat2/xcat-dep/sles11/&lt;arch&gt; xCAT-dep 
     zypper ar file:///root/xcat2/xcat-core  xcat-core
~~~~    

You can check a zypper repository using "zypper lr -d", or remove a zypper repository using "zypper rr". 

**[SLES 10.2+]:**

~~~~
    
    zypper sa file:///root/xcat2/xcat-dep/sles10/&lt;arch&gt; xCAT-dep
    zypper sa file:///root/xcat2/xcat-core xcat-core
~~~~    

You can check a zypper repository using "zypper sl -d", or remove a zypper repository using "zypper sd". 

## **Get the Requisite Packages From the Distro**

xCAT depends on several packages that come from the Linux distro. Follow this section to create the repository of the OS on the Management Node. 

  
**[RHEL] Setup repository**

To make the necessary RHEL RPM prereqs available to the xCAT install process, mount the RHEL CD/DVD or ISO and then create a repo file in /etc/yum.repos.d that points to it. 

  
**If you have the RHEL iso files:**

**If the RHEL distro only has one iso file:**

Copy the iso file to any directory, such as /iso 

~~~~    
    mkdir /iso
    cp RHEL5.2-Server-20080430.0-ppc-DVD.iso /iso/
~~~~    

Mount the iso file to a directory such as /iso/rhels5.2 

~~~~    
    cd /iso
    mkdir /iso/rhels5.2
    mount -o loop RHEL5.2-Server-20080430.0-ppc-DVD.iso /iso/rhels5.2
~~~~    

Create a YUM repository file, for example, rhel-dvd.repo, under directory /etc/yum.repos.d. The YUM repository contents should look like: 
 
~~~~   
    [rhe-5-server]
    name=RHEL 5 SERVER packages
    baseurl=file:///iso/rhels5.2/Server
    enabled=1
    gpgcheck=1
~~~~    

Note: To make the YUM repository work persistently after management node reboot, the iso mount needs to be added into the /etc/fstab, or add the mount command into Linux startup scripts. 

  
**If the RHEL distro has more than one iso files**

**For each iso file:**

  * Loopback mount the iso file 
  * For the 1st iso file only, cd to the mounted directory and run: rpm --import RPM-GPG-KEY-redhat-release 
  * Copy the RPMs from the Server subdirectory of the mounted directory to a directory on your hard disk (for example /rhels5.3). You can put the RPMs from all of the iso files into the same directory. 
  * cd into the newly created RPM directory, install the createrepo RPM, and run: createrepo . 
  * Create a YUM repository file, for example, rhel-cd.repo, in directory /etc/yum.repos.d. The YUM repository contents should look like: 
 
~~~~   
    [rhel-5.3]
    name=RHEL 5.3 from directory
    baseurl=file:///rhels5.3
    enabled=1
    gpgcheck=1
~~~~    

  
**For either case above:**

change directory to where the RHEL CD image is and run 
 
 
~~~~  
    cd /iso/rhels5.2
    rpm --import RPM-GPG-KEY-redhat-release
~~~~    

Check that the repo is set up correctly by looking for one rpm: 
 
~~~~   
    yum list screen
~~~~    

  
**[SLES] Setup repository**

If you have a SLES ISO: 

~~~~    
    mkdir /iso
    copy SLES11-DVD-ppc-GM-DVD1.iso to /iso/
    mkdir /iso/1
    cd /iso
    mount -o loop SLES11-DVD-ppc-GM-DVD1.iso 1
    zypper ar [../../../iso/1 file:///iso/1] sles11
~~~~    

Check that the repo is set up correctly by looking for one rpm: 
  
~~~~  
    zypper search --match-exact -s screen
~~~~    

  
**[FEDORA] Setup the repository**

If your management node _has access_ to the internet, you can simply create a file called **/etc/yum.repos.d/fedora-internet.repo** that contains: 
 
~~~~   
    [fedora-everything]
    name=Fedora $releasever - $basearch
    failovermethod=priority
    #baseurl=http://download.fedora.redhat.com/pub/fedora/linux/releases/$releasever/Everything
    /$basearch/os/
    mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora [../../../etc/pki/rpm-gpg/RPM-GPG-KEY
    file:///etc/pki/rpm-gpg/RPM-GPG-KEY]
~~~~    

Check that the repo is set up correctly by looking for one rpm: 
 
~~~~   
    yum list screen
~~~~    

  
If your management node _does not have internet access_, then download the iso of Fedora OS and setup the repository like **[RHEL] Setup repository** part. 

For Fedora Operating System, xCAT still needs some packages which are not included in the installation iso, you need to download them from internet, copy them to the MN, and create a local YUM repository: 

  
**Note: The value of &lt;releasever&gt; in following link can be the release number of Fedora, it can be 8,9,12,13,14. **
    
    cd /root/xcat2/xcat-dep/fedoara/x86_64
    export BASEURL=http://download.fedora.redhat.com/pub/fedora/linux/releases/<releasever>/Everything/x86_64/os/Packages/
    
~~~~
  
**[Fedora8]**
    
    wget $BASEURL/perl-Net-SNMP-5.2.0-1.fc8.1.noarch.rpm
    wget $BASEURL/perl-XML-Simple-2.17-1.fc8.noarch.rpm
    wget $BASEURL/perl-Crypt-DES-2.05-4.fc7.x86_64.rpm
    wget $BASEURL/net-snmp-perl-5.4.1-4.fc8.x86_64.rpm
    wget $BASEURL/ksh-20070628-1.1.fc8.x86_64.rpm
    wget $BASEURL/perl-IO-Socket-INET6-2.51-2.fc8.1.noarch.rpm
    wget $BASEURL/dhcp-3.0.6-10.fc8.x86_64.rpm
    wget $BASEURL/syslinux-3.36-7.fc8.x86_64.rpm
    wget $BASEURL/mtools-3.9.11-2.fc8.x86_64.rpm
    wget $BASEURL/expect-5.43.0-9.fc8.x86_64.rpm
    wget $BASEURL/perl-DBD-SQLite-1.12-2.fc8.1.x86_64.rpm
    wget $BASEURL/perl-Expect-1.20-1.fc8.1.noarch.rpm
    wget $BASEURL/perl-IO-Tty-1.07-2.fc8.1.x86_64.rpm
    wget $BASEURL/scsi-target-utils-0.0-1.20070803snap.fc8.x86_64.rpm
    wget $BASEURL/perl-Net-Telnet-3.03-5.1.noarch.rpm
    wget $BASEURL/perl-TimeDate-1.16.6.fc8.noarch.rpm
    wget $BASEURL/perl-DateTime-0.41-1.fc8.x86_64.rpm
    wget $BASEURL/perl-DateTime-Set-0.25-4.fc7.noarch.rpm
    wget $BASEURL/perl-MailTools-1.77-2.fc8.noarch.rpm
    wget $BASEURL/perl-Set-Infinite-0.61-3.fc7.noarch.rpm
    wget $BASEURL/perl-MIME-Lite-3.01-5.fc8.1.noarch.rpm
    wget $BASEURL/perl-version-0.7203-2.fc8.x86_64.rpm
    wget $BASEURL/perl-SOAP-Lite-0.68-5.fc8.noarch.rpm
~~~~    

  
**[Fedora9]**

~~~~

You need to download rpm packages which are same with the Fedata8, but net-snmp-5.4.1-19.fc9 is needed for Fedora9. 
~~~~
  
[**Fedora12**] 

~~~~    
    wget $BASEURL/expect-5.43.0-19.fc12.i686.rpm
    wget $BASEURL/net-snmp-perl-5.4.2.1-18.fc12.x86_64.rpm
    wget $BASEURL/syslinux-3.75-4.fc12.x86_64.rpm
    wget $BASEURL/dhcp-4.1.0p1-12.fc12.x86_64.rpm
    wget $BASEURL/perl-XML-Simple-2.18-5.fc12.noarch.rpm
    wget $BASEURL/ksh-20090630-1.fc12.x86_64.rpm
    wget $BASEURL/perl-Test-Simple-0.92-82.fc12.x86_64.rpm
    wget $BASEURL/perl-Net-Telnet-3.03-9.fc12.noarch.rpm
    wget $BASEURL/ipmitool-1.8.11-4.fc12.x86_64.rpm
    wget $BASEURL/perl-Crypt-PasswdMD5-1.3-5.fc12.noarch.rpm
    wget $BASEURL/perl-DBD-SQLite-1.25-4.fc12.x86_64.rpm
~~~~    

  
**[Fedora13]**

~~~~
    
    wget $BASEURL/dhcp-4.1.1-15.fc13.x86_64.rpm
    wget $BASEURL/ipmitool-1.8.11-4.fc13.x86_64.rpm
    wget $BASEURL/syslinux-3.84-1.fc13.x86_64.rpm
    wget $BASEURL/ksh-20100309-3.fc13.x86_64.rpm
    wget $BASEURL/net-snmp-perl-5.5-12.fc13.x86_64.rpm
    wget $BASEURL/expect-5.43.0-19.fc12.i686.rpm
    wget $BASEURL/perl-Test-Simple-0.92-112.fc13.x86_64.rpm
    wget $BASEURL/perl-Crypt-PasswdMD5-1.3-6.fc13.noarch.rpm
    wget $BASEURL/perl-DBD-SQLite-1.27-3.fc13.x86_64.rpm
~~~~    

  
**[Fedora14]**

~~~~
    
    wget $BASEURL/expect-5.44.1.15-1.fc14.x86_64.rpm
    wget $BASEURL/ipmitool-1.8.11-5.fc14.x86_64.rpm
    wget $BASEURL/ksh-20100701-1.fc14.x86_64.rpm
    wget $BASEURL/net-snmp-perl-5.5-20.fc14.x86_64.rpm
    wget $BASEURL/perl-Crypt-SSLeay-0.58-1.fc14.x86_64.rpm
    wget $BASEURL/perl-DBD-SQLite-1.29-3.fc14.x86_64.rpm
    wget $BASEURL/perl-Test-Simple-0.94-2.fc14.noarch.rpm
    wget $BASEURL/perl-XML-LibXML-1.70-5.fc14.x86_64.rpm
    wget $BASEURL/perl-XML-NamespaceSupport-1.11-2.fc14.noarch.rpm
    wget $BASEURL/perl-XML-SAX-0.96-10.fc14.noarch.rpm
    wget $BASEURL/syslinux-4.02-3.fc14.x86_64.rpm
~~~~    

Since the dhcp packages of Fedara14 have issue to handle the omshell command, download the following two pakcages from fedora13 URL. 
 
~~~~   
    wget $BASEURL13/dhclient-4.1.1-15.fc13.x86_64.rpm
    wget $BASEURL13/dhcp-4.1.1-15.fc13.x86_64.rpm
~~~~    

At last, in this directory, run following command to create the local repository. 
 
~~~~   
    createrepo .
~~~~    

## **Install xCAT and Dependencies on the MN (yum/zypper)**

**[RH]:**

~~~~    
    yum clean metadata
    yum install xCAT    # or yum install xCAT --nogpgcheck
~~~~    

  
**[SLES]:**
 
~~~~   
    zypper install xCAT
~~~~    

To get to xCAT commands 
  
~~~~  
    source /etc/profile.d/xcat.sh
~~~~    

### **Additional Steps**

**[fedora15/redhat6.1]:**

xCAT built a new conserver-xcat rpm package to replace the conserver rpm package for fedora15 and later. The 2.7 version of xCAT (and later) will automatically require conserver-xcat. For earlier versions of xCAT, uninstall conserver and install conserver-xcat manually before installing or upgrading xCAT: 
   
~~~~ 
    rpm -e --force conserver
    yum install conserver-xcat
~~~~    

## **Install xCAT and Deps on the MN ( without yum/zypper)**

If you chose not to use yum or zypper, then you will be managing all the dependencies that are needed for xCAT and it's dependency package. You may want to make sure the entire OS is installed on the Management Node to avoid having to search for missing dependencies. We recommend that you use yum/zipper for the install to avoid having to worry about missing dependencies. 

You will need to download the xCAT rpms and dependencies as was described in Download and Install xCAT 2 For an MN That Does Not Have Internet Access. 

  


A list of all the dependencies and xCAT rpms must be input to rpm. There are cross dependencies, xCAT requires some dependency rpms and some of the dependency rpms require xCAT rpms. For xCAT 2.4 and greater, atftp rpm is replaced with atftp-xcat rpm. You need to remove atftp rpm from the xcat-dep/&lt;release&gt;/&lt;arch&gt; directory before running the following commands. 

  

~~~~    
    cd /root/xcat2
    rpm -Uvh xcat-dep/<release>/<arch>/*.rpm xcat-core/perl-xCAT*.rpm xcat-core/xCAT-2*.<arch>.rpm xcat-core/xCAT-client*.rpm 
    xcat-core/xCAT-nbroot-core*.rpm xcat-core/xCAT-server*.rpm --replacepkgs
~~~~    

  
for example: 
    
    rpm -Uvh xcat-dep/fedora9/x86_64/*.rpm xcat-core/perl-xCAT*.rpm xcat-core/xCAT-2*.x86_64.rpm xcat-core/xCAT-client*.rpm 
    xcat-core/xCAT-nbroot-core*.rpm xcat-core/xCAT-server*.rpm --replacepkgs
    

  
**You can add these optional rpms to the list:**

~~~~
xcat-core/xCAT-rmc*.rpm xcat-core/xCAT-IBMhpc*.rpm xcat-core/xCAT-UI*.rpm 
~~~~

for rmc monitoring, hpc stack support and the web interface. 

  
Do not install xCATsn*- this is only for a service node. 

  
Note: The tftp client in the open firmware of Power 5 is only compatible with tftp-server instead of atftp-xcat/atftp rpm which is required by xCAT2. So you have to remove the atftp-xcat/atftp rpm with --nodeps flag first and then install the tftp-server. This is not required for Power6 or later. 

The rpms installed on the MN, without the optional rpms, should look similar to this: 

  

~~~~
    
    xCAT-nbkernel-x86_64-2.6.18_92-4.noarch
    perl-xCAT-2.4-snap201005031505.noarch
    xCAT-nbkernel-ppc64-2.6.18_92-4.noarch
    xCAT-nbroot-oss-x86_64-2.0-snap200801291344.noarch
    xCAT-nbroot-core-ppc64-2.4-snap201005031505.noarch
    xCAT-nbkernel-x86-2.6.18_92-4.noarch
    xCAT-client-2.4-snap201005031505.noarch
    xCAT-nbroot-core-ppc64-2.4-snap201004300946.noarch
    xCAT-nbroot-oss-x86-2.0-snap200804021050.noarch
    xCAT-nbroot-oss-ppc64-2.0-snap200801291320.noarch
    xCAT-nbroot-core-x86-2.4-snap201005031505.noarch
    xCAT-2.4-snap201005031505.x86_64
    xCAT-nbroot-core-x86_64-2.2-snap200904010841.noarch
    xCAT-server-2.4-snap201005031505.noarch
~~~~    

**Install/Update Service Node ( without yum/zypper)**

You use the same process to as in the Install/Update xCAT and Deps on the MN ( without yum/zypper) for downloading and installing except one rpms changes. 

Instead of the installing the xcat-core/xCAT-2*.rpm which is for the MN, you will install the xcat-core/xCATsn-2*.rpm for the service node. 

  
So the command would look like the following: 

  
~~~~
    
    cd /root/xcat2
    rpm -Uvh xcat-dep/<release>/<arch>/*.rpm xcat-core/perl-xCAT*.rpm xcat-core/**xCATsn-2*.rpm** xcat-core/xCAT-client*.rpm 
    xcat-core/xCAT-nbroot-core*.rpm xcat-core/xCAT-server*.rpm --replacepkgs
~~~~    

## **Test xCAT Installation**

Add command to the path: 
  
~~~~  
    source /etc/profile.d/xcat.sh
~~~~    

  
Check to see the database is initialized: 
 
~~~~   
    tabdump site
~~~~    

  
The output should similar to the following: 
 
~~~~   
    key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "installdir","/install",,
         .
         .
~~~~         
    

## **Update xCAT Software at a Later Time**

If you need to update the xCAT 2 rpms later: 

### Without Yum/Zypper

  * **If the management node does not have access to the internet**: download the new version of [xCAT Download](http://xcat.sourceforge.net/#download) and untar and install as before. 
 
~~~~   
    cd /root/xcat2
    tar jxvf core-rpms-snap.tar.bz2
          OR
    tar jxvf xcat-core-2.x.tar.bz2
~~~~    

### With Yum/Zypper

  * If the management node has access to the internet, the yum/zypper command below will pull the updates directly from the xCAT site. 

  
**[RH]:**

If you want to just update the xCAT rpms then run the below command. Note: this will not apply the changes that may have been made to the xCAT deps packages. 
  
~~~~  
    yum update '*xCAT*'
~~~~    

  
If you want to make all updates for xCAT, xCAT rpms and deps, run the following command. This command may also pick up additional OS updates. 

  
~~~~

    
    yum update
~~~~    

  
**[SLES]:**

If you want to just update the xCAT rpms then run the below commands. Note: this will not apply the changes that may have been made to the xCAT deps packages. 
  
~~~~  
    zypper refresh
    zypper update -t package '*xCAT*'
~~~~    

  
If you want to make all updates for xCAT, xCAT rpms and deps, run the following commands. These command may also pick up additional OS updates. 

  

~~~~    
    zypper refresh
    zypper update
~~~~    

  
Note: If you have a service node stateless image in a hierarchical configuration , don't forget to update the image with the new xCAT rpms to keep the service node at the same level as the management Node. 

## **Appendix A: Network Table Setup Example**

[[img src=Networks_setup.png]] 

And the following table shows all network IP addresses of the cluster: 


Network Table 

<!---
begin_xcat_table;
numcols=3;
colwidths=20,10,30;
-->
  

|Machine name  |IP Address  |Alias 
|--------------|------------|----------------
|managementnode.pub.site.net|10.0.12.53|managementnode.site.net
|managementnode.priv.site.net|92.168.1.10| 
|node01.pub.site.net|10.0.12.61| 
|node02.pub.site.net|10.0.12.62| 
|node01.infiniband.site.net|10.0.6.236| 
|node02.infiniband.site.net|10.0.6.237| 
|node01.10g.site.net|10.0.17.14|node01.site.net 
|node02.10g.site.net|10.0.17.15|node02.site.net 
|node01.priv.site.net|192.168.1.21| 
|node02.priv.site.net|192.168.1.22|
 
<!---
end_xcat_table
-->

  
All networks in the cluster must be defined in the networks table which can be modified with the command chtab,chdef or with the command tabedit . 

The xCAT 2 installation ran the command makenetworks which created the following entry: 

~~~~    
    # tabdump networks
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,    logservers,dynamicrange,nodehostname,comments,disable
    "10_0_12_0-255_255_255_0","192.168.1.0","255.255.255.0","eth1"
    ,,,"192.168.1.10","10.0.12.10,10.0.17.10",,,,,,
    "192_168_1_0-255_255_255_0,"10.0.12.0","255.255.255.0","eth0"
    ,,,"10.0.12.53","10.0.12.10,10.0.17.10",,,,,,
~~~~    

  
• Update the private network of this table as follow: 
  
~~~~  
    # chdef -t network -o "pvtnet" net=192.168.1.0 mask=255.255.255.0 mgtifname=eth0\
    dhcpserver=192.168.1.10 tftpserver=192.168.1.10\
    nameservers=10.0.12.10,10.0.17.10\
    dynamicrange=192.168.1.21-192.168.1.22
~~~~    

• Disable the entry for the public network: 
 
~~~~   
    # chtab net=10.0.12.0 networks.disable=1
    # tabdump networks
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,  -
    logservers,dynamicrange,nodehostname,comments,disable
    "10_0_12_0-255_255_255_0","10.0.12.0","255.255.255.0","eth1",,,
    "10.0.12.53","10.0.12.10,10.0.17.10",,,,,,"1" 
    "pvtnet","192.168.1.0","255.255.255.0","eth0",,
    "192.168.1.10","192.168.1.10","10.0.12.10,10.0.17.10",,,"192.168.1.21-192.168.1.22",,,,,,
~~~~    

## **Appendix B: Migrate your Management Node to a new Service Pack of Linux**

If you need to migrate your xCAT Management Node with a new level of Linux, you should as a precautionary measure: 

  * Backup database and save critical files to be used if needed to reference or restore using xcatsnap. Move the xcatsnap log and *gz file off the Management Node. 
  * Backup images and custom data in /install and move off the Management Node. 
  * service xcatd stop 
  * service xcatd stop on any service nodes 
  * Migrate to the new level of Linux ( e.g. Redhat 6.0 to Redhat 6.1). 
  * service xcatd start 

If you have any Service Nodes: 

  * Migrate to the new level of linux or reinstall with the new level of linux. 
  * service xcatd start 

Note if you are using DB2 and moving from Redhat 6.0 and 6.1, you will have to upgrade from FixPack4 to FixPack5 of release 9.7 of DB2. [Setting_Up_DB2_as_the_xCAT_DB/#appendix_b_installing_db2_fix_packs](Setting_Up_DB2_as_the_xCAT_DB/#appendix_b_installing_db2_fix_packs) 

## **Appendix C: Install your Management Node to a new Release of Linux**

First backup critical xCAT data to another server so it will not be loss during OS install. 

  * Back up the xcat database using xcatsnap, important config files and other system config files for reference and for restore later. Prune some of the larger tables: 
  *     * tabprune eventlog -a 
    * tabprune auditlog -a 
    * tabprune isnm_perf -a (Power 775 only) 
    * tabprune isnm_perf_sum -a (Power 775 only) 
  * Run xcatsnap ( will capture database, config files) and copy to another host. By default it will create in /tmp/xcatsnap two files, for example: 
    * xcatsnap.hpcrhmn.10110922.log 
    * xcatsnap.hpcrhmn.10110922.tar.gz 
  * Back up from /install directory, all images, custom setup data that you want to save. and move to another server. xcatsnap will not backup images. 

After the OS install: 

  * Proceed to to setup the xCAT MN as a new xCAT MN using the instructions in this document. 

## **Appendix D: Upgrade your Management Node to a new Service Pack of Linux**

**Note: use this procedure at your own risk:**

**1) It is not fully tested.**

**2) It is not formally supported according to the Linux documentation.**

**3) This is only an example to upgrade RHEL 6 to RHEL 6.1, it _might_ work for similar upgrade scenarios.**

### **D.1. Prior to the upgrade**

Do the following before the upgrade: 

1. Stop xcatd, teal, cnmd and the db2 database on the management node. Service Nodes and compute nodes should be powered off per these instructions. 

2. Make a list of your system's current packages for later reference: 
  
~~~~  
       rpm -qa --qf '%{NAME} %{VERSION}-%{RELEASE} %{ARCH}' &gt; ~/old-pkglist.txt
~~~~    

3. (Optional, recommended by RedHat doc) Make a backup of any system configuration data and backup any other important data 
 
~~~~   
       tar czf /tmp/etc-`date +%F`.tar.gz /etc 
       mv /tmp/etc-*.tar.gz /home/
~~~~    

4. Record the kernel version and release info of your current system 
 
~~~~   
       uname -a
       cat /etc/*release*
~~~~    

Then you can choose either upgrade from DVD (D.2) or upgrade use installer (D.3). 

### **D.2 Upgrade from DVD**

Details of the OS upgrade process can be obtained from &lt;RedHat Enterprise Linux Installation Guide&gt; -upgrade an Existing Installation http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/pdf/Installation_Guide/Red_Hat_Enterprise_Linux-6-Installation_Guide-en-US.pdf 

Here are the basic steps: 

1. Insert RedHat 6.1 installation DVD to DVD-ROM (or other boot device) 

2. Reboot the system from a RedHat 6.1 installation DVD (or other boot media) 

3. Enter the kernel option linux upgradeany at the boot: prompt. 

4. Follow the dialog -Upgrade and Existing Installation ,then step by step 

### **D.3 Upgrade using installer (good only for minor upgrade)**

1. copycds /iso/RHEL6.1-20110510.1-Server-ppc64-DVD1.iso 

2. Modify the yum repository file under /etc/yum.repos.d, for example: 

Change from: 

~~~~    
    [rhe-6.0-server]
    
    name=RHEL 6.0 SERVER packages
    
    baseurl=file:///install/rhels6/ppc64/Server
    
    enabled=1
    
    gpgcheck=1
~~~~    

to: 
 
~~~~   
    [rhe-6.1-server]
    
    name=RHEL 6.1 SERVER packages
    
    baseurl=file:///install/rhels6.1/ppc64/Server 
    
    enabled=1
    
    gpgcheck=1
~~~~    

3. To ensure that you only upgrade RedHat in this step, temporarily rename/move all other repo definition files in the /etc/yum.repos.d directory. 

4. Perform upgrade 

~~~~    
       yum clean metadata
       yum -y update
~~~~    

During the update, I saw an error with updating glibc, not sure if it will impact the operating system: 

~~~~
    
     Updating:  glibc-2.12-1.25.el6.ppc64 

    Non-fatal POSTIN scriptlet failure in rpm package glibc-2.12-1.25.el6.ppc64 

    telinit:error.c:319: Assertion failed in nih_error_get: context_stack&nbsp;!= NULL 

    /usr/sbin/glibc_post_upgrade: While trying to execute /sbin/telinit child terminated  abnormally 

    warning: %post(glibc-2.12-1.25.el6.ppc64) scriptlet failed, exit status 118 
~~~~


4. Reboot the management node 

### **D.4 After the upgrade**

1. Verify the operating system has been updated 
  
~~~~  
       uname -a
       cat /etc/*release*
~~~~   

2. Check the operating system packages list, there might be some packages be uninstalled during the upgrade, reinstall any packages that were uninstalled during upgrade 
 
~~~~   
       awk '{print $1}' ~/old-pkglist.txt | sort | uniq &gt; ~/old-pkgnames.txt
       rpm -qa --qf '%{NAME}' | sort | uniq &gt; ~/new-pkgnames.txt
       diff -u ~/old-pkgnames.txt ~/new-pkgnames.txt | grep '^-' | sed 's/^-//' &gt; /tmp/pkgs-toinstall.txt
~~~~    

If there is any package name in /tmp/pkgs-toinstall.txt, you need to install these packages either using yum or rpm command 

3. Verify the network configuration files that are being used by xCAT are not changed, like: 
 
~~~~   
       /etc/dhcpd/dhcpd.conf
       /var/lib/dhcpd/dhcpd.leases
       /etc/ssh/sshd_config
       /etc/exports 
       /etc/httpd/conf.d/xcat.conf
~~~~    

(any other files that need to be checked?) 

4. Verify xcatd and some network services used by xCAT are still running, for example: 

~~~~    
       service xcatd status
       service named status
       service httpd status
       service xinetd status
       service ntpd status
       service vsftpd status
~~~~    

end of doc