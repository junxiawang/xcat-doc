<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Monitor installation**](#monitor-installation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### **Monitor installation**

It is possible to use the wcons command to watch the installation process for a sampling of the nodes: 
    
    wcons n1,n20,n80,n100
    

or rcons to watch one node 
    
    rcons n1
    

Additionally, nodestat may be used to check the status of a node as it installs: 
    
    nodestat n20,n21
    n20: installing man-pages - 2.39-10.el5 (0%)
    n21: installing prep
    

Note: the percentage complete reported by nodestat is not necessarily reliable. 

You can also watch nodelist.status until it changes to "booted" for each node: 
    
    nodels compute nodelist.status | xcoll
    

Once all of the nodes are installed and booted, you should be able ssh to all of them from the MN (w/o a password), because xCAT should have automatically set up the ssh keys (if the postscripts ran successfully): 
    
    xdsh compute date
    

If there are problems, see [Debugging_xCAT_Problems]. 
