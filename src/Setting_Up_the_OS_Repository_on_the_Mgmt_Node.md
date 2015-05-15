<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Get the Requisite Packages From the Distro**](#get-the-requisite-packages-from-the-distro)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## **Get the Requisite Packages From the Distro**

xCAT depends on several packages that come from the Linux distro. Follow this section to create the repository of the OS on the Management Node. 

  
**\[RHEL\] Setup repository**

To make the necessary RHEL RPM prereqs available to the xCAT install process, mount the RHEL CD/DVD or ISO and then create a repo file in /etc/yum.repos.d that points to it. 

  
**If you have the RHEL iso files:**

**If the RHEL distro only has one iso file:**

Copy the iso file to any directory, such as /iso 
    
    mkdir /iso
    cp RHEL5.2-Server-20080430.0-ppc-DVD.iso /iso/
    

Mount the iso file to a directory such as /iso/rhels5.2 
    
    cd /iso
    mkdir /iso/rhels5.2
    mount -o loop RHEL5.2-Server-20080430.0-ppc-DVD.iso /iso/rhels5.2
    

Create a YUM repository file, for example, rhel-dvd.repo, under directory /etc/yum.repos.d. The YUM repository contents should look like: 
    
    [rhe-5-server]
    name=RHEL 5 SERVER packages
    baseurl=file:///iso/rhels5.2/Server
    enabled=1
    gpgcheck=1
    

Note: To make the YUM repository work persistently after management node reboot, the iso mount needs to be added into the /etc/fstab, or add the mount command into Linux startup scripts. 

  
**If the RHEL distro has more than one iso files**

**For each iso file:**

  * Loopback mount the iso file 
  * For the 1st iso file only, cd to the mounted directory and run: rpm --import RPM-GPG-KEY-redhat-release 
  * Copy the RPMs from the Server subdirectory of the mounted directory to a directory on your hard disk (for example /rhels5.3). You can put the RPMs from all of the iso files into the same directory. 
  * cd into the newly created RPM directory, install the createrepo RPM, and run: createrepo . 
  * Create a YUM repository file, for example, rhel-cd.repo, in directory /etc/yum.repos.d. The YUM repository contents should look like: 
    
    [rhel-5.3]
    name=RHEL 5.3 from directory
    baseurl=file:///rhels5.3
    enabled=1
    gpgcheck=1
    

  
**For either case above:**

change directory to where the RHEL CD image is and run 
    
    cd /iso/rhels5.2
    rpm --import RPM-GPG-KEY-redhat-release
    

Check that the repo is set up correctly by looking for one rpm: 
    
    yum list screen
    

**Note:** For RHEL 6.1 and RHEL 6.2 on x86_64 platform, the package perl-Net-Telnet, which is required by xCAT, but is not included in the repository &lt;os_name&gt;/Server, you need to add the perl-Net-Telnet into the yum repository through whatever method, a simple way is to add a new yum repository that points to the &lt;os_name&gt;/HighAvailability: 
    
     [root@xcatmn ~]# cat /etc/yum.repos.d/rhels6.1.ha.repo 
     [rhe-6.1-server-ha]
     name=RHEL 6.1 HA packages
     baseurl=file:///iso/rhels6.1/x86_64/HighAvailability
     enabled=1
     gpgcheck=1
     [root@xcatmn ~]# 
    

**\[SLES\] Setup repository**

If you have a SLES ISO: 
    
    mkdir /iso
    copy SLES11-DVD-ppc-GM-DVD1.iso to /iso/
    mkdir /iso/1
    cd /iso
    mount -o loop SLES11-DVD-ppc64-GM-DVD1.iso 1
    zypper ar [../../../iso/1 file:///iso/1] sles11
    or
    zypper ar file:///iso/1  sles11
    

Check that the repo is set up correctly by looking for one rpm: 
    
    zypper search --match-exact -s screen
    

  
**\[FEDORA\] Setup the repository**

If your management node _has access_ to the internet, you can simply create a file called **/etc/yum.repos.d/fedora-internet.repo** that contains: 
    
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
    

Check that the repo is set up correctly by looking for one rpm: 
    
    yum list screen
    

  
If your management node _does not have internet access_, then download the iso of Fedora OS and setup the repository like **\[RHEL\] Setup repository** part. 