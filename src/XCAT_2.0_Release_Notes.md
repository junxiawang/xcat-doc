<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2.0 Release Notes](#xcat-20-release-notes)
  - [Limitations](#limitations)
  - [Not Thoroughly Tested](#not-thoroughly-tested)
  - [Known Bugs](#known-bugs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# xCAT 2.0 Release Notes

## Limitations

  * xCAT 1.3 and 2.0 do not play well together. Please have a dedicated xCAT 2.0 management node. To switch from one xCAT to another disable DHCP and Conserver on unused management node. 
  * For SLES 10, you must use SP2 
  * Monitoring: when new MM, RSAII or BM is added or removed from the cluster. You must restart snmp monitoring if snmpmon is turned on in order to have the changes take effect. 
  * Fedora 9 iSCSI and serial console unimplemented. Consider using Fedora 8 to build F9 image for stateless. 

&gt; 

## Not Thoroughly Tested

  * Full, stateful install with hierarchy (service nodes) 
  * SLES 10 in hierarchy 
  * A SLES 10 management node (SLES 10 compute nodes have been tested) 

## Known Bugs

  * TBD 
