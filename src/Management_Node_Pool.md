<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Assumptions](#assumptions)
- [Enhancements Needed](#enhancements-needed)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


The goal of this feature is to enable having many mgmt nodes in a single cluster, that are all active at the same time (i.e. can all be used by the admin to manage the cluster), and that share the mgmt load, and if any one of them goes down the cluster continues to run. 

The advantages of this vs. the traditional HA failover/passive backup MN approach are: 

  * don't have to use failover software like pacemaker &amp; corosync, that we don't have support options for 
  * the redundant MNs can also be used to lighten the load on each of them 
  * the admin can be sure that the hw and software is working correctly on the additional MNs, because they can be used at any time 

The approach will be to use the existing SN pool capabilities, with the enhancements listed in the rest of this design. The 1st mgmt node that is installed will be called the MN. The subsequent mgmt nodes will be called SNs. (It will be easier from a migration perspective to not change the terminology we have been using. We do have to make a distinction anyway for the primary MN, so it is more clear to call that one the MN and the rest SNs.) The admin will be able to manage the cluster from any of the MN/SNs. And it will be easy to turn one of the SNs into the MN. 

This is an HA approach that the PCM/PCM-AE team is also interested in. 

## Assumptions

  * Linux only, both x &amp; p (we will not support the enhancements in this design on aix) 
  * Same ssh keys &amp; xcat certificates on all the MN &amp; SNs, like we do today, except that the ssh key needs to be a different key than the compute nodes need. See the enhancements section for details. 
  * A global/reliable file server must be provided for /install, /etc/xcat, /root/xcat (anything else?) (e.g. gpfs gss) 
  * A flat ethernet mgmt network that the MN, SNs, and compute nodes are all on. (If the service network is separate from the mgmt network, all MN/SNs must be connected to it as well.) 
  * The db is running in replication mode on the MN and one of the SNs. (Or they have the db on a external/reliable server.) Could we use sqlite as the db with the .sqlite files on the file server? Probably not, unless we deemed the performance is good enough and the locking in gpfs is good enough. See http://www.sqlite.org/whentouse.html . This needs investigation/testing. 
  * site.disjointdhcps=0 (i.e. dhcpd will be configured the same on all MN/SNs, since they are all on the same network) The one exception is that a dynamic range will only be configured on the MN. 
  * site.sharedtftp=0 (this is a requirement of SN pools, i think because it has to point the booting node to itself?) 
  * Compute nodes will leave noderes.xcatmaster blank, like for traditional SN pools. Noderes.servicenode should be set to at least 2 MN/SNs (and it is best to distribute which MN/SN is first to balance the load). 
  * snmove will still work much like it does today to switch a live node from one MN/SN to another, when a MN/SN goes down 
  * The SNs will be deployed from the MN, much like they are today. 
  * The services that are started up on each MN/SN is still determined by the servicenode table, but it is suggested that they all be the same. 
  * Can SNs be stateless (and boot off of any MN/SN), or only stateful? 

## Enhancements Needed

  * Some xcat cmds may not dispatch correctly from a SN (e.g. xdsh). This needs to be fixed. 
  * Only the MN can have a dynamic range defined. Can this be automated in makedhcp if site.disjointdhcps=0&nbsp;? 
  * Are there any changes needed in xcatconfig or AAsn.pm for configuring the MN or SNs differently than what they do today? 
  * More than 1 MN/SN must be able to act as the console server for a node - maybe use console on demand? Or have jarrod support multiple conservers in his conserver replacement 
  * When noderes.servicenode has 2 entries, we should configure the services on the compute node to point to both (e.g. for dns, ntp). Norm did some investigation into this, but we might need more work in this area. 
  * We might have to lock some operations that write to /install so 2 mn's are not writing at the same time 
  * I think we have a few chks to not do certain operations on the mn. We should modify that to allow one MN/SN to manage another MN/SN. For example, a SN should be able to run updatenode -S to the MN to install some otherpkgs. 
  * The common ssh key for the compute nodes needs to be different than the common ssh key for MN/SNs, so the MN/SNs can have the latter in their authorized_keys file to allow ssh'ing between all MN/SNs. 
  * Might want a streamlined way (or at least simple documentation) for defining additional SNs. 
  * One of the SNs needs to have a db replication instance running on it. We won't give this SN a special status, but we do need to make sure one has it and be able to know where it is. 
  * Need a reliable/HA way to have a gateway to external networks. (I.e. not solely thru the MN.) 
  * How should we configure DNS so all the SN instances aren't solely dependent on the MN? NTP on each SN should probably point directly to an external time server, or at least MN and one other SN. 
  * Need to be able to list the MN along with SNs in the noderes.servicenode attribute of compute nodes. Arif implies this doesn't work: https://sourceforge.net/p/xcat/feature-requests/127/ 
  * Need a new cmd to turn one of the SNs into the new MN. (Maybe called makemn?) It will do: 
    * Must be able to run when the previous MN is down or up 
    * The cmd will be run on the SN that is designated to be the new MN 
    * On the previous MN, change /etc/xCATMN to /etc/xCATSN, and vice versa on new MN 
    * Set dhcp dynamic range on the new MN 
    * Start replicated instance of the db 
    * Change site.master to this new MN 

## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
