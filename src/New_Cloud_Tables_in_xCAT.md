<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Tables (in 2.8.2)](#tables-in-282)
  - [cfgmgt Table](#cfgmgt-table)
  - [clouds Table](#clouds-table)
  - [cloud Table](#cloud-table)
- [xCAT-openstack rpm (in 2.8.2)](#xcat-openstack-rpm-in-282)
- [Use of the Table Data](#use-of-the-table-data)
  - [Workflow of Deploy Openstack with Chef (implemented in xCAT 2.8.3&nbsp;?)](#workflow-of-deploy-openstack-with-chef-implemented-in-xcat-283&nbsp)
  - [Workflow of Deploy Openstack with Puppet (in xCAT 2.8.3&nbsp;?)](#workflow-of-deploy-openstack-with-puppet-in-xcat-283&nbsp)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

Note: this is a very rough strawman for this mini-design. Still needs work. 


## Background

In order for xCAT to automate some of the steps of setting up a cloud based on openstack, it needs some information about the cloud and the chef/puppet configuration that should be set up. This design describes the tables that should exist in xcat for this purpose and a little bit about what each attribute will be used for. The assumption is that the user would fill out these tables before using xcat and chef/puppet to set up the cloud. 

## Tables (in 2.8.2)

### cfgmgt Table

Add the new table cfgmgt in xCAT, and it will be in xCAT by default. It's not in the xCAT-Openstack-xx.rpm This table is used for puppetserver and chefserver . 

  * **node** \- the node name of chef-client(or puppet-client). This is the key. 
  * **cfgmgr** \- puppet or chef 
  * **cfgserver** \- the node name of chef-server or puppet-server 
  * **roles** \- call it **cfgmgtroles** in the node def object. a comma-separated list of roles this node will have. These role names map to the chef/puppet recipes that should be run for this node. From chef point, each role you specify would have a list of recipes it requires. Take openstack cookbooks as an example, there are some roles,such as: mysql-master, keystone, glance, nova-controller, nova-conductor, cinder-all. Users can add their roles into the cookbooks. Once one role is updated to the chef-server, and it can be assigned to the chef-client node. 

### clouds Table

We need to support xcat setting up more than one cloud. A typical case would be they have a production cloud and a test cloud. So we will list the clouds in the clouds table: 

  * **name** \- user specified cloud name. This is the key for the table. 
  * **controller** \- node name of the controller node. 
  * **publicnet** \- name of network in networks table to be used for the openstack public network 
  * **novanet** \- name of network in networks table to be used for the openstack nove network 
  * **mgtnet** \- name of network in networks table to be used for the openstack management network 
  * **vmnet** \- name of network in networks table to be used for the openstack vm network 
  * **adminpw**
  * **dbpw**

### cloud Table

This is a node oriented table, storing cloud info for each node. 

  * **node** \- the node name. This is the key. 
  * **cloudname** \- the cloud this node is in. This points to the clouds.name attribute. 

## xCAT-openstack rpm (in 2.8.2)

The xCAT-openstack rpm will be a meta-meta rpm. It would include the cloud tables and chef &amp; puppet recipes specific to openstack and then require the xCAT rpm so it would pull in all of xcat. 

## Use of the Table Data

When nodeset or updatenode is run, xcat will pull info from these tables and plug the info in the correct places in the chef/puppet recipes. 

In addition, the mypostscript.tmpl file will include environment variables for the chef/puppet server (from the noderes table), so that the chef/puppet postscript will no who to contact. 

### Workflow of Deploy Openstack with Chef (implemented in xCAT 2.8.3&nbsp;?)

1 Install the chef-server/chef-client: 

1.1 If the chefserver node is not installation, install the chef-server during postbootscripts when OS provision; otherwise, just need to run "updatenode" to install the chef-server 

1.2 If the chefclient node is not installation, install the chef-client during postbootscripts when OS provision; otherwise, just need to run "updatenode" to install the chef-client. 

Refer to [Adding_Chef_in_xCAT_Cluster] to get more information. 

2\. Configure the chef-server 

2.1 Prepare the chef-cookbooks 

The chef-cookbooks will be on the MN firstly, and then distribute them to each chef-server. The users can use scp or xdcp to do the distribution. After that, the cfgmgt.path which is used to specify the cookbooks/recipes paths on the chef-server should be updated. (jjh: I think we can put the chef-cookbooks in the /install/chef directory on MN. And the distribution could be done by the script config_ops_chef_server automatically . Considering there are not so much chef-server, so the performance will not be an issue. What do you think of it?) 

And the mypostscript.tmpl file will include environment variables for the chef server. 

publicnet, novanet, mgtnet,vmnet,adminpw,dbpw, cfgmtgpath, chef-client-list, roles_of_&lt;each_chef_client&gt;

Run "updatenode &lt;chef-server-noderange&gt; -P config_ops_chef_server" . The script config_ops_chef_server will 
    
     (1)generate chef environment file
     (2)use knife command to load the environment file
     (3)apply the environment name to the chef-client nodes
     (4)upload the cookbooks/roles
     (5)assign the roles to the chef-client. 
    

If we want to do only one action, we can specify the argument for config_ops_chef_env. 

3\. Run "chef-client" on each client node to deploy the openstack. 
    
     xdsh &lt;controller-noderange&gt; -s chef-client 
     xdsh &lt;computer-noderange&gt; -s chef-client 
    

Currently, there are many outputs of chef-client. If there are many nodes, the output of xdsh may be not easy to read directly. 

### Workflow of Deploy Openstack with Puppet (in xCAT 2.8.3&nbsp;?)

Under construction. 

## Other Design Considerations

  * **Required reviewers**: Bruce, Linda, Ling, Guang Cheng and Jie Hua. 
  * **Required approvers**: Bruce Potter 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
