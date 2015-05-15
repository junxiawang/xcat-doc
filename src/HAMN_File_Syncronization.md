<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Node Deployment Packages**](#node-deployment-packages)
- [**Network Services Configuration Files**](#network-services-configuration-files)
- [**Additional Customization Files and Production files**](#additional-customization-files-and-production-files)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### **Node Deployment Packages**

The node deployment packages are under the directory specified by the "installdir" attribute in the xCAT site table. The default location is /install directory. The node deployment packages need to be synchronized to the standby management node. 

For Linux, it will be easy to achieve this by copying the whole /install directory from the primary management node to the standby management node. However, copying the whole /install directory is not enough for AIX; we will have to create the NIM resources on the standby management node. Some manual steps are required to create the NIM resources on the backup management node. 

  
Here is an example of the crontab entries for synchronizing the node deployment packages: 
    
    0 2 * * * /usr/bin/rsync -Lprogtz /install aixmn2:/
    

  
If you do not want to do the manual steps on the standby management node to re-create the NIM resources, the AIX feature High Availability Network Installation Manager(HANIM) can be used for keeping the NIM resources synchronized between the primary management node and standby management node. Please refer to the AIX redbook "NIM from A to Z in AIX 5L" at http://www.redbooks.ibm.com/redbooks/pdfs/sg247296.pdf for more details about HANIM. 

### **Network Services Configuration Files**

A lot of network services are configured on the management node, such as DNS, DHCP and HTTP. The network services are mainly controlled by configuration files. However, some of the network services configuration files contain the local hostname/ipaddresses related information, so simply copying these network services configuration files to the standby management node may not work. Generating these network services configuration files is very easy and quick by running xCAT commands such as makedhcp, makedns or nimnodeset, as long as the xCAT database contains the correct information. 

While it is easier to configure the network services on the standby management node by running xCAT commands when failing over to the standby management node, a couple of exceptions are the /etc/hosts and /etc/resolve files; the /etc/hosts and /etc/resolv.conf may be modified on your primary management node as ongoing cluster maintenance occurs. Since the /etc/hosts and /etc/resolv.conf are very important for xCAT commands, the /etc/hosts and /etc/resolv.conf will be synchronized between the primary management node and standby management node. Here is an example of the crontab entries for synchronizing the /etc/hosts and /etc/resolv.conf: 

  

    
    0 2 * * * /usr/bin/rsync -Lprogtz /etc/hosts /etc/resolv.conf aixmn2:/etc/
    

### **Additional Customization Files and Production files**

Besides the files mentioned above, there may be some additional customization files and production files that need to be copied over to the standby management node, depending on your local unique requirements. You should always try to keep the standby management node as an identical clone of the primary management node. Here are some example files that can be considered: 
    
    /.profile
    /.rhosts
    /etc/auto_master
    /etc/auto/maps/auto.u
    /etc/motd
    /etc/security/limits
    /etc/resolv.conf
    /etc/netscvc.conf
    /etc/ntp.conf
    /etc/inetd.conf
    /etc/passwd
    /etc/security/passwd
    /etc/group
    /etc/security/group
    /etc/exports
    /etc/dhcpsd.cnf
    /etc/sevices
    /etc/inittab
    (and more)
    

  
Note: if the IBM HPC software stack is configured in your environment, please refer to the xCAT wiki page [IBM_HPC_Stack_in_an_xCAT_Cluster] for additional steps required for HAMN setup. 
