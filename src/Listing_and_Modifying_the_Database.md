<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Database Commands and Tables](#database-commands-and-tables)
- [**xCAT Database Tables and Object Defs**](#xcat-database-tables-and-object-defs)
  - [**Object definitions**](#object-definitions)
- [Node Group Support in the xCAT Tables](#node-group-support-in-the-xcat-tables)
    - [**Searching precedence**](#searching-precedence)
- [Using Regular Expressions in the xCAT Tables](#using-regular-expressions-in-the-xcat-tables)
    - [Easy Regular expressions](#easy-regular-expressions)
    - [Verify your regular expression](#verify-your-regular-expression)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Database Commands and Tables

Note: some of these commands run on Linux and AIX, some are targeted only for AIX or Linux. 

  * [DB Tables](http://xcat.sourceforge.net/man5/xcatdb.5.html)\- Complete list of xCAT database tables descriptions. 
  * [chdef](http://xcat.sourceforge.net/man1/chdef.1.html) \- Change xCAT data object definitions. 
  * [chtab ](http://xcat.sourceforge.net/man8/chtab.8.html)\- Add, delete or update rows in the database tables. 
  * [dumpxCATdb](http://xcat.sourceforge.net/man1/dumpxCATdb.1.html) \- dumps entire xCAT database. 
  * [gettab](http://xcat.sourceforge.net/man1/gettab.1.html) \- searches through tables with keys and return matching attributes. 
  * [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) \- used to display xCAT object definitions which are stored in the xCAT database. 
  * [lsflexnode](http://xcat.sourceforge.net/man1/lsflexnode.1.html) \- Displays the information of a flexible node. ( 2.5 or later) 
  * [mkdef ](http://xcat.sourceforge.net/man1/mkdef.1.html) \- used to create xCAT data object definitions. 
  * [mkflexnode](http://xcat.sourceforge.net/man1/mkflexnode.1.html) \- Create a flexible node. ( 2.5 or later) 
  * [nodeadd](http://xcat.sourceforge.net/man8/nodeadd.8.html) \- Adds nodes to the xCAT cluster database. 
  * [nodech](http://xcat.sourceforge.net/man1/nodech.1.html) \- Changes nodes' attributes in the xCAT cluster database. 
  * [nodels](http://xcat.sourceforge.net/man1/nodech.1.html) \- lists the nodes, and their attributes, from the xCAT database. 
  * [noderm ](http://xcat.sourceforge.net/man1/noderm.1.html)\- removes the nodes in the noderange from all database table. 
  * [restorexCATdb](http://xcat.sourceforge.net/man1/restorexCATdb.1.html) \- restore the xCAT database. 
  * [rmdef ](http://xcat.sourceforge.net/man1/rmdef.1.html)\- remove xCAT data object definitions. 
  * [rmflexnode](http://xcat.sourceforge.net/man1/rmflexnode.1.html) \- Remove a flexible node. ( 2.5 or later) 
  * [runsqlcmd ](http://xcat.sourceforge.net/man1/runsqlcmd.8.html) \- Runs sql commands input from a file against the currect xCAT DB ( 2.5 or later) 
  * [tabdump](http://xcat.sourceforge.net/man8/tabdump.8.html) \- display an xCAT database table in CSV format. 
  * [tabedit](http://xcat.sourceforge.net/man8/tabedit.8.html) \- view an xCAT database table in an editor and make changes. 
  * [tabgrep](http://xcat.sourceforge.net/man1/tabgrep.1.html) \- list table names in which an entry for the given node appears. 
  * [tabprune](http://xcat.sourceforge.net/man8/tabprune.8.html) \- delete records from the eventlog and auditlog tables (2.4 or later). 
  * [tabrestore ](http://xcat.sourceforge.net/man8/tabrestore.8.html)\- replaces the contents of an xCAT database table with the contents in a csv file. 
  * [xcatstanzafile](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html) \- Format of a stanza file that can be used with xCAT data object definition commands. 
  * [Summary of all xCAT Commands](http://xcat.sourceforge.net/man1/xcat.1.html)

## **xCAT Database Tables and Object Defs**

The xCAT data that is used to manage a cluster is contained in a relational database. Different types of data are stored in different tables. You can manage this information directly using the set of table oriented commands provided by xCAT defined above. 

  
See [xcatdb](http://xcat.sf.net/man5/xcatdb.5.html) the man page for xcatdb 

### **Object definitions**

In addition to managing the database tables directly, xCAT also supports the concept of data object definitions. Data objects are abstractions of the data that is stored in the xCAT database. This support provides a conceptually simpler implementation for managing cluster data, (especially data associated with a specific cluster node). It is also more consistent with other IBM systems management products. The attributes and values defined in the data object definitions will still be stored in the database tables defined for xCAT. These data object definitions should not limit experienced xCAT customers from managing the specific tables directly, if they so desire. A new set of commands is provided to support the object definitions. These commands will automatically handle the storage in and retrieval from the correct tables. 

  
The following data object types are currently supported, as of xCAT 2.8. The list can be checked by running 
 
~~~~   
    lsdef -t
~~~~    

  * **auditlog** \- Information from the auditlog table 
  * **boottarget**\- Target profiles with their accompanying kernel parameters. 
  * **eventlog** \- Stores events that occurred. 
  * **firmware** \- firmware info 
  * **group** \- Defines a set of nodes. A group definition can be used as the target set of nodes for a specific xCAT operation. It can also be used to define node attributes that are applied to all group members. The group data is stored in multiple tables in the database. 
  * **kit** \- kit information. 
  * **kitcomponent** \- kitcomponent information 
  * **kitrepo** \- kitrepo information 
  * **monitoring** \- A description of a monitoring plugin. This data is stored in the _monitoring table. 
  * **network** \- A description of a unique network. This data is stored in the networks table. 
  * **node** \- Information for a specific cluster node. The data for a node is stored in multiple tables in the database. The commands that are provided to manage these definitions automatically figure out which attributes are stored in which table. It is therefore not necessary to keep track of a large number of table names and attribute locations.* **notification** \- Defines the Perl modules and commands that will get called for changes in certain xCAT database tables. The data is stored in the notification table. 
  * **osdistro** \- os distribution information 
  * **osimage** \- Defines a unique operating system image and related resources that are required for xCAT to deploy a cluster node. 
  * **policy** \- Controls who has authority to run specific xCAT operations. 
  * **rack** \- node rack location description 
  * **route** \- defined routes 
  * **site** \- Cluster-wide information. All the data is stored in the site table. 

  


There are four basic xCAT commands that may be used to manage any of the data object definitions. 

  * **mkdef** \- Make data object definitions. 
  * **chdef** \- Change data object definitions. 
  * **lsdef** \- List data object definitions. 
  * **rmdef** \- Remove data object definitions. 

In addition to the standard command line input and output the **mkdef**, **chdef**, and **lsdef** commands support the use of a stanza file format for the input and output of information. Input to a command can be read from a stanza file and the output of a command can be written to a stanza file. A stanza file contains one or more stanzas that provide information for individual object definitions. For example: 

  


  * To create a set of definitions using information contained in a stanza file. 

~~~~    
    cat mystanzafile | mkdef -z
~~~~    

  


  * To write all node definitions to a stanza file. 


~~~~
    
    lsdef -t node -l -z > nodestanzafile
~~~~    

  
The stanza file support also provides an easy way to backup and restore the cluster data. 

  
For more information on the use of stanza files see the xcatstanzafile man page. 

## Node Group Support in the xCAT Tables

The xCAT database has a number of tables, some with rows that are keyed by node name (such as noderes and nodehm) and others that are not keyed by node name (for example, the policy table). The tables that are keyed by node name (**except the nodelist table**) have some extra features that enable a more template-based style to be used: 

For example defined a list of nodes with the group compute: 
  
~~~~  
    mkdef -t node node1-node3 groups=compute
~~~~    

The group name, **compute** , can be used in lieu of a node name in the node field, and that row will then provide **default** attribute values for any node in that group. A row with a specific node name can then override one or more attribute values for that specific node. 

Now assign, some attributes to the entire group. 
  
~~~~  
     chdef -t group compute mgt=ipmi serialspeed=19200
~~~~    

Now check the nodes: 
  
~~~~  
      lsdef compute
     Object name: node1
        .
      serialspeed=19200   
        .
      Object name: node2
        .
      serialspeed=19200
        .
~~~~    

Assign a different attribute just to node1 
 
~~~~   
    chdef  node1 serialspeed=115200
~~~~    

Now check the node settings: 
 
~~~~   
     lsdef  compute
     Object name: node1
        .
      serialspeed=115200   
        .
      Object name: node2
        .
      serialspeed=19200
        .
~~~~    

In the nodehm table, you will see: 
    
 
~~~~   #node,power,mgt,cons,termserver,termport,conserver,serialport,serialspeed,serialflow,getmac,cmdmapping,comments,disable
    "compute",,"ipmi",,,,,,"19200",,,,,
    "node1",,,,,,,,"115200",,,,,
~~~~    

In the above example, the node group called compute sets mgt=ipmi and serialspeed=19200. The nodes (node1-node3), that are in this group, will have those attribute values, unless overridden. In this example, node2 is a member of compute, it will automatically inherit these attribute values (even though it is not explicitly listed in this table). In the case of node1 above, it inherits mgt=ipmi, but overrides the serialspeed to be 115200, instead of 19200. A typical way to use this capability is to create a node group for your nodes and for all the attribute values that are the same for every node, set them at the group level. Then you only have to set attributes for each node that vary from node to node. 

#### **Searching precedence**

When xCAT is searching a table for a value for a specific node, it will first look for a row that specifies the exact node name. If not found, it will then look for rows with a group that the node is a member of. It will search groups in the order that the groups are specified for that node in the nodelist table. For this reason, it will make most sense for you to list the groups in the nodelist table in order of most specific to most general. 

## Using Regular Expressions in the xCAT Tables

xCAT extends the group capability so that it can also be used for attribute values that vary from node to node in a very regular pattern. For example, if in the ipmi table you want the bmc attribute to be set to whatever the nodename is with ``-bmc appended to the end of it, then use this in the ipmi table:
   
~~~~ 
    #node,bmc,bmcport,taggedvlan,bmcid,username,password,comments,disable
    "compute","/\z/-bmc/",,,,,,,
~~~~    

In this example, **compute** is a node group that contains all of the compute nodes. The 2nd attribute (bmc) is a regular expression that is similar to a substitution pattern. The 1st part ``\z matches the end of the node name and substitutes ``-bmc, effectively appending it to the node name. 

Another example is if node1 is to have IP address 10.0.0.1, node2 is to have IP address 10.0.0.2, etc., then this could be represented in the hosts table with the single row: 

~~~~    
    #node,ip,hostnames,otherinterfaces,comments,disable
    "compute","|node(\d+)|10.0.0.($1+0)|",",,,
~~~~    

In this example, the regular expression in the ip attribute uses ``| to separate the 1st and 2nd part. This means that xCAT will allow arithmetic operations in the 2nd part. In the 1st part, ``(\d+), will match the number part of the node name and put that in a variable called $1. The 2nd part is what value to give the ip attribute. In this case it will set it to the string ``10.0.0. and the number that is in $1. (Zero is added to $1 just to remove any leading zeroes.)

A more involved example is with the mp table. If your blades have node names node01, node02, etc., and your chassis node names are cmm01, cmm02, etc., then you might have an mp table like: 

~~~~    
    #node,mpa,id,nodetype,comments,disable
    "blade","|\D+(\d+)|cmm(sprintf('%02d',($1-1)/14+1))|","|\D+(\d+)|(($1-1)%14+1)|",,
~~~~    

Before you panic, let me explain each column: 

blade 

This is a group name. In this example, we are assuming that all of your blades belong to this group. Each time the xCAT software accesses the mp table to get the management module and slot number of a specific blade (e.g. node20), this row will match (because node20 is in the blade group). Once this row is matched for node20, then the processing described in the following items will take place. 

~~~~
   |\D+(\d+)|cmm(sprintf('%02d',($1-1)/14+1))| 
~~~~

This is a perl substitution pattern that will produce the value for the second column of the table (the management module hostname). The text &#92;D+(&#92;d+) between the 1st two vertical bars is a regular expression that matches the node name that was searched for in this table (in this example node20). The text that matches within the 1st set of parentheses is set to $1. (If there was a 2nd set of parentheses, it would be set to $2, and so on.) In our case, the &#92;D+ matches the non-numeric part of the name (node) and the &#92;d+ matches the numeric part (20). So $1 is set to 20. The text cmm(sprintf('%02d',($1-1)/14+1)) between the 2nd and 3rd vertical bars produces the string that should be used as the value for the mpa attribute for node20. Since $1 is set to 20, the expression ($1-1)/14+1 equals 19/14 + 1, which equals 2. (The division is integer division, so 19/14 equals 1. Fourteen is used as the divisor, because there are 14 blades in each chassis.) The value of 2 is then passed into sprintf() with a format string to add a leading zero, if necessary, to always make the number two digits. Lastly the string cmm is added to the beginning, making the resulting string cmm02, which will be used as the hostname of the management module. 

~~~~
   |\D+(\d+)|(($1-1)%14+1)| 
~~~~

This item is similar to the one above. This substituion pattern will produce the value for the 3rd column (the chassis slot number for this blade). Because this row was the match for node20, the parentheses within the 1st set of vertical bars will set $1 to 20. Since % means modulo division, the expression ($1-1)%14+1 will evaluate to 6. 

See http://www.perl.com/doc/manual/html/pod/perlre.html for information on perl regular expressions. 

#### Easy Regular expressions

As of xCAT 2.8.1, you can use a modified version of the regular expression support described in the previous section. You do not need to enter the node information (1st part of the expression), it will be derived from the input nodename. You only need to supply the 2nd part of the expression to determine the value to give the attribute. For example: 

If node1 is to have IP address 10.0.0.1, node2 is to have IP address 10.0.0.2, etc., then this could be represented in the hosts table with the single row: 

Using **full** regular expression support you would put this in the hosts table. 

~~~~    
    chdef -t group compute ip="|node(\d+)|10.0.0.($1+0)|"
    tabdump hosts
    #node,ip,hostnames,otherinterfaces,comments,disable
    "compute","|node(\d+)|10.0.0.($1+0)|",,,,
~~~~    

Using easy regular expression support you would put this in the hosts table. 

~~~~    
    chdef -t group compute ip="|10.0.0.($1+0)|"
    tabdump hosts
    #node,ip,hostnames,otherinterfaces,comments,disable
    "compute","|10.0.0.($1+0)|",,,,
~~~~    

In the easy regx example, the expression only has the 2nd part of the expression from the previous example. xCAT will evaluate the node name, matching the number part of the node name, and create the 1st part of the expression . The 2nd part supplied is what value to give the ip attribute. The resulting output is the same. 

#### Verify your regular expression

After you create your table with regular expression, make sure they are evaluating as you expect. 

~~~~    
     lsdef node1 | grep ip
       ip=10.0.0.1
~~~~    
