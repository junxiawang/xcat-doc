<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Overview**](#overview)
- [**xcatconfig**](#xcatconfig)
- [xdcp/xdsh](#xdcpxdsh)
- [updatenode](#updatenode)
  - [Interface](#interface)
  - [Syncfiles and postscripts](#syncfiles-and-postscripts)
  - [Installing/updating packages](#installingupdating-packages)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## **Overview**

In release 2.8, we are adding the ability to managed the xCAT Management Node with xCAT on the Management Node. Although it is a special node and some function is restricted, like updatenode -k, we would like to be able to run other xCAT command to update the Management Node. 

  
The following sections outline a design for the additional xCAT functions that should be able to run on the Management Node. 

## **xcatconfig**

The first step was defining the Management Node in the xCAT database. Function has been added in xcatconfig to define the Management node in the database such tht xCAT commands have a reliable way to recognize it as the Management node. To do this run: 
    
    xcatconfig -m
    

## xdcp/xdsh

xdcp and xdsh should be able to run on the Management node with the Management Node in the noderange. They accomplish this by not using ssh or scp. If xdcp is used, then it will either use the cp function or the rsync function locally. If xdsh is used, it will use the local shell. The one exception to this is the xdsh -K command to update ssh keys which is denied on the Management node. (TBD are there other exceptions?) 

## updatenode

updatenode should be able to run syncfiles, postscripts and install rpms. updatenode -k will not be supported to a Management Node. 

### Interface

&lt;s&gt;A new option would be added to updatenode. This option (-m) would replace the noderange and indicate the function is being run the the Management Node. It could not be combined with a noderange. &lt;/s&gt;
    
    updatenode -m 
    updatenode -m -F
    updatenode -m -P
    updatenode -m -P myscript
    

### Syncfiles and postscripts

Currently updatenode requires a defined synclist in a defined image for the node, to know what synclist to run. It runs the postscripts defined for the nodes per the postscripts table. Since the Management Node today does not have a defined image in provmethod, I am suggesting we enhance the setup of the Management Node (MN) in the database to include defining a special **osimage** name for the MN. This would allow us a place to store the synclist file location and a list of postscripts and postbootscripts. I think in most cases the ones defined in the postscripts table (especially the defaults) would not apply to the MN. 
    
    tabdump osimage
    #imagename,groups,profile,imagetype,provmethod,rootfstype,osname,osvers,osdistro,
    osdistroupdates,osarch,synclists,postscripts,postbootscripts,serverrole,comments,disable
    

### Installing/updating packages

Need to design the setup of packages/kits to be installed on the Management Node. 
