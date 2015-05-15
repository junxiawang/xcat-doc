<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function in 2.5.3 Since 2.5.2](#new-function-in-253-since-252)
- [Bugs Fixed in 2.5.3](#bugs-fixed-in-253)
- [Known Issues and Work Arounds](#known-issues-and-work-arounds)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

These are changes since the [2.5.2 release](XCAT_2.5.2_Release_Notes). 

## New Function in 2.5.3 Since 2.5.2

  * A new [site attribute](http://xcat.sourceforge.net/man5/site.5.html) "vsftp" to control if the vsftpd daemon will be started automatically when xcatd is started. (The default is 1.) 
  * Node "os" attribute is now case sensitive to better support Scientific Linux (SL). 
  * chhypervisor command to allow query and change of an ESXi hypervisor maintenance mode state. 

## Bugs Fixed in 2.5.3

  * nodestat no longer hangs on running systems with a service running on port 3001 
  * The nodeset command now returns non zero value when prescripts fail. 
  * Fixed the issue for handling variables in the statelite table attributes. 
  * Fixed the issue that the getpostscript.awk file hangs when "getpostscript" entry is not in the policy table. 
  * Fixed rinv crashing on orphan VMs in VMware. 
  * Removed pbstop from xcat 2.5 because of GPL. 
  * Removed ISRDown condition and ISR_status sensor from RMC monitoring 
  * Recovery of vms from a dead VMware hypervisor using mkvm/rpower/rmigrate now gets placed correctly on a specific hypervisor if requested. 
  * Fix rmigrate -f for VMware in the event that the source hypervisor is not currently in vCenter inventory 
  * Fix genimage to again create ifcfg-ethx file if -i options is used. The removal of this code caused some postscripts to fail which relied on the file. 

For details see the [Tracker Bugs](http://sourceforge.net/tracker2/?func=browse&group_id=208749&atid=1006945), or check the subversion commit history for the 2.5 branch. 

## Known Issues and Work Arounds

  * NA 
