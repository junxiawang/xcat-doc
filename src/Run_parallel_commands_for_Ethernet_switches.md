<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [The Design](#the-design)
  - [Using existing attributes to store the SSH/Telnet username and password](#using-existing-attributes-to-store-the-sshtelnet-username-and-password)
  - [Using --devicetype to identify Ethernet Switches](#using---devicetype-to-identify-ethernet-switches)
  - [Adding support for backup config file](#adding-support-for-backup-config-file)
  - [Using SSHInteractive and Net::Telnet classes for SSH and Telnet sessions in xdsh](#using-sshinteractive-and-nettelnet-classes-for-ssh-and-telnet-sessions-in-xdsh)
- [How to Use](#how-to-use)
- [How to Add New Switch Types](#how-to-add-new-switch-types)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Introduction

When managing Ethernet switches, the admin often gets on the switches one by one using SSH or Telnet and runs the switch commands. However, there are a lot of switches for a large cluster; this work becomes time consuming. There is a need to run the switch CLIs in parallel. One example is that the admin configures one switch and pushes the same configuration to other switches. In xCAT today, we can xdsh to run parallel commands on nodes and QLogic and Mellanox IB switches, So if we can modify the xdsh to work with Ethernet switches, it will be easier for the user to understand and use it. 

## The Design

xdsh currently only supports password-less SSH when running remote commands on the nodes. In order to do so, one has to add the server's SSH public key to the authorized_keys file on the node. However, the CLI of the Ethernet switches does not support such function. We need to modify the xdsh to use SSH/Telnet interactive session to pass in the password. The following is the list of things that will be added or changed. 

### Using existing attributes to store the SSH/Telnet username and password

The switches table already has two columns: 

  * sshusername 
  * sshoassword 

They were added for IB switches in xCAT 2.7. Now we can use them for Ethernet switches. We just need to expend the meaning of it to include both SSH and Telnet, though the names say "ssh". 

### Using --devicetype to identify Ethernet Switches

xdsh supports --devicetype for IB switches. For example: device type IBSwitch::QLogic and IBSwitch::Mellanox are for QLogic and Mellanox IB switches respectively. In this release, the new devicetype EthSwitch will be added. For example: EthSwitch::Cisco, EthSwitch::BNT etc. 

### Adding support for backup config file

In xdsh, each device type has a configuration file called **config** associated with it where it stores the pre-command scripts and post-command scripts. xdsh searches the configuration file under /var/opt/xcat/&lt;name&gt;/ directory, where &lt;name&gt; is the devicetype specified on the command. We'll add support so that xdsh will search for /opt/xcat/share/devicetype/&lt;name&gt; if the first search fails. For example, for --devicetype EthSwitch::Cisco, xdsh will first search for /var/opt/xcat/EthSwitch/Cisco/config file. If it fails, it will search for /opt/xcat/share/xcat/EthSwitch/Cisco/config file. This way the user does not have to move the config file to /var if they do not wish to make any changes to it. xCAT will ship default config files under /opt/xcat/share/xcat/devicetype directory for the following switches in this release: 

  * Cisco 
  * BNT 
  * Juniper 

User can add other types of switches by providing the config files under /var/opt/xcat/EthSwitch/&lt;switch_vendor&gt;/ directory. 

### Using SSHInteractive and Net::Telnet classes for SSH and Telnet sessions in xdsh

xdsh internally uses /usr/bin/ssh command to communicate with the nodes. ssh command does not take possword from the arguments. We'll add a new command called /opt/xcat/sbin/rshell_api which is used internally by xdsh to communicate interactively with the Ethernet switches using SSHInteractive class and Net::Telnet class. It will try to ssh to switch with the username and the password read from the switches table. If it fails, it will try to telnet to the switch. More than one switch command can be specified at a time. They will be comma separated. 

## How to Use

Example: Create a new vlan called vlan 3 on a BNT Switch named bntc125. 

     1\. Install xCAT 2.8 and later versions. 
     2\. Configure the switch to allow ssh or telnet. 
     3\. Add the switch name in the nodelsit table. 
    
       mkdef bntc125 groups=switch
    

     4\. Save the ssh or telnet username and password in the switches table. 
    
       chdef switches.switch=bntc125 switches.sshusername=&lt;name&gt; switches.sshpassword=&lt;passwd&gt; switches.protocol=&lt;telnet|ssh&gt;
    

     5\. Run xdsh command 
    
       xdsh bntc125--devicetype EthSwitch::BNT "enable;configure terminal;vlan 3;end;show vlan"
    

     Here is what result will look like: 
    
       bntc125: start SSH session...
       bntc125:  RS G8000&gt;enable
       bntc125:  Enable privilege granted.
       bntc125: configure terminal
       bntc125:  Enter configuration commands, one per line.  End with Ctrl/Z.
       bntc125: vlan 3
       bntc125: end
       bntc125: show vlan
       bntc125: VLAN                Name                Status            Ports
       bntc125:  ----  --------------------------------  ------  ------------------------          -
       bntc125:  1     Default VLAN                      ena     45-XGE4
       bntc125:  3     VLAN 3                            dis     empty
       bntc125:  101   xcatpriv101                       ena     24-44
       bntc125:  2047  9.114.34.0-pub                    ena     1-23 44
    

    Please note that you can specify more than one switches here. 

## How to Add New Switch Types

It is very easy to add a new Ethernet switch type. All you need to do is to add a new configuration file for that switch and make some modifications. For example, if you want to add a new type called XXX, then just copy /opt/xcat/share/xcat/devicetype/EthSwitch/Cisco/config to /var/opt/xcat/EthSwitch/XXX/config. The Cisco configuration looks like this: 
    
      # cat /opt/xcat/share/xcat/devicetype/EthSwitch/Cisco/config
      [main]
      ssh-setup-command=
      [xdsh]
      pre-command=terminal length 0;
      post-command=NULL
    

The **pre-command** here ("terminal length 0") is a switch command for disable the page breaks so that the output will come out as a whole page. You can modify it to be the equivalent command from XXX type. Please remember to add a semi-colon at the then. Now you can run xdsh for this type of switches: 
    
       xdsh myswitches --devicetype EthSwitch::XXX "some commands"
    
