<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Basic Idea](#basic-idea)
- [External User Interface](#external-user-interface)
- [Internal Implementation](#internal-implementation)
  - [ddns.pm](#ddnspm)
- [Documentation Change](#documentation-change)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Background

This requirement is from the scenario where the users want to use xcat SN as DNS failover, but current xcat DNS structure can not support it because current SN acts as DNS forwarding/caching server, so when MN goes down, SN can not be working independently. See more details in [bug3863 ](https://sourceforge.net/p/xcat/bugs/3863/)

## Basic Idea

Using DDNS master/slave configuration can meet this requirement, after making corresponding configuration on DNS master/slave(/etc/named.conf), the master allows to transfer DNS zones to the DNS slaves, it means when DNS records are updated dynamically(for example, makedns &lt;noderange&gt; is issued), the auto-sync will be done between the master and slaves without xcat's involvement. So this can make sure DNS records synced between MN and SNs, even MN goes down, SNs can be working for name resolution. 

## External User Interface

  * add to the servicenode.nameserver attribute an additional valid value, 2, that means make it a slave dns (a value of 1 will still mean a forwarding dns). 
  * makedsn -n can check to see if there are any SNs defined in the servicenode table with nameserver=2, and if so, add them to MN's named.conf. 
  * if they add their SN definitions in the db after they initially ran makedns -n, then they need to run makedns -n again after adding the SNs. 
  * for the config of named.conf on the SN, it can still be done by AAsn.pm when xcatd starts on the SN. 

This setting(servicenode.nameserver=2) only impacts the behavior of "makedns -n" to generate a different /etc/named.conf supporting dns master/slave mode, "makedns &lt;noderange&gt;" or "makedns -d &lt;noderange&gt;" can just keep the current logic to update DNS records on MN(DNS master), then named will be responsible to transfer/sync them to slaves. 

## Internal Implementation

### ddns.pm

The code change in ddns.pm impacts /etc/named.conf on MN(dns master). 

Modify the logic for /etc/named.conf generation, get servicenode.nameserver value, if it's 2, indicates servicenode.node(can be noderange or nodegroup) should be set as dns slave, generate /etc/named.conf as below (only list the difference here). 
    
    # diff /etc/named.conf.master_slave /etc/named.conf.org
    7,9d6
    &lt;slave IP1&gt;; &lt;slave IP2&gt;;...};
    &lt;slave IP1&gt;; &lt;slave IP2&gt;;...};
    45d41
    &lt;master_IP&gt;; };
           file "db.xx.xx";
    };
    

## Documentation Change

Since there is user interface change for this implementation, so the documentation [Cluster Name Resolution](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=Cluster_Name_Resolution#Option_.233:_Run_DNS_on_Management_Node_and_Service_Nodes) needs to be updated accordingly. 

Need to add comments in the Schema.pm file for the servicenode table ( nameserver attribute) for this new setting, so it will show up on man servicenode. 

## Other Design Considerations

  * **Required reviewers**: xCAT ALL 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: Yes 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: Yes 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
