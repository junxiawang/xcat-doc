Note: 

  1. Pay more attention on the IP address(11.1.35.103), you should replace them based on your environment. 

Steps: 

1\. Create a 1GB test loopfile as the swift storage disk. 
    
    # dd if=/dev/zero of=/srv/swift-disk bs=1024 count=0 seek=1000000
    # mkfs.xfs -i size=1024 /srv/swift-disk
    # echo "/srv/swift-disk /srv/node/sdb1 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" &gt;&gt; /etc/fstab
    # mkdir /srv/node/sdb1
    # mount /srv/node/sdb1
    # chown -R swift:swift /srv/node
    

2\. Create self-signed cert for swift proxy SSL(all the inputs are default value): 
    
    # openssl req -new -x509 -nodes -out cert.crt -keyout cert.key
    

3\. Create the account, container and object rings. 
    
    # swift-ring-builder account.builder create 18 3 1
    # swift-ring-builder container.builder create 18 3 1
    # swift-ring-builder object.builder create 18 3 1
    

4\. For every storage device on each node add entries to each ring: 
    
    # swift-ring-builder account.builder add z1-11.1.35.103:6002/sdb1 100
    # swift-ring-builder container.builder add z1-11.1.35.103:6001/sdb1 100
    # swift-ring-builder object.builder add z1-11.1.35.103:6000/sdb1 100
    

5.Verify the ring contents for each ring: 
    
    # swift-ring-builder account.builder
    # swift-ring-builder container.builder
    # swift-ring-builder object.builder
              
    

6\. Rebalance the rings: 
    
    # swift-ring-builder account.builder rebalance
    # swift-ring-builder container.builder rebalance
    # swift-ring-builder object.builder rebalance
                   
    

7\. Make sure all files in /etc/swift are owned by the swift user: 
    
    # chown -R swift:swift /etc/swift
    

8\. Start Proxy services: 
    
    # service swift-proxy start
    

9\. Start all the Storage Nodes Services 
    
    #for i in swift-object swift-object-replicator swift-object-updater swift-container swift-container-replicator swift-container-updater swift-container-auditor swift-container-sync swift-account swift-account-replicator swift-account-reaper swift-account-auditor; do service $i status; done
    

10\. Create the common OpenStack envs 
    
    # vim openstackrc
    export OS_USERNAME=admin
    export OS_PASSWORD=admin
    export OS_TENANT_NAME=admin
    export OS_AUTH_URL=http://11.1.35.103:5000/v2.0
    export OS_AUTH_STRATEGY=keystone
    export OS_REGION_NAME=RegionOne
    

11\. register the swift in keystone 
    
    # keystone tenant-list | grep service
    | 0ec9f0f34f0d4677abaa273a7c4be719 | service |   True  |
    # keystone user-create --name=swift --pass=swift --tenant_id 0ec9f0f34f0d4677abaa273a7c4be719
    # keystone user-role-add --tenant_id 0ec9f0f34f0d4677abaa273a7c4be719 --user swift --role admin
    # keystone service-create --name swift --type object-store --description "Swift Storage Service"
    # keystone service-list | grep swift
    | 0cbba801e21a4728809764d1d0dc5c30 |  swift   | object-store |   Swift Storage Service   |
    # keystone endpoint-create --region RegionOne --service_id 0cbba801e21a4728809764d1d0dc5c30 --publicurl "http://11.1.35.103:8080/v1/AUTH_\$(tenant_id)s" --adminurl "http://11.1.35.103:8080/v1" --internalurl "http://11.1.35.103:8080/v1/AUTH_\$(tenant_id)s"
    

12\. Verify the Installation 
    
    # swift -V 2.0 -A http://11.1.35.103:5000/v2.0 -U service:swift -K swift stat
      Account: AUTH_e031308503e04e9ea1f7548277d82e4f
      Containers: 0
      Objects: 0
        Bytes: 0
      Accept-Ranges: bytes 
      X-Timestamp: 1390376328.69912
      X-Trans-Id: tx938c110ceb874e31abd7f3596188bf26
      Content-Type: text/plain; charset=utf-8
    # swift -V 2.0 -A http://11.1.35.103:5000/v2.0 -U service:swift -K swift upload myfiles /root/post.log
    root/post.log
    # swift -V 2.0 -A http://11.1.35.103:5000/v2.0 -U service:swift -K swift upload myfiles /root/post.script
    root/post.script
    # swift -V 2.0 -A http://11.1.35.103:5000/v2.0 -U service:swift -K swift list myfiles
    root/post.log
    root/post.script
    
