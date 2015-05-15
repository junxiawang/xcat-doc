<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Log structure](#log-structure)
- [Logging performance](#logging-performance)
- [Log files](#log-files)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Logging in confluent should still use syslog as appropriate, but it will always use it's internal logging facility. 

Log structure
========================
For every log, there are two files.  A plaintext file that should provide roughly equivalent experience to /var/log/messages, and a binary metadata file that utilities can use to more quickly process the plaintext and filter information out from unstructured text that isn't pertinent to the viewing situation. There will be three general classes of log in terms of plaintext file layout (binary metadata is constant across all):

*  Console log: plaintext will concatenate the entries without line feeds and interject data like connects, disconnects, timestamps, and so on as [] inside the unstructured text.  Most timestamp data will be omitted from the plaintext file.
* Unstructured log files (e.g. trace, debug logs).  Entries are always prepended with timestamp and have line feeds appended
* Structured log files (e.g. audit log).  Same as unstructured log, but the plaintext data is JSON formatted for easy programmatic or human processing.

Logging performance
==============================
Conventionally log files are written with as much assurance as possible.  This has caused issues with overwhelming IO load for console servers with large numbers of managed targets.  In confluent, effort is made to aggregate writes and in fact combine log entries in console log when metadata would match.  The thought is that unlike most logging (where the thing logging data is self-monitoring and failing to commit log to disk fast enough has a high chance of missing important clues), confluent is monitoring other entities.  If the other entity has a kernel panic, there is no threat to our log due to caching, so we can cache more aggressively than conventional situtations.

Log files
=======================
Logs are written to /var/log/confluent.

* audit (what user does what action and when)
* consoles/nodename (historical console output)
* stderr (data that would be printed to stderr is captured here.  Ideally this should never get entries but is provided as a last resort)
* stdout (data that would show up in stdout.  If a library or plugin does a 'print' it lands here.  This shouldn't be needed and this file growing in most cases should be considered a bug.
* trace (if an unexpected condition occurs, the traceback is recorded here)
* plainstdout/plainstderr (if some non-python code writes to stdout/stderr, it will land here without any of the aforementioned binary metadata or timestamping).