<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Required Reviewers](#required-reviewers)
  - [Required Approvers](#required-approvers)
- [Background](#background)
- [Overview](#overview)
  - [makentp](#makentp)
  - [Database changes](#database-changes)
  - [Changes to existing code](#changes-to-existing-code)
    - [**AAsn.pm**](#aasnpm)
    - [**xcatconfig**](#xcatconfig)
    - [**setupntp**](#setupntp)
    - [**new option**](#new-option)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

  



### Required Reviewers

  * Lissa Valletta 

  


### Required Approvers

  * Bruce Potter 

## Background

## Overview

This design is to add automatic setup of a NTP server on the Management Node. It also changes/improves the setup of NTP on the nodes. This can be implemented in 2.8.2 or even 2.8.3. 

### makentp

**makentp** is a new command that will be written to setup a NTP server on the Management Node. It will need to read the new site table externalntpserver attribute to get the address(s) of the external time servers to use for time. If none defined, use MN's local clock. 

makentp will need to check to see if the NTP server is already setup (either by makentp or the admin). It will need to determine, if it needs changing and restarting. For example, if the external server changed. If no change, just exit. 

If the logic needed in makentp is very similar to what is done in setupntp for the service node, then makentp could just query site.externalntpserver and pass it into setupntp. 

### Database changes

A new site table attribute, externalntpservers, will be added to list addresses of NTP servers to be used for clock time by the Management Node. 

makedhcp needs to honor the site.ntpservers and networks.ntpservers. 

### Changes to existing code

#### **AAsn.pm**

AAsn.pm will be modified, if running on the Management Node and there is a servicenode table entry for the MN and ntpserver is set, it will then call makentp, to setup the NTP Server on the MN. 

#### **xcatconfig**

For a new install, xcatconfig should add the setupntp postscript to the default postscripts. This is only for new install, because for existing xCAT clusters, the admin may already have created and added a ntp setup postscript by some other name. 

#### **setupntp**

Evaluate the current logic in setupntp, and also see if the suggestion in this defect should be added. https://sourceforge.net/p/xcat/bugs/3048/ 

#### **new option**

Add a new option to sync hw clock. It's set to "no" by default in file /etc/sysconfig/ntpdate: 
    
    # Set to 'yes' to sync hw clock after successful ntpdate
    SYNC_HWCLOCK=no
    

## Other Design Considerations

  * **Required reviewers**: Bruce, Lissa, Guang Cheng 
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
