<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Interface](#interface)
  - [The change of the interface compared to blade center](#the-change-of-the-interface-compared-to-blade-center)
- [Internal Implementation](#internal-implementation)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

This is the mini-design of supporting the energy management for the flex system. The supported hardware includes the 'chassis', 'power ITE' and 'x86 ITE'. 

Technically, we have two approach to support the energy for flex. 

  1. Communicate with IMM (for x86 ITE) via IPMI interface to perform the energy management. And communicate with FSP (for power ITE) via CIM interface to perform the energy management. 
  2. Communicate with CMM via the snmp interface to perform the energy management for Chassis, power ITE and x86 ITE. 

The first approach is a native one since we are using 'ipmi' as the management method for x86 ITE to do the hardware control things and using 'fsp' as the management method for power ITE to do the hardware control. But the problem is we have to use the close source code to handle the energy management via 'IMM' and 'FSP' because of IBM's internal policy. And we have to make complex code to parse the protocol for energy management. Also we have to maintain the update for the IMM/FSP interface change and new firmware adding. 

The second approach is simple that we just use the snmp which supplied by CMM to get/set all the information we needed for the flex energy management support. The disadvantage is the snmp interface of CMM is not totally complete (I found some bugs), so I need put more effort to push them to fix them. 

Compared the two approach, the second one was selected for the flex energy support. 

## Interface

We have supported the energy management for the blade center via snmp interface of AMM. The CMM is the next generation management product of AMM, most of the snmp OIDs are same between them. So for flex, I just need to change the interface which could not supported by AMM or have been changed for Flex. 

### The change of the interface compared to blade center

  * For chassis, since the concept of 'power domain' has been removed from CMM (you could think that there's only one power domain for CMM, but there are two for AMM), the attribute start with pd[1|2] will be replaced with 'power', see following. 

    renergy noderange [-V] { all │ [powerstatus] [powerpolicy] [powermodule] [avaiablepower] [reservedpower] [remainpower] [inusedpower] [availableDC] [averageAC] [thermaloutput] [ambienttemp] [mmtemp] } 

  * For ITE, the getting and setting of capping have been added for CMM, see following: 

    renergy noderange [-V] { all │ [averageDC] [capability] [cappingvalue] [cappingmaxmin] [cappingmax] [cappingmin] [CPUspeed] [maxCPUspeed] [savingstatus] [dsavingstatus] } 
    renergy noderange [-V] { cappingwatt=watt │ cappingperc=percentage │ savingstatus={on │ off} │ dsavingstatus={on-norm │ on-maxp │ off} } 

Note: All the attributes for the ITE are common for power and x86 ITE except that the 'dsavingstatus' and 'savingstatus' are only working for power ITE. 

## Internal Implementation

  * Classify the flex nodes to get the proper plugin 

For the flex node, the 'mgt' attribute is set to 'ipmi' for 'x86 ITE' and the 'mgt' is set to 'fsp' for 'power ITE', but we want to use the snmp interface in the blade.pm to handle energy management for flex. Then we have to make a filter function to classify the nodes before really running in the plugins. 

The plan is to add a function in the Utils.pm - xCAT::Utils-&gt;filter_nodes which classify the nodes base on the command name and argument for the command to figure out which nodes should be run by blade.pm, which nodes should be run by ipmi.pm and which nodes should be run by fsp.pm. 

For the renergy command, the program will run into all the three plugins blade.pm, ipmi.pm and fsp.pm, then each plugin will run the xCAT::Utils-&gt;filter_nodes to figure out whether there are nodes that should be run by itself, if having, go ahead, otherwise, return directly. 

  * Power domain 

As described in the previous section that the support of flex will be an enhancement base on the existed code for the blade center, only the changes against the current code will be listed. The concept of power domain has been removed from the flex, or you can consider there's only one power domain (blade center chassis has two power domain) in the flex chassis. The name of attributes for the power domain will be changed to following for flex: 
    
    pd1status =&gt; powerstatus
    pd1policy =&gt; powerpolicy
    pd1powermodule1 =&gt; powermodule
    pd1avaiablepower =&gt; avaiablepower
    pd1reservedpower =&gt; reservedpower
    pd1remainpower =&gt; remainpower
    pd1inusedpower =&gt; inusedpower
    

  * Power Capping 

Power capping function is supported for flex. 
    
    Query: cappingmaxmin cappingmax cappingmin
    Set: cappingwatt=watt | cappingperc=percentage
    

  


## Other Design Considerations

  * **Required reviewers**: Bruce, Brian, Er Tao, Guang Cheng 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
