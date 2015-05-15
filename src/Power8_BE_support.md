Overview

This design describes the xCAT 2.8.5 support for Power 8 BE, specifically Tuleta. The basic idea is to take the Tuleta as a general Power box and support the hw ctrl, os provisioning and Infiniband features. Because of the resource and schedule constrains, with xCAT 2.8.5, only part of the hw ctrl capabilities will be support and only RHEL 7 will be supported.

Features supported on Power 8 BE in xCAT 2.8.5

1. Hardware discovery
    1.1 Define the HMC as node object
       
    [root@xcatmn ~]# lsdef hmc01
    Object name: hmc01
        groups=hmc,all
        hwtype=hmc
        ip=x.x.x.x
        mgt=hmc
        nodetype=ppc
        password=abc123
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles
        username=hscroot
    
    Create the hostname and ip address mapping.
    [root@xcatmn ~]# makehosts hmc01    
    
    1.2 Discover CECs and LPARs through HMC
    
    [root@xcatmn ~]# rscan hmc01 -w
    type    name                       id      type-model  serial-number  side  
    cec     Server-8284-22A-SN1084A7T          8284-22A    1084A7T              
    hmc     hmc01                              7042-CR5    10F0D1B              
    lpar    lpar1                      1       8284-22A    1084A7T


2. Hardware initialization
    2.1 Configure password-less ssh between xCAT management node and HMC
        rspconfig <node> sshcfg=enable        
        
    2.2 Firmware update
        rflash cec_name -p /tmp/fw --activate disruptive

3. Hardware control
    3.1 remote power
        rpower node [on|off|...]
    3.2 remote console
        rcons node   
    3.3 network boot
        rnetboot node
       
4. Hardware inventory (rinv)
    4.1 MTMS
    4.2 Physical slots information
    4.3 Number of processors       
    4.4 Amount of memory
    4.5 Firmware version
    4.6 MAC addresses

5. Hardware vitals (rvitals)
    5.1 Power/system status
    5.2 LCDs

6. OS support - RHEL 7 only

7. Infiniband support - FDR

Features not supported on Power 8 BE in xCAT 2.8.5

The following features will not be supported on Power 8 BE machine in xCAT 2.8.5, the decision was made based on the requirements from different teams, we will investigate on supporting these features in a later release like in xCAT 2.9. 


1. Partitioning


2. DFM


3. Energy management


4. SLP hardware discovery and hardware connections management, this feature is for HMC-managed scalability configuration

Other Design Considerations
•    Required reviewers: xCAT ALL
•    Required approvers: Li Guang Cheng, Joan McComb
•    Database schema changes: N/A
•    Affect on other components: N/A
•    External interface changes, documentation, and usability issues: Yes
•    Packaging, installation, dependencies: N/A
•    Portability and platforms (HW/SW) supported: Tuleta, RHEL 7.
•    Performance and scaling considerations: N/A
•    Migration and coexistence: Yes
•    Serviceability: N/A
•    Security: N/A
•    NLS and accessibility: N/A
•    Invention protection: N/A