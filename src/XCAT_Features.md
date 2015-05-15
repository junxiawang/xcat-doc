<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2 Features and Supported HW/OS](#xcat-2-features-and-supported-hwos)
  - [Highlights](#highlights)
  - [OS Support](#os-support)
  - [Hardware Support](#hardware-support)
  - [Hardware Control Features](#hardware-control-features)
  - [Additional Features](#additional-features)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[[img src=Official-xcat-doc.png]] 


# xCAT 2 Features and Supported HW/OS

xCAT 2 is not an evolution or a rewrite of xCAT 1.x. xCAT 2 is a revolutionary new project created by the best cluster management developers at IBM. This team consists of IBM CSM, xCAT 1.x, System x, System p, e1350, and iDataPlex developers. 

## Highlights

  * Client/server architecture. Clients can run on any Perl compliant system (including Windows). All communications are SSL encrypted. 
  * Role-based administration. Different users can be assigned various administrative roles for different resources. 
  * Stateless,statelite and iSCSI support. Stateless can be RAM-root, compressed RAM-root, or stacked NFS-root. Linux software initiator iSCSI support for RH and SLES included. Systems without hardware-based initiators can still be iSCSI installed and booted. 
  * Windows support: imagex, rinstall, and iSCSI. 
  * Kvm and VMWare full virtualized support, including the rmigrate command to request live migration of a virtualized guest from one host to another. 
  * Scalability. xCAT 2.x was designed to scale beyond your budget. 100,000 nodes? No problem with xCAT's Hierarchical Management Cloud (HMC). A single A Management node may have any number of service nodes to increase the provisioning throughput and management of the largest clusters. All cluster services such as LDAP, DNS, DHCP, NTP, Syslog, etc... are configured to use the Hierarchical Management Cloud. Outbound cluster management commands (e.g. rpower, xdsh, xdcp, etc...) utilize this hierarchy for scalable systems management. 
  * [Automagic discovery](Node_Discovery). Single power button press, physical location based, discovery and configuration capability. "Any sufficiently advanced technology is indistinguishable from magic." -- Arthur C. Clark. 
  * Choice of database backend: SQLite, Postgresql, MySQL, DB2. 
  * Plug-in architecture for compartmental development. Add your own xCAT functionally to do what ever you want. New plug-ins extend the xCAT vocabulary available to xCAT clients. 
  * Monitoring plug-in infrastructure to easily integrate 3rd party monitoring software into xCAT cluster. Plug-ins provided with xCAT: SNMP, RMC, Ganglia, Performance Copilot (more in future) 
  * Notification infrastructure to be able to watch for xCAT DB table changes. 
  * SNMP monitoring. Trap handler handles all SNMP traps. 
  * Node status update (nodelist.status is updated during the node deployment node power on/off and updatenode processing). 
  * Centralized console and systems logs. 
  * Software/firmware inventory command to detect variance between nodes. Software inventory for images too. 
  * Automatic installation of any additional rpms requested by the user during node deployment phase and after the nodes are up and running. 
  * Documentation: online wiki, pdfs, complete man pages, database table documentation 
  * Eclipse Public License. 

## OS Support

Note: the list of supported distros is constantly changing, but here's what's supported as of 10/3/2013. 

The supported OS's vary depending on the node provisioning method... 

  * Traditional local disk and SAN provisioning using native deployment methods (kickstart, etc.): 
    * SLES10 SP2 or higher, SLES 11 SPx, SLES 12, RHEL 5.x &amp; 6.x, CentOS 5.x &amp; 6.x, SL 5.x &amp; 6.x, Fedora 8-19, Ubuntu 12.04 &amp; 13.04, AIX 6.1, 7.1 (all available Technology Levels), Windows 2008-2012, Windows 7 
  * Stateless (RAM-root diskless): 
    * All of the OS's listed above in the traditional diskful provisioning, **except**: SLES12, AIX and Windows 
  * Statelite (NFS-root diskless): 
    * All of the OS's listed above for stateless, **plus** AIX 6.1, 7.1 (all available Technology Levels), but **not** Ubuntu 
  * Stateful diskless using iSCSI: 
    * All of the versions listed above for SLES, RHEL/CentOS/Fedora, and Windows 
  * Imaging (cloning): 
    * RHEL 6 and SLES 11 SP2 &amp; SP3, AIX 6.1, 7.1 (all available Technology Levels), Windows 2008 
  * Note: AIX 5.3 is no longer supported in xCAT 2.5 and above. 

## Hardware Support

Here's what's supported as of 03/15/2013: 

  * All IBM Bladecenter and System x hw that is part of the IBM Intelligent Cluster 
  * All iDataplex hw 
  * All IBM Flex hw 
  * Most IPMI-controlled x86_64 machines, if not IBM/Lenovo we need to work with you.
  * All System p hardware 
  * All System z hardware running zVM 

## Hardware Control Features

  * Power control 
  * Boot device control (full boot sequence on Bladecenter, next boot device on other systems) 
  * Sensor readings (Temperature, Fan speed, Voltage, Current, and fault indicators as supported by systems) 
  * Collection of MAC addresses 
  * Event logs 
  * LED status/modification (identify LED on all systems, diagnostic LEDs on select IBM rack mount servers) 
  * Serial-over-LAN (SOL) 
  * Service processor configuration. 
  * Hardware control point discovery using SLP (MM, HMC, FSP) 
  * Virtual partition creation 

## Additional Features

  * CLI mode, scripts, simple text based config files 
  * Uses perl primarily 
  * xcat installed linux nodes are identical to kickstart or autoyast installed nodes, wrt RPMs, etc. Nothing is altered from the distro (eg: Rocks switched from /etc/passwd to 411 for authentication), we use stock kernels. So, if commercial support is critical, xcat has a better story. 
  * Multiple distros: AIX,SLES, OpenSUSE, RHEL, CentOS, SL, FC, Windows via imaging is supported. You can even have mixed OSs in a single cluster with certain limitations. 
  * Works well with any x86/x86_64 server (even non-IBM servers). 
  * IBM Bladecenter and iDataPlex are fully supported 
  * Custom extensions need only minimal effort: eg adding a new distro. 
  * PBS, GPFS, Myrinet installations are supported 
  * Postscripts - Post installation scripts supported for both diskful and diskfree environments. 
