<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [On AIX 71B:](#on-aix-71b)
- [&lt;xCAT data object stanza file&gt;](#&ltxcat-data-object-stanza-file&gt)
- [&lt;xCAT data object stanza file&gt;](#&ltxcat-data-object-stanza-file&gt-1)
- [On RHEL6:](#on-rhel6)
  - [Preparation:](#preparation)
  - [Steps:](#steps)
- [&lt;xCAT data object stanza file&gt;](#&ltxcat-data-object-stanza-file&gt-2)
- [tabdump site | grep dhcp](#tabdump-site-%7C-grep-dhcp)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This guide describes the initial iteration of the xCAT support for booting AIX and Linux diskless node over an HFI network. 

  



# On AIX 71B:

1\. Install xCAT and DB2 on AIX management node. 

  
1). Install and configure an xCAT management node. See the following xCAT document for details: 

[XCAT_AIX_Cluster_Overview_and_Mgmt_Node] 

  
2)HPC requires a Hierarchical cluster, the DB2 database and the HPC software, refer to the following document. [Setting_Up_an_AIX_Hierarchical_Cluster] 

  
3)To setup the hardware and create the hardware connections between management node and BPA/FSPs in PERCS without HMC, please contact IBM to get the latest hardware server, fsp-api builds and instructions. 

  
4). To use HPC software, you need to install additional xCAT package which is not installed by default. The package is distributed in xCAT-core tarball: 

rpm -Uvh xCAT-IBMhpc*.rpm 

  
2\. Download HFI packages 

There are several separate packages required for boot over HFI including NIM server/HFI device driver/xCAT scripts. Contact IBM. 

In this example, we assume all the packages have been downloaded and extracted to /hfi folder on management node. 

  
3\. Update the /etc/hosts file 

The examples in this guide assume the following IP addresses and hostnames. 

10.0.0.208 c250mgrs03-pvt //management node 

10.7.2.5 c250f07c02ap05.ppd.pok.ibm.com c250f07c02ap05 //host name and IP of the ethernet network interface on service node. 

20.7.2.5 c250f07c02ap05-hf0.ppd.pok.ibm.com c250f07c02ap05-hf0 //service node 

21.7.2.5 c250f07c02ap05-hf1.ppd.pok.ibm.com c250f07c02ap05-hf1 //service node 

22.7.2.5 c250f07c02ap05-hf2.ppd.pok.ibm.com c250f07c02ap05-hf2 //service node 

23.7.2.5 c250f07c02ap05-hf3.ppd.pok.ibm.com c250f07c02ap05-hf3 //service node 

20.7.2.9 c250f07c02ap09-hf0.ppd.pok.ibm.com c250f07c02ap09-hf0 //compute node 

21.7.2.9 c250f07c02ap09-hf1.ppd.pok.ibm.com c250f07c02ap09-hf1 //compute node 

22.7.2.9 c250f07c02ap09-hf2.ppd.pok.ibm.com c250f07c02ap09-hf2 //compute node 

23.7.2.9 c250f07c02ap09-hf3.ppd.pok.ibm.com c250f07c02ap09-hf3 //compute node 

Make sure /etc/hosts on Management node contains hostnames for the ethernet interface and the HFI interface for the service node(s). 

  
4\. Define the service node and compute node 

If there is no HMC configured to manage the Power 775 hardwares, you have to define the service nodes and compute nodes manually. If the hardwares are managed by HMC, you can use xCAT command "rscan" to generate the compute node definition. See man page of rscan for more details. 

  
This is an example of service node definition: 

# &lt;xCAT data object stanza file&gt;

c250f07c02ap05: 

objtype=node 

arch=ppc64 

cons=fsp 

groups=all,service //Specify service group indicate this is a service node. 

hcp=f07c02fsp1_a //FSP node definition that managed it. 

id=5 

installnic=en0 

ip=10.7.2.5 

mgt=fsp 

monserver=10.0.0.208 

nfsserver=10.0.0.208 

nodetype=lpar,osi 

os=AIX 

parent=f07c02fsp1_a //Set to Fsp that manage it. 

postbootscripts=servicenode 

pprofile=c250f07c02ap05 

primarynic=en0 

provmethod=1040A_SN 

setupconserver=0 

setupdhcp=1 

setupftp=1 

setupnfs=1 

setuptftp=1 

tftpserver=10.0.0.208 

xcatmaster=10.0.0.208 

  
This is an example of compute nodes definition: 

For example; 

# &lt;xCAT data object stanza file&gt;

c250f07c02ap09-hf0: 

objtype=node 

arch=ppc64 

cons=fsp 

currchain=boot 

currstate=boot 

groups=lpar,all 

hcp=Server-9125-F2C-SNP7IH019-A 

id=9 

ip=10.4.32.224 

mgt=fsp 

nodetype=lpar,osi 

os=AIX 

parent=Server-9458-100-SNBPCF007-A 

pprofile=xcatnode9 

servicenode=c250f07c02ap05 

xcatmaster=c250f07c02ap05-hf0 

  
You can put the definition into one stanza file and import it to xCAT with the mkdef xCAT command. 

cat /percs/hfi/c250f07c02ap09-hf0.stanza | mkdef -z 

  
5\. Install service node(s) and install HFI device drivers and NIM to service node(s). 

  
1). Create NIM image for service node 

mknimimage -s /percs/aiximages/aix/ 1040A_SN 

where /install/aiximages/1040a/aix/ contains the AIX image. 

// If there are existing resource, you can specify the resource type and value as an option of mknimimage so mknimimage will not create same resource type. For example you have copied one lpp_source "1040A_SN_lpp_source" to /install/nim/lpp_source and created NIM lpp source "1040A_SN_lpp_source" then you can just use it to avoiding creating new lpp_source with command: 

mknimimage -s /install/aiximages/1040a/aix/ 1040A_SN lpp_source=1040A_SN_lpp_source spot=1040A_SN -f 

  
2). Add required service node software 

Following steps add the HFI device driver, replace the NIM with new version, and replace the bootpd birnay for HFI support. Please aware that this software is to work with HFI support, there are still other software needed to be installed on service node, please check the following doc: 

[Setting_Up_an_AIX_Hierarchical_Cluster] 

  
3). Update the HFI device driver to lpp source 

inutoc /hfi/dd/ 

nim -o update -a packages=all -a source=/hfi/dd/ 1040A_SN_lpp_source 

  
4). Define HFI device driver installp bundle 

