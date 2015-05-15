<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [A Brief Introduction to the most common usage of xCAT tables](#a-brief-introduction-to-the-most-common-usage-of-xcat-tables)
    - [Common Tables](#common-tables)
  - [Common Table commands](#common-table-commands)
  - [site Table](#site-table)
  - [nodelist Table](#nodelist-table)
  - [nodehm Table](#nodehm-table)
  - [ipmi Table](#ipmi-table)
  - [mpa Table](#mpa-table)
  - [mp Table](#mp-table)
  - [Take a breath and look at the big picture...](#take-a-breath-and-look-at-the-big-picture)
  - [networks Table](#networks-table)
  - [noderes Table](#noderes-table)
  - [passwd Table](#passwd-table)
  - [chain Table](#chain-table)
  - [switch Table](#switch-table)
  - [nodetype Table](#nodetype-table)
  - [iscsi Table](#iscsi-table)
  - [prodkey Table](#prodkey-table)
- [Summary](#summary)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# A Brief Introduction to the most common usage of xCAT tables

xCAT stores all information about the nodes and subsystems it manages in a database. For the basic xCAT install this database is located in /etc/xcat in sqlite tables. You can also store the tables in MySQL or PostgreSQL as well. (See the documentation section) 

At first glance the number of tables and table entries can be daunting! For example, run the command: 
    
    tabdump

And you'll see the list of all the tables. You can run tabdump on any of the tables and it will show you what is contained in there. But do you want to know the good news? For most installations you won't need to even fill up half of the tables! And for the tables that you do need, in most cases you'll only need to put one line in the table! Remarkable! So if you don't need them all why all the tables and why so many confusing parameters? xCAT is extreme! Meaning that you have so much flexibility with it you can do amazing things! Also realize that xCAT supports AIX and Linux operating systems. Many of the tables are for AIX, many are for just monitoring, and some are for advanced functions like virtual machines, iSCSI settings, custom boot targets, or specialized switches. For most users the only tables you'll need to edit are the following: 

### Common Tables
    
    chain
    ipmi
    mac
    mp
    mpa
    networks
    nodehm
    nodelist
    noderes
    nodetype
    passwd
    site
    switch

## Common Table commands

xCAT comes with a rich set of functions for manipulating tables. Tables can be changed via command line or an editor. To show tables we've already seen the tabdump command. But the tabdump command (analogous to the 'cat' command) can also describe what each table does. For all tables you can run: 
    
    tabdump -d &lt;tablename&gt;

And you'll get an output of sugguestions for the fields.  
To edit a table you run the tabedit command: 
    
    tabedit &lt;tablename&gt;

By default you'll be placed in a vi editor with the table contents displayed. By writing the file and saving it you then can make changes to the database. But what if vi isn't your bag? Suppose you like nano? Or emacs? Or even open office? xCAT is an equal-editor friendly software. You can simply change the editor to be something else by running: 
    
    export EDITOR=emacs

Then you can edit tables with emacs when running tabedit.  
The final way to edit tables are with the nodech, chtab and the chdef commands. These commands come with man pages that show their usage but edit tables via the command line as opposed to entering an editor. Some examples, straight from the man pages include: 
    
    chdef  -t site -o clustersite tftpdir="/tftpboot" 
    
    nodech node[1-4] groups,=newgroup

Now that we know how to edit tables, lets explain what they do. I'll proceed in the order that I usually edit tables. Lets start with the site table. 

## site Table

The site table controls settings that are primarily used for the management node in how xCAT will behave. For example, it specifies the port that the client and server will communicate on, the tftp directory, information for DNS, and most importantly: Who is the master xCAT server? This becomes more important as service nodes are running, because service nodes run xcatd's as well as the master node.  
For the most part you can get by with a minimal config similar to: 
    
    #key,value,comments,disable
    "xcatdport","3001",,
    "xcatiport","3002",,
    "tftpdir","/tftpboot",,
    "master","10.0.0.39",,
    "domain","idplx",,
    "installdir","/install",,
    "timezone","America/Los_Angeles",,
    "nameservers","10.0.0.1",,
    "forwarders","9.0.2.1",,

Most of these settings xCAT figures out and installs for you during the yum install. Notice the top line that begins with the #. That line is necessary for xCAT to feed the parameters back into the database. Don't touch it! Don't change it! Danger Will Robinson! Actually its not that bad, but don't change it. If you want to put more settings in, go on right ahead. Just do the tabdump -d site command and see all the glorious things you can place in xCAT. For most people, the basics above are all you need. 

## nodelist Table

Now that you have some basic parameters for your management node, you need to get all your nodes defined. Who will be managed by xCAT? You can use the xCAT host table to set up an /etc/hosts file but for us we'll just assume that you put all your host names inside /etc/hosts and that you now just want xCAT to know about them. There are really only two parameters you need for each host: The host name and the groups it belongs to. The other parameters are pretty much useless right now, or at least I've never seen them work properly. So if you see random status that appears in the nodelist table (that is most likely wrong) just ignore those. So basically all you need in the nodelist table is a line for each node and the groups that it belongs to: 
    
    node01,"all,compute,rack3"

You don't need to surround everything by quotes, xCAT will do that for you. But for fields that have commas in them like the groups line does above, you need to wrap the parameter in quotes. After you save it and then view it again you'll see that xCAT has placed quotes around it. 

one last note on this table:  
If your node has an alias, like node01-eth1 then you don't need to put node01-eth1 in there. Likewise if you have an infiniband adapter, don't put node01-ib0 in the nodelist table. 

  


## nodehm Table

After you define your nodes the next step I usually do is try to get control of them. This is done by editing the node hardware management (nodehm) table. Today it is more than likely that your machine is managed by IPMI. So putting one line in this table is usually sufficient for all your nodes. Something like the following will work in most cases: 
    
    #node,power,mgt,cons,termserver,termport,conserver,serialport,serialspeed,serialflow,getmac,comments,disable
    "compute",,"ipmi",,,,,"1","19200","hard",,,

Notice how much we left out! But lets describe what we've done. The first entry is the node. Here we have placed the key 'compute'. So every node in the compute group will get these settings. You can use the groups that you defined above in the nodelist table or simply put the node name. The groups works faster and its much easier to change one line than if you put 100 host names. 

We placed the 'ipmi' parameter under the mgt column. By doing this, xCAT assumes that power, remote console and all other functions requiring remote access will be done through ipmi. So you don't even have to fill in all those other fields. 

Finally, we want serial over lan (SoL) to work on this group of machines, so we set the values that will get added to the node during install. These should match the BIOS settings as well so that you can view console redirection. Don't expect that just because you placed these parameters in serial over lan will work right off the bat! You still need to make sure the BIOS is set to redirect and also that you are going out of the right serial port with the right serial speed. For IBM dx360 M2s the serial port should be set to 0. For the IBM dx360 and dx340 it should be set to 1. Isn't that obvious? 

If you had a blade server instead, then you would put 'blade' instead of 'ipmi' in the mgt column. 

So now you should think to yourself logically: Ok, I told xCAT to manage the machines with ipmi, but where does xCAT know to look for ipmi settings such as the password or even what the IP address is of the baseboard management controller that sits on the node itself? Or if we told it it was a blade, then where do we tell it what slot its in or in the case of IBM hardware, what the management module IP address is? Well for that you need to go to the ipmi table for ipmi or the mp &amp; mpa table for blades. Lets start with the ipmi table 

## ipmi Table

While all tables are able to use regular expressions, the ipmi table is one of the best places to use it. Before we talk about that lets mention some of the conventions used in xCAT for host names:  
\- simple names are better than crazy complex names that have positional information in the node. For example, it is common for people to name nodes something like r23u01 for the host name. xCAT makes it so this is not necessary. xCAT has a nodepos table for this information to go in. Therefore, we recommend normal host names like 'n001' or your favorite prefix.  
\- for extra interfaces it is preferred to use &lt;hostname&gt;-ethX e.g.: n001-eth1, or for infiniband: n001-ib0  
\- for BMCs we usually prefer &lt;hostname&gt;-bmc 

So, assuming you put all your ipmi nodes into a compute group and you followed the above sugguestion for host names, all you need is: 
    
    #node,bmc,bmcport,username,password,comments,disable
    "compute","/\z/-bmc/",,"USERID","PASSW0RD",,

This tells you: For every node in the compute group, take its hostname and add -bmc to it, then talk to it with user name: USERID and password PASSW0RD  
If you have more than one group, other nodes that don't belong to the compute nodegroup, then you can copy that line and change compute to something else, like login or storage or whatever group you defined. If you only have ipmi nodes you do not need to fill out the mp or mpa table. That is used for blades and other devices. Onward and upwards son! 

## mpa Table

This is where you put the information for a BladeCenter management module. Currently, only IBM Blades are supported, but it wouldn't be hard to add information to work with other vendors blades. Post a question to the mailing list for that. For one blade center management module with hostname mm01, an entry might look like this: 
    
    #mpa,username,password,comments,disable
    mm01,USERID,PASSW0RD

## mp Table

Now that you have the management module defined for blades, you now provide a map of where the blades go in relationship to the management module. For 14 Blades an example may be something like this: 
    
    b01,mm01,1
    b02,mm01,2
    b03,mm01,3
    b04,mm01,4
    b05,mm01,5
    b06,mm01,6
    b07,mm01,7
    b08,mm01,8
    b09,mm01,9
    b10,mm01,10
    b11,mm01,11
    b12,mm01,12
    b13,mm01,13
    b14,mm01,14

There you have it! 14 blades on one management module. You should be able to run commands like rpower and rinv if this has been done right. 

## Take a breath and look at the big picture...

Ok, tabs are not fun. But you've come a long way baby! So what have you done?  
\- You've defined basic xCAT settings for DHCP, DNS, xcatd, and basic install information with site table  
\- You defined all your nodes with the nodelist table  
\- You defined how to remotely manage those nodes with either the ipmi table or the mpa &amp; mp tables. 

So what to do next?  
Usually about here is where I get the automatic discovery process done. To do this you need to configure:  
\- networks - to make sure all network settings are correct and to generate dhcp file  
\- noderes - to tell what type of boot the nodes will use (usually its just pxe)  
\- passwd - so you have default system information  
\- chain - so you can tell nodes what to do so they boot from discovery, to setup, to install automatically.  
\- switch - so you have a mapping of network switch port to node. This is for automated discovery to map mac addresses to the correct machines. 

From there you will want to install the machines. To do this you need to configure:  
\- nodetype - tells which OS, architecture and install template to use.  
\- iscsi - for nodes that do iSCSI boot you need to tell them where their iSCSI targets are (this is only if you use xCAT iSCSI)  
\- prodkey - for windows installs you need to tell xCAT the key it should use! 

That's it! Nothing to it. So lets finish up: 

## networks Table

You have to define the networks that your management server is attached to. The important thing here is for automated discovery. You need to put a dynamic range of IP addresses for the networks that are allowed to discover nodes. A simple example is a machine with one network: 
    
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,comments,disable
    mgmt,"10.0.0.0","255.255.0.0","eth0","10.0.0.1","10.0.0.1","10.0.0.1","10.0.0.1",,,"10.0.0.208-10.0.0.250",,,

The above shows a network that I have arbitrarily named mgmt. The network is 10.0.0.0 and it is a class B network: 255.255.0.0. The management node interface that talks to it is eth0. Then this network's dhcpserver, tftpserver, nameserver, &amp; ntpserver is all the same server: 10.0.0.1, which also happens to be my management server. Finally there is a dynamic range of IP addresses: 10.0.0.208-10.0.0.250. Its pretty small, but enough to discover 43 nodes. 

## noderes Table

The noderes table defines the resources of the nodes. This includes all of the servers it uses to boot to a usable state and all the types of boot ups it will do. Again this is usually as easy as doing something like: 
    
    #node,servicenode,netboot,tftpserver,nfsserver,monserver,nfsdir,installnic,primarynic,cmdinterface,xcatmaster,current_osimage,next_osimage,nimserver,comments,disable
    compute,,pxe,,,,/install,eth1,eth0,,10.0.0.1,,,,,

The blanks are assumed by xCAT to be the management server, in this case 10.0.0.1. pxe is what we use for standard pxe boot and iscsiboot.  
This can get tricky in some cases:  
1\. primary interface for ipmi machines is the one where the BMC is set to. If you want to install over a different nic, go ahead. By default IBM nodes have eth0 as the port with the BMC on it, but if you stick a PCI card that has network adapters on it, that may change.  
2\. In xCAT 1.3 there was a precidence of the top one was used over the first one. That's not true in xCAT2. Just make a node only matches one stanza unless they are disjoint lines. (i.e: one line doesn't have the same fields that another does defined.) 

## passwd Table

This one is easy. Just put the passwords for the things you'll need: 
    
    #key,username,password,comments,disable
    "omapi","xcat_key","cm9UZUJ5SmRQdHNhUnNKR3lBTHQwTXVBd29vU1Q2QjM=",,
    "system","root","cluster",,
    "system","Administrator","cluster",,

The omapi is done by xCAT and that is used to communicate with DHCP. The system 'root' key is the root password that is used for Linux node installs while the Administrator password is for Windows installs. Most places will be fine with one or the other. 

## chain Table

This table is for chaining initial boot sequences and other advanced chaining rules that we won't go into here. Essentially, you can automatically discover a machine, flash its bios, set its CMOS settings, set the BMC settings, then boot to an operating system after that to run a job and then boot to another operating system after that. The chain table tells the destiny of the node and what to do. Read the xCAT documentation [here](https://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/share/doc/). 

## switch Table

This table is used to map the node to a switch and a port. xCAT makes you do all that nasty admin stuff that you don't want to do, but in the long term you know will help you. The reason you have to fill this out is because this is where the autodiscovery happens. A node boots up, xCAT gets signaled, it checks to see if he knows who it is, if he doesn't he queries the switches to see who it is. An example of this table is simply: 
    
    n001,switch1,1
    n002,switch1,2
    ...

As you can see, this sane switch configuration has n001 connected to switch1 in port 1. For this automagic to work you need to have snmp enabled on the switches. xCAT expects it to be simple snmp v1 and public community string. If you want something else (snmp v3, or different community string), check out the switches table. (that's different than the *switch* table we're talking about here) 

## nodetype Table

This is the table where you tell the node what to install! Its simple: node name (or group), architecture, operating system, and template for that operating system. Here's an example: 
    
    #node,os,arch,profile,nodetype,comments,disable
    "render","centos5.3","x86_64","compute",,,
    "workstation","win2k8","x86_64","enterprise.win2k8.x86_64",,,

Here my workstation node groups are installing the win2k8 OS with the enterprise.win2k8.x86_64 template and my render nodes are installing CentOS 5.3 with the compute template. Those templates are located in /opt/xcat/share/xcat/install/&lt;windows|centos&gt;/. However, the render nodes can also be installed stateless if there is a stateless image that matches the compute stateless image. (this can be generated in /opt/xcat/share/xcat/netboot/centos). 

## iscsi Table

For machines that boot off an iSCSI target you can place the information for these targets in the iscsi table: 
    
    "node02","10.0.0.99","iqn.2001-05.com.equallogic:0-8a0906-71d4c4a01-d6a0000012949a87-mytestvolume","1",,,,,,,,,

Here my node is booting off an iscsi target we defined on an iSCSI device. xCAT also has the ability to make your management server an iSCSI device! 

## prodkey Table

For some operating systems you need a product key to install them. (Windows, VMWare ESX). This is the place to put those keys: 
    
    #node,product,key,comments,disable
    #node,product,key,comments,disable
    "n9999","win2k8.enterprise","XXXX-XXXXX-XXXXX-XXXXX-XXXXX",,

Here, node n9999 has its windows key so that automatic installs can happen and the user doesn't have to enter the windows product key every time. 

# Summary

This was a fast tour through some of the widely used xCAT tables! Wow, that was fast. And you probably have more questions right? And I'm sure you just want to keep reading more. So here is where you can get more in depth information: 

[xCAT Docs](https://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/share/doc/)
