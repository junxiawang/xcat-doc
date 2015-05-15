<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Integrate xCAT with event logging software](#integrate-xcat-with-event-logging-software)
  - [HW service events collected from HMCs to EMS](#hw-service-events-collected-from-hmcs-to-ems)
- [when the mn is down for a period of time](#when-the-mn-is-down-for-a-period-of-time)
- [when we failover to the backup mn](#when-we-failover-to-the-backup-mn)
- [when an HMC goes down](#when-an-hmc-goes-down)
- [when an HMC fails over to the backup hmc (if we even support this)](#when-an-hmc-fails-over-to-the-backup-hmc-if-we-even-support-this)
  - [Predefined conditions to support Failure analysis](#predefined-conditions-to-support-failure-analysis)
  - [Exploitation of batched event hierarchical support](#exploitation-of-batched-event-hierarchical-support)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


##Integrate xCAT with event logging software
 
The event logging software is closely tied with xCAT. It uses xCAT's database to store the events to the table defined by this software.  xCAT's configuration/setup for the event logging software includes the following:
* xCAT's external table support allows 3rd party to add its own tables into xCAT's database. 
* xCAT helps to set up the management domain for RMC monitoring to be used by the event logging software 
* xCAT helps it to create conditions, responses and sensors on the mn, sn and the nodes

In order for consolidate all the events into one table, xCAT will also provides responses to write the events from the conditions that are monitored by xCAT into the same event log table for the event logging software.

##HW service events collected from HMCs to EMS 
 
The SFP connector the event logging software collects the servicable events from a HMC. xCAT will configure the HMC so that it sends the events to the mn to be captured by the SFP connector. 
we need to reliably get all of the hw service events from the hmcs to the ems.  Specifically, we don't want to miss events in the following situations:
#when the mn is down for a period of time
#when we failover to the backup mn
#when an HMC goes down
#when an HMC fails over to the backup hmc (if we even support this)
The proposed approach is to use the rmc batched event capability and create a condition on each hmc that monitors the sensor and tells errm to batch up the events in batch files on the hmc (probably with a short duration so service events come to the ems pretty quickly).  The ems then needs some code that monitors the conditions on the hmcs and retrieves new batch files when created.  It also needs to record which batch files have been retrieved so that when the ems first comes (back) up, it can look at its records and look at the batch files on the hmcs and retrieve any that haven't been retrieved yet.


##Predefined conditions to support Failure analysis 
 
More predefined conditions, responses and sensors will be provided to monitor the p7 HW and HPC software. 

##Exploitation of batched event hierarchical support 
Events can be batched in RMC and only one response can be send out for batched event. Batched events are stored in a file. There are some attributes on the Condition class that indicate when a batched event file is ready to be processed.  xCAT will supply some new responses that will be installed on mn. When called, they go to the sn to get the batch event file and parse it, then call the action commands.