nim -o define -t installp_bundle -a server=master -a location=/hfi/dd/xCATaixHFIdd.bnd xCATaixHFIdd 

  
5). Assign HFI devices drivers isntallp bundle to service node image so they will be installed during service node installation. 

chdef -t osimage -o 1040A_SN installp_bundle=xCATaixHFIdd,xCATaixSN71 

Where installp_bundle should have been defined when installing required service node software. 

  
6). Configure HFI interfaces with postscript 

cp /hfi/scripts/confighfi /install/postscripts/ 

cp /hfi/scripts/confignim /install/postscripts/ 

chdef -t osimage -o 1040A_SN synclists=/hfi/scripts/synclist 

chdef c250f07c02ap05 postscripts=confighfi,confignim 

  
7). If you are using an existing NIM resource including HPC softwares, two steps needs to be done to automatically install and configure the HPC softwares 

a) Create installp bundles which specified what are HPC softwares need to be installed: 

mkdir -p /install/nim/installp_bundle 

cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle 

nim -o define -t installp_bundle -a server=master -a 

location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base 

cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_all.bnd /install/nim/installp_bundle 

nim -o define -t installp_bundle -a server=master -a 

location=/install/nim/installp_bundle/IBMhpc_all.bnd IBMhpc_all 

chdef -t osimage -o 1040A_SN 

installp_bundle="xCATaixHFIdd,xCATaixSN71,IBMhpc_base,IBMhpc_all" 

  
b). Assign the postscripts to service node to configure the HPC softwares automatically. 

cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts 

cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts 

cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts 

cp -p /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts 

cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install /install/postscripts 

cp -p /opt/xcat/share/xcat/IBMhpc/essl/essl_install /install/postscripts 

cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts 

chdef c250f07c02ap05 postscripts=confighfi,confignim,IBMhpc.postbootscript 

  
For more details and steps about HPC integration, please review following page: 

[Setting_up_all_IBM_HPC_products_in_a_Stateful_Cluster] 

  
8). Then follow the Hiearchical setup document starting from "Define xCAT networks" to install service node. 

[Setting_Up_an_AIX_Hierarchical_Cluster] 

  
9). Check if HFI interfaces are up after service node is setup. 

xdsh c250f07c02ap05 ifconfig hf0 

  
6\. Create a diskless image for the compute nodes. 

Create a diskless image: 

mknimimage -V -f -r -t diskless -s /percs/aiximages/aix 1040A_CN 

