<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Basic Thought](#basic-thought)
- [Implementation](#implementation)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Overview

Based on the pre-defined groups in template, it will be much convenient to automatically match the machine type of node to those groups. 

## Basic Thought

1\. Add a file ibmhwtypes.pm storing the machine type(mt) and corresponding group under $xCAT/lib/perl/xCAT/data/, export a global hash with the key is machine type and value is pre-defined group. 

2\. After the machine type is gotten, match the type to the global hash and obtain the corresponding group, then append the group to groups attribute of the specified node. 

## Implementation

1\. The file ibmhwtypes.pm will include two main part: 

Part1. The hash table groups2mtm is used to store the matching of groups and related MTs. It is like this: 
    
       my %groups2mtm = (    
       "x3250" =&gt; ["2583","4251","4252"],
       "x3550" =&gt; ["7914","7944","7946"],
       "x3650" =&gt; ["7915","7945"],
       "dx360" =&gt; [],
       "x220"  =&gt; ["7906"],
       "x240"  =&gt; ["8737","7863"],
       "x440"  =&gt; ["7917"],
       "p260"  =&gt; ["7895"], #789522X, 789523X
       "p460"  =&gt; [],       #789542X
       "p470"  =&gt; ["7954"],
       );
    

Part2. The subroutine parse_group is used to return group for the given MT. 

Note: for MT 7895, the 789522X and 789523X are belong to p260, 789542X is belong to p460. It is dealt in this subroutine. 

The admin can add new (group, mt) pair or append a new mt for a specified group in groups2mtm. 

Since there is many model(The last 3 characters of MTM) for the same machine Type(The first 4 characters of MTM), the machine Type is used as the key to find group. 

2\. For xCAT commands. 

After mtm is gotten when doing node discovery or definitionu pdating(lsslp, rscan, or genesis findme process) or checking node information(rinv), collect the machine Type(The first 4 characters of MTM) and use ibmhwtypes::parse_group to get the proper group. 

For rinv, there is an option '-t ' is added to specify that we need to update the groups attribute of the node with pre-defined groups. 

At last, append the proper group to the groups attribute of the specified node. 

## Other Design Considerations

  * **Required reviewers**: Bruce Potter, Guang Cheng 
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
