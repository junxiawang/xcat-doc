<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [iSCSI Anywhere with xCAT for RHEL5.3](#iscsi-anywhere-with-xcat-for-rhel53)
- [Assumptions](#assumptions)
- [](#)
- [Install required iSCSI tools](#install-required-iscsi-tools)
- [Change tables to to allow for node to boot from iSCSI](#change-tables-to-to-allow-for-node-to-boot-from-iscsi)
- [Create iSCSI target](#create-iscsi-target)
- [Install the Node](#install-the-node)
- [Troubleshoot](#troubleshoot)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


## iSCSI Anywhere with xCAT for RHEL5.3

## Assumptions

as usual with these howtos you should have at least a basic xCAT install done. We're going to take a diskless node and boot it into iSCSI. As a sanity check, make sure that you can do a diskful install and/or a diskless install on the node you're going to do iSCSI with. If this works then you should be able to boot iSCSI 

## 

## Install required iSCSI tools
    
    yum -y install gpxe-xcat # on the management server
    yum -y install scsi-target-utils-0.9.1-1 # on the tgt server (this has to be a service node or the xCAT management server)
    service tgtd start
    chkconfig tgtd on

If you need to create an iSCSI target on the machine you 

You'll need to install scsi-target-utils on the machine that you wish to be the iSCSI target and gpxe-xcat on the management node. 

## Change tables to to allow for node to boot from iSCSI
    
    chtab node=node01 nodetype.os=rhels5.3 nodetype.arch=x86_64 nodetype.profile=iscsi

You'll also need to set the **iscsi table**: 
    
    tabdump iscsi
    #node,server,target,lun,iname,file,userid,passwd,kernel,kcmdline,initrd,comments,disable
    "node01","redhouse",

Notice that the first two arguments: The node and the server are all you need. xCAT will populate the other fields automatically.  
You'll also need to know where you're iscsi targets are going to live. We made a directory called iscsi to put ours in. Do this by modifying the **site table**. And finally, you'll need the password for your Windows machine: 
    
    chtab key=iscsidir site.value=/iscsi

## Create iSCSI target

If you are using a machine as an iSCSI target like we are then you'll need to create the iSCSI target: 
    
    setupscsidev node01 -s 10240 # 10GB of disk

if you now look at your iscsi table you'll see the new settings that xCAT configured for you. 

Note that if the system hosting the iSCSI targets is rebooted, the "setupiscsidev" command (with no arguments) will have to be re-run to export the iSCSI targets again (be careful not to re-create/overwrite the iSCSI targets). 

## Install the Node
    
    rinstall node01
    nodeset node01 iscsiboot

## Troubleshoot
    
    tgtadm --mode target --op show

To remotely access the node from linux, use rdesktop version 1.60 or later 