\- where /install/AIX71GOLD/ contains the AIX 710 GOLD source images. 

  
// Same as diskfull images creation, if there are existing resource, you can specify the resource type and value as an option of mknimimage so mknimimage will not create same resource type. For example, you have copied one lpp_source 1040A_CN_lpp_source to /install/nim/lpp_source, then you can just use it to avoiding creating new lpp_source with command: 

mknimimage -V -f -r -t diskless -s /install/AIX71GOLD/ 1040A_CNlpp_source=1040A_CN_lpp_source spot=1040A_CN 1040A_CN 

  
7\. Update the spot 

Note: Skip this step if you are using the existing image including HFP softwares since all the packages have been updated into the image 

See sections 4.2.1 (Update options) and section 4.2.2 "Adding required software" in the xCAT document "Using xCAT Service Nodes with AIX" to add necessary software to spot: 

[Setting_Up_an_AIX_Hierarchical_Cluster] 

  
8\. Create an xCAT HFI network definition 

Run a command similar to the following: 

mkdef -t network -o hfinet net=20.0.0.0 mask=255.0.0.0 gateway=20.7.2.5 

  
9\. Install HFI device driver into spot 

(Skip this step if you are using the existing image including HFP softwares since all the packages have been updated) 

Install the HFI device driver into the spot on the management node. 

inutoc /hfi/dd/ 

nim -o update -a packages=all -a source=/hfi/dd 1040A_CN_lpp_source 

where: /percs/hfi/dd contains the HFI device driver installp packages. 

chdef -t osimage -o 1040A_CN installp_bundle="xCATaixHFIdd,xCATaixCN71" 

Where xCATaixCN71 should have been defined when add the additional softwares into spot. 

mknimimage -u 1040A_CN 

  
10\. synchronize /etc/hosts to SPOT to bring up all the HFI interfaces on compute nodes 

chdef -t osimage -o 1040A_CN synclists=/hfi/scripts/synclist 

mknimimage -u 1040A_CN 

  
11\. If you are using the existing NIM resource including HPC softwares, you need to assign the postscripts to computes node to configure the HPC softwares automatically.(Optional) 

chdef c250f07c02ap09-hf0 postscripts=IBMhpc.postbootscript 

  
12\. Initialize console for the compute node. 

makeconservercf 

  
13\. Add confighfi postscript to compute node to config HFI interfaces automatically. 

cp /hfi/scripts/confighfi /install/postscripts/ 

chdef c250f07c02ap09-hf0 postscripts=confighfi,IBMhpc.postbootscript 

Notes: remove the IBMhpc.postbootscript if you are not using a diskless image with HPC softwares. 

  
14\. Get the MAC address of the compute node 

getmacs c250f07c02ap09-hf0 -D --hfi 

  
15\. Initialize the AIX/NIM diskless nodes 

mkdsklsnode -i 1040A_CN c250f07c02ap09-hf0 --hfi -f -V 

  
16\. Open remote console 

Open another window, login to the management node (ih1901) and run the following command to watch the installation from the console: 

rcons c250f07c02ap09-hf0 

  
17\. Boot the compute node 

rnetboot c250f07c02ap09-hf0 --hfi 

# On RHEL6:

## Preparation:

1\. We are using following nodes as an example in all the steps: 

MN: c250mgrs04-pvt 

SN: c250f07c04ap01 

CN: c250f07c04ap13 

  
2\. All the steps are running on xCAT management node. For those commands running on server node, we are using xdsh to the service nodes to run the commands parallized. 

  
3\. We assume all the HFI device driver and DHCP server/client packages has been extrated to /hfi directory on xCAT MN. 

  


## Steps:

1\. After installing xCAT, increase the /boot file system size for service node since we need to use a customized kernel on service node, there will be two kernels existing on service nodes, /boot needs more space. 

This is just for workarounds of customized kernel. After the kernel is accepted by Linux community, there will be only one kernel existing on service node, and we don't need to increase the /boot space at that time. 

Change file /opt/xcat/share/xcat/install/rh/service.rhels6.ppc64.tmpl, search the line: 

From: 

part /boot --size 50 --fstype ext4 

To: 

part /boot --size 200 --fstype ext4 

  
2\. Follow the xCAT MN ans SN setup document to setup xCAT MN and install service nodes. xCAT2pLinux.pdf and xCAT2SetupHierarchy.pdf 

  
3\. Install the HFI device drivers on xCAT MN 

