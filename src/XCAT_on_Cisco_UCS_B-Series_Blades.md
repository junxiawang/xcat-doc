<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Install xCAT-cisco RPM](#install-xcat-cisco-rpm)
  - [Install from latest binary builds](#install-from-latest-binary-builds)
  - [build latest xCAT-cisco RPM from github](#build-latest-xcat-cisco-rpm-from-github)
  - [Verify that xCAT-cisco RPM was installed correctly](#verify-that-xcat-cisco-rpm-was-installed-correctly)
- [Configure UCS Manager in xCAT](#configure-ucs-manager-in-xcat)
  - [Add UCS Manager To /etc/hosts](#add-ucs-manager-to-etchosts)
  - [Add UCS Manager to nodelist](#add-ucs-manager-to-nodelist)
  - [Update nodehm table for UCS Manager](#update-nodehm-table-for-ucs-manager)
  - [Update mpa table for UCS Manager](#update-mpa-table-for-ucs-manager)
  - [Verify that UCS manager connection works](#verify-that-ucs-manager-connection-works)
- [Configure UCS Blades in xCAT](#configure-ucs-blades-in-xcat)
  - [Add nodes to /etc/hosts and resolve DNS](#add-nodes-to-etchosts-and-resolve-dns)
  - [Add nodes to nodelist](#add-nodes-to-nodelist)
  - [Update nodehm table for UCS Blades](#update-nodehm-table-for-ucs-blades)
  - [Update mp table for UCS Blades](#update-mp-table-for-ucs-blades)
  - [Test it out](#test-it-out)
  - [Update noderes table](#update-noderes-table)
  - [Get MAC addresses](#get-mac-addresses)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->




## Overview

  * Set up xCAT following basic instructions 
  * Setup UCS service profiles and assign them to blades. Make sure they are active and ready with no errors. 
  * download the [Cisco xCAT plugin](http://benincosa.com/cisco/ucs/xCAT) (source is hosted at [github](http://github.com/vallard/xCAT-cisco) ) 
  * install the RPM 
  * put the UCS manager into your nodelist and set the nodehm.mgmt to ucs. make sure you can ping it from xCAT management server 
  * Add username and password to ucs manager in mpa table. 
  * run lssp &lt;ucs manager&gt; This will give you a list of the service profiles. 
  * put the service profile names into the mp.tab next to the node name you want. 
  * run getmacs &lt;usc nodes&gt;

The current B-series configuration uses IPMI. We are working on a native plugin that will use XML to communicate with the fabric interconnects to manage service profiles and mac addresses. The current package is being hosted on github: [xCAT-cisco](http://github.com/vallard/xCAT-cisco) binary distributions for RHEL will be available soon as well as instructions on how to configure. 

Questions can be addressed to the xCAT mailing list or to [xcat@cisco.com](mailto:xcat@cisco.com)

## Install xCAT-cisco RPM

This has been tested on rhel5.5-rhel6.2. 

The easiest way to install xCAT-cisco code is to download the latest RPM. If you want to be sure you have the latest, you are also welcome to build it from the github repo. 

### Install from latest binary builds

Obtain the latest xCAT-cisco.rpm from [Cisco xCAT plugin](http://benincosa.com/cisco/ucs/xCAT)
   
~~~~ 
      # rpm -ivh xCAT-cisco-0.1-snap201205111247.noarch.rpm 
      Preparing...                ########################################### [100%]
      1:xCAT-cisco             ########################################### [100%]
      Restarting xCAT for plugins to take effect...
      Reloading xCATd Stopping xCATd [  OK  ]
      [  OK  ]
~~~~     

### build latest xCAT-cisco RPM from github

~~~~     
      # git clone git@github.com:vallard/xCAT-cisco.git
      # cd xCAT-cisco
      # ./build-xCAT-cisco-RPM
~~~~     

The RPM will then be placed in /usr/src/redhat/RPMS/noarch/ 

### Verify that xCAT-cisco RPM was installed correctly

Run: 

~~~~     
      # which lssp
      /opt/xcat/bin/lssp
~~~~     

## Configure UCS Manager in xCAT

### Add UCS Manager To /etc/hosts

My entry looks like: 
   
~~~~  
      10.93.234.241 ucsm
~~~~     

Make sure you can ping it from your xCAT server. 

### Add UCS Manager to nodelist
  
~~~~   
      # nodeadd ucsm groups=ucsm
~~~~     

Verify: 
  
~~~~   
      nodels ucsm
~~~~     

### Update nodehm table for UCS Manager
 
~~~~    
      # nodegrpch ucsm nodehm.mgt=ucs
~~~~     

### Update mpa table for UCS Manager

~~~~     
      # tabedit mpa
~~~~     

Fill in the table to look like the below: 
    
~~~~ 
      #mpa,username,password,comments,disable
      ucsm,admin,password
~~~~     

(this of course assumes that password is your real password to log into UCS Manager. You may consider creating an xCAT user for UCS Manager in order to log all events.) 

### Verify that UCS manager connection works

If you filled in the tables right you should be able to now run the lssp command to see all the service profiles inside of UCS 
   
~~~~  
      [root@xcat2 tmp]# lssp ucsm
      ucsm: org-root/org-vallard-test/ls-lucky04-iscsiboot: sys/chassis-2/blade-2
      ucsm: org-root/org-vallard-test/ls-ciac02: sys/chassis-2/blade-3
      ucsm: org-root/org-vallard-test/ls-ciac01: sys/chassis-1/blade-3
      ucsm: org-root/org-vallard-test/ls-lucky01: sys/chassis-1/blade-1
      ucsm: org-root/org-vallard-test/ls-lucky03-iscsiboot: sys/chassis-1/blade-2
      ucsm: org-root/org-vallard-test/ls-lucky02: sys/chassis-2/blade-1
      ucsm: org-root/org-CIAC/ls-CIAC-TSP-2: unassigned
      ucsm: org-root/org-CIAC/ls-CIAC-TSP-1: unassigned
~~~~     

Notice that some of the service profiles are not assigned while the others are. We are going to use the service profile names to map the nodes in xCAT. 

## Configure UCS Blades in xCAT

Before configuring UCS Blades you must have configured UCS Manager in xCAT using the steps above. Please do not go any further unless that part works. If you need help, please email [xcat@cisco.com](mailto:xcat@cisco.com) or use the xCAT mailing list. 

### Add nodes to /etc/hosts and resolve DNS

You can do this by using the hosts table inside of xCAT or doing it manually. I will add 4 hosts: 
  
~~~~   
      192.168.40.101 lucky01
      192.168.40.102 lucky02
      192.168.40.103 lucky03
      192.168.40.104 lucky04
~~~~     

Now run makedns and add these hosts to your DNS so they can resolve and be installed. 

### Add nodes to nodelist
  
~~~~   
      nodeadd lucky01-lucky04 groups=ucs
~~~~     

### Update nodehm table for UCS Blades
 
~~~~    
      nodegrpch ucs nodehm.mgt=ucs
~~~~     

### Update mp table for UCS Blades

Here you will use the lssp command you used to verify your connection to UCS Manager in the last section. We then take the output of the lssp command and populate the mp table. Here is an example: 
  
~~~~   
      lssp ucsm
      ucsm: org-root/org-vallard-test/ls-lucky04-iscsiboot: sys/chassis-2/blade-2
      ucsm: org-root/org-vallard-test/ls-lucky01: sys/chassis-1/blade-1
      ucsm: org-root/org-vallard-test/ls-lucky03-iscsiboot: sys/chassis-1/blade-2
      ucsm: org-root/org-vallard-test/ls-lucky02: sys/chassis-2/blade-1
~~~~     

From here we see that service profile that is named org-root/org-vallard-test/ls-lucky04-iscsiboot is mapped to chassis 2 / blade 2. Regardless of what its mapped to, with UCS we will map the blade identity in xCAT to the service profile of the blade. Not the physical slot that you may be used to doing in other solutions. This may be changed at a later date if we decide we want to use xCAT to update the service profile on a physical server slot. We are always looking for feedback on this. 

But I digress... Let's map these inside of the mp table. 
  
~~~~   
      # tabedit mp
~~~~     
    
      Mine looks like this:

~~~~ 
      #node,mpa,id,nodetype,comments,disable
      lucky01,ucsm,org-root/org-vallard-test/ls-lucky01
      lucky02,ucsm,org-root/org-vallard-test/ls-lucky02
      lucky03,ucsm,org-root/org-vallard-test/ls-lucky03-iscsiboot
      lucky04,ucsm,org-root/org-vallard-test/ls-lucky04-iscsiboot
~~~~     

Notice that the ID is mapped to the full service profile name using the output of the lssp command. 

### Test it out

If you got this far you should be able to test it out by running rinv: 
    
~~~~ 
      [root@xcat2 tmp]# rinv lucky01
      lucky01: memory available: 49152
      lucky01: memory speed: 1333
      lucky01: memory total: 49152
      lucky01: model: N20-B6620-1
      lucky01: number of CPUs: 2
      lucky01: number of cores: 8
      lucky01: number of cores enabled: 8
      lucky01: number of ethernet interfaces: 6
      lucky01: number of fc interfaces: 2
      lucky01: serial number: QCI1340008I
      lucky01: server chassis: 1
      lucky01: server slot: 1
      lucky01: uuid: 00000000-0000-0000-dead-beef00000008
      lucky01: uuid original: a6726335-b4dd-11de-ab66-000bab01c0fb
      lucky01: vendor: Cisco Systems Inc
~~~~     

### Update noderes table

In order to install the node we need to specify a number of parameters. 
 
~~~~   
      nodegrpch ucs noderes.netboot=xnba noderes.tftpserver=xcat2 \
         noderes.nfsserver=xcat2 noderes.installnic=esxa
~~~~     

Here we are setting the TFTP server, the NFS Server to xcat2, which is the name of my xCAT management server. Its also key that we set the installnic to be the name we gave to our vNICs when we created the service profiles. If you don't know the name of the vNIC, just fill in something like eth0 for now. 

### Get MAC addresses

Get the MAC addresses of the nodes: 

~~~~     
      getmacs lucky01-lucky04
      ...
      lucky02: lucky02-nfsa: 00:25:B5:AA:AA:0A
      lucky02: lucky02-esx-a: 00:25:B5:AA:AA:0B
      lucky02: lucky02-vm-traffic-a: 00:25:B5:AA:AA:0C
      lucky02: lucky02-esx-b: 00:25:B5:BB:BB:0B
      lucky02: lucky02-vm-traffic-b: 00:25:B5:BB:BB:0C
      lucky02: lucky02-nfsb: 00:25:B5:BB:BB:0 
      ...
~~~~     

If you guessed the wrong interface while setting you noderes table, xCAT will notify you that it couldn't find it. In this case, it couldn't find esxa. I change noderes table to be: 
 
~~~~    
      nodegrpch ucs noderes.installnic=esx-a
~~~~     

And then rerun getmacs. This time the mac table will be populated. Example below: 
 
~~~~    
      "lucky04",,"00:25:B5:AA:AA:05!lucky04|00:25:B5:AA:AA:11!lucky04-vm-a|00:25:B5:BB:BB:11!lucky04-vm-b|00:25:B5:AA:AA:14!lucky04-nfs-a|00:25:B5:BB:BB:05!lucky04-esx-b|00:25:B5:BB:BB:14!lucky04-nfs-b",,
      "lucky03",,"00:25:B5:00:00:25!lucky03|00:25:B5:00:00:15!lucky03-nfsb|00:25:B5:00:00:06!lucky03-vm-traffic-a|00:25:B5:00:00:05!lucky03-nfsa|00:25:B5:00:00:16!lucky03-vm-traffic-b|00:25:B5:00:00:35!lucky03-esx-b",,
      "lucky01",,"00:25:B5:AA:AA:0E!lucky01|00:25:B5:BB:BB:0D!lucky01-nfsb|00:25:B5:AA:AA:0F!lucky01-vm-traffic-a|00:25:B5:AA:AA:0D!lucky01-nfsa|00:25:B5:BB:BB:0E!lucky01-esx-b|00:25:B5:BB:BB:0F!lucky01-vm-traffic-b",,
      "lucky02",,"00:25:B5:AA:AA:0B!lucky02|00:25:B5:BB:BB:0A!lucky02-nfsb|00:25:B5:AA:AA:0C!lucky02-vm-traffic-a|00:25:B5:AA:AA:0A!lucky02-nfsa|00:25:B5:BB:BB:0C!lucky02-vm-traffic-b|00:25:B5:BB:BB:0B!lucky02-esx-b",,
~~~~     

If you have different service profiles then you may need to create different entries in the noderes table. 
