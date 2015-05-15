<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [On RHEL6:](#on-rhel6)
  - [Preparation:](#preparation)
  - [Steps:](#steps)
- [SLES 11](#sles-11)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

  
  
**This document is no longer used! It's content has been integrated into the main xcat cookbooks.**   
  
  
  
  
  
  
  


  
This doc describes how to set up an xCAT management node and service node to boot compute nodes over the system p HFI network. 


## On RHEL6:

### Preparation:

  1. We are using the following node names as an example in this document: 
        
        Management node (MN): c250mgrs04-pvt
        Service node (SN): c250f07c04ap01
        Compute node (CN): c250f07c04ap13

  2. All the steps should be run on the xCAT management node. For those commands that need to run on the service node, we are using xdsh to run the command remotely on the service node. 
  3. The following RPMs and scripts referred to in this document currently must be obtained from IBM and put on the xCAT MN in the suggested directories: 
    * /hfi/dd/kernel-2.6.*hfi-*.ppc64.rpm 
    * /hfi/dd/hfi_util-*.el6.ppc64.rpm 
    * /hfi/dd/net-tools-*.el6.ppc64.rpm 
    * /hfi/dhcp/dhcp-*.el6.ppc64.rpm 
    * /hfi/dhcp/dhclient-*.el6.ppc64.rpm 
    * /hfi/scripts/hficonfig 
    * /hfi/scripts/compute.rhel6.ppc64.synclist 

### Steps:

  1. After installing xCAT on the management node according [XCAT_pLinux_Clusters], increase the /boot file system size for service node since we need to use a customized kernel on service node, there will be two kernels existing on service nodes, /boot needs more space. 

    This is just for a workaround of a customized kernel. After the kernel is accepted by Linux community, there will be only one kernel existing on service node, and we don't need to increase the /boot space at that time. 

    In file /opt/xcat/share/xcat/install/rh/service.rhels6.ppc64.tmpl, change the line: 

    From: 
        
        part /boot --size 50 --fstype ext4

    To: 
        
        part /boot --size 200 --fstype ext4

  2. Refer to the rest of [XCAT_pLinux_Clusters] and [Setting_Up_a_Linux_Hierarchical_Cluster] for instructions for setting up a basic xCAT MN and SN and stateless compute nodes. The rest of the instructions below are additional steps you need to take to be able to boot the compute nodes over the HFI network. Eventually, this document will be integrated with the other two. 
  3. After the basic MN is set up and the SN is installed, install the HFI device drivers on xCAT MN 
        
        cd /hfi/dd
        rpm -ivh kernel-2.6.32hfi-3.ppc64.rpm
        rpm -ivh --nodeps hfi_util-1.0-0.el6.ppc64.rpm
        rpm -ivh --force net-tools-1.60-102.el6.ppc64.rpm

  4. Configure the xCAT SN with the HFI device driver 
    1. Copy the HFI driver and DHCP packages to service node: 
            
            xdcp c250f07c04ap01 -R /hfi /hfi

    2. Install the HFI device drivers on the xCAT SN 
            
            xdsh c250f07c04ap01 rpm -ivh /hfi/dd/kernel-2.6.32hfi-2.ppc64.rpm
            xdsh c250f07c04ap01 rpm -ivh --nodeps /hfi/dd/hfi_util-1.0-0.el6.ppc64.rpm
            xdsh c250f07c04ap01 rpm -ivh --force /hfi/dd/net-tools-1.60-102.el6.ppc64.rpm
            xdsh c250f07c04ap01 /sbin/new-kernel-pkg --mkinitrd --depmod --install 2.6.32hfi
            xdsh c250f07c04ap01 /sbin/new-kernel-pkg --rpmposttrans 2.6.32hfi

    3. Create soft links and change yaboot.conf to boot from the customized kernel with HFI support 
            
            xdsh c250f07c04ap01 ln -sf /boot/vmlinuz-2.6.32hfi /boot/vmlinuz
            xdsh c250f07c04ap01 ln -sf /boot/System.map-2.6.32hfi /boot/System.map

Login to the service node and change the "default=" setting in /boot/etc/yaboot.conf to the new label with HFI support. For example, change it from: 
            
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

    4. Reset the service node to boot from the kernel with HFI 
            
            xdsh c250f07c04ap01 reboot

  5. Now the HFI interfaces should be available on the service node. Sync the /etc/hosts from MN to SN and run the hficonfig postscript to configure the HFI interfaces with IP addresses. 
        
        xdcp c250f07c04ap01 /etc/hosts /etc/hosts
        cp /hfi/scripts/hficonfig /install/postscripts/hficonfig
        chdef c250f07c04ap01 postscripts=servicenode,xcatserver,xcatclient,hficonfig
        updatenode c250f07c04ap01

In **xCAT 2.7**, the xcatserver and xcatclient postscripts are not longer needed in the postscripts table. You should use the following command: 

chdef c250f07c04ap01 postscripts=servicenode,hficonfig 

  


  6. Install the DHCP server/client on MN and SN. 
        
        rpm -Uvh /hfi/dhcp/dhcp-4.1.1-13.P1.el6.ppc64.rpm
        rpm -Uvh /hfi/dhcp/dhclient-4.1.1-13.P1.el6.ppc64.rpm
        xdsh c250f07c04ap01 rpm -Uvh /hfi/dhcp/dhcp-4.1.1-13.P1.el6.ppc64.rpm
        xdsh c250f07c04ap01 rpm -Uvh /hfi/dhcp/dhclient-4.1.1-13.P1.el6.ppc64.rpm

  7. Create a new networks definition in the xCAT database for the HFI interface. Generally we only need to create one new HFI network definition (for hf0) for diskless booting of compute nodes over HFI. 
        
        mkdef -t network -o hfinet net=20.0.0.0 mask=255.0.0.0 gateway=20.255.255.254 mgtifname=hf0 dhcpserver=20.7.4.1 tftpserver=20.7.4.1 nameservers=20.7.4.1

where the above net, mask, and gateway are appropriate for your hf0 network, and 20.7.4.1 should be changed to be the IP address of the hf0 NIC on your SN. 

  8. Create compute node definitions. Make sure the servicenode and xcatmaster attributes are set correctly. 

    servicenode attribute should be set to the IP address or hostname of the ethernet NIC on the service node that faces the MN. The xcatmaster attribute should be set to hf0 IP address on the service node. An example [mkdef stanza file](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html) for defining the compute node: 
        
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
        nodetype=ppc,osi
        hwtype=lpar
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

  9. Create a diskless image for the compute node 
        
        copycds -n rhels6 /iso/RHEL6.0-20100922.1-Server-ppc64-DVD1.iso

Where rhels6 stands for the OS version (RHEL 6 Server). 

  10. The HFI kernel can be installed by xCAT automatically, but the other two packages, hfi_util and nettools, require the rpm options --nodeps and --force respectively, which xCAT cannot handle automatically. So we need to modify the postinstall file manually which will be run during the diskless image generation. 

    Add the following lines to /opt/xcat/share/xcat/netboot/rh/compute.rhels6.ppc64.postinstall. (rhels6 stands for the OS version - it should be the same as the previous step.) 
        
        cp /hfi/dd/hfi_util-1.0-0.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/hfi_util-1.0-0.el6.ppc64.rpm
        cp /hfi/dd/net-tools-1.60-102.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/nettools-1.60-102.el6.ppc64.rpm
        cp /hfi/dhcp/dhclient-4.1.1-13.P1.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/dhclient-.1.1-13.P1.el6.ppc64.rpm
        cp /hfi/dhcp/dhcp-4.1.1-13.P1.el6.ppc64.rpm /install/netboot/rhels6/ppc64/compute/rootimg/tmp/dhcp-4.1.1-13.P1.el6.ppc64.rpm
        chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh /tmp/net-tools-1.60-102.el6.ppc64.rpm --force
        chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -ivh /tmp/hfi_util-1.0-0.el6.ppc64.rpm --nodeps --force
        chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -Uvh /tmp/dhclient-4.1.1-13.P1.el6.ppc64.rpm --force
        chroot /install/netboot/rhels6/ppc64/compute/rootimg/ /bin/rpm -Uvh /tmp/dhcp-4.1.1-13.P1.el6.ppc64.rpm --force

  11. Sync /etc/hosts to the diskless image. This is used by the postscript hficonfig to configure all the HFI interfaces on the compute nodes. 
        
        cp /hfi/scripts/compute.rhels6.ppc64.synclist /install/custom/netboot/rh/compute.rhels6.ppc64.synclist

  12. Generate the diskless image 
        
        cd /opt/xcat/share/xcat/netboot/rh/ && /opt/xcat/share/xcat/netboot/rh/genimage -i hf0 -n hf_if -o rhels6 -p compute -k 2.6.32hfi

where hf0 stands for the boot interface on compute nodes, and hf_if stands for the hfi device driver. 

  13. pack the image: 
        
        packimage -o rhels6 -p compute -a ppc64

  14. Get the compute node mac address and set up dhcp services. 
        
        getmacs c250f07c04ap13 --hfi -D

  15. Prepare for the compute node boot 
        
        nodeset c250f07c04ap13 netboot

  16. Make sure your site.dhcpinterfaces attribute is set correctly to have the MN and SN listen only on the correct NICs. 
        
        &gt; tabdump site | grep dhcp
        "dhcpinterfaces","c250mgrs04-pvt|eth0;c250f07c04ap01|hf0",,

Issue makedhcp to setup dhcp services. Specify --HFI option to identify this is a HFI devices. 
        
        makedhcp c250f07c04ap13 --HFI

  17. Reboot the node to boot from network. 
        
        rnetboot c250f07c04ap13 --hfi

  18. Open a console to watch the compute node installation. 
        
        rcons c250f07c04ap13

## SLES 11

Instructions for SLES 11 will come at a later time. 
