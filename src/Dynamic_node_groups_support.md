{{:Design Warning}} 

This feature will enable the dynamic node group support for xCAT. 

1\. **Starting point:** nodegroup manpage is a good start point for us to interpret the dynamic node groups support. The manpage does indicate several implementation hints and most of the description in nodegroup manpage seems reasonable. 

2\. **Dynamic node group defintion location:** The table "nodegroup" is a perfect place to store the dynamic node group definition, and the nodegroup manpage also indicates that the table nodegroup can be used to store the dynamic node group definition.  
3\. **User interface changes:** The dynamic node&nbsp;: 1groups user interfaces can be grouped into two categories) create, display, modify, delete the dynamic node group definition. 2) Pass the dynamic node group to any xCAT command.  
To create, display, modify, delete the dynamic node group definition, the users can simply use tabedit, tabdump, chdef to achieve this. 

For example, the users can use tabedit or use mkdef/chdef to create/modify the dynamic node group definition. 
    
    mkdef -t group -o grp1 grouptype=dynamic -d -w "mgt=hmc" -w "hcp=c76v1hmc04"  
    

  
Note the mkdef command has been enhanced with the -d flag, see man mkdef. 

The dynamic node group behaves the same as the static node group when passing to the xCAT commands. For example, in command "nodels grp1", the grp1 can be dynamic node group or dynamic node group, it should not makes any difference.  
4\. **Selection string syntax:** The dynamic node groups selection string basic syntax is the same as the *def commands selection string syntax.A list of "attr*val" pairs, where the * can be "==", "=~", "!=" or "!~". Each -w flag will be followed by one pair. For example, the -w "mgthmc" -w "hcp=~c1hmc04".  
5\. **Coordinate with the static node groups:** Since the static node groups definition and the dynamic node groups definition are not stored in the same location, so there may be some confliction between the dynamic node groups and the static node groups. For example, if the node1 is included in dynamic node groups grp1, but the users can use _chdef -t node1 nodegroups=grp1_ to add node1 into grp1 statically, when the users trying to use chdef or mkdef to add a node to a dynamic node group manually, a warning message will be displayed to indicate that the the node group is a dynamic node group and should not add a node into a dynamic node group statically, when users run nodels   
**6\. manpage and documentation updates:** The nodegroup manpage needs to be updated to remove the "Not supported yet!". The mkdef manpage needs to be updated to enable the "-d | --dynamic" flag. Since the node group is used widely in the xCAT docs, plan to add a separate section to describe the dynamic/static node groups. 

Here is an example of using dynamic node group.  
[[root@xcatmn](mailto:root@xcatmn) ~]# tabdump nodegroup  


  1. groupname,grouptype,members,wherevals,comments,disable  


...  
"grp1","dynamic",,"mgt==hmc::hcp==c1hmc04",,   
[[root@xcatmn](mailto:root@xcatmn) ~]#  
[[root@xcatmn](mailto:root@xcatmn) ~]# nodels grp1   
c1fsp01  
c1fsp02  
[[root@xcatmn](mailto:root@xcatmn) ~]# 
