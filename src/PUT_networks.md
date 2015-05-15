<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [modify the specified nerwok object](#modify-the-specified-nerwok-object)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### modify the specified nerwok object
    
    PUT https://127.0.0.1/xcatws/networks/xxx_xxx_xxx_0-255_255_255_0?userName=root&password=cluster

With data:  

    
    ["nameservers=xxx.xxx.xxx.xxx",...,"gateway=xxx.xxx.xxx.xxx"]

"
    
    xxx_xxx_xxx_0-255_255_255_0

" is the network object name with need to be modified. "
    
    nameservers

" and "
    
    gateway

" are attributes for the network object. For all currently supported attributes, you can refer the output of "
    
    lsdef -h -t network

".
