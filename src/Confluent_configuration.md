<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Organization](#organization)
- [Inheritance](#inheritance)
- [Expressions](#expressions)
- [On Disk](#on-disk)
- [Backup format](#backup-format)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Organization
============
In xCAT 2, there are two configuration schemes, 'table' and 'objdef'.  For confluent, converge the two models.  The result is something that resembles objdef, but with dot-delimited names to help organize data and provide a way to map 'tabedit' behavior as desired.  Also, rename and consolidate concepts for more understandable use. For example:

* lsdef shows 'bmc' and nodels thinks of it as 'ipmi.bmc'.  confluent uses 'hardwaremanagement.manager'
* 'mp.mpa' becomes 'enclosure.manager'

Some attributes are removed entirely for now (installnic).  At least long enough to have people comfortable with the concept that it need not be defined for the common case.  Boot from media may indicate a return of the need of it.

Inheritance
==================
Inheritence behaves on the surface much like xCAT 2.  Under the covers, performance is dramatically improved on read as inheritance is done and re-evaluated on writes and results stored in memory and on disk.  Backup process will skip the result fields and only get the source material, restore will re-evaluate the information

Expressions
=======================
Expressions are dramatically changed.  In xCAT 2, regular expressions were used and extended by allowing 'Safe' compartment evaluation of result data with a blacklist of forbidden low level operations.  This results in a syntax that is unbelievably flexible, but slow, hard to follow, and likely able to do unexpected things from a security standpoint.  Confluent expressions, like inheritance improve performance by doing all evaluations on write rather than read of data.  One additional capability is the ability to read in values from other attributes.  Some example xCAT2 expressions and confluent equivalents (using the relatively new 'easy' xCAT expressions when possible:
<table>
<tr><td>xCAT 2</td><td>Confluent</td></tr>
<tr><td>/\z/-bmc</td><td>{nodename}-bmc</td></tr>
<tr><td>|10.1.($1/255).($1%255)|</td><td>10.1.{n0/255}.{n0%255}</td></tr>
<tr><td>N/A</td><td>10.1.{enclosure.id}.{enclosure.bay}</td></tr>
<tr><td>/n/bmc/</td><td>*TBD*, possibly {nodename.replace('n', 'bmc')}</td></tr>
<tr><td>/(\D+)\d+\D+(\d+)/test$1$2/</td><td>N/A (TODO if requested)</td></tr>
</table>

On Disk
============================
Data is committed to disk in a DBM style backing store.

Backup format
============================
Backup data is to be in .json files.  inheritedfrom entries are omitted.  value attributes alongside expression attributes are omitted.  cryptvalue entries are converted to base64.  The master integrity and privacy keys are encrypted by a backup password which is required to restore the encrypted values.  See [Confluent_security] for more on that aspect.