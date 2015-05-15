<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Switch Discovery and Switch Management](#switch-discovery-and-switch-management)
  - [Overview](#overview)
  - [Switch Discovery](#switch-discovery)
  - [Switch Definition](#switch-definition)
  - [Switch Management](#switch-management)
  - [Documentation](#documentation)
- [Switches Supported](#switches-supported)
  - [Packaging, installation, dependencies](#packaging-installation-dependencies)
  - [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

# Switch Discovery and Switch Management

## Overview
This feature request comes from a custom. The customer requested that xCAT be able to do switch discovery from xCAT mn for a subnet,  get all the switches defined in the xCAT DB with their IP, mac, model and serial number, and configure the switches to enable VLAN, bonding, SNMP and others which needed by solution. So the feature will be divided into following three categories:

* switch discovery
* switch definition
* switch management 
 
## Switch Discovery
There are several different tools we can use to discover a switch. 
1. lldpd http://vincentbernat.github.io/lldpd/index.html.  It supports several discovery protocols:
    * LLDP (For all switches that has LLDP enabled, for example: BNT switches)
    * CDP (For Cisco switches)
    * EDP (For Extreme switches)
    * SONMP (For Nortel switches)
    * FDP (For Foundry switches)
It can provide a lot of information about the switch like system name and description, port name and description, IPv4/IPv6 management address, MAC/PHY information,etc.
2. NMAP http://nmap.org/. It is a utility for network discovery and security auditing. NMAP detects available hosts on the network, the services the hosts are offering, the operating systems (and OS versions) the hosts are running etc. We can use this tool to detect switches that are not LLDP enalbled, for example Mellanox IB switches. 
3. SNMP http://en.wikipedia.org/wiki/Simple_Network_Management_Protocol. It is a popular protocol for network management. It is used for collecting information from, and configuring, network devices, such as servers, printers, hubs, switches, and routers on an Internet Protocol (IP) network. 


A new command called switchdiscover will be introduced in xCAT 2.10 release to scan the subnets and discover all the switches on the subnets. The default subnets will be the ones that the xCAT management node is on. The command will also take a subnet as an input. The default discovery method will be lldpd. The nmap and snmp methods will be supported as options chosen by some flags. The following is the format of the command. It is trying to be consistent with lsslp command for flags.

       switchdiscover   [-h| --help]

       switchdiscover   [-v| --version]

       switchdiscover [noderange] [-i adpt[,adpt..]][-w][-r|-x|-z][-n][-s scan_methods]

       noderange   The switches which the user want to discover.
                   If the user specify the noderange, this command will just return the switches in
                   the node range. Which means it will help to add the new switches to the xCAT
                   database without modifying the existed definitions. But the switches'name
                   specified in noderange should be defined in database in advance, the ips of the
                   switches be defined in /etc/hosts file. This command will fill the switch
                   attributes for the switches defined.


       -i          The adapters the command will search through. (defaults to all available adapters).

       -h          Display usage message.

       -n          Only display and write the newly discovered switches.

       --range     Specify one or more IP ranges. 
                   It accepts multiple formats. For example, 192.168.1.1/24, 40-41.1-2.3-4.1-100.
                   If the range is huge, for example, 192.168.1.1/8,  switchdiscover may take a 
                   very long time for node scan.
                   So the range should be exactly specified.

       -r          Display Raw response.

       -s          It is a comma separated list of methods for switch discovery. The possible 
                   switch scan methods are: llpd, nmap and snmp. The default is lldpd.

       -v          Command Version.

       -V          Verbose output.

       -w          Writes output to xCAT database.

       -x          XML format.

       -z          Stanza formatted output.




## Switch Definition
xCAT currently has a switches table for switch related information. The switch discovery process will populate this table as well as vpd and mac tables. A new switch def object will be create to represent a switch. It will include switch name, ip, mac, model, serial number, login info, snmp access info etc.

## Switch Management
For this release, xCAT will not do a lot of switch management functions. Instead, it will configure the switch so that the admin can run remote command such as xdsh for it. Thus, the admin can use the xdsh to run proprietary switch commands remotely from the xCAT mn to enable VLAN, bonding, SNMP and others. 

In order to run xdsh, ssh must be setup on the switch. Because switches from different vendors have different ways to get ssh setup, we need more investigation in this area. Currently xCAT supports enabling/disabling ssh to switch without password for Mellanox switches with rspconfig command. 

     rspconfig <switch> sshcfg=enable/disable 

We intend to use this command for the Ethernet switches.

## Documentation
Since a new command will be introduced. Its usage will be documented in the man page. The [Managing Ethernet Switches](Managing_Ethernet_Switches) and [Managing the Mellanox Infiniband Network](Managing_the_Mellanox_Infiniband_Network1) external documents will be updated with switch discovery function. 

# Switches Supported
* BNT
* Cisco
* Mellanox

## Packaging, installation, dependencies
nmap and snmp are already required by xCAT. lldpd will be added as a new dependency for xCAT and xCATsn packages. Since lldps does not come from the OS distros, xCAT will put it into the xcat-dep tarball.


## Other Design Considerations

  * **Required reviewers**: Guang Cheng, Ting Ting.
  * **Required approvers**: Guang Cheng 
  * **Database schema changes**: Yes. Will add switch def object. 
  * **Affect on other components**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 