<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Overview](#overview)
  - [Interface](#interface)
    - [For Query](#for-query)
    - [For Setting](#for-setting)
    - [The Node Definition](#the-node-definition)
      - [For PowerBE](#for-powerbe)
- [lsdef Server-8247-22L-SN10121BA](#lsdef-server-8247-22l-sn10121ba)
- [lsdef 50.3.3.1 -S](#lsdef-50331--s)
      - [For PowerLE](#for-powerle)
- [lsdef test_ppcle](#lsdef-test_ppcle)
  - [Implementation](#implementation)
    - [A Common CIM Utils](#a-common-cim-utils)
    - [A CIM specific plugin for energy](#a-cim-specific-plugin-for-energy)
    - [To make renergy command for P8 node can route to energy.pm](#to-make-renergy-command-for-p8-node-can-route-to-energypm)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


##Overview

Energy Management for Power series (P6 and P7) and x86_64 serials (Refer to the man page of renergy command) has been supported by xCAT. For both of them, there's an additional rpm package (xCAT-pEnergy or xCAT-xEnergy) needs be installed to enable this feature. These two additional packages only can be gotten from IBM, they are commercial one and close source.

Now for the Energy Management support for Power 8, the situation has been changed that the original interface that xCAT used to query/set Energy for P6/P7 has been obsoleted. But another public CIM interface has been published by IBM for Power 8 machines. This means xCAT can make a open source version (use Perl language) of Energy Management feature for Power 8.

The final decision is to make a new energy management implementation for P8 with CIM interface, the old implementation will be kept for old platforms like P6/P7 and x86_64.

IBM uses Power 8 chip to make two types of Power 8 machine, one is the original one which is running with PowerVM hypervisor that the machine or Lpar will run in Big Endian mode, the other is the machine or virtual machine will run in Little Endian mode. Now we call them PowerBE and PowerLE machines.

From the xCAT perspective that the Hardware Control for PowerBE and PowerLE machines is totally different. The PowerBE will use DFM inteface, but PowerLE will use IPMI interface. So the node definition will be different. But currently a good point is both of them are using the FSP as the service processor, so the implementation will be same. NOTE: in the near future that the service processor for PowerLE will be changed to BMC, in that case we need make change to support it.

Since the capping support is complicated and we did not see a lot customers were using this capping feature,  we decided to NOT support capping in the phase 1 for P8 energy management support.

##Interface

###For Query

All the energy management attributes except capping related ones in renergy command for P6/P7 will be supported for P8.

~~~~
[savingstatus] [dsavingstatus] [averageAC] [averageDC] [ambienttemp] [exhausttemp] [CPUspeed] [syssbpower] [sysIPLtime] [fsavingstatus] [ffoMin] [ffoVmin] [ffoTurbo] [ffoNorm] [ffovalue]

~~~~

Additionally, another fan related attribute named 'fanspeed' will be supported.

Another big change in the interface is that a history attribute will be added for each of '[averageAC] [averageDC] [ambienttemp] [exhausttemp] [CPUspeed] [fanspeed]'. The history will be a historical records for each attribute in last one hour. The interval of records will be 30s.

###For Setting 

All the energy management attributes except capping related ones in renergy command for P6/P7 will be supported for P8.

~~~~~

{ savingstatus={on | off} | dsavingstatus={on-norm | on-maxp | off} | fsavingstatus={on | off} | ffovalue=MHZ }

~~~~

###The Node Definition

####For PowerBE

  * The 'mgt' attribute must be set to 'fsp'. 
  * The 'hcp' attribute must be set. 
  * The 'mtm' attribute must be set, otherwise xCAT cannot figure out this is a P6/P7 or P8.

For example:

~~~~
# lsdef Server-8247-22L-SN10121BA
Object name: Server-8247-22L-SN10121BA
    groups=cec,all
    hcp=Server-8247-22L-SN10121BA
    hwtype=cec
    mgt=fsp
    mtm=8247-22L
    nodetype=ppc
    serial=10121BA

# lsdef 50.3.3.1 -S
Object name: 50.3.3.1
    groups=fsp,all
    hcp=50.3.3.1
    hwtype=fsp
    mgt=fsp
    mtm=8247-22L
    nodetype=ppc
    parent=Server-8247-22L-SN10121BA
    serial=10121BA
~~~~

####For PowerLE

  * The 'mgt' attribute must be 'ipmi'. 
  * The 'bmc' must be set to the IP of service process. 
  * The 'arch' must be set to 'ppc64le' to make xcat to know this is a P8 node.

For example:

~~~~
# lsdef test_ppcle
Object name: test_ppcle
    arch=ppc64le
    bmc=50.3.3.1
    groups=cec,ppcle
    mgt=ipmi
    mtm=8247-22L
    serial=10121BA
~~~~


##Implementation


###A Common CIM Utils

Since the energy management feature for P8 must be done through CIM interface, we will create a xCAT/CIMUtils.pm to implement a common interface to access CIM server.

In the CIMUtils.pm, several common HTTP subroutines will be created to make 'http head', 'http content' and send/receive http package.

A common CIM 'enum_instance' subroutine will be created to enumerate instance for a specified class. 

A common CIM 'set_property' subroutine will be created to set property for a specified instance.

###A CIM specific plugin for energy

Since the implementation for P8 energy is totally different with P6/P7, we decide to create a new plugin module xCAT_plugin/energy.pm to implement the energy management feature for P8.

This plugin will do following things:

~~~~

1. Verify this is a valid P8 node that energy.pm can handle.
2. Get the service process IP for the node;
3. Get the user and password of service processor for the node.
4. For each service processor (if it has multiple ones), call 'run_cim' subroutine to do the real thing.

~~~~

In the run_cim subroutine:

~~~~

1. Check this 'Service Processor IP' is accessible;
2. Check whether this is a standby FSP. If yes, another 'Service Process IP' will be tried;
3. Go through each target attributes to know which 'CIM instance' needs be queried. This step will skip the unnecessary query for certain instance when they are required by multiple attributes.
4. Query all necessary instances at once.
5. Go through each target attributes:
5.1. For 'attribute query', get values from 'pre-queried instance' and display them.
5.2. For 'Attribute Setting', get values from 'pre-queried instance' to make sure it's valid to run the setting, and then call the 'set_property' subroutine to do the setting. Note, the setting need a name path of instance (a list of instance attribute to identify an instance') , this will be gotten from instance query. 

~~~~

###To make renergy command for P8 node can route to energy.pm
Before the support of P8 energy, the renergy command might route to 'blade.pm', 'fsp.pm' or 'ipmi.pm' base on the attributes of the node. We have a subroutine xCAT::Utils->filter_nodes() to help figure out which plugin to go in.

We will enhance this subroutine to make it can figure out which node should get in 'blade.pm' (blade node), 'fsp.pm' (only P6/P7) or 'ipmi.pm'(x86_64). Then the rest ones will get into energy.pm