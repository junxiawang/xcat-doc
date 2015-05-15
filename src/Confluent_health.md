<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [States](#states)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

For various elements, there is a concept of relative health.  To the extent possible, evaluate and summarize the health of things into an understandable enumeration.

States
==============

* 'ok': Nothing at all wrong.  If associated with an event, indicating an informational thing
* 'warning': A condition exists that does not impact performance or expose risk of data loss.  For example a fan failure, non-critical thermal situation, etc.
* 'critical': A condition exists that impacts performance and/or represents an imminent risk of data loss, but workload is currently still proceeding.  Thermal throttling, degraded array, critical temperature)
* 'failed': Condition has caused data loss and/or interruption of workload.