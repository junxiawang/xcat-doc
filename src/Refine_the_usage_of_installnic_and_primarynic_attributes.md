<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Original Design](#original-design)
- [](#)
- [The Current Code Logic to use 'installnic' and 'primarynic'](#the-current-code-logic-to-use-installnic-and-primarynic)
- [](#-1)
- [New Design:](#new-design)
  - [Interface](#interface)
  - [Implementation](#implementation)
- [](#-2)
- [Discussion](#discussion)
- [](#-3)
- [Reference](#reference)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


##Overview
We have a lot confusion of how to use 'instalnic' and 'primarynic'. It' also not clear in our code logic. This mini-design is used to clarify how to use them from xCAT dev perspective and end customer perspective.


##Original Design
The definition of how to use 'installnic' and 'primarynic' in the Schema.pm:

* installnic: The nic will be used for OS deployment.
* primarynic: The nic will be used for xCAT management.

The original design of how to use 'installnic' and 'primarynic':

* 'installnic' is used to send dhcp request, download bootloader (xnab,yaboot,grub2) and download kernel+initrd. For diskfull install, it also is used to download the packages of OS.

* 'primarynic' is used to select network interface after the OS deployment.

----

##The Current Code Logic to use 'installnic' and 'primarynic'
Base on the original design that 'installnic' should be used to generate the kernel parameters like 'ifname', 'netdev', 'BOOTIF' .... The 'primarynic' should be used to select network interface as management network after OS deployment.

But in current code logic, both of the installnic and primarynic are used to generate the 'ifname', 'netdev', 'ip' and 'BOOTIF' kernel parameters. (installnic and primarynic support the same value format, but installnic has high priority)

* For diskfull install: 'primarynic' is used to get the hostname and set to the target node. 'installnic' is NOT used.

* For diskless netboot:  The kernel parameters generated from 'installnic' and 'primarynic' will be used in order ifname->netdev->BOOTIF to get the active interface for the target node. 

Base on the above comparison that xCAT does not have a clear definition of how to use 'installnic' and 'primarynic'. And in our code, there are three implementations (sles.pm, anaconda.p, debian.pm) for how to use 'installnic' and 'primarynic' to generate kernel parameters. 

Our goal in this item will be to clarify the usage of installnic and primarynic from interface point of view and clean up the code logic of how to use installnic and primarynic.

----

##New Design:
Since the usage of 'installnic' and 'primarynic' is very confusing and complicated and in all of the cases that we can thought that 'intallnic' and 'primarynic' have same value, we decide to deprecate 'primarynic'. 

We won't remove all the code which is using 'primarynic', but for the code which generate boot kernel parameters, the primarynic is skipped only except that 'installnic' is black, but 'primarynic' is set.

###Interface

'installnic' is recommended for using to set the interface which will be used to perform the OS deployment and remaining works.

'primarynic' is deprecated even it still works in certain cases.

'installnic' supports 4 types of values:

* <blade>

Does not set anything. Kept it black. This is a recommended setting that the 'mac' attribute of the node will be used to select installation interface.

* <mac> keyword

It sames with <black> that the 'mac' attribute of the node will be used to select installation interface.

* A mac address

A valid mac address. This address will replace the one in the 'mac' attribute to be used to select installation interface.

* Interface name.

A name of network interface like 'eth0'. This is NOT recommended since the interface name can NOT guarantee to be mapped to certain physical interface.

###Implementation
As I mentioned above that xCAT has three modules (anaconda.pm, sles.pm, debian.pm) to use 'installnic' and 'primarynic' to generate kernel parameters, the code logic are not consistent between the modules. 

In this design we will centralize the code which calculate kernel parameters with 'installnic' in a subroutine xCAT::NetworkUtils->gen_net_boot_params.  This subroutine will return a hash which contains all possible network boot kernel parameters that generated base on 'installnic' setting. Then in each module, it can choose any parameter from this hash and add them into kernel parameter string.

----

##Discussion

Ideas from email discussion.

1 Do not change the original behaviors of using 'installnic' and 'primarynic', this will be easy for old customer. For most of the customer that we recommend them to keep them as black (after this change). If they do want to set nic name, use any one should work. If they set both of 'installnic' and 'primarynic', but with different values, we will display a warning message like ''Are you sure that you want installnic and primarynic to be different values?'.

2 For x86, if not set 'installnic' and 'primarynic', try to use the firmware selected nic.

----

##Reference
Refer to Er Tao's investigation for how our current code to use 'installnic' and 'primarynic':
https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/xCAT/page/The%20summary%20of%20installnic%20and%20primarynic%20using%20in%20xCAT 
