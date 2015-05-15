<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Current postscript process on Linux](#current-postscript-process-on-linux)
  - [Problem](#problem)
  - [New design for postscript process](#new-design-for-postscript-process)
  - [Details of the different scenarios](#details-of-the-different-scenarios)
- [Postscript process for AIX](#postscript-process-for-aix)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Current postscript process on Linux

On Linux, xCAT postscripts are executed during the init.d process via xcatdsklspost when a node boots up the first time. xcatdsklspost gets all the postscripts and environmental variables for the node from its master. It then runs the postscripts one by one. Node's DHCP server is used as its master. updatenode command also uses xcatdsklspost for running postscripts. 

### Problem

In a flat network, even if we set the noderes.xcatmaster for a node, any service node can respond to the DHCP request for the node. When the node's original DHCP server is down, updatenode will fail because xcatdsklspost cannot get all the postscripts from its DHCP server. In this case, the node's service node is alive, but updatenode cannot be run successfully. This problem also prevents nodes from being moved from one service node to another. 

### New design for postscript process

Retry logic will be added to the wget call (for getting the postscripts from the master) in xcatdsklspost. It will try to get the hostname of the master from the following sources in order: 

  1. the parameter passed to xcatdsklspost through -M flag (from updatenode). 
  2. /etc/xcatinfo file. (This is where we record the SN hostname when we think we know the correct one.) 
  3. the parameter passed to xcatdsklspost through -m flag (from updatenode). (This is the SN that was chosen by the MN in the top down direction - from noderes.servicenode.) 
  4. the DHCP server it got the DHCP response from. (This is the original SN to respond to it, but it may or may not be the correct SN, depending on the scenario.) 

/etc/xcatinfo file is used to save the node's master for later use. At the end of the xcatdsklspost script, it will save the value from the environmental variable MASTER to the file. This file contains a line like "XCATSERVER=&lt;svr_name&gt;". 

### Details of the different scenarios

  * Diskless case: /etc/xcatinfo file is empty when the node is first booted up. The node gets a dhcp response from one of the SNs. 
    * In the SN pool case (noderes.xcatmaster is blank): this is the SN that will service this node. When the postscripts run, Postage.pm will fill in itself as MASTER (because noderes.xcatmaster is blank), and xcatdsklspost will put that in /etc/xcatinfo for safekeeping, in case the dhclient info expires. Updatenode will make use of /etc/xcatinfo. 
    * In the subdivided SN case (noderes.xcatmaster has an explicit value): this may **not** be the correct SN for this node. When the postscripts run, Postage.pm will fill in noderes.xcatmaster as MASTER, and xcatdsklspost will put that in /etc/xcatinfo. Updatenode will make use of /etc/xcatinfo. 
  * Full install case: 
    * In the SN pool case: the kickstart/autoyast template does **not** fill in /etc/xcatinfo during nodeset (because noderes.xcatmaster is not set for this node). The node will get a dhcp response. This is the SN that will service this node. When the postscripts run, Postage.pm will fill in itself as MASTER (because noderes.xcatmaster is blank), and xcatdsklspost will put that in /etc/xcatinfo for safekeeping, in case the dhclient info expires or they use hardeths. Updatenode will make use of /etc/xcatinfo. 
    * In the subdivided SN case: svr_name in /etc/xcatinfo will be set to noderes.xcatmaster in the kickstart/autoyast template during nodeset (because noderes.xcatmaster has an explicit value). When xcatdsklspost runs, it will use this /etc/xcatinfo file. When the postscripts run, Postage.pm will fill in noderes.xcatmaster as MASTER, and xcatdsklspost will put that in /etc/xcatinfo (which is the same value as before). Updatenode will make use of /etc/xcatinfo. 
  * Updatenode: Passing the node's service nodes to xcatdsklspost in a parameter through -m flag is done by updatenode command only. If the noderes.xcatmaster is set for the node, the -m is set to this value. Otherwise, -m is the value of the network interface facing the node from a server node that sends the command. If the mn is the node's service node, -m is the value of site.master. But remember that this value is only used if there is not a good value in /etc/xcatinfo. In this case, the -m value will be used to contact the SN, and when xcatdsklspost runs it will get this value in MASTER and put it in /etc/xcatinfo. In this way, updatenode changed the node's record of who its SN is (if the original SN wasn't reachable). How do we explicity change the SN for a node? Another parameter to xcatdsklspost (-M) will always override the /etc/xcatinfo file (and have its value set in the xcatinfo file as a result of the xcatdsklespost processing). This flag is set when updatenode -s (a new flag) is used by the user. 

## Postscript process for AIX

During an AIX diskfull install or diskless boot the xCAT "xcataixpost" script is run. Among other things it will run whatever additional postscripts are specified. 

When postscripts are run on AIX nodes the name of the server is read from the /etc/xcatinfo file. This file was originally created to preserve the information from the NIM /etc/niminfo file that is automatically created during the node installation (by NIM). This copy of the niminfo file was needed because the niminfo file is changed when an xCAT SN is configured as a NIM master. The xcatinfo file is now also being used it the Linux process. 

Diskfull install flow: 

During the creation of a diskfull image (using mknimimage) a NIM script resource is automatically defined using the xCAT "xcataixscript" script. NIM runs this script during the node install. This script will read the /etc/niminfo file and create the /etc/xcatinfo file. It will also mount/copy postscripts to the node and add the xCAT "xcataixpost" script to the /etc/inittab file. 

During the initial reboot of the node the "xcataixpost" is run. It gets the name of the server from /etc/xcatinfo, requests the node-unique postscript from the server and runs the postscripts for the node. (It also sets the password, removes itself from inittab etc.) 

Note: In the current design the /etc/xcatinfo file is only created once. The "xcataixpost" script will check for it and create one if it's not there but will not overwrite it. 

Diskless boot flow: 

During the creation of a diskless image the mknimimage command automatically updates the NIM SPOT resource. It adds "xcataixpost" to the image and it adds an entry for it in the /etc/inittab file contained in the image. 

When the node is booted the script checks for the xcatinfo file, and if not there, it creates one. It will then mount/copy the postscripts, request the node-unique postscript and run the list of postscripts that have been specified. 

  
Updatenode flow: 

The updatenode support for running postscripts on AIX uses xdsh to call the "xcataixpost" script on the nodes. 

(New support: ) 

The updatenode command will be modified to support the "-s|--sn" option. This option will cause the the /etc/xcatinfo file on the node to be updated. 

For AIX nodes the updatenode command will call the xcataixpost script with either the "-m &lt;servername&gt;" or "-M &lt;servername&gt;" option. The "-M" option will mean to reset the xcatinfo file. It will be used if the updatenode command is called with the "-s" option. The "-m" option will be used otherwise and will provide a backup server name that may be used if the server named in the xcatinfo file is not reachable. 

The server name is determined when the process_request part of the updatenode command runs on the MN or SN. It will be the value of the "xcatmaster" attribute in the node definition or, if not set, it will default to the name of the server as known by the node. The name of the server as known by the node will be determined by calling the getFacingIP(&lt;nodename&gt;) routine. 
