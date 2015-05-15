[Howto_Warning](Howto_Warning) 

This is a step by step for install xCAT2 and manage IBM Blade Center with examples of related tables for the configuration. 

**_Here is the Hardware configuration in the environment:_**

**1 x IBM BladeCenter™ H Chassis**

  * 2 x IBM BladeCenter™ Advanced Management Module 
  * 2 x Cisco Systems GbE Switch Module for IBM BladeCenter 
  * 1 x Cisco Systems 4Gb 20 port Fibre Channel Switch Module for IBM BladeCenter 

7 **x IBM HS21 Blade**

7 **x IBM HS22 Blade**

**1 x IBM x3550** **xServer**

**1 x IBM DS4700 Express Model 70**

**1 x 2950 Catalyst Cisco Lan Switch**

**Here is the Network Vlan configuration in the environment:**

  * Public Vlan: 192.168.80.x 
  * xCAT Vlan: 172.1.1.x 
  * Management Vlan: 192.168.70.x (BC AMM, BC Lan Switches, BC San Switches, RSA, Storage MM ...) 

 

 [[img src=Xcat-labv1.jpg]] 


  


  
  
**Here is the Operating System in the environment:**

  * xCAT2 server - RHEL5 U2 x86_64 
  * HS21 servers - RHEL5 U2 x86_64 
  * HS22 servers - RHEL5 U3 x86_64 

_**Install and Setup of xCAT2 server:**_

  1. mkdir -p /iso/1  

  2. cp /tmp/rhel-5.2-server-x86_64-dvd.iso /iso/  

  3. mount -o loop /iso/rhel-5.2-server-x86_64-dvd.iso /iso/1  

  4. mkdir /root/xcat2  

  5. cd /root/xcat2/  

  6. cp /tmp/xcat-core-2.1.1.tar.bz2 .  

  7. cp /tmp/xcat-dep-2.2-snap200902201712.tar.bz2 .  

  8. cd /root/xcat2/  

  9. tar -jxvf xcat-dep-2.2-snap200902201712.tar.bz2  

  10. tar -jxvf xcat-core-2.1.1.tar.bz2 

Verify that the following rpms installed - if not install them from the Redhat DVD:  
dhcpd, expect, httpd, nfs-utils, vsftpd, perl-XML-Parser, OpenIPMI 

Remove the following rpms if they are installed:  
tftp-server, OpenIPMI-tools  
**_Example:_**

  1. rpm -e tftp-server-0.42-3.1 

error: Failed dependencies:  
tftp-server &gt;= 0.29-3 is needed by (installed) system-config-netboot-cmd-0.1.45.1-1.el5.noarch 

  1. rpm -e --nodeps tftp-server-0.42-3.1 
  2. rpm -e OpenIPMI-tools-2.0.6-6.el5 
  1. cd xcat-dep/rh5/x86_64/ 
  2. ./mklocalrepo.sh  


root/xcat2/xcat-dep/rh5/x86_64 

  1. cd ../../../xcat-core 
  2. ./mklocalrepo.sh 

/root/xcat2/xcat-core 

You will need to copy the dependencies rpms from the Redhat DVD to the xcat-dep directory (in this case to - /root/xcat2/xcat-dep/rh5/x86_64)  
perl-Net-SSLeay, perl-XML-Simple, perl-Crypt-SSLeay, net-snmp-perl, ksh, perl-IO-Socket-INET6, syslinux, perl-Net-Telnet, createrepo  


  1. cd /root/xcat2/xcat-dep/rh5/x86_64  


For each rpm package run the following command:  


  1. cp /iso/1/Server/&lt;rpm&gt; . 

Install the createrepo rpm: 

  1. rpm -ihv /iso/1/Server/createrepo-0.4.11-3.el5.noarch.rpm 
  2. createrepo . 
  3. rpm --import /iso/1/RPM-GPG-KEY-redhat-release 



     To be continue this week... 
