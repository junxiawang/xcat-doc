<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Define the CMMs](#define-the-cmms)
- [Define the Switches](#define-the-switches)
- [Fill in More xCAT Tables](#fill-in-more-xcat-tables)
  - [The passwd Table](#the-passwd-table)
  - [The networks Table](#the-networks-table)
- [**Declare a dynamic range of addresses for discovery**](#declare-a-dynamic-range-of-addresses-for-discovery)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


### Define the CMMs

First just add the list of CMMs and the groups they belong to: 

~~~~    
    nodeadd cmm[01-15] groups=cmm,all
~~~~    

Now define attributes that are the same for all CMMs. These can be defined at the group level. For a description of the attribute names, see the [node object definition](http://xcat.sourceforge.net/man7/node.7.html). 

~~~~    
    chdef -t group cmm hwtype=cmm mgt=blade 
~~~~    

Next define the attributes that vary for each CMM. There are 2 different ways to do this. Assuming your naming conventions follow a regular pattern, the fastest way to do this is use regular expressions at the group level: 
 
~~~~   
    chdef -t group cmm mpa='|(.*)|($1)|' ip='|cmm(\d+)|10.0.50.($1+0)|'
~~~~    

Note: The Flow for CMM IP addressing is 1) initially each CMM obtains a DHCP address from a dynamic range of IP addresses specified later, 2) This DHCP address will be listed when we do CMM discovery using lsslp 3) CMM configuration steps will change the CMM DHCP obtained ip address to the permanent static IP address which is specified here. 

This chdef might look confusing at first, but once you parse it, it's not too bad. The regular expression syntax in xcat database attribute values follows the form: 
 
~~~~   
    |pattern-to-match-on-the-nodename|value-to-give-the-attribute|
~~~~    

You use parentheses to indicate what should be matched on the left side and substituted on the right side. So for example, the mpa attribute above is: 

~~~~    
    |(.*)|($1)|
~~~~    

This means match the entire nodename (.*) and substitute it as the value for mpa. This is what we want because for CMMs the mpa attribute should be set to itself. 

For the ip attribute above, it is: 
  
~~~~  
    |cmm(\d+)|10.0.50.($1+0)|
~~~~    

This means match the number part of the node name and use it as the last part of the IP address. (Adding 0 to the value just converts it from a string to a number to get rid of any leading zeros, i.e. change 09 to 9.) So for cmm07, the ip attribute will be 10.0.50.7. 

For more information on xCAT's database regular expressions, see http://xcat.sourceforge.net/man5/xcatdb.5.html . To verify that the regular expressions are producing what you want, run lsdef for a node and confirm that the values are correct. 

If you don't want to use regular expressions, you can create a stanza file containing the node attribute values: 

~~~~    
    cmm01:
      objtype=node
      mpa=cmm01
      ip=10.0.50.1
    cmm02:
      objtype=node
      mpa=cmm02
      ip=10.0.50.2
    ...
~~~~    

Then pipe this into chdef: 
 
~~~~   
    cat <stanzafile> | chdef -z
~~~~    

When you are done defining the CMMs, listing one should look like this: 
 
~~~~   
    lsdef cmm07
    Object name: cmm07
        groups=cmm,all
        hwtype=cmm
        ip=10.0.50.7
        mgt=blade
        mpa=cmm07
        postbootscripts=otherpkgs
        postscripts=syslog,remoteshell,syncfiles
~~~~    

### Define the Switches
  
~~~~  
    nodeadd switch[1-4] groups=switch,all
    chdef -t group switch ip='|switch(\d+)|10.0.60.($1+0)|'
~~~~    

### Fill in More xCAT Tables

#### The passwd Table

There are several passwords required for management: 

  * **blade** \- The userid and password for the CMM. 
  * **ipmi** \- The userid and password used to communicate with the IPMI service on the IMM (BMC) of each blade. To avoid problems, this should be the same as the CMM userid and password above. 
  * **system** \- The root id and password which will be set on the node OS during node deployment and used later for the administrator to login to the node OS. 

Use [tabedit](http://xcat.sourceforge.net/man8/tabedit.8.html) to give the passwd table contents like: 
   
~~~~ 
    key,username,password,cryptmethod,comments,disable
    "blade","USERID","PASSW0RD",,,
    "ipmi","USERID","PASSW0RD",,,
    "system","root","cluster",,,
~~~~    

#### The networks Table

All networks in the cluster must be defined in the networks table. When xCAT was installed, it ran makenetworks, which created an entry in this table for each of the networks the management node is connected to. Now is the time to add to the networks table any other networks in the cluster, or update existing networks in the table. 

For a sample Networks Setup, see the following example: [Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example).

### **Declare a dynamic range of addresses for discovery**

If you want to use hardware discovery, 2 dynamic ranges must be defined in the networks table: one for the service network (CMMs and IMMs), and one for the management network (the OS for each blade). The dynamic range in the service network (in our example 10.0) is used while discovering the CMMs and IMMs using SLP. The dynamic range in the management network (in our example 10.1) is used when booting the blade with the genesis kernel to get the MACs. 

~~~~    
    chdef -t network 10_0_0_0-255_255_0_0 dynamicrange=10.0.255.1-10.0.255.254
    chdef -t network 10_1_0_0-255_255_0_0 dynamicrange=10.1.255.1-10.1.255.254
~~~~   