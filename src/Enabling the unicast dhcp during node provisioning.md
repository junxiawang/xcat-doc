Enabling the unicast dhcp during node provisioning
==================================================

**Overview:**

The whole process of node deployment with xCAT usually involves several times of DHCP(BOOTP): 
1.On the network devices activation, fetching the network information and the pxe/uefi/grub2/yaboot related binaries and configuration files
2.Loading the linux kernel and initrd to start installation , request network information, i.e. IP address, network mask,gateway,hostname and nameserver
3.On the 1st reboot after installation, request the network information of the installed system on the network device activation.  
Sometimes the 2nd and 3rd DHCP need to be elininated to avoid DHCP broadcast, for example, consider the scenario that the management node/service node and the node to be deployed are in the different subnet.
From the xCAT 2.8.5 release, a site attribute “site.managedaddressmode” is introduced as the switch to enable the unicast dhcp during node deployment. It can be enabled by setting the attribute “static”. Currently, this feature is only supported in Redhat and Sles provisioning.

**Usage:**
1.Setting all the network related node attributes and network table correctly, the following attributes should be specified:

(1)node attributes:
ip,mac,xcatmaster
(2)network table:
netname,net,mask,mgtifname,gateway,nameservers,domain
(3)site table:
domain,nameservers

*Note:* The "nameservers" and "domain" values defined in networks take precedence over the values in site table


2.Change the “site.managedaddressmode” to “static”

3.Run “nodeset” 

**Example:**

~~~~

[root@service-02 ~]# lsdef service-07
Object name: service-07
...
ip=9.114.34.52
mac=00:21:5e:a6:3d:d7
xcatmaster=9.114.34.46
...
[root@service-02 ~]# tabdump networks                            
#netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
"9_114_34_0","9.114.34.0","255.255.255.0","eth3","9.114.34.254",,"9.114.34.46",,,,,,,,,,,,
[root@service-02 ~]# tabdump site
#key,value,comments,disable
"domain","clusters.com",,
"nameservers","9.114.34.46",,
"managedaddressmode","static",,

[root@service-02 ~]# nodeset service-07 osimage=rhels6.4-ppc64-install-compute        
service-07: install rhels6.4-ppc64-compute
[root@service-02 ~]# lsdef service-07 -i kcmdline                                   
Object name: service-07
    kcmdline=quiet repo=http://9.114.34.46:80/install/rhels6.4/ppc64 ks=http://9.114.34.46:80/install/autoinst/service-07 ksdevice=00:21:5e:a6:3d:d7  ip=9.114.34.52 netmask=255.255.255.0 gateway=9.114.34.254  hostname=service-07  dns=9.114.34.46
[root@service-02 ~]# 

[root@service-02 ~]# cat /install/autoinst/service-07 |more
....
network --onboot=yes --bootproto=static  --device=00:21:5e:a6:3d:d7 --ip=9.114.34.52 --netmask=255.255.255.0 --g
ateway=9.114.34.254 --hostname=service-07  --nameserver=9.114.34.46
....

~~~~
  