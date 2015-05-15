<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Get the xCAT Installation Source**](#get-the-xcat-installation-source)
  - [**Option 1: Prepare for the Install of xCAT without Internet Access**](#option-1-prepare-for-the-install-of-xcat-without-internet-access)
  - [**Option 2: Use the Internet-hosted xCAT Repository**](#option-2-use-the-internet-hosted-xcat-repository)
    - [**Internet repo for xCAT-core**](#internet-repo-for-xcat-core)
    - [**Internet repo for xCAT-dep**](#internet-repo-for-xcat-dep)
- [**For both Options: Make Required Packages From the Distro Available**](#for-both-options-make-required-packages-from-the-distro-available)
- [**Install xCAT Packages**](#install-xcat-packages)
- [(Optional) Install the Packages for sysclone](#optional-install-the-packages-for-sysclone)
- [**Quick Test of xCAT Installation**](#quick-test-of-xcat-installation)
- [**Restart or Reload xcatd**](#restart-or-reload-xcatd)
- [**Updating xCAT Packages Later**](#updating-xcat-packages-later)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### **Get the xCAT Installation Source**

There are two options to get the installation source of xCAT: 

  1. download the xCAT installation packages 
  2. or install directly from the internet-hosted repository 

Pick either one, but not both. 

**Note:
    1. Due to the packages "net-snmp-libs" and "net-snmp-agent-libs"(required by "net-snmp-perl" in xcat-dep) are updated in Redhat 7.1 iso, a xcat-dep branch for Redhat 7.0 is created. Thus, please use the repo under "xcat-dep/rh7.0" for Redhat 7.0 and use "xcat-dep/rh7" for other Redhat 7 releases.  
    2. for CentOS and ScientificLinux, could use the same xcat-dep configuration with RHEL. For example, CentOS 7.0 could use xcat-dep/rh7.0/x86_64 as the xcat-dep repo.**

#### **Option 1: Prepare for the Install of xCAT without Internet Access**

If not able to, or not want to, use the live internet repository, choose this option. 

Go to the [Download xCAT](Download_xCAT) site and download the level of xCAT tarball you desire. Go to the [xCAT Dependencies Download](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/) page and download the latest snap of the xCAT dependency tarball. (The latest snap of the xCAT dependency tarball will work with any version of xCAT.) 

Copy the files to the Management Node (MN) and untar them: 
  
~~~~  
    mkdir /root/xcat2
    cd /root/xcat2
    tar jxvf xcat-core-2.*.tar.bz2     # or core-rpms-snap.tar.bz2
    tar jxvf xcat-dep-*.tar.bz2
~~~~
    

Point yum/zypper to the local repositories for xCAT and its dependencies: 

**\[RH\]:**
 
~~~~   
    cd /root/xcat2/xcat-dep/<release>/<arch>;
    ./mklocalrepo.sh
    cd /root/xcat2/xcat-core
    ./mklocalrepo.sh
~~~~    

**\[SLES 11, SLES12\]:**
  
~~~~  
     zypper ar file:///root/xcat2/xcat-dep/<os>/<arch> xCAT-dep 
     zypper ar file:///root/xcat2/xcat-core  xcat-core
~~~~    

**\[SLES 10.2+\]:**
 
~~~~   
    zypper sa file:///root/xcat2/xcat-dep/sles10/<arch> xCAT-dep
    zypper sa file:///root/xcat2/xcat-core xcat-core
~~~~    

#### **Option 2: Use the Internet-hosted xCAT Repository**

When using the live internet repository, you need to first make sure that name resolution on your management node is at least set up enough to resolve sourceforge.net. Then make sure the correct repo files are in /etc/yum.repos.d.

##### **Internet repo for xCAT-core**

You could use the **official release** or **latest snapshot build** or **development build**, based on your requirements.

* **To get the repo file for the current official release**: 

**\[RH\]:**

wget http://sourceforge.net/projects/xcat/files/yum/<xCAT-release\>/xcat-core/xCAT-core.repo 

for example: 
   
~~~~ 
    cd /etc/yum.repos.d
    wget http://sourceforge.net/projects/xcat/files/yum/2.8/xcat-core/xCAT-core.repo
~~~~

**\[SLES11, SLES12\]:**

~~~~
zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/<xCAT-release\>/xcat-core xCAT-core 
~~~~

for example: 
  
~~~~  
    zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/2.8/xcat-core xCAT-core
~~~~
        

**\[SLES10.2+\]:**
   
~~~~ 
    zypper sa http://sourceforge.net/projects/xcat/files/yum/<xCAT-release\>/xcat-core xCAT-core
~~~~ 

for example:

~~~~
     zypper sa http://sourceforge.net/projects/xcat/files/yum/2.8/xcat-core xCAT-core
~~~~

    
* **To get the repo file for the latest snapshot build, which includes the latest bug fixes, but is not completely tested:**

**\[RH\]:**

wget http://sourceforge.net/projects/xcat/files/yum/<xCAT-release\>/core-snap/xCAT-core.repo 

for example:

~~~~
    cd /etc/yum.repos.d
    wget http://sourceforge.net/projects/xcat/files/yum/2.8/core-snap/xCAT-core.repo
~~~~

**\[SLES11, SLES12\]:**

zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/<xCAT-release\>/core-snap xCAT-core 

for example: 
  
~~~~  
    zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/2.8/core-snap xCAT-core
~~~~        

**\[SLES10.2+\]:**
  
~~~~  
    zypper sa http://sourceforge.net/projects/xcat/files/yum/<xCAT-release\>/core-snap xCAT-core 
~~~~

for example:

~~~~
     zypper sa http://sourceforge.net/projects/xcat/files/yum/2.8/core-snap xCAT-core
~~~~

* **To get the repo file for the latest development build, which is the snap shot build of the new version we are actively developing. This version has not been released yet. Use at your own risk:**

**\[RH\]:**

~~~~
    wget http://sourceforge.net/projects/xcat/files/yum/devel/core-snap/xCAT-core.repo
~~~~

**\[SLES11, SLES12\]:**

~~~~
    zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/devel/core-snap xCAT-core 
~~~~      

**\[SLES10.2+\]:**
    
~~~~
    zypper sa http://sourceforge.net/projects/xcat/files/yum/devel/core-snap xCAT-core 
~~~~

##### **Internet repo for xCAT-dep**

**To get the repo file for xCAT-dep packages:** 

** \[RH\]:**

wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/<OS-release\>/<arch\>/xCAT-dep.repo 

for example: 
    
    wget http://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64/xCAT-dep.repo
    

**\[SLES11, SLES12\]:**

zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/xcat-dep/<OS-release\>/<arch\> xCAT-dep 

for example: 
    
    zypper ar -t rpm-md http://sourceforge.net/projects/xcat/files/yum/xcat-dep/sles11/x86_64 xCAT-dep
        

**\[SLES10.2+\]:**
    
    zypper sa http://sourceforge.net/projects/xcat/files/yum/xcat-dep/<OS-release\>/<arch\> xCAT-dep

for example:

    zypper sa http://sourceforge.net/projects/xcat/files/yum/xcat-dep/sles10/x86_64 xCAT-dep
        

### **For both Options: Make Required Packages From the Distro Available**

xCAT uses on several packages that come from the Linux distro. Follow this section to create the repository of the OS on the Management Node. 

See the following documentation: 

[Setting Up the OS Repository on the Mgmt Node](Setting_Up_the_OS_Repository_on_the_Mgmt_Node) 

### **Install xCAT Packages**

\[RH\]: Use yum to install xCAT and all the dependencies: 
    
    yum clean metadata  
    
or
    yum clean all

then
    yum install xCAT
    

\[SLES\]Use zypper to install xCAT and all the dependencies: 
    
    zypper install xCAT
    

### (Optional) Install the Packages for sysclone

Note:syslcone is not supported on SLES.

In xCAT 2.8.2 and above, xCAT supports cloning new nodes from a pre-installed/pre-configured node, we call this provisioning method as **sysclone**. It leverages the opensource tool [systemimager](http://www.systemimager.org). xCAT ships the required systemimager packages with xcat-dep. If you will be installing stateful(diskful) nodes using the **sysclone** provmethod, you need to install systemimager and all the dependencies: 

\[RH\]: Use yum to install systemimager and all the dependencies: 
    
    yum install systemimager-server
    

\[SLES\]: Use zypper to install systemimager and all the dependencies: 
    
    zypper install systemimager-server
    

### **Quick Test of xCAT Installation**

Add xCAT commands to the path by running the following: 
    
    source /etc/profile.d/xcat.sh
    

Check to see the database is initialized: 
    
    tabdump site
    

The output should similar to the following: 

~~~~    
    key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "installdir","/install",,
         .
         .
         .
~~~~    

If the tabdump command does not work, see [Debugging xCAT Problems](Debugging_xCAT_Problems). 

### **Restart or Reload xcatd**

**If you really encountered certain problem that xcat daemon failed to function, you can try to restart the xcat daemon.**

\[For xcat daemon is running on NON-systemd enabled Linux OS like rh6.x and sles11.x\]

~~~~
    service xcatd restart
~~~~

\[For xcat daemon is running on systemd enabled Linux OS like rh7.x and sles12.x. And AIX.\]

~~~~
    restartxcatd
~~~~

Refer to the doc of restartxcatd to get the information why you need to use it for systemd enabled system.

**If you want to restart xcat daemon but do not want to reconfigure the network service on the management (this will restart xcat daemon quickly for a large cluster).**

\[For xcat daemon is running on NON-systemd enabled Linux OS like rh6.x and sles11.x\]

~~~~
    service xcatd reload
~~~~

\[For xcat daemon is running on systemd enabled Linux OS like rh7.x and sles12.x. And AIX.\]

~~~~
    restartxcatd -r
~~~~

**If you want to rescan plugin when you added a new plugin, or you changed the subroutine handled_commands of certain plugin.**

~~~~
    rescanplugins
~~~~

### **Updating xCAT Packages Later**

If you need to update the xCAT RPMs later: 

  * **If the management node does not have access to the internet**: download the new version of xCAT from [Download xCAT](Download_xCAT) and the dependencies from [xCAT Dependencies Download](http://sourceforge.net/project/showfiles.php?group_id=208749&package_id=258529&release_id=608981) and untar them in the same place as before. 
  * **If the management node has access to the internet**, the commands below will pull the updates directly from the xCAT site. 

To update xCAT: 

\[RH\]: 

~~~~    
    yum clean metadata or you may need to use yum clean all
    yum update '*xCAT*'
~~~~    

\[SLES\]: 

~~~~    
    zypper refresh
    zypper update -t package '*xCAT*'
~~~~    

Note: this will not apply updates that may have been made to some of the xCAT deps packages. (If there are brand new deps packages, they will get installed.) In most cases, this is ok, but if you want to make all updates for xCAT rpms and deps, run the following command. This command will also pick up additional OS updates. 

\[RH\]: 

~~~~    
    yum update
~~~~    

\[SLES\]: 

~~~~    
    zypper refresh
    zypper update
~~~~    

**Note:** Sometimes zypper refresh fails to refresh zypper local repository. Try to run zypper clean to clean local metadata, then use zypper refresh. 

**Note:** If you are updating from xCAT 2.7.x (or earlier) to xCAT 2.8 or later, there are some additional migration steps that need to be considered: 

  1. Switch from xCAT IBM HPC Integration support to using Software Kits - see 
[IBM_HPC_Software_Kits#Switching_from_xCAT_IBM_HPC_Integration_Support_to_Using_Software_Kits](IBM_HPC_Software_Kits/#switching-from-xcat-ibm-hpc-integration-support-to-using-software-kits)
 for details. 
  2. (Optional) Use nic attibutes to replace the otherinterfaces attribute to configure secondary see [Cluster_Name_Resolution](Cluster_Name_Resolution) for details. 
  3. Convert non-osimage based system to osimage based system - see
[Convert_Non-osimage_Based_System_To_Osimage_Based_System](Convert_Non-osimage_Based_System_To_Osimage_Based_System) for details
 