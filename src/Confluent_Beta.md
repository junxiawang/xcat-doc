<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Trying out the confluent beta in RedHat 6:](#trying-out-the-confluent-beta-in-redhat-6)
  - [Using the web interface:](#using-the-web-interface)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Trying out the confluent beta in RedHat 6:
==============================
1.  Select a server with access to the BMC IP addresses (does not need to be any particular existing system or can be xCAT node)
+  Install all rpms from https://sourceforge.net/projects/xcat/files/confluent_dep/rhels6/
+  Install all rpms from https://sourceforge.net/projects/xcat/files/confluent/
+  service conserver stop
+  service confluent start
+  service httpd restart (or start depending on the circumstance)
+  Example to create a group to reflect the fact that you use node1-bmc to manage node1 (adjust according to your scheme)
> /opt/confluent/bin/confetty create /nodegroups/mygroup secret.hardwaremanagementpassword=YOURPASSWORDHERE secret.hardwaremanagementuser=USERID hardwaremanagement.manager={nodename}-bmc

+  Define nodes to confluent:
>	for node in `nodels noderange`; do # or just paste in the list of nodes to loop through
>        /opt/confluent/bin/confetty create /nodes/$node groups=mygroup
>	done
	
* Test it out (should behave like 'rcons'):
>	/opt/confluent/bin/confetty start /nodes/node1/console/session
	
*  Enabling user(s) for web or TLS, select one of two ways:
    * PAM:
    ---------------------
    If there is a pam configuration for 'confluent', it will be used.  Any user passing that module
    will be granted full access.  This is subject to change in an update.  For example, to granted
    any user that has ssh access confluent access:
    > cp /etc/pam.d/sshd /etc/pam.d/confluent

    At that point any ssh-able account can get console access to any managed node

    * Independent user database:
    ---------------
    Do not bother with this method if using pam instead.
    If no pam service 'confluent' exists, then the independent user database will be used.  To create a user:
    > /opt/confluent/bin/confetty create /users/usernamehere password=passwordhere

			
Using the web interface:
--------------------
  Go to: https://confluentserver/confluent/consoles.html
  http without ssl can also of course work but understand that sensitive data would be in the clear including passwords.
  https set up in the typical way of setting up https would suffice.
