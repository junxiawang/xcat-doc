<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Install xCAT on Management Node](#install-xcat-on-management-node)
  - [Hardware discovery for P8 LE machines](#hardware-discovery-for-p8-le-machines)
    - [Configure xCAT](#configure-xcat)
      - [configure network table](#configure-network-table)
- [makenetworks](#makenetworks)
- [tabdump networks](#tabdump-networks)
- [netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable](#netnamenetmaskmgtifnamegatewaydhcpservertftpservernameserversntpserverslogserversdynamicrangestaticrangestaticrangeincrementnodehostnameddnsdomainvlaniddomaincommentsdisable)
      - [setup DHCP](#setup-dhcp)
- [chdef -t site dhcpinterfaces=eth1,eth2](#chdef--t-site-dhcpinterfaceseth1eth2)
- [makedhcp -n](#makedhcp--n)
- [makedhcp -a](#makedhcp--a)
      - [setup DNS](#setup-dns)
- [chdef –t site forwarders=1.2.3.4,1.2.5.6](#chdef-%E2%80%93t-site-forwarders12341256)
- [makedns -n](#makedns--n)
      - [config passwd table](#config-passwd-table)
      - [Check the genesis pkg:](#check-the-genesis-pkg)
- [rpm -aq | grep genesis](#rpm--aq-%7C-grep-genesis)
- [dpkg -l | grep genesis](#dpkg--l-%7C-grep-genesis)
- [mknb ppc64](#mknb-ppc64)
    - [Predefine node](#predefine-node)
      - [Declare a dynamic range of addresses for discovery](#declare-a-dynamic-range-of-addresses-for-discovery)
- [chdef -t network 10_1_0_0-255_255_0_0 dynamicrange="10.1.100.1-10.1.100.100"](#chdef--t-network-10_1_0_0-255_255_0_0-dynamicrange1011001-101100100)
- [chdef -t network 10_2_0_0-255_255_0_0 dynamicrange="10.2.100.1-10.2.100.100"](#chdef--t-network-10_2_0_0-255_255_0_0-dynamicrange1021001-102100100)
- [makedhcp -n](#makedhcp--n-1)
- [makedhcp -a](#makedhcp--a-1)
      - [Predefine node for discovering](#predefine-node-for-discovering)
- [nodeadd node[001-100] groups=pkvm,all](#nodeadd-node001-100-groupspkvmall)
- [chdef node001 mgt=ipmi cons=ipmi ip=10.1.101.1 bmc=10.2.101.1 netboot=petitboot bmcpassword=abc123 installnic=mac primarynic=mac](#chdef-node001-mgtipmi-consipmi-ip1011011-bmc1021011-netbootpetitboot-bmcpasswordabc123-installnicmac-primarynicmac)
- [chdef node001 mtm=8247-22L serial=10112CA](#chdef-node001-mtm8247-22l-serial10112ca)
      - [Setup /etc/hosts and DNS](#setup-etchosts-and-dns)
- [makehosts pkvm](#makehosts-pkvm)
- [makedns -n](#makedns--n-1)
- [makedns -a](#makedns--a)
      - [Configure conserver](#configure-conserver)
- [makeconservercf](#makeconservercf)
- [service conserver stop](#service-conserver-stop)
- [service conserver start](#service-conserver-start)
    - [Discover node](#discover-node)
      - [discovery FSP/BMCs](#discovery-fspbmcs)
- [lsslp –s PBMC -w](#lsslp-%E2%80%93s-pbmc--w)
- [lsdef Server-8247-22L-SN01112CA](#lsdef-server-8247-22l-sn01112ca)
- [chdef Server-8247-22L-SN01112CA bmcpassword=<your_password>](#chdef-server-8247-22l-sn01112ca-bmcpasswordyour_password)
      - [power on the hosts](#power-on-the-hosts)
- [rpower pbmc on](#rpower-pbmc-on)
      - [discover the nodes](#discover-the-nodes)
- [chdef pbmc cons=ipmi](#chdef-pbmc-consipmi)
- [makeconsercf](#makeconsercf)
- [rcons Server-8247-22L-SN01112CA](#rcons-server-8247-22l-sn01112ca)
- [lsdef node001](#lsdef-node001)
  - [Firmware updating for P8 LE machine](#firmware-updating-for-p8-le-machine)
  - [Provisioning OS for powerKVM and VMs](#provisioning-os-for-powerkvm-and-vms)
    - [Provisioning PowerKVM for p8 LE machine](#provisioning-powerkvm-for-p8-le-machine)
      - [create the osimage object](#create-the-osimage-object)
      - [Define the node object](#define-the-node-object)
        - [Option 1: use node object updated by hardware discovery process](#option-1-use-node-object-updated-by-hardware-discovery-process)
        - [Option 2: define the node object and its attribute by yourself](#option-2-define-the-node-object-and-its-attribute-by-yourself)
          - [Define node](#define-node)
          - [Setup dns](#setup-dns)
          - [Check the DNS setup](#check-the-dns-setup)
      - [Prepare the petitboot, console and dhcpd configurations](#prepare-the-petitboot-console-and-dhcpd-configurations)
      - [Reboot the node to start the provisioning process](#reboot-the-node-to-start-the-provisioning-process)
      - [Check bridge setting after installation finished](#check-bridge-setting-after-installation-finished)
- [brctl show](#brctl-show)
      - [Make sure the powerKVM is able to connection Internet](#make-sure-the-powerkvm-is-able-to-connection-internet)
    - [Steps to install ubuntu 14.x LE or SLES 12 LE for powerkvm VM through network](#steps-to-install-ubuntu-14x-le-or-sles-12-le-for-powerkvm-vm-through-network)
      - [Define node "vm1" as a normal vm node:](#define-node-vm1-as-a-normal-vm-node)
      - [create VM](#create-vm)
      - [Define the console attributes for VM](#define-the-console-attributes-for-vm)
      - [Create LE osimage object](#create-le-osimage-object)
      - [Prepare grub2 and dhcpd configurations](#prepare-grub2-and-dhcpd-configurations)
      - [Use console to monitor the installing process](#use-console-to-monitor-the-installing-process)
  - [Provisioning Ubuntu 14.x for powerNV](#provisioning-ubuntu-14x-for-powernv)
    - [Create ubuntu LE osimage object](#create-ubuntu-le-osimage-object)
    - [Define the powerNV object](#define-the-powernv-object)
      - [Option 1: use node object updated by hardware discovery process](#option-1-use-node-object-updated-by-hardware-discovery-process-1)
      - [Option 2: define the node object and its attribute by yourself](#option-2-define-the-node-object-and-its-attribute-by-yourself-1)
        - [Define node](#define-node-1)
        - [Setup dns](#setup-dns-1)
        - [Check the DNS setup](#check-the-dns-setup-1)
    - [Prepare the petitboot, console and dhcpd configurations](#prepare-the-petitboot-console-and-dhcpd-configurations-1)
    - [Configure node boot from network](#configure-node-boot-from-network)
    - [Reboot the node to start the provisioning process](#reboot-the-node-to-start-the-provisioning-process-1)
  - [Energy Management](#energy-management)
  - [Appendix A: Installing other packages with Ubuntu official mirror](#appendix-a-installing-other-packages-with-ubuntu-official-mirror)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Install xCAT on Management Node

For xCAT installing on Rh or sles, pls reference https://sourceforge.net/p/xcat/wiki/XCAT_iDataPlex_Cluster_Quick_Start/#prepare-the-management-node-for-xcat-installation
For xCAT installing on ubuntu, pls reference https://sourceforge.net/p/xcat/wiki/Ubuntu_Quick_Start/#install-xcat

## Hardware discovery for P8 LE machines

Hardware discovery is used to configure the FSP/BMC and get the hardware configuration information for the physical machine. In this document, we use the following configuration as the example:

machine type/model: 8247-22L
serial: 10112CA
ip address for host: 10.1.101.1
ip address for FSP/BMC:10.2.101.1
password for FSP/BMC: abc123
the dynamic range for service network(used for hosts): 10.1.100.1-10.1.100.100
the dynamic range for management network(used for FSP/BMCs): 10.2.100.1-10.2.100.100
the nic information on MN for service network: eth1, 10.1.1.1/16
the nic information on MN for management network: eth2, 10.2.1.1/16

Note: the management Node need NICs both for management network and service network. 
 
The hardware discovery process will be: 
### Configure xCAT
#### configure network table
Normally, there will be at least two entries for the two subnet on MN in "networks" table after xCAT is installed. If not, pls run the following command to add networks in "networks" table.

~~~~
#makenetworks
~~~~

To check the networks, use:

~~~~
# tabdump networks
#netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
"10_1_0_0-255_255_0_0","10.1.0.0","255.255.0.0","eth1","<xcatmaster>",,"10.1.1.1",,,,,,,,,,,,
"10_2_0_0-255_255_0_0","10.2.0.0","255.255.0.0","eth2","<xcatmaster>",,"10.2.1.1",,,,,,,,,,,,
~~~~

#### setup DHCP

Set the correct NIC from which DHCP server provide service:

~~~~
#chdef -t site dhcpinterfaces=eth1,eth2
~~~~

Update DHCP configuration file:

~~~~
#makedhcp -n
#makedhcp -a
~~~~

#### setup DNS
To get the hostname/IP pairs copied from /etc/hosts to the DNS on the MN:
* Ensure that /etc/sysconfig/named does not have ROOTDIR set
* Set site.forwarders to your site-wide DNS servers that can resolve site or public hostnames. The DNS on the MN will forward any requests it can’t answer to these servers.
~~~~
#chdef –t site forwarders=1.2.3.4,1.2.5.6
~~~~
* Edit /etc/resolv.conf to point the MN to its own DNS. (Note: this won't be required in xCAT 2.8 and above.)
~~~~
search cluster
nameserver 10.1.1.1
~~~~
* Run makedns
~~~~
#makedns -n
~~~~

#### config passwd table
To configure default password for FSP/BMCs

~~~~
*#tabedit passwd
*#key,username,password,cryptmethod,authdomain,comments,disable
"system","root","cluster",,,,
"ipmi",,"PASSW0RD",,,,
~~~~

Note: At present, no username is supported for FSP through IPMI
#### Check the genesis pkg:
Genesis pkg can be used to creates a network boot root image, it must be installed before do hardware discovery:
    *[RH]
~~~~
#rpm -aq | grep genesis
xCAT-genesis-scripts-ppc64-xxxx.noarch
xCAT-genesis-base-ppc64-xxxx.noarch
~~~~
    *[ubuntu]
~~~~
# dpkg -l | grep genesis
ii  xcat-genesis-base-ppc64             2.9-xxxx          all          xCAT Genesis netboot image
ii  xcat-genesis-scripts                2.9-xxxx          ppc64el      xCAT genesis
~~~~

If the two pkgs haven’t installed yet, pls installed them first and then run the following command to create the network boot root image.

~~~~
#mknb ppc64
~~~~

### Predefine node

#### Declare a dynamic range of addresses for discovery
The dynamic range are used for assigning temporary IP adddress for FSP/BMCs and hosts:

~~~~
#chdef -t network 10_1_0_0-255_255_0_0 dynamicrange="10.1.100.1-10.1.100.100"
#chdef -t network 10_2_0_0-255_255_0_0 dynamicrange="10.2.100.1-10.2.100.100"
#makedhcp -n
#makedhcp -a
~~~~

#### Predefine node for discovering
The attributes for predefined node are scheduled by system admin. He shall make a plan that what ip address, bmc address, bmc password... can be used for the specified hosts with specified MTMS. 

~~~~
#nodeadd node[001-100] groups=pkvm,all
#chdef node001 mgt=ipmi cons=ipmi ip=10.1.101.1 bmc=10.2.101.1 netboot=petitboot bmcpassword=abc123 installnic=mac primarynic=mac
#chdef node001 mtm=8247-22L serial=10112CA
~~~~

#### Setup /etc/hosts and DNS
After the node and its IP address are defined, the admin need to create /etc/hosts file from node definition:

~~~~
#makehosts pkvm
~~~~

Add the node/ip mapping into DNS:

~~~~
#makedns -n
#makedns -a
~~~~

#### Configure conserver
The xCAT rcons command uses the conserver package to provide support for multiple read-only consoles on a single node and the console logging.
To add or remove new nodes for conserver support:

~~~~
#makeconservercf
#service conserver stop
#service conserver start
~~~~

### Discover node

#### discovery FSP/BMCs

The FSP/BMCs will automatically powered on once the physical machine is  powered on. Currently, we can use SLP to find all the FSPs for the p8 LE host:

~~~~
#lsslp –s PBMC -w
~~~~

The PBMC node will be like this:

~~~~
# lsdef Server-8247-22L-SN01112CA
Object name: Server-8247-22L-SN01112CA
 bmc=<fsp_ip1>,<fsp_ip2>
 groups=pbmc,all
 hidden=0
 hwtype=pbmc
 mgt=ipmi
 mtm=8247-22L
 nodetype=mp
 postbootscripts=otherpkgs
 postscripts=syslog,remoteshell,syncfiles
 serial=10112CA
~~~~

If you know the special FSP/BMCs doesn't use the default password configured in 'passwd' table, pls use the following command to add special password for the specified PBMC node.

~~~~
#chdef Server-8247-22L-SN01112CA bmcpassword=<your_password>
~~~~

#### power on the hosts
~~~~
#rpower pbmc on
~~~~

#### discover the nodes
After hosts is powered on, the discover process will start automatically. If you'd like to monitor the discovery process, you can use:

~~~~
#chdef pbmc cons=ipmi
#makeconsercf
#rcons Server-8247-22L-SN01112CA
~~~~

After the discovery finished, the hardware information will be updated to the predefined node

~~~~
#lsdef node001
Object name: node001
arch=ppc64
bmc=10.2.101.1
bmcpassword=abc123
cons=ipmi
cpucount=192
cputype=POWER8E (raw), altivec supported
groups=pkvm,all
installnic=mac
ip=10.1.101.1
mac=6c:ae:8b:02:12:50
memory=65118MB
mgt=ipmi
mtm=8247-22L
netboot=petitboot
postbootscripts=otherpkgs
postscripts=syslog,remoteshell,syncfiles
primarynic=mac
serial=10112CA
statustime=10-15-2014 01:54:22
supportedarchs=ppc64
~~~~

## Firmware updating for P8 LE machine

The firmware updating process can be done during discovery or at a later time. The steps are:

1. Download firmware file from Support Portal in IBM webpage(www.ibm.com). The firmware name is like this: 01SVXXX_XXX_XXX.rpm
2. Extract the firmware img file from the rpm file.
    *[RH or SLES]
~~~~
    # rpm -i 01SV810_061_054.rpm --ignoreos
    Then, you will find the image file 01SV810_xxx_xxx.img under /tmp/fwupdate/
~~~~
    *[Ubuntu]
~~~~
    # apt-get install alien
    # alien 0SVXXX_XXX_XXX.rpm                #It will generate a deb pkg like 01sv810xxx.deb
    # dpkg -i 01svXXX_XXX_XXX*.deb
    Then, you will find the image file 01SV810_xxx_xxx.img under /tmp/fwupdate/
~~~~

3. Put it into a tarball:
    * The firmware img file extracted from rpm pkg.
    * a runme.sh script that you create that runs the executable with appropriate flags
    - For example:
        *#cd /install/firmware/
        *#ls -lh
~~~~
total 197M
-rw-r--r-- 1 root root 197M Oct 10 08:10 01SV810_061_054.img
-rwxr-xr-x 1 root root  149 Oct 13 07:36 runme.sh
~~~~    
        *#cat runme.sh
~~~~ 
echo "================Start update"
/bin/update_flash -f ./01SV810_061_054.img
~~~~
        *# chmod +x runme.sh 
         # tar -zcvf firmware-update.tgz .
~~~~
./
./runme.sh
./01SV810_061_054.img
tar: .: file changed as we read it
~~~~

3. start firmware update:
    * Option 1 - update during discovery: 
If you want to update the firmware during the node discovery process, ensure you have already added a dynamic range to the networks table and run "makedhcp -n". Then update the chain table to do both bmcsetup and the firmware update:
~~~~
*#chdef node001 chain="runcmd=bmcsetup,runimage=http://mgmtnode/install/firmware/firmware-update.tgz,shell"
~~~~
    * Option 2 - update after node deployment: 
If you are updating the firmware at a later time (i.e. not during the node discovery process), tell nodeset that you want to do the firmware update, and then set currchain to drop the nodes into a shell when they are done:
~~~~
*#nodeset node001 runimage=http://mgmtnode/install/firmware/firmware-update.tgz,boot
~~~~
    * Option 3 - update with xcat xdsh:
If the machine is up and running, and have OS installed. You can use the following commands to update firmware
~~~~
*#xdcp node001 /tmp/fwupdate/01SV810_061_054.img /tmp/ | xdsh node001 "/usr/sbin/update_flash -f /tmp/01SV810_061_054.img"
~~~~
*#rpower node001 reset

4. commit or reject the updated image after the machine is up and running.

    * To commit
~~~~
*#xdsh node001 "/usr/sbin/update_flash -c"
~~~~

    * To reject
~~~~
*#xdsh node001 "/usr/sbin/update_flash -r"
~~~~

## Provisioning OS for powerKVM and VMs


### Provisioning PowerKVM for p8 LE machine
This is the process for setting up PowerKVM with xCAT

#### create the osimage object

~~~~
 copycds /iso/ibm-powerkvm-2.1.1.0-22.0-ppc64-gold-201410191558.iso
~~~~

Currently, copycds only support PowerKVM Release 2.1.1 Build 22 Gold, for other build, you need to use <-n> option to specify the distroname.

~~~~
 copycds /iso/ibm-powerkvm-2.1.1.0-18.1-ppc64-gold-201410141637.iso -n pkvm2.1.1
~~~~
 
To check the osimage object created by copycds, run the following:
 
~~~~
   lsdef -t osimage
   pkvm2.1.1-ppc64-install-compute (osimage)
~~~~

####Define the node object

##### Option 1: use node object updated by hardware discovery process

The hardware discovery process have updated most of attributes for the specified node, you just need modify the following attributes:

~~~~
   chdef node001 tftpserver=10.1.1.1 conserver=10.1.1.1 nfsserver=10.1.1.1
~~~~

##### Option 2: define the node object and its attribute by yourself

The following steps are needed if you don't have done hardware discovery.
###### Define node 

~~~~
   mkdef node001 groups=all,kvm cons=ipmi mgt=ipmi
   chdef node001 bmc=10.2.101.1 bmcpassword=abc123
   chdef node001 mac=6c:ae:8b:02:12:50 installnic=mac primarynic=mac
   chdef node001 tftpserver=10.1.1.1 conserver=10.1.1.1 nfsserver=10.1.1.1
~~~~
 
Note: The discovery is not supported.  So the mac address must be obtained by user.

######Setup dns
 
define the name domain for this cluster

~~~~
  chdef -t site domain=cluster.com
~~~~


Define IP address for the node

~~~~
  chdef node001 ip=10.1.101.1
  makedns –n
~~~~

Config DNS server, the resolv.conf file will be similar to:
 
~~~~
cat /etc/resolv.conf
domain cluster.com
search cluster.com
nameserver 10.1.1.1
~~~~
 
######Check the DNS setup
 
~~~~
nslookup node001
Server: 10.1.1.1
Address: 10.1.1.1
 
Name: node001.cluster.com
Address: 10.1.101.1
~~~~
 
#### Prepare the petitboot, console and dhcpd configurations

~~~~
  chdef node001 netboot=petitboot
  chdef node001 serialport=0 serialspeed=115200
  makedhcp -n
  makedhcp -a
  nodeset node001 osimage=pkvm2.1.1-ppc64-install-compute
  node001: install pkvm2.1.1-ppc64-compute
  rsetboot node001 net
~~~~
 
#### Reboot the node to start the provisioning process

~~~~
rpower node001 on/reset
~~~~

#### Check bridge setting after installation finished

You can get the bridge information like following after pkvm host installation is done: 

~~~~
# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.000000000000       no              eth0
~~~~

If you don't have that, it probably that you didn't use the xCAT post install script. You can hack it together quickly by running: 

~~~~
    IPADDR=10.1.101.1/16
    brctl addbr br0
    brctl addif br0 eth0
    brctl setfd br0 0
    ip addr add dev br0 $IPADDR
    ip link set br0 up
    ip addr del dev eth0 $IPADDR
~~~~

#### Make sure the powerKVM is able to connection Internet

For installing ubuntu LE through network, the VM need to access Internet when doing installing. So pls make sure the host is able to connection Internet.

### Steps to install ubuntu 14.x LE or SLES 12 LE for powerkvm VM through network


#### Define node "vm1" as a normal vm node:

~~~~

  mkdef vm1 groups=vm,all
  chdef vm1 vmhost=node001
  chdef vm1 tftpserver=10.1.1.1 conserver=10.1.1.1 nfsserver=10.1.1.1
  chdef vm1 ip=x.x.x.x
  makehosts vm1
  makedns -n
  makedns -a
~~~~

#### create VM

~~~~
   chdef vm1 mgt=kvm cons=kvm
   chdef vm1 vmcpus=2 vmmemory=4096 vmnics=br0 vmnicnicmodel=virtio vmstorage=dir:///var/lib/libvirt/images/
   optional:

   chtab node=vm1 vm.vidpassword=abc123  (for monitor the installing process from kimchi)

   mkvm vm1 -s 20G
~~~~

#### Define the console attributes for VM
~~~~
   chdef vm1 serialport=0 serialspeed=115200
~~~~

For more information about modifying VM attributes, pls refer to [Define Virtual Machines attributes](https://sourceforge.net/p/xcat/wiki/XCAT_Virtualization_with_KVM/#define-the-attributes-of-virtual-machine) 

#### Create LE osimage object

   
After you download the latest LE ISO, pls run the following command to create osimage objects.

~~~~
  Ubuntu:
  copycds trusty-server-ppc64el.iso
~~~~

~~~~
  SLES:
  copycds SLE-12-Server-DVD-ppc64le-GM-DVD1.is
~~~~

You can check the /install/<os>/ppc64el directory have been created. And you can find the osimage objects with:

~~~~
   Ubuntu:
   lsdef -t osimage
   ubuntu14.04-ppc64el-install-compute  (osimage)
   ubuntu14.04-ppc64el-install-kvm  (osimage)
   ubuntu14.04-ppc64el-netboot-compute  (osimage)
   ubuntu14.04-ppc64el-statelite-compute  (osimage)
~~~~

~~~~
   SLES:
   lsdef -t osimage
   sles12-ppc64le-install-compute  (osimage)
   sles12-ppc64le-install-iscsi  (osimage)
   sles12-ppc64le-install-xen  (osimage)
   sles12-ppc64le-netboot-compute  (osimage)
   sles12-ppc64le-netboot-service  (osimage)
   sles12-ppc64le-stateful-mgmtnode  (osimage)
   sles12-ppc64le-statelite-compute  (osimage)
   sles12-ppc64le-statelite-service  (osimage)
~~~~

For Ubuntu, in order to boot from network, you need to download the mini.iso from "http://ports.ubuntu.com/ubuntu-ports/dists/$(lsb_release -sc)/main/installer-ppc64el/current/images/netboot/", then mount the mini.iso to a tmp directory. 
For **ubuntu 14.04.2**, pls download the mini.iso from "http://ports.ubuntu.com/ubuntu-ports/dists/trusty-updates/main/installer-ppc64el/current/images/utopic-netboot/".

~~~~
  mkdir /tmp/iso
  mount -o loop mini.iso /tmp/iso
  ls /tmp/iso/install
  initrd.gz  vmlinux
~~~~

Then, copy the file /tmp/iso/install/initrd.gz to /install/<ubuntu-version>/ppc64el/install/netboot.

~~~~
  mkdir -p  /install/<ubuntu-version>/ppc64el/install/netboot
  cp  /tmp/iso/install/initrd.gz  /install/<ubuntu-version>/ppc64el/install/netboot
~~~~

####Prepare grub2 and dhcpd configurations


Make sure the grub2 had been installed on your Management Node:

~~~~
  rpm -aq | grep grub2
  grub2-xcat-1.0-1.noarch
~~~~

Note: If you are working with xCAT-dep oldder than 20141012, the modules for xCAT shipped grub2 can not support ubuntu LE smoothly. So the following steps needed to complete the grub2 setting.

~~~~
  rm /tftpboot/boot/grub2/grub2.ppc
  cp /tftpboot/boot/grub2/powerpc-ieee1275/core.elf /tftpboot/boot/grub2/grub2.ppc
  /bin/cp -rf /tmp/iso/boot/grub/powerpc-ieee1275/elf.mod /tftpboot/boot/grub2/powerpc-ieee1275/
~~~~

Set 'netboot' attribute to 'grub2'

~~~~
  chdef vm1 netboot=grub2
~~~~

Config password for root:

~~~~
chtab key=system passwd.username=root passwd.password=xxxxxx
~~~~

Create grub2 boot configuration file by running nodeset:

~~~~
Ubuntu:
nodeset vm1 osimage=ubuntu14.04-ppc64el-install-compute
~~~~


~~~~
SLES:
nodeset vm1 osimage=sles12-ppc64le-install-compute
~~~~

Send a hard reset to cycle the VM to start OS installation

~~~~
rpower vm1 boot
~~~~

####Use console to monitor the installing process


On the pkvm host, pls make sure firewalld service had been stopped.

~~~~
chkconfig firewalld off
~~~~
 
Note: Forwarding request to systemctl will disable firewalld.service.

~~~~ 
  rm /etc/systemd/system/basic.target.wants/firewalld.service 
  rm /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service
~~~~

Then, run wvid vm1 on MN

~~~~
wvid vm1
~~~~

Besides we could use kimchi to monitor the installing process

~~~~
 Open "https://<pkvm_ip>:8001" to open kimchi
 There will be a “connect” button you can use below "Actions" button and input Password required:abc123 your have just set before mkvm
 Then you could get the console
~~~~

To use the text console
~~~~
makeconservercf
rcons vm1
~~~~

## Provisioning Ubuntu 14.x for powerNV

The steps below are used to provisioning ubuntu LE for powerNV.

###Create ubuntu LE osimage object
~~~~
copycds trusty-server-ppc64el.iso
~~~~

~~~~
lsdef -t osimage
ubuntu14.04-ppc64el-install-compute (osimage)
ubuntu14.04-ppc64el-install-kvm (osimage)
ubuntu14.04-ppc64el-netboot-compute (osimage)
ubuntu14.04-ppc64el-statelite-compute (osimage)
~~~~

And in order to boot from network, you need to download the mini.iso from "http://ports.ubuntu.com/ubuntu-ports/dists/$(lsb_release -sc)/main/installer-ppc64el/current/images/netboot/", then mount the mini.iso to a tmp directory. 
For **ubuntu 14.04.2**, pls download the mini.iso from "http://ports.ubuntu.com/ubuntu-ports/dists/trusty-updates/main/installer-ppc64el/current/images/utopic-netboot/".

~~~~
  mkdir /tmp/iso
  mount -o loop mini.iso /tmp/iso
  ls /tmp/iso/install
  initrd.gz  vmlinux
~~~~
Then, copy the file /tmp/iso/install/initrd.gz to /install/<ubuntu-version>/ppc64el/install/netboot.
~~~~
  mkdir -p  /install/<ubuntu-version>/ppc64el/install/netboot
  cp  /tmp/iso/install/initrd.gz  /install/<ubuntu-version>/ppc64/installel/netboot
~~~~


###Define the powerNV object

#### Option 1: use node object updated by hardware discovery process

The hardware discovery process have updated most of attributes for the specified node, you just need modify the following attributes:
~~~~
   chdef node001 tftpserver=10.1.1.1 conserver=10.1.1.1 nfsserver=10.1.1.1
~~~~

#### Option 2: define the node object and its attribute by yourself

The following steps are needed if you don't have done hardware discovery.
##### Define node 
~~~~
   mkdef node001 groups=all,kvm cons=ipmi mgt=ipmi
   chdef node001 bmc=10.2.101.1 bmcpassword=abc123
   chdef node001 mac=6c:ae:8b:02:12:50 installnic=mac primarynic=mac
   chdef node001 tftpserver=10.1.1.1 conserver=10.1.1.1 nfsserver=10.1.1.1
~~~~
 
Note: The discovery is not supported.  So the mac address must be obtained by user.

#####Setup dns
 
define the name domain for this cluster

~~~~
  chdef -t site domain=cluster.com
~~~~


Define IP address for the node

~~~~
  chdef node001 ip=10.1.101.1
  makedns –n
~~~~

Config DNS server, the resolv.conf file will be similar to:
 
~~~~
cat /etc/resolv.conf
domain cluster.com
search cluster.com
nameserver 10.1.1.1
~~~~
 
#####Check the DNS setup
 
~~~~
nslookup node001
Server: 10.1.1.1
Address: 10.1.1.1
 
Name: node001.cluster.com
Address: 10.1.101.1
~~~~

### Prepare the petitboot, console and dhcpd configurations
~~~~
chdef node001 serialport=0 serialspeed=115200
nodeset node001 osimage=ubuntu14.04-ppc64el-install-compute
node001: install ubuntu14.04-ppc64el-compute
~~~~

### Configure node boot from network
~~~~
rsetboot node001 net
~~~~

###Reboot the node to start the provisioning process
~~~~
rpower node001 on/reset
~~~~

## Energy Management

IBM Power Servers support the Energy management capabilities like to query and monitor the 

* Power Saving Status
* Power Capping Status
* Power Consumption
* CPU Frequency
* Ambient temperature
* Fan Speed
*  ... 

and to set the 

* Power Saving
* Power Capping
* CPU frequency

xCAT offers the command 'renergy' to manipulate the Energy related features for Power Server. Refer to the man page of [renergy](http://xcat.sourceforge.net/man1/renergy.1.html) to get the detail of usage.


## Appendix A: Installing other packages with Ubuntu official mirror

[Installing_other_packages_with_Ubuntu_official_mirror](Installing_other_packages_with_Ubuntu_official_mirror)