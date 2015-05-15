<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Authorization model](#authorization-model)
- [Credential protection](#credential-protection)
- [Redacted 'Backup'](#redacted-backup)
- [Running as non-root](#running-as-non-root)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Authorization model
=======================
In xCAT 2.x, we employ a policy table that implements a rule based authorization scheme.  In confluent, try for something simpler with nodes optionally organized into tenants.  A user is assigned a role which confers a defined set of authority for all nodes in the same tenant.  There is a 'null' tenant meaning users and nodes not defined within a tenant.  The null tenant may be considered special (e.g. administrators in the null tenant can examine all tenants and retrieve stored credentials, but administrators in non-null tenants cannot retrieved stored credential data even for 'their' nodes).  The following roles are expected be defined:

* administrator (do everything, default role)
* operator (read-only non-secret configuration, read-write consoles, control node power)
* user (allowed to read non-secret information, read-only consoles)
* technician (allowed to look up health details only)

Credential protection
=========================
All attributes starting with 'secret.' are afforded protection throughout the stack.  At the lowest level, it is encrypted and the decryption is an option that is done on demand as requested (unlike expression evaluation which happens eagerly and results are in-memory constantly).  By default the decryption key is kept in the clear, with options to seal it to a password (requiring manual unlock on daemon start before real work can be done) or seal to TPM (which allows automated daemon start so long as TPM module is available.  Sealed to TPM should only be done if there is also a seal to password version available so that loss of TPM can be recovered through password.  When a backup of the configuration is done, a password should be provided to protect the master key so that the key is not in backup in plain text.  A user not wishing to mess with it just uses an empty string for password, but should do so explicitly.  Restore utility should try an empty string for password before prompting for a password if a utility did not receive a password via other mechanisms.

Redacted 'Backup'
===========================
Often times a dump of configuration for review by a less trusted third party is in order.  Backup utility should offer a facility to auto-redact.  This clearly marks the resultant backup file as redacted to prevent any attempt to 'restore'.  The default behavior would simply omit any cryptval data.  Identifier redaction is an option that may likely break expressions where applied.  If identifier redaction is performed, ip, mac addresses, node names, uuids would be replaced by iterating values.  A map from the dummy redacted values to real values is retained in a separate file to help someone map guidance from the dummy values to real values.


Running as non-root
================================
Every effort should be made to enable non-root mode of execution if possible.  Some of the obstacles and mitigation:

* iso currently gets loop mounted.  When time comes, use libguestfs to keep kernel out of it
* Server side 'xdsh' like function suggests wide open access.  Don't implement server side xdsh
* Binding to privileged ports like 67 Perhaps employ a start as root, drop privilege model.  Using capabilities would have been nice, but seems to be unfriendly toward an interpreted implementation (would have to grant capabilities to python executable which would be inappropriate)
* Modifying config files like named.conf.  Have a bundled utility to craft basic named.conf and rely upon DDNS to update going forward.  Similar scheme as appropriate (dhcpd.conf by utility, OMAPI for dynamic updates *IF NEEDED*
