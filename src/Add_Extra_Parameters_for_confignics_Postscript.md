<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Requirement](#requirement)
- [Design](#design)
- [Implementation](#implementation)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

Requirement
----

The requirement comes from defect 3567 (http://sourceforge.net/p/xcat/bugs/3567/), "Extend confignics & configib to support connected mode and large MTUs."  The final result the user wants is to set the following for the network configuration file for a specific nic. 

     CONNECTED_MODE=yes
     MTU=65520


Design
----

1. As we know, the network configuration is setup by xCAT postscript *confignics* which in tern calls *configeth* and *configib* according to the *nictypes* defined in the *nics* table.  We can add code in configeth and configib to support CONNECTED_MODE and MTU as environmental variables and put these settings in the nic configuration file.  
2. CONNECTED_MODE and MTU values may be different for different nics. So we should have the env variables on a per nic base. 
3. How to pass the environment variables all the way from mn to *configeth* and configib postscripts on the node? 

Add a new *nics* table attributes called ***nicextraparams***. It will define the additional environmental variables that will be passed to the nic configuration scripts. The format is:

    nic1!env1=value1 env2=value2,nic2:env1=value1 env2=value2.

For example,

    ib0!CONNECTED_MODE=yes MTU=65520,eth0!MTU=17000

The new attribute will be passed down to the postscripts as an environment variable.

Implementation
----
1. Add a new attribute called ***nicextraparams*** in *nics* table.
2. Incorporates it into the *def* commands 
3. Add the new attribute in the default postscript template so that it can be passed down to the nodes.
4. Handle MTU environment variable in *configeth* postscript. Ethernet does not have connected mode setting. Handle MTU and CONNECTED_MODE environment variables in *configib* postscript. 

Other Design Considerations
----

  * **Required reviewers**: Guang Cheng
  * **Required approvers**: Guang Cheng 
  * **Database schema changes**: Yes. A new attribute will be added in nics table. The def command will be modified to accept this new attribute.
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: The tabdump -d command will show the format of the new attribute.
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 