<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Terminology](#terminology)
- [External](#external)
- [Internal](#internal)
  - [Databags in OpenStack-Chef-Cookbooks](#databags-in-openstack-chef-cookbooks)
  - [loadclouddata enhancement](#loadclouddata-enhancement)
  - [Templates improvement for Databag](#templates-improvement-for-databag)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

  



## Introduction

This mini-design discusses that using chef databag to support for deploying OpenStack in xCAT. In xCAT 2.8.3, xCAT used OpenStack-Chef-Cookbooks to deploy clouds in xCAT clusters. And the password of each account for different components is default. This is develop mode. If "develop_mode=false", the OpenStack chef cookbooks need chef databag. 

For the general chef databag knowledge, we can get more information from 
    
      http://docs.opscode.com/essentials_data_bags.html
      http://docs.opscode.com/knife_data_bag.html
    

This doc discusses how to make the chef databag work in OpenStack-Chef-cookbook. 

## Terminology

**Data Bag**: A data bag is a global variable that is stored as JSON data and is accessible from the chef-server node. The contents of a data bag can vary, but they often include sensitive information (such as database passwords). The xCAT scripts use [[knife](http://docs.opscode.com/knife_data_bag.html)] command to create the databag. Before we run the command, it's required to prepare the data bag folders and data bag item JSON files. 

**Secret Keys**: Encrypting a data bag requires a secret key. A secret key can be created in any number of ways. xCAT script use OpenSSL to generate a random number, which can then be used as the secret key. 

## External

loadclouddata is a postscript of updatenode to update the cookbooks, roles, environment files and chef-client nodes. To support the databag, the postscript loadclouddata will update the databag into the chef-server. Currently, databag is experimental, so I add the option --nodevmode in loadclouddata. When running the following command: 
    
      updatenode &lt;chef-server-nodes&gt;  "loadclouddata --nodevmode"
    

It will update the cookbooks, roles, environment files, chef-client nodes, and databags into the chef-server nodes. 

  


## Internal

### Databags in OpenStack-Chef-Cookbooks

The OpenStack-Chef-Cookbooks are in /install/chef-cookbooks/grizzly-xCAT/ of xCAT management node. And the community version for grizzly is in https://github.com/stackforge . Currently, there isn't any document to introduce how to use databag in OpenStack-Chef-Cookbook. I made an investigation, and I made a summary. There are 4 different databags: 
    
       db_passwords, service_passwords, user_passwords, and secrets
    

**db_passwords** provides the password of each user (always the OpenStack component name) for each OpenStack component database. 

**service_passwords** provides the passwords for the users of services in keystone, such as quantum, nova, glance and cinder. these passwords will be in some configuration file, such as /etc/nova/nova.conf 

**user_passwords** provides the **guest** password of message queue, and the "admin" password for identify (keystone). 

**secrets** provides bootstrap_token for keystone when register services and endpoints, and provide for quantum_metadata_proxy_shared_secret. 

We need to prepare the databag directories and databag items. 

Take db_passwords for example, the directory structure is as follows 
    
     [root@oscn12 databags]# tree db_passwords
     db_passwords
     |-- ceilometer_password.json
     |-- cinder_password.json
     |-- glance_password.json
     |-- horizon_password.json
     |-- keystone_password.json
     |-- nova_password.json
     `-- quantum_password.json
                               
     0 directories, 7 files
    

There are 7 databag items in the databag db_passowords. The content of the databag item is very simple, take keystone_password.json as an exmaple: 
    
     [root@oscn12 db_passwords]# cat keystone_password.json
     {
       "id": "keystone",
       "keystone": "xcatcloud"
     }
    

Note: The OpenStack-Chef-Cookbooks are being updated, the databag names or databag items may be changes. 

  


### loadclouddata enhancement

The postscript "loadclouddata --nodevmode" will update the databags into the chef-server nodes. The basic workflow is as follows: 

  1. generate the secret key 
  2. check if the key path in the /root/.chef/knife.rb , if not, add it 
  3. clear all the old databags 
  4. create the databag based on the secret key 
  5. upload each databag item in the databag based on the secret key 

### Templates improvement for Databag

Currently, the cloud_environment template files grizzly_allinone.rb.tmpl and grizzly_per-tenant_routers_with_private_networks.rb.tmpl are not support for databag. To support databag, we should add the following into the template files: 
    
     ...
     "developer_mode" =&gt; false,
     "secret"=&gt;{
         "key_path"=&gt;"/etc/chef/encrypted_data_bag_secret"
      },
     ...
    

  


## Other Design Considerations

  * **Required reviewers**: Bruce, Linda, Guang Cheng, Gao Ling, Sun Jing and etc. 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
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
