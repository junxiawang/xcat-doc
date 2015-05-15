<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Install the Management Node OS**](#install-the-management-node-os)
- [**Supported OS and Hardware**](#supported-os-and-hardware)
- [**\[RH\] Ensure that SELinux is Disabled**](#%5Crh%5C-ensure-that-selinux-is-disabled)
- [**Disable the Firewall**](#disable-the-firewall)
- [**Set Up the Networks**](#set-up-the-networks)
- [**Configure NICS**](#configure-nics)
- [**Prevent DHCP client from overwriting DNS configuration (Optional)**](#prevent-dhcp-client-from-overwriting-dns-configuration-optional)
- [**Configure hostname**](#configure-hostname)
- [**Setup basic hosts file**](#setup-basic-hosts-file)
- [**Setup the TimeZone**](#setup-the-timezone)
- [**Create a Separate File system for /install (optional)**](#create-a-separate-file-system-for-install-optional)
- [**Restart Management Node**](#restart-management-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These steps prepare the Management Node for xCAT Installation.



### **Install the Management Node OS**

Install one of the supported distros on the Management Node (MN). It is recommended to ensure that dhcp, bind (not bind-chroot), httpd, nfs-utils, and perl-XML-Parser are installed.  (But if not, the process of installing the xCAT software later will pull them in, assuming you follow the steps to make the distro RPMs available.)

Hardware requirements for your xCAT management node are dependent on your cluster size and configuration. A minimum requirement for an xCAT Management Node or Service Node that is dedicated to running xCAT to install a small cluster ( < 16 nodes) should have 4-6 Gigabytes of memory. A medium size cluster, 6-8 Gigabytes of memory; and a large cluster, 16 Gigabytes or more. Keeping swapping to a minimum should be a goal.

### **Supported OS and Hardware**
For a list of supported OS and Hardware, refer to  [XCAT_Features](XCAT_Features).

### **\[RH\] Ensure that SELinux is Disabled**

To disable SELinux manually:

~~~~
 echo 0 > /selinux/enforce
 sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
~~~~

### **Disable the Firewall**

Note: you can skip this step in xCAT 2.8 and above, because xCAT does it automatically when it is installed.

The management node provides many services to the cluster nodes, but the firewall on the management node can interfere with this. If your cluster is on a secure network, the easiest thing to do is to disable the firewall on the Management Mode:

For RH:

~~~~
 service iptables stop
 chkconfig iptables off

~~~~
 
For SLES:

~~~~
 SuSEfirewall2 stop
~~~~

If disabling the firewall completely isn't an option, configure iptables to allow the ports described in [XCAT_Port_Usage](xCAT_Port_Usage).

### **Set Up the Networks**

The xCAT installation process will scan and populate certain settings from the running configuration. Having the networks configured ahead of time will aid in correct configuration. (After installation of xCAT, all the networks in the cluster must be defined in the xCAT networks table before starting to install cluster nodes.)  When xCAT is installed on the Management Node, it will automatically run makenetworks to create an entry in the networks table for each of the networks the management node is on. Additional network configurations can be added to the xCAT networks table manually later if needed. 

The networks that are typically used in a cluster are:

* Management network - used by the management node to install and manage the OS of the nodes.  The MN and in-band NIC of the nodes are connected to this network.  If you have a large cluster with service nodes, sometimes this network is segregated into separate VLANs for each service node.  See [Setting Up a Linux Hierarchical Cluster](Setting_Up_a_Linux_Hierarchical_Cluster) for details.
* Service network -  used by the management node to control the nodes out of band via the hardware control point, e.g. BMC or HMC.  If the BMCs are configured in shared mode, then this network can be combined with the management network.
* Application network - used by the HPC applications on the compute nodes.  Usually an IB network.
* Site (Public) network - used to access the management node and sometimes for the compute nodes to provide services to the site.

In our example, we only focus on the management network:

* The service network usually does not need special configuration, just the management node and service nodes need to communicate with the hardware control points through service network. In system x cluster, if the BMCs are in shared mode, so they don't need a separate service network.
* we are not showing how to have xCAT automatically configure the application network NICs.  See [Configuring_Secondary_Adapters](Configuring_Secondary_Adapters) if you are interested in that.
* under normal circumstances there is no need to put the site network in the networks table


For a sample Networks Setup, see the following example: [Setting_Up_a_Linux_xCAT_Mgmt_Node#Appendix_A:_Network_Table_Setup_Example](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-a-network-table-setup-example)

### **Configure NICS**

Configure the cluster facing NIC(s) on the management node.
For example edit the following files:

~~~~
On RH: /etc/sysconfig/network-scripts/ifcfg-eth1
On SLES: /etc/sysconfig/network/ifcfg-eth1

 DEVICE=eth1
 ONBOOT=yes
 BOOTPROTO=static
 IPADDR=172.20.0.1
 NETMASK=255.240.0.0
~~~~

### **Prevent DHCP client from overwriting DNS configuration (Optional)**

If the public facing NIC on your management node is configured by DHCP, you may want to set '''PEERDNS=no''' in the NIC's config file to prevent the dhclient from rewriting /etc/resolv.conf.  This would be important if you will be configuring DNS on the management node (via makedns - covered later in this doc) and want the management node itself to use that DNS.  In this case, set '''PEERDNS=no''' in each /etc/sysconfig/network-scripts/ifcfg-* file that has '''BOOTPROTO=dhcp'''.

On the other hand, if you '''want''' dhclient to configure /etc/resolv.conf on your management node, then don't set PEERDNS=no in the NIC config files.

### **Configure hostname**

The xCAT management node hostname should be configured before installing xCAT on the management node. The hostname or its resolvable ip address will be used as the default master name in the xCAT site table, when installed. This name needs to be the one that will resolve to the cluster-facing NIC. Short hostnames (no domain) are the norm for the management node and all cluster nodes.  Node names should never end in  "-enx"  for any x. 

To set the hostname, edit /etc/sysconfig/network to contain, for example:

~~~~
 HOSTNAME=mgt
~~~~

If you run hostname command, if should return the same:

~~~~
 # hostname
 mgt
~~~~

### **Setup basic hosts file**
Ensure that at least the management node is in /etc/hosts:

~~~~
 127.0.0.1               localhost.localdomain localhost
 ::1                     localhost6.localdomain6 localhost6
 ###
 172.20.0.1 mgt mgt.cluster
~~~~

### **Setup the TimeZone**

When using the management node to install compute nodes, the timezone configuration on the management node will be inherited by the compute nodes. So it is recommended to setup the correct timezone on the management node.  To do this on RHEL, see http://www.redhat.com/advice/tips/timezone.html.  The process is similar, but not identical, for SLES.  (Just google it.)

You can also optionally set up the MN as an NTP for the cluster.  See [Setting_up_NTP_in_xCAT](Setting_up_NTP_in_xCAT).


### **Create a Separate File system for /install (optional)**

It is not required, but recommended, that you create a separate file system for the /install directory on the Management Node. The size should be at least 30 meg to hold to allow space for several install images.

### **Restart Management Node**

Note: in xCAT 2.8 and above, you do not need to restart the management node.  Simply restart the cluster-facing NIC, for example:  ifdown eth1; ifup eth1

For xCAT 2.7 and below, though it is possible to restart the correct services for all settings, the simplest step would be to reboot the Management Node at this point.