<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Required Reviewers](#required-reviewers)
  - [Required Approvers](#required-approvers)
- [Overview](#overview)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

  


### Required Reviewers

  * Linda Mellor 
  * Bin XA Xu (Platform) 

### Required Approvers

  * Guang Cheng Li 

## Overview

Needed mkvlan enhancements (TBD). But here a come comments about current support. 

Currently it only supports Cisco and some modules of BNT switches (EN4093,G8000,G8124,G8264, 8264E). To support more BNT modules, we need to update the OID table because each BNT modules uses different OIDs for the same function (a very bad design by BNT). And to support other switch vendors like Juniper, a significant code change needs to be done because currently Juniper does not support vlan function through SNMP interface. We have to use its own libraries to have it done. This needs framework change in our vlan code. 
