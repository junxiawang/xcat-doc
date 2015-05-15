[Howto_Warning](Howto_Warning)

  
This process is to setup the userid's in order to be able to run xcat commands from the login node. Reference: [http://xcat.wiki.sourceforge.net/Granting+Users+xCAT+privileges.](Granting_Users_xCAT_privileges.) The additional work to be done here is to setup ssh such that the user can run the xcat commands from a login node to the Management Node , and the user home directory is nfs mounted from the login node on the Management Node and nodes.  
First, the root admin must define the user and it's group and ensure that the uid and gid are the same across the cluster. It is also desirable to assign a password and distribute this across the cluster. We will be using ssh keys, but if the keys are not there, you can always login with a password.  
Since the home directory of all the users will be mounted on the nodes from the login node ( in our case /nfs01). The home directory must be exported as follows: /nfs01 -sec=sys:krb5p:krb5i:krb5:dh,rw. This ensures that only a user can write to their own directory ( not even root). This is required for the ssh keys in $HOME/.ssh to work. The user's home directory must have permission set to 0700 for ssh.  
On the Management Node, root must run /opt/xcat/share/xcat/scripts/setup-local-client.sh &lt;user&gt;, for each user. This will generate the needed credentials for the user. Since root cannot write to the $HOME directory of the user, we must put the credentials in a directory where root can write, and then have the user copy them to their $HOME/,xcat directory.  
So as root:  
\- created /u/xcat directory in a global mounted /u directory ( substitute "home" for "u" for AIX).  
\- for each user, generate the credential and store in this directory under the user name.  
/opt/xcat/share/xcat/scripts/setup-local-client.sh &lt;user&gt; /u/xcat/&lt;user&gt;

On the login node as root:  
\- chown -R &lt;user&gt;:usr /u/xcat/&lt;user&gt;  
\- mv /u/xcat/&lt;user&gt;/.xcat /u/user/.xcat 

Mount the user home directories on the Management Node and nodes.  
On the Management Node, root must update the policy table to indicate which users are able to run which commands. One way is to just have all users run a subset of xcat commands, like xdsh, xdsh,psh, nodels, lsdef,xcoll,xdshbak, rpower, nodestat, rnetboot, tabdump, sinv,rinv.etc.  
Make sure that in the site table the attribute "useSSHonAIX","yes", if your logon node or your Management Node is AIX.  
To setup ssh so the user can run as root under the xcatd daemon, we need the root ssh authorized_key files from the Managment node added to the users authorized_key files. Root needs to copy to the Login node, the /install/postscripts/_ssh from the Management node:  
\- mkdir /u/xcat/c906mgrs1/_ssh  
\- scp c906mgrs1:/install/postscripts/_ssh/* /u/xcat/c906mgrs1_ssh 

Now the user needs to generate their ssh keys on login node: 

/usr/bin/ssh-keygen -t rsa1. Hit enter to take defaults on all questions, do not set a passphrase.  
/usr/bin/ssh-keygen -t rsa . Hit enter to take all defaults.  
/usr/bin/ssh-keygen -t dsa. Hit enter to take all defaults.  
You should have public and private keys (identity, rsa,dsa) in $HOME/.ssh  
Make sure your $HOME directory permission is set to 0700. Make sure you $HOME/.ssh directory permission is set to 0700.  
cat identity.pub &gt; authorized_keys  
cat id_rsa.pub &gt; authorized_keys2  
cat id_dsa.pub &gt;&gt; authorized_keys2  
add roots keys:  
cat /u/xcat/c906mgrs1_ssh/authorized_keys &gt;&gt; authorized_keys  
cat /u/xcat/c906mgrs1_ssh/authorized_keys2 &gt;&gt; authorized_keys2  
chmod 0600 authorized_keys*  
At this point on the Login node, the user must "export XCATHOST=Management Node:3001", to run xCAT commands on the MN.  
\- Added entries to /etc/profile so this is set up for all users. Right now points to Linux mn. Will need to switch to point to AIX mn when we switch modes on the cluster.  
\- Also, users shouuld check their PATH and MANPATH for xCAT directories. These are set in /etc/profile, but many users override these settings in their private .profile files.  
Run nodels and xdsh &lt;some compute node&gt; date to verify the setup.  
\- Also run 'xdsh &lt;node&gt; -l root date' to verify root xdsh access. 
