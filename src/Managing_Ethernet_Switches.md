<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Running Remote Commands in Parallel](#running-remote-commands-in-parallel)
  - [How to Add New Switch Types](#how-to-add-new-switch-types)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Overview

When managing Ethernet switches, the admin often logs into the switches one by one using SSH or Telnet and runs the switch commands. However, it becomes time consuming when there are a lot of switches in a cluster. In a very large cluster, the switches are often identical and the configurations are identical. It helps to configure and monitor them in parallel from a single command. 

For managing Mellanox switches, see the following: [Managing_the_Mellanox_Infiniband_Network]. 

For managing Qlogic switches , see the following: [Managing_the_Infiniband_Network] 

## Running Remote Commands in Parallel

From xCAT 2.8, you can use xdsh to run parallel commands on Ethernet switches. The following shows how to configure xCAT to run xdsh on the switches: 

1. Install xCAT 2.8 and later versions. 
2. Configure the switch to allow ssh or telnet. This varies for switch to switch. Please refer to the switch command references to find out how to do it. 
3. Add the switch name in the **nodelist** table. 
    
~~~~
       mkdef bntc125 groups=switch
~~~~  
  
4. Put the ssh or telnet username and password in the **switches** table. 
 
~~~~   
       tabch switches.switch=bntc125 switches.sshusername=<name> \
             switches.sshpassword=<passwd> \
             switches.protocol=<ssh|telnet>
~~~~

**Note:If it is for telnet, add tn: in front of the username.  For example: tn:admin**
    
5. Run xdsh command 

~~~~    
 xdsh bntc125 --devicetype EthSwitch::BNT "enable;configure terminal;vlan 3;end;show vlan"
~~~~    

Please note that you can run multiple switch commands, they are separated by comma. 
Please also note that --devicetype is used here. xCAT ships the following switch types: 

~~~~
             * BNT 
             * Cisco 
             * Juniper 
~~~~

If you have different type of switches, you can either use the general flag
       "**\--devicetype EthSwitch**" or add your own switch types. (See the following section). 
Here is what result will look like: 

~~~~    
       bntc125: start SSH session...
       bntc125:  RS G8000&gt;enable
       bntc125:  Enable privilege granted.
       bntc125: configure terminal
       bntc125:  Enter configuration commands, one per line.  End with Ctrl/Z.
       bntc125: vlan 3
       bntc125: end
       bntc125: show vlan
       bntc125: VLAN                Name                Status            Ports
       bntc125:  ----  --------------------------------  ------  ------------------------ 
       bntc125:  1     Default VLAN                      ena     45-XGE4
       bntc125:  3     VLAN 3                            dis     empty
       bntc125:  101   xcatpriv101                       ena     24-44
       bntc125:  2047  9.114.34.0-pub                    ena     1-23 44
~~~~  
  
You can run xdsh against more than one switches at a time,just like running xdsh against nodes.
Use xcoll to summarize the result. For example: 
 
~~~~   
      xdsh bntc1,bntc2 --devicetype EthSwitch::BNT  "show access-control" |xcoll
    
~~~~

The output looks like this: 

~~~~    
      ====================================
       bntc1,bntc2
      ====================================
      start Telnet session...
      terminal-length 0
      show access-control
      Current access control configuration:
         No ACLs configured.
         No IPv6 ACL configured.
         No ACL group configured.
         No VMAP configured.
    
~~~~
  


### How to Add New Switch Types

For any new switch types that's not supported by xCAT yet, you can use the general "--device EthSwitch" flag with xdsh command. 

~~~~    
       xdsh <switch_names> --devicetype EthSwitch "cmd1;cmd2..."
~~~~    

The only problem is that the page break is not handled well when the command output is long. To remove the page break, you can add a switch command that sets the terminal length to 0 before all other commands. 

~~~~    
 xdsh <switch_names> --devicetype EthSwitch "command-to-set-term-length-to-0;cmd1;cmd2..."
~~~~    

     where command-to-set-term-length-to-0 is the command 
     to set the terminal length to 0 so that the output does not have page breaks. 

  


You can add this command to the configuration file to avoid specifying it for each xdsh by creating a new switch type. Here is what you do: 

~~~~    
       cp /opt/xcat/share/xcat/devicetype/EthSwitch/Cisco/config \
           /var/opt/xcat/EthSwitch/XXX/config
~~~~    

where XXX is the name of the new switch type. You can give it any name. 
Then add the command for set terminal length to 0 to the "pre-command" line.
The new configuration  file will look like this: 

~~~~    
      # cat /var/opt/xcat/EthSwitch/XXX/config
      [main]
      ssh-setup-command=command-to-set-term-length-to-0;
      [xdsh]
      pre-command=;
      post-command=NULL
~~~~    

For BNT switches, the command-to-set-term-length-to-0 is "terminal-length 0". 

Please make sure to add a semi-colon at the end of the "pre-command" line. 

Then you can run the xdsh like this: 

~~~~    
       xdsh <switch_names> --devicetype EthSwitch::XXX "cmd1;cmd2..."
~~~~    
