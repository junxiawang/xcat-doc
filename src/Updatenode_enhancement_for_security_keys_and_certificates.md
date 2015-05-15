<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Interface (added for updatenode command)](#interface-added-for-updatenode-command)
- [Implementation](#implementation)
- [Implementation details:](#implementation-details)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## Background

xCAT framework supports to use the SSL to secure the communication messages among Login node, Management Node and Service Node, it also supports to use the SSH as the secure remote shell to execute command on remote node. All the security related keys and certificates are created during the installation of xCAT packages on Management node, and the security configuration for the nodes (both service node and compute node) are done during the installation process of the nodes . 

After the installation of nodes, sometimes, the security configuration would be lost or messed up for some reason, but xCAT has not an effective approach to reconfigure the security configuration for the whole cluster. Therefore, this security update function is developed to handle these scenarios. 

## Interface (added for updatenode command)

\--security 

Setup the SSH or RSH for the target nodes; Copy the host keys from management node to the target nodes; Update the SSL RSA private key, certificate and Certificate Authorities files from management node to service node. If working with --user or --devicetype flag, the --security flag only setup the SSH key for target nodes; 

\--user user_ID 

Specify the user id which setup the SSH keys for. This flag only can be used with --security and --devicetype flags. 

\--devicetype type_of_device 

Specify a user-defined device type that references the location of relevant device configuration file. This flag only can be used with --security and --user flag. 

So only following two cases will be supported, and them cannot be used together with other options of updatenode command: 
    
     updatenode &lt;noderange&gt; --security
     updatenode &lt;noderange&gt; --security --user --devicetype
    

## Implementation

\--security 

1\. Setup the SSH or RSH for the target nodes; 

If attribute 'useSSHonAIX' = no or 0 is set in site table, only the RSH would be set for the AIX target nodes, otherwise, the SSH would be set on the AIX nodes. For Linux nodes, always setup SSH. 

RSH setup: Add the master IP and root into the /.rhosts on target nodes. For example 4.445.5.1 root 

SSH setup: Since the SSH key setup has already been implemented in ‘xdsh –K’ command, the updatenode will call the 'xdsh -K' through the runxcmd function to complete SSH setup. If the --user flag is also specified with --security, the value of --user will be transported to 'xdsh -K --user' command to complete the function that setup SSH key for non-root user. If the --devicetype is specified with -security flag, the value of --devicetype will be transported to 'xdsh -K --devicetype' command to complete the function that setup SSH key with specific configuration file. 

If specifying the --user or --devicetype flag with --security, the function of --security will be stopped here and return a succeeded message. 

If need to update the host keys for a node with service node then the hostkeys must be updated on the service node first. 

2\. Copy the host keys from management node to the target nodes; 

Copy the keys /etc/xcat/hostkeys/ssh_host_dsa_key, /etc/xcat/hostkeys/ssh_host_rsa_key and ~/.ssh/id_rsa from management node to target nodes. Since the copy action has been implemented in the remoteshell (for linux) and aixremoteshell (for AIX) postscript, updatenode command could call the run postscript function 'updatenode -P remoteshell(aixremoteshell)' to rerun this remoteshell postscript on target nodes. Note: as of xCAT 2.8, we no longer put aixremoteshell in the postscripts table. remoteshell is used for both AIX and Linux nodes. aixremoteshell is called by remoteshell on AIX nodes. 

These keys should be copied from service node if there is, so updatenode needs to figure out and update the service node firstly, then update the compute nodes. If the update of service node failed, then stop the update of compute nodes. 

3\. Update the SSL RSA private key, certificate and CA files to the service node. 

Since these SSL keys only needed by service node, this part of code will only run for service target nodes. 

Copy the keys /etc/xcat/cert/server-cred.pem, /root/.xcat/client-cred.pem, /etc/xcat/cert/ca.pem, ~/.xcat/ca.pem from management node to the service node. Since the copy action has already been implemented in the postscripts servicenode, xcatserver and xcatclient, updatenode command could call the run postscript function 'updatenode -P servicenode,xcatserver,xcatclient' to rerun these postscripts on the target nodes. The xcatserver and xcatclient are only needed to run for Linux node. 

Only part of the servicenode postscript code is used to update the SSL keys, so an option is needed to be added to make the servicenode postscript only do the SSL key update things. 

4\. misc things 

4.1. Setup the /etc/ssh/sshd_config and /etc/ssh/ssh_configon configuration files on the target nodes; 

This will be done in remoteshell or aixremoteshell postscript. 

4.2. Update the ~/.ssh/known_hosts on management node and service node; 

Remove the target node entries from the ~/.ssh/known_hosts before setting up the SSH key. 

4.3. Transfer /etc/xcat/cfgloc to the service nodes 

This will be done in servicenode postscript. 

4.4. Restart the xcatd and sshd on the target node; 

The sshd will be restarted in the remoteshell postscript and the xcatd will be restarted in the servicenode postscript. 

4.5. Test the keys and certificates after the redelivering. 

SSH setup has already been tested in the 'xdsh -K'. 

\--user user_ID 

\--devicetype type_of_device 

The value will be transferred to 'xdsh' command directly. 

## Implementation details:

1\. If a target node is served by a service node, the service node will be updated before updating the target node. All the operations which will be done against the target nodes will be done on the service node firstly. That means if just trying to set up the ssh key, then set up ssh keys on service node; if trying to set up ssh keys and delivering the certificates, then do both of them on service node firstly. 

2\. Since --security option needs to get the enter of user for password which is used for ssh key setup, a updatenode command needs to be added to replace the link of /opt/xcat/bin/xcatclient. 
