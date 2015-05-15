<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Define configuration information for the Secondary Adapters in the nics table](#define-configuration-information-for-the-secondary-adapters-in-the-nics-table)
  - [Use stanza file](#use-stanza-file)
  - [Use command line input](#use-command-line-input)
- [Add confignics into the node's postscripts list](#add-confignics-into-the-nodes-postscripts-list)
  - [configure install nic](#configure-install-nic)
- [Add network object into the networks table](#add-network-object-into-the-networks-table)
- [add perl into the pkglist file for stateless/statelite image](#add-perl-into-the-pkglist-file-for-statelessstatelite-image)
- [Option -r to remove the undefined NICS](#option--r-to-remove-the-undefined-nics)
- [configure IB interfaces](#configure-ib-interfaces)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


This doc only works for xCAT 2.8 and beyond, for the previous xCAT versions, use [Configuring_Secondary_Adapters_Old](Configuring_Secondary_Adapters_Old) instead.


## Introduction

The **nics** table and the **confignics** postscript can be used to automatically configure additional **ethernet** and **Infiniband** adapters on nodes as they are being deployed. ("Additional adapters" means adapters other than the primary adapter that the node is being installed/booted over.)

The way the confignics postscript decides what IP address to give the secondary adapter is by checking the nics table, in which the nic configuration information is stored.

To use the nics table and confignics postscript to define a secondary adapter on one or more nodes, follow these steps:

## Define configuration information for the Secondary Adapters in the nics table

You could either use tabedit to edit the nics table directly or use the *def commands to define the nics attributes for the nodes. The syntax of the fields in the nics table is a little bit complex, directly editing the nics table can be tedious and error prone. It is recommended to use the *def commands to define the nics attributes for the nodes. The **nicips**, **nictypes** and **nicnetworks** attributes are required.


Here is a sample nics table content:

~~~~
    [root@ls21n01 ~]# tabdump nics
    #node,nicips,nichostnamesuffixes,nictypes,niccustomscripts,nicnetworks,nicaliases,comments,disable
    "cn1","eth1!11.1.89.7|12.1.89.7,eth2!13.1.89.7|14.1.89.7","eth1!-eth1-1|-eth1-2,eth2!-eth2-1|-eth2-2,"eth1!Ethernet,eth2!Ethernet",,"eth1!net11|net12,eth2!net13|net14",,,
    [root@ls21n01 ~]#

~~~~

Using *def commands is much easier and cleaner:

### Use stanza file

~~~~
    [root@ls21n01 ~]# cat cn1
    # <xCAT data object stanza file>

    cn1:
      objtype=node
      arch=x86_64
      groups=kvm,vm,all
      nichostnamesuffixes.eth1=-eth1-1|-eth1-2
      nichostnamesuffixes.eth2=-eth2-1|-eth2-2
      nicips.eth1=11.1.89.7|12.1.89.7
      nicips.eth2=13.1.89.7|14.1.89.7
      nicnetworks.eth1=net11|net12
      nicnetworks.eth2=net13|net14
      nictypes.eth1=Ethernet
      nictypes.eth2=Ethernet
    [root@ls21n01 ~]# cat cn1 | mkdef -z
    1 object definitions have been created or modified.
    [root@ls21n01 ~]# lsdef cn1
    Object name: cn1
      arch=x86_64
      groups=kvm,vm,all
      nichostnamesuffixes.eth1=-eth1-1|-eth1-2
      nichostnamesuffixes.eth2=-eth2-1|-eth2-2
      nicips.eth1=11.1.89.7|12.1.89.7
      nicips.eth2=13.1.89.7|14.1.89.7
      nicnetworks.eth1=net11|net12
      nicnetworks.eth2=net13|net14
      nictypes.eth1=Ethernet
      nictypes.eth2=Ethernet
      postbootscripts=otherpkgs
      postscripts=syslog,remoteshell,syncfiles
    [root@ls21n01 ~]#

~~~~

### Use command line input

~~~~
    [root@ls21n01 ~]# mkdef cn1 groups=all nicips.eth1="11.1.89.7|12.1.89.7" nicnetworks.eth1="net11|net12" nictypes.eth1="Ethernet"
    1 object definitions have been created or modified.
    [root@ls21n01 ~]#
    [root@ls21n01 ~]# chdef cn1 nicips.eth2="13.1.89.7|14.1.89.7" nicnetworks.eth2="net13|net14" nictypes.eth2="Ethernet"
    1 object definitions have been created or modified.
    [root@ls21n01 ~]#

~~~~

Once you have this entry in the xCAT nics table, you can run:


~~~~
    makehosts cn1
~~~~


and it will put these entries in the /etc/hosts table:

~~~~
     11.1.89.7 cn1-eth1-1 cn1-eth1-1.ppd.pok.ibm.com
     12.1.89.7 cn1-eth1-2 cn1-eth1-2.ppd.pok.ibm.com
     13.1.89.7 cn1-eth2-1 cn1-eth2-1.ppd.pok.ibm.com
     14.1.89.7 cn1-eth2-2 cn1-eth2-2.ppd.pok.ibm.com
~~~~


## Add confignics into the node's postscripts list

~~~~
     chdef cn1 -p postscripts=confignics
~~~~


### configure install nic

By default, confignics does not configure the install nic. Can use flag "-s" to allow the install nic to be configured.

~~~~
    chdef cn1 -p prostscripts="confignics -s"
~~~~


Option "-s" write the install nic's information into configuration file for persistance. All install nic's data defined in nics table will be written also.

## Add network object into the networks table

The nicnetworks attribute only defined the network object name which used by the ip address. Other information about the network should be define in the networks table. Can use tabedit to add/ modify the networks objects.

~~~~
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
    ...
    "net11", "11.1.89.0", "255.255.255.0", "eth1",,,,,,,,,,,,,,,
    "net12", "12.1.89.0", "255.255.255.0", "eth1",,,,,,,,,,,,,,,
    "net13", "13.1.89.0", "255.255.255.0", "eth2",,,,,,,,,,,,,,,
    "net14", "14.1.89.0", "255.255.255.0", "eth2",,,,,,,,,,,,,,,
~~~~


## add perl into the pkglist file for stateless/statelite image

xCAT 2.8.3 or later can ignore this step.

The confignics and configeth are written in perl. Should install perl on the compute node. refer [set up pkglists](XCAT_pLinux_Clusters#Set_up_pkglists) for more detail.

[Note] AIX user in xCAT 2.8.3 or later should use postscript configeth_aix instead of configeth.

## Option -r to remove the undefined NICS

If the compute node's nics were configured by confignics, and the nics configuration changed in the nics table, can use "confignics -r" to remove the undefined nics. For example: On the compute node the eth0, eth1 and eth2 were configured

~~~~
    # ifconfig
    eth0      Link encap:Ethernet  HWaddr 00:14:5e:d9:6c:e6
    ...
    eth1      Link encap:Ethernet  HWaddr 00:14:5e:d9:6c:e7
    ...
    eth2      Link encap:Ethernet  HWaddr 00:14:5e:d9:6c:e8
    ...
~~~~


Delete the eth2 definition in nics table with chdef command.

Run the

~~~~
 updatenode <noderange> -P "confignics -r" to remove the undefined eth2 on the compute node.
~~~~

The complete result is:

~~~~
    # ifconfig
    eth0      Link encap:Ethernet  HWaddr 00:14:5e:d9:6c:e6
    ...
    eth1      Link encap:Ethernet  HWaddr 00:14:5e:d9:6c:e7
    ...
~~~~


**Deleting the install nic will import some strange problems. So confignics -r can not delete the install nic.**

## configure IB interfaces

If you wish to configure IB interfaces, the basic procedure is very similar with the procedure described above, here are the minor differences:

1\. In the nics table, the NIC names should be something like "ib0", "ib1"(On AIX, the NIC name may be ml0), etc; the nictypes should be "Infiniband". Here is an example:

~~~~
[root@ls21n01 postscripts]# lsdef dx360m3n06 --nics Object name: dx360m3n06

       nichostnamesuffixes.ib0=-ib0|-ib0-2
       nichostnamesuffixes.ib1=-ib1|-ib1-2
       nicips.ib0=11.1.89.10|21.1.89.10
       nicips.ib1=12.1.89.10|22.1.89.10
       nicnetworks.ib0=11_1_0_0-255_255_0_0|21_1_0_0-255_255_0_0
       nicnetworks.ib1=12_1_0_0-255_255_0_0|22_1_0_0-255_255_0_0
       nictypes.ib0=Infiniband
       nictypes.ib1=Infiniband
~~~~


[root@ls21n01 postscripts]#

2\. A flag --ibaports can be used to specify the ports number of IB adapters, the default value is 1.

~~~~
     chdef cn1 -p postscripts='confignics --ibaports=2'
~~~~


"--ibaports=x" to specify the number of ports for an ib adapter. This value will set in an environment variable prior to calling configib.


