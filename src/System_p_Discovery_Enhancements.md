<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Discovery Overview](#discovery-overview)
  - [Define the Service LAN(s) in the Database and DHCP](#define-the-service-lans-in-the-database-and-dhcp)
  - [Power On and Configure the HMCs](#power-on-and-configure-the-hmcs)
  - [Define the Frame Name/MTMS Mapping](#define-the-frame-namemtms-mapping)
  - [Use xcatsetup to Create Initial Definitions in the Database](#use-xcatsetup-to-create-initial-definitions-in-the-database)
  - [Discover the BPAs, Modify Their Network Information, and Connect To Them](#discover-the-bpas-modify-their-network-information-and-connect-to-them)
  - [Power On the FSPs, Discover Them, Modify Network Information, and Connect](#power-on-the-fsps-discover-them-modify-network-information-and-connect)
- [Appendix A: Creating Initial Node Definitions Manually](#appendix-a-creating-initial-node-definitions-manually)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

_This documents the new system p discovery flow as a result of focussing on the Power 775, using permanent IP addresses, direct fsp/bpa mgmt, and redundant fsps/bpas. This is a draft of what should replace the current discovery section of the [XCAT_System_p_Hardware_Management] doc._

When setting up a new cluster, you can use the xCAT commands [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html) and [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to speed the proper definition of all of the cluster hardware in the xCAT database, by automatically discovering and defining them. This is optional - you can define all of the hardware in the database by hand, but that can be confusing and error prone. 

**Note:** this version of the document focusses on the following environment: 

  * the Power 775 
  * using permanent IP addresses (instead of random/dynamic addresses) 
  * direct fsp/bpa mgmt (DFM) 
  * supporting (optionally) and redundant fsps and bpas 

If you want to discover and define older system p hardware, see the [previous version of this document](XCAT_System_p_Hardware_Management). 

To use the DFM features of xCAT you need to download from IBM's Fix Central site and install: xCAT-dfm-*.rpm and ISNM-hdwr_svr-*.rpm (linux) or isnm.hdwr_svr (AIX). 

This discovery section should be performed in the following place within the high level cluster setup flow: 

  1. Install the OS on the management node 
  2. Install and configure the xCAT prereqs and xCAT software on the management node 
  3. **Discover and define the cluster hardware components**
  4. Continue with the rest of the management node configuration 
  5. Create the images that should be installed or booted on the nodes 
  6. Run nodeset or nimnodeset and rpower/rnetboot to boot up the nodes. 

### Discovery Overview

A **summary** of the steps you should follow to discover the hardware and get it defined properly in the database are: 

  * Define the service LAN(s) in the database 
  * Run "makedhcp -n" to configure dhpcd and define the service network stanza, and then start dhcpd 
  * Power on and configure the HMCs 
  * Manually power on the frames 
  * Run "lsslp -s BPA -m --vpdtable" to generate a stanza file of frame definitions 
  * Edit the stanza file to give the proper node name to each frame object, identifying the frames by MTMS. 
  * Create a cluster config file that will direct xcatsetup to create skeleton definitions for the hw components in the db. 
  * Run "xcatsetup &lt;config-file-name&gt;" to create the skeleton objects 
  * Run "lsslp -s BPA -m -w" to discover the BPAs, match them with the corresponding frameand BPA objects in the db (using the mtms), and write additional attributes for the frames and BPAs in the db. 
  * Run "makedhcp bpa" to write the permanent ip/mac pairs for all the bpas into the dhcp config 
  * Add the current passwords for the frame objects in the ppcdirect table 
  * Run "rspconfig frame --resetnet" to have all the bpas acquire their permanent ip address 
  * Establish connections to all of the frames: mkhwconn -t frame 
  * If the frame passwords are still the factory defaults, you must change them now: rspconfig frame '*_passwd=&lt;oldpwd&gt;,&lt;newpd&gt;' 
  * Verify the hw ctrl setup is correct for the frames: 
  * Get the frames out of rack standby and power up the FSPs: rpower frame exit_rackstandby 
  * Run "lsslp -s FSP -m -w" to discover the FSPs, match them with the corresponding CEC and FSP object in the db (using the cage # and frame mtms), and write additional attributes for the CECs and FSPs in the db. 
  * Run "makedhcp fsp" to write the permanent ip/mac pairs for all the bpas and fsps into the dhcp config 
  * Add the current passwords for the cec objects in the ppcdirect table 
  * Run "rspconfig cec --resetnet" to have all the fsps acquire their permanent ip address 
  * Establish connections to all of the cecs: mkhwconn -t cec 
  * If the cec passwords are still the factory defaults, you must change them now: rspconfig cec '*_passwd=&lt;oldpwd&gt;,&lt;newpd&gt;' 
  * Associate the hmcs with the appropriate frames: mkhwconn -s -t -p hmc (how do you do this for multiple hmcs??) 
  * Verify the hw ctrl setup is correct for the cecs: 

Easy, right? Each step is explained in more detail below. 

In the examples given below, it is assumed that you have redundant service LANs and that the xCAT management node has 2 NICs, each connected to one of the service LANs. The subnet of the first example service LAN is 10.230.0.0/255.255.0.0 and the subnet of the 2nd example service LAN is 10.231.0.0/255.255.0.0 . 

### Define the Service LAN(s) in the Database and DHCP

xCAT uses [SLP](http://en.wikipedia.org/wiki/Service_Location_Protocol) to discover the hardware components on the service networks. Before doing this, you must configure the management node to give dynamic DHCP IP addresses to the hardware components so that they can respond to SLP broadcasts. 

If you haven't already, configure with static IP addresses the management node's NICs that are connected to the service LAN and cluster management LAN. 

If you already had the management node's service LAN NICs configured when you installed xcat, it automatically ran "makenetworks" and created the necessary entries in the networks table. If not, run: 
    
    makenetworks
    

Now set the networks.dynamicrange attribute for each service LAN. For example: 
    
    chdef -t network 10_230_0_0-255_255_0_0 dynamicrange=10.230.200.1-10.230.200.200
    chdef -t network 10_231_0_0-255_255_0_0 dynamicrange=10.231.200.1-10.231.200.200

Set [site](http://xcat.sourceforge.net/man5/site.5.html).dhcpinterfaces to the list of NICs (on the management node and service nodes) that DHCP should listen on. For the management node, this is normally the NICs that are connected to the service LAN and the NICs connected to the cluster management LAN. For the service node it should only be the NIC connected to the compute node LAN: 
    
     chdef -t site clustersite dhcpinterfaces='mgmtnode|eth1,eth2,eth3,eth4;service|hf0'
    

On AIX, you have to stop the bootp daemon before starting dhcp, because they listen on the same port number: 
    
    # Stop bootp from rebooting by commenting out the bootps line in /etc/inetd.conf file:
    #bootps dgram udp wait root /usr/sbin/bootpd bootpd /etc/bootptab
    
    refresh -s inetd                     # stop and restart the inetd subsystem
    kill `ps -ef | grep bootp | grep -v grep | awk '{print $2}' `    # stop the bootp daemon
    start /usr/sbin/dhcpsd "$src_running"             # start up the DHCP Server
    stopsrc -g tcpip                       # restart the tcpip group
    startsrc -g tcpip

Have xCAT configure the service network stanza for dhcpd and then start the daemon: 
    
    makedhcp -n
    service dhcpd restart   # linux
    startsrc -s dhcpd       # AIX
    

Look at the DHCP configuration file on the xCAT management node to ensure that it contains only the networks you want: 
    
    cat /etc/dhcpd.conf   # Linux
    cat /etc/dhcpsd.cnf   # AIX
    

### Power On and Configure the HMCs

This section is TBD, but must cover: 

  * Manually collect MACs of HMCs and create database definitions manually (including the ipmi table) 
  * makedhcp hmc 
  * Enable: SLP, SSH, SOL (if not enabled from the factory) 
  * Disable DHCP 
  * Configure the IMM 

### Define the Frame Name/MTMS Mapping

SLP gives xCAT a list of hardware components on the network, without telling it the physical location of each. This means that xCAT does not have a way to give each component a sensible name without getting a little bit of information from you: the mapping between the name you want each frame to have and its MTMS (machine type, model, and serial #). 

To provide this information, first manually power on the frames. (If the frames are being powered on (EPO'ed), the BPAs will come up in rack standy mode. At this point there will not be any power to the CEC FSPs so they will not yet be able to be discovered. So we must first discover the frames, get them defined in the database, and make connections to them, so we can get them out of rack standby mode. This process will be accomplished in the next several sections.) 

Have xCAT generate a stanza file of frame definitions (with MTMS) so you can easily give each one a name: 
    
    lsslp -s BPA -m -i 10.230.0.0,10.231.0.0 --vpdtable &gt; vpd-frame.stanza
    

    

  * Note: the implementation of this lsslp option should be changed to produce frame objects, instead of bpa objects 

Edit the stanza file to give the desired node name to each frame object, identifying the frames by MTMS. (The node name is the identifier before the colon. Set the [xcatstanzafile man page](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html) for details.) The node names should indicate order (e.g. frame01, frame02, etc.) because xCAT will use that to understand the physical order of the hardware. 

### Use xcatsetup to Create Initial Definitions in the Database

The [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html) command creates initial node definitions in the xCAT database, based on naming conventions and IP address ranges that you provide via a cluster configuration file. In a later step, xCAT will combine this information with the SLP information discovered on the service network to create a complete picture of your cluster hardware components. 

Create a cluster config file with information about the hardware components that should be defined. Note that you are not only specifying the naming pattern for the HMCs, frames, and CECS, but also the permanent IP addresses you want the BPAs and FSPs to have. (When the BPAs and FSPs initially power on, they will get dynamic IP addresses from DHCP. Once you are done with this whole discovery chapter, DHCP will always give them the IP addresses you define in the cluster config file. We call these the "permanent" IP addresses.) For a detailed description of the cluster config file, see the [xcatsetup man page](http://xcat.sourceforge.net/man8/xcatsetup.8.html). Here's a sample config file: 
    
    # A small cluster config file for a single 2 frame bldg block.
    # Just the hmcs, frames, bpas, cecs, and fsps are created.
    xcat-site:
     use-direct-fsp-control = 1
    
    xcat-hmcs:
     hostname-range = hmc[1-2]
    
    xcat-frames:
     hostname-range = frame[1-2]
     num-frames-per-hmc = 1
     vpd-file = vpd-frame.stanza
     # This assumes you have 2 service LANs:  a primary service LAN 10.230.0.0/255.255.0.0 that all of the port 0's
     # are connected to, and a backup service LAN 10.231.0.0/255.255.0.0 that all of the port 1's are connected to.
     bpa-a-0-starting-ip = 10.230.1.1
     bpa-b-0-starting-ip = 10.230.2.1
     bpa-a-1-starting-ip = 10.231.1.1
     bpa-b-1-starting-ip = 10.231.2.1
    
    xcat-cecs:
     hostname-range = cec[01-24]
     num-cecs-per-frame = 12
     fsp-a-0-starting-ip = 10.230.3.1
     fsp-b-0-starting-ip = 10.230.4.1
     fsp-a-1-starting-ip = 10.231.3.1
     fsp-b-1-starting-ip = 10.231.4.1
    

    

  * Note: the exact names of the bpa and fsp starting ip attributes haven't been determined yet. 

Run xcatsetup to create the initial node definitions: 
    
    xcatsetup &lt;config-file-name&gt;

This writes the following essential attributes to the database (more attributes are written, but these are the attributes that are necessary for running lsslp later on): 

  * frames: nodelist.node, nodelist.groups, ppc.nodetype, vpd.serial, vpd.mtm 
  * bpas: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent 
  * cecs: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent, ppc.cageid 
  * fsps: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent 
  * creates groups: hmc, frame, bpa, cec, fsp 

Note: unlike most nodes in the xCAT database, the BPAs and FSPs will use their IP address (the permanent one) as their node name. 

Note: as an alternative to using xcatsetup and the cluster config file, you can create the database definitions manually. This is documented in Appendix A. 

### Discover the BPAs, Modify Their Network Information, and Connect To Them

Now we are ready to discover the BPAs on the network, match them with the corresponding frames and BPAs in the database (using the mtms), and write additional attributes in the database: 
    
    lsslp -s BPA -m -i 10.230.0.0,10.231.0.0 -w
    

This will put the MAC for each BPA into the mac.mac attribute and temporarily store the dynamic IP address of each BPA object in the hosts.otherinterfaces attribute. You can confirm that by running: 
    
    lsdef -i mac,otherinterfaces bpa
    

Configure DHCP with the permanent ip/mac pairs so that it will always give the BPAs their permanent IP address from now on: 
    
    makedhcp bpa
    

To enable xCAT to connect to the BPAs, you must add the current passwords for the frame objects in the ppcdirect table. If the password for all of the frames is the same, you can set the username/password in the ppcdirect table using group entries: 
    
    chdef -t group frame passwd.HMC=xxx
    chdef -t group frame passwd.admin=yyy
    chdef -t group frame passwd.general=zzz
    

Tell all of the BPAs to re-acquire their IP address from DHCP, so that they will receive the new permanent IP address that DHCP has been configured with: 
    
    rspconfig frame --resetnet
    

  * Note: the --resetnet flag will eventually be moved to the rspconfig command. 

Have xCAT's DFM daemon (called hw server) establish connections to all of the frames: 
    
    mkhwconn -t frame
    

If the BPA passwords are still the factory defaults, you must change them before running any other commands to them: 
    
    rspconfig frame '*_passwd=&lt;oldpwd&gt;,&lt;newpd&gt;'
    

Verify the hardware control setup is correct for the frames: 
    
    # lshwconn frame
    (output to be added here)
    
    # rpower frame state
    (output to be added here)

### Power On the FSPs, Discover Them, Modify Network Information, and Connect

Taking the frames out of rack standby will cause the FSPs to be powered on and they will get a dynamic DHCP IP address so that they can communicate on the network: 
    
    rpower frame exit_rackstandby
    

Run lsslp to discover the CECs/FSPs, and match the discovered hardware with the corresponding objects in the database, and write additional attributes in the database: 
    
    lsslp -s FSP -m -i 10.230.0.0,10.231.0.0 -w
    

For each FSP discovered on the network, the lsslp command uses the cage # and its parent (frame) MTMS to match the correct CEC entry in the database. The attributes that will be written to the database are: 

  * the mtms of each CEC object 
  * the MAC for each FSP will be stored in the mac.mac attribute and the dynamic IP address of each FSP object will be temporarily stored in the hosts.otherinterfaces attribute. 
  * Should we also discover the hmcs in this step?? We had to manually collect the MACs and define the hmcs very early on in the process, so the only thing lsslp would add to the definition at this point is the mtms. Not sure it is worth it. 

You can confirm these settings by running: 
    
    lsdef -i mtm,serial cec
    lsdef -i mac,otherinterfaces fsp
    

Configure DHCP with the permanent ip/mac pairs so that it will always give the FSPs their permanent IP address from now on: 
    
    makedhcp fsp
    

To enable xCAT to connect to the FSPs, you must add the current passwords for the CEC objects in the ppcdirect table. If the password for all of the CECs is the same, you can set the username/password in the ppcdirect table using group entries: 
    
    chdef -t group cec passwd.HMC=xxx
    chdef -t group cec passwd.admin=yyy
    chdef -t group cec passwd.general=zzz
    

Tell all of the FSPs to re-acquire their IP address from DHCP, so that they will receive the new permanent IP address that DHCP has been configured with: 
    
    rspconfig cec --resetnet
    

  * Note: the --resetnet flag will eventually be moved to the rspconfig command. 

Have xCAT's DFM daemon (called hw server) establish connections to all of the CECs: 
    
    mkhwconn -t cec
    

If the FSP passwords are still the factory defaults, you must change them before running any other commands to them: 
    
    rspconfig cec '*_passwd=&lt;oldpwd&gt;,&lt;newpd&gt;'
    

Associate the HMCs with the appropriate frames: 
    
    mkhwconn -s -t -p hmc  (how do you do this for multiple hmcs??)
    

Verify the hardware control setup is correct for the CECs: 
    
    # lshwconn cec
    (output to be added here)
    
    # rpower cec state
    (output to be added here)

Verify that the CECs are healthy: 
    
    rvitals cec lcds
    rinv cec deconfig

## Appendix A: Creating Initial Node Definitions Manually

If the xcatsetup command is not appropriate for your cluster because your naming patterns have too many exceptions, you can create node definitions manually to prepare for running lsslp. 

After editing the vpd-frame.stanza file that was created using the --vpdtable option of lsslp, define the frame objects: 
    
    cat vpd-frame.stanza | mkdef -z

(the rest of this section is still under construction...) 

  * bpas: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent 
  * cecs: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent, ppc.cageid 
  * fsps: nodelist.node, nodelist.groups, ppc.nodetype, ppc.parent 
  * creates groups: hmc, frame, bpa, cec, fsp 
