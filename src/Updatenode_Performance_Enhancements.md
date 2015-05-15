<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Postscripts Performance and Scaling Enhancement](#postscripts-performance-and-scaling-enhancement)
  - [Put /install/postscripts in diskless images as /xcatpost](#put-installpostscripts-in-diskless-images-as-xcatpost)
  - [Add Option to Create mypostscripts Ahead of Time](#add-option-to-create-mypostscripts-ahead-of-time)
  - [Add a Template for mypostscript](#add-a-template-for-mypostscript)
    - [The Template for mypostscript](#the-template-for-mypostscript)
  - [Remove first sleep in postscript process](#remove-first-sleep-in-postscript-process)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Postscripts Performance and Scaling Enhancement

Note: this design is for xCAT 2.8 and 2.9 release 

This specific enhancement applies to more than just updatenode, but the discussion about it was started during the updatenode enhancement work, so it is documented in this design. 

To improve the performance/scaling of getting &amp; running postscripts during node deployment and updatenode, we propose adding the following: 

### Put /install/postscripts in diskless images as /xcatpost

This could be implemented in 2.9 

Since today we use the -N flag of wget to download the postscripts, it will only download files that are newer than what is on the node. And since, be default, we don't remove /xcatpost, updatenode should normally not have to download anything. But for each boot of diskless nodes, they don't have /xcatpost yet. We should enhance packimage and liteimg to copy /install/postscripts into the image at /xcatpost. This way, only postscripts that have changed since then will have to be downloaded by wget. 

### Add Option to Create mypostscripts Ahead of Time

This is implemented in 2.8 and later The biggest load on the MN/SN during the postscript phase of deploying a lot of nodes is xcatd handling the getpostscript.awk request and querying the db for all of the db attrs needed. We could add a site attribute (maybe called precreatemypostscripts?) to instruct xcat at nodeset and updatenode time to query the db once for all of the nodes passed into the cmd and create the mypostscript file for each node and put them in a directory in /tftpboot. (This would be similar to the processing of the template files and creating the node-specific files in /install/autoinst.) 

BTW, we want to put the mypostscript files in /tftpboot instead of /install, because in general we want to move in the direction of having all of the node-specific info in /tftpboot and have /install as just generic data. We've had a wish list item about this for years ([Wish_List_for_xCAT_2#Someday...]). Even though we haven't done this item, we at least don't want to go in the opposite direction. Plus, if we put the mypostscript files in /install, then the user has to know when to rsync /install if they don't have /install mounted (like in the nfs-based statelite case). 

Nodeset and updatenode should call a function in Postage.pm that can handle doing this for a list of nodes. The best approach is for Postage::makescript to be modified so that it can be called with a single node or with an array of nodes. This way we still have the logic of querying the db attrs and building mypostscripts in 1 place. The traditional getpostscript.pm plugin can call it with a single node, and nodeset and updatenode can call it will a list of nodes (when precreatemypostscripts is set). Nodeset/updatenode would also have to be hierarchically smart to call it either on the MN or SNs, depending on the value of site.sharedtftp. And it would have to decide which SNs based on SN pools, like the tftpboot stuff works today. 

We would instruct users in the Large Scale Clusters doc to set site.precreatepostscripts and they would have to know to rerun nodeset if they changed db attrs that the postscripts use. For this reason, we would also recommend that they also set site.dhcpsetup=n so that nodeset wouldn't run makedhcp every time. 

The xcatdsklspost (and post.xcat for diskful) script would then try to first wget the node's mypostscript file in /tftpboot. If it is not available, then it would run getpostscript.awk in the traditional way. 

### Add a Template for mypostscript

This is implemented in 2.8 and later This isn't part of the performance enhancement, but is related function: we could add a template for the mypostscript like we have a template for the kickstart and autoyast files. This template could have the whole environment variable section with what db attrs should be plugged in for them. Postage.pm would process the template and add the list of postscript invocations. In this way, users could add additional db attrs that should be available to the postscripts. 

#### The Template for mypostscript

The mypostscript.tmpl will be put in {$XCATLROOT}/xcat/share/xcat/templates/mypostscript/ . If users customize the mypostscript.tmpl, they should copy the mypostscript.tmpl to {$INSTALLROOT}/postscripts/ , and then edit it. The mypostscript for each node will be named as mypostscript.nodename, and all the mypostscript.nodename will be put in the /tftpboot/mypostscripts/ directory. 

If site.precreatemypostscripts is set to 1 or yes, when run nodeset/updatenode, it will search the {$INSTALLROOT}/postscripts/mypostscript.tmpl firstly. If the {$INSTALLROOT}/postscripts/mypostscript.tmpl exists, it will use the template to generate mypostscript for each node. Otherwise, it will use {$XCATLROOT}/xcat/share/xcat/templates/mypostscript/mypostscript.tmpl 

**There are several different kinds of variables in the template.**

1\. For the simple variable, the syntax is as follows&nbsp;: 
    
     NODE=$NODE
     export NODE 
    

The $NODE will be matched by $node in our code. 

In the template, there is "NTYPE=$NTYPE", the $NTYPE is matched by the $ntype which is got in the code. The $NTYPE value can be "service" or "compute". "service" means this node is a service node. "compute" means this node is a compute node. 

So, notice that: for this simple variable, it should be matched by another variable which can be got in the code. 

2\. The value of one attribute from one table. The syntax is VARNAME=#TABLE:tablename:$NODE:attribute#. For example: 
    
      MACADDRESS=#TABLE:mac:$NODE:mac#
      export MACADDRESS
    

This syntax means that get the value of the attribute from the Table and its key is $NODE. It doesn't support the cases which table has 2 keys. 

3\. The value of one variable. There are some complex logic to get the values. The syntax is VARNAME=#Subroutine:modulename::subroutinename:$NODE# or VARNAME=#Subroutine:modulename::subroutinename#. For example: 
    
     NODESETSTATE=#Subroutine:xCAT::Postage::getnodesetstate:$NODE#
     export NODESETSTATE
    

4\. For the number of the variables is uncertain and the logic is complex. The syntax is #FLAG#. When parsing the template, it will call the one subroutine to generate them. For example: The values of all attributes from the site table. The tag is 
    
    #SITE_TABLE_ALL_ATTRIBS_EXPORT#
    

For the tag, the related subroutine will get the attributes' values and deal with the special case. such as&nbsp;: the site.master should be exported as ""SITEMASTER". And if the noderes.xcatmaster exists, the noderes.xcatmaster should be exported as "MASTER", otherwise, we also should export site.master as the "MASTER". 

5\. Get all the info from the specified table which doesn't include the log related table, "site" table, and "node as the key" table. The syntax is: 

tabdump(&lt;TABLENAME&gt;) 

The &lt;TABLENAME&gt; only could be non-"node key" table and two keys table, such as networks, passwd. And &lt;TABLENAME&gt; also couldn't be log related tables. The site table is used so frequent that the &lt;TABLENAME&gt; couldn't be the site table. And each attribute=value pair will be delimited by "||" . We may put special characters in the comments attribute. So the comments attribute will be put as the last in the list, and the parsing should be more carefull. 

In one table, if the key is the node, you should use #TABLE:tablename:$NODE:attribute#, instead of tabdump(). 

The content of the template for mypostscript: 
    
     ## beginning of all attributes from the site table
     #SITE_TABLE_ALL_ATTRIBS_EXPORT#
     ## end of all attributes from the site table
     ## One variable:
     ## There is a complex loglic to get the value of variable, and 
     ## if there is one subroutine in one module, 
     ## mark it as the following syntax.
     ENABLESSHBETWEENNODES=#Subroutine:xCAT::Template::enablesshbetweennodes:$NODE#
     export ENABLESSHBETWEENNODES
     ## tabdump(&lt;TABLENAME&gt;) is used to get all the information in the &lt;TABLENAME&gt; table
     ## The &lt;TABLENAME&gt; only could be non-"node key" table and two keys table, such as networks, passwd.
     ## And &lt;TABLENAME&gt; also couldn't be log related tables.
     ## The site table is used so frequent that the &lt;TABLENAME&gt; couldn't be the site table.
     ## And if the key is the node, you should use #TABLE...# instead of tabdump().
     ## We may put special characters in the comments attribute.
     ## So the comments attribute will be put as the last in the list,
     ## and the parsing should be more carefull.
     tabdump(networks)
     NODE=$NODE
     export NODE
     ## nfsserver,installnic,primarynic
     NFSSERVER=#TABLE:noderes:$NODE:nfsserver#
     export NFSSERVER
     INSTALLNIC=#TABLE:noderes:$NODE:installnic#
     export INSTALLNIC
     PRIMARYNIC=#TABLE:noderes:$NODE:primarynic#
     export PRIMARYNIC
     MASTER=#TABLE:noderes:$NODE:xcatmaster#
     export MASTER
     NODEROUTENAMES=#TABLE:noderes:$NODE:routenames#
     export NODEROUTENAMES
     ## examples:
     ## NFSSERVER=11.10.34.108
     ## export NFSSERVER
     ## INSTALLNIC=mac
     ## export INSTALLNIC
     ## PRIMARYNIC=mac
     ## export PRIMARYNIC
     ## The number of the variables is uncertain. In some case, it will be blank.
     ## Complex logic
     ## The syntax will be #FLAG#.
     #ROUTES_VARS_EXPORT#
     ## The details will be as follows or blank.
     ## NODEROUTENAMES=$NODE_routenames
     ## export NODEROUTENAMES
     ## ...
     ## osver, arch, profile export
     OSVER=#TABLE:nodetype:$NODE:os#
     export OSVER
     ARCH=#TABLE:nodetype:$NODE:arch#
     export ARCH
     PROFILE=#TABLE:nodetype:$NODE:profile#
     export PROFILE
     PROVMETHOD=#TABLE:nodetype:$NODE:provmethod#
     export PROVMETHOD
     PATH=`dirname $0`:$PATH
     export PATH
     NODESETSTATE=#Subroutine:xCAT::Postage::getnodesetstate:$NODE#
     export NODESETSTATE
     UPDATENODE=0
     export UPDATENODE
     NTYPE=$NTYPE
     export NTYPE
     MACADDRESS=#TABLE:mac:$NODE:mac#
     export MACADDRESS
     ## vlan related items. It may not be configured by the users. 
     #VLAN_VARS_EXPORT#
     ## the details of VLAN_VARS_EXPORT will be looked like:
     ## VMNODE='YES' 
     ## export VMNODE
     ## VLANID=vlan1...
     ## export VLANID 
     ## VLANHOSTNAME=..
     ## ..
     ## get monitoring server and other configuration data for monitoring setup on nodes
     #MONITORING_VARS_EXPORT#
     ## the details will be looked like as follows
     ## MONSERVER=11.10.34.108
     ## export MONSERVER
     ## MONMASTER=11.10.34.108
     ## export MONMASTER
     ## get the osimage related variables, such as ospkgdir, ospkgs ...
     #OSIMAGE_VARS_EXPORT#
     ## examples:
     ## OSPKGDIR=/install/rhels6.2/ppc64
     ## export OSPKGDIR
     ## OSPKGS='bash,nfs-utils,openssl,dhclient,kernel,openssh-server,openssh-clients,busybox,wget,rsyslog,dash,vim-minimal,ntp,rsyslog,rpm,rsync,
       ppc64-utils,iputils,dracut,dracut-network,e2fsprogs,bc,lsvpd,irqbalance,procps,yum'
     ## export OSPKGS
     ## get the diskless networks information. There may be no information.
     #NETWORK_FOR_DISKLESS_EXPORT#
     ## examples of NETWORK_FOR_DISKLESS_EXPORT
     ## the details will be looked like:
     ## NETMASK=255.255.255.0
     ## export NETMASK
     ## GATEWAY=9.114.34.108
     ## 
     ##
     ## Notice:  The following flag postscripts-start-here could not be deleted from the template!!!
     # postscripts-start-here
     #INCLUDE_POSTSCRIPTS_LIST#
     ## the details will be looked like:
     ##   #defaults-postscripts-start-here
     ##   run_ps syslog
     ##   run_ps remoteshell
     ##   run_ps syncfiles
     ##   #defaults-postscripts-end-here 
     ##   ....
     ## Notice:  The following flag postscripts-end-here could not be deleted from the template!!!
     # postscripts-end-here
     ## Notice:  The following flag postbootscripts-start-here could not be deleted from the template!!!
     # postbootscripts-start-here
     #INCLUDE_POSTBOOTSCRIPTS_LIST#
     ## Notice:  The following flag postbootscripts-end-here could not be deleted from the template!!!
     # postbootscripts-end-here
    

### Remove first sleep in postscript process

This will be implemented in 2.9 using new xcatd function "throttling mechanism". 

  


There is a sleep at the begining of xcatdsklspost (and post.xcat for diskful) for a node to wait for a random amount of time. This was added there so that the node will not connect to the server at the same time for wget and for getpostscripts. Now we have changed wget to use http instead of vsftp, it is more reliable. Since we are using site table variables to stagger rpower command for node deployment and using xdsh fanout to stagger the updatenode command, it is not a problem any more for nodes to send the requests to the server all at the same time. Hence we can remove this first sleep. 
