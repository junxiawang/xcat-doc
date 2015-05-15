[Howto_Warning](Howto_Warning)

For additional IB information, see also [Managing_the_Infiniband_Network]. 

Add IB to a stateless node 

Typically we use the OFED stack. You can also try the default drivers that come with the operating system. We downloaded the distribution and extracted into /install/src/ofed1.4. 

Don't forget to copy the .mlnx or .&lt;something&gt; configuration file into that directory too. 

Then we just install the OFED package in the distro: 
    
    IMGROOT=/install/netboot/rhels5.3/x86_64/compute-ib/rootimg
    yum --installroot=$IMGROOT -y install bind-utils rpm tcl tk glibc-devel.i386 pciutils expat
    IBROOT=/install/src/ofed1.4
    mount -o bind /proc $IMGROOT/proc
    mount -o bind /sys $IMGROOT/sys
    mount -o bind $IBROOT $IMGROOT/mnt
    chroot $IMGROOT /mnt/mlnxofedinstall --basic --without-ib-bonding
    umount $IMGROOT/mnt
    umount $IMGROOT/sys
    umount $IMGROOT/proc

Then you need to make a script that will bring up the IB interface. You can add something to rc.local to do that: 
    
    vim $IMGROOT/etc/rc.local
    
            ip_ib=`host $HOSTNAME-ib | awk '{ print $4 }'`
            ifconfig ib0 $ip_ib netmask 255.255.0.0

Pack your image and off you go! 
