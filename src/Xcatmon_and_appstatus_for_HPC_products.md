<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Summary](#summary)
- [Symbols](#symbols)
- [Checking methods for HPC application status](#checking-methods-for-hpc-application-status)
- [Pull model implementation](#pull-model-implementation)
- [Push model implementation](#push-model-implementation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Summary

This LI is used to monitor the HPC product status, we support two models: 

1.&nbsp;&nbsp;&nbsp; Pull models: 

Using the existing xcatmon mechanism, it will provide ongoing status of the applications, and customers will probably want to set something like a 5 minute polling interval. The status checking result will be presented in the node attribute "appstatus". 

2.&nbsp;&nbsp;&nbsp; Push models: 

Writing a new postscript called "HPCbootstatus", it will check the initial appstatus when nodes first boot and report the appstatus to xcatd daemon on xCAT Management Node. We call it "push" model so that we could see the initial status immediately. 

To run the status query script every time the node boots, we should specify "HPCbootstatus" in the node attribute "postscripts" if we need this monitor function. For diskfull nodes, this postscript will set up an entry in /etc/init.d or /etc/inittab to make sure it's run in the sequent reboot after the installation. 

It's not enough to just set HPCbootstatus as the last postscript, because the app startup may be slow, so when our HPCbootstatus script is running, the app might not complete the start yet. So we plan to use a loop/sleep to query the app status in HPCbootstatus script, and set a timeout value (e.g. 5 mins) for waiting. If in this time period, once we get the status for a certain application, we will report to xcatd, instead of waiting for all status ready to report, this can let the user know app status in time. 

## Symbols

The status of applications will be presented as the format "&lt;keyword&gt;=&lt;value&gt;" in node attribute "appstatus", the users can customarize the &lt;keyword&gt; and the &lt;value&gt; as they want. Change xcatmon configuration or monsetting table to customerize the &lt;keyword&gt;, change the output of "cmd"/"dcmd" script to customerize the &lt;value&gt;. 

Here is an example for your reference. 

  


Product  keyword  value 

GPFS 
gpfs-mmfsd 
up/down 

gpfs-quorum 
Quorum = 1, Quorum achieved 

gpfs-filesystem 
/gpfs1,/gpfs2 

LoadLeveler 
loadl-schedd 
1!Avail&nbsp; (&lt;Availability&gt;!&lt;State&gt;) 

loadl-startd 
1!Idle&nbsp; (&lt;Availability&gt;!&lt;State&gt;) 

LAPI 
lapi-pnsd 
active/inoperative 

&nbsp;

## Checking methods for HPC application status

I plan to use "port", "lcmd=xxx" and "dcmd=xxx" to check the node appstatus via xcatmon, based on the calls provided by GPFS, LAPI and Loadleveler teams. 

Here is an example of xcatmon/monsetting configuration and status calls: 

Product  keyword  monsetting table  status calls 

GPFS 
gpfs-mmfsd 
port=1191,group=compute 
n/a, use the existing logic. 

gpfs-quorum 
lcmd=/xcat/xcatmon/gpfs-quorum 
/usr/lpp/mmfs/bin/mmgetstate -s&amp;#124;grep achieved 

gpfs-filesystem 
lcmd=/xcat/xcatmon/gpfs-filesystem 
/usr/lpp/mmfs/bin/mmlsmount all -L 

LoadLeveler 
loadl-schedd 
lcmd=/xcat/xcatmon/loadl-schedd 
llrstatus -r %sca %scs 

loadl-startd 
lcmd=/xcat/xcatmon/loadl-startd 
llrstatus -r %sta %sts 

LAPI 
lapi-pnsd 
dcmd=/xcat/xcatmon/lapi-pnsd,group=compute 
lssrc -s pnsd 

&nbsp;

## Pull model implementation

To support the "pull" model, we need to update xCAT2-Monitoring.pdf and give some examples about how to set up xCAT monsetting table to monitor the status of HPC applications, including the status calls listed in the table above. 

Since the calls is very simple, so I think we do not need to ship these sample scripts (e.g. /xcat/xcatmon/loadl-schedd, etc) in xCAT packages, we can write them in xCAT2-Monitoring documentation as a simple example so that the user can get sense of how we use it. 

No code change is needed for "pull" support. 

## Push model implementation

To support the "push" model, we need to write a new postscript called "HPCbootstatus" to check the initial application status when the node first boots. That is the last script to run which runs local commands to query each application's status. Query in the order listed above, since each application is dependent on the previous one running correctly. 

In this script, after we get the application's status locally, we need to do communication with xcatd on MN to update xCAT Database. For AIX, we can use a similar subroutine as "updateflag" in "xcataixpost" script to report the status, e.g. "hpcbootstatus $state\n"; For Linux, we can call "updateflag.awk" to report the status. 1

**(1)** I found xcat does not use "updateflag.awk" in AIX logic, and I did a quick test to use "updateflag.awk" on AIX to try to communicate with xcatd on MN, it failed. So I am thinking maybe there is some difference about awk support between Linux and AIX. I will follow the existing logic on AIX to report the initial status, that is something like "updateflag" subroutine. 

We need to develope two sub-scripts, such as HPCbootstatus.aix and HPCbootstatus.linux. Because on Linux, the postscript should be written in shell and call updateflag.awk to report appstatus to xcatd., While on AIX, we have to write HPCbootstatus.aix in Perl since it should call Perl module "IO::Socket::INET" to updateflags to xcatd on MN. We will release a unique postscript "HPCbootstatus" to our users, and in this script, we will call HPCbootstatus.aix or HPCbootstatus.linux depends on its uname. 

In xcatd, we need to add a new case when handling "$text" message, that is "elsif ($text =\~ /hpcbootstatus/)", then call $tab-&gt;setNodeAttribs to update "appstatus" column of the nodelist table with the new node appstatus. At the sametime, we need to make sure to also update the appstatustime attribute, too. 

Beside, in this script, we need to add an entry in /etc/init.d or /etc/inittab to make sure it's run in the sequent reboot after the installation. 

The "push" model will not depend on Ling's condition-response mechanism, only depends on xcatd daemon, it looks more flexible. 

If the administrator configures both pull model and push model, then we can accept the overlap. 
