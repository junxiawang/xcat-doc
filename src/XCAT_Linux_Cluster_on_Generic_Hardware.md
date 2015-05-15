<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [IPMI settings](#ipmi-settings)
- [General guideline](#general-guideline)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**We need help writing this document! If you would like to help, please post to the xCAT mailing list.**

Although xCAT has specific support for IBM and HP hardware, it has been successfully used on other hardware. This document will contain the tricks that are helpful for using xCAT on other hardware and the list of functions that will work in that environment. 

xCAT has been successfully used on the following vendors: 

  * IBM 
  * HP 
  * Dell 
  * Oracle (Sun) 
  * Fujitsu 
  * SuperMicro 
  * Intel 

### IPMI settings

You need to configure the [ipmi settings](http://sumavi.com/sections/ipmi-settings) inside the ipmi table. For each node you would need at least to tell the node in the nodehm table that it is managed by ipmi and to specify the IP address or hostname for the IPMI device. 
    
    nodech <noderange> nodehm.mgt=ipmi
    nodech <node> ipmi.bmc=10.3.0.34
    

This command lists the settings: 
    
    nodels <noderange>nodehm ipmi
    

It is easy with the passwd.cvs template in /opt/xcat/share/xcat/templates/e1350 to set the general username and password for IPMI. After editing the file you load the template into your database: 
    
    cd /opt/xcat/share/xcat/templates/e1350
    tabrestore passwd.csv
    

A simple test to check the IPMI settings is to display the power state of a node. 
    
    rpower node001 status
    node001: on
    

### General guideline

As a general guideline, you can follow the [XCAT_iDataPlex_Cluster_Quick_Start], since that is also IPMI-controlled hardware. If there are differences for specific hardware, they will be listed here (in this doc you are reading). 
