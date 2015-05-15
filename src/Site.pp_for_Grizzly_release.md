This file is based on /etc/puppet/modules/openstack/tests/site.pp with a few fixes for Grizzly. 
    
    import "nodes/*"
    
    #
    # This document serves as an example of how to deploy
    # basic single and multi-node openstack environments.
    #
    
    # deploy a script that can be used to test nova
    class { 'openstack::test_file': }
    
    ####### shared variables ##################
    
    
    # this section is used to specify global variables that will
    # be used in the deployment of multi and single node openstack
    # environments
    
    $openstack_version    = 'grizzly'
    
    # assumes that eth0 is the public interface
    $public_interface        = 'eth0'
    # assumes that eth1 is the interface that will be used for the vm network
    # this configuration assumes this interface is active but does not have an
    # ip address allocated to it.
    $private_interface       = 'eth1'
    
    # credentials
    $admin_email             = 'root@localhost'
    $admin_password          = 'keystone_admin'
    $keystone_db_password    = 'keystone_db_pass'
    $keystone_admin_token    = 'keystone_admin_token'
    $nova_db_password        = 'nova_pass'
    $nova_user_password      = 'nova_pass'
    $glance_db_password      = 'glance_pass'
    $glance_user_password    = 'glance_pass'
    $rabbit_password         = 'openstack_rabbit_password'
    $rabbit_user             = 'openstack_rabbit_user'
    
    # networks
    $fixed_network_range     = '10.0.0.0/24'
    $floating_network_range  = '192.168.101.64/28'
    
    # servers
    $controller_node_address  = '192.168.101.11'
    
    # switch this to true to have all service log at verbose
    $verbose                 = false
    # by default it does not enable atomatically adding floating IPs
    $auto_assign_floating_ip = false
    
    # 
    
