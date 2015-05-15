Notice: 

  1. Pay more attention on the IP address, gateway, subnet, you should replace them based on your environment. 
  2. Run all the steps on the controller node. 
    
~~~~    
    source /root/openrc
    
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
    nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0
    nova secgroup-add-rule default udp 1 65535 0.0.0.0/0
    
    glance image-create --name cirros --is-public true --container-format bare --disk-format qcow2 --location https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
    
    glance image-list
    
    #Create the external network and its subnet by admin user:
    quantum net-create ext_net --router:external=True
    
    #10.1.34.x
    quantum subnet-create --name ext_subnet --allocation-pool start=9.114.54.230,end=9.114.54.240 --gateway  9.114.54.254  ext_net 9.114.54.0/24 -- --enable_dhcp=False
    
    keystone tenant-list
    
    ##Create a new tenant
    keystone tenant-create --name tenantB
    TENANTB_ID=`keystone tenant-list | grep tenantB | awk  '{print $2}'`
    #Create a new user and assign the member role to it in the new tenant (keystone role-list to get the appropriate id):
    keystone user-create --name=user_b --pass=user_b --tenant-id ${TENANTB_ID} --email=user_b@domain.com
    USER_B_ID=`keystone user-list | grep user_b | awk '{print $2}'`
    Member_ID=`keystone role-list  | grep Member | awk '{print $2}'`
    keystone user-role-add --tenant-id ${TENANTB_ID} --user-id ${USER_B_ID} --role-id ${Member_ID}
    
    ##Create a new network for the tenant:
    quantum net-create --tenant-id ${TENANTB_ID} tenantb-net
    TENANTB_NET_ID=`quantum net-list | grep tenantb-net| awk '{print $2}'`
    #Create a new subnet inside the new tenant network:
    quantum subnet-create --name tenantb-subnet --tenant-id ${TENANTB_ID} tenantb-net 192.168.1.0/24
    TENANTB_SUBNET_ID=`quantum subnet-list | grep  tenantb-subnet | awk '{print $2}'`
    
    #Create a router for the new tenant:
    quantum router-create --tenant-id ${TENANTB_ID} tenantb_router
    #Add the router to the subnet:
    quantum router-interface-add tenantb_router  ${TENANTB_SUBNET_ID}
    quantum router-gateway-set tenantb_router ext_net
    
    echo -e "export OS_TENANT_NAME=tenantB
    export OS_USERNAME=user_b
    export OS_PASSWORD=user_b
    export OS_AUTH_URL=\"http://100.3.1.8:5000/v2.0/\"" &gt;  /root/creds_tenantB_rc
    
    source /root/creds_tenantB_rc
    
    nova  boot --image cirros --flavor 1 --nic net-id=${TENANTB_NET_ID}  tenant_b_testvm1
    
    TENANTB_TESTVM1_ID=`nova list | grep tenant_b_testvm1 | awk '{print $2}'`
    
    #Create a floating IP
    quantum floatingip-create ext_net
    
    FLOATINGIP_ID_JUST_CREATED=`quantum floatingip-list | grep 9.114 | awk '{print $2}'`
    
    #Get the port ID of the VM with ID
    VM_PORT_ID_JUST_GOT=`quantum  port-list -- --device_id  ${TENANTB_TESTVM1_ID} | grep subnet_id | awk '{print $2}'`
    
    #quantum floatingip-associate d7d3fb7e-b00a-4cb6-bbed-e379ab22119b d8003e37-e5cc-4222-9eb8-18e99a0310da
    quantum floatingip-associate ${FLOATINGIP_ID_JUST_CREATED}  ${VM_PORT_ID_JUST_GOT}
    
    #Add this security rules to make your VMs pingable:
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
    nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0
    nova secgroup-add-rule default udp 1 65535 0.0.0.0/0
    
    echo "waiting about 1 minutes later, you can run nova list to check the vm with 2 IPs"
    nova list
    +--------------------------------------+------------------+--------+--------------------------------------+
    | ID                                   | Name             | Status | Networks                             |
    +--------------------------------------+------------------+--------+--------------------------------------+
    | 5b026d4b-754c-4670-85b0-84f9ac247d71 | tenant_b_testvm1 | ACTIVE | tenantb-net=192.168.1.2, 9.114.54.231 |
    +--------------------------------------+------------------+--------+--------------------------------------+
    
    
    #ping to the vm
    echo "do the ping tests on the floating ip, or ssh the floating ip with cirros/cubswin:) to login the nova vm ."
    ping 9.114.54.231
    PING 9.114.54.231 (9.114.54.231) 56(84) bytes of data.
    64 bytes from 9.114.54.231: icmp_req=1 ttl=63 time=10.6 ms
    ....
    
    or
    
    ssh cirros@9.114.54.231
    
~~~~   
    
