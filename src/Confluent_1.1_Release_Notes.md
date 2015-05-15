<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New features/Modified behavior](#new-featuresmodified-behavior)
- [Fixes](#fixes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New features/Modified behavior
* CLI clients now stay 'connected' through a server restart (confetty at prompt or running console).
* Sensor data is now available (/nodes/<node>/sensors/)
* Noderanges are (mostly) implemented
    * Can do multi-numbered ranges, e.g. 'r1u1-r10u10', which xCAT can not do
    * Also added pagination: <n Skips 'n' nodes into the range, >x limits matches to x
    * Implemented in the API tree as '/noderange/' with members that auto-vivify (sort of like automount)
         * `/noderange/n1-n8/` (n1 through n8)
         * `/noderange/n[1-8]/` (same as above)
         * `/noderange/compute@rack1/` (nodes both in compute and rack1)
         * `/noderange/rack1,rack2/` (rack1 and rack2, multiple groups)
         * `/noderange/compute<50>25/` (skip first 50, show 25 nodes in compute group)
* Dynamic nodegroups, members defined as a noderange evaluated on the fly
* xCAT style commands that go straight to confluent (named so as not to conflict)
    * nodepower (like rpower)
    * nodesetboot (like rsetboot)
    * nodeidentify (like rbeacon)
    * nodehealth (new concept, summarize health of nodes)
* nodesensors offers more powerful tools for gathering data
    * Can specify interval and data points for controlled data collection
    * Can specify csv output
    * Default behavior is similar to 'rvitals'
* Valid PAM users are no longer allowed unless they *also* have a /users/ entry in confluent.  No password is needed for the entry, password is verified by PAM and not confluent in this mode.
* stdout/stderr logs now report the source of any data that comes in
* Set identify LED is implemented
* node collections are now sorted when enumerated

## Fixes
* Various issues with handling UTF-8 data
* More robust handling of shellmodule plugins
* Address some errors that were logged but no failure sent to client
* nodegroup requests without trailing '/' no longer fail
* Improved handling of console plugin exceptions
* Connected client count no longer goes negative
* Fix confetty behavior when not outputting straight to terminal
* Confluent no longer fails to work on ppc64
* More specifically indicate a remote system 'timeout' condition to client
* HTTP API now tolerates invalid cookies that may leak in from another site in the same domain
* Configuration change handlers could induce errors to clients that aren't trying to care about the handlers.  This is addressed by redirecting those errors to the trace log.