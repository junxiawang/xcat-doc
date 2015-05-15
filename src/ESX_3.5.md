<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT &amp; ESX](#xcat-&amp-esx)
- [1\. Install ESX Hypervisor](#1%5C-install-esx-hypervisor)
  - [1.1. Copycds](#11-copycds)
  - [1.2. Set up kickstart file stuff](#12-set-up-kickstart-file-stuff)
    - [**1.2.1 esx.tmpl**](#121-esxtmpl)
    - [**1.2.2 post.esx**](#122-postesx)
    - [**1.2.3 setupesx**](#123-setupesx)
  - [1.3 More management node setup](#13-more-management-node-setup)
  - [1.4. Table Setup and install](#14-table-setup-and-install)
- [VMware Image Setup](#vmware-image-setup)
- [Miscellanious Fun](#miscellanious-fun)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# xCAT &amp; ESX

You can install ESX with xCAT. This covers ESX 3.5 

# 1\. Install ESX Hypervisor

It requires a few changes. First, you'll need to copy the Media, then create a suitable kickstart file and then do post install scripts. The following article shows you how. 

## 1.1. Copycds
    
    copycds -n rh esx*.iso

This will copy the ESX ISO into /install/rh/x86 

## 1.2. Set up kickstart file stuff

### **1.2.1 esx.tmpl**

The latest release of xCAT comes with an esx.tmpl. You can download it [here](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-server/share/xcat/install/rh/esx.tmpl) if its not in your version of xCAT and save it to: 
    
    /opt/xcat/share/xcat/install/rh/esx.tmpl

### **1.2.2 post.esx**

You'll also need to make sure that you have: 
    
    /opt/xcat/share/xcat/install/scripts/post.esx

If you don't have it get it [here](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT-server/share/xcat/install/scripts/post.esx). 

### **1.2.3 setupesx**

Verify that you have: 
    
    /install/postscripts/setupesx

If you don't you can get it [here](http://xcat.svn.sourceforge.net/viewvc/xcat/xcat-core/trunk/xCAT/postscripts/setupesx).  
If you are installing over eth0 then this script should work as is. If you change it to eth1 or want to set up other virtual interfaces then you should edit that file. You may need to do some experiments with it. Good luck. 

## 1.3 More management node setup

Make sure that /install is exported via NFS for post scripts to run. This is not done by xCAT by default since installations are done with HTTP. The postscripts use stunnel which are not available in ESX3.5, hence the post install is a little different. 

If you have a shared NFS filesystem, you may want to put that in the post install script as well. 

Note that the xCAT postscripts standard do not work in this setup. Any changes to post scripts should be done in post.esx or in setupesx. You should also take note that many scripts don't run until the VMware kernel boots up the first time. 

Another thing I've noticed is that if I have the serial port in nodehm table I sometimes have problems with hangs during install. 

## 1.4. Table Setup and install

Most of your tables will be set up normally. The only difference is the nodetype table. Ours looks like this: 
    
    #node,os,arch,profile,nodetype,comments,disable
    "compute","rh","x86","esx"

Now you can install it: 
    
    rinstall &lt;node&gt; -o rh -a x86 -p esx

Now provided everything else is setup correctly, you can do an rinstall and install ESX 3.5 and have ssh setup for provisioning virtual machines. 

# VMware Image Setup

TODO!!! 

# Miscellanious Fun

  
Once ESX is installed on your machines, you are ready to install virtual machines. I recommend that you make your virtual machines have static IP addresses.  
VMware shows the range that static generated IP addresses can have: 

Generate a ton of static IP addresses as follows: 
    
    use strict;
    
    # give a node and generate a mac address for it.
    
    my $nr = shift;
    my @nodes = `nodels $nr`;
    
    foreach my $node (@nodes) {
            my $X = (int(rand(63)));
            # between 00 and 3F
    
    
            # between 00 and FF
            my $Y = (int(rand(255)));
    
            #between 00 and FF
            my $Z = (int(rand(255)));
    
    
            chomp($node);
            my $d = sprintf ("$node,eth0,00:50:56:%02x:%02x:%02x", $X,$Y,$Z);
            print "$d\n";
    }

I ran that and added that to my mac table.  
Here's how I generated a bunch of vnc ports: 
    
    for j in $(seq 98); do P=5901; for i in $(nodels esx$j); do echo "$i,,,,$P"; P=$(expr $P + 1); done; done

. 
