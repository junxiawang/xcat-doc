<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Overview](#overview)
- [Design details](#design-details)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

##Background

The command 'makedhcp -a' or 'makedhcp node' can be used to define nodes into DHCP server. It will be run when installing xCAT, or manually by system admin. 
There are 4 modules that will call "makedhcp -s <statement>" within "nodeset" to write <statement> into dhcp lease file. 
The issue is, if run "makedhcp -a" or "makedhcp node" after "nodeset" , the useful <statement> info will be deleted. Pls reference https://sourceforge.net/p/xcat/bugs/4622/ for more information. 

##Overview

In order to resolve the issue mentioned above, the idea is to write <statement> in "makedhcp -a" or "makedhcp node" (in addnode subroutine in fact) based on node netboot attribute.

##Design details

The modules and the <statement> that they write into dhcp lease file are as belows:

* petitboot.pm
    The statement: option conf-file "http://$mn_ip/tftpboot/petitboot/$node";

* nimol.pm
    The statement: supersede server.filename = "/$vios-distroname/nodes/viobootimg-$nodename";

* grub2.pm
    * The statement when doing os provisioning: filename="/boot/grub2/grub2.ppc";
    * The statement after reboot: filename = "xcat/nonexistant_file_to_intentionally_break_netboot_for_localboot_to_work";

* yaboot.pm
    * The statement when doing os provisioning: filename="/yb/$osvers/yaboot";
    * The statement after reboot: filename = "xcat/nonexistant_file_to_intentionally_break_netboot_for_localboot_to_work";

In order to provide a easy fix, the following will be done:

* For nimol.pm
  * the statement filename will be "/vios/nodes/$node"
  * when 'nodeset', link /tftpboot/vios/nodes/$node to the specified vios-bootimage-file

* For yaboot.pm
  * the statement filename will be "/yb/node/yaboot-$nodename"
  * when 'nodeset', link /tftpboot/yb/$osvers/yaboot to the specified statement file.
  * when 'updateflag', remove /tftpboot/yb/node/yaboot-$nodename

* For grub2.pm
  * the statement filename will be "/boot/grub2/grub2-$nodename.ppc"
  * when 'nodeset', link /tftpboot/boot/grub2/grub2.ppc to the specified statement file.
  * when 'updateflag', remove /tftpboot/boot/grub2/grub2-$nodename.ppc

* For petitboot.pm
  * write the statement filename "http://$mn_ip/tftpboot/petitboot/$node"

With the fix above, run "makedhcp -a" or "makedhcp node" before "nodeset", "nodeset" won't need to call 'makedhcp' internally anymore.

## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Guang Cheng 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 