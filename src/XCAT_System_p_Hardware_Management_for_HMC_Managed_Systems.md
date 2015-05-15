<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Terminology](#terminology)
- [System P setup with HMC Discovery](#system-p-setup-with-hmc-discovery)
  - [** System P Hardware and HMC Discovery setup**](#-system-p-hardware-and-hmc-discovery-setup)
    - [**Setting up the HMC network for use by xCAT**](#setting-up-the-hmc-network-for-use-by-xcat)
  - [Setup HMC objects on xCAT MN](#setup-hmc-objects-on-xcat-mn)
    - [**Enable ssh interface to the HMC**](#enable-ssh-interface-to-the-hmc)
  - [Discover the LPARs managed by HMC using rscan](#discover-the-lpars-managed-by-hmc-using-rscan)
- [Firmware upgrade](#firmware-upgrade)
  - [Prepare for Firmware upgrade](#prepare-for-firmware-upgrade)
    - [Enable the HMC to allow remote ssh connections(Only for P5/P6 with HMC).](#enable-the-hmc-to-allow-remote-ssh-connectionsonly-for-p5p6-with-hmc)
    - [Define the necessary attributes](#define-the-necessary-attributes)
    - [Define the HMC as a node(Only for P5/P6 with HMC)](#define-the-hmc-as-a-nodeonly-for-p5p6-with-hmc)
    - [Setup SSH connection to HMC(Only for P5/P6 with HMC)](#setup-ssh-connection-to-hmconly-for-p5p6-with-hmc)
    - [Get the Microcode update package and associated XML file](#get-the-microcode-update-package-and-associated-xml-file)
  - [**Perform Firmware upgrade for CEC on P5/P6/P7**](#perform-firmware-upgrade-for-cec-on-p5p6p7)
    - [**Define the CEC as a node on the management node**](#define-the-cec-as-a-node-on-the-management-node)
    - [Check firmware level](#check-firmware-level)
    - [**Update the firmware**](#update-the-firmware)
  - [**Perform Firmware upgrades for BPA on P5/P6/P7**](#perform-firmware-upgrades-for-bpa-on-p5p6p7)
    - [**Define the BPA as a node on the Management Node**](#define-the-bpa-as-a-node-on-the-management-node)
    - [Use rinv to check the firmware level](#use-rinv-to-check-the-firmware-level)
    - [Update the firmware](#update-the-firmware)
  - [**Commit currently activated LIC update(copy T to P) for a CEC/BPA on p5/p6/p7**](#commit-currently-activated-lic-updatecopy-t-to-p-for-a-cecbpa-on-p5p6p7)
    - [**Check firmware level**](#check-firmware-level)
    - [**Commit the firmware LIC**](#commit-the-firmware-lic)
- [Energy Management](#energy-management)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

This document provides information about xCAT Management Node (MN) implementation for setting up hardware connections between the xCAT MN, HMC and attached IBM System P hardware. It will provide the xCAT commands and instructions used to create node objects, setup the HMC connections, and execute administration tasks to support for System P CECs and LPARs. 

This document applies mainly for HMC controlled system p servers. 
For information on managing the system Power 775 servers, see [XCAT_Power_775_Hardware_Management]. 
For information with System P IBM Flex systems, see [XCAT_system_p_support_for_IBM_Flex] 

The IBM Hardware Management Console(HMC) provides a standard user interface for configuring and operating partitioned and SMP systems. The HMC supports features that enable a system administrator to manage configuration and operation of partitions as well as monitor system events in a System P environment. 

### Terminology

The following terms will be used in this document: 

**Frame (frame) node**: A node with nodetype set to _frame_ represents a high end System P server 24 inch frame. For example, here is a frame node: 
 
~~~~   
    Server-9458-100-SNBPCF007:
     objtype=node
     groups=frame,all
     hcp=hmc1
     id=1
     mgt=hmc
     mtm=9458-100
     nodetype=ppc
     hwtype=frame
     serial=BPCF007
~~~~    

In the above example, the attributes: 

  * nodetype - this is system p hw 
  * hwtype - this is a frame 
  * id - the frame id number. 
  * mgt - the current type of the hardware control point 
  * hcp - the HMC that controls this frame 
  * mtm - the type model 
  * serial - serial number of the server 

  
For lower end System P servers, there is no BPA device contained in a 19 inch frame, so there is no xCAT node object represented for a 19 inch System P frame. 

**CEC (cec) node**: A server node with attribute hwtype set to _cec_ which represents a System P CEC. Here is an example of CEC node that exists in a high end System P server: 
 
~~~~   
    Server-9125-F2C-SN02D8B25:
     objtype=node
     groups=cec,all
     hcp=hmc1
     id=6
     mgt=hmc
     mtm=9125-F2C
     nodetype=ppc
     hwtype=cec
     parent=Server-9458-100-SNBPCF007
     serial=02D8B25
~~~~    

In above example, the attributes: 

  * nodetype - this is system p hardware 
  * hwtype - this is a CEC 
  * id - the cage number of this CEC in a 24 inch frame (This will be set to blank for low end System P machine) 
  * parent - the frame node that this CEC is part of 
  * mgt - the current type of hardware control point 
  * hcp - the HMC that controls this CEC 
  * mtm - the type model 
  * serial - serial number of the server 

## System P setup with HMC Discovery

This section describes the xCAT implementation where the HMC does the hardware discovery to the System P servers. It has been found that some xCAT admins prefer to setup DHCP server on the HMC for the HW VLAN System P connections. This means that the System P admin will execute hardware discovery to the System P Frames and CECs using the HMC GUI. They will also manually create the LPAR configurations and assign the proper resources using the HMC. You can reference the HMC documentation here: http://www.redbooks.ibm.com/redbooks/pdfs/sg247491.pdf 

### ** System P Hardware and HMC Discovery setup**

The xCAT hardware management with HMC as the hardware control point (hcp) is supported for System P hardware (P5,P6,P7,P8) with minimal HMC V6.1.3 driver working with xCAT 2.4 or later releases. The admin uses the HMC GUI for the hardware discovery, attaches the Frame and CECs, and creates the LPARs using the tools from the HMC GUI. 

The HMCs should be configured with static ip addresses working in a VLAN network that can communicate to the xCAT MN. For this HMC support environment, the DHCP server will be configured by the HMC where there is second private service VLAN that is connected to the System P BPAs (Frame) and the FSPs (CECs). 

#### **Setting up the HMC network for use by xCAT**

The following are minimal steps required to Setup the HMC network for Static IP,and enable SSH ports working with HMC GUI. Reference the HMC website and documentation for more details. 

  * Open the HMC GUI, Select **HMC Management**, then **Change Network Settings**. 
  * Select **Customize Network Configuration**, and then** LAN Adapters **. 
  * Select **Ethernet interface **configured on the VLAN being used to connect to xCAT MN. 
  * Click on the **Details **button. 
  * Select **Basic Settings**, Click on **Open**, and **Specify IP address.**
  * Fill in **IP address**, **Netmask** for HMC static IP to connect to xCAT MN. 
  * Make sure that DHCP Server box is not selected and is blank. 
  * Select on **Firewall Settings**, Click on **Secure Shell** in the upper window. 
  * (You may also want to enable other HMC Firewall settings) 
  * Click on the **Allow incoming **button for each required setting, and then select OK at bottom. 
  * Select **Ethernet interface ** configured on the private System P BPA/FSP VLAN . 
  * Click on the **Details **button. 
  * Select **Basic Settings**, Click on **Open**, and **Specify IP address.**
  * Fill in **IP address**, **Netmask** for HMC IP used with BPA/FSP VLAN or let DHCP set it. 
  * Make sure that DHCP Server box is selected and a proper subnet is provided, and then select OK at bottom. 
  * Make sure you Select OK at the bottom of the window to save all of your updates. 
  * Reboot the HMC, and then make sure Network changes are properly working. 

### Setup HMC objects on xCAT MN

The xCAT admin needs to define each System P HMC being used in the xCAT database. This requires that HMC node objects are created with proper HMC attributes. Each HMC needs to have a proper network connection, where the HMC node has proper name resolution working with the xCAT MN. 

The xCAT database needs to contain the proper authentication working with HMC userid (hscroot)and the HMC password. The admin can create a global HMC security setting in the **passwd** table if all the HMCs are using the same userid and password. 

  * **Add the default account for hmc**
 
~~~~   
    chtab key=hmc passwd.username=hscroot passwd.password=abc123
~~~~    

The admin needs to create an HMC node object using the mkdef or chdef commands for each HMC. The admin can also set the username and password directly to the HMC node object which will be added to the **ppchcp** table. This is useful when a specific HMC has a username and/or password that is different from the default one specified in the passwd table. For example, to create an HMC node object for hmc1 and set a unique username or password for it: 
 
~~~~   
    mkdef -t node -o hmc1 groups=hmc,all nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc1234
    
    
    # lsdef hmc1
     Object name: c98v2hmc03
       groups=hmc,all
       hcp=hmc1
       hidden=0
       hwtype=hmc
       mgt=hmc
       nodetype=ppc
       password=abc1234
       postbootscripts=otherpkgs
       postscripts=syslog,remoteshell,syncfiles
       username=hscroot 
~~~~    

If you need to change the username or password of the HMC definition, use "chdef" command if already hmc1 exists: 

~~~~    
    chdef -t node -o hmc1 username=hscroot password=abc1234 
~~~~    

  


#### **Enable ssh interface to the HMC**

You will want to enable the SSH interface between the xCAT MN and HMC, so the xCAT commands will run without being prompted for passwords. Run the "rspconfig" command to do this: 

~~~~    
     rspconfig  <HMC node>  sshcfg=enable
~~~~    

After you setup the ssh keys to the HMC with the rspconfig command, xCAT will no longer need the hscroot password in the database and it can be removed. It will be needed in the future, if root's ssh keys are ever regenerated on the EMS. If ssh keys are regenerated, then the **rspconfig &lt;HMC node&gt; sshcfg=enable command** will have to be rerun, and the new password will need to be available in the database on the xCAT MN. 

### Discover the LPARs managed by HMC using rscan

Run the **rscan** command to each HMC to gather the Frame, CEC, and LPAR information. This command can be used to display the information in several formats and can also write the Frame, CEC, and LPAR information directly to the xCAT database. In this example we will use the "-z" option to create a stanza file that contains the information gathered by **rscan** that will be used for the Frame, CEC, and LPAR node definitions. 

To write the stanza format output of **rscan** to a file called "hmc1node.stanza" run the following command. For example: 
   
~~~~ 
    rscan -z hmc1 > hmc1node.stanza
~~~~    

This stanza file can then be checked and modified as needed. For example you may need to add a different name for the some of the node definition or add additional attributes and values. Once the stanza file has been updated with the proper LPAR node information, we will execute the **mkdef** command to place the node definitions into the xCAT database 
 
~~~~   
    cat hmc1node.stanza |  mkdef -z 
~~~~    

The stanza file for P7 CEC and LPAR node object will look something like the following. 

~~~~    
    Server-8233-E8B-SN100538P
        groups=cec,all
        hcp=hmc1
        hwtype=cec
        mgt=hmc
        mtm=8233-E8B
        nodetype=ppc
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles
        serial=100538P
    

    
    
    p7hv16sber01:
        cons=hmc
        groups=lpar,all
        hcp=hmc1
        hwtype=lpar
        id=3
        mgt=hmc
        nodetype=ppc,osi
        parent=Server-8236-E8C-SN06355FP
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles
        pprofile=p7hv16profile
    
    
~~~~
  


**Note**: The **rscan** command supports an option to automatically create node definitions in the xCAT database. To do this the LPAR name gathered by **rscan** is used as the node name and the command sets several default values. But the nodename of CEC and lpar **can not be the same** since xCAT use nodename to identify every object.

For a node which was defined correctly before, you can use the following commands  to export the definition into a node.stanza file  and  to take the definitions in the node.stanza file and update the database.  You can edit the node.stanza file to make any changes before updating the database if you need to. 

~~~~
  lsdef -z nodename > node.stanza
  cat node.stanza | chdef -z 

~~~~


## Firmware upgrade

### Prepare for Firmware upgrade

#### Enable the HMC to allow remote ssh connections(Only for P5/P6 with HMC).

**[AIX]**

Ensure that ssh is installed on the AIX xCAT management node. If you are using an AIX management node, make sure the value of "useSSHonAIX" is "yes" in the site table. 

~~~~    
     chdef -t site -o clustersite useSSHonAIX=yes
~~~~    

#### Define the necessary attributes

The Lpar , CEC, or BPA has been defined in the nodelist, nodehm, nodetype, vpd, ppc tables. 

#### Define the HMC as a node(Only for P5/P6 with HMC)

Define the HMC as a node on the management node. For example, 

~~~~    
    chdef hmc01.clusters.com nodetype=hmc mgt=hmc groups=hmc username=hscroot password=abc123
~~~~    

#### Setup SSH connection to HMC(Only for P5/P6 with HMC)

Run the rspconfig command to set up and generate the ssh keys on the xCAT management node and transfer the public key to the HMC. You must also manually configure the HMC to allow remote ssh connections. The password of the hscroot must have been put in the xCAT passwd table. This password is used by the rspconfig command to authenticate to the HMC. For example: 
 
~~~~   
    rspconfig hmc01.clusters.com sshcfg=enable
~~~~    

#### Get the Microcode update package and associated XML file

Download the Microcode update package and associated XML file from the IBM Web site: 

~~~~    
    http://www14.software.ibm.com/webapp/set2/firmware/gjsn.
~~~~    

  


### **Perform Firmware upgrade for CEC on P5/P6/P7**

#### **Define the CEC as a node on the management node**

For P5/P6 (with HMC),P7 (without HMC) node definition, refer to [XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems/#define-the-cec-as-a-node-on-the-management-node](XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems/#define-the-cec-as-a-node-on-the-management-node).

#### Check firmware level
 
~~~~   
    rinv Server-m_tmp-SNs_tmp firm
~~~~    

#### **Update the firmware**

Download the Microcode update package and associated XML file from the IBM Web site: 

~~~~    
    http://www14.software.ibm.com/webapp/set2/firmware/gjsn.
~~~~    

Create the /tmp/fw directory, if necessary, and copy the downloaded files to the /tmp/fw directory. 

  
Run the rflash command with the --activate flag to specify the update mode to perform the updates. See the "flash" manpage for more information. 
 
~~~~   
    rflash Server-m_tmp-SNs_tmp -p /tmp/fw --activate disruptive
~~~~    

  
NOTE:You Need check your update is concurrent or disruptive here!! And the concurrent update is only for P5/P6 with HMC. Other commands sample: 
 
~~~~   
    rflash Server-m_tmp-SNs_tmp -p /tmp/fw --activate concurrent
~~~~    

  
Notes:

1)If the noderange is the group lpar, the upgrade steps are the same as the CEC's.

2)System p5, p6 and p7 updates can require time to complete and there is no visual indication that the command is proceeding.

### **Perform Firmware upgrades for BPA on P5/P6/P7**

#### **Define the BPA as a node on the Management Node**

For P5/P6 (with HMC),P7 (without HMC) nodes definition, refer to [XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems/#define-the-bpa-as-a-node-on-the-management-node](XCAT_System_p_Hardware_Management_for_HMC_Managed_Systems/#define-the-bpa-as-a-node-on-the-management-node).

#### Use rinv to check the firmware level
  
~~~~  
    rinv Server-m_tmps_tmp firm
~~~~    

See rinv manpage for more options. 

#### Update the firmware

Download he Microcode update package and associated XML file from the IBM Web site: 
  
~~~~  
    http://www14.software.ibm.com/webapp/set2/firmware/gjsn
~~~~    

Create the /tmp/fw directory, if necessary, and copy the downloaded files to the /tmp/fw directory. 

  
Run the rflash command with the --activate flag to specify the update mode to perform the updates. 
  
~~~~  
    rflash Server-m_tmps_tmp -p /tmp/fw --activate disruptive
~~~~    

  
NOTE:You Need check your update is concurrent or disruptive here!! And the concurrent update is only for P5/P6 with HMC. other commands sample:
 
~~~~   
    rflash Server-m_tmps_tmp -p /tmp/fw --activate concurrent
~~~~    

### **Commit currently activated LIC update(copy T to P) for a CEC/BPA on p5/p6/p7**

#### **Check firmware level**

Refer to the environment setup in the section 'Firmware upgrade for CEC on P5/P6/p7' to make sure the firmware version is correct. 

#### **Commit the firmware LIC**

Run the rflash command with the **commit** flag. 
 
~~~~   
    rflash Server-m_tmp-SNs_tmp --commit
~~~~    

  
Notes:

(1)If the noderange is Lpar, the commit steps are the same as the CEC's.

(2) When the **\--commit or --recover** two flags is used, the noderange cannot be BPA . It only can be CEC or LPAR for P5/P6,and will take effect for both managed systems and power subsystems. It can be frame or BPA for P7, and will take effect for power subsystems only.

## Energy Management

IBM Power Servers support the Energy management capabilities like to query and monitor the 

* Power Saving Status
* Power Capping Status
* Power Consumption
* CPU Frequency
* Ambient temperature
* Fan Speed
*  ... 

and to set the 

* Power Saving
* Power Capping
* CPU frequency

xCAT offers the command 'renergy' to manipulate the Energy related features for Power Server. Refer to the man page of [renergy](http://xcat.sourceforge.net/man1/renergy.1.html) to get the detail of usage.

