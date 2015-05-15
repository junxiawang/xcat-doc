<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Optional Discovery Method 1 - Mapping the CMMs to the switch port information (Development)](#optional-discovery-method-1---mapping-the-cmms-to-the-switch-port-information-development)
- [Optional Discovery Method 2 - Manually Discovering the CMMs Instead of Using the Switch Ports](#optional-discovery-method-2---manually-discovering-the-cmms-instead-of-using-the-switch-ports)
- [CMM Configuration](#cmm-configuration)
- [CMM Security Password Expiration](#cmm-security-password-expiration)
- [Redundant CMM Support](#redundant-cmm-support)
- [Update the CMM firmware (optional)](#update-the-cmm-firmware-optional)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


### Overview

In this section you will perform the CMM discovery and configuration tasks for the CMMs. 

During the CMM discovery process all CMMs are discovered using Service Location Protocol(SLP) and the xCAT lsslp command. There are two methods which will allow mapping the SLP discovered CMMs to the CMMs predefined in the xCAT DB. You can either use method 1 which map the SLP data to the switch SNMP data together to update the xCAT DB or you can use method 2 to capture the SLP information to a file and edit it manually and then update the xCAT DB. 

Two factors will determine which method you use. If this is a large configuration with many chassis and you are able to enable SNMP on the switch that the CMMs are connected to then method 1 would be preferred. If you are only defining a few chassis then method 2 might be an easier choice. 

Note: xCAT Flex discovery now does not support the CMM with both primary and standby port. 



### Optional Discovery Method 1 - Mapping the CMMs to the switch port information (Development)

This supported will be available in xCAT 2.8.2 and later. This method requires SNMP access to the Ethernet switch where the CMMs are connected. If you can't configure SNMP on your switches, then use the section after:

[CMM_Discovery_and_Configuration/#optional-discovery-method-2-manually-discovering-the-cmms-instead-of-using-the-switch-ports](CMM_Discovery_and_Configuration/#optional-discovery-method-2-manually-discovering-the-cmms-instead-of-using-the-switch-ports)  to discover and define the CMMs to xCAT. 



In large clusters the most automated method for discovering is to map the SLP CMM information to the Ethernet switch SNMP data from which each chassis CMM is connected. 

To use this method the xCAT switch and switches tables must be configured. The xCAT switch table will need to be updated with the switch port that each CMM is connected. The xCAT switches table must contain the SNMP access information. 

Add the CMM switch/port information to the switch table. 

~~~~    
 tabdump switch
 node,switch,port,vlan,interface,comments,disable
 "cmm01","switch","0/1",,,,
 "cmm02","switch","0/2",,,,
~~~~      

where: node is the cmm node object name switch is the hostname of the switch port is the switch port id. Note that xCAT does not need the complete port name. Preceding non numeric characters are ignored. 

If you configured your switches to use SNMP V3, then you need to define several attributes in the switches table. Assuming all of your switches use the same values, you can set these attributes at the group level: 

~~~~      
    tabch switch=switch switches.snmpversion=3 switches.username=xcatadmin \
         switches.password=passw0rd switches.auth=SHA
         
     
    
   tabdump switches
   switch,snmpversion,username,password,privacy,auth,linkports,sshusername,...
    "switch","3","xcatadmin","passw0rd",,"SHA",,,,,,
~~~~      

Note: It might also be necessary to allow authentication at the VLAN level 
  
~~~~    
    snmp-server group xcatadmin v3 auth context vlan-230
~~~~      

Discover and update the xCAT CMM node definitions with the MAC, Model Type, and Serial Number. 
 
~~~~     
    lsslp -s CMM -w
~~~~      

Verify that the CMMs have been updated with the mac, mtm, and serial information. 
 
~~~~     
    lsdef cmm01
    cmm01:
           objtype=node
           mpa=cmm01
           nodetype=mp
           mtm=789392X
           serial=100037A
           side=2
           groups=cmm,all
           mgt=blade
           mac=5c:f3:fc:25:da:99
           hidden=0
           otherinterfaces=10.0.0.235
           hwtype=cmm
~~~~      

### Optional Discovery Method 2 - Manually Discovering the CMMs Instead of Using the Switch Ports

If you can't enable SNMP on your switches, use this more manual approach to discover your hardware. If you have already discovered your hardware using spldiscover of lsslp --flexdiscover, skip this whole section. 

Assuming your CMMs have at least received a dynamic address from the DHCP server, you can run [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to discover them and create a stanza file that contains their attributes that can be used to update the existing CMM nodes in the xCAT database. The problem is that without the switch port information, lsslp has no way to correlate the responses from SLP to the correct nodes in the database, so you must do that manually. Run: 

~~~~      
    lsslp -m -z -s CMM > cmm.stanza
~~~~      

and it will create a stanza file with entries for each CMM that look like this: 

~~~~      
    Server--SNY014BG27A01K:
           objtype=node
           mpa=Server--SNY014BG27A01K
           nodetype=mp
           mtm=789392X
           serial=100CF0A
           side=1
           groups=cmm,all
           mgt=blade
           mac=3440b5df0abe
           hidden=0
           otherinterfaces=10.0.0.235
           hwtype=cmm
~~~~      

Note: the otherinterfaces attribute is the dynamic IP address assigned to the CMM. 

The first thing we want to do is strip out the non-essential attributes, because we have already defined them at a group level: 
  
~~~~    
    grep -v -E '(mac=|nodetype=|groups=|mgt=|hidden=|hwtype=)' cmm.stanza > cmm2.stanza
~~~~      

Now edit cmm2.stanza and change each "&lt;node&gt;:" line and mpa to have the correct node name. Then put these attributes into the database: 

~~~~      
    cat cmm2.stanza | chdef -z
~~~~      

### CMM Configuration

For a new CMM the user USERID password is set as expired and you must use the xCAT rspconfig command to change the password to a new password before any other commands can access the CMM. 

~~~~    
rspconfig cmm01 USERID=<new password>
~~~~
    

Note: If password for CMM has been changed after discovery, you must make sure the correct password for CMM user USERID is updated into mpa table: chtab mpa=&lt;cmm&gt; mpa.username=USERID mpa.password=&lt;password&gt;; . You can then run the rspconfig command listed above. 

  
Once a new password is use [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) to set the IP address of each CMM to the permanent (static) address specified in the ip attribute: 
    
~~~~  
    rspconfig cmm01 initnetwork=*
~~~~      
    
Note: The rspconfig command with the initnetwork option will set the CMM IP address
    to a the static IP address specified in the cmm01 node object ip attribute value. 
The changing of the CMM network definition and will reset  the CMM to boot
 with the new value which will cause the CMM to temporarily loose its ethernet connection.  
    

Checking the CMM definition will show that the DHCP value stored in otherinterfaces
 has been removed since it is no longer being used. 
You should use ping to test the IP address defined in the CMM node ip attribute to know when the CMM comes up before issuing other commands. 

Once the CMM is back up and operationals use rspconfig to set the CMM to allow SSH and SNMP. 
 
~~~~     
    rspconfig cmm01 sshcfg=enable 
    rspconfig cmm01 snmpcfg=enable
~~~~      

Note: If you receive error cmmxx: Failed to login to cmmxx, you can run "ssh USERID@cmm01" and set the ssh password for the CAT MN. If this does not work, we may need to check the passwords being referenced on the target CMM and in the xCAT database. 

Note: If the cmm was previously defined and the rspconfig sshcfg=enable fails, you may need to clean up the old ssh entry in the know_hosts table on the xCAT MN. You can run "makeknownhosts cmm01 -r" to clean this ssh entry. 

Check the values to make sure they were enabled properly. 
 
~~~~     
    rspconfig cmm01 sshcfg snmpcfg
    cmm01: SSH: enabled
    cmm01: SNMP: enabled
~~~~      

Test the SSH connection to the CMM with the rscan CMM info command. 
 
~~~~     
    ssh USERID@cmm01 info
    system> info
    UUID: 5CFB E60F 2EFB 4143 9154 B677 2A37 2143 
    Manufacturer: IBM (BG)
    Manufacturer ID: 20301
    Product ID: 336
    Mach type/model: 789392X
    Mach serial number: 100037A
    Manuf date: 2411
    Hardware rev: 52.48
    Part no.: 88Y6660
    FRU no.: 81Y2893
    FRU serial no.: Y130BG16D022
    CLEI: Not Available
    CMM bays: 2
    Blade bays: 14
    I/O Module bays: 4
    Power Module bays: 6
    Blower bays: 10
    Rear LED Card bays: 1
    U Height of Chassis 10
    Product Name: IBM Chassis Midplane
~~~~      

Test the SNMP connection to the CMM using rscan. 
 
~~~~     
    rscan cmm01
    type    name             id      type-model  serial-number  mpa    address
    cmm     SN#Y014BG27A01K  0       789392X     100CF0A        cmm01  cmm01
    blade   node01           1       789523X     1082EAB        cmm01  10.0.0.232
    blade   node02           2       789523X     1082EBB        cmm01  10.0.0.231
~~~~      

### CMM Security Password Expiration

The default security setting for the CMM is secure. This setting will require that the CMM user USERID password be changed within 90 days by default. You can change the password expiration date with the CMM accseccfg command. The following are examples of changing the expiration date. 

List the security settings. The -pe is the password expiration: 
  
~~~~    
   > ssh USERID@cmm01 accseccfg -T mm[1]
    system&gt; accseccfg -T mm[1]
    Custom settings:
    -alt 300
    -am local
    -cp on
    -ct 0
    -dc 2
    -de on
    -ia 120
    -ici off
    -id 180
    -lf 20
    -lp 2
    -mls 0
    -pc on
    -pe 90
    -pi 0
    -rc 5
    -wt user
~~~~      

You can change the password expiration date using the CMM flex command accseccfg . 

~~~~      
     ssh USERID@cmm01 accseccfg -pe 300 -T mm[1] (set expiration days to 300)
     ssh USERID@cmm01 accseccfg -pe 0 -T mm[1]   (set expiration date to not expire)
~~~~      

More details on the CMM accseccfg command can be found at: http://publib.boulder.ibm.com/infocenter/flexsys/information/index.jsp?topic=%2Fcom.ibm.acc.cmm.doc%2Fcli_command_accseccfg.html 

### Redundant CMM Support

The xCAT support for CMM redundancy is to use the second CMM as the default standby CMM that has its own ethernet connection into the HW VLAN. For CMM discovery, it is recommended that the Flex cluster admin only plug in and connect the Bay 1 CMM as the primary CMM, where the admin does discovery and configuration of the Flex cluster with one primary CMM. When the primary CMM is fully working as a "static" IP with proper firmware levels, the admin can plug in the second Bay 2 CMM into the Flex chassis, and it will automatically come online as a standby CMM with same CMM firmware as the primary CMM. You can see more information about CMM recovery with Redundant CMM in a different section below. 

### Update the CMM firmware (optional)

This section specifies how to update the CMM firmware. You can run the xCAT "rinv cmm firm" command to list the cmm firmware level. 

~~~~      
     rinv  cmm firm
~~~~      

The CMM firmware can be updated by loading the new **cmefs.uxp** firmware file using the CMM **update** command working with the http or tftp interface. Since the AIX xCAT MN does not usually support http, we have provided CMM update instructions working with tftp. The administrator needs to download firmware from IBM Fix Central. The compressed tar file will need to be uncompressed and unzipped to extract the firmware update files. You need to place the cmefs.uxp file in the /tftpboot directory on the xCAT MN for CMM update to work properly. 

Once the firmware is unzipped and the cmefs.uxp is placed in the /tftpboot directory on the xCAT MN you can use the CMM **update** command to update the firmware on one chassis at a time or on all chassis managed by xCAT MN. More details on the CMM update command can be found at: http://publib.boulder.ibm.com/infocenter/flexsys/information/index.jsp?topic=%2Fcom.ibm.acc.cmm.doc%2Fcli_command_update.html 

The format of the update command is: flash (-u) the CMM firmware file and reboot (-r) afterwards 
  
~~~~    
    update -T system:mm[1] -r -u tftp://<server>/<update file>
~~~~      

flash (-u), show progress (-v), and reboot (-r) afterwards 
   
~~~~   
    update -T system:mm[1] -v -r -u tftp://<server>/<update file>
~~~~      

Note: Make sure the CMM firmware file cmefs.uxp is placed in /tftpboot directory on xCAT MN. The tftp interface from the CMM will reference the /tftpboot as the default location. 

To update firmware and restart a single CMM cmm01 from xCAT MN 70.0.0.1 use: 
 
~~~~     
    ssh USERID@cmm01 update -T system:mm[1] -v  -r -u tftp://70.0.0.1/cmefs.uxp
~~~~      

If unprompted password is setup on all CMMs then you can use xCAT psh to update all CMMs in the cluster at once. 
 
~~~~     
    psh -l USERID cmm update -T system:mm[1] -v -u tftp://70.0.0.1/cmefs.uxp
~~~~      

If you are experiencing a "Unsupported security level" message after the CMM firmware was updated then you should run the following command to overcome this issue. 

~~~~      
    rspconfig cmm sshcfg=enable snmpcfg=enable 
~~~~      

You can run the xCAT "rinv cmm firm" command to list the new cmm firmware. 

~~~~      
     rinv  cmm firm
~~~~      
