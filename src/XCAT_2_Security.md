<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Some Requirements (need more)](#some-requirements-need-more)
- [Auditing](#auditing)
- [Software/Hardware Inventory](#softwarehardware-inventory)
- [User Management](#user-management)
  - [xCAT LDAP support](#xcat-ldap-support)
- [Access Control](#access-control)
- [Password Management](#password-management)
- [Certificates](#certificates)
- [OpenSSH](#openssh)
  - [Restricting node to node ssh](#restricting-node-to-node-ssh)
  - [Secure Zones](#secure-zones)
- [Host Authentication](#host-authentication)
- [Regenerating Certificates and SSH Keys](#regenerating-certificates-and-ssh-keys)
- [File Management](#file-management)
- [Diskful/Diskless support](#diskfuldiskless-support)
- [Hierarchy](#hierarchy)
- [Multiple Database Support](#multiple-database-support)
- [Future Considerations](#future-considerations)
  - [Identity Management](#identity-management)
    - [Active Directory](#active-directory)
    - [Kerberos](#kerberos)
    - [LDAP](#ldap)
  - [Safe-Guarding Passwords in xCAT](#safe-guarding-passwords-in-xcat)
- [Port Usage](#port-usage)
- [Notes](#notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Overview

The security of a system covers a wide range of elements, from the security of system deployment and configuration, to the security of the system’s management, and the security of the software that is running on the system. This document will only cover xCAT and not address the OS, or any additional software packages that might be installed. 

We will discuss security features that are currently implemented in xCAT and proposed enhancements for the future. All information pertains to AIX or Linux, unless otherwise noted. 

This document assumes you are familiar with xCAT, and its architecture. You can reference the following documentation, if you are not. 

The xCAT Home Page: http://xcat.sourceforge.net/ 

xCAT Architecture: [XCAT_2_Architecture] 

### Some Requirements (need more)

  * ssh from MN to CN as root (xcat) 
  * ssh from CN to CN as user (POE/app) - optional 
  * ssh from login node to CN as user 
  * Host key can be common across CNs, but root's private key should be optional 
  * Auditing 

## Auditing

xCAT logs xCAT commands run by the xcatd daemon to both the syslog and the auditlog table in the xCAT database. The commands that are audited can be “ALL” xCAT commands or a list provided by the admin. The auditlog table allows the admin to monitor any attacks against the system or simply over use of resources. The auditlog table is store in the xCAT database ( sqlite,MySQL, Postgresql, DB2) and contains the following record. 

recid: The record id. 
 
~~~~   
      audittime:     The timestamp for the audit entry.
      userid:        The user running the command.
      clientname:    The client machine, where the command originated.
      clienttype:    Type of command: cli,java,webui,other.
      command:       Command executed.
      noderange:     The noderange on which the command was run.
      args:          The command argument list.
      status:        Allowed or Denied.
~~~~    

For more information about auditing, refer to the following documentation: 

[Syslog_and_auditlog] 

## Software/Hardware Inventory

A feature of xCAT is to be able to quickly inventory the software and firmware levels that are installed on the node. For security, this gives you the ability to determine if anything has been changed. For example, you can create a report of the software that is in the OS image that was installed on the node, and then run the **software inventory command (sinv)** to compare what is installed on the node(s) to the original OS image. 

Similarly, you can compare the firmware level, to the original firmware level installed using sinv to run the remote hardware inventory command (rinv) 

For more information, see xCAT use of parallel commands and inventory: 

[Parallel_Commands_and_Inventory] 

## User Management

By default, only root on the management node is authorized to run xCAT commands. But xCAT can be configured to allow both non-root users and remote users to run xCAT commands. By remote users we mean the users can be limited to running the xCAT commands from other nodes ( e.g. login nodes), and not have to login to the Management Server (MS). This helps secure the Management Server by limiting the access to it by only admin accounts. 

Allowing non-root users and remote usrs to run xCAT commands on the MN, is done using the policy table. See Access Control. 

For more information on User Management, refer to the following documentation: 

[User_Management] 

### xCAT LDAP support

xCAT supports the use of LDAP to manage user accounts. This gives you the benefit of a centralize database containing your user accounts, so maintenance it much easier and you do not allow dormant accounts to persist. This is particularly important when you have many user accounts that are changing often. Currently, it is not automatically setup by xCAT. The documenation is how to set it up manally in an xCAT cluster. 

For information on setting up LDAP in xCAT: 

[Setting_up_LDAP_in_xCAT] 

## Access Control

During installation, xCAT gives only root userid the authority to run xCAT commands including accessing the database. 

The policy table in the xCAT database controls who has authority to run specific xCAT operations. It is basically the Access Control List (ACL) for xCAT. The admin ( running as root) may change the policy table to allow other userids to run some or all commands based on configurable restrictions. As of xCAT release 2.8.3 or later, the policy table is first sorted by the priority field, before it is checked. 

For more information about the policy Table, refer to the following documentation: 

http://xcat.sourceforge.net/man5/policy.5.html 

## Password Management

xCAT is required to store passwords for various logons such that the application can login to the devices without having to prompt for a password. The issue was how to securely store and transmit these passwords. 

Currently xCAT stores password in the xCAT database passwd table. You can store them in the clear or some passwords like root userid can be stored encrypted and supply the name of the encryption algorithm in the table. 

In the table you can set the password for root, to be set during the install of the node. This protects the node from any window of time where root is not assigned a password. 

The password for root could be stored MD5 encrypted in the passwd table, here is an example on how to use this in Linux cluster. 

1\. Change the password in passwd table as MD5 encrypted 
  
~~~~  
    tabch key=system passwd.username=root passwd.password=`openssl passwd -1 passw0rd`
~~~~    

2\. Use the encrypted password for node provisioning: 

For diskful: 
 
~~~~   
     nodeset <noderange> osimage=<osimage_name>
~~~~    

For stateless: 

~~~~    
     packimg <osimage_name>
~~~~    

For statelite: 
  
~~~~  
     liteimg <osimage_name>
~~~~    

## Certificates

xCAT generates X.509 (SSL) certificates which it installs on nodes, such as the Service Nodes, where it needs to ensure a secure connection using the SSL/TLS protocol. 

The xCAT daemon uses ssl socket communications to only allow authorized users to run xCAT commands, since all commands are typically run as root in the xCAT cluster. All xCAT commands are initiated as an xCAT "client" (even when run from the xCAT management node) that opens an SSL socket to the xCAT daemon, sends the command and data across that port, and receives responses from the daemon across the same port. When the xCAT daemon receives a request, in addition to having SSL validate the initiating userid/host through proper keys/credentials, the xCAT daemon also checks the policy table to verify that the user is allowed to run a particular command. This is how we support role-based authentication (we only have the basics implemented so far and have many ideas for extending the support to validate/restrict command execution based on parameters such as nodes, etc.). 

xCAT uses the socket for the exchange of any sensitive data during the install, such as ssh private keys to the nodes and we put the credentials on the service nodes ( alternate install nodes), so the xcat daemon on the Service Nodes can communicate with the xcatd on the Management Node. 

## OpenSSH

xCAT performs the setup for root to be able to ssh without password from the Management Node(MN) to all the nodes in the cluster. All nodes are able to ssh to each other without password or being prompted for a known_host entry, unless restricted.
See [XCAT_2_Security/#restricting-node-to-node-ssh](XCAT_2_Security/#restricting-node-to-node-ssh). 
Nodes cannot ssh back to the Management Node or Service Nodes without a password by default. 

  
xCAT generates, on the MN, a new set of ssh hostkeys for the nodes to share, which are distributed to all the nodes during install. If ssh keys do not already exist for root on the MN, it will generate an id_rsa public and private key pair. 

During node install, xCAT sends the ssh hostkeys to /etc/ssh on the node, the id_rsa private key and authorized_keys file to root's .ssh directory on the node to allow root on the MN to ssh to the nodes without password. This key setup on the node allows the MN to ssh to the node with no password prompting. 

On the MN and the nodes, xCAT sets the ssh configuration file to "strictHostKeyChecking no" , so that a known_host file does not have to be built in advanced. Each node can ssh to every other cluster node without being prompted for a password, and because they share the same ssh host keys there will be no prompting to add entries to known_hosts. 

On the MN, you will be prompted to add entries to known_hosts file for each node once. See makeknownhosts command for a quick way to build a known_hosts file on the MN, if your nodes are defined in the xCAT database. 

### Restricting node to node ssh

As of xCAT 2.6, xcat provides a way to limit which nodes are setup to ssh without password to other nodes. 
See [Disable_node_to_node_root_passwordless_access] 

  
### Secure Zones
As of xCAT 2.8.4, you can setup secure zones in xCAT in the cluster.  A node in the zone can ssh without password to any other node in the zone,  but not to nodes in other zones.  See the following documentation:
[Setting_Up_Zones]


  


## Host Authentication

Using OpenSSH for secure remote commands, enables to xCAT to use the built in security of that product. 

Each Database supported ( MySQL, DB2,PostgreSQL) also provides it's own secure host authentication. 

For xCAT commands, currently xCAT uses the privileged port. Since normal users are not allowed to run servers on these ports, you can be fairly sure you have not been intercepted by a hacker. XCAT will also only run commands to hosts that you have defined in the xCAT database and have host name resolution. 

## Regenerating Certificates and SSH Keys

Should your ssl certificates or ssh keys in the cluster become compromised, xCAT makes it quick and easy to regenerate a new set of certificates and/or root ssh key and redistribute them throughout the cluster using the xcatconfig and updatenode commands. 

## File Management

An important feature of xCAT is for the admin to be able to sync configuration files to the nodes. XCAT uses rsync which in turn use the secure remote copy protocol of OpenSSH (scp) to perform the task. 

For more information: [Sync-ing_Config_Files_to_Nodes]. 

## Diskful/Diskless support

xCAT supports creation and install of diskful or diskless images on the nodes. The OS images are built and retained on the Management Node. Each node can run 

its own OS image tailored to the functionality they perform and they have their own specific security hardening needs. It also ensures that the node uses a minimal OS image, without any unnecessary file sets and applications 

The ability to rapidly reinstall the original image to the node, can help protect against viruses and other malicious software that may invade the node over time. 

## Hierarchy

xCAT supports a hierarchical cluster where the Management Node is using a set of Service Nodes to administer the compute nodes in the cluster. The service nodes connect two networks—the management 

and service VLANs; and the network on which the compute nodes running user processes reside. This allows these two networks to be strictly isolated from one another. xCAT has code installed on the Management Node and the Service Nodes but requires no code on the compute nodes in the cluster. 

xCAT automatically sets up the credential, ssh keys and database on the Service Nodes using a secure protocol during install. 

## Multiple Database Support

xCAT supports multiple databases. By default, it uses SQLite. You can chose to use databases such as MySQL, PostgreSQL or DB2, and the additional functionality and security those products offer. 

## Future Considerations

### Identity Management

xCAT needs to integrate with or support a secure Identity Management protocol. This include User id management and machine management. 

Some of the options being considered are:   


#### Active Directory

xCAT is proposing to support Active Directory in a future release. This strengthens security by centralizing identity management which helps in eliminating dormant accounts and enforces consistent security and configuration policies. 

Note: need to check for AIX support of Active Directory. 

#### Kerberos

xCAT could add Kerberos support. This could include OpenSSH support for Kerberos principals and keys. 

Note: How does this fit in an SELinux environment. 

#### LDAP

Better integration with LDAP. Right now xCAT only has a documented procedure to follow:[Setting_up_LDAP_in_xCAT]. 

### Safe-Guarding Passwords in xCAT

A proposal for the future is to change xCAT such the following will occur: 

The passwords will be stored in the xCAT database, with a field indicating this is protected data. The customer can chose a "secure" (xCAT daemon option), by running an xCAT command and supplying a password to the xcatd, to be used to generate a key, that will encrypt all" protected" fields in the database in a one-way hash. This password will only be kept in memory of xcatd. Each time the xcatd is started the password must be supplied. If the password is lost then new passwords for BMC, HMC etc must be setup in the database, and the command must be run encryption on the protected files in the DB . Site.tab table will contain the "secure option enabled" and the one-way hash key. Database will need a "ready" and "maintenance" state to allow the time for the encryption, and update of the DB to take place. Maintenance state will be used to preclude other transactions on the tables while the updates are being done. 

Additional Proposal: In the interest of avoiding a maintenance mode, have a key (I'm thinking stored in a table) that is set either at install time or any time xcatd starts and does not see a key set there. The key entry would have two components, the first a field that would be an MD5 hash of a passphrase that can be used to generate a key to decrypt the key (empty indicates clear key), and the second would be the key itself, potentially encrypted by the passphrase that hashes to the correct value. If xcatd auto-populates it, the passphrase hash entry would be blank, and the key data would be written in the clear. This is the default insecure mode, but happens to encrypt passwords, but not meaningfully. If they desire secure mode, they would run some command that would be obvious for tightening security, presumably shortly after install, that would set a passphrase on that key, deleting the clear copy of the key and writing back the crypted one. The actual key used on encrypted fields would not change, and as such only one field in one table would have to be updated, the whole while every running xcatd retains the memory-resident clear key, so there is no service disruption for possibly distributing the new passphrase to other mgt servers (may or may not be the case depending on the hierarchical architecture chosen). In short, it avoids the issue of effectively downing all management servers (and coding the coordination) for maintenance, while employing strategies that widely-accepted security programs use today to achieve it. 

## Port Usage

The following documentation describes xCAT Port Usage that must be taken into consideration, if desiring to setup a Firewall between the Management Node and Service or Compute Nodes. 

[XCAT_Port_Usage] 

## Notes
Latest release of GPFS only requires root ssh on nodes that will be used to manage GPFS 
