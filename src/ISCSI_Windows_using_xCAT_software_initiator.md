<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [iSCSI Windows using xCAT software initiator](#iscsi-windows-using-xcat-software-initiator)
  - [Introduction](#introduction)
  - [xCAT Package Requirements and Management Server changes](#xcat-package-requirements-and-management-server-changes)
    - [Windows Netboot Image](#windows-netboot-image)
    - [Setup Samba on the headnode](#setup-samba-on-the-headnode)
  - [xCAT Table Changes](#xcat-table-changes)
  - [Install a Node](#install-a-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


# iSCSI Windows using xCAT software initiator

Note: You may have better luck following the updated Windows documentation [here](http://www-03.ibm.com/support/techdocs/atsmastr.nsf/WebIndex/WP101470). 

## Introduction

xCAT has the power to let any node boot from an iSCSI device. The machine only has to support PXE boot in order to do this. In this example we'll use the management node as an iSCSI target device and install Windows Server 2008 from a RedHat Linux machine. Our node is called x01 and our management server is redhouse. 

We assume that you set up your xCAT server as normal and that you can install machines from it. If so, then please continue. 

## xCAT Package Requirements and Management Server changes

You'll need a few packages that don't install with the standard xCAT 2.1 distribution: 
    
    yum -y install gpxe-xcat scsi-target-utils-0.9.1-1 samba
    service tgtd start
    chkconfig tgtd on

You'll also need to copy the Windows ISO image on to the management server. You can get that ISO [here](http://www.microsoft.com/downloads/details.aspx?FamilyId=13C7300E-935C-415A-A79C-538E933D5424&WT.sp=_technet_,dcsjwb9vb00000c932fd0rjc7_5p3t&displaylang=en). 
    
    copycds windows_server_2008_x64.iso

During copycds the % complete will probably hang for a while on 52%. Don't be alarmed, just be patient and let it finish. 

### Windows Netboot Image

You'll also need to download a netboot image file for the Windows install to boot.  
On an existing Windows Vista/Server 2008 node: (or whatever node type you are booting)  
Download the Automated Install Kit (AIK) ISO [here](https://www.microsoft.com/downloads/details.aspx?displaylang=en&FamilyID=94bb6e34-d890-4932-81a5-5b50c657de08)  
Mount the ISO with a tool like Daemon Tools, or burn it to a disk and put it in the system  
Install the AIK  
Copy the contents of /opt/xcat/share/xcat/netboot/windows/ on the headnode to a Windows node (genimage.bat and startnet.cmd) 

**For 64-bit:**  
At the Windows command prompt, run: 
    
    genimage.bat amd64

Copy the contents of the C:\WinPE_64\pxe folder to /tftpboot/ on the xCAT headnode 

**For 32-bit:**  
At the Windows command prompt, run: 
    
    genimage.bat x86

Copy the contents of the C:\WinPE\pxe folder to /tftpboot/ on the xCAT headnode 

### Setup Samba on the headnode

Make sure that a samba service is installed. 

Edit /etc/samba/smb.conf 

In the [global] section, change security to: 
    
    security = share

Paste the following lines under Share Definitions 
    
    [install]
    path = /install
    public = yes
    writable = no

Restart the Samba server. 
    
    service smb restart

## xCAT Table Changes

Each machine will need its own license to run Windows 2008 x64. You put this in the **prodkey table**. Our table looks like: 
    
    # tabdump prodkey
    #node,product,key,comments,disable
    "all","win2k8.enterprise","xxxxx-xxxxx-xxxxx-xxxxx-xxxxx",,

You'll also need to set the **iscsi table**: 
    
    tabdump iscsi
    #node,server,target,lun,iname,file,userid,passwd,kernel,kcmdline,initrd,comments,disable
    "x01","redhouse",

Notice that the first two arguments: The node and the server are all you need. xCAT will populate the other fields automatically.  
You'll also need to know where you're iscsi targets are going to live. We made a directory called iscsi to put ours in. Do this by modifying the **site table**. And finally, you'll need the password for your Windows machine: 
    
    chdef -t site -o clustersite iscsidir="/iscsi"
    chtab key=system passwd.username=Administrator passwd.password=(password)

## Install a Node
    
    setupscsidev x01 -s 10240 # you may need 20GB: 20480
    rinstall -o win2k8 -p enterprise -a x86_64 x01

If you run the command: 
    
    tail -n 20 /var/lib/dhcpd.leases

You should see the gpxe entry in the DHCP file: 
    
    host x01 {
      dynamic;
      hardware ethernet 00:14:5e:55:58:61;
      fixed-address 192.168.15.71;
            supersede host-name = "x01";
            if exists gpxe.bus-id {
              supersede server.filename = "pxelinux.0";
            } elsif exists client-architecture {
              supersede server.filename = "undionly.kpxe";
            }
            supersede root-path = "iscsi:redhouse:::1:iqn.2009-0.cluster.net:x01";
            supersede server.next-server = c0:a8:0f:01;
    }
