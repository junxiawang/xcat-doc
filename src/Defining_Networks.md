<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Define xCAT networks**](#define-xcat-networks)
- [**Create additional NIM network definitions**](#create-additional-nim-network-definitions)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

You will need both an xCAT and a NIM network definition for each subnet containing cluster nodes. 

### **Define xCAT networks**

Create an xCAT network definition for each network that contains cluster nodes. You will need a name for the network definition and values for the following attributes. 

**net** The network address. 

**mask** The network mask. 

**gateway** The network gateway. 

You can use the xCAT **mkdef** command to define the network. 

For example, to define an ethernet network called net1: 
 
~~~~   
    mkdef -t network -o net1 net=9.114.0.0 mask=255.255.255.224 gateway=9.114.113.254
~~~~    

### **Create additional NIM network definitions**

Depending on your specific cluster setup, you may need to create additional NIM network and route definitions. 

NIM network definitions represent the networks used in the NIM environment. When you configure NIM, the primary network associated with the NIM master is automatically defined. You need to define additional networks only if there are nodes that reside on other local area networks or subnets. If the physical network is changed in any way, the NIM network definitions need to be modified. 

To create the NIM network definitions corresponding to the xCAT network definitions you can use the xCAT **xcat2nim** command. 

For example, to create the NIM definitions corresponding to the xCAT "clstr_net" network you could run the following command. 

~~~~    
    xcat2nim -V -t network -o clstr_net
~~~~    

  
**Manual method**

The following is an example of how to define a new NIM network using the NIM command line interface. 

**Step 1**

Create a NIM network definition. Assume the NIM name for the new network is "clstr_net", the network address is "10.0.0.0", the network mask is "255.0.0.0", and the default gateway is "10.0.0.247". 
 
~~~~   
    nim -o define -t ent -a net_addr=10.0.0.0 -a snm=255.0.0.0 -a routing1='default 10.0.0.247' clstr_net
~~~~    

**Step 2**

Create a new interface entry for the NIM "master" definition. Assume that the next available interface index is "2" and the hostname of the NIM master is "xcataixmn". This must be the hostname of the management node interface that is connected to the "clstr_net" network. 

~~~~    
    nim -o change -a if2='clstr_net xcataixmn 0' -a cable_type2=N/A master
~~~~    

**Step 3 - (optional)**

If the new subnet is not directly connected to a NIM master network interface then you should create NIM routing information 

The routing information is needed so that NIM knows how to get to the new subnet. Assume the next available routing index is "2", and the IP address of the NIM master on the "master_net" network is "8.124.37.24". Assume the IP address on the NIM master on the "clstr_net" network is " 10.0.0.241". This command will set the route from "master_net" to "clstr_net" to be " 10.0.0.241" and it will set the route from "clstr_net" to "master_net" to be "8.124.37.24". 

~~~~    
    nim -o change -a routing2='master_net 10.0.0.241 8.124.37.24' clstr_net
~~~~    

**Step 4**

Verify the definitions by running the following commands. 

~~~~    
    lsnim -l master
    lsnim -l master_net
    lsnim -l clstr_net
~~~~    

  
See the NIM documentation for details on creating additional network and route definitions. (_IBM AIX Installation Guide and Reference_. &lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;) 
