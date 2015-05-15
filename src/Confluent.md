<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Intent](#intent)
- [Proposed milestones](#proposed-milestones)
  - [xCAT 2.10](#xcat-210)
  - ['xCAT 3'](#xcat-3)
- [Goals](#goals)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Intent
=====
Confluent is a codebase with a few goals in mind, servig to augment xCAT 2.x series and potentially serve in place of xCAT-server in xCAT3

Proposed milestones
====================


xCAT 2.10
----------------------
* Change Requires to confluent instead of conserver, making confluent the default
        
'xCAT 3'
-----------------------
* Switch to confulent as the core rather than xCATd
* Rely upon the existence of xCAT 2 to err on a different side of some judgement calls (i.e. users can just use xCAT 2).  xCAT 2.x erred on the side of flexibility and rapid feature delivery at the expense of usability and consistency for the sake of users willing to put up with it for the benefit, this may not cover all use cases and features may come slower if it means better usability and consistency.
* Continue xCAT 2.x branch.  Remain committed to the xCAT 2 experience as the 'xCAT 3' experience may not be as capable in all circumstances or meet the tastes of xCAT 2 users
* A rename may better set expectations, both in terms of retraining and commitment to continued xCAT 2.x development for environments that do not want to or cannot embrace the confluent based concept

Goals
=====================
* Implement node 'aliases' for alternate names without creating 1-member groups
* Easy to write shell script plugins in addition to more structured python plugins
* Improved server performance (lower memory usage, lower latency), especially for http
* Provide built in console management and logging [Confluent_consoles]
* Scrap current XML socket api and RESTful protocol and have a unified structure for socket and http [Confluent_interface]
* Enhance user authentication to include independent auth, PAM auth, and local authentication [Confluent_auth]
* Replace disparate 'nodech' and 'chdef' models to unified syntax. [Confluent_configuration]
* Replace use of SQL with an in-process, in-memory configuration engine for configuration
* Provide baked in HA capability [Confluent_HA]
* Replace use of SQL for eventlog/auditlog with enhanced sequential data facility [Confluent_logging]
* Consistent authentication of all node request, consolidating 'interesting' authentication facilities into a single tunable request to allow tight control of security policy
* Replace policy table with simplified role based model within 'tenant' groups
* Capability for DHCP-independent and DHCP-free deployment capabilities (latter requiring special hardware support) [Confluent_bootsupport]
* Unix socket mode to allow *all* directives to go through server if warranted (e.g. 'tabch' versus 'chtab' issue goes away).
* Restructure osimage concept to be entirely in filesystem (more discoverable and portable) [Confluent_osimage]
* Provide better protection to stored credential information
* Ability to run as non-root (see [Confluent_security] for limitations and strategies)
* Passive and active discovery [Confluent_discovery]
* Executive summary of 'health' [Confluent_health]
* Low cost, highly responsive event notification [Confluent_clientevents]
* Automatically respond to reconfiguration [Confluent_reconfigure]