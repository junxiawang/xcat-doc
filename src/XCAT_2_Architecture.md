<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2 Overall Architecture](#xcat-2-overall-architecture)
  - [Client/Server](#clientserver)
  - [Flow](#flow)
  - [xcatd Plugins](#xcatd-plugins)
  - [Additional notes](#additional-notes)
  - [Database](#database)
  - [Portability](#portability)
- [Node Deployment](#node-deployment)
- [HPC Stack Install, Config, Monitor](#hpc-stack-install-config-monitor)
- [Monitoring](#monitoring)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## xCAT 2 Overall Architecture

An overview and architecture of xCAT from a user's perspective can be found at [XCAT_Overview,_Architecture,_and_Planning]. 

The rest of this document is oriented toward the xCAT developer... 

The heart of the xCAT architecture is the xCAT daemon (xcatd) on the management node. This receives requests from the client, validates the requests, and then invokes the operation. The xcatd daemon also receives status and inventory info from the nodes as they are being discovered and installed/booted.  
[File:xCAT-Architecture.png] 

### Client/Server

### Flow

  * User invokes an xcat cmd on the client 
  * The cmd can either be a sym link to xcatclient/xcatclientnnr or a thin wrapper that calls xCAT::Client::submit_request(). 
  * The xcatclient cmd packages the info into xml and passes it to xcatd 
  * xcatd receives the request and forks to process the request 
  * The ACL/Role Policy Engine determines whether this person is allowed to execute this request. It evaluates the following info: 
    * The cmd name and args 
    * Who executed the cmd on the client machine 
    * The hostname/IP address of the client machine 
    * The node range passed to the cmd 
  * If the ACL check is approved, the cmd is passed to the Queue (this part is not yet fully implemented): 
    * The queue can run the action in either of 2 modes. The client cmd wrapper decides which mode to use (although it can give the user a flag to specify): 
      * Keep the socket connection with the client open for the life of the action and continue to send back the output of the action as it is produced. 
      * Initiate the action, pass the action ID back to the client, and close the connection. At any subsequent time, the client can use the action ID to request the status and output of the action. This is intended long running cmds. **This mode hasn't been implemented yet.**
    * The Queue logs every action performed, including date/time, cmd name, arguments, who, etc. **Not implemented yet.**
    * In phase 2, the Queue will support locking (semaphores) to serialize actions that should not be run simultaneously. 
  * To invoke the action, the xml is passed to the appropriate plugin pm, which performs the action and returns results to the client 

### xcatd Plugins

  * When xcatd starts, it loads all of the plugins from /opt/xcat/lib/perl/xCAT_plugin and invokes handled_commands() to see which cmds each pm handles. 
  * When a command is run by the user, xcatd passes it to the corresponding plugin by 1st calling preprocess_request() to determine if this request should also be sent to some service nodes 
  * Next it calls process_request() of the plugin on each machine indicated by the return structure of preprocess_request(). 
  * The plugin is passed a callback that it uses to return output to the client. 
  * Bypass Mode: 
    * If a user is running as root on the Management Node, the client/server daemon communication can be bypassed by setting an environment variable. If the XCATBYPASS environment variable is set, the connection to the server/daemon will be bypassed and the plugin will be called directly by Client.pm. If it is set to a directory, all perl modules in that directory will be loaded in as plugins. If it is set to any other value (e.g. "yes", "default", whatever string you want) the default plugin directory will be used. 

### Additional notes

  * The p cmds have the option of not going thru xcatd (i.e. going straight from the client to the nodes) so that they can run as the real user invoking the cmd (not as root). 
  * Reasons for client/server split: 
    * implement access controls and roles for non-root users 
    * don't require non-root users to have ids on the mgmt node 
    * access to xcat mgmt server info from the nodes w/o nfs 
    * ability to run the web server for the UI on a different machine from the mgmt svr 
  * Performance/scaling of xcatd: 
    * xcatd must listen on a different port for node requests vs. user/client/cmd requests 

### Database

  * xCAT will use perl dbi to access the database, so that any database can be used to store the xCAT tables. SQLite is the default database. 
  * The tabedit cmd is provided to simulate the 1.x table format. 
  * All xCAT code should use Table.pm to access the tables. Table.pm will implement the following features: 
    * Notifications for table changes (triggers): There will be a separate table (called subscriptions?) that lists the table name (or \\*) and a cmd that will be run whenever that table is changed. When the cmd is run, the changed rows will be piped into its stdin. 
    * A begin/end mechanism that xCAT code can use when it knows it will be updating a lot of rows. This can allow Table.pm to optimize the update to the database and call the notifications just once for all the updates. 
  * Need to support other non-perl programs reading the database using packages like ODBC (for C program access). 

### Portability

  * Need to localize the HW and OS differences into a few pm's and files. 
    * Examples of this from CSM are OSDefs.pm and Pkgdefs.pm 
    * Still discussing this design... 

## Node Deployment

  * **This section is not entirely accurate.**
  * Will use our own boot kernel (based on CentOS 5) and kexec for deployment booting on all platforms that will support this. In exception cases, will stick to essentially the xCAT 1.3 model. 
  * Need a standard way to represent image definitions across platforms, and some common image management commands. Have set up an osimage table in the DB for this. 
  * 2.0 will use its own diskless/stateless node support. 
  * Need to describe the features of fault tolerant install - Egan 
  * During node deployment, the boot kernel can collect HW inventory info and send it back to xcatd to have it stored in the database. 
  * Discovery: 
    * Use SLP (Service Location Protocol) for finding hw ctrl points (e.g. MMs, RSAs, HMC, FSPs) 
    * Use querying of hw ctrl points or autonode to discover nodes and automatically add them to the database. 

[Image:Xcat-deployment-framework.gif] 

## HPC Stack Install, Config, Monitor

  * HPC Stack Install: handled through image management using xCAT IBM HPC Integration. See 

[IBM_HPC_Stack_in_an_xCAT_Cluster] 

  * STAB/SCAB - can use for AIX HPC benchmarking 

## Monitoring

  * xCAT will support a monitoring plug-in framework so that users will have a choice about which monitoring subsystem to use with xCAT (or none at all). Plugin wrappers will be provided for RMC, Ganglia, Nagios, and maybe others. 
  * xCAT needs some basic built in monitoring (state monitor) for ping status, sshd status, install state, etc. 
  * See the [Monitoring howto](http://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/share/doc/xCAT2-Monitoring.pdf) for more info. 
