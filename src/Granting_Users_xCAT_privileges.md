<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Granting Users xCAT privileges &amp; Setting Up a Remote Client](#granting-users-xcat-privileges-&amp-setting-up-a-remote-client)
- [Create SSL certificate so that user can be authenticated to xCAT](#create-ssl-certificate-so-that-user-can-be-authenticated-to-xcat)
  - [Change the policy table to allow the user to run commands](#change-the-policy-table-to-allow-the-user-to-run-commands)
  - [Make sure xCAT commands are in the user's path](#make-sure-xcat-commands-are-in-the-users-path)
- [Setup remote commands for user](#setup-remote-commands-for-user)
- [Setup sudo for xCAT user](#setup-sudo-for-xcat-user)
- [Setup Login Node (remote client)](#setup-login-node-remote-client)
- [Setting Up Mounted User Home Directory](#setting-up-mounted-user-home-directory)
- [Setting up a non-root userid for passwordless ssh access (no xCAT privileges)](#setting-up-a-non-root-userid-for-passwordless-ssh-access-no-xcat-privileges)
- [Set up to run xdsh to the node running as root but authenticating as a non-root userid.](#set-up-to-run-xdsh-to-the-node-running-as-root-but-authenticating-as-a-non-root-userid)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Granting Users xCAT privileges &amp; Setting Up a Remote Client

By default, only root on the management node can run xCAT commands. But xCAT can be configured to allow both non-root users and remote users to run xCAT commands. The steps below will explain how. If you only want non-root local users, you can stop after step 2. 

**Note: this support assumes the non-root and root userids are maintained in /etc/passwd.**

## Create SSL certificate so that user can be authenticated to xCAT

This is done by running the following command on the Management node as root: 

~~~~    
    /opt/xcat/share/xcat/scripts/setup-local-client.sh <username>
~~~~ 

By running this command you'll see SSL certificates created. Enter yes where prompted and take the defaults. 

This will create the following files in the $HOME/.xcat directory of your userid: 

~~~~     
    ca.pem
    client-cert.pem
    client-cred.pem
    client-key.pem
    client-req.pem
~~~~ 

This causes xCAT to recognize this userid, so that it can be specified in the policy table in the next step. 

### Change the policy table to allow the user to run commands

For information on the policy table. See man the man the manpage: http://xcat.sourceforge.net/man5/policy.5.html 

To give a user all xCAT command privileges, run "tabedit policy", and add a line: 

~~~~     
    6,"username",,,,,,allow,,
~~~~ 

where <username> is the name of the user that you are granting privileges to. In the above case, this user can
 now perform *all* xCAT commands, including changing the policy table to do things like allow them to become 
other users, so this should be used with caution. 

You may only want to grant users limited access. One example, is that one user may only be allowed to run the nodels command. This can be done as follows: 

~~~~     
    6,"username",,nodels,,,,allow
~~~~ 

If you want to grant all users the ability to run nodels, add this line: 

~~~~     
    6.1,*,,nodels,,,,allow
~~~~ 

Another example is to allow the user to run the rpower command with only the "stat" parameter, and only on
 certain nodes. **(Note: use of the noderange does not currently work for the *def commands).**

~~~~
    
    # mkdef -t policy -o 7 name=<username> commands=rpower parameters=stat noderange=h02-h05 rule=allow
    # su - <username>
    -bash-3.2$ rpower h02 on
    Error: Permission denied for request
    -bash-3.2$ rpower h02 stat
    h02: on
    -bash-3.2$ rpower h01 stat
    Error: Permission denied for request
~~~~

For a full explanation of the policy table, refer to the policy man page: 
~~~~    
    man policy
~~~~

### Make sure xCAT commands are in the user's path

Make sure the directories that contain the xcat commands are in the user's path. If not, add them to the path as appropriate for your AIX or Linux system. 

~~~~    
    echo $PATH | grep xcat
    /opt/xcat/bin:/opt/xcat/sbin: .......
~~~~    

## Setup remote commands for user

To give a user the ability to run remote commands (xdsh,xdcp,psh,pcp), as the username run: 
~~~~    
    xdsh <noderange> -K
~~~~
This will setup the user and root ssh keys for the user under the $HOME/.ssh directory of the user on the nodes. The root ssh keys are needed for the user to run the xCAT commands under the xcatd daemon, where the user will be running as root. Note: the uid for the user should match the uid on the Management Node and a password for the user must have been set on the nodes. 

If your userid's $HOME directory is mounted from the Management Node, you can just do the following on the Management Node instead of using xdsh -K: 

**As root on the MN**: 
    
~~~~
    cat ~/.ssh/id_rsa.pub >>  <Userid home directory>/.ssh/authorized_keys
~~~~    

## Setup sudo for xCAT user

In xCAT 2.8, you can setup a non-root user to run the updatenode and xdsh commands as root on the nodes using sudo. This is only supported in a **non-hierarchical cluster** ( no service nodes) for the first release. As of xCAT 2.8.1, hierarchy is supported. The non-root userid must be setup as an xCAT user as described above. On the nodes , the non-root user id must be defined in sudo (visudo) to be able to run the commands you would like it to run as root. 

If you have not used sudo before, you might check this link for information, which will help understand our setup below. 
 
~~~~    
    http://www.sudo.ws/sudoers.man.html
~~~~     

  
For updatenode -P -S to run as non-root user you need to setup sudo on the nodes. updatenode -S is only supported on Linux for this feature. You may want to give more permission to the non-root user than we have defined below. The minimum required setup is described here. 

Using visudo command. On any node, where you want to run xdsh or updatenode, comment out the following line, if it exists. 

~~~~    
    #Defaults    requiretty
~~~~    

The non-root user must be able to execute commands in /tmp without being prompted for a password as a minimum 
requirement. Using visudo create the following entry, where admin is the group name of your non-root userid. 
    
~~~~
    %admin ALL=NOPASSWD: /tmp/*.dsh
~~~~    

You can then run the following, where the username is a non-root id. 
    
~~~~
    updatenode <nodename> -l username -P syslog
      
    xdsh <nodename> -l username --sudo /tmp/mytest.dsh
~~~~    

In xCAT 2.8.1, we have added sudo support for scp and rsync in xdcp and updatenode -F and support hierarchical
 clusters. Depending on what options you use in xdcp -F and updatenode -F you will have to tailor your sudo
 permission for the non-root userid. The following will allow your non-root userid to run any command.
 
~~~~    
    visudo
    %admin  ALL=(ALL)       NOPASSWD: ALL
~~~~    

## Setup Login Node (remote client)

In some cases, you many not want your non-root user to login to the Management Node, but to use a Login Node and run the xCAT commands from the Login Node.  
To setup a Linux or AIX Login Node, first install the following rpms: 
 
~~~~
perl-xCAT-*  
xCAT-client-+ 
~~~~ 

and from dependencies: 

~~~~ 

perl-IO-Socket-SSL*  
perl-Net-SSLeay-*  
perl-DBI-* 
~~~~

When running on the Login Node, the environment variable XCATHOST must be export to the name or address of the Management node and the port for connections (usually 3001).
 
~~~~    
    export XCATHOST=myManagmentServer:3001
~~~~

The userids and groupids of the non-root users should be kept the same on the Login Node, the Management Node, Service Nodes and compute nodes. 

As in the first step, setup the credentials on the Management node by running the /opt/xcat/share/xcat/scripts/setup-local-client.sh <username> command as root. The credentials are placed in $HOME/.xcat directory. These file must be copied to the $HOME/.xcat directory of the username on the Login Node. 

As in the second step, setup your policy table on the Managment Node with the permissions that you would like the non-root id to have. Remember, you are giving this id the authority to run the xcat commands as root. 

At this time, the id should be able to execute any commands that have been set in the policy table from the Login Node as their userid. 

If any remote shell commmands (psh,xdsh) are needed, then you need to follow the step 3. 

## Setting Up Mounted User Home Directory

This process is to setup the userid's in order to be able to run xcat commands from the login node. The additional work to be done here is to setup ssh such that the user can run the xcat commands from a login node to the Management Node , and the user home directory is nfs mounted from the login node on the Management Node and nodes. 

First, the root admin must define the user and it's group and ensure that the uid and gid are the same across the cluster. It is also desirable to assign a password and distribute this across the cluster. We will be using ssh keys, but if the keys are not there, you can always login with a password. 

Since the home directory of all the users will be mounted on the nodes from the login node ( in our case /nfs01). The home directory must be exported as follows: 

~~~~     
    /nfs01 -sec=sys:krb5p:krb5i:krb5:dh,rw
~~~~     

This ensures that only a user can write to their own directory ( not even root). This is required for the ssh keys in $HOME/.ssh to work. The user's home directory must have permission set to 0700 for ssh. 

On the Management Node, for each user, root must generate the needed credentials for the user. Since root cannot write to the $HOME directory of the user, we must put the credentials in a directory where root can write, and then have the user copy them to their $HOME/,xcat directory. 

So as root: 

  * Create /u/xcat directory in a global mounted /u directory ( substitute "home" for "u" for AIX). 
  * For each user, generate the credential and store in this directory under the user name. 

~~~~     
    /opt/xcat/share/xcat/scripts/setup-local-client.sh <user> /u/xcat/<user>
~~~~     

On the login node as root: 

~~~~    
    chown -R <user>:usr /u/xcat/<user>
    mv /u/xcat/<user>/.xcat  /u/user/.xcat
~~~~
   
    

Mount the user home directories on the Management Node and nodes. 

On the Management Node, root must update the policy table to indicate which users are able to run which 
commands. One way is to just have all users run a subset of xcat commands, like xdsh, xdsh,psh, nodels, lsdef,xcoll,xdshbak, rpower, nodestat, rnetboot, tabdump, sinv,rinv.etc. 

Make sure that in the site table the attribute "useSSHonAIX","yes", if your logon node or your Management Node is AIX. 

To setup ssh so the user can run as root under the xcatd daemon, we need the root ssh authorized_key files from the Managment node added to the users authorized_key files. Root needs to copy to the Login node, the /install/postscripts/_ssh from the Management node: 

~~~~    
    mkdir /u/xcat/c906mgrs1/_ssh
    scp c906mgrs1:/install/postscripts/_ssh/* /u/xcat/c906mgrs1_ssh
~~~~    

Now the user needs to generate their ssh keys on login node: 

~~~~    
    /usr/bin/ssh-keygen -t rsa1. Hit enter to take defaults on all questions, do not set a passphrase.
    /usr/bin/ssh-keygen -t rsa . Hit enter to take all defaults.
    /usr/bin/ssh-keygen -t dsa. Hit enter to take all defaults.
~~~~    

You should have public and private keys (identity, rsa,dsa) in $HOME/.ssh Make sure your $HOME directory permission is set to 0700. Make sure you $HOME/.ssh directory permission is set to 0700. 
    
~~~~    cat identity.pub > authorized_keys
    cat id_rsa.pub > authorized_keys2
    cat id_dsa.pub >>  authorized_keys2
~~~~    

add roots keys: 

~~~~    
    cat /u/xcat/c906mgrs1_ssh/authorized_keys >> authorized_keys
    cat /u/xcat/c906mgrs1_ssh/authorized_keys2 >> authorized_keys2
    chmod 0600 authorized_keys*
~~~~    

At this point on the Login node, the user must 

~~~~    
    "export XCATHOST=Management Node:3001"
    to run xCAT commands on the MN.
~~~~    

Added entries to /etc/profile so this is set up for all users. Right now points to Linux mn. Will need to 
switch to point to AIX MN when we switch modes on the cluster. Also, users should check their PATH and MANPATH 
for xCAT directories. These are set in /etc/profile, but many users override these settings in their private .profile files. 

Verify your setup, as non-root user on the login node run: 
    
~~~~
    nodels to verify database access
    xdsh <node> -l root date   to verify root xdsh access.
~~~~   
    
## Setting up a non-root userid for passwordless ssh access (no xCAT privileges) ##
    

To setup a userid to be able to ssh without being prompted for a password do the following: 
    
~~~~
    login as userid or su - userid
    ssh-keygen -t rsa   ( for every question just hit enter to take the default and no passphrase)
~~~~    

If your userid's home directory is common (mounted) on all machines, then 

~~~~    
    cp ~/.ssh/id_rsa.pub  ~/.ssh/authorized_keys2
~~~~    

If your userid's home directory is not mounted on the node where you wish to run ssh do the following. 
Note: the userid must exist and have a password on the node. You will be prompted for the password the one time to do the below copy. 
 
~~~~   
    scp ~/.ssh/id_rsa.pub <nodename>:.ssh/authorized_keys2
~~~~    

## Set up to run xdsh to the node running as root but authenticating as a non-root userid.

To have root run a command like the one below, where it authenticates to the node as lissatest.
 
~~~~    
    xdsh  node -l lissatest date
~~~~    

You will have to cat /root/.ssh/id_rsa.pub key from the Management Node into /home/lissatest/.ssh/authorized_keys file on the node. Make sure the permission on that directory look like this on the node. 

~~~~    
     drwx------ 2 lissatest lissatest 4096 Aug 19 06:32 .
     drwx------ 5 lissatest lissatest 4096 Aug 19 06:30 ..
     -rw------- 1 lissatest lissatest  381 Aug 19 06:32 authorized_keys
~~~~    
