<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Networks Table**](#networks-table)
- [**passwd Table**](#passwd-table)
- [**Setup DNS**](#setup-dns)
- [**Setup TFTP**](#setup-tftp)
- [**Setup conserver**](#setup-conserver)
- [**Setup DHCP**](#setup-dhcp)
  - [**(Optional)Setup the DHCP interfaces in site table**](#optionalsetup-the-dhcp-interfaces-in-site-table)
  - [**Initialize DHCP service**](#initialize-dhcp-service)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


### **Networks Table**

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is connected to. Now is the time to add to the networks table any other networks in the cluster, or update existing networks in the table. 

For a sample Networks Setup, see the following example in Appendix_A 
 [Setting_Up_a_Linux_xCAT_Mgmt_Node#Appendix_A:_Network_Table_Setup_Example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example)



### **passwd Table**

The password should be set in the passwd table that will be assigned to root when the node is installed. You can modify this table using tabedit. To change the default password for root on the nodes, change the system line. To change the password to be used for the BMCs (x-series only), change the ipmi line. 
    
    tabedit passwd
    #key,username,password,cryptmethod,comments,disable
    "system","root","cluster",,,
    "hmc","hscroot","ABC123",,,
    

### **Setup DNS**

To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN: 

  * Ensure that /etc/sysconfig/named does not have ROOTDIR set 
  * Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can't answer to these servers. 

~~~~    
    chdef -t site forwarders=1.2.3.4,1.2.5.6
~~~~

  * Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above.) 
    
    search cluster
    nameserver 172.20.0.1
    

  * Run makedns 

~~~~    
    makedns -n
~~~~
    

For more information about name resolution in an xCAT Cluster, see [Cluster_Name_Resolution]. 

### **Setup TFTP**

Nothing to do here - the TFTP server is done by xCAT during the Management Node install. 

### **Setup conserver**

~~~~
    makeconservercf
~~~~

### **Setup DHCP**

#### **(Optional)Setup the DHCP interfaces in site table**

To set up the site table dhcp interfaces for your system p cluster, identify the correct interfaces that xCAT should listen to on your management node and service nodes:

~~~~
     chdef -t site dhcpinterfaces='pmanagenode|eth1;service|eth0'
~~~~

#### **Initialize DHCP service** ####

Create a new dhcp configuration file with a network statement for each network the dhcp daemon should listen on.

~~~~
     makedhcp -n
     service dhcpd restart
~~~~