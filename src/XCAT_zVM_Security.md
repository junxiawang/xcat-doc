<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Document Abstract](#document-abstract)
- [User Access Control](#user-access-control)
- [No Root Login](#no-root-login)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 

## Document Abstract

This document provides a guide to security for xCAT on z/VM and Linux on System z. For technical support, please post your question(s) on the [mailing-list](https://lists.sourceforge.net/lists/listinfo/xcat-user). 

## User Access Control

This section provides details on how to add users to xCAT and limit the scope of their usage. 

  
In order to add a user to xCAT, you must modify two xCAT tables: policy and passwd. Below are the instructions on how to modify these tables. 

  1. Create an entry for the new user in the policy table. 
        
        
        # chtab priority=6.1 policy.name=joe policy.rule=allow
        

The policy table controls which commands a user can run and which nodes the user can access. There is a unique priority number for each user. You must verify that the priority number you have chosen is not in use by viewing the existing policies in the policy table (`tabdump policy`). In the example above, a user named joe is added with a priority number of 6.1. 

  2. By default, a user is allowed to run all xCAT commands. To restrict a user to a specific set of commands, the policy.commands attribute must be modified to contain the specific set of commands. A complete list of xCAT commands can be found at [this link](http://xcat.sourceforge.net/man1/xcat.1.html). 
        
        
        # chtab priority=6.1 policy.commands="rpower,mkvm,rmvm,lsvm,chvm,mkdef,lsdef,rscan,rinv,nodeadd"
        

Multiple commands can be specified. Each command has to be separated by a comma. Be sure to use the correct priority number when setting the commands. Otherwise, you might be overriding the policy of another user. 

  3. xCAT encrypts its password using MD5 hashes. To generate an MD5 hashed password, you can use the Perl crypt routine. 
        
        
        # perl -e "print crypt('rootpw', rand(12345678))"
        48aVyK0x4vqCc
        

The password being encrypted is rootpw. It uses the Perl crypt routine with a random number between 0 and 12345678 as a seed. 

  4. Create an entry for the new user in the passwd table using the encrypted password created above 
        
        
        # chtab username=joe passwd.key=xcat passwd.password=48aVyK0x4vqCc
        

More information can be found on granting xCAT user privileges by going to [this link](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Granting_Users_xCAT_privileges). 

## No Root Login

This section provides details on how to setup a non-root login for xCAT and virtual machines provisioned by xCAT. 

  
In some environments, system administrators cannot use root to access and manage their systems. The following setup provides an alternative way (via a sudoer) to access and manage systems. 

  1. Create a non-root user (xcat) on the xCAT MN. 
        
        
        # /usr/sbin/userdel xcat
        # /usr/sbin/useradd -p rootpw -m xCAT
        

  2. Add the user to the sudoers list. 
        
        
        # echo "xcat ALL=(ALL) NOPASSWD: ALL" &gt;&gt; /etc/sudoers
        

The sudoer can be customized to run only a small set of commands. In this example, 

    * xcat - User name
    * ALL= - From any Host/IP
    * (ALL) - Can run as any user
    * NOPASSWD: - No password required
    * ALL - All commands accepted

If you are running RHEL, an extra line must be added in the sudoers file. 
        
        
        # echo "Defaults:xcat !requiretty" &gt;&gt; /etc/sudoers
        

  3. xCAT runs as root, but users can log into xCAT as a sudoer. Once a sudoer is created, add the sudoer to the xCAT policy and passwd tables. 
        
        
        # chtab priority=1.3 policy.name=xcat policy.rule=allow policy.comments="privilege:root;"
        # perl -e "print crypt('rootpw', rand(12345678))"
        48aVyK0x4vqCc
        
        # chtab username=xcat passwd.key=xcat passwd.password=48aVyK0x4vqCc
        

In order for the sudoer (xcat) to access the xCAT UI, you must add "privilege:root;" into the policy.comments. 

  4. To manage other virtual machines (including the zHCP) via a sudoer, you have to create a non-root user (xcat) on each virtual machine and add the sudoer to the sudoers list (as above). There is a script on the xCAT MN, /install/postscripts/sudoer, that can be run to create the sudoer. 
        
        
        updatenode zhcp -P sudoer
        

In order for updatenode to run the postscript, the public SSH key (id_rsa.pub) must already be setup on the target virtual machine. The postscript create a sudoer with a user name of _xcat_ and a password of _rootpw_. The username and password contained in the sudoer script can be modified to suit your needs. 

  5. To create a sudoer for any newly provisioned virtual machine, you have to add the sudoers postscript to the postscripts table. The postscript will run after the Linux installation is completed. 
        
        
        # chtab node=all postscripts.postscripts+=sudoer
        

In the example above, the sudoer postscript will be run for any node in the group _all_. 

  6. Add an entry into the xCAT passwd table to force xCAT to access and manage virtual machines by the sudoer, instead of using root. 
        
        
        chtab username=xcat passwd.key=sudoer
        

If as entry is found in the passwd table (where key = sudoer), then xCAT will use the username when accessing any virtual machine. 

  7. By the end of this setup, you should have the following entries in the password, policy, and postscripts table. 
        
        
        # tabdump policy
        #priority,name,host,commands,noderange,parameters,time,rule,comments,disable
        "1","root",,,,,,"allow",,
        "1.2","ihost1",,,,,,"trusted",,
        "1.3","xcat",,,,,,"allow",,
        
        # tabdump passwd
        #key,username,password,cryptmethod,comments,disable
        "xcat","root","12JtAcMN8jn8k",,,
        "xcat","xcat","12JtAcMN8jn8k",,,
        "sudoer","xcat",,,,
        
        # tabdump postscripts
        #node,postscripts,postbootscripts,comments,disable
        "xcatdefaults","syslog,remoteshell,syncfiles,sudoer","setuprepo,otherpkgs",,
        "all","setuprepo,otherpkgs,sudoer",,,
        
