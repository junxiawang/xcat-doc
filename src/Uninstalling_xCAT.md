<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Removing xCAT](#removing-xcat)
  - [**Backup your xCAT database** ( if you want to keep it)](#backup-your-xcat-database--if-you-want-to-keep-it)
  - [Save your node information](#save-your-node-information)
  - [Save your networks information](#save-your-networks-information)
  - [Clean up tftpboot](#clean-up-tftpboot)
  - [Cleanup dhcp](#cleanup-dhcp)
  - [Clean up /etc/hosts](#clean-up-etchosts)
  - [Remove nodes from DNS](#remove-nodes-from-dns)
  - [**Stop xcatd and clean up network services**](#stop-xcatd-and-clean-up-network-services)
    - [**Stop xcatd**](#stop-xcatd)
    - [**Clean up network services(Optional)**](#clean-up-network-servicesoptional)
- [Remove xCAT rpms](#remove-xcat-rpms)
  - [**Remove OSS prerequisites installed for xCAT(Optional)**](#remove-oss-prerequisites-installed-for-xcatoptional)
  - [**Remove root ssh keys(Optional)**](#remove-root-ssh-keysoptional)
  - [**Remove xCAT credentials**](#remove-xcat-credentials)
  - [**Remove xCAT data directories**](#remove-xcat-data-directories)
  - [**Remove Extraneous files**](#remove-extraneous-files)
  - [**Clean up system files that were updated by xCAT (optional)**](#clean-up-system-files-that-were-updated-by-xcat-optional)
- [Remove Databases](#remove-databases)
- [Document Test Record](#document-test-record)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Removing xCAT

### **Backup your xCAT database** ( if you want to keep it)
    
    dumpxCATdb -p <path to where to save the database>
    

### Save your node information

To create a stanza file of your node definitions (all group), run the following: 
    
    lsdef -z all
    

### Save your networks information

To create a stanza file of your network information, run the following: 

  

    
    lsdef -z -t network -l 
    

### Clean up tftpboot

To clean up the node information in tftpboot 
    
      nodeset all offline
    

### Cleanup dhcp

You may want to remove all nodes from dhcp. 
    
    makedhcp -d <noderange>
    

### Clean up /etc/hosts

You may want to remove you cluster nodes from /etc/hosts 
    
    vi /etc/hosts
    tabedit hosts  (remove all the nodes from the hosts table)
    
    

### Remove nodes from DNS

After removing all the nodes from /etc/hosts and the hosts table. 
    
    makedns -n
    

### **Stop xcatd and clean up network services**

#### **Stop xcatd**

For Linux: 
    
    service xcatd stop
    

  
For AIX: 

  

    
    stopsrc -s xcatd
    

#### **Clean up network services(Optional)**

xCAT uses various network services on the management node and service nodes, the network services setup by xCAT may need to be cleaned up on the management node and service nodes before uninstalling xCAT. 

  * NFS: stop nfs service, unexport all the file systems exported by xCAT, and remove the xCAT file systems from /etc/exports. 
  * HTTP: stop http service, remove the xcat.conf in the http configuration directory. 
  * TFTP: stop tftp service, remove the tftp files created by xCAT in tftp directory. 
  * DHCP: stop dhcp service, remove the configuration made by xCAT in dhcp configuration files. 
  * DNS: stop the named service, remove the named entries created by xCAT from the named database. 

## Remove xCAT rpms

Run rpm -qa | grep xCAT and remove the rpms output as in the example: 

  

    
    xCAT-nbkernel-x86_64-2.6.18_92-4.noarch
    xCAT-nbkernel-ppc64-2.6.18_92-4.noarch
    xCAT-nbroot-oss-x86_64-2.0-snap200801291344.noarch
    xCAT-web-2.2-snap200904011710.noarch
    xCAT-server-2.3-snap200907061256.noarch
    xCAT-rmc-2.3-snap200905291339.noarch
    xCAT-2.3-snap200907061256.x86_64
    xCAT-nbroot-core-ppc64-2.3-snap200907061256.noarch
    xCAT-nbkernel-x86-2.6.18_92-4.noarch
    xCAT-nbroot-oss-x86-2.0-snap200804021050.noarch
    xCAT-nbroot-oss-ppc64-2.0-snap200801291320.noarch
    xCAT-client-2.3-snap200907061256.noarch
    perl-xCAT-2.3-snap200907061256.noarch
    xCAT-nbroot-core-x86-2.3-snap200907061256.noarch
    xCAT-nbroot-core-x86_64-2.2-snap200904010841.noarch
    

### **Remove OSS prerequisites installed for xCAT(Optional)**
    
    rpm -e fping-2.2b1-1
    rpm -e perl-Digest-MD5-2.36-1
    rpm -e perl-Net_SSLeay.pm-1.30-1
    rpm -e perl-IO-Socket-SSL-1.06-1
    rpm -e perl-IO-Stty-.02-1
    rpm -e perl-IO-Tty-1.07-1
    rpm -e perl-Expect-1.21-1
    rpm -e conserver-8.1.16-2
    rpm -e expect-5.42.1-3
    rpm -e tk-8.4.7-3
    rpm -e tcl-8.4.7-3
    rpm -e perl-DBD-SQLite-1.13-1
    rpm -e perl-DBI-1.55-1
              .
              .
              .
    

### **Remove root ssh keys(Optional)**
    
    rm -rf $ROOTHOME/.ssh (Be caution: do not remove the $ROOTHOME/.ssh if do not plan to remove /install/postscripts/_ssh directory)
    

### **Remove xCAT credentials**
    
     rm -rf $ROOTHOME/.xcat
    

### **Remove xCAT data directories**

For Linux: 
    
    rm -rf /install (for AIX this include the nim directory with images which you may not want to remove)
    

For AIX or Linux: 
    
    rm -rf /tftpboot/xcat* (**Note: Remember to uninstall the packages elilo-xcat and xnba-undi, otherwise the next install of xCAT will fail.**)
    rm -rf /tftpboot/etc
    rm -rf /etc/xcat
    rm -rf /etc/sysconfig/xcat ( may not exist)
    rm /mnt/xcat
    

### **Remove Extraneous files**
    
    rm /tmp/genimage*
    rm /tmp/packimage*
    rm /tmp/mknb*
    rm /etc/yum.repos.d/*
    

### **Clean up system files that were updated by xCAT (optional)**

There are multiple system configuration files that may have been updated while using xCAT to manage your cluster. In most cases you can determine what files have been updated by understanding the function of the commands that you run or by reading the xCAT documentation. There is no automated way to know what files should be cleaned up or removed. You will have to determine on a case by case basis whether or not a particular file should be updated to remove any leftover entries. 

  
For example, on AIX management nodes the /etc/profile and /etc/environment files are automatically updated by xCAT when it was installed. They include updates to the PATH (for xCAT and possibly MySQL) and PERL5LIB environment variables. It is not likely that these additions would cause a problem if they were left in the files but you can remove them if desired. 

## Remove Databases

For PostgreSQL: See [Removing xCAT from PostgreSQL](Setting_Up_PostgreSQL_as_the_xCAT_DB/#removing-postgresql-database)

For DB2: See [Removing xCAT from DB2](Setting_Up_DB2_as_the_xCAT_DB/#removing-xcat-from-db2-and-the-xcat-db2-database) 

For MySQL: [Removing MySQL xcatd Database](Setting_Up_MySQL_as_the_xCAT_DB/#removing-mysql-xcatd-database) 

## Document Test Record
Tested by Ting Ting Li on Aug. 6 2014 against xCAT 2.8.5