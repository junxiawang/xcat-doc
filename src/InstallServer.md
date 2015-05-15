<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Intro](#intro)
- [Make A diskless Install Server Image](#make-a-diskless-install-server-image)
- [Edit xCAT Tabs](#edit-xcat-tabs)
  - [postscripts](#postscripts)
  - [noderes](#noderes)
  - [servicenode](#servicenode)
  - [nodetype](#nodetype)
- [Installing](#installing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Intro

Installing an Install Server makes your cluster scale. In this example I have 2 install servers. Each install server is an install server for 128 nodes. This for SLES10.1. If you're running another OS, mkinstall probably won't work for you. Use the default in /opt/xcat/share/xcat/netboot/rh.

Also note, that you'll need genimage.yum. If you use something else, then change the below script. This should be used as a reference and not copied directly.

## Make A diskless Install Server Image

Here is the code I used to make a diskless install image. To run it just run:

~~~~
./mkinstall <new image name>

~~~~

This is not tested anywhere but on my cluster. YMMV.

**mkinstall**

~~~~
    #!/bin/bash

    NAME=$1
    GENIMAGEDIR=/opt/xcat/share/xcat/netboot/sles
    GENIMAGE=$GENIMAGEDIR/genimage.yum
    IMGROOT=/install/netboot/sles10.1/x86_64/$NAME/rootimg
    MASTERIP=$(grep `hostname` /etc/hosts | head -1 | awk '{print $1}')
    echo "master is: $MASTERIP"
    sleep 5
    #MASTERIP=10.4.2.30
    ERROR=0


    if [ ! -f $GENIMAGEDIR/$NAME.pkglist ]
    then
     echo "Creating $GENIMAGEDIR/$NAME.pkglist"
     cat > "$GENIMAGEDIR/$NAME.pkglist" <EOF
    atftp
    bash
    bind
    bind-utils
    bzip2
    compat-libstdc++
    dbus-1
    dbus-1-glib
    dhclient
    dhcp-relay
    dhcp
    dhcpcd
    expat
    gcc
    gcc-fortran
    hal
    iputils
    kernel
    kernel-smp
    ksh
    libgfortran
    libxml2
    make
    nfs-utils
    ntp
    numactl
    openssh
    procps
    psmisc
    resmgr
    rpm
    rsh
    stunnel
    tar
    tcsh
    tk
    vim
    cron
    vsftpd
    wget
    perl-DBD-Pg
    apache2
    xCATsn
    conserver
    expect
    fping
    ipmitool
    perl-XML-Parser
    perl-xCAT
    postgresql
    postgresql-server
    syslinux
    xCAT-client
    xCAT-nbkernel-x86_64
    xCAT-nbroot-core-x86_64
    xCAT-nbroot-oss-x86_64
    xCAT-server
    xCATsn
    dhcp-server
    EOF
    fi

    if [ ! -f $GENIMAGEDIR/$NAME.exlist ]
    then
      echo "Creating $GENIMAGEDIR/$NAME.exlist"
      cat > "$GENIMAGEDIR/$NAME.exlist" <EOF2
    ./usr/share/man*
    ./usr/share/locale*
    ./usr/share/i18n*
    ./var/cache/yum*
    ./usr/share/doc*
    ./usr/share/gnome*
    ./usr/share/zoneinfo*
    ./usr/share/cracklib*
    ./usr/share/info*
    ./usr/share/omf*
    ./usr/lib/locale*
    ./boot*
    EOF2

    fi


    $GENIMAGE -i eth0 -n tg3,bnx2 -o sles10.1 -p $NAME
    chroot $IMGROOT insserv boot.localnet
    chroot $IMGROOT insserv haldaemon
    chroot $IMGROOT insserv dbus
    chroot $IMGROOT insserv network

    # change syslog
    echo "*.* @$MASTERIP" > $IMGROOT/etc/syslog.conf
    chroot $IMGROOT insserv syslog


    chroot $IMGROOT insserv portmap
    chroot $IMGROOT insserv sshd

    # NTP
    echo "server $MASTERIP" >> $IMGROOT/etc/ntp.conf
    cp /etc/localtime $IMGROOT/etc/
    cp /etc/hosts $IMGROOT/etc/
    chroot $IMGROOT insserv ntp
    chroot $IMGROOT insserv apache2

    # stop dhcp from starting up until xCAT does it.
    chroot $IMGROOT chkconfig dhcpd off
    chroot $IMGROOT chkconfig dhcrelay off

    # copy head nodes sysctl for kernel params
    cp /etc/sysctl.conf $IMGROOT/etc/

    # add more nfs threads
    perl -pi -e 's/USE_KERNEL_NFSD_NUMBER="4"/USE_KERNEL_NFSD_NUMBER="64"/g' $IMGROOT/etc/sysconfig/nfs

    # dhcp interface assignment
    perl -pi -e 's/DHCPD_INTERFACE=""/DHCPD_INTERFACE="eth0"/g' $IMGROOT/etc/sysconfig/dhcpd

    # NFS vodoo
    echo '/install *(ro,no_root_squash,sync,fsid=13)' >>$IMGROOT/etc/exports

    # FSTAB vodoo
    perl -pi -e 's/tmpfs/#tmpfs/g' $IMGROOT/etc/fstab
    echo "$NAME   /   tmpfs rw 0 1 " >>$IMGROOT/etc/fstab
    #echo "none    /tmp    tmpfs   defaults,size=10m 0 2" >>$IMGROOT/etc/fstab
    #echo "none    /var/tmp    tmpfs   defaults,size=10m 0 2" >>$IMGROOT/etc/fstab

    #HTTP fix
    mv $IMGROOT/etc/httpd/conf.d/xcat.conf $IMGROOT/etc/apache2/conf.d/


    cp /etc/security/limits.conf $IMGROOT/etc/security
    cp /usr/bin/strace $IMGROOT/usr/bin
    echo "Packing Image..."
    packimage -o sles10.1 -p $NAME -a x86_64
    echo "Install Server Image: $NAME has been created.  Please remember to edit"

    #echo "the nodetype table:  e.g.: tabedit nodetype"
    #echo "then run: nodeset service netboot"
    #echo "then reboot service nodes:  rpower, or reboot"
    #echo "make sure tabedit site has installloc set to /install"
    #echo "you should also verify post install scripts."

~~~~


## Edit xCAT Tabs

I'll show you the important tables here. The rest are just normal.

### postscripts

~~~~

    #node,postscripts,comments,disable
    "service","servicenode,xcatclient,xcatserver,setupeth,restartxcat",,

~~~~

As of xCAT 2.7, the servicenode postscript calls the xcatclient and xcatserver postscripts, so all three are not needed in the postscript table. The table would look like the following:


~~~~
    #node,postscripts,comments,disable
    "service","servicenode,setupeth,restartxcat",,

~~~~


All the scripts here are included with xCAT. I added setupeth because I wanted to change the GbE cards. Then after I did that I needed to restart xCAT so a made a script to do that.

Here are the scripts:

**setupeth**
Here I have a 10GbE card that I needed to load the driver on. I also needed to change the way they were ordered because I wanted my 10GbE card to be eth0. So here is how I did it. (Notice this is all in SLES10)


~~~~
    insmod /xcatpost/myri10ge.ko
    ME=`hostname`
    MMM=`grep $ME-bmm /etc/hosts | awk '{print $1}'`
    TENGE=`grep $ME /etc/hosts | head -1 | awk '{print $1}'`

    # flip the udev's around
    cp /etc/udev/rules.d/30-net_persistent_names.rules /tmp/net_persistent_names.rules.ORIG
    perl -pi -e 's/eth0/ethX/g' /etc/udev/rules.d/30-net_persistent_names.rules
    perl -pi -e 's/eth2/eth0/g' /etc/udev/rules.d/30-net_persistent_names.rules
    perl -pi -e 's/eth1/eth2/g' /etc/udev/rules.d/30-net_persistent_names.rules
    perl -pi -e 's/ethX/eth1/g' /etc/udev/rules.d/30-net_persistent_names.rules

    echo "BOOTPROTO='static'
    IPADDR=$TENGE
    NETMASK=255.255.0.0
    STARTMODE=auto
    MTU=1500
    " >/etc/sysconfig/network/ifcfg-eth0

    echo "BOOTPROTO='static'
    IPADDR=$MMM
    NETMASK=255.255.0.0
    STARTMODE=auto
    " >/etc/sysconfig/network/ifcfg-eth1
    service network stop
    rmmod bnx2
    rmmod myri10ge
    modprobe bnx2
    insmod /xcatpost/myri10ge.ko
    sleep 5
    service network start
    #sleep 10

~~~~

**restartxcat**
does just what it says it does... oh, and syslog too.


~~~~
    service syslog restart
    service xcatd restart

~~~~

### noderes


~~~~
    "service",,"pxe",,"10.1.2.30",,,,,,,"eth0","eth0","10.1.2.30",,,,
    "hgroup","dnh01","pxe","dnh01","dnh01",,,,,,,"eth0","eth0","dnh01",,,,
    "igroup","dni01","pxe","dni01","dni01",,,,,,,"eth0","eth0","dni01",,,,

~~~~

Here my two install servers are dnh01 and dni01. They service the hgroup and the igroup. Each of these groups has about 128 nodes. The nodes are assigned in the nodelist table.

### servicenode

Looks like this:


~~~~
    #node,nameserver,dhcpserver,tftpserver,nfsserver,conserver,monserver,ldapserver,ntpserver,ftpserver,comments,disable
    "dnh01","0","1","1","1","0","1","0","1","1",,
    "dni01","0","1","1","1","0","1","0","1","1",

~~~~

### nodetype


~~~~
    #node,os,arch,profile,nodetype,comments,disable
    "service","sles10.1","x86_64","s10","osi",,

~~~~

Notice that when I ran mkinstall above I ran it like:


~~~~
    mkinstall s10

~~~~

So since that's the image I made, I want to boot to it.




## Installing

The rest is all just done using normal xCAT commands. Run: nodeset &lt;servicenodes&gt; netboot.
The biggest problem I had when doing this initially was that the 10GbE card runs at 9000MTU by default and my switch wasn't set to handle that. So when I added the MTU in there it made everything work fine.

Hopefully this helps someone else.

