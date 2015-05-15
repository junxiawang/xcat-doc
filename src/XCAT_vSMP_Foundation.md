<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [HOWTO Setup vSMP Foundation using xCAT](#howto-setup-vsmp-foundation-using-xcat)
- [Booting vSMP Foundation for Cloud from xCAT](#booting-vsmp-foundation-for-cloud-from-xcat)
- [PXE booting from vSMP Foundation for Cloud](#pxe-booting-from-vsmp-foundation-for-cloud)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

*****NOTE*** This is a new feature and has been submitted via tracker with ID: 2953727 to be included in v2.4**


## HOWTO Setup vSMP Foundation using xCAT

Directions for vSMP Foundation setup using xCAT and then explaining how to netboot an OS on the aggregated system. This example uses RHEL5.3, but any supported OS could be used in its place. 

  
This document will guide you through the process of setting up xCAT first to boot a vSMP Foundation system and then to PXE boot an OS from vSMP Foundation. The example below has the following setup: 

  * 2 node vSMP Foundation system - hostnames: scalemp-1, scalemp-2 
  * vSMP Foundation for Cloud 2.1 images 
  * PXE booting RHEL Server 5.3 netboot image 
  * ibm120 (10.0.0.10) is the management node/xCAT server 
  * all network services are running on ibm120 - dhcp server, tftp, named, etc 

## Booting vSMP Foundation for Cloud from xCAT

You will need to define nodes in hosts, mac, and nodelist tables. 
    
    
    tabedit mac
    
    #node,interface,mac,comments,disable
    "scalemp-1","eth0","00:24:E8:60:C2:7D",,
    "scalemp-2","eth0","00:24:E8:60:BC:D4",,
    
    tabedit hosts
    
    #node,ip,hostnames,otherinterfaces,comments,disable
    "scalemp-1","10.0.0.12",,,,
    "scalemp-2","10.0.0.13",,,,
    
    # tabedit nodelist
    
    #node,groups,status,appstatus,primarysn,comments,disable
    "scalemp-1","compute,all","booted",,,,
    "scalemp-2","compute,all","configuring",,,,
    

With that information we can now build some of the required config files. 

Run the following: 
    
    
     makehosts all
     makedhcp -n
     makedhcp all
     service dhcpd restart
    

You should also verify that dhcpd is set to run on startup. Next we need to setup DNS. 

Edit /etc/resolv.conf where (xcat_dom) and (xcat_int_ip) are the domain and internal IP you wish to use. 
    
    
    vi /etc/resolv.conf
    
    set "search (xcat_dom)"
    set "nameserver (xcat_int_ip)"
    

Now build the DNS server 
    
    
     makedns
     makedns all
     service named restart
    

Also verify that the named server will begin on startup. 

Define an entry in noderes which will be used for these nodes. Usually compute is fine. 
    
    
    tabedit noderes
    
    #node,servicenode,netboot,tftpserver,nfsserver,monserver,nfsdir,installnic,primarynic,cmdinterface,xcatmaster,current_osimage,next_osimage,nimserver,comments,disable
    "compute",,"pxe","10.0.0.10","10.0.0.10",,,"eth0","eth0",,,,,,,
    

Define an entry in the networks table for the networks which need to be defined. 
    
    
    tabedit networks
    
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,comments,disable
    ,"10.0.0.0","255.255.255.0","eth0","10.0.0.1","10.0.0.10","10.0.0.10","10.0.0.10",,,"10.0.0.11-10.0.0.254",,,
    

Create an entry for a primary and secondary boot profiles in the boottarget table, referring to memdisk as the kernel and the vSMP Foundation image file as the initrd. 

You will need to generate your own image files and place them in /tftpboot. Here I've generated a primary and secondary image of 2.1 and placed them in /tftpboot. 
    
    
    tabedit boottarget
    
    #bprofile,kernel,initrd,kcmdline,comments,disable
    "scalemp-primary","memdisk","scalemp.2.1.p",,,
    "scalemp-secondary","memdisk","scalemp.2.1.s",,,
    

Define the nodes in the nodetype table and use the boot profile which should be used for that particular node (ex: primary or secondary) 
    
    
    tabedit nodetype
    
    #node,os,arch,profile,nodetype,comments,disable
    "scalemp-1","boottarget","x86_64","scalemp-primary",,,
    "scalemp-2","boottarget","x86_64","scalemp-secondary",,,
    

Run nodeset on each node 
    
    
    nodeset scalemp-[1-2] netboot
    

## PXE booting from vSMP Foundation for Cloud

Define a new vm node, which has the same name as the primary node with "-vsmp" appended to it. You **must** follow this naming convention. 

Add it to the nodelist table: 
    
    
    tabedit nodelist
    
    #node,groups,status,appstatus,primarysn,comments,disable
    "scalemp-1","compute,all","booted",,,,
    "scalemp-2","compute,all","configuring",,,,
    "scalemp-1-vsmp","vsmp,all","booted",,,,
    

Add it to noderes with netboot type of vsmppxe 
    
    
    tabedit noderes
    
    #node,servicenode,netboot,tftpserver,nfsserver,monserver,nfsdir,installnic,primarynic,cmdinterface,xcatmaster,current_osimage,next_osimage,nimserver,comments,disable
    "scalemp-1-vsmp",,"vsmppxe","10.0.0.10","10.0.0.10",,,"eth0","eth0",,,,,,,
    "compute",,"pxe","10.0.0.10","10.0.0.10",,,"eth0","eth0",,,,,,,
    

Add an entry for the vm node in the nodetype table with rhels5.3 as the OS (if an OS image not already present you'll have to run genimage, packimage, etc) 
    
    
    tabedit nodetype
    
    #node,os,arch,profile,nodetype,comments,disable
    "scalemp-1","boottarget","x86_64","scalemp-primary",,,
    "scalemp-2","boottarget","x86_64","scalemp-secondary",,,
    "scalemp-1-vsmp","rhels5.3","x86_64","vsmp",,,
    

Run nodeset on the vm node. 
    
    
    nodeset scalemp-1-vsmp netboot
    

That's it! Now powercycle the nodes and they should first load vSMP Foundation and then if the boot device in vSMP Foundation is set to PXE boot from the first NIC on the primary it will load the RHEL 5.3 netboot image. 
