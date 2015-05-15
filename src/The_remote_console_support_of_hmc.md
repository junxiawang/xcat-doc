<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Introduction**](#introduction)
- [**Following commands will be added to the hmc for "hscroot" id**](#following-commands-will-be-added-to-the-hmc-for-hscroot-id)
  - [**Setup the sol**](#setup-the-sol)
  - [**Setup the bmc**](#setup-the-bmc)
- [**xCAT command**](#xcat-command)
  - [**Turn on/off the sol**](#turn-onoff-the-sol)
  - [**Setup the network for the bmc**](#setup-the-network-for-the-bmc)
  - [**Setup the user/password for the bmc**](#setup-the-userpassword-for-the-bmc)
  - [**Configure the interface mode for the bmc**](#configure-the-interface-mode-for-the-bmc)
- [**The steps to setup the hmc for a cluster**](#the-steps-to-setup-the-hmc-for-a-cluster)
  - [**Hardware setup**](#hardware-setup)
  - [**Define the hmc object**](#define-the-hmc-object)
  - [**Configure the bmc for SOL support**](#configure-the-bmc-for-sol-support)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

Mini-design of sol/bmc setup for hmc [TOC]

## **Introduction**

The remote console to the hmc is important for a cluster with large number of hmcs. Since hmc is working on a restrict linux, some commands and functions which are necessary for the remote console are not available for the general user id "hscroot". If xCAT would like to make sol/bmc setup work for "hscroot" user, some new hmc commands are needed to setup the sol and bmc in "hscroot" id. hmc people is working on two commands to turn on/off sol and setup the bmc, xCAT can use these commands to implement the remote console for hmc. 

## **Following commands will be added to the hmc for "hscroot" id**

### **Setup the sol**

chhmc --sol -s {enable | disable} 
    
       enable - will add the configuration
       disable - will remove the configuration
    

Following things will be done when enable the sol: 

  * Redirect the remote console to the com1; do the related configuration in the BIOS. (in the development phase) 
  * Add a line in the /etc/inittab and /boot/grub/menu.lst to open the tty when booting the hmc. 
  * Setup the bmc. (in the development phase) 
  * Possibly to make ipmitool available on hmc? 

### **Setup the bmc**

Following functions will be supported for the bmc setup on hmc: 

  * Setup the network information (IP/Netmask/Gateway) for the bmc. 
    
       chhmc -c imm -s modify -a &lt;imm_ipaddr&gt; -nm &lt;imm_netmask_ipaddr&gt;
    

  * Setup the user/password for the bmc. 
    
       chhmc -c imm -s modify -u &lt;imm_login_id&gt; -p &lt;imm_passwd&gt;
    

  * Configure the interface mod of IMM. The value can be one of 'Dedicated' or 'Shared'. 
    
       chhmc -c imm -s modify -i &lt;if_mode&gt;
    

## **xCAT command**

xCAT has the command rspconfig to handle the configuration for the service processor of a node. For the sol and bmc setup of the hmc, the rspconfig command is a good place to implement them.   


### **Turn on/off the sol**
    
    rspconfig &lt;noderange&gt; solcfg={enable|disable}
    

The hmc command 'chhmc' will be called directly (ssh) to handle the on/off operations. 

### **Setup the network for the bmc**
    
    rspconfig &lt;noderange&gt; network={[ip],[netmask] | *}
    

The hmc will have a command to handle this. If specifying the argument 'network=*', the ip/netmask/gateway information will be gotten from xCAT DB. 

### **Setup the user/password for the bmc**
    
    rspconfig &lt;noderange&gt; bmc_userpwd={newuser,newpasswd}
    

The hmc will have a command to handle this. The old user/passwd will be gotten from xCAT DB. After the successfully setup, the new user:passwd should be written into xCAT DB. 

### **Configure the interface mode for the bmc**
    
    rspconfig &lt;noderange&gt; bmc_ifmode={Dedicated|Shared}
    

In Dedicated mode, the IMM is using the IMM-eth to communicate (Out-of-Band); In Shared mode, the IMM will using the eth0 of hmc host to communicate (In-Band). 

## **The steps to setup the hmc for a cluster**

### **Hardware setup**

Both of the hmc and bmc should be connected to the service network, so that xCAT can communicate with them for management. A hmc has three ethernet interfaces: one for IMM management (it can be named IMM-eth0); two for the hmc host (they can named hmc-eth0, hmc-eth1). The IMM suppots In-Band and Out-of-Band for communication. 
    
    In-Band: Using the hmc-eth0 for communication. It is set by Shared mode.
    Out-Band: Using the IMM-eth0 for communiction. It is set by Dedicated mode.
    

For the redundancy support, there are two service networks for failover. The hmc-eth0 should be connected to the Primary network; the hmc-eth1 of hmc host and IMM-eth0 should be connected to the Secondary network. 

  * When the cluster is working in Primary network, the IMM interface should be set to 'Shared' mode. In this case, both hmc and bmc are using the hmc-eth0 for communication. 
  * When the cluster is working in Secondary network, the IMM interface should be set to 'Dedicated' mode. In this case, IMM is using the IMM-eth0 for communicatation but the hmc is using the hmc-eth1 for communication. 

### **Define the hmc object**

There are two possible methods to defined the hmc in a cluster, we still need to investigate that whether they are workable. 

**Method 1** 1\. Install the hmc hardware during the setup of a cluster.  
2\. Manually collect the mac addresses of all hmcs. Assign hostname, 'OS level IP' and 'BMC level IP' to all hmcs. Add the hostname and 'OS level IP' mapping of hmcs in the /etc/hosts file.  
3\. Define all the hmcs into the xCAT DB. The hmc objects should include following attributes: 
    
     Object name: hmc1
         bmc=&lt;bmc_ip&gt;
         bmcpassword=&lt;bmc_passwd&gt;
         bmcusername=&lt;bmc_user&gt;
         mac=xx:xx:xx:xx:xx:xx
         cons=ipmi
         groups=hmc,all
         mgt=ipmi
         serialflow=hard
         serialport=0
         serialspeed=19200
    

4\. Run 'makedhcp -a' to add the IP-MAC mapping in the dhcpd lease file.   
5\. Manually boot up the hmcs. The hmcs will get network configuration which defined in step2 from dhcp server.  


**The method 2** 1\. Assign a IP range in the xCAT dhcp server for the hmc in a cluster. 2\. Power on the hmc to make each of them get a dynamic IP. 3\. run the lsslp to get the information of each hmc. 4\. Admin needs to map them to the physical hmc and define a xCAT object base on this information. 

  


### **Configure the bmc for SOL support**

1\. Setup the network for bmc: 
    
     rspconfig hmc network=*
    

2\. Change the user/password for bmc: (Optinal) 
    
     rspconfig hmc bmc_userpwd=user,passwd
    

3\. Enable the sol for hmc: 
    
     rspconfig hmc solcfg=enable
    
