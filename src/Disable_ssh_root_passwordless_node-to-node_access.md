<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [1\. Overview](#1%5C-overview)
- [2\. Site Table Attribute](#2%5C-site-table-attribute)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

## 1\. Overview

xCAT when it installs a node, always sets up root passwordless ssh between the nodes and service nodes. This design will allow the admin to limit which nodes , other than service nodes, the root passwordless ssh will be setup during install and running xdsh -K. 

## 2\. Site Table Attribute

A new attribute sshbetweennodes is defined for xCAT 2.6 site table. This attributes defaults to ALLGROUPS, which means we setup ssh between all nodes as in the past. This attribute can be used to define a comma-separated list of groups and only the nodes in those groups will be setup with ssh between the nodes. The attribute can be set to NOGROUPS, to indicate no nodes (groups) will be setup. Service Nodes will always be setup with ssh between service nodes and all nodes. It is unaffected by this attribute. This also only affects root userid setup and does not affect the setup of devices. 

This setting of site.sshbetweennodes will only enable root ssh between nodes of the compute1 and compute 2 groups and all service nodes. 
    
    "sshbetweennodes","compute1,compute2",,
    
