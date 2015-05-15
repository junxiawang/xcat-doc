<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Install a new Kernel on the nodes](#install-a-new-kernel-on-the-nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Install a new Kernel on the nodes

Using a postinstall script ( you could also use the updatenode method): 
    
    mkdir /install/postscripts/data
    cp &lt;kernel&gt; /install/postscripts/data
    

Create the postscript updatekernel: 
    
    vi /install/postscripts/updatekernel
    

Add the following lines to the file 
    
    #!/bin/bash
    rpm -Uivh data/kernel-*rpm
    

Change the permission on the file 
    
    chmod 755 /install/postscripts/updatekernel
    

Add the script to the postscripts table and run the install: 
    
    chdef -p -t group -o compute postscripts=updatekernel
    rnetboot compute
    
