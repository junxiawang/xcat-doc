<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Get all defined network object](#get-all-defined-network-object)
- [Get one network object's detail information](#get-one-network-objects-detail-information)
- [Get one network object's specified attribute](#get-one-network-objects-specified-attribute)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Get all defined network object
    
    GET https://127.0.0.1/xcatws/networks/?userName=xxx&password=xxx

Return all of the defined network object name. 

xxx_xxx_xxx_0-255_255_255_0 (network)

xxxx:xxxx:xxxx:xxxx::/64 (network)

### Get one network object's detail information
    
    GET https://127.0.0.1/xcatws/networks/xxx_xxx_xxx_0-255_255_255_0?userName=root&password=cluster

Retrun network object xxx_xxx_xxx_0-255_255_255_0's attribute name and value. 

Object name
xxx_xxx_xxx_0-255_255_255_0

gateway
xxx.xxx.xxx.xxx

mask
255.255.255.0

mgtifname
eth0

net
xxx.xxx.xxx.0

tftpserver
xxx.xxx.xxx.xxx

### Get one network object's specified attribute
    
    GET https://127.0.0.1/xcatws/networks/xxx_xxx_xxx_0-255_255_255_0?userName=root&password=cluster&field=gateway&field=mask

Return the attribute name and value map which specified in the url request. For all currently supported attributes, you can refer the output of "
    
    lsdef -h -t network

". 

Object name
xxx_xxx_xxx_0-255_255_255_0

gateway
xxx.xxx.xxx.xxx

mask
255.255.255.0

  


  * The return format also support JSON and XML. 
