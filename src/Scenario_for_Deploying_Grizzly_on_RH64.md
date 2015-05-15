<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Scenario for Deploying Grizzly OpenStack on RH 6.4](#scenario-for-deploying-grizzly-openstack-on-rh-64)
  - [(optional) Reinstall nodes](#optional-reinstall-nodes)
  - [(optional) Reset Chef](#optional-reset-chef)
  - [Standup OpenStack on network node](#standup-openstack-on-network-node)
  - [Standup OpenStack on compute node](#standup-openstack-on-compute-node)
  - [Use OpenStack](#use-openstack)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Scenario for Deploying Grizzly OpenStack on RH 6.4

Note that standing up the Grizzly OpenStack cluster through xCAT 2.8.3 on RH 6.4 is not fully supported and tested. This wiki page describes one successful scenario that was repeatedly executed with some hand-tending to certain configuration files and to overcome some issues with the community versions of the Chef cookbooks. 

Here are some notes on the cluster and this scenario: 

  * xCAT management node mn.cluster.com with IP 10.11.0.204 is not included in the actual OpenStack cluster. It acts as the Chef server. 
  * xCAT 2.8.3, using the Chef cookbooks shipped with the xCAT-OpenStack rpm (community version at the time of xCAT 2.8.3 GA) 
  * RHELS 6.4 
  * The OpenStack Per-tenant Routers with Private Networks use case was followed 
  * The cluster: 
    * xCAT nodegroup referenced below: ops 
    * op1 - 10.11.0.244 - the OpenStack server running Nova, Keystone, and most other OpenStack services 
    * op2 - 10.11.0.201 - the OpenStack network node running Quantum, dnsmasq, etc. and other OpenStack network services 
    * op3 - 10.11.0.208 - the OpenStack compute node running the OpenStack compute services and on which the VMs will be created 
  * Networking: 
    * public network connected to xCAT management node only. HTTP proxies were set up from the ops nodes to route through the MN to access the rdo/epel repositories during Chef installs of the OpenStack software then turned off to allow OpenStack services to operate correctly within the cluster. 
    * xCAT management network 10.11.0.0 between the xCAT mn and the ops nodes used by xCAT to manage the cluster. Also used as the network for OpenStack services to communicate across. 

  
The details listed here are a quick capture of the steps gleaned from [Deploying_OpenStack] interspersed with manual changes for RH6.4. 

### (optional) Reinstall nodes

If necessary, reinstall the nodes to start with a clean slate: 
    
      nodeset ops osimage=RH64_no_chef_kit
    

     make sure osimage has pkglist entries for: 
    
      httpd
      httpd-tools
    

     Download the following rpms and put them into &lt;osimage.otherpkgdir&gt;/ops_deps, run createrepo in that dir, and make sure osimage has otherpkgs.pkglist entry for: 
    
      ops_deps/epel-release
      ops_deps/rdo-release-grizzly
    

     OpenStack requires dnsmasq 2.59, but dnsmasq 2.48 was shipped with RH 6.4 and a newer version was not available through the RDO repository. Find and download a copy of this and add to otherpkgs for the osimage. 

     Boot the nodes with rpower, watch installs with rcons if necessary 

  


### (optional) Reset Chef

On the MN, reset chef to clear out all previous definitions to start clean: 
    
     knife cookbook bulk delete '.*' -y
     knife role bulk delete '.*' -y
     knife environment list
     knife environment delete cloud1 -y
    
    
     knife client list
     knife client delete op1.cluster.com -y
     knife client delete op2.cluster.com -y
     knife client delete op3.cluster.com -y
    
    
     knife node list
     knife node delete op1.cluster.com -y
     knife node delete op2.cluster.com -y
     knife node delete op3.cluster.com -y
    

  
During one experiment, for some reason, lost all files in /etc/chef on the xCAT MN (the chef server/workstation), and all chef/knife commands were failing. To recreate them: 
    
     [root@mn]# cd /etc/chef
     [root@mn]# knife configure client ./
     Creating client configuration
     Writing client.rb
     Writing validation.pem
     [root@mn]# chef-client
    

Cookbook fix for RH quantum package: 
    
     vi /install/chef-cookbooks/grizzly-xcat/cookbooks/openstack-network/attributes/default.rb
     [root@mn]# diff default.rb default.rb.ORIG
     754c754
     &lt;login&gt;
     shutdown -r now
     &lt;during reboot, may need to capture F12 to boot from harddrive, and select OpenStack kernel&gt;
     &lt;if chef-client does not run from postscripts, run manually&gt;
    

     verify controller services: 
    
     ssh op1
     source /root/openrc
      nova-manage service list
    
    
     service quantum-server status  
     &gt;&gt;&gt; if still dead, verify previous fix:
         yum install openstack-quantum-openvswitch
     ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini
     service quantum-server restart
    

  


### Standup OpenStack on network node

Standup OpenStack on network node: 
    
     chdef op2 provmethod=RH64_with_chef_kit
     updatenode op2
    

     Fix quantum before the reboot: 
    
     ssh op2
    
    
     ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini
     vi /etc/quantum/quantum.conf:
     ### comment out following lines (may be listed multiple times):
     #rpc_backend = quantum.openstack.common.rpc.impl_qpid
     #qpid_hostname =
    
    
     Being put in by quantum setup scripts (NOT the cookbooks):
     quantum-dhcp-setup
     quantum-l3-setup
     quantum-node-setup
     Need to edit these scripts after the quantum rpms are installed so that subsequent chef-client runs do not revert the quantum.conf back.
    

     turn off the auto run of chef-client on reboot: 
    
     chdef op2 provmethod=RH64_no_chef_kit
    

     Reboot the node: 
    
     rcons op2
     &lt;login&gt;
     shutdown -r now
     &lt;during reboot, may need to capture F12 to boot from harddrive and select OpenStack kernel&gt;
    

     Configure the network bridge: 
    
     updatenode op2 -P 'confignics --script configbr-ex'  
     (will hang updatenode cmd, need to kill it;  keep rcons to node open, run 'service network restart')
    

     Re-run the chef-client on the node to redo any necessary configs that might have needed the new kernel and to properly start openvswitch 
    
     ssh op2
     chef-client
    

     Fix quantum again if necessary: 
    
     ssh op2
    
    
     ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini
     vi /etc/quantum/quantum.conf:
     ### comment out following lines (may be listed multiple times):
     #rpc_backend = quantum.openstack.common.rpc.impl_qpid
     #qpid_hostname =
    
    
     Being put in by quantum setup scripts (NOT the cookbooks):
     quantum-dhcp-setup
     quantum-l3-setup
     quantum-node-setup
     Need to edit these scripts after the quantum rpms are installed so that subsequent chef-client runs do not revert the quantum.conf back.
    
    
     # re-run chef to fix quantum and openvswitch
     chef-client
    
    
     # verify openvswitch/quantum and restart any service not running:
     service openvswitch status
     service quantum-l3-agent status
     service quantum-openvswitch-agent status
     service quantum-dhcp-agent status
     service quantum-metadata-agent status
    

### Standup OpenStack on compute node

Standup OpenStack on compute node: 
    
     chdef op3 provmethod=RH64_with_chef_kit
     updatenode op3
    

     fix quantum before the reboot: 
    
     ssh op3
    
    
     ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini
     vi /etc/quantum/quantum.conf:
     ### comment out following lines (may be listed multiple times):
     #rpc_backend = quantum.openstack.common.rpc.impl_qpid
     #qpid_hostname =
    
    
     Being put in by quantum setup scripts (NOT the cookbooks):
     quantum-dhcp-setup
     quantum-l3-setup
     quantum-node-setup
     Need to edit these scripts after the quantum rpms are installed so that subsequent chef-client runs do not revert the quantum.conf back.
    

     turn off the auto run of chef-client on reboot: 
    
     chdef op3 provmethod=RH64_no_chef_kit
    

     Reboot the node: 
    
     rcons op3
     &lt;login&gt;
     shutdown -r now
     &lt;during reboot, may need to capture F12 to boot from harddrive and select OpenStack kernel&gt;
    
    
     ### rerun the chef-client to redo any necessary configs that might have needed the new kernel
     chef-client
    

  


### Use OpenStack

Continue following the Per Tenant example in the [Deploying_OpenStack] doc: 

     On the controller node, check all services and fix any not running: 
    
     source /root/openrc
     nova-manage service-list
     quantum net-list
     nova secgroup-list
    
    
     nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
     nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0
     nova secgroup-add-rule default udp 1 65535 0.0.0.0/0
    
    
     glance image-create --name cirros --is-public true --container-format bare --disk-format qcow2 --location https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
    
    
     glance image-list
    

     Create the external network and its subnet by admin user: 
    
     quantum net-create ext_net --router:external=True
    
    
     quantum subnet-create --name ext_subnet --allocation-pool start=10.11.107.1,end=10.11.107.20 --gateway 10.11.0.204 ext_net 10.11.0.0/16 -- --enable_dhcp=False
    

  


     Create a new tenant 
    
     keystone tenant-list
     keystone tenant-create --name tenantB
     TENANTB_ID=`keystone tenant-list | grep tenantB | awk  '{print $2}'`
    

     Create a new user and assign the member role to it in the new tenant (keystone role-list to get the appropriate id): 
    
     keystone user-create --name=user_b --pass=user_b --tenant-id ${TENANTB_ID} --email=user_b@domain.com
     USER_B_ID=`keystone user-list | grep user_b | awk '{print $2}'`
     Member_ID=`keystone role-list  | grep Member | awk '{print $2}'`
     keystone user-role-add --tenant-id ${TENANTB_ID} --user-id ${USER_B_ID} --role-id ${Member_ID}
    

     Create a new network for the tenant: 
    
     quantum net-create --tenant-id ${TENANTB_ID} tenantb-net
     TENANTB_NET_ID=`quantum net-list | grep tenantb-net| awk '{print $2}'`
     
    

     Create a new subnet inside the new tenant network: 
    
     quantum subnet-create --name tenantb-subnet --tenant-id ${TENANTB_ID} tenantb-net 192.168.1.0/24
     TENANTB_SUBNET_ID=`quantum subnet-list | grep  tenantb-subnet | awk '{print $2}'`
    

     Create a router for the new tenant: 
    
     quantum router-create --tenant-id ${TENANTB_ID} tenantb_router
     
    

     Add the router to the subnet: 
    
     quantum router-interface-add tenantb_router  ${TENANTB_SUBNET_ID}
     quantum router-gateway-set tenantb_router ext_net
    

     Create creds for tenant: 
    
     ###  CHANGE OS_AUTH_URL to my controller IP:
     ### echo -e "export OS_TENANT_NAME=tenantB
     ### export OS_USERNAME=user_b
     ### export OS_PASSWORD=user_b
     ### export OS_AUTH_URL=\"http://100.3.1.8:5000/v2.0/\"" &gt;  /root/creds_tenantB_rc
     echo -e "export OS_TENANT_NAME=tenantB
     export OS_USERNAME=user_b
     export OS_PASSWORD=user_b
     export OS_AUTH_URL=\"http://10.11.0.244:5000/v2.0/\"" &gt;  /root/creds_tenantB_rc
    
    
     source /root/creds_tenantB_rc
    

     Create virtual machine: 
    
     nova  boot --image cirros --flavor 1 --nic net-id=${TENANTB_NET_ID}  tenant_b_testvm1
    
    
     TENANTB_TESTVM1_ID=`nova list | grep tenant_b_testvm1 | awk '{print $2}'`
    

     Create a floating IP: 
    
     quantum floatingip-create ext_net
    
    
     ####  CHANGE IP to grep for
     ###FLOATINGIP_ID_JUST_CREATED=`quantum floatingip-list | grep 9.114 | awk '{print $2}'`
     FLOATINGIP_ID_JUST_CREATED=`quantum floatingip-list | grep 10.11 | awk '{print $2}'`
    
    
     #Get the port ID of the VM with ID
     VM_PORT_ID_JUST_GOT=`quantum  port-list -- --device_id  ${TENANTB_TESTVM1_ID} | grep subnet_id | awk '{print $2}'`
    
    
     #quantum floatingip-associate d7d3fb7e-b00a-4cb6-bbed-e379ab22119b d8003e37-e5cc-4222-9eb8-18e99a0310da
     quantum floatingip-associate ${FLOATINGIP_ID_JUST_CREATED}  ${VM_PORT_ID_JUST_GOT}
    
    
     ###  NEED TO DO THIS AGAIN HERE AS TENANTB????
     #Add this security rules to make your VMs pingable:
     nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
     nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0
     nova secgroup-add-rule default udp 1 65535 0.0.0.0/0
    
    
     ### waiting about 1 minute, you can run nova list to check the vm with 2 IPs
     nova list
    

     test connection: 
    
     ping 10.11.107.2
    

     Log onto new VM: 
    
     ssh cirros@10.11.107.2
      pw:   cubswin:)
    
