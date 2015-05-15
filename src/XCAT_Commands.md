<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT Commands and Database Tables](#xcat-commands-and-database-tables)
  - [Database support](#database-support)
  - [Hardware Control](#hardware-control)
  - [Monitoring](#monitoring)
  - [Inventory](#inventory)
  - [Parallel Commands](#parallel-commands)
  - [Deployment](#deployment)
  - [csm to xCAT migration tools](#csm-to-xcat-migration-tools)
  - [Kit commands](#kit-commands)
  - [Others](#others)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## xCAT Commands and Database Tables

Note: some of these commands run on Linux and AIX, some are targeted only for AIX or Linux. 

  


### Database support

  * [DB Tables](http://xcat.sourceforge.net/man5/xcatdb.5.html) \- Complete list of xCAT database tables descriptions. 
  * [chdef](http://xcat.sourceforge.net/man1/chdef.1.html) \- Change xCAT data object definitions. 
  * [chtab ](http://xcat.sourceforge.net/man8/chtab.8.html)\- Add, delete or update rows in the database tables. 
  * [dumpxCATdb](http://xcat.sourceforge.net/man1/dumpxCATdb.1.html) \- dumps entire xCAT database. 
  * [gettab](http://xcat.sourceforge.net/man1/gettab.1.html) \- searches through tables with keys and return matching attributes. 
  * [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) \- used to display xCAT object definitions which are stored in the xCAT database. 
  * [lsflexnode](http://xcat.sourceforge.net/man1/lsflexnode.1.html) \- Displays the information of a flexible node. ( 2.5 or later) 
  * [mkdef ](http://xcat.sourceforge.net/man1/mkdef.1.html) \- used to create xCAT data object definitions. 
  * [mkflexnode](http://xcat.sourceforge.net/man1/mkflexnode.1.html) \- Create a flexible node. ( 2.5 or later) 
  * [mkrrbc](http://xcat.sourceforge.net/man8/mkrrbc.8.html) \- Adds or deletes BladeCenter management module and switch node definitions in the xCAT cluster database. 
  * [mkrrnodes](http://xcat.sourceforge.net/man8/mkrrnodes.8.html) \- adds or deletes nodes in the xCAT cluster database. Allows creation/deletion of many nodes at once. 
  * [nodeadd](http://xcat.sourceforge.net/man8/nodeadd.8.html) \- Adds nodes to the xCAT cluster database. 
  * [nodech](http://xcat.sourceforge.net/man1/nodech.1.html) \- Changes nodes' attributes in the xCAT cluster database. 
  * [nodels](http://xcat.sourceforge.net/man1/nodech.1.html) \- lists the nodes, and their attributes, from the xCAT database. 
  * [noderm ](http://xcat.sourceforge.net/man1/noderm.1.html)\- removes the nodes in the noderange from all database table. 
  * [restorexCATdb](http://xcat.sourceforge.net/man1/restorexCATdb.1.html) \- restore the xCAT database. 
  * [rmdef ](http://xcat.sourceforge.net/man1/rmdef.1.html)\- remove xCAT data object definitions. 
  * [rmflexnode](http://xcat.sourceforge.net/man1/rmflexnode.1.html) \- Remove a flexible node. ( 2.5 or later) 
  * [runsqlcmd ](http://xcat.sourceforge.net/man1/runsqlcmd.8.html) \- Runs sql commands input from a file against the currect xCAT DB ( 2.5 or later) 
  * [tabdump](http://xcat.sourceforge.net/man8/tabdump.8.html) \- display an xCAT database table in CSV format. 
  * [tabedit](http://xcat.sourceforge.net/man8/tabedit.8.html) \- view an xCAT database table in an editor and make changes. 
  * [tabgrep](http://xcat.sourceforge.net/man1/tabgrep.1.html) \- list table names in which an entry for the given node appears. 
  * [tabprune](http://xcat.sourceforge.net/man8/tabprune.8.html) \- delete records from the eventlog and auditlog tables (2.4 or later). 
  * [tabrestore ](http://xcat.sourceforge.net/man8/tabrestore.8.html)\- replaces the contents of an xCAT database table with the contents in a csv file. 
  * [xcatstanzafile](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html) \- Format of a stanza file that can be used with xCAT data object definition commands. 

### Hardware Control

  * [getmacs](http://xcat.sourceforge.net/man1/getmacs.1.html) \- Collects node MAC address. 
  * [lshwconn](http://xcat.sourceforge.net/man1/lshwconn.1.html) \- Display the connection status for FSP and BPA nodes (2.3) 
  * [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) \- Discovers selected networked services information within the same subnet. 
  * [lsvm ](http://xcat.sourceforge.net/man1/lsvm.1.html)\- Lists partition profile information for HMC- and IVM-managed nodes. 
  * [mkhwconn](http://xcat.sourceforge.net/man1/mkhwconn.1.html) \- Sets up connections for FSP and BPA nodes to HMC nodes (2.3). 
  * [nodestat ](http://xcat.sourceforge.net/man1/nodestat.1.html)\- display the running status of a noderange 
  * [rbeacon ](http://xcat.sourceforge.net/man1/rbeacon.1.html)\- Turns beacon on/off/blink or gives status of a node or noderange. 
  * [rcons ](http://xcat.sourceforge.net/man1/rcons.1.html)\- remotely accesses the serial console of a node. 
  * [renergy ](http://xcat.sourceforge.net/man1/renergy.1.html) \- remote energy management tools (2.3) 
  * [replaycons](http://xcat.sourceforge.net/man1/replaycons.1.html) \- replay the console output for a node 
  * [reventlog](http://xcat.sourceforge.net/man1/reventlog.1.html) \- retrieve or clear remote hardware event logs 
  * [rflash ](http://xcat.sourceforge.net/man1/rflash.1.html)\- Performs Licensed Internal Code (LIC) update support for HMC-attached P5/P6 
  * [rmhwconn ](http://xcat.sourceforge.net/man1/rmhwconn.1.html) \- Remove the connections from the FSP and BPA nodes to the HMC nodes (2.3). 
  * [rmigrate](http://xcat.sourceforge.net/man1/rmigrate.1.html) \- Execute migration of a guest VM between hosts/hypervisors . 
  * [rmvm](http://xcat.sourceforge.net/man1/rmvm.1.html) \- Removes HMC- and IVM-managed partitions. 
  * [rnetboot](http://xcat.sourceforge.net/man1/rnetboot.1.html) \- Cause the range of nodes to boot to network. 
  * [rpower ](http://xcat.sourceforge.net/man1/rpower.1.html)\- remote power control of nodes 
  * [rscan](http://xcat.sourceforge.net/man1/rscan.1.html) \- Collects node information from one or more hardware control points. 
  * [rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html) \- Sets the boot device to be used for BMC-based servers for the next boot only. 
  * [rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html) \- configures various settings in the nodes' service processors. 
  * [rspreset](http://xcat.sourceforge.net/man1/rspreset.1.html) \- resets the service processors associated with the specified nodes 
  * [switchblade](http://xcat.sourceforge.net/man1/switchblade.1.html) \- reassign the BladeCenter media tray and/or KVM to the specified blade 
  * [wcons](http://xcat.sourceforge.net/man1/wcons.1.html) \- windowed remote console 
  * [wkill ](http://xcat.sourceforge.net/man1/wkill.1.html) \- kill windowed remote consoles 

### Monitoring

  * [monadd](http://xcat.sourceforge.net/man1/monadd.1.html) \- Registers a monitoring plug-in to the xCAT cluster. 
  * [moncfg](http://xcat.sourceforge.net/man1/moncfg.1.html) \- Configures a 3rd party monitoring software to monitor the xCAT cluster. 
  * [mondecfg](http://xcat.sourceforge.net/man1/mondecfg.1.html) \- Deconfigures a 3rd party monitoring software from monitoring the xCAT cluster. 
  * [monls ](http://xcat.sourceforge.net/man1/monls.1.html)\- Lists monitoring plug-in modules that can be used to monitor the xCAT cluster. 
  * [monrm](http://xcat.sourceforge.net/man1/monrm.1.html) \- Unregisters a monitoring plug-in module from the xCAT cluster. 
  * [monstart](http://xcat.sourceforge.net/man1/monstart.1.html) \- Starts a plug-in module to monitor the xCAT cluster. 
  * [monstop](http://xcat.sourceforge.net/man1/monstop.1.html) \- Stops a monitoring plug-in module to monitor the xCAT cluster. 
  * [regnotif ](http://xcat.sourceforge.net/man1/regnotif.1.html)\- Registers a Perl module or a command that will get called when changes occur in the desired xCAT database tables. 
  * [unregnotif ](http://xcat.sourceforge.net/man1/unregnotif.1.html)\- unregister a Perl module or a command that was watching for the changes of the desired xCAT database tables. 

### Inventory

  * [rinv ](http://xcat.sourceforge.net/man1/rinv.1.html)\- remote hardware inventory. 
  * [rvitals](http://xcat.sourceforge.net/man1/rvitals.1.html) \- retrieves remote hardware vitals information. 
  * [sinv ](http://xcat.sourceforge.net/man1/sinv.1.html)\- Checks the software configuration of the nodes in the cluster. 

### Parallel Commands

  * [pcons](http://xcat.sourceforge.net/man1/pcons.1.html) \- runs a command on the noderange using the out-of-band console. 
  * [pping](http://xcat.sourceforge.net/man1/pping.1.html) \- parallel ping. 
  * [ppping](http://xcat.sourceforge.net/man1/ppping.1.html) \- parallel ping between nodes in a cluster. 
  * [prsync](http://xcat.sourceforge.net/man1/prsync.1.html) \- parallel rsync 
  * [pscp](http://xcat.sourceforge.net/man1/pscp.1.html) \- parallel remote copy ( supports scp and not hierarchy) 
  * [psh](http://xcat.sourceforge.net/man1/psh.1.html) \- parallel remote shell ( supports ssh and not hierarchy) 
  * [pasu](http://xcat.sourceforge.net/man1/pasu.1.html) \- parallel ASU utility 
  * [xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html) \- concurrently copies files too and from multiple nodes. ( scp/rcp and hierarchy) 
  * [xdsh ](http://xcat.sourceforge.net/man1/xdsh.1.html) \- concurrently runs commands on multiple nodes. ( supports ssh/rsh and hierarchy) 
  * [xdshbak](http://xcat.sourceforge.net/man1/xdshbak.1.html)\- formats the output of the xdsh command. 
  * [xcoll](http://xcat.sourceforge.net/man1/xcoll.1.html) \- Formats command output of the psh, xdsh, rinv command 

### Deployment

  * [copycds-cdrom](http://xcat.sourceforge.net/man8/copycds-cdrom.8.html) \- client side wrapper for copycds supporting physical drives. 
  * [copycds ](http://xcat.sourceforge.net/man8/copycds.8.html)\- Copies Linux distributions and service levels from CDs to install directory. 
  * [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) \- Generates a stateless image to be used for a diskless install. 
  * [geninitrd](http://xcat.sourceforge.net/man1/geninitrd.1.html) \- Regenerates the initrd for a stateless image to be used for a diskless install. 
  * [imgexport - ](http://xcat.sourceforge.net/man1/imgexport.1.html)Exports an xCAT image (2.5+) 
  * [imgimport](http://xcat.sourceforge.net/man1/imgimport.1.html) \- Imports an xCAT image or configuration file into the xCAT tables (2.5+) 
  * [liteimg](http://xcat.sourceforge.net/man1/liteimg.1.html) \- Modify statelite image 
  * [mkdsklsnode](http://xcat.sourceforge.net/man1/mkdsklsnode.1.html) \- xCAT command to define and initialize AIX/NIM diskless machines. 
  * [mknimimage](http://xcat.sourceforge.net/man1/mknimimage.1.html) \- xCAT command to create AIX image definitions. 
  * [makeroutes](http://xcat.sourceforge.net/man8/makeroutes.8.html) \- connect nodes to the Management Node using Service node as gateway. ( 2.5+) 
  * [mknb](http://xcat.sourceforge.net/man8/mknb.8.html) \- creates a network boot root image for node discovery and flashing 
  * [nimnodecust ](http://xcat.sourceforge.net/man1/nimnodecust.1.html)\- xCAT command to customize AIX/NIM standalone machines. 
  * [nimnodeset ](http://xcat.sourceforge.net/man1/nimnodeset.1.html)\- xCAT command to initialize AIX/NIM standalone machines. 
  * [nodeset ](http://xcat.sourceforge.net/man8/nodeset.8.html)\- set the boot state for a noderange 
  * [packimage](http://xcat.sourceforge.net/man1/packimage.1.html) \- Packs the stateless image from the chroot file system. 
  * [rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html) \- Persistently sets the order of boot devices for BladeCenter blades. 
  * [rinstall](http://xcat.sourceforge.net/man8/rinstall.8.html) \- Begin installation on a noderange 
  * [rmdsklsnode](http://xcat.sourceforge.net/man1/rmdsklsnode.1.html) \- Use this xCAT command to remove AIX/NIM diskless machine definitions. 
  * [rmnimimage](http://xcat.sourceforge.net/man1/rmnimimage.1.html) \- xCAT command to remove an xCAT osimage definition and the associated NIM resources. 
  * [setupiscsidev](http://xcat.sourceforge.net/man8/setupiscsidev.8.html) \- creates a LUN for a node to boot up with, using iSCSI. 
  * [snmove](http://xcat.sourceforge.net/man1/snmove.1.html) \- moves nodes from one Service Node to another. ( 2.5 or later) 
  * [updateSNimage](http://xcat.sourceforge.net/man1/updateSNimage.1.html) \- (No longer used) Adds the needed Service Node configuration files to the install image. 
  * [updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html) \- Reruns postsctipts or runs additional scripts on the nodes. 
  * [winstall](http://xcat.sourceforge.net/man8/winstall.8.html) \- Begin installation on a noderange and display in wcons 
  * [xcat2nim](http://xcat.sourceforge.net/man1/xcat2nim.1.html) \- Use this command to create and manage AIX NIM definitions based on xCAT object definitions. 
  * [xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html)\- Use this command to modify an xCAT AIX diskless operating system image. (2.5) 
  * [chkosimage](http://xcat.sourceforge.net/man1/chkosimage.1.html)\- Use this command to check an osimage. (2.5 or later) 

### csm to xCAT migration tools

  * [csm2xcat](http://xcat.sourceforge.net/man1/csm2xcat.1.html)-Migrates a CSM database to a xCAT database. 
  * [cfm2xcat](http://xcat.sourceforge.net/man1/cfm2xcat.1.html) \- (2.3+)Migrates a CSM cfmupdatenode set to the xdcp -F sync files setup in xCAT. 
  * [groupfiles4dsh](http://xcat.sourceforge.net/man1/groupfiles4dsh.1.html)\- Creates a directory of nodegroup files to be used with AIX dsh. 

### Kit commands
 
  * [lskit](http://xcat.sourceforge.net/man1/lskit.1.html)\- Lists information for one or more Kits.

### Others

  * [lsxcatd](http://xcat.sourceforge.net/man1/lsxcatd.1.html) \- query xcatd daemon (2.6+) 
  * [makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html) \- Creates new dhcp configuration files and updates live dhcp configuration using omapi. 
  * [makedns](http://xcat.sourceforge.net/man8/makedns.8.html) \- sets up domain name services (DNS) from the entries in /etc/hosts. 
  * [makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html) \- sets up /etc/hosts from the xCAT hosts table. 
  * [makeconservercf](http://xcat.sourceforge.net/man8/makeconservercf.8.html) \- creates the conserver.cf configuration file and stops and starts conserver. 
  * [makeknownhosts ](http://xcat.sourceforge.net/man8/makeknownhosts.8.html) \- creates a ssh known_hosts file from the input node range. 
  * [makenetworks](http://xcat.sourceforge.net/man8/makenetworks.8.html) \- populates the xCAT networks table, using network information from the local system 
  * [mysqlsetup](http://xcat.sourceforge.net/man8/mysqlsetup.8.html) \- automatically setup of the MySQL database and xCAT to use MySql. 
  * [noderange](http://xcat.sourceforge.net/man3/noderange.3.html) \- Supported syntax for compactly expressing a list of node names. 
  * [pgsqlsetup](http://xcat.sourceforge.net/man8/pgsqlsetup.8.html) \- ( 2.5 or later)automatically setup of the PostgreSQL database and xCAT to use PostgreSQL. 
  * [xcatconfig](http://xcat.sourceforge.net/man8/xcatconfig.8.html) \- setups up MN during install. Can be used to reinitialize keys, credentials, site table after install. 
  * [xcatd](http://xcat.sourceforge.net/man8/xcatd.8.html) \- xCAT daemon 
  * [xcatstart](http://xcat.sourceforge.net/man1/xcatstart.1.html) \- Starts the xCAT daemon (xcatd) on AIX ( removed in xCAT2.4) 
  * [xcatstop](http://xcat.sourceforge.net/man1/xcatstop.1.html) \- Stops the xCAT daemon (xcatd) on AIX. (removed in xCAT2.4) 
  * [restartxcatd](http://xcat.sourceforge.net/man1/xcatstart.1.html) \- restart the xCAT daemon (xcatd) on AIX. (xCAT2.4 or later) 
  * [xcatchroot](http://xcat.sourceforge.net/man1/xcatchroot.1.html) \- AIX command (2.4+) to modify an xCAT diskless operating system image. 
  * [xCATWorld](http://xcat.sourceforge.net/man1/xCATWorld.1.html) \- Sample client program for xCAT. 
  * [xpbsnodes](http://xcat.sourceforge.net/man1/xpbsnodes.1.html) \- PBS pbsnodes front-end for a noderange. 
  * [Summary of xCAT Commands](http://xcat.sourceforge.net/man1/xcat.1.html)
