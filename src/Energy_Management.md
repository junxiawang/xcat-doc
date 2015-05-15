<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Energy Management**](#energy-management)
  - [**Query power information**](#query-power-information)
  - [**Power saving**](#power-saving)
  - [**Prerequisite**](#prerequisite)
  - [**Supported hardware**](#supported-hardware)
- [Appendix: System P hardware discovery Directly from xCAT MN](#appendix-system-p-hardware-discovery-directly-from-xcat-mn)
  - [**Prerequisites**](#prerequisites)
  - [** System P Hardware and HMC**](#-system-p-hardware-and-hmc)
    - [**Setting up the HMC network for use by xCAT**](#setting-up-the-hmc-network-for-use-by-xcat)
    - [**Cleanup BPA/FSP IPs Service Network for HMC environment**](#cleanup-bpafsp-ips-service-network-for-hmc-environment)
  - [**xCAT DB setup with HW Discovery**](#xcat-db-setup-with-hw-discovery)
    - [**Setup DHCP server**](#setup-dhcp-server)
      - [**Update networks table**](#update-networks-table)
      - [**Stop bootp and initialize DHCP (AIX only)**](#stop-bootp-and-initialize-dhcp-aix-only)
      - [**Configure the network interface for DHCP**](#configure-the-network-interface-for-dhcp)
      - [**Specify the dhcp network interface in site table**](#specify-the-dhcp-network-interface-in-site-table)
      - [**Generate dhcp configuration file**](#generate-dhcp-configuration-file)
      - [**Power on all the frames and CECs**](#power-on-all-the-frames-and-cecs)
    - [**Create node definitions for the hardware components**](#create-node-definitions-for-the-hardware-components)
    - [**Update the node definitions with vpd and ppc information**](#update-the-node-definitions-with-vpd-and-ppc-information)
      - [**Discover HMCs/frame/CECs, and define them in xCAT DB**](#discover-hmcsframececs-and-define-them-in-xcat-db)
      - [**Update xCAT database directly with lsslp**](#update-xcat-database-directly-with-lsslp)
    - [**Make the dynamic IP addresses permanent**](#make-the-dynamic-ip-addresses-permanent)
  - [**Define the hardware control point for the Frames/CECs.**](#define-the-hardware-control-point-for-the-framescecs)
  - [**Make connections from Frames/CECs to HMC**](#make-connections-from-framescecs-to-hmc)
  - [Define the Compute Nodes](#define-the-compute-nodes)
  - [Discover the LPARs managed by HMC using rscan](#discover-the-lpars-managed-by-hmc-using-rscan)
  - [Define xCAT node using the stanza file](#define-xcat-node-using-the-stanza-file)
  - [Define xCAT nodes using xcatsetup](#define-xcat-nodes-using-xcatsetup)
  - [**HW Discovery Limitations**](#hw-discovery-limitations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## **Energy Management**

xCAT delivered a renergy command to manage the energy related functions for System p hardware. Basically, renergy command supports to query the power consumption, power capping, temperature, CPU frequency of hardware and set the status to enable/disable the power saving, power capping.

The renergy command can only operate against CEC or fsp objects. For general attributes, the CEC objects can be managed by HMC or direct managed through fsp. But for the FFO functions, only the direct fsp managed CEC/fsp can be accepted.

### **Query power information**

Power consumption: Query the average AC and DC consumption for a CEC. For certain type of CEC, the AC value is getting for the whole frame.

  * Power capping: Query the capping value which can be set to a CEC and the current capping value as well.

~~~~
    renergy CEC1 cappingstatus cappingmaxmin cappingvalue cappingsoftmin
~~~~


  * Temperature of the CEC: Get the ambient and exhaust temperature of a CEC.

~~~~
    renergy CEC1 ambienttemp exhausttemp
~~~~


  * CPU frequency: Get the CPU frequency of a CEC.

~~~~
    renergy CEC1 CPUspeed
~~~~


  * Power saving status: Get the power saving status for static, dynamic and FFO (fixed frequency override)

~~~~
    renergy CEC1 savingstatus dsavingstatus fsavingstatus
~~~~


### **Power saving**

  * Static power saving

If turning on the static power saving, the processor frequency and voltage will be dropped to a fixed value to save energy.

~~~~
    renergy CEC1 savingstatus=on
~~~~


  * Dynamic power saving

If turning on the dynamic power saving, the processor frequency and voltage will be dropped dynamically based on the core utilization. It supports two modes for turn on state: on-norm - means normal, the processor frequency cannot exceed the nominal value; on-maxp - means maximum performance, the processor frequency can exceed the nominal value.

~~~~
    renergy CEC1 dsavingstatus=on-norm
~~~~


  * Fixed frequency power saving (FFO)

Set the CPU frequency to a fixed value to save the power consumption.

~~~~
    renergy CEC1 fsavingstatus=on
~~~~


  * Power capping

Set the maximum power consumption for a CEC.

~~~~
    renergy CEC1 cappingstatus=on
    renergy CEC1 cappingwatt=2500
~~~~


### **Prerequisite**

For the System p, the renergy command depends on the Energy Management Plug-in xCAT-pEnergy to communicate with server. xCAT-pEnergy can be downloaded from the IBM web site: http://www.ibm.com/support/fixcentral/. (Other Software -> EM)

~~~~
    Product Group:      Power
    Product:            Cluster Software
    Cluster Software:   System p Energy Management plug-in for xCAT (EM)
~~~~


### **Supported hardware**

~~~~
8203-E4A, 8204-E8A, 9125-F2A, 8233-E8B, 8236-E8C, 9125-F2C
~~~~

Note: Not all the attributes are available for every type of hardware, refer to the man page of renergy for the support list for each hardware type.

## Appendix: System P hardware discovery Directly from xCAT MN

Note: this section is only recommended for very large clusters. For most clusters it is much simpler to follow [XCAT_System_p_Hardware_Management/#system-p-setup-with-hmc-discovery](XCAT_System_p_Hardware_Management/#system-p-setup-with-hmc-discovery).

This chapter will introduce how the xCAT MN can discover HMCs, System P frames with their BPAs, and CECs with their FSPs working with xCAT lsslp command. The System P hardware will be discovered on the xCAT service network, and then added to xCAT database as node attributes.

### **Prerequisites**

Before performing hardware discovery, users should confirm the following database setup:

~~~~
  tabdump site table
~~~~

Make sure the following attributes in [site](http://xcat.sourceforge.net/man5/site.5.html) table are set to match your xCAT cluster site environment:

~~~~
       domain
       nameservers
       ntpservers
       dhcpinterfaces

~~~~

  * **Add the default account for hmc**

~~~~
    chtab key=hmc passwd.username=hscroot passwd.password=abc123
~~~~


Note: The username and password for xCAT to access an HMC can also be assigned directly to the HMC node object using the mkdef or chdef commands. This assignment is useful when a specific HMC has a username and/or password that is different from the default one specified in the passwd table. For example, to create an HMC node object and set a unique username or password for it:

~~~~
    mkdef -t node -o hmc1 groups=hmc,all nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc1234
~~~~


or to change it if the HMC definition already exists:

~~~~
    chdef -t node -o hmc1 username=hscroot password=abc1234
~~~~


  * **Network configuration**

The xCAT Management Node needs to be properly connected to the xCAT service network which is used with all HMCs, System P frames and CECs being used in the xCAT cluster. This service network should be located on a private subnet to allow the xCAT MN DHCP server to communicate with HMCs, BPAs (frame), and FSPs (CECs) in your cluster.

In a larger cluster where Service Nodes are being used for hardware management and OS deployment, then these Service Nodes also need to be connected to the private service network to communicate to each frame BPA and CEC FSP.




### ** System P Hardware and HMC**

The hardware management function with HMC connection is currently supported for System P hardware (P5,P6,P7) and xCAT 2.3.4 or later releases.

HMCs should be configured with static ip addresses working in the HW service VLAN, so that they can communicate with xCAT MN. Because the xCAT MN runs the DHCP server on the service VLAN, the DHCP service on the HMCs should be turned off prior to performing the xCAT HW discovery function. (By default, the DHCP service is disabled for all network interfaces on HMC.)

The DHCP service can be run from different server that is connected to the xCAT service VLAN, instead of the xCAT MN. In this case, users need to configure the DHCP service manually on the DHCP server, and skip the step "Setup DHCP service on MN" .

#### **Setting up the HMC network for use by xCAT**

The following are minimal steps required to Setup the HMC network for Static IP,and enable SLP and SSH ports working with HMC GUI. Reference the HMC website and documentation for more details.

  * Open the HMC GUI, Select **HMC Management**, then **Change Network Settings**.
  * Select **Customize Network Configuration**, and then** LAN Adapters **.
  * Select **Ethernet interface **configured on the service network.
  * Click on the **Details **button.
  * Select **Basic Settings**, Click on **Open**, and **Specify IP address.**
  * Fill in **IP address**, **Netmask**for HMC static IP on the xCAT service network.
  * Make sure that DHCP Server box is not selected and is blank.
  * Select on **Firewall Settings**, Click on **SLP, Secure Shell, **in the upper window.
  * (You may also want to enable other HMC Firewall settings)
  * Click on the **Allow incoming **button for each required setting.
  * Make sure you Select OK at the bottom of the window to save your updates.
  * Reboot the HMC, and then make sure Network changes are properly working.

The Frame and CEC should be configured to use dynamic IPs by default, so that the DHCP server can properly assign hardware IP addresses in the xCAT service VLAN. (If the administrator wants to use static ip addresses with the BPA/FSP, they must use the proper service VLAN subnet address range specified by the DHCP server.)

#### **Cleanup BPA/FSP IPs Service Network for HMC environment**

The xCAT administrator needs to make sure that BPA/FSP ip addresses and server node names are planned out and are properly defined when working with the xCAT Database, and the DHCP environment. There should be no issues, if this is a new xCAT System P cluster installation, where the frames and CECs are being specified in the xCAT database and HMC for the first time.

For existing xCAT 2.5 clusters setup with a HMC DHCP server environment where BPA/FSPs are already acknowledged by HMC and xCAT DB, it is important that they use the same existing BPA/FSP network ip addresses and server node names. This includes setting up the DHCP server dynamic address ranges to match the current subnets used by the BPA/FSPs.

If the service network requires changes to the BPA/FSP ip addresses, the administrator should plan to cleanup the current BPA/FSP environment. It includes doing cleanup for both the HMC and the xCAT Database for any IP addresses and server node name changes.

For the HMC, the administrator should plan to remove the existing frames and servers that will require new HW IP addresses or server hostnames working in the xCAT service VLAN. This will allow the xCAT mkhwconn command to reinitialize the frame and CECs using the xCAT DB information to make new HW connections to the HMC.

For the xCAT Management Node (MN), the administrator should review the xCAT database using lsdef and tabdump commands to check for any existing HMC/frame/BPA/CEC/FSP node objects that require updates. The xCAT chdef command can be used to modify server node attributes. The rmdef command can be used to remove the HMC/frame/BPA/CEC/FSP node objects to get to a clean state. It is important that the xCAT administrator also clean up Domain Name Service (DNS) and the /etc/hosts file make sure the HMC/frame/Server IP addresses and host names are matching the proper settings required for their xCAT cluster.

### **xCAT DB setup with HW Discovery**

This section describes the xCAT DB tables and commands used to work with xCAT HW discovery. It will properly define the xCAT support requirements for the HW service network, DHCP server, and how ip addresses are defined for the BPAs and FSPs.

#### **Setup DHCP server**

##### **Update networks table**

All the FSPs and BPAs need to receive their dynamic ip addresses from the DHCP server. The first step is to create an xCAT network object in the xCAT DB using with [mkdef](http://xcat.sourceforge.net/man1/mkdef.1.html) command for the service VLAN used by xCAT cluster.

Here is an example mkdef stanza for creating a network object:

~~~~
    vlan1:
        objtype=network
        dhcpserver=192.168.200.205
        gateway=192.168.200.205
        mask=255.255.255.0
        mgtifname=en0
        net=192.168.200.0
        dynamicrange=192.168.200.1-192.168.200.224
~~~~

In this example, the xCAT MN connects to the service vlan1 on network interface name en0. The "192.168.200.1-192.168.200.224" field indicates the dynamic ip range that is used by DHCP to give dynamic IP addresses to the BPA/FSPs on the service network. The IP address 192.168.200.205 is the DHCP server, which is also the xCAT MN.

The xCAT command **makenetworks** is executed on the MN when xCAT is install and populates the xCAT networks table, but this command will not specify the dynamic range field. Use the following lsdef command to see if an entry for the service network has already been created:

~~~~
    lsdef -t network -l
~~~~


If so, then you only need to set the dynamicrange attribute in the service network object using the xCAT [chdef](http://xcat.sourceforge.net/man1/chdef.1.html) command.

##### **Stop bootp and initialize DHCP (AIX only)**

For AIX clusters, there is a bootp service daemon on the xCAT MN that is used by default for AIX node installations. If the DHCP server for the service network is the xCAT management node, you will need to disable the bootp service and enable dhcpsd in rc.tcpip so that the dhcp service will start during system boot up.

Stop bootp from rebootting by commenting out the bootps line in /etc/inetd.conf file:

~~~~
    #bootps dgram udp wait root /usr/sbin/bootpd bootpd /etc/bootptab
~~~~


Restart the inetd subsystem:

~~~~
     refresh -s inetd
~~~~


Stop bootp deamon:

~~~~
    ps -ef | grep bootp
    kill the bootp process
~~~~


Start up the DHCP Server

~~~~
    start /usr/sbin/dhcpsd "$src_running"
~~~~


Stop and restart the tcpip group

~~~~
    stopsrc -g tcpip
    startsrc -g tcpip
~~~~


##### **Configure the network interface for DHCP**

It is necessary to configure a static IP address for each network interface that is used by DHCP on the xCAT Management Node to communicate on the service networks. This is necessary so that the DHCP server can provide service automatically after a reboot.

The following examples use eth0 as the DHCP network interface:

  * For RHEL, the network configuration is in a file named like /etc/sysconfig/network-scripts/ifcfg-eth0:

~~~~
    DEVICE=eth0
    BOOTPROTO=static
    HWADDR=00:14:5E:5F:20:90
    IPADDR=192.168.200.205
    NETMASK=255.255.255.0
    ONBOOT=yes
~~~~


  * For SLES, the network configuration is in a file named like /etc/sysconfig/network/ifcfg-eth0:

~~~~
    DEVICE=eth0
    BOOTPROTO=static
    HWADDR=00:14:5E:5F:20:90
    IPADDR=192.168.200.205
    NETMASK=255.255.255.0
    STARTMODE=onboot
~~~~


  * For AIX Clusters, issue the following command to define the static IP address for the network interface:

~~~~
    mktcpip -a 192.168.200.205 -i en0 -m 255.255.255.0
~~~~


##### **Specify the dhcp network interface in site table**

In the [site](http://xcat.sourceforge.net/man5/site.5.html) table, the attribute dhcpinterfaces should be set to the network interfaces being used for hardware discovery. Assuming DHCP will be used for node installations, the network interface on the compute network should also be included here, but can be added at a later date.

~~~~
    chdef -t site clustersite dhcpinterfaces=en0
~~~~


##### **Generate dhcp configuration file**

The xCAT command [makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html) can be used with the -n flag to create the dhcp service configuration file based on attributes found in the xCAT site and networks tables. In this configuration file, the dynamic address range IP pool is created based on the field dynamicrange in networks table.

~~~~
    makedhcp -n
~~~~


If there are no definitions listed in the networks table and dhcpinterfaces is blank, the makedhcp command will try to generate a DHCP service for all active subnets found on xCAT MN, even if there are no dynamic IP ranges specified. Verify the DHCP configuration files on the xCAT MN to ensure that they contain only the networks you want.

~~~~
    cat /etc/dhcpd.conf   # (Linux)
    cat /etc/dhcpsd.cnf   # (AIX)
~~~~


##### **Power on all the frames and CECs**

After physical installation and checkout of the Frames/CECs has been completed, power them on. All the FSPs and BPAs should get dynamic IP addresses from the DHCP server.

**Note:** If the frame was already powered on when dhcp was configured/started, you will have to restart the slp daemon on **each fsp** before running lsslp:

~~~~
    $ killall slpd
    $ netsSlp
~~~~


#### **Create node definitions for the hardware components**

Create skeleton definitions for the hardware components. They will be used by the lsslp command.

~~~~
    mkdef frame01-frame16 groups="all,frame" hcp=hmc
    mkdef f[01-16]cec[01-12] groups="all,cec" hcp=hmc
    mkdef f[01-16]fsp[01-12] groups="all,fsp"    # do we really need to create the fsps???  Won't lsslp do that?

~~~~

#### **Update the node definitions with vpd and ppc information**

Before doing the full lsslp discovery, you must specify a few vpd and ppc attributes in the skeleton definitions so that lsslp can associate the hardware components discovered on the network with the definitions in the xCAT database.

For the high end servers such as POWER 595/575 that exist in 24 inch frames, you only need to specify the Frame MTMS information, since the CECs (FSPs) will be automatically located by the BPA. For the System P low end servers that exist in 19 inch frames such as POWER 520, the CEC MTMS information must also be specified. To specify the VPD information, we will use [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to help us create a stanza file:

~~~~
    lsslp -m -s FRAME -z -i 192.168.200.205 > /tmp/frame.stanza
    lsslp -m -s CEC -z -i 192.168.200.205 > /tmp/cec.stanza     # only needed for low-end servers

~~~~


For high end servers environment, the "vpd" table needs to be updated to include the Frame MTMS information, and "ppc" table needs to be updated to include the CEC's parent which is the Frame node that is controlling it.

For the low end servers environment, the "vpd" table needs to be updated to only include the CEC MTMS information.

After collecting the Frame MTMS information for high end servers and CEC MTMS information for low end servers, and assign the proper nodenames in the stanza file, issue chdef to write them into xCAT DB.

~~~~
    cat /stanza/file/Framepath > chdef -z
~~~~


or

~~~~
    cat /stanza/file/CECpath > chdef -z
~~~~



The vpd table is looks like the following after writing the BPA/FSP MTMS information into xCAT DB.

For high end servers:

~~~~
    #node,serial,mtm,side,asset,comments,disable
    "frame1","99200G1","9A00-100",,,,
    ... ...
    "frame16","99410D1","9A00-100",,,,

~~~~

Note: The frames' MTMS information can be obtained from the BPA stanza file.


For low end servers:

~~~~
    #node,serial,mtm,side,asset,comments,disable
    "f1c1","100538P","8233-E8B",,,,
    ... ...
    "f16c16","100496P","8233-E8B",,,,
~~~~


For System P low end servers, the FSP MTMS information is found from the FSP stanza file that was created by lsslp command.

  * Setting up the PPC table

For high end CECs working with BPA(frame), the xCAT "ppc" table also needs to be updated to include the "cage" location information, the frame "parent" information for each CEC, and "nodetype" to indicate the hardware type for Frame and CECs. For low end CECs, the "ppc" table needs to be updated to include the "nodetype" attribute for CECs. The following command can help to write the "cage id" into ppc table:

High end servers:

~~~~
    chdef frame1 nodetype=frame
    .
    chdef frame16 nodetype=frame
    chdef f1c1 id=1 parent=frame1 nodetype=cec
    chdef f1c2 id=2 parent=frame1 nodetype=cec
    .
    chdef f16c2 id=2 parent=frame16 nodetype=cec
~~~~



Low end servers:

~~~~
    chdef f1c1 nodetype=cec
    .
    chdef f16c2 nodetype=cec
~~~~



The ppc table will looks like:




~~~~
    #node,hcp,id,pprofile,parent,supernode,comments,disable
    "f1c1",,"1",,"frame1a",,,
    "f1c2",,"2",,"frame1a",,,
          .
    "f16c1",,"1",,"frame16a",,,
    "f16c2",,"2",,"frame16a",,,
~~~~


##### **Discover HMCs/frame/CECs, and define them in xCAT DB**

The xCAT command lsslp is used to discovery the HMC/frame/CECs, to reference the hardware and network information from the DHCP server . It can then write the discovered information into xCAT DB . It can generate output in different format, including RAW, XML and stanza format. We recommend working with the -z flag to create stanza files, so the administrator can review the HW data prior to placing in the xCAT DB. The lsslp command does support the -w flag which can directly update the HW discovery data directly into the xCAT DB if the administrator does not need to make any changes.

See man page of lsslp for details.

  * **Use stanza file**

Note: If you work with xCAT Direct FSP Management, you still need to discover the HMC below and make the connections between HMC and the hardware. The HMC will always be used for Service Focal Point an for Srvice Repair and Verify procedures. You always need to discover the Frame and CECs, and make their connections to xCAT management node or service node.

Issue lsslp to locate the HMC information and write into a HMC stanza file. You will need to execute the -m (multicast) flag to reference later supported HMC V7R35x/V7R71 levels.

~~~~
    lsslp -m -s HMC -z -i 192.168.200.205 > /hmc/stanza/file
~~~~


Review the HMC stanza file and make modifications if necessary.

You will need to include the **username** and **password** attributes being used by the target HMC node. Make sure that the HMC host name and ip address is resolvable in the xCAT cluster name resolution (/etc/hosts, DNS).


Write the HMC stanza information into xCAT DB with xCAT command mkdef.

~~~~
    cat /hmc/stanza/file | mkdef -z
~~~~


Issue lsslp command to reference the Frame information and write into the Frame stanza file .

~~~~
    lsslp -s BPA -z -i 192.168.200.205 > /frame/stanza/file
~~~~


Review the frame stanza file and make modifications if necessary. You may want to update the frame server hostnames and/or BPA ip addresses to match your planned xCAT configuration.

Write the Frame stanza information into xCAT DB with xCAT command mkdef

~~~~
    cat /frame/stanza/file | mkdef -z
~~~~


Issue lsslp to get CEC information and write into the CEC stanza file.

~~~~
    lsslp -s FSP -z -i 192.168.200.205 > /CEC/stanza/file
~~~~


Review the CEC stanza file and make modifications if necessary. You may want to update the CEC hostnames and/or FSP ip addresses to match your planned xCAT configuration.

Write the CEC stanza information into xCAT DB with xCAT command mkdef.

~~~~
    cat /CEC/stanza/file | mkdef -z
~~~~


##### **Update xCAT database directly with lsslp**

You should only write directly into the xCAT DB if you are certain that the BPA/FSP server data specified by lsslp command is correct. This is used by experienced xCAT administrators, or if they are adding new System P servers into an existing xCAT cluster. The lsslp -w flag will update existing xCAT DB data, if the new HW discovery finds any BPA/FSP node contentions. The lsslp -n flag is used to locate only new found System P BPA/FSP servers during HW discovery. It can work with -z stanza, or the -w flag, but will only reference or add new BPA/FSP servers into the xCAT DB. The xCAT administrator always has the option to use the chdef command to add or modify attributes to the HMC/BPA/FSP node objects.

#### **Make the dynamic IP addresses permanent**

When the FSPs and BPAs are powered up for the first time, the MAC addresses for the FSPs and BPAs are not known by the DHCP server or the admin. We can only work a dynamic ip range in DHCP configuration file, so each FSP or BPA will get an dynamic ip address. The random ip address for each FSP or BPA could change when the DHCP client on FSP or BPA restarts. We recommend using a large enough dynamic ip range to avoid the DHCP ip addresses reuse. Be aware that using dynamic ip addresses will increase the maintenance effort, because you can not guarantee BPA/FSP server ip address. Using dynamic DHCP ip addresses opens the possibility that FSPs/BPAs ip addresses may be changed during the FSPs/BPAs server reboot. The FSPs/BPAs ip addresses changing will result in HMC and xCAT DFM connection being lost, where you have to do some administrator steps to recover. The dynamic DHCP ip addresses solution should be able to work well for most of the scenarios when the proper dynamic range is used on the Cluster service network.

There is a way provided by xCAT to make the dynamic IP address to be permanent to avoid the above issue. If the DHCP client MAC address and ip address mapping is specified in the DHCP AIX configuration file /etc/dhcpsd.cnf, RHEL lease file /var/lib/dhcpd/dhcpd.leases or SLES lease file /var/lib/dhcp/db/dhcp.leases, the BPA/FSP will consistently receive the same ip address from the DHCP server. The BPA/FSPs' IP address will not be changed during the BPA/FSPs' reboot.

Issue the makedhcp -a command to write the dynamic ip addresses, server host names, and MAC address of the BPA and FSP in the xCAT DB into the DHCP AIX configuration file/etc/dhcpsd.cnf, RHEL lease file /var/lib/dhcpd/dhcpd.leases, SLESlease file /var/lib/dhcp/db/dhcp.leases.. See more details in man page of makedhcp:

~~~~
    makedhcp -a
~~~~


You can also execute lsslp command with --makedhcp option to update the DHCP configuration with the dynamic ip address, server name and MAC address of BPA/FSP. This will use the information from xCAT DB and update the DHCP AIX configuration file /etc/db_file.cr, RHEL lease file /var/lib/dhcpd/dhcpd.leases, or SLES lease file /var/lib/dhcp/db/dhcp.leases also.

### **Define the hardware control point for the Frames/CECs.**

The following command will create an xCAT node definition for an HMC with a host name of hmc1. The groups, nodetype, mgt, username, and password attributes will be set.

~~~~
    mkdef -t node -o hmc1 groups=hmc,all nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc123
~~~~


to change and add new groups:

~~~~
    chdef -t node -o hmc1 groups=hmc,rack1,all
~~~~


to verify your data:

~~~~
    lsdef -l hmc1
~~~~



If xCAT Management Node is in the same service network with HMC, you will be able to discover the HMC and create an xCAT node definition for the HMC automatically.

~~~~
    lsslp -w -s HMC
~~~~


To check for the hmc name added to the nodelist:

~~~~
    tabdump nodelist
~~~~


The above xCAT command lsslp discovers and writes the HMCs into xCAT database, but we still need to set HMCs' username and password.

~~~~
    chdef -t node -o <hmcname from lsslp> username=hscroot password=abc123
~~~~

### **Make connections from Frames/CECs to HMC**

Change the hcp and mgt of Frames/CECs

~~~~
    chdef frame hcp=hmc1 mgt=hmc
~~~~

Have HMC establish connections to all of the frames:

~~~~
    mkhwconn frame -t
~~~~


Verify the connections were made successfully:

~~~~
    lshwconn frame
    frame14: connected
    frame14: connected
~~~~

If the BPA passwords are still the factory defaults, you must change them before running any other commands to them:

~~~~
    rspconfig frame general_passwd=general,<newpd>
    rspconfig frame admin_passwd=admin,<newpd>
    rspconfig frame HMC_passwd=,<newpd>
~~~~

### Define the Compute Nodes

The definition of a node is stored in several tables of the xCAT database.

You can use **rscan** command to discover the HCP to get the nodes that managed by this HCP. The discovered nodes can be stored into a stanza file. Then edit the stanza file to keep the nodes which you want to create and use the mkdef command to create the nodes definition.

### Discover the LPARs managed by HMC using rscan

Run the **rscan** command to gather the LPAR information. This command can be used to display the LPAR information in several formats and can also write the LPAR information directly to the xCAT database. In this example we will use the "-z" option to create a stanza file that contains the information gathered by **rscan** as well as some default values that could be used for the node definitions.

To write the stanza format output of **rscan** to a file called "node.stanza" run the following command. We are assuming, for our example ,that the hmc name returned from lsslp was hmc1.




~~~~
    rscan -z hmc1 > node.stanza
~~~~



This file can then be checked and modified as needed. For example you may need to add a different name for the node definition or add additional attributes and values.

**Note''**: The stanza file will contain stanzas for things other than the LPARs. This information must also be defined in the xCAT database. ''The stanza will repeat the same bpa'** information for multiple fsp(s). '**It is not necessary to modify the non-LPAR stanzas in any way.

The stanza file will look something like the following.

~~~~
    Server-9117-MMA-SN10F6F3D:
    objtype=node
    nodetype=fsp
    id=5
    model=9118-575
    serial=02013EB
    hcp=hmc01
    pprofile=
    parent=Server-9458-10099201WM_A
    groups=fsp,all
    mgt=hmc
    pnode1:
    objtype=node
    nodetype=lpar,osi
    id=9
    hcp=hmc1
    pprofile=lpar9
    parent=Server-9117-MMA-SN10F6F3D
    groups=lpar,all
    mgt=hmc
    cons=hmc
    pnode2:
    objtype=node
    nodetype=lpar,osi
    id=7
    hcp=hmc1
    pprofile=lpar6
    parent=Server-9117-MMA-SN10F6F3D
    groups=lpar,all
    mgt=hmc
    cons=hmc
~~~~



**Note''**: The ''**rscan''** command supports an option ( -w)  to automatically create node definitions in the xCAT database. To do this the LPAR name gathered by ''**rscan''** is used as the node ''name and the command sets several default values. If you use the -w option, make sure the LPAR name you defined will be the name you want used as your node name.

For a node which was defined correctly before, you can use the following commands to export the definition into the node.stanza, then edit the  node.stanza file and then update the database with changes. 

~~~~
    lsdef -z  nodename > node.stanza
    cat node.stanza | chdef -z 
~~~~

### Define xCAT node using the stanza file

The information gathered by the **rscan **command with the -z options creates a stanza format and  also can be used to create xCAT node definitions by running the following command:

~~~~
    
    cat node.stanza | mkdef -z
~~~~



Verify the data:

~~~~
    lsdef -t node -l all
~~~~





### Define xCAT nodes using xcatsetup

For P7/IH, Create Cluster Config File - The customer creates an hw/cluster configuration data file that contains the info enumerated below. The purpose of this file is for the customer to describe how all the discovered hw components should be logically arranged, ordered, and configured. This is because, during the discovery phase (step 5), we will 1st SLP discover all of the raw hw components (HMCs, BPAs, FSPs) on the service network. But this only gives us basic info about each component (MTMS, MAC, etc). We don't know the physical arrangement of the components, and we don't know the IP/hostnames the customer wants for each one. Therefore, the customer below provides that info. You can think of this as a cluster plan or blueprint - used to automate the configuration of the system and used to verify the cluster configuration. The cluster config file also allows the customer to provide some basic info about the other HPC products so that a basic set up of them can be accomplished throughout the cluster. The format of the file will be typical stanza file format. See the cluster config file mini-design, [Cluster_config_file](Cluster_config_file), for more details and the xcatsetup man page [[http://xcat.sourceforge.net/man8/xcatsetup.8.html...](http://xcat.sourceforge.net/man8/xcatsetup.8.html)] for the exact format and keywords in the files.

~~~~
    xcatsetup <cluster_config_file>
~~~~


### **HW Discovery Limitations**

The following are limitations of HW discovery working with xCAT 2.4 +

  * In a cluster that contains a large number of P5 IH machines, the **lsslp** command may not be able to discover all machines. You can reduce this scaling issue with lsslp by using the -t (retry times) and -c (timeout value) flags . For an example:

~~~~
    lsslp -s FSP -i 192.168.200.205 -t 5 -c 3000,3000,3000,3000,3000
~~~~


See lsslp man page for the details.

  * For HMC with V7R350 and V7R340 release, we had experienced some HMC discovery issues "lsslp -m" in different layer2/layer3 ethernet switch environments. In this case, the xCAT admin may have to manually create the HMC node objects using xCAT command **mkdef**.




  * If you run xCAT command lsslp with flag "-w" to auto discover BPA/FSP and create BPA/FSP nodes in xCAT DB, there are some types of Frame/CEC that cannot resolve the user-defined BPA/FSP system names to xCAT. This is because the node name created by lsslp is not consistent as the system name that is known by HMC. This limitation will not block most functions of xCAT. If system admins want to sync the user-defined system names used by the HMC to xCAT DB, run rscan with -u option to update the FSP/BPA node names in the xCAT database. The rscan -u command should only be executed after the running of the mkhwconn command.