rpm -ivh kernel-2.6.32hfi-3.ppc64.rpm 

rpm -ivh --nodeps hfi_util-1.0-0.el6.ppc64.rpm 

rpm -ivh --force net-tools-1.60-102.el6.ppc64.rpm 

  
4\. Configure xCAT SN with HFI device driver and new DHCP server/client 

1) Create folders on service node and copy the HFI driver and DHCP packages to service node: 

xdcp c250f07c04ap01 -R /hfi /hfi 

  
2) Install the HFI device drivers and DHCP server for xCAT SN 

xdsh c250f07c04ap01 rpm -ivh /hfi/dd/kernel-2.6.32hfi-2.ppc64.rpm 

xdsh c250f07c04ap01 rpm -ivh --nodeps /hfi/dd/hfi_util-1.0-0.el6.ppc64.rpm 

xdsh c250f07c04ap01 rpm -ivh --force /hfi/dd/net-tools-1.60-102.el6.ppc64.rpm 

xdsh c250f07c04ap01 /sbin/new-kernel-pkg --mkinitrd --depmod --install 2.6.32hfi 

xdsh c250f07c04ap01 /sbin/new-kernel-pkg --rpmposttrans 2.6.32hfi 

  
3) Create softlink and change yaboot.conf to boot from the customized kernel with HFI support 

xdsh c250f07c04ap01 ln -sf /boot/vmlinuz-2.6.32hfi /boot/vmlinuz 

xdsh c250f07c04ap01 ln -sf /boot/System.map-2.6.32hfi /boot/System.map 

Login to service node, change the "default=" setting to the new label with HFI support, for example: 

  
Change from: 

  
boot=/dev/sda1 

init-message="Welcome to Red Hat Enterprise Linux!\nHit &lt;TAB&gt; for boot options" 

partition=3 

timeout=5 

install=/usr/lib/yaboot/yaboot 

delay=5 

enablecdboot 

enableofboot 

enablenetboot 

nonvram 

fstype=raw 

default=linux 

image=/vmlinuz-2.6.32hfi 

label=2.6.32hfi 

read-only 

initrd=/initrd-2.6.32hfi.img 

append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba" 

image=/vmlinuz-2.6.32-71.el6.ppc64 

label=linux 

read-only 

initrd=/initramfs-2.6.32-71.el6.ppc64.img 

append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba" 

  
TO: 

  
boot=/dev/sda1 

init-message="Welcome to Red Hat Enterprise Linux!\nHit &lt;TAB&gt; for boot options" 

partition=3 

timeout=5 

install=/usr/lib/yaboot/yaboot 

delay=5 

enablecdboot 

enableofboot 

enablenetboot 

nonvram 

fstype=raw 

default=2.6.32hfi 

image=/vmlinuz-2.6.32hfi 

label=2.6.32hfi 

read-only 

initrd=/initrd-2.6.32hfi.img 

append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba" 

image=/vmlinuz-2.6.32-71.el6.ppc64 

label=linux 

read-only 

initrd=/initramfs-2.6.32-71.el6.ppc64.img 

append="rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrhebsun16 KEYTABLE=us console=hvc0 crashkernel=auto rhgb quiet root=UUID=e2123609-7080-45f0-b583-23d5ef27dbba" 

  
4) Reset service nodes to boot from kernel with HFI 

xdsh c250f07c04ap01 reboot 

  
5\. Now the HFI interfaces on service nodes should be available on service node, sync the /etc/hosts 

from MN to SN and configure HFI interfaces with IP address. 

xdcp c250f07c04ap01 /etc/hosts /etc/hosts 

cp /hfi/scripts/hficonfig /install/postscripts/hficonfig 

chdef c250f07c04ap01 postscripts=servicenode,xcatserver,xcatclient,hficonfig 

As of xCAT 2.7, xcatclient and xcatserver are called from the servicenode postscript so you should run the following: 

chdef c250f07c04ap01 postscripts=servicenode,hficonfig 

  


updatenode c250f07c04ap01 

  
6\. Install DHCP server/client on MN and SN. 

rpm -Uvh /hfi/dhcp/dhcp-4.1.1-13.P1.el6.ppc64.rpm 

rpm -Uvh /hfi/dhcp/dhclient-4.1.1-13.P1.el6.ppc64.rpm 

xdsh c250f07c04ap01 rpm -Uvh /hfi/dhcp/dhcp-4.1.1-13.P1.el6.ppc64.rpm 

