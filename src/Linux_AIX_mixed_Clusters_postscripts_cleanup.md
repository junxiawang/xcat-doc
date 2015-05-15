<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Default Postscripts](#default-postscripts)
- [Service Node Postscripts](#service-node-postscripts)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


###Overview

For Linux/AIX mixed cluster support, xCAT default postscripts and servicenode postscripts can no longer be separate for AIX/Linux.  There must be common postscripts that will run on either AIX or Linux.

###Default Postscripts 

* On AIX, currently the default postscripts are the following:
 "xcatdefaults","syslog,aixremoteshell,syncfiles",,,
* On Linux:
 "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,

Note:  as of xCAT 2.8,  we no longer put aixremoteshell in the postscripts table. remoteshell is used for both AIX and Linux nodes.   aixremoteshell is called by remoteshell on AIX nodes.

After the change there will be one postscript (written in shell), remoteshell that will setup either Linux or AIX and the default postscripts for either Linux or AIX will become:
 "xcatdefaults","syslog,remoteshell,syncfiles","otherpkgs",,



###Service Node Postscripts 

* On AIX, currently the servicenode postscript shipped is the following:
 "service",,"servicenode",,
* On Linux currently the servicenode postscripts shipped are as follows:
 "service","servicenode,xcatserver,xcatclient",,

In xCAT 2.7 there is  one postscript (written in Perl), servicenode that will be for either Linux or AIX,  and the postscript entry will be the following:
 "service",,"servicenode",,



servicenode postscripts will be modified to call  xcatserver and xcatclient, if the servicenode is Linux. Also, postage.pm will add an Env Variable to the mypost* file, designating the release. 
Since xcatserver and xcatclient will still exist, they can check that Env Variable and know, if it is that release or later then servicenode has already run them and exit.  The admin can remove their entries from the postscripts table when convenient. (Anyone got any better ideas?).

Another possibility is we copy the logic that is currently in xcatserver and xcatclient to two new scripts and call those scripts and then modify xcatserver and xcatclient so they do nothing but return 0.  That way they stay in the postscripts table, without affecting anything until the they are removed.  The only problem with this is if the SN does not mount the /install/postscripts directory and they do not update the SN,  they will have problems.