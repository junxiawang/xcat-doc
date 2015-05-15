<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Structure](#structure)
  - [/nodes/](#nodes)
  - [/nodegroups/](#nodegroups)
  - [/users/](#users)
  - [/usergroups/](#usergroups)
  - [/noderange/](#noderange)
  - [/detected/](#detected)
- [Content](#content)
- [References to other resources](#references-to-other-resources)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Structure
===================

Confluent organizes managed elements into a filesystem like structure.  Using confetty or a browser to point at the api provides a browsable interface to whatever the code implements.  This page is intended to show intent of things not done and flesh out explanation of the intent of each branch.  It might also be incomplete, so a user should consider using confetty or web browser to their instance as the canonical set of data.

/nodes/
-------------------
The complete collection of node resources.  Beneath each node resource is a structure that includes:
    * power/state (on/off/reset, etc)
    * boot/nextdevice (next one time boot)
    * health/hardware (summary of the health of the hardware aspect of the node)
    * console/session (access to a live console session to node, not a restful resource in http)
    * attributes/current (currently defined attributes for node)
    * attributes/all (all possible attributes that a node can have)
    * (more to come...)

/nodegroups/
--------------------
The complete collection of nodegroups.  The mapping from nodegroups to nodes is bidirectional and refreshes both ways when one way is updated.  This provides the structure for inherited configuration values as well as a component for noderange expansion.  Not used to actually manage the members, just to configure membership and attributes.
    * attributes/current
    * attributes/all

/users/
-------------------
The list of users known to confluent.  The users may have a password attribute to authenticate them or else be a common name with PAM or whatever authentication mechanism was used.  See [Confluent_auth] for some more details.  

/usergroups/
-----------------------
Groups that should be recognized by confluent.  One day this may be used for some mass user management function or inheritence, but when first implemented it will mostly be a mechanism to link group-based external authentication (e.g. /etc/group) to confluent role.

/noderange/
-----------------------
This collection acts sort of like an automount point.  When looking at it directly, it appears empty.  Look at /noderange/n1-n5/ and there will be something.  This structure enables request for noderange resolution.  This interface is not strictly a 'RESTful' scheme at the top, but aside from auto-instantiation it behaves with those confines.  A /noderange/<nr>/ will look much like a /nodes/<node>/, except it will have a 'nodes/' to show links back to /nodes/<node> for each match in the noderange.

/detected/
-----------------------
A collection of items that are seen as a result of active or passive scanning.  The discovery process operates on members here.  Autodiscovery can fire in response of new things appearing in this area (e.g. scanning enclosures or switches for matches like in xCAT 2).  Clients can walk through this and auto-assign (analagous to nodediscoverstart behavior).  


Content
==================
All data returned from a plugin must conform to confluent.messages.  A developer is asked not to subclass ConfluentMessage within their own plugin, but instead modify confluent.messages.  We may break up confluent.messages into categories if it gets too big.  The intent is that multiple parties working on different backends to the same problem are likely to look at the same chunk of code and more conciously coordinate how they describe the state to be as common as possible.

References to other resources
======================
Any references to other resources should be done in a relative way.  In much the same way
a symbolic link with absolute path will break if mounted on a different mount point, an absolute reference could break based on protocol or path api is mounted on.  This means explicitly that the hostname should be considered unavailable for any information (e.g. 'virtualhost' sensibilities would be implemented either through distinct confluent instances or as tenants).