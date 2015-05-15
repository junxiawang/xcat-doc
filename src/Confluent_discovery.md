<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Detection](#detection)
  - [PXE detection](#pxe-detection)
  - [Boot image detection](#boot-image-detection)
  - [Vendor specific](#vendor-specific)
- [Discovery](#discovery)
  - [Methods](#methods)
  - [Actions](#actions)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Confluent should expand the discovery facility present in xCAT 2.  The general flow is that things are divided into two pieces:

1. detection.  Something being detected simply causes confluent to take note of it under the /detected/ collection and notify any 'discovery' handles of the new or updated entry
2. discovery.  Classifiying a detected object as a known entity.  This could be an automated action due to switch or enclosure matching.  It could be a client application implementing a first-come, first-serve scheme to assign detected to existing nodes, or a client application creating nodes and then assigning them based on what is seen.   The first come, first serve model I think best implemented as a client utility rather than a server capability (shouldn't be full-time automatic)

Detection
=======================
To the extent reasonable, this should be a non-intrusive collection of information about relevant targets.  A detected node is not told to boot anything or reconfigured at all.  Sometimes multiple sources will indicate different facets of a single node (e.g. PXE and service processor).  Those sources will merge into a single source of data.

PXE detection
---------------------
As per [Confluent_bootsupport] the intent is to bring in the facility to respond to DHCP requests.  Take advantage of the situation to detect a potentially actionable amount of data before the first OFFER is even sent.  Auto-detection could even occur before any boot directive sent to node.

Boot image detection
-------------------------
If the above is insufficient or triggers an inquiry for more data, boot genesis.  This enables deeper exploration of a node, what network interfaces it has, and so on.  Unlike xCAT, where this always happens, have it be an option disabled by default.  The deeper inventory would likely be a result of 'discovery', but 'detection' will be less disruptive.  The ability to find a node by a non-boot NIC would require this feature be enabled, but searching server enclosures and switches would not require this most of the time.

Vendor specific
----------------------
Implement vendor-specific detection capabilities as appropriate for product, service processors being high on list.

Discovery
=======================================

Methods
----------------------

Same as xCAT:

* snmp of switches
* interrogation of server enclosure managers

Actions
--------------------------

* For a compute node that is discovered, boot into Genesis for a deeper inventory followed by administrator defined 'chain' with a default of parking it in an sshable state for future action.
* Other resources may have specific discovery responses coded into plugins.  For example, IMM would have a remote login and remote configure.
