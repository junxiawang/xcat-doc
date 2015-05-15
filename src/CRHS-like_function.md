<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [CRHS-like function](#crhs-like-function)
  - [1\. Overview (or external design)](#1%5C-overview-or-external-design)
    - [1.1 What is xCAT CRHS-like functions](#11-what-is-xcat-crhs-like-functions)
    - [1.2 Prerequisites](#12-prerequisites)
    - [1.3 How to perform xCAT CRHS-like functions](#13-how-to-perform-xcat-crhs-like-functions)
  - [2\. Function flow](#2%5C-function-flow)
  - [3\. New commands](#3%5C-new-commands)
    - [3.1 mkconn](#31-mkconn)
    - [3.2 rmconn](#32-rmconn)
    - [3.3 lsconn](#33-lsconn)
  - [](#)
  - [4\. Commands to be changed](#4%5C-commands-to-be-changed)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


# CRHS-like function

## 1\. Overview (or external design)

xCAT CRHS-like function provides an automatic approach for users to easily initialize and manage a large scaling cluster. 

### 1.1 What is xCAT CRHS-like functions

xCAT CRHS-like function includes 2 parts:  
1\. Discovering HMCs, CECs and frames in MN subnet. To perform this function, users need to issue xCAT command lsslp, which has been implemented in xCAT 2.0, but in this line item this command will be improved. See section 3.2 for the detailed changes, and see lsslp man page for the implemented functions.  
2\. Assigning discovered CECs and frames to HMCs. New commands mkconn, lsconn and rmconn will be added in this line item. Users can run these 3 new commands to manipulate the connections between HMCs and CECs/frames. See section 4.1 for the details of these commands. 

  


### 1.2 Prerequisites

1.2.1 xCAT MN  
xCAT MN can running any OS that xCAT 2.3 support: AIX, RedHat, and SLES, or any other systems that will be supported in future.  
No predefined object in xCAT DB is required, i.e. users can perform this function on a “fresh” xCAT MN. 

1.2.2 Network configuration  
To perform CRHS-like function, xCAT MN should be connected to the HMC service subnet (which is used for HMCs to connect to Frames and CECs). 

1.2.3 Hardware  
This function only supports P6 in xCAT 2.3. So Power 6 HMC, FSP and BPA are required. HMCs should be configured with correct IP addresses so that they can communicate with MN. Or, it can be configured as a DHCP client (this is the common case). 

  


### 1.3 How to perform xCAT CRHS-like functions

There are 2 scenarios to perform this function. Users can choose either one, according their actual environment: 

  * HMC/FSP/BPA will finally be running with static IP addresses. Though, as mentioned in 1.2.3, the HMC/FSP/BPA probably has been configured as DHCP clients to receive dynamic IP addresses from DHCP server(s). Users may want their machines to be set to static IP addresses, to avoid any drawbacks of setting up one or more DHCP servers. 
  * HMC/FSP/BPA will finally be running with dynamic IP addresses. This is a more common case than above scenario. 

See following sections for the details of function flow for both 2 scenarios. 

## 2\. Function flow

**2.1 Scenario #1.** HMC/FSP/BPA will run with static IP addresses.  
There are 2 possible initial configurations on HMC/FSP/BPA: 

**2.1.1 HMC/FSP/BPA have been configured as DHCP clients:**

  * Step 1: Setup networks table, add a dynamic IP range. Run "makedhcp -n" to add a dynamic IP pool. 

     &lt;Design note: an example is needed here&gt;

  * Step 2: Power on HMC/FSP/BPA manually, and they will get dynamic IP addresses from MN. 
  * Step 3: Run lsslp to discover the HMC/FSP/BPA, this command will also logon HMC/FSP/BPA to update their IP to static IP addresses. 

     &lt;Design note: add more details here, with several examples.&gt;

  * Step 4: Run mkconn to assign frames/CECs to correct HMCs. 

     &lt;Design note: add more details here, with several examples.&gt;

**2.1.2 HMC/FSP/BPA have been configured with static IP addresses, and they are in the MN service subnet:**

  * Step 1: Run lsslp to discover the HMC/FSP/BPA, this command will also logon HMC/FSP/BPA to update their IP to static IP addresses. Same as step #3 in above. 
  * Step 2: Run mkconn to assign frames/CECs to correct HMCs. Same as step #4 in 2.1.1. 

**2.2 Scenario #2.** HMC/FSP/BPA will run with dynamic IP addresses.  
Again, there are 2 possible initial configurations on HMC/FSP/BPA: 

**2.2.1 HMC/FSP/BPA have been configured as DHCP clients:**

  * Step 1: Setup networks table, add a dynamic IP range. Run "makedhcp -n" to add a dynamic IP pool. Same as step #1 in section 2.1.1. 
  * Step 2: Power on HMC/FSP/BPA manually, and they will get dynamic IP addresses from MN. 
  * Step 3: Run lsslp to discover the HMC/FSP/BPA, this command will also put HMC/FSP/BPA IP addresses into xCAT hosts table. (The detailed command option is different to the lsslp in step #3 in section 2.1.1.) 

     &lt;Design note: add more details here, with several examples.&gt;

  * Step 2: Run mkconn to assign frames/CECs to correct HMCs. Same as step #4 in 2.1.1 

**2.2.2 HMC/FSP/BPA have been configured with static IP addresses, and they are in the MN service subnet:**

  * Step 1: Setup networks table, add a dynamic IP range. Run "makedhcp -n" to add a dynamic IP pool. Same as step #1 in section 2.1.1. 
  * Step 2: Power on HMC/FSP/BPA manually, and they will get dynamic IP addresses from MN. 
  * Step 3: Run lsslp to discover the HMC/FSP/BPA, this command will also logon HMC/FSP/BPA to update their IP to **dynamic** IP addresses, and reboot them. 

     &lt;Design note: add more details here, with several examples.&gt;

  * Step 4: After all HMC/FSP/BPA reboot with the new IP addresses provide by the DHCP server on MN (setup in step 1). Run lsslp again to discover the HMC/FSP/BPA with new IP addresses. The option is same as step #3 in 2.2.1. 
  * Step 2: Run mkconn to assign frames/CECs to correct HMCs. Same as step #4 in 2.1.1 

  


## 3\. New commands

Following 3 new commands will be added into xCAT 2.3 to manipulate the connection between HMCs and CECs/frames. 

### 3.1 mkconn

mkconn: to create the connection for a set of CECs/frames to a set of HMCs. 

**Syntax**
**Description**

mkconn _fsp_bpa_node_range_ -t 
Create the connections for CECs and BPAs according the setting in ppc table, i.e. connection info need to be defined in ppc table firstly before running this command. This command can handle the connection for multiple CECs/BPAs to multiple hmc. Note: If a CEC is controlled by a BPA, this CEC cannot be assigned to an HMC individually, instead, the whole frame (BPA node represented) should be assigned to the HMC. That means in this case user should defined the relationship of BPA and CEC in ppc table before running this command (if run lsslp to discover BPA before FSP, lsslp can set the correct relationship in ppc table). 

mkconn _fsp_bpa_node_range -p single_hmc_ [-P _fsp/bpa passwd_] 
Connect CECs/BPAs to the HMC(single hmc node) specified after -p. This syntax does not need the connection defined before running command. This command can only handle multiple CECs/BPAs to one HMC. After a CEC is connected to the hmc successfully, the ppc table will be updated (if there is no connection info in ppc table, then the new info will be added, otherwise the old info will be changed.). 

### 3.2 rmconn

rmconn: to remove the connection for a set CECs/BPAs to a set of HMCs. 

**Syntax**
**Description**

rmconn _fsp_bpa_node_range_
Remove the connections for CECs and BPAs according the setting in ppc table. This command can handle the connection for multiple CECs/BPAs to multiple hmc. 

### 3.3 lsconn

lsconn: to display the connection status for a set of CECs/BPAs 

**Syntax**
**Description**

lsconn _fsp_bpa_node_range_
List the connection status for a set of CECs/BPAs. 

## 

## 4\. Commands to be changed

lsslp 
