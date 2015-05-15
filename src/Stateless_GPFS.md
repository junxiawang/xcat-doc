<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [How to setup a GPFS stateless cluster (for xCAT 2.2 and greater)](#how-to-setup-a-gpfs-stateless-cluster-for-xcat-22-and-greater)
- [Step 1: Setup GPFS on the management server](#step-1-setup-gpfs-on-the-management-server)
- [Step 2: Put GPFS in your stateless image](#step-2-put-gpfs-in-your-stateless-image)
  - [File 1: $IMGROOT/etc/init.d/autogpfsc](#file-1-imgrootetcinitdautogpfsc)
  - [File 2: $IMGROOT/usr/sbin/autogpfsc.pl](#file-2-imgrootusrsbinautogpfscpl)
  - [File 3: $IMGROOT/etc/sysconfig/autogpfsc](#file-3-imgrootetcsysconfigautogpfsc)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning) 

For current and complete information, refer to [IBM_HPC_Software_Kits].


## How to setup a GPFS stateless cluster (for xCAT 2.2 and greater)

GPFS is a premier cluster filesystem. With a few tricks, you can run it stateless on nodes. There are two parts to setting it up. 

1\. Install a listener script on a management node or some other node that is already part of a GPFS cluster. This is called autogpfsd and listens for new stateless images to boot up. 

2\. Install an autogpfsc client daemon on the stateless node so that when it boots up it contacts the servers running autogpfsd and receives all the configuration files from them. 

This listen mode can happen in two ways: If the autogpfsd is accepting 'new' connections then when a node boots up that has autogpfsc, the node running autogpfsd will check with GPFS to see if this node is already part of the cluster. If it is not, then it will add the node to the cluster. If autogpfsd is running in 'old' mode, then it will not automatically add new nodes to the cluster - you'll have to run mmaddnode manually. This is probably a safer way to do it, but requires more manual work. Once a stable environment is achieved, running the autogpfsd in 'old' mode is the recommended way to remain. 

## Step 1: Setup GPFS on the management server

Install the GPFS base rpms and then the update rpms: 
    
    cd &lt;pathtogpfsbaserpms&gt;/
    rpm -ivh gpfs*rpm
    cd &lt;updates&gt;
    rpm -Uivh gpfs*rpm

  
Now create the portability layer 
    
    cd /usr/lpp/mmfs/src/
    make AutoConfig
    make World
    make InstallImages

  
From here on out you need to configure your GPFS setup environment. This includes running mmcreatecluster, mmcreatensds, etc. We'll refer you to the GPFS documentation for this. 

Now you need to create the autogpfsd file in /etc/init.d. 
    
    cp /opt/xcat/share/xcat/netboot/add-on/autogpfs/autogpfsd /etc/init.d/

  
Now you need to copy the file /usr/sbin/autogpfsd.pl. You also need to configure 
    
    cp /opt/xcat/share/xcat/netboot/add-on/autogpfs/autogpfsd.pl /usr/sbin/

Next put the parameters specific to your cluster in /etc/sysconfig/autogpfsd 
    
    domain cluster.foo
    autogpfsdport 3003
    autogpfsdmax 100
    autogpfsdmode old

Autogpfsmode old means that it won't automatically run mmaddnode to new nodes on the cluster if they are running autogpfsc 

Now start it up on the management node: 
    
    chkconfig --add autogpfsd
    service autogpfsd start

This is the code on the management server. Now you need to put code in the stateless servers. 

## Step 2: Put GPFS in your stateless image

When you create your stateless image put GPFS in it and three files. 

### File 1: $IMGROOT/etc/init.d/autogpfsc
    
    export IMGROOT=/install/netboot/rhels5.3/x86_64/compute/rootimg
    cp /opt/xcat/share/xcat/netboot/add-on/autogpfs/autogpfsc $IMGROOT/etc/init.d/

### File 2: $IMGROOT/usr/sbin/autogpfsc.pl
    
    cp /opt/xcat/share/xcat/netboot/add-on/autogpfs/autogpfsc.pl $IMGROOT/usr/sbin/

### File 3: $IMGROOT/etc/sysconfig/autogpfsc

This file you need to create that has the configurable parameters specific to your cluster.  
SERVERS - these are nodes that are running GPFS that have the autogpfsd.pl command running.  
PORT - this is the port that autogpfsc should run on  
BLOCK - setting this to 'yes' means that the node will hold on boot up until GPFS is loaded before doing anything. This is useful if the rest of your startup scripts require GPFS to be active, such as /home mounted or job scheduler availability. 
    
    SERVERS=gpfsnode1,gpfsnode2,gpfsnode3
    PORT=3003
    BLOCK=no

Once you have that in your stateless server it'll boot up, contact the GPFS server on the node and add itself in. 
