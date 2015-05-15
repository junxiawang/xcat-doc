<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Modification of rscan](#modification-of-rscan)
- [Modification of rspconfig](#modification-of-rspconfig)
- [Modification of lsslp](#modification-of-lsslp)
- [Removal of slpdiscover.pm](#removal-of-slpdiscoverpm)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

Since lsslp command is a list command, we decide to move the configuration process of the lsslp --flexdiscover out of it and merge it to rspconfig and rscan command. The modified part should be consistent with the firebird part so that these commands can hide the internal details and provide the user the unified working style. 

## Modification of rscan

In this part we intend to use rscan to show the system x nodes and define them in database with rscan. It should be consistent with the existed code which used to show firebird nodes. 

The rscan result will be modified as: 
    
     [root@x3850n02 xcat]# rscan cmm01
     type name id type-model serial-number mpa address
     cmm SN#Y030BG168034 0 789392X 100037A cmm01 cmm01
     blade ngpcmm01node01 1 789542X 10F69BA cmm01 70.0.0.41
     blade ngpcmm01node03 3 789522X 10F75AA cmm01 70.0.0.22
     blade ngpcmm01node04 4 789580X 10D86CA cmm01
     xblade ngpblade05 5 8737AC1 23FFP63 cmm01 70.0.0.15
     xblade ngpblade06 6 8737AC1 23FFR16 cmm01 70.0.0.16
     xblade ngpblade07 7 8737AC1 23FFP92 cmm01 70.0.0.17
     xblade ngpblade08 8 8737AC1 23FFP69 cmm01 70.0.0.18
     blade ngpcmm01node09 9 789523X 1035CDB cmm01 70.0.0.99
     xblade node11 11 786310X 1040BEB cmm01 70.0.0.9
     xblade node12 12 786310X 1040BDB cmm01 70.0.0.8
     blade ngpcmm01node13 13 789522X 104243B cmm01 70.0.0.130
    

rscan -u works the same way as before: if the node has been defined in database, rscan updates its attributes but dose not change its name. For identifying the system x node, the attributes of mpa(should be the cmm) and id are used. 

If the user want to write the rscan result to database, these attributes of system x nodes will be written to the related tables: 
    
     mgt=ipmi(nodehm table)
     bmc=70.0.0.9(ipmi table)
     mpa=cmm01(mp table)
     cons=ipmi(nodehm)
     id=11(mp table)
     nodetype=blade(mp table)
     mtm=786310X(vpd table)
     serial=1040BEB(vpd table)
     group=blade,all(nodelist table)
     nodetype=mp,osi(nodetype table)
    

## Modification of rspconfig

We intend to make a rspconfig command to configure the imms that are managed by it. This configuration of imms includes these steps: 
    
     Set IP ***, mask ***, gw *** for imm
    

To be consistent with rspconfig for FSP setup for flex - support added for network=* option for system x. This part will be put in rspconfig part of blade.pm 

We already have support for CMM initnetwork and enable snmpcfg and sshcfg along with password. So there is no rspconfig work needed for CMM setup. 

## Modification of lsslp

we need to keep the discovery process here for three reasons: 

1) We have exposed this user interface in our documents and too much changes in beta version may make it hard to document and even lead confusion. 

2) Since slpdiscover is no used any more so we need to keep this process somewhere. 

3) Lsslp is especially used to do the discovery things, so put this process here is reasonable. 

For the concern of doing setup things in lsslp, I think we can only remove the setup process of cmm and imm from lsslp. 

## Removal of slpdiscover.pm

Once we have confirmed that we have all of the function covered with rspconfig and updated the documentation we will want to disable this .pm. 
