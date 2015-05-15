<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Requirements](#requirements)
- [Implementation](#implementation)
- [Usage Scenarios](#usage-scenarios)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

## Requirements

We are starting to get requirements to manage from a single point sets of nodes that are more geographically or logically disperse than can be easily handled by service nodes. Some of the perceive requirements are: 

  * network connectivity between sites may be slow 
  * different sites may be controlled by different organizations, making a single consolidated db undesirable 

## Implementation

We want to take a relatively simple approach to satisfying these requirements, based on our remote client support. Here are some ideas: 

  * On the global client (GC, the central point of control), it should have an ssl certificate (for xcatd) and an ssh key for each xcat MN it communicates with. 
    * This would allow any xcat cmd to be run towards a single MN. 
    * With a small modification to the p cmds (to not use xcatd to resolve the node range), all of them could work to the MNs (psh, prsync, etc.) 
  * The global client should have a list of the clusters that are being managed, i.e. a list of the MNs 
    * This could either just be the list of ssl certificates, or a simpler list of hostnames in a config file 
    * This would allow the p cmds above to support some simple groups like "all" in this context 
    * We should also have a file on this machine like /etc/xCATGC that indicates this is a global client (similar to the /etc/xcATMN and /etc/xCATSN files). Then code like the p cmds can use this to know it should get node ranges from a different place. 
  * We should support running an xcat cmd to multiple MNs in one invocation. 
    * This could be implemented as a new front end cmd like: xcatsh &lt;nr&gt; &lt;xcatcmd&gt;
    * Or existing the existing xcat cmd client scripts (xcatclient and xcatclientnnr) could be modified to automatically do this if it detects a special node range. But there are more client front ends than these, so they would all have to be modified. 
    * In either case, the node range syntax supported should be something like: mn1%grp1,mn2%n1-n5 
    * Then the output should be prefixed by the MN it came from so that xcoll can separate it 
  * Packaging: 
    * A new meta pkg called xCATgc that requires xCAT-client 

As an alternative implementation, we could install xcatd on the GC and have it dispatch cmds to the other MNs. In some ways, this would be a more elegant solution. But i'm concerned it would make xcatd even more complicated than it already is, which is a problem. 

## Usage Scenarios

  * rpower stat of all nodes in all clusters: 
    * xcatsh 'all%all' rpower stat | xcoll 
  * Show the nodelist.status atttribute for all nodes in mn1 and mn2: 
    * xcatsh mn1,mn2%all nodelist nodelist.status | xcoll 
  * Push content for the policy table to all clusters: 
    * pscp /tmp/policy.csv all:/tmp/policy.csv 
    * xcatsh all tabrestore /tmp/policy.csv 
  * Roll out a new stateless image to all clusters: 
    * prsync /install/netboot/rhels6/x86_64/compute all:/install/netboot/rhels6/x86_64/ 
    * xcatsh all%compute nodeset netboot 
    * xcatsh all%compute rpower boot 
