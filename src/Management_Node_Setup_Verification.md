<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Overview**](#overview)
  - [**General**](#general)
  - [**Linux Specific**](#linux-specific)
  - [**AIX Specific**](#aix-specific)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## **Overview**

This design is for a routine that will verify the Management Node installation and database setup after install or upgrade. It is expect that the routine will continuously be updated with new checks as we find they are needed. The following checks are needed and appropriate warnings will be display. 

### **General**

  * Checks policy table for default xCAT policy setup (getpostscript, getcredentials,syncfiles,...) 
  * Runs Utils-&gt;checkCredFiles - which checks to see if ssh keys and credentials are setup for install 
  * The xCAT and dependency packages have been installed 
  * All the processes of xCAT have been started 
  * The xcatconfig has been run correctly. The attributes in the site,policy tables; the credentials (the files in .xcat/, .ssh/, /etc/xcat, /install/postscripts/); 
  * The syslog has been configured 
  * The service tftp, nfs, http, tftp, dhcp, conserver, dns have been started and has the correct configuration 
  * Disabled the selinux and iptables 
  * Network issue: 

    

  * Select the correct IP for site.master 
  * The correct network entries have been added into the networks table 
  * The dns has been configured correctly (site.domain, site.forward, site.nameserver, /etc/resolv.conf) 
  * dhcp listening port 

  * Database issue 

  
See [Health_Check_Script_Framework] mini-design for more ideas. 

### **Linux Specific**

### **AIX Specific**
