<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [External Interface](#external-interface)
- [Internal Design](#internal-design)
- [Furture consideration](#furture-consideration)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


## External Interface

1\. Add a new flag "-n" to nodediscoverstart, to specify to run makedns &lt;nodename&gt; for any new discovered node. This is useful mainly for non-predefined configuration, before running the "nodediscoverstart -n", the user needs to run makedns -n to initialize the named setup on the management node. 

2\. Add a new argument osimage=xxx to nodediscoverstart, to specify the discovered nodes will be associated with the osimage and start the os provisioning automatically. 

3\. If the bmciprange is specified with nodediscoverstart, will setup the BMC for any new discovered nodes automatically during the sequential discovery process. A new flag "-s|--skipbmcsetup" is added to skip the bmcsetup, if the user does not want to run bmcsetup for whatever reason, could specify the "-s|--skipbmcsetup" with nodediscoverstart command to skip the bmcsetup. 

## Internal Design

1\. If the -n is specified with nodediscoverstart command, will add a new element "dns=yes" in site.__SEQDiscover, then the subroutine findme could check whether the dns=yes is in site.__SEQDiscover, if yes, run makedns &lt;nodename&gt; for any new discovered node. 

2\. The osimage=xxx will be added to site.__SEQDiscover by the existing code logic, the subroutine findme will know if the osimage=xxx is specified. In general, the osimage should be the last element in the chain attribute, if the osimage is not already in the chain attribute, sequential discovery code will append the osimage at the end of chain attribute; if the osimage is already in the chain attribute, sequential discovery code will replace the existing osimage name with the new one specified with nodediscoverstart command. 

3\. If the bmciprange in site.__SEQDiscover, the findme subroutine will add the runcmd=bmcsetup to the node's chain attribute. If the runcmd=bmcsetup is not already in the chain attribute of the node, sequential discovery code will add the runcmd=bmcsetup at the beginning of the chain attribute automatically; if the bmcsetup is already in the chain attribute of the node, then sequential discovery code will not add multiple runcmd=bmcsetup in the chain attribute. 

If the -s|--skipbmcsetup is specified with nodediscoverstart command, the nodediscoverstart subroutine will add the "skipbmcsetup=yes" to site.__SEQDiscover, the findme subroutine will check the skipbmcsetup and remove the runcmd=bmcsetup from the node's chain attribute. 

## Furture consideration

The current design of sequential discovery uses the groups=xxx with nodediscoverstart to inherit attributes from node groups, if the user needs to specify more node attributes for any new discovered node, the user could create node groups with the designated attributes, and specify the groups=xxx with nodediscoverstart the inherit the node attributes from the node group, this mechanism could work, but might be a little bit complex for the users, if we get customer requirements on simplifying this in the future, we could use the "free-form node attributes" with nodediscoverstart, like this: 

nodediscoverstart &lt;noderange&gt; attr1=val1 attr2=val2 attr3=val3 ... 

where the attr1,attr2,attr3,... are node attributes, the sequential discovery code will set the attributes for any new discovered nodes based on the arguments of nodediscoverstart. 

  


## Other Design Considerations

  * **Required reviewers**: Bruce Potter, Jarrod Johnson 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: profile disocvery 
  * **External interface changes, documentation, and usability issues**: update doc and manpage for nodediscover* command 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
