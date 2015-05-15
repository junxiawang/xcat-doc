<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Overview](#1%5C-overview)
- [2\. The attributes that the renergy command will support](#2%5C-the-attributes-that-the-renergy-command-will-support)
- [3\. Implementation details](#3%5C-implementation-details)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

## 1\. Overview

Blade Center has the architecture that all the blade servers are put in one chassis, and all the power of blade servers is supplied by the power modules which installed in the chassis. In the blade center architecture, the blade servers are managed by the Management Module which also is a module installed in the chassis. The Management Module supplies the SNMP interface to manage other modules that installed in the chassis. (includes the blade server modules) 

The Management Module supplies the energy management information of all the modules which installed in the chassis, and supplies the information for each blade server. The renergy command can use the Management module as the target node to get the power information for the whole chassis and use the blade as the node to get the information for the specific blade server. 

## 2\. The attributes that the renergy command will support

2.1 The power attributes supported by chassis 

In the blade center, the power management is divided into two domains. Each domain has two power modules and several blade slots. The power domain information is useful for user to know the power domain status. 

2.1.1 Get the energy information for power domain 1: 

For this domain, the following information will be displayed: 
    
    1. Status of power domain
    SNMP node: fuelGaugeStatus - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.3.x] (x is the domain number)
    
    
    2. Power Management Policy
    Description: It has several values:                    
      redundantWithoutPerformanceImpact(0),
      redundantWithPerformanceImpact(1),
      nonRedundant(2),
      redundantACPowerSource(3),
      acPowerSourceWithBladeThrottlingAllowed(4),
      notApplicable(255)
    SNMP node: fuelGaugePowerManagementPolicySetting - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.6.x]
    
    
    3. The first power module capability in this domain
    Description: Unit is Watt.
    SNMP node: fuelGaugeFirstPowerModule - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.4.x]
    
    
    4. The second power module capability in this domain
    Description: Unit is Watt.
    SNMP node: fuelGaugeSecondPowerModule - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.5.x]
    
    
    5. Total available power in this domain
    Description: This value comes from the installed power modules and the current Power Management Policy Setting
    SNMP node: fuelGaugeTotalPower - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.7.x]
    
    
    6. Power that has been reserved in this domain
    Description: It includes the power reservation for management modules, IO modules and blade servers.
    SNMP node: fuelGaugeAllocatedPower - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.8.x]
    
    
    7. Remaining power available in this domain
    Description: Remaining Power = Total Power - Power In Use
    SNMP node: fuelGaugeRemainingPower - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.9.x]
    
    
    8. Total power being used in this domain 
    SNMP node: fuelGaugePowerInUsed - [.1.3.6.1.4.1.2.3.51.2.2.10.1.1.1.10.x]
    

2.1.2 Get the energy information for power domain 2: 

The attributes are same with ones in the domain 1. 

2.1.3 Get the total available DC 

chassisTotalDCPowerAvailable - [.1.3.6.1.4.1.2.3.51.2.2.10.5.1.1.0] 

2.1.4 Get the total AC in use 

Description: All the power in use + power consumed by the cooling device 

chassisTotalACPowerInUsed - [.1.3.6.1.4.1.2.3.51.2.2.10.5.1.2.0] 

2.1.5 Output Thermal of the chassis 

chassisTotalThermalOutput - [.1.3.6.1.4.1.2.3.51.2.2.10.5.1.3.0] 

2.1.6 The temperature of environment 

frontPanelTemp - [.1.3.6.1.4.1.2.3.51.2.2.1.5.1.0] 

2.1.7 The temperature of management module 

mmTemp - [.1.3.6.1.4.1.2.3.51.2.2.1.1.2.0] 

2.2 The power attributes supported by blade server 

2.2.1 Get the current power allocation for the blade (current power in used) 

SNMP node: pd2ModuleAllocatedPowerCurrent - [.1.3.6.1.4.1.2.3.51.2.2.10.3.1.1.7] 

2.2.2 Get the the maximum power allocation for the blade 

SNMP node: pd2ModuleAllocatedPowerMax - [.1.3.6.1.4.1.2.3.51.2.2.10.3.1.1.8] 

2.2.3 Get the minimum power allocation for the blade 

SNMP node: pd2ModuleAllocatedPowerMin - [.1.3.6.1.4.1.2.3.51.2.2.10.3.1.1.9] 

2.2.4 Get the power capability of the blade 

SNMP node: pd1ModulePowerCapabilities - [.1.3.6.1.4.1.2.3.51.2.2.10.3.1.1.12] 
    
    Values:
    noAbility(0),
    staticPowerManagement(1),
    fixedPowerManagement(2),
    dynamicPowerManagement(3),
    dynamicPowerMeasurement1(4),
    dynamicPowerMeasurement2(5),
    dynamicPowerMeasurementWithPowerCapping(6),
    notApplicable(255)
    

2.2.5 Get/Set the maximum power that can be used by the blade (power capping) 

SNMP node: bladeDetailsMaxPowerConfig - [.1.3.6.1.4.1.2.3.51.2.2.10.4.1.1.1.3] 

2.2.6 Get the Effective CPU Clock Rate 

SNMP node: bladeDetailsEffectiveClockRate - [.1.3.6.1.4.1.2.3.51.2.2.10.4.1.1.1.4] 

2.2.7 Get the Maximum CPU Clock Rate 

SNMP node: bladeDetailsMaximumClockRate - [.1.3.6.1.4.1.2.3.51.2.2.10.4.1.1.1.5] 

2.2.8 Get/Set the static/dynamic power save (looks like the snmp does not support it now) 

SNMP node: bladeDetailsPowerSaverMode - [.1.3.6.1.4.1.2.3.51.2.2.10.4.1.1.1.6] 

  


## 3\. Implementation details

Blade center has two power domains, part of the blade modules accommodated by power domain 1 and others accommodated by power domain 2. Following is the bay map between the server blade bay and domain bay. 

powerDomain1 - contains the serverBladeBay 1-7 
    
    BladeCenter: (serverBladeBay 1-6) (BayNumber 11-16)
    BladeCenter H: (serverBladeBay 1-7) (BayNumber 17-23)
    BladeCenter T: (serverBladeBay 1-4) (BayNumber 13-16)
    BladeCenter HT:(serverBladeBay 1-6) (BayNumber 23-28)
    BladeCenter S:(serverBladeBay 1-6) (BayNumber 18-23)
    

powerDomain2 - contains the serverBladeBay 8-14 (BayNumber 17-23) 
    
    BladeCenter: (serverBladeBay 7-14) (BayNumber 1-8)
    BladeCenter H: (serverBladeBay 1-7) (BayNumber 17-23)   "It should be the serverBladeBay 8-14. It's a bug and has been fixed."
    BladeCenter T: (serverBladeBay 5-8) (BayNumber 3-6)
    BladeCenter HT:(serverBladeBay 7-12) (BayNumber 3-8)
    
