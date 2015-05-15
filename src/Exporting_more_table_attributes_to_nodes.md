{{:Design Warning}} 

This is a low priority item, we just like the put the design here so that it will not be lost. 

During the node deployment or updatenode -P command is called, a file called /xcatpost/mypostscripts (/xcatpost/myxcatpost_nodename for AIX) will be generated on the node which contains a list of postscripts to be run and some environmental variables. These environmental variables are mostly the node attributes that are defined in the xCAT tables. This file will be invoked on the node to run the given list of postscripts. 

Currently the following table attributes are exported in this file: 

  * site table 
  * noderes: nfsserver, installnic, primarynic, routenames, xcatmaster 
  * routes: net, mask, gateway, ifname 
  * nodetype: os, arch, profile, provmethod 
  * postscripts: postscripts, postbootscripts 
  * osimage: postscripts, postbootscripts 
  * linuximage: pkglist, pkgdir, otherpkglist, otherpkgdir 
  * mac: mac 
  * switch: vlan 
  * networks: vlanid, net, mask, gateway (for vlan) 
  * hosts: otherinterfaces (for vlan) 
  * vm: nics (for vlan) 
  * noderes.monserver (for monitoring) 
  * monsetting table (for monitoring) 

However, sometimes the user requests more attribute to be exported. This design provides a plugable way to allow them to do so without making code changes. A file called /install/custom/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;.envlist will be used. The format of the file will be: 
    
    table_name,attribute_name,selection_string,env_name
    

For example: 
    
     vpd,serial,,SERIAL
     vpd,uuid,
     vpd,mgm,,MYENV   
     networks,mgtifname,net=mynet,MNIC
       when env_name is omitted, it will be the same as the attribute name with call capital letters.
       when selection_string is omitted, it will default to node=&lt;this node&gt;
       when multi-lines are returned from a selection string, the environmental variables will be env_name_1, env_name_2 etc.
    

The Postage.pm will read this file, parse the contents and get the attributes from the tables efficiently. 