xdsh c250f07c04ap01 rpm -Uvh /hfi/dhcp/dhclient-4.1.1-13.P1.el6.ppc64.rpm 

  
7\. Create new networks for HFI interface. Generally we only need to create one new HFI network for 

installation. 

mkdef -t network -o hfinet net=20.0.0.0 mask=255.0.0.0 gateway=20.255.255.254 mgtifname=hf0 

dhcpserver=20.7.4.1 tftpserver=20.7.4.1 nameservers=20.7.4.1 

  
8\. Create compute node definitions. Make sure the servicenode and xcatmaster are setting correctly. 

servicenode attribute should be set to the ethernet IP address or hostname on service node, and 

xcatmaster should be set to HFI IP 

address on service node. 

# &lt;xCAT data object stanza file&gt;

c250f07c04ap13: 

objtype=node 

arch=ppc64 

cons=fsp 

groups=lpar,all 

hcp=f07c04fsp1_a 

id=13 

installnic=hf0 

ip=20.7.4.13 

mgt=fsp 

monserver=20.7.4.1 

netboot=yaboot 

nfsserver=20.7.4.1 

nodetype=lpar,osi 

os=rhels6 

parent=f07c04fsp1_a 

postscripts=hficonfig 

pprofile=c250f07c04ap13 

primarynic=hf0 

profile=compute 

provmethod=netboot 

servicenode=10.7.4.1 

tftpserver=20.7.4.1 

xcatmaster=20.7.4.1 

  
9\. Create diskless images 

copycds -n rhels6 /iso/RHEL6.0-20100922.1-Server-ppc64-DVD1.iso 

Where rhels6 stands for the OS version. 

  
10\. The HFI kernel can be installed by xCAT automatically, but another two packages hfi_util and nettools required rpm --force or --nodeps options, xCAT cannot handle the options automatically. So we need to modify the postinstall file manually which will be run during diskless image generation. 

Add following lines to /opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.postinstall 

//rhels6 stands for the OS version, it should be the same as name in step 8. 

cp /hfi/dd/hfi_util-1.0-0.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/hfi_util-1.0-0.el6.ppc64.rpm 

cp /hfi/dd/net-tools-1.60-102.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/nettools-1.60-102.el6.ppc64.rpm 

cp /hfi/dhcp/dhclient-4.1.1-13.P1.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/dhclient-4.1.1-13.P1.el6.ppc64.rpm 

cp /hfi/dhcp/dhcp-4.1.1-13.P1.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/dhcp-4.1.1-13.P1.el6.ppc64.rpm 

chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh /tmp/net-tools-1.60-102.el6.ppc64.rpm --force 

chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh /tmp/hfi_util-1.0-0.el6.ppc64.rpm --nodeps --force 

chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -Uvh /tmp/dhclient-4.1.1-13.P1.el6.ppc64.rpm --force 

chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -Uvh /tmp/dhcp-4.1.1-13.P1.el6.ppc64.rpm --force 

  
11\. Sync the /etc/hosts to diskless image. This is used for the postscript hficonfig to configure all the HFI interfaces on compute nodes. 

cp /hfi/scripts/compute.rhels6.ppc64.synclist 

/install/custom/netboot/rh/compute.rhels6.ppc64.synclist 

  
12\. Generate the diskless images 

cd /opt/xcat/share/xcat/netboot/rh/ &amp;&amp; /opt/xcat/share/xcat/netboot/rh/genimage -i hf0 -n hf_if -o rhels6 -p compute -k 2.6.32hfi 

where hf0 stands for the boot interface on compute nodes, and hf_hf stands for the boot devices. 

  
13\. pack the image: 

packimage -o rhels6 -p compute -a ppc64 

  
14\. Get the compute node mac address and setup dhcp services. 

getmacs c250f07c04ap13 --hfi -D 

//Make sure your site table have setup dhcp server on MN and SN correctly. 

#tabdump site | grep dhcp 

"dhcpinterfaces","c250mgrs04-pvt|eth0;c250f07c04ap01|hf0",, 

//Issue makedhcp to setup dhcp services. Specify --HFI option to identify this is a HFI devices. 

makedhcp c250f07c04ap13 --HFI 

  
15\. Initialized the boot 

nodeset c250f07c04ap13 netboot 

  
16\. Reboot the node to boot from network. 

rnetboot c250f07c04ap13 --hfi 

  
17\. Open a console to watch the compute node installation. 

rcons c250f07c04ap13 
