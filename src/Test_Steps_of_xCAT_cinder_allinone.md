1\. check the cinder service status 
    
     #for i in `ls cinder*`; do service $i status; done
    

2\. Create a 2GB test loopfile, and mount it 
    
     #sudo dd if=/dev/zero of=cinder-volumes bs=1 count=0 seek=2G
    

3\. Initialise it as an lvm 'physical volume', then create the lvm 'volume group' 
    
     #sudo pvcreate /dev/loop2
     #sudo vgcreate cinder-volumes /dev/loop2
    

4\. Lets check if our volume is created. 
    
     #sudo pvscan
     
    

5\. Restart the services, and check the stutus 
    
     #cd /etc/init.d; for i in `ls cinder*`; do service $i restart; done
     #cd /etc/init.d; for i in `ls cinder*`; do service $i status; done
    

6\. Make sure the image is ready. 
    
    #glance image-list
    +--------------------------------------+--------+-------------+------------------+---------+--------+
    | ID | Name | Disk Format | Container Format | Size | Status |
    +--------------------------------------+--------+-------------+------------------+---------+--------+
    | a37039d6-3fb5-4453-a404-776eab001657 | cirros | qcow2 | bare | 9761280 | active |
    +--------------------------------------+--------+-------------+------------------+---------+--------+
    

7\. List volumes to see the bootable volume 
    
    #cinder list
    +--------------------------------------+-----------+--------------+------+-------------+----------+-------------+
    | ID | Status | Display Name | Size | Volume Type | Bootable | Attached to |
    +--------------------------------------+-----------+--------------+------+-------------+----------+-------------+
    | c47896bc-e877-4dbe-a845-8d318aa86836 | available | my-boot-vol | 1 | None | true | |
    +--------------------------------------+-----------+--------------+------+-------------+----------+-------------+
    

8\. To create a bootable volume from an image and launch an instance from this volume 
    
    #nova boot --flavor 2 --image a37039d6-3fb5-4453-a404-776eab001657 --block_device_mapping vda=c47896bc-e877-4dbe-a845-8d318aa86836:::0 myInstanceFromVolume
    

9\. Waiting about 30s, and verify the vm ( account:cirros/cubswin:) ) 
    
    #ssh cirros@12.1.35.203    
     cirros@12.1.35.203's password:
     $ ip a
     1: lo: &lt;LOOPBACK,UP,LOWER_UP&gt; mtu 16436 qdisc noqueue state UNKNOWN
       link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
       inet 127.0.0.1/8 scope host lo
       inet6 ::1/128 scope host
          valid_lft forever preferred_lft forever
     2: eth0: &lt;BROADCAST,MULTICAST,UP,LOWER_UP&gt; mtu 1500 qdisc pfifo_fast state UP qlen 1000
       link/ether fa:16:3e:e4:1d:79 brd ff:ff:ff:ff:ff:ff
       inet 12.1.35.203/16 brd 12.1.255.255 scope global eth0
       inet6 fe80::f816:3eff:fee4:1d79/64 scope link
          valid_lft forever preferred_lft forever
     $ df
     Filesystem 1K-blocks Used Available Use% Mounted on
     /dev 1025120 0 1025120 0% /dev
     /dev/vda1 23797 13235 9334 59% /
     tmpfs 1028236 0 1028236 0% /dev/shm
     tmpfs 200 16 184 8% /run
     $
    